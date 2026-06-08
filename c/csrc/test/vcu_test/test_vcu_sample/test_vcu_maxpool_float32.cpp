#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/tensor.h"
#include "compute_model/sample/maxpool.h"
#include "sample/maxpool.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include <vector>

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;
  int h             = 4;
  int w             = 4;
  int kh            = 3;
  int kw            = 3;
  int pad_h         = 1;
  int pad_w         = 1;
  int stride_h      = 2;
  int stride_w      = 2;
  int oc_group      = 8;
  int dilation_h    = 1;
  int dilation_w    = 1;
  int ifmap_block_h = 4;
  int ifmap_block_w = 4;
  int oc_group_size = 32;

  uint64_t data_in_ddr_base_addr  = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr = OFMAP_ADDR;
  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  using maxpool_t                   = vcu::MaxpoolOp<kFloat32, kFloat32, true>;
  maxpool_t::Arguments maxpool_args = {h,
                                       w,
                                       kh,
                                       kw,
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
                                       0,
                                       1,
                                       data_in_ddr_base_addr,
                                       data_out_ddr_base_addr};
  maxpool_t            maxpool_op;
  auto                 insn_series = maxpool_op(maxpool_args);
  common::insn::pad_serial_sync_word(insn_series);
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 data gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  auto data_in  = randn<float>({oc_group, h, w, oc_group_size}, kFloat32, -1.0f, 1.0f, 0);
  auto data_out = zeros<float>({oc_group, 2, 2, oc_group_size}, kFloat32);

  using maxpool_sim_t           = compute_model::sample::Maxpool2dSim<float, float, true>;
  maxpool_sim_t::Arguments args = {data_out, data_in, {kh, kw}, {stride_h, stride_w}, {pad_h, pad_w}, {dilation_h, dilation_w}};
  maxpool_sim_t            maxpool_sim;
  maxpool_sim(args);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), (char*)data_out.data_ptr(), data_out.numel() * sizeof(float), 32, true);

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