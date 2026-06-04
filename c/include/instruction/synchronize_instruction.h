#pragma once

#include "instruction/instruction.h"

namespace common {
namespace insn {

typedef struct {
  uint64_t insn_opcode : 6;            // 0 + 6 = 6
  uint64_t sync_insns : 2;             // 6 + 2 = 8
  uint64_t valid_insn_number : 2;      // 8 + 2 = 10
  uint64_t sync_word_0 : 32;           // 10 + 32 = 42
  uint64_t sync_word_1_low : 22;       // 42 + 22 = 64
  uint64_t sync_word_1_high : 10;      // 64 + 10 = 74
  uint64_t sync_word_2 : 32;           // 74 + 32 = 106
  uint64_t load_highaddr_config : 1;   // 106 + 1 = 107
  uint64_t store_highaddr_config : 1;  // 107 + 1 = 108
  uint64_t reserved : 19;              // 108 + 19 = 127
} synchronize_indie_bits;

typedef struct {
  uint64_t insn_opcode : 6;         // 0 + 6 = 6
  uint64_t sync_insns : 2;          // 6 + 2 = 8
  uint64_t valid_insn_number : 2;   // 8 + 2 = 10
  uint64_t sync_word_0 : 32;        // 10 + 32 = 42
  uint64_t load_highaddr_low : 22;  // 42 + 22 = 64
  uint64_t load_highaddr_high : 2;  // 64 + 2 = 66
  uint64_t store_highaddr : 24;     // 66 + 24 = 90
  uint64_t reserved : 37;           // 90 + 37 = 127
} synchronize_cross_bits;

union synchronize_cvt {
  synchronize_indie_bits indie;
  synchronize_cross_bits cross;
  insn_bits              insn;
};

struct synchronize_indie: public instruction {

  private:
  synchronize_indie_bits storage_t;

  public:
  synchronize_indie(uint64_t low, uint64_t high): instruction(low, high) {}

  synchronize_indie(instruction insn)
  {
    union synchronize_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.indie;
    this->set_insn();
  }

  synchronize_indie(uint64_t valid_insn_number,
                    uint64_t sync_word_0,
                    uint64_t sync_word_1,
                    uint64_t sync_word_2,
                    uint64_t load_highaddr_config,
                    uint64_t store_highaddr_config)
  {
    this->storage_t.insn_opcode           = 0;
    this->storage_t.sync_insns            = 0;
    this->storage_t.valid_insn_number     = valid_insn_number;
    this->storage_t.sync_word_0           = sync_word_0;
    this->storage_t.sync_word_1_low       = (sync_word_1 & 0x3fffff);
    this->storage_t.sync_word_1_high      = (sync_word_1 >> 22);
    this->storage_t.sync_word_2           = sync_word_2;
    this->storage_t.load_highaddr_config  = load_highaddr_config;
    this->storage_t.store_highaddr_config = store_highaddr_config;
    this->storage_t.reserved              = 0;
    this->set_insn();
  }

  void set_valid_insn_number(uint64_t valid_insn_number)
  {
    this->storage_t.valid_insn_number = valid_insn_number;
    this->set_insn();
  }

  void set_sync_word_0(uint64_t sync_word_0)
  {
    this->storage_t.sync_word_0 = sync_word_0;
    this->set_insn();
  }

  void set_sync_word_1(uint64_t sync_word_1)
  {
    this->storage_t.sync_word_1_low  = (sync_word_1 & 0x3fffff);
    this->storage_t.sync_word_1_high = (sync_word_1 >> 22);
    this->set_insn();
  }

  void set_sync_word_2(uint64_t sync_word_2)
  {
    this->storage_t.sync_word_2 = sync_word_2;
    this->set_insn();
  }

  void set_load_highaddr_config(uint64_t load_highaddr_config)
  {
    this->storage_t.load_highaddr_config = load_highaddr_config;
    this->set_insn();
  }

  void set_store_highaddr_config(uint64_t store_highaddr_config)
  {
    this->storage_t.store_highaddr_config = store_highaddr_config;
    this->set_insn();
  }

  void set_insn()
  {
    union synchronize_cvt cvt;
    cvt.indie     = this->storage_t;
    this->storage = cvt.insn;
  }

  int64_t get_insn_opcode()
  {
    return this->storage_t.insn_opcode;
  }

  int64_t get_sync_insns()
  {
    return this->storage_t.sync_insns;
  }

  int64_t get_valid_insn_number()
  {
    return this->storage_t.valid_insn_number;
  }

  int64_t get_sync_word_0()
  {
    return this->storage_t.sync_word_0;
  }

  int64_t get_sync_word_1()
  {
    return (this->storage_t.sync_word_1_low | (this->storage_t.sync_word_1_high << 22));
  }

  int64_t get_sync_word_2()
  {
    return this->storage_t.sync_word_2;
  }

  int64_t get_load_highaddr_config()
  {
    return this->storage_t.load_highaddr_config;
  }

  int64_t get_store_highaddr_config()
  {
    return this->storage_t.store_highaddr_config;
  }
};

struct synchronize_cross: public instruction {

  private:
  synchronize_cross_bits storage_t;

  public:
  synchronize_cross(uint64_t low, uint64_t high): instruction(low, high) {}

  synchronize_cross(instruction insn)
  {
    union synchronize_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.cross;
    this->set_insn();
  }

  synchronize_cross(uint64_t valid_insn_number, uint64_t sync_word_0, uint64_t load_highaddr, uint64_t store_highaddr)
  {
    this->storage_t.insn_opcode        = 0;
    this->storage_t.sync_insns         = 1;
    this->storage_t.valid_insn_number  = valid_insn_number;
    this->storage_t.sync_word_0        = sync_word_0;
    this->storage_t.load_highaddr_low  = (load_highaddr & 0x3fffff);
    this->storage_t.load_highaddr_high = (load_highaddr >> 22);
    this->storage_t.store_highaddr     = store_highaddr;
    this->storage_t.reserved           = 0;
    this->set_insn();
  }

  void set_valid_insn_number(uint64_t valid_insn_number)
  {
    this->storage_t.valid_insn_number = valid_insn_number;
    this->set_insn();
  }

  void set_sync_word_0(uint64_t sync_word_0)
  {
    this->storage_t.sync_word_0 = sync_word_0;
    this->set_insn();
  }

  void set_load_highaddr(uint64_t load_highaddr)
  {
    this->storage_t.load_highaddr_low  = (load_highaddr & 0x3fffff);
    this->storage_t.load_highaddr_high = (load_highaddr >> 22);
    this->set_insn();
  }

  void set_store_highaddr(uint64_t store_highaddr)
  {
    this->storage_t.store_highaddr = store_highaddr;
    this->set_insn();
  }

  void set_insn()
  {
    union synchronize_cvt cvt;
    cvt.cross     = this->storage_t;
    this->storage = cvt.insn;
  }

  int64_t get_insn_opcode()
  {
    return this->storage_t.insn_opcode;
  }

  int64_t get_sync_insns()
  {
    return this->storage_t.sync_insns;
  }

  int64_t get_valid_insn_number()
  {
    return this->storage_t.valid_insn_number;
  }

  int64_t get_sync_word_0()
  {
    return this->storage_t.sync_word_0;
  }

  int64_t get_load_highaddr()
  {
    return (this->storage_t.load_highaddr_low | (this->storage_t.load_highaddr_high << 22));
  }

  int64_t get_store_highaddr()
  {
    return this->storage_t.store_highaddr;
  }
};

}  // namespace insn
}  // namespace common