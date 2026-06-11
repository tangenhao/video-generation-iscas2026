#pragma once

#include "instruction/instruction.h"

namespace common {
namespace insn {

#ifdef CONFIG_FOR_FPGA
  typedef struct {
    uint64_t insn_opcode : 6;          // 0 + 6 = 6
    uint64_t insn_number : 4;          // 6 + 4 = 10
    uint64_t insn_kind : 4;            // 10 + 4 = 14
    uint64_t psum_data_type : 3;       // 14 + 3 = 17
    uint64_t resadd_para_type : 3;     // 17 + 3 = 20
    uint64_t data_out_type : 3;        // 20 + 3 = 23
    uint64_t data_out_ram : 2;         // 23 + 2 = 25
    uint64_t opcode_number : 7;        // 25 + 7 = 32
    uint64_t opcode_addr : 7;          // 32 + 7 = 39
    uint64_t psum_in_addr : 9;         // 39 + 9 = 48
    uint64_t para_in_addr : 9;         // 48 + 9 = 57
    uint64_t resadd_in_addr_low : 7;   // 57 + 7 = 64
    uint64_t resadd_in_addr_high : 2;  // 64 + 2 = 66
    uint64_t ram_out_addr : 8;         // 66 + 8 = 74
    uint64_t num_data_cnt : 14;        // 74 + 14 = 88
    uint64_t oc_group_cnt : 8;         // 88 + 8 = 96
    uint64_t para_func_cnt : 2;        // 96 + 2 = 98
    uint64_t psum_sram_valid : 1;      // 98 + 1 = 99
    uint64_t resadd_sram_valid : 1;    // 99 + 1 = 100
    uint64_t para_sram_valid : 1;      // 100 + 1 = 101
    uint64_t psum_addr_hop : 1;        // 101 + 1 = 102
    uint64_t acc_clear : 1;            // 102 + 1 = 103
    uint64_t stream_en : 1;            // 103 + 1 = 104
    uint64_t ifmap_sram_valid : 1;     // 104 + 1 = 105
    uint64_t ifmap_in_addr : 9;        // 105 + 9 = 114
    uint64_t s2p_32_en : 1;            // 114 + 1 = 115
    uint64_t psum_1_sram_valid : 1;    // 115 + 1 = 116
    uint64_t psum_1_in_addr : 9;       // 116 + 9 = 125
    uint64_t reversed : 3;             // 125 + 3 = 128
  } vcu_execute_bits;
#else
  // for vcs simulation
  typedef struct {
    uint64_t insn_opcode : 6;          // 0 + 6 = 6
    uint64_t insn_number : 4;          // 6 + 4 = 10
    uint64_t insn_kind : 4;            // 10 + 4 = 14
    uint64_t psum_data_type : 3;       // 14 + 3 = 17
    uint64_t resadd_para_type : 3;     // 17 + 3 = 20
    uint64_t data_out_type : 3;        // 20 + 3 = 23
    uint64_t data_out_ram : 2;         // 23 + 2 = 25
    uint64_t opcode_number : 7;        // 25 + 7 = 32
    uint64_t opcode_addr : 7;          // 32 + 7 = 39
    uint64_t psum_in_addr : 9;         // 39 + 9 = 48
    uint64_t para_in_addr : 9;         // 48 + 9 = 57
    uint64_t resadd_in_addr_low : 7;   // 57 + 7 = 64
    uint64_t resadd_in_addr_high : 2;  // 64 + 2 = 66
    uint64_t ram_out_addr : 8;         // 66 + 8 = 74
    uint64_t num_data_cnt : 14;        // 74 + 14 = 88
    uint64_t oc_group_cnt : 8;         // 88 + 8 = 96
    uint64_t para_func_cnt : 2;        // 96 + 2 = 98
    uint64_t psum_sram_valid : 1;      // 98 + 1 = 99
    uint64_t resadd_sram_valid : 1;    // 99 + 1 = 100
    uint64_t para_sram_valid : 1;      // 100 + 1 = 101
    uint64_t psum_addr_hop : 1;        // 101 + 1 = 102
    uint64_t acc_clear : 1;            // 102 + 1 = 103
    uint64_t stream_en : 1;            // 103 + 1 = 104
    uint64_t ifmap_sram_valid : 1;     // 104 + 1 = 105
    uint64_t ifmap_in_addr : 9;        // 105 + 9 = 114
    uint64_t s2p_32_en : 1;            // 114 + 1 = 115
    uint64_t psum_1_sram_valid : 1;    // 115 + 1 = 116
    uint64_t psum_1_in_addr : 9;       // 116 + 9 = 125
    uint64_t reversed : 3;             // 125 + 3 = 128
  } vcu_execute_bits;
#endif

static_assert(sizeof(vcu_execute_bits) == sizeof(insn_bits), "vcu_execute_bits must remain 128 bits");

typedef struct {
  uint64_t insn_opcode : 6;                   // 0 + 6 = 6
  uint64_t insn_number : 4;                   // 6 + 4 = 10
  uint64_t insn_kind : 4;                     // 10 + 4 = 14
  uint64_t sin_cos_lut_base_highaddr : 2;     // 14 + 2 = 16
  uint64_t reciprocal_lut_base_highaddr : 2;  // 16 + 2 = 18
  uint64_t log_lut_base_highaddr : 2;         // 18 + 2 = 20
  uint64_t exp_lut_base_highaddr : 2;         // 20 + 2 = 22
  uint64_t rsqrt_lut_base_highaddr : 2;       // 22 + 2 = 24
  uint64_t tanh_lut_base_highaddr : 2;        // 24 + 2 = 26
  uint64_t sigmoid_lut_base_highaddr : 2;     // 26 + 2 = 28
  uint64_t swish_lut_base_highaddr : 2;       // 28 + 2 = 30
  uint64_t mish_lut_base_highaddr : 2;        // 30 + 2 = 32
  uint64_t gelu_lut_base_highaddr : 2;        // 32 + 2 = 34
  uint64_t reversed_0 : 30;                   // 34 + 30 = 64
  uint64_t reversed_1 : 64;                   // 64 + 64 = 128
} vcu_config_bits;

#ifdef CONFIG_FOR_FPGA
  typedef struct { 
    uint64_t insn_opcode : 6;             // 0 + 6 = 6
    uint64_t insn_number : 4;             // 6 + 4 = 10
    uint64_t insn_kind : 4;               // 10 + 4 = 14
    uint64_t data_in_bits_type : 1;       // 14 + 1 = 15
    uint64_t psum_read_base_addr : 15;    // 15 + 15 = 30
    uint64_t ofmap_write_base_addr : 16;  // 30 + 16 = 46
    uint64_t num_data : 14;               // 46 + 14 = 60
    //4 bits
    uint64_t in_oc_group : 8;             // 64 + 8 = 72
    uint64_t out_oc_group : 8;            // 72 + 8 = 80
    uint64_t reversed : 48;               // 80 + 48 = 128
  }vcu_parallelism_conversion_bits;
#else
  // for vcs simulation
  typedef struct {
    uint64_t insn_opcode : 6;             // 0 + 6 = 6
    uint64_t insn_number : 4;             // 6 + 4 = 10
    uint64_t insn_kind : 4;               // 10 + 4 = 14
    uint64_t data_in_bits_type : 1;       // 14 + 1 = 15
    uint64_t psum_read_base_addr : 14;    // 15 + 14 = 29
    uint64_t ofmap_write_base_addr : 13;  // 29 + 13 = 42
    uint64_t num_data : 14;               // 42 + 14 = 56
    uint64_t in_oc_group : 8;             // 56 + 8 = 64
    uint64_t out_oc_group : 8;            // 64 + 8 = 72
    uint64_t reversed : 56;               // 72 + 56 = 128
  } vcu_parallelism_conversion_bits;
#endif

typedef struct {
  uint64_t insn_opcode : 6;          // 0 + 6 = 6
  uint64_t insn_number : 4;          // 6 + 4 = 10
  uint64_t insn_kind : 4;            // 10 + 4 = 14
  uint64_t data_in_type : 2;         // 14 + 2 = 16
  uint64_t data_out_type : 2;        // 16 + 2 = 18
  uint64_t psum_width : 11;          // 18 + 11 = 29
  uint64_t psum_height : 11;         // 29 + 11 = 40
  uint64_t oc_group : 8;             // 40 + 8 = 48
  uint64_t psum_read_highaddr : 6;   // 48 + 6 = 54
  uint64_t psum_write_highaddr : 6;  // 54 + 6 = 60
  uint64_t kernel_width_low : 4;     // 60 + 4 = 64
  uint64_t kernel_width_high : 4;    // 64 + 4 = 68
  uint64_t kernel_height : 8;        // 68 + 8 = 76
  uint64_t pool_width : 11;          // 76 + 11 = 87
  uint64_t pool_height : 11;         // 87 + 11 = 98
  uint64_t stride_width : 5;         // 98 + 5 = 103
  uint64_t stride_height : 5;        // 103 + 5 = 108
  uint64_t dilation_width : 5;       // 108 + 5 = 113
  uint64_t dilation_height : 5;      // 113 + 5 = 118
  uint64_t pad_left : 5;             // 118 + 5 = 123
  uint64_t pad_top : 5;              // 123 + 5 = 128
} vcu_maxpool_bits;

typedef struct {
  uint64_t insn_opcode : 6;          // 0 + 6 = 6
  uint64_t insn_number : 4;          // 6 + 4 = 10
  uint64_t insn_kind : 4;            // 10 + 4 = 14
  uint64_t data_in_type : 2;         // 14 + 2 = 16
  uint64_t data_out_type : 2;        // 16 + 2 = 18
  uint64_t psum_width : 11;          // 18 + 11 = 29
  uint64_t psum_height : 11;         // 29 + 11 = 40
  uint64_t oc_group : 8;             // 40 + 8 = 48
  uint64_t psum_read_highaddr : 6;   // 48 + 6 = 54
  uint64_t psum_write_highaddr : 6;  // 54 + 6 = 60
  uint64_t kernel_width_low : 4;     // 60 + 4 = 64
  uint64_t kernel_width_high : 4;    // 64 + 4 = 68
  uint64_t kernel_height : 8;        // 68 + 8 = 76
  uint64_t pool_width : 11;          // 76 + 11 = 87
  uint64_t pool_height : 11;         // 87 + 11 = 98
  uint64_t stride_width : 5;         // 98 + 5 = 103
  uint64_t stride_height : 5;        // 103 + 5 = 108
  uint64_t dilation_width : 5;       // 108 + 5 = 113
  uint64_t dilation_height : 5;      // 113 + 5 = 118
  uint64_t pad_left : 5;             // 118 + 5 = 123
  uint64_t pad_top : 5;              // 123 + 5 = 128
} vcu_avgpool_bits;

typedef struct {
  uint64_t insn_opcode : 6;          // 0 + 6 = 6
  uint64_t insn_number : 4;          // 6 + 4 = 10
  uint64_t insn_kind : 4;            // 10 + 4 = 14
  uint64_t data_in_type : 2;         // 14 + 2 = 16
  uint64_t data_out_type : 2;        // 16 + 2 = 18
  uint64_t psum_width : 11;          // 18 + 11 = 29
  uint64_t psum_height : 11;         // 29 + 11 = 40
  uint64_t oc_group : 8;             // 40 + 8 = 48
  uint64_t psum_read_highaddr : 6;   // 48 + 6 = 54
  uint64_t psum_write_highaddr : 6;  // 54 + 6 = 60
  uint64_t scale_width_low : 4;      // 60 + 4 = 64
  uint64_t scale_width_high : 1;     // 64 + 1 = 65
  uint64_t scale_height : 5;         // 65 + 5 = 70
  uint64_t upsample_width : 11;      // 70 + 11 = 81
  uint64_t upsample_height : 11;     // 81 + 11 = 92
  uint64_t reversed : 36;            // 92 + 36 = 128
} vcu_upsample_bits;

#ifdef CONFIG_FOR_FPGA
  typedef struct {
    uint64_t insn_opcode : 6;            // 0 + 6 = 6
    uint64_t insn_number : 4;            // 6 + 4 = 10
    uint64_t insn_kind : 4;              // 10 + 4 = 14
    uint64_t psum_datawidth : 2;         // 14 + 2 = 16
    uint64_t psum_read_base_addr : 15;   // 16 + 15 = 31
    uint64_t psum_write_base_addr : 15;  // 31 + 15 = 46
    uint64_t reversed_0 : 20;            // 46 + 20 = 66
    uint64_t reversed_1 : 62;            // 66 + 62 = 128
  } vcu_transpose_bits;
#else
  // for vcs simulation
  typedef struct {
    uint64_t insn_opcode : 6;            // 0 + 6 = 6
    uint64_t insn_number : 4;            // 6 + 4 = 10
    uint64_t insn_kind : 4;              // 10 + 4 = 14
    uint64_t psum_datawidth : 2;         // 14 + 2 = 16
    uint64_t psum_read_base_addr : 14;   // 16 + 14 = 30
    uint64_t psum_write_base_addr : 14;  // 30 + 14 = 44
    uint64_t reversed_0 : 20;            // 44 + 20 = 64
    uint64_t reversed_1 : 64;            // 64 + 64 = 128
  } vcu_transpose_bits;
#endif

union vcu_cvt {
  vcu_execute_bits                execute;
  vcu_config_bits                 config;
  vcu_parallelism_conversion_bits parallelism_conversion;
  vcu_maxpool_bits                maxpool;
  vcu_avgpool_bits                avgpool;
  vcu_upsample_bits               upsample;
  vcu_transpose_bits              transpose;
  insn_bits                       insn;
};

struct vcu_execute: public instruction {

  private:
  vcu_execute_bits storage_t;

  public:
  vcu_execute() {}

  vcu_execute(uint64_t low, uint64_t high): instruction(low, high) {}

  vcu_execute(instruction& insn)
  {
    union vcu_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.execute;
    this->set_insn();
  }

  vcu_execute(uint64_t psum_data_type,
              uint64_t resadd_para_type,
              uint64_t data_out_type,
              uint64_t data_out_ram,
              uint64_t opcode_number,
              uint64_t opcode_addr,
              uint64_t psum_in_addr,
              uint64_t para_in_addr,
              uint64_t resadd_in_addr,
              uint64_t ram_out_addr,
              uint64_t num_data_cnt,
              uint64_t oc_group_cnt,
              uint64_t para_func_cnt,
              uint64_t psum_sram_valid   = 1,
              uint64_t resadd_sram_valid = 1,
              uint64_t para_sram_valid   = 1,
              uint64_t psum_addr_hop     = 0,
              uint64_t acc_clear         = 0,
              uint64_t stream_en  = 0,
              uint64_t ifmap_sram_valid  = 0,
              uint64_t ifmap_in_addr     = 0,
              uint64_t s2p_32_en         = 0,
              uint64_t psum_1_sram_valid = 0,
              uint64_t psum_1_in_addr    = 0)
  {
    this->storage_t.insn_opcode         = 25;
    this->storage_t.insn_number         = 0;
    this->storage_t.insn_kind           = 1;
    this->storage_t.psum_data_type      = psum_data_type;
    this->storage_t.resadd_para_type    = resadd_para_type;
    this->storage_t.data_out_type       = data_out_type;
    this->storage_t.data_out_ram        = data_out_ram;
    this->storage_t.opcode_number       = opcode_number;
    this->storage_t.opcode_addr         = opcode_addr;
    this->storage_t.psum_in_addr        = psum_in_addr;
    this->storage_t.para_in_addr        = para_in_addr;
    this->storage_t.resadd_in_addr_low  = (resadd_in_addr & 0x7F);
    this->storage_t.resadd_in_addr_high = (resadd_in_addr >> 7);
    this->storage_t.ram_out_addr        = ram_out_addr;
    this->storage_t.num_data_cnt        = num_data_cnt;
    this->storage_t.oc_group_cnt        = oc_group_cnt;
    this->storage_t.para_func_cnt       = para_func_cnt;
    this->storage_t.psum_sram_valid     = psum_sram_valid;
    this->storage_t.resadd_sram_valid   = resadd_sram_valid;
    this->storage_t.para_sram_valid     = para_sram_valid;
    this->storage_t.psum_addr_hop       = psum_addr_hop;
    this->storage_t.acc_clear           = acc_clear;
    this->storage_t.stream_en    = stream_en;
    this->storage_t.ifmap_sram_valid    = ifmap_sram_valid;
    this->storage_t.ifmap_in_addr       = ifmap_in_addr;
    this->storage_t.s2p_32_en           = s2p_32_en;
    this->storage_t.psum_1_sram_valid   = psum_1_sram_valid;
    this->storage_t.psum_1_in_addr      = psum_1_in_addr;
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

  void set_psum_data_type(uint64_t psum_data_type)
  {
    this->storage_t.psum_data_type = psum_data_type;
    this->set_insn();
  }

  void set_resadd_para_type(uint64_t resadd_para_type)
  {
    this->storage_t.resadd_para_type = resadd_para_type;
    this->set_insn();
  }

  void set_data_out_type(uint64_t data_out_type)
  {
    this->storage_t.data_out_type = data_out_type;
    this->set_insn();
  }

  void set_data_out_ram(uint64_t data_out_ram)
  {
    this->storage_t.data_out_ram = data_out_ram;
    this->set_insn();
  }

  void set_opcode_number(uint64_t opcode_number)
  {
    this->storage_t.opcode_number = opcode_number;
    this->set_insn();
  }

  void set_opcode_addr(uint64_t opcode_addr)
  {
    this->storage_t.opcode_addr = opcode_addr;
    this->set_insn();
  }

  void set_psum_in_addr(uint64_t psum_in_addr)
  {
    this->storage_t.psum_in_addr = psum_in_addr;
    this->set_insn();
  }

  void set_para_in_addr(uint64_t para_in_addr)
  {
    this->storage_t.para_in_addr = para_in_addr;
    this->set_insn();
  }

  void set_resadd_in_addr(uint64_t resadd_in_addr)
  {
    this->storage_t.resadd_in_addr_low  = (resadd_in_addr & 0x7F);
    this->storage_t.resadd_in_addr_high = (resadd_in_addr >> 7);
    this->set_insn();
  }

  void set_ram_out_addr(uint64_t ram_out_addr)
  {
    this->storage_t.ram_out_addr = ram_out_addr;
    this->set_insn();
  }

  void set_num_data_cnt(uint64_t num_data_cnt)
  {
    this->storage_t.num_data_cnt = num_data_cnt;
    this->set_insn();
  }

  void set_oc_group_cnt(uint64_t oc_group_cnt)
  {
    this->storage_t.oc_group_cnt = oc_group_cnt;
    this->set_insn();
  }

  void set_para_func_cnt(uint64_t para_func_cnt)
  {
    this->storage_t.para_func_cnt = para_func_cnt;
    this->set_insn();
  }

  void set_psum_sram_valid(uint64_t psum_sram_valid)
  {
    this->storage_t.psum_sram_valid = psum_sram_valid;
    this->set_insn();
  }

  void set_para_sram_valid(uint64_t para_sram_valid)
  {
    this->storage_t.para_sram_valid = para_sram_valid;
    this->set_insn();
  }

  void set_resadd_sram_valid(uint64_t resadd_sram_valid)
  {
    this->storage_t.resadd_sram_valid = resadd_sram_valid;
    this->set_insn();
  }

  void set_psum_addr_hop(uint64_t psum_addr_hop)
  {
    this->storage_t.psum_addr_hop = psum_addr_hop;
    this->set_insn();
  }

  void set_acc_clear(uint64_t acc_clear)
  {
    this->storage_t.acc_clear = acc_clear;
    this->set_insn();
  }

  void set_stream_en(uint64_t stream_en)
  {
    this->storage_t.stream_en = stream_en;
    this->set_insn();
  }

  void set_ifmap_sram_valid(uint64_t ifmap_sram_valid)
  {
    this->storage_t.ifmap_sram_valid = ifmap_sram_valid;
    this->set_insn();
  }

  void set_ifmap_in_addr(uint64_t ifmap_in_addr)
  {
    this->storage_t.ifmap_in_addr = ifmap_in_addr;
    this->set_insn();
  }

  void set_s2p_32_en(uint64_t s2p_32_en)
  {
    this->storage_t.s2p_32_en = s2p_32_en;
    this->set_insn();
  }

  void set_psum_1_sram_valid(uint64_t psum_1_sram_valid)
  {
    this->storage_t.psum_1_sram_valid = psum_1_sram_valid;
    this->set_insn();
  }

  void set_psum_1_in_addr(uint64_t psum_1_in_addr)
  {
    this->storage_t.psum_1_in_addr = psum_1_in_addr;
    this->set_insn();
  }

  void set_insn()
  {
    union vcu_cvt cvt;
    cvt.execute   = this->storage_t;
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

  int64_t get_psum_data_type()
  {
    return this->storage_t.psum_data_type;
  }

  int64_t get_resadd_para_type()
  {
    return this->storage_t.resadd_para_type;
  }

  int64_t get_data_out_type()
  {
    return this->storage_t.data_out_type;
  }

  int64_t get_data_out_ram()
  {
    return this->storage_t.data_out_ram;
  }

  int64_t get_opcode_number()
  {
    return this->storage_t.opcode_number;
  }

  int64_t get_opcode_addr()
  {
    return this->storage_t.opcode_addr;
  }

  int64_t get_psum_in_addr()
  {
    return this->storage_t.psum_in_addr;
  }

  int64_t get_para_in_addr()
  {
    return this->storage_t.para_in_addr;
  }

  int64_t get_resadd_in_addr()
  {
    return (this->storage_t.resadd_in_addr_high << 7) | this->storage_t.resadd_in_addr_low;
  }

  int64_t get_ram_out_addr()
  {
    return this->storage_t.ram_out_addr;
  }

  int64_t get_num_data_cnt()
  {
    return this->storage_t.num_data_cnt;
  }

  int64_t get_oc_group_cnt()
  {
    return this->storage_t.oc_group_cnt;
  }

  int64_t get_para_func_cnt()
  {
    return this->storage_t.para_func_cnt;
  }

  int64_t get_psum_sram_valid()
  {
    return this->storage_t.psum_sram_valid;
  }

  int64_t get_resadd_sram_valid()
  {
    return this->storage_t.resadd_sram_valid;
  }

  int64_t get_para_sram_valid()
  {
    return this->storage_t.para_sram_valid;
  }

  int64_t get_psum_addr_hop()
  {
    return this->storage_t.psum_addr_hop;
  }

  int64_t get_acc_clear()
  {
    return this->storage_t.acc_clear;
  }

  int64_t get_stream_en()
  {
    return this->storage_t.stream_en;
  }

  int64_t get_ifmap_sram_valid()
  {
    return this->storage_t.ifmap_sram_valid;
  }

  int64_t get_ifmap_in_addr()
  {
    return this->storage_t.ifmap_in_addr;
  }

  int64_t get_s2p_32_en()
  {
    return this->storage_t.s2p_32_en;
  }

  int64_t get_psum_1_sram_valid()
  {
    return this->storage_t.psum_1_sram_valid;
  }

  int64_t get_psum_1_in_addr()
  {
    return this->storage_t.psum_1_in_addr;
  }
};

struct vcu_config: public instruction {

  private:
  vcu_config_bits storage_t;

  public:
  vcu_config() {}

  vcu_config(uint64_t low, uint64_t high): instruction(low, high) {}

  vcu_config(instruction& insn)
  {
    union vcu_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.config;
    this->set_insn();
  }

  vcu_config(uint64_t sin_cos_lut_base_highaddr,
             uint64_t reciprocal_lut_base_highaddr,
             uint64_t log_lut_base_highaddr,
             uint64_t exp_lut_base_highaddr,
             uint64_t rsqrt_lut_base_highaddr,
             uint64_t tanh_lut_base_highaddr,
             uint64_t sigmoid_lut_base_highaddr = 0,
             uint64_t swish_lut_base_highaddr   = 0,
             uint64_t mish_lut_base_highaddr    = 0,
             uint64_t gelu_lut_base_highaddr    = 0)
  {
    this->storage_t.insn_opcode                  = 25;
    this->storage_t.insn_number                  = 0;
    this->storage_t.insn_kind                    = 0;
    this->storage_t.sin_cos_lut_base_highaddr    = sin_cos_lut_base_highaddr;
    this->storage_t.reciprocal_lut_base_highaddr = reciprocal_lut_base_highaddr;
    this->storage_t.log_lut_base_highaddr        = log_lut_base_highaddr;
    this->storage_t.exp_lut_base_highaddr        = exp_lut_base_highaddr;
    this->storage_t.rsqrt_lut_base_highaddr      = rsqrt_lut_base_highaddr;
    this->storage_t.tanh_lut_base_highaddr       = tanh_lut_base_highaddr;
    this->storage_t.sigmoid_lut_base_highaddr    = sigmoid_lut_base_highaddr;
    this->storage_t.swish_lut_base_highaddr      = swish_lut_base_highaddr;
    this->storage_t.mish_lut_base_highaddr       = mish_lut_base_highaddr;
    this->storage_t.gelu_lut_base_highaddr       = gelu_lut_base_highaddr;
    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_sin_cos_lut_base_highaddr(uint64_t sin_cos_lut_base_highaddr)
  {
    this->storage_t.sin_cos_lut_base_highaddr = sin_cos_lut_base_highaddr;
    this->set_insn();
  }

  void set_reciprocal_lut_base_highaddr(uint64_t reciprocal_lut_base_highaddr)
  {
    this->storage_t.reciprocal_lut_base_highaddr = reciprocal_lut_base_highaddr;
    this->set_insn();
  }

  void set_log_lut_base_highaddr(uint64_t log_lut_base_highaddr)
  {
    this->storage_t.log_lut_base_highaddr = log_lut_base_highaddr;
    this->set_insn();
  }

  void set_exp_lut_base_highaddr(uint64_t exp_lut_base_highaddr)
  {
    this->storage_t.exp_lut_base_highaddr = exp_lut_base_highaddr;
    this->set_insn();
  }

  void set_rsqrt_lut_base_highaddr(uint64_t rsqrt_lut_base_highaddr)
  {
    this->storage_t.rsqrt_lut_base_highaddr = rsqrt_lut_base_highaddr;
    this->set_insn();
  }

  void set_tanh_lut_base_highaddr(uint64_t tanh_lut_base_highaddr)
  {
    this->storage_t.tanh_lut_base_highaddr = tanh_lut_base_highaddr;
    this->set_insn();
  }

  void set_sigmoid_lut_base_highaddr(uint64_t sigmoid_lut_base_highaddr)
  {
    this->storage_t.sigmoid_lut_base_highaddr = sigmoid_lut_base_highaddr;
    this->set_insn();
  }

  void set_swish_lut_base_highaddr(uint64_t swish_lut_base_highaddr)
  {
    this->storage_t.swish_lut_base_highaddr = swish_lut_base_highaddr;
    this->set_insn();
  }

  void set_mish_lut_base_highaddr(uint64_t mish_lut_base_highaddr)
  {
    this->storage_t.mish_lut_base_highaddr = mish_lut_base_highaddr;
    this->set_insn();
  }

  void set_gelu_lut_base_highaddr(uint64_t gelu_lut_base_highaddr)
  {
    this->storage_t.gelu_lut_base_highaddr = gelu_lut_base_highaddr;
    this->set_insn();
  }

  void set_insn()
  {
    union vcu_cvt cvt;
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

  int64_t get_sin_cos_lut_base_highaddr()
  {
    return this->storage_t.sin_cos_lut_base_highaddr;
  }

  int64_t get_reciprocal_lut_base_highaddr()
  {
    return this->storage_t.reciprocal_lut_base_highaddr;
  }

  int64_t get_log_lut_base_highaddr()
  {
    return this->storage_t.log_lut_base_highaddr;
  }

  int64_t get_exp_lut_base_highaddr()
  {
    return this->storage_t.exp_lut_base_highaddr;
  }

  int64_t get_rsqrt_lut_base_highaddr()
  {
    return this->storage_t.rsqrt_lut_base_highaddr;
  }

  int64_t get_tanh_lut_base_highaddr()
  {
    return this->storage_t.tanh_lut_base_highaddr;
  }

  int64_t get_sigmoid_lut_base_highaddr()
  {
    return this->storage_t.sigmoid_lut_base_highaddr;
  }

  int64_t get_swish_lut_base_highaddr()
  {
    return this->storage_t.swish_lut_base_highaddr;
  }

  int64_t get_mish_lut_base_highaddr()
  {
    return this->storage_t.mish_lut_base_highaddr;
  }

  int64_t get_gelu_lut_base_highaddr()
  {
    return this->storage_t.gelu_lut_base_highaddr;
  }
};

struct vcu_transpose: public instruction {

  private:
  vcu_transpose_bits storage_t;

  public:
  vcu_transpose() {}

  vcu_transpose(uint64_t low, uint64_t high): instruction(low, high) {}

  vcu_transpose(instruction& insn)
  {
    union vcu_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.transpose;
    this->set_insn();
  }

  vcu_transpose(uint64_t psum_datawidth, uint64_t psum_read_base_addr, uint64_t psum_write_base_addr)
  {
    this->storage_t.insn_opcode          = 25;
    this->storage_t.insn_number          = 0;
    this->storage_t.insn_kind            = 8;
    this->storage_t.psum_datawidth       = psum_datawidth;
    this->storage_t.psum_read_base_addr  = psum_read_base_addr;
    this->storage_t.psum_write_base_addr = psum_write_base_addr;

    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_psum_datawidth(uint64_t psum_datawidth)
  {
    this->storage_t.psum_datawidth = psum_datawidth;
    this->set_insn();
  }

  void set_psum_read_base_addr(uint64_t psum_read_base_addr)
  {
    this->storage_t.psum_read_base_addr = psum_read_base_addr;
    this->set_insn();
  }

  void set_psum_write_base_addr(uint64_t psum_write_base_addr)
  {
    this->storage_t.psum_write_base_addr = psum_write_base_addr;
    this->set_insn();
  }

  void set_insn()
  {
    union vcu_cvt cvt;
    cvt.transpose = this->storage_t;
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

  int64_t get_psum_datawidth()
  {
    return this->storage_t.psum_datawidth;
  }

  int64_t get_psum_read_base_addr()
  {
    return this->storage_t.psum_read_base_addr;
  }

  int64_t get_psum_write_base_addr()
  {
    return this->storage_t.psum_write_base_addr;
  }
};

struct maxpool: public instruction {

  private:
  vcu_maxpool_bits storage_t;

  public:
  maxpool() {}

  maxpool(uint64_t low, uint64_t high): instruction(low, high) {}

  maxpool(instruction& insn)
  {
    union vcu_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.maxpool;
    this->set_insn();
  }

  maxpool(uint64_t data_in_type,
          uint64_t data_out_type,
          uint64_t psum_width,
          uint64_t psum_height,
          uint64_t oc_group,
          uint64_t kernel_width,
          uint64_t kernel_height,
          uint64_t psum_read_highaddr,
          uint64_t psum_write_highaddr,
          uint64_t pool_width,
          uint64_t pool_height,
          uint64_t stride_width,
          uint64_t stride_height,
          uint64_t dilation_width,
          uint64_t dilation_height,
          uint64_t pad_left,
          uint64_t pad_top)
  {
    this->storage_t.insn_opcode         = 25;
    this->storage_t.insn_number         = 0;
    this->storage_t.insn_kind           = 3;
    this->storage_t.data_in_type        = data_in_type;
    this->storage_t.data_out_type       = data_out_type;
    this->storage_t.psum_width          = psum_width;
    this->storage_t.psum_height         = psum_height;
    this->storage_t.oc_group            = oc_group;
    this->storage_t.kernel_width_low    = (kernel_width & 0xF);
    this->storage_t.kernel_width_high   = (kernel_width >> 4);
    this->storage_t.kernel_height       = kernel_height;
    this->storage_t.psum_read_highaddr  = psum_read_highaddr;
    this->storage_t.psum_write_highaddr = psum_write_highaddr;
    this->storage_t.pool_width          = pool_width;
    this->storage_t.pool_height         = pool_height;
    this->storage_t.stride_width        = stride_width;
    this->storage_t.stride_height       = stride_height;
    this->storage_t.dilation_width      = dilation_width;
    this->storage_t.dilation_height     = dilation_height;
    this->storage_t.pad_left            = pad_left;
    this->storage_t.pad_top             = pad_top;
    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_data_in_type(uint64_t data_in_type)
  {
    this->storage_t.data_in_type = data_in_type;
    this->set_insn();
  }

  void set_data_out_type(uint64_t data_out_type)
  {
    this->storage_t.data_out_type = data_out_type;
    this->set_insn();
  }

  void set_psum_width(uint64_t psum_width)
  {
    this->storage_t.psum_width = psum_width;
    this->set_insn();
  }

  void set_psum_height(uint64_t psum_height)
  {
    this->storage_t.psum_height = psum_height;
    this->set_insn();
  }

  void set_oc_group(uint64_t oc_group)
  {
    this->storage_t.oc_group = oc_group;
    this->set_insn();
  }

  void set_kernel_width(uint64_t kernel_width)
  {
    this->storage_t.kernel_width_low  = (kernel_width & 0xF);
    this->storage_t.kernel_width_high = (kernel_width >> 4);
    this->set_insn();
  }

  void set_kernel_height(uint64_t kernel_height)
  {
    this->storage_t.kernel_height = kernel_height;
    this->set_insn();
  }

  void set_psum_read_highaddr(uint64_t psum_read_highaddr)
  {
    this->storage_t.psum_read_highaddr = psum_read_highaddr;
    this->set_insn();
  }

  void set_psum_write_highaddr(uint64_t psum_write_highaddr)
  {
    this->storage_t.psum_write_highaddr = psum_write_highaddr;
    this->set_insn();
  }

  void set_pool_width(uint64_t pool_width)
  {
    this->storage_t.pool_width = pool_width;
    this->set_insn();
  }

  void set_pool_height(uint64_t pool_height)
  {
    this->storage_t.pool_height = pool_height;
    this->set_insn();
  }

  void set_stride_width(uint64_t stride_width)
  {
    this->storage_t.stride_width = stride_width;
    this->set_insn();
  }

  void set_stride_height(uint64_t stride_height)
  {
    this->storage_t.stride_height = stride_height;
    this->set_insn();
  }

  void set_dilation_width(uint64_t dilation_width)
  {
    this->storage_t.dilation_width = dilation_width;
    this->set_insn();
  }

  void set_dilation_height(uint64_t dilation_height)
  {
    this->storage_t.dilation_height = dilation_height;
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

  void set_insn()
  {
    union vcu_cvt cvt;
    cvt.maxpool   = this->storage_t;
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

  int64_t get_data_in_type()
  {
    return this->storage_t.data_in_type;
  }

  int64_t get_data_out_type()
  {
    return this->storage_t.data_out_type;
  }

  int64_t get_psum_width()
  {
    return this->storage_t.psum_width;
  }

  int64_t get_psum_height()
  {
    return this->storage_t.psum_height;
  }

  int64_t get_oc_group()
  {
    return this->storage_t.oc_group;
  }

  int64_t get_kernel_width()
  {
    return (this->storage_t.kernel_width_high << 4) | this->storage_t.kernel_width_low;
  }

  int64_t get_kernel_height()
  {
    return this->storage_t.kernel_height;
  }

  int64_t get_psum_read_highaddr()
  {
    return this->storage_t.psum_read_highaddr;
  }

  int64_t get_psum_write_highaddr()
  {
    return this->storage_t.psum_write_highaddr;
  }

  int64_t get_pool_width()
  {
    return this->storage_t.pool_width;
  }

  int64_t get_pool_height()
  {
    return this->storage_t.pool_height;
  }

  int64_t get_stride_width()
  {
    return this->storage_t.stride_width;
  }

  int64_t get_stride_height()
  {
    return this->storage_t.stride_height;
  }

  int64_t get_dilation_width()
  {
    return this->storage_t.dilation_width;
  }

  int64_t get_dilation_height()
  {
    return this->storage_t.dilation_height;
  }

  int64_t get_pad_left()
  {
    return this->storage_t.pad_left;
  }

  int64_t get_pad_top()
  {
    return this->storage_t.pad_top;
  }
};

struct avgpool: public instruction {

  private:
  vcu_avgpool_bits storage_t;

  public:
  avgpool() {}

  avgpool(uint64_t low, uint64_t high): instruction(low, high) {}

  avgpool(instruction& insn)
  {
    union vcu_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.avgpool;
    this->set_insn();
  }

  avgpool(uint64_t data_in_type,
          uint64_t data_out_type,
          uint64_t psum_width,
          uint64_t psum_height,
          uint64_t oc_group,
          uint64_t kernel_width,
          uint64_t kernel_height,
          uint64_t psum_read_highaddr,
          uint64_t psum_write_highaddr,
          uint64_t pool_width,
          uint64_t pool_height,
          uint64_t stride_width,
          uint64_t stride_height,
          uint64_t dilation_width,
          uint64_t dilation_height,
          uint64_t pad_left,
          uint64_t pad_top)
  {
    this->storage_t.insn_opcode         = 25;
    this->storage_t.insn_number         = 0;
    this->storage_t.insn_kind           = 4;
    this->storage_t.data_in_type        = data_in_type;
    this->storage_t.data_out_type       = data_out_type;
    this->storage_t.psum_width          = psum_width;
    this->storage_t.psum_height         = psum_height;
    this->storage_t.oc_group            = oc_group;
    this->storage_t.kernel_width_low    = (kernel_width & 0xF);
    this->storage_t.kernel_width_high   = (kernel_width >> 4);
    this->storage_t.kernel_height       = kernel_height;
    this->storage_t.psum_read_highaddr  = psum_read_highaddr;
    this->storage_t.psum_write_highaddr = psum_write_highaddr;
    this->storage_t.pool_width          = pool_width;
    this->storage_t.pool_height         = pool_height;
    this->storage_t.stride_width        = stride_width;
    this->storage_t.stride_height       = stride_height;
    this->storage_t.dilation_width      = dilation_width;
    this->storage_t.dilation_height     = dilation_height;
    this->storage_t.pad_left            = pad_left;
    this->storage_t.pad_top             = pad_top;
    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_data_in_type(uint64_t data_in_type)
  {
    this->storage_t.data_in_type = data_in_type;
    this->set_insn();
  }

  void set_data_out_type(uint64_t data_out_type)
  {
    this->storage_t.data_out_type = data_out_type;
    this->set_insn();
  }

  void set_psum_width(uint64_t psum_width)
  {
    this->storage_t.psum_width = psum_width;
    this->set_insn();
  }

  void set_psum_height(uint64_t psum_height)
  {
    this->storage_t.psum_height = psum_height;
    this->set_insn();
  }

  void set_oc_group(uint64_t oc_group)
  {
    this->storage_t.oc_group = oc_group;
    this->set_insn();
  }

  void set_kernel_width(uint64_t kernel_width)
  {
    this->storage_t.kernel_width_low  = (kernel_width & 0xF);
    this->storage_t.kernel_width_high = (kernel_width >> 4);
    this->set_insn();
  }

  void set_kernel_height(uint64_t kernel_height)
  {
    this->storage_t.kernel_height = kernel_height;
    this->set_insn();
  }

  void set_psum_read_highaddr(uint64_t psum_read_highaddr)
  {
    this->storage_t.psum_read_highaddr = psum_read_highaddr;
    this->set_insn();
  }

  void set_psum_write_highaddr(uint64_t psum_write_highaddr)
  {
    this->storage_t.psum_write_highaddr = psum_write_highaddr;
    this->set_insn();
  }

  void set_pool_width(uint64_t pool_width)
  {
    this->storage_t.pool_width = pool_width;
    this->set_insn();
  }

  void set_pool_height(uint64_t pool_height)
  {
    this->storage_t.pool_height = pool_height;
    this->set_insn();
  }

  void set_stride_width(uint64_t stride_width)
  {
    this->storage_t.stride_width = stride_width;
    this->set_insn();
  }

  void set_stride_height(uint64_t stride_height)
  {
    this->storage_t.stride_height = stride_height;
    this->set_insn();
  }

  void set_dilation_width(uint64_t dilation_width)
  {
    this->storage_t.dilation_width = dilation_width;
    this->set_insn();
  }

  void set_dilation_height(uint64_t dilation_height)
  {
    this->storage_t.dilation_height = dilation_height;
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

  void set_insn()
  {
    union vcu_cvt cvt;
    cvt.avgpool   = this->storage_t;
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

  int64_t get_data_in_type()
  {
    return this->storage_t.data_in_type;
  }

  int64_t get_data_out_type()
  {
    return this->storage_t.data_out_type;
  }

  int64_t get_psum_width()
  {
    return this->storage_t.psum_width;
  }

  int64_t get_psum_height()
  {
    return this->storage_t.psum_height;
  }

  int64_t get_oc_group()
  {
    return this->storage_t.oc_group;
  }

  int64_t get_kernel_width()
  {
    return (this->storage_t.kernel_width_high << 4) | this->storage_t.kernel_width_low;
  }

  int64_t get_kernel_height()
  {
    return this->storage_t.kernel_height;
  }

  int64_t get_psum_read_highaddr()
  {
    return this->storage_t.psum_read_highaddr;
  }

  int64_t get_psum_write_highaddr()
  {
    return this->storage_t.psum_write_highaddr;
  }

  int64_t get_pool_width()
  {
    return this->storage_t.pool_width;
  }

  int64_t get_pool_height()
  {
    return this->storage_t.pool_height;
  }

  int64_t get_stride_width()
  {
    return this->storage_t.stride_width;
  }

  int64_t get_stride_height()
  {
    return this->storage_t.stride_height;
  }

  int64_t get_dilation_width()
  {
    return this->storage_t.dilation_width;
  }

  int64_t get_dilation_height()
  {
    return this->storage_t.dilation_height;
  }

  int64_t get_pad_left()
  {
    return this->storage_t.pad_left;
  }

  int64_t get_pad_top()
  {
    return this->storage_t.pad_top;
  }
};

struct upsample: public instruction {

  private:
  vcu_upsample_bits storage_t;

  public:
  upsample() {}

  upsample(uint64_t low, uint64_t high): instruction(low, high) {}

  upsample(instruction& insn)
  {
    union vcu_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.upsample;
    this->set_insn();
  }

  upsample(uint64_t data_in_type,
           uint64_t data_out_type,
           uint64_t psum_width,
           uint64_t psum_height,
           uint64_t oc_group,
           uint64_t psum_read_highaddr,
           uint64_t psum_write_highaddr,
           uint64_t scale_width,
           uint64_t scale_height,
           uint64_t upsample_width,
           uint64_t upsample_height)
  {
    this->storage_t.insn_opcode         = 25;
    this->storage_t.insn_number         = 0;
    this->storage_t.insn_kind           = 5;
    this->storage_t.data_in_type        = data_in_type;
    this->storage_t.data_out_type       = data_out_type;
    this->storage_t.psum_width          = psum_width;
    this->storage_t.psum_height         = psum_height;
    this->storage_t.oc_group            = oc_group;
    this->storage_t.psum_read_highaddr  = psum_read_highaddr;
    this->storage_t.psum_write_highaddr = psum_write_highaddr;
    this->storage_t.scale_width_low     = (scale_width & 0xF);
    this->storage_t.scale_width_high    = (scale_width >> 4);
    this->storage_t.scale_height        = scale_height;
    this->storage_t.upsample_width      = upsample_width;
    this->storage_t.upsample_height     = upsample_height;
    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_data_in_type(uint64_t data_in_type)
  {
    this->storage_t.data_in_type = data_in_type;
    this->set_insn();
  }

  void set_data_out_type(uint64_t data_out_type)
  {
    this->storage_t.data_out_type = data_out_type;
    this->set_insn();
  }

  void set_psum_width(uint64_t psum_width)
  {
    this->storage_t.psum_width = psum_width;
    this->set_insn();
  }

  void set_psum_height(uint64_t psum_height)
  {
    this->storage_t.psum_height = psum_height;
    this->set_insn();
  }

  void set_oc_group(uint64_t oc_group)
  {
    this->storage_t.oc_group = oc_group;
    this->set_insn();
  }

  void set_psum_read_highaddr(uint64_t psum_read_highaddr)
  {
    this->storage_t.psum_read_highaddr = psum_read_highaddr;
    this->set_insn();
  }

  void set_psum_write_highaddr(uint64_t psum_write_highaddr)
  {
    this->storage_t.psum_write_highaddr = psum_write_highaddr;
    this->set_insn();
  }

  void set_scale_width(uint64_t scale_width)
  {
    this->storage_t.scale_width_low  = (scale_width & 0xF);
    this->storage_t.scale_width_high = (scale_width >> 4);
    this->set_insn();
  }

  void set_scale_height(uint64_t scale_height)
  {
    this->storage_t.scale_height = scale_height;
    this->set_insn();
  }

  void set_upsample_width(uint64_t upsample_width)
  {
    this->storage_t.upsample_width = upsample_width;
    this->set_insn();
  }

  void set_upsample_height(uint64_t upsample_height)
  {
    this->storage_t.upsample_height = upsample_height;
    this->set_insn();
  }

  void set_insn()
  {
    union vcu_cvt cvt;
    cvt.upsample  = this->storage_t;
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

  int64_t get_data_in_type()
  {
    return this->storage_t.data_in_type;
  }

  int64_t get_data_out_type()
  {
    return this->storage_t.data_out_type;
  }

  int64_t get_psum_width()
  {
    return this->storage_t.psum_width;
  }

  int64_t get_psum_height()
  {
    return this->storage_t.psum_height;
  }

  int64_t get_oc_group()
  {
    return this->storage_t.oc_group;
  }

  int64_t get_psum_read_highaddr()
  {
    return this->storage_t.psum_read_highaddr;
  }

  int64_t get_psum_write_highaddr()
  {
    return this->storage_t.psum_write_highaddr;
  }

  int64_t get_scale_width()
  {
    return (this->storage_t.scale_width_high << 4) | this->storage_t.scale_width_low;
  }

  int64_t get_scale_height()
  {
    return this->storage_t.scale_height;
  }

  int64_t get_upsample_width()
  {
    return this->storage_t.upsample_width;
  }

  int64_t get_upsample_height()
  {
    return this->storage_t.upsample_height;
  }
};

struct vcu_parallelism_conversion: public instruction {

  private:
  vcu_parallelism_conversion_bits storage_t;

  public:
  vcu_parallelism_conversion() {}

  vcu_parallelism_conversion(uint64_t low, uint64_t high): instruction(low, high) {}

  vcu_parallelism_conversion(instruction& insn)
  {
    union vcu_cvt cvt;
    cvt.insn        = insn.storage;
    this->storage_t = cvt.parallelism_conversion;
    this->set_insn();
  }

  vcu_parallelism_conversion(uint64_t data_in_bits_type,
                             uint64_t psum_read_base_addr,
                             uint64_t ofmap_write_base_addr,
                             uint64_t num_data,
                             uint64_t in_oc_group,
                             uint64_t out_oc_group)
  {
    this->storage_t.insn_opcode           = 25;
    this->storage_t.insn_number           = 0;
    this->storage_t.insn_kind             = 2;
    this->storage_t.data_in_bits_type     = data_in_bits_type;
    this->storage_t.psum_read_base_addr   = psum_read_base_addr;
    this->storage_t.ofmap_write_base_addr = ofmap_write_base_addr;
    this->storage_t.num_data              = num_data;
    this->storage_t.in_oc_group           = in_oc_group;
    this->storage_t.out_oc_group          = out_oc_group;
    this->set_insn();
  }

  void set_insn_opcode(uint64_t opcode)
  {
    this->storage_t.insn_opcode = opcode;
    this->set_insn();
  }

  void set_data_in_bits_type(uint64_t data_in_bits_type)
  {
    this->storage_t.data_in_bits_type = data_in_bits_type;
    this->set_insn();
  }

  void set_psum_read_base_addr(uint64_t psum_read_base_addr)
  {
    this->storage_t.psum_read_base_addr = psum_read_base_addr;
    this->set_insn();
  }

  void set_ofmap_write_base_addr(uint64_t ofmap_write_base_addr)
  {
    this->storage_t.ofmap_write_base_addr = ofmap_write_base_addr;
    this->set_insn();
  }

  void set_num_data(uint64_t num_data)
  {
    this->storage_t.num_data = num_data;
    this->set_insn();
  }

  void set_in_oc_group(uint64_t in_oc_group)
  {
    this->storage_t.in_oc_group = in_oc_group;
    this->set_insn();
  }

  void set_out_oc_group(uint64_t out_oc_group)
  {
    this->storage_t.out_oc_group = out_oc_group;
    this->set_insn();
  }

  void set_insn()
  {
    union vcu_cvt cvt;
    cvt.parallelism_conversion = this->storage_t;
    this->storage              = cvt.insn;
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

  int64_t get_data_in_bits_type()
  {
    return this->storage_t.data_in_bits_type;
  }

  int64_t get_psum_read_base_addr()
  {
    return this->storage_t.psum_read_base_addr;
  }

  int64_t get_ofmap_write_base_addr()
  {
    return this->storage_t.ofmap_write_base_addr;
  }

  int64_t get_num_data()
  {
    return this->storage_t.num_data;
  }

  int64_t get_in_oc_group()
  {
    return this->storage_t.in_oc_group;
  }

  int64_t get_out_oc_group()
  {
    return this->storage_t.out_oc_group;
  }
};

}  // namespace insn
}  // namespace common
