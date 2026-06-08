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
#include "compute_model/common/subbyte.h"

namespace vcu {
using namespace compute_model::common;
using namespace common;

template<int TYPE_IN, int TYPE_OUT, bool DEBUG_>
struct AvgpoolOp {

  static constexpr bool DEBUG = DEBUG_;

  struct Arguments {
    int      ifmap_h;
    int      ifmap_w;
    int      weight_h;
    int      weight_w;
    int      channels;
    int      stride_h;
    int      stride_w;
    int      pad_h;
    int      pad_w;
    int      dilation_h;
    int      dilation_w;
    int      ifmap_block_h;
    int      ifmap_block_w;
    int      weight_block_h;
    int      weight_block_w;
    int      block_channel_group;
    int      psum_read_highaddr;
    int      psum_write_highaddr;
    uint64_t psum_base_addr;
    uint64_t ofmap_base_addr;
  };

  int   ofmap_h;
  int   ofmap_w;
  int   oc_group;
  int   oc_group_size;
  float bytes_psum;
  float bytes_ofmap;

  AvgpoolOp()
  {
    if (TYPE_IN == kInt4 || TYPE_IN == kInt8 || TYPE_IN == kInt16) {
      std::runtime_error("Avgpool2d: TYPE_IN should be float16 or float32 or bfloat16");
    }

    if (TYPE_OUT == kInt4 || TYPE_OUT == kInt8 || TYPE_OUT == kInt16) {
      std::runtime_error("Avgpool2d: TYPE_OUT should be float16 or float32 or bfloat16");
    }

    oc_group_size = 32;

    if (TYPE_IN == kFloat32) {
      bytes_psum = 4;
    }
    else {
      bytes_psum = 2;
    }

    if (TYPE_OUT == kFloat32) {
      bytes_ofmap = 4;
    }
    else {
      bytes_ofmap = 2;
    }
  }

  std::vector<insn::instruction> operator()(Arguments args)
  {

    ofmap_h = floor((args.ifmap_h + 2 * args.pad_h - args.dilation_h * (args.weight_h - 1) - 1) / args.stride_h + 1);
    ofmap_w = floor((args.ifmap_w + 2 * args.pad_w - args.dilation_w * (args.weight_w - 1) - 1) / args.stride_w + 1);

    std::vector<insn::instruction> instruction_series;
    int                            ofmap_block_h =
      floor((double)(args.ifmap_block_h + 2 * args.pad_h - args.dilation_h * (args.weight_h - 1) - 1) / (double)args.stride_h + 1);
    int ofmap_block_w =
      floor((double)(args.ifmap_block_w + 2 * args.pad_w - args.dilation_w * (args.weight_w - 1) - 1) / (double)args.stride_w + 1);
    int h_iterations  = ceil((double)ofmap_h / (double)ofmap_block_h);
    int w_iterations  = ceil((double)ofmap_w / (double)ofmap_block_w);
    int kh_iterations = ceil((double)args.weight_h / (double)args.weight_block_h);
    int kw_iterations = ceil((double)args.weight_w / (double)args.weight_block_w);
    int oc_group      = ceil((double)args.channels / (double)oc_group_size);
    int oc_iterations = ceil((double)oc_group / (double)args.block_channel_group);
    if (DEBUG) {
      std::cout << "ofmap_block_h: " << ofmap_block_h << std::endl;
      std::cout << "ofmap_block_w: " << ofmap_block_w << std::endl;
      std::cout << "ofmap_h: " << ofmap_h << std::endl;
      std::cout << "ofmap_w: " << ofmap_w << std::endl;
      std::cout << "h_iterations: " << h_iterations << std::endl;
      std::cout << "w_iterations: " << w_iterations << std::endl;
      std::cout << "kh_iterations: " << kh_iterations << std::endl;
      std::cout << "kw_iterations: " << kw_iterations << std::endl;
      std::cout << "oc_group: " << oc_group << std::endl;
      std::cout << "oc_iterations: " << oc_iterations << std::endl;
    }

    int64_t i_h_start, i_w_start, k_h_start, k_w_start, o_h_start, o_w_start;
    int64_t i_h, i_w, k_h, k_w, i_ic, k_oc;
    int64_t pad_top, pad_left;
    int64_t ifmap_ddr_offset, weight_ddr_offset, ofmap_ddr_offset;

    for (int oc_iter = 0; oc_iter < oc_iterations; ++oc_iter) {
      for (int h_iter = 0; h_iter < h_iterations; ++h_iter) {
        for (int w_iter = 0; w_iter < w_iterations; ++w_iter) {
          // ofmap horizontal and vertical start index
          o_w_start = w_iter * ofmap_block_w;
          o_h_start = h_iter * ofmap_block_h;
          k_oc      = std::min(oc_group - (oc_iter * args.block_channel_group), args.block_channel_group);
          for (int kh_iter = 0; kh_iter < kh_iterations; ++kh_iter) {
            for (int kw_iter = 0; kw_iter < kw_iterations; ++kw_iter) {
              // real padding
              pad_left = w_iter == 0 ? std::max(args.pad_w - kw_iter * args.weight_block_w, 0) : 0;
              pad_top  = h_iter == 0 ? std::max(args.pad_h - kh_iter * args.weight_block_h, 0) : 0;

              // ifmap horizontal and vertical start index
              i_w_start = std::max(o_w_start * args.stride_w + kw_iter - args.pad_w, 0l);
              i_h_start = std::max(o_h_start * args.stride_h + kh_iter - args.pad_h, 0l);

              // real ifmap horizontal and vertical length
              i_h = std::min((ofmap_block_h - 1) * args.stride_h + args.weight_block_h - pad_top, args.ifmap_h - i_h_start);
              i_w = std::min((ofmap_block_w - 1) * args.stride_w + args.weight_block_w - pad_left, args.ifmap_w - i_w_start);

              // real channels
              i_ic = std::min(oc_group - (oc_iter * args.block_channel_group), args.block_channel_group);

              // ddr offset calculation
              ifmap_ddr_offset =
                int64_t(bytes_psum * oc_group_size
                        * (args.ifmap_h * args.ifmap_w * (oc_iter * args.block_channel_group) + i_h_start * args.ifmap_w + i_w_start));

              ofmap_ddr_offset = int64_t(bytes_ofmap * oc_group_size
                                         * (ofmap_h * ofmap_w * (oc_iter * args.block_channel_group) + o_h_start * ofmap_w + o_w_start));

              // load psum
              instruction_series.push_back(LoadPsum(
                args.psum_base_addr + ifmap_ddr_offset, oc_group, args.ifmap_h, args.ifmap_w, i_ic, i_h, i_w, args.psum_read_highaddr));

              // Avgpool execute
              instruction_series.push_back(insn::avgpool(TYPE_IN == kFloat32  ? 2 :
                                                         TYPE_IN == kBfloat16 ? 1 :
                                                                                0,
                                                         TYPE_OUT == kFloat32  ? 2 :
                                                         TYPE_OUT == kBfloat16 ? 1 :
                                                                                 0,
                                                         i_w - 1,
                                                         i_h - 1,
                                                         i_ic - 1,
                                                         args.weight_w - 1,
                                                         args.weight_h - 1,
                                                         args.psum_read_highaddr,
                                                         args.psum_write_highaddr,
                                                         ofmap_block_w - 1,
                                                         ofmap_block_h - 1,
                                                         args.stride_w,
                                                         args.stride_h,
                                                         args.dilation_w,
                                                         args.dilation_h,
                                                         pad_left,
                                                         pad_top));
            }
          }
          instruction_series.push_back(Store(args.ofmap_base_addr + ofmap_ddr_offset,
                                             oc_group,
                                             ofmap_h,
                                             ofmap_w,
                                             args.block_channel_group,
                                             ofmap_block_h,
                                             ofmap_block_w,
                                             h_iter == h_iterations - 1 && w_iter == w_iterations - 1 && oc_iter == oc_iterations - 1,
                                             args.psum_write_highaddr));
        }
      }
    }

    return instruction_series;
  }

  private:
  insn::instruction LoadPsum(int64_t  ddr_base_addr,
                             int64_t  oc_group,
                             int64_t  h,
                             int64_t  w,
                             int64_t  block_oc_group,
                             int64_t  block_h,
                             int64_t  block_w,
                             uint64_t psum_read_highaddr)
  {
    auto seq_1_offset = split_exp_fra(bytes_psum * oc_group_size * w);
    auto seq_2_offset = split_exp_fra(bytes_psum * oc_group_size * w * h);

    if (DEBUG) {
      std::cout << "======== Load Ifmap ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "oc_group: " << oc_group << std::endl;
      std::cout << "h: " << h << std::endl;
      std::cout << "w: " << w << std::endl;
      std::cout << "block_oc_group: " << block_oc_group << std::endl;
      std::cout << "block_h: " << block_h << std::endl;
      std::cout << "block_w: " << block_w << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << block_w << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_h << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << block_oc_group << std::endl;
      std::cout << "sram_base_addr: " << (MASTER_PSUM_ADDR | (psum_read_highaddr << (8 + int(log2(oc_group_size * bytes_ofmap / 16)))))
                << std::endl;
    }

    return insn::load_iteration_3(ddr_base_addr,
                                  block_w * bytes_psum - 1,
                                  seq_1_offset.first,
                                  seq_1_offset.second,
                                  block_h - 1,
                                  seq_2_offset.first,
                                  seq_2_offset.second,
                                  block_oc_group - 1,
                                  MASTER_PSUM_ADDR | (psum_read_highaddr << (8 + int(log2(oc_group_size * bytes_psum / 16)))),
                                  0);
  }

  insn::instruction Store(int64_t  ddr_base_addr,
                          int64_t  oc_group,
                          int64_t  h,
                          int64_t  w,
                          int64_t  block_oc_group,
                          int64_t  block_h,
                          int64_t  block_w,
                          int64_t  all_done,
                          uint64_t psum_write_highaddr)
  {
    auto seq_1_offset = split_exp_fra(bytes_ofmap * oc_group_size * w);
    auto seq_2_offset = split_exp_fra(bytes_ofmap * oc_group_size * w * h);

    if (DEBUG) {
      std::cout << "======== Store ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "oc_group: " << oc_group << std::endl;
      std::cout << "h: " << h << std::endl;
      std::cout << "w: " << w << std::endl;
      std::cout << "block_oc_group: " << block_oc_group << std::endl;
      std::cout << "block_h: " << block_h << std::endl;
      std::cout << "block_w: " << block_w << std::endl;
      std::cout << "all_done: " << all_done << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << block_w * bytes_ofmap << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_h << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << block_oc_group << std::endl;
      std::cout << "sram_base_addr: " << (MASTER_PSUM_ADDR | (psum_write_highaddr << (8 + int(log2(oc_group_size * bytes_ofmap / 16)))))
                << std::endl;
    }

    return insn::store_iteration_3(ddr_base_addr,
                                   block_w * bytes_ofmap - 1,
                                   seq_1_offset.first,
                                   seq_1_offset.second,
                                   block_h - 1,
                                   seq_2_offset.first,
                                   seq_2_offset.second,
                                   block_oc_group - 1,
                                   (MASTER_PSUM_ADDR | (psum_write_highaddr << (8 + int(log2(oc_group_size * bytes_ofmap / 16))))),
                                   all_done);
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
}  // namespace vcu