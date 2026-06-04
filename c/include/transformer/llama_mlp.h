#pragma once

#include "addr_for_llama.h"
#include "common/insn.h"
#include "common/type_utils.h"
#include "vcu/vcu_opcode.h"
#include "vcu/vcu_insn.h"
#include "pea/pea_insn.h"
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <cmath>

namespace transformer {
namespace llama_mlp {

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
struct LlamaMlpOp {

  static constexpr int MAX_IFMAP_DEPTH  = DEFAULT_MAX_IFMAP_DEPTH;
  static constexpr int MAX_WEIGHT_DEPTH = DEFAULT_MAX_WEIGHT_DEPTH;
  static constexpr int MAX_PSUM_DEPTH   = DEFAULT_MAX_PSUM_DEPTH;
  static constexpr int MAX_OFMAP_DEPTH  = DEFAULT_MAX_OFMAP_DEPTH;
  
  int n_group_size; 
  int n_group_scale;
  int k_group_size;      
  int bytes_input;      
  int bytes_weight;      
  int bytes_output;      
  int bytes_float;
  int bytes_half;
  int n_group;
  int n_group_ff;
  int k_group;
  int k_group_ff;

  struct Argument {
    int seq_len;                      
    int hidden_size;                  
    int intermediate_size;            
    uint64_t input_base_addr;         
    uint64_t gate_weight_base_addr;   
    uint64_t up_weight_base_addr;     
    uint64_t down_weight_base_addr;   
    uint64_t gate_output_base_addr;   
    uint64_t up_output_base_addr;     
    uint64_t mul_output_base_addr;   
    uint64_t final_output_base_addr; 
    uint64_t vcu_code_base_addr;            
    uint64_t swish_lut_base_addr = SWISH_LUT_ADDR;     
    uint64_t all_done = 1;            
  };

  LlamaMlpOp()
  {
    /** Default fp16 */
    n_group_size = 32;
    n_group_scale = 2;
    k_group_size = 16;
    bytes_input = 2;   
    bytes_weight = 2;  
    bytes_output = 2; 
    bytes_float = 4;
    bytes_half = 2;
  }

  std::pair<std::vector<instruction>, std::vector<uint64_t>> operator()(const Argument& args)
  {
    std::vector<instruction> insn_series;
    std::vector<uint64_t> vcucode_series;

    this->set_vcucode(vcucode_series);
    size_t vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
    size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
    vcucode_series.resize(vcucode_ddr_lines * 8, 0);
    
    /** Load vcu code */
    insn_series.push_back(load_iteration_2<0>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

    /** Load vculut */
    insn_series.push_back(load_iteration_2<0>(args.swish_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    
    /** Vcu Config */
    using vcu_cfg_t = vcu::VcuConfig;
    vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
    vcu_cfg_t vcu_cfg;
    auto vcu_cfg_insns = vcu_cfg(cfg_args);
    insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());
    
    /** Compute LlamaMLP */
    this->compute_llama_mlp(insn_series, vcucode_series, args);
    
    return {insn_series, vcucode_series};
  }

  void set_vcucode(std::vector<uint64_t>& vcucode_series)
  {
    /** LlamaMLP ：fastswish and mul */
    auto mlp_code = vcu::asm_vcu_op({
      "fastswish psum, reg0",     // fastswish激活
      "mul psum resadd, reg1",    // 逐元素乘法
    });
    for (auto code : mlp_code) {
      vcucode_series.push_back(code);
    }

    /** copy */
    auto copy_code = vcu::asm_vcu_op({
      "copy psum, reg0", // fp32 -> fp16 要用到vcu
    });
    for (auto code : copy_code) {
      vcucode_series.push_back(code);
    }
  }

  void compute_llama_mlp(std::vector<instruction>& insn_series, const std::vector<uint64_t>& vcucode_series, const Argument& args)
  {
    /** Compute Group Number */
    n_group = args.hidden_size / n_group_size;        // 输出通道组数
    n_group_ff = args.intermediate_size / n_group_size;  // 中间层输出通道组数
    k_group = args.hidden_size / k_group_size;        // 输入通道组数
    k_group_ff = args.intermediate_size / k_group_size;  // 中间层输入通道组数

    /** fully utilize the ifmap and weight sram */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_group);
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / block_k_group / n_group_size, n_group);
    int block_k_group_ff = std::min(MAX_IFMAP_DEPTH / tile_m, k_group_ff);
    int block_n_group_ff = std::min(MAX_WEIGHT_DEPTH / block_k_group_ff / n_group_size, n_group_ff);
    // int tile_m = 32;
    // int block_k_group = 8; // for test
    // int block_n_group = 4;
    // int block_k_group_ff = 8;
    // int block_n_group_ff = 4;

    if(block_n_group == 0 || block_n_group_ff == 0){
      std::throw_with_nested(std::runtime_error("block_n_group or block_n_group_ff is 0, please modify tile"));
    }

    if (DEBUG) {
      print("======== LlamaMLP Parameters ========");
      print_dec("seq_len", args.seq_len);
      print_dec("hidden_size", args.hidden_size);
      print_dec("intermediate_size", args.intermediate_size);
      print_dec("n_group", n_group);
      print_dec("n_group_ff", n_group_ff);
      print_dec("k_group", k_group);
      print_dec("k_group_ff", k_group_ff);
      print_dec("tile_m", tile_m);
      print_dec("block_n_group", block_n_group);
      print_dec("block_k_group", block_k_group);
      print_dec("block_n_group_ff", block_n_group_ff);
      print_dec("block_k_group_ff", block_k_group_ff);
    }
    
    /** step1. Compute up_proj(x) */
    using pea_gemm_up_t = pea::GemmOp<0, 0, 0, 0, kHalf, kHalf, kFloat32, kFloat32, DEBUG>;
    typename pea_gemm_up_t::Arguments pea_up_args = {
      args.seq_len,            // m
      args.intermediate_size,  // n
      args.hidden_size,        // k
      tile_m,             // tile_m
      block_n_group_ff,      // block_n_group
      block_k_group,      // block_k_group
      args.input_base_addr,        // 输入数据地址
      args.up_weight_base_addr,    // 权重地址
      args.up_output_base_addr,    // 输出地址
      0,  //ifmap_scale_base_addr
      0,  //weight_scale_base_addr
      0,  //outlier_index_base_addr
      0,  //ifmap_mask_base_addr
      0   //all_done
    };
    pea_gemm_up_t pea_up_op;
    auto up_insns = pea_up_op(pea_up_args);
    insn_series.insert(insn_series.end(), up_insns.begin(), up_insns.end());

    /** step2. Compute gate_proj(x) */
    using pea_gemm_t = pea::GemmOp<0, 0, 0, 0, kHalf, kHalf, kFloat32, kFloat32, DEBUG>;
    typename pea_gemm_t::Arguments pea_gate_args = {
      args.seq_len,            // m
      args.intermediate_size,  // n
      args.hidden_size,        // k
      tile_m,             // tile_m
      block_n_group_ff,      // block_n_group
      block_k_group,      // block_k_group
      args.input_base_addr,          // 输入数据地址
      args.gate_weight_base_addr,    // 权重地址
      args.gate_output_base_addr,    // 输出地址
      0,  //ifmap_scale_base_addr
      0,  //weight_scale_base_addr
      0,  //outlier_index_base_addr
      0,  //ifmap_mask_base_addr
      0   //all_done
    };
    pea_gemm_t pea_gate_op;
    auto gate_insns = pea_gate_op(pea_gate_args);
    insn_series.insert(insn_series.end(), gate_insns.begin(), gate_insns.end());
      
    /** step3-8. Execute tiled Swish activation and multiplication */
    this->execute_tiled_vcu_operations(insn_series, args);
    
    /** step9. Execute down_proj(mul_output) */
    using pea_gemm_down_t = pea::GemmOp<0, 0, 0, 0, kHalf, kHalf, kFloat32, kFloat32, DEBUG>;
    typename pea_gemm_down_t::Arguments pea_down_args = {
      args.seq_len,            // m
      args.hidden_size,        // n
      args.intermediate_size,  // k
      tile_m,             // tile_m
      block_n_group,      // block_n_group
      block_k_group_ff,      // block_k_group
      args.mul_output_base_addr,     // 输入数据地址
      args.down_weight_base_addr,    // 权重地址
      args.final_output_base_addr,   // 输出地址
      0,  //ifmap_scale_base_addr
      0,  //weight_scale_base_addr
      0,  //outlier_index_base_addr
      0,  //ifmap_mask_base_addr
      args.all_done   //all_done
    };
    pea_gemm_down_t pea_down_op;
    auto down_insns = pea_down_op(pea_down_args);
    insn_series.insert(insn_series.end(), down_insns.begin(), down_insns.end());

    // /** step10. fp32 -> fp16, and change parallelism */
    
    // auto down_seq_1_offset = split_exp_fra(args.seq_len * n_group_size * bytes_float);
    // insn_series.push_back(load_iteration_2<0>(args.final_output_base_addr,
    //                                           args.seq_len * n_group_size * bytes_float / 32 - 1,
    //                                           down_seq_1_offset.first,
    //                                           down_seq_1_offset.second,
    //                                           n_group - 1,
    //                                           MASTER_PSUM_ADDR,
    //                                           0));
    // // fp32 -> fp16
    // vcu_t::Arguments copy_vcu_args = {
    //   vcu_psum_dtype[kFloat32],      // psum_data_type
    //   vcu_resadd_dtype[kFloat32],    // resadd_para_type
    //   vcu_out_dtype[kHalf],          // data_out_type
    //   VcuOutSram::PSUM,              // data_out_ram
    //   1,                             // opcode_number
    //   2,                             // opcode_addr
    //   0,                             // psum_in_addr
    //   0,                             // para_in_addr
    //   0,                             // resadd_in_addr
    //   0,                             // ram_out_addr
    //   (uint64_t)args.seq_len - 1,    // num_data
    //   (uint64_t)n_group - 1,         // oc_group
    //   0                              // para_func
    // };

    // vcu_t copy_vcu_op;
    // auto copy_vcu_insns = copy_vcu_op(copy_vcu_args);
    // insn_series.insert(insn_series.end(), copy_vcu_insns.begin(), copy_vcu_insns.end());

    // // [n_group, seq_len, n_group_size] -> [n_group * n_group_scale, seq_len, n_group_size / n_group_scale] 
    // vcu_convert = vcu_parallelism_conversion(0, 0, 0, args.seq_len, n_group, n_group * n_group_scale); 
    // vcu_convert.set_insn_number(0);
    // vcu_convert.set_insn_opcode(25);
    // insn_series.push_back(vcu_convert);

    // /** step11. Store final output, fp16 */
    // auto final_seq_1_offset = split_exp_fra(args.seq_len * (n_group_size / n_group_scale) * bytes_output);
    // insn_series.push_back(store_iteration_2<0>(args.final_output_base_addr,
    //                                           args.seq_len * (n_group_size / n_group_scale) * bytes_output / 32 - 1,
    //                                           final_seq_1_offset.first,
    //                                           final_seq_1_offset.second,
    //                                           (n_group * n_group_scale) - 1,
    //                                           MASTER_OFMAP_ADDR, 
    //                                           args.all_done));
  }

private:
  void execute_tiled_vcu_operations(std::vector<instruction>& insn_series, const Argument& args)
  {
    /** 计算分块参数，按照 [dim_groups, seq_len, n_group_size] 内存布局 */
    int tile_m = std::min(std::min(MAX_OFMAP_DEPTH / 2, MAX_PSUM_DEPTH), args.seq_len);
    // int tile_m = 32;
    int tile_n_groups = std::min(std::min(MAX_OFMAP_DEPTH / tile_m / 2, MAX_PSUM_DEPTH / tile_m), n_group_ff);
    // int tile_n_groups = 4;

    int n_iterations = std::ceil((double)n_group_ff / (double)tile_n_groups);
    int m_iterations = std::ceil((double)args.seq_len / (double)tile_m);
    
    if (DEBUG) {
      print("======== Tiled VCU Operation Parameters ========");
      print_dec("tile_m", tile_m);
      print_dec("tile_n_groups", tile_n_groups);
      print_dec("n_iterations", n_iterations);
      print_dec("m_iterations", m_iterations);
    }

    for (int n_iter = 0; n_iter < n_iterations; n_iter++) {
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
        
        // 计算当前块的实际大小
        int valid_item_seq_len = std::min(tile_m, args.seq_len - m_iter * tile_m);
        int valid_item_n_groups = std::min(tile_n_groups, n_group_ff - n_iter * tile_n_groups);
                
        // 计算DDR地址偏移
        uint64_t input_n_offset = n_iter * tile_n_groups * args.seq_len * n_group_size * bytes_float; 
        uint64_t input_m_offset = m_iter * tile_m * n_group_size * bytes_float;
        
        if (DEBUG) {
          print_dec(" ======== Processing tile ======== ", n_iter * m_iterations + m_iter);
          print_dec("valid_item_seq_len", valid_item_seq_len);
          print_dec("valid_item_n_groups", valid_item_n_groups);
          print_hex("input_n_offset", input_n_offset);
          print_hex("input_m_offset", input_m_offset);
        }
        
      /** step3. Load gate_output for swish activation */
      auto gate_seq_1_offset = split_exp_fra(args.seq_len * n_group_size * bytes_float);
      insn_series.push_back(load_iteration_2<0>(
        args.gate_output_base_addr + input_n_offset + input_m_offset,
        valid_item_seq_len * n_group_size * bytes_float / 32 - 1,
        gate_seq_1_offset.first,
        gate_seq_1_offset.second,
        valid_item_n_groups - 1,
        MASTER_PSUM_ADDR,
        0));
                                                
      /** step4. Execute Swish activation */
      using vcu_t = vcu::VcuExecute;
      vcu_t::Arguments vcu_args = {
        vcu_psum_dtype[kFloat32],      // psum_data_type
        vcu_resadd_dtype[kFloat32],    // resadd_para_type
        vcu_out_dtype[kFloat32],       // data_out_type
        VcuOutSram::PSUM,              // data_out_ram
        1,                             // opcode_number
        0,                             // opcode_addr
        0,                             // psum_in_addr
        0,                             // para_in_addr
        0,                             // resadd_in_addr
        0,                             // ram_out_addr
        (uint64_t)valid_item_seq_len - 1,    // num_data
        (uint64_t)valid_item_n_groups - 1,   // oc_group
        0                              // para_func
      };
      
      vcu_t vcu_op;
      auto vcu_insns = vcu_op(vcu_args);
      insn_series.insert(insn_series.end(), vcu_insns.begin(), vcu_insns.end());

      /** step5. Load up_output (prepare for multiplication) */
      auto up_seq_1_offset = split_exp_fra(args.seq_len * n_group_size * bytes_float);
      insn_series.push_back(load_iteration_2<0>(
        args.up_output_base_addr + input_n_offset + input_m_offset,
        valid_item_seq_len * n_group_size * bytes_float / 32 - 1,
        up_seq_1_offset.first,
        up_seq_1_offset.second,
        valid_item_n_groups - 1,
        MASTER_VCURES_ADDR,
        0));
                                              
      /** step6. Execute multiplication (swish_output * up_output), fp32 * fp32 -> fp16 */
      vcu_t::Arguments mul_vcu_args = {
        vcu_psum_dtype[kFloat32],      // psum_data_type
        vcu_resadd_dtype[kFloat32],    // resadd_para_type
        vcu_out_dtype[kHalf],          // data_out_type
        VcuOutSram::PSUM,              // data_out_ram
        1,                             // opcode_number
        1,                             // opcode_addr
        0,                             // psum_in_addr
        0,                             // para_in_addr
        0,                             // resadd_in_addr
        0,                             // ram_out_addr
        (uint64_t)valid_item_seq_len - 1,    // num_data
        (uint64_t)valid_item_n_groups - 1,   // oc_group
        0                              // para_func
      };

      vcu_t mul_vcu_op;
      auto mul_vcu_insns = mul_vcu_op(mul_vcu_args);
      insn_series.insert(insn_series.end(), mul_vcu_insns.begin(), mul_vcu_insns.end());
      
      /** step7. Parallelism conversion, [n_group_ff, seq_len, n_group_size] -> [k_group_ff, seq_len, k_group_size] */
      auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_groups, valid_item_n_groups * 2); 
      vcu_convert.set_insn_number(0);
      vcu_convert.set_insn_opcode(25);
      insn_series.push_back(vcu_convert);
      
      /** step8. Store multiplication result, fp16 */
      int valid_item_k_groups = valid_item_n_groups * n_group_scale; // 并行度转换后的k_groups

      uint64_t output_n_offset = n_iter * (tile_n_groups * n_group_scale) * args.seq_len * k_group_size * bytes_half; 
      uint64_t output_m_offset = m_iter * tile_m * k_group_size * bytes_half;
      auto mul_seq_1_offset = split_exp_fra(args.seq_len * k_group_size * bytes_half);
      insn_series.push_back(store_iteration_2<0>(
        args.mul_output_base_addr + output_n_offset + output_m_offset,
        valid_item_seq_len * k_group_size * bytes_half / 32 - 1,
        mul_seq_1_offset.first,
        mul_seq_1_offset.second,
        valid_item_k_groups - 1,
        MASTER_OFMAP_ADDR,
        0));
      }
    }
  }
};

} // namespace llama_mlp
} // namespace transformer 