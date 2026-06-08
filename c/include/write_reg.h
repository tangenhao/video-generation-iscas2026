#pragma once

#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>

#define BROADCAST 1
#define NO_BROADCAST 0

#define PSUM_LOAD_1024 0
#define PSUM_LOAD_512 1
#define PSUM_LOAD_256 2
#define PSUM_LOAD_128 3

#define PSUM_STORE_1024 0
#define PSUM_STORE_512 1
#define PSUM_STORE_256 2
#define PSUM_STORE_128 3

#define VCURES_LOAD_1024 0
#define VCURES_LOAD_512 1
#define VCURES_LOAD_256 2
#define VCURES_LOAD_128 3

#define IFMAP_MASK_LOAD_32 0
#define IFMAP_MASK_LOAD_64 1
#define IFMAP_MASK_LOAD_128 2

void write_regs(const char* file_name                  = "../../sim/bench/reg_data.txt",
                int64_t     insn_addr                  = 0,
                int         insn_number                = 100,
                int         insn_burst_length          = 32,
                int         local_highaddr             = 0,
                int         ifmap_broadcast            = 0,
                int         ifmap_scale_broadcast      = 0,
                int         weight_broadcaast          = 0,
                int         weight_scale_broadcast     = 0,
                int         outlier_index_broadcast    = 0,
                int         vcupara_broadcast          = 0,
                int         vcures_broadcast           = 0,
                int         vcucode_broadcast          = 0,
                int         vculut_broadcast           = 0,
                int         psum_load_valid_bits       = 0,
                int         psum_store_valid_bits      = 0,
                int         vcures_load_valid_bits     = 0,
                int         ifmap_mask_load_valid_bits = 0,
                int         enable_prof_counter        = 1)
{
  std::ofstream file;
  file.open(file_name);

  file << std::setfill('0') << std::setw(8) << std::hex << (insn_addr & 0xffffffff) << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << (insn_addr >> 32) << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << insn_number << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << insn_burst_length << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << local_highaddr << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << ifmap_broadcast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << ifmap_scale_broadcast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << weight_broadcaast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << weight_scale_broadcast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << outlier_index_broadcast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << vcupara_broadcast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << vcures_broadcast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << vcucode_broadcast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << vculut_broadcast << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << psum_load_valid_bits << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << psum_store_valid_bits << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << vcures_load_valid_bits << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << ifmap_mask_load_valid_bits << std::endl;
  file << std::setfill('0') << std::setw(8) << std::hex << enable_prof_counter << std::endl;
}