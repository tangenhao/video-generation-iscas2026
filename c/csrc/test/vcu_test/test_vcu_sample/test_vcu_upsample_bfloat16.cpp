#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/bf16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/sample/upsample.h"
#include "sample/upsample.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include <vector>

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;
  int h             = 7;
  int w             = 7;
  int ic_group      = 1;
  int oc_group      = 1;
  int ifmap_block_h = 7;
  int ifmap_block_w = 7;
  int scale_factor  = 2;
  int oc_group_size = 32;

  uint64_t data_in_ddr_base_addr  = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr = OFMAP_ADDR;
  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  using namespace compute_model::common::bf16;

  using upsample_t                    = vcu::UpsampleOp<kBfloat16, kBfloat16, true>;
  upsample_t::Arguments upsample_args = {h,
                                         w,
                                         scale_factor,
                                         scale_factor,
                                         oc_group * oc_group_size,
                                         ifmap_block_h,
                                         ifmap_block_w,
                                         1,
                                         0,
                                         1,
                                         data_in_ddr_base_addr,
                                         data_out_ddr_base_addr};
  upsample_t            upsample_op;
  auto                  insn_series = upsample_op(upsample_args);
  common::insn::pad_serial_sync_word(insn_series);
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 data gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  auto data_in  = randn<bfloat16>({ic_group, h, w, oc_group_size}, kBfloat16, -1.0f, 1.0f, 0);
  auto data_out = zeros<bfloat16>({oc_group, 14, 14, oc_group_size}, kBfloat16);

  using upsample_sim_t           = compute_model::sample::UpsampleSim<bfloat16, bfloat16, true>;
  upsample_sim_t::Arguments args = {data_out, data_in, {scale_factor, scale_factor}};
  upsample_sim_t            upsample_sim;
  upsample_sim(args);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), (char*)data_out.data_ptr(), data_out.numel() * sizeof(bfloat16), 32, true);

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
             PSUM_LOAD_512,
             PSUM_STORE_512,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}