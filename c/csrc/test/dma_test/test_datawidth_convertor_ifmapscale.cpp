#include "common/insn.h"
#include <random>
#include <vector>

int main(int argc, const char** argv)
{
  std::vector<common::insn::instruction> instruction_series;
  instruction_series.push_back(common::insn::synchronize_indie(2, 0, 0, 0, 0, 2, 1, 0, 0).get_instruction());

  instruction_series.push_back(common::insn::load_iteration_4(0, 55, 5, 112, 55, 0, 0, 0, 0, 0, 0, 0x10000, 0).get_instruction());

  instruction_series.push_back(common::insn::store_iteration_4(0, 55, 5, 112, 55, 0, 0, 0, 0, 0, 0, 0x10000, 1).get_instruction());

  uint64_t data_bytes = 56 * 56 * 64;

  std::string   buf0;
  std::string   buf1;
  std::ofstream ofs0("../../sim/memory/ddr0.txt");
  std::ofstream ofs1("../../sim/memory/ddr1.txt");

  if (instruction_series.size() % 4 == 1) {
    instruction_series.push_back(common::insn::empty().get_instruction());
    instruction_series.push_back(common::insn::empty().get_instruction());
    instruction_series.push_back(common::insn::empty().get_instruction());
  }
  else if (instruction_series.size() % 4 == 2) {
    instruction_series.push_back(common::insn::empty().get_instruction());
    instruction_series.push_back(common::insn::empty().get_instruction());
  }
  else if (instruction_series.size() % 4 == 3) {
    instruction_series.push_back(common::insn::empty().get_instruction());
  }

  int ddr_switch = 0;
  for (auto& insn : instruction_series) {
    if (ddr_switch % 4 == 0) {
      buf0 = insn.to_string();
    }
    else if (ddr_switch % 4 == 1) {
      ofs0 << insn;
      ofs0 << buf0 << std::endl;
    }
    else if (ddr_switch % 4 == 2) {
      buf1 = insn.to_string();
    }
    else {
      ofs1 << insn;
      ofs1 << buf1 << std::endl;
    }
    ddr_switch++;
  }
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x80000000, 0x807fffff);
  uint32_t                        data;
  for (uint64_t i = 0; i < data_bytes / 2 / 4; i++) {
    data = distrib(gen);
    ofs0 << data;
    data = distrib(gen);
    ofs1 << data;
    if (i % 8 == 7) {
      ofs0 << std::endl;
      ofs1 << std::endl;
    }
  }
}