#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/conv/conv2d.h"
#include "compute_model/sparse/sparse.h"
#include "pea/pea_insn.h"
#include "write_reg.h"
#include <vector>

int main(int argc, const char** argv)
{
  int h             = 6;
  int w             = 6;
  int kh            = 3;
  int kw            = 3;
  int pad_h         = 1;
  int pad_w         = 1;
  int stride_h      = 1;
  int stride_w      = 1;
  int ic_group      = 8;
  int oc_group      = 1;
  int dilation_h    = 1;
  int dilation_w    = 1;
  int ifmap_block_h = 6;
  int ifmap_block_w = 6;
  int ic_group_size = 32;
  int oc_group_size = 32;

  const int SPARSE_ENABLE = 1;

  int sparse_ratio = 2;

  using conv2d_t           = pea::Conv2dOp<SPARSE_ENABLE, 0, 0, 0, kInt8, kInt4, kInt32, kInt32, true>;
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
                              1,
                              1,
                              IFMAP_ADDR,
                              WEIGHT_ADDR,
                              OFMAP_ADDR,
                              0,
                              0,
                              0,
                              IFMAPMASK_ADDR};
  conv2d_t            conv2d_op;
  auto                insn_series = conv2d_op(args);
  common::insn::pad_serial_sync_word(insn_series);
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  using namespace compute_model::common::fp16;
  using namespace compute_model::common::bf16;
  using namespace compute_model::common::subbyte;

  int32_t ofmap_h = (int32_t)floor((double)(h + 2 * pad_h - (kh - 1) - 1) / double(stride_h) + 1);
  int32_t ofmap_w = (int32_t)floor((double)(w + 2 * pad_w - (kw - 1) - 1) / double(stride_w) + 1);

  using namespace compute_model::tensor;
  using namespace compute_model::sparse;

  auto ifmap        = randn<int8_t>({ic_group, h, w, ic_group_size}, kHalf, -128.0f, 127.0f, 0);
  auto weight_dense = randn<int4_t>({oc_group, ic_group / 2, kh, kw, oc_group_size, ic_group_size * 2}, kHalf, -8.0f, 7.0f, 100);
  auto ifmap_mask   = GenIfmapMask(oc_group, ic_group / 2, kh, kw, oc_group_size, ic_group_size * 2, SPARSE_ENABLE, 0);
  auto ofmap        = zeros<int32_t>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);

  // auto ifmap_mask_int32 = zeros<int32_t>({oc_group, ic_group / 2, kh, kw, oc_group_size, ic_group_size * 2}, kInt32);
  // for (int i = 0; i < ifmap_mask.numel(); i++) {
  //   ifmap_mask_int32[i] = ifmap_mask[i];
  // }
  // std::cout << ifmap_mask_int32 << std::endl;

  // std::cout << weight_dense << std::endl;

  auto weight_sparse          = weightetZero(weight_dense, ifmap_mask, sparse_ratio);
  auto weight_sparse_compress = WeightProcess(weight_dense, ifmap_mask, sparse_ratio);
  auto ifmap_transform        = TransformIfmap(ifmap, sparse_ratio);
  auto ifmap_mask_transform   = IfmapMaskProcess(ifmap_mask, sparse_ratio);

  // std::cout << weight_sparse << std::endl;
  // std::cout << weight_sparse_compress << std::endl;
  // std::cout << ifmap_transform << std::endl;
  // auto ifmap_mask_transform_int32 = zeros<int32_t>(
  //   {oc_group, ic_group / sparse_ratio / 2, kh, kw, oc_group_size, ic_group_size * sparse_ratio * 2}, kInt32);
  // for (int i = 0; i < ifmap_mask_transform.numel(); i++) {
  //   ifmap_mask_transform_int32[i] = ifmap_mask_transform[i];
  // }
  // std::cout << ifmap_mask_transform_int32 << std::endl;

  using conv2d_sim_t = compute_model::conv2d::Conv2dSim<SPARSE_ENABLE, 0, false, false, int8_t, int4_t, int32_t, int32_t, true>;
  conv2d_sim_t::Arguments conv2d_args = {ofmap,
                                         ifmap_transform,
                                         weight_sparse_compress,
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
                                         1,
                                         1,
                                         ifmap_mask_transform};

  conv2d_sim_t conv2d_sim_op;
  conv2d_sim_op(conv2d_args);

  common::file_utils::saveCharArrayToFormattedTextFile(ifmap_file.c_str(), (char*)ifmap.data_ptr(), ifmap.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(weight_file.c_str(),
                                                       reinterpret_cast<char*>(weight_sparse_compress.data_ptr()),
                                                       weight_sparse_compress.numel() * sizeof(int4_t),
                                                       64,
                                                       true,
                                                       true);

  auto ifmap_mask_compress =
    zeros<int8_t>({oc_group, (ic_group / sparse_ratio), kh, kw, oc_group_size * (ic_group_size / 8) * sparse_ratio}, kInt8);
  for (int i = 0; i < ifmap_mask.numel() / 8; i++) {
    int8_t mask = 0;
    for (int j = 0; j < 8; j++) {
      mask |= ifmap_mask_transform[i * 8 + j] << j;
    }
    ifmap_mask_compress[i] = mask;
  }

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ifmap_mask.txt",
                                                       reinterpret_cast<char*>(ifmap_mask_compress.data_ptr()),
                                                       ifmap_mask_compress.numel() * sizeof(int8_t),
                                                       32,
                                                       true);

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
             IFMAP_MASK_LOAD_128,
             1);

  return 0;
}