#pragma once

#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include <cmath> 

namespace compute_model {
namespace transformer {
namespace softmax {

using namespace compute_model::tensor;
using namespace compute_model::function;

template<typename T, bool DEBUG = false>
void apply_softmax(
    Tensor<T>& input,
    Tensor<T>& output)
{
    int oc_group = input.shape()[0];
    int seq_len = input.shape()[1];
    int oc_group_size = input.shape()[2];

    if (DEBUG) {
        std::cout << "======== Softmax Parameters ========" << std::endl;
        std::cout << "Input shape: (" << oc_group << ", " << seq_len << ", " << oc_group_size << ")" << std::endl;
    }

    auto data_exp = input * (std::log2(exp(1.0f)));
    data_exp = compute_model::function::exp2(data_exp);

    Tensor<T> data_sum({seq_len, oc_group_size}, kFloat32);
    for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
        Tensor<T> sub_tensor({seq_len, oc_group_size}, kFloat32);
        for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
            for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
                sub_tensor[seq_len_iter * oc_group_size + oc_inner_iter] =
                data_exp[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter];
            }
        }

        auto data_sum_temp = compute_model::function::reduce_sum(sub_tensor, 32, DEBUG);
        data_sum = data_sum + data_sum_temp;
    }

    auto sum_rec = compute_model::function::reciprocal(data_sum);

    for (int oc_iter = 0; oc_iter < oc_group; oc_iter++) {
        for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
            for (int oc_inner_iter = 0; oc_inner_iter < oc_group_size; oc_inner_iter++) {
                output[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter] =
                data_exp[oc_iter * seq_len * oc_group_size + seq_len_iter * oc_group_size + oc_inner_iter]
                * sum_rec[seq_len_iter * oc_group_size + oc_inner_iter];
            }
        }
    }
}

template<typename T, bool DEBUG = false>
Tensor<T> compute_softmax(
    Tensor<T>& input)
{
    Tensor<T> output_tensor(input.shape(), input.dtype);
    apply_softmax<T, DEBUG>(input, output_tensor);
    return output_tensor;
}

}  // namespace softmax
}  // namespace transformer
}  // namespace compute_model
