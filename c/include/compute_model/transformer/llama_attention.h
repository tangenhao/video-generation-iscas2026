#pragma once

#include "compute_model/common/tensor.h"
#include "compute_model/common/fp16.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/function/reduce.h"
#include "compute_model/gemm/gemm.h"
#include "common/file_utils.h"
#include "compute_model/transformer/rope_embedding.h"
#include <cmath>

namespace compute_model {
namespace transformer {
namespace mha {

using namespace compute_model::tensor;
using namespace compute_model::function;
using namespace compute_model::common::fp16;
using namespace compute_model::gemm;

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

/**
 * 对key张量进行变换以适应后续计算
 * 
 * @param key 输入key张量 [n_group, seq_len, n_group_size]
 * @param head_num 注意力头数
 * @param d_model 模型维度
 * @return 变换后的key张量 [head_num, seq_len/n_group_size, d_h/k_group_size, n_group_size, k_group_size]
 */
Tensor<half> KeyTransform(Tensor<half>& key, int head_num, int d_model)
{
  int d_h          = d_model / head_num;
  int seq_len      = key.shape(1);
  int k_group_size = 16;
  int n_group_size = 32;
  int n_groups     = key.shape(0);

  auto output = zeros<half>({head_num, seq_len / n_group_size, d_h / k_group_size, n_group_size, k_group_size}, kHalf);

  for (int head = 0; head < head_num; head++) {
    for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
      for (int k_iter = 0; k_iter < d_h / k_group_size; k_iter++) {
        for (int n = 0; n < n_group_size; n++) {
          for (int k = 0; k < k_group_size; k++) {
            int out_idx = head * seq_len * d_h + n_iter * d_h * n_group_size + k_iter * n_group_size * k_group_size + n * k_group_size + k;
            int in_idx =
              (head * (d_h / k_group_size) + k_iter) * seq_len * k_group_size + n_iter * n_group_size * k_group_size + n * k_group_size + k;
            output[out_idx] = key[in_idx];
          }
        }
      }
    }
  }
  return output;
}
/**
 * 从转换后的query张量中提取特定头的slice
 * 
 * @param query 输入query张量 [n_group, seq_len, n_group_size]
 * @param head_num 注意力头数
 * @param head_cnt 当前头索引
 * @param d_model 模型维度
 * @param seq_len 序列长度
 * @return 提取的query slice [d_h/k_group_size, seq_len, k_group_size]
 */
Tensor<half> QuerySlice(Tensor<half>& query, int head_num, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / head_num;
  int k_group_size = 16;
  int n_group_size = 32;

  auto output = zeros<half>({d_h / k_group_size, seq_len, k_group_size}, kHalf);

  for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
    for (int k_iter = 0; k_iter < d_h / k_group_size; k_iter++) {
      for (int n = 0; n < n_group_size; n++) {
        for (int k = 0; k < k_group_size; k++) {
          int out_idx = n_iter * d_h * n_group_size + k_iter * n_group_size * k_group_size + n * k_group_size + k;
          int in_idx  = n_iter * d_h * n_group_size + k_iter * n_group_size * k_group_size + n * k_group_size + k
                       + head_cnt * (d_h / k_group_size) * seq_len * k_group_size;
          output[out_idx] = query[in_idx];
        }
      }
    }
  }

  return output;
}
/**
 * 从转换后的key张量中提取特定头的slice
 * 
 * @param key 输入key张量 [head_num, seq_len/n_group_size, d_h/k_group_size, n_group_size, k_group_size]
 * @param head_num 注意力头数
 * @param head_cnt 当前头索引
 * @param d_model 模型维度
 * @param seq_len 序列长度
 * @return 提取的key slice [seq_len/n_group_size, d_h/k_group_size, n_group_size, k_group_size]
 */
Tensor<half> KeySlice(Tensor<half>& key, int head_num, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / head_num;
  int k_group_size = 16;
  int n_group_size = 32;

  auto output = zeros<half>({seq_len / n_group_size, d_h / k_group_size, n_group_size, k_group_size}, kHalf);
  for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
    for (int k_iter = 0; k_iter < d_h / k_group_size; k_iter++) {
      for (int n = 0; n < n_group_size; n++) {
        for (int k = 0; k < k_group_size; k++) {
          int out_idx = n_iter * d_h * n_group_size + k_iter * n_group_size * k_group_size + n * k_group_size + k;
          int in_idx = n_iter * d_h * n_group_size + k_iter * n_group_size * k_group_size + n * k_group_size + k + head_cnt * seq_len * d_h;
          output[out_idx] = key[in_idx];
        }
      }
    }
  }
  return output;
}
/**
 * 将计算得到的score_slice合并到score张量中
 * 
 * @param score 目标score张量 [head_num, seq_len/n_group_size, seq_len, n_group_size]
 * @param score_slice 当前头的score_slice [seq_len/n_group_size, seq_len, n_group_size]
 * @param head_num 注意力头数
 * @param head_cnt 当前头索引
 * @param d_model 模型维度
 * @param seq_len 序列长度
 */
void ScoreConcat(Tensor<float>& score, Tensor<float>& score_slice, int head_num, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / head_num;
  int n_group_size = 32;

  for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
    for (int seq = 0; seq < seq_len; seq++) {
      for (int n = 0; n < n_group_size; n++) {
        for (int head = 0; head < head_num; head++) {
          int out_idx    = head_cnt * seq_len * seq_len + n_iter * seq_len * n_group_size + seq * n_group_size + n;
          int in_idx     = n_iter * seq_len * n_group_size + seq * n_group_size + n;
          score[out_idx] = score_slice[in_idx];
        }
      }
    }
  }
}

/**
 * 为score张量应用因果掩码
 * 
 * @param score 输入score张量 [num_head, seq_len/n_group_size, seq_len, n_group_size]
 * @param num_head 注意力头数
 * @param seq_len 序列长度
 */
void CausalMask(Tensor<float>& score, int num_head, int seq_len)
{
  int n_group_size = 32;

  auto mask_head_origianl = zeros<float>({seq_len, seq_len}, kFloat32);
  for (int i = 0; i < seq_len; i++) {
    for (int j = 0; j < seq_len; j++) {
      if (i < j) {
        mask_head_origianl[i * seq_len + j] = -1e9f;  // -inf
      }
      else {
        mask_head_origianl[i * seq_len + j] = 0.0f;
      }
    }
  }

  auto mask_head_transformed = zeros<float>({seq_len/n_group_size, seq_len, n_group_size}, kFloat32);
  for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
    for (int seq = 0; seq < seq_len; seq++) {
      for (int n = 0; n < n_group_size; n++) {
        int out_idx = n_iter * seq_len * n_group_size + seq * n_group_size + n;
        int in_idx  = n_iter * n_group_size + seq * seq_len + n;
        mask_head_transformed[out_idx] = mask_head_origianl[in_idx];
      }
    }
  }

  auto mask_concat = zeros<float>({num_head, seq_len/n_group_size, seq_len, n_group_size}, kFloat32);
  for (int head = 0; head < num_head; head++) {
    for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
      for (int seq = 0; seq < seq_len; seq++) {
        for (int n = 0; n < n_group_size; n++) {
          int out_idx = head * seq_len * seq_len + n_iter * seq_len * n_group_size + seq * n_group_size + n;
          int in_idx  = n_iter * seq_len * n_group_size + seq * n_group_size + n;
          mask_concat[out_idx] = mask_head_transformed[in_idx];
        }
      }
    }
  }

  /** 暂时放这里，后续考虑开个接口存文件路径 */
  saveCharArrayToFormattedTextFile(
  "../../sim/memory_llama/mask_concat.txt", (char*)mask_concat.data_ptr(), mask_concat.numel() * sizeof(float), 32, true);
  saveCharArrayToFormattedTextFile(
  "../../sim/memory_transformer/mask_concat.txt", (char*)mask_concat.data_ptr(), mask_concat.numel() * sizeof(float), 32, true);

  /** score shape: [num_head, seq_len/n_group_size, seq_len, n_group_size] */
  for (int head = 0; head < num_head; head++) {
    for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
      for (int seq = 0; seq < seq_len; seq++) {
        for (int n = 0; n < n_group_size; n++) {
          int idx = head * seq_len * seq_len + n_iter * seq_len * n_group_size + seq * n_group_size + n;
          score[idx] += mask_concat[idx];
        }
      }
    }
  }
}

/**
 * 对score张量应用softmax操作
 * 
 * @param score 输入score张量 [head_num, seq_len/n_group_size, seq_len, n_group_size]
 * @return softmax后的结果 [head_num, seq_len/n_group_size*2, seq_len, n_group_size/2]
 */
Tensor<half> Softmax(Tensor<float>& score)
{
  int head_num = score.shape(0);
  int n_groups = score.shape(1);
  int seq_len  = score.shape(2);

  int n_group_size = 32;

  auto output = zeros<float>({score.shape(0), score.shape(1), score.shape(2), score.shape(3)}, kFloat32);

  auto data_exp = score * (std::log2(exp(1.0f)));
  data_exp = compute_model::function::exp2(data_exp);

  for (int head = 0; head < head_num; head++) {
    auto data_sum = zeros<float>({seq_len, n_group_size}, kFloat32);
    for (int n_iter = 0; n_iter < n_groups; n_iter++) {
      Tensor<float> sub_tensor({seq_len, n_group_size}, kFloat32);
      for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
        for (int n_group_iter = 0; n_group_iter < n_group_size; n_group_iter++) {
          sub_tensor[seq_len_iter * n_group_size + n_group_iter] =
            data_exp[head * n_groups * seq_len * n_group_size + n_iter * seq_len * n_group_size + seq_len_iter * n_group_size
                     + n_group_iter];
        }
      }

      auto data_sum_temp = compute_model::function::reduce_sum(sub_tensor, 32, false);

      data_sum = data_sum + data_sum_temp;
    }

    auto sum_rec = compute_model::function::reciprocal(data_sum);

    for (int n_iter = 0; n_iter < n_groups; n_iter++) {
      for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
        for (int n_group_iter = 0; n_group_iter < n_group_size; n_group_iter++) {
          output[head * n_groups * seq_len * n_group_size + n_iter * seq_len * n_group_size + seq_len_iter * n_group_size + n_group_iter] =
            data_exp[head * n_groups * seq_len * n_group_size + n_iter * seq_len * n_group_size + seq_len_iter * n_group_size
                     + n_group_iter]
            * sum_rec[seq_len_iter * n_group_size + n_group_iter];
        }
      }
    }
  }


  auto output_hf = ToFloat16(output);

  auto output_hf_convert = zeros<half>({score.shape(0), score.shape(1) * 2, score.shape(2), score.shape(3) / 2}, kHalf);
  // auto output_hf_convert = ParallelismConvertion32to16(output_hf);
  for (int i = 0; i < head_num; i++) {
    auto sub_tensor = zeros<half>({score.shape(1), score.shape(2), score.shape(3)}, kHalf);
    for (int j = 0; j < score.shape(1); j++) {
      for (int k = 0; k < score.shape(2); k++) {
        for (int l = 0; l < score.shape(3); l++) {
          sub_tensor[j * score.shape(2) * score.shape(3) + k * score.shape(3) + l] =
            output_hf[i * score.shape(1) * score.shape(2) * score.shape(3) + j * score.shape(2) * score.shape(3) + k * score.shape(3) + l];
        }
      }
    }

    auto sub_tensor_convert = ParallelismConvertion32to16(sub_tensor);

    for (int j = 0; j < score.shape(1) * 2; j++) {
      for (int k = 0; k < score.shape(2); k++) {
        for (int l = 0; l < score.shape(3) / 2; l++) {
          output_hf_convert[i * score.shape(1) * 2 * score.shape(2) * score.shape(3) / 2 + j * score.shape(2) * score.shape(3) / 2
                            + k * score.shape(3) / 2 + l] =
            sub_tensor_convert[j * score.shape(2) * score.shape(3) / 2 + k * score.shape(3) / 2 + l];
        }
      }
    }
  }

  return output_hf_convert;
}
/**
 * 对value张量进行变换以适应后续计算
 * 
 * @param value 输入value张量 [n_group, seq_len, n_group_size]
 * @param head_num 注意力头数
 * @param d_model 模型维度
 * @return 变换后的value张量 [head_num, d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size]
 */
Tensor<half> ValueTransform(Tensor<float>& value, int num_head, int d_model)
{
  int d_h          = d_model / num_head;
  int seq_len      = value.shape(1);
  int k_group_size = 16;
  int n_group_size = 32;

  // Step 1: Transform from [d_model/n_group_size, seq_len, n_group_size] to [seq_len/n_group_size, d_model, n_group_size]
  auto value_step1 = zeros<float>({seq_len / n_group_size, d_model, n_group_size}, kFloat32);
  for (int seq_iter = 0; seq_iter < seq_len / n_group_size; seq_iter++) {
    for (int d_iter = 0; d_iter < d_model / n_group_size; d_iter++) {
      for (int n = 0; n < n_group_size; n++) {
        for (int seq_in_group = 0; seq_in_group < n_group_size; seq_in_group++) {
          int out_idx = seq_iter * d_model * n_group_size + d_iter * n_group_size * n_group_size + n * n_group_size + seq_in_group;
          int in_idx = d_iter * seq_len * n_group_size + (seq_iter * n_group_size + seq_in_group) * n_group_size + n;
          value_step1[out_idx] = value[in_idx];
        }
      }
    }
  }

  // Step 2: Transform from [seq_len/n_group_size, d_model, n_group_size] to [seq_len/k_group_size, d_model, k_group_size]
  auto value_step2 = zeros<half>({seq_len / k_group_size, d_model, k_group_size}, kHalf);
  for (int seq_iter = 0; seq_iter < seq_len / n_group_size; seq_iter++) {
    for (int d_iter = 0; d_iter < d_model; d_iter++) {
      for (int n = 0; n < n_group_size; n++) {
        int in_idx = seq_iter * d_model * n_group_size + d_iter * n_group_size + n;
        
        int out_seq_iter = seq_iter * 2 + (n >= k_group_size ? 1 : 0);
        int out_k = n >= k_group_size ? n - k_group_size : n;
        int out_idx = out_seq_iter * d_model * k_group_size + d_iter * k_group_size + out_k;
        
        value_step2[out_idx] = (half)value_step1[in_idx];
      }
    }
  }

  // Step 3: Transform from [seq_len/k_group_size, d_model, k_group_size] to [head_num, d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size]
  auto output_hf = zeros<half>({num_head, d_h / n_group_size, seq_len / k_group_size, n_group_size, k_group_size}, kHalf);
  for (int head = 0; head < num_head; head++) {
    for (int d_iter = 0; d_iter < d_h / n_group_size; d_iter++) {
      for (int seq_iter = 0; seq_iter < seq_len / k_group_size; seq_iter++) {
        for (int n = 0; n < n_group_size; n++) {
          for (int k = 0; k < k_group_size; k++) {
            int out_idx = head * (d_h / n_group_size) * (seq_len / k_group_size) * n_group_size * k_group_size
                         + d_iter * (seq_len / k_group_size) * n_group_size * k_group_size
                         + seq_iter * n_group_size * k_group_size
                         + n * k_group_size + k;
            
            // 计算在原始 d_model 维度中的全局位置
            int d_global = head * d_h + d_iter * n_group_size + n;
            // Correct indexing for value_step2[seq_iter, d_global, n % k_group_size]
            int in_idx = seq_iter * (d_model * k_group_size) + d_global * k_group_size + k;
            
            if (in_idx < value_step2.numel()) {
              output_hf[out_idx] = value_step2[in_idx];
            }
          }
        }
      }
    }
  }

  return output_hf;
}

/**
 * 从softmax后的probe张量中提取特定头的slice
 * 
 * @param probe softmax后的张量 [head_num, seq_len/n_group_size*2, seq_len, n_group_size/2]
 * @param head_num 注意力头数
 * @param head_cnt 当前头索引
 * @param d_model 模型维度
 * @param seq_len 序列长度
 * @return 提取的probe slice [seq_len/k_group_size, seq_len, k_group_size]
 */
Tensor<half> ProbeSlice(Tensor<half> probe, int head_num, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / head_num;
  int k_group_size = 16;
  int n_group_size = 32;

  auto output = zeros<half>({seq_len / k_group_size, seq_len, k_group_size}, kHalf);

  for (int k_iter = 0; k_iter < seq_len / k_group_size; k_iter++) {
    for (int seq = 0; seq < seq_len; seq++) {
      for (int k = 0; k < k_group_size; k++) {
        int out_idx     = k_iter * seq_len * k_group_size + seq * k_group_size + k;
        int in_idx      = k_iter * seq_len * k_group_size + seq * k_group_size + k + head_cnt * seq_len * seq_len;
        output[out_idx] = probe[in_idx];
      }
    }
  }

  return output;
}

/**
 * 从变换后的value张量中提取特定头的slice
 * 
 * @param value 变换后的value张量 [head_num, d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size]
 * @param head_num 注意力头数
 * @param head_cnt 当前头索引
 * @param d_model 模型维度
 * @param seq_len 序列长度
 * @return 提取的value slice [d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size]
 */
Tensor<half> ValueSlice(Tensor<half>& value, int head_num, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / head_num;
  int k_group_size = 16;
  int n_group_size = 32;

  auto output = zeros<half>({d_h / n_group_size, seq_len / k_group_size, n_group_size, k_group_size}, kHalf);

  for (int n_iter = 0; n_iter < d_h / n_group_size; n_iter++) {
    for (int k_iter = 0; k_iter < seq_len / k_group_size; k_iter++) {
      for (int n = 0; n < n_group_size; n++) {
        for (int k = 0; k < k_group_size; k++) {
          int out_idx = n_iter * seq_len * n_group_size + k_iter * n_group_size * k_group_size + n * k_group_size + k;
          int in_idx =
            n_iter * seq_len * n_group_size + k_iter * n_group_size * k_group_size + n * k_group_size + k + head_cnt * d_h * seq_len;
          output[out_idx] = value[in_idx];
        }
      }
    }
  }

  return output;
}

/**
 * 将计算得到的output_slice合并到output_temp_hf张量中
 * 
 * @param output 目标output张量 [d_model/k_group_size, seq_len, k_group_size]
 * @param output_slice 当前头的output_slice [d_h/k_group_size, seq_len, k_group_size]
 * @param head_num 注意力头数
 * @param head_cnt 当前头索引
 * @param d_model 模型维度
 * @param seq_len 序列长度
 */
void OutputConcat(Tensor<half>& output, Tensor<half>& output_slice, int head_num, int head_cnt, int d_model, int seq_len)
{
  int k_group_size = 16;
  int d_h          = d_model / head_num;

  for (int k_iter = 0; k_iter < d_h / k_group_size; k_iter++) {
    for (int seq = 0; seq < seq_len; seq++) {
      for (int k = 0; k < k_group_size; k++) {
        int in_idx      = k_iter * seq_len * k_group_size + seq * k_group_size + k;
        int out_idx     = head_cnt * seq_len * d_h + k_iter * seq_len * k_group_size + seq * k_group_size + k;
        output[out_idx] = output_slice[in_idx];
      }
    }
  }
}

/**
 * 应用RoPE位置编码
 * 
 * @param input 输入张量 [d_model/k_group_size, seq_len, k_group_size]
 * @param seq_len 序列长度
 * @param d_model 模型维度
 * @param num_head 注意力头数
 * @return 应用RoPE位置编码后的张量 [d_model/k_group_size, seq_len, k_group_size]
 */
Tensor<float> RoPE_Embedding(Tensor<float>& input, int seq_len, int d_model, int num_head)
{
  int d_h          = d_model / num_head;
  int n_group_size = 32;
  int n_group      = d_model / n_group_size;
  
  using namespace compute_model::transformer::rope_embedding;

  auto freq_cls_head = generate_freq_cls<float>(seq_len, d_h); //单个head的频率张量,{d_h/n_group_size, seq_len, n_group_size}
  auto freq_cls_concat = zeros<float>({d_model/n_group_size, seq_len, n_group_size}, kFloat32); //所有head的频率张量拼接
  for (int head = 0; head < num_head; head++) {
    for(int n_iter = 0; n_iter < d_h / n_group_size; n_iter++) {
      for(int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
        for(int n_group_iter = 0; n_group_iter < n_group_size; n_group_iter++) {
          int out_idx = head * d_h * seq_len + n_iter * seq_len * n_group_size + seq_len_iter * n_group_size + n_group_iter;
          int in_idx = n_iter * seq_len * n_group_size + seq_len_iter * n_group_size + n_group_iter;
          freq_cls_concat[out_idx] = freq_cls_head[in_idx];
        }
      }
    }
  }

  // 暂时先放着，后面考虑开个文件路径接口？
  saveCharArrayToFormattedTextFile("../../sim/memory_transformer/freq_cls_concat.txt",
                                    reinterpret_cast<char*>(freq_cls_concat.data_ptr()),
                                    freq_cls_concat.numel() * sizeof(float),
                                    32,
                                    true);
  saveCharArrayToFormattedTextFile("../../sim/memory_llama/freq_cls_concat.txt",
                                    reinterpret_cast<char*>(freq_cls_concat.data_ptr()),
                                    freq_cls_concat.numel() * sizeof(float),
                                    32,
                                    true);

  auto rope_output = rope_embedding::rope_embedding<float>(input, freq_cls_concat);
  return rope_output;
}

/**
 * Llama Attention
 * 
 * @param input 输入张量 [k_group, seq_len, k_group_size]
 * @param output 输出张量 [k_group, seq_len, k_group_size]
 * @param weight_query 查询权重 [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size]
 * @param weight_key 键权重 [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size]
 * @param weight_value 值权重 [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size]
 * @param weight_output 输出投影权重 [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size]
 * @param head_num 注意力头数
 * @param debug 是否输出调试信息
 */
template<typename TYPE_A, typename TYPE_B, typename TYPE_C, bool DEBUG = false>
void ApplyLlamaAttention(
    Tensor<TYPE_A>& input,
    Tensor<TYPE_C>& output,
    Tensor<TYPE_B>& weight_query,
    Tensor<TYPE_B>& weight_key,
    Tensor<TYPE_B>& weight_value,
    Tensor<TYPE_B>& weight_output,
    int head_num)
{
  // 获取维度信息
  int seq_len = input.shape()[1];
  int k_group_size = input.shape()[2];
  int k_group = input.shape()[0];
  
  int n_group_size = weight_query.shape()[2];
  int n_group = weight_query.shape()[0];
  
  int d_model = k_group * k_group_size;
  int d_h = d_model / head_num;

  //分块参数
  int tile_m = std::min(seq_len, 32);
  int block_n_group = std::min(n_group, 8);
  int block_k_group = std::min(k_group, 8);
  
  if (DEBUG) {
    std::cout << "======== LlamaAttention Parameters ========" << std::endl;
    std::cout << "seq_len: " << seq_len << std::endl;
    std::cout << "d_model: " << d_model << std::endl;
    std::cout << "head_num: " << head_num << std::endl;
    std::cout << "d_h: " << d_h << std::endl;
    std::cout << "k_group_size: " << k_group_size << std::endl;
    std::cout << "k_group: " << k_group << std::endl;
    std::cout << "n_group_size: " << n_group_size << std::endl;
    std::cout << "n_group: " << n_group << std::endl;
  }
    
  using gemm_sim_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, DEBUG>;
  gemm_sim_t gemm_sim_op;

  /* ------------------------------------------- Query Projection ------------------------------------------- */
  if (DEBUG){
    std::cout << "========================================" << std::endl;
    std::cout << "============Query Projection============" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << std::dec;
  }

  auto query_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

  typename gemm_sim_t::Arguments args_query_sim = {query_temp, input, weight_query, tile_m, block_n_group, block_k_group};
  gemm_sim_op(args_query_sim);

  auto query_temp_rope = RoPE_Embedding(query_temp, seq_len, d_model, head_num);

  auto query_temp_fp = ToFloat16(query_temp_rope);
  query_temp_fp      = ParallelismConvertion32to16(query_temp_fp);
  
  /* ------------------------------------------- Key Projection ------------------------------------------- */
  if (DEBUG) {
    std::cout << "========================================" << std::endl;
    std::cout << "============Key Projection============" << std::endl;
    std::cout << "========================================" << std::endl;
  }
  auto key_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

  typename gemm_sim_t::Arguments args_key_sim = {key_temp, input, weight_key, tile_m, block_n_group, block_k_group};
  gemm_sim_op(args_key_sim);

  auto key_temp_rope = RoPE_Embedding(key_temp, seq_len, d_model, head_num);

  auto key_temp_fp = ToFloat16(key_temp_rope);
  key_temp_fp      = ParallelismConvertion32to16(key_temp_fp);

  auto key_temp_ref = KeyTransform(key_temp_fp, head_num, d_model);

  /* ------------------------------------------------- QK^T ------------------------------------------------- */
  if (DEBUG) {
    std::cout << "========================================" << std::endl;
    std::cout << "============QK^T============" << std::endl;
    std::cout << "========================================" << std::endl;
  }
  auto score_temp = zeros<float>({head_num, seq_len / n_group_size, seq_len, n_group_size}, kFloat32);

  for (int head = 0; head < head_num; head++) {
    auto query_head = QuerySlice(query_temp_fp, head_num, head, d_model, seq_len);
    auto key_head   = KeySlice(key_temp_ref, head_num, head, d_model, seq_len);
    auto score_head = zeros<float>({seq_len / n_group_size, seq_len, n_group_size}, kFloat32);

    typename gemm_sim_t::Arguments args_score_sim = {score_head, query_head, key_head, tile_m, block_n_group, block_k_group};
    gemm_sim_op(args_score_sim);

    score_head = score_head * (1.0f / std::sqrt((float)d_h));  // 缩放因子：1/sqrt(d_h)
    ScoreConcat(score_temp, score_head, head_num, head, d_model, seq_len);

    if(DEBUG){
      std::cout << "head_idx: " << head << std::endl;
      std::cout << "query_head shape: " << query_head.shape()[0] << " x " << query_head.shape()[1] << " x " << query_head.shape()[2] << std::endl;
      std::cout << "key_head shape: " << key_head.shape()[0] << " x " << key_head.shape()[1] << " x " << key_head.shape()[2] << " x " << key_head.shape()[3] << std::endl;
      std::cout << "score_head shape: " << score_head.shape()[0] << " x " << score_head.shape()[1] << " x " << score_head.shape()[2] << std::endl;
      std::cout << "score_head: " << score_head << std::endl;
    }
  }

  /* ------------------------------------------------ casual mask ----------------------------------------------- */
  CausalMask(score_temp, head_num, seq_len);
  if(DEBUG){
    std::cout << "========================================" << std::endl;
    std::cout << "============casual mask============" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "score_temp after casual mask: " << score_temp << std::endl;
  }

  /* ------------------------------------------------ softmax ----------------------------------------------- */
  auto softmax_ref = Softmax(score_temp);
  if(DEBUG){
    std::cout << "========================================" << std::endl;
    std::cout << "============softmax============" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "softmax_ref: " << softmax_ref << std::endl;
  }

  /* ------------------------------------------- Value Projection ------------------------------------------- */
  if(DEBUG){
    std::cout << "========================================" << std::endl;
    std::cout << "============Value Projection============" << std::endl;
    std::cout << "========================================" << std::endl;
  }

  auto value_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

  typename gemm_sim_t::Arguments args_value_sim = {value_temp, input, weight_value, tile_m, block_n_group, block_k_group};
  gemm_sim_op(args_value_sim);

  auto value_transform = ValueTransform(value_temp, head_num, d_model);
  if (DEBUG){
    std::cout << "value_transform: " << value_transform << std::endl;
  }

  /* --------------------------------------------- Probe x Value -------------------------------------------- */
  if (DEBUG){
    std::cout << "========================================" << std::endl;
    std::cout << "============Probe x Value============" << std::endl;
    std::cout << "========================================" << std::endl;
  }

  auto output_temp = zeros<half>({d_model / k_group_size, seq_len, k_group_size}, kHalf);

  for (int head = 0; head < head_num; head++) {
    auto probe_head = ProbeSlice(softmax_ref, head_num, head, d_model, seq_len);
    auto value_head = ValueSlice(value_transform, head_num, head, d_model, seq_len);
    auto output_head = zeros<float>({d_h / n_group_size, seq_len, n_group_size}, kFloat32);

    typename gemm_sim_t::Arguments args_output_sim = {output_head, probe_head, value_head, tile_m, block_n_group, block_k_group};
    gemm_sim_op(args_output_sim);

    auto output_head_hf         = ToFloat16(output_head);
    auto output_head_hf_convert = ParallelismConvertion32to16(output_head_hf);
    OutputConcat(output_temp, output_head_hf_convert, head_num, head, d_model, seq_len);
  }

  /* ------------------------------------------- Output Projection ------------------------------------------ */
  if (DEBUG){
    std::cout << "========================================" << std::endl;
    std::cout << "============Output Projection============" << std::endl;
    std::cout << "========================================" << std::endl;
  }
  auto output_fp32        = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);
  typename gemm_sim_t::Arguments args_output_sim = {output_fp32, output_temp, weight_output, tile_m, block_n_group, block_k_group};
  gemm_sim_op(args_output_sim);

  output = output_fp32;
  // auto output_hf = ToFloat16(output_fp32);

  // auto output_hf_convert = ParallelismConvertion32to16(output_hf);
  // output = output_hf_convert;
}

/**
 * 便捷版本，直接返回结果而不是通过引用输出
 */
template<typename TYPE_A, typename TYPE_B, typename TYPE_C>
Tensor<TYPE_C> LlamaAttention(
    Tensor<TYPE_A>& input,
    Tensor<TYPE_B>& weight_query,
    Tensor<TYPE_B>& weight_key,
    Tensor<TYPE_B>& weight_value,
    Tensor<TYPE_B>& weight_output,
    int head_num)
{
  int seq_len = input.shape()[1];
  int k_group = input.shape()[0];
  int k_group_size = input.shape()[2];
  
  Tensor<TYPE_C> output({k_group / 2, seq_len, k_group_size * 2}, kFloat32);
  
  ApplyLlamaAttention<TYPE_A, TYPE_B, TYPE_C>(
      input, output, weight_query, weight_key, weight_value, weight_output, head_num);
  
  return output;
}

}  // namespace llama_attention
}  // namespace transformer
}  // namespace compute_model
