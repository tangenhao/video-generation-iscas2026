#include "addr.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include <iostream>
#include <random>
#include <vector>

int main()
{
  using namespace common::insn;
  std::vector<instruction> instruction_series;

  for (int i = 0; i < 256; ++i) {
    if (i == 126) {
      instruction_series.push_back(synchronize_indie(3, 4, 4, 4, 0, 0));
    }
    instruction_series.push_back(instruction(3, i));
  }

  common::file_utils::saveCharArrayToFormattedTextFile(insn_file.c_str(),
                                                       reinterpret_cast<char*>(instruction_series.data()),
                                                       instruction_series.size() * sizeof(common::insn::instruction),
                                                       32,
                                                       true);

  return 0;
}
