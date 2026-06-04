#pragma once

#include "instruction/instruction.h"

namespace common {
namespace insn {

typedef struct {
  uint64_t insn_opcode : 6;            // 0 + 6 = 6
  uint64_t insn_number : 4;            // 6 + 4 = 10
  uint64_t load_insns : 2;             // 10 + 2 = 12
  uint64_t ddr_addr : 38;              // 12 + 38 = 50
  uint64_t sequ_burst_0 : 9;           // 50 + 9 = 59
  uint64_t hop_offset_1_exp : 3;       // 59 + 3 = 62
  uint64_t hop_offset_1_fra_low : 2;   // 62 + 2 = 64
  uint64_t hop_offset_1_fra_high : 6;  // 64 + 6 = 70
  uint64_t sequ_burst_1 : 5;           // 70 + 5 = 75
  uint64_t hop_offset_2_exp : 4;       // 75 + 4 = 79
  uint64_t hop_offset_2_fra : 8;       // 79 + 8 = 87
  uint64_t sequ_burst_2 : 4;           // 87 + 4 = 91
  uint64_t hop_offset_3_exp : 5;       // 91 + 5 = 96
  uint64_t hop_offset_3_fra : 8;       // 96 + 8 = 104
  uint64_t sequ_burst_3 : 3;           // 104 + 3 = 107
  uint64_t sram_addr : 20;             // 107 + 20 = 127
  uint64_t all_done : 1;               // 127 + 1 = 128
} load_4_bits;

typedef struct {
  uint64_t insn_opcode : 6;            // 0 + 6 = 6
  uint64_t insn_number : 4;            // 6 + 4 = 10
  uint64_t load_insns : 2;             // 10 + 2 = 12
  uint64_t ddr_addr : 38;              // 12 + 38 = 50
  uint64_t sequ_burst_0 : 11;          // 50 + 11 = 61
  uint64_t hop_offset_1_exp_low : 3;   // 61 + 3 = 64
  uint64_t hop_offset_1_exp_high : 2;  // 64 + 2 = 66
  uint64_t hop_offset_1_fra : 8;       // 66 + 8 = 74
  uint64_t sequ_burst_1 : 10;          // 74 + 10 = 84
  uint64_t hop_offset_2_exp : 5;       // 84 + 5 = 89
  uint64_t hop_offset_2_fra : 8;       // 89 + 8 = 97
  uint64_t sequ_burst_2 : 10;          // 97 + 10 = 107
  uint64_t sram_addr : 20;             // 107 + 20 = 127
  uint64_t all_done : 1;               // 127 + 1 = 128
} load_3_bits;

typedef struct {
  uint64_t insn_opcode : 6;        // 0 + 6 = 6
  uint64_t insn_number : 4;        // 6 + 4 = 10
  uint64_t load_insns : 2;         // 10 + 2 = 12
  uint64_t ddr_addr : 38;          // 12 + 38 = 50
  uint64_t sequ_burst_0_low : 14;  // 50 + 14 = 64
  uint64_t sequ_burst_0_high : 8;  // 64 + 8 = 72
  uint64_t hop_offset_1_exp : 5;   // 72 + 5 = 77
  uint64_t hop_offset_1_fra : 8;   // 77 + 8 = 85
  uint64_t sequ_burst_1 : 22;      // 85 + 22 = 107
  uint64_t sram_addr : 20;         // 107 + 20 = 127
  uint64_t all_done : 1;           // 127 + 1 = 128
} load_2_bits;

union load_cvt {
  load_4_bits load_4;
  load_3_bits load_3;
  load_2_bits load_2;
  insn_bits   insn;
};

template<int dma_id = 0>
struct load_iteration_4: public instruction {

  private:
  load_4_bits storage_t;

  public:
  load_iteration_4(): instruction() {}

  load_iteration_4(uint64_t low, uint64_t high): instruction(low, high) {}

  load_iteration_4(instruction& insn)
  {
    union load_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.load_4;
    this->set_insn();
  }

  load_iteration_4(uint64_t ddr_addr,
                   uint64_t sequ_burst_0,
                   uint64_t hop_offset_1_exp,
                   uint64_t hop_offset_1_fra,
                   uint64_t sequ_burst_1,
                   uint64_t hop_offset_2_exp,
                   uint64_t hop_offset_2_fra,
                   uint64_t sequ_burst_2,
                   uint64_t hop_offset_3_exp,
                   uint64_t hop_offset_3_fra,
                   uint64_t sequ_burst_3,
                   uint64_t sram_addr,
                   uint64_t all_done)
  {
    this->storage_t.insn_number           = 0;
    this->storage_t.insn_opcode           = dma_id + 1;
    this->storage_t.load_insns            = 0;
    this->storage_t.ddr_addr              = ddr_addr;
    this->storage_t.sequ_burst_0          = sequ_burst_0;
    this->storage_t.hop_offset_1_exp      = hop_offset_1_exp;
    this->storage_t.hop_offset_1_fra_low  = (hop_offset_1_fra & 0x3);
    this->storage_t.hop_offset_1_fra_high = (hop_offset_1_fra >> 2);
    this->storage_t.sequ_burst_1          = sequ_burst_1;
    this->storage_t.hop_offset_2_exp      = hop_offset_2_exp;
    this->storage_t.hop_offset_2_fra      = hop_offset_2_fra;
    this->storage_t.sequ_burst_2          = sequ_burst_2;
    this->storage_t.hop_offset_3_exp      = hop_offset_3_exp;
    this->storage_t.hop_offset_3_fra      = hop_offset_3_fra;
    this->storage_t.sequ_burst_3          = sequ_burst_3;
    this->storage_t.sram_addr             = sram_addr;
    this->storage_t.all_done              = all_done;
    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_insn_number(uint64_t insn_number)
  {
    this->storage_t.insn_number = insn_number;
    this->set_insn();
  }

  void set_ddr_addr(uint64_t ddr_addr)
  {
    this->storage_t.ddr_addr = ddr_addr;
    this->set_insn();
  }

  void set_all_done(uint64_t all_done)
  {
    this->storage_t.all_done = all_done;
    this->set_insn();
  }

  void set_sequ_burst_0(uint64_t sequ_burst_0)
  {
    this->storage_t.sequ_burst_0 = sequ_burst_0;
    this->set_insn();
  }

  void set_sequ_burst_1(uint64_t sequ_burst_1)
  {
    this->storage_t.sequ_burst_1 = sequ_burst_1;
    this->set_insn();
  }

  void set_sequ_burst_2(uint64_t sequ_burst_2)
  {
    this->storage_t.sequ_burst_2 = sequ_burst_2;
    this->set_insn();
  }

  void set_sequ_burst_3(uint64_t sequ_burst_3)
  {
    this->storage_t.sequ_burst_3 = sequ_burst_3;
    this->set_insn();
  }

  void set_hop_offset_1_exp(uint64_t hop_offset_1_exp)
  {
    this->storage_t.hop_offset_1_exp = hop_offset_1_exp;
    this->set_insn();
  }

  void set_hop_offset_1_fra(uint64_t hop_offset_1_fra)
  {
    this->storage_t.hop_offset_1_fra_low  = (hop_offset_1_fra & 0x3);
    this->storage_t.hop_offset_1_fra_high = (hop_offset_1_fra >> 2);
    this->set_insn();
  }

  void set_hop_offset_2_exp(uint64_t hop_offset_2_exp)
  {
    this->storage_t.hop_offset_2_exp = hop_offset_2_exp;
    this->set_insn();
  }

  void set_hop_offset_2_fra(uint64_t hop_offset_2_fra)
  {
    this->storage_t.hop_offset_2_fra = hop_offset_2_fra;
    this->set_insn();
  }

  void set_hop_offset_3_exp(uint64_t hop_offset_3_exp)
  {
    this->storage_t.hop_offset_3_exp = hop_offset_3_exp;
    this->set_insn();
  }

  void set_hop_offset_3_fra(uint64_t hop_offset_3_fra)
  {
    this->storage_t.hop_offset_3_fra = hop_offset_3_fra;
    this->set_insn();
  }

  void set_sram_addr(uint64_t sram_addr)
  {
    this->storage_t.sram_addr = sram_addr;
    this->set_insn();
  }

  void set_insn()
  {
    union load_cvt cvt;
    cvt.load_4    = this->storage_t;
    this->storage = cvt.insn;
  }

  int64_t get_insn_opcode()
  {
    return this->storage_t.insn_opcode;
  }

  int64_t get_insn_number()
  {
    return this->storage_t.insn_number;
  }

  int64_t get_load_insns()
  {
    return this->storage_t.load_insns;
  }

  int64_t get_ddr_addr()
  {
    return this->storage_t.ddr_addr;
  }

  int64_t get_sequ_burst_0()
  {
    return this->storage_t.sequ_burst_0;
  }

  int64_t get_hop_offset_1_exp()
  {
    return this->storage_t.hop_offset_1_exp;
  }

  int64_t get_hop_offset_1_fra()
  {
    return (this->storage_t.hop_offset_1_fra_low | (this->storage_t.hop_offset_1_fra_high << 6));
  }

  int64_t get_sequ_burst_1()
  {
    return this->storage_t.sequ_burst_1;
  }

  int64_t get_hop_offset_2_exp()
  {
    return this->storage_t.hop_offset_2_exp;
  }

  int64_t get_hop_offset_2_fra()
  {
    return this->storage_t.hop_offset_2_fra;
  }

  int64_t get_sequ_burst_2()
  {
    return this->storage_t.sequ_burst_2;
  }

  int64_t get_hop_offset_3_exp()
  {
    return this->storage_t.hop_offset_3_exp;
  }

  int64_t get_hop_offset_3_fra()
  {
    return this->storage_t.hop_offset_3_fra;
  }

  int64_t get_sequ_burst_3()
  {
    return this->storage_t.sequ_burst_3;
  }

  int64_t get_sram_addr()
  {
    return this->storage_t.sram_addr;
  }

  int64_t get_all_done()
  {
    return this->storage_t.all_done;
  }
};

template<int dma_id = 0>
struct load_iteration_3: public instruction {

  private:
  load_3_bits storage_t;

  public:
  load_iteration_3(): instruction() {}

  load_iteration_3(uint64_t low, uint64_t high): instruction(low, high) {}

  load_iteration_3(instruction& insn)
  {
    union load_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.load_3;
    this->set_insn();
  }

  load_iteration_3(uint64_t ddr_addr,
                   uint64_t sequ_burst_0,
                   uint64_t hop_offset_1_exp,
                   uint64_t hop_offset_1_fra,
                   uint64_t sequ_burst_1,
                   uint64_t hop_offset_2_exp,
                   uint64_t hop_offset_2_fra,
                   uint64_t sequ_burst_2,
                   uint64_t sram_addr,
                   uint64_t all_done)
  {
    this->storage_t.insn_number           = 0;
    this->storage_t.insn_opcode           = 1 + dma_id;
    this->storage_t.load_insns            = 1;
    this->storage_t.ddr_addr              = ddr_addr;
    this->storage_t.sequ_burst_0          = sequ_burst_0;
    this->storage_t.hop_offset_1_exp_low  = (hop_offset_1_exp & 0x7);
    this->storage_t.hop_offset_1_exp_high = (hop_offset_1_exp >> 3);
    this->storage_t.hop_offset_1_fra      = hop_offset_1_fra;
    this->storage_t.sequ_burst_1          = sequ_burst_1;
    this->storage_t.hop_offset_2_exp      = hop_offset_2_exp;
    this->storage_t.hop_offset_2_fra      = hop_offset_2_fra;
    this->storage_t.sequ_burst_2          = sequ_burst_2;
    this->storage_t.sram_addr             = sram_addr;
    this->storage_t.all_done              = all_done;
    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_insn_number(uint64_t insn_number)
  {
    this->storage_t.insn_number = insn_number;
    this->set_insn();
  }

  void set_ddr_addr(uint64_t ddr_addr)
  {
    this->storage_t.ddr_addr = ddr_addr;
    this->set_insn();
  }

  void set_all_done(uint64_t all_done)
  {
    this->storage_t.all_done = all_done;
    this->set_insn();
  }

  void set_sequ_burst_0(uint64_t sequ_burst_0)
  {
    this->storage_t.sequ_burst_0 = sequ_burst_0;
    this->set_insn();
  }

  void set_sequ_burst_1(uint64_t sequ_burst_1)
  {
    this->storage_t.sequ_burst_1 = sequ_burst_1;
    this->set_insn();
  }

  void set_sequ_burst_2(uint64_t sequ_burst_2)
  {
    this->storage_t.sequ_burst_2 = sequ_burst_2;
    this->set_insn();
  }

  void set_hop_offset_1_exp(uint64_t hop_offset_1_exp)
  {
    this->storage_t.hop_offset_1_exp_low  = (hop_offset_1_exp & 0x7);
    this->storage_t.hop_offset_1_exp_high = (hop_offset_1_exp >> 3);
    this->set_insn();
  }

  void set_hop_offset_1_fra(uint64_t hop_offset_1_fra)
  {
    this->storage_t.hop_offset_1_fra = hop_offset_1_fra;
    this->set_insn();
  }

  void set_hop_offset_2_exp(uint64_t hop_offset_2_exp)
  {
    this->storage_t.hop_offset_2_exp = hop_offset_2_exp;
    this->set_insn();
  }

  void set_hop_offset_2_fra(uint64_t hop_offset_2_fra)
  {
    this->storage_t.hop_offset_2_fra = hop_offset_2_fra;
    this->set_insn();
  }

  void set_sram_addr(uint64_t sram_addr)
  {
    this->storage_t.sram_addr = sram_addr;
    this->set_insn();
  }

  void set_insn()
  {
    union load_cvt cvt;
    cvt.load_3    = this->storage_t;
    this->storage = cvt.insn;
  }

  int64_t get_insn_opcode()
  {
    return this->storage_t.insn_opcode;
  }

  int64_t get_insn_number()
  {
    return this->storage_t.insn_number;
  }

  int64_t get_load_insns()
  {
    return this->storage_t.load_insns;
  }

  int64_t get_ddr_addr()
  {
    return this->storage_t.ddr_addr;
  }

  int64_t get_sequ_burst_0()
  {
    return this->storage_t.sequ_burst_0;
  }

  int64_t get_hop_offset_1_exp()
  {
    return (this->storage_t.hop_offset_1_exp_low | (this->storage_t.hop_offset_1_exp_high << 3));
  }

  int64_t get_hop_offset_1_fra()
  {
    return this->storage_t.hop_offset_1_fra;
  }

  int64_t get_sequ_burst_1()
  {
    return this->storage_t.sequ_burst_1;
  }

  int64_t get_hop_offset_2_exp()
  {
    return this->storage_t.hop_offset_2_exp;
  }

  int64_t get_hop_offset_2_fra()
  {
    return this->storage_t.hop_offset_2_fra;
  }

  int64_t get_sequ_burst_2()
  {
    return this->storage_t.sequ_burst_2;
  }

  int64_t get_sram_addr()
  {
    return this->storage_t.sram_addr;
  }

  int64_t get_all_done()
  {
    return this->storage_t.all_done;
  }
};

template<int dma_id = 0>
struct load_iteration_2: public instruction {

  private:
  load_2_bits storage_t;

  public:
  load_iteration_2(): instruction() {}

  load_iteration_2(uint64_t low, uint64_t high): instruction(low, high) {}

  load_iteration_2(instruction& insn)
  {
    union load_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.load_2;
    this->set_insn();
  }

  load_iteration_2(uint64_t ddr_addr,
                   uint64_t sequ_burst_0,
                   uint64_t hop_offset_1_exp,
                   uint64_t hop_offset_1_fra,
                   uint64_t sequ_burst_1,
                   uint64_t sram_addr,
                   uint64_t all_done)
  {
    this->storage_t.insn_number       = 0;
    this->storage_t.insn_opcode       = 1 + dma_id;
    this->storage_t.load_insns        = 2;
    this->storage_t.ddr_addr          = ddr_addr;
    this->storage_t.sequ_burst_0_low  = (sequ_burst_0 & 0x3FFF);
    this->storage_t.sequ_burst_0_high = (sequ_burst_0 >> 14);
    this->storage_t.hop_offset_1_exp  = hop_offset_1_exp;
    this->storage_t.hop_offset_1_fra  = hop_offset_1_fra;
    this->storage_t.sequ_burst_1      = sequ_burst_1;
    this->storage_t.sram_addr         = sram_addr;
    this->storage_t.all_done          = all_done;
    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_insn_number(uint64_t insn_number)
  {
    this->storage_t.insn_number = insn_number;
    this->set_insn();
  }

  void set_ddr_addr(uint64_t ddr_addr)
  {
    this->storage_t.ddr_addr = ddr_addr;
    this->set_insn();
  }

  void set_all_done(uint64_t all_done)
  {
    this->storage_t.all_done = all_done;
    this->set_insn();
  }

  void set_sequ_burst_0(uint64_t sequ_burst_0)
  {
    this->storage_t.sequ_burst_0_low  = (sequ_burst_0 & 0x3FFF);
    this->storage_t.sequ_burst_0_high = (sequ_burst_0 >> 14);
    this->set_insn();
  }

  void set_sequ_burst_1(uint64_t sequ_burst_1)
  {
    this->storage_t.sequ_burst_1 = sequ_burst_1;
    this->set_insn();
  }

  void set_hop_offset_1_exp(uint64_t hop_offset_1_exp)
  {
    this->storage_t.hop_offset_1_exp = hop_offset_1_exp;
    this->set_insn();
  }

  void set_hop_offset_1_fra(uint64_t hop_offset_1_fra)
  {
    this->storage_t.hop_offset_1_fra = hop_offset_1_fra;
    this->set_insn();
  }

  void set_sram_addr(uint64_t sram_addr)
  {
    this->storage_t.sram_addr = sram_addr;
    this->set_insn();
  }

  void set_insn()
  {
    union load_cvt cvt;
    cvt.load_2    = this->storage_t;
    this->storage = cvt.insn;
  }

  int64_t get_insn_opcode()
  {
    return this->storage_t.insn_opcode;
  }

  int64_t get_insn_number()
  {
    return this->storage_t.insn_number;
  }

  int64_t get_load_insns()
  {
    return this->storage_t.load_insns;
  }

  int64_t get_ddr_addr()
  {
    return this->storage_t.ddr_addr;
  }

  int64_t get_sequ_burst_0()
  {
    return (this->storage_t.sequ_burst_0_low | (this->storage_t.sequ_burst_0_high << 14));
  }

  int64_t get_hop_offset_1_exp()
  {
    return this->storage_t.hop_offset_1_exp;
  }

  int64_t get_hop_offset_1_fra()
  {
    return this->storage_t.hop_offset_1_fra;
  }

  int64_t get_sequ_burst_1()
  {
    return this->storage_t.sequ_burst_1;
  }

  int64_t get_sram_addr()
  {
    return this->storage_t.sram_addr;
  }

  int64_t get_all_done()
  {
    return this->storage_t.all_done;
  }
};

}  // namespace insn
}  // namespace common