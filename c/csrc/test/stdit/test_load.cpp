#include "addr_for_stdit.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "stdit/gemm_i8w8.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

std::pair<int, int> split_exp_fra(int64_t x)
{
  if (x > 8355840) {
    throw std::runtime_error("x is too large");
  }
  int max_fra = (1 << 8) - 1;
  int exp     = 0;
  while (x > max_fra) {
    x /= 2;
    exp++;
  }
  return {exp, static_cast<int>(x)};
}

void print_ifmap_qact_hex(const int8_t* ifmap, int m, int k_group, int k_group_size, int bytes_ifmap)
{
  int group_bytes = k_group_size * bytes_ifmap;

  std::cout << "ifmap shape: {" << m << ", " << k_group << ", " << k_group_size << "}" << std::endl;
  std::cout << "qact_wvalid reference: one line = k_group_size * bytes_ifmap = " << group_bytes
            << " bytes, shown as qact_wdata[" << (group_bytes * 8 - 1) << ":0] hex" << std::endl;

  for (int m_idx = 0; m_idx < m; ++m_idx) {
    for (int kg_idx = 0; kg_idx < k_group; ++kg_idx) {
      int64_t base_offset = (int64_t(m_idx) * k_group + kg_idx) * group_bytes;
      int64_t qact_addr   = int64_t(m_idx) * k_group + kg_idx;

      std::cout << "m=" << std::setw(2) << m_idx << " k_group=" << std::setw(2) << kg_idx << " qact_waddr=0x"
                << std::hex << std::setw(3) << std::setfill('0') << qact_addr << " qact_wdata=0x";

      for (int byte_idx = group_bytes - 1; byte_idx >= 0; --byte_idx) {
        uint8_t value = static_cast<uint8_t>(ifmap[base_offset + byte_idx]);
        std::cout << std::setw(2) << static_cast<int>(value);
      }

      std::cout << std::dec << std::setfill(' ') << std::endl;
    }
  }
}

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;

  int      m                    = 2;
  int      n                    = 144;
  int      k                    = 576;
  int      n_group_size         = 36;
  int      k_group_size         = 36;
  int      n_group              = n / n_group_size;  //store时，n_group_size=36，需要seq_0_burst为整数
  int      k_group              = k / k_group_size;  //k_group/block_k_group需要>=1，因为有bias和dequant（scale）需要load
  int      block_n_group        = 4;
  int      block_k_group        = 8; //block_k_group需要>=8且为偶数
  int      tile_m               = 1;

  int      bytes_ifmap          = 1; // int8_t

  uint64_t ifmap_base_addr      = QACT_ADDR;
  uint64_t weight_base_addr     = WEIGHT_ADDR;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  std::vector<insn::instruction> insn_series;
  insn::sync_word_list sync_words;

  int row_load_bytes = bytes_ifmap * block_k_group * k_group_size;
  int row_stride_bytes = bytes_ifmap * k;  // 对应字节数原始 ifmap 一整行在 DDR 中的跨度;
  
  auto seq_1_offset = split_exp_fra(row_stride_bytes);

  for (int k_iter = 0; k_iter < (k_group/block_k_group); ++k_iter)
  {
    int head_offset = k_iter * block_k_group * k_group_size * bytes_ifmap;

    insn_series.push_back(insn::load_iteration_2<0>(ifmap_base_addr + head_offset,
                                                  row_load_bytes / 32 - 1,
                                                  seq_1_offset.first,
                                                  seq_1_offset.second,
                                                  m - 1,
                                                  MASTER_QACT_ADDR,
                                                  0));

    sync_words.append(insn::sync_word().load(0));
  }
  
//   common::insn::pad_serial_sync_word(insn_series);
  common::insn::pad_manual_sync_word(insn_series, sync_words);

  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);


  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 data gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  auto ifmap  = randn<int8_t>({m, k_group, k_group_size}, kInt8, -128.0f, 127.0f, 0);

  print_ifmap_qact_hex(reinterpret_cast<int8_t*>(ifmap.data_ptr()), m, k_group, k_group_size, bytes_ifmap);

  common::file_utils::saveCharArrayToFormattedTextFile(
    qact_file.c_str(), reinterpret_cast<char*>(ifmap.data_ptr()), ifmap.numel() * sizeof(int8_t), 32, true);

  write_regs(reg_cfg_file.c_str(),
             0,
             insn_series.size() * sizeof(common::insn::instruction) / 32,
             32,
             0,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             PSUM_LOAD_1024,
             PSUM_STORE_1024,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}
