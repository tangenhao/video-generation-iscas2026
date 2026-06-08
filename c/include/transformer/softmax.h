#pragma once

#include "addr_for_transformer.h"
#include "common/insn.h"
#include "common/type_utils.h"
#include "vcu/vcu_opcode.h"
#include "vcu/vcu_insn.h"
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <cmath>

namespace transformer {
namespace softmax {

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

template<typename T>
std::string to_string_with_precision(const T a_value, const int n = 6)
{
  std::ostringstream out;
  out << std::fixed << std::setprecision(n) << a_value;
  return out.str();
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

template<bool DEBUG = false>
struct SoftmaxOp {

  static constexpr int MAX_PSUM_DEPTH = DEFAULT_MAX_PSUM_DEPTH;

  int oc_group_size;     
  int bytes_input;
  int bytes_output;
  
  struct Argument {
    int seq_len;          
    int d_model;     
    int tile_m;
    int block_oc_group;
    DType dtype;
    uint64_t input_base_addr;     
    uint64_t output_base_addr;     
    uint64_t vcu_code_base_addr;
    uint64_t rec_lut_base_addr   = REC_LUT_ADDR;
    uint64_t exp_lut_base_addr   = EXP_LUT_ADDR;
    uint64_t all_done = 1;
  };

  SoftmaxOp()
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

    /** fp32 or fp16 */
    bytes_input = (args.dtype == kFloat32) ? 4 : 2;
    bytes_output = (args.dtype == kFloat32) ? 4 : 2;

    this->set_vcucode(vcucode_series);
    size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
    size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
    vcucode_series.resize(vcucode_ddr_lines * 8, 0);

    /** Load vcu code */   
    insn_series.push_back(load_iteration_2<0>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

    /** Load vculut */
    insn_series.push_back(load_iteration_2<0>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    insn_series.push_back(load_iteration_2<0>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64 * 128 / 256, 0));

    /** Vcu Config */
    using vcu_cfg_t               = vcu::VcuConfig;  
    vcu_cfg_t::Arguments cfg_args = {0, 0, 0, 1, 0, 0, 0, 0, 0, 0};
    vcu_cfg_t            vcu_cfg;
    auto                 vcu_cfg_insns = vcu_cfg(cfg_args);
    insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());
    
    this->compute_softmax(insn_series, vcucode_series, args);
    
    return {insn_series, vcucode_series};
  }

  void set_vcucode(std::vector<uint64_t>& vcucode_series)
  {
    /** Softmax VCU操作码序列 */
    auto softmax_code = vcu::asm_vcu_op({
      "config reg0, 0.0",  // 0: 初始配置，写入vcures，seq_len = seq_len, oc_group = 1

      "mulc psum, reg0, " + to_string_with_precision(std::log2(exp(1.0f)), 7), // 1: 计算输入 * ln(e)/ln(2)，写入psum，seq_len = seq_len, oc_group = oc_group
      "exp2 reg0, reg0",   // 2: 计算exp2，写入psum，seq_len = seq_len, oc_group = oc_group

      "redsum psum, reg0, 32",  // 3: 32元素规约求和
      "add reg0 resadd, reg1",  // 4: 累加结果，写入vcures，seq_len = seq_len，重复oc_group次

      "rec resadd, reg0",  // 5: 计算倒数，写入vcures，seq_len = seq_len, oc_group = 1

      "mul psum resadd, reg0",  // 6: 乘以倒数，写入psum，seq_len = seq_len, oc_group = 1，重复oc_group次
    });

    for(auto code : softmax_code) {
      vcucode_series.push_back(code);
    }
  }

  void compute_softmax(std::vector<instruction>& insn_series, const std::vector<uint64_t>& vcucode_series, const Argument& args)
  {
    int oc_group = args.d_model / oc_group_size;

    /** The number of iterations on each dimension */
    int m_iterations = ceil((double)args.seq_len / (double)args.tile_m);
    int oc_iterations = ceil((double)oc_group / (double)args.block_oc_group);

    if (DEBUG) {
      print("======== Softmax Iteration Setting ========");
      print_dec("tile_m", args.tile_m);
      print_dec("block_oc_group", args.block_oc_group);
      print_dec("m_iterations", m_iterations);
      print_dec("oc_iterations", oc_iterations);
    }

    if(args.tile_m * args.block_oc_group > MAX_PSUM_DEPTH) {
      std::throw_with_nested(std::runtime_error("softmax: tile_m * block_oc_group > MAX_PSUM_DEPTH"));
    }

    for (int m_iter = 0; m_iter < m_iterations; m_iter++) { 
      /** valid_item_seq_len is the actual seq_len for each iteration */
      u_int64_t valid_item_seq_len = (m_iter * args.tile_m + args.tile_m) <= args.seq_len ? args.tile_m : args.seq_len - m_iter * args.tile_m;
      
      /** Vcu Execute */
      using vcu_t = vcu::VcuExecute;
      vcu_t vcu_op;
      /** ============ Step 0: Reset VCURES Sram ============ */
      vcu_t::Arguments step_0_config_args = {
        vcu_psum_dtype.at(args.dtype),                  
        vcu_resadd_dtype.at(args.dtype),                  
        vcu_out_dtype.at(args.dtype),                  
        VcuOutSram::VCURES,                   
        1,         // opcode_number
        0,         // opcode_addr
        0,         // psum_in_addr
        0,         // para_in_addr
        0,         // resadd_in_addr
        0,         // ram_out_addr
        valid_item_seq_len - 1,  // seq_len
        0,                           // oc_group
        0,                          // para_func
        0,                      
        0,                      
        0
      };
      auto step_0_config_insns = vcu_op(step_0_config_args);
      insn_series.insert(insn_series.end(), step_0_config_insns.begin(), step_0_config_insns.end());
      
      /** -------------------------First loop for oc_group------------------------- */
      for (int oc_iter = 0; oc_iter < oc_iterations; oc_iter++){
        /** valid_item_oc_group is the actual oc_group_size for each iteration */
        u_int64_t valid_item_oc_group = (oc_iter * args.block_oc_group + args.block_oc_group) <= oc_group ? args.block_oc_group : oc_group - oc_iter * args.block_oc_group;

        if (DEBUG) {
          print("======== Softmax Computation Iteration ========");
          print_dec("oc_iter", oc_iter);
          print_dec("m_iter", m_iter);
          print_dec("valid_item_seq_len", valid_item_seq_len);
          print_dec("valid_item_oc_group", valid_item_oc_group);
        }
        
        /** Compute offset of input: the input is stored in the format of [d_model/oc_group_size, seq_len, oc_group_size]*/
        uint64_t input_ddr_addr = (oc_iter * args.block_oc_group) * args.seq_len * oc_group_size * bytes_input
                                  + m_iter * args.tile_m * oc_group_size * bytes_input + args.input_base_addr;
        auto input_ddr_offset = split_exp_fra(args.seq_len * oc_group_size * bytes_input);

        /** Load input */
        auto load_input = load_iteration_2<0>(input_ddr_addr,
                                              valid_item_seq_len * oc_group_size * bytes_input / 32 - 1,
                                              input_ddr_offset.first,
                                              input_ddr_offset.second,
                                              valid_item_oc_group - 1,
                                              MASTER_PSUM_ADDR, 0);
        insn_series.push_back(load_input);
        
        /** ============ Step 1: Exp operation (exp2(input * ln(e)/ln(2))) ============*/
        vcu_t::Arguments step_1_exp_args = {
          vcu_out_dtype.at(args.dtype),                  
          vcu_resadd_dtype.at(args.dtype),                  
          vcu_out_dtype.at(args.dtype),                 
          VcuOutSram::PSUM,                   
          2,                      // opcode_number
          1,                      // opcode_addr
          0,                      // psum_in_addr
          0,                      // para_in_addr
          0,                      // resadd_in_addr
          0,                      // ram_out_addr
          valid_item_seq_len - 1,  // seq_len
          valid_item_oc_group - 1, // oc_group
          0,                      // para_func
          1,                      
          0,                      
          0
        };
        auto step_1_exp_insns = vcu_op(step_1_exp_args);
        insn_series.insert(insn_series.end(), step_1_exp_insns.begin(), step_1_exp_insns.end());

        /** Store result */
        uint64_t exp_ddr_addr = (oc_iter * args.block_oc_group) * args.seq_len * oc_group_size * bytes_output
                                  + m_iter * args.tile_m * oc_group_size * bytes_output + args.input_base_addr;
        auto exp_ddr_offset = split_exp_fra(args.seq_len * oc_group_size * bytes_output);
        insn_series.push_back(store_iteration_2<0>(
                                    exp_ddr_addr, 
                                    valid_item_seq_len * oc_group_size * bytes_output / 32 - 1, 
                                    exp_ddr_offset.first, 
                                    exp_ddr_offset.second, 
                                    valid_item_oc_group - 1, 
                                    MASTER_PSUM_ADDR, 
                                    (m_iter == m_iterations - 1) && (oc_iter == oc_iterations - 1) && args.all_done));

        /** ============ Step 2: Reduction sum for each oc_group ============ */
        for (uint64_t i = 0; i < valid_item_oc_group; ++i) {
          vcu_t::Arguments step_2_redsum_args = {
            vcu_out_dtype.at(args.dtype),                  
            vcu_resadd_dtype.at(args.dtype),                  
            vcu_out_dtype.at(args.dtype),                 
            VcuOutSram::VCURES,                   
            2,                      // opcode_number
            3,                      // opcode_addr
            i * valid_item_seq_len, // psum_in_addr
            0,                      // para_in_addr
            0,                      // resadd_in_addr
            0,                      // ram_out_addr
            valid_item_seq_len - 1,  // seq_len
            0,                      // oc_group
            0,                      // para_func
            1,                      
            1,                      
            0
          };
          auto step_2_redsum_insns = vcu_op(step_2_redsum_args);
          insn_series.insert(insn_series.end(), step_2_redsum_insns.begin(), step_2_redsum_insns.end());
        }
      } // end of first loop for oc_group

      /** ============ Step 3: Reciprocal operation ============ */
      vcu_t::Arguments step_3_reciprocal_args = {
        vcu_out_dtype.at(args.dtype),                  
        vcu_resadd_dtype.at(args.dtype),                  
        vcu_out_dtype.at(args.dtype),                  
        VcuOutSram::VCURES,                   
        1,                      // opcode_number
        5,                      // opcode_addr
        0,                      // psum_in_addr
        0,                      // para_in_addr
        0,                      // resadd_in_addr
        0,                      // ram_out_addr
        valid_item_seq_len - 1,  // seq_len
        0,                      // oc_group
        0,                      // para_func
        0,                      
        1,                      
        0
      };
      auto step_3_reciprocal_insns = vcu_op(step_3_reciprocal_args);
      insn_series.insert(insn_series.end(), step_3_reciprocal_insns.begin(), step_3_reciprocal_insns.end());

      /** -------------------------Second loop for oc_group------------------------- */
      for (int oc_iter = 0; oc_iter < oc_iterations; oc_iter++) { 
        /** valid_item_oc_group is the actual oc_group_size for each iteration */
        u_int64_t valid_item_oc_group = (oc_iter * args.block_oc_group + args.block_oc_group) <= oc_group ? args.block_oc_group : oc_group - oc_iter * args.block_oc_group;

        /** Compute offset of input: the input is stored in the format of [d_model/oc_group_size, seq_len, oc_group_size]*/
        uint64_t input_ddr_addr = (oc_iter * args.block_oc_group) * args.seq_len * oc_group_size * bytes_input
                                  + m_iter * args.tile_m * oc_group_size * bytes_input + args.input_base_addr;
        auto input_ddr_offset = split_exp_fra(args.seq_len * oc_group_size * bytes_input);

        /** Load input */
        auto load_input = load_iteration_2<0>(input_ddr_addr,
                                              valid_item_seq_len * oc_group_size * bytes_input / 32 - 1,
                                              input_ddr_offset.first,
                                              input_ddr_offset.second,
                                              valid_item_oc_group - 1,
                                              MASTER_PSUM_ADDR, 0);
        insn_series.push_back(load_input);

        /** Step 4: Multiply with reciprocal for each oc_group */
        for (uint64_t i = 0; i < valid_item_oc_group; ++i) {
          vcu_t::Arguments step_4_mul_args = {
            vcu_out_dtype.at(args.dtype),                  
            vcu_resadd_dtype.at(args.dtype),                  
            vcu_out_dtype.at(args.dtype),                 
            VcuOutSram::PSUM,                   
            1,                      // opcode_number
            6,                      // opcode_addr
            i * valid_item_seq_len,  // psum_in_addr
            0,                      // para_in_addr
            0,                      // resadd_in_addr
            i * valid_item_seq_len,  // ram_out_addr
            valid_item_seq_len - 1,  // seq_len
            0,                      // oc_group
            0,                      // para_func
            1,                      
            1,                      
            0
          };
          auto step_4_mul_insns = vcu_op(step_4_mul_args);
          insn_series.insert(insn_series.end(), step_4_mul_insns.begin(), step_4_mul_insns.end());
        }

        /** Store result */
        uint64_t output_ddr_addr = (oc_iter * args.block_oc_group) * args.seq_len * oc_group_size * bytes_output
                                  + m_iter * args.tile_m * oc_group_size * bytes_output + args.output_base_addr;
        auto output_ddr_offset = split_exp_fra(args.seq_len * oc_group_size * bytes_output);
        insn_series.push_back(store_iteration_2<0>(
                                    output_ddr_addr, 
                                    valid_item_seq_len * oc_group_size * bytes_output / 32 - 1, 
                                    output_ddr_offset.first, 
                                    output_ddr_offset.second, 
                                    valid_item_oc_group - 1, 
                                    MASTER_PSUM_ADDR, 
                                    (m_iter == m_iterations - 1) && (oc_iter == oc_iterations - 1) && args.all_done));
      } // end of second loop for oc_group
    } // end of loop for m_iter
  }
};

} // namespace softmax
} // namespace transformer
