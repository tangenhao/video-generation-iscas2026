#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/gemm/gemm.h"
#include "npu_insn_u.h"
#include "write_reg.h"
#include <vector>

int main(int argc, const char** argv)
{
  int m             = 32;
  int n_group       = 2;
  int k_group       = 2;
  int n_group_size  = 32;
  int k_group_size  = 16;
  int n             = n_group * n_group_size;
  int k             = k_group * k_group_size;
  int tile_m        = 16;
  int block_n_group = 2;
  int block_k_group = 1;

  using gemm_t                           = npu_u::GemmOp<0, 0, 0, 0, 0, kHalf, kHalf, kFloat32, kInt4, true>;
  vcu::VcuConfig::Arguments vcu_cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu::vcu_exe_args         vcu_exe_args = {kFloat32, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  gemm_t::Arguments         args         = {m,
                            n,
                            k,
                            tile_m,
                            block_n_group,
                            block_k_group,
                            IFMAP_ADDR,
                            WEIGHT_ADDR,
                            OFMAP_ADDR,
                            VCURES_ADDR,
                            VCUPARA_ADDR,
                            vcu_cfg_args,
                            vcu_exe_args,
                            {"add psum para, reg6", "add reg6 resadd, reg11", "fastgelu reg11, reg7"}};
  gemm_t                    gemm_op;
  auto                      temp           = gemm_op(args);
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
  using namespace compute_model::common::fp16;
  using namespace compute_model::tensor;

  auto ifmap     = randn<half>({k_group, m, k_group_size}, kHalf, -1.0f, 1.0f, 0);
  auto weight    = randn<half>({n_group, k_group, n_group_size, k_group_size}, kHalf, -1.0f, 1.0f, 100);
  auto pea_ofmap = zeros<float>({n_group, m, n_group_size}, kFloat32);

  // resadd---------------------------------------------

  auto resadd = randn<float>({n_group, m, n_group_size}, kFloat32, -1.0f, 1.0f, 7);

  common::file_utils::saveCharArrayToFormattedTextFile(
    res_file.c_str(), reinterpret_cast<char*>(resadd.data_ptr()), resadd.numel() * sizeof(float), 32, true);

  // bias---------------------------------------------------------------------------
  auto para = randn<float>({n_group, 1, n_group_size}, kFloat32, -1.0f, 1.0f, 6);

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(para.data_ptr()), para.numel() * sizeof(float), 32, true);

  //--------------------------------------------------------------

  using gemm_sim_t               = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, true>;
  gemm_sim_t::Arguments args_sim = {pea_ofmap, ifmap, weight, tile_m, block_n_group, block_k_group};

  gemm_sim_t gemm_sim_op;
  gemm_sim_op(args_sim);

  // common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_pea_out.txt",
  //                                                      reinterpret_cast<char*>(pea_ofmap.data_ptr()),
  //                                                      pea_ofmap.numel() * sizeof(float),
  //                                                      256,
  //                                                      true);

  auto bias_add_out = zeros<float>({n_group, m, n_group_size}, kFloat32);
  bias_add_out      = pea_ofmap + para;
  // common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_bias_out_out.txt",
  //                                                      reinterpret_cast<char*>(bias_add_out.data_ptr()),
  //                                                      bias_add_out.numel() * sizeof(float),
  //                                                      256,
  //                                                      true);

  // common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_para_bias.txt",
  //                                                      reinterpret_cast<char*>(para.data_ptr()),
  //                                                      para.numel() * sizeof(float),
  //                                                      256,
  //                                                      true);

  auto resadd_out = zeros<float>({n_group, m, n_group_size}, kFloat32);
  resadd_out      = bias_add_out + resadd;

  // common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_resadd_out_out.txt",
  //                                                      reinterpret_cast<char*>(resadd_out.data_ptr()),
  //                                                      resadd_out.numel() * sizeof(float),
  //                                                      256,
  //                                                      true);

  // common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_resadd_in.txt",
  //                                                      reinterpret_cast<char*>(resadd.data_ptr()),
  //                                                      resadd.numel() * sizeof(float),
  //                                                      256,
  //                                                      true);

  auto vcu_ofmap = zeros<float>({n_group, m, n_group_size}, kFloat32);
  vcu_ofmap      = compute_model::function::fast_gelu(resadd_out);

  // common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_vcu_out_fp32.txt",
  //                                                      reinterpret_cast<char*>(vcu_ofmap.data_ptr()),
  //                                                      vcu_ofmap.numel() * sizeof(float),
  //                                                      256,
  //                                                      true);
  auto vcu_ofmap_int4 = ToInt4(vcu_ofmap);

  // parallelism convertion -----------------------------------------------
  using namespace compute_model::common::subbyte;
  // common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/ofmap_mid_vcu_out.txt",
  //                                                      reinterpret_cast<char*>(vcu_ofmap_int4.data_ptr()),
  //                                                      vcu_ofmap_int4.numel() * sizeof(int4_t),
  //                                                      64,
  //                                                      true,
  //                                                      true);

  auto ofmap_reshape = ParallelismConvertion32to64(vcu_ofmap_int4);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), reinterpret_cast<char*>(ifmap.data_ptr()), ifmap.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    weight_file.c_str(), reinterpret_cast<char*>(weight.data_ptr()), weight.numel() * sizeof(half), 32, true);

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
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);
  return 0;
}