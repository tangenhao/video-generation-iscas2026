#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/bf16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/conv/conv2d.h"
#include "load_config/load_config.h"
#include "pea/pea_insn.h"
#include <vector>

int main(int argc, const char** argv)
{
  int h             = 4;
  int w             = 4;
  int kh            = 1;
  int kw            = 1;
  int pad_h         = 0;
  int pad_w         = 0;
  int stride_h      = 1;
  int stride_w      = 1;
  int ic_group      = 2;
  int oc_group      = 1;
  int dilation_h    = 1;
  int dilation_w    = 1;
  int ifmap_block_h = 2;
  int ifmap_block_w = 2;
  int ic_group_size = 16;
  int oc_group_size = 32;

  using conv2d_t           = pea::Conv2dOp<0, 0, 0, 0, kBfloat16, kBfloat16, kFloat32, kFloat32, false>;
  conv2d_t::Arguments args = {h,
                              w,
                              kh,
                              kw,
                              ic_group * ic_group_size,
                              oc_group * oc_group_size,
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
                              0,
                              0};
  conv2d_t            conv2d_op;
  auto                insn_series = conv2d_op(args);

  std::string file_store_path              = "../../sim/memory/config.txt";
  int64_t     config_file_ddr_base_addr    = CONFIG_ADDR;
  int32_t     ifmap_broadcast              = 0;
  int32_t     ifmap_scale_broadcast        = 0;
  int32_t     weight_broadcast             = 0;
  int32_t     weight_scale_broadcast       = 0;
  int32_t     outlier_index_broadcast      = 0;
  int32_t     vcupara_broadcast            = 0;
  int32_t     vcures_broadcast             = 0;
  int32_t     vcucode_broadcast            = 0;
  int32_t     vculut_broadcast             = 0;
  int32_t     psum_load_valid_bits         = 0;
  int32_t     psum_store_valid_bits        = 0;
  int32_t     vcures_load_valid_bits       = 0;
  int32_t     ifmap_mask_load_valid_bits   = 0;
  int32_t     enable_prof_counter          = 0;
  int32_t     ifmap_broadcast_mask         = 0;
  int32_t     ifmap_scale_broadcast_mask   = 0;
  int32_t     weight_broadcast_mask        = 0;
  int32_t     weight_scale_broadcast_mask  = 0;
  int32_t     outlier_index_broadcast_mask = 0;
  int32_t     vcupara_broadcast_mask       = 0;
  int32_t     vcures_broadcast_mask        = 0;
  int32_t     vcucode_broadcast_mask       = 0;
  int32_t     vculut_broadcast_mask        = 0;

  using config_t                  = load_config::LoadConfigOp<true>;
  config_t::Arguments config_args = {
    file_store_path,
    config_file_ddr_base_addr,
    ifmap_broadcast,
    ifmap_scale_broadcast,
    weight_broadcast,
    weight_scale_broadcast,
    outlier_index_broadcast,
    vcupara_broadcast,
    vcures_broadcast,
    vcucode_broadcast,
    vculut_broadcast,
    psum_load_valid_bits,
    psum_store_valid_bits,
    vcures_load_valid_bits,
    ifmap_mask_load_valid_bits,
    enable_prof_counter,
    ifmap_broadcast_mask,
    ifmap_scale_broadcast_mask,
    weight_broadcast_mask,
    weight_scale_broadcast_mask,
    outlier_index_broadcast_mask,
    vcupara_broadcast_mask,
    vcures_broadcast_mask,
    vcucode_broadcast_mask,
    vculut_broadcast_mask,
  };
  config_t config_op;
  auto     config_insn = config_op(config_args);
  insn_series.insert(insn_series.end(), config_insn.begin(), config_insn.end());

  args                 = {h,
          w,
          kh,
          kw,
          ic_group * ic_group_size,
          oc_group * oc_group_size,
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
          0,
          1};
  auto new_insn_series = conv2d_op(args);
  insn_series.insert(insn_series.end(), new_insn_series.begin(), new_insn_series.end());

  common::insn::pad_serial_sync_word(insn_series);
  // for (auto& insn : insn_series) {
  //   std::cout << insn.to_string() << std::endl;
  // }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  using namespace compute_model::common::bf16;

  int32_t ofmap_h = (int32_t)floor((double)(h + 2 * pad_h - (kh - 1) - 1) / double(stride_h) + 1);
  int32_t ofmap_w = (int32_t)floor((double)(w + 2 * pad_w - (kw - 1) - 1) / double(stride_w) + 1);

  using namespace compute_model::tensor;

  auto ifmap  = randn<bfloat16>({ic_group, h, w, ic_group_size}, kHalf, -1.0f, 1.0f, 0);
  auto weight = randn<bfloat16>({oc_group, ic_group, kh, kw, oc_group_size, ic_group_size}, kHalf, -1.0f, 1.0f, 100);
  auto ofmap  = zeros<float>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);

  using conv2d_sim_t                  = compute_model::conv2d::Conv2dSim<0, false, false, false, bfloat16, bfloat16, float, float, false>;
  conv2d_sim_t::Arguments conv2d_args = {
    ofmap, ifmap, weight, stride_h, stride_w, pad_h, pad_w, dilation_h, dilation_w, ifmap_block_h, ifmap_block_w, kh, kw, 1, 1};

  conv2d_sim_t conv2d_sim_op;
  conv2d_sim_op(conv2d_args);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), (char*)ifmap.data_ptr(), ifmap.numel() * sizeof(bfloat16), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    weight_file.c_str(), reinterpret_cast<char*>(weight.data_ptr()), weight.numel() * sizeof(bfloat16), 32, true);

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