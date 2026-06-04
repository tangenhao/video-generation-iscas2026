#include "addr.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include <random>
#include <vector>

int main(int argc, const char** argv)
{
  using namespace common::insn;
  std::vector<instruction> instruction_series;
  instruction_series.push_back(synchronize_indie(2, 0, 0x100, 1, 0, 0));
  instruction_series.push_back(load_iteration_2(PSUM_ADDR, 13, 2, 112, 13, MASTER_PSUM_ADDR, 0));
  instruction_series.push_back(store_iteration_2(OFMAP_ADDR, 13, 2, 112, 13, MASTER_PSUM_ADDR, 1));

  uint64_t data_bytes = 14 * 14 * 32;

  std::string   buf0;
  std::ofstream ofs0("../../sim/memory/psum.txt");
  std::ofstream ofs1("../../sim/memory/ofmap.txt");

  if (instruction_series.size() % 2 == 1) {
    instruction_series.push_back(empty());
  }

  common::file_utils::saveCharArrayToFormattedTextFile(insn_file.c_str(),
                                                       reinterpret_cast<char*>(instruction_series.data()),
                                                       instruction_series.size() * sizeof(common::insn::instruction),
                                                       32,
                                                       true);

  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x80000000, 0x807fffff);
  uint32_t                        data;
  for (uint64_t i = 0; i < data_bytes / 4; i++) {
    data = distrib(gen);
    ofs0 << std::hex << data;
    ofs1 << std::hex << data;
    if (i % 8 == 7) {
      ofs0 << std::endl;
      ofs1 << std::endl;
    }
  }

  write_regs(reg_cfg_file.c_str(),
             0,
             instruction_series.size() * sizeof(common::insn::instruction) / 32,
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
             PSUM_LOAD_128,
             PSUM_STORE_128,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}