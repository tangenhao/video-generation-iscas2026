#include "addr.h"
#include "common/insn.h"
#include <vector>

int main(int argc, const char** argv)
{

  std::vector<common::insn::instruction> instruction_series;

  // common::insn::store_insn store_insn(0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x8000, 1);
  instruction_series.push_back(common::insn::synchronize_indie(3, 5, 1, 1, 0, 0));
  instruction_series.push_back(common::insn::synchronize_indie(3, 5, 5, 5, 0, 0));
  instruction_series.push_back(common::insn::synchronize_indie(3, 5, 5, 5, 0, 0));
  instruction_series.push_back(common::insn::synchronize_indie(3, 5, 5, 5, 0, 0));
  instruction_series.push_back(common::insn::synchronize_indie(3, 5, 5, 5, 0, 0));
  instruction_series.push_back(common::insn::synchronize_indie(3, 5, 5, 5, 0, 0));
  instruction_series.push_back(common::insn::synchronize_indie(3, 5, 5, 5, 0, 0));
  instruction_series.push_back(common::insn::synchronize_indie(1, 0, 0, 4, 0, 0));
  for (int i = 0; i < 20; ++i) {
    instruction_series.push_back(common::insn::load_iteration_4(0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, MASTER_PSUM_ADDR + i, 0));
    if (i == 0) {
      instruction_series[9].set_insn_number(0);
    }
    else {
      instruction_series[9 + i * 3].set_insn_number(1);
    }
    instruction_series.push_back(common::insn::load_iteration_4(0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, MASTER_PSUM_ADDR + i + 1, 0));
    instruction_series.push_back(common::insn::convolution_execute(0, 0, 0, 0, 13, 13, 2, 2, 13, 13, 0, 0, 0, 0, 0, 1, 1, 8, 0));
  }
  instruction_series.push_back(common::insn::load_iteration_4(0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, MASTER_PSUM_ADDR, 0));
  instruction_series.push_back(common::insn::load_iteration_4(0, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, MASTER_PSUM_ADDR, 0));
  instruction_series.push_back(common::insn::vcu_execute(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
  instruction_series.push_back(common::insn::store_iteration_4(0, 31, 0, 0, 31, 0, 0, 0, 0, 0, 0, MASTER_PSUM_ADDR, 1));
  std::string buf0;

  std::ofstream ofs0("../../sim/memory/ddr0.txt");

  if (instruction_series.size() % 4 == 1) {
    instruction_series.push_back(common::insn::empty());
    instruction_series.push_back(common::insn::empty());
    instruction_series.push_back(common::insn::empty());
  }
  else if (instruction_series.size() % 4 == 2) {
    instruction_series.push_back(common::insn::empty());
    instruction_series.push_back(common::insn::empty());
  }
  else if (instruction_series.size() % 4 == 3) {
    instruction_series.push_back(common::insn::empty());
  }

  int ddr_switch = 0;
  for (auto& insn : instruction_series) {
    if (ddr_switch % 2 == 0) {
      buf0 = insn.to_string();
    }
    else if (ddr_switch % 2 == 1) {
      ofs0 << insn;
      ofs0 << buf0 << std::endl;
    }
    ddr_switch++;
  }

  return 0;
}
