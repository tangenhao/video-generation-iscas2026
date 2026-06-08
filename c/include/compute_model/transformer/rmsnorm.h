#pragma once

#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/function/reduce.h"

namespace compute_model {
namespace transformer {
namespace rmsnorm {

using namespace compute_model::tensor;
using namespace compute_model::function;

template<typename T, bool DEBUG = false>
void apply_rmsnorm(
    Tensor<T>& input,
    Tensor<T>& output,
    Tensor<T>& gamma,
    float epsilon = 1e-6f)
{

  // 获取维度信息
  int seq_len = input.shape()[1];
  int d_model = input.shape()[0] * input.shape()[2];
  int oc_group_size = input.shape()[2];
  int oc_group = input.shape()[0];

  if (DEBUG) {
    std::cout << "======== RMSNorm Parameters ========" << std::endl;
    std::cout << "seq_len: " << seq_len << std::endl;
    std::cout << "d_model: " << d_model << std::endl;
    std::cout << "oc_group_size: " << oc_group_size << std::endl; 
    std::cout << "oc_group: " << oc_group << std::endl;
  }

  // 计算d_model的倒数
  Tensor<T> d_model_tensor({1, 1, 1}, kFloat32);
  d_model_tensor[0] = static_cast<T>(d_model);
  auto d_model_tensor_rec = reciprocal(d_model_tensor);
  T d_model_rec = d_model_tensor_rec[0];

  // 计算RMS
  auto data_rms = zeros<T>({seq_len, oc_group_size}, kFloat32);

  // 计算平方和
  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    Tensor<T> sub_tensor({seq_len, oc_group_size}, kFloat32);
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        T val = input[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter];
        sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter] = val * val;
      }
    }

    auto data_rms_temp = reduce_sum(sub_tensor, oc_group_size, false);
    data_rms = data_rms + data_rms_temp;
  }

  // 计算RMS
  data_rms = data_rms * d_model_rec;
  data_rms = data_rms + epsilon;
  data_rms = rsqrt(data_rms);

  // 应用RMS归一化
  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        output[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] =
          input[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] *
          data_rms[seq_len_iter * oc_group_size + oc_inner_iter];
      }
    }
  }

  // 应用gamma缩放
  for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
        output[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] *=
          gamma[oc_iter * oc_group_size + oc_inner_iter];
      }
    }
  }
  
}

// 便捷版本，直接返回结果而不是通过引用输出
template<typename T>
Tensor<T> rmsnorm(
    Tensor<T>& input,
    Tensor<T>& gamma,
    float epsilon = 1e-6f)
{
  Tensor<T> output(input.shape(), kFloat32);
  apply_rmsnorm(input, output, gamma, epsilon);
  return output;
}

}  // namespace rmsnorm
}  // namespace transformer
}  // namespace compute_model
