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
#include <algorithm>
#include <iomanip>
#include <sstream>
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

  // int h = 14;
  // int w = 14;

  int seq_len       = 1;
  int d_model       = 1152;
  int oc_group_size = 36;
  int oc_group      = d_model / oc_group_size;

  uint64_t psum_data_type   = vcu_psum_dtype.at(kHalf);
  uint64_t resadd_para_type = vcu_resadd_dtype.at(kHalf);
  uint64_t data_out_type    = vcu_out_dtype.at(kHalf);
  uint64_t data_out_ram     = 0b0;
  uint64_t opcode_number    = 0b0001000;
  uint64_t opcode_addr      = 0b0000000;
  uint64_t psum_in_addr     = 0b0000000000000;
  uint64_t para_in_addr     = 0b000000;
  uint64_t resadd_in_addr   = 0b000000000000;
  uint64_t ram_out_addr     = 0b0000000000000;
  int      num_data         = oc_group;
  uint64_t para_func        = 0b00;
  uint64_t bytes_input      = sizeof(half);

  uint64_t rec_lut_ddr_base_addr   = REC_LUT_ADDR;
  uint64_t log_lut_ddr_base_addr   = LOG_LUT_ADDR;
  uint64_t exp_lut_ddr_base_addr   = EXP_LUT_ADDR;
  uint64_t rsqrt_lut_ddr_base_addr = RSQRT_LUT_ADDR;
  uint64_t data_in_ddr_base_addr   = IFMAP_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 data gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  auto data_in = randn<half>({oc_group, seq_len, oc_group_size}, kHalf, half(-1.0f), half(1.0f), 0);

  Tensor<half> data_out({oc_group, seq_len, oc_group_size}, kHalf);
  std::vector<half> row_sum(oc_group * seq_len);
  for (int row = 0; row < oc_group * seq_len; ++row) {
    float sum = 0.0f;
    for (int j = 0; j < oc_group_size; ++j) {
      sum += static_cast<float>(data_in[row * oc_group_size + j]);
    }
    half sum_half(sum);
    row_sum[row] = sum_half;
    for (int j = 0; j < oc_group_size; ++j) {
      data_out[row * oc_group_size + j] = sum_half;
    }
  }

  auto fp16_hex = [](half value) {
    std::ostringstream oss;
    oss << "0x" << std::hex << std::setw(4) << std::setfill('0') << value.storage;
    return oss.str();
  };

  std::cout << std::fixed << std::setprecision(6);
  std::cout << "\n================ reduce_sum pipeline golden ================\n";
  std::cout << "shape: oc_group=" << oc_group << ", seq_len=" << seq_len << ", oc_group_size=" << oc_group_size << "\n";
  std::cout << "dtype: fp16\n";
  std::cout << "input fp16 hex values:\n";
  for (int row = 0; row < oc_group * seq_len; ++row) {
    for (int lane_base = 0; lane_base < oc_group_size; lane_base += 18) {
      int lane_end = std::min(lane_base + 17, oc_group_size - 1);
      std::cout << "  row[" << std::setw(2) << row << "] lane[" << std::setw(2) << lane_base << ":" << std::setw(2) << lane_end
                << "]:";
      for (int lane = lane_base; lane <= lane_end; ++lane) {
        std::cout << " " << fp16_hex(data_in[row * oc_group_size + lane]);
      }
      std::cout << "\n";
    }
  }
  if (row_sum.size() == 1) {
    std::cout << "expected scalar sum: " << fp16_hex(row_sum[0]) << " (" << static_cast<float>(row_sum[0]) << ")\n";
  }
  else {
    std::cout << "expected row sums:\n";
    for (int row = 0; row < oc_group * seq_len; ++row) {
      std::cout << "  row[" << std::setw(2) << row << "] sum = " << fp16_hex(row_sum[row]) << " (" << std::setw(10)
                << static_cast<float>(row_sum[row]) << ")\n";
    }
  }
  std::cout << "=============================================================\n\n";

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), (char*)data_out.data_ptr(), data_out.numel() * sizeof(half), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */

  auto vcucode_series = vcu::asm_vcu_op({"redsum ifmap, reg11, 36"});

  auto   num_vcucodes      = vcucode_series.size();
  size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  vcucode_series.resize(vcucode_ddr_lines * 8, 0);

  // for (auto code : vcucode_series) {
  //   std::cout << std::hex << code << std::endl;
  // }

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  std::vector<insn::instruction> insn_series;

  insn_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  auto seq_1_bytes = oc_group_size * bytes_input * oc_group;
  auto seq_1_lines = seq_1_bytes  / 32;
  auto seq_1_offset = split_exp_fra(seq_1_bytes);

  insn_series.push_back(insn::load_iteration_2<0>(
    data_in_ddr_base_addr, seq_1_lines - 1, seq_1_offset.first, seq_1_offset.second, seq_len - 1, MASTER_IFMAP_ADDR, 0));

  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);

  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());
  using vcu_t           = vcu::VcuExecute;
  vcu_t::Arguments args = {psum_data_type,
                           resadd_para_type,
                           data_out_type,
                           data_out_ram,
                           num_vcucodes,
                           opcode_addr,
                           psum_in_addr,
                           para_in_addr,
                           resadd_in_addr,
                           ram_out_addr,
                           (uint64_t)num_data - 1,
                           (uint64_t)oc_group - 1,
                           para_func,
                           0,                      // psum_sram_valid
                           0,                      // resadd_sram_valid
                           0,                      // para_sram_valid
                           0,                      // psum_addr_hop
                           0,                      // acc_clear
                           1,                      // stream_en
                           1,                      // ifmap_sram_valid
                           0                       // ifmap_in_addr  
                          };

  vcu_t vcu_op;
  auto  vcu_insns = vcu_op(args);

  insn_series.insert(insn_series.end(), vcu_insns.begin(), vcu_insns.end());

  insn_series.push_back(insn::store_iteration_2<0>(
    data_out_ddr_base_addr, seq_1_lines - 1, seq_1_offset.first, seq_1_offset.second, seq_len - 1, MASTER_PSUM_ADDR, 1));


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
