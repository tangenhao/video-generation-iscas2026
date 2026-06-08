#pragma once

#include "common/insn.h"
#include "common/type_utils.h"
#include "vcu/vcu_opcode.h"
#include "vcu/vcu_insn.h"
#include "addr.h"
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <unordered_map>
#include <cmath>

namespace vcu {
namespace operation {

using namespace common::insn;

void print_dec(std::string str, int num, std::ostream& os = std::cout)
{
  os << std::dec << str << ": " << num << std::endl;
}

void print_hex(std::string str, uint64_t num, std::ostream& os = std::cout)
{
  os << std::hex << str << ": 0x" << num << std::endl;
}

void print(std::string str, std::ostream& os = std::cout)
{
  os << str << std::endl;
}

void print(instruction insn, std::ostream& os = std::cout)
{
  os << insn << std::endl;
}

std::pair<int, int> split_exp_fra(int64_t x)
{
  if (x > 8355840) {
    std::throw_with_nested(std::runtime_error("x is too large"));
  }
  int max_exp = (1 << 4) - 1;
  int max_fra = (1 << 8) - 1;
  int exp     = 0;
  while (x > max_fra) {
    x /= 2;
    exp++;
  }
  return {exp, x};
}

enum OP_TYPE : int32_t {
  ADD = 0,
  MUL = 1,
  CONVERT = 2
};

template<bool DEBUG = false>
struct SingleVCUOp {

  static constexpr int MAX_PSUM_DEPTH = DEFAULT_MAX_PSUM_DEPTH;
  static constexpr int MAX_OFMAP_DEPTH = DEFAULT_MAX_OFMAP_DEPTH;
 
  int oc_group_size;
  int bytes_input;
  int bytes_output;
  
  struct Argument {
    int seq_len;         
    int d_model;          
    int tile_m;           
    int block_oc_group;   
    DType dtype;          
    OP_TYPE op_type;
    uint64_t input1_base_addr;  
    uint64_t input2_base_addr = 0;  
    uint64_t output_base_addr;  
    uint64_t vcu_code_addr;     
    uint64_t all_done = 1;      
  };

  SingleVCUOp()
  {
    /** Default float32 */
    oc_group_size = 32;
    bytes_input = 4;
    bytes_output = 4;
  }

  std::pair<std::vector<instruction>, std::vector<uint64_t>> operator()(const Argument& args)
  {
    std::vector<instruction> insn_series;
    std::vector<uint64_t> vcucode_series;

    /** set vcu code */
    this->set_vcucode(vcucode_series, args);
    size_t vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
    size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
    vcucode_series.resize(vcucode_ddr_lines * 8, 0);

    /** load vcu code */
    insn_series.push_back(load_iteration_2<0>(args.vcu_code_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

    /** config vcu */
    using vcu_cfg_t = vcu::VcuConfig;
    vcu_cfg_t::Arguments cfg_args = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    vcu_cfg_t vcu_cfg;
    auto vcu_cfg_insns = vcu_cfg(cfg_args);
    insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());
    
    /** compute single vcu */
    if (args.op_type == OP_TYPE::CONVERT) {
      this->ToFloat16_with_Parallelism(insn_series, args);
    }
    else {
      this->compute_single_vcu(insn_series, args);
    }
    
    return {insn_series, vcucode_series};
  }

private:
  void set_vcucode(std::vector<uint64_t>& vcucode_series, const Argument& args)
  {
    /** generate vcu code */
    /** add */
    if (args.op_type == OP_TYPE::ADD) {
      vcucode_series = vcu::asm_vcu_op({
        "add psum resadd, reg0",  
      });
    }
    /** mul */
    else if (args.op_type == OP_TYPE::MUL) {
      vcucode_series = vcu::asm_vcu_op({
        "mul psum resadd, reg0",  
      });
    }
    /** copy */
    else if (args.op_type == OP_TYPE::CONVERT) {
      vcucode_series = vcu::asm_vcu_op({
        "copy psum, reg0",  
      });
    }
    else {
      std::throw_with_nested(std::runtime_error("SingleVCUOp: invalid op_type"));
    }
  }

  void ToFloat16_with_Parallelism(std::vector<instruction>& insn_series, const Argument& args)
  {
    int bytes_input = 4;        //fp32
    int bytes_output = 2;       //fp16
    int oc_group = args.d_model / oc_group_size;
    int oc_group_scale = 2;

    /** compute iterations */
    int m_iterations = std::ceil((double)args.seq_len / (double)args.tile_m);
    int oc_iterations = std::ceil((double)oc_group / (double)args.block_oc_group);

    if (DEBUG) {
      print("======== ToFloat16_with_Parallelism Iteration Setting ========");
      print_dec("tile_m", args.tile_m);
      print_dec("block_oc_group", args.block_oc_group);
      print_dec("m_iterations", m_iterations);
      print_dec("oc_iterations", oc_iterations);
    }

    /** check tiling parameters */
    if(args.tile_m * args.block_oc_group > MAX_PSUM_DEPTH) {
      std::throw_with_nested(std::runtime_error("ToFloat16_with_Parallelism: tile_m * block_oc_group > MAX_PSUM_DEPTH"));
    }
    if(args.tile_m * args.block_oc_group * oc_group_scale > MAX_OFMAP_DEPTH) {
      std::throw_with_nested(std::runtime_error("ToFloat16_with_Parallelism: tile_m * block_oc_group * oc_group_scale > MAX_OFMAP_DEPTH"));
    }

    /** compute tiled */
    for (int oc_iter = 0; oc_iter < oc_iterations; oc_iter++) {
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) { 
        /** compute valid item */
        u_int64_t valid_item_seq_len = (m_iter * args.tile_m + args.tile_m) <= args.seq_len ? 
                                       args.tile_m : args.seq_len - m_iter * args.tile_m;
        u_int64_t valid_item_oc_group = (oc_iter * args.block_oc_group + args.block_oc_group) <= oc_group ? 
                                        args.block_oc_group : oc_group - oc_iter * args.block_oc_group;

        if (DEBUG) {
          print("======== ToFloat16_with_Parallelism Computation Iteration ========");
          print_dec("oc_iter", oc_iter);
          print_dec("m_iter", m_iter);
          print_dec("valid_item_seq_len", valid_item_seq_len);
          print_dec("valid_item_oc_group", valid_item_oc_group);
        }
        
        /** compute input1 address offset */
        uint64_t input1_ddr_addr = (oc_iter * args.block_oc_group) * args.seq_len * oc_group_size * bytes_input
                                  + m_iter * args.tile_m * oc_group_size * bytes_input + args.input1_base_addr;
        auto input1_ddr_offset = split_exp_fra(args.seq_len * oc_group_size * bytes_input);
        
        /** load input1 */
        auto load_input1 = load_iteration_2<0>(input1_ddr_addr,
                                              valid_item_seq_len * oc_group_size * bytes_input / 32 - 1,
                                              input1_ddr_offset.first,
                                              input1_ddr_offset.second,
                                              valid_item_oc_group - 1,
                                              MASTER_PSUM_ADDR, 0);
        insn_series.push_back(load_input1);
                
        /** execute vcu */
        using vcu_t = vcu::VcuExecute;
        vcu_t vcu_op;

        /** fp32 to fp16 */
        vcu_t::Arguments add_args = {
          vcu_psum_dtype[kFloat32],      // psum_data_type
          vcu_resadd_dtype[kHalf],    // resadd_para_type
          vcu_out_dtype[kHalf],       // data_out_type
          VcuOutSram::PSUM,                // data_out_ram
          1,                               // opcode_number
          0,                               // opcode_addr
          0,                               // psum_in_addr
          0,                               // para_in_addr
          0,                               // resadd_in_addr
          0,                               // ram_out_addr
          valid_item_seq_len - 1,          // seq_len
          valid_item_oc_group - 1,         // oc_group
          0                                // para_func
        };
                               
        auto add_insns = vcu_op(add_args);
        insn_series.insert(insn_series.end(), add_insns.begin(), add_insns.end());

        auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_oc_group, valid_item_oc_group * 2);
        vcu_convert.set_insn_number(0);
        insn_series.push_back(vcu_convert);

        /** compute output address offset */
        uint64_t output_ddr_addr = (oc_iter * args.block_oc_group * oc_group_scale) * args.seq_len * (oc_group_size / oc_group_scale) * bytes_output
                                  + m_iter * args.tile_m * (oc_group_size / oc_group_scale) * bytes_output + args.output_base_addr;
        auto output_ddr_offset = split_exp_fra(args.seq_len * (oc_group_size / oc_group_scale) * bytes_output);
        
        /** store result */
        insn_series.push_back(store_iteration_2<0>(
          output_ddr_addr, 
          valid_item_seq_len * (oc_group_size / oc_group_scale) * bytes_output / 32 - 1, 
          output_ddr_offset.first, 
          output_ddr_offset.second, 
          (valid_item_oc_group * oc_group_scale) - 1, 
          MASTER_OFMAP_ADDR, 
          (m_iter == m_iterations - 1) && (oc_iter == oc_iterations - 1) && args.all_done));
      }
    }
  } 

  void compute_single_vcu(std::vector<instruction>& insn_series, const Argument& args)
  {
    bytes_input = 4;
    int oc_group = args.d_model / oc_group_size;

    /** compute iterations */
    int m_iterations = std::ceil((double)args.seq_len / (double)args.tile_m);
    int oc_iterations = std::ceil((double)oc_group / (double)args.block_oc_group);

    if (DEBUG) {
      print("======== SingleVCUOp Iteration Setting ========");
      print_dec("tile_m", args.tile_m);
      print_dec("block_oc_group", args.block_oc_group);
      print_dec("m_iterations", m_iterations);
      print_dec("oc_iterations", oc_iterations);
    }
    
    /** check tiling parameters */
    if(args.tile_m * args.block_oc_group > MAX_PSUM_DEPTH) {
      std::throw_with_nested(std::runtime_error("SingleVCUOp: tile_m * block_oc_group > MAX_PSUM_DEPTH"));
    }

    /** compute tiled */
    for (int oc_iter = 0; oc_iter < oc_iterations; oc_iter++) { 
       for (int m_iter = 0; m_iter < m_iterations; m_iter++) { 
      
        /** compute valid item */
        u_int64_t valid_item_seq_len = (m_iter * args.tile_m + args.tile_m) <= args.seq_len ? 
                                       args.tile_m : args.seq_len - m_iter * args.tile_m;
        u_int64_t valid_item_oc_group = (oc_iter * args.block_oc_group + args.block_oc_group) <= oc_group ? 
                                        args.block_oc_group : oc_group - oc_iter * args.block_oc_group;

        if (DEBUG) {
          print("======== SingleVCUOp Computation Iteration ========");
          print_dec("oc_iter", oc_iter);
          print_dec("m_iter", m_iter);
          print_dec("valid_item_seq_len", valid_item_seq_len);
          print_dec("valid_item_oc_group", valid_item_oc_group);
        }
        
        /** compute input1 address offset */
        uint64_t input1_ddr_addr = (oc_iter * args.block_oc_group) * args.seq_len * oc_group_size * bytes_input
                                  + m_iter * args.tile_m * oc_group_size * bytes_input + args.input1_base_addr;
        auto input1_ddr_offset = split_exp_fra(args.seq_len * oc_group_size * bytes_input);
        
        /** compute input2 address offset */
        uint64_t input2_ddr_addr = (oc_iter * args.block_oc_group) * args.seq_len * oc_group_size * bytes_input
                                  + m_iter * args.tile_m * oc_group_size * bytes_input + args.input2_base_addr;
        auto input2_ddr_offset = split_exp_fra(args.seq_len * oc_group_size * bytes_input);

        /** load input1 */
        auto load_input1 = load_iteration_2<0>(input1_ddr_addr,
                                              valid_item_seq_len * oc_group_size * bytes_input / 32 - 1,
                                              input1_ddr_offset.first,
                                              input1_ddr_offset.second,
                                              valid_item_oc_group - 1,
                                              MASTER_PSUM_ADDR, 0);
        insn_series.push_back(load_input1);
        
        /** load input2 */
        auto load_input2 = load_iteration_2<0>(input2_ddr_addr,
                                              valid_item_seq_len * oc_group_size * bytes_input / 32 - 1,
                                              input2_ddr_offset.first,
                                              input2_ddr_offset.second,
                                              valid_item_oc_group - 1,
                                              MASTER_VCURES_ADDR, 0);
        insn_series.push_back(load_input2);
        
        /** execute vcu */
        using vcu_t = vcu::VcuExecute;
        vcu_t vcu_op;

        /** compute */
        vcu_t::Arguments add_args = {
          vcu_psum_dtype.at(args.dtype),      // psum_data_type
          vcu_resadd_dtype.at(args.dtype),    // resadd_para_type
          vcu_out_dtype.at(args.dtype),       // data_out_type
          VcuOutSram::PSUM,                // data_out_ram
          1,                               // opcode_number
          0,                               // opcode_addr
          0,                               // psum_in_addr
          0,                               // para_in_addr
          0,                               // resadd_in_addr
          0,                               // ram_out_addr
          valid_item_seq_len - 1,          // seq_len
          valid_item_oc_group - 1,         // oc_group
          0                                // para_func
        };
                               
        auto add_insns = vcu_op(add_args);
        insn_series.insert(insn_series.end(), add_insns.begin(), add_insns.end());

        /** compute output address offset */
        uint64_t output_ddr_addr = (oc_iter * args.block_oc_group) * args.seq_len * oc_group_size * bytes_output
                                  + m_iter * args.tile_m * oc_group_size * bytes_output + args.output_base_addr;
        auto output_ddr_offset = split_exp_fra(args.seq_len * oc_group_size * bytes_output);
        
        /** store result */
        insn_series.push_back(store_iteration_2<0>(
          output_ddr_addr, 
          valid_item_seq_len * oc_group_size * bytes_output / 32 - 1, 
          output_ddr_offset.first, 
          output_ddr_offset.second, 
          valid_item_oc_group - 1, 
          MASTER_PSUM_ADDR, 
          (m_iter == m_iterations - 1) && (oc_iter == oc_iterations - 1) && args.all_done));
      }
    }
  }
};

} // namespace operation
} // namespace vcu

