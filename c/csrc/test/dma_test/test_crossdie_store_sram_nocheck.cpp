#include "addr.h"
#include "common/insn.h"
#include <iomanip>
#include <random>
#include <vector>

int main(int argc, const char** argv)
{
  std::vector<common::insn::instruction> instruction_series;
  instruction_series.push_back(common::insn::synchronize_indie(1, 0, 0, 1, 0, 0));
  instruction_series.push_back(common::insn::load_iteration_2(0, 55, 4, 112, 55, MASTER_PSUM_ADDR, 1));
  instruction_series.push_back(common::insn::synchronize_cross_store(2, 0x400016, 1, 2, 0, 0, 0, 1));
  instruction_series.push_back(common::insn::store_iteration_2(SLAVE_PSUM_ADDR, 55, 4, 112, 55, MASTER_PSUM_ADDR, 1));

  uint64_t data_bytes = 56 * 56 * 32;

  std::string   buf0;
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
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x80000000, 0x807fffff);
  uint32_t                        data;
  for (uint64_t i = 0; i < data_bytes / 4; i++) {
    data = distrib(gen);
    ofs0 << std::hex << std::setfill('0') << std::setw(8) << data;
    if (i % 8 == 7) {
      ofs0 << std::endl;
    }
  }
  std::ofstream ofs1("../../sim/memory/ddr1.txt");

  return 0;
}