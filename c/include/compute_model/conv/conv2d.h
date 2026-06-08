#pragma once

#include "common/file_utils.h"
#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/subbyte.h"
#include "compute_model/common/tensor.h"
#include "compute_model/mpt/mpt.h"
#include "compute_model/quant/custom_fma.h"
#include <cstring>
#include <typeinfo>

namespace compute_model {
namespace conv2d {

float as_float(uint32_t x)
{
  return *reinterpret_cast<float*>(&x);
}

float as_float(float x)
{
  return *reinterpret_cast<float*>(&x);
}

float as_float(int32_t x)
{
  return *reinterpret_cast<float*>(&x);
}

uint32_t as_uint(float x)
{
  return *reinterpret_cast<uint32_t*>(&x);
}

uint32_t as_uint(uint32_t x)
{
  return *reinterpret_cast<uint32_t*>(&x);
}

uint32_t as_uint(int32_t x)
{
  return *reinterpret_cast<uint32_t*>(&x);
}

using half     = compute_model::common::fp16::half;
using bfloat16 = compute_model::common::bf16::bfloat16;
using int4_t   = compute_model::common::subbyte::int4_t;

template<int  SPARSE_ENABLE_                   = 0,
         bool IFMAP_NON_UNIFORM_QUANTIZATION_  = false,
         bool WEIGHT_NON_UNIFORM_QUANTIZATION_ = false,
         bool OUTLIER_ENABLE_                  = false,
         typename TYPE_A                       = int4_t,
         typename TYPE_B                       = int4_t,
         typename TYPE_ACCUMULATOR             = int32_t,
         typename TYPE_OUTPUT                  = int32_t,
         bool DEBUG_                           = false>
struct Conv2dSim {

  static constexpr int  SPARSE_ENABLE                   = SPARSE_ENABLE_;
  static constexpr bool IFMAP_NON_UNIFORM_QUANTIZATION  = IFMAP_NON_UNIFORM_QUANTIZATION_;
  static constexpr bool WEIGHT_NON_UNIFORM_QUANTIZATION = WEIGHT_NON_UNIFORM_QUANTIZATION_;
  static constexpr bool OUTLIER_ENABLE                  = OUTLIER_ENABLE_;
  static constexpr int  DEBUG                           = DEBUG_;

  int ic_group_size;
  int oc_group_size;
  int ic_group_scale;

  float bytes_ifmap;
  float bytes_weight;
  float bytes_ofmap;

  int ifmap_mask_ic_group_scale;

  struct Arguments {
    tensor::Tensor<TYPE_OUTPUT>& ofmap;
    tensor::Tensor<TYPE_A>       ifmap;
    tensor::Tensor<TYPE_B>       weight;
    int                          stride_h;
    int                          stride_w;
    int                          pad_h;
    int                          pad_w;
    int                          dilation_h;
    int                          dilation_w;
    int                          ifmap_block_h;
    int                          ifmap_block_w;
    int                          weight_block_h;
    int                          weight_block_w;
    int                          block_ic_group;
    int                          block_oc_group;

    tensor::Tensor<int8_t> ifmap_mask    = tensor::Tensor<int8_t>();
    tensor::Tensor<half>   ifmap_scale   = tensor::Tensor<half>();
    tensor::Tensor<half>   weight_scale  = tensor::Tensor<half>();
    tensor::Tensor<int8_t> outlier_index = tensor::Tensor<int8_t>();
    tensor::Tensor<half>   outlier_scale = tensor::Tensor<half>();
  };

  Conv2dSim()
  {
    /* -------------------------------------------- Error checking -------------------------------------------- */
    if (typeid(TYPE_A) == typeid(int16_t) && typeid(TYPE_B) == typeid(int16_t)) {
      ic_group_size = 16;
      bytes_ifmap   = 2;
      bytes_weight  = 2;
    }
    else if (typeid(TYPE_A) == typeid(bfloat16) || typeid(TYPE_B) == typeid(bfloat16) || typeid(TYPE_A) == typeid(half)
             || typeid(TYPE_B) == typeid(half)) {
      ic_group_size = 16;
      if (typeid(TYPE_A) == typeid(int4_t)) {
        bytes_ifmap = 4;
      }
      else {
        bytes_ifmap = 2;
      }
      if (typeid(TYPE_B) == typeid(int4_t)) {
        bytes_weight = 4;
      }
      else {
        bytes_weight = 2;
      }
    }
    else if (((typeid(TYPE_A) == typeid(int8_t)) && (typeid(TYPE_B) == typeid(int8_t) || typeid(TYPE_B) == typeid(int4_t)))
             || (typeid(TYPE_B) == typeid(int8_t) && (typeid(TYPE_A) == typeid(int8_t) || typeid(TYPE_A) == typeid(int4_t)))) {
      ic_group_size = 32;
      if (typeid(TYPE_A) == typeid(int4_t)) {
        bytes_ifmap = 2;
      }
      else {
        bytes_ifmap = 1;
      }
      if (typeid(TYPE_B) == typeid(int4_t)) {
        bytes_weight = 2;
      }
      else {
        bytes_weight = 1;
      }
    }
    else {
      ic_group_size = 64;
      bytes_ifmap   = 1;
      bytes_weight  = 1;
    }
    oc_group_size = 32;

    if (SPARSE_ENABLE) {
      ic_group_scale = 2;
    }
    else {
      ic_group_scale = 1;
    }

    bytes_ofmap = 4;

    if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      if (typeid(TYPE_A) == typeid(int16_t) || typeid(TYPE_B) == typeid(int16_t)) {
        std::cerr << "ERROR: float accumulator is not supported for int16_t" << std::endl;
        exit(1);
      }
    }

    if (IFMAP_NON_UNIFORM_QUANTIZATION | WEIGHT_NON_UNIFORM_QUANTIZATION) {
      if (typeid(TYPE_A) == typeid(int16_t) || typeid(TYPE_B) == typeid(int16_t)) {
        std::cerr << "ERROR: Non-uniform quantization is not supported for int16_t" << std::endl;
        exit(1);
      }

      if (typeid(TYPE_A) == typeid(bfloat16) || typeid(TYPE_B) == typeid(bfloat16)) {
        std::cerr << "ERROR: Non-uniform quantization is not supported for bf16" << std::endl;
        exit(1);
      }

      if (typeid(TYPE_A) == typeid(half) || typeid(TYPE_B) == typeid(half)) {
        std::cerr << "ERROR: Non-uniform quantization is not supported for fp16" << std::endl;
        exit(1);
      }

      if (typeid(TYPE_ACCUMULATOR) != typeid(float)) {
        std::cerr << "ERROR: Non-uniform quantization is not supported for non-float accumulator" << std::endl;
        exit(1);
      }

      if (typeid(TYPE_OUTPUT) != typeid(float)) {
        std::cerr << "ERROR: Non-uniform quantization is not supported for non-float output" << std::endl;
        exit(1);
      }
    }

    if (OUTLIER_ENABLE) {
      if (typeid(TYPE_A) == typeid(int16_t) || typeid(TYPE_B) == typeid(int16_t)) {
        std::cerr << "ERROR: Outlier detection is not supported for int16_t" << std::endl;
        exit(1);
      }

      if (typeid(TYPE_A) == typeid(bfloat16) || typeid(TYPE_B) == typeid(bfloat16)) {
        std::cerr << "ERROR: Outlier detection is not supported for bf16" << std::endl;
        exit(1);
      }

      if (typeid(TYPE_A) == typeid(half) || typeid(TYPE_B) == typeid(half)) {
        std::cerr << "ERROR: Outlier detection is not supported for fp16" << std::endl;
        exit(1);
      }

      if (typeid(TYPE_ACCUMULATOR) != typeid(float)) {
        std::cerr << "ERROR: Outlier detection is not supported for non-float accumulator" << std::endl;
        exit(1);
      }

      if (typeid(TYPE_OUTPUT) != typeid(float)) {
        std::cerr << "ERROR: Outlier detection is not supported for non-float output" << std::endl;
        exit(1);
      }
    }
  }

  void operator()(Arguments args)
  {
    int32_t ifmap_h      = args.ifmap.shape()[1];
    int32_t ifmap_w      = args.ifmap.shape()[2];
    int32_t ic_group     = args.ifmap.shape()[0];
    int32_t weight_h     = args.weight.shape()[2];
    int32_t weight_w     = args.weight.shape()[3];
    int32_t oc_group     = args.weight.shape()[0];
    int32_t in_channels  = args.ifmap.shape()[0] * args.ifmap.shape()[3];
    int32_t out_channels = args.weight.shape()[0] * oc_group_size;

    bool weight_2_ifmap_2            = false;
    bool weight_4_ifmap_4            = false;
    bool weight_1_ifmap_2            = false;
    bool weight_1_ifmap_4            = false;
    int  weight_2_ifmap_2_identifier = 0;
    int  weight_4_ifmap_4_identifier = 0;
    int  weight_1_ifmap_2_identifier = 0;
    int  weight_1_ifmap_4_identifier = 0;

    if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int8_t))
        || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int8_t))
        || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t))) {
      assert(args.ifmap.shape()[3] == ic_group_size * ic_group_scale);
      assert(args.weight.shape()[4] == oc_group_size);
      assert(args.weight.shape()[5] == ic_group_size * 2);
      assert(args.ifmap.shape()[0] == args.weight.shape()[1] * 2);
      ic_group = ceil((double)in_channels / (double)((ic_group_size * ic_group_scale) * 2));

      weight_1_ifmap_2          = true;
      ifmap_mask_ic_group_scale = 2;
    }
    else if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int4_t))
             || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int4_t))) {
      assert(args.ifmap.shape()[3] == ic_group_size * ic_group_scale);
      assert(args.weight.shape()[4] == oc_group_size);
      assert(args.weight.shape()[5] == ic_group_size * 4);
      assert(args.ifmap.shape()[0] == args.weight.shape()[1] * 4);
      ic_group = ceil((double)in_channels / (double)((ic_group_size * ic_group_scale) * 4));

      weight_1_ifmap_4          = true;
      ifmap_mask_ic_group_scale = 4;
    }
    else if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(half))
             || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(bfloat16))
             || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))) {
      assert(args.ifmap.shape()[3] == ic_group_size * ic_group_scale * 2);
      assert(args.weight.shape()[4] == oc_group_size);
      assert(args.weight.shape()[5] == ic_group_size);
      assert(args.ifmap.shape()[0] * 2 == args.weight.shape()[1]);
      ic_group = ceil((double)in_channels / ((double)(ic_group_size * ic_group_scale) * 2));

      weight_2_ifmap_2          = true;
      ifmap_mask_ic_group_scale = 1;
    }
    else if (((typeid(TYPE_A) == typeid(int4_t)) && (typeid(TYPE_B) == typeid(half)))
             || ((typeid(TYPE_A) == typeid(int4_t)) && (typeid(TYPE_B) == typeid(bfloat16)))) {
      assert(args.ifmap.shape()[3] == ic_group_size * ic_group_scale * 4);
      assert(args.weight.shape()[4] == oc_group_size);
      assert(args.weight.shape()[5] == ic_group_size);
      assert(args.ifmap.shape()[0] * 4 == args.weight.shape()[1]);
      ic_group = ceil((double)in_channels / ((double)(ic_group_size * ic_group_scale) * 4));

      weight_4_ifmap_4          = true;
      ifmap_mask_ic_group_scale = 1;
    }
    else if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t))
             || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int4_t))) {
      assert(args.ifmap.shape()[3] == ic_group_size * ic_group_scale);
      assert(args.weight.shape()[4] == oc_group_size);
      assert(args.weight.shape()[5] == ic_group_size);
      ifmap_mask_ic_group_scale = 1;
    }
    else if ((typeid(TYPE_A) == typeid(int16_t) && typeid(TYPE_B) == typeid(int16_t))
             || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(bfloat16))
             || (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(half))) {
      assert(args.ifmap.shape()[3] == ic_group_size * ic_group_scale);
      assert(args.weight.shape()[4] == oc_group_size);
      assert(args.weight.shape()[5] == ic_group_size);
      ifmap_mask_ic_group_scale = 1;
    }
    else {
      assert(args.ifmap.shape()[3] == ic_group_size * ic_group_scale);
      assert(args.weight.shape()[4] == oc_group_size);
      assert(args.weight.shape()[5] == ic_group_size);
      ifmap_mask_ic_group_scale = 1;
    }

    if (((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t))
         || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int4_t)))
        && typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      assert(args.ifmap_scale.shape().size() == 2);
      assert(args.ifmap_scale.shape()[0] == args.ifmap.shape()[1]);
      assert(args.ifmap_scale.shape()[1] == args.ifmap.shape()[2]);
      assert(args.weight_scale.shape().size() == 4);
      assert(args.weight_scale.shape()[0] == args.weight.shape()[0]);
      assert(args.weight_scale.shape()[1] == args.weight.shape()[2]);
      assert(args.weight_scale.shape()[2] == args.weight.shape()[3]);
      assert(args.weight_scale.shape()[3] == args.weight.shape()[4]);
      assert(args.ifmap_scale.dtype == kHalf);
      assert(args.weight_scale.dtype == kHalf);
    }

    int32_t ofmap_h = (int32_t)floor((double)(ifmap_h + 2 * args.pad_h - args.dilation_h * (weight_h - 1) - 1) / double(args.stride_h) + 1);
    int32_t ofmap_w = (int32_t)floor((double)(ifmap_w + 2 * args.pad_w - args.dilation_w * (weight_w - 1) - 1) / double(args.stride_w) + 1);

    // 计算输出特征图分块尺寸
    int ofmap_block_h =
      floor((double)(args.ifmap_block_h + 2 * args.pad_h - args.dilation_h * (weight_h - 1) - 1) / (double)args.stride_h + 1);
    int ofmap_block_w =
      floor((double)(args.ifmap_block_w + 2 * args.pad_w - args.dilation_w * (weight_w - 1) - 1) / (double)args.stride_w + 1);

    // 计算循环次数
    int h_iterations        = ceil((double)ofmap_h / (double)ofmap_block_h);
    int w_iterations        = ceil((double)ofmap_w / (double)ofmap_block_w);
    int kh_iterations       = ceil((double)weight_h / (double)args.weight_block_h);
    int kw_iterations       = ceil((double)weight_w / (double)args.weight_block_w);
    int ic_group_iterations = ceil((double)ic_group / (double)args.block_ic_group);
    int oc_group_iterations = ceil((double)oc_group / (double)args.block_oc_group);

    if (DEBUG) {
      std::cout << "ifmap_shape: (" << ifmap_h << ", " << ifmap_w << ")" << std::endl;
      std::cout << "padding: (" << args.pad_h << ", " << args.pad_w << ")" << std::endl;
      std::cout << "stride: (" << args.stride_h << ", " << args.stride_w << ")" << std::endl;
      std::cout << "dilation: (" << args.dilation_h << ", " << args.dilation_w << ")" << std::endl;
      std::cout << "ofmap_h: " << ofmap_h << std::endl;
      std::cout << "ofmap_w: " << ofmap_w << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "ic_group_size: " << ic_group_size << std::endl;
      std::cout << "ic_group_scale: " << ic_group_scale << std::endl;
      std::cout << "h_iterations: " << h_iterations << std::endl;
      std::cout << "w_iterations: " << w_iterations << std::endl;
      std::cout << "kh_iterations: " << kh_iterations << std::endl;
      std::cout << "kw_iterations: " << kw_iterations << std::endl;
      std::cout << "ic_group_iterations: " << ic_group_iterations << std::endl;
      std::cout << "oc_group_iterations: " << oc_group_iterations << std::endl;
    }

    int64_t i_h_start, i_w_start, k_h_start, k_w_start, o_h_start, o_w_start;
    int64_t i_h, i_w, k_h, k_w, i_ic, k_oc, k_ic;
    int64_t pad_top, pad_left;
    int64_t ifmap_ddr_offset, weight_ddr_offset, ofmap_ddr_offset;
    int64_t ifmap_scale_ddr_offset, weight_scale_ddr_offset;
    int64_t outlier_index_ddr_offset;
    int64_t ifmap_mask_ddr_offset;

    for (int oc_iter = 0; oc_iter < oc_group_iterations; ++oc_iter) {
      for (int h_iter = 0; h_iter < h_iterations; ++h_iter) {
        for (int w_iter = 0; w_iter < w_iterations; ++w_iter) {

          // ofmap horizontal and vertical start index
          o_w_start = w_iter * ofmap_block_w;
          o_h_start = h_iter * ofmap_block_h;
          k_oc      = std::min(oc_group - (oc_iter * args.block_oc_group), args.block_oc_group);

          TYPE_ACCUMULATOR* ofmap_ptr = new TYPE_ACCUMULATOR[args.block_oc_group * ofmap_block_h * ofmap_block_w * oc_group_size];

          for (int ic_iter = 0; ic_iter < ic_group_iterations; ++ic_iter) {
            for (int kh_iter = 0; kh_iter < kh_iterations; ++kh_iter) {
              for (int kw_iter = 0; kw_iter < kw_iterations; ++kw_iter) {

                // real padding
                pad_left = w_iter == 0 ? std::max(args.pad_w - kw_iter * (args.weight_block_h * args.dilation_h), 0) : 0;
                pad_top  = h_iter == 0 ? std::max(args.pad_h - kh_iter * (args.weight_block_h * args.dilation_h), 0) : 0;

                // ifmap horizontal and vertical start index
                i_w_start = std::max(o_w_start * args.stride_w + kw_iter - args.pad_w, 0l);
                i_h_start = std::max(o_h_start * args.stride_h + kh_iter - args.pad_h, 0l);

                // real ifmap horizontal and vertical length
                i_h =
                  std::min((ofmap_block_h - 1) * args.stride_h + (args.weight_block_h * args.dilation_h) - pad_top, ifmap_h - i_h_start);
                i_w =
                  std::min((ofmap_block_w - 1) * args.stride_w + (args.weight_block_w * args.dilation_w) - pad_left, ifmap_w - i_w_start);

                // real channels
                if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int8_t))
                    || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int8_t))
                    || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t))) {
                  i_ic = std::min((ic_group - (ic_iter * args.block_ic_group)) * 2, args.block_ic_group * 2);
                  k_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                }
                else if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int4_t))
                         || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int4_t))) {
                  i_ic = std::min((ic_group - (ic_iter * args.block_ic_group)) * 4, args.block_ic_group * 4);
                  k_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                }
                else if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(half))
                         || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(bfloat16))
                         || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))) {
                  i_ic = std::min(ic_group - (ic_iter * args.block_ic_group), args.block_ic_group);
                  k_ic = std::min((ic_group - (ic_iter * args.block_ic_group)) * 2, args.block_ic_group * 2);
                }
                else if ((typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(half))
                         || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(bfloat16))) {
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
                k_w = std::min((int64_t)args.weight_block_w, weight_w - k_w_start);
                k_h = std::min((int64_t)args.weight_block_h, weight_h - k_h_start);

                // ddr offset calculation
                if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int8_t))
                    || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int8_t))
                    || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t))) {
                  ifmap_ddr_offset =
                    int64_t(bytes_ifmap * (ic_group_size * ic_group_scale)
                            * (ifmap_h * ifmap_w * ((ic_iter * args.block_ic_group) * 2) + i_h_start * ifmap_w + i_w_start));
                  ifmap_scale_ddr_offset = int64_t(2 * (i_h_start * ifmap_w + i_w_start));
                  outlier_index_ddr_offset =
                    int64_t((ic_group_size * ic_group_scale)
                            * (ifmap_h * ifmap_w * ((ic_iter * args.block_ic_group) * 2) + i_h_start * ifmap_w + i_w_start));
                }
                else if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int4_t))
                         || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int4_t))) {
                  ifmap_ddr_offset =
                    int64_t(bytes_ifmap * (ic_group_size * ic_group_scale)
                            * (ifmap_h * ifmap_w * ((ic_iter * args.block_ic_group) * 4) + i_h_start * ifmap_w + i_w_start));
                  ifmap_scale_ddr_offset = int64_t(2 * (i_h_start * ifmap_w + i_w_start));
                  outlier_index_ddr_offset =
                    int64_t((ic_group_size * ic_group_scale)
                            * (ifmap_h * ifmap_w * ((ic_iter * args.block_ic_group) * 4) + i_h_start * ifmap_w + i_w_start));
                }
                else {
                  ifmap_ddr_offset       = int64_t(bytes_ifmap * (ic_group_size * ic_group_scale)
                                             * (ifmap_h * ifmap_w * (ic_iter * args.block_ic_group) + i_h_start * ifmap_w + i_w_start));
                  ifmap_scale_ddr_offset = int64_t(2 * (i_h_start * ifmap_w + i_w_start));
                  if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t)) {
                    outlier_index_ddr_offset =
                      int64_t((ic_group_size * ic_group_scale * 2)
                              * (ifmap_h * ifmap_w * (ic_iter * args.block_ic_group) + i_h_start * ifmap_w + i_w_start));
                  }
                  else {
                    outlier_index_ddr_offset =
                      int64_t((ic_group_size * ic_group_scale)
                              * (ifmap_h * ifmap_w * (ic_iter * args.block_ic_group) + i_h_start * ifmap_w + i_w_start));
                  }
                }

                if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(half))
                    || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(bfloat16))
                    || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))) {
                  weight_ddr_offset     = int64_t(bytes_weight * oc_group_size * ic_group_size
                                              * (weight_h * weight_w * (ic_group * 2) * (oc_iter * args.block_oc_group)
                                                 + weight_h * weight_w * (ic_iter * 2) + k_h_start * weight_w + k_w_start));
                  ifmap_mask_ddr_offset = int64_t(oc_group_size * (ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale)
                                                  * (weight_h * weight_w * (ic_group * 2) * (oc_iter * args.block_oc_group)
                                                     + weight_h * weight_w * (ic_iter * 2) + k_h_start * weight_w + k_w_start));
                }
                else if ((typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(half))
                         || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(bfloat16))) {
                  weight_ddr_offset     = int64_t(bytes_weight * oc_group_size * ic_group_size
                                              * (weight_h * weight_w * (ic_group * 4) * (oc_iter * args.block_oc_group)
                                                 + weight_h * weight_w * (ic_iter * 4) + k_h_start * weight_w + k_w_start));
                  ifmap_mask_ddr_offset = int64_t(oc_group_size * (ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale)
                                                  * (weight_h * weight_w * (ic_group * 4) * (oc_iter * args.block_oc_group)
                                                     + weight_h * weight_w * (ic_iter * 4) + k_h_start * weight_w + k_w_start));
                }
                else {
                  weight_ddr_offset =
                    int64_t(bytes_weight * oc_group_size * ic_group_size
                            * (weight_h * weight_w * ic_group * (oc_iter * args.block_oc_group)
                               + weight_h * weight_w * (ic_iter * args.block_ic_group) + k_h_start * weight_w + k_w_start));
                  ifmap_mask_ddr_offset =
                    int64_t(oc_group_size * (ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale)
                            * (weight_h * weight_w * ic_group * (oc_iter * args.block_oc_group)
                               + weight_h * weight_w * (ic_iter * args.block_ic_group) + k_h_start * weight_w + k_w_start));
                }

                weight_scale_ddr_offset =
                  int64_t(2 * oc_group_size * (weight_h * weight_w * (oc_iter * args.block_oc_group) + k_h_start * weight_w + k_w_start));
                ofmap_ddr_offset = int64_t(bytes_ofmap * oc_group_size
                                           * (ofmap_h * ofmap_w * (oc_iter * args.block_oc_group) + o_h_start * ofmap_w + o_w_start));

                // temp buffer
                TYPE_A* ifmap_ptr = (TYPE_A*)(new char[int(i_ic * i_h * i_w * ic_group_size * ic_group_scale * bytes_ifmap)]);
                TYPE_B* weight_ptr =
                  (TYPE_B*)(new char[int(args.block_oc_group * k_ic * k_h * k_w * oc_group_size * ic_group_size * bytes_weight)]);
                int8_t* ifmap_mask_ptr = new int8_t[int(args.block_oc_group * k_ic * k_h * k_w * oc_group_size * ic_group_size
                                                        * ic_group_scale * ifmap_mask_ic_group_scale)];
                int     outlier_index_ifmap_icgroup_scale = 1;

                if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t)) {
                  outlier_index_ifmap_icgroup_scale = 2;
                }

                int8_t* outlier_index_ptr =
                  new int8_t[i_ic * i_h * i_w * ic_group_size * ic_group_scale * outlier_index_ifmap_icgroup_scale];
                half* ifmap_scale_ptr   = new half[i_h * i_w];
                half* weight_scale_ptr  = new half[args.block_oc_group * k_h * k_w * oc_group_size];
                half* outlier_scale_ptr = new half[i_h * i_w];

                LoadIfmap((char*)args.ifmap.data_ptr(), (char*)ifmap_ptr, ifmap_ddr_offset, ic_group, ifmap_h, ifmap_w, i_ic, i_h, i_w);

                LoadWeight((char*)args.weight.data_ptr(),
                           (char*)weight_ptr,
                           weight_ddr_offset,
                           oc_group,
                           ic_group,
                           weight_h,
                           weight_w,
                           args.block_oc_group,
                           k_ic,
                           k_h,
                           k_w);
                if (DEBUG) {
                  std::cout << "====** Conv Block **====" << std::endl;
                  std::cout << "oc_iter: " << oc_iter << " ic_iter: " << ic_iter << " h_iter: " << h_iter << " w_iter: " << w_iter
                            << " kh_iter: " << kh_iter << " kw_iter: " << kw_iter << std::endl;
                }

                if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t))
                    || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int4_t))
                    || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))
                    || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t))) {
                  if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                    LoadIfmapScale(
                      (char*)args.ifmap_scale.data_ptr(), (char*)ifmap_scale_ptr, ifmap_scale_ddr_offset, ifmap_h, ifmap_w, i_h, i_w);

                    LoadWeightScale((char*)args.weight_scale.data_ptr(),
                                    (char*)weight_scale_ptr,
                                    weight_scale_ddr_offset,
                                    oc_group,
                                    weight_h,
                                    weight_w,
                                    args.block_oc_group,
                                    args.weight_block_h,
                                    args.weight_block_w);
                    if (OUTLIER_ENABLE) {
                      LoadIfmapScale(
                        (char*)args.outlier_scale.data_ptr(), (char*)outlier_scale_ptr, ifmap_scale_ddr_offset, ifmap_h, ifmap_w, i_h, i_w);

                      LoadOutlierIndex((char*)args.outlier_index.data_ptr(),
                                       (char*)outlier_index_ptr,
                                       outlier_index_ddr_offset,
                                       ic_group,
                                       ifmap_h,
                                       ifmap_w,
                                       i_ic,
                                       i_h,
                                       i_w);
                    }
                  }
                }

                if (SPARSE_ENABLE) {
                  LoadIfmapMask((char*)args.ifmap_mask.data_ptr(),
                                (char*)ifmap_mask_ptr,
                                ifmap_mask_ddr_offset,
                                oc_group,
                                ic_group,
                                weight_h,
                                weight_w,
                                args.block_oc_group,
                                k_ic,
                                k_h,
                                k_w);
                }

                bool outlier_second_pass = false;

                if (OUTLIER_ENABLE && !outlier_second_pass) {
                  outlier_second_pass = true;
                }

                if (DEBUG) {
                  std::cout << "ifmap: " << std::endl;
                  for (int j = 0; j < i_ic * i_h * i_w; ++j) {
                    int real_ic_group_size = ic_group_size * ic_group_scale * bytes_ifmap;
                    for (int i = 0; i < real_ic_group_size; ++i) {
                      if (i == 0) {
                        std::cout << std::dec << std::setw(2) << std::setfill(' ') << j << " ";
                      }
                      std::cout << std::hex << std::setfill('0') << std::setw(2)
                                << (uint32_t)((uint8_t*)ifmap_ptr)[j * int(real_ic_group_size) + real_ic_group_size - 1 - i];
                      if (i == real_ic_group_size / 2) {
                        std::cout << " ";
                      }
                    }
                    std::cout << std::endl;
                  }
                  std::cout << std::endl;
                  std::cout << "weight: " << std::endl;
                  for (int j = 0; j < int(args.block_oc_group * k_ic * k_h * k_w * oc_group_size * ic_group_size * bytes_weight) / 32;
                       ++j) {
                    for (int i = 0; i < 32; ++i) {
                      if (i == 0) {
                        std::cout << std::dec << std::setw(2) << std::setfill(' ') << j << " ";
                      }
                      std::cout << std::hex << std::setfill('0') << std::setw(2) << (uint32_t)((uint8_t*)weight_ptr)[j * 32 + 31 - i];
                      if (i == 31) {
                        std::cout << " ";
                      }
                    }
                    std::cout << std::endl;
                  }
                  std::cout << std::endl;
                  std::cout << "ifmap sclae: " << std::endl;
                  for (int j = 0; j < i_h * i_w; ++j) {
                    for (int i = 0; i < 2; ++i) {
                      if (i == 0) {
                        std::cout << std::dec << std::setw(4) << std::setfill(' ') << j << " ";
                      }
                      std::cout << std::hex << std::setfill('0') << std::setw(2) << (uint32_t)((uint8_t*)ifmap_scale_ptr)[j * 2 + 1 - i];
                    }
                    std::cout << std::endl;
                  }
                  std::cout << std::endl;
                  std::cout << "weight scale: " << std::endl;
                  for (int j = 0; j < args.block_oc_group * k_h * k_w * oc_group_size; ++j) {
                    for (int i = 0; i < 2; ++i) {
                      if (i == 0) {
                        std::cout << std::dec << std::setw(4) << std::setfill(' ') << j << " ";
                      }
                      std::cout << std::hex << std::setfill('0') << std::setw(2) << (uint32_t)((uint8_t*)weight_scale_ptr)[j * 2 + 1 - i];
                    }
                    std::cout << std::endl;
                  }
                  std::cout << std::endl;
                  if (OUTLIER_ENABLE) {
                    std::cout << "outlier index: " << std::endl;
                    for (int j = 0; j < i_ic * i_h * i_w; ++j) {
                      for (int i = 0; i < ic_group_size * ic_group_scale * outlier_index_ifmap_icgroup_scale; ++i) {
                        if (i == 0) {
                          std::cout << std::dec << std::setw(4) << std::setfill(' ') << j << " ";
                        }
                        int num = 0;
                        for (int k = 0; k < 8; ++k) {
                          num +=
                            ((uint8_t*)
                               outlier_index_ptr)[j * ic_group_size * ic_group_scale * outlier_index_ifmap_icgroup_scale
                                                  + ic_group_size * ic_group_scale * outlier_index_ifmap_icgroup_scale - 1 - i * 8 + k - 7]
                            << k;
                        }
                        std::cout << std::hex << std::setfill('0') << std::setw(2) << num;
                        if (i == ic_group_size * ic_group_scale * outlier_index_ifmap_icgroup_scale / 8 / 2 - 1) {
                          std::cout << " ";
                        }
                      }
                      std::cout << std::endl;
                    }
                    std::cout << std::endl;
                    std::cout << "outlier sclae: " << std::endl;
                    for (int j = 0; j < i_h * i_w; ++j) {
                      for (int i = 0; i < 2; ++i) {
                        if (i == 0) {
                          std::cout << std::dec << std::setw(4) << std::setfill(' ') << j << " ";
                        }
                        std::cout << std::hex << std::setfill('0') << std::setw(2)
                                  << (uint32_t)((uint8_t*)outlier_scale_ptr)[j * 2 + 1 - i];
                      }
                      std::cout << std::endl;
                    }
                    std::cout << std::endl;
                  }

                  if (SPARSE_ENABLE) {
                    std::cout << "ifmap mask: " << std::endl;
                    for (int j = 0; j < int(args.block_oc_group * k_ic * k_h * k_w * oc_group_size); ++j) {
                      for (int i = 0; i < ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale / 8; ++i) {
                        if (i == 0) {
                          std::cout << std::dec << std::setw(2) << std::setfill(' ') << j << " ";
                        }
                        int num = 0;
                        for (int k = 0; k < 8; ++k) {
                          num +=
                            ((uint8_t*)ifmap_mask_ptr)[j * ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale
                                                       + ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale - 1 - i * 8 + k - 7]
                            << k;
                        }
                        std::cout << std::hex << std::setfill('0') << std::setw(2) << num;
                        if (i == ic_group_size * ic_group_scale * ifmap_mask_ic_group_scale / 8 / 2 - 1) {
                          std::cout << " ";
                        }
                      }
                      std::cout << std::endl;
                    }
                    std::cout << std::endl;
                  }
                }

                if (DEBUG) {
                  std::cout << " ==== Start Block Conv Exe ==== \n";
                }
                for (int block_oc_iter = 0; block_oc_iter < args.block_oc_group; ++block_oc_iter) {
                  for (int block_ic_iter = 0; block_ic_iter < args.block_ic_group; ++block_ic_iter) {
                    for (int block_kh_iter = 0; block_kh_iter < args.weight_block_h; ++block_kh_iter) {
                      for (int block_kw_iter = 0; block_kw_iter < args.weight_block_w; ++block_kw_iter) {
                        for (int block_h_iter = 0; block_h_iter < ofmap_block_h; ++block_h_iter) {
                          for (int block_w_iter = 0; block_w_iter < ofmap_block_w; ++block_w_iter) {
                            for (int oc = 0; oc < oc_group_size; ++oc) {
                              int psum_width_read_cnt     = block_w_iter;
                              int psum_height_read_cnt    = block_h_iter;
                              int weight_width_read_cnt   = block_kw_iter;
                              int weight_height_read_cnt  = block_kh_iter;
                              int weight_icgroup_read_cnt = block_ic_iter;
                              int weight_ocgroup_read_cnt = block_oc_iter;
                              int ifmap_icgroup_read_cnt  = block_ic_iter;

                              if (weight_1_ifmap_2 && weight_1_ifmap_2_identifier) {
                                ifmap_icgroup_read_cnt += 1;
                              }

                              if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier != 0) {
                                ifmap_icgroup_read_cnt += weight_1_ifmap_4_identifier;
                              }

                              if (weight_2_ifmap_2 && weight_2_ifmap_2_identifier) {
                                weight_icgroup_read_cnt += 1;
                              }

                              if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier != 0) {
                                weight_icgroup_read_cnt += weight_4_ifmap_4_identifier;
                              }

                              int ifmap_horizontal_offset = psum_width_read_cnt * args.stride_w + weight_width_read_cnt * args.dilation_w;
                              int ifmap_vertical_offset   = psum_height_read_cnt * args.stride_h + weight_height_read_cnt * args.dilation_h;
                              int ifmap_col_nopad         = ifmap_horizontal_offset - pad_left;
                              int ifmap_row_nopad         = ifmap_vertical_offset - pad_top;
                              int ifmap_local_idx         = 0;
                              int ifmap_scale_local_idx   = (ifmap_col_nopad + ifmap_row_nopad * i_w);

                              if (weight_2_ifmap_2) {
                                ifmap_local_idx = (ifmap_col_nopad + ifmap_row_nopad * i_w + ifmap_icgroup_read_cnt * i_h * i_w)
                                                  * ic_group_size * ic_group_scale * 2;
                              }
                              else if (weight_4_ifmap_4) {
                                ifmap_local_idx = (ifmap_col_nopad + ifmap_row_nopad * i_w + ifmap_icgroup_read_cnt * i_h * i_w)
                                                  * ic_group_size * ic_group_scale * 4;
                              }
                              else {
                                ifmap_local_idx = (ifmap_col_nopad + ifmap_row_nopad * i_w + ifmap_icgroup_read_cnt * i_h * i_w)
                                                  * ic_group_size * ic_group_scale;
                              }

                              bool ifmap_read_zero = ifmap_horizontal_offset < pad_left || ifmap_col_nopad >= i_w
                                                     || ifmap_vertical_offset < pad_top || ifmap_row_nopad >= i_h;

                              bool psum_read_zero;
                              if (kh_iter != 0 || kw_iter != 0 || ic_iter != 0) {
                                psum_read_zero = 0;
                              }
                              else if (weight_icgroup_read_cnt != 0 || weight_height_read_cnt != 0 || weight_width_read_cnt != 0
                                       || (OUTLIER_ENABLE && (!outlier_second_pass)) || (weight_1_ifmap_2 && weight_1_ifmap_2_identifier)
                                       || (weight_1_ifmap_4 && weight_1_ifmap_4_identifier != 0)
                                       || (weight_2_ifmap_2 && weight_2_ifmap_2_identifier)
                                       || (weight_4_ifmap_4 && weight_4_ifmap_4_identifier != 0)) {
                                psum_read_zero = 0;
                              }
                              else {
                                psum_read_zero = 1;
                              }

                              int weight_local_idx       = 0;
                              int weight_scale_local_idx = (weight_width_read_cnt + weight_height_read_cnt * args.weight_block_w
                                                            + weight_ocgroup_read_cnt * args.weight_block_w * args.weight_block_h)
                                                             * oc_group_size
                                                           + oc;
                              int ifmap_mask_local_idx = 0;
                              if (weight_1_ifmap_2) {
                                weight_local_idx = (weight_width_read_cnt + weight_height_read_cnt * args.weight_block_w
                                                    + weight_icgroup_read_cnt * args.weight_block_w * args.weight_block_h
                                                    + weight_ocgroup_read_cnt * args.weight_block_w * args.weight_block_h * k_ic)
                                                     * oc_group_size * ic_group_size * 2
                                                   + oc * ic_group_size * 2;
                                ifmap_mask_local_idx = (weight_width_read_cnt + weight_height_read_cnt * args.weight_block_w
                                                        + weight_icgroup_read_cnt * args.weight_block_w * args.weight_block_h
                                                        + weight_ocgroup_read_cnt * args.weight_block_w * args.weight_block_h * k_ic)
                                                         * oc_group_size * ic_group_size * ic_group_scale * 2
                                                       + oc * ic_group_size * ic_group_scale * 2;
                              }
                              else if (weight_1_ifmap_4) {
                                weight_local_idx = (weight_width_read_cnt + weight_height_read_cnt * args.weight_block_w
                                                    + weight_icgroup_read_cnt * args.weight_block_w * args.weight_block_h
                                                    + weight_ocgroup_read_cnt * args.weight_block_w * args.weight_block_h * k_ic)
                                                     * oc_group_size * ic_group_size * 4
                                                   + oc * ic_group_size * 4;
                                ifmap_mask_local_idx = (weight_width_read_cnt + weight_height_read_cnt * args.weight_block_w
                                                        + weight_icgroup_read_cnt * args.weight_block_w * args.weight_block_h
                                                        + weight_ocgroup_read_cnt * args.weight_block_w * args.weight_block_h * k_ic)
                                                         * oc_group_size * ic_group_size * ic_group_scale * 4
                                                       + oc * ic_group_size * ic_group_scale * 4;
                              }
                              else {
                                weight_local_idx = (weight_width_read_cnt + weight_height_read_cnt * args.weight_block_w
                                                    + weight_icgroup_read_cnt * args.weight_block_w * args.weight_block_h
                                                    + weight_ocgroup_read_cnt * args.weight_block_w * args.weight_block_h * k_ic)
                                                     * oc_group_size * ic_group_size
                                                   + oc * ic_group_size;
                                ifmap_mask_local_idx = (weight_width_read_cnt + weight_height_read_cnt * args.weight_block_w
                                                        + weight_icgroup_read_cnt * args.weight_block_w * args.weight_block_h
                                                        + weight_ocgroup_read_cnt * args.weight_block_w * args.weight_block_h * k_ic)
                                                         * oc_group_size * ic_group_size * ic_group_scale
                                                       + oc * ic_group_size * ic_group_scale;
                              }

                              int psum_local_idx =
                                (psum_width_read_cnt + psum_height_read_cnt * ofmap_block_w + block_oc_iter * ofmap_block_h * ofmap_block_w)
                                  * oc_group_size
                                + oc;
                              uint32_t psum = psum_read_zero ? 0 : as_uint(ofmap_ptr[psum_local_idx]);

                              if (!ifmap_read_zero || !psum_read_zero) {
                                if (typeid(TYPE_A) == typeid(int16_t) && typeid(TYPE_B) == typeid(int16_t)) {
                                  ofmap_ptr[psum_local_idx] = mpt_int16(ifmap_read_zero,
                                                                        (int16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (int16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        psum);
                                }

                                if (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(half)) {
                                  ofmap_ptr[psum_local_idx] = mpt_fpxfp(ifmap_read_zero,
                                                                        (uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        oc == 0);
                                }

                                if (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(bfloat16)) {
                                  ofmap_ptr[psum_local_idx] = mpt_fpxbf(ifmap_read_zero,
                                                                        (uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum));
                                }

                                if (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int8_t)) {
                                  ofmap_ptr[psum_local_idx] = mpt_fpxi8(ifmap_read_zero,
                                                                        (uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        weight_1_ifmap_2_identifier);
                                }

                                if (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int4_t)) {
                                  ofmap_ptr[psum_local_idx] = mpt_fpxi4(ifmap_read_zero,
                                                                        (uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        weight_1_ifmap_4_identifier,
                                                                        oc == 0);
                                }

                                if (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t)) {
                                  if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                                    ofmap_ptr[psum_local_idx] = as_float(mpt_i8xi8(ifmap_read_zero,
                                                                                   (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                                   (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                                   (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                                   (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                                   as_uint(psum),
                                                                                   ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                                   weight_scale_ptr[weight_scale_local_idx],
                                                                                   outlier_scale_ptr[ifmap_scale_local_idx],
                                                                                   outlier_second_pass, oc == 0));
                                  }
                                  else {
                                    ofmap_ptr[psum_local_idx] = mpt_i8xi8(ifmap_read_zero,
                                                                          (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                          (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                          (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                          as_uint(psum),
                                                                          ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                          weight_scale_ptr[weight_scale_local_idx],
                                                                          outlier_scale_ptr[ifmap_scale_local_idx],
                                                                          false);
                                  }
                                }

                                if (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t)) {
                                  if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                                    ofmap_ptr[psum_local_idx] = as_float(mpt_i8xi4(ifmap_read_zero,
                                                                                   (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                                   (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                                   (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                                   (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                                   psum,
                                                                                   ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                                   weight_scale_ptr[weight_scale_local_idx],
                                                                                   outlier_scale_ptr[ifmap_scale_local_idx],
                                                                                   weight_1_ifmap_2_identifier,
                                                                                   outlier_second_pass,
                                                                                   oc == 0));
                                  }
                                  else {
                                    ofmap_ptr[psum_local_idx] = mpt_i8xi4(ifmap_read_zero,
                                                                          (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                          (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                          (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                          psum,
                                                                          ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                          weight_scale_ptr[weight_scale_local_idx],
                                                                          outlier_scale_ptr[ifmap_scale_local_idx],
                                                                          weight_1_ifmap_2_identifier);
                                  }
                                }

                                if (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(half)) {
                                  ofmap_ptr[psum_local_idx] = mpt_i8xfp(ifmap_read_zero,
                                                                        (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        weight_2_ifmap_2_identifier);
                                }

                                if (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(bfloat16)) {
                                  ofmap_ptr[psum_local_idx] = mpt_i8xbf(ifmap_read_zero,
                                                                        (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        weight_2_ifmap_2_identifier);
                                }

                                if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int4_t)) {
                                  if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                                    ofmap_ptr[psum_local_idx] = as_float(mpt_i4xi4(ifmap_read_zero,
                                                                                   (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                                   (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                                   (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                                   (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                                   psum,
                                                                                   ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                                   weight_scale_ptr[weight_scale_local_idx],
                                                                                   outlier_scale_ptr[ifmap_scale_local_idx],
                                                                                   outlier_second_pass,
                                                                                   oc == 0));
                                  }
                                  else {
                                    ofmap_ptr[psum_local_idx] = mpt_i4xi4(ifmap_read_zero,
                                                                          (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                          (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                          (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                          psum,
                                                                          ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                          weight_scale_ptr[weight_scale_local_idx],
                                                                          outlier_scale_ptr[ifmap_scale_local_idx],
                                                                          false);
                                  }
                                }

                                if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(half)) {
                                  ofmap_ptr[psum_local_idx] = mpt_i4xfp(ifmap_read_zero,
                                                                        (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        weight_4_ifmap_4_identifier,
                                                                        oc == 0);
                                }

                                if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(bfloat16)) {
                                  ofmap_ptr[psum_local_idx] = mpt_i4xbf(ifmap_read_zero,
                                                                        (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        weight_4_ifmap_4_identifier,
                                                                        oc == 0);
                                }

                                if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t)) {
                                  if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                                    ofmap_ptr[psum_local_idx] = as_float(mpt_i4xi8(ifmap_read_zero,
                                                                                   (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                                   (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                                   (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                                   (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                                   psum,
                                                                                   ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                                   weight_scale_ptr[weight_scale_local_idx],
                                                                                   outlier_scale_ptr[ifmap_scale_local_idx],
                                                                                   weight_2_ifmap_2_identifier,
                                                                                   outlier_second_pass,
                                                                                   oc == 0));
                                  }
                                  else {
                                    ofmap_ptr[psum_local_idx] = mpt_i4xi8(ifmap_read_zero,
                                                                          (int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                          (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                          (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                          psum,
                                                                          ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                          weight_scale_ptr[weight_scale_local_idx],
                                                                          outlier_scale_ptr[ifmap_scale_local_idx],
                                                                          weight_2_ifmap_2_identifier,
                                                                          false,
                                                                          oc == 0);
                                  }
                                }

                                if (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(half)) {
                                  ofmap_ptr[psum_local_idx] = mpt_bfxfp(ifmap_read_zero,
                                                                        (uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum));
                                }

                                if (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(bfloat16)) {
                                  ofmap_ptr[psum_local_idx] = mpt_bfxbf(ifmap_read_zero,
                                                                        (uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum));
                                }

                                if (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int8_t)) {
                                  ofmap_ptr[psum_local_idx] = mpt_bfxi8(ifmap_read_zero,
                                                                        (uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        weight_1_ifmap_2_identifier);
                                }

                                if (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int4_t)) {
                                  ofmap_ptr[psum_local_idx] = mpt_bfxi4(ifmap_read_zero,
                                                                        (uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                        (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                        (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                        as_float(psum),
                                                                        weight_1_ifmap_4_identifier);
                                }
                              }
                              else {
                                ofmap_ptr[psum_local_idx] = 0;
                              }
                            }
                          }
                        }
                        if (DEBUG) {
                          std::cout << "==== Conv Execute ====" << std::endl;
                          std::cout << "block_oc_iter: " << block_oc_iter << " block_ic_iter: " << block_ic_iter
                                    << " block_kh_iter: " << block_kh_iter << " block_kw_iter: " << block_kw_iter
                                    << " outlier_second_pass: " << outlier_second_pass << " pad_left: " << pad_left
                                    << " pad_top: " << pad_top << std::endl;
                          std::cout << "ofmap: " << std::endl;
                          for (int j = 0; j < int(args.block_oc_group * ofmap_block_h * ofmap_block_w * oc_group_size * bytes_ofmap) / 128;
                               ++j) {
                            for (int i = 0; i < 128; ++i) {
                              if (i == 0) {
                                std::cout << std::dec << std::setw(2) << std::setfill(' ') << j << " ";
                              }
                              std::cout << std::hex << std::setfill('0') << std::setw(2)
                                        << (uint32_t)((uint8_t*)ofmap_ptr)[j * 128 + 127 - i];
                            }
                            std::cout << std::endl;
                          }
                        }

                        if (weight_1_ifmap_2 && (!weight_1_ifmap_2_identifier)) {
                          if ((typeid(TYPE_A) == typeid(int8_t)) && (typeid(TYPE_B) == typeid(int4_t)) && OUTLIER_ENABLE) {
                            if (outlier_second_pass == false) {
                              weight_1_ifmap_2_identifier = 1;
                              block_kw_iter               = block_kw_iter - 1;
                            }
                            else {
                              block_kw_iter = block_kw_iter - 1;
                            }
                          }
                          else {
                            weight_1_ifmap_2_identifier = 1;
                            block_kw_iter               = block_kw_iter - 1;
                          }
                        }
                        else if (weight_1_ifmap_2 && (weight_1_ifmap_2_identifier)) {
                          if ((typeid(TYPE_A) == typeid(int8_t)) && (typeid(TYPE_B) == typeid(int4_t)) && OUTLIER_ENABLE) {
                            if (outlier_second_pass == false) {
                              weight_1_ifmap_2_identifier = 0;
                            }
                            else {
                              block_kw_iter = block_kw_iter - 1;
                            }
                          }
                          else {
                            weight_1_ifmap_2_identifier = 0;
                          }
                        }

                        if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier == 0) {
                          weight_1_ifmap_4_identifier = 1;
                          block_kw_iter               = block_kw_iter - 1;
                        }
                        else if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier == 1) {
                          weight_1_ifmap_4_identifier = 2;
                          block_kw_iter               = block_kw_iter - 1;
                        }
                        else if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier == 2) {
                          weight_1_ifmap_4_identifier = 3;
                          block_kw_iter               = block_kw_iter - 1;
                        }
                        else if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier == 3) {
                          weight_1_ifmap_4_identifier = 0;
                        }

                        if (weight_2_ifmap_2 && !weight_2_ifmap_2_identifier) {
                          if ((typeid(TYPE_A) == typeid(int4_t)) && (typeid(TYPE_B) == typeid(int8_t)) && OUTLIER_ENABLE) {
                            if (outlier_second_pass == false) {
                              if (block_kh_iter == args.weight_block_h - 1 && block_kw_iter == args.weight_block_w - 1) {
                                weight_2_ifmap_2_identifier = 1;
                                block_kh_iter               = 0;
                                block_kw_iter               = -1;
                              }
                            }
                            else {
                              block_kw_iter = block_kw_iter - 1;
                            }
                          }
                          else {
                            if (block_kh_iter == args.weight_block_h - 1 && block_kw_iter == args.weight_block_w - 1) {
                              weight_2_ifmap_2_identifier = 1;
                              block_kw_iter               = -1;
                              block_kh_iter               = 0;
                            }
                          }
                        }
                        else if (weight_2_ifmap_2 && weight_2_ifmap_2_identifier) {
                          if ((typeid(TYPE_A) == typeid(int4_t)) && (typeid(TYPE_B) == typeid(int8_t)) && OUTLIER_ENABLE) {
                            if (outlier_second_pass == false) {
                              if (block_kh_iter == args.weight_block_h - 1 && block_kw_iter == args.weight_block_w - 1) {
                                weight_2_ifmap_2_identifier = 0;
                              }
                            }
                            else {
                              block_kw_iter = block_kw_iter - 1;
                            }
                          }
                          else {
                            if (block_kh_iter == args.weight_block_h - 1 && block_kw_iter == args.weight_block_w - 1) {
                              weight_2_ifmap_2_identifier = 0;
                            }
                          }
                        }

                        if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier == 0 && block_kh_iter == args.weight_block_h - 1
                            && block_kw_iter == args.weight_block_w - 1) {
                          weight_4_ifmap_4_identifier = 1;
                          block_kw_iter               = -1;
                          block_kh_iter               = 0;
                        }
                        else if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier == 1 && block_kh_iter == args.weight_block_h - 1
                                 && block_kw_iter == args.weight_block_w - 1) {
                          weight_4_ifmap_4_identifier = 2;
                          block_kw_iter               = -1;
                          block_kh_iter               = 0;
                        }
                        else if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier == 2 && block_kh_iter == args.weight_block_h - 1
                                 && block_kw_iter == args.weight_block_w - 1) {
                          weight_4_ifmap_4_identifier = 3;
                          block_kw_iter               = -1;
                          block_kh_iter               = 0;
                        }
                        else if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier == 3 && block_kh_iter == args.weight_block_h - 1
                                 && block_kw_iter == args.weight_block_w - 1) {
                          weight_4_ifmap_4_identifier = 0;
                        }

                        if (OUTLIER_ENABLE && outlier_second_pass) {
                          outlier_second_pass = false;
                          if ((!weight_1_ifmap_2) && (!weight_2_ifmap_2)) {
                            block_kw_iter = block_kw_iter - 1;
                          }
                        }
                        else if (OUTLIER_ENABLE && (!outlier_second_pass)) {
                          if (block_kw_iter == args.weight_block_w - 1 && block_kh_iter == args.weight_block_h - 1
                              && ic_iter == ic_group_iterations - 1) {
                            outlier_second_pass = false;
                          }
                          else {
                            outlier_second_pass = true;
                          }
                        }
                      }
                    }
                  }
                }

                if (ic_iter == ic_group_iterations - 1 && kh_iter == kh_iterations - 1 && kw_iter == kw_iterations - 1) {
                  StoreOfmap((char*)args.ofmap.data_ptr(),
                             (char*)ofmap_ptr,
                             ofmap_ddr_offset,
                             oc_group,
                             ofmap_h,
                             ofmap_w,
                             args.block_oc_group,
                             ofmap_block_h,
                             ofmap_block_w);
                }
                delete ifmap_ptr;
                delete weight_ptr;
                delete ifmap_mask_ptr;
                delete outlier_index_ptr;
                delete ifmap_scale_ptr;
                delete weight_scale_ptr;
                delete outlier_scale_ptr;
              }
            }
          }
          delete ofmap_ptr;
        }
      }
    }
  }

  void LoadIfmap(char*   ddr_ptr,
                 char*   sram_ptr,
                 int64_t ddr_base_addr,
                 int64_t ic_group,
                 int64_t h,
                 int64_t w,
                 int64_t block_ic_group,
                 int64_t block_h,
                 int64_t block_w)
  {
    int seq_1_offset = bytes_ifmap * ic_group_size * ic_group_scale * w;
    int seq_2_offset = bytes_ifmap * ic_group_size * ic_group_scale * h * w;
    int burst_0      = typeid(TYPE_A) == typeid(int4_t) ? block_w * ic_group_scale * 2 : block_w * ic_group_scale;
    int burst_1      = block_h;
    int burst_2      = block_ic_group;

    if (DEBUG) {
      std::cout << "==== Load Ifmap ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "burst_2: " << burst_2 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "seq_2_offset: " << seq_2_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_2_iter = 0; burst_2_iter < burst_2; ++burst_2_iter) {
      for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
        int sram_offset = (burst_1_iter * burst_0 + burst_2_iter * burst_1 * burst_0) * 32;
        int ddr_offset  = burst_1_iter * seq_1_offset + burst_2_iter * seq_2_offset;
        std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * 32);
      }
    }
  }

  void LoadWeight(char*   ddr_ptr,
                  char*   sram_ptr,
                  int64_t ddr_base_addr,
                  int64_t oc_group,
                  int64_t ic_group,
                  int64_t h,
                  int64_t w,
                  int64_t block_oc_group,
                  int64_t block_ic_group,
                  int64_t block_h,
                  int64_t block_w)
  {
    int seq_1_offset = bytes_weight * ic_group_size * oc_group_size * w;
    int seq_2_offset = bytes_weight * ic_group_size * oc_group_size * w * h;
    int seq_3_offset = bytes_weight * ic_group_size * oc_group_size * w * h * ic_group;

    int burst_0 = typeid(TYPE_B) == typeid(int4_t) ? block_w * oc_group_size * 2 : block_w * oc_group_size;
    int burst_1 = block_h;
    int burst_2 = block_ic_group;
    int burst_3 = block_oc_group;

    if (DEBUG) {
      std::cout << "==== Load Weight ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "burst_2: " << burst_2 << std::endl;
      std::cout << "burst_3: " << burst_3 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "seq_2_offset: " << seq_2_offset << std::endl;
      std::cout << "seq_3_offset: " << seq_3_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_3_iter = 0; burst_3_iter < burst_3; ++burst_3_iter) {
      for (int burst_2_iter = 0; burst_2_iter < burst_2; ++burst_2_iter) {
        for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
          int sram_offset = (burst_1_iter * burst_0 + burst_2_iter * burst_1 * burst_0 + burst_3_iter * burst_2 * burst_1 * burst_0) * 32;
          int ddr_offset  = burst_1_iter * seq_1_offset + burst_2_iter * seq_2_offset + burst_3_iter * seq_3_offset;
          std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * 32);
        }
      }
    }
  }

  void LoadIfmapScale(char* ddr_ptr, char* sram_ptr, int64_t ddr_base_addr, int64_t h, int64_t w, int64_t block_h, int64_t block_w)
  {
    int seq_1_offset = 2 * w;

    int burst_0 = block_w;
    int burst_1 = block_h;

    if (DEBUG) {
      std::cout << "==== Load Ifmap Scale ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
      int sram_offset = burst_1_iter * burst_0 * 2;
      int ddr_offset  = burst_1_iter * seq_1_offset;
      std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * 2);
    }
  }

  void LoadWeightScale(char*   ddr_ptr,
                       char*   sram_ptr,
                       int64_t ddr_base_addr,
                       int64_t oc_group,
                       int64_t h,
                       int64_t w,
                       int64_t block_oc_group,
                       int64_t block_h,
                       int64_t block_w)
  {
    int seq_1_offset = 2 * oc_group_size * w;
    int seq_2_offset = 2 * oc_group_size * w * h;

    int burst_0 = block_w * oc_group_size;
    int burst_1 = block_h;
    int burst_2 = block_oc_group;

    if (DEBUG) {
      std::cout << "==== Load Weight Scale ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "burst_2: " << burst_2 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "seq_2_offset: " << seq_2_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_2_iter = 0; burst_2_iter < burst_2; ++burst_2_iter) {
      for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
        int sram_offset = (burst_1_iter * burst_0 + burst_2_iter * burst_1 * burst_0) * 2;
        int ddr_offset  = burst_1_iter * seq_1_offset + burst_2_iter * seq_2_offset;
        std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * 2);
      }
    }
  }

  void LoadOutlierIndex(char*   ddr_ptr,
                        char*   sram_ptr,
                        int64_t ddr_base_addr,
                        int64_t ic_group,
                        int64_t h,
                        int64_t w,
                        int64_t block_ic_group,
                        int64_t block_h,
                        int64_t block_w)
  {
    int seq_1_offset = 0;
    int seq_2_offset = 0;
    int burst_0      = 0;
    if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t)) {
      seq_1_offset = ic_group_size * ic_group_scale * w * 2;
      seq_2_offset = ic_group_size * ic_group_scale * h * w * 2;
      burst_0      = block_w * ic_group_scale * 2;
    }
    else {
      seq_1_offset = ic_group_size * ic_group_scale * w;
      seq_2_offset = ic_group_size * ic_group_scale * h * w;
      burst_0      = block_w * ic_group_scale;
    }
    int burst_1 = block_h;
    int burst_2 = block_ic_group;

    if (DEBUG) {
      std::cout << "==== Load Ifmap ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "burst_2: " << burst_2 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "seq_2_offset: " << seq_2_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_2_iter = 0; burst_2_iter < burst_2; ++burst_2_iter) {
      for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
        int sram_offset = (burst_1_iter * burst_0 + burst_2_iter * burst_1 * burst_0) * ic_group_size;
        int ddr_offset  = burst_1_iter * seq_1_offset + burst_2_iter * seq_2_offset;
        std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * ic_group_size);
      }
    }
  }

  void LoadIfmapMask(char*   ddr_ptr,
                     char*   sram_ptr,
                     int64_t ddr_base_addr,
                     int64_t oc_group,
                     int64_t ic_group,
                     int64_t h,
                     int64_t w,
                     int64_t block_oc_group,
                     int64_t block_ic_group,
                     int64_t block_h,
                     int64_t block_w)
  {
    int seq_1_offset = ic_group_size * oc_group_size * ic_group_scale * w * ifmap_mask_ic_group_scale;
    int seq_2_offset = ic_group_size * oc_group_size * ic_group_scale * h * w * ifmap_mask_ic_group_scale;
    int seq_3_offset = ic_group_size * oc_group_size * ic_group_scale * h * w * ic_group * ifmap_mask_ic_group_scale;

    int burst_0 = block_w * oc_group_size * ic_group_scale * ifmap_mask_ic_group_scale;
    int burst_1 = block_h;
    int burst_2 = block_ic_group;
    int burst_3 = block_oc_group;

    if (DEBUG) {
      std::cout << "==== Load Ifmap Mask ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "burst_2: " << burst_2 << std::endl;
      std::cout << "burst_3: " << burst_3 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "seq_2_offset: " << seq_2_offset << std::endl;
      std::cout << "seq_3_offset: " << seq_3_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_3_iter = 0; burst_3_iter < burst_3; ++burst_3_iter) {
      for (int burst_2_iter = 0; burst_2_iter < burst_2; ++burst_2_iter) {
        for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
          int sram_offset =
            (burst_1_iter * burst_0 + burst_2_iter * burst_1 * burst_0 + burst_3_iter * burst_2 * burst_1 * burst_0) * ic_group_size;
          int ddr_offset = burst_1_iter * seq_1_offset + burst_2_iter * seq_2_offset + burst_3_iter * seq_3_offset;
          std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * ic_group_size);
        }
      }
    }
  }

  void StoreOfmap(char*   ddr_ptr,
                  char*   sram_ptr,
                  int64_t ddr_base_addr,
                  int64_t ic_group,
                  int64_t h,
                  int64_t w,
                  int64_t block_ic_group,
                  int64_t block_h,
                  int64_t block_w)
  {
    int seq_1_offset = bytes_ofmap * oc_group_size * w;
    int seq_2_offset = bytes_ofmap * oc_group_size * h * w;
    int burst_0      = block_w * 4;
    int burst_1      = block_h;
    int burst_2      = block_ic_group;

    if (DEBUG) {
      std::cout << "==== Store Ofmap ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "burst_2: " << burst_2 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "seq_2_offset: " << seq_2_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_2_iter = 0; burst_2_iter < burst_2; ++burst_2_iter) {
      for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
        int sram_offset = (burst_1_iter * burst_0 + burst_2_iter * burst_1 * burst_0) * 32;
        int ddr_offset  = burst_1_iter * seq_1_offset + burst_2_iter * seq_2_offset;
        std::memcpy(ddr_ptr + ddr_base_addr + ddr_offset, sram_ptr + sram_offset, burst_0 * 32);
      }
    }
  }

  int32_t
  mpt_int16(bool ifmap_read_zero, int16_t* ifmap_ptr, int16_t* weight_ptr, uint8_t* ifmap_mask_ptr, int32_t psum, bool debug = false)
  {
    int32_t ofmap           = 0;
    int16_t ifmap_local[16] = {0};
    int     index           = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = ifmap_ptr[i];
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (ifmap_mask_ptr[i] == 1) {
            ifmap_local[index] = ifmap_ptr[i];
            index++;
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = 0;
      }
    }

    ofmap = mpt::MptInt16(ifmap_local, weight_ptr, psum, false);

    if (debug) {
      std::cout << "==== MPT Int16 ====" << std::endl;
      std::cout << "ifmap_read_zero: " << ifmap_read_zero << std::endl;
      std::cout << "ifmap: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << ifmap_local[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << weight_ptr[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << psum << std::endl;
      std::cout << "ofmap: " << ofmap << std::endl;
    }

    return ofmap;
  }

  float mpt_bfxbf(bool ifmap_read_zero, uint16_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, bool debug = false)
  {
    float    ofmap           = 0;
    uint16_t ifmap_local[16] = {0};
    int      index           = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = ifmap_ptr[i];
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (ifmap_mask_ptr[i] == 1) {
            ifmap_local[index] = ifmap_ptr[i];
            index++;
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = 0;
      }
    }

    ofmap = mpt::MptFloat((uint16_t*)ifmap_local, weight_ptr, psum, 3, 3, 0, false);

    if (debug) {
      std::cout << "ifmap: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<uint32_t>(reinterpret_cast<int16_t*>(ifmap_local)[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << reinterpret_cast<int16_t*>(weight_ptr)[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "ofmap: " << std::endl;
      std::cout << as_uint(ofmap) << std::endl;
    }

    return ofmap;
  }

  float mpt_bfxfp(bool ifmap_read_zero, uint16_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, bool debug = false)
  {
    float    ofmap           = 0;
    uint16_t ifmap_local[16] = {0};
    int      index           = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = ifmap_ptr[i];
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (ifmap_mask_ptr[i] == 1) {
            ifmap_local[index] = ifmap_ptr[i];
            index++;
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = 0;
      }
    }

    if (debug) {
      std::cout << "ifmap: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<uint32_t>(reinterpret_cast<int16_t*>(ifmap_local)[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << reinterpret_cast<int16_t*>(weight_ptr)[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "ofmap: " << std::endl;
      std::cout << as_uint(ofmap) << std::endl;
    }

    ofmap = mpt::MptFloat((uint16_t*)ifmap_local, weight_ptr, psum, 3, 2, 0, false);

    return ofmap;
  }

  float mpt_bfxi8(bool      ifmap_read_zero,
                  uint16_t* ifmap_ptr,
                  int8_t*   weight_ptr,
                  uint8_t*  ifmap_mask_ptr,
                  float     psum,
                  bool      weight_1_ifmap_2_identifier,
                  bool      debug = false)
  {
    float    ofmap            = 0;
    uint16_t ifmap_local[16]  = {0};
    int16_t  weight_local[16] = {0};
    int      index            = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = ifmap_ptr[i];
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (weight_1_ifmap_2_identifier == 0) {
            if (ifmap_mask_ptr[i] == 1) {
              ifmap_local[index] = ifmap_ptr[i];
              index++;
            }
          }
          else {
            if (ifmap_mask_ptr[i + 32] == 1) {
              ifmap_local[index] = ifmap_ptr[i];
              index++;
            }
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = 0;
      }
    }

    if (!weight_1_ifmap_2_identifier) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i];
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i + 16];
      }
    }

    float psum_new = mpt::MptFloat((uint16_t*)ifmap_local, (uint16_t*)weight_local, 0, 3, 1, 0, false);
    ofmap          = as_float(psum) + psum_new;

    if (debug) {
      std::cout << "weight_1_ifmap_2_identifier: " << weight_1_ifmap_2_identifier << std::endl;
      std::cout << "ifmap: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<uint32_t>(reinterpret_cast<int16_t*>(ifmap_local)[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << reinterpret_cast<int16_t*>(weight_local)[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "psum_new: " << as_uint(psum_new) << std::endl;
    }

    return ofmap;
  }

  float mpt_bfxi4(bool      ifmap_read_zero,
                  uint16_t* ifmap_ptr,
                  int8_t*   weight_ptr,
                  uint8_t*  ifmap_mask_ptr,
                  float     psum,
                  int       weight_1_ifmap_4_identifier,
                  bool      debug = false)
  {
    float    ofmap            = 0;
    uint16_t ifmap_local[16]  = {0};
    int16_t  weight_local[16] = {0};
    int      index            = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = ifmap_ptr[i];
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (weight_1_ifmap_4_identifier == 0) {
            if (ifmap_mask_ptr[i] == 1) {
              ifmap_local[index] = ifmap_ptr[i];
              index++;
            }
          }
          else if (weight_1_ifmap_4_identifier == 1) {
            if (ifmap_mask_ptr[i + 32] == 1) {
              ifmap_local[index] = ifmap_ptr[i];
              index++;
            }
          }
          else if (weight_1_ifmap_4_identifier == 2) {
            if (ifmap_mask_ptr[i + 64] == 1) {
              ifmap_local[index] = ifmap_ptr[i];
              index++;
            }
          }
          else if (weight_1_ifmap_4_identifier == 3) {
            if (ifmap_mask_ptr[i + 96] == 1) {
              ifmap_local[index] = ifmap_ptr[i];
              index++;
            }
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = 0;
      }
    }

    if (weight_1_ifmap_4_identifier == 0) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i];
      }
    }
    else if (weight_1_ifmap_4_identifier == 1) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i + 16];
      }
    }
    else if (weight_1_ifmap_4_identifier == 2) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i + 32];
      }
    }
    else if (weight_1_ifmap_4_identifier == 3) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i + 48];
      }
    }

    float psum_new = mpt::MptFloat((uint16_t*)ifmap_local, (uint16_t*)weight_local, 0, 3, 0, 0, false);
    ofmap          = as_float(psum) + psum_new;

    if (debug) {
      std::cout << "weight_1_ifmap_4_identifier: " << weight_1_ifmap_4_identifier << std::endl;
      std::cout << "ifmap: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<uint32_t>(reinterpret_cast<int16_t*>(ifmap_local)[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << reinterpret_cast<int16_t*>(weight_local)[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "psum_new: " << as_uint(psum_new) << std::endl;
    }

    return ofmap;
  }

  float mpt_fpxbf(bool ifmap_read_zero, uint16_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum)
  {
    float ofmap           = 0;
    half  ifmap_local[16] = {0};
    int   index           = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = half(ifmap_ptr[i]);
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (ifmap_mask_ptr[i] == 1) {
            ifmap_local[index] = half(ifmap_ptr[i]);
            index++;
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = half(0);
      }
    }

    ofmap = mpt::MptFloat((uint16_t*)ifmap_local, weight_ptr, psum, 2, 3, 0, false);
    return ofmap;
  }

  float mpt_fpxfp(bool ifmap_read_zero, uint16_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, bool debug = false)
  {
    float ofmap           = 0;
    half  ifmap_local[16] = {0};
    int   index           = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = half(ifmap_ptr[i]);
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (ifmap_mask_ptr[i] == 1) {
            ifmap_local[index] = half(ifmap_ptr[i]);
            index++;
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = half(0);
      }
    }

    ofmap = mpt::MptFloat((uint16_t*)ifmap_local, (uint16_t*)weight_ptr, psum, 2, 2, 0, false);

    if (debug) {
      std::cout << "ifmap: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<uint32_t>(reinterpret_cast<int16_t*>(ifmap_local)[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << reinterpret_cast<int16_t*>(weight_ptr)[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "ofmap: " << as_uint(ofmap) << std::endl;
    }

    return ofmap;
  }

  float mpt_fpxi8(bool      ifmap_read_zero,
                  uint16_t* ifmap_ptr,
                  int8_t*   weight_ptr,
                  uint8_t*  ifmap_mask_ptr,
                  float     psum,
                  bool      weight_1_ifmap_2_identifier,
                  bool      debug = false)
  {
    float   ofmap            = 0;
    half    ifmap_local[16]  = {0};
    int16_t weight_local[16] = {0};
    int     index            = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = half(ifmap_ptr[i]);
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (weight_1_ifmap_2_identifier == 0) {
            if (ifmap_mask_ptr[i] == 1) {
              ifmap_local[index] = half(ifmap_ptr[i]);
              index++;
            }
          }
          else {
            if (ifmap_mask_ptr[i + 32] == 1) {
              ifmap_local[index] = half(ifmap_ptr[i]);
              index++;
            }
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = half(0);
      }
    }

    if (!weight_1_ifmap_2_identifier) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i];
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i + 16];
      }
    }

    float psum_new = mpt::MptFloat((uint16_t*)ifmap_local, (uint16_t*)weight_local, 0, 2, 1, 0, false);
    ofmap          = as_float(psum) + psum_new;

    if (debug) {
      std::cout << "weight_1_ifmap_2_identifier: " << weight_1_ifmap_2_identifier << std::endl;
      std::cout << "ifmap: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << std::hex << static_cast<uint32_t>(reinterpret_cast<int16_t*>(ifmap_local)[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << reinterpret_cast<int16_t*>(weight_local)[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "psum_new: " << as_uint(psum_new) << std::endl;
      std::cout << "ofmap: " << as_uint(ofmap) << std::endl;
    }

    return ofmap;
  }

  float mpt_fpxi4(bool      ifmap_read_zero,
                  uint16_t* ifmap_ptr,
                  int8_t*   weight_ptr,
                  uint8_t*  ifmap_mask_ptr,
                  float     psum,
                  int       weight_1_ifmap_4_identifier,
                  bool      debug = false)
  {
    float   ofmap            = 0;
    half    ifmap_local[16]  = {0};
    int16_t weight_local[16] = {0};
    int     index            = 0;
    if (!ifmap_read_zero) {
      if (!SPARSE_ENABLE) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = half(ifmap_ptr[i]);
        }
      }
      else if (SPARSE_ENABLE) {
        for (int i = 0; i < 32; ++i) {
          if (weight_1_ifmap_4_identifier == 0) {
            if (ifmap_mask_ptr[i] == 1) {
              ifmap_local[index] = half(ifmap_ptr[i]);
              index++;
            }
          }
          else if (weight_1_ifmap_4_identifier == 1) {
            if (ifmap_mask_ptr[i + 32] == 1) {
              ifmap_local[index] = half(ifmap_ptr[i]);
              index++;
            }
          }
          else if (weight_1_ifmap_4_identifier == 2) {
            if (ifmap_mask_ptr[i + 64] == 1) {
              ifmap_local[index] = half(ifmap_ptr[i]);
              index++;
            }
          }
          else if (weight_1_ifmap_4_identifier == 3) {
            if (ifmap_mask_ptr[i + 96] == 1) {
              ifmap_local[index] = half(ifmap_ptr[i]);
              index++;
            }
          }
        }
      }
    }
    else {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = half(0);
      }
    }

    if (weight_1_ifmap_4_identifier == 0) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i];
      }
    }
    else if (weight_1_ifmap_4_identifier == 1) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i + 16];
      }
    }
    else if (weight_1_ifmap_4_identifier == 2) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i + 32];
      }
    }
    else if (weight_1_ifmap_4_identifier == 3) {
      for (int i = 0; i < 16; ++i) {
        weight_local[i] = (int16_t)weight_ptr[i + 48];
      }
    }

    float psum_new = mpt::MptFloat((uint16_t*)ifmap_local, (uint16_t*)weight_local, 0, 2, 0, 0, false);
    ofmap          = as_float(psum) + psum_new;

    if (debug) {
      std::cout << "weight_1_ifmap_4_identifier: " << weight_1_ifmap_4_identifier << std::endl;
      std::cout << "ifmap: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << std::hex << static_cast<uint32_t>(reinterpret_cast<int16_t*>(ifmap_local)[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: " << std::endl;
      for (int i = 0; i < 16; ++i) {
        std::cout << reinterpret_cast<int16_t*>(weight_local)[i] << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "psum_new: " << as_uint(psum_new) << std::endl;
      std::cout << "ofmap: " << as_uint(ofmap) << std::endl;
    }

    return ofmap;
  }

  float mpt_i8xbf(bool      ifmap_read_zero,
                  int8_t*   ifmap_ptr,
                  uint16_t* weight_ptr,
                  uint8_t*  ifmap_mask_ptr,
                  float     psum,
                  int       weight_2_ifmap_2_identifier,
                  bool      debug = false)
  {
    float   ofmap = 0;
    int16_t ifmap_local[16];
    int     index = 0;

    if (!weight_2_ifmap_2_identifier) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i - 16 + 32]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }
    else {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 16]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 16]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 16 - 16 + 32]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }

    ofmap = mpt::MptFloat(reinterpret_cast<uint16_t*>(ifmap_local), reinterpret_cast<uint16_t*>(weight_ptr), psum, 1, 3, 0, false);

    if (debug) {
      std::cout << "weight_2_ifmap_2_identifier: " << weight_2_ifmap_2_identifier << std::endl;
      std::cout << "ifmap: ";
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: ";
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "ofmap: " << as_uint(ofmap) << std::endl;
    }

    return ofmap;
  }

  float mpt_i8xfp(bool      ifmap_read_zero,
                  int8_t*   ifmap_ptr,
                  uint16_t* weight_ptr,
                  uint8_t*  ifmap_mask_ptr,
                  float     psum,
                  int       weight_2_ifmap_2_identifier,
                  bool      debug = false)
  {
    float   ofmap = 0;
    int16_t ifmap_local[16];
    int     index = 0;

    if (!weight_2_ifmap_2_identifier) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i - 16 + 32]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }
    else {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 16]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 16]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 16 - 16 + 32]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }

    ofmap = mpt::MptFloat(reinterpret_cast<uint16_t*>(ifmap_local), reinterpret_cast<uint16_t*>(weight_ptr), psum, 1, 2, 0, false);

    if (debug) {
      std::cout << "weight_2_ifmap_2_identifier: " << weight_2_ifmap_2_identifier << std::endl;
      std::cout << "ifmap: ";
      for (int i = 0; i < 16; ++i) {
        std::cout << std::hex << static_cast<int32_t>(ifmap_local[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: ";
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "ofmap: " << as_uint(ofmap) << std::endl;
    }

    return ofmap;
  }

  uint32_t mpt_i8xi8(bool     ifmap_read_zero,
                     int8_t*  ifmap_ptr,
                     int8_t*  weight_ptr,
                     int8_t*  outlier_index_ptr,
                     uint8_t* ifmap_mask_ptr,
                     int32_t  psum,
                     half     ifmap_scale,
                     half     weight_scale,
                     half     outlier_scale,
                     bool     outlier_second_pass = false,
                     bool     debug               = false)
  {
    uint32_t ofmap;
    int8_t   ifmap_local[32] = {0};
    int      index           = 0;
    if (typeid(TYPE_ACCUMULATOR) == typeid(int32_t)) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            ifmap_local[i] = ifmap_ptr[i];
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 64; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              ifmap_local[index] = ifmap_ptr[i];
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 32; ++i) {
          ifmap_local[i] = 0;
        }
      }

      ofmap = mpt::MptInt8(ifmap_local, weight_ptr, psum, debug);

      if (debug) {
        std::cout << "================================" << std::endl;
        if (SPARSE_ENABLE) {
          std::cout << "ifmap_origin: " << std::endl;
          for (int i = 0; i < 64; ++i) {
            std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "ifmap_dense: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
          }
          std::cout << std::endl;
        }

        std::cout << "ifmap: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "weight: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "psum: " << psum << std::endl;
        std::cout << "ofmap: " << ofmap << std::endl;
      }
    }
    else if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      half   mul_scale;
      int8_t outlier_index_local[32] = {0};
      int8_t real_ifmap[32]          = {0};
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            ifmap_local[i]         = ifmap_ptr[i];
            outlier_index_local[i] = outlier_index_ptr[i];
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 64; ++i) {
            if (ifmap_mask_ptr[i]) {
              ifmap_local[index]         = ifmap_ptr[i];
              outlier_index_local[index] = outlier_index_ptr[i];
              index++;
            }
          }
        }
      }
      if (OUTLIER_ENABLE) {
        if (outlier_second_pass) {
          for (int i = 0; i < 32; ++i) {
            if (!outlier_index_local[i]) {
              real_ifmap[i] = ifmap_local[i];
            }
          }
          mul_scale = ifmap_scale * weight_scale;
        }
        else {
          for (int i = 0; i < 32; ++i) {
            if (outlier_index_local[i]) {
              real_ifmap[i] = ifmap_local[i];
            }
          }
          mul_scale = outlier_scale * weight_scale;
        }
      }
      else {
        for (int i = 0; i < 32; ++i) {
          real_ifmap[i] = ifmap_local[i];
          mul_scale     = ifmap_scale * weight_scale;
        }
      }
      uint32_t psum_int       = mpt::MptInt8(real_ifmap, weight_ptr, 0, false);
      float    last_psum      = as_float(psum);
      uint32_t dequanted_psum = compute_model::quant::custom_fma(psum_int, mul_scale.storage, false);
      float    new_psum       = as_float(dequanted_psum);
      // new_psum += last_psum;
      ofmap = as_uint(new_psum + last_psum);

      if (debug) {
        std::cout << "================================" << std::endl;
        if (SPARSE_ENABLE) {
          std::cout << "ifmap_origin: " << std::endl;
          for (int i = 0; i < 64; ++i) {
            std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "ifmap_dense: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "outlier index origin : " << std::endl;
          for (int i = 0; i < 64; ++i) {
            std::cout << static_cast<int32_t>(outlier_index_ptr[i]);
          }
          std::cout << std::endl;
          std::cout << "outlier index dense: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(outlier_index_local[i]);
          }
          std::cout << std::endl;
        }

        std::cout << "ifmap: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(real_ifmap[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "weight: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "psum: " << psum_int << std::endl;
        std::cout << "ifmap_scale: " << ifmap_scale.storage << std::endl;
        std::cout << "outlier_scale: " << outlier_scale.storage << std::endl;
        std::cout << "weight_scale: " << weight_scale.storage << std::endl;
        std::cout << "mul_scale: " << mul_scale.storage << std::endl;
        std::cout << "last_psum: " << as_uint(last_psum) << std::endl;
        std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
        std::cout << "ofmap: " << ofmap << std::endl;
      }
    }
    return ofmap;
  }

  uint32_t mpt_i8xi4(bool     ifmap_read_zero,
                     int8_t*  ifmap_ptr,
                     int8_t*  weight_ptr,
                     int8_t*  outlier_index_ptr,
                     uint8_t* ifmap_mask_ptr,
                     int32_t  psum,
                     half     ifmap_scale,
                     half     weight_scale,
                     half     outlier_scale,
                     bool     weight_1_ifmap_2_identifier,
                     bool     outlier_second_pass = false,
                     bool     debug               = false)
  {
    uint32_t ofmap;
    int8_t   weight_local[32] = {0};
    int8_t   ifmap_local[32]  = {0};

    if (!weight_1_ifmap_2_identifier) {
      for (int i = 0; i < 32; ++i) {
        if (WEIGHT_NON_UNIFORM_QUANTIZATION) {
          weight_local[i] = weight_ptr[i] << 4;
        }
        else {
          weight_local[i] = weight_ptr[i];
        }
      }
    }
    else {
      for (int i = 0; i < 32; ++i) {
        if (WEIGHT_NON_UNIFORM_QUANTIZATION) {
          weight_local[i] = weight_ptr[i + 32] << 4;
        }
        else {
          weight_local[i] = weight_ptr[i + 32];
        }
      }
    }

    if (typeid(TYPE_ACCUMULATOR) == typeid(int32_t)) {

      int index = 0;
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            ifmap_local[i] = ifmap_ptr[i];
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 64; ++i) {
            if (weight_1_ifmap_2_identifier == 0) {
              if (ifmap_mask_ptr[i] == 1) {
                ifmap_local[index] = ifmap_ptr[i];
                index++;
              }
            }
            else {
              if (ifmap_mask_ptr[i + 64] == 1) {
                ifmap_local[index] = ifmap_ptr[i];
                index++;
              }
            }
          }
        }
      }
      else {
        for (int i = 0; i < 32; ++i) {
          ifmap_local[i] = 0;
        }
      }
      ofmap = mpt::MptInt8(ifmap_local, weight_local, psum, false);
    }
    else if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      half   mul_scale;
      int8_t outlier_index_local[32] = {0};
      int8_t real_ifmap[32]          = {0};

      int index = 0;
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            ifmap_local[i]         = ifmap_ptr[i];
            outlier_index_local[i] = outlier_index_ptr[i];
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 64; ++i) {
            if (weight_1_ifmap_2_identifier == 0) {
              if (ifmap_mask_ptr[i] == 1) {
                ifmap_local[index]         = ifmap_ptr[i];
                outlier_index_local[index] = outlier_index_ptr[i];
                index++;
              }
            }
            else {
              if (ifmap_mask_ptr[i + 64] == 1) {
                ifmap_local[index]         = ifmap_ptr[i];
                outlier_index_local[index] = outlier_index_ptr[i];
                index++;
              }
            }
          }
        }
      }
      else {
        for (int i = 0; i < 32; ++i) {
          ifmap_local[i]         = 0;
          outlier_index_local[i] = outlier_index_ptr[i];
        }
      }

      if (OUTLIER_ENABLE) {
        if (outlier_second_pass) {
          for (int i = 0; i < 32; ++i) {
            if (!outlier_index_local[i]) {
              real_ifmap[i] = ifmap_local[i];
            }
          }
          mul_scale = ifmap_scale * weight_scale;
        }
        else {
          for (int i = 0; i < 32; ++i) {
            if (outlier_index_local[i]) {
              real_ifmap[i] = ifmap_local[i];
            }
          }
          mul_scale = outlier_scale * weight_scale;
        }
      }
      else {
        for (int i = 0; i < 32; ++i) {
          real_ifmap[i] = ifmap_local[i];
        }
        mul_scale = ifmap_scale * weight_scale;
      }

      uint32_t psum_int       = mpt::MptInt8(real_ifmap, weight_local, 0, false);
      float    last_psum      = as_float(psum);
      uint32_t dequanted_psum = compute_model::quant::custom_fma(psum_int, mul_scale.storage, false);
      float    new_psum       = as_float(dequanted_psum);
      new_psum += last_psum;
      ofmap = as_uint(new_psum);

      if (debug) {
        std::cout << "================================" << std::endl;
        std::cout << "outlier_second_pass: " << outlier_second_pass << std::endl;
        std::cout << "weight_1_ifmap_2_identifier: " << weight_1_ifmap_2_identifier << std::endl;
        if (SPARSE_ENABLE) {
          std::cout << "ifmap origin: " << std::endl;
          for (int i = 0; i < 64; ++i) {
            std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
          }
          std::cout << std::endl;
        }
        std::cout << "ifmap: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(real_ifmap[i]) << " ";
        }
        std::cout << std::endl;
        if (OUTLIER_ENABLE) {
          if (SPARSE_ENABLE) {
            std::cout << "outlier_index origin: " << std::endl;
            for (int i = 0; i < 64; ++i) {
              std::cout << static_cast<int32_t>(outlier_index_ptr[i]) << " ";
            }
            std::cout << std::endl;
          }
          std::cout << "outlier_index: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(outlier_index_local[i]) << " ";
          }
          std::cout << std::endl;
        }
        std::cout << std::endl;
        std::cout << "weight: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(weight_local[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "psum: " << psum_int << std::endl;
        std::cout << "last_psum: " << as_uint(last_psum) << std::endl;
        std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
        std::cout << "ofmap: " << ofmap << std::endl;
      }
    }

    return ofmap;
  }

  float mpt_i4xbf(bool      ifmap_read_zero,
                  int8_t*   ifmap_ptr,
                  uint16_t* weight_ptr,
                  uint8_t*  ifmap_mask_ptr,
                  float     psum,
                  int       weight_4_ifmap_4_identifier,
                  bool      debug = false)
  {
    float   ofmap = 0;
    int16_t ifmap_local[16];
    int     index = 0;

    if (weight_4_ifmap_4_identifier == 0) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i - 16 + 64]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }
    else if (weight_4_ifmap_4_identifier == 1) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 16]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 16]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 16 - 16 + 64]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }
    else if (weight_4_ifmap_4_identifier == 2) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 32]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 32]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 32 - 16 + 64]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }
    else if (weight_4_ifmap_4_identifier == 3) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 48]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 48]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 48 - 16 + 64]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }

    ofmap = mpt::MptFloat(reinterpret_cast<uint16_t*>(ifmap_local), reinterpret_cast<uint16_t*>(weight_ptr), psum, 0, 3, 0, false);

    if (debug) {
      std::cout << "weight_4_ifmap_4_identifier: " << weight_4_ifmap_4_identifier << std::endl;
      std::cout << "ifmap: ";
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: ";
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "ofmap: " << as_uint(ofmap) << std::endl;
    }

    return ofmap;
  }

  float mpt_i4xfp(bool      ifmap_read_zero,
                  int8_t*   ifmap_ptr,
                  uint16_t* weight_ptr,
                  uint8_t*  ifmap_mask_ptr,
                  float     psum,
                  int       weight_4_ifmap_4_identifier,
                  bool      debug = false)
  {
    float   ofmap = 0;
    int16_t ifmap_local[16];
    int     index = 0;

    if (weight_4_ifmap_4_identifier == 0) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i - 16 + 64]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }
    else if (weight_4_ifmap_4_identifier == 1) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 16]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 16]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 16 - 16 + 64]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }
    else if (weight_4_ifmap_4_identifier == 2) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 32]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 32]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 32 - 16 + 64]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }
    else if (weight_4_ifmap_4_identifier == 3) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 16; ++i) {
            ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 48]);
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 32; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              if (i < 16) {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 48]);
              }
              else {
                ifmap_local[index] = static_cast<int16_t>(ifmap_ptr[i + 48 - 16 + 64]);
              }
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = 0;
        }
      }
    }

    if (debug) {
      std::cout << "weight_4_ifmap_4_identifier: " << weight_4_ifmap_4_identifier << std::endl;
      if (SPARSE_ENABLE) {
        std::cout << "ifmap mask: ";
        for (int i = 0; i < 32 * ic_group_scale; ++i) {
          std::cout << static_cast<int32_t>(ifmap_mask_ptr[i]) << " ";
        }
      }
      std::cout << std::endl;
      std::cout << "ifmap: ";
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
      }
      std::cout << std::endl;
      std::cout << "weight: ";
      for (int i = 0; i < 16; ++i) {
        std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
      }
      std::cout << std::endl;
    }

    ofmap = mpt::MptFloat(reinterpret_cast<uint16_t*>(ifmap_local), reinterpret_cast<uint16_t*>(weight_ptr), psum, 0, 2, 0, false);

    if (debug) {
      std::cout << "psum: " << as_uint(psum) << std::endl;
      std::cout << "ofmap: " << as_uint(ofmap) << std::endl;
    }

    return ofmap;
  }

  uint32_t mpt_i4xi8(bool     ifmap_read_zero,
                     int8_t*  ifmap_ptr,
                     int8_t*  weight_ptr,
                     int8_t*  outlier_index_ptr,
                     uint8_t* ifmap_mask_ptr,
                     int32_t  psum,
                     half     ifmap_scale,
                     half     weight_scale,
                     half     outlier_scale,
                     int      weight_2_ifmap_2_identifier,
                     bool     outlier_second_pass = false,
                     bool     debug               = false)
  {
    uint32_t ofmap;
    int8_t   ifmap_local[32] = {0};
    int      index           = 0;

    if (typeid(TYPE_ACCUMULATOR) == typeid(int32_t)) {

      if (!weight_2_ifmap_2_identifier) {
        if (!ifmap_read_zero) {
          if (!SPARSE_ENABLE) {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i] = ifmap_ptr[i];
            }
          }
          else if (SPARSE_ENABLE) {
            for (int i = 0; i < 64; ++i) {
              if (ifmap_mask_ptr[i] == 1) {
                if (i < 32) {
                  ifmap_local[index] = ifmap_ptr[i];
                }
                else {
                  ifmap_local[index] = ifmap_ptr[i - 32 + 64];
                }
                index++;
              }
            }
          }
        }
        else {
          for (int i = 0; i < 32; ++i) {
            ifmap_local[i] = 0;
          }
        }
      }
      else {
        if (!ifmap_read_zero) {
          if (!SPARSE_ENABLE) {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i] = ifmap_ptr[i + 32];
            }
          }
          else if (SPARSE_ENABLE) {
            for (int i = 0; i < 64; ++i) {
              if (ifmap_mask_ptr[i] == 1) {
                if (i < 32) {
                  ifmap_local[index] = ifmap_ptr[i + 32];
                }
                else {
                  ifmap_local[index] = ifmap_ptr[i + 32 - 32 + 64];
                }
                index++;
              }
            }
          }
        }
        else {
          for (int i = 0; i < 32; ++i) {
            ifmap_local[i] = 0;
          }
        }
      }

      ofmap = mpt::MptInt8(ifmap_local, weight_ptr, psum, false);

      if (debug) {
        std::cout << "================================" << std::endl;
        if (SPARSE_ENABLE) {
          std::cout << "ifmap original: " << std::endl;
          for (int i = 0; i < 64; ++i) {
            std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "ifmap dense: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
          }
          std::cout << std::endl;
        }
        std::cout << "ifmap original: " << std::endl;
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "ifmap: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "weight: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "ofmap: " << ofmap << std::endl;
      }
    }
    else if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      if (IFMAP_NON_UNIFORM_QUANTIZATION) {
        half   mul_scale;
        int8_t outlier_index_local[32] = {0};
        int8_t real_ifmap[32]          = {0};

        if (!weight_2_ifmap_2_identifier) {
          if (!ifmap_read_zero) {
            if (!SPARSE_ENABLE) {
              for (int i = 0; i < 32; ++i) {
                ifmap_local[i]         = ifmap_ptr[i];
                outlier_index_local[i] = outlier_index_ptr[i];
              }
            }
            else if (SPARSE_ENABLE) {
              for (int i = 0; i < 64; ++i) {
                if (ifmap_mask_ptr[i]) {
                  if (i < 32) {
                    ifmap_local[index]         = ifmap_ptr[i];
                    outlier_index_local[index] = outlier_index_ptr[i];
                  }
                  else {
                    ifmap_local[index]         = ifmap_ptr[i - 32 + 64];
                    outlier_index_local[index] = outlier_index_ptr[i - 32 + 64];
                  }
                  index++;
                }
              }
            }
          }
          else {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i]         = 0;
              outlier_index_local[i] = outlier_index_ptr[i];
            }
          }
        }
        else {
          if (!ifmap_read_zero) {
            if (!SPARSE_ENABLE) {
              for (int i = 0; i < 32; ++i) {
                ifmap_local[i]         = ifmap_ptr[i + 32];
                outlier_index_local[i] = outlier_index_ptr[i + 32];
              }
            }
            else if (SPARSE_ENABLE) {
              for (int i = 0; i < 64; ++i) {
                if (ifmap_mask_ptr[i]) {
                  if (i < 32) {
                    ifmap_local[index]         = ifmap_ptr[i + 32];
                    outlier_index_local[index] = outlier_index_ptr[i + 32];
                  }
                  else {
                    ifmap_local[index]         = ifmap_ptr[i + 32 - 32 + 64];
                    outlier_index_local[index] = outlier_index_ptr[i + 32 - 32 + 64];
                  }
                  index++;
                }
              }
            }
          }
          else {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i]         = 0;
              outlier_index_local[i] = outlier_index_ptr[i + 32];
            }
          }
        }

        if (OUTLIER_ENABLE) {
          if (outlier_second_pass) {
            for (int i = 0; i < 32; ++i) {
              if (!outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = outlier_scale * weight_scale;
          }
          else {
            for (int i = 0; i < 32; ++i) {
              if (outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = ifmap_scale * weight_scale;
          }
        }
        else {
          for (int i = 0; i < 32; ++i) {
            real_ifmap[i] = ifmap_local[i];
          }
          mul_scale = ifmap_scale * weight_scale;
        }

        int8_t ifmap_post_process[32] = {0};

        for (int i = 0; i < 32; ++i) {
          ifmap_post_process[i] = real_ifmap[i] << 4;
        }

        uint32_t psum_int       = mpt::MptInt8(ifmap_post_process, weight_ptr, 0, false);
        float    last_psum      = as_float(psum);
        uint32_t dequanted_psum = compute_model::quant::custom_fma(psum_int, mul_scale.storage, false);
        float    new_psum       = as_float(dequanted_psum);
        new_psum += last_psum;
        ofmap = as_uint(new_psum);

        if (debug) {
          std::cout << "================================" << std::endl;
          std::cout << "outlier_second_pass: " << outlier_second_pass << std::endl;
          std::cout << "weight_2_ifmap_2_identifier: " << weight_2_ifmap_2_identifier << std::endl;
          if (SPARSE_ENABLE) {
            std::cout << "ifmap original: " << std::endl;
            for (int i = 0; i < 64; ++i) {
              std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
            }
            std::cout << std::endl;
            std::cout << "ifmap dense: " << std::endl;
            for (int i = 0; i < 32; ++i) {
              std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
            }
            std::cout << std::endl;
            if (OUTLIER_ENABLE) {
              std::cout << "outlier index original: " << std::endl;
              for (int i = 0; i < 64; ++i) {
                std::cout << static_cast<int32_t>(outlier_index_ptr[i]);
              }
              std::cout << std::endl;
              std::cout << "outlier index dense: " << std::endl;
              for (int i = 0; i < 32; ++i) {
                std::cout << static_cast<int32_t>(outlier_index_local[i]);
              }
              std::cout << std::endl;
            }
          }
          std::cout << "ifmap original: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "ifmap: ";
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(real_ifmap[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "weight: ";
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "psum: " << psum_int << std::endl;
          std::cout << "weight_scale: " << as_uint((float)weight_scale) << std::endl;
          std::cout << "ifmap_scale: " << as_uint((float)ifmap_scale) << std::endl;
          std::cout << "last_psum: " << as_uint(last_psum) << std::endl;
          std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
          std::cout << "ofmap: " << ofmap << std::endl;
        }
      }
      else {
        half   mul_scale;
        int8_t outlier_index_local[32] = {0};
        int8_t real_ifmap[32]          = {0};

        if (!weight_2_ifmap_2_identifier) {
          if (!ifmap_read_zero) {
            if (!SPARSE_ENABLE) {
              for (int i = 0; i < 32; ++i) {
                ifmap_local[i]         = ifmap_ptr[i];
                outlier_index_local[i] = outlier_index_ptr[i];
              }
            }
            else if (SPARSE_ENABLE) {
              for (int i = 0; i < 64; ++i) {
                if (ifmap_mask_ptr[i]) {
                  if (i < 32) {
                    ifmap_local[index]         = ifmap_ptr[i];
                    outlier_index_local[index] = outlier_index_ptr[i];
                  }
                  else {
                    ifmap_local[index]         = ifmap_ptr[i - 32 + 64];
                    outlier_index_local[index] = outlier_index_ptr[i - 32 + 64];
                  }
                  index++;
                }
              }
            }
          }
          else {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i]         = 0;
              outlier_index_local[i] = outlier_index_ptr[i];
            }
          }
        }
        else {
          if (!ifmap_read_zero) {
            if (!SPARSE_ENABLE) {
              for (int i = 0; i < 32; ++i) {
                ifmap_local[i]         = ifmap_ptr[i + 32];
                outlier_index_local[i] = outlier_index_ptr[i + 32];
              }
            }
            else if (SPARSE_ENABLE) {
              for (int i = 0; i < 64; ++i) {
                if (ifmap_mask_ptr[i]) {
                  if (i < 32) {
                    ifmap_local[index]         = ifmap_ptr[i + 32];
                    outlier_index_local[index] = outlier_index_ptr[i + 32];
                  }
                  else {
                    ifmap_local[index]         = ifmap_ptr[i + 32 - 32 + 64];
                    outlier_index_local[index] = outlier_index_ptr[i + 32 - 32 + 64];
                  }
                  index++;
                }
              }
            }
          }
          else {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i]         = 0;
              outlier_index_local[i] = outlier_index_ptr[i + 32];
            }
          }
        }

        if (OUTLIER_ENABLE) {
          if (outlier_second_pass) {
            for (int i = 0; i < 32; ++i) {
              if (!outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = outlier_scale * weight_scale;
          }
          else {
            for (int i = 0; i < 32; ++i) {
              if (outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = ifmap_scale * weight_scale;
          }
        }
        else {
          for (int i = 0; i < 32; ++i) {
            real_ifmap[i] = ifmap_local[i];
          }
          mul_scale = ifmap_scale * weight_scale;
        }

        uint32_t psum_int       = mpt::MptInt8(real_ifmap, weight_ptr, 0, false);
        float    last_psum      = as_float(psum);
        uint32_t dequanted_psum = compute_model::quant::custom_fma(psum_int, mul_scale.storage, false);
        float    new_psum       = as_float(dequanted_psum);
        new_psum += last_psum;
        ofmap = as_uint(new_psum);

        if (debug) {
          std::cout << "================================" << std::endl;
          std::cout << "outlier_second_pass: " << outlier_second_pass << std::endl;
          std::cout << "weight_2_ifmap_2_identifier: " << weight_2_ifmap_2_identifier << std::endl;
          if (SPARSE_ENABLE) {
            std::cout << "ifmap original: " << std::endl;
            for (int i = 0; i < 64; ++i) {
              std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
            }
            std::cout << std::endl;
            std::cout << "ifmap dense: " << std::endl;
            for (int i = 0; i < 32; ++i) {
              std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
            }
            std::cout << std::endl;
            if (OUTLIER_ENABLE) {
              std::cout << "outlier index original: " << std::endl;
              for (int i = 0; i < 64; ++i) {
                std::cout << static_cast<int32_t>(outlier_index_ptr[i]);
              }
              std::cout << std::endl;
              std::cout << "outlier index dense: " << std::endl;
              for (int i = 0; i < 32; ++i) {
                std::cout << static_cast<int32_t>(outlier_index_local[i]);
              }
              std::cout << std::endl;
            }
          }
          std::cout << "ifmap original: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "outlier index dense: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(outlier_index_local[i]);
          }
          std::cout << std::endl;
          std::cout << "ifmap: ";
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(real_ifmap[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "weight: ";
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "psum: " << psum_int << std::endl;
          std::cout << "weight_scale: " << weight_scale.storage << std::endl;
          std::cout << "ifmap_scale: " << ifmap_scale.storage << std::endl;
          std::cout << "last_psum: " << as_uint(last_psum) << std::endl;
          std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
          std::cout << "ofmap: " << ofmap << std::endl;
        }
      }
    }

    return ofmap;
  }

  uint32_t mpt_i4xi4(bool     ifmap_read_zero,
                     int8_t*  ifmap_ptr,
                     int8_t*  weight_ptr,
                     int8_t*  outlier_index_ptr,
                     uint8_t* ifmap_mask_ptr,
                     int32_t  psum,
                     half     ifmap_scale,
                     half     weight_scale,
                     half     outlier_scale,
                     bool     outlier_second_pass = false,
                     bool     debug               = false)
  {
    uint32_t ofmap;
    int8_t   ifmap_local[64] = {0};
    int      index           = 0;
    if (typeid(TYPE_ACCUMULATOR) == typeid(int32_t)) {
      if (!ifmap_read_zero) {
        if (!SPARSE_ENABLE) {
          for (int i = 0; i < 64; ++i) {
            ifmap_local[i] = ifmap_ptr[i];
          }
        }
        else if (SPARSE_ENABLE) {
          for (int i = 0; i < 128; ++i) {
            if (ifmap_mask_ptr[i] == 1) {
              ifmap_local[index] = ifmap_ptr[i];
              index++;
            }
          }
        }
      }
      else {
        for (int i = 0; i < 64; ++i) {
          ifmap_local[i] = 0;
        }
      }

      ofmap = mpt::MptInt4(ifmap_local, weight_ptr, psum, debug);

      if (debug) {
        std::cout << "================================" << std::endl;
        std::cout << "ifmap: ";
        for (int i = 0; i < 64; ++i) {
          std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "weight: ";
        for (int i = 0; i < 64; ++i) {
          std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "psum: " << psum << std::endl;
        std::cout << "ofmap: " << ofmap << std::endl;
      }
    }
    else if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      if (IFMAP_NON_UNIFORM_QUANTIZATION || WEIGHT_NON_UNIFORM_QUANTIZATION) {
        half   mul_scale;
        int8_t outlier_index_local[64] = {0};
        int8_t real_ifmap[64]          = {0};

        if (!ifmap_read_zero) {
          if (!SPARSE_ENABLE) {
            for (int i = 0; i < 64; ++i) {
              ifmap_local[i]         = ifmap_ptr[i];
              outlier_index_local[i] = outlier_index_ptr[i];
            }
          }
          else if (SPARSE_ENABLE) {
            for (int i = 0; i < 128; ++i) {
              if (ifmap_mask_ptr[i]) {
                ifmap_local[index]         = ifmap_ptr[i];
                outlier_index_local[index] = outlier_index_ptr[i];
                index++;
              }
            }
          }
        }
        else {
          for (int i = 0; i < 64; ++i) {
            ifmap_local[i]         = 0;
            outlier_index_local[i] = outlier_index_ptr[i];
          }
        }

        if (OUTLIER_ENABLE) {
          if (outlier_second_pass) {
            for (int i = 0; i < 64; ++i) {
              if (!outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = ifmap_scale * weight_scale;
          }
          else {
            for (int i = 0; i < 64; ++i) {
              if (outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = outlier_scale * weight_scale;
          }
        }
        else {
          for (int i = 0; i < 64; ++i) {
            real_ifmap[i] = ifmap_local[i];
            mul_scale     = ifmap_scale * weight_scale;
          }
        }

        int8_t ifmap_post_process[32]  = {0};
        int8_t weight_post_process[32] = {0};

        if (IFMAP_NON_UNIFORM_QUANTIZATION) {
          for (int i = 0; i < 32; ++i) {
            ifmap_post_process[i] = real_ifmap[i] << 4;
          }
        }
        else {
          for (int i = 0; i < 32; ++i) {
            ifmap_post_process[i] = real_ifmap[i];
          }
        }

        if (WEIGHT_NON_UNIFORM_QUANTIZATION) {
          for (int i = 0; i < 32; ++i) {
            weight_post_process[i] = weight_ptr[i] << 4;
          }
        }
        else {
          for (int i = 0; i < 32; ++i) {
            weight_post_process[i] = weight_ptr[i];
          }
        }

        uint32_t psum_int       = mpt::MptInt8(ifmap_post_process, weight_post_process, 0, false);
        float    last_psum      = as_float(psum);
        uint32_t dequanted_psum = compute_model::quant::custom_fma(psum_int, mul_scale.storage, false);
        float    new_psum       = as_float(dequanted_psum);
        ofmap                   = as_uint(new_psum + last_psum);

        if (debug) {
          std::cout << "================================" << std::endl;
          std::cout << "IFMAP_NON_UNIFORM_QUANTIZATION: " << IFMAP_NON_UNIFORM_QUANTIZATION << std::endl;
          std::cout << "WEIGHT_NON_UNIFORM_QUANTIZATION: " << WEIGHT_NON_UNIFORM_QUANTIZATION << std::endl;
          if (SPARSE_ENABLE) {
            std::cout << "ifmap original: " << std::endl;
            for (int i = 0; i < 128; ++i) {
              std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
            }
            std::cout << std::endl;
            std::cout << "ifmap dense: " << std::endl;
            for (int i = 0; i < 64; ++i) {
              std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
            }
            std::cout << std::endl;
            if (OUTLIER_ENABLE) {
              std::cout << "outlier index original: " << std::endl;
              for (int i = 0; i < 128; ++i) {
                std::cout << static_cast<int32_t>(outlier_index_ptr[i]);
              }
              std::cout << std::endl;
              std::cout << "outlier index dense: " << std::endl;
              for (int i = 0; i < 64; ++i) {
                std::cout << static_cast<int32_t>(outlier_index_local[i]);
              }
              std::cout << std::endl;
            }
          }
          std::cout << "ifmap original: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "outlier index dense: " << std::endl;
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(outlier_index_local[i]);
          }
          std::cout << std::endl;
          std::cout << "ifmap: ";
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(ifmap_post_process[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "weight: ";
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(weight_post_process[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "psum: " << psum_int << std::endl;
          std::cout << "last_psum: " << as_uint(last_psum) << std::endl;
          std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
          std::cout << "ofmap: " << ofmap << std::endl;
        }

        if (IFMAP_NON_UNIFORM_QUANTIZATION) {
          for (int i = 0; i < 32; ++i) {
            ifmap_post_process[i] = real_ifmap[i + 32] << 4;
          }
        }
        else {
          for (int i = 0; i < 32; ++i) {
            ifmap_post_process[i] = real_ifmap[i + 32];
          }
        }

        if (WEIGHT_NON_UNIFORM_QUANTIZATION) {
          for (int i = 0; i < 32; ++i) {
            weight_post_process[i] = weight_ptr[i + 32] << 4;
          }
        }
        else {
          for (int i = 0; i < 32; ++i) {
            weight_post_process[i] = weight_ptr[i + 32];
          }
        }

        psum_int       = mpt::MptInt8(ifmap_post_process, weight_post_process, 0, false);
        last_psum      = as_float(ofmap);
        dequanted_psum = compute_model::quant::custom_fma(psum_int, mul_scale.storage, false);
        new_psum       = as_float(dequanted_psum);
        ofmap          = as_uint(new_psum + last_psum);

        if (debug) {
          std::cout << "================================" << std::endl;
          std::cout << "ifmap: ";
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(ifmap_post_process[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "weight: ";
          for (int i = 0; i < 32; ++i) {
            std::cout << static_cast<int32_t>(weight_post_process[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "psum: " << psum_int << std::endl;
          std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
          std::cout << "ofmap: " << ofmap << std::endl;
        }
      }
      else {
        half   mul_scale;
        int8_t outlier_index_local[64] = {0};
        int8_t real_ifmap[64]          = {0};

        if (!ifmap_read_zero) {
          if (!SPARSE_ENABLE) {
            for (int i = 0; i < 64; ++i) {
              ifmap_local[i]         = ifmap_ptr[i];
              outlier_index_local[i] = outlier_index_ptr[i];
            }
          }
          else if (SPARSE_ENABLE) {
            for (int i = 0; i < 128; ++i) {
              if (ifmap_mask_ptr[i]) {
                ifmap_local[index]         = ifmap_ptr[i];
                outlier_index_local[index] = outlier_index_ptr[i];
                index++;
              }
            }
          }
        }
        else {
          for (int i = 0; i < 64; ++i) {
            ifmap_local[i]         = 0;
            outlier_index_local[i] = outlier_index_ptr[i];
          }
        }

        if (OUTLIER_ENABLE) {
          if (outlier_second_pass) {
            for (int i = 0; i < 64; ++i) {
              if (!outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = ifmap_scale * weight_scale;
          }
          else {
            for (int i = 0; i < 64; ++i) {
              if (outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = outlier_scale * weight_scale;
          }
        }
        else {
          for (int i = 0; i < 64; ++i) {
            real_ifmap[i] = ifmap_local[i];
            mul_scale     = ifmap_scale * weight_scale;
          }
        }
        uint32_t psum_int       = mpt::MptInt4(real_ifmap, weight_ptr, 0, false);
        float    last_psum      = as_float(psum);
        uint32_t dequanted_psum = compute_model::quant::custom_fma(psum_int, mul_scale.storage, false);
        float    new_psum       = as_float(dequanted_psum);
        // new_psum += last_psum;
        ofmap = as_uint(new_psum + last_psum);

        if (debug) {
          std::cout << "================================" << std::endl;
          std::cout << "ifmap: ";
          for (int i = 0; i < 64; ++i) {
            std::cout << static_cast<int32_t>(real_ifmap[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "weight: ";
          for (int i = 0; i < 64; ++i) {
            std::cout << static_cast<int32_t>(weight_ptr[i]) << " ";
          }
          std::cout << std::endl;
          std::cout << "psum: " << psum_int << std::endl;
          std::cout << "last_psum: " << as_uint(last_psum) << std::endl;
          std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
          std::cout << "ofmap: " << ofmap << std::endl;
        }
      }
    }
    return ofmap;
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

}  // namespace conv2d
}  // namespace compute_model