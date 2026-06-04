#pragma once

#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>

#include "common/cfg.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include "common/read_cfg.h"

namespace store_master {
int store_master_insn_sim(uint64_t             ddr_addr,
                          uint64_t             sequ_burst_0,
                          uint64_t             sram_addr,
                          uint64_t             hop_offset_1_exp,
                          uint64_t             hop_offset_1_fra,
                          uint64_t             sequ_burst_1,
                          uint64_t             hop_offset_2_exp,
                          uint64_t             hop_offset_2_fra,
                          uint64_t             sequ_burst_2,
                          uint64_t             hop_offset_3_exp,
                          uint64_t             hop_offset_3_fra,
                          uint64_t             sequ_burst_3,
                          uint64_t             all_done,
                          common::cfg::Config* insn_bits,
                          uint64_t             sram_width_exp,
                          uint64_t             bus_width_exp,
                          uint64_t             dummy_seed,
                          uint64_t             dummy_mega_number,
                          bool                 update)
{
  uint64_t insn_opcode = 1;
  uint64_t store_insns = 1;

  printf("checking ... \n");
  uint64_t insn_opcode_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "insn_opcode");
  common::insn::check_value(insn_opcode, insn_opcode_bits, "insn_opcode");
  uint64_t store_insns_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "store_insns");
  common::insn::check_value(store_insns, store_insns_bits, "store_insns");
  uint64_t ddr_addr_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "ddr_addr");
  common::insn::check_value(ddr_addr, ddr_addr_bits, "ddr_addr");
  uint64_t sequ_burst_0_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "sequ_burst_0");
  common::insn::check_value(sequ_burst_0, sequ_burst_0_bits, "sequ_burst_0");
  uint64_t hop_offset_1_exp_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "hop_offset_1_exp");
  common::insn::check_value(hop_offset_1_exp, hop_offset_1_exp_bits, "hop_offset_1_exp");
  uint64_t hop_offset_1_fra_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "hop_offset_1_fra");
  common::insn::check_value(hop_offset_1_fra, hop_offset_1_fra_bits, "hop_offset_1_fra");
  uint64_t sequ_burst_1_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "sequ_burst_1");
  common::insn::check_value(sequ_burst_1, sequ_burst_1_bits, "sequ_burst_1");
  uint64_t hop_offset_2_exp_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "hop_offset_2_exp");
  common::insn::check_value(hop_offset_2_exp, hop_offset_2_exp_bits, "hop_offset_2_exp");
  uint64_t hop_offset_2_fra_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "hop_offset_2_fra");
  common::insn::check_value(hop_offset_2_fra, hop_offset_2_fra_bits, "hop_offset_2_fra");
  uint64_t sequ_burst_2_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "sequ_burst_2");
  common::insn::check_value(sequ_burst_2, sequ_burst_2_bits, "sequ_burst_2");
  uint64_t hop_offset_3_exp_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "hop_offset_3_exp");
  common::insn::check_value(hop_offset_3_exp, hop_offset_3_exp_bits, "hop_offset_3_exp");
  uint64_t hop_offset_3_fra_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "hop_offset_3_fra");
  common::insn::check_value(hop_offset_3_fra, hop_offset_3_fra_bits, "hop_offset_3_fra");
  uint64_t sequ_burst_3_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "sequ_burst_3");
  common::insn::check_value(sequ_burst_3, sequ_burst_3_bits, "sequ_burst_3");
  uint64_t sram_addr_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "sram_addr");
  common::insn::check_value(sram_addr, sram_addr_bits, "sram_addr");
  uint64_t all_done_bits = common::read_cfg::getConfigIntValue(insn_bits, "store_master_execute_insn", "all_done");
  common::insn::check_value(all_done, all_done_bits, "all_done");

  // uint64_t      m_bytes            = 1024 * 1024;
  // const size_t  dummy_ddr_size     = dummy_mega_number * m_bytes;
  // const size_t  dummy_ddr_int_size = dummy_ddr_size / sizeof(int);
  // unsigned int* dummy_ddr_int      = reinterpret_cast<unsigned int*>(malloc(dummy_ddr_size));
  // if (dummy_ddr_int == NULL) {
  //   printf("malloc dummy_ddr failed\n");
  //   return 0;
  // }
  // memset(dummy_ddr_int, 0, dummy_ddr_size);
  // char* dummy_ddr = (char*)dummy_ddr_int;
  // printf("malloc dummy_ddr %ld MB successfully\n", dummy_mega_number);

  uint64_t bitwidth_bytes = 1ULL << bus_width_exp;
  printf("bitwidth_bytes: %ld, bitwidth: %ld\n", bitwidth_bytes, bitwidth_bytes * 8);
  uint64_t sram_bytes = 1ULL << sram_width_exp;
  printf("sram_bytes: %ld, sram_width: %ld\n", sram_bytes, sram_bytes * 8);
  assert(((sram_bytes >= bitwidth_bytes) && (sram_bytes % bitwidth_bytes == 0))
         || ((sram_bytes < bitwidth_bytes) && (bitwidth_bytes % sram_bytes == 0)));
  const size_t  sram_size     = bitwidth_bytes * (sequ_burst_0 + 1) * (sequ_burst_1 + 1) * (sequ_burst_2 + 1) * (sequ_burst_3 + 1);
  const size_t  sram_int_size = sram_size / sizeof(int);
  unsigned int* sram_int      = reinterpret_cast<unsigned int*>(malloc(sram_size));
  if (sram_int == NULL) {
    printf("malloc sram failed\n");
    return 0;
  }
  srand(dummy_seed);
  for (int i = 0; i < sram_int_size; i++) {
    sram_int[i] = rand();
  }
  char* sram = (char*)sram_int;
  printf("malloc sram %ld B successfully\n", (sram_size));

  uint64_t          true_ddr_address  = ddr_addr;
  uint64_t          true_sram_address = sram_addr;
  uint64_t          offset_0          = ddr_addr;
  uint64_t          offset_1          = ddr_addr;
  uint64_t          offset_2          = ddr_addr;
  uint64_t          offset_3          = ddr_addr;
  char*             transaction_data  = (char*)malloc(bitwidth_bytes);
  std::ofstream     file;
  std::stringstream ss;
  std::string       result, tmp;
  file.open("../../cocotb/test_store/memory/transfers.txt");
  for (int iter_3 = 0; iter_3 <= sequ_burst_3; iter_3++) {
    offset_3 += hop_offset_3_fra << hop_offset_3_exp;
    for (int iter_2 = 0; iter_2 <= sequ_burst_2; iter_2++) {
      offset_2 += hop_offset_2_fra << hop_offset_2_exp;
      for (int iter_1 = 0; iter_1 <= sequ_burst_1; iter_1++) {
        offset_1 += hop_offset_1_fra << hop_offset_1_exp;
        std::cout << "==== AXI Transation ====\n";
        std::cout << "Iter 1: " << iter_1 << ", Iter 2: " << iter_2 << ", Iter 3: " << iter_3 << std::endl;
        std::cout << std::hex << "AWADDR: 0x" << offset_0 << ", AWLEN: " << sequ_burst_0 << std::endl;
        for (int iter_0 = 0; iter_0 <= sequ_burst_0; iter_0++) {
          true_ddr_address = offset_0;
          file << std::setfill('0') << std::setw(8) << std::hex << (true_ddr_address & 0xffffffff) << ",";
          for (int iter = 0; iter < bitwidth_bytes; iter++) {
            // dummy_ddr[true_ddr_address] = sram[true_sram_address];
            transaction_data[iter] = sram[true_sram_address];
            // std::cout << "iter_0: " << iter_0 << std::endl;
            // std::cout << "iter_1: " << iter_1 << std::endl;
            // std::cout << "iter_2: " << iter_2 << std::endl;
            // std::cout << "iter_3: " << iter_3 << std::endl;
            // std::cout << "true_sram_address: " << true_sram_address << std::endl;
            // std::cout << "true_ddr_address: " << true_ddr_address << std::endl;
            true_sram_address++;
            true_ddr_address++;
          }
          for (int i = 0; i < bitwidth_bytes; ++i) {
            if (i % bitwidth_bytes == 0) {
              result.clear();
            }
            ss.clear();
            ss << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)transaction_data[i] & 0xff);
            ss >> tmp;
            result = tmp + result;
            if (i % bitwidth_bytes == bitwidth_bytes - 1) {
              file << result << std::endl;
            }
          }
          offset_0 += bitwidth_bytes;
        }
        offset_0 = offset_1;
      }
      offset_1 = offset_2;
      offset_0 = offset_1;
    }
    offset_2 = offset_3;
    offset_1 = offset_2;
    offset_0 = offset_1;
  }
  file.close();
  int file_status;
  file_status =
    common::file_utils::saveCharArrayToFormattedTextFile("../../cocotb/test_store/memory/sram.txt", sram, sram_size, sram_bytes, true);
  // if (update) {
  //   file_status = common::file_utils::saveCharArrayToFormattedTextFile(
  //     "../../cocotb/test_store/memory/dummy_ddr.txt", dummy_ddr, dummy_ddr_size, bitwidth_bytes, true);
  // }

  return 1;
}

}  // namespace store_master