#include "addr.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include <vector>

using namespace common;

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

insn::instruction LoadWeight(int64_t ddr_base_addr,
                             int64_t oc_group,
                             int64_t ic_group,
                             int64_t h,
                             int64_t w,
                             int64_t block_oc_group,
                             int64_t block_ic_group,
                             int64_t block_h,
                             int64_t block_w,
                             int64_t sram_addr)
{
  int bytes_weight  = 2;
  int ic_group_size = 16;
  int oc_group_size = 32;

  auto seq_1_offset = split_exp_fra(bytes_weight * ic_group_size * oc_group_size * w);
  auto seq_2_offset = split_exp_fra(bytes_weight * ic_group_size * oc_group_size * w * h);
  auto seq_3_offset = split_exp_fra(bytes_weight * ic_group_size * oc_group_size * w * h * ic_group);

  return insn::load_iteration_4(ddr_base_addr,
                                block_w * oc_group_size - 1,
                                seq_1_offset.first,
                                seq_1_offset.second,
                                block_h - 1,
                                seq_2_offset.first,
                                seq_2_offset.second,
                                block_ic_group - 1,
                                seq_3_offset.first,
                                seq_3_offset.second,
                                block_oc_group - 1,
                                sram_addr,
                                0);
}

int main()
{
  using namespace common;

  std::vector<insn::instruction> instructions;

  instructions.push_back(LoadWeight(0, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR));
  instructions.push_back(LoadWeight(0x200, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x200));
  instructions.push_back(LoadWeight(0x400, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x400));
  instructions.push_back(LoadWeight(0x600, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x600));
  instructions.push_back(LoadWeight(0x800, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x800));
  instructions.push_back(LoadWeight(0xa00, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0xa00));
  instructions.push_back(LoadWeight(0xc00, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0xc00));
  instructions.push_back(LoadWeight(0xe00, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0xe00));
  instructions.push_back(LoadWeight(0x1000, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x1000));
  instructions.push_back(LoadWeight(0x1200, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x1200));
  instructions.push_back(LoadWeight(0x1400, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x1400));
  instructions.push_back(LoadWeight(0x1600, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x1600));
  instructions.push_back(LoadWeight(0x1800, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x1800));
  instructions.push_back(LoadWeight(0x1a00, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x1a00));
  instructions.push_back(LoadWeight(0x1c00, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x1c00));
  instructions.push_back(LoadWeight(0x1e00, 16, 1, 1, 1, 1, 1, 1, 1, MASTER_WEIGHT_ADDR + 0x1e00));

  pad_serial_sync_word(instructions);

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(instructions.data()), instructions.size() * sizeof(common::insn::instruction), 32, true);

  return 0;
}