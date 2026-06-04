#include "addr.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/subbyte.h"
#include "compute_model/common/tensor.h"
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

  uint64_t data_in_ddr_base_addr  = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr = OFMAP_ADDR;

  int      num_data              = 10;
  int      oc_group              = 1;
  uint64_t psum_sram_read_addr   = 0;
  uint64_t ofmap_sram_write_addr = 1024;
  int      k_group_size          = 16;
  int      n_group_size          = 32;

  using namespace compute_model::common::fp16;

  auto data = randn<half>({oc_group, num_data, n_group_size}, kHalf, -1.0f, 1.0f, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data.data_ptr()), data.numel() * sizeof(half), 32, true);

  auto data_reshape = zeros<half>({oc_group * 2, num_data, k_group_size}, kHalf);

  for (int i = 0; i < oc_group; ++i) {
    for (int j = 0; j < num_data; ++j) {
      for (int k = 0; k < n_group_size; ++k) {
        int ori_idx = i * num_data * n_group_size + j * n_group_size + k;
        int dst_idx;
        if (k < k_group_size) {
          dst_idx = 2 * i * num_data * k_group_size + j * k_group_size + k;
        }
        else {
          dst_idx = (2 * i + 1) * num_data * k_group_size + j * k_group_size + k - k_group_size;
        }
        data_reshape[dst_idx] = data[ori_idx];
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), (char*)data_reshape.data_ptr(), data_reshape.numel() * sizeof(half), 32, true);

  std::vector<insn::instruction> insn_series;

  auto seq_1_offset = split_exp_fra(64 * num_data);

  insn_series.push_back(insn::load_iteration_2(
    data_in_ddr_base_addr, num_data * 2 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_PSUM_ADDR, 0));

  using vcu_convertion_t           = vcu::VcuParallelismConvertion;
  vcu_convertion_t::Arguments args = {
    0, psum_sram_read_addr, ofmap_sram_write_addr, (uint64_t)num_data, (uint64_t)oc_group, (uint64_t)(oc_group * 2)};
  vcu_convertion_t vcu_convertion;
  auto             vcu_convertion_insn = vcu_convertion(args);

  insn_series.insert(insn_series.end(), vcu_convertion_insn.begin(), vcu_convertion_insn.end());

  seq_1_offset = split_exp_fra(32 * num_data);
  insn_series.push_back(insn::store_iteration_2(
    data_out_ddr_base_addr, num_data - 1, seq_1_offset.first, seq_1_offset.second, oc_group * 2 - 1, MASTER_OFMAP_ADDR + 1024, 1));
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
             PSUM_LOAD_512,
             PSUM_STORE_1024,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}