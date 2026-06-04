#pragma once
#include "compute_model/common/tensor.h"
#include "compute_model/transformer/llama_attention.h" 
#include "compute_model/transformer/llama_mlp.h"
#include "compute_model/transformer/rmsnorm.h"
#include <iostream> 
#include <vector>   

int saveCharArrayToFormattedTextFile(
  const char* filename, const char* data, size_t dataSize, size_t bytesPerLine, bool rightLow, bool int4 = false)
{
  std::ofstream file;
  file.open(filename);

  if (rightLow) {
    std::stringstream ss;
    std::string       result, tmp;

    for (int i = 0; i < dataSize; ++i) {
      if (i % bytesPerLine == 0) {
        result.clear();
      }
      ss.clear();
      if (int4) {
        ss << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data[i] & 0xf);
      }
      else {
        ss << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)data[i] & 0xff);
      }
      ss >> tmp;
      result = tmp + result;
      if (i % bytesPerLine == bytesPerLine - 1) {
        file << result << std::endl;
      }
    }
    file.close();
  }
  else {
    for (int i = 0; i < dataSize; ++i) {
      if (int4) {
        file << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data[i] & 0xf) << std::endl;
      }
      else {
        file << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data[i] & 0xff) << std::endl;
      }
    }
  }
  return 0;
}

namespace compute_model {
namespace transformer {
namespace llama_block {

using namespace compute_model::tensor;
using namespace compute_model::common::fp16;


template<typename TYPE_A, typename TYPE_B, bool DEBUG = false>
void apply_llama_block(
    Tensor<TYPE_A>& input_hidden_state, // fp32, group_size = 32
    Tensor<TYPE_A>& output_hidden_state, // fp32, group_size = 32
    // RMSNorm para
    Tensor<TYPE_A>& attn_norm_para, // fp32, group_size = 32
    Tensor<TYPE_A>& ffn_norm_para, // fp32, group_size = 32
    // Attention weights
    Tensor<TYPE_B>& query_weight, // fp16, n_group_size = 32, k_group_size = 16
    Tensor<TYPE_B>& key_weight, // fp16
    Tensor<TYPE_B>& value_weight, // fp16
    Tensor<TYPE_B>& output_proj_weight, // fp16
    // MLP weights
    Tensor<TYPE_B>& gate_weight, // fp16
    Tensor<TYPE_B>& up_weight, // fp16
    Tensor<TYPE_B>& down_weight, // fp16
    // Parameters
    int num_attention_heads,
    float rmsnorm_epsilon = 1e-6f)
{
    const auto& shape = input_hidden_state.shape();
    auto dtype_a = input_hidden_state.dtype;

    // Intermediate tensors
    Tensor<TYPE_A> attn_norm_output_tensor(shape, dtype_a);
    Tensor<TYPE_A> attention_output_tensor(shape, dtype_a);
    // residual_after_attn will be created by the + operator
    Tensor<TYPE_A> ffn_norm_output_tensor(shape, dtype_a);
    Tensor<TYPE_A> ffn_output_tensor(shape, dtype_a);

    if (DEBUG) {
        std::cout << "======== Applying Llama Block ========" << std::endl;
        std::cout << "Input shape: ";
        for(int s_dim : shape) std::cout << s_dim << " ";
        std::cout << std::endl;
    }

    /** 1. Pre-Attention RMSNorm */ 
    if (DEBUG) {
        std::cout << "Llama Block: Applying pre-attention RMSNorm..." << std::endl;
    }
    compute_model::transformer::rmsnorm::apply_rmsnorm<TYPE_A, DEBUG>(
        input_hidden_state, attn_norm_output_tensor, attn_norm_para, rmsnorm_epsilon
    );
    saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_attn_norm_output_tensor.txt", reinterpret_cast<char*>(attn_norm_output_tensor.data_ptr()), attn_norm_output_tensor.numel() * sizeof(float), 32, true);
    
    /** (fp32, group_size = 32 -> fp16, group_size = 16) */
    auto attn_norm_output_tensor_hf = ToFloat16(attn_norm_output_tensor);
    auto attn_norm_output_tensor_hf_convert = ParallelismConvertion32to16(attn_norm_output_tensor_hf);
    saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_attn_norm_output_tensor_hf_convert.txt", reinterpret_cast<char*>(attn_norm_output_tensor_hf_convert.data_ptr()), attn_norm_output_tensor_hf_convert.numel() * sizeof(half), 32, true);

    /** 2. Self-Attention */ 
    if (DEBUG) {
        std::cout << "Llama Block: Applying self-attention..." << std::endl;
    }
    compute_model::transformer::mha::ApplyLlamaAttention<half, half, float, DEBUG>(
        attn_norm_output_tensor_hf_convert, attention_output_tensor,
        query_weight, key_weight, value_weight, output_proj_weight,
        num_attention_heads
    );
    saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_attention_output_tensor.txt", reinterpret_cast<char*>(attention_output_tensor.data_ptr()), attention_output_tensor.numel() * sizeof(float), 32, true);

    /** 3. First Residual Connection: residual_after_attn = input_hidden_state + attention_output_tensor */
    if (DEBUG) {
        std::cout << "Llama Block: Applying first residual connection..." << std::endl;
    }
    // Tensor operator+ return a new Tensor
    Tensor<TYPE_A> residual_after_attn = input_hidden_state + attention_output_tensor;
    saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_residual_after_attn.txt", reinterpret_cast<char*>(residual_after_attn.data_ptr()), residual_after_attn.numel() * sizeof(float), 32, true);

    /** 4. Pre-FFN RMSNorm */
    if (DEBUG) {
        std::cout << "Llama Block: Applying pre-FFN RMSNorm..." << std::endl;
    }
    compute_model::transformer::rmsnorm::apply_rmsnorm<TYPE_A, DEBUG>(
        residual_after_attn, ffn_norm_output_tensor, ffn_norm_para, rmsnorm_epsilon
    );
    saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_ffn_norm_output_tensor.txt", reinterpret_cast<char*>(ffn_norm_output_tensor.data_ptr()), ffn_norm_output_tensor.numel() * sizeof(float), 32, true);

    /** (fp32, group_size = 32 -> fp16, group_size = 16) */
    auto ffn_norm_output_tensor_hf = ToFloat16(ffn_norm_output_tensor);
    auto ffn_norm_output_tensor_hf_convert = ParallelismConvertion32to16(ffn_norm_output_tensor_hf);
    saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_ffn_norm_output_tensor_hf_convert.txt", reinterpret_cast<char*>(ffn_norm_output_tensor_hf_convert.data_ptr()), ffn_norm_output_tensor_hf_convert.numel() * sizeof(half), 32, true);

    /** 5. MLP (Feed-Forward Network) */
    if (DEBUG) {
        std::cout << "Llama Block: Applying MLP..." << std::endl;
    }
    compute_model::transformer::llama_mlp::apply_llama_mlp<half, half, float, DEBUG>(
        ffn_norm_output_tensor_hf_convert, ffn_output_tensor,
        gate_weight, up_weight, down_weight
    );
    saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_ffn_output_tensor.txt", reinterpret_cast<char*>(ffn_output_tensor.data_ptr()), ffn_output_tensor.numel() * sizeof(float), 32, true);

    /** 6. Second Residual Connection: output_hidden_state = residual_after_attn + ffn_output_tensor */
    if (DEBUG) {
        std::cout << "Llama Block: Applying second residual connection..." << std::endl;
    }
    // Assigns the result to the output_hidden_state parameter
    output_hidden_state = residual_after_attn + ffn_output_tensor;

    if (DEBUG) {
        std::cout << "======== Llama Block Applied ========" << std::endl;
    }
}

// Convenience wrapper that returns the tensor
template<typename TYPE_A, typename TYPE_B, bool DEBUG = false>
Tensor<TYPE_A> llama_block(
    Tensor<TYPE_A>& input_hidden_state,
    // RMSNorm weights
    Tensor<TYPE_B>& attn_norm_para,
    Tensor<TYPE_B>& ffn_norm_para,
    // Attention weights
    Tensor<TYPE_B>& query_weight,
    Tensor<TYPE_B>& key_weight,
    Tensor<TYPE_B>& value_weight,
    Tensor<TYPE_B>& output_proj_weight,
    // MLP weights
    Tensor<TYPE_B>& gate_weight,
    Tensor<TYPE_B>& up_weight,
    Tensor<TYPE_B>& down_weight,
    // Parameters
    int num_attention_heads,
    float rmsnorm_epsilon = 1e-6f)
{
    Tensor<TYPE_A> result_tensor(input_hidden_state.shape(), input_hidden_state.dtype());
    apply_llama_block<TYPE_A, TYPE_B, DEBUG>(
        input_hidden_state, result_tensor,
        attn_norm_para, ffn_norm_para,
        query_weight, key_weight, value_weight, output_proj_weight,
        gate_weight, up_weight, down_weight,
        num_attention_heads, rmsnorm_epsilon
    );
    return result_tensor;
}

} // namespace llama_block
} // namespace transformer
} // namespace compute_model
