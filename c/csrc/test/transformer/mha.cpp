#include "addr_for_transformer.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/gemm/gemm.h"
#include "instruction/parser.h"
#include "transformer/mha_multi_core.h"

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
  int n_groups     = value.shape(0);

  auto value_split = zeros<float>({n_groups, seq_len / n_group_size, n_group_size, n_group_size}, kFloat32);
  for (int n_iter = 0; n_iter < n_groups; n_iter++) {
    for (int k_iter = 0; k_iter < seq_len / n_group_size; k_iter++) {
      for (int n = 0; n < n_group_size; n++) {
        for (int k = 0; k < n_group_size; k++) {
          int out_idx          = n_iter * seq_len * n_group_size + k_iter * n_group_size * n_group_size + n * n_group_size + k;
          int in_idx           = n_iter * seq_len * n_group_size + k_iter * n_group_size * n_group_size + n * n_group_size + k;
          value_split[out_idx] = value[in_idx];
        }
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/value_split.txt",
                                                       reinterpret_cast<char*>(value_split.data_ptr()),
                                                       value_split.numel() * sizeof(float),
                                                       128,
                                                       true);

  auto value_transpose = zeros<half>({n_groups, seq_len / n_group_size, n_group_size, n_group_size}, kFloat32);
  for (int n_iter = 0; n_iter < n_groups; n_iter++) {
    for (int k_iter = 0; k_iter < seq_len / n_group_size; k_iter++) {
      for (int n = 0; n < n_group_size; n++) {
        for (int k = 0; k < n_group_size; k++) {
          int out_idx = n_iter * seq_len * n_group_size + k_iter * n_group_size * n_group_size + k * n_group_size + n;
          int in_idx  = n_iter * seq_len * n_group_size + k_iter * n_group_size * n_group_size + n * n_group_size + k;

          value_transpose[out_idx] = (half)value_split[in_idx];
        }
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/value_transpose.txt",
                                                       reinterpret_cast<char*>(value_transpose.data_ptr()),
                                                       value_transpose.numel() * sizeof(half),
                                                       64,
                                                       true);

  auto output_fp = zeros<half>({num_head, d_h / n_group_size, seq_len / n_group_size, n_group_size, n_group_size}, kFloat32);
  for (int head = 0; head < num_head; head++) {
    for (int n_iter = 0; n_iter < d_h / n_group_size; n_iter++) {
      for (int k_iter = 0; k_iter < seq_len / n_group_size; k_iter++) {
        for (int n = 0; n < n_group_size; n++) {
          for (int k = 0; k < n_group_size; k++) {
            int out_idx =
              head * d_h * seq_len + n_iter * seq_len * n_group_size + k_iter * n_group_size * n_group_size + n * n_group_size + k;
            int in_idx = (head * num_head + n_iter) * seq_len * n_group_size + k_iter * n_group_size * n_group_size + n * n_group_size + k;
            output_fp[out_idx] = value_transpose[in_idx];
          }
        }
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/value_transpose_split_head.txt",
                                                       reinterpret_cast<char*>(value_transpose.data_ptr()),
                                                       value_transpose.numel() * sizeof(half),
                                                       64,
                                                       true);

  auto output_hf = zeros<half>({num_head, d_h / n_group_size, seq_len / k_group_size, n_group_size, k_group_size}, kHalf);
  for (int head = 0; head < num_head; head++) {
    for (int n_iter = 0; n_iter < d_h / n_group_size; n_iter++) {
      for (int k_iter = 0; k_iter < seq_len / n_group_size; k_iter++) {
        for (int n = 0; n < n_group_size; n++) {
          for (int k = 0; k < n_group_size; k++) {
            int out_idx = 0;
            int in_idx =
              head * d_h * seq_len + n_iter * seq_len * n_group_size + k_iter * n_group_size * n_group_size + n * n_group_size + k;

            if (k < n_group_size / 2) {
              out_idx =
                head * d_h * seq_len + n_iter * seq_len * n_group_size + 2 * k_iter * n_group_size * k_group_size + n * k_group_size + k;
            }
            else {
              out_idx = head * d_h * seq_len + n_iter * seq_len * n_group_size + (2 * k_iter + 1) * n_group_size * k_group_size
                        + n * k_group_size + k - k_group_size;
            }

            if (out_idx == 31 * 16 || out_idx == 79 * 16) {
              std::cout << "out_idx: " << out_idx << " in_idx: " << in_idx << std::endl;
              std::cout << "head: " << head << " n_iter: " << n_iter << " k_iter: " << k_iter << " n: " << n << " k: " << k << std::endl;
            }

            output_hf[out_idx] = output_fp[in_idx];
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

int main()
{
  int head_num     = 2;
  int seq_len      = 128;
  int d_model      = 128;
  int d_h          = d_model / head_num;
  int k_group_size = 16;
  int n_group_size = 32;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                               Instructions                                               */
  /* -------------------------------------------------------------------------------------------------------- */
  using config_t = transformer::mha::ConfigMHA<true>;
  config_t config_op;
  config_t::Argument cfg_args = {d_model, d_h};
  auto     pack        = config_op(cfg_args);
  auto     insn_series = pack.first;
  auto     opcode      = pack.second;

  // auto parser = common::insn::instruction_parser(insn_series);
  // parser.parse_instruction();
  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/insn.txt",
                                                       reinterpret_cast<char*>(insn_series.data()),
                                                       insn_series.size() * sizeof(common::insn::instruction),
                                                       32,
                                                       true);

  auto   num_vcucodes      = opcode.size();
  size_t vcucode_bytes     = opcode.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  opcode.resize(vcucode_ddr_lines * 4, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_transformer/vcucode.txt", reinterpret_cast<char*>(opcode.data()), opcode.size() * sizeof(uint64_t), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 Reference                                                */
  /* -------------------------------------------------------------------------------------------------------- */

  if (update_reference) {
    using gemm_sim_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, false>;
    gemm_sim_t gemm_sim_op;

    using gemm_sim_dbg_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, true>;
    gemm_sim_dbg_t gemm_sim_op_dbg;

    /* ------------------------------------------- Query Projection ------------------------------------------- */
    auto input        = randn<half>({d_model / k_group_size, seq_len, k_group_size}, kHalf, 0.0f, 0.1f, 0);
    auto weight_query = randn<half>({d_model / n_group_size, d_model / k_group_size, n_group_size, k_group_size}, kHalf, 0.0f, 0.1f, 100);
    auto query_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

    gemm_sim_t::Arguments args_query_sim = {query_temp, input, weight_query, seq_len, 4, 4};
    gemm_sim_op(args_query_sim);

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

    auto query_temp_fp = ToFloat16(query_temp);
    query_temp_fp      = ParallelismConvertion32to16(query_temp_fp);

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/query_temp_hf.txt",
                                                         reinterpret_cast<char*>(query_temp_fp.data_ptr()),
                                                         query_temp_fp.numel() * sizeof(half),
                                                         32,
                                                         true);

    /* ------------------------------------------- Key Projection ------------------------------------------- */
    auto weight_key = randn<half>({d_model / n_group_size, d_model / k_group_size, n_group_size, k_group_size}, kHalf, 0.0f, 0.1f, 200);
    auto key_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

    gemm_sim_t::Arguments args_key_sim = {key_temp, input, weight_key, 32, 1, 1};
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

    auto key_temp_fp = ToFloat16(key_temp);
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
    auto score_temp = zeros<float>({head_num, seq_len / n_group_size, seq_len, n_group_size}, kFloat32);

    for (int head = 0; head < head_num; head++) {
      auto query_head = QuerySlice(query_temp_fp, head_num, head, d_model, seq_len);
      auto key_head   = KeySlice(key_temp_ref, head_num, head, d_model, seq_len);

      auto query_file = "../../sim/memory_transformer/query_head" + std::to_string(head) + ".txt";
      auto key_file   = "../../sim/memory_transformer/key_head" + std::to_string(head) + ".txt";
      common::file_utils::saveCharArrayToFormattedTextFile(
        query_file.c_str(), reinterpret_cast<char*>(query_head.data_ptr()), query_head.numel() * sizeof(half), 32, true);

      common::file_utils::saveCharArrayToFormattedTextFile(
        key_file.c_str(), reinterpret_cast<char*>(key_head.data_ptr()), key_head.numel() * sizeof(half), 32, true);

      auto score_head = zeros<float>({seq_len / n_group_size, seq_len, n_group_size, k_group_size}, kFloat32);

      gemm_sim_t::Arguments args_score_sim = {score_head, query_head, key_head, seq_len, 4, 4};
      gemm_sim_op(args_score_sim);

      score_head = score_head * 0.125;

      ScoreConcat(score_temp, score_head, head_num, head, d_model, seq_len);
    }

    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/score_temp.txt",
                                                         reinterpret_cast<char*>(score_temp.data_ptr()),
                                                         score_temp.numel() * sizeof(float),
                                                         32,
                                                         true);

    /* ------------------------------------------------ softmax ----------------------------------------------- */
    auto softmax_ref = Softmax(score_temp);
    common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory_transformer/softmax_ref.txt",
                                                         reinterpret_cast<char*>(softmax_ref.data_ptr()),
                                                         softmax_ref.numel() * sizeof(half),
                                                         32,
                                                         true);

    /* ------------------------------------------- Value Projection ------------------------------------------- */
    auto weight_value = randn<half>({d_model / n_group_size, d_model / k_group_size, n_group_size, k_group_size}, kHalf, -1.0f, 1.0f, 300);
    auto value_temp   = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

    gemm_sim_t::Arguments args_value_sim = {value_temp, input, weight_value, 32, 1, 1};
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

    /* --------------------------------------------- Probe x Value -------------------------------------------- */
    auto output_temp = zeros<half>({d_model / k_group_size, seq_len, k_group_size}, kFloat32);

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

      gemm_sim_t::Arguments args_output_sim = {output_head, probe_head, value_head, seq_len, 1, 1};
      gemm_sim_op(args_output_sim);

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
    auto weight_output = randn<half>({d_model / n_group_size, d_model / k_group_size, n_group_size, k_group_size}, kHalf, 0.0f, 0.1f, 400);
    auto output        = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, kFloat32);

    gemm_sim_dbg_t::Arguments args_output_sim = {output, output_temp, weight_output, 32, 1, 1};
    gemm_sim_op_dbg(args_output_sim);

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
