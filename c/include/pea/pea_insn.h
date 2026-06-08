#pragma once

#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <vector>

#include "addr.h"
#include "common/cfg.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include "common/read_cfg.h"

namespace pea {

using namespace common;

enum class PEA_INPUT_TYPE : std::uint32_t {
  INT4    = 0,
  INT8    = 1,
  FLOAT16 = 2,
  BFOAT16 = 3,
  INT16   = 4
};

enum class PEA_ACCUMULATOR_TYPE : std::uint32_t {
  INT32   = 0,
  FLOAT32 = 1
};

enum class PEA_OUTPUT_TYPE : std::uint32_t {
  INT32   = 0,
  FLOAT32 = 1,
  INT16   = 2
};

// 类模板信息
template<int  SPARSE_ENABLE_                   = 0,       // 稀疏基数
         bool IFMAP_NON_UNIFORM_QUANTIZATION_  = false,   // 是否支持非均匀量化, 仅int4的weight支持
         bool WEIGHT_NON_UNIFORM_QUANTIZATION_ = false,   // 是否支持非均匀量化, 仅int4的weight支持
         bool OUTLIER_ENABLE_                  = false,   // 是否支持异常值处理, 仅int卷积/矩阵乘支持
         int  TYPE_A_                          = kInt4,   // ifmap的输入数据类型, 定义在c/include/common/type_utils.h
         int  TYPE_B_                          = kInt4,   // weight的输入数据类型, 定义在c/include/common/type_utils.h
         int  TYPE_ACCUMULATOR_                = kInt32,  // 累加器的数据类型, 定义在c/include/common/type_utils.h
         int  TYPE_OUTPUT_                     = kInt32,  // 输出的数据类型, 定义在c/include/common/type_utils.h
         bool DEBUG_                           = false    // 是否打印调试信息
         >
struct Conv2dOp {
  // 参数信息
  static constexpr int  SPARSE_ENABLE                   = SPARSE_ENABLE_;
  static constexpr bool WEIGHT_NON_UNIFORM_QUANTIZATION = WEIGHT_NON_UNIFORM_QUANTIZATION_;
  static constexpr bool IFMAP_NON_UNIFORM_QUANTIZATION  = IFMAP_NON_UNIFORM_QUANTIZATION_;
  static constexpr bool OUTLIER_ENABLE                  = OUTLIER_ENABLE_;
  static constexpr int  TYPE_A                          = TYPE_A_;
  static constexpr int  TYPE_B                          = TYPE_B_;
  static constexpr int  TYPE_ACCUMULATOR                = TYPE_ACCUMULATOR_;
  static constexpr int  TYPE_OUTPUT                     = TYPE_OUTPUT_;
  static constexpr int  DEBUG                           = DEBUG_;

  // 尺寸信息及基地址参数
  struct Arguments {
    int      ifmap_h;
    int      ifmap_w;
    int      weight_h;
    int      weight_w;
    int      in_channels;
    int      out_channels;
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
    int      block_ic_group;
    int      block_oc_group;
    uint64_t ifmap_base_addr;
    uint64_t weight_base_addr;
    uint64_t ofmap_base_addr;
    uint64_t ifmap_scale_base_addr   = 0;
    uint64_t weight_scale_base_addr  = 0;
    uint64_t outlier_index_base_addr = 0;
    uint64_t ifmap_mask_base_addr    = 0;
    int all_done                = 1;
  };

  int   ofmap_h;
  int   ofmap_w;
  int   ic_group;
  int   oc_group;
  int   ic_group_size;
  int   oc_group_size;
  float bytes_ifmap;
  float bytes_weight;
  float bytes_ofmap;
  int   ic_group_scale;
  int   ifmap_mask_ic_group_scale;

  // 构造函数, 检查参数合法性
  Conv2dOp(): ofmap_h(0), ofmap_w(0), ic_group(0), oc_group(32)
  {
    /* -------------------------------------------- Error checking -------------------------------------------- */
    if (TYPE_A == 4 && TYPE_B != 4 || TYPE_A != 4 && TYPE_B == 4) {
      std::runtime_error("Invalid input type, when one is INT16, the other must be INT16");
    }

    if ((IFMAP_NON_UNIFORM_QUANTIZATION && TYPE_A != 0) || (WEIGHT_NON_UNIFORM_QUANTIZATION && TYPE_B != 0)) {
      std::runtime_error("Invalid input type, non-uniform quantization only supports INT4");
    }

    if (TYPE_ACCUMULATOR == kFloat32) {
      if (TYPE_A == kInt16 || TYPE_B == kInt16) {
        std::runtime_error("ERROR: float accumulator is not supported for int16_t");
      }
    }

    if (IFMAP_NON_UNIFORM_QUANTIZATION || WEIGHT_NON_UNIFORM_QUANTIZATION) {
      if (TYPE_A == kInt16 || TYPE_B == kInt16) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for int16_t");
      }

      if (TYPE_A == kBfloat16 || TYPE_B == kBfloat16) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for bf16");
      }

      if (TYPE_A == kHalf || TYPE_B == kHalf) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for fp16");
      }

      if (TYPE_ACCUMULATOR == kFloat32) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for non-float accumulator");
      }

      if (TYPE_OUTPUT == kFloat32) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for non-float output");
      }
    }

    if (OUTLIER_ENABLE) {
      if (TYPE_A == kInt16 || TYPE_B == kInt16) {
        std::runtime_error("ERROR: Outlier detection is not supported for int16_t");
      }

      if (TYPE_A == kBfloat16 || TYPE_B == kBfloat16) {
        std::runtime_error("ERROR: Outlier detection is not supported for bf16");
      }

      if (TYPE_A == kHalf || TYPE_B == kHalf) {
        std::runtime_error("ERROR: Outlier detection is not supported for fp16");
      }

      if (TYPE_ACCUMULATOR == kFloat32) {
        std::runtime_error("ERROR: Outlier detection is not supported for non-float accumulator");
      }

      if (TYPE_OUTPUT == kFloat32) {
        std::runtime_error("ERROR: Outlier detection is not supported for non-float output");
      }
    }

    /* --------------------------------------------- Type Decoder --------------------------------------------- */
    if (TYPE_A == 4 && TYPE_B == 4) {  // INt16
      ic_group_size = 16;
      bytes_ifmap   = 2;
      bytes_weight  = 2;
    }
    else if (TYPE_A == 3 || TYPE_B == 3 || TYPE_A == 2 || TYPE_B == 2) {  // Bfloat16 or Float16
      ic_group_size = 16;
      bytes_ifmap   = 2;
      bytes_weight  = 2;
    }
    else if ((TYPE_A == 1 && TYPE_B <= 1) || (TYPE_B == 1 && TYPE_A <= 1)) {  // Int8
      ic_group_size = 32;
      bytes_ifmap   = 1;
      bytes_weight  = 1;
    }
    else {  // Int4
      ic_group_size = 64;
      bytes_ifmap   = 0.5;
      bytes_weight  = 0.5;
    }
    bytes_ofmap   = 4;
    oc_group_size = 32;

    if (SPARSE_ENABLE == 0) {
      ic_group_scale = 1;
    }
    else if (SPARSE_ENABLE == 1) {
      ic_group_scale = 2;
    }
  }

  // 重载函数调用操作符, 获得pea指令序列
  std::vector<insn::instruction> operator()(const Arguments& args)
  {
    // 计算输出特征图整体尺寸
    ofmap_h = floor((args.ifmap_h + 2 * args.pad_h - args.dilation_h * (args.weight_h - 1) - 1) / args.stride_h + 1);
    ofmap_w = floor((args.ifmap_w + 2 * args.pad_w - args.dilation_w * (args.weight_w - 1) - 1) / args.stride_w + 1);

    std::vector<insn::instruction> instruction_series;

    // 计算输出特征图分块尺寸
    int ofmap_block_h =
      floor((double)(args.ifmap_block_h + 2 * args.pad_h - args.dilation_h * (args.weight_h - 1) - 1) / (double)args.stride_h + 1);
    int ofmap_block_w =
      floor((double)(args.ifmap_block_w + 2 * args.pad_w - args.dilation_w * (args.weight_w - 1) - 1) / (double)args.stride_w + 1);
    // 计算循环次数
    int h_iterations  = ceil((double)ofmap_h / (double)ofmap_block_h);
    int w_iterations  = ceil((double)ofmap_w / (double)ofmap_block_w);
    int kh_iterations = ceil((double)args.weight_h / (double)args.weight_block_h);
    int kw_iterations = ceil((double)args.weight_w / (double)args.weight_block_w);
    int ic_group      = 0;
    if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8) || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
      ic_group = ceil((double)args.in_channels / (double)((ic_group_size * ic_group_scale) * 2));
    }
    else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
      ic_group = ceil((double)args.in_channels / (double)((ic_group_size * ic_group_scale) * 4));
    }
    else if ((TYPE_A == kInt8 && TYPE_B == kHalf) || (TYPE_A == kInt8 && TYPE_B == kBfloat16) || (TYPE_A == kInt4 && TYPE_B == kInt8)) {
      ic_group = ceil((double)args.in_channels / ((double)(ic_group_size * ic_group_scale) * 2));
    }
    else if ((TYPE_A == kInt4 && TYPE_B == kBfloat16) || (TYPE_A == kInt4 && TYPE_B == kHalf)) {
      ic_group = ceil((double)args.in_channels / ((double)(ic_group_size * ic_group_scale) * 4));
    }
    else {
      ic_group = ceil((double)args.in_channels / (double)(ic_group_size * ic_group_scale));
    }

    int oc_group      = ceil((double)args.out_channels / (double)oc_group_size);
    int ic_iterations = ceil((double)ic_group / (double)args.block_ic_group);
    int oc_iterations = ceil((double)oc_group / (double)args.block_oc_group);

    if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8) || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
      ifmap_mask_ic_group_scale = 2;
    }
    else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
      ifmap_mask_ic_group_scale = 4;
    }
    else {
      ifmap_mask_ic_group_scale = 1;
    }

    if (DEBUG) {
      std::cout << "ofmap_block_h: " << ofmap_block_h << std::endl;
      std::cout << "ofmap_block_w: " << ofmap_block_w << std::endl;
      std::cout << "ofmap_h: " << ofmap_h << std::endl;
      std::cout << "ofmap_w: " << ofmap_w << std::endl;
      std::cout << "h_iterations: " << h_iterations << std::endl;
      std::cout << "w_iterations: " << w_iterations << std::endl;
      std::cout << "kh_iterations: " << kh_iterations << std::endl;
      std::cout << "kw_iterations: " << kw_iterations << std::endl;
      std::cout << "ic_iterations: " << ic_iterations << std::endl;
      std::cout << "oc_iterations: " << oc_iterations << std::endl;
      std::cout << "args.in_channels: " << args.in_channels << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "oc_group: " << oc_group << std::endl;
      std::cout << "args.out_channels: " << args.out_channels << std::endl;
      std::cout << "ic_group_size: " << ic_group_size << std::endl;
      std::cout << "ic_group_scale: " << ic_group_scale << std::endl;
      std::cout << "oc_group_size: " << oc_group_size << std::endl;
    }

    // 循环中使用到的变量
    int64_t i_h_start, i_w_start, k_h_start, k_w_start, o_h_start, o_w_start;
    int64_t i_h, i_w, k_h, k_w, i_ic, k_oc, k_ic;
    int64_t pad_top, pad_left;
    int64_t ifmap_ddr_offset, weight_ddr_offset, ofmap_ddr_offset;
    int64_t ifmap_scale_ddr_offset, weight_scale_ddr_offset;
    int64_t outlier_index_ddr_offset;
    int64_t ifmap_mask_ddr_offset;

    // convolution Config
    instruction_series.push_back(insn::pea_config(SPARSE_ENABLE,
                                                  WEIGHT_NON_UNIFORM_QUANTIZATION,
                                                  IFMAP_NON_UNIFORM_QUANTIZATION,
                                                  OUTLIER_ENABLE,
                                                  args.stride_w,
                                                  args.stride_h,
                                                  args.dilation_w,
                                                  args.dilation_h));

    for (int oc_iter = 0; oc_iter < oc_iterations; ++oc_iter) {
      for (int h_iter = 0; h_iter < h_iterations; ++h_iter) {
        for (int w_iter = 0; w_iter < w_iterations; ++w_iter) {
          // ofmap horizontal and vertical start index
          o_w_start = w_iter * ofmap_block_w;
          o_h_start = h_iter * ofmap_block_h;
          k_oc      = std::min(oc_group - oc_iter * args.block_oc_group, args.block_oc_group);
          for (int ic_iter = 0; ic_iter < ic_iterations; ++ic_iter) {
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
                if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8)
                    || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
                  i_ic = std::min((ic_group - (ic_iter * args.block_ic_group)) * 2, args.block_ic_group * 2);
                  k_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                }
                else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
                  i_ic = std::min((ic_group - (ic_iter * args.block_ic_group)) * 4, args.block_ic_group * 4);
                  k_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                }
                else if ((TYPE_A == kInt8 && TYPE_B == kHalf) || (TYPE_A == kInt8 && TYPE_B == kBfloat16)
                         || (TYPE_A == kInt4 && TYPE_B == kInt8)) {
                  i_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                  k_ic = std::min((ic_group - (ic_iter * args.block_ic_group)) * 2, args.block_ic_group * 2);
                }
                else if ((TYPE_A == kInt4 && TYPE_B == kHalf) || (TYPE_A == kInt4 && TYPE_B == kBfloat16)) {
                  i_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                  k_ic = std::min((ic_group - (ic_iter * args.block_ic_group)) * 4, args.block_ic_group * 4);
                }
                else {
                  i_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                  k_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                }
                // weight horizontal and vertical start index
                k_w_start = kw_iter * args.weight_block_w;
                k_h_start = kh_iter * args.weight_block_h;
                // weight horizontal and vertical length
                k_w = std::min((int64_t)args.weight_block_w, args.weight_w - k_w_start);
                k_h = std::min((int64_t)args.weight_block_h, args.weight_h - k_h_start);
                // ddr offset calculation
                if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8)
                    || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
                  ifmap_ddr_offset         = int64_t(bytes_ifmap * ic_group_size
                                             * (args.ifmap_h * args.ifmap_w * ((ic_iter * args.block_ic_group * ic_group_scale) * 2)
                                                + i_h_start * args.ifmap_w + i_w_start));
                  ifmap_scale_ddr_offset   = int64_t(32 * (i_h_start * args.ifmap_w + i_w_start));
                  outlier_index_ddr_offset = int64_t(bytes_ifmap * ic_group_size
                                                     * (args.ifmap_h * args.ifmap_w * ((ic_iter * args.block_ic_group * ic_group_scale) * 2)
                                                        + i_h_start * args.ifmap_w + i_w_start));
                }
                else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
                  ifmap_ddr_offset = int64_t(bytes_ifmap * ic_group_size
                                             * (args.ifmap_h * args.ifmap_w * ((ic_iter * args.block_ic_group * ic_group_scale) * 4)
                                                + i_h_start * args.ifmap_w + i_w_start));

                  ifmap_scale_ddr_offset   = int64_t(32 * (i_h_start * args.ifmap_w + i_w_start));
                  outlier_index_ddr_offset = int64_t(bytes_ifmap * ic_group_size
                                                     * (args.ifmap_h * args.ifmap_w * ((ic_iter * args.block_ic_group * ic_group_scale) * 4)
                                                        + i_h_start * args.ifmap_w + i_w_start));
                }
                else {
                  ifmap_ddr_offset         = int64_t(bytes_ifmap * ic_group_size
                                             * (args.ifmap_h * args.ifmap_w * (ic_iter * args.block_ic_group * ic_group_scale)
                                                + i_h_start * args.ifmap_w + i_w_start));
                  ifmap_scale_ddr_offset   = int64_t(32 * (i_h_start * args.ifmap_w + i_w_start));
                  outlier_index_ddr_offset = int64_t(bytes_ifmap * ic_group_size
                                                     * (args.ifmap_h * args.ifmap_w * (ic_iter * args.block_ic_group * ic_group_scale)
                                                        + i_h_start * args.ifmap_w + i_w_start));
                }

                if ((TYPE_A == kInt8 && TYPE_B == kHalf) || (TYPE_A == kInt8 && TYPE_B == kBfloat16)
                    || (TYPE_A == kInt4 && TYPE_B == kInt8)) {
                  weight_ddr_offset     = int64_t(bytes_weight * oc_group_size * ic_group_size
                                              * (args.weight_h * args.weight_w * (ic_group * 2) * (oc_iter * args.block_oc_group)
                                                 + args.weight_h * args.weight_w * ((ic_iter * args.block_ic_group) * 2)
                                                 + k_h_start * args.weight_w + k_w_start));
                  ifmap_mask_ddr_offset = int64_t(oc_group_size * (ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale)
                                                  * (args.weight_h * args.weight_w * (ic_group * 2) * (oc_iter * args.block_oc_group)
                                                     + args.weight_h * args.weight_w * ((ic_iter * args.block_ic_group) * 2)
                                                     + k_h_start * args.weight_w + k_w_start)
                                                  / 8);
                }
                else if ((TYPE_A == kInt4 && TYPE_B == kHalf) || (TYPE_A == kInt4 && TYPE_B == kBfloat16)) {
                  weight_ddr_offset     = int64_t(bytes_weight * oc_group_size * ic_group_size
                                              * (args.weight_h * args.weight_w * (ic_group * 4) * (oc_iter * args.block_oc_group)
                                                 + args.weight_h * args.weight_w * ((ic_iter * args.block_ic_group) * 4)
                                                 + k_h_start * args.weight_w + k_w_start));
                  ifmap_mask_ddr_offset = int64_t(oc_group_size * (ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale)
                                                  * (args.weight_h * args.weight_w * (ic_group * 4) * (oc_iter * args.block_oc_group)
                                                     + args.weight_h * args.weight_w * ((ic_iter * args.block_ic_group) * 4)
                                                     + k_h_start * args.weight_w + k_w_start)
                                                  / 8);
                }
                else {
                  weight_ddr_offset =
                    int64_t(bytes_weight * oc_group_size * ic_group_size
                            * (args.weight_h * args.weight_w * ic_group * (oc_iter * args.block_oc_group)
                               + args.weight_h * args.weight_w * (ic_iter * args.block_ic_group) + k_h_start * args.weight_w + k_w_start));
                  ifmap_mask_ddr_offset =
                    int64_t(oc_group_size * (ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale)
                            * (args.weight_h * args.weight_w * ic_group * (oc_iter * args.block_oc_group)
                               + args.weight_h * args.weight_w * (ic_iter * args.block_ic_group) + k_h_start * args.weight_w + k_w_start)
                            / 8);
                }

                weight_scale_ddr_offset =
                  int64_t(2 * oc_group_size
                          * (args.weight_h * args.weight_w * (oc_iter * args.block_oc_group) + k_h_start * args.weight_w + k_w_start));
                ofmap_ddr_offset = int64_t(bytes_ofmap * oc_group_size
                                           * (ofmap_h * ofmap_w * (oc_iter * args.block_oc_group) + o_h_start * ofmap_w + o_w_start));
                // load ifmap
                if (SPARSE_ENABLE) {
                  for (int i = 0; i < ic_group_scale; ++i) {
                    if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8)
                        || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
                      if (i != 0) {
                        ifmap_ddr_offset += int64_t(bytes_ifmap * ic_group_size * args.ifmap_h * args.ifmap_w);
                      }
                    }
                    else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
                      if (i != 0) {
                        ifmap_ddr_offset += int64_t(bytes_ifmap * ic_group_size * args.ifmap_h * args.ifmap_w);
                      }
                    }
                    else {
                      if (i != 0) {
                        ifmap_ddr_offset += int64_t(bytes_ifmap * ic_group_size * args.ifmap_h * args.ifmap_w);
                      }
                    }
                    // std::cout << ifmap_ddr_offset << std::endl;
                    instruction_series.push_back(LoadIfmap(args.ifmap_base_addr + ifmap_ddr_offset,
                                                           ic_group,
                                                           args.ifmap_h,
                                                           args.ifmap_w,
                                                           i_ic,
                                                           i_h,
                                                           i_w,
                                                           MASTER_IFMAP_ADDR + i * 256));
                  }
                }
                else {
                  instruction_series.push_back(LoadIfmap(
                    args.ifmap_base_addr + ifmap_ddr_offset, ic_group, args.ifmap_h, args.ifmap_w, i_ic, i_h, i_w, MASTER_IFMAP_ADDR));
                }
                // load weight
                int real_weight_ic_group = 0;
                if (TYPE_A == kInt8 && TYPE_B == kInt4) {
                  real_weight_ic_group = args.in_channels / ic_group_size / 2 / ic_group_scale;
                }
                else if (TYPE_A == kHalf && TYPE_B == kInt8) {
                  real_weight_ic_group = args.in_channels / ic_group_size / 2 / ic_group_scale;
                }
                else if (TYPE_A == kHalf && TYPE_B == kInt4) {
                  real_weight_ic_group = args.in_channels / ic_group_size / 4 / ic_group_scale;
                }
                else if (TYPE_A == kBfloat16 && TYPE_B == kInt8) {
                  real_weight_ic_group = args.in_channels / ic_group_size / 2 / ic_group_scale;
                }
                else if (TYPE_A == kBfloat16 && TYPE_B == kInt4) {
                  real_weight_ic_group = args.in_channels / ic_group_size / 4 / ic_group_scale;
                }
                else {
                  real_weight_ic_group = args.in_channels / ic_group_size / ic_group_scale;
                }
                instruction_series.push_back(LoadWeight(args.weight_base_addr + weight_ddr_offset,
                                                        oc_group,
                                                        real_weight_ic_group,
                                                        args.weight_h,
                                                        args.weight_w,
                                                        k_oc,
                                                        k_ic,
                                                        k_h,
                                                        k_w));
                // For per vector scale quantization
                if (((TYPE_A == kInt8 && TYPE_B == kInt8) || (TYPE_A == kInt4 && TYPE_B == kInt4) || (TYPE_A == kInt8 && TYPE_B == kInt4)
                     || (TYPE_A == kInt4 && TYPE_B == kInt8))
                    && TYPE_ACCUMULATOR == kFloat32) {
                  int repeat_times = 1;
                  if (TYPE_A == kInt4 && TYPE_B == kInt8) {
                    repeat_times = 2 * args.block_ic_group;
                  }
                  else if (TYPE_A == kInt4 && TYPE_B == kInt4) {
                    if (OUTLIER_ENABLE || WEIGHT_NON_UNIFORM_QUANTIZATION || IFMAP_NON_UNIFORM_QUANTIZATION) {
                      repeat_times = args.block_ic_group;
                    }
                  }
                  else if (TYPE_A == kInt8 && TYPE_B == kInt8 && OUTLIER_ENABLE) {
                    repeat_times = args.block_ic_group;
                  }
                  else if (TYPE_A == kInt8 && TYPE_B == kInt4) {
                    if (OUTLIER_ENABLE || WEIGHT_NON_UNIFORM_QUANTIZATION) {
                      repeat_times = args.block_ic_group;
                    }
                    else {
                      repeat_times = 2 * args.block_ic_group;
                    }
                  }
                  instruction_series.push_back(
                    LoadIfmapScale(args.ifmap_scale_base_addr + ifmap_scale_ddr_offset, args.ifmap_h, args.ifmap_w, i_h, i_w));
                  instruction_series.push_back(LoadWeightScale(args.weight_scale_base_addr + weight_scale_ddr_offset,
                                                               oc_group,
                                                               args.weight_h,
                                                               args.weight_w,
                                                               k_oc,
                                                               k_h,
                                                               k_w,
                                                               repeat_times));
                  // For outlier process
                  if (OUTLIER_ENABLE) {
                    if (SPARSE_ENABLE) {
                      for (int i = 0; i < ic_group_scale; ++i) {
                        if ((TYPE_A == kInt8 && TYPE_B == kInt4)) {
                          if (i != 0) {
                            outlier_index_ddr_offset += int64_t(bytes_ifmap * ic_group_size * (args.ifmap_h * args.ifmap_w));
                          }
                        }
                        else {
                          if (i != 0) {
                            outlier_index_ddr_offset += int64_t(bytes_ifmap * ic_group_size * (args.ifmap_h * args.ifmap_w));
                          }
                        }
                        // std::cout << ifmap_ddr_offset << std::endl;
                        instruction_series.push_back(LoadOutlierIndex(args.outlier_index_base_addr + outlier_index_ddr_offset,
                                                                      ic_group,
                                                                      args.ifmap_h,
                                                                      args.ifmap_w,
                                                                      i_ic,
                                                                      i_h,
                                                                      i_w,
                                                                      MASTER_OUTLIER_INDEX_ADDR + i * 256));
                      }
                    }
                    else {
                      instruction_series.push_back(LoadOutlierIndex(args.outlier_index_base_addr + outlier_index_ddr_offset,
                                                                    ic_group,
                                                                    args.ifmap_h,
                                                                    args.ifmap_w,
                                                                    i_ic,
                                                                    i_h,
                                                                    i_w,
                                                                    MASTER_OUTLIER_INDEX_ADDR));
                    }
                  }
                }

                // For sparse
                if (SPARSE_ENABLE) {
                  instruction_series.push_back(LoadIfmapMask(args.ifmap_mask_base_addr + ifmap_mask_ddr_offset,
                                                             oc_group,
                                                             real_weight_ic_group,
                                                             args.weight_h,
                                                             args.weight_w,
                                                             k_oc,
                                                             k_ic,
                                                             k_h,
                                                             k_w));
                }
                if (DEBUG) {
                  std::cout << "==== Convolution Execute ====" << std::endl;
                  std::cout << "i_h: " << i_h << std::endl;
                  std::cout << "i_w: " << i_w << std::endl;
                  std::cout << "k_h: " << k_h << std::endl;
                  std::cout << "k_w: " << k_w << std::endl;
                  std::cout << "k_ic: " << k_ic << std::endl;
                  std::cout << "k_oc: " << k_oc << std::endl;
                }

                int psum_number;
                if ((TYPE_A == kInt8 && TYPE_B == kHalf) || (TYPE_A == kInt8 && TYPE_B == kBfloat16) || (TYPE_A == kInt4 && TYPE_B == kInt8)
                    || (TYPE_A == kInt4 && TYPE_B == kInt4 && (IFMAP_NON_UNIFORM_QUANTIZATION | WEIGHT_NON_UNIFORM_QUANTIZATION))) {
                  psum_number = k_w * k_h * i_ic * k_oc * 2;
                }
                else if ((TYPE_A == kInt4 && TYPE_B == kHalf) || (TYPE_A == kInt4 && TYPE_B == kBfloat16)) {
                  psum_number = k_w * k_h * i_ic * k_oc * 4;
                }
                else {
                  psum_number = k_w * k_h * i_ic * k_oc;
                }
                if (OUTLIER_ENABLE) {
                  psum_number *= 2;
                }

                // convolution execute
                instruction_series.push_back(insn::convolution_execute(TYPE_A,
                                                                       TYPE_B,
                                                                       TYPE_ACCUMULATOR - 5,
                                                                       TYPE_OUTPUT - 5,
                                                                       i_w - 1,
                                                                       i_h - 1,
                                                                       k_w - 1,
                                                                       k_h - 1,
                                                                       ofmap_block_w - 1,
                                                                       ofmap_block_h - 1,
                                                                       k_ic - 1,
                                                                       k_oc - 1,
                                                                       0,
                                                                       0,
                                                                       0,
                                                                       pad_left,
                                                                       pad_top,
                                                                       psum_number - 1,
                                                                       ic_iter != 0 || kw_iter != 0 || kh_iter != 0));
              }
            }
          }

          // VCU放在这里
          instruction_series.push_back(
            Store(args.ofmap_base_addr + ofmap_ddr_offset,
                  oc_group,
                  ofmap_h,
                  ofmap_w,
                  args.block_oc_group,
                  ofmap_block_h,
                  ofmap_block_w,
                  h_iter == h_iterations - 1 && w_iter == w_iterations - 1 && oc_iter == oc_iterations - 1 && args.all_done));
        }
      }
    }
    return instruction_series;
  }

  private:
  insn::instruction LoadIfmap(int64_t ddr_base_addr,
                              int64_t ic_group,
                              int64_t h,
                              int64_t w,
                              int64_t block_ic_group,
                              int64_t block_h,
                              int64_t block_w,
                              int64_t sram_base_addr)
  {
    auto seq_1_offset = split_exp_fra(bytes_ifmap * ic_group_size * w);
    auto seq_2_offset = split_exp_fra(bytes_ifmap * ic_group_size * w * h * ic_group_scale);

    if (DEBUG) {
      std::cout << "======== Load Ifmap ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "h: " << h << std::endl;
      std::cout << "w: " << w << std::endl;
      std::cout << "block_ic_group: " << block_ic_group << std::endl;
      std::cout << "block_h: " << block_h << std::endl;
      std::cout << "block_w: " << block_w << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << block_w << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_h << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << block_ic_group << std::endl;
    }

    return insn::load_iteration_3(ddr_base_addr,
                                  block_w - 1,
                                  seq_1_offset.first,
                                  seq_1_offset.second,
                                  block_h - 1,
                                  seq_2_offset.first,
                                  seq_2_offset.second,
                                  block_ic_group - 1,
                                  sram_base_addr,
                                  0);
  }

  insn::instruction LoadIfmapScale(int64_t ddr_base_addr, int64_t h, int64_t w, int64_t block_h, int64_t block_w)
  {
    auto seq_1_offset = split_exp_fra(w * 32);

    if (DEBUG) {
      std::cout << "======== Load Ifmap Scale ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "h: " << h << std::endl;
      std::cout << "w: " << w << std::endl;
      std::cout << "block_h: " << block_h << std::endl;
      std::cout << "block_w: " << block_w << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << block_w << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_h << std::endl;
    }

    return insn::load_iteration_2(
      ddr_base_addr, block_w - 1, seq_1_offset.first, seq_1_offset.second, block_h - 1, MASTER_IFMAP_SCALE_ADDR, 0);
  }

  insn::instruction LoadWeight(int64_t ddr_base_addr,
                               int64_t oc_group,
                               int64_t ic_group,
                               int64_t h,
                               int64_t w,
                               int64_t block_oc_group,
                               int64_t block_ic_group,
                               int64_t block_h,
                               int64_t block_w)
  {
    auto seq_1_offset = split_exp_fra(bytes_weight * ic_group_size * oc_group_size * w);
    auto seq_2_offset = split_exp_fra(bytes_weight * ic_group_size * oc_group_size * w * h);
    auto seq_3_offset = split_exp_fra(bytes_weight * ic_group_size * oc_group_size * w * h * ic_group);

    if (DEBUG) {
      std::cout << "======== Load Weight ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "oc_group: " << oc_group << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "h: " << h << std::endl;
      std::cout << "w: " << w << std::endl;
      std::cout << "block_oc_group: " << block_oc_group << std::endl;
      std::cout << "block_ic_group: " << block_ic_group << std::endl;
      std::cout << "oc_group_size: " << oc_group_size << std::endl;
      std::cout << "ic_group_size: " << ic_group_size << std::endl;
      std::cout << "block_h: " << block_h << std::endl;
      std::cout << "block_w: " << block_w << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << block_w * oc_group_size << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_h << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << block_ic_group << std::endl;
      std::cout << "seq_3_hop_exp: " << seq_3_offset.first << std::endl;
      std::cout << "seq_3_hop_fra: " << seq_3_offset.second << std::endl;
      std::cout << "seq_3_burst: " << block_oc_group << std::endl;
    }

    return insn::load_iteration_4<1>(ddr_base_addr,
                                     block_w * oc_group_size - 1,
                                     seq_1_offset.first,
                                     seq_1_offset.second,
                                     block_h - 1,
                                     seq_2_offset.first,
                                     seq_2_offset.second,
                                     block_ic_group - 1,
                                     seq_3_offset.first,
                                     seq_3_offset.second,
                                     block_oc_group - 1,
                                     MASTER_WEIGHT_ADDR,
                                     0);
  }

  insn::instruction LoadWeightScale(int64_t ddr_base_addr,
                                    int64_t oc_group,
                                    int64_t h,
                                    int64_t w,
                                    int64_t block_oc_group,
                                    int64_t block_h,
                                    int64_t block_w,
                                    int64_t repeat_times)
  {
    auto seq_1_offset = split_exp_fra(2 * oc_group_size * w);
    auto seq_2_offset = split_exp_fra(2 * oc_group_size * w * h);

    if (DEBUG) {
      std::cout << "======== Load Weight Scale ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "oc_group: " << oc_group << std::endl;
      std::cout << "h: " << h << std::endl;
      std::cout << "w: " << w << std::endl;
      std::cout << "block_oc_group: " << block_oc_group << std::endl;
      std::cout << "block_h: " << block_h << std::endl;
      std::cout << "block_w: " << block_w << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << block_w * 2 << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_h << std::endl;
      std::cout << "seq_2_hop_exp: " << 0 << std::endl;
      std::cout << "seq_2_hop_fra: " << 0 << std::endl;
      std::cout << "seq_2_burst: " << repeat_times << std::endl;
      std::cout << "seq_3_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_3_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_3_burst: " << block_oc_group << std::endl;
    }

    return insn::load_iteration_4<1>(ddr_base_addr,
                                     block_w * 2 - 1,
                                     seq_1_offset.first,
                                     seq_1_offset.second,
                                     block_h - 1,
                                     0,
                                     0,
                                     repeat_times - 1,
                                     seq_2_offset.first,
                                     seq_2_offset.second,
                                     block_oc_group - 1,
                                     MASTER_WEIGHT_SCALE_ADDR,
                                     0);
  }

  insn::instruction LoadOutlierIndex(int64_t ddr_base_addr,
                                     int64_t ic_group,
                                     int64_t h,
                                     int64_t w,
                                     int64_t block_ic_group,
                                     int64_t block_h,
                                     int64_t block_w,
                                     int64_t sram_base_addr)
  {
    auto seq_1_offset = split_exp_fra(bytes_ifmap * ic_group_size * w);
    auto seq_2_offset = split_exp_fra(bytes_ifmap * ic_group_size * w * h * ic_group_scale);

    if (DEBUG) {
      std::cout << "======== Load Outlier Index ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "h: " << h << std::endl;
      std::cout << "w: " << w << std::endl;
      std::cout << "block_ic_group: " << block_ic_group << std::endl;
      std::cout << "block_h: " << block_h << std::endl;
      std::cout << "block_w: " << block_w << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << block_w << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_h << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << block_ic_group << std::endl;
    }

    return insn::load_iteration_3(ddr_base_addr,
                                  block_w - 1,
                                  seq_1_offset.first,
                                  seq_1_offset.second,
                                  block_h - 1,
                                  seq_2_offset.first,
                                  seq_2_offset.second,
                                  block_ic_group - 1,
                                  sram_base_addr,
                                  0);
  }

  insn::instruction LoadIfmapMask(int64_t ddr_base_addr,
                                  int64_t oc_group,
                                  int64_t ic_group,
                                  int64_t h,
                                  int64_t w,
                                  int64_t block_oc_group,
                                  int64_t block_ic_group,
                                  int64_t block_h,
                                  int64_t block_w)
  {
    auto seq_1_offset = split_exp_fra(int(ic_group_size * oc_group_size * ic_group_scale * w / 8 * ifmap_mask_ic_group_scale));
    auto seq_2_offset = split_exp_fra(int(ic_group_size * oc_group_size * ic_group_scale * w * h / 8 * ifmap_mask_ic_group_scale));
    auto seq_3_offset =
      split_exp_fra(int(ic_group_size * oc_group_size * ic_group_scale * w * h * ic_group / 8 * ifmap_mask_ic_group_scale));

    if (DEBUG) {
      std::cout << "======== Load Ifmap Mask ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "oc_group: " << oc_group << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "h: " << h << std::endl;
      std::cout << "w: " << w << std::endl;
      std::cout << "block_oc_group: " << block_oc_group << std::endl;
      std::cout << "block_ic_group: " << block_ic_group << std::endl;
      std::cout << "block_h: " << block_h << std::endl;
      std::cout << "block_w: " << block_w << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << block_w * oc_group_size * (ic_group_scale / 2) / 8 * ifmap_mask_ic_group_scale << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_h << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << block_ic_group << std::endl;
      std::cout << "seq_3_hop_exp: " << seq_3_offset.first << std::endl;
      std::cout << "seq_3_hop_fra: " << seq_3_offset.second << std::endl;
      std::cout << "seq_3_burst: " << block_oc_group << std::endl;
    }

    return insn::load_iteration_4<1>(ddr_base_addr,
                                     block_w * oc_group_size * (ic_group_size * ic_group_scale) * ifmap_mask_ic_group_scale / 256 - 1,
                                     seq_1_offset.first,
                                     seq_1_offset.second,
                                     block_h - 1,
                                     seq_2_offset.first,
                                     seq_2_offset.second,
                                     block_ic_group - 1,
                                     seq_3_offset.first,
                                     seq_3_offset.second,
                                     block_oc_group - 1,
                                     MASTER_IFMAPMASK_ADDR,
                                     0);
  }

  insn::instruction Store(int64_t ddr_base_addr,
                          int64_t oc_group,
                          int64_t h,
                          int64_t w,
                          int64_t block_oc_group,
                          int64_t block_h,
                          int64_t block_w,
                          int64_t all_done)
  {
    auto seq_1_offset = split_exp_fra(bytes_ofmap * oc_group_size * w);
    auto seq_2_offset = split_exp_fra(bytes_ofmap * oc_group_size * w * h);

    if (DEBUG) {
      std::cout << "======== Store ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
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
    }

    return insn::store_iteration_3(ddr_base_addr,
                                   block_w * bytes_ofmap - 1,
                                   seq_1_offset.first,
                                   seq_1_offset.second,
                                   block_h - 1,
                                   seq_2_offset.first,
                                   seq_2_offset.second,
                                   block_oc_group - 1,
                                   MASTER_PSUM_ADDR,
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

template<int  SPARSE_ENABLE_                   = 0,
         bool IFMAP_NON_UNIFORM_QUANTIZATION_  = false,
         bool WEIGHT_NON_UNIFORM_QUANTIZATION_ = false,
         bool OUTLIER_ENABLE_                  = false,
         int  TYPE_A_                          = kInt4,
         int  TYPE_B_                          = kInt4,
         int  TYPE_ACCUMULATOR_                = kInt32,
         int  TYPE_OUTPUT_                     = kInt32,
         bool DEBUG_                           = false>
struct GemmOp {
  static constexpr int  SPARSE_ENABLE                   = SPARSE_ENABLE_;
  static constexpr bool WEIGHT_NON_UNIFORM_QUANTIZATION = WEIGHT_NON_UNIFORM_QUANTIZATION_;
  static constexpr bool IFMAP_NON_UNIFORM_QUANTIZATION  = IFMAP_NON_UNIFORM_QUANTIZATION_;
  static constexpr bool OUTLIER_ENABLE                  = OUTLIER_ENABLE_;
  static constexpr int  TYPE_A                          = TYPE_A_;
  static constexpr int  TYPE_B                          = TYPE_B_;
  static constexpr int  TYPE_ACCUMULATOR                = TYPE_ACCUMULATOR_;
  static constexpr int  TYPE_OUTPUT                     = TYPE_OUTPUT_;
  static constexpr int  DEBUG                           = DEBUG_;

  int k_group_size;
  int n_group_size;
  int k_group_scale;
  int ifmap_mask_ic_group_scale;

  float bytes_ifmap;
  float bytes_weight;
  float bytes_ofmap;

  struct Arguments {
    int      m;
    int      n;
    int      k;
    int      tile_m;
    int      block_n_group;
    int      block_k_group;
    uint64_t ifmap_base_addr;
    uint64_t weight_base_addr;
    uint64_t ofmap_base_addr;
    uint64_t ifmap_scale_base_addr   = 0;
    uint64_t weight_scale_base_addr  = 0;
    uint64_t outlier_index_base_addr = 0;
    uint64_t ifmap_mask_base_addr    = 0;
    uint64_t all_done                = 1;
  };

  GemmOp()
  {
    /* -------------------------------------------- Error checking -------------------------------------------- */
    if (TYPE_A == 4 && TYPE_B != 4 || TYPE_A != 4 && TYPE_B == 4) {
      std::runtime_error("Invalid input type, when one is INT16, the other must be INT16");
    }

    if ((IFMAP_NON_UNIFORM_QUANTIZATION && TYPE_A != 4) || (WEIGHT_NON_UNIFORM_QUANTIZATION && TYPE_B != 4)) {
      std::runtime_error("Invalid input type, non-uniform quantization only supports INT4");
    }

    if (TYPE_ACCUMULATOR == kFloat32) {
      if (TYPE_A == kInt16 || TYPE_B == kInt16) {
        std::runtime_error("ERROR: float accumulator is not supported for int16_t");
      }
    }

    if (WEIGHT_NON_UNIFORM_QUANTIZATION || IFMAP_NON_UNIFORM_QUANTIZATION) {
      if (TYPE_A == kInt16 || TYPE_B == kInt16) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for int16_t");
      }

      if (TYPE_A == kBfloat16 || TYPE_B == kBfloat16) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for bf16");
      }

      if (TYPE_A == kHalf || TYPE_B == kHalf) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for fp16");
      }

      if (TYPE_A == kInt8 && TYPE_B == kInt8) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for subbyte");
      }

      if (TYPE_ACCUMULATOR == kFloat32) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for non-float accumulator");
      }

      if (TYPE_OUTPUT == kFloat32) {
        std::runtime_error("ERROR: Non-uniform quantization is not supported for non-float output");
      }
    }

    if (OUTLIER_ENABLE) {
      if (TYPE_A == kInt16 || TYPE_B == kInt16) {
        std::runtime_error("ERROR: Outlier detection is not supported for int16_t");
      }

      if (TYPE_A == kBfloat16 || TYPE_B == kBfloat16) {
        std::runtime_error("ERROR: Outlier detection is not supported for bf16");
      }

      if (TYPE_A == kHalf || TYPE_B == kHalf) {
        std::runtime_error("ERROR: Outlier detection is not supported for fp16");
      }

      if (TYPE_ACCUMULATOR == kFloat32) {
        std::runtime_error("ERROR: Outlier detection is not supported for non-float accumulator");
      }

      if (TYPE_OUTPUT == kFloat32) {
        std::runtime_error("ERROR: Outlier detection is not supported for non-float output");
      }
    }

    /* --------------------------------------------- Type Decoder --------------------------------------------- */
    if (TYPE_A == 4 && TYPE_B == 4) {
      k_group_size = 16;
      bytes_ifmap  = 2;
      bytes_weight = 2;
    }
    else if (TYPE_A == 3 || TYPE_B == 3 || TYPE_A == 2 || TYPE_B == 2) {
      k_group_size = 16;
      bytes_ifmap  = 2;
      bytes_weight = 2;
    }
    else if ((TYPE_A == 1 && TYPE_B <= 1) || (TYPE_B == 1 && TYPE_A <= 1)) {
      k_group_size = 32;
      bytes_ifmap  = 1;
      bytes_weight = 1;
    }
    else {
      k_group_size = 64;
      bytes_ifmap  = 0.5;
      bytes_weight = 0.5;
    }
    bytes_ofmap  = 4;
    n_group_size = 32;

    if (SPARSE_ENABLE == 0) {
      k_group_scale = 1;
    }
    else if (SPARSE_ENABLE == 1) {
      k_group_scale = 2;
    }
  }

  std::vector<insn::instruction> operator()(const Arguments& args)
  {
    std::vector<insn::instruction> instruction_series;

    int m_iterations = ceil((double)args.m / (double)args.tile_m);
    int n_group      = ceil((double)args.n / (double)n_group_size);
    int k_group      = 0;

    if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8) || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
      k_group = ceil((double)args.k / (double)((k_group_size * k_group_scale) * 2));
    }
    else if (TYPE_A == kHalf && TYPE_B == kInt4 || TYPE_A == kBfloat16 && TYPE_B == kInt4) {
      k_group = ceil((double)args.k / (double)((k_group_size * k_group_scale) * 4));
    }
    else if ((TYPE_A == kInt8 && TYPE_B == kHalf) || (TYPE_A == kInt8 && TYPE_B == kBfloat16) || (TYPE_A == kInt4 && TYPE_B == kInt8)) {
      k_group = ceil((double)args.k / ((double)(k_group_size * k_group_scale) * 2));
    }
    else if ((TYPE_A == kInt4 && TYPE_B == kBfloat16) || (TYPE_A == kInt4 && TYPE_B == kHalf)) {
      k_group = ceil((double)args.k / ((double)(k_group_size * k_group_scale) * 4));
    }
    else {
      k_group = ceil((double)args.k / (double)(k_group_size * k_group_scale));
    }

    if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8) || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
      ifmap_mask_ic_group_scale = 2;
    }
    else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
      ifmap_mask_ic_group_scale = 4;
    }
    else {
      ifmap_mask_ic_group_scale = 1;
    }

    if (DEBUG) {
      std::cout << "m_iterations: " << m_iterations << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
    }

    int64_t m_start;
    int64_t i_ic, k_oc, k_ic;

    int ifmap_ddr_offset, weight_ddr_offset, ofmap_ddr_offset;
    int ifmap_scale_ddr_offset, weight_scale_ddr_offset;
    int outlier_index_ddr_offset;
    int ifmap_mask_ddr_offset;
    int n_iterations = ceil((double)n_group / (double)args.block_n_group);
    int k_iterations = ceil((double)k_group / (double)args.block_k_group);

    // convolution Config
    instruction_series.push_back(
      insn::pea_config(SPARSE_ENABLE, WEIGHT_NON_UNIFORM_QUANTIZATION, IFMAP_NON_UNIFORM_QUANTIZATION, OUTLIER_ENABLE, 0, 0, 0, 0));
    for (int n_iter = 0; n_iter < n_iterations; ++n_iter) {
      for (int m_iter = 0; m_iter < m_iterations; ++m_iter) {
        for (int k_iter = 0; k_iter < k_iterations; ++k_iter) {
          m_start = m_iter * args.tile_m;
          k_oc    = std::min(n_group - (n_iter * args.block_n_group), args.block_n_group);
          // real channels
          if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8) || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
            i_ic = std::min((k_group - (k_iter * args.block_k_group)) * 2, args.block_k_group * 2);
            k_ic = std::min(k_group - (k_iter * args.block_k_group), args.block_k_group);
          }
          else if (TYPE_A == kHalf && TYPE_B == kInt4 || TYPE_A == kBfloat16 && TYPE_B == kInt4) {
            i_ic = std::min((k_group - (k_iter * args.block_k_group)) * 4, args.block_k_group * 4);
            k_ic = std::min(k_group - (k_iter * args.block_k_group), args.block_k_group);
          }
          else if ((TYPE_A == kInt8 && TYPE_B == kHalf) || (TYPE_A == kInt8 && TYPE_B == kBfloat16)
                   || (TYPE_A == kInt4 && TYPE_B == kInt8)) {
            i_ic = std::min(k_group - (k_iter * args.block_k_group), args.block_k_group);
            k_ic = std::min((k_group - (k_iter * args.block_k_group)) * 2, args.block_k_group * 2);
          }
          else if ((TYPE_A == kInt4 && TYPE_B == kHalf) || (TYPE_A == kInt4 && TYPE_B == kBfloat16)) {
            i_ic = std::min(k_group - (k_iter * args.block_k_group), args.block_k_group);
            k_ic = std::min((k_group - (k_iter * args.block_k_group)) * 4, args.block_k_group * 4);
          }
          else {
            i_ic = std::min(k_group - (k_iter * args.block_k_group), args.block_k_group);
            k_ic = std::min(k_group - (k_iter * args.block_k_group), args.block_k_group);
          }
          // ddr offset calculation
          if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8) || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
            ifmap_ddr_offset =
              int64_t(bytes_ifmap * k_group_size * (args.m * ((k_iter * args.block_k_group * k_group_scale) * 2) + m_start));
            ifmap_scale_ddr_offset = int64_t((m_start) * 32);
            outlier_index_ddr_offset =
              int64_t(bytes_ifmap * k_group_size * (args.m * ((k_iter * args.block_k_group * k_group_scale) * 2) + m_start));
          }
          else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
            ifmap_ddr_offset =
              int64_t(bytes_ifmap * k_group_size * (args.m * ((k_iter * args.block_k_group * k_group_scale) * 4) + m_start));
            ifmap_scale_ddr_offset = int64_t((m_start) * 32);
            outlier_index_ddr_offset =
              int64_t(bytes_ifmap * k_group_size * (args.m * ((k_iter * args.block_k_group * k_group_scale) * 4) + m_start));
          }
          else {
            ifmap_ddr_offset = int64_t(bytes_ifmap * k_group_size * (args.m * (k_iter * args.block_k_group * k_group_scale) + m_start));
            ifmap_scale_ddr_offset = int64_t((m_start) * 32);
            outlier_index_ddr_offset =
              int64_t(bytes_ifmap * k_group_size * (args.m * (k_iter * args.block_k_group * k_group_scale) + m_start));
          }

          if ((TYPE_A == kInt8 && TYPE_B == kHalf) || (TYPE_A == kInt8 && TYPE_B == kBfloat16) || (TYPE_A == kInt4 && TYPE_B == kInt8)) {
            weight_ddr_offset     = int64_t(bytes_weight * n_group_size * k_group_size
                                        * ((k_group * 2) * (n_iter * args.block_n_group) + ((k_iter * args.block_k_group) * 2)));
            ifmap_mask_ddr_offset = int64_t(n_group_size * (k_group_size * k_group_scale * ifmap_mask_ic_group_scale)
                                            * ((k_group * 2) * (n_iter * args.block_n_group) + ((k_iter * args.block_k_group) * 2)) / 8);
          }
          else if ((TYPE_A == kInt4 && TYPE_B == kHalf) || (TYPE_A == kInt4 && TYPE_B == kBfloat16)) {
            weight_ddr_offset     = int64_t(bytes_weight * n_group_size * k_group_size
                                        * ((k_group * 4) * (n_iter * args.block_n_group) + ((k_iter * args.block_k_group) * 4)));
            ifmap_mask_ddr_offset = int64_t(n_group_size * (k_group_size * k_group_scale * ifmap_mask_ic_group_scale)
                                            * ((k_group * 4) * (n_iter * args.block_n_group) + ((k_iter * args.block_k_group) * 4)) / 8);
          }
          else {
            weight_ddr_offset     = int64_t(bytes_weight * n_group_size * k_group_size
                                        * (k_group * (n_iter * args.block_n_group) + (k_iter * args.block_k_group)));
            ifmap_mask_ddr_offset = int64_t(n_group_size * (k_group_size * k_group_scale * ifmap_mask_ic_group_scale)
                                            * (k_group * (n_iter * args.block_n_group) + (k_iter * args.block_k_group)) / 8);
          }

          weight_scale_ddr_offset = int64_t(2 * n_group_size * (n_iter * args.block_n_group));
          ofmap_ddr_offset        = int64_t(bytes_ofmap * n_group_size * (args.m * (n_iter * args.block_n_group) + m_start));
          // load ifmap
          if (SPARSE_ENABLE) {
            for (int i = 0; i < k_group_scale; ++i) {
              if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8)
                  || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
                if (i != 0) {
                  ifmap_ddr_offset += int64_t(bytes_ifmap * k_group_size * args.m);
                }
              }
              else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
                if (i != 0) {
                  ifmap_ddr_offset += int64_t(bytes_ifmap * k_group_size * args.m);
                }
              }
              else {
                if (i != 0) {
                  ifmap_ddr_offset += int64_t(bytes_ifmap * k_group_size * args.m);
                }
              }
              // std::cout << ifmap_ddr_offset << std::endl;
              instruction_series.push_back(
                LoadIfmap(args.ifmap_base_addr + ifmap_ddr_offset, k_group, args.m, i_ic, args.tile_m, MASTER_IFMAP_ADDR + i * 256));
            }
          }
          else {
            instruction_series.push_back(
              LoadIfmap(args.ifmap_base_addr + ifmap_ddr_offset, k_group, args.m, i_ic, args.tile_m, MASTER_IFMAP_ADDR));
          }
          // load weight
          int real_weight_k_group = 0;
          if (TYPE_A == kInt8 && TYPE_B == kInt4) {
            real_weight_k_group = args.k / k_group_size / 2;
          }
          else if (TYPE_A == kHalf && TYPE_B == kInt8) {
            real_weight_k_group = args.k / k_group_size / 2;
          }
          else if (TYPE_A == kHalf && TYPE_B == kInt4) {
            real_weight_k_group = args.k / k_group_size / 4;
          }
          else if (TYPE_A == kBfloat16 && TYPE_B == kInt8) {
            real_weight_k_group = args.k / k_group_size / 2;
          }
          else if (TYPE_A == kBfloat16 && TYPE_B == kInt4) {
            real_weight_k_group = args.k / k_group_size / 4;
          }
          else {
            real_weight_k_group = args.k / k_group_size;
          }
          instruction_series.push_back(LoadWeight(args.weight_base_addr + weight_ddr_offset, n_group, real_weight_k_group, k_oc, k_ic));
          // For per vector scale quantization
          if (((TYPE_A == kInt8 && TYPE_B == kInt8) || (TYPE_A == kInt4 && TYPE_B == kInt4) || (TYPE_A == kInt8 && TYPE_B == kInt4)
               || (TYPE_A == kInt4 && TYPE_B == kInt8))
              && TYPE_ACCUMULATOR == kFloat32) {
            instruction_series.push_back(LoadIfmapScale(args.ifmap_scale_base_addr + ifmap_scale_ddr_offset, args.tile_m));
            int repeat_times = 1;
            if (TYPE_A == kInt4 && TYPE_B == kInt8) {
              repeat_times = 2 * args.block_k_group;
            }
            else if (TYPE_A == kInt4 && TYPE_B == kInt4) {
              if (OUTLIER_ENABLE || WEIGHT_NON_UNIFORM_QUANTIZATION || IFMAP_NON_UNIFORM_QUANTIZATION) {
                repeat_times = args.block_k_group;
              }
            }
            else if (TYPE_A == kInt8 && TYPE_B == kInt8 && OUTLIER_ENABLE) {
              repeat_times = args.block_k_group;
            }
            else if (TYPE_A == kInt8 && TYPE_B == kInt4) {
              if (OUTLIER_ENABLE || WEIGHT_NON_UNIFORM_QUANTIZATION) {
                repeat_times = args.block_k_group;
              }
              else {
                repeat_times = 2 * args.block_k_group;
              }
            }
            instruction_series.push_back(
              LoadWeightScale(args.weight_scale_base_addr + weight_scale_ddr_offset, n_group, k_group, k_oc, repeat_times));
            // For outlier process
            if (OUTLIER_ENABLE) {
              if (SPARSE_ENABLE) {
                for (int i = 0; i < k_group_scale; ++i) {
                  if ((TYPE_A == kHalf && TYPE_B == kInt8) || (TYPE_A == kBfloat16 && TYPE_B == kInt8)
                      || (TYPE_A == kInt8 && TYPE_B == kInt4)) {
                    if (i != 0) {
                      outlier_index_ddr_offset += int64_t(bytes_ifmap * k_group_size * args.m);
                    }
                  }
                  else if ((TYPE_A == kHalf && TYPE_B == kInt4) || (TYPE_A == kBfloat16 && TYPE_B == kInt4)) {
                    if (i != 0) {
                      outlier_index_ddr_offset += int64_t(bytes_ifmap * k_group_size * args.m);
                    }
                  }
                  else {
                    if (i != 0) {
                      outlier_index_ddr_offset += int64_t(bytes_ifmap * k_group_size * args.m);
                    }
                  }
                  // std::cout << ifmap_ddr_offset << std::endl;
                  instruction_series.push_back(LoadOutlierIndex(args.outlier_index_base_addr + outlier_index_ddr_offset,
                                                                k_group,
                                                                args.m,
                                                                i_ic,
                                                                args.tile_m,
                                                                MASTER_OUTLIER_INDEX_ADDR + i * 256));
                }
              }
              else {
                instruction_series.push_back(LoadOutlierIndex(
                  args.outlier_index_base_addr + outlier_index_ddr_offset, k_group, args.m, i_ic, args.tile_m, MASTER_OUTLIER_INDEX_ADDR));
                if (DEBUG) {
                  std::cout << "==== INFO : Load Outlier index ====" << std::endl;
                  std::cout << "ddr_base_addr: " << args.outlier_index_base_addr + outlier_index_ddr_offset << std::endl;
                }
              }
            }
          }

          // For sparse
          if (SPARSE_ENABLE) {
            instruction_series.push_back(LoadIfmapMask(args.ifmap_mask_base_addr + ifmap_mask_ddr_offset, n_group, k_group, k_oc, k_ic));
          }

          int psum_number;
          if ((TYPE_A == kInt8 && TYPE_B == kHalf) || (TYPE_A == kInt8 && TYPE_B == kBfloat16) || (TYPE_A == kInt4 && TYPE_B == kInt8)
              || (TYPE_A == kInt4 && TYPE_B == kInt4 && (IFMAP_NON_UNIFORM_QUANTIZATION | WEIGHT_NON_UNIFORM_QUANTIZATION))) {
            psum_number = i_ic * k_oc * 2;
          }
          else if ((TYPE_A == kInt4 && TYPE_B == kHalf) || (TYPE_A == kInt4 && TYPE_B == kBfloat16)) {
            psum_number = i_ic * k_oc * 4;
          }
          else {
            psum_number = i_ic * k_oc;
          }
          if (OUTLIER_ENABLE) {
            psum_number *= 2;
          }
          instruction_series.push_back(insn::gemm_execute(TYPE_A,
                                                          TYPE_B,
                                                          TYPE_ACCUMULATOR - 5,
                                                          TYPE_OUTPUT - 5,
                                                          args.tile_m - 1,
                                                          k_oc - 1,
                                                          k_ic - 1,
                                                          0,
                                                          0,
                                                          0,
                                                          psum_number - 1,
                                                          k_iter != 0));
        }
        if (DEBUG) {
          std::cout << "m_iter: " << m_iter << " m_iterations: " << m_iterations << std::endl;
          std::cout << "n_iter: " << n_iter << " n_iterations: " << n_iterations << std::endl;
        }
        instruction_series.push_back(Store(args.ofmap_base_addr + ofmap_ddr_offset,
                                           n_group,
                                           args.m,
                                           args.block_n_group,
                                           args.tile_m,
                                           m_iter == m_iterations - 1 && n_iter == n_iterations - 1 && args.all_done));
      }
    }

    return instruction_series;
  }

  private:
  insn::instruction LoadIfmap(int64_t ddr_base_addr, int64_t k_group, int64_t m, int64_t block_k_group, int64_t tile_m, int64_t sram_addr)
  {
    auto seq_1_offset = split_exp_fra(bytes_ifmap * k_group_size * m * k_group_scale);

    if (DEBUG) {
      std::cout << "======== Load Ifmap ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "m: " << m << std::endl;
      std::cout << "tile_m: " << tile_m << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << tile_m << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_k_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    return insn::load_iteration_2(ddr_base_addr, tile_m - 1, seq_1_offset.first, seq_1_offset.second, block_k_group - 1, sram_addr, 0);
  }

  insn::instruction LoadIfmapScale(int64_t ddr_base_addr, int tile_m)
  {

    if (DEBUG) {
      std::cout << "======== Load Ifmap Scale ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "tile_m: " << tile_m << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << tile_m << std::endl;
      std::cout << "==========================" << std::endl;
    }

    return insn::load_iteration_2(ddr_base_addr, tile_m - 1, 0, 0, 0, MASTER_IFMAP_SCALE_ADDR, 0);
  }

  insn::instruction LoadWeight(int64_t ddr_base_addr, int n_group, int k_group, int block_n_group, int block_k_group)
  {
    // (n_group, k_group, 32, 32)
    auto seq_1_offset = split_exp_fra(bytes_weight * k_group_size * n_group_size);
    auto seq_2_offset = split_exp_fra(bytes_weight * k_group_size * n_group_size * k_group);

    if (DEBUG) {
      std::cout << "======== Load Weight ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << n_group_size << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_k_group << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << block_n_group << std::endl;
      std::cout << "==========================" << std::endl;
    }
    return insn::load_iteration_3<1>(ddr_base_addr,
                                     n_group_size - 1,
                                     seq_1_offset.first,
                                     seq_1_offset.second,
                                     block_k_group - 1,
                                     seq_2_offset.first,
                                     seq_2_offset.second,
                                     block_n_group - 1,
                                     MASTER_WEIGHT_ADDR,
                                     0);
  }

  insn::instruction LoadIfmapMask(int64_t ddr_base_addr, int n_group, int k_group, int block_n_group, int block_k_group)
  {
    auto seq_1_offset = split_exp_fra(int(k_group_size * n_group_size * k_group_scale / 8 * ifmap_mask_ic_group_scale));
    auto seq_2_offset = split_exp_fra(int(k_group_size * n_group_size * k_group * k_group_scale / 8 * ifmap_mask_ic_group_scale));

    if (DEBUG) {
      std::cout << "======== Load Ifmap Mask ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << n_group_size << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << k_group << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << n_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    return insn::load_iteration_3<1>(ddr_base_addr,
                                     n_group_size * k_group_size * k_group_scale * ifmap_mask_ic_group_scale / 256 - 1,
                                     seq_1_offset.first,
                                     seq_1_offset.second,
                                     block_k_group - 1,
                                     seq_2_offset.first,
                                     seq_2_offset.second,
                                     block_n_group - 1,
                                     MASTER_IFMAPMASK_ADDR,
                                     0);
  }

  insn::instruction LoadWeightScale(int64_t ddr_base_addr, int n_group, int k_group, int64_t block_n_group, int repeat_times)
  {
    auto seq_1_offset = split_exp_fra(2 * n_group_size);

    if (DEBUG) {
      std::cout << "======== Load Weight Scale ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << repeat_times * 2 - 1 << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_n_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    auto load_insn =
      insn::load_iteration_3<1>(ddr_base_addr, repeat_times * 2 - 1, 0, 0, block_n_group * 2 - 1, 0, 0, 0, MASTER_WEIGHT_SCALE_ADDR, 0);
    return load_insn;
  }

  insn::instruction
  LoadOutlierIndex(int64_t ddr_base_addr, int64_t k_group, int64_t m, int64_t block_k_group, int64_t tile_m, int64_t sram_addr)
  {
    auto seq_1_offset = split_exp_fra(bytes_ifmap * k_group_size * m * k_group_scale);

    if (DEBUG) {
      std::cout << "======== Load Outlier Index ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
      std::cout << "m: " << m << std::endl;
      std::cout << "block_k_group: " << block_k_group << std::endl;
      std::cout << "tile_m: " << tile_m << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << tile_m << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_k_group << std::endl;
    }

    return insn::load_iteration_2(ddr_base_addr, tile_m - 1, seq_1_offset.first, seq_1_offset.second, block_k_group - 1, sram_addr, 0);
  }

  insn::instruction Store(int64_t ddr_base_addr, int64_t n_group, int64_t m, int64_t block_n_group, int64_t tile_m, int all_done)
  {
    auto seq_1_offset = split_exp_fra(bytes_ofmap * n_group_size * m);

    if (DEBUG) {
      std::cout << "======== Store ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "m: " << m << std::endl;
      std::cout << "block_n_group: " << block_n_group << std::endl;
      std::cout << "tile_m: " << tile_m << std::endl;
      std::cout << "all_done: " << all_done << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << tile_m << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_n_group << std::endl;
    }

    return insn::store_iteration_2(
      ddr_base_addr, tile_m * bytes_ofmap - 1, seq_1_offset.first, seq_1_offset.second, block_n_group - 1, MASTER_PSUM_ADDR, all_done);
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

}  // namespace pea