#include "common/insn.h"
#include "common/type_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/transformer/llama_mlp.h"
#include "transformer/llama_mlp.h"
#include "instruction/parser.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include "addr_for_llama.h"
#include <vector>
#include <iostream>

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;
  using namespace compute_model::common::fp16;
  using namespace compute_model::transformer::llama_mlp;
  
  // MLP配置参数
  int seq_len = 256;          // 序列长度
  int hidden_size = 256;      // 隐藏层大小
  int intermediate_size = 256; // 中间层大小（SwiGLU使用的中间层大小）
  
  // 硬件相关参数
  int n_group_size = 32;    
  int k_group_size = 16;    
  
  // 计算组数信息
  int d_model = hidden_size;
  int d_ff = intermediate_size;
  
  int n_group = d_model / n_group_size;      
  int n_group_ff = d_ff / n_group_size;       
  int k_group = d_model / k_group_size;      
  int k_group_ff = d_ff / k_group_size; 

  int n_group_scale = 2;      
  
  // DDR基址
  uint64_t input_ddr_base_addr = BLOCK_INPUT_ADDR;
  uint64_t gate_weight_ddr_base_addr = MLP_GATE_WEIGHT_ADDR;
  uint64_t up_weight_ddr_base_addr = MLP_UP_WEIGHT_ADDR;
  uint64_t down_weight_ddr_base_addr = MLP_DOWN_WEIGHT_ADDR;
  uint64_t gate_output_ddr_base_addr = MLP_GATE_OUTPUT_ADDR;
  uint64_t up_output_ddr_base_addr = MLP_UP_OUTPUT_ADDR;
  uint64_t mul_output_ddr_base_addr = MLP_MUL_OUTPUT_ADDR;
  uint64_t final_output_ddr_base_addr = BLOCK_OUTPUT_ADDR;
  uint64_t swish_lut_ddr_base_addr = LLAMA_BLOCK_SWISH_LUT_ADDR;
  uint64_t opcode_ddr_base_addr = LLAMA_BLOCK_VCUCODE_ADDR;
  
  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                Data Generation                                                   */
  /* -------------------------------------------------------------------------------------------------------- */
  
  // 输入张量: [k_group, seq_len, k_group_size]
  auto input = randn<half>({k_group, seq_len, k_group_size}, kHalf, -0.1f, 0.1f, 42);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_input_hidden_state.txt", reinterpret_cast<char*>(input.data_ptr()), input.numel() * sizeof(half), 32, true);
  
  // up投影权重: [n_group_ff, k_group, n_group_size, k_group_size]
  auto up_weight = randn<half>({n_group_ff, k_group, n_group_size, k_group_size}, kHalf, -0.1f, 0.1f, 44);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_mlp_up_weight.txt", reinterpret_cast<char*>(up_weight.data_ptr()), up_weight.numel() * sizeof(half), 32, true);

  // gate投影权重: [n_group_ff, k_group, n_group_size, k_group_size]
  auto gate_weight = randn<half>({n_group_ff, k_group, n_group_size, k_group_size}, kHalf, -0.1f, 0.1f, 43);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_mlp_gate_weight.txt", reinterpret_cast<char*>(gate_weight.data_ptr()), gate_weight.numel() * sizeof(half), 32, true);

  // down投影权重: [n_group, k_group_ff, n_group_size, k_group_size]
  auto down_weight = randn<half>({n_group, k_group_ff, n_group_size, k_group_size}, kHalf, -0.1f, 0.1f, 45);
  common::file_utils::saveCharArrayToFormattedTextFile( 
    "../../sim/memory_llama/block_mlp_down_weight.txt", reinterpret_cast<char*>(down_weight.data_ptr()), down_weight.numel() * sizeof(half), 32, true);

  // 初始化输出张量, fp32, group_size = 32
  auto output = zeros<float>({n_group, seq_len, n_group_size}, kFloat32);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                           Reference Output Generation                                                    */
  /* -------------------------------------------------------------------------------------------------------- */

  // compute_model::transformer::llama_mlp
  apply_llama_mlp<half, half, float, false>(
      input, output, gate_weight, up_weight, down_weight);
  
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_output_hidden_state_ref.txt", reinterpret_cast<char*>(output.data_ptr()), output.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                               Generate Instructions                                                      */
  /* -------------------------------------------------------------------------------------------------------- */
  
  using LlamaMlpOpClass = transformer::llama_mlp::LlamaMlpOp<true>;
  LlamaMlpOpClass llama_mlp_op;
  
  // config parameters
  LlamaMlpOpClass::Argument args;
  args.seq_len = seq_len;
  args.hidden_size = hidden_size;
  args.intermediate_size = intermediate_size;
  args.input_base_addr = input_ddr_base_addr;
  args.gate_weight_base_addr = gate_weight_ddr_base_addr;
  args.up_weight_base_addr = up_weight_ddr_base_addr;
  args.down_weight_base_addr = down_weight_ddr_base_addr;
  args.gate_output_base_addr = gate_output_ddr_base_addr;
  args.up_output_base_addr = up_output_ddr_base_addr;
  args.mul_output_base_addr = mul_output_ddr_base_addr;
  args.final_output_base_addr = final_output_ddr_base_addr;
  args.vcu_code_base_addr = opcode_ddr_base_addr;
  args.swish_lut_base_addr = swish_lut_ddr_base_addr;
  args.all_done = 1;
  
  // generate instructions and vcu code
  auto pack = llama_mlp_op(args);
  auto insn_series = pack.first;
  auto vcucode_series = pack.second;
  
  common::insn::pad_serial_sync_word(insn_series);
  
  // parse instructions
  auto parser = common::insn::instruction_parser(insn_series);
  parser.parse_instruction();
    
  // save vcu code to file
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/vcucode.txt", reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);
  
  // save instructions to file
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/insn.txt", reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);
  
  write_regs(reg_cfg_file.c_str(),
           0,
           insn_series.size() * sizeof(common::insn::instruction) / 32,
           32,
           0,
           NO_BROADCAST,
           NO_BROADCAST,
           NO_BROADCAST,
           NO_BROADCAST,
           NO_BROADCAST,
           NO_BROADCAST,
           NO_BROADCAST,
           NO_BROADCAST,
           NO_BROADCAST,
           PSUM_LOAD_1024,
           PSUM_STORE_1024,
           VCURES_LOAD_1024,
           IFMAP_MASK_LOAD_32,
           1);
  
  return 0;
} 