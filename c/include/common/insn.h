#pragma once

#include "instruction/instruction.h"
#include "instruction/load_instruction.h"
#include "instruction/pea_instruction.h"
#include "instruction/store_instruction.h"
#include "instruction/synchronize_instruction.h"
#include "instruction/vcu_instruction.h"

namespace common {
namespace insn {

void check_value(uint64_t insnword, uint64_t insnbits, const char* sectionName)
{
  assert(insnbits <= 64);
  printf("name: %s, bits: %ld, value: %ld\n", sectionName, insnbits, insnword);
  uint64_t max_value = (1ULL << insnbits);
  assert(insnword < max_value);
}

void pad_serial_sync_word(std::vector<instruction>& instructions)
{
  int64_t valid_insn_cnt = instructions.size();
  int64_t sync_insn_cnt  = (valid_insn_cnt - 1) / 3 + 1;
  int64_t pad_insn_cnt   = sync_insn_cnt * 3 - valid_insn_cnt;
  int64_t total_insn_cnt = valid_insn_cnt + pad_insn_cnt + sync_insn_cnt;
  int64_t valid_pad_insn_cnt =
    ((total_insn_cnt % 2) <= pad_insn_cnt) ? (pad_insn_cnt - (total_insn_cnt % 2)) : pad_insn_cnt + 2 - (total_insn_cnt % 2);

  std::vector<int64_t> sync_words;

  for (int i = 0; i < valid_pad_insn_cnt; i++) {
    instructions.push_back(empty().get_instruction());
  }

  for (int i = 0; i < total_insn_cnt; ++i) {
    sync_words.push_back(pow(2, instructions[i].get_insn_opcode() - 1));
  }

  for (int i = 0; i < sync_insn_cnt; ++i) {
    instructions.insert(instructions.begin() + i * 3 + i,
                        synchronize_indie((i == sync_insn_cnt - 1) ? (valid_insn_cnt - (sync_insn_cnt - 1) * 3) : 3,
                                          sync_words[i * 3 + 2],
                                          sync_words[i * 3 + 1],
                                          sync_words[i * 3],
                                          0,
                                          0));
  }
}

}  // namespace insn
}  // namespace common