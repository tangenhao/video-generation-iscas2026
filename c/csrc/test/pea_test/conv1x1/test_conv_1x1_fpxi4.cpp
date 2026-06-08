#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/conv/conv2d.h"
#include "pea/pea_insn.h"
#include <vector>

int main(int argc, const char** argv)
{
  int h              = 4;
  int w              = 4;
  int kh             = 1;
  int kw             = 1;
  int pad_h          = 0;
  int pad_w          = 0;
  int stride_h       = 1;
  int stride_w       = 1;
  int ic_group       = 8;
  int oc_group       = 8;
  int dilation_h     = 1;
  int dilation_w     = 1;
  int ifmap_block_h  = 4;
  int ifmap_block_w  = 4;
  int ic_group_size  = 16;
  int oc_group_size  = 32;
  int block_ic_group = 2;
  int block_oc_group = 2;

  using conv2d_t           = pea::Conv2dOp<0, 0, 0, 0, kHalf, kInt4, kFloat32, kFloat32, true>;
  conv2d_t::Arguments args = {h,
                              w,
                              kh,
                              kw,
                              ic_group_size * ic_group,
                              oc_group_size * oc_group,
                              stride_h,
                              stride_w,
                              pad_h,
                              pad_w,
                              dilation_h,
                              dilation_w,
                              ifmap_block_h,
                              ifmap_block_w,
                              kh,
                              kw,
                              block_ic_group,
                              block_oc_group,
                              IFMAP_ADDR,
                              WEIGHT_ADDR,
                              OFMAP_ADDR};
  conv2d_t            conv2d_op;
  auto                insn_series = conv2d_op(args);
  common::insn::pad_serial_sync_word(insn_series);
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  using namespace compute_model::common::fp16;
  using namespace compute_model::common::subbyte;

  int32_t ofmap_h = (int32_t)floor((double)(h + 2 * pad_h - (kh - 1) - 1) / double(stride_h) + 1);
  int32_t ofmap_w = (int32_t)floor((double)(w + 2 * pad_w - (kw - 1) - 1) / double(stride_w) + 1);

  using namespace compute_model::tensor;

  auto ifmap  = randn<half>({ic_group, h, w, ic_group_size}, kHalf, -1.0f, 1.0f, 0);
  auto weight = randn<int4_t>({oc_group, ic_group / 4, kh, kw, oc_group_size, ic_group_size * 4}, kHalf, -8.0f, 7.0f, 100);
  auto ofmap  = zeros<float>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);

  using conv2d_sim_t                  = compute_model::conv2d::Conv2dSim<0, false, false, false, half, int4_t, float, float, true>;
  conv2d_sim_t::Arguments conv2d_args = {
    ofmap, ifmap, weight, stride_h, stride_w, pad_h, pad_w, dilation_h, dilation_w, ifmap_block_h, ifmap_block_w, kh, kw, 1, 1};

  conv2d_sim_t conv2d_sim_op;
  conv2d_sim_op(conv2d_args);

  common::file_utils::saveCharArrayToFormattedTextFile(ifmap_file.c_str(), (char*)ifmap.data_ptr(), ifmap.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    weight_file.c_str(), reinterpret_cast<char*>(weight.data_ptr()), weight.numel() * sizeof(int4_t), 64, true, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(ofmap.data_ptr()), ofmap.numel() * sizeof(float), 32, true);

  write_regs(reg_cfg_file.c_str(),
             0,
             insn_series.size() * sizeof(common::insn::instruction) / 32,
             32,
             0,
             NO_BROADCAST,
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