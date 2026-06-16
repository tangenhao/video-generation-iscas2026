#pragma once

#include <algorithm>
#include <cstdint>
#include <vector>

#include "compute_model/common/tensor.h"

namespace compute_model {
namespace function {

using namespace tensor;

template<typename T>
Tensor<T> reduce_sum(Tensor<T>& input, int valid_items, bool debug = false)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  int  rows  = 1;
  auto shape = input.shape();

  for (int i = 0; i < shape.size() - 1; i++) {
    rows *= shape[i];
  }

  for (int i = 0; i < rows; i++) {
    std::vector<T> layer(shape.back(), T(0));
    int active_items = std::max(1, std::min(valid_items + 1, shape.back()));

    if (debug) {
      std::cout << "row index: " << i << std::endl;
    }

    for (int j = 0; j < active_items; j++) {
      layer[j] = input[i * shape.back() + j];
    }

    int layer_idx = 0;
    while (layer.size() > 1) {
      if (debug) {
        std::cout << "layer" << layer_idx << ": " << std::endl;
      }

      std::vector<T> next_layer;
      next_layer.reserve((layer.size() + 1) / 2);
      for (int j = 0; j + 1 < layer.size(); j += 2) {
        T a = layer[j];
        T b = layer[j + 1];
        T sum = a + b;
        next_layer.push_back(sum);
        if (debug) {
          std::cout << std::hex << "a: " << *(uint32_t*)(&a) << " b: " << *(uint32_t*)(&b) << " sum: " << *(uint32_t*)(&sum)
                    << std::endl;
        }
      }
      if (layer.size() % 2) {
        next_layer.push_back(layer.back());
      }
      layer.swap(next_layer);
      layer_idx++;
    }

    for (int j = 0; j < shape.back(); j++) {
      output[i * shape.back() + j] = layer[0];
    }
  }

  return output;
}

template<typename T>
Tensor<T> reduce_min(Tensor<T>& input, int valid_items)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  int  rows  = 1;
  auto shape = input.shape();

  for (int i = 0; i < shape.size() - 1; i++) {
    rows *= shape[i];
  }

  for (int i = 0; i < rows; i++) {
    T min = input[i * shape.back()];
    for (int j = 1; j <= valid_items; j++) {
      if (input[i * shape.back() + j] < min) {
        min = input[i * shape.back() + j];
      }
    }
    for (int j = 0; j < shape.back(); j++) {
      output[i * shape.back() + j] = min;
    }
  }

  return output;
}

template<typename T>
Tensor<T> reduce_max(Tensor<T>& input, int valid_items)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  int  rows  = 1;
  auto shape = input.shape();

  for (int i = 0; i < shape.size() - 1; i++) {
    rows *= shape[i];
  }

  for (int i = 0; i < rows; i++) {
    T max = input[i * shape.back()];
    for (int j = 1; j <= valid_items; j++) {
      if (input[i * shape.back() + j] > max) {
        max = input[i * shape.back() + j];
      }
    }
    for (int j = 0; j < shape.back(); j++) {
      output[i * shape.back() + j] = max;
    }
  }

  return output;
}

}  // namespace function
}  // namespace compute_model
