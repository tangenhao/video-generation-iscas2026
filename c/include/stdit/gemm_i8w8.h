#pragma once

#include <cassert>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <vector>

#include "addr_for_stdit.h"
#include "common/cfg.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include "common/read_cfg.h"

#include "common/type_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include <string>

namespace stdit {
namespace gemm {

using namespace common;

template<bool DEBUG_ = false,
         int  TYPE_A_ = kInt8,
         int  TYPE_B_ = kInt8,
         int  TYPE_ACCUMULATOR_ = kInt32,
         int  TYPE_OUTPUT_ = kInt32>
struct insn_gen {
  static constexpr int  DEBUG            = DEBUG_;
  static constexpr int  TYPE_A           = TYPE_A_;
  static constexpr int  TYPE_B           = TYPE_B_;
  static constexpr int  TYPE_ACCUMULATOR = TYPE_ACCUMULATOR_;
  static constexpr int  TYPE_OUTPUT      = TYPE_OUTPUT_;

  int k_group_size;
  int n_group_size;

  int bytes_ifmap;
  int bytes_weight;
  int bytes_scale;
  int bytes_bias;
  int bytes_ofmap;


  static void require_arg(bool condition, const std::string& message)
  {
    if (!condition) {
      std::cerr << "[gemm_i8w8] invalid argument: " << message << std::endl;
      assert(condition);
      std::abort();
    }
  }

  struct Arguments {
    int      m;
    int      n;
    int      k;
    int      tile_m;
    int      n_group_size;
    int      k_group_size;
    int      block_n_group;
    int      block_k_group;
    uint64_t ifmap_base_addr;
    uint64_t weight_base_addr;
    uint64_t ofmap_base_addr;
    uint64_t opcode_ddr_base_addr ;
    uint64_t bias_base_addr ;
    uint64_t scale_base_addr ;
    std::vector<std::string>  opcode;
  };

  insn_gen()
  {
    k_group_size = 0;
    n_group_size = 0;
    bytes_ifmap  = 1;
    bytes_weight = 1;
    bytes_ofmap  = 2;
    bytes_scale  = 2;
    bytes_bias   = 2;
  }

  std::pair<std::vector<insn::instruction>, std::vector<uint64_t>> operator()(const Arguments& args)
  {
    std::vector<insn::instruction> instruction_series;
    std::vector<uint64_t> vcucode_series;

    k_group_size = args.k_group_size;
    n_group_size = args.n_group_size;

    // int m_iterations = ceil((double)args.m / (double)args.tile_m);
    int m_iterations = args.m ;
    int n_group      = ceil((double)args.n / (double)n_group_size);
    int k_group      = ceil((double)args.k / (double)(k_group_size));

    if (DEBUG) {
      std::cout << "m_iterations: " << m_iterations << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
    }

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                pea insn gen                                              */
  /* -------------------------------------------------------------------------------------------------------- */

    int ifmap_ddr_offset, weight_ddr_offset, ofmap_ddr_offset;
    int bias_ddr_offset = 0, scale_ddr_offset, vecmul_ddr_offset, vecadd_ddr_offset;
    int n_iterations = n_group;
    int k_iterations = k_group / args.block_k_group + 1;
    int k_group_burst_size=args.block_k_group;
    require_arg(args.block_k_group > 0,
                "block_k_group must be > 0.");
    require_arg(args.block_k_group >= 8 && args.block_k_group % 2 == 0,
                "block_k_group must be >= 8 and even for 36x36 i8w8 weight DMA alignment. Current block_k_group=" +
                  std::to_string(args.block_k_group) + ".");
    require_arg(k_group / args.block_k_group >= 1,
                "k_group / block_k_group must be >= 1 because bias and dequant scale need at least one k block. Current k_group=" +
                  std::to_string(k_group) + ", block_k_group=" + std::to_string(args.block_k_group) + ".");
    require_arg(k_group % args.block_k_group == 0,
                "k_group must be divisible by block_k_group. Current k_group=" + std::to_string(k_group) +
                  ", block_k_group=" + std::to_string(args.block_k_group) + ".");
    require_arg(n_group_size % 4 == 0,
                "n_group_size must be divisible by 4 for 4-channel weight DMA. Current n_group_size=" +
                  std::to_string(n_group_size) + ".");
    int weight_k_blocks = k_group / args.block_k_group;
    int64_t weight_block_bytes = bytes_weight * k_group_size * n_group_size * args.block_k_group;
    bool weight_8_channel_transfer = 0;
    int m_ifmap_iter = 0;
    int m_scale_iter = 0;
    int ofmap_n_iter, ofmap_m_iter;

    int vecmul_sram_depth  = 128;
    int vecadd_sram_depth  = 128;
    int dequant_sram_depth = 128;
    int vcuofmap_sram_depth = 64;
    int qact_sram_depth     = 128;

    int block_store_group = args.block_n_group;
    require_arg(block_store_group >= 4,
                "block_n_group must be >= 4 for store. Current block_n_group=" +
                  std::to_string(block_store_group) + ".");
    require_arg(n_group % block_store_group == 0,
                "n_group must be divisible by block_n_group so each store covers a full n block. Current n_group=" +
                  std::to_string(n_group) + ", block_n_group=" + std::to_string(block_store_group) + ".");
    require_arg((int64_t(block_store_group) * n_group_size * bytes_ofmap) % 32 == 0,
                "block_n_group * n_group_size * bytes_ofmap must be 32B aligned for integer seq_0_burst. Current block_n_group=" +
                  std::to_string(block_store_group) + ", n_group_size=" + std::to_string(n_group_size) +
                  ", bytes_ofmap=" + std::to_string(bytes_ofmap) + ".");
    insn::sync_word_list sync_words;

    auto append_sync_word = [&](uint32_t word, int k_iter, int n_iter, int m_iter, const char* tag) {
      sync_words.append(word);
      if (DEBUG) {
        size_t index = sync_words.size() - 1;
        auto flags = std::cout.flags();
        auto fill  = std::cout.fill();
        std::cout << std::dec
                  << "[DEBUG][sync_words] index=" << index
                  << " sync_insn_index=" << (index / 3)
                  << " slot=sync_word_" << (index % 3)
                  << " k_iter=" << k_iter
                  << " n_iter=" << n_iter
                  << " m_iter=" << m_iter
                  << " tag=" << tag
                  << " word=0x" << std::hex << std::setw(8) << std::setfill('0') << word
                  << std::dec << std::endl;
        std::cout.flags(flags);
        std::cout.fill(fill);
      }
    };


    for (int m_iter = 0; m_iter < m_iterations; ++m_iter) {
      for (int n_iter = 0; n_iter < n_iterations; ++n_iter) {
        for (int k_iter = 0; k_iter < k_iterations; ++k_iter) {

          if (n_iter == 0 && m_iter == 0)
          {
            k_iterations = k_group / args.block_k_group + 1; //inital: 多load一次，为了pingpong
          }
          else
          {
            k_iterations = k_group / args.block_k_group;
          }

          int weight_load_block_idx = (n_iter == 0 && m_iter == 0)
                                        ? k_iter
                                        : n_iter * weight_k_blocks + k_iter + 1;
          weight_load_block_idx %= n_group * weight_k_blocks;
          weight_ddr_offset = int64_t(weight_load_block_idx * weight_block_bytes);

          // else if (n_iter == n_iterations - 1 && m_iter != m_iterations - 1)
          // {
          //   k_iterations = k_group / args.block_k_group;
          //   k_group_burst_size = args.block_k_group;
          //   weight_8_channel_transfer = 0;
          // }
          // else
          // {
          //   k_iterations = k_group / args.block_k_group / 2;
          //   k_group_burst_size = args.block_k_group * 2;
          //   weight_8_channel_transfer = 1;
          // }

          //load ifmap
          if (k_iter == 0 && n_iter == 0 && m_iter == 0)
          {
            int64_t ifmap_sram_offset = (int64_t(m_ifmap_iter) * k_group) % qact_sram_depth;
            instruction_series.push_back(LoadIfmap(args.ifmap_base_addr,
                                                   k_group,
                                                   MASTER_QACT_ADDR + ifmap_sram_offset));
            m_ifmap_iter = m_ifmap_iter + 1;
          }
          else if (k_iter == 0 && n_iter == n_iterations-1 && m_iter != m_iterations-1 )
          {
            ifmap_ddr_offset = int64_t(m_ifmap_iter) * bytes_ifmap * args.k;
            int64_t ifmap_sram_offset = (int64_t(m_ifmap_iter) * k_group) % qact_sram_depth;
            m_ifmap_iter = m_ifmap_iter + 1;
            instruction_series.push_back(LoadIfmap(args.ifmap_base_addr + ifmap_ddr_offset,
                                                   k_group,
                                                   MASTER_QACT_ADDR + ifmap_sram_offset));
          }
          else
          {
            ifmap_ddr_offset = 0;
          }

          //load weight
          if (!(k_iter == k_iterations - 1 && n_iter == n_iterations - 1 && m_iter == m_iterations - 1))
          {
            auto load_weight_insns =
              LoadWeight(args.weight_base_addr + weight_ddr_offset, k_group_burst_size);
            instruction_series.insert(instruction_series.end(), load_weight_insns.begin(), load_weight_insns.end());
          }

          //load scale
          if (k_iter == 1 && n_iter == 0 && m_iter == 0 )
          {
            int64_t scale_sram_offset = (int64_t(m_scale_iter) * n_group) % vecmul_sram_depth;
            m_scale_iter = m_scale_iter + 1;
            instruction_series.push_back(LoadScale(args.scale_base_addr,
                                                   n_group,
                                                   MASTER_VCUPARA_ADDR + scale_sram_offset*2));
          }
          else if (k_iter == 1 && n_iter == n_iterations-1 && m_iter != m_iterations-1 )
          {
            scale_ddr_offset = int64_t(m_scale_iter) * bytes_scale * args.n;
            int64_t scale_sram_offset = (int64_t(m_scale_iter) * n_group) % vecmul_sram_depth;
            m_scale_iter = m_scale_iter + 1;
            instruction_series.push_back(LoadScale(args.scale_base_addr + scale_ddr_offset,
                                                   n_group,
                                                   MASTER_VCUPARA_ADDR + scale_sram_offset*2));
          }
          else
          {
            scale_ddr_offset = 0;
          }

          //load bias
          if (k_iter == 1 && n_iter == 0 && m_iter == 0)
          {
            instruction_series.push_back(LoadBias(args.bias_base_addr + bias_ddr_offset, n_group, 1));
          }

          //pea insn
          int gemm_last_k_groups = (k_iter == k_iterations - 1) ? 1 : 0;
          int gemm_acc_clear =
            ((n_iter == 0 && m_iter == 0) ? (k_iter == 1) : (k_iter == 0)) ? 1 : 0;

          if (!(k_iter == 0 && n_iter == 0 && m_iter == 0))
          {
            instruction_series.push_back(insn::gemm_execute(TYPE_A,
                                                            TYPE_B,
                                                            TYPE_ACCUMULATOR - 5,
                                                            TYPE_OUTPUT - 5,
                                                            k_group_burst_size,  //ifmap_burst_len, weight_burst_len
                                                            n_group,             //real_n_groups
                                                            k_group,             //real_k_groups
                                                            0,                   //ifmap_highaddr,
                                                            0,                   //weight_highaddr
                                                            gemm_acc_clear,      //gemm_acc_clear
                                                            gemm_last_k_groups,  //gemm_last_k_groups
                                                            0,
                                                            0));
          }

          //vcu insn

          vcucode_series = vcu::asm_vcu_op(args.opcode);  // 生成opcode
          auto   num_vcucodes      = vcucode_series.size();
          size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
          size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
          vcucode_series.resize(vcucode_ddr_lines * 8, 0);

          if (k_iter == 1 && n_iter == 0 && m_iter == 0)
          {

            if (DEBUG) {
              std::cout << "num_vcucodes: " << num_vcucodes << std::endl;
              std::cout << "vcucode_bytes: " << vcucode_bytes << std::endl;
              std::cout << "vcucode_ddr_lines: " << vcucode_ddr_lines << std::endl;
            }

            instruction_series.push_back(insn::load_iteration_2<0>(args.opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0,  MASTER_VCUCODE_ADDR, 0));
          }

          int special_last_vcu_store_iter = (k_iter == k_iterations - 1 && n_iter == n_iterations - 1 && m_iter == m_iterations - 1) ? 1 : 0; //最后一次iter后，还需要两个k_iter用于vcu和store
          int vcu_ofmap_n_iter = (special_last_vcu_store_iter) ? n_group-1 : ((n_iter > 0) ? n_iter - 1 : n_group-1);
          int vcu_ofmap_m_iter = (special_last_vcu_store_iter) ? m_iter : ((m_iter > 0 && n_iter == 0) ? m_iter - 1 : m_iter);

          using vcu_t = vcu::VcuExecute;
          vcu_t vcu_op;
          vcu_t::Arguments vcu_args = {
            vcu_psum_dtype.at(kInt32),                // psum_data_type: 3 for int32(dequant_Sram); 0 for fp16(ifmap_vcu_sram)
            0,                                        // vcu_resadd_dtype.at(kHalf)
            vcu_out_dtype.at(kHalf),                  // data_out_type: 3 for int32
            VcuOutSram::OFMAP,                        // data_out_ram
            num_vcucodes,                             // opcode_number: pair-fuse trigger requires 2
            0,                                        // opcode_addr
            0,                                        // psum_in_addr
            (uint64_t)((vcu_ofmap_m_iter*n_group+vcu_ofmap_n_iter)%vecmul_sram_depth),                                        // para_in_addr
            (uint64_t)(vcu_ofmap_n_iter%vecadd_sram_depth),                                        // resadd_in_addr
            (uint64_t)(vcu_ofmap_n_iter%vcuofmap_sram_depth),                                        // ram_out_addr
            (uint64_t)1 - 1,                          // num_data
            0,                                        // oc_group
            0,                                        // para_func
            0,                                        // psum_sram_valid
            1,                                        // resadd_sram_valid
            1,                                        // para_sram_valid
            0,                                        // psum_addr_hop
            1,                                        // acc_clear
            1,                                        // stream_en
            1,                                        // ifmap_sram_valid
            (uint64_t)((vcu_ofmap_m_iter*n_group+vcu_ofmap_n_iter)%dequant_sram_depth)                                         // ifmap_in_addr
          };

          if (k_iter == 0 && !(n_iter == 0 && m_iter == 0))
          {
            auto vcu_insns = vcu_op(vcu_args);
            instruction_series.insert(instruction_series.end(), vcu_insns.begin(), vcu_insns.end());
          }

          if ( special_last_vcu_store_iter)
          {
            auto vcu_insns = vcu_op(vcu_args);
            instruction_series.insert(instruction_series.end(), vcu_insns.begin(), vcu_insns.end());
          }

          //store insn
          bool store_block_ready = ((vcu_ofmap_n_iter + 1) % block_store_group) == 0;
          int store_block_n_iter = vcu_ofmap_n_iter + 1 - block_store_group;
          int64_t store_sram_bytes = int64_t(store_block_n_iter) * n_group_size * bytes_ofmap;
          require_arg(!store_block_ready || store_sram_bytes % 32 == 0,
                      "store SRAM offset must be 32B aligned. Choose block_n_group so block_n_group * n_group_size * bytes_ofmap is divisible by 32.");
          int64_t store_sram_offset = store_sram_bytes / 32;
          bool regular_store_enabled =
            (k_iter == 1 && !(n_iter == 0 && m_iter == 0) && !special_last_vcu_store_iter && store_block_ready);
          bool special_store_enabled = special_last_vcu_store_iter && store_block_ready;

          if (regular_store_enabled)
          {
            ofmap_ddr_offset = int64_t(bytes_ofmap * n_group_size * store_block_n_iter + bytes_ofmap * args.n * vcu_ofmap_m_iter);
            instruction_series.push_back(Store(args.ofmap_base_addr + ofmap_ddr_offset,
                                               block_store_group,
                                               MASTER_OFMAP_ADDR + (store_sram_offset%vcuofmap_sram_depth),
                                               0));
          }

          if (special_store_enabled)
          {
            ofmap_ddr_offset = int64_t(bytes_ofmap * n_group_size * store_block_n_iter + bytes_ofmap * args.n * vcu_ofmap_m_iter);
            instruction_series.push_back(Store(args.ofmap_base_addr + ofmap_ddr_offset,
                                               block_store_group,
                                               MASTER_OFMAP_ADDR + (store_sram_offset%vcuofmap_sram_depth),
                                               special_last_vcu_store_iter));
          }

          //同步字
          if (k_iter == 0 && n_iter == 0 && m_iter == 0)
          {
            append_sync_word(insn::sync_word().load(0).load(1).load(3).load(5).load(7),
                             k_iter,
                             n_iter,
                             m_iter,
                             "initial_load"); //load ifmap and weight, load0 for ifmap, and load_odd(1,3,5,7) for weight
          }
          else if (k_iter == 0 && !(n_iter == 0 && m_iter == 0)) //vcu enable
          {
            // if (weight_8_channel_transfer) {
            //   append_sync_word(insn::sync_word().load(0).load(1).load(2).load(3).load(4).load(5).load(6).load(7).pea(0).vcu(0),
            //                    k_iter,
            //                    n_iter,
            //                    m_iter,
            //                    "load_pea_vcu_all_weight");
            // }
            if (n_iter == n_iterations-1 && m_iter != m_iterations-1 ) {
              append_sync_word(insn::sync_word().load(0).load(1).load(3).load(5).load(7).pea(0).vcu(0),
                               k_iter,
                               n_iter,
                               m_iter,
                               "load0+load_odd_pea_vcu");
            }
            else {
              append_sync_word(insn::sync_word().load(1).load(3).load(5).load(7).pea(0).vcu(0),
                               k_iter,
                               n_iter,
                               m_iter,
                               "load_odd_pea_vcu");
            }
          }
          else if (k_iter == 1 && !(n_iter == 0 && m_iter == 0)) //store enable
          {
            // if (weight_8_channel_transfer) {
            //   append_sync_word(insn::sync_word().load(0).load(1).load(2).load(3).load(4).load(5).load(6).load(7).pea(0).vcu(0).store(0),
            //                    k_iter,
            //                    n_iter,
            //                    m_iter,
            //                    "load_pea_vcu_store_all_weight");
            // }
            if (n_iter == n_iterations-1 && m_iter != m_iterations-1 ) {
              auto sync_word = insn::sync_word().load(0).load(1).load(3).load(5).load(7).pea(0);
              if (regular_store_enabled) {
                sync_word.store(0);
              }
              append_sync_word(sync_word,
                               k_iter,
                               n_iter,
                               m_iter,
                               regular_store_enabled ? "load0+load_odd_pea_store" : "load0+load_odd_pea");
            }
            else if (n_iter == n_iterations-1 && m_iter == m_iterations-1 && k_iter == k_iterations-1) {
              append_sync_word(insn::sync_word().pea(0),
                               k_iter,
                               n_iter,
                               m_iter,
                               "last_iter_only_pea");
            }
            else {
              auto sync_word = insn::sync_word().load(1).load(3).load(5).load(7).pea(0);
              if (regular_store_enabled) {
                sync_word.store(0);
              }
              append_sync_word(sync_word,
                               k_iter,
                               n_iter,
                               m_iter,
                               regular_store_enabled ? "load_odd_pea_store" : "load_odd_pea");
            }
          }
          else if ((m_iter == 0 && n_iter == 0 && k_iter != 0) ) //pea+load_0+load_odd(weight)
          {
            append_sync_word(insn::sync_word().load(0).load(1).load(3).load(5).load(7).pea(0),
                             k_iter,
                             n_iter,
                             m_iter,
                             "load_0+load_odd(weight)+pea");

          }
          else if (special_last_vcu_store_iter) //last iter, only pea
          {
            append_sync_word(insn::sync_word().pea(0),
                               k_iter,
                               n_iter,
                               m_iter,
                               "last_pea");
          }
          else //pea+load_odd(weight)
          {
            if (weight_8_channel_transfer) {
              append_sync_word(insn::sync_word().load(1).load(2).load(3).load(4).load(5).load(6).load(7).pea(0),
                               k_iter,
                               n_iter,
                               m_iter,
                               "load_pea_all_weight");
            }
            else {
              append_sync_word(insn::sync_word().load(1).load(3).load(5).load(7).pea(0),
                               k_iter,
                               n_iter,
                               m_iter,
                               "load_odd_pea");
            }
          }

          if (special_last_vcu_store_iter) //vcu and store enable
          {
            append_sync_word(insn::sync_word().vcu(0), k_iter, n_iter, m_iter, "last_vcu");
            if (special_store_enabled) {
              append_sync_word(insn::sync_word().store(0), k_iter, n_iter, m_iter, "last_store");
            }
          }


        }
      }
    }
    common::insn::pad_manual_sync_word(instruction_series, sync_words);
    return std::make_pair(instruction_series, vcucode_series);
  }

  private:
  insn::instruction LoadIfmap(int64_t ddr_base_addr, int64_t block_k_group, int64_t sram_addr)
  {
    auto seq_1_offset = split_exp_fra(block_k_group * k_group_size * bytes_ifmap);
    int64_t seq_0_burst = block_k_group * bytes_ifmap * k_group_size / 32 - 1;

    if (DEBUG) {
      std::cout << "======== Load Ifmap ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "sram_addr: " << sram_addr << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << seq_0_burst << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_k_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    return insn::load_iteration_2<0>(ddr_base_addr, seq_0_burst, seq_1_offset.first, seq_1_offset.second, 1 - 1, sram_addr, 0);
  }

  std::vector<insn::instruction> LoadWeight(int64_t ddr_base_addr, int block_k_group)
  {
    constexpr int weight_dma_channels = 4;

    require_arg(n_group_size % weight_dma_channels == 0,
                "n_group_size must be divisible by 4 for 4-channel weight DMA. Current n_group_size=" +
                  std::to_string(n_group_size) + ".");
    int n_group_size_per_channel = n_group_size / weight_dma_channels;
    int64_t channel_bytes        = int64_t(block_k_group) * bytes_weight * k_group_size * n_group_size_per_channel;
    require_arg(channel_bytes >= 32 && channel_bytes % 32 == 0,
                "per-channel weight transfer bytes must be >= 32 and 32B aligned. Current channel_bytes=" +
                  std::to_string(channel_bytes) + "; adjust block_k_group, k_group_size, or n_group_size.");

    auto seq_1_offset = split_exp_fra(channel_bytes);
    int64_t seq_0_burst = channel_bytes / 32 - 1;

    if (DEBUG) {
      std::cout << "======== Load Weight ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << seq_0_burst << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << 0 << std::endl;
      std::cout << "ddr_channel_offset: " << channel_bytes << std::endl;
      std::cout << "==========================" << std::endl;
    }

    std::vector<insn::instruction> load_insns;

    load_insns.push_back(insn::load_iteration_2<1>(ddr_base_addr + channel_bytes * 0, seq_0_burst, seq_1_offset.first, seq_1_offset.second, 0, MASTER_WEIGHT_ADDR, 0));
    load_insns.push_back(insn::load_iteration_2<3>(ddr_base_addr + channel_bytes * 1, seq_0_burst, seq_1_offset.first, seq_1_offset.second, 0, MASTER_WEIGHT_ADDR, 0));
    load_insns.push_back(insn::load_iteration_2<5>(ddr_base_addr + channel_bytes * 2, seq_0_burst, seq_1_offset.first, seq_1_offset.second, 0, MASTER_WEIGHT_ADDR, 0));
    load_insns.push_back(insn::load_iteration_2<7>(ddr_base_addr + channel_bytes * 3, seq_0_burst, seq_1_offset.first, seq_1_offset.second, 0, MASTER_WEIGHT_ADDR, 0));


    return load_insns;
  }

  insn::instruction LoadScale(int64_t ddr_base_addr, int64_t block_n_group, int64_t sram_addr)
  {
    auto seq_1_offset = split_exp_fra(block_n_group*n_group_size);

    int64_t seq_0_burst = block_n_group * n_group_size * bytes_scale  / 32 - 1;

    if (DEBUG) {
      std::cout << "======== Load Weight Scale ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "sram_addr: " << sram_addr << std::endl;
      std::cout << "block_n_group: " << block_n_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << seq_0_burst << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_n_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    auto load_insn =
      insn::load_iteration_2<0>(ddr_base_addr, seq_0_burst, seq_1_offset.first, seq_1_offset.second, 1 - 1, sram_addr, 0);

    return load_insn;
  }

  insn::instruction LoadBias(int64_t ddr_base_addr, int64_t block_n_group, int64_t insn_num)
  {
    auto seq_1_offset = split_exp_fra(block_n_group * n_group_size);

    int64_t seq_0_burst = block_n_group * n_group_size * bytes_bias  / 32 - 1;

    if (DEBUG) {
      std::cout << "======== Load Bias ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "block_n_group: " << block_n_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << seq_0_burst << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_n_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    return insn::load_iteration_2<0>(ddr_base_addr, seq_0_burst, seq_1_offset.first, seq_1_offset.second, 0, MASTER_VCURES_ADDR, 0, insn_num);
  }

  insn::instruction Store(int64_t ddr_base_addr, int64_t block_n_group, int64_t sram_addr, int64_t all_done)
  {
    require_arg(block_n_group >= 4,
                "store block_n_group must be >= 4. Current block_n_group=" + std::to_string(block_n_group) + ".");
    require_arg((int64_t(block_n_group) * n_group_size * bytes_ofmap) % 32 == 0,
                "store block_n_group * n_group_size * bytes_ofmap must be 32B aligned for integer seq_0_burst. Current block_n_group=" +
                  std::to_string(block_n_group) + ", n_group_size=" + std::to_string(n_group_size) +
                  ", bytes_ofmap=" + std::to_string(bytes_ofmap) + ".");
    auto seq_1_offset = split_exp_fra(bytes_ofmap * n_group_size * block_n_group);
    int64_t seq_0_burst = block_n_group * n_group_size * bytes_ofmap  / 32 - 1;

    if (DEBUG) {
      std::cout << "======== Store ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "block_n_group: " << block_n_group << std::endl;
      std::cout << "sram_addr: " << sram_addr << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << seq_0_burst << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_n_group << std::endl;
    }

    return insn::store_iteration_2<0>(
      ddr_base_addr, seq_0_burst, seq_1_offset.first, seq_1_offset.second, 1 - 1, sram_addr, all_done);
  }

  std::pair<int, int> split_exp_fra(int64_t x)
  {
    if (x > 8355840) {
      std::throw_with_nested(std::runtime_error("x is too large"));
    }
    int max_exp = (1 << 4) - 1;
    int max_fra = (1 << 8) - 1;
    int exp     = 0;
    while (x > max_fra) {
      x /= 2;
      exp++;
    }
    return {exp, x};
  }
};

}
}
