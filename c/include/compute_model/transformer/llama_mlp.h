#pragma once

#include "compute_model/common/tensor.h"
#include "compute_model/common/fp16.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/gemm/gemm.h"

namespace compute_model {
namespace transformer {
namespace llama_mlp {

using namespace compute_model::tensor;
using namespace compute_model::function;
using namespace compute_model::common::fp16;
using namespace compute_model::gemm;

template<typename TYPE_A, typename TYPE_B, typename TYPE_C, bool DEBUG = false>
void apply_llama_mlp(
    Tensor<TYPE_A>& input,                  // 输入张量 [k_group, seq_len, k_group_size]
    Tensor<TYPE_C>& output,                 // 输出张量 [n_group * n_group_scale, seq_len, n_group_size / n_group_scale]
    Tensor<TYPE_B>& gate_weight,            // gate投影权重 [n_group_ff, k_group, n_group_size, k_group_size]
    Tensor<TYPE_B>& up_weight,              // up投影权重 [n_group_ff, k_group, n_group_size, k_group_size]
    Tensor<TYPE_B>& down_weight)             // down投影权重 [n_group, k_group_ff, n_group_size, k_group_size]
{
  // 获取维度信息
  int seq_len = input.shape()[1];
  int k_group_size = input.shape()[2];
  int k_group = input.shape()[0];
  
  int n_group_size = gate_weight.shape()[2];
  int n_group_ff = gate_weight.shape()[0];
  int n_group = down_weight.shape()[0];
  
  int d_model = k_group * k_group_size;
  int d_ff = n_group_ff * n_group_size;
  
  //分块参数
  int tile_m = std::min(seq_len, 32);
  int block_n_group = std::min(n_group, 16);
  int block_k_group = std::min(k_group, 16);

  if (DEBUG) {
    std::cout << "======== LlamaMLP Parameters ========" << std::endl;
    std::cout << "seq_len: " << seq_len << std::endl;
    std::cout << "d_model: " << d_model << std::endl;
    std::cout << "d_ff: " << d_ff << std::endl;
    std::cout << "k_group_size: " << k_group_size << std::endl;
    std::cout << "k_group: " << k_group << std::endl;
    std::cout << "n_group_size: " << n_group_size << std::endl;
    std::cout << "n_group_ff: " << n_group_ff << std::endl;
    std::cout << "n_group: " << n_group << std::endl;
  }
  
  // 初始化中间张量
  auto gate_output = zeros<float>({n_group_ff, seq_len, n_group_size}, kFloat32);
  auto up_output = zeros<float>({n_group_ff, seq_len, n_group_size}, kFloat32);
  auto swish_output = zeros<float>({n_group_ff, seq_len, n_group_size}, kFloat32);
  auto mul_output = zeros<float>({n_group_ff, seq_len, n_group_size}, kFloat32);

  // 1. up投影: up_output = up_proj(x)
  if (DEBUG) {
    std::cout << "Computing up projection..." << std::endl;
  }
  using gemm_up_t = GemmSim<0, 0, false, false, TYPE_A, TYPE_B, float, float, DEBUG>;
  typename gemm_up_t::Arguments up_args = {up_output, input, up_weight, tile_m, block_n_group, block_k_group};
  gemm_up_t up_op;
  up_op(up_args);

  // 2. gate投影: gate_output = gate_proj(x)
  if (DEBUG) {
    std::cout << "Computing gate projection..." << std::endl;
  }
  using gemm_gate_t = GemmSim<0, 0, false, false, TYPE_A, TYPE_B, float, float, DEBUG>;
  typename gemm_gate_t::Arguments gate_args = {gate_output, input, gate_weight, tile_m, block_n_group, block_k_group};
  gemm_gate_t gate_op;
  gate_op(gate_args);

  // 3. fast_swish激活: swish_output = swish(gate_output)
  if (DEBUG) {
    std::cout << "Applying swish activation..." << std::endl;
  }
  swish_output = fast_swish(gate_output);

  // 4. 逐元素乘法: mul_output = swish_output * up_output
  if (DEBUG) {
    std::cout << "Computing element-wise multiplication..." << std::endl;
  }
  for (int oc_iter = 0; oc_iter < n_group_ff; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < n_group_size; oc_inner_iter++) {
        int idx = oc_iter * seq_len * n_group_size + seq_len_iter * n_group_size + oc_inner_iter;
        mul_output[idx] = swish_output[idx] * up_output[idx];
      }
    }
  }
  
  // 5. 将mul_output转换为half类型，处理类型转换
  auto mul_output_half = ToFloat16(mul_output);
  
  // 6. 并行度转换，适应下一步计算要求
  mul_output_half = ParallelismConvertion32to16(mul_output_half);
  
  // 7. down投影: output = down_proj(mul_output_half)
  if (DEBUG) {
    std::cout << "Computing down projection..." << std::endl;
  }
  auto output_temp = zeros<float>({n_group, seq_len, n_group_size}, kFloat32);
  using gemm_down_t = GemmSim<0, 0, false, false, half, TYPE_B, float, float, DEBUG>;
  typename gemm_down_t::Arguments down_args = {output_temp, mul_output_half, down_weight, tile_m, block_n_group, block_k_group};
  gemm_down_t down_op;
  down_op(down_args);

  output = output_temp;
  // 8. fp32 -> fp16, covert parallelism
  // auto output_temp_half = ToFloat16(output_temp);
  // // [n_group, seq_len, n_group_size] -> [n_group * n_group_scale, seq_len, n_group_size / n_group_scale]
  // output = ParallelismConvertion32to16(output_temp_half);
}

// 便捷版本，直接返回结果而不是通过引用输出
template<typename TYPE_A, typename TYPE_B, typename TYPE_C>
Tensor<TYPE_C> llama_mlp(
    Tensor<TYPE_A>& input,
    Tensor<TYPE_B>& gate_weight,
    Tensor<TYPE_B>& up_weight,
    Tensor<TYPE_B>& down_weight)
{
  // 确定输出形状和类型
  int seq_len = input.shape()[1];
  int n_group = down_weight.shape()[0];
  int n_group_size = down_weight.shape()[2];
  int n_group_scale = 2;
  
  // 创建输出张量
  // Tensor<TYPE_C> output({n_group * n_group_scale, seq_len, n_group_size / n_group_scale}, kFloat32);
  Tensor<TYPE_C> output({n_group, seq_len, n_group_size}, kFloat32);
  
  // 应用LlamaMLP
  apply_llama_mlp<TYPE_A, TYPE_B, TYPE_C>(
      input, output, gate_weight, up_weight, down_weight);
  
  return output;
}

}  // namespace llama_mlp
}  // namespace transformer
}  // namespace compute_model
