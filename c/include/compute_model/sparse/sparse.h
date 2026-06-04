#pragma once

#include "compute_model/common/tensor.h"
#include <cstdint>

namespace compute_model {
namespace sparse {

using namespace tensor;

template<typename T>
Tensor<T> WeightProcess(const Tensor<T>& weight, const Tensor<int8_t>& ifmap_mask, int sparse_ratio)
{
  int       oc_group      = 0;
  int       ic_group      = 0;
  int       kh            = 0;
  int       kw            = 0;
  int       oc_group_size = 0;
  int       ic_group_size = 0;
  Tensor<T> weight_out;
  if (weight.shape_.size() == 6) {
    oc_group      = weight.shape(0);
    ic_group      = weight.shape(1);
    kh            = weight.shape(2);
    kw            = weight.shape(3);
    oc_group_size = weight.shape(4);
    ic_group_size = weight.shape(5);
    weight_out    = zeros<T>({oc_group, ic_group / sparse_ratio, kh, kw, oc_group_size, ic_group_size}, kHalf);
  }
  else {
    oc_group      = weight.shape(0);
    ic_group      = weight.shape(1);
    kh            = 1;
    kw            = 1;
    oc_group_size = weight.shape(2);
    ic_group_size = weight.shape(3);
    weight_out    = zeros<T>({oc_group, ic_group / sparse_ratio, oc_group_size, ic_group_size}, kHalf);
  }

  int ic_group_offset = 0, ori_idx = 0, dst_idx_base = 0;

  for (int oc_iter = 0; oc_iter < oc_group; ++oc_iter) {
    for (int kh_iter = 0; kh_iter < kh; ++kh_iter) {
      for (int kw_iter = 0; kw_iter < kw; ++kw_iter) {
        for (int oc_group_iter = 0; oc_group_iter < oc_group_size; ++oc_group_iter) {
          for (int ic_iter = 0; ic_iter < ic_group; ++ic_iter) {
            if (ic_iter % sparse_ratio == 0) {
              ic_group_offset = 0;
            }
            for (int ic_group_iter = 0; ic_group_iter < ic_group_size; ++ic_group_iter) {
              ori_idx = oc_iter * ic_group * kh * kw * oc_group_size * ic_group_size + ic_iter * kh * kw * oc_group_size * ic_group_size
                        + kh_iter * kw * oc_group_size * ic_group_size + kw_iter * oc_group_size * ic_group_size
                        + oc_group_iter * ic_group_size + ic_group_iter;
              dst_idx_base = oc_iter * (ic_group / sparse_ratio) * kh * kw * oc_group_size * ic_group_size
                             + (ic_iter / sparse_ratio) * kh * kw * oc_group_size * ic_group_size
                             + kh_iter * kw * oc_group_size * ic_group_size + kw_iter * oc_group_size * ic_group_size
                             + oc_group_iter * ic_group_size + ic_group_offset;
              if (ifmap_mask[ori_idx] == 1) {
                weight_out[dst_idx_base] = weight[ori_idx];
                ic_group_offset += 1;
              }
            }
          }
        }
      }
    }
  }

  return weight_out;
}

template<typename T>
Tensor<T> weightetZero(const Tensor<T>& weight, const Tensor<int8_t>& ifmap_mask, int sparse_ratio)
{
  int       oc_group      = 0;
  int       ic_group      = 0;
  int       kh            = 0;
  int       kw            = 0;
  int       oc_group_size = 0;
  int       ic_group_size = 0;
  Tensor<T> weight_out;
  if (weight.shape_.size() == 6) {
    oc_group      = weight.shape(0);
    ic_group      = weight.shape(1);
    kh            = weight.shape(2);
    kw            = weight.shape(3);
    oc_group_size = weight.shape(4);
    ic_group_size = weight.shape(5);
    weight_out    = zeros<T>({oc_group, ic_group / sparse_ratio, kh, kw, oc_group_size, ic_group_size * sparse_ratio}, kHalf);
  }
  else {
    oc_group      = weight.shape(0);
    ic_group      = weight.shape(1);
    kh            = 1;
    kw            = 1;
    oc_group_size = weight.shape(2);
    ic_group_size = weight.shape(3);
    weight_out    = zeros<T>({oc_group, ic_group / sparse_ratio, oc_group_size, ic_group_size * sparse_ratio}, kHalf);
  }

  int ori_idx = 0, dst_idx = 0;

  for (int oc_iter = 0; oc_iter < oc_group; ++oc_iter) {
    for (int kh_iter = 0; kh_iter < kh; ++kh_iter) {
      for (int kw_iter = 0; kw_iter < kw; ++kw_iter) {
        for (int oc_group_iter = 0; oc_group_iter < oc_group_size; ++oc_group_iter) {
          for (int ic_iter = 0; ic_iter < ic_group; ++ic_iter) {
            for (int ic_group_iter = 0; ic_group_iter < ic_group_size; ++ic_group_iter) {
              ori_idx = oc_iter * ic_group * kh * kw * oc_group_size * ic_group_size + ic_iter * kh * kw * oc_group_size * ic_group_size
                        + kh_iter * kw * oc_group_size * ic_group_size + kw_iter * oc_group_size * ic_group_size
                        + oc_group_iter * ic_group_size + ic_group_iter;
              dst_idx = oc_iter * (ic_group / sparse_ratio) * kh * kw * oc_group_size * (ic_group_size * sparse_ratio)
                        + (ic_iter / sparse_ratio) * kh * kw * oc_group_size * (ic_group_size * sparse_ratio)
                        + kh_iter * kw * oc_group_size * (ic_group_size * sparse_ratio)
                        + kw_iter * oc_group_size * (ic_group_size * sparse_ratio) + oc_group_iter * (ic_group_size * sparse_ratio)
                        + ic_group_iter + ic_group_size * (ic_iter % sparse_ratio);
              if (ifmap_mask[ori_idx] == 1) {
                weight_out[dst_idx] = weight[ori_idx];
              }
            }
          }
        }
      }
    }
  }

  return weight_out;
}

template<typename T>
Tensor<T> TransformIfmap(const Tensor<T>& ifmap, int sparse_ratio)
{
  int ic_group      = 0;
  int h             = 0;
  int w             = 0;
  int ic_group_size = 0;
  if (ifmap.shape_.size() == 4) {
    ic_group      = ifmap.shape(0);
    h             = ifmap.shape(1);
    w             = ifmap.shape(2);
    ic_group_size = ifmap.shape(3);
  }
  else {
    ic_group      = ifmap.shape(0);
    h             = 1;
    w             = ifmap.shape(1);
    ic_group_size = ifmap.shape(2);
  }

  Tensor<T> ifmap_out;
  if (ifmap.shape_.size() == 4) {
    ifmap_out = zeros<T>({ic_group / sparse_ratio, h, w, ic_group_size * sparse_ratio}, kHalf);
  }
  else {
    ifmap_out = zeros<T>({ic_group / sparse_ratio, w, ic_group_size * sparse_ratio}, kHalf);
  }

  int ori_idx = 0, dst_idx = 0;

  for (int ic_iter = 0; ic_iter < ic_group; ++ic_iter) {
    for (int h_iter = 0; h_iter < h; ++h_iter) {
      for (int w_iter = 0; w_iter < w; ++w_iter) {
        for (int ic_group_iter = 0; ic_group_iter < ic_group_size; ++ic_group_iter) {
          ori_idx = ic_iter * h * w * ic_group_size + h_iter * w * ic_group_size + w_iter * ic_group_size + ic_group_iter;
          dst_idx = (ic_iter / sparse_ratio) * h * w * (ic_group_size * sparse_ratio) + h_iter * w * (ic_group_size * sparse_ratio)
                    + w_iter * (ic_group_size * sparse_ratio) + ic_group_iter + ic_group_size * (ic_iter % sparse_ratio);
          ifmap_out[dst_idx] = ifmap[ori_idx];
        }
      }
    }
  }

  return ifmap_out;
}

Tensor<int8_t>
GenIfmapMask(int oc_group, int ic_group, int kh, int kw, int oc_group_size, int ic_group_size, int sparse_enable, uint64_t seed)
{
  if (sparse_enable == 0) {
    return ones<int8_t>({oc_group, ic_group, kh, kw, oc_group_size, ic_group_size}, kInt8);
  }

  if (sparse_enable == 1) {
    int real_sparse_base;
    real_sparse_base = 4;

    std::uniform_int_distribution<int> dist(0, real_sparse_base - 1);
    std::default_random_engine         e(seed);

    Tensor<int8_t> mask = zeros<int8_t>({oc_group, ic_group, kh, kw, oc_group_size, ic_group_size}, kInt8);
    for (int oc_iter = 0; oc_iter < oc_group; ++oc_iter) {
      for (int ic_iter = 0; ic_iter < ic_group; ++ic_iter) {
        for (int kh_iter = 0; kh_iter < kh; ++kh_iter) {
          for (int kw_iter = 0; kw_iter < kw; ++kw_iter) {
            for (int oc_group_iter = 0; oc_group_iter < oc_group_size; ++oc_group_iter) {
              for (int ic_group_iter = 0; ic_group_iter < ic_group_size / real_sparse_base; ++ic_group_iter) {
                int old_idx[32] = {0};
                int idx = oc_iter * ic_group * kh * kw * oc_group_size * ic_group_size + ic_iter * kh * kw * oc_group_size * ic_group_size
                          + kh_iter * kw * oc_group_size * ic_group_size + kw_iter * oc_group_size * ic_group_size
                          + oc_group_iter * ic_group_size + ic_group_iter * real_sparse_base;

                for (int i = 0; i < real_sparse_base / 2; ++i) {
                  int  new_idx = -1;
                  bool match   = false;
                  do {
                    match   = false;
                    new_idx = dist(e);
                    for (int j = 0; j < real_sparse_base / 2; ++j) {
                      if (new_idx == old_idx[j]) {
                        match = true;
                        break;
                      }
                    }
                  } while (match);
                  mask[idx + new_idx] = 1;
                  old_idx[i]          = new_idx;
                }
              }
            }
          }
        }
      }
    }
    return mask;
  }

  return ones<int8_t>({oc_group, ic_group, kh, kw, oc_group_size, ic_group_size}, kInt8);
}

Tensor<int8_t> GenIfmapMask(int oc_group, int ic_group, int oc_group_size, int ic_group_size, int sparse_enable, uint64_t seed)
{
  if (sparse_enable == 0) {
    return ones<int8_t>({oc_group, ic_group, oc_group_size, ic_group_size}, kInt8);
  }

  if (sparse_enable == 1) {
    int real_sparse_base = 4;

    std::uniform_int_distribution<int> dist(0, real_sparse_base - 1);
    std::default_random_engine         e(seed);

    Tensor<int8_t> mask = zeros<int8_t>({oc_group, ic_group, oc_group_size, ic_group_size}, kInt8);
    for (int oc_iter = 0; oc_iter < oc_group; ++oc_iter) {
      for (int ic_iter = 0; ic_iter < ic_group; ++ic_iter) {
        for (int oc_group_iter = 0; oc_group_iter < oc_group_size; ++oc_group_iter) {
          for (int ic_group_iter = 0; ic_group_iter < ic_group_size / real_sparse_base; ++ic_group_iter) {
            int old_idx[32] = {0};
            int idx         = oc_iter * ic_group * oc_group_size * ic_group_size + ic_iter * oc_group_size * ic_group_size

                      + oc_group_iter * ic_group_size + ic_group_iter * real_sparse_base;

            for (int i = 0; i < real_sparse_base / 2; ++i) {
              int  new_idx = -1;
              bool match   = false;
              do {
                match   = false;
                new_idx = dist(e);
                for (int j = 0; j < real_sparse_base / 2; ++j) {
                  if (new_idx == old_idx[j]) {
                    match = true;
                    break;
                  }
                }
              } while (match);
              mask[idx + new_idx] = 1;
              old_idx[i]          = new_idx;
            }
          }
        }
      }
    }
    return mask;
  }
  return ones<int8_t>({oc_group, ic_group, oc_group_size, ic_group_size}, kInt8);
}

Tensor<int8_t> IfmapMaskProcess(const Tensor<int8_t>& ifmap_mask, int sparse_ratio)
{
  int            oc_group      = 0;
  int            ic_group      = 0;
  int            kh            = 0;
  int            kw            = 0;
  int            oc_group_size = 0;
  int            ic_group_size = 0;
  Tensor<int8_t> ifmap_mask_compress;
  if (ifmap_mask.shape_.size() == 6) {
    oc_group            = ifmap_mask.shape(0);
    ic_group            = ifmap_mask.shape(1);
    kh                  = ifmap_mask.shape(2);
    kw                  = ifmap_mask.shape(3);
    oc_group_size       = ifmap_mask.shape(4);
    ic_group_size       = ifmap_mask.shape(5);
    ifmap_mask_compress = zeros<int8_t>({oc_group, ic_group / sparse_ratio, kh, kw, oc_group_size, ic_group_size * sparse_ratio}, kInt8);
  }
  else {
    oc_group            = ifmap_mask.shape(0);
    ic_group            = ifmap_mask.shape(1);
    kh                  = 1;
    kw                  = 1;
    oc_group_size       = ifmap_mask.shape(2);
    ic_group_size       = ifmap_mask.shape(3);
    ifmap_mask_compress = zeros<int8_t>({oc_group, ic_group / sparse_ratio, oc_group_size, ic_group_size * sparse_ratio}, kInt8);
  }

  int ori_idx = 0, dst_idx = 0;
  for (int oc_iter = 0; oc_iter < oc_group; ++oc_iter) {
    for (int ic_iter = 0; ic_iter < ic_group; ++ic_iter) {
      for (int kh_iter = 0; kh_iter < kh; ++kh_iter) {
        for (int kw_iter = 0; kw_iter < kw; ++kw_iter) {
          for (int oc_group_iter = 0; oc_group_iter < oc_group_size; ++oc_group_iter) {
            for (int ic_group_iter = 0; ic_group_iter < ic_group_size; ++ic_group_iter) {
              ori_idx = oc_iter * ic_group * kh * kw * oc_group_size * ic_group_size + ic_iter * kh * kw * oc_group_size * ic_group_size
                        + kh_iter * kw * oc_group_size * ic_group_size + kw_iter * oc_group_size * ic_group_size
                        + oc_group_iter * ic_group_size + ic_group_iter;
              dst_idx = oc_iter * (ic_group / sparse_ratio) * kh * kw * oc_group_size * ic_group_size * sparse_ratio
                        + (ic_iter / sparse_ratio) * kh * kw * oc_group_size * ic_group_size * sparse_ratio
                        + kh_iter * kw * oc_group_size * ic_group_size * sparse_ratio
                        + kw_iter * oc_group_size * ic_group_size * sparse_ratio + oc_group_iter * ic_group_size * sparse_ratio
                        + ic_group_iter + ic_group_size * (ic_iter % sparse_ratio);
              ifmap_mask_compress[dst_idx] = ifmap_mask[ori_idx];
            }
          }
        }
      }
    }
  }
  return ifmap_mask_compress;
}

}  // namespace sparse
}  // namespace compute_model