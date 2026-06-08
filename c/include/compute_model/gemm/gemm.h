#pragma once
#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/subbyte.h"
#include "compute_model/common/tensor.h"
#include "compute_model/mpt/mpt.h"
#include "compute_model/quant/custom_fma.h"
#include <cstring>
#include <typeinfo>

namespace compute_model {
namespace gemm {

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
struct GemmSim {
  static constexpr int  SPARSE_ENABLE                   = SPARSE_ENABLE_;
  static constexpr bool IFMAP_NON_UNIFORM_QUANTIZATION  = IFMAP_NON_UNIFORM_QUANTIZATION_;
  static constexpr bool WEIGHT_NON_UNIFORM_QUANTIZATION = WEIGHT_NON_UNIFORM_QUANTIZATION_;
  static constexpr bool OUTLIER_ENABLE                  = OUTLIER_ENABLE_;
  static constexpr int  DEBUG                           = DEBUG_;

  int k_group_size;
  int n_group_size;
  int k_group_scale;

  float bytes_ifmap;
  float bytes_weight;
  float bytes_ofmap;

  int ifmap_mask_ic_group_scale;

  struct Arguments {
    tensor::Tensor<TYPE_OUTPUT>& ofmap;
    tensor::Tensor<TYPE_A>       ifmap;
    tensor::Tensor<TYPE_B>       weight;
    int                          tile_m;
    int                          block_n_group;
    int                          block_k_group;

    tensor::Tensor<int8_t> ifmap_mask    = tensor::Tensor<int8_t>();
    tensor::Tensor<half>   ifmap_scale   = tensor::Tensor<half>();
    tensor::Tensor<half>   weight_scale  = tensor::Tensor<half>();
    tensor::Tensor<int8_t> outlier_index = tensor::Tensor<int8_t>();
    tensor::Tensor<half>   outlier_scale = tensor::Tensor<half>();
  };

  GemmSim()
  {
    /* -------------------------------------------- Error checking -------------------------------------------- */
    if (typeid(TYPE_A) == typeid(int16_t) && typeid(TYPE_B) == typeid(int16_t)) {
      k_group_size = 16;
      bytes_ifmap  = 2;
      bytes_weight = 2;
    }
    else if (typeid(TYPE_A) == typeid(bfloat16) || typeid(TYPE_B) == typeid(bfloat16) || typeid(TYPE_A) == typeid(half)
             || typeid(TYPE_B) == typeid(half)) {
      k_group_size = 16;
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
      k_group_size = 32;
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
      k_group_size = 64;
      bytes_ifmap  = 1;
      bytes_weight = 1;
    }
    n_group_size = 32;

    if (SPARSE_ENABLE) {
      k_group_scale = 2;
    }
    else {
      k_group_scale = 1;
    }

    bytes_ofmap = 4;

    if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      if (typeid(TYPE_A) == typeid(int16_t) || typeid(TYPE_B) == typeid(int16_t)) {
        std::cerr << "ERROR: float accumulator is not supported for int16_t" << std::endl;
        exit(1);
      }
    }

    if (IFMAP_NON_UNIFORM_QUANTIZATION || WEIGHT_NON_UNIFORM_QUANTIZATION) {
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

      if (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t)) {
        std::cerr << "ERROR: Non-uniform quantization is not supported for subbyte" << std::endl;
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

  void operator()(Arguments& args)
  {
    int32_t m       = args.ofmap.shape()[1];
    int32_t k_group = args.ifmap.shape()[0];
    int32_t n_group = args.weight.shape()[0];

    int32_t tile_m = std::min(m, args.tile_m);
    int32_t block_n_group = std::min(n_group, args.block_n_group);
    int32_t block_k_group = std::min(k_group, args.block_k_group);

    if(DEBUG){
      std::cout << std::dec << "ofmap shape: " << args.ofmap.shape()[0] << " x " << args.ofmap.shape()[1] << " x " << args.ofmap.shape()[2] << std::endl;
      std::cout << std::dec << "ifmap shape: " << args.ifmap.shape()[0] << " x " << args.ifmap.shape()[1] << " x " << args.ifmap.shape()[2] << std::endl;
      std::cout << std::dec << "weight shape: " << args.weight.shape()[0] << " x " << args.weight.shape()[1] << " x " << args.weight.shape()[2] << " x " << args.weight.shape()[3] << std::endl;
      std::cout << std::dec << "m = " << m << " k_group = " << k_group << " n_group = " << n_group << std::endl;
      std::cout << std::dec << "block_n_group = " << block_n_group << " block_k_group = " << block_k_group << std::endl;
    }

    int32_t k = args.ifmap.shape()[0] * args.ifmap.shape()[2];
    int32_t n = n_group * n_group_size;

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
      assert(args.ifmap.shape()[2] == k_group_size * k_group_scale);
      assert(args.weight.shape()[2] == n_group_size);
      assert(args.weight.shape()[3] == k_group_size * 2);
      assert(args.ifmap.shape()[0] == args.weight.shape()[1] * 2);
      k_group = ceil((double)k / (double)((k_group_size * k_group_scale) * 2));

      weight_1_ifmap_2          = true;
      ifmap_mask_ic_group_scale = 2;
    }
    else if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int4_t))
             || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int4_t))) {
      assert(args.ifmap.shape()[2] == k_group_size * k_group_scale);
      assert(args.weight.shape()[2] == n_group_size);
      assert(args.weight.shape()[3] == k_group_size * 4);
      assert(args.ifmap.shape()[0] == args.weight.shape()[1] * 4);
      k_group = ceil((double)k / (double)((k_group_size * k_group_scale) * 4));

      weight_1_ifmap_4          = true;
      ifmap_mask_ic_group_scale = 4;
    }
    else if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(half))
             || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(bfloat16))
             || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))) {
      assert(args.ifmap.shape()[2] == k_group_size * k_group_scale * 2);
      assert(args.weight.shape()[2] == n_group_size);
      assert(args.weight.shape()[3] == k_group_size);
      assert(args.ifmap.shape()[0] * 2 == args.weight.shape()[1]);
      k_group = ceil((double)k / (double)((k_group_size * k_group_scale) * 2));

      weight_2_ifmap_2          = true;
      ifmap_mask_ic_group_scale = 1;
    }
    else if (((typeid(TYPE_A) == typeid(int4_t)) && (typeid(TYPE_B) == typeid(half)))
             || ((typeid(TYPE_A) == typeid(int4_t)) && (typeid(TYPE_B) == typeid(bfloat16)))) {
      assert(args.ifmap.shape()[2] == k_group_size * k_group_scale * 4);
      assert(args.weight.shape()[2] == n_group_size);
      assert(args.weight.shape()[3] == k_group_size);
      assert(args.ifmap.shape()[0] * 4 == args.weight.shape()[1]);
      k_group = ceil((double)k / (double)((k_group_size * k_group_scale) * 4));

      weight_4_ifmap_4          = true;
      ifmap_mask_ic_group_scale = 1;
    }
    else if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t))
             || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int4_t))) {
      assert(args.ifmap.shape()[2] == k_group_size * k_group_scale);
      assert(args.weight.shape()[2] == n_group_size);
      assert(args.weight.shape()[3] == k_group_size);
      ifmap_mask_ic_group_scale = 1;
    }
    else if ((typeid(TYPE_A) == typeid(int16_t) && typeid(TYPE_B) == typeid(int16_t))
             || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(bfloat16))
             || (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(half))) {
      assert(args.ifmap.shape()[2] == k_group_size * k_group_scale);
      assert(args.weight.shape()[2] == n_group_size);
      assert(args.weight.shape()[3] == k_group_size);
      ifmap_mask_ic_group_scale = 1;
    }
    else {
      assert(args.ifmap.shape()[2] == k_group_size * k_group_scale);
      assert(args.weight.shape()[2] == n_group_size);
      assert(args.weight.shape()[3] == k_group_size);
      ifmap_mask_ic_group_scale = 1;
    }

    if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t)
         || typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int4_t)
         || typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t)
         || typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))
        && typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      assert(args.ifmap_scale.shape().size() == 1);
      assert(args.ifmap_scale.shape()[0] == args.ifmap.shape()[1]);
      assert(args.weight_scale.shape().size() == 2);
      assert(args.weight_scale.shape()[0] == args.weight.shape()[0]);
      assert(args.weight_scale.shape()[1] == args.weight.shape()[2]);
      assert(args.ifmap_scale.dtype == kHalf);
      assert(args.weight_scale.dtype == kHalf);
    }

    int m_iterations = ceil((double)m / (double)tile_m);
    int n_iterations = ceil((double)n_group / (double)block_n_group);
    int k_iterations = ceil((double)k_group / (double)block_k_group);

    if (DEBUG) {
      std::cout << "m: " << m << " n: " << n << " k: " << k << std::endl;
      std::cout << "m_iterations: " << m_iterations << " n_iterations: " << n_iterations << " k_iterations: " << k_iterations << std::endl;
    }

    int m_start;
    int ifmap_ddr_offset, weight_ddr_offset, ofmap_ddr_offset;
    int ifmap_scale_ddr_offset, weight_scale_ddr_offset;
    int outlier_index_ddr_offset;
    int ifmap_mask_ddr_offset;
    int i_ic, k_oc, k_ic;

    for (int n_iter = 0; n_iter < n_iterations; ++n_iter) {
      for (int m_iter = 0; m_iter < m_iterations; ++m_iter) {

        m_start = m_iter * tile_m;

        k_oc = std::min(n_group - (n_iter * block_n_group), block_n_group);

        TYPE_ACCUMULATOR* ofmap_ptr = new TYPE_ACCUMULATOR[block_n_group * tile_m * n_group_size];

        for (int k_iter = 0; k_iter < k_iterations; ++k_iter) {

          // real channels
          if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int8_t))
              || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int8_t))
              || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t))) {
            i_ic = std::min((k_group - (k_iter * block_k_group)) * 2, block_k_group * 2);
            k_ic = std::min(k_group - (k_iter * block_k_group), block_k_group);
          }
          else if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int4_t))
                   || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int4_t))) {
            i_ic = std::min((k_group - (k_iter * block_k_group)) * 4, block_k_group * 4);
            k_ic = std::min(k_group - (k_iter * block_k_group), block_k_group);
          }
          else if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(half))
                   || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(bfloat16))
                   || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))) {
            i_ic = std::min(k_group - (k_iter * block_k_group), block_k_group);
            k_ic = std::min((k_group - (k_iter * block_k_group)) * 2, block_k_group * 2);
          }
          else if ((typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(half))
                   || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(bfloat16))) {
            i_ic = std::min(k_group - (k_iter * block_k_group), block_k_group);
            k_ic = std::min((k_group - (k_iter * block_k_group)) * 4, block_k_group * 4);
          }
          else {
            i_ic = std::min(k_group - (k_iter * block_k_group), block_k_group);
            k_ic = std::min(k_group - (k_iter * block_k_group), block_k_group);
          }
          if(DEBUG){
            std::cout << "i_ic: " << i_ic << " k_ic: " << k_ic << std::endl;
          }
          
          // ddr offset calculation
          if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int8_t))
              || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int8_t))
              || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t))) {
            ifmap_ddr_offset = int64_t(bytes_ifmap * (k_group_size * k_group_scale) * (m * ((k_iter * block_k_group) * 2) + m_start));
            ifmap_scale_ddr_offset = int64_t(2 * (m_start));
            outlier_index_ddr_offset =
              int64_t(bytes_ifmap * (k_group_size * k_group_scale) * (m * ((k_iter * block_k_group) * 2) + m_start));
          }
          else if ((typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int4_t))
                   || (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int4_t))) {
            ifmap_ddr_offset = int64_t(bytes_ifmap * (k_group_size * k_group_scale) * (m * ((k_iter * block_k_group) * 4) + m_start));
            ifmap_scale_ddr_offset = int64_t(2 * (m_start));
            outlier_index_ddr_offset =
              int64_t(bytes_ifmap * (k_group_size * k_group_scale) * (m * ((k_iter * block_k_group) * 4) + m_start));
          }
          else {
            ifmap_ddr_offset       = int64_t(bytes_ifmap * (k_group_size * k_group_scale) * (m * (k_iter * block_k_group) + m_start));
            ifmap_scale_ddr_offset = int64_t(2 * (m_start));
            outlier_index_ddr_offset =
              int64_t(bytes_ifmap * (k_group_size * k_group_scale) * (m * (k_iter * block_k_group) + m_start));
          }

          if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(half))
              || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(bfloat16))
              || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))) {
            weight_ddr_offset     = int64_t(bytes_weight * n_group_size * k_group_size
                                        * ((k_group * 2) * (n_iter * block_n_group) + ((k_iter * block_k_group) * 2)));
            ifmap_mask_ddr_offset = int64_t(n_group_size * (k_group_size * k_group_scale * ifmap_mask_ic_group_scale)
                                            * ((k_group * 2) * (n_iter * block_n_group) + ((k_iter * block_k_group) * 2)));
          }
          else if ((typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(half))
                   || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(bfloat16))) {
            weight_ddr_offset     = int64_t(bytes_weight * n_group_size * k_group_size
                                        * ((k_group * 4) * (n_iter * block_n_group) + ((k_iter * block_k_group) * 4)));
            ifmap_mask_ddr_offset = int64_t(n_group_size * (k_group_size * k_group_scale * ifmap_mask_ic_group_scale)
                                            * ((k_group * 4) * (n_iter * block_n_group) + ((k_iter * block_k_group) * 4)));
          }
          else {
            weight_ddr_offset     = int64_t(bytes_weight * n_group_size * k_group_size
                                        * (k_group * (n_iter * block_n_group) + (k_iter * block_k_group)));
            ifmap_mask_ddr_offset = int64_t(n_group_size * (k_group_size * k_group_scale * ifmap_mask_ic_group_scale)
                                            * (k_group * (n_iter * block_n_group) + (k_iter * block_k_group)));
          }

          weight_scale_ddr_offset               = int64_t(2 * n_group_size * ((n_iter * block_n_group)));
          ofmap_ddr_offset                      = int64_t(bytes_ofmap * n_group_size * (m * (n_iter * block_n_group) + m_start));
          int outlier_index_ifmap_icgroup_scale = 1;
          if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t)) {
            outlier_index_ifmap_icgroup_scale = 2;
          }
          // temp buffer
          TYPE_A* ifmap_ptr  = (TYPE_A*)(new char[int(i_ic * tile_m * k_group_size * k_group_scale * bytes_ifmap)]);
          TYPE_B* weight_ptr = (TYPE_B*)(new char[int(block_n_group * k_ic * n_group_size * k_group_size * bytes_weight)]);
          int8_t* ifmap_mask_ptr =
            new int8_t[block_n_group * k_ic * n_group_size * k_group_size * k_group_scale * ifmap_mask_ic_group_scale];
          int8_t* outlier_index_ptr = new int8_t[i_ic * tile_m * k_group_size * k_group_scale * outlier_index_ifmap_icgroup_scale];
          half*   ifmap_scale_ptr   = new half[tile_m];
          half*   weight_scale_ptr  = new half[block_n_group * n_group_size];
          half*   outlier_scale_ptr = new half[tile_m];
          
          if(DEBUG){
            std::cout << std::dec << "ifmap_ptr " <<"i_ic: " << i_ic << " tile_m: " << tile_m << " k_group_size: " << k_group_size << " k_group_scale: " << k_group_scale << std::endl;
            std::cout << std::dec << "weight_ptr " << "block_n_group: " << block_n_group << " k_ic: " << k_ic << " n_group_size: " << n_group_size << " k_group_size: " << k_group_size << std::endl;
            std::cout << std::dec << "ifmap_ptr elements: " << int(i_ic * tile_m * k_group_size * k_group_scale) << std::endl;
            std::cout << std::dec << "weight_ptr elements: " << int(block_n_group * k_ic * n_group_size * k_group_size) << std::endl;
          }

          LoadIfmap((char*)args.ifmap.data_ptr(), (char*)ifmap_ptr, ifmap_ddr_offset, k_group, m, i_ic, tile_m);

          LoadWeight((char*)args.weight.data_ptr(), (char*)weight_ptr, weight_ddr_offset, n_group, k_group, block_n_group, k_ic);
          if (DEBUG) {
            std::cout << "====** Conv Block **====" << std::endl;
            std::cout << "n_iter: " << n_iter << " k_iter: " << k_iter << " m_iter: " << m_iter << std::endl;
          }

          if ((typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t))
              || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int4_t))
              || (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t))
              || (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t))) {
            if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
              LoadIfmapScale((char*)args.ifmap_scale.data_ptr(), (char*)ifmap_scale_ptr, ifmap_scale_ddr_offset, tile_m);

              LoadWeightScale(
                (char*)args.weight_scale.data_ptr(), (char*)weight_scale_ptr, weight_scale_ddr_offset, n_group, block_n_group);
              if (OUTLIER_ENABLE) {
                LoadIfmapScale((char*)args.outlier_scale.data_ptr(), (char*)outlier_scale_ptr, ifmap_scale_ddr_offset, tile_m);

                LoadOutlierIndex(
                  (char*)args.outlier_index.data_ptr(), (char*)outlier_index_ptr, outlier_index_ddr_offset, k_group, m, i_ic, tile_m);
              }
            }
          }

          if (SPARSE_ENABLE) {
            LoadIfmapMask(
              (char*)args.ifmap_mask.data_ptr(), (char*)ifmap_mask_ptr, ifmap_mask_ddr_offset, n_group, k_group, block_n_group, k_ic);
          }

          bool outlier_second_pass = false;

          if (OUTLIER_ENABLE && !outlier_second_pass) {
            outlier_second_pass = true;
          }

          if (DEBUG) {
            std::cout << "ifmap: " << std::endl;
            for (int j = 0; j < i_ic * tile_m; ++j) {
              int real_k_group_size = k_group_size * k_group_scale * bytes_ifmap;
              for (int i = 0; i < real_k_group_size; ++i) {
                if (i == 0) {
                  std::cout << std::dec << std::setw(2) << std::setfill(' ') << j << " ";
                }
                std::cout << std::hex << std::setfill('0') << std::setw(2)
                          << (uint32_t)((uint8_t*)ifmap_ptr)[j * int(real_k_group_size) + real_k_group_size - 1 - i];
                if (i == real_k_group_size / 2) {
                  std::cout << " ";
                }
              }
              std::cout << std::endl;
            }
            std::cout << std::endl;
            std::cout << "weight: " << std::endl;
            for (int j = 0; j < int(block_n_group * k_ic * n_group_size * k_group_size * bytes_weight) / 32; ++j) {
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
            for (int j = 0; j < tile_m; ++j) {
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
            for (int j = 0; j < block_n_group * n_group_size; ++j) {
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
              for (int j = 0; j < i_ic * tile_m; ++j) {
                for (int i = 0; i < k_group_size * k_group_scale * outlier_index_ifmap_icgroup_scale / 8; ++i) {
                  if (i == 0) {
                    std::cout << std::dec << std::setw(4) << std::setfill(' ') << j << " ";
                  }
                  int num = 0;
                  for (int l = 0; l < 8; ++l) {
                    num +=
                      ((uint8_t*)outlier_index_ptr)[j * k_group_size * k_group_scale * outlier_index_ifmap_icgroup_scale
                                                    + k_group_size * k_group_scale * outlier_index_ifmap_icgroup_scale - 1 - i * 8 + l - 7]
                      << l;
                  }
                  std::cout << std::hex << std::setfill('0') << std::setw(2) << num;
                  if (i == k_group_size * k_group_scale * outlier_index_ifmap_icgroup_scale / 8 / 2 - 1) {
                    std::cout << " ";
                  }
                }
                std::cout << std::endl;
              }
              std::cout << std::endl;
              std::cout << "outlier sclae: " << std::endl;
              for (int j = 0; j < tile_m; ++j) {
                for (int i = 0; i < 2; ++i) {
                  if (i == 0) {
                    std::cout << std::dec << std::setw(4) << std::setfill(' ') << j << " ";
                  }
                  std::cout << std::hex << std::setfill('0') << std::setw(2) << (uint32_t)((uint8_t*)outlier_scale_ptr)[j * 2 + 1 - i];
                }
                std::cout << std::endl;
              }
              std::cout << std::endl;
            }

            if (SPARSE_ENABLE) {
              std::cout << "ifmap mask: " << std::endl;
              for (int j = 0; j < int(block_n_group * k_ic * n_group_size); ++j) {
                for (int i = 0; i < k_group_size * k_group_scale * ifmap_mask_ic_group_scale / 8; ++i) {
                  if (i == 0) {
                    std::cout << std::dec << std::setw(2) << std::setfill(' ') << j << " ";
                  }
                  int num = 0;
                  for (int l = 0; l < 8; ++l) {
                    num += ((uint8_t*)ifmap_mask_ptr)[j * k_group_size * k_group_scale * ifmap_mask_ic_group_scale
                                                      + k_group_size * k_group_scale * ifmap_mask_ic_group_scale - 1 - i * 8 + l - 7]
                           << l;
                  }
                  std::cout << std::hex << std::setfill('0') << std::setw(2) << num;
                  if (i == k_group_size * k_group_scale * ifmap_mask_ic_group_scale / 8 / 2 - 1) {
                    std::cout << " ";
                  }
                  if (i == k_group_size * k_group_scale / 2) {
                    std::cout << " ";
                  }
                }
                std::cout << std::endl;
              }
              std::cout << std::endl;
            }
          }

          for (int block_n_iter = 0; block_n_iter < block_n_group; ++block_n_iter) {
            for (int block_k_iter = 0; block_k_iter < block_k_group; ++block_k_iter) {
              for (int block_m_iter = 0; block_m_iter < tile_m; ++block_m_iter) {
                for (int oc = 0; oc < n_group_size; ++oc) {
                  int psum_tile_m_read_cnt    = block_m_iter;
                  int weight_k_group_read_cnt = block_k_iter;
                  int weight_n_group_read_cnt = block_n_iter;
                  int ifmap_k_group_read_cnt  = block_k_iter;

                  if (weight_1_ifmap_2 && weight_1_ifmap_2_identifier) {
                    ifmap_k_group_read_cnt += 1;
                  }

                  if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier != 0) {
                    ifmap_k_group_read_cnt += weight_1_ifmap_4_identifier;
                  }

                  if (weight_2_ifmap_2 && weight_2_ifmap_2_identifier) {
                    weight_k_group_read_cnt += 1;
                  }

                  if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier != 0) {
                    weight_k_group_read_cnt += weight_4_ifmap_4_identifier;
                  }

                  int ifmap_local_idx = 0;

                  if (weight_2_ifmap_2) {
                    ifmap_local_idx = (ifmap_k_group_read_cnt * tile_m + psum_tile_m_read_cnt) * k_group_size * k_group_scale * 2;
                  }
                  else if (weight_4_ifmap_4) {
                    ifmap_local_idx = (ifmap_k_group_read_cnt * tile_m + psum_tile_m_read_cnt) * k_group_size * k_group_scale * 4;
                  }
                  else {
                    ifmap_local_idx = (ifmap_k_group_read_cnt * tile_m + psum_tile_m_read_cnt) * k_group_size * k_group_scale;
                  }

                  int weight_local_idx     = 0;
                  int ifmap_mask_local_idx = 0;
                  if (weight_1_ifmap_2) {
                    weight_local_idx =
                      (weight_k_group_read_cnt + weight_n_group_read_cnt * k_ic) * n_group_size * k_group_size * 2 + oc * k_group_size * 2;
                    ifmap_mask_local_idx =
                      (weight_k_group_read_cnt + weight_n_group_read_cnt * k_ic) * n_group_size * k_group_size * k_group_scale * 2
                      + oc * k_group_size * k_group_scale * 2;
                  }
                  else if (weight_1_ifmap_4) {
                    weight_local_idx =
                      (weight_k_group_read_cnt + weight_n_group_read_cnt * k_ic) * n_group_size * k_group_size * 4 + oc * k_group_size * 4;
                    ifmap_mask_local_idx =
                      (weight_k_group_read_cnt + weight_n_group_read_cnt * k_ic) * n_group_size * k_group_size * k_group_scale * 4
                      + oc * k_group_size * k_group_scale * 4;
                  }
                  else {
                    weight_local_idx =
                      (weight_k_group_read_cnt + weight_n_group_read_cnt * k_ic) * n_group_size * k_group_size + oc * k_group_size;
                    ifmap_mask_local_idx =
                      (weight_k_group_read_cnt + weight_n_group_read_cnt * k_ic) * n_group_size * k_group_size * k_group_scale
                      + oc * k_group_size * k_group_scale;
                  }
                  int ifmap_scale_local_idx  = block_m_iter;
                  int weight_scale_local_idx = block_n_iter * n_group_size + oc;

                  int      psum_local_idx = (block_m_iter + block_n_iter * tile_m) * n_group_size + oc;
                  uint32_t psum           = 0;
                  if (weight_k_group_read_cnt != 0 || (weight_1_ifmap_2 && weight_1_ifmap_2_identifier)
                      || (weight_1_ifmap_4 && weight_1_ifmap_4_identifier != 0) || (weight_4_ifmap_4 && weight_4_ifmap_4_identifier)
                      || (weight_2_ifmap_2 && weight_2_ifmap_2_identifier != 0) || k_iter != 0
                      || (!outlier_second_pass && OUTLIER_ENABLE)) {
                    psum = as_uint(ofmap_ptr[psum_local_idx]);
                  }
                  else {
                    psum = 0;
                  }

                  if (typeid(TYPE_A) == typeid(int16_t) && typeid(TYPE_B) == typeid(int16_t)) {
                    ofmap_ptr[psum_local_idx] = mpt_int16((int16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (int16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          psum);
                  }

                  if (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(half)) {
                    ofmap_ptr[psum_local_idx] = mpt_fpxfp((uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          oc == 0 && DEBUG_);
                  }

                  if (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(bfloat16)) {
                    ofmap_ptr[psum_local_idx] = mpt_fpxbf((uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum));
                  }

                  if (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int8_t)) {
                    ofmap_ptr[psum_local_idx] = mpt_fpxi8((uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (int8_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          weight_1_ifmap_2_identifier);
                  }

                  if (typeid(TYPE_A) == typeid(half) && typeid(TYPE_B) == typeid(int4_t)) {
                    ofmap_ptr[psum_local_idx] = mpt_fpxi4((uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (int8_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          weight_1_ifmap_4_identifier);
                  }

                  if (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int8_t)) {
                    if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                      ofmap_ptr[psum_local_idx] = as_float(mpt_i8xi8((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                     (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                     (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                     (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                     psum,
                                                                     ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                     weight_scale_ptr[weight_scale_local_idx],
                                                                     outlier_scale_ptr[ifmap_scale_local_idx],
                                                                     outlier_second_pass));
                    }
                    else {
                      ofmap_ptr[psum_local_idx] = mpt_i8xi8((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                            (int8_t*)(&weight_ptr[weight_local_idx]),
                                                            (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                            (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                            psum,
                                                            ifmap_scale_ptr[ifmap_scale_local_idx],
                                                            weight_scale_ptr[weight_scale_local_idx],
                                                            outlier_scale_ptr[ifmap_scale_local_idx]);
                    }
                  }

                  if (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(int4_t)) {
                    if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                      ofmap_ptr[psum_local_idx] = as_float(mpt_i8xi4((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                     (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                     (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                     (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                     psum,
                                                                     ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                     weight_scale_ptr[weight_scale_local_idx],
                                                                     outlier_scale_ptr[ifmap_scale_local_idx],
                                                                     weight_1_ifmap_2_identifier,
                                                                     outlier_second_pass));
                    }
                    else {
                      ofmap_ptr[psum_local_idx] = mpt_i8xi4((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
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
                    ofmap_ptr[psum_local_idx] = mpt_i8xfp((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          weight_2_ifmap_2_identifier);
                  }

                  if (typeid(TYPE_A) == typeid(int8_t) && typeid(TYPE_B) == typeid(bfloat16)) {
                    ofmap_ptr[psum_local_idx] = mpt_i8xbf((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          weight_2_ifmap_2_identifier);
                  }

                  if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int4_t)) {
                    if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                      ofmap_ptr[psum_local_idx] = as_float(mpt_i4xi4((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                     (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                     (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                     (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                     psum,
                                                                     ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                     weight_scale_ptr[weight_scale_local_idx],
                                                                     outlier_scale_ptr[ifmap_scale_local_idx],
                                                                     outlier_second_pass));
                    }
                    else {
                      ofmap_ptr[psum_local_idx] = mpt_i4xi4((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
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
                    ofmap_ptr[psum_local_idx] = mpt_i4xfp((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          weight_4_ifmap_4_identifier);
                  }

                  if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(bfloat16)) {
                    ofmap_ptr[psum_local_idx] = mpt_i4xbf((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          weight_4_ifmap_4_identifier);
                  }

                  if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t)) {
                    if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
                      ofmap_ptr[psum_local_idx] = as_float(mpt_i4xi8((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                                     (int8_t*)(&weight_ptr[weight_local_idx]),
                                                                     (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                                     (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                                     psum,
                                                                     ifmap_scale_ptr[ifmap_scale_local_idx],
                                                                     weight_scale_ptr[weight_scale_local_idx],
                                                                     outlier_scale_ptr[ifmap_scale_local_idx],
                                                                     weight_2_ifmap_2_identifier,
                                                                     outlier_second_pass));
                    }
                    else {
                      ofmap_ptr[psum_local_idx] = mpt_i4xi8((int8_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                            (int8_t*)(&weight_ptr[weight_local_idx]),
                                                            (int8_t*)(&outlier_index_ptr[ifmap_local_idx]),
                                                            (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                            psum,
                                                            ifmap_scale_ptr[ifmap_scale_local_idx],
                                                            weight_scale_ptr[weight_scale_local_idx],
                                                            outlier_scale_ptr[ifmap_scale_local_idx],
                                                            weight_2_ifmap_2_identifier,
                                                            false);
                    }
                  }

                  if (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(half)) {
                    ofmap_ptr[psum_local_idx] = mpt_bfxfp((uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum));
                  }

                  if (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(bfloat16)) {
                    ofmap_ptr[psum_local_idx] = mpt_bfxbf((uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (uint16_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum));
                  }

                  if (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int8_t)) {
                    ofmap_ptr[psum_local_idx] = mpt_bfxi8((uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (int8_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          weight_1_ifmap_2_identifier);
                  }

                  if (typeid(TYPE_A) == typeid(bfloat16) && typeid(TYPE_B) == typeid(int4_t)) {
                    ofmap_ptr[psum_local_idx] = mpt_bfxi4((uint16_t*)(&ifmap_ptr[ifmap_local_idx]),
                                                          (int8_t*)(&weight_ptr[weight_local_idx]),
                                                          (uint8_t*)(&ifmap_mask_ptr[ifmap_mask_local_idx]),
                                                          as_float(psum),
                                                          weight_1_ifmap_4_identifier);
                  }
                }
              }

              if (DEBUG) {
                std::cout << "==== Gemm Execute ====" << std::endl;
                std::cout << "block_n_iter: " << block_n_iter << " block_k_iter: " << block_k_iter
                          << " outlier_second_pass: " << outlier_second_pass << std::endl;
                std::cout << "ofmap: " << std::endl;
                for (int j = 0; j < int(block_n_group * tile_m * n_group_size * bytes_ofmap) / 128; ++j) {
                  for (int i = 0; i < 128; ++i) {
                    if (i == 0) {
                      std::cout << std::dec << std::setw(2) << std::setfill(' ') << j << " ";
                    }
                    std::cout << std::hex << std::setfill('0') << std::setw(2) << (uint32_t)((uint8_t*)ofmap_ptr)[j * 128 + 127 - i];
                  }
                  std::cout << std::endl;
                }
              }

              if (weight_1_ifmap_2 && (!weight_1_ifmap_2_identifier)) {
                if ((typeid(TYPE_A) == typeid(int8_t)) && (typeid(TYPE_B) == typeid(int4_t)) && OUTLIER_ENABLE) {
                  if (outlier_second_pass == false) {
                    weight_1_ifmap_2_identifier = 1;
                    block_k_iter                = block_k_iter - 1;
                  }
                  else {
                    block_k_iter = block_k_iter - 1;
                  }
                }
                else {
                  weight_1_ifmap_2_identifier = 1;
                  block_k_iter                = block_k_iter - 1;
                }
              }
              else if (weight_1_ifmap_2 && (weight_1_ifmap_2_identifier)) {
                if ((typeid(TYPE_A) == typeid(int8_t)) && (typeid(TYPE_B) == typeid(int4_t)) && OUTLIER_ENABLE) {
                  if (outlier_second_pass == false) {
                    weight_1_ifmap_2_identifier = 0;
                  }
                  else {
                    block_k_iter = block_k_iter - 1;
                  }
                }
                else {
                  weight_1_ifmap_2_identifier = 0;
                }
              }

              if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier == 0) {
                weight_1_ifmap_4_identifier = 1;
                block_k_iter                = block_k_iter - 1;
              }
              else if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier == 1) {
                weight_1_ifmap_4_identifier = 2;
                block_k_iter                = block_k_iter - 1;
              }
              else if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier == 2) {
                weight_1_ifmap_4_identifier = 3;
                block_k_iter                = block_k_iter - 1;
              }
              else if (weight_1_ifmap_4 && weight_1_ifmap_4_identifier == 3) {
                weight_1_ifmap_4_identifier = 0;
              }

              if (weight_2_ifmap_2 && !weight_2_ifmap_2_identifier) {
                if ((typeid(TYPE_A) == typeid(int4_t)) && (typeid(TYPE_B) == typeid(int8_t)) && OUTLIER_ENABLE) {
                  if (outlier_second_pass == false) {
                    weight_2_ifmap_2_identifier = 1;
                    block_k_iter                = -1;
                  }
                  else {
                    block_k_iter = block_k_iter - 1;
                  }
                }
                else {
                  weight_2_ifmap_2_identifier = 1;
                  block_k_iter                = -1;
                }
              }
              else if (weight_2_ifmap_2 && weight_2_ifmap_2_identifier) {
                if ((typeid(TYPE_A) == typeid(int4_t)) && (typeid(TYPE_B) == typeid(int8_t)) && OUTLIER_ENABLE) {
                  if (outlier_second_pass == false) {
                    weight_2_ifmap_2_identifier = 0;
                  }
                  else {
                    block_k_iter = block_k_iter - 1;
                  }
                }
                else {
                  weight_2_ifmap_2_identifier = 0;
                }
              }

              if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier == 0) {
                weight_4_ifmap_4_identifier = 1;
                block_k_iter                = block_k_iter - 1;
              }
              else if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier == 1) {
                weight_4_ifmap_4_identifier = 2;
                block_k_iter                = block_k_iter - 1;
              }
              else if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier == 2) {
                weight_4_ifmap_4_identifier = 3;
                block_k_iter                = block_k_iter - 1;
              }
              else if (weight_4_ifmap_4 && weight_4_ifmap_4_identifier == 3) {
                weight_4_ifmap_4_identifier = 0;
              }

              if (OUTLIER_ENABLE && outlier_second_pass) {
                outlier_second_pass = false;
                if ((!weight_1_ifmap_2) && (!weight_2_ifmap_2)) {
                  block_n_iter = block_n_iter - 1;
                }
              }
              else if (OUTLIER_ENABLE && (!outlier_second_pass)) {
                if (block_k_iter == block_k_group - 1) {
                  outlier_second_pass = false;
                }
                else {
                  outlier_second_pass = true;
                }
              }
            }
          }

          if (k_iter == k_iterations - 1) {
            StoreOfmap((char*)args.ofmap.data_ptr(), (char*)ofmap_ptr, ofmap_ddr_offset, n_group, m, block_n_group, tile_m);
          }
          delete ifmap_ptr;
          delete weight_ptr;
          delete ifmap_mask_ptr;
          delete outlier_index_ptr;
          delete ifmap_scale_ptr;
          delete weight_scale_ptr;
          delete outlier_scale_ptr;
        }
        delete ofmap_ptr;
      }
    }
  }

  void LoadIfmap(char* ddr_ptr, char* sram_ptr, int64_t ddr_base_addr, int64_t k_group, int64_t m, int64_t block_k_group, int64_t tile_m)
  {
    int seq_1_offset = bytes_ifmap * k_group_size * k_group_scale * m;
    int burst_0      = typeid(TYPE_A) == typeid(int4_t) ? tile_m * k_group_scale * 2 : tile_m * k_group_scale;
    int burst_1      = block_k_group;

    if (DEBUG) {
      std::cout << "==== Load Ifmap ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
      int sram_offset = (burst_1_iter * burst_0) * 32;
      int ddr_offset  = burst_1_iter * seq_1_offset;
      std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * 32);
      if (DEBUG) {
        std::cout << "sram_offset: " << sram_offset << std::endl;
        std::cout << "ddr_offset: " << ddr_offset << std::endl;
      }
    }
  }

  void LoadWeight(
    char* ddr_ptr, char* sram_ptr, int64_t ddr_base_addr, int64_t n_group, int64_t k_group, int64_t block_n_group, int64_t block_k_group)
  {
    int seq_1_offset = bytes_weight * k_group_size * n_group_size;
    int seq_2_offset = bytes_weight * k_group_size * n_group_size * k_group;

    int burst_0 = typeid(TYPE_B) == typeid(int4_t) ? n_group_size * 2 : n_group_size;
    int burst_1 = block_k_group;
    int burst_2 = block_n_group;

    if (DEBUG) {
      std::cout << "==== Load Weight ====" << std::endl;
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

  void LoadIfmapScale(char* ddr_ptr, char* sram_ptr, int64_t ddr_base_addr, int64_t tile_m)
  {
    int burst_0 = tile_m;

    if (DEBUG) {
      std::cout << "==== Load Ifmap Scale ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    std::memcpy(sram_ptr, ddr_ptr + ddr_base_addr, burst_0 * 2);
  }

  void LoadWeightScale(char* ddr_ptr, char* sram_ptr, int64_t ddr_base_addr, int64_t n_group, int64_t block_n_group)
  {
    int seq_1_offset = 2 * n_group_size;

    int burst_0 = n_group_size;
    int burst_1 = block_n_group;

    if (DEBUG) {
      std::cout << "==== Load Weight Scale ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
      int sram_offset = (burst_1_iter * burst_0) * 2;
      int ddr_offset  = burst_1_iter * seq_1_offset;
      std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * 2);
    }
  }

  void
  LoadOutlierIndex(char* ddr_ptr, char* sram_ptr, int64_t ddr_base_addr, int64_t k_group, int64_t m, int64_t block_k_group, int64_t tile_m)
  {
    int seq_1_offset = 0;
    int burst_0      = 0;
    if (typeid(TYPE_A) == typeid(int4_t) && typeid(TYPE_B) == typeid(int8_t)) {
      seq_1_offset = k_group_size * k_group_scale * m * 2;
      burst_0      = tile_m * k_group_scale * 2;
    }
    else {
      seq_1_offset = k_group_size * k_group_scale * m;
      burst_0      = tile_m * k_group_scale;
    }
    int burst_1 = block_k_group;

    if (DEBUG) {
      std::cout << "==== Load Ifmap ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
      int sram_offset = (burst_1_iter * burst_0) * k_group_size;
      int ddr_offset  = burst_1_iter * seq_1_offset;
      std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * k_group_size);
    }
  }

  void LoadIfmapMask(
    char* ddr_ptr, char* sram_ptr, int64_t ddr_base_addr, int64_t n_group, int64_t k_group, int64_t block_n_group, int64_t block_k_group)
  {
    int seq_1_offset = k_group_size * n_group_size * k_group_scale * ifmap_mask_ic_group_scale;
    int seq_2_offset = k_group_size * n_group_size * k_group_scale * k_group * ifmap_mask_ic_group_scale;

    int burst_0 = n_group_size * k_group_scale * ifmap_mask_ic_group_scale;
    int burst_1 = block_k_group;
    int burst_2 = block_n_group;

    if (DEBUG) {
      std::cout << "==== Load Ifmap Mask ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "burst_2: " << burst_2 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "seq_2_offset: " << seq_2_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_2_iter = 0; burst_2_iter < burst_2; ++burst_2_iter) {
      for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
        int sram_offset = (burst_1_iter * burst_0 + burst_2_iter * burst_1 * burst_0) * k_group_size;
        int ddr_offset  = burst_1_iter * seq_1_offset + burst_2_iter * seq_2_offset;
        std::memcpy(sram_ptr + sram_offset, ddr_ptr + ddr_base_addr + ddr_offset, burst_0 * k_group_size);
      }
    }
  }

  void StoreOfmap(char* ddr_ptr, char* sram_ptr, int64_t ddr_base_addr, int64_t k_group, int64_t m, int64_t block_k_group, int64_t tile_m)
  {
    int seq_1_offset = bytes_ofmap * n_group_size * m;
    int burst_0      = tile_m * 4;
    int burst_1      = block_k_group;

    if (DEBUG) {
      std::cout << "==== Store Ofmap ====" << std::endl;
      std::cout << "burst_0: " << burst_0 << std::endl;
      std::cout << "burst_1: " << burst_1 << std::endl;
      std::cout << "seq_1_offset: " << seq_1_offset << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
    }

    for (int burst_1_iter = 0; burst_1_iter < burst_1; ++burst_1_iter) {
      int sram_offset = (burst_1_iter * burst_0) * 32;
      int ddr_offset  = burst_1_iter * seq_1_offset;
      std::memcpy(ddr_ptr + ddr_base_addr + ddr_offset, sram_ptr + sram_offset, burst_0 * 32);
    }
  }

  int32_t mpt_int16(int16_t* ifmap_ptr, int16_t* weight_ptr, uint8_t* ifmap_mask_ptr, int32_t psum, bool debug = false)
  {
    int32_t ofmap           = 0;
    int16_t ifmap_local[16] = {0};
    int     index           = 0;

    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] == ifmap_ptr[i];
      }
    }
    else if (SPARSE_ENABLE == 1) {
      for (int i = 0; i < 32; ++i) {
        if (ifmap_mask_ptr[i] == 1) {
          ifmap_local[index] = ifmap_ptr[i];
          index++;
        }
      }
    }

    ofmap = mpt::MptInt16(ifmap_local, weight_ptr, psum, false);

    if (debug) {
      std::cout << "==== MPT Int16 ====" << std::endl;
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
      std::cout << "ofmap: " << ofmap << std::endl;
    }

    return ofmap;
  }

  float mpt_bfxbf(uint16_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, bool debug = false)
  {
    float    ofmap           = 0;
    uint16_t ifmap_local[16] = {0};
    int      index           = 0;
    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = ifmap_ptr[i];
      }
    }
    else if (SPARSE_ENABLE == 1) {
      for (int i = 0; i < 32; ++i) {
        if (ifmap_mask_ptr[i] == 1) {
          ifmap_local[index] = ifmap_ptr[i];
          index++;
        }
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

  float mpt_bfxfp(uint16_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, bool debug = false)
  {
    float    ofmap           = 0;
    uint16_t ifmap_local[16] = {0};
    int      index           = 0;
    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = ifmap_ptr[i];
      }
    }
    else if (SPARSE_ENABLE == 1) {
      for (int i = 0; i < 32; ++i) {
        if (ifmap_mask_ptr[i] == 1) {
          ifmap_local[index] = ifmap_ptr[i];
          index++;
        }
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

  float mpt_bfxi8(
    uint16_t* ifmap_ptr, int8_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, bool weight_1_ifmap_2_identifier, bool debug = false)
  {
    float    ofmap            = 0;
    uint16_t ifmap_local[16]  = {0};
    int16_t  weight_local[16] = {0};
    int      index            = 0;
    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = ifmap_ptr[i];
      }
    }
    else if (SPARSE_ENABLE == 1) {
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

  float mpt_bfxi4(
    uint16_t* ifmap_ptr, int8_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, int weight_1_ifmap_4_identifier, bool debug = false)
  {
    float    ofmap            = 0;
    uint16_t ifmap_local[16]  = {0};
    int16_t  weight_local[16] = {0};
    int      index            = 0;
    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = ifmap_ptr[i];
      }
    }
    else if (SPARSE_ENABLE == 1) {
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

  float mpt_fpxbf(uint16_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum)
  {
    float ofmap           = 0;
    half  ifmap_local[16] = {0};
    int   index           = 0;
    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = half(ifmap_ptr[i]);
      }
    }
    else if (SPARSE_ENABLE == 1) {
      for (int i = 0; i < 32; ++i) {
        if (ifmap_mask_ptr[i] == 1) {
          ifmap_local[index] = half(ifmap_ptr[i]);
          index++;
        }
      }
    }

    ofmap = mpt::MptFloat((uint16_t*)ifmap_local, weight_ptr, psum, 2, 3, 0, false);
    return ofmap;
  }

  float mpt_fpxfp(uint16_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, bool debug = false)
  {
    float ofmap           = 0;
    half  ifmap_local[16] = {0};
    int   index           = 0;
    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = half(ifmap_ptr[i]);
      }
    }
    else if (SPARSE_ENABLE == 1) {
      for (int i = 0; i < 32; ++i) {
        if (ifmap_mask_ptr[i] == 1) {
          ifmap_local[index] = half(ifmap_ptr[i]);
          index++;
        }
      }
    }

    ofmap = mpt::MptFloat((uint16_t*)ifmap_local, (uint16_t*)weight_ptr, psum, 2, 2, 0, false);

    if (debug) {
      if (SPARSE_ENABLE) {
        std::cout << "ifmap mask: " << std::endl;
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<uint32_t>((ifmap_mask_ptr)[i]) << " ";
        }
        std::cout << std::endl;
        std::cout << "ifmap origin: " << std::endl;
        for (int i = 0; i < 16 * k_group_scale; ++i) {
          std::cout << static_cast<uint32_t>(reinterpret_cast<int16_t*>(ifmap_ptr)[i]) << " ";
        }
        std::cout << std::endl;
      }
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

  float mpt_fpxi8(
    uint16_t* ifmap_ptr, int8_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, bool weight_1_ifmap_2_identifier, bool debug = false)
  {
    float   ofmap            = 0;
    half    ifmap_local[16]  = {0};
    int16_t weight_local[16] = {0};
    int     index            = 0;
    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = half(ifmap_ptr[i]);
      }
    }
    else if (SPARSE_ENABLE == 1) {
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
    }

    return ofmap;
  }

  float mpt_fpxi4(
    uint16_t* ifmap_ptr, int8_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, int weight_1_ifmap_4_identifier, bool debug = false)
  {
    float   ofmap            = 0;
    half    ifmap_local[16]  = {0};
    int16_t weight_local[16] = {0};
    int     index            = 0;
    if (SPARSE_ENABLE == 0) {
      for (int i = 0; i < 16; ++i) {
        ifmap_local[i] = half(ifmap_ptr[i]);
      }
    }
    else if (SPARSE_ENABLE == 1) {
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
    }

    return ofmap;
  }

  float mpt_i8xbf(
    int8_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, int weight_2_ifmap_2_identifier, bool debug = false)
  {
    float   ofmap = 0;
    int16_t ifmap_local[16];
    int     index = 0;

    if (!weight_2_ifmap_2_identifier) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 16]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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

  float mpt_i8xfp(
    int8_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, int weight_2_ifmap_2_identifier, bool debug = false)
  {
    float   ofmap = 0;
    int16_t ifmap_local[16];
    int     index = 0;

    if (!weight_2_ifmap_2_identifier) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 16]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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

  uint32_t mpt_i8xi8(int8_t*  ifmap_ptr,
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
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 32; ++i) {
          ifmap_local[i] = ifmap_ptr[i];
        }
      }
      else if (SPARSE_ENABLE == 1) {
        for (int i = 0; i < 64; ++i) {
          if (ifmap_mask_ptr[i] == 1) {
            ifmap_local[index] = ifmap_ptr[i];
            index++;
          }
        }
      }

      ofmap = mpt::MptInt8(ifmap_local, weight_ptr, psum, false);
    }
    else if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      half   mul_scale;
      int8_t outlier_index_local[32] = {0};
      int8_t real_ifmap[32]          = {0};
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 32; ++i) {
          ifmap_local[i]         = ifmap_ptr[i];
          outlier_index_local[i] = outlier_index_ptr[i];
        }
      }
      else if (SPARSE_ENABLE == 1) {
        for (int i = 0; i < 64; ++i) {
          if (ifmap_mask_ptr[i]) {
            ifmap_local[index]         = ifmap_ptr[i];
            outlier_index_local[index] = outlier_index_ptr[i];
            index++;
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
        if (SPARSE_ENABLE == 1) {
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
        std::cout << "weight_scale: " << weight_scale.storage << std::endl;
        std::cout << "mul_scale: " << mul_scale.storage << std::endl;
        std::cout << "last_psum: " << as_uint(last_psum) << std::endl;
        std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
        std::cout << "ofmap: " << ofmap << std::endl;
      }
    }
    return ofmap;
  }

  uint32_t mpt_i8xi4(int8_t*  ifmap_ptr,
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
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 32; ++i) {
          ifmap_local[i] = ifmap_ptr[i];
        }
      }
      else if (SPARSE_ENABLE == 1) {
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

      ofmap = mpt::MptInt8(ifmap_local, weight_local, psum, false);
    }
    else if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      half   mul_scale;
      int8_t outlier_index_local[32] = {0};
      int8_t real_ifmap[32]          = {0};

      int index = 0;
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 32; ++i) {
          ifmap_local[i]         = ifmap_ptr[i];
          outlier_index_local[i] = outlier_index_ptr[i];
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
        if (SPARSE_ENABLE) {
          std::cout << "ifmap origin: " << std::endl;
          for (int i = 0; i < 64; ++i) {
            std::cout << static_cast<int32_t>(ifmap_ptr[i]) << " ";
          }
          std::cout << std::endl;
        }
        std::cout << "ifmap: ";
        for (int i = 0; i < 32; ++i) {
          std::cout << static_cast<int32_t>(ifmap_local[i]) << " ";
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

  float mpt_i4xbf(
    int8_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, int weight_4_ifmap_4_identifier, bool debug = false)
  {
    float   ofmap = 0;
    int16_t ifmap_local[16];
    int     index = 0;

    if (weight_4_ifmap_4_identifier == 0) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
    else if (weight_4_ifmap_4_identifier == 1) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 16]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
    else if (weight_4_ifmap_4_identifier == 2) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 32]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
    else if (weight_4_ifmap_4_identifier == 3) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 48]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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

  float mpt_i4xfp(
    int8_t* ifmap_ptr, uint16_t* weight_ptr, uint8_t* ifmap_mask_ptr, float psum, int weight_4_ifmap_4_identifier, bool debug = false)
  {
    float   ofmap = 0;
    int16_t ifmap_local[16];
    int     index = 0;

    if (weight_4_ifmap_4_identifier == 0) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
    else if (weight_4_ifmap_4_identifier == 1) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 16]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
    else if (weight_4_ifmap_4_identifier == 2) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 32]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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
    else if (weight_4_ifmap_4_identifier == 3) {
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 16; ++i) {
          ifmap_local[i] = static_cast<int16_t>(ifmap_ptr[i + 48]);
        }
      }
      else if (SPARSE_ENABLE == 1) {
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

    if (debug) {
      std::cout << "weight_4_ifmap_4_identifier: " << weight_4_ifmap_4_identifier << std::endl;
      if (SPARSE_ENABLE) {
        std::cout << "ifmap mask: ";
        for (int i = 0; i < 32 * k_group_scale; ++i) {
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

  uint32_t mpt_i4xi8(int8_t*  ifmap_ptr,
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
        if (SPARSE_ENABLE == 0) {
          for (int i = 0; i < 32; ++i) {
            ifmap_local[i] = ifmap_ptr[i];
          }
        }
        else if (SPARSE_ENABLE == 1) {
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
        if (SPARSE_ENABLE == 0) {
          for (int i = 0; i < 32; ++i) {
            ifmap_local[i] = ifmap_ptr[i + 32];
          }
        }
        else if (SPARSE_ENABLE == 1) {
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

      ofmap = mpt::MptInt8(ifmap_local, weight_ptr, psum, false);
    }
    else if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      if (IFMAP_NON_UNIFORM_QUANTIZATION) {
        half   mul_scale;
        int8_t outlier_index_local[32] = {0};
        int8_t real_ifmap[32]          = {0};

        if (!weight_2_ifmap_2_identifier) {
          if (SPARSE_ENABLE == 0) {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i]         = ifmap_ptr[i];
              outlier_index_local[i] = outlier_index_ptr[i];
            }
          }
          else if (SPARSE_ENABLE == 1) {
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
          if (SPARSE_ENABLE == 0) {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i]         = ifmap_ptr[i + 32];
              outlier_index_local[i] = outlier_index_ptr[i + 32];
            }
          }
          else if (SPARSE_ENABLE == 1) {
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
          if (SPARSE_ENABLE == 1) {
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
          if (SPARSE_ENABLE == 0) {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i]         = ifmap_ptr[i];
              outlier_index_local[i] = outlier_index_ptr[i];
            }
          }
          else if (SPARSE_ENABLE == 1) {
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
          if (SPARSE_ENABLE == 0) {
            for (int i = 0; i < 32; ++i) {
              ifmap_local[i]         = ifmap_ptr[i + 32];
              outlier_index_local[i] = outlier_index_ptr[i + 32];
            }
          }
          else if (SPARSE_ENABLE == 1) {
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
          if (SPARSE_ENABLE == 1) {
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
          std::cout << "last_psum: " << as_uint(last_psum) << std::endl;
          std::cout << "new_psum: " << as_uint(new_psum) << std::endl;
          std::cout << "ofmap: " << ofmap << std::endl;
        }
      }
    }

    return ofmap;
  }

  uint32_t mpt_i4xi4(int8_t*  ifmap_ptr,
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
      if (SPARSE_ENABLE == 0) {
        for (int i = 0; i < 64; ++i) {
          ifmap_local[i] = ifmap_ptr[i];
        }
      }
      else if (SPARSE_ENABLE == 1) {
        for (int i = 0; i < 128; ++i) {
          if (ifmap_mask_ptr[i] == 1) {
            ifmap_local[index] = ifmap_ptr[i];
            index++;
          }
        }
      }

      ofmap = mpt::MptInt4(ifmap_local, weight_ptr, psum, false);
    }
    else if (typeid(TYPE_ACCUMULATOR) == typeid(float)) {
      if (IFMAP_NON_UNIFORM_QUANTIZATION || WEIGHT_NON_UNIFORM_QUANTIZATION) {
        half   mul_scale;
        int8_t outlier_index_local[64] = {0};
        int8_t real_ifmap[64]          = {0};

        if (SPARSE_ENABLE == 0) {
          for (int i = 0; i < 64; ++i) {
            ifmap_local[i]         = ifmap_ptr[i];
            outlier_index_local[i] = outlier_index_ptr[i];
          }
        }
        else if (SPARSE_ENABLE == 1) {
          for (int i = 0; i < 128; ++i) {
            if (ifmap_mask_ptr[i]) {
              ifmap_local[index]         = ifmap_ptr[i];
              outlier_index_local[index] = outlier_index_ptr[i];
              index++;
            }
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

        if (SPARSE_ENABLE == 0) {
          for (int i = 0; i < 64; ++i) {
            ifmap_local[i]         = ifmap_ptr[i];
            outlier_index_local[i] = outlier_index_ptr[i];
          }
        }
        else if (SPARSE_ENABLE == 1) {
          for (int i = 0; i < 128; ++i) {
            if (ifmap_mask_ptr[i]) {
              ifmap_local[index]         = ifmap_ptr[i];
              outlier_index_local[index] = outlier_index_ptr[i];
              index++;
            }
          }
        }

        if (OUTLIER_ENABLE) {
          if (outlier_second_pass) {
            for (int i = 0; i < 64; ++i) {
              if (outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = outlier_scale * weight_scale;
          }
          else {
            for (int i = 0; i < 64; ++i) {
              if (!outlier_index_local[i]) {
                real_ifmap[i] = ifmap_local[i];
              }
            }
            mul_scale = ifmap_scale * weight_scale;
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
        new_psum += last_psum;
        ofmap = as_uint(new_psum);

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
}  // namespace gemm
}  // namespace compute_model