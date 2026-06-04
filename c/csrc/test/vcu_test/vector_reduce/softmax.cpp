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

  int seq_len       = 64;
  int d_model       = 128;
  int oc_group_size = 32;
  int oc_group      = d_model / oc_group_size;

  uint64_t rec_lut_ddr_base_addr   = REC_LUT_ADDR;
  uint64_t log_lut_ddr_base_addr   = LOG_LUT_ADDR;
  uint64_t exp_lut_ddr_base_addr   = EXP_LUT_ADDR;
  uint64_t rsqrt_lut_ddr_base_addr = RSQRT_LUT_ADDR;
  uint64_t data_in_ddr_base_addr   = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  auto data_in = randn<float>({oc_group, seq_len, oc_group_size}, kFloat32, -1.0f, 1.0f, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  auto data_exp = data_in * (std::log2(exp(1.0f)));
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_exp_mul.txt", (char*)data_exp.data_ptr(), data_exp.numel() * sizeof(float), 32, true);

  data_exp = compute_model::function::exp2(data_exp);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_exp.txt", (char*)data_exp.data_ptr(), data_exp.numel() * sizeof(float), 32, true);

  Tensor<float> data_out({oc_group, seq_len, oc_group_size}, kFloat32);
  auto          data_sum = zeros<float>({seq_len, oc_group_size}, kFloat32);
  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    Tensor<float> sub_tensor({seq_len, oc_group_size}, kFloat32);
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter] =
          data_exp[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }

    auto data_sum_temp = compute_model::function::reduce_sum(sub_tensor, 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(("../../sim/memory/data_sum_temp_" + std::to_string(oc_iter) + ".txt").c_str(),
                                                         (char*)data_sum_temp.data_ptr(),
                                                         data_sum_temp.numel() * sizeof(float),
                                                         32,
                                                         true);
    data_sum = data_sum + data_sum_temp;
    common::file_utils::saveCharArrayToFormattedTextFile(("../../sim/memory/data_sum_" + std::to_string(oc_iter) + ".txt").c_str(),
                                                         (char*)data_sum.data_ptr(),
                                                         data_sum.numel() * sizeof(float),
                                                         32,
                                                         true);
  }

  auto sum_rec = compute_model::function::reciprocal(data_sum);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/sum_rec.txt", (char*)sum_rec.data_ptr(), sum_rec.numel() * sizeof(float), 32, true);

  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        data_out[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] =
          data_exp[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter]
          * sum_rec[seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), (char*)data_out.data_ptr(), data_out.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */

  auto vcucode_series = vcu::asm_vcu_op({
    "config reg0, 0.0",  // write to vcures, seq_len = seq_len, oc_group = 1

    "mulc psum, reg0, " + std::to_string(std::log2(exp(1.0f))),
    "exp2 reg0, reg0",  // write to psum, seq_len = seq_len, oc_group = oc_group

    "redsum psum, reg0, 32",
    "add reg0 resadd, reg1",  // write to vcures, seq_len = seq_len, repeat oc_group times

    "rec resadd, reg0",  // write to vcures, seq_len = seq_len, oc_group = 1

    "mul psum resadd, reg0",  // write to psum, seq_len = seq_len, oc_group = 1, repeat oc_group times
  });

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

  // 0. config
  vcu_t::Arguments step_0_config_args  = {0b100,                  // psum_data_type
                                          0b011,                  // resadd_para_type
                                          0b111,                  // data_out_type
                                          0b10,                   // data_out_ram
                                          1,                      // opcode_number
                                          0b0000000,              // opcode_addr
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

  // 1. exp
  vcu_t::Arguments step_1_redsum_args  = {0b111,                   // psum_data_type
                                          0b011,                   // resadd_para_type
                                          0b111,                   // data_out_type
                                          0b00,                    // data_out_ram
                                          2,                       // opcode_number
                                          0b0000001,               // opcode_addr
                                          0b0000000000000,         // psum_in_addr
                                          0b000000,                // para_in_addr
                                          0b000000000000,          // resadd_in_addr
                                          0b0000000000000,         // ram_out_addr
                                          (uint64_t)seq_len - 1,   // seq_len
                                          (uint64_t)oc_group - 1,  // oc_group
                                          0b00,                    // para_func
                                          1,
                                          0,
                                          0};
  auto             step_1_redsum_insns = vcu_op(step_1_redsum_args);
  insn_series.insert(insn_series.end(), step_1_redsum_insns.begin(), step_1_redsum_insns.end());

  // 2. redsum
  vcu_t::Arguments step_2_redsum_args;
  for (uint64_t i = 0; i < oc_group; ++i) {
    step_2_redsum_args       = {0b111,                  // psum_data_type
                                0b011,                  // resadd_para_type
                                0b111,                  // data_out_type
                                0b10,                   // data_out_ram
                                2,                      // opcode_number
                                0b0000011,              // opcode_addr
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
    auto step_2_redsum_insns = vcu_op(step_2_redsum_args);
    insn_series.insert(insn_series.end(), step_2_redsum_insns.begin(), step_2_redsum_insns.end());
  }

  // 3. reciprocal
  vcu_t::Arguments step_3_reciprocal_args  = {0b111,                  // psum_data_type
                                              0b011,                  // resadd_para_type
                                              0b111,                  // data_out_type
                                              0b10,                   // data_out_ram
                                              1,                      // opcode_number
                                              0b0000101,              // opcode_addr
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
  auto             step_3_reciprocal_insns = vcu_op(step_3_reciprocal_args);
  insn_series.insert(insn_series.end(), step_3_reciprocal_insns.begin(), step_3_reciprocal_insns.end());

  // 4. mul
  vcu_t::Arguments step_4_mul_args;
  for (uint64_t i = 0; i < oc_group; ++i) {
    step_4_mul_args       = {0b111,                  // psum_data_type
                             0b011,                  // resadd_para_type
                             0b111,                  // data_out_type
                             0b00,                   // data_out_ram
                             1,                      // opcode_number
                             0b0000110,              // opcode_addr
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
    auto step_4_mul_insns = vcu_op(step_4_mul_args);
    insn_series.insert(insn_series.end(), step_4_mul_insns.begin(), step_4_mul_insns.end());
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