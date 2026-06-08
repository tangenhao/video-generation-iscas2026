#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/conv/conv2d.h"
#include "multi_core/set_core_id.h"
#include "multi_issue/multi_issue.h"
#include "npu_insn_u.h"
#include "write_reg.h"
#include <vector>

int main(int argc, const char** argv)
{
  int h              = 1;
  int w              = 128;
  int kh             = 1;
  int kw             = 1;
  int pad_h          = 0;
  int pad_w          = 0;
  int stride_h       = 1;
  int stride_w       = 1;
  int ic_group       = 2;
  int oc_group       = 4;
  int dilation_h     = 1;
  int dilation_w     = 1;
  int ifmap_block_h  = 1;
  int ifmap_block_w  = 128;
  int ic_group_size  = 16;
  int oc_group_size  = 32;
  int block_ic_group = 1;
  int block_oc_group = 2;

  using conv2d_t                         = npu_u::Conv2dOp<0, 0, 0, 0, kHalf, kHalf, kFloat32, kInt4, true>;
  vcu::VcuConfig::Arguments vcu_cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu::vcu_exe_args         vcu_exe_args = {kBfloat16, 1, 1, 0, 3, 0, 0, 0, 0, 0, 0, 0};
  conv2d_t::Arguments       args         = {h,
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
                              OFMAP_ADDR,
                              VCURES_ADDR,
                              VCUPARA_ADDR,
                              vcu_cfg_args,
                              vcu_exe_args,
                              {"add psum para, reg6", "add reg6 resadd, reg7", "fastswish reg7, reg7"}};
  conv2d_t                  conv2d_op;
  auto                      temp           = conv2d_op(args);
  auto                      insn_series    = temp.first;
  auto                      vcucode_series = temp.second;
  // multi_core::core_id::set_core_id(insn_series, 0);
  common::insn::pad_serial_sync_word(insn_series);
  auto parser = common::insn::instruction_parser(insn_series);
  parser.parse_instruction();

  for (auto insn : insn_series) {
    std::cout << insn << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  //--------------------------------------------------------------

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  //--------------------------------------------------------------
  using namespace compute_model::common::fp16;
  using namespace compute_model::common::bf16;

  int32_t ofmap_h = (int32_t)floor((double)(h + 2 * pad_h - (kh - 1) - 1) / double(stride_h) + 1);
  int32_t ofmap_w = (int32_t)floor((double)(w + 2 * pad_w - (kw - 1) - 1) / double(stride_w) + 1);

  using namespace compute_model::tensor;

  auto ifmap     = randn<half>({ic_group, h, w, ic_group_size}, kHalf, -1.0f, 1.0f, 0);
  auto weight    = randn<half>({oc_group, ic_group, kh, kw, oc_group_size, ic_group_size}, kHalf, -1.0f, 1.0f, 100);
  auto pea_ofmap = zeros<float>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);

  // resadd---------------------------------------------

  auto resadd = randn<bfloat16>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kHalf, -1.0f, 1.0f, 7);
  common::file_utils::saveCharArrayToFormattedTextFile(
    res_file.c_str(), reinterpret_cast<char*>(resadd.data_ptr()), resadd.numel() * sizeof(bfloat16), 32, true);

  // bias---------------------------------------------------------------------------
  auto para = randn<float>({oc_group, 1, 1, oc_group_size}, kFloat32, -1.0f, 1.0f, 6);

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(para.data_ptr()), para.numel() * sizeof(float), 32, true);

  //--------------------------------------------------------------

  using conv2d_sim_t                  = compute_model::conv2d::Conv2dSim<0, false, false, false, half, half, float, float, true>;
  conv2d_sim_t::Arguments conv2d_args = {pea_ofmap,
                                         ifmap,
                                         weight,
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
                                         block_oc_group};

  conv2d_sim_t conv2d_sim_op;
  conv2d_sim_op(conv2d_args);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/ofmap_mid_pea_out.txt", reinterpret_cast<char*>(pea_ofmap.data_ptr()), pea_ofmap.numel() * sizeof(float), 128, true);

  auto bias_add_out = zeros<float>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);
  bias_add_out      = pea_ofmap + para;

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_bias_out_out.txt",
                                                       reinterpret_cast<char*>(bias_add_out.data_ptr()),
                                                       bias_add_out.numel() * sizeof(float),
                                                       128,
                                                       true);

  auto resadd_fp  = ToFloat32(resadd);
  auto resadd_out = zeros<float>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);
  resadd_out      = bias_add_out + resadd_fp;

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_resadd_out_out.txt",
                                                       reinterpret_cast<char*>(resadd_out.data_ptr()),
                                                       resadd_out.numel() * sizeof(float),
                                                       128,
                                                       true);

  auto vcu_ofmap = zeros<float>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);
  vcu_ofmap      = compute_model::function::fast_swish(resadd_out);

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_vcu_out_fp32.txt",
                                                       reinterpret_cast<char*>(vcu_ofmap.data_ptr()),
                                                       vcu_ofmap.numel() * sizeof(float),
                                                       128,
                                                       true);
  auto vcu_ofmap_int4 = ToInt4(vcu_ofmap);

  // parallelism convertion -----------------------------------------------
  using namespace compute_model::common::subbyte;
  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_vcu_out.txt",
                                                       reinterpret_cast<char*>(vcu_ofmap_int4.data_ptr()),
                                                       vcu_ofmap_int4.numel() * sizeof(int4_t),
                                                       64,
                                                       true,
                                                       true);
  //

  auto ofmap_reshape = ParallelismConvertion32to64(vcu_ofmap_int4);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), reinterpret_cast<char*>(ifmap.data_ptr()), ifmap.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    weight_file.c_str(), reinterpret_cast<char*>(weight.data_ptr()), weight.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), (char*)ofmap_reshape.data_ptr(), ofmap_reshape.numel() * sizeof(int4_t), 64, true, true);

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
             BROADCAST,
             PSUM_LOAD_1024,
             PSUM_STORE_1024,
             VCURES_LOAD_512,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}