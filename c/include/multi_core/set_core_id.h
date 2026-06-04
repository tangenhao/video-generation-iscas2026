#pragma once

#include "common/assert_with_message.h"
#include "common/insn.h"
#include "instruction/parser.h"
#include <cassert>

namespace multi_core {
namespace core_id {
using namespace common::insn;

void set_load_sram_address(instruction& load_insn, int core_id)
{
  if (load_insn.get_load_insn_kind() == 0) {
    auto load_ = load_iteration_4<0>(load_insn);
    if (load_.get_sram_addr() == MASTER_IFMAP_ADDR) {
      load_.set_sram_addr(MASTER_IFMAP_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_WEIGHT_ADDR) {
      load_.set_sram_addr(MASTER_WEIGHT_ADDR + (core_id % 2) * 1024);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_IFMAP_SCALE_ADDR) {
      load_.set_sram_addr(MASTER_IFMAP_SCALE_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_WEIGHT_SCALE_ADDR) {
      load_.set_sram_addr(MASTER_WEIGHT_SCALE_ADDR + (core_id % 2) * 1024);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_OUTLIER_INDEX_ADDR) {
      load_.set_sram_addr(MASTER_OUTLIER_INDEX_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_PSUM_ADDR) {
      load_.set_sram_addr(MASTER_PSUM_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCUCODE_ADDR) {
      load_.set_sram_addr(MASTER_VCUCODE_ADDR + (core_id % 2) * 32);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCUPARA_ADDR) {
      load_.set_sram_addr(MASTER_VCUPARA_ADDR + (core_id % 2) * 256);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCURES_ADDR) {
      load_.set_sram_addr(MASTER_VCURES_ADDR + (core_id % 2) * 1024);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_IFMAPMASK_ADDR) {
      load_.set_sram_addr(MASTER_IFMAPMASK_ADDR + (core_id % 2) * 64);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCULUT_ADDR) {
      load_.set_sram_addr(MASTER_VCULUT_ADDR + (core_id % 2) * 128);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    load_.set_insn();
    load_insn = load_;
  }
  else if (load_insn.get_load_insn_kind() == 1) {
    auto load_ = load_iteration_3<0>(load_insn);
    if (load_.get_sram_addr() == MASTER_IFMAP_ADDR) {
      load_.set_sram_addr(MASTER_IFMAP_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_WEIGHT_ADDR) {
      load_.set_sram_addr(MASTER_WEIGHT_ADDR + (core_id % 2) * 1024);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_IFMAP_SCALE_ADDR) {
      load_.set_sram_addr(MASTER_IFMAP_SCALE_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_WEIGHT_SCALE_ADDR) {
      load_.set_sram_addr(MASTER_WEIGHT_SCALE_ADDR + (core_id % 2) * 1024);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_OUTLIER_INDEX_ADDR) {
      load_.set_sram_addr(MASTER_OUTLIER_INDEX_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_PSUM_ADDR) {
      load_.set_sram_addr(MASTER_PSUM_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCUCODE_ADDR) {
      load_.set_sram_addr(MASTER_VCUCODE_ADDR + (core_id % 2) * 32);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCUPARA_ADDR) {
      load_.set_sram_addr(MASTER_VCUPARA_ADDR + (core_id % 2) * 256);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCURES_ADDR) {
      load_.set_sram_addr(MASTER_VCURES_ADDR + (core_id % 2) * 1024);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_IFMAPMASK_ADDR) {
      load_.set_sram_addr(MASTER_IFMAPMASK_ADDR + (core_id % 2) * 64);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCULUT_ADDR) {
      load_.set_sram_addr(MASTER_VCULUT_ADDR + (core_id % 2) * 128);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    load_.set_insn();
    load_insn = load_;
  }
  else if (load_insn.get_load_insn_kind() == 2) {
    auto load_ = load_iteration_2<1>(load_insn);
    if (load_.get_sram_addr() == MASTER_IFMAP_ADDR) {
      load_.set_sram_addr(MASTER_IFMAP_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_WEIGHT_ADDR) {
      load_.set_sram_addr(MASTER_WEIGHT_ADDR + (core_id % 2) * 1024);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_IFMAP_SCALE_ADDR) {
      load_.set_sram_addr(MASTER_IFMAP_SCALE_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_WEIGHT_SCALE_ADDR) {
      load_.set_sram_addr(MASTER_WEIGHT_SCALE_ADDR + (core_id % 2) * 1024);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_OUTLIER_INDEX_ADDR) {
      load_.set_sram_addr(MASTER_OUTLIER_INDEX_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_PSUM_ADDR) {
      load_.set_sram_addr(MASTER_PSUM_ADDR + (core_id % 2) * 512);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCUCODE_ADDR) {
      load_.set_sram_addr(MASTER_VCUCODE_ADDR + (core_id % 2) * 32);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCUPARA_ADDR) {
      load_.set_sram_addr(MASTER_VCUPARA_ADDR + (core_id % 2) * 256);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCURES_ADDR) {
      load_.set_sram_addr(MASTER_VCURES_ADDR + (core_id % 2) * 1027);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_IFMAPMASK_ADDR) {
      load_.set_sram_addr(MASTER_IFMAPMASK_ADDR + (core_id % 2) * 64);
      load_.set_insn_opcode(2 + (core_id / 2) * 2);
    }
    else if (load_.get_sram_addr() == MASTER_VCULUT_ADDR) {
      load_.set_sram_addr(MASTER_VCULUT_ADDR + (core_id % 2) * 128);
      load_.set_insn_opcode(1 + (core_id / 2) * 2);
    }
    load_.set_insn();
    load_insn = load_;
  }
}

void set_store_sram_address(instruction& store_insn, int core_id)
{
  if (store_insn.get_store_insn_kind() == 0) {
    auto store_ = store_iteration_4<1>(store_insn);
    if (store_.get_sram_addr() == MASTER_PSUM_ADDR) {
      store_.set_sram_addr(MASTER_PSUM_ADDR + (core_id % 2) * 512);
      store_.set_insn_opcode(9 + (core_id / 2) * 2);
    }
    else if (store_.get_sram_addr() == MASTER_OFMAP_ADDR) {
      store_.set_sram_addr(MASTER_OFMAP_ADDR + (core_id % 2) * 1024);
      store_.set_insn_opcode(9 + (core_id / 2) * 2);
    }
    store_.set_insn();
    store_insn = store_;
  }
  else if (store_insn.get_store_insn_kind() == 1) {
    auto store_ = store_iteration_3<0>(store_insn);
    if (store_.get_sram_addr() == MASTER_PSUM_ADDR) {
      store_.set_sram_addr(MASTER_PSUM_ADDR + (core_id % 2) * 512);
      store_.set_insn_opcode(9 + (core_id / 2) * 2);
    }
    else if (store_.get_sram_addr() == MASTER_OFMAP_ADDR) {
      store_.set_sram_addr(MASTER_OFMAP_ADDR + (core_id % 2) * 1024);
      store_.set_insn_opcode(9 + (core_id / 2) * 2);
    }
    store_.set_insn();
    store_insn = store_;
  }
  else if (store_insn.get_store_insn_kind() == 2) {
    auto store_ = store_iteration_2<0>(store_insn);
    if (store_.get_sram_addr() == MASTER_PSUM_ADDR) {
      store_.set_sram_addr(MASTER_PSUM_ADDR + (core_id % 2) * 512);
      store_.set_insn_opcode(9 + (core_id / 2) * 2);
    }
    else if (store_.get_sram_addr() == MASTER_OFMAP_ADDR) {
      store_.set_sram_addr(MASTER_OFMAP_ADDR + (core_id % 2) * 1024);
      store_.set_insn_opcode(9 + (core_id / 2) * 2);
    }
    store_.set_insn();
    store_insn = store_;
  }
}

void set_pea_sram_address(instruction& pea_insn, int core_id)
{
  if (pea_insn.get_pea_insn_kind() == 0) {
    auto pea_ = pea_config(pea_insn);
    pea_.set_insn_opcode(17 + core_id);
    pea_.set_insn();
    pea_insn = pea_;
  }
  else if (pea_insn.get_pea_insn_kind() == 1) {
    auto pea_ = convolution_execute(pea_insn);
    pea_.set_insn_opcode(17 + core_id);
    pea_.set_insn();
    pea_insn = pea_;
  }
  else if (pea_insn.get_pea_insn_kind() == 2) {
    auto pea_ = maxpool(pea_insn);
    pea_.set_insn_opcode(17 + core_id);
    pea_.set_insn();
    pea_insn = pea_;
  }
}

void set_vcu_sram_address(instruction& vcu_insn, int core_id)
{
  if (vcu_insn.get_vcu_insn_kind() == 0) {
    auto vcu_ = vcu_config(vcu_insn);
    vcu_.set_insn_opcode(25 + core_id);
    vcu_.set_insn();
    vcu_insn = vcu_;
  }
  else if (vcu_insn.get_vcu_insn_kind() == 1) {
    auto vcu_ = vcu_execute(vcu_insn);
    vcu_.set_insn_opcode(25 + core_id);
    vcu_.set_psum_in_addr(vcu_.get_psum_in_addr());
    vcu_.set_resadd_in_addr(vcu_.get_resadd_in_addr());
    vcu_.set_ram_out_addr(vcu_.get_ram_out_addr());
    vcu_.set_insn();
    vcu_insn = vcu_;
  }
  else if (vcu_insn.get_vcu_insn_kind() == 2) {
    auto vcu_ = vcu_parallelism_conversion(vcu_insn);
    vcu_.set_insn_opcode(25 + core_id);
    vcu_.set_psum_read_base_addr(vcu_.get_psum_read_base_addr());
    vcu_.set_ofmap_write_base_addr(vcu_.get_ofmap_write_base_addr());
    vcu_.set_insn();
    vcu_insn = vcu_;
  }
  else if (vcu_insn.get_vcu_insn_kind() == 3) {
    auto vcu_ = maxpool(vcu_insn);
    vcu_.set_insn_opcode(25 + core_id);
    vcu_.set_insn();
    vcu_insn = vcu_;
  }
  else if (vcu_insn.get_vcu_insn_kind() == 4) {
    auto vcu_ = avgpool(vcu_insn);
    vcu_.set_insn_opcode(25 + core_id);
    vcu_.set_insn();
    vcu_insn = vcu_;
  }
  else if (vcu_insn.get_vcu_insn_kind() == 5) {
    auto vcu_ = upsample(vcu_insn);
    vcu_.set_insn_opcode(25 + core_id);
    vcu_.set_insn();
    vcu_insn = vcu_;
  }
  else if (vcu_insn.get_vcu_insn_kind() == 8) {
    auto vcu_ = vcu_transpose(vcu_insn);
    vcu_.set_insn_opcode(25 + core_id);
    vcu_.set_insn();
    vcu_insn = vcu_;
  }
}

void set_core_id(std::vector<instruction>& instructions, int core_id)
{
  for (int i = 0; i < instructions.size(); i++) {
    if (instructions[i].get_insn_opcode() > 0 && instructions[i].get_insn_opcode() <= 8) {
      set_load_sram_address(instructions[i], core_id);
    }
    else if (instructions[i].get_insn_opcode() > 8 && instructions[i].get_insn_opcode() <= 16) {
      set_store_sram_address(instructions[i], core_id);
    }
    else if (instructions[i].get_insn_opcode() > 16 && instructions[i].get_insn_opcode() <= 24) {
      set_pea_sram_address(instructions[i], core_id);
    }
    else if (instructions[i].get_insn_opcode() > 24 && instructions[i].get_insn_number() <= 32) {
      set_vcu_sram_address(instructions[i], core_id);
    }
  }
}

};  // namespace core_id
};  // namespace multi_core
