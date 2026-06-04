#include "common/insn.h"
#include "common/type_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/transformer/rope_embedding.h"
#include "transformer/rope_embedding.h"
#include "instruction/parser.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include "addr.h"
#include <vector>
#include <iostream>
#include <cmath>

void print_dec(std::string str, int num, std::ostream& os = std::cout)
{
  os << std::dec << str << ": " << num << std::endl;
}

void print_hex(std::string str, uint64_t num, std::ostream& os = std::cout)
{
  os << std::hex << str << ": 0x" << num << std::endl;
}

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;
  using namespace compute_model::common::fp16;
  using namespace compute_model::transformer::rope_embedding;
  
  std::cout << "=== RoPE Embedding Operator Test ===" << std::endl;
  
  // RoPE配置参数
  int seq_len = 256;           // 序列长度
  int dim = 2048;               // 特征维度（必须是偶数）
  int n_group_size = 32;      // 硬件分组大小
  
  // 验证参数
  if (dim % n_group_size != 0) {
    std::throw_with_nested(std::runtime_error("dim must be divisible by n_group_size"));
  }
  if (dim % 2 != 0) {
    std::throw_with_nested(std::runtime_error("dim must be even for complex representation"));
  }
  
  int dim_groups = dim / n_group_size;  // 维度分组数
  
  // DDR地址配置
  uint64_t input_ddr_base_addr = PSUM_ADDR;
  uint64_t freq_cls_ddr_base_addr = VCURES_ADDR;
  uint64_t output_ddr_base_addr = OFMAP_ADDR;
  uint64_t vcu_code_ddr_base_addr = VCUCODE_ADDR;
  
  std::cout << "Configuration:" << std::endl;
  print_dec("seq_len", seq_len);
  print_dec("dim", dim);
  print_dec("n_group_size", n_group_size);
  print_dec("dim_groups", dim_groups);
  print_hex("input_ddr_base_addr", input_ddr_base_addr);
  print_hex("freq_cls_ddr_base_addr", freq_cls_ddr_base_addr);
  print_hex("output_ddr_base_addr", output_ddr_base_addr);
  print_hex("vcu_code_ddr_base_addr", vcu_code_ddr_base_addr);
  
  /* -------------------------------------------------------------------------------------------------------- */
  /*                                               Data Generation                                           */
  /* -------------------------------------------------------------------------------------------------------- */
  
  std::cout << "\n=== Data Generation ===" << std::endl;
  
  // 生成输入张量: [dim_groups, seq_len, n_group_size]
  auto input = randn<float>({dim_groups, seq_len, n_group_size}, kFloat32, -1.0f, 1.0f, 42);
  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(),
    reinterpret_cast<char*>(input.data_ptr()),
    input.numel() * sizeof(float), 32, true);
  
  // 生成频率张量: [dim_groups, seq_len, n_group_size]
  // 使用compute_model提供的生成函数
  auto freq_cls = generate_freq_cls<float>(seq_len, dim, 10000.0f);
  common::file_utils::saveCharArrayToFormattedTextFile(
    res_file.c_str(),
    reinterpret_cast<char*>(freq_cls.data_ptr()),
    freq_cls.numel() * sizeof(float), 32, true);
  
  std::cout << "Generated input tensor: [" << dim_groups << ", " << seq_len << ", " << n_group_size << "]" << std::endl;
  std::cout << "Generated freq_cls tensor: [" << dim_groups << ", " << seq_len << ", " << n_group_size << "]" << std::endl;
  
  // 初始化输出张量
  auto output = zeros<float>({dim_groups, seq_len, n_group_size}, kFloat32);
  
  /* -------------------------------------------------------------------------------------------------------- */
  /*                               Reference Output Generation                                                */
  /* -------------------------------------------------------------------------------------------------------- */
  
  std::cout << "\n=== Reference Output Generation ===" << std::endl;
  
  // 使用compute_model的RoPE实现生成参考输出
  apply_rope_embedding<float, float, float, true>(input, freq_cls, output);
  
  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(),
    reinterpret_cast<char*>(output.data_ptr()),
    output.numel() * sizeof(float), 32, true);
  
  std::cout << "Reference computation completed!" << std::endl;
  
  /* -------------------------------------------------------------------------------------------------------- */
  /*                               Generate Instructions                                                      */
  /* -------------------------------------------------------------------------------------------------------- */
  
  std::cout << "\n=== Instruction Generation ===" << std::endl;
  
  using RopeEmbeddingOpClass = transformer::rope_embedding::RopeEmbeddingOp<true>;
  RopeEmbeddingOpClass rope_embedding_op;
  
  // 配置参数
  RopeEmbeddingOpClass::Argument args;
  args.seq_len = seq_len;
  args.dim = dim;
  args.input_base_addr = input_ddr_base_addr;
  args.freq_cls_base_addr = freq_cls_ddr_base_addr;
  args.output_base_addr = output_ddr_base_addr;
  args.vcu_code_base_addr = vcu_code_ddr_base_addr;
  args.all_done = 1;
  
  // 生成指令和VCU代码
  auto pack = rope_embedding_op(args);
  auto insn_series = pack.first;
  auto vcucode_series = pack.second;
  
  common::insn::pad_serial_sync_word(insn_series);
  
  std::cout << "Generated " << insn_series.size() << " instructions" << std::endl;
  std::cout << "Generated " << vcucode_series.size() << " VCU code words" << std::endl;
  
  // 解析指令
  auto parser = common::insn::instruction_parser(insn_series);
  parser.parse_instruction();
  
  // 保存VCU代码到文件
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/vcucode.txt",
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t), 32, true);
  
  // 保存指令到文件
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/insn.txt",
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction), 32, true);
  
  // 写入寄存器配置
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
  
  std::cout << "\n=== Test Completed Successfully ===" << std::endl;
  
  return 0;
}
