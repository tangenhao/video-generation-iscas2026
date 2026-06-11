#pragma once

#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <vector>

#include "common/cfg.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include "common/read_cfg.h"
#include "common/type_utils.h"
namespace vcu {

using namespace common;

struct vcu_exe_args {
  DType    resadd_type;
  uint64_t resadd_valid;
  uint64_t para_valid;
  uint64_t acc_compute;
  uint64_t fast_func_class;
  uint64_t data_out_ram;
  uint64_t opcode_addr;
  uint64_t psum_in_addr;
  uint64_t para_in_addr;
  uint64_t resadd_in_addr;
  uint64_t ram_out_addr;
  uint64_t para_func;
  uint64_t psum_sram_valid   = 1;
  uint64_t resadd_sram_valid = 1;
  uint64_t para_sram_valid   = 1;
  uint64_t psum_addr_hop     = 0;
  uint64_t acc_clear         = 0;
  uint64_t stream_en  = 0;
  uint64_t ifmap_sram_valid  = 0;
  uint64_t ifmap_in_addr     = 0;
  uint64_t s2p_32_en         = 0;
  uint64_t psum_1_sram_valid = 0;
  uint64_t psum_1_in_addr    = 0;
};

struct VcuConfig {

  struct Arguments {
    uint64_t sin_cos_lut_base_highaddr;
    uint64_t reciprocal_lut_base_highaddr;
    uint64_t log_lut_base_highaddr;
    uint64_t exp_lut_base_highaddr;
    uint64_t rsqrt_lut_base_highaddr;
    uint64_t tanh_lut_base_highaddr;
    uint64_t sigmoid_lut_base_highaddr;
    uint64_t swish_lut_base_highaddr;
    uint64_t mish_lut_base_highaddr;
    uint64_t gelu_lut_base_highaddr;
  };

  VcuConfig() {}

  std::vector<insn::instruction> operator()(const Arguments& args)
  {
    std::vector<insn::instruction> instruction_series;

    instruction_series.push_back(insn::vcu_config(args.sin_cos_lut_base_highaddr,
                                                  args.reciprocal_lut_base_highaddr,
                                                  args.log_lut_base_highaddr,
                                                  args.exp_lut_base_highaddr,
                                                  args.rsqrt_lut_base_highaddr,
                                                  args.tanh_lut_base_highaddr,
                                                  args.sigmoid_lut_base_highaddr,
                                                  args.swish_lut_base_highaddr,
                                                  args.mish_lut_base_highaddr,
                                                  args.gelu_lut_base_highaddr));

    return instruction_series;
  }
};

struct VcuExecute {
  struct Arguments {
    uint64_t psum_data_type;
    uint64_t resadd_para_type;
    uint64_t data_out_type;
    uint64_t data_out_ram;
    uint64_t opcode_number;
    uint64_t opcode_addr;
    uint64_t psum_in_addr;
    uint64_t para_in_addr;
    uint64_t resadd_in_addr;
    uint64_t ram_out_addr;
    uint64_t num_data;
    uint64_t oc_group;
    uint64_t para_func;
    uint64_t psum_sram_valid   = 1;
    uint64_t resadd_sram_valid = 1;
    uint64_t para_sram_valid   = 1;
    uint64_t psum_addr_hop     = 0;
    uint64_t acc_clear         = 0;
    uint64_t stream_en  = 0;
    uint64_t ifmap_sram_valid  = 0;
    uint64_t ifmap_in_addr     = 0;
    uint64_t s2p_32_en         = 0;
    uint64_t psum_1_sram_valid = 0;
    uint64_t psum_1_in_addr    = 0;
  };

  VcuExecute() {}

  std::vector<insn::instruction> operator()(const Arguments& args)
  {
    std::vector<insn::instruction> instruction_series;

    instruction_series.push_back(insn::vcu_execute(args.psum_data_type,
                                                   args.resadd_para_type,
                                                   args.data_out_type,
                                                   args.data_out_ram,
                                                   args.opcode_number,
                                                   args.opcode_addr,
                                                   args.psum_in_addr,
                                                   args.para_in_addr,
                                                   args.resadd_in_addr,
                                                   args.ram_out_addr,
                                                   args.num_data,
                                                   args.oc_group,
                                                   args.para_func,
                                                   args.psum_sram_valid,
                                                   args.resadd_sram_valid,
                                                   args.para_sram_valid,
                                                   args.psum_addr_hop,
                                                   args.acc_clear,
                                                   args.stream_en,
                                                   args.ifmap_sram_valid,
                                                   args.ifmap_in_addr,
                                                   args.s2p_32_en,
                                                   args.psum_1_sram_valid,
                                                   args.psum_1_in_addr));
    return instruction_series;
  }
};

struct VcuTranspose {
  struct Arguments {
    uint64_t psum_datawidth;
    uint64_t psum_read_base_addr;
    uint64_t psum_write_base_addr;
  };

  VcuTranspose() {}

  std::vector<insn::instruction> operator()(const Arguments& args)
  {
    std::vector<insn::instruction> instruction_series;

    instruction_series.push_back(insn::vcu_transpose(args.psum_datawidth, args.psum_read_base_addr, args.psum_write_base_addr));

    return instruction_series;
  }
};

struct VcuParallelismConvertion {
  struct Arguments {
    uint64_t data_in_bits_type : 1;
    uint64_t psum_read_base_addr : 13;
    uint64_t ofmap_write_base_addr : 13;
    uint64_t num_data : 10;
    uint64_t in_oc_group : 7;
    uint64_t out_oc_group : 7;
  };

  VcuParallelismConvertion() {}

  std::vector<insn::instruction> operator()(const Arguments& args)
  {
    std::vector<insn::instruction> instruction_series;

    instruction_series.push_back(insn::vcu_parallelism_conversion(
      args.data_in_bits_type, args.psum_read_base_addr, args.ofmap_write_base_addr, args.num_data, args.in_oc_group, args.out_oc_group));
    return instruction_series;
  }
};

}  // namespace vcu
