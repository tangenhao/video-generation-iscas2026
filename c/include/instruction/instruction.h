#pragma once

#include <cassert>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <utility>
#include <vector>

namespace common {
namespace insn {

struct insn_bits {
  uint64_t low_64;
  uint64_t high_64;
};

struct instruction {
  insn_bits storage;

  instruction() {}

  instruction(uint64_t low, uint64_t high)
  {
    storage.low_64  = low;
    storage.high_64 = high;
  }

  void print()
  {
    std::cout << std::hex << std::setw(16) << std::setfill('0') << storage.high_64 << std::setw(16) << std::setfill('0') << storage.low_64
              << std::endl;
  }

  std::pair<uint64_t, uint64_t> get()
  {
    return std::make_pair(storage.low_64, storage.high_64);
  }

  friend std::ostream& operator<<(std::ostream& os, const instruction& insn)
  {
    os << std::hex << std::setw(16) << std::setfill('0') << insn.storage.high_64 << std::setw(16) << std::setfill('0')
       << insn.storage.low_64;
    return os;
  }

  friend std::stringstream& operator<<(std::stringstream& ss, const instruction& insn)
  {
    ss << std::hex << std::setw(16) << std::setfill('0') << insn.storage.high_64 << std::setw(16) << std::setfill('0')
       << insn.storage.low_64;
    return ss;
  }

  std::string to_string()
  {
    std::stringstream ss;
    ss << *this;
    return ss.str();
  }

  instruction& get_instruction()
  {
    return *this;
  }

  void set_insn_number(uint64_t insn_number)
  {
    this->storage.low_64 = (((insn_number & 0xfL) << 6) | this->storage.low_64);
  }

  uint32_t get_insn_number()
  {
    return (this->storage.low_64 & 0x3c0) >> 6;
  }

  int get_insn_opcode()
  {
    return this->storage.low_64 & 0x3f;
  }

  void set_insn_opcode(int opcode)
  {
    this->storage.low_64 = (this->storage.low_64 & 0xffffffffffffffc0) | (opcode & 0x3f);
  }

  int get_load_insn_kind()
  {
    return (this->storage.low_64 >> 10) & 0x7;
  }

  int get_store_insn_kind()
  {
    return (this->storage.low_64 >> 10) & 0x7;
  }

  int get_sync_insn_kind()
  {
    return (this->storage.low_64 >> 6) & 0x3;
  }

  int get_vcu_insn_kind()
  {
    return (this->storage.low_64 >> 10) & 0xf;
  }

  int get_pea_insn_kind()
  {
    return (this->storage.low_64 >> 10) & 0x7;
  }
};

struct empty: public instruction {
  empty(uint64_t low, uint64_t high): instruction(low, high) {}

  empty()
  {
    instruction::storage.low_64  = 33;
    instruction::storage.high_64 = 0;
  }
};

}  // namespace insn
}  // namespace common