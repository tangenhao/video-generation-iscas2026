#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/subbyte.h"
#include "compute_model/common/tensor.h"
#include <typeinfo>

namespace compute_model {
namespace sample {

template<typename TYPE_IN, typename TYPE_OUT, bool DEBUG_>
struct UpsampleSim {
  static constexpr bool DEBUG = DEBUG_;

  int ic_group_size;

  struct Arguments {
    tensor::Tensor<TYPE_OUT>& output;
    tensor::Tensor<TYPE_IN>&  input;
    std::vector<int>          scale_factor;
  };

  UpsampleSim()
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
    int32_t ifmap_h      = args.input.shape()[1];
    int32_t ifmap_w      = args.input.shape()[2];
    int32_t ic_group     = args.input.shape()[0];
    int32_t scale_width  = args.scale_factor[1];
    int32_t scale_height = args.scale_factor[0];

    if (DEBUG) {
      std::cout << "ifmap_h: " << ifmap_h << std::endl;
      std::cout << "ifmap_w: " << ifmap_w << std::endl;
      std::cout << "ic_group: " << ic_group << std::endl;
      std::cout << "scale_width: " << scale_width << std::endl;
      std::cout << "scale_height: " << scale_height << std::endl;
    }

    int32_t ofmap_h = ifmap_h * scale_height;
    int32_t ofmap_w = ifmap_w * scale_width;

    int32_t ofmap_h_idx, ofmap_w_idx, ofmap_idx_start, ifmap_idx;

    for (int h_iter = 0; h_iter < ifmap_h; ++h_iter) {
      for (int w_iter = 0; w_iter < ifmap_w; ++w_iter) {
        for (int ic_iter = 0; ic_iter < ic_group; ++ic_iter) {
          ifmap_idx = w_iter * ic_group_size + h_iter * ifmap_w * ic_group_size + ic_iter * ifmap_w * ifmap_h * ic_group_size;

          for (int scale_height_i = 0; scale_height_i < scale_height; ++scale_height_i) {
            for (int scale_width_i = 0; scale_width_i < scale_width; ++scale_width_i) {
              ofmap_h_idx = h_iter * scale_height + scale_height_i;
              ofmap_w_idx = w_iter * scale_width + scale_width_i;
              ofmap_idx_start =
                ofmap_w_idx * ic_group_size + ofmap_h_idx * ofmap_w * ic_group_size + ic_iter * ofmap_w * ofmap_h * ic_group_size;

              // for (int i = 0; i < ic_group_size; ++i) {
              //   std::cout << std::hex << (*(uint32_t*)(&args.input[ifmap_idx_start + i])) << " ";
              // }
              // std::cout << std::endl;
              for (int i = 0; i < ic_group_size; ++i) {
                args.output[ofmap_idx_start + i] = args.input[ifmap_idx + i];
              }
            }
          }
        }
      }
    }
  }
};

}  // namespace sample
}  // namespace compute_model