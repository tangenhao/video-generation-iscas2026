#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/transformer/softmax.h"
#include "transformer/softmax.h"
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
  using namespace compute_model::transformer::softmax;
  using SoftmaxOpClass = transformer::softmax::SoftmaxOp<true>; 

  int seq_len       = 96;
  int d_model       = 96;
  int oc_group_size = 32;
  int oc_group      = d_model / oc_group_size;
  int tile_m        = 64;        
  int block_oc_group = 2;      

  // 内存地址配置
  uint64_t rec_lut_ddr_base_addr   = REC_LUT_ADDR;
  uint64_t exp_lut_ddr_base_addr   = EXP_LUT_ADDR;
  uint64_t data_in_ddr_base_addr   = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  auto data_in = randn<float>({oc_group, seq_len, oc_group_size}, kFloat32, -1.0f, 1.0f, 0);
  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  // 使用compute_model::transformer::softmax进行计算验证
  Tensor<float> data_out_expected(data_in.shape(), kFloat32);
  apply_softmax<float, false>(data_in, data_out_expected);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out_expected.data_ptr()), data_out_expected.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                          SoftmaxOp Insntruction                                         */
  /* -------------------------------------------------------------------------------------------------------- */
  
  SoftmaxOpClass softmax_op;
  
  SoftmaxOpClass::Argument args;
  args.seq_len = seq_len;
  args.d_model = d_model;
  args.tile_m = tile_m;
  args.block_oc_group = block_oc_group;
  args.dtype = kFloat32;
  args.input_base_addr = data_in_ddr_base_addr;
  args.output_base_addr = data_out_ddr_base_addr;
  args.vcu_code_base_addr = opcode_ddr_base_addr;
  args.rec_lut_base_addr = rec_lut_ddr_base_addr;
  args.exp_lut_base_addr = exp_lut_ddr_base_addr;
  args.all_done = 1;
  
  // 生成指令和VCU代码
  auto pack = softmax_op(args);
  auto insn_series = pack.first;
  auto vcucode_series = pack.second;
  
  common::insn::pad_serial_sync_word(insn_series);
  auto parser = common::insn::instruction_parser(insn_series);
  parser.parse_instruction();

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  cout << "======== Generated Instructions ========" << endl;
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  cout << "======== Test Parameters ========" << endl;
  cout << "seq_len: " << seq_len << endl;
  cout << "d_model: " << d_model << endl;
  cout << "oc_group_size: " << oc_group_size << endl;
  cout << "oc_group: " << oc_group << endl;
  cout << "tile_m: " << tile_m << endl;
  cout << "block_oc_group: " << block_oc_group << endl;
  cout << "Total instructions: " << insn_series.size() << endl;
  cout << "VCU code size: " << vcucode_series.size() << endl;

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
