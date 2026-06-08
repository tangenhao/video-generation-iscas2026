#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/conv/conv2d.h"
#include "npu_insn_u.h"
#include "write_reg.h"
#include <vector>

#include "common/file_utils.h"
#include "compute_model/common/subbyte.h"
#include "compute_model/function/tensor_function.h"
#include "vcu/vcu_opcode.h"

int main(int argc, const char** argv)
{
  int h              = 8;
  int w              = 8;
  int kh             = 3;
  int kw             = 3;
  int pad_h          = 1;
  int pad_w          = 1;
  int stride_h       = 2;
  int stride_w       = 2;
  int ic_group       = 2;
  int oc_group       = 4;
  int dilation_h     = 1;
  int dilation_w     = 1;
  int ifmap_block_h  = 4;
  int ifmap_block_w  = 4;
  int ic_group_size  = 16;
  int oc_group_size  = 32;
  int block_ic_group = 2;
  int block_oc_group = 2;

  using conv2d_t                         = npu_u::Conv2dOp<0, 0, 0, 0, kBfloat16, kBfloat16, kFloat32, kInt4, false>;
  vcu::VcuConfig::Arguments vcu_cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu::vcu_exe_args         vcu_exe_args = {kInt8, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0};
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
                              {"add psum para, reg6",
                               "add reg6 resadd, reg11",
                               "config reg3, 1.0",
                               "config reg4, 20.0",
                               "copy reg11, reg0",
                               "mul reg0 reg3, reg6",
                               "mulc reg6, reg1, 1.442695",
                               "exp2 reg1, reg1",
                               "addc reg1, reg1, 1.0",
                               "log2 reg1, reg1",
                               "mulc reg1, reg1, 0.6931472",
                               "rec reg3, reg5",
                               "mul reg1 reg5, reg1",
                               "compgeq reg6, reg4, reg0, reg1, reg1"}};
  conv2d_t                  conv2d_op;
  auto                      temp           = conv2d_op(args);
  auto                      insn_series    = temp.first;
  auto                      vcucode_series = temp.second;
  common::insn::pad_serial_sync_word(insn_series);
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  //--------------------------------------------------------------
  // auto   num_vcucodes      = vcucode_series.size();
  // size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
  // size_t vcucode_ddr_lines = (vcucode_bytes + 63) / 64;
  // vcucode_series.resize(vcucode_ddr_lines * 8, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  //--------------------------------------------------------------
  using namespace compute_model::common::bf16;

  int32_t ofmap_h = (int32_t)floor((double)(h + 2 * pad_h - (kh - 1) - 1) / double(stride_h) + 1);
  int32_t ofmap_w = (int32_t)floor((double)(w + 2 * pad_w - (kw - 1) - 1) / double(stride_w) + 1);

  using namespace compute_model::tensor;

  auto ifmap     = randn<bfloat16>({ic_group, h, w, ic_group_size}, kBfloat16, -1.0f, 1.0f, 0);
  auto weight    = randn<bfloat16>({oc_group, ic_group, kh, kw, oc_group_size, ic_group_size}, kBfloat16, -1.0f, 1.0f, 100);
  auto pea_ofmap = zeros<float>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);
  // resadd---------------------------------------------

  auto resadd = randn<int8_t>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kHalf, -64.0f, 64.0f, 7);

  common::file_utils::saveCharArrayToFormattedTextFile(
    res_file.c_str(), reinterpret_cast<char*>(resadd.data_ptr()), resadd.numel() * sizeof(int8_t), 32, true);

  // bias---------------------------------------------------------------------------
  auto para = randn<float>({oc_group, 1, 1, oc_group_size}, kFloat32, -2.0f, 2.0f, 6);

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(para.data_ptr()), para.numel() * sizeof(float), 32, true);

  //--------------------------------------------------------------
  using conv2d_sim_t                  = compute_model::conv2d::Conv2dSim<0, false, false, false, bfloat16, bfloat16, float, float, false>;
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

  auto bias_add_out = pea_ofmap + para;
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/ofmap_mid_pea_out.txt", reinterpret_cast<char*>(pea_ofmap.data_ptr()), pea_ofmap.numel() * sizeof(float), 256, true);

  // common::file_utils::saveCharArrayToFormattedTextFile(
  //   "../../sim/memory/bias_in.txt", reinterpret_cast<char*>(para.data_ptr()), para.numel() * sizeof(float), 256,
  //   true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/bias_add_out.txt", reinterpret_cast<char*>(bias_add_out.data_ptr()), bias_add_out.numel() * sizeof(float), 256, true);

  auto resadd_fp = ToFloat32(resadd);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/resadd_fp.txt", reinterpret_cast<char*>(resadd_fp.data_ptr()), resadd_fp.numel() * sizeof(float), 256, true);
  auto resadd_out = bias_add_out + resadd_fp;

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/resadd_out.txt", reinterpret_cast<char*>(resadd_out.data_ptr()), resadd_out.numel() * sizeof(float), 256, true);

  auto vcu_ofmap = zeros<float>({oc_group, ofmap_h, ofmap_w, oc_group_size}, kFloat32);
  vcu_ofmap      = compute_model::function::softplus(resadd_out);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/ofmap_mid_vcu_out.txt", reinterpret_cast<char*>(vcu_ofmap.data_ptr()), vcu_ofmap.numel() * sizeof(float), 256, true);

  auto vcu_ofmap_int4 = ToInt4(vcu_ofmap);

  // parallelism convertion -----------------------------------------------

  using namespace compute_model::common::subbyte;
  // common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_vcu_out_int.txt",
  //                                                      reinterpret_cast<char*>(vcu_ofmap_int4.data_ptr()),
  //                                                      vcu_ofmap_int4.numel() * sizeof(int4_t),
  //                                                      64,
  //                                                      true);

  int num_data = ofmap_h * ofmap_w;  // int * int -> uint64_t
  // auto ofmap_reshape = zeros<int4_t>({oc_group / 2, ofmap_h, ofmap_w,  128}, kInt4);

  // using namespace compute_model::common::subbyte;
  auto ofmap_reshape = ParallelismConvertion32to64(vcu_ofmap_int4);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), (char*)ifmap.data_ptr(), ifmap.numel() * sizeof(bfloat16), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    weight_file.c_str(), (char*)weight.data_ptr(), weight.numel() * sizeof(bfloat16), 32, true);

  // common::file_utils::saveCharArrayToFormattedTextFile(
  //   ofmap_file.c_str(), reinterpret_cast<char*>(ofmap.data_ptr()), ofmap.numel() * sizeof(float), 64,
  //   true);

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
             NO_BROADCAST,
             PSUM_LOAD_1024,
             PSUM_STORE_1024,
             VCURES_LOAD_256,
             IFMAP_MASK_LOAD_32,
             1);
  return 0;
}