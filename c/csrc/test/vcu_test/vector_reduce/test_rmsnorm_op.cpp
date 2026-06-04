#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/transformer/rmsnorm.h"
#include "transformer/rmsnorm.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include "instruction/parser.h"
#include <vector>

#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>

using namespace std;

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

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;
  using namespace compute_model::transformer::rmsnorm;
  using RMSNormOpClass = transformer::rmsnorm::RMSNormOp<true>; // 启用DEBUG模式

  // 基本参数配置
  int seq_len       = 64;
  int d_model       = 128;
  int oc_group_size = 32;
  int oc_group      = d_model / oc_group_size;
  int tile_m        = 32;        
  int block_oc_group = 2;       
  float epsilon     = 1e-6f;

  // 内存地址配置
  uint64_t rec_lut_ddr_base_addr   = REC_LUT_ADDR;
  uint64_t log_lut_ddr_base_addr   = LOG_LUT_ADDR;
  uint64_t exp_lut_ddr_base_addr   = EXP_LUT_ADDR;
  uint64_t rsqrt_lut_ddr_base_addr = RSQRT_LUT_ADDR;
  uint64_t data_in_ddr_base_addr   = PSUM_ADDR;
  uint64_t para_ddr_base_addr      = VCUPARA_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  // 生成输入数据
  auto data_in = randn<float>({oc_group, seq_len, oc_group_size}, kFloat32, -1.0f, 1.0f, 0);
  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  // 生成gamma参数（RMSNorm只需要gamma）
  auto gamma = randn<float>({oc_group, 1, oc_group_size}, kFloat32, 0.5f, 1.5f, 0);
  auto para = zeros<float>({oc_group, 1, oc_group_size}, kFloat32);

  for (int i = 0; i < oc_group; i++) {
    for (int j = 0; j < oc_group_size; j++) {
      para[i * oc_group_size + j] = gamma[i * oc_group_size + j];
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(para.data_ptr()), para.numel() * sizeof(float), 32, true);

  // 使用compute_model::transformer::rmsnorm进行计算
  Tensor<float> data_out(data_in.shape(), kFloat32);
  apply_rmsnorm<float, true>(data_in, data_out, gamma, epsilon);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out.data_ptr()), data_out.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                          使用RMSNormOp生成指令                                             */
  /* -------------------------------------------------------------------------------------------------------- */
  
  // 创建RMSNormOp实例
  RMSNormOpClass rmsnorm_op;
  
  // 配置参数
  RMSNormOpClass::Argument args;
  args.seq_len = seq_len;
  args.d_model = d_model;
  args.tile_m = tile_m;
  args.block_oc_group = block_oc_group;
  args.epsilon = epsilon;
  args.dtype = kFloat32;
  args.input_base_addr = data_in_ddr_base_addr;
  args.gamma_base_addr = para_ddr_base_addr;
  args.output_base_addr = data_out_ddr_base_addr;
  args.vcu_code_addr = opcode_ddr_base_addr;
  args.rec_lut_ddr_base_addr = rec_lut_ddr_base_addr;
  args.log_lut_ddr_base_addr = log_lut_ddr_base_addr;
  args.exp_lut_ddr_base_addr = exp_lut_ddr_base_addr;
  args.rsqrt_lut_ddr_base_addr = rsqrt_lut_ddr_base_addr;
  
  // 生成指令和VCU代码
  auto pack = rmsnorm_op(args);
  auto insn_series = pack.first;
  auto vcucode_series = pack.second;
  
  common::insn::pad_serial_sync_word(insn_series);
  auto parser = common::insn::instruction_parser(insn_series);
  parser.parse_instruction();

  // 写入指令文件
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  // 保存VCU代码到文件
  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  // 输出指令
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

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

  return 0;
} 