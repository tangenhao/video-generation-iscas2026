#pragma once

#include "instruction/instruction.h"
#include "instruction/load_instruction.h"
#include "instruction/pea_instruction.h"
#include "instruction/store_instruction.h"
#include "instruction/synchronize_instruction.h"
#include "instruction/vcu_instruction.h"

#include <algorithm>
#include <initializer_list>

namespace common {
namespace insn {

/*
 * Manual sync word usage:
 *
 * Use sync_word_list as a Python-list-like container while generating normal
 * instructions. After all normal instructions are generated, call
 * pad_manual_sync_word() once. It packs every three sync_words into one
 * synchronize_indie instruction and inserts the sync instructions into the
 * instruction stream.
 *
 * Example:
 *
 *   std::vector<insn::instruction> instruction_series;
 *   insn::sync_word_list sync_words;
 *
 *   if (n_iter == 0 && m_iter == 0 && k_iter == 0) {
 *     sync_words.append(insn::sync_word().load(0).load(1));
 *   }
 *
 *   if (need_pea_vcu) {
 *     sync_words.append(insn::sync_word().pea(0).vcu(0));
 *   }
 *
 *   sync_words.insert(1, insn::sync_word().store(0));
 *
 *   instruction_series.push_back(LoadIfmap(...));
 *   instruction_series.push_back(insn::gemm_execute(...));
 *   instruction_series.push_back(Store(...));
 *
 *   insn::pad_manual_sync_word(instruction_series, sync_words);
 * 
 *   如果你只想生成同步指令列表，不想插入到普通指令流里，也可以用 make_indie_sync_instructions(sync_words)。
 *
 * Do not call pad_serial_sync_word() or manually push synchronize_indie when
 * using this manual sync_words path.
 */

enum class sync_module {
  load  = 0,
  store = 8,
  pea   = 16,
  vcu   = 24,
};

inline uint32_t sync_bit(sync_module module, uint32_t index)
{
  assert(index < 8);
  return (uint32_t(1) << (static_cast<uint32_t>(module) + index));
}

inline uint32_t make_sync_word(std::initializer_list<uint32_t> bits)
{
  uint32_t word = 0;
  for (auto bit : bits) {
    word |= bit;
  }
  return word;
}

struct sync_word {
  uint32_t value = 0;

  sync_word& set(sync_module module, uint32_t index)
  {
    value |= sync_bit(module, index);
    return *this;
  }

  sync_word& load(uint32_t index)
  {
    return set(sync_module::load, index);
  }

  sync_word& store(uint32_t index)
  {
    return set(sync_module::store, index);
  }

  sync_word& pea(uint32_t index)
  {
    return set(sync_module::pea, index);
  }

  sync_word& vcu(uint32_t index)
  {
    return set(sync_module::vcu, index);
  }

  operator uint32_t() const
  {
    return value;
  }
};

struct sync_word_list {
  std::vector<uint32_t> words;

  void append(uint32_t word)
  {
    words.push_back(word);
  }

  void append(sync_word word)
  {
    words.push_back(word.value);
  }

  void insert(size_t index, uint32_t word)
  {
    assert(index <= words.size());
    words.insert(words.begin() + index, word);
  }

  void insert(size_t index, sync_word word)
  {
    insert(index, word.value);
  }

  void erase(size_t index)
  {
    assert(index < words.size());
    words.erase(words.begin() + index);
  }

  void clear()
  {
    words.clear();
  }

  size_t size() const
  {
    return words.size();
  }

  bool empty() const
  {
    return words.empty();
  }

  uint32_t& operator[](size_t index)
  {
    return words[index];
  }

  const uint32_t& operator[](size_t index) const
  {
    return words[index];
  }
};

void check_value(uint64_t insnword, uint64_t insnbits, const char* sectionName)
{
  assert(insnbits <= 64);
  printf("name: %s, bits: %ld, value: %ld\n", sectionName, insnbits, insnword);
  uint64_t max_value = (1ULL << insnbits);
  assert(insnword < max_value);
}

inline std::vector<instruction> make_indie_sync_instructions(const std::vector<uint32_t>& sync_words,
                                                             uint64_t                     load_highaddr_config  = 0,
                                                             uint64_t                     store_highaddr_config = 0)
{
  std::vector<instruction> sync_insns;
  int64_t                  word_cnt      = static_cast<int64_t>(sync_words.size());
  int64_t                  sync_insn_cnt = (word_cnt + 2) / 3;

  sync_insns.reserve(sync_insn_cnt);
  for (int64_t i = 0; i < sync_insn_cnt; ++i) {
    int64_t base               = i * 3;
    int64_t valid_word_cnt     = std::min<int64_t>(3, word_cnt - base);
    uint32_t sync_word_0       = (valid_word_cnt > 0) ? sync_words[base] : 0;
    uint32_t sync_word_1       = (valid_word_cnt > 1) ? sync_words[base + 1] : 0;
    uint32_t sync_word_2       = (valid_word_cnt > 2) ? sync_words[base + 2] : 0;
    sync_insns.push_back(synchronize_indie(valid_word_cnt,
                                           sync_word_0,
                                           sync_word_1,
                                           sync_word_2,
                                           load_highaddr_config,
                                           store_highaddr_config)
                           .get_instruction());
  }

  return sync_insns;
}

inline std::vector<instruction> make_indie_sync_instructions(const sync_word_list& sync_words,
                                                             uint64_t              load_highaddr_config  = 0,
                                                             uint64_t              store_highaddr_config = 0)
{
  return make_indie_sync_instructions(sync_words.words, load_highaddr_config, store_highaddr_config);
}

inline void pad_manual_sync_word(std::vector<instruction>& instructions,
                                 const std::vector<uint32_t>& sync_words,
                                 uint64_t                     load_highaddr_config  = 0,
                                 uint64_t                     store_highaddr_config = 0)
{
  auto sync_insns = make_indie_sync_instructions(sync_words, load_highaddr_config, store_highaddr_config);

  for (size_t i = 0; i < sync_insns.size(); ++i) {
    size_t insert_pos = i * 4;
    if (insert_pos > instructions.size()) {
      insert_pos = instructions.size();
    }
    instructions.insert(instructions.begin() + insert_pos, sync_insns[i]);
  }

  while ((instructions.size() % 2) != 0) {
    instructions.push_back(empty().get_instruction());
  }
}

inline void pad_manual_sync_word(std::vector<instruction>& instructions,
                                 const sync_word_list&      sync_words,
                                 uint64_t                   load_highaddr_config  = 0,
                                 uint64_t                   store_highaddr_config = 0)
{
  pad_manual_sync_word(instructions, sync_words.words, load_highaddr_config, store_highaddr_config);
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
