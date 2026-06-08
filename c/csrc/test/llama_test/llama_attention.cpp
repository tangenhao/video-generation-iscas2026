#include "transformer/llama_attention.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/gemm/gemm.h"
#include "instruction/parser.h"
#include "compute_model/transformer/rope_embedding.h"
#include "cmath"
#include "addr_for_transformer.h"

bool update_reference = 1;
using namespace compute_model::tensor;

Tensor<half> KeyTransform(Tensor<half>& key, int num_head, int d_model)
{
  int d_h          = d_model / num_head;
  int seq_len      = key.shape(1);
  int k_group_size = 16;
  int n_group_size = 32;
  int n_groups     = key.shape(0);

  auto output = zeros<half>({num_head, seq_len / n_group_size, d_h / k_group_size, n_group_size, k_group_size}, kHalf);

  for (int head = 0; head < num_head; head++) {
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

Tensor<half> QuerySlice(Tensor<half>& query, int num_head, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / num_head;
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

Tensor<half> KeySlice(Tensor<half>& key, int num_head, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / num_head;
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

void ScoreConcat(Tensor<float>& score, Tensor<float>& score_slice, int num_head, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / num_head;
  int n_group_size = 32;

  for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
    for (int seq = 0; seq < seq_len; seq++) {
      for (int n = 0; n < n_group_size; n++) {
        for (int head = 0; head < num_head; head++) {
          int out_idx    = head_cnt * seq_len * seq_len + n_iter * seq_len * n_group_size + seq * n_group_size + n;
          int in_idx     = n_iter * seq_len * n_group_size + seq * n_group_size + n;
          score[out_idx] = score_slice[in_idx];
        }
      }
    }
  }
}

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
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/mask_concat.txt", (char*)mask_concat.data_ptr(), mask_concat.numel() * sizeof(float), 32, true);
  
  /** score shape: [num_head, seq_len/n_group_size, seq_len, n_group_size] */
  // for (int head = 0; head < num_head; head++) {
  //   auto score_head = zeros<float>({seq_len / n_group_size, seq_len, n_group_size}, kFloat32);
  //   auto mask_head  = zeros<float>({seq_len / n_group_size, seq_len, n_group_size}, kFloat32);
  //   for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
  //     for (int seq = 0; seq < seq_len; seq++) {
  //       for (int n = 0; n < n_group_size; n++) {
  //         int in_idx = head * seq_len * seq_len + n_iter * seq_len * n_group_size + seq * n_group_size + n;
  //         int out_idx = n_iter * seq_len * n_group_size + seq * n_group_size + n;
  //         score_head[out_idx] = score[in_idx];
  //         mask_head[out_idx]  = mask_concat[in_idx];
  //       }
  //     }
  //   }
  //   score_head = compute_model::function::add_elementwise(score_head, mask_head);
  //   for (int n_iter = 0; n_iter < seq_len / n_group_size; n_iter++) {
  //     for (int seq = 0; seq < seq_len; seq++) {
  //       for (int n = 0; n < n_group_size; n++) {
  //         int in_idx  = n_iter * seq_len * n_group_size + seq * n_group_size + n;
  //         int out_idx = head * seq_len * seq_len + in_idx;
  //         score[out_idx] = score_head[in_idx];
  //       }
  //     }
  //   }
  // }
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

Tensor<half> Softmax(Tensor<float>& score)
{
  int num_head = score.shape(0);
  int n_groups = score.shape(1);
  int seq_len  = score.shape(2);

  int n_group_size = 32;

  auto output = zeros<float>({score.shape(0), score.shape(1), score.shape(2), score.shape(3)}, kFloat32);

  auto data_exp = score * (std::log2(exp(1.0f)));
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/data_exp_mul.txt", (char*)data_exp.data_ptr(), data_exp.numel() * sizeof(float), 32, true);
  data_exp = compute_model::function::exp2(data_exp);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/data_exp.txt", (char*)data_exp.data_ptr(), data_exp.numel() * sizeof(float), 32, true);

  for (int head = 0; head < num_head; head++) {
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
      common::file_utils::saveCharArrayToFormattedTextFile(
        ("../../sim/memory_transformer/softmax_sum_temp_" + std::to_string(n_iter) + "_head_" + std::to_string(head) + ".txt").c_str(),
        (char*)data_sum_temp.data_ptr(),
        data_sum_temp.numel() * sizeof(float),
        32,
        true);

      data_sum = data_sum + data_sum_temp;
      common::file_utils::saveCharArrayToFormattedTextFile(
        ("../../sim/memory_transformer/softmax_sum_" + std::to_string(n_iter) + "_head_" + std::to_string(head) + ".txt").c_str(),
        (char*)data_sum.data_ptr(),
        data_sum.numel() * sizeof(float),
        32,
        true);
    }

    auto sum_rec = compute_model::function::reciprocal(data_sum);

    common::file_utils::saveCharArrayToFormattedTextFile(
      ("../../sim/memory_transformer/softmax_sum_rec_head_" + std::to_string(head) + ".txt").c_str(),
      (char*)sum_rec.data_ptr(),
      sum_rec.numel() * sizeof(float),
      32,
      true);

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

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/softmax_out_fp32.txt", (char*)output.data_ptr(), output.numel() * sizeof(float), 32, true);

  auto output_hf = ToFloat16(output);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/softmax_out_fp16.txt", (char*)output_hf.data_ptr(), output.numel() * sizeof(half), 32, true);
  auto output_hf_convert = zeros<half>({score.shape(0), score.shape(1) * 2, score.shape(2), score.shape(3) / 2}, kHalf);
  // auto output_hf_convert = ParallelismConvertion32to16(output_hf);
  for (int i = 0; i < num_head; i++) {
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

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/value_step1.txt",
                                                       reinterpret_cast<char*>(value_step1.data_ptr()),
                                                       value_step1.numel() * sizeof(float),
                                                       32,
                                                       true);

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

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/value_step2.txt",
                                                       reinterpret_cast<char*>(value_step2.data_ptr()),
                                                       value_step2.numel() * sizeof(half),
                                                       32,
                                                       true);

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

Tensor<half> ProbeSlice(Tensor<half> probe, int num_head, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / num_head;
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

Tensor<half> ValueSlice(Tensor<half>& value, int num_head, int head_cnt, int d_model, int seq_len)
{
  int d_h          = d_model / num_head;
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

void OutputConcat(Tensor<half>& output, Tensor<half>& output_slice, int num_head, int head_cnt, int d_model, int seq_len)
{
  int k_group_size = 16;
  int d_h          = d_model / num_head;

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
  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/freq_cls_concat.txt",
                                                       reinterpret_cast<char*>(freq_cls_concat.data_ptr()),
                                                       freq_cls_concat.numel() * sizeof(float),
                                                       32,
                                                       true);

  auto rope_output = rope_embedding<float>(input, freq_cls_concat);
  return rope_output;
}

int main()
{
  int head_num     = 2;
  int seq_len      = 64;
  int d_model      = 128;
  int d_h          = d_model / head_num;
  int k_group_size = 16;
  int n_group_size = 32;
  int n_group      = d_model / n_group_size;
  int k_group      = d_model / k_group_size;
  int block_n_group = std::min(n_group, 8);
  int block_k_group = std::min(k_group, 8);
  int tile_m = std::min(seq_len, 32);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                               Instructions                                               */
  /* -------------------------------------------------------------------------------------------------------- */
  using llama_mha_t = transformer::mha::LlamaAttentionOp<true, false>;
  llama_mha_t           llama_mha_op;
  llama_mha_t::Argument args  = 
  {.seq_len = seq_len,
  .d_model = d_model,
  .head_num = head_num,
  .input_base_addr = INPUT_ADDR,
  .weight_query_base_addr = QUERY_WEIGHT_ADDR,
  .weight_key_base_addr = KEY_WEIGHT_ADDR,
  .weight_value_base_addr = VALUE_WEIGHT_ADDR,
  .weight_output_base_addr = OUTPUT_WEIGHT_ADDR,
  .query_temp_base_addr = QUERY_TEMP_ADDR,
  .key_temp_base_addr = KEY_TEMP_ADDR,
  .value_temp_base_addr = VALUE_TEMP_ADDR,
  .score_temp_base_addr = SCORE_TEMP_ADDR,
  .probe_temp_base_addr = PROBE_TEMP_ADDR,
  .output_temp_base_addr = OUTPUT_TEMP_ADDR, 
  .output_base_addr = OUTPUT_ADDR,
  .freq_cls_base_addr = FREQ_CLS_ADDR,
  .mask_base_addr = MASK_ADDR
};

  auto            pack        = llama_mha_op(args);
  auto            insn_series = pack.first;
  auto            vcucode_series  = pack.second;

  common::insn::pad_serial_sync_word(insn_series);

  auto parser = common::insn::instruction_parser(insn_series);
  parser.parse_instruction();
  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/insn.txt",
                                                       reinterpret_cast<char*>(insn_series.data()),
                                                       insn_series.size() * sizeof(common::insn::instruction),
                                                       32,
                                                       true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/vcucode.txt", reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 Reference                                                */
  /* -------------------------------------------------------------------------------------------------------- */
  if (update_reference) {
    using gemm_sim_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, false>;
    gemm_sim_t gemm_sim_op;

    using gemm_sim_dbg_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, true>;
    gemm_sim_dbg_t gemm_sim_op_dbg;

    /* ------------------------------------------- Query Projection ------------------------------------------- */
    std::cout << "========================================" << std::endl;
    std::cout << "============Query Projection============" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << std::dec;

    auto input        = randn<half>({d_model / k_group_size, seq_len, k_group_size}, kHalf, -0.1f, 0.1f, 0);
    auto weight_query = randn<half>({d_model / n_group_size, d_model / k_group_size, n_group_size, k_group_size}, kHalf, -0.1f, 0.1f, 100);
    auto query_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

    gemm_sim_dbg_t::Arguments args_query_sim = {query_temp, input, weight_query, tile_m, block_n_group, block_k_group};
    gemm_sim_op_dbg(args_query_sim);

    common::file_utils::saveCharArrayToFormattedTextFile(
      "../../sim/memory_transformer/input.txt", reinterpret_cast<char*>(input.data_ptr()), input.numel() * sizeof(half), 32, true);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/weight_query.txt",
                                                         reinterpret_cast<char*>(weight_query.data_ptr()),
                                                         weight_query.numel() * sizeof(half),
                                                         32,
                                                         true);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/query_temp.txt",
                                                         reinterpret_cast<char*>(query_temp.data_ptr()),
                                                         query_temp.numel() * sizeof(float),
                                                         32,
                                                         true);

    auto query_temp_rope = RoPE_Embedding(query_temp, seq_len, d_model, head_num);
    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/query_temp_rope.txt",
                                                         reinterpret_cast<char*>(query_temp_rope.data_ptr()),
                                                         query_temp_rope.numel() * sizeof(float),
                                                         32,
                                                         true);
    auto query_temp_fp = ToFloat16(query_temp_rope);
    query_temp_fp      = ParallelismConvertion32to16(query_temp_fp);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/query_temp_hf.txt",
                                                         reinterpret_cast<char*>(query_temp_fp.data_ptr()),
                                                         query_temp_fp.numel() * sizeof(half),
                                                         32,
                                                         true);
    
    /* ------------------------------------------- Key Projection ------------------------------------------- */
    std::cout << "========================================" << std::endl;
    std::cout << "============Key Projection============" << std::endl;
    std::cout << "========================================" << std::endl;

    auto weight_key = randn<half>({d_model / n_group_size, d_model / k_group_size, n_group_size, k_group_size}, kHalf, -0.1f, 0.1f, 200);
    auto key_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

    gemm_sim_t::Arguments args_key_sim = {key_temp, input, weight_key, tile_m, block_n_group, block_k_group};
    gemm_sim_op(args_key_sim);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/weight_key.txt",
                                                         reinterpret_cast<char*>(weight_key.data_ptr()),
                                                         weight_key.numel() * sizeof(half),
                                                         32,
                                                         true);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/key_temp.txt",
                                                         reinterpret_cast<char*>(key_temp.data_ptr()),
                                                         key_temp.numel() * sizeof(float),
                                                         32,
                                                         true);

    auto key_temp_rope = RoPE_Embedding(key_temp, seq_len, d_model, head_num);
    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/key_temp_rope.txt",
                                                         reinterpret_cast<char*>(key_temp_rope.data_ptr()),
                                                         key_temp_rope.numel() * sizeof(float),
                                                         32,
                                                         true);
                                                         
    auto key_temp_fp = ToFloat16(key_temp_rope);
    key_temp_fp      = ParallelismConvertion32to16(key_temp_fp);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/key_temp_hf.txt",
                                                         reinterpret_cast<char*>(key_temp_fp.data_ptr()),
                                                         key_temp_fp.numel() * sizeof(half),
                                                         32,
                                                         true);

    auto key_temp_ref = KeyTransform(key_temp_fp, head_num, d_model);
    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/key_temp_hf_transform.txt",
                                                         reinterpret_cast<char*>(key_temp_ref.data_ptr()),
                                                         key_temp_ref.numel() * sizeof(half),
                                                         32,
                                                         true);

    /* ------------------------------------------------- QK^T ------------------------------------------------- */
    std::cout << "========================================" << std::endl;
    std::cout << "============QK^T============" << std::endl;
    std::cout << "========================================" << std::endl;

    auto score_temp = zeros<float>({head_num, seq_len / n_group_size, seq_len, n_group_size}, kFloat32);

    for (int head = 0; head < head_num; head++) {
      std::cout << "head_idx: " << head << std::endl;

      auto query_head = QuerySlice(query_temp_fp, head_num, head, d_model, seq_len);
      auto key_head   = KeySlice(key_temp_ref, head_num, head, d_model, seq_len);
      std::cout << "query_head shape: " << query_head.shape()[0] << " x " << query_head.shape()[1] << " x " << query_head.shape()[2] << std::endl;
      std::cout << "key_head shape: " << key_head.shape()[0] << " x " << key_head.shape()[1] << " x " << key_head.shape()[2] << " x " << key_head.shape()[3] << std::endl;

      auto query_file = "../../sim/memory_transformer/query_head" + std::to_string(head) + ".txt";
      auto key_file   = "../../sim/memory_transformer/key_head" + std::to_string(head) + ".txt";
      common::file_utils::saveCharArrayToFormattedTextFile(
        query_file.c_str(), reinterpret_cast<char*>(query_head.data_ptr()), query_head.numel() * sizeof(half), 32, true);

      common::file_utils::saveCharArrayToFormattedTextFile(
        key_file.c_str(), reinterpret_cast<char*>(key_head.data_ptr()), key_head.numel() * sizeof(half), 32, true);

      auto score_head = zeros<float>({seq_len / n_group_size, seq_len, n_group_size}, kFloat32);
      std::cout << "score_head shape: " << score_head.shape()[0] << " x " << score_head.shape()[1] << " x " << score_head.shape()[2] << std::endl;

      gemm_sim_t::Arguments args_score_sim = {score_head, query_head, key_head, tile_m, block_n_group, block_k_group};
      gemm_sim_op(args_score_sim);

      std::cout << "score_head: " << score_head << std::endl;
      score_head = score_head * (1.0f / std::sqrt((float)d_h));  // 缩放因子：1/sqrt(d_h)
      ScoreConcat(score_temp, score_head, head_num, head, d_model, seq_len);
    }

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/score_temp.txt",
                                                         reinterpret_cast<char*>(score_temp.data_ptr()),
                                                         score_temp.numel() * sizeof(float),
                                                         32,
                                                         true);

    /* ------------------------------------------------ casual mask ----------------------------------------------- */
    std::cout << "========================================" << std::endl;
    std::cout << "============casual mask============" << std::endl;
    std::cout << "========================================" << std::endl;
    CausalMask(score_temp, head_num, seq_len);
    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/score_temp_casual_mask.txt",
                                                         reinterpret_cast<char*>(score_temp.data_ptr()),
                                                         score_temp.numel() * sizeof(float),
                                                         32,
                                                         true);
    std::cout << "score_temp after casual mask: " << score_temp << std::endl;

    /* ------------------------------------------------ softmax ----------------------------------------------- */
    std::cout << "========================================" << std::endl;
    std::cout << "============softmax============" << std::endl;
    std::cout << "========================================" << std::endl;    
    
    auto softmax_ref = Softmax(score_temp);
    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/softmax_ref.txt",
                                                         reinterpret_cast<char*>(softmax_ref.data_ptr()),
                                                         softmax_ref.numel() * sizeof(half),
                                                         32,
                                                         true);
    std::cout << "softmax_ref: " << softmax_ref << std::endl;

    /* ------------------------------------------- Value Projection ------------------------------------------- */
    std::cout << "========================================" << std::endl;
    std::cout << "============Value Projection============" << std::endl;
    std::cout << "========================================" << std::endl;
    
    auto weight_value = randn<half>({d_model / n_group_size, d_model / k_group_size, n_group_size, k_group_size}, kHalf, -0.1f, 0.1f, 300);
    auto value_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

    gemm_sim_t::Arguments args_value_sim = {value_temp, input, weight_value, tile_m, block_n_group, block_k_group};
    gemm_sim_op(args_value_sim);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/weight_value.txt",
                                                         reinterpret_cast<char*>(weight_value.data_ptr()),
                                                         weight_value.numel() * sizeof(half),
                                                         32,
                                                         true);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/value_temp.txt",
                                                         reinterpret_cast<char*>(value_temp.data_ptr()),
                                                         value_temp.numel() * sizeof(float),
                                                         128,
                                                         true);

    auto value_transform = ValueTransform(value_temp, head_num, d_model);
    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/value_temp_hf_transform.txt",
                                                         reinterpret_cast<char*>(value_transform.data_ptr()),
                                                         value_transform.numel() * sizeof(half),
                                                         32,
                                                         true);
    std::cout << "value_transform: " << value_transform << std::endl;
    
    /* --------------------------------------------- Probe x Value -------------------------------------------- */
    std::cout << "========================================" << std::endl;
    std::cout << "============Probe x Value============" << std::endl;
    std::cout << "========================================" << std::endl;

    auto output_temp = zeros<half>({d_model / k_group_size, seq_len, k_group_size}, kHalf);

    for (int head = 0; head < head_num; head++) {
      auto probe_head = ProbeSlice(softmax_ref, head_num, head, d_model, seq_len);
      auto value_head = ValueSlice(value_transform, head_num, head, d_model, seq_len);

      auto probe_file = "../../sim/memory_transformer/probe_head" + std::to_string(head) + ".txt";
      auto value_file = "../../sim/memory_transformer/value_head" + std::to_string(head) + ".txt";
      common::file_utils::saveCharArrayToFormattedTextFile(
        probe_file.c_str(), reinterpret_cast<char*>(probe_head.data_ptr()), probe_head.numel() * sizeof(half), 32, true);

      common::file_utils::saveCharArrayToFormattedTextFile(
        value_file.c_str(), reinterpret_cast<char*>(value_head.data_ptr()), value_head.numel() * sizeof(half), 32, true);

      auto output_head = zeros<float>({d_h / n_group_size, seq_len, n_group_size}, kFloat32);

      gemm_sim_dbg_t::Arguments args_output_sim = {output_head, probe_head, value_head, tile_m, block_n_group, block_k_group};
      gemm_sim_op_dbg(args_output_sim);

      common::file_utils::saveCharArrayToFormattedTextFile(
        ("../../sim/memory_transformer/output_head" + std::to_string(head) + ".txt").c_str(),
        reinterpret_cast<char*>(output_head.data_ptr()),
        output_head.numel() * sizeof(float),
        32,
        true);

      auto output_head_hf         = ToFloat16(output_head);
      auto output_head_hf_convert = ParallelismConvertion32to16(output_head_hf);

      auto output_file = "../../sim/memory_transformer/output_head_hf_transform" + std::to_string(head) + ".txt";

      common::file_utils::saveCharArrayToFormattedTextFile(output_file.c_str(),
                                                           reinterpret_cast<char*>(output_head_hf_convert.data_ptr()),
                                                           output_head_hf_convert.numel() * sizeof(half),
                                                           32,
                                                           true);
      OutputConcat(output_temp, output_head_hf_convert, head_num, head, d_model, seq_len);
    }

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/output_temp.txt",
                                                         reinterpret_cast<char*>(output_temp.data_ptr()),
                                                         output_temp.numel() * sizeof(half),
                                                         32,
                                                         true);

    /* ------------------------------------------- Output Projection ------------------------------------------ */
    std::cout << "========================================" << std::endl;
    std::cout << "============Output Projection============" << std::endl;
    std::cout << "========================================" << std::endl;

    auto weight_output = randn<half>({d_model / n_group_size, d_model / k_group_size, n_group_size, k_group_size}, kHalf, -0.1f, 0.1f, 400);
    auto output        = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

    gemm_sim_t::Arguments args_output_sim = {output, output_temp, weight_output, tile_m, block_n_group, block_k_group};
    gemm_sim_op(args_output_sim);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/weight_output.txt",
                                                         reinterpret_cast<char*>(weight_output.data_ptr()),
                                                         weight_output.numel() * sizeof(half),
                                                         32,
                                                         true);

    common::file_utils::saveCharArrayToFormattedTextFile(
      "../../sim/memory_transformer/output.txt", reinterpret_cast<char*>(output.data_ptr()), output.numel() * sizeof(float), 32, true);

    auto output_hf = ToFloat16(output);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/output_hf.txt",
                                                         reinterpret_cast<char*>(output_hf.data_ptr()),
                                                         output_hf.numel() * sizeof(half),
                                                         32,
                                                         true);

    auto output_hf_convert = ParallelismConvertion32to16(output_hf);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/output_hf_convert.txt",
                                                         reinterpret_cast<char*>(output_hf_convert.data_ptr()),
                                                         output_hf_convert.numel() * sizeof(half),
                                                         32,
                                                         true);
  }
  write_regs(reg_cfg_file.c_str(),
             0,
             insn_series.size() * sizeof(common::insn::instruction) / 32,
             32,
             0,
             BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             PSUM_LOAD_1024,
             PSUM_STORE_1024,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}