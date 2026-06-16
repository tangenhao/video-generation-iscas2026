#pragma once

#include "instruction/instruction.h"

namespace common {
namespace insn {

typedef struct {
  uint64_t insn_opcode : 6;     // 0 + 6 = 6
  uint64_t insn_number : 4;     // 6 + 4 = 10
  uint64_t insn_kind : 3;       // 10 + 3 = 13
  uint64_t real_k_groups : 8;   // 13 + 8 = 21
  uint64_t real_n_groups : 8;   // 21 + 8 = 29
  uint64_t gemm_type : 2;       // 29 + 2 = 31
  uint64_t reserved_low : 33;   // 31 + 33 = 64
  uint64_t reserved_high : 64;  // 64 + 64 = 128
} pea_config_bits;

typedef struct {
  uint64_t insn_opcode : 6;       // 0 + 6 = 6
  uint64_t insn_number : 4;       // 6 + 4 = 10
  uint64_t insn_kind : 3;         // 10 + 3 = 13
  uint64_t type_a : 3;            // 13 + 3 = 16
  uint64_t type_b : 3;            // 16 + 3 = 19
  uint64_t type_accumulator : 1;  // 19 + 1 = 20
  uint64_t type_output : 2;       // 20 + 2 = 22
  uint64_t ifmap_width : 12;      // 22 + 12 = 34
  uint64_t ifmap_height : 12;     // 34 + 12 = 46
  uint64_t weight_width : 8;      // 46 + 8 = 54
  uint64_t weight_height : 8;     // 54 + 8 = 62
  uint64_t psum_width_low : 2;    // 62 + 2 = 64
  uint64_t psum_width_high : 10;  // 64 + 10 = 74
  uint64_t psum_height : 12;      // 74 + 12 = 86
  uint64_t ic_group : 8;          // 86 + 8 = 94
  uint64_t oc_group : 8;          //  94 + 8 = 102
  uint64_t ifmap_highaddr : 1;    // 102 + 1 = 103
  uint64_t weight_highaddr : 1;   // 103 + 1 = 104
  uint64_t psum_highaddr : 2;     // 104 + 2 = 106
  uint64_t pad_left : 7;          // 106 + 7 = 113
  uint64_t pad_top : 7;           // 113 + 7 = 120
  uint64_t psum_number : 7;       // 120 + 7 = 127
  uint64_t psum_accumulated : 1;  // 127 + 1 = 128
} convolution_execute_bits;

typedef struct {
  uint64_t insn_opcode : 6;       // 0 + 6 = 6
  uint64_t insn_number : 4;       // 6 + 4 = 10
  uint64_t insn_kind : 3;         // 10 + 3 = 13
  uint64_t type_a : 3;            // 13 + 3 = 16
  uint64_t type_b : 3;            // 16 + 3 = 19
  uint64_t type_accumulator : 1;  // 19 + 1 = 20
  uint64_t type_output : 2;       // 20 + 2 = 22
  uint64_t tile_m : 12;           // 22 + 12 = 34
  uint64_t n_groups : 8;          // 34 + 8 = 42
  uint64_t k_groups : 8;          //  42 + 8 = 50
  uint64_t ifmap_highaddr : 1;    // 50 + 1 = 51
  uint64_t weight_highaddr : 1;   // 51 + 1 = 52
  uint64_t psum_write_flag : 1;   // 52 + 1 = 53
  uint64_t psum_read_flag : 1;    // 53 + 1 = 54
  uint64_t psum_number_low : 10;  // 54 + 10 = 64
  uint64_t psum_number_high : 2;  // 64 + 2 = 66
  uint64_t psum_accumulated : 1;  // 66 + 1 = 67
  uint64_t reserved : 61;         // 67 + 61 = 128
} gemm_execute_bits;

union pea_cvt {
  convolution_execute_bits convolution_execute;
  gemm_execute_bits        gemm_execute;
  pea_config_bits          config;
  insn_bits                insn;
};

struct convolution_execute: public instruction {

  private:
  convolution_execute_bits storage_t;

  public:
  convolution_execute() {}

  convolution_execute(uint64_t low, uint64_t high): instruction(low, high) {}

  convolution_execute(instruction& insn)
  {
    union pea_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.convolution_execute;
    this->set_insn();
  }

  convolution_execute(uint64_t type_a,
                      uint64_t type_b,
                      uint64_t type_accumulator,
                      uint64_t type_output,
                      uint64_t ifmap_width,
                      uint64_t ifmap_height,
                      uint64_t weight_width,
                      uint64_t weight_height,
                      uint64_t psum_width,
                      uint64_t psum_height,
                      uint64_t ic_group,
                      uint64_t oc_group,
                      uint64_t ifmap_highaddr,
                      uint64_t weight_highaddr,
                      uint64_t psum_highaddr,
                      uint64_t pad_left,
                      uint64_t pad_top,
                      uint64_t psum_number,
                      uint64_t psum_accumulated)
  {
    this->storage_t.insn_opcode      = 17;
    this->storage_t.insn_number      = 0;
    this->storage_t.insn_kind        = 1;
    this->storage_t.type_a           = type_a;
    this->storage_t.type_b           = type_b;
    this->storage_t.type_accumulator = type_accumulator;
    this->storage_t.type_output      = type_output;
    this->storage_t.ifmap_height     = ifmap_height;
    this->storage_t.ifmap_width      = ifmap_width;
    this->storage_t.weight_width     = weight_width;
    this->storage_t.weight_height    = weight_height;
    this->storage_t.psum_width_low   = (psum_width & 0x3);
    this->storage_t.psum_width_high  = (psum_width >> 2);
    this->storage_t.psum_height      = psum_height;
    this->storage_t.ic_group         = ic_group;
    this->storage_t.oc_group         = oc_group;
    this->storage_t.ifmap_highaddr   = ifmap_highaddr;
    this->storage_t.weight_highaddr  = weight_highaddr;
    this->storage_t.psum_highaddr    = psum_highaddr;
    this->storage_t.pad_left         = pad_left;
    this->storage_t.pad_top          = pad_top;
    this->storage_t.psum_number      = psum_number;
    this->storage_t.psum_accumulated = psum_accumulated;
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

  void set_insn_kind(uint64_t insn_kind)
  {
    this->storage_t.insn_kind = insn_kind;
    this->set_insn();
  }

  void set_type_a(uint64_t type_a)
  {
    this->storage_t.type_a = type_a;
    this->set_insn();
  }

  void set_type_b(uint64_t type_b)
  {
    this->storage_t.type_b = type_b;
    this->set_insn();
  }

  void set_type_accumulator(uint64_t type_accumulator)
  {
    this->storage_t.type_accumulator = type_accumulator;
    this->set_insn();
  }

  void set_type_output(uint64_t type_output)
  {
    this->storage_t.type_output = type_output;
    this->set_insn();
  }

  void set_ifmap_width(uint64_t ifmap_width)
  {
    this->storage_t.ifmap_width = ifmap_width;
    this->set_insn();
  }

  void set_ifmap_height(uint64_t ifmap_height)
  {
    this->storage_t.ifmap_height = ifmap_height;
    this->set_insn();
  }

  void set_weight_width(uint64_t weight_width)
  {
    this->storage_t.weight_width = weight_width;
    this->set_insn();
  }

  void set_weight_height(uint64_t weight_height)
  {
    this->storage_t.weight_height = weight_height;
    this->set_insn();
  }

  void set_psum_width(uint64_t psum_width)
  {
    this->storage_t.psum_width_low  = (psum_width & 0x3);
    this->storage_t.psum_width_high = (psum_width >> 2);
    this->set_insn();
  }

  void set_psum_height(uint64_t psum_height)
  {
    this->storage_t.psum_height = psum_height;
    this->set_insn();
  }

  void set_ic_group(uint64_t ic_group)
  {
    this->storage_t.ic_group = ic_group;
    this->set_insn();
  }

  void set_oc_group(uint64_t oc_group)
  {
    this->storage_t.oc_group = oc_group;
    this->set_insn();
  }

  void set_ifmap_highaddr(uint64_t ifmap_highaddr)
  {
    this->storage_t.ifmap_highaddr = ifmap_highaddr;
    this->set_insn();
  }

  void set_weight_highaddr(uint64_t weight_highaddr)
  {
    this->storage_t.weight_highaddr = weight_highaddr;
    this->set_insn();
  }

  void set_psum_highaddr(uint64_t psum_highaddr)
  {
    this->storage_t.psum_highaddr = psum_highaddr;
    this->set_insn();
  }

  void set_pad_left(uint64_t pad_left)
  {
    this->storage_t.pad_left = pad_left;
    this->set_insn();
  }

  void set_pad_top(uint64_t pad_top)
  {
    this->storage_t.pad_top = pad_top;
    this->set_insn();
  }

  void set_psum_number(uint64_t psum_number)
  {
    this->storage_t.psum_number = psum_number;
    this->set_insn();
  }

  void set_psum_accumulated(uint64_t psum_accumulated)
  {
    this->storage_t.psum_accumulated = psum_accumulated;
    this->set_insn();
  }

  void set_insn()
  {
    union pea_cvt cvt;
    cvt.convolution_execute = this->storage_t;
    this->storage           = cvt.insn;
  }

  int64_t get_insn_opcode()
  {
    return this->storage_t.insn_opcode;
  }

  int64_t get_insn_number()
  {
    return this->storage_t.insn_number;
  }

  int64_t get_insn_kind()
  {
    return this->storage_t.insn_kind;
  }

  int64_t get_type_a()
  {
    return this->storage_t.type_a;
  }

  int64_t get_type_b()
  {
    return this->storage_t.type_b;
  }

  int64_t get_type_accumulator()
  {
    return this->storage_t.type_accumulator;
  }

  int64_t get_type_output()
  {
    return this->storage_t.type_output;
  }

  int64_t get_ifmap_width()
  {
    return this->storage_t.ifmap_width;
  }

  int64_t get_ifmap_height()
  {
    return this->storage_t.ifmap_height;
  }

  int64_t get_weight_width()
  {
    return this->storage_t.weight_width;
  }

  int64_t get_weight_height()
  {
    return this->storage_t.weight_height;
  }

  int64_t get_psum_width()
  {
    return (this->storage_t.psum_width_low | (this->storage_t.psum_width_high << 2));
  }

  int64_t get_psum_height()
  {
    return this->storage_t.psum_height;
  }

  int64_t get_ic_group()
  {
    return this->storage_t.ic_group;
  }

  int64_t get_oc_group()
  {
    return this->storage_t.oc_group;
  }

  int64_t get_ifmap_highaddr()
  {
    return this->storage_t.ifmap_highaddr;
  }

  int64_t get_weight_highaddr()
  {
    return this->storage_t.weight_highaddr;
  }

  int64_t get_psum_highaddr()
  {
    return this->storage_t.psum_highaddr;
  }

  int64_t get_pad_left()
  {
    return this->storage_t.pad_left;
  }

  int64_t get_pad_top()
  {
    return this->storage_t.pad_top;
  }

  int64_t get_psum_number()
  {
    return this->storage_t.psum_number;
  }

  int64_t get_psum_accumulated()
  {
    return this->storage_t.psum_accumulated;
  }
};

struct gemm_execute: public instruction {

  private:
  gemm_execute_bits storage_t;

  public:
  gemm_execute() {}

  gemm_execute(uint64_t low, uint64_t high): instruction(low, high) {}

  gemm_execute(instruction& insn)
  {
    union pea_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.gemm_execute;
    this->set_insn();
  }

  gemm_execute(uint64_t type_a,
               uint64_t type_b,
               uint64_t type_accumulator,
               uint64_t type_output,
               uint64_t tile_m,
               uint64_t n_groups,
               uint64_t k_groups,
               uint64_t ifmap_highaddr,
               uint64_t weight_highaddr,
               uint64_t psum_highaddr,
               uint64_t psum_number,
               uint64_t psum_accumulated)
    : gemm_execute(type_a,
                   type_b,
                   type_accumulator,
                   type_output,
                   tile_m,
                   n_groups,
                   k_groups,
                   ifmap_highaddr,
                   weight_highaddr,
                   (psum_highaddr >> 1) & 0x1,
                   psum_highaddr & 0x1,
                   psum_number,
                   psum_accumulated)
  {
  }

  gemm_execute(uint64_t type_a,
               uint64_t type_b,
               uint64_t type_accumulator,
               uint64_t type_output,
               uint64_t tile_m,
               uint64_t n_groups,
               uint64_t k_groups,
               uint64_t ifmap_highaddr,
               uint64_t weight_highaddr,
               uint64_t psum_read_flag,
               uint64_t psum_write_flag,
               uint64_t psum_number,
               uint64_t psum_accumulated)
  {
    this->storage_t.insn_opcode      = 17;
    this->storage_t.insn_number      = 0;
    this->storage_t.insn_kind        = 2;
    this->storage_t.type_a           = type_a;
    this->storage_t.type_b           = type_b;
    this->storage_t.type_accumulator = type_accumulator;
    this->storage_t.type_output      = type_output;
    this->storage_t.tile_m           = tile_m;
    this->storage_t.n_groups         = n_groups;
    this->storage_t.k_groups         = k_groups;
    this->storage_t.ifmap_highaddr   = ifmap_highaddr;
    this->storage_t.weight_highaddr  = weight_highaddr;
    this->storage_t.psum_read_flag   = psum_read_flag;
    this->storage_t.psum_write_flag  = psum_write_flag;
    this->storage_t.psum_number_low  = (psum_number & 0x3FF);
    this->storage_t.psum_number_high = (psum_number >> 10);
    this->storage_t.psum_accumulated = psum_accumulated;
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

  void set_insn_kind(uint64_t insn_kind)
  {
    this->storage_t.insn_kind = insn_kind;
    this->set_insn();
  }

  void set_type_a(uint64_t type_a)
  {
    this->storage_t.type_a = type_a;
    this->set_insn();
  }

  void set_type_b(uint64_t type_b)
  {
    this->storage_t.type_b = type_b;
    this->set_insn();
  }

  void set_type_accumulator(uint64_t type_accumulator)
  {
    this->storage_t.type_accumulator = type_accumulator;
    this->set_insn();
  }

  void set_type_output(uint64_t type_output)
  {
    this->storage_t.type_output = type_output;
    this->set_insn();
  }

  void set_tile_m(uint64_t tile_m)
  {
    this->storage_t.tile_m = tile_m;
    this->set_insn();
  }

  void set_n_groups(uint64_t n_groups)
  {
    this->storage_t.n_groups = n_groups;
    this->set_insn();
  }

  void set_k_groups(uint64_t k_groups)
  {
    this->storage_t.k_groups = k_groups;
    this->set_insn();
  }

  void set_ifmap_highaddr(uint64_t ifmap_highaddr)
  {
    this->storage_t.ifmap_highaddr = ifmap_highaddr;
    this->set_insn();
  }

  void set_weight_highaddr(uint64_t weight_highaddr)
  {
    this->storage_t.weight_highaddr = weight_highaddr;
    this->set_insn();
  }

  void set_psum_highaddr(uint64_t psum_highaddr)
  {
    this->storage_t.psum_read_flag  = (psum_highaddr >> 1) & 0x1;
    this->storage_t.psum_write_flag = psum_highaddr & 0x1;
    this->set_insn();
  }

  void set_psum_read_flag(uint64_t psum_read_flag)
  {
    this->storage_t.psum_read_flag = psum_read_flag;
    this->set_insn();
  }

  void set_psum_write_flag(uint64_t psum_write_flag)
  {
    this->storage_t.psum_write_flag = psum_write_flag;
    this->set_insn();
  }

  void set_psum_number(uint64_t psum_number)
  {
    this->storage_t.psum_number_low  = (psum_number & 0x3FF);
    this->storage_t.psum_number_high = (psum_number >> 10);
    this->set_insn();
  }

  void set_psum_accumulated(uint64_t psum_accumulated)
  {
    this->storage_t.psum_accumulated = psum_accumulated;
    this->set_insn();
  }

  void set_insn()
  {
    union pea_cvt cvt;
    cvt.gemm_execute = this->storage_t;
    this->storage    = cvt.insn;
  }

  int64_t get_insn_opcode()
  {
    return this->storage_t.insn_opcode;
  }

  int64_t get_type_a()
  {
    return this->storage_t.type_a;
  }

  int64_t get_type_b()
  {
    return this->storage_t.type_b;
  }

  int64_t get_type_accumulator()
  {
    return this->storage_t.type_accumulator;
  }

  int64_t get_type_output()
  {
    return this->storage_t.type_output;
  }

  int64_t get_tile_m()
  {
    return this->storage_t.tile_m;
  }

  int64_t get_n_groups()
  {
    return this->storage_t.n_groups;
  }

  int64_t get_k_groups()
  {
    return this->storage_t.k_groups;
  }

  int64_t get_ifmap_highaddr()
  {
    return this->storage_t.ifmap_highaddr;
  }

  int64_t get_weight_highaddr()
  {
    return this->storage_t.weight_highaddr;
  }

  int64_t get_psum_highaddr()
  {
    return (this->storage_t.psum_read_flag << 1) | this->storage_t.psum_write_flag;
  }

  int64_t get_psum_read_flag()
  {
    return this->storage_t.psum_read_flag;
  }

  int64_t get_psum_write_flag()
  {
    return this->storage_t.psum_write_flag;
  }

  int64_t get_psum_number()
  {
    return (this->storage_t.psum_number_low | (this->storage_t.psum_number_high << 10));
  }

  int64_t get_psum_accumulated()
  {
    return this->storage_t.psum_accumulated;
  }
};

struct pea_config: public instruction {

  private:
  pea_config_bits storage_t;

  public:
  pea_config() {}

  pea_config(uint64_t low, uint64_t high): instruction(low, high) {}

  pea_config(instruction& insn)
  {
    union pea_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.config;
    this->set_insn();
  }

  pea_config(uint64_t real_k_groups, uint64_t real_n_groups, uint64_t gemm_type)
  {
    this->storage_t.insn_opcode   = 17;
    this->storage_t.insn_number   = 0;
    this->storage_t.insn_kind     = 0;
    this->storage_t.real_k_groups = real_k_groups;
    this->storage_t.real_n_groups = real_n_groups;
    this->storage_t.gemm_type     = gemm_type;
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

  void set_insn_kind(uint64_t insn_kind)
  {
    this->storage_t.insn_kind = insn_kind;
    this->set_insn();
  }

  void set_real_k_groups(uint64_t real_k_groups)
  {
    this->storage_t.real_k_groups = real_k_groups;
    this->set_insn();
  }

  void set_real_n_groups(uint64_t real_n_groups)
  {
    this->storage_t.real_n_groups = real_n_groups;
    this->set_insn();
  }

  void set_gemm_type(uint64_t gemm_type)
  {
    this->storage_t.gemm_type = gemm_type;
    this->set_insn();
  }

  void set_insn()
  {
    union pea_cvt cvt;
    cvt.config    = this->storage_t;
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

  int64_t get_insn_kind()
  {
    return this->storage_t.insn_kind;
  }

  int64_t get_real_k_groups()
  {
    return this->storage_t.real_k_groups;
  }

  int64_t get_real_n_groups()
  {
    return this->storage_t.real_n_groups;
  }

  int64_t get_gemm_type()
  {
    return this->storage_t.gemm_type;
  }
};

}  // namespace insn
}  // namespace common
