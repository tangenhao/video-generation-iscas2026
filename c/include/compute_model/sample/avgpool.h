#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/subbyte.h"
#include "compute_model/common/tensor.h"
#include "compute_model/mpt/mpt.h"
#include <typeinfo>

namespace compute_model {
namespace sample {

template<typename TYPE_IN, typename TYPE_OUT, bool DEBUG_>
struct Avgpool2dSim {
  static constexpr bool DEBUG = DEBUG_;

  int ic_group_size;

  struct Arguments {
    tensor::Tensor<TYPE_OUT>& output;
    tensor::Tensor<TYPE_IN>&  input;
    std::vector<int>          kernel_size;
    std::vector<int>          stride;
    std::vector<int>          pad;
    std::vector<int>          dilation;
  };

  Avgpool2dSim()
  {
    if (typeid(TYPE_IN) == typeid(common::subbyte::int4_t) || typeid(TYPE_IN) == typeid(int8_t) || typeid(TYPE_IN) == typeid(int16_t)) {
      std::runtime_error("Maxpool2dSim: TYPE_IN should be float16 or float32 or bfloat16");
    }

    if (typeid(TYPE_OUT) == typeid(common::subbyte::int4_t) || typeid(TYPE_OUT) == typeid(int8_t) || typeid(TYPE_OUT) == typeid(int16_t)) {
      std::runtime_error("Maxpool2dSim: TYPE_OUT should be float16 or float32 or bfloat16");
    }

    ic_group_size = 32;
  }

  void operator()(Arguments args)
  {
    int32_t ifmap_h    = args.input.shape()[1];
    int32_t ifmap_w    = args.input.shape()[2];
    int32_t ic_group   = args.input.shape()[0];
    int32_t weight_h   = args.kernel_size[0];
    int32_t weight_w   = args.kernel_size[1];
    int32_t stride_h   = args.stride[0];
    int32_t stride_w   = args.stride[1];
    int32_t pad_h      = args.pad[0];
    int32_t pad_w      = args.pad[1];
    int32_t dilation_h = args.dilation[0];
    int32_t dilation_w = args.dilation[1];

    if (DEBUG) {
      std::cout << "ifmap_h: " << ifmap_h << std::endl;
      std::cout << "ifmap_w: " << ifmap_w << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "weight_h: " << weight_h << std::endl;
      std::cout << "weight_w: " << weight_w << std::endl;
      std::cout << "stride_h: " << stride_h << std::endl;
      std::cout << "stride_w: " << stride_w << std::endl;
      std::cout << "pad_h: " << pad_h << std::endl;
      std::cout << "pad_w: " << pad_w << std::endl;
      std::cout << "dilation_h: " << dilation_h << std::endl;
      std::cout << "dilation_w: " << dilation_w << std::endl;
    }

    int32_t ofmap_h = (int32_t)floor((double)(ifmap_h + 2 * pad_h - (weight_h - 1) - 1) / double(stride_h) + 1);
    int32_t ofmap_w = (int32_t)floor((double)(ifmap_w + 2 * pad_w - (weight_w - 1) - 1) / double(stride_w) + 1);

    int32_t ifmap_h_idx, ifmap_w_idx, ifmap_idx_start, ofmap_idx;

    float accum[ic_group_size] = {0};

    for (int h_iter = 0; h_iter < ofmap_h; ++h_iter) {
      for (int w_iter = 0; w_iter < ofmap_w; ++w_iter) {
        for (int ic_iter = 0; ic_iter < ic_group; ++ic_iter) {
          for (int i = 0; i < ic_group_size; ++i) {
            accum[i] = 0;
          }
          ofmap_idx = w_iter * ic_group_size + h_iter * ofmap_w * ic_group_size + ofmap_w * ofmap_h * ic_iter * ic_group_size;
          for (int kh_iter = 0; kh_iter < weight_h; ++kh_iter) {
            for (int kw_iter = 0; kw_iter < weight_w; ++kw_iter) {
              if (h_iter * stride_h + kh_iter - pad_h >= 0 && w_iter * stride_w + kw_iter - pad_w >= 0
                  && h_iter * stride_h + kh_iter - pad_h < ifmap_h && w_iter * stride_w + kw_iter - pad_w < ifmap_w) {
                ifmap_h_idx     = std::max(h_iter * stride_h + kh_iter - pad_h, 0);
                ifmap_w_idx     = std::max(w_iter * stride_w + kw_iter - pad_w, 0);
                ifmap_idx_start = (ifmap_w_idx + ifmap_h_idx * ifmap_w + ic_iter * ifmap_w * ifmap_h) * ic_group_size;

                if (DEBUG) {
                  std::cout << "h_iter: " << h_iter << " w_iter: " << w_iter << " ic_iter: " << ic_iter << " kh_iter: " << kh_iter
                            << " kw_iter: " << kw_iter << "\n";
                  std::cout << "ifmap_h_idx: " << ifmap_h_idx << std::endl;
                  std::cout << "ifmap_w_idx: " << ifmap_w_idx << std::endl;

                  for (int i = 0; i < ic_group_size; ++i) {
                    float val = (float)args.input[ifmap_idx_start + i];
                    std::cout << std::hex << (*(uint32_t*)(&val)) << " ";
                  }
                  std::cout << std::endl;
                }

                for (int i = 0; i < ic_group_size; ++i) {
                  accum[i] = accum[i] + (float)args.input[ifmap_idx_start + i];
                  std::cout << std::hex << (*(uint32_t*)(&accum[i])) << " ";
                }
                std::cout << std::endl;
              }
            }
          }
          for (int i = 0; i < ic_group_size; ++i) {
            args.output[ofmap_idx + i] = accum[i];
          }
        }
      }
    }
  }
};

}  // namespace sample
}  // namespace compute_model