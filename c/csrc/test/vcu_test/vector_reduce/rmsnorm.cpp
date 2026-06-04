#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
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

  // 基本参数配置
  int seq_len       = 10;
  int d_model       = 128;
  float d_model_rec;

  Tensor<float> d_model_tensor({1, 1, 1}, kFloat32);
  d_model_tensor[0] = (float)128;
  auto d_model_tensor_rec = compute_model::function::reciprocal(d_model_tensor);
  d_model_rec = d_model_tensor_rec[0];

  int oc_group_size = 32;
  int oc_group      = d_model / oc_group_size;

  // 内存地址配置
  uint64_t rec_lut_ddr_base_addr   = REC_LUT_ADDR;
  uint64_t log_lut_ddr_base_addr   = LOG_LUT_ADDR;
  uint64_t exp_lut_ddr_base_addr   = EXP_LUT_ADDR;
  uint64_t rsqrt_lut_ddr_base_addr = RSQRT_LUT_ADDR;
  uint64_t data_in_ddr_base_addr   = PSUM_ADDR;
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

  // 计算RMS
  Tensor<float> data_out({oc_group, seq_len, oc_group_size}, kFloat32);
  auto          data_rms = zeros<float>({seq_len, oc_group_size}, kFloat32);

  // 计算平方和
  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    Tensor<float> sub_tensor({seq_len, oc_group_size}, kFloat32);
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        float val = data_in[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter];
        sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter] = val * val;
      }
    }

    auto data_rms_temp = compute_model::function::reduce_sum(sub_tensor, 32, true);
    data_rms = data_rms + data_rms_temp;
  }

  // 计算RMS
  data_rms = data_rms * d_model_rec;
  data_rms = data_rms + 1e-5f;  // 添加epsilon
  data_rms = compute_model::function::rsqrt(data_rms);

  // 应用RMS归一化
  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        data_out[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] =
          data_in[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] *
          data_rms[seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }
  }

  // 应用gamma缩放
  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        data_out[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] *=
          gamma[oc_iter * oc_group_size + oc_inner_iter];
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out.data_ptr()), data_out.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */
  auto vcucode_series = vcu::asm_vcu_op({
                                         "config reg0, 0.0",  // 初始配置

                                         "mul psum psum, reg1",    // 计算平方
                                         "redsum reg1, reg2, 32",  // 规约求和
                                         "add reg2 resadd, reg3",  // 累加结果, 写入vcures    

                                         "config reg0, " + to_string_with_precision(d_model, 7),       
                                         "rec reg0, reg1",
                                         "mul resadd reg1, reg4",  // 除以维度
                                         "addc reg4, reg5, " + to_string_with_precision(0.00001, 10),   // 添加epsilon
                                         "rsqrt reg5, reg6",                                            // 计算RMS, 写入vcures

                                         "mul psum resadd, reg7",   // 应用RMS归一化
                                         "mul reg7 para, reg0"  // 应用gamma缩放, 写入psum
                                        });
  // auto   num_vcucodes      = vcucode_series.size();
  size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  vcucode_series.resize(vcucode_ddr_lines * 8, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  std::vector<insn::instruction> insn_series;

  // 加载LUT表
  insn_series.push_back(insn::load_iteration_2<0>(rec_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
  insn_series.push_back(
    insn::load_iteration_2<0>(log_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64 * 128 / 256, 0));
  insn_series.push_back(
    insn::load_iteration_2<0>(exp_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 2 * 64 * 128 / 256, 0));
  insn_series.push_back(
    insn::load_iteration_2<0>(rsqrt_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 3 * 64 * 128 / 256, 0));

  // 加载操作码
  insn_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  // 加载参数
  auto para_seq_1_offset = split_exp_fra(oc_group_size * 4);
  insn_series.push_back(insn::load_iteration_2<0>(
    VCUPARA_ADDR, 4 - 1, para_seq_1_offset.first, para_seq_1_offset.second, oc_group - 1, MASTER_VCUPARA_ADDR, 0));

  // 加载输入数据
  auto seq_1_offset = split_exp_fra(seq_len * oc_group_size * 4);
  insn_series.push_back(insn::load_iteration_2<0>(
    data_in_ddr_base_addr, seq_len * 4 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_PSUM_ADDR, 0));

  // VCU配置
  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);
  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());

  // VCU执行配置
  using vcu_t = vcu::VcuExecute;
  vcu_t vcu_op;

  // 配置阶段
  vcu_t::Arguments step_0_config_args = {0b100,                  // psum_data_type
                                         0b011,                  // resadd_para_type
                                         0b111,                  // data_out_type
                                         0b10,                   // data_out_ram
                                         1,                      // opcode_number
                                         0,                      // opcode_addr
                                         0b0000000000000,        // psum_in_addr
                                         0b000000,               // para_in_addr
                                         0b000000000000,         // resadd_in_addr
                                         0b0000000000000,        // ram_out_addr
                                         (uint64_t)seq_len - 1,  // seq_len
                                         0,                      // oc_group
                                         0b00,                   // para_func
                                         0,                      
                                         0,                      
                                         0};                     

  auto step_0_config_insns = vcu_op(step_0_config_args);
  insn_series.insert(insn_series.end(), step_0_config_insns.begin(), step_0_config_insns.end());

  // accumulate
  for (uint64_t i = 0; i < oc_group; ++i) {
    vcu_t::Arguments step_1_acc_args = {0b111,                  // psum_data_type
                                        0b011,                  // resadd_para_type
                                        0b111,                  // data_out_type
                                        0b10,                   // data_out_ram
                                        3,                      // opcode_number
                                        1,                      // opcode_addr
                                        i * seq_len,            // psum_in_addr
                                        0b000000,               // para_in_addr
                                        0b000000000000,         // resadd_in_addr
                                        0b0000000000000,        // ram_out_addr
                                        (uint64_t)seq_len - 1,  // seq_len
                                        0,                      // oc_group
                                        0b00,                   // para_func
                                        1,                      
                                        1,                      
                                        0};                     

    auto step_1_acc_insns = vcu_op(step_1_acc_args);
    insn_series.insert(insn_series.end(), step_1_acc_insns.begin(), step_1_acc_insns.end());
  }

  // calculate data_rms
  vcu_t::Arguments step_2_rms_args = {0b111,                  // psum_data_type
                                      0b011,                  // resadd_para_type
                                      0b111,                  // data_out_type
                                      0b10,                   // data_out_ram
                                      5,                      // opcode_number
                                      4,                      // opcode_addr
                                      0b0000000000000,        // psum_in_addr
                                      0b000000,               // para_in_addr
                                      0b000000000000,         // resadd_in_addr
                                      0b0000000000000,        // ram_out_addr
                                      (uint64_t)seq_len - 1,  // seq_len
                                      0,                      // oc_group
                                      0b00,                   // para_func
                                      0,                      
                                      1,                      
                                      0};                     

  auto step_2_rms_insns = vcu_op(step_2_rms_args);
  insn_series.insert(insn_series.end(), step_2_rms_insns.begin(), step_2_rms_insns.end());

  // RMS归一化和缩放阶段
  for (uint64_t i = 0; i < oc_group; ++i) {
    vcu_t::Arguments step_3_norm_args = {0b111,                  // psum_data_type
                                         0b011,                  // resadd_para_type
                                         0b111,                  // data_out_type
                                         0b0,                    // data_out_ram
                                         2,                      // opcode_number
                                         9,                      // opcode_addr
                                         i * seq_len,            // psum_in_addr
                                         i,                      // para_in_addr
                                         0b000000000000,         // resadd_in_addr
                                         i * seq_len,            // ram_out_addr
                                         (uint64_t)seq_len - 1,  // seq_len
                                         0,                      // oc_group
                                         0b00,                   // para_func
                                         1,                      
                                         1,                      
                                         1};                     

    auto step_3_norm_insns = vcu_op(step_3_norm_args);
    insn_series.insert(insn_series.end(), step_3_norm_insns.begin(), step_3_norm_insns.end());
  }

  // 存储结果
  insn_series.push_back(insn::store_iteration_2<0>(
    data_out_ddr_base_addr, seq_len * 4 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_PSUM_ADDR, 1));

  // 添加同步字
  common::insn::pad_serial_sync_word(insn_series);

  // 输出指令
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  // 写入指令文件
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

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

  std::cout << "d_model_rec value = " << d_model_rec << std::endl;
  return 0;
} 