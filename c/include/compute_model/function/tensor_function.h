#pragma once
#include "compute_model/function/func_from_lib.h"

#define _USE_MATH_DEFINES
#include <cmath>

namespace compute_model {
namespace function {

using namespace tensor;

template<typename T>
Tensor<T> sin(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = sin16divpi_c(input[i]);
  }
  return output;
}

template<typename T>
Tensor<T> cos(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = cos16divpi_c(input[i]);
  }
  return output;
}

template<typename T>
Tensor<T> log2(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = log2_c(input[i]);
  }
  return output;
}

template<typename T>
Tensor<T> shuffle(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> result(input.shape(), kFloat32);
  int       index = 0;
  for (int oc_group = 0; oc_group < input.shape_[0]; oc_group++) {
    for (int wh = 0; wh < input.shape_[1]; wh++) {
      for (int num = 0; num < input.shape_[2]; num++) {
        index = oc_group * (input.shape_[1]) * (input.shape_[2]) + wh * (input.shape_[2]) + num;
        if (num == input.shape_[2] - 1) {
          result[index] = input[index - input.shape_[2] + 1];
        }
        else {
          result[index] = input[index + 1];
        }
      }
    }
  }
  return result;
}

template<typename T>
Tensor<T> relu(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    if (input[i] > 0) {
      output[i] = input[i];
    }
    else {
      output[i] = 0;
    }
  }
  return output;
}

template<typename T>
Tensor<T> leaky_relu(Tensor<T>& input, float a)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    if (input[i] > 0) {
      output[i] = input[i];
    }
    else {
      output[i] = input[i] * a;
    }
  }
  return output;
}

template<typename T>
Tensor<T> reciprocal(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = reciprocal_c(input[i]);
  }
  return output;
}

template<typename T>
Tensor<T> rsqrt(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = rsqrt_c(input[i]);
  }
  return output;
}

template<typename T>
Tensor<T> abs(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = std::abs(input[i]);
  }

  return output;
}

template<typename T>
Tensor<T> inv(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = -input[i];
  }
  return output;
}

template<typename T>
Tensor<T> sqrt(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = std::sqrt(input[i]);
  }
  return output;
}

template<typename T>
Tensor<T> exp2(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = exp2_c(input[i], i == 0);
  }
  return output;
}

template<typename T>
Tensor<T> tanh(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    output[i] = tanh_c(input[i]);
  }
  return output;
}

template<typename T>
Tensor<T> fma(Tensor<T>& a, Tensor<T>& b, Tensor<T>& c)
{
  assert(a.dtype == kFloat32);
  assert(b.dtype == kFloat32);
  assert(c.dtype == kFloat32);
  assert(a.shape() == b.shape());
  assert(a.shape() == c.shape());

  Tensor<T> output(a.shape(), kFloat32);

  for (int i = 0; i < a.numel(); i++) {
    output[i] = std::fmaf(a[i], b[i], c[i]);
  }
  return output;
}

template<typename T>
Tensor<T> sigmoid(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  auto data_out = input * (-std::log2(exp(1.0f)));
  data_out      = exp2(data_out);
  data_out      = data_out + 1.0f;
  data_out      = reciprocal(data_out);
  return data_out;
}

template<typename T>
Tensor<T> swish(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  auto data_out = input * (-std::log2(exp(1.0f)));
  data_out      = exp2(data_out);
  data_out      = data_out + 1.0f;
  data_out      = reciprocal(data_out);
  data_out      = data_out * input;
  return data_out;
}

template<typename T>
Tensor<T> softplus(Tensor<T>& input, float beta = 1.0, float threshold = 20.0)
{
  assert(input.dtype == kFloat32);
  auto data_adj = input * beta;
  data_adj      = data_adj * (std::log2(exp(1.0f)));
  auto data_out = exp2(data_adj);
  data_out      = data_out + 1.0f;
  data_out      = log2(data_out);
  data_out      = data_out * (1 / std::log2(exp(1.0f)));
  data_out      = data_out * (1.0f / beta);
  for (int i = 0; i < data_out.numel(); i++) {
    if (data_adj[i] > threshold) {
      data_out[i] = input[i];
    }
  }
  return data_out;
}

template<typename T>
Tensor<T> selu(Tensor<T>& input, float alpha = 1.67326319217681884765625f, float lambda = 1.05070102214813232421875f)
{
  assert(input.dtype == kFloat32);
  auto data_out = input * std::log2(exp(1.0f));
  data_out      = exp2(data_out);
  data_out      = data_out - 1.0f;
  data_out      = data_out * alpha;

  for (int i = 0; i < data_out.numel(); i++) {
    if (input[i] > 0) {
      data_out[i] = input[i] * lambda;
    }
    else {
      data_out[i] = data_out[i] * lambda;
    }
  }
  return data_out;
}

template<typename T>
Tensor<T> mish(Tensor<T>& input, float beta = 1.0f, float threshold = 20.0f)
{
  assert(input.dtype == kFloat32);
  auto data_out = softplus(input, beta, threshold);
  data_out      = tanh(data_out);
  data_out      = input * data_out;
  return data_out;
}

template<typename T>
Tensor<T> gelu(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  auto x2    = input * input;
  auto x3    = x2 * input;
  auto fma_o = x3;
  for (int i = 0; i < x3.numel(); i++) {
    fma_o[i] = std::fmaf(x3[i], 0.044715f, input[i]);
  }
  auto mul_o    = fma_o * std::sqrt(2.0f / M_PI);
  auto tanh_o   = tanh(mul_o);
  auto data_out = input * 0.5f * (tanh_o + 1.0f);
  return data_out;
}

template<typename T>
Tensor<T> fast_tanh(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    uint32_t output_int = tanh_less_precision_approx_c(input[i], i == 64);
    output[i]           = *(float*)(&output_int);
  }
  return output;
}

template<typename T>
Tensor<T> fast_sigmoid(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    uint32_t output_int = sigmoid_less_precision_approx_c(input[i], i == 0);
    output[i]           = *(float*)(&output_int);
  }
  return output;
}

template<typename T>
Tensor<T> fast_swish(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    uint32_t output_int = swish_less_precision_approx_c(input[i]);
    output[i]           = *(float*)(&output_int);
  }
  return output;
}

template<typename T>
Tensor<T> fast_mish(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    uint32_t output_int = mish_less_precision_approx_c(input[i]);
    output[i]           = *(float*)(&output_int);
  }
  return output;
}

template<typename T>
Tensor<T> fast_gelu(Tensor<T>& input)
{
  assert(input.dtype == kFloat32);
  Tensor<T> output(input.shape(), kFloat32);

  for (int i = 0; i < input.numel(); i++) {
    uint32_t output_int = gelu_less_precision_approx_c(input[i]);
    output[i]           = *(float*)(&output_int);
  }
  return output;
}

template<typename T>
Tensor<T> add_elementwise(Tensor<T>& a, Tensor<T>& b)
{
  assert(a.shape() == b.shape());

  Tensor<T> output(a.shape(), a.dtype);

  for (int i = 0; i < a.numel(); i++) {
    output[i] = a[i] + b[i];
  }
  return output;
}

template<typename T>
Tensor<T> mul_elementwise(Tensor<T>& a, Tensor<T>& b)
{
  assert(a.shape() == b.shape());

  Tensor<T> output(a.shape(), a.dtype);

  for (int i = 0; i < a.numel(); i++) {
    output[i] = a[i] * b[i];
  }
  return output;
}

}  // namespace function
}  // namespace compute_model