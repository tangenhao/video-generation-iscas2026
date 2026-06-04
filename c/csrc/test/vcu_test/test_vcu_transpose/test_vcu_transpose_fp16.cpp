#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
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

  uint64_t psum_sram_read_addr  = 8192;
  uint64_t psum_sram_write_addr = 0;

  using namespace compute_model::common::fp16;

  auto data = randn<half>({32, 32}, kHalf, -1.0f, 1.0f, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data.data_ptr()), data.numel() * sizeof(uint16_t), 32, true);

  std::vector<insn::instruction> insn_series;

  insn_series.push_back(insn::load_iteration_2(data_in_ddr_base_addr, 32 * 2 - 1, 0, 0, 0, MASTER_PSUM_ADDR + 8192 * 2, 0));

  using vcu_transpose_t           = vcu::VcuTranspose;
  vcu_transpose_t::Arguments args = {2, psum_sram_read_addr, psum_sram_write_addr};
  vcu_transpose_t            vcu_transpose;
  auto                       vcu_transpose_insn = vcu_transpose(args);

  insn_series.insert(insn_series.end(), vcu_transpose_insn.begin(), vcu_transpose_insn.end());

  insn_series.push_back(insn::store_iteration_2(data_out_ddr_base_addr, 32 * 2 - 1, 0, 0, 0, MASTER_PSUM_ADDR, 1));
  common::insn::pad_serial_sync_word(insn_series);

  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  auto ofmap = data;

  for (int i = 0; i < 32; ++i) {
    for (int j = 0; j < 32; ++j) {
      int ori_idx    = i * 32 + j;
      int new_idx    = j * 32 + i;
      ofmap[new_idx] = data[ori_idx];
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), ofmap.data_ptr<char>(), ofmap.numel() * sizeof(uint16_t), 32, true);

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
             PSUM_STORE_512,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}