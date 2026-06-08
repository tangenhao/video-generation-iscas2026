#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/func_from_lib.h"

namespace compute_model {
namespace transformer {
namespace mha {

using namespace compute_model::common::fp16;

template<typename T>
tensor::Tensor<T> matMul(const tensor::Tensor<T>& a, const tensor::Tensor<T>& b)
{
  if (a.shape_.size() == 2) {
    int m = a.shape_[0];
    int k = a.shape_[1];
    int n = b.shape_[0];

    tensor::Tensor<T> c({m, n}, a.dtype);

    for (int i = 0; i < m; ++i) {
      for (int j = 0; j < n; ++j) {
        T sum = 0;
        for (int l = 0; l < k; ++l) {
          sum += a[i * k + l] * b[l * n + j];
        }
        c[i * n + j] = sum;
      }
    }

    return c;
  }
  else if (a.shape_.size() == 3) {
    int batch_size = a.shape_[0];
    int m          = a.shape_[1];
    int k          = a.shape_[2];
    int n          = b.shape_[0];

    tensor::Tensor<T> c({batch_size, m, n}, a.dtype);

    for (int batch = 0; batch < batch_size; ++batch) {
      for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
          T sum = 0;
          for (int l = 0; l < k; ++l) {
            sum += a[batch * m * k + i * k + l] * b[l * n + j];
          }
          c[batch * m * n + i * n + j] = sum;
        }
      }
    }

    return c;
  }
  else {
    std::cerr << "matMul: Unsupported shape" << std::endl;
    exit(-1);
  }
  return tensor::Tensor<T>();
}

template<typename T>
tensor::Tensor<T> addBias(const tensor::Tensor<T>& a, const tensor::Tensor<half>& b)
{
  if (a.shape_.size() == 2) {
    int m = a.shape_[0];
    int n = a.shape_[1];

    tensor::Tensor<T> c({m, n}, a.dtype);

    for (int i = 0; i < m; ++i) {
      for (int j = 0; j < n; ++j) {
        c[i * n + j] = a[i * n + j] + static_cast<T>(b[j]);
      }
    }

    return c;
  }
  else if (a.shape_.size() == 3) {
    int batch_size = a.shape_[0];
    int m          = a.shape_[1];
    int n          = a.shape_[2];

    tensor::Tensor<T> c({batch_size, m, n}, a.dtype);

    for (int batch = 0; batch < batch_size; ++batch) {
      for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
          c[batch * m * n + i * n + j] = a[batch * m * n + i * n + j] + static_cast<T>(b[j]);
        }
      }
    }

    return c;
  }
  else {
    std::cerr << "addBias: Unsupported shape" << std::endl;
    exit(-1);
  }
  return tensor::Tensor<T>();
}

template<typename T>
tensor::Tensor<T> splitHead(const tensor::Tensor<T>& a, int num_heads)
{
  if (a.shape_.size() == 3) {
    int batch_size = a.shape_[0];
    int seq_len    = a.shape_[1];
    int d_model    = a.shape_[2];

    int head_size = d_model / num_heads;
    int head_num  = num_heads;

    tensor::Tensor<T> c({batch_size, head_num, seq_len, head_size}, a.dtype);

    for (int batch = 0; batch < batch_size; ++batch) {
      for (int i = 0; i < seq_len; ++i) {
        for (int j = 0; j < d_model; ++j) {
          c[batch * head_num * seq_len * head_size + (j / head_size) * seq_len * head_size + i * head_size + (j % head_size)] =
            a[batch * seq_len * d_model + i * d_model + j];
        }
      }
    }

    return c;
  }
  else {
    std::cerr << "splitHead: Unsupported shape" << std::endl;
    exit(-1);
  }
  return tensor::Tensor<T>();
}

template<typename T>
tensor::Tensor<T> batchMatMul(const tensor::Tensor<T>& a, const tensor::Tensor<T>& b)
{
  if (a.shape_.size() == 3) {
    int batch_size = a.shape_[0];
    int m          = a.shape_[1];
    int k          = a.shape_[2];
    int n          = b.shape_[1];

    tensor::Tensor<T> c({batch_size, m, n}, a.dtype);

    for (int batch = 0; batch < batch_size; ++batch) {
      for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
          T sum = 0;
          for (int l = 0; l < k; ++l) {
            sum += a[batch * m * k + i * k + l] * b[batch * k * n + l * n + j];
          }
          c[batch * m * n + i * n + j] = sum;
        }
      }
    }

    return c;
  }
  else if (a.shape_.size() == 4) {
    int batch_size = a.shape_[0];
    int head       = a.shape_[1];
    int m          = a.shape_[2];
    int k          = a.shape_[3];
    int n          = b.shape_[2];

    tensor::Tensor<T> c({batch_size, head, m, n}, a.dtype);

    for (int batch = 0; batch < batch_size; ++batch) {
      for (int h = 0; h < head; ++h) {
        for (int i = 0; i < m; ++i) {
          for (int j = 0; j < n; ++j) {
            T sum = 0;
            for (int l = 0; l < k; ++l) {
              sum += a[batch * head * m * k + h * m * k + i * k + l] * b[batch * head * k * n + h * k * n + l * n + j];
            }
            c[batch * head * m * n + h * m * n + i * n + j] = sum;
          }
        }
      }
    }

    return c;
  }
  else {
    std::cerr << "batchMatMul: Unsupported shape" << std::endl;
    exit(-1);
  }
  return tensor::Tensor<T>();
}

template<typename T>
tensor::Tensor<T> mergeHead(const tensor::Tensor<T>& a, int num_heads)
{
  if (a.shape_.size() == 4) {
    int batch_size = a.shape_[0];
    int head_num   = a.shape_[1];
    int seq_len    = a.shape_[2];
    int head_size  = a.shape_[3];

    int d_model = head_num * head_size;

    tensor::Tensor<T> c({batch_size, seq_len, d_model}, a.dtype);

    for (int batch = 0; batch < batch_size; ++batch) {
      for (int i = 0; i < seq_len; ++i) {
        for (int j = 0; j < d_model; ++j) {
          c[batch * seq_len * d_model + i * d_model + j] =
            a[batch * head_num * seq_len * head_size + (j / head_size) * seq_len * head_size + i * head_size + (j % head_size)];
        }
      }
    }

    return c;
  }
  else {
    std::cerr << "mergeHead: Unsupported shape" << std::endl;
    exit(-1);
  }
  return tensor::Tensor<T>();
}

template<typename T>
tensor::Tensor<T> SoftMax(const tensor::Tensor<T>& a)
{
  int batch_size = a.shape_[0];
  int seq_len    = a.shape_[1];
  int head_num   = a.shape_[2];
  int head_size  = a.shape_[3];

  tensor::Tensor<T> c(a.shape_, a.dtype);
  tensor::Tensor<T> max_val({batch_size, seq_len, head_num}, a.dtype);
  tensor::Tensor<T> exp_sum({batch_size, seq_len, head_num}, a.dtype);

  /** 1. Calculate max val */
  for (int batch = 0; batch < batch_size; ++batch) {
    for (int i = 0; i < seq_len; ++i) {
      for (int j = 0; j < head_num; ++j) {
        T max = a[batch * seq_len * head_num * head_size + i * head_num * head_size + j * head_size];
        for (int k = 1; k < head_size; ++k) {
          if (a[batch * seq_len * head_num * head_size + i * head_num * head_size + j * head_size + k] > max) {
            max = a[batch * seq_len * head_num * head_size + i * head_num * head_size + j * head_size + k];
          }
        }
        max_val[batch * seq_len * head_num + i * head_num + j] = max;
      }
    }
  }

  /** 2. Calculate exp sum */
  for (int batch = 0; batch < batch_size; ++batch) {
    for (int i = 0; i < seq_len; ++i) {
      for (int j = 0; j < head_num; ++j) {
        T sum = 0;
        for (int k = 0; k < head_size; ++k) {
          sum += std::exp(a[batch * seq_len * head_num * head_size + i * head_num * head_size + j * head_size + k]
                          - max_val[batch * seq_len * head_num + i * head_num + j]);
        }
        exp_sum[batch * seq_len * head_num + i * head_num + j] = sum;
      }
    }
  }

  /** 3. Calculate softmax */
  for (int batch = 0; batch < batch_size; ++batch) {
    for (int i = 0; i < seq_len; ++i) {
      for (int j = 0; j < head_num; ++j) {
        for (int k = 0; k < head_size; ++k) {
          c[batch * seq_len * head_num * head_size + i * head_num * head_size + j * head_size + k] =
            std::exp(a[batch * seq_len * head_num * head_size + i * head_num * head_size + j * head_size + k]
                     - max_val[batch * seq_len * head_num + i * head_num + j])
            / exp_sum[batch * seq_len * head_num + i * head_num + j];
        }
      }
    }
  }

  return c;
}

template<typename T>
tensor::Tensor<T> transpose(const tensor::Tensor<T>& a)
{
  if (a.shape_.size() == 2) {
    int m = a.shape_[0];
    int n = a.shape_[1];

    tensor::Tensor<T> c({n, m}, a.dtype);

    for (int i = 0; i < m; ++i) {
      for (int j = 0; j < n; ++j) {
        c[j * m + i] = a[i * n + j];
      }
    }

    return c;
  }
  else if (a.shape_.size() == 3) {
    int batch_size = a.shape_[0];
    int m          = a.shape_[1];
    int n          = a.shape_[2];

    tensor::Tensor<T> c({batch_size, n, m}, a.dtype);

    for (int batch = 0; batch < batch_size; ++batch) {
      for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
          c[batch * n * m + j * m + i] = a[batch * m * n + i * n + j];
        }
      }
    }

    return c;
  }
  else if (a.shape_.size() == 4) {
    int batch_size = a.shape_[0];
    int num_heads  = a.shape_[1];
    int seq_len    = a.shape_[2];
    int head_size  = a.shape_[3];

    tensor::Tensor<T> c({batch_size, num_heads, head_size, seq_len}, a.dtype);

    for (int batch = 0; batch < batch_size; ++batch) {
      for (int i = 0; i < num_heads; ++i) {
        for (int j = 0; j < seq_len; ++j) {
          for (int k = 0; k < head_size; ++k) {
            c[batch * num_heads * head_size * seq_len + i * head_size * seq_len + k * seq_len + j] =
              a[batch * num_heads * seq_len * head_size + i * seq_len * head_size + j * head_size + k];
          }
        }
      }
    }

    return c;
  }
  else {
    std::cerr << "transpose: Unsupported shape" << std::endl;
    exit(-1);
  }

  return tensor::Tensor<T>();
}

template<typename T>
tensor::Tensor<T> multiHeadAttentionRef(const tensor::Tensor<T>&      query,
                                        const tensor::Tensor<T>&      key,
                                        const tensor::Tensor<T>&      value,
                                        const tensor::Tensor<int8_t>& mask,
                                        const tensor::Tensor<T>&      weight_query,
                                        const tensor::Tensor<T>&      weight_key,
                                        const tensor::Tensor<T>&      weight_value,
                                        const tensor::Tensor<T>&      weight_output,
                                        const tensor::Tensor<half>&   bias_query,
                                        const tensor::Tensor<half>&   bias_key,
                                        const tensor::Tensor<half>&   bias_value,
                                        const tensor::Tensor<half>&   bias_output,
                                        int                           num_heads)
{
  int batch_size = query.shape_[0];
  int seq_len    = query.shape_[1];
  int d_model    = query.shape_[2];

  int head_size = d_model / num_heads;
  int head_num  = num_heads;

  /** 1. Query, Key, Value */
  auto Q = matMul(query, weight_query);
  Q      = addBias(Q, bias_query);

  auto K = matMul(key, weight_key);
  K      = addBias(K, bias_key);

  auto V = matMul(value, weight_value);
  V      = addBias(V, bias_value);

  /** 2. Split head */
  Q = splitHead(Q, num_heads);
  K = splitHead(K, num_heads);
  V = splitHead(V, num_heads);

  /** 3. Attention */
  auto attention_score = batchMatMul(Q, K);
  attention_score      = attention_score / std::sqrt(static_cast<T>(head_size));

  for (int b = 0; b < batch_size; ++b) {
    for (int i = 0; i < seq_len; ++i) {
      for (int j = 0; j < seq_len; ++j) {
        if (mask[b * seq_len * seq_len + i * seq_len + j] == 0) {
          attention_score[b * seq_len * seq_len + i * seq_len + j] = -std::numeric_limits<T>::infinity();
        }
      }
    }
  }

  auto attention_prob = SoftMax(attention_score);
  auto attention      = batchMatMul(attention_prob, transpose(V));

  /** 4. Merge head */
  auto attention_merge = mergeHead(attention, num_heads);

  /** 5. Output */
  auto output = matMul(attention_merge, weight_output);
  output      = addBias(output, bias_output);

  return output;
}

}  // namespace mha
}  // namespace transformer
}  // namespace compute_model