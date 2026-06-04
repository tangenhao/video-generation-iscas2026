#include "common/insn.h"
#include "common/type_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/transformer/llama_attention.h"
#include "transformer/llama_attention.h"
#include "instruction/parser.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include "addr_for_transformer.h"
#include <vector>
#include <iostream>

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;
  using namespace compute_model::common::fp16;
  using namespace compute_model::transformer::mha;
  
  // Attention配置参数
  int seq_len = 32;          // 序列长度
  int d_model = 128;         // 模型维度
  int head_num = 2;          // 注意力头数量
  int d_h = d_model / head_num; // 每个头的维度
  
  // 硬件相关参数
  int n_group_size = 32;
  int k_group_size = 16;
  
  // 计算组数信息
  int k_group = d_model / k_group_size;
  int n_group = d_model / n_group_size;
  
  /* -------------------------------------------------------------------------------------------------------- */
  /*                                           Data Generation                                                */
  /* -------------------------------------------------------------------------------------------------------- */
  
  // 输入张量: [k_group, seq_len, k_group_size]
  auto input = randn<half>({k_group, seq_len, k_group_size}, kHalf, 0.0f, 0.1f, 0);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/input.txt", reinterpret_cast<char*>(input.data_ptr()), input.numel() * sizeof(half), 32, true);
  
  // Query权重: [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size]
  auto query_weight = randn<half>({d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, kHalf, 0.0f, 0.1f, 100);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/weight_query.txt", reinterpret_cast<char*>(query_weight.data_ptr()), query_weight.numel() * sizeof(half), 32, true);
  
  // Key权重: [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size]
  auto key_weight = randn<half>({d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, kHalf, 0.0f, 0.1f, 200);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/weight_key.txt", reinterpret_cast<char*>(key_weight.data_ptr()), key_weight.numel() * sizeof(half), 32, true);
  
  // Value权重: [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size]
  auto value_weight = randn<half>({d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, kHalf, -1.0f, 1.0f, 300);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/weight_value.txt", reinterpret_cast<char*>(value_weight.data_ptr()), value_weight.numel() * sizeof(half), 32, true);
  
  // Output权重: [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size]
  auto output_weight = randn<half>({d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, kHalf, 0.0f, 0.1f, 400);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/weight_output.txt", reinterpret_cast<char*>(output_weight.data_ptr()), output_weight.numel() * sizeof(half), 32, true);
  
  // 初始化输出张量, fp32, group_size = 32
  auto output = zeros<float>({n_group, seq_len, n_group_size}, kFloat32);
  
  /* -------------------------------------------------------------------------------------------------------- */
  /*                           Reference Output Generation                                                    */
  /* -------------------------------------------------------------------------------------------------------- */
  
  // compute_model::transformer::llama_attention
  ApplyLlamaAttention<half, half, float, true>(
      input, output, query_weight, key_weight, value_weight, output_weight, head_num);
  
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/output.txt", reinterpret_cast<char*>(output.data_ptr()), output.numel() * sizeof(float), 32, true);
  
  /* -------------------------------------------------------------------------------------------------------- */
  /*                               Generate Instructions                                                      */
  /* -------------------------------------------------------------------------------------------------------- */
  
  using llama_mha_t = transformer::mha::LlamaAttentionOp<true, false>;
  llama_mha_t llama_mha_op;
  
  // config parameters
  llama_mha_t::Argument args  = {seq_len,
                                 d_model,
                                 head_num,
                                 INPUT_ADDR,
                                 QUERY_WEIGHT_ADDR,
                                 KEY_WEIGHT_ADDR,
                                 VALUE_WEIGHT_ADDR,
                                 OUTPUT_WEIGHT_ADDR,
                                 QUERY_TEMP_ADDR,
                                 KEY_TEMP_ADDR,
                                 VALUE_TEMP_ADDR,
                                 SCORE_TEMP_ADDR,
                                 PROBE_TEMP_ADDR,
                                 OUTPUT_TEMP_ADDR,
                                 OUTPUT_ADDR,
                                 FREQ_CLS_ADDR,
                                 MASK_ADDR};
  
  // generate instructions
  auto pack = llama_mha_op(args);
  auto insn_series = pack.first;
  auto vcucode_series = pack.second;
  
  common::insn::pad_serial_sync_word(insn_series);
  
  // parse instructions
  auto parser = common::insn::instruction_parser(insn_series);
  parser.parse_instruction();
  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/insn.txt",
                                                       reinterpret_cast<char*>(insn_series.data()),
                                                       insn_series.size() * sizeof(common::insn::instruction),
                                                       32,
                                                       true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/vcucode.txt", reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);
  
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
