#include "common/insn.h"
#include <random>
#include <vector>

int main(int argc, const char** argv)
{
  using namespace common::insn;
  std::vector<instruction> instruction_series;
  instruction_series.push_back(synchronize_cross_load(1, 0x400016, 1, 2, 0, 0, 0, 0));
  instruction_series.push_back(load_iteration_2(0x0, 55, 4, 112, 55, 0x30000, 0));

  instruction_series.push_back(synchronize_indie(1, 0, 0, 1, 0, 0));
  instruction_series.push_back(load_iteration_2(0x0, 55, 4, 112, 55, 0x30000, 0));

  instruction_series.push_back(synchronize_indie(1, 0, 0, 1, 0, 0));
  instruction_series.push_back(load_iteration_2(0x0, 55, 4, 112, 55, 0x30000, 0));

  instruction_series.push_back(synchronize_indie(1, 0, 0, 1, 0, 0));
  instruction_series.push_back(load_iteration_2(0x0, 55, 4, 112, 55, 0x30000, 0));

  instruction_series.push_back(synchronize_indie(1, 0, 0, 1, 0, 0));
  instruction_series.push_back(load_iteration_2(0x0, 55, 4, 112, 55, 0x30000, 0));

  instruction_series.push_back(synchronize_indie(1, 0, 0, 2, 0, 0));
  instruction_series.push_back(store_iteration_2(0, 55, 4, 112, 55, 0x30000, 1));

  uint64_t data_bytes = 56 * 56 * 32;

  std::string   buf0;
  std::ofstream ofs0("../../sim/memory/ddr0.txt");

  if (instruction_series.size() % 4 == 1) {
    instruction_series.push_back(empty());
    instruction_series.push_back(empty());
    instruction_series.push_back(empty());
  }
  else if (instruction_series.size() % 4 == 2) {
    instruction_series.push_back(empty());
    instruction_series.push_back(empty());
  }
  else if (instruction_series.size() % 4 == 3) {
    instruction_series.push_back(empty());
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
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x80000000, 0x807fffff);
  uint32_t                        data;
  for (uint64_t i = 0; i < data_bytes / 4; i++) {
    data = distrib(gen);
    ofs0 << data;
    if (i % 8 == 7) {
      ofs0 << std::endl;
    }
  }

  return 0;
}