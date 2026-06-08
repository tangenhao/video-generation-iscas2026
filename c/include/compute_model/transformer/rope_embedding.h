#pragma once

#include "compute_model/common/tensor.h"
#include "compute_model/common/fp16.h"
#include "compute_model/function/tensor_function.h"

namespace compute_model {
namespace transformer {
namespace rope_embedding {

using namespace compute_model::tensor;
using namespace compute_model::function;
using namespace compute_model::common::fp16;

template<typename TYPE_A, typename TYPE_B, typename TYPE_C, bool DEBUG = false>
void apply_rope_embedding(
    Tensor<TYPE_A>& input,                  // 输入张量 [dim_groups, seq_len, n_group_size]
    Tensor<TYPE_B>& freq_cls,               // 频率张量 [dim_groups, seq_len, n_group_size] (包含cos和sin值)
    Tensor<TYPE_C>& output)                 // 输出张量 [dim_groups, seq_len, n_group_size]
{
  // 获取维度信息
  int dim_groups = input.shape()[0];
  int seq_len = input.shape()[1];
  int n_group_size = input.shape()[2];
  
  // 验证输入维度
  assert(input.shape() == freq_cls.shape());
  assert(input.shape() == output.shape());
  assert(n_group_size % 2 == 0);  // 必须是偶数，因为要分实部虚部
  
  if (DEBUG) {
    std::cout << "======== RoPE Parameters ========" << std::endl;
    std::cout << "dim_groups: " << dim_groups << std::endl;
    std::cout << "seq_len: " << seq_len << std::endl;
    std::cout << "n_group_size: " << n_group_size << std::endl;
    std::cout << "total_dim: " << dim_groups * n_group_size << std::endl;
  }
  
  // 分块参数，用于硬件实现
  const int BLOCK_SIZE = 32;
  int total_rows = seq_len;
  int total_cols = dim_groups * n_group_size;
  int row_blocks = total_rows / BLOCK_SIZE;
  int col_blocks = total_cols / BLOCK_SIZE;
  
  if (DEBUG) {
    std::cout << "Block configuration: " << row_blocks << "x" << col_blocks 
              << " blocks of " << BLOCK_SIZE << "x" << BLOCK_SIZE << std::endl;
  }
  
  // 1. 转置输入和频率张量以适应硬件处理
  auto input_transposed = input;
  auto freq_transposed = freq_cls;
  
  if (DEBUG) {
    std::cout << "Transposing input and freq_cls tensors..." << std::endl;
  }
  
  // 对输入进行转置
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx = temp_block_start + i * BLOCK_SIZE + j;
          int new_idx = temp_block_start + j * BLOCK_SIZE + i;
          input_transposed[new_idx] = input[ori_idx];
        }
      }
    }
  }
  
  // 对频率张量进行转置
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx = temp_block_start + i * BLOCK_SIZE + j;
          int new_idx = temp_block_start + j * BLOCK_SIZE + i;
          freq_transposed[new_idx] = freq_cls[ori_idx];
        }
      }
    }
  }
  
  // 2. 分离实部和虚部
  int separated_size = (dim_groups * seq_len * n_group_size) / 2;
  
  auto input_real = zeros<float>({separated_size}, kFloat32);
  auto input_imag = zeros<float>({separated_size}, kFloat32);
  auto freq_real = zeros<float>({separated_size}, kFloat32);  // cos values
  auto freq_imag = zeros<float>({separated_size}, kFloat32);  // sin values
  
  if (DEBUG) {
    std::cout << "Separating real and imaginary parts..." << std::endl;
    std::cout << "Each separated tensor size: " << separated_size << " elements" << std::endl;
  }
  
  // 分离过程：偶数索引为实部，奇数索引为虚部
  int real_index = 0;
  int imag_index = 0;
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx = temp_block_start + i * BLOCK_SIZE + j;
          
          if (i % 2 == 0) {
            // 实部
            input_real[real_index] = input_transposed[ori_idx];
            freq_real[real_index] = freq_transposed[ori_idx];
            real_index++;
          } else {
            // 虚部
            input_imag[imag_index] = input_transposed[ori_idx];
            freq_imag[imag_index] = freq_transposed[ori_idx];
            imag_index++;
          }
        }
      }
    }
  }
  
  // 3. RoPE核心计算
  // q_real' = q_real * cos θ - q_imag * sin θ
  // q_imag' = q_real * sin θ + q_imag * cos θ
  
  if (DEBUG) {
    std::cout << "Computing RoPE transformation..." << std::endl;
  }
  
  auto cos_values = freq_real;
  auto sin_values = freq_imag;
  
  auto output_real = zeros<float>({separated_size}, kFloat32);
  auto output_imag = zeros<float>({separated_size}, kFloat32);
  
  // 执行复数旋转
  output_real = mul_elementwise<float>(input_real, cos_values) - mul_elementwise<float>(input_imag, sin_values);
  output_imag = mul_elementwise<float>(input_real, sin_values) + mul_elementwise<float>(input_imag, cos_values);
  
  // 4. 数据重排：将实部和虚部重新组合
  auto final_output_concat = zeros<float>({dim_groups, seq_len, n_group_size}, kFloat32);
  
  if (DEBUG) {
    std::cout << "Reconstructing final output tensor..." << std::endl;
  }
  
  // 重新组合：将实部和虚部交错排列
  int final_real_index = 0;
  int final_imag_index = 0;
  
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx = temp_block_start + i * BLOCK_SIZE + j;
          
          if (i % 2 == 0) {
            // 偶数行写入实部数据
            if (final_real_index < separated_size) {
              final_output_concat[ori_idx] = output_real[final_real_index];
              final_real_index++;
            }
          } else {
            // 奇数行写入虚部数据
            if (final_imag_index < separated_size) {
              final_output_concat[ori_idx] = output_imag[final_imag_index];
              final_imag_index++;
            }
          }
        }
      }
    }
  }
  
  // 5. 最后转置回原始布局
  if (DEBUG) {
    std::cout << "Transposing back to original layout..." << std::endl;
  }
  
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int original_idx = temp_block_start + i * BLOCK_SIZE + j;
          int target_idx = temp_block_start + j * BLOCK_SIZE + i;
          output[target_idx] = final_output_concat[original_idx];
        }
      }
    }
  }
}

// 便捷版本，直接返回结果而不是通过引用输出
template<typename TYPE_C, typename TYPE_A=float, typename TYPE_B=float>
Tensor<TYPE_C> rope_embedding(
    Tensor<TYPE_A>& input,
    Tensor<TYPE_B>& freq_cls)
{
  // 创建输出张量
  Tensor<TYPE_C> output(input.shape(), kFloat32);
  
  // 应用RoPE
  apply_rope_embedding<TYPE_A, TYPE_B, TYPE_C>(input, freq_cls, output);
  
  return output;
}

// 生成频率张量的辅助函数
template<typename T>
Tensor<T> generate_freq_cls(int seq_len, int dim, float theta = 10000.0f)
{
  int n_group_size = 32;  
  int dim_groups = dim / n_group_size;  
  auto freq_cls = zeros<T>({dim_groups, seq_len, n_group_size}, kFloat32);
  
  int total_dim = dim_groups * n_group_size;
  
  for (int pos = 0; pos < seq_len; pos++) {
    for (int i = 0; i < total_dim / 2; i++) {
      float freq = 1.0f / std::pow(theta, 2.0f * i / total_dim);
      float angle = pos * freq;
      
      // 重新映射到张量结构
      int dim_group_idx = (2 * i) / n_group_size;
      int inner_idx = (2 * i) % n_group_size;
      
      if (dim_group_idx < dim_groups && inner_idx < n_group_size) {
        int real_idx = dim_group_idx * seq_len * n_group_size + pos * n_group_size + inner_idx;
        int imag_idx = dim_group_idx * seq_len * n_group_size + pos * n_group_size + (inner_idx + 1);
        
        if (inner_idx + 1 < n_group_size) {
          freq_cls[real_idx] = std::cos(angle);  // cos values for real part
          freq_cls[imag_idx] = std::sin(angle);  // sin values for imaginary part
        }
      }
    }
  }
  
  return freq_cls;
}

}  // namespace rope_embedding
}  // namespace transformer
}  // namespace compute_model