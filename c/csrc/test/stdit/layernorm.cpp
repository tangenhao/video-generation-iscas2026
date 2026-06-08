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
  int                nn = n;
  std::ostringstream out;
  out << std::fixed << std::setprecision(nn) << a_value;
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

  int seq_len       = 1;
  int d_model       = 128;
  int oc_group_size = 32;
  int oc_group      = d_model / oc_group_size;

  uint64_t rec_lut_ddr_base_addr   = REC_LUT_ADDR;
  uint64_t log_lut_ddr_base_addr   = LOG_LUT_ADDR;
  uint64_t exp_lut_ddr_base_addr   = EXP_LUT_ADDR;
  uint64_t rsqrt_lut_ddr_base_addr = RSQRT_LUT_ADDR;
  uint64_t data_in_ddr_base_addr   = IFMAP_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  auto data_in = randn<float>({oc_group, seq_len, oc_group_size}, kFloat32, -1.0f, 1.0f, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  auto gamma = randn<float>({oc_group, 1, oc_group_size}, kFloat32, 0.5f, 1.5f, 0);
  auto beta  = randn<float>({oc_group, 1, oc_group_size}, kFloat32, -1.0f, 1.0f, 0);

  auto para = zeros<float>({oc_group, 2, oc_group_size}, kFloat32);

  for (int i = 0; i < oc_group; i++) {
    for (int j = 0; j < oc_group_size; j++) {
      para[i * oc_group_size + j] = gamma[i * oc_group_size + j];
    }
  }

  for (int i = 0; i < oc_group; i++) {
    for (int j = 0; j < oc_group_size; j++) {
      para[oc_group * oc_group_size + i * oc_group_size + j] = beta[i * oc_group_size + j];
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(para.data_ptr()), para.numel() * sizeof(float), 32, true);

  Tensor<float> data_out({oc_group, seq_len, oc_group_size}, kFloat32);
  auto          data_mean = zeros<float>({seq_len, oc_group_size}, kFloat32);
  auto          data_var  = zeros<float>({seq_len, oc_group_size}, kFloat32);
  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    Tensor<float> sub_tensor({seq_len, oc_group_size}, kFloat32);
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter] =
          data_in[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }

    auto data_mean_temp = compute_model::function::reduce_sum(sub_tensor, 32, true);
    data_mean           = data_mean + data_mean_temp;
  }
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_mean.txt", (char*)data_mean.data_ptr(), data_mean.numel() * sizeof(float), 32, true);

  data_mean = data_mean / (-d_model);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_mean_real.txt", (char*)data_mean.data_ptr(), data_mean.numel() * sizeof(float), 32, true);

  auto data_minus_mean = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);

  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        data_minus_mean[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] =
          data_in[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter]
          + data_mean[seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_minus_mean.txt", (char*)data_minus_mean.data_ptr(), data_minus_mean.numel() * sizeof(float), 32, true);

  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    Tensor<float> sub_tensor({seq_len, oc_group_size}, kFloat32);
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter] =
          data_minus_mean[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }

    common::file_utils::saveCharArrayToFormattedTextFile(("../../sim/memory/data_var_sub_tensor_in" + to_string(oc_iter) + ".txt").c_str(),
                                                         (char*)sub_tensor.data_ptr(),
                                                         sub_tensor.numel() * sizeof(float),
                                                         32,
                                                         true);

    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter] =
          sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter] * sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }

    common::file_utils::saveCharArrayToFormattedTextFile(("../../sim/memory/data_var_sub_tensor_out" + to_string(oc_iter) + ".txt").c_str(),
                                                         (char*)sub_tensor.data_ptr(),
                                                         sub_tensor.numel() * sizeof(float),
                                                         32,
                                                         true);

    auto data_var_temp = compute_model::function::reduce_sum(sub_tensor, 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(
      ("../../sim/memory/data_var_sub_tensor_reduce_sum" + to_string(oc_iter) + ".txt").c_str(),
      (char*)data_var_temp.data_ptr(),
      data_var_temp.numel() * sizeof(float),
      32,
      true);
    data_var = data_var + data_var_temp;
    common::file_utils::saveCharArrayToFormattedTextFile(
      ("../../sim/memory/data_var_sub_tensor_result" + to_string(oc_iter) + ".txt").c_str(),
      (char*)data_var.data_ptr(),
      data_var.numel() * sizeof(float),
      32,
      true);
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_var.txt", (char*)data_var.data_ptr(), data_var.numel() * sizeof(float), 32, true);

  data_var = data_var / d_model;

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_var_real.txt", (char*)data_var.data_ptr(), data_var.numel() * sizeof(float), 32, true);

  data_var = data_var + 1e-5f;

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_var_add.txt", (char*)data_var.data_ptr(), data_var.numel() * sizeof(float), 32, true);

  data_var = compute_model::function::rsqrt(data_var);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_var_rsqrt.txt", (char*)data_var.data_ptr(), data_var.numel() * sizeof(float), 32, true);

  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        data_out[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] =
          data_minus_mean[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter]
          * data_var[seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_mul_var.txt", (char*)data_out.data_ptr(), data_out.numel() * sizeof(float), 32, true);

  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        data_out[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] =
          data_out[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter]
          * gamma[oc_iter * oc_group_size + oc_inner_iter];
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_mul_gamma.txt", (char*)data_out.data_ptr(), data_out.numel() * sizeof(float), 32, true);

  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        data_out[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] =
          data_out[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter]
          + beta[oc_iter * oc_group_size + oc_inner_iter];
      }
    }
  }
  // common::file_utils::saveCharArrayToFormattedTextFile(
  //   "../../sim/memory/data_mul_beta.txt", (char*)data_out.data_ptr(), data_out.numel() * sizeof(float), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out.data_ptr()), data_out.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */
  std::cout << to_string_with_precision(0.00001, 10) << std::endl;
  auto vcucode_series = vcu::asm_vcu_op({"config reg0, 0.0",  // write to vcures, seq_len = seq_len, oc_group = 1

                                         "redsum psum, reg3, 32",
                                         "add reg3 resadd, reg4",  // write to vcures, seq_len = seq_len, repeat oc_group times

                                         "divc resadd, reg5, " + to_string_with_precision(-d_model, 7),

                                         //  "inv resadd, reg0",
                                         "add psum resadd, reg6",  // write to psum

                                        //  "config reg0, 0.0",
                                        
                                         "mul psum psum, reg7",
                                         "redsum reg7, reg0, 32",
                                         "add reg0 resadd, reg1",  // write to vcures, seq_len = seq_len, repeat oc_group times

                                         "divc resadd, reg2, " + to_string_with_precision(d_model, 7),
                                         "addc reg2, reg3, " + to_string_with_precision(0.00001, 10),
                                         "rsqrt reg3, reg4",  // write to vcures, seq_len = seq_len, oc_group = 1

                                         "mul psum resadd, reg5",
                                         "mul reg5 para, reg6",  // write to psum, seq_len = seq_len, oc_group = 1, repeat oc_group times

                                         "add psum para, reg7"});

  auto   num_vcucodes      = vcucode_series.size();
  size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  vcucode_series.resize(vcucode_ddr_lines * 8, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  std::vector<insn::instruction> insn_series;

  insn_series.push_back(insn::load_iteration_2<0>(rec_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));

  insn_series.push_back(
    insn::load_iteration_2<0>(log_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64 * 128 / 256, 0));

  insn_series.push_back(
    insn::load_iteration_2<0>(exp_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 2 * 64 * 128 / 256, 0));

  insn_series.push_back(
    insn::load_iteration_2<0>(rsqrt_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 3 * 64 * 128 / 256, 0));

  insn_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  auto para_seq_1_offset = split_exp_fra(2 * oc_group_size * 4);

  insn_series.push_back(insn::load_iteration_2<0>(
    VCUPARA_ADDR, 2 * 4 - 1, para_seq_1_offset.first, para_seq_1_offset.second, oc_group - 1, MASTER_VCUPARA_ADDR, 0));

  auto seq_1_offset = split_exp_fra(seq_len * oc_group_size * 4);

  insn_series.push_back(insn::load_iteration_2<0>(
    data_in_ddr_base_addr, seq_len * 4 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_PSUM_ADDR, 0));

  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);
  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());

  using vcu_t = vcu::VcuExecute;
  vcu_t vcu_op;

  // 0. config vcures to 0
  vcu_t::Arguments step_0_config_args  = {0b100,                  // psum_data_type
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
  auto             step_0_config_insns = vcu_op(step_0_config_args);
  insn_series.insert(insn_series.end(), step_0_config_insns.begin(), step_0_config_insns.end());

  // 1. cal mean
  vcu_t::Arguments step_1_mean_args;
  for (uint64_t i = 0; i < oc_group; ++i) {
    step_1_mean_args       = {0b111,                  // psum_data_type
                              0b011,                  // resadd_para_type
                              0b111,                  // data_out_type
                              0b10,                   // data_out_ram
                              2,                      // opcode_number
                              1,                      // opcode_addr
                              i * seq_len,            // psum_in_addr
                              0b000000,               // para_in_addr
                              0b000000000000,         // resadd_in_addr
                              0b0000000000000,        // ram_out_addr
                              (uint64_t)seq_len - 1,  // seq_len
                              0,                      // oc_group
                              0b00,                   // para_func
                              1,                      // psum_sram_valid
                              1,                      // resadd_sram_valid
                              0,                      // para_sram_valid
                              0,                      // psum_addr_hop
                              1,                      // acc_clear
                              1                       // stream_en
                            };
    auto step_1_mean_insns = vcu_op(step_1_mean_args);
    insn_series.insert(insn_series.end(), step_1_mean_insns.begin(), step_1_mean_insns.end());
  }

  vcu_t::Arguments step_2_mul_args  = {0b111,                  // psum_data_type
                                       0b011,                  // resadd_para_type
                                       0b111,                  // data_out_type
                                       0b10,                   // data_out_ram
                                       1,                      // opcode_number
                                       3,                      // opcode_addr
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
  auto             step_2_mul_insns = vcu_op(step_2_mul_args);
  insn_series.insert(insn_series.end(), step_2_mul_insns.begin(), step_2_mul_insns.end());

  vcu_t::Arguments step_3_sub_args;
  for (uint64_t i = 0; i < oc_group; ++i) {
    step_3_sub_args       = {0b111,                  // psum_data_type
                             0b011,                  // resadd_para_type
                             0b111,                  // data_out_type
                             0b00,                   // data_out_ram
                             1,                      // opcode_number
                             4,                      // opcode_addr
                             i * seq_len,            // psum_in_addr
                             0b000000,               // para_in_addr
                             0b000000000000,         // resadd_in_addr
                             i * seq_len,            // ram_out_addr
                             (uint64_t)seq_len - 1,  // seq_len
                             0,                      // oc_group
                             0b00,                   // para_func
                             1,
                             1,
                             0};
    auto step_3_sub_insns = vcu_op(step_3_sub_args);
    insn_series.insert(insn_series.end(), step_3_sub_insns.begin(), step_3_sub_insns.end());
  }

  // 2. config vcures to 0
  insn_series.insert(insn_series.end(), step_0_config_insns.begin(), step_0_config_insns.end());

  // 3. cal var
  vcu_t::Arguments step_4_var_args;
  for (uint64_t i = 0; i < oc_group; ++i) {
    step_4_var_args       = {0b111,                  // psum_data_type
                             0b011,                  // resadd_para_type
                             0b111,                  // data_out_type
                             0b10,                   // data_out_ram
                             3,                      // opcode_number
                             5,                      // opcode_addr
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
    auto step_4_var_insns = vcu_op(step_4_var_args);
    insn_series.insert(insn_series.end(), step_4_var_insns.begin(), step_4_var_insns.end());
  }

  // 4. cal var
  vcu_t::Arguments step_5_mul_args  = {0b111,                  // psum_data_type
                                       0b011,                  // resadd_para_type
                                       0b111,                  // data_out_type
                                       0b10,                   // data_out_ram
                                       3,                      // opcode_number
                                       8,                      // opcode_addr
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
  auto             step_5_mul_insns = vcu_op(step_5_mul_args);
  insn_series.insert(insn_series.end(), step_5_mul_insns.begin(), step_5_mul_insns.end());

  // 6. cal layernorm
  vcu_t::Arguments step_6_var_args;
  for (uint64_t i = 0; i < oc_group; ++i) {
    step_6_var_args       = {0b111,                  // psum_data_type
                             0b011,                  // resadd_para_type
                             0b111,                  // data_out_type
                             0b0,                    // data_out_ram
                             2,                      // opcode_number
                             11,                     // opcode_addr
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
    auto step_6_var_insns = vcu_op(step_6_var_args);
    insn_series.insert(insn_series.end(), step_6_var_insns.begin(), step_6_var_insns.end());

    step_6_var_args  = {0b111,                  // psum_data_type
                        0b011,                  // resadd_para_type
                        0b111,                  // data_out_type
                        0b0,                    // data_out_ram
                        1,                      // opcode_number
                        13,                     // opcode_addr
                        i * seq_len,            // psum_in_addr
                        i + oc_group,           // para_in_addr
                        0b000000000000,         // resadd_in_addr
                        i * seq_len,            // ram_out_addr
                        (uint64_t)seq_len - 1,  // seq_len
                        0,                      // oc_group
                        0b00,                   // para_func
                        1,
                        0,
                        1};
    step_6_var_insns = vcu_op(step_6_var_args);
    insn_series.insert(insn_series.end(), step_6_var_insns.begin(), step_6_var_insns.end());
  }

  insn_series.push_back(insn::store_iteration_2<0>(
    data_out_ddr_base_addr, seq_len * 4 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_PSUM_ADDR, 1));

  common::insn::pad_serial_sync_word(insn_series);

  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

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