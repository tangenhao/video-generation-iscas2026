#pragma once

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
    T sum = 0;
    T layer0[16];
    if (debug) {
      std::cout << "row index: " << i << std::endl;
      std::cout << "layer0: " << std::endl;
    }
    for (int j = 0; j < 32 / 2; j++) {
      int idx_a = i * shape.back() + j * 2;
      int idx_b = i * shape.back() + j * 2 + 1;
      T   a;
      if (j * 2 <= valid_items) {
        a = input[idx_a];
      }
      else {
        a = 0;
      }
      T b;
      if (j * 2 + 1 <= valid_items) {
        b = input[idx_b];
      }
      else {
        b = 0;
      }
      layer0[j] = a + b;
      if (debug) {
        std::cout << std::hex << "a: " << *(uint32_t*)(&a) << " b: " << *(uint32_t*)(&b) << " sum: " << *(uint32_t*)(&layer0[j])
                  << std::endl;
      }
    }
    if (debug) {
      std::cout << "layer1: " << std::endl;
    }
    T layer1[8];
    for (int j = 0; j < 16 / 2; j++) {
      T a;
      if (j * 2 <= valid_items / 2) {
        a = layer0[j * 2];
      }
      else {
        a = 0;
      }
      T b;
      if (j * 2 + 1 <= valid_items / 2) {
        b = layer0[j * 2 + 1];
      }
      else {
        b = 0;
      }
      layer1[j] = a + b;
      if (debug) {
        std::cout << std::hex << "a: " << *(uint32_t*)(&a) << " b: " << *(uint32_t*)(&b) << " sum: " << *(uint32_t*)(&layer1[j])
                  << std::endl;
      }
    }

    if (debug) {
      std::cout << "layer2: " << std::endl;
    }
    T layer2[4];
    for (int j = 0; j < 8 / 2; j++) {
      T a;
      if (j * 2 <= valid_items / 4) {
        a = layer1[j * 2];
      }
      else {
        a = 0;
      }
      T b;
      if (j * 2 + 1 <= valid_items / 4) {
        b = layer1[j * 2 + 1];
      }
      else {
        b = 0;
      }
      layer2[j] = a + b;
      if (debug) {
        std::cout << std::hex << "a: " << *(uint32_t*)(&a) << " b: " << *(uint32_t*)(&b) << " sum: " << *(uint32_t*)(&layer2[j])
                  << std::endl;
      }
    }

    if (debug) {
      std::cout << "layer3: " << std::endl;
    }
    T layer3[2];
    for (int j = 0; j < 4 / 2; j++) {
      T a;
      if (j * 2 <= valid_items / 8) {
        a = layer2[j * 2];
      }
      else {
        a = 0;
      }
      T b;
      if (j * 2 + 1 <= valid_items / 8) {
        b = layer2[j * 2 + 1];
      }
      else {
        b = 0;
      }
      layer3[j] = a + b;

      if (debug) {
        std::cout << std::hex << "a: " << *(uint32_t*)(&a) << " b: " << *(uint32_t*)(&b) << " sum: " << *(uint32_t*)(&layer3[j])
                  << std::endl;
      }
    }

    if (debug) {
      std::cout << "layer4: " << std::endl;
    }
    T layer4[1];
    for (int j = 0; j < 2 / 2; j++) {
      T a;
      if (j * 2 <= valid_items / 16) {
        a = layer3[j * 2];
      }
      else {
        a = 0;
      }
      T b;
      if (j * 2 + 1 <= valid_items / 16) {
        b = layer3[j * 2 + 1];
      }
      else {
        b = 0;
      }
      layer4[j] = a + b;
      if (debug) {
        std::cout << std::hex << "a: " << *(uint32_t*)(&a) << " b: " << *(uint32_t*)(&b) << " sum: " << *(uint32_t*)(&layer4[j])
                  << std::endl;
      }
    }

    for (int j = 0; j < shape.back(); j++) {
      output[i * shape.back() + j] = layer4[0];
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