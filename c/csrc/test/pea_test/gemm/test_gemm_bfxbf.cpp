#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/gemm/gemm.h"
#include "pea/pea_insn.h"
#include <vector>

int main(int argc, const char** argv)
{
  int m             = 16;
  int n_group       = 4;
  int k_group       = 4;
  int n_group_size  = 32;
  int k_group_size  = 16;
  int n             = n_group * n_group_size;
  int k             = k_group * k_group_size;
  int tile_m        = 16;
  int block_n_group = 4;
  int block_k_group = 4;

  using gemm_t           = pea::GemmOp<0, 0, 0, 0, kBfloat16, kBfloat16, kFloat32, kFloat32, false>;
  gemm_t::Arguments args = {m, n, k, tile_m, block_n_group, block_k_group, IFMAP_ADDR, WEIGHT_ADDR, OFMAP_ADDR};

  gemm_t gemm_op;
  auto   insn_series = gemm_op(args);
  common::insn::pad_serial_sync_word(insn_series);
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  using namespace compute_model::common::bf16;
  using gemm_sim_t = compute_model::gemm::GemmSim<0, 0, false, false, bfloat16, bfloat16, float, float, false>;
  using namespace compute_model::tensor;

  auto ifmap  = randn<bfloat16>({k_group, m, k_group_size}, kBfloat16, -1.0f, 1.0f, 0);
  auto weight = randn<bfloat16>({n_group, k_group, n_group_size, k_group_size}, kBfloat16, -1.0f, 1.0f, 100);
  auto ofmap  = zeros<float>({n_group, m, n_group_size}, kFloat32);

  gemm_sim_t::Arguments args_sim = {ofmap, ifmap, weight, tile_m, 1, 1};

  gemm_sim_t gemm_sim_op;
  gemm_sim_op(args_sim);

  common::file_utils::saveCharArrayToFormattedTextFile(ifmap_file.c_str(), (char*)ifmap.data_ptr(), ifmap.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    weight_file.c_str(), reinterpret_cast<char*>(weight.data_ptr()), weight.numel() * sizeof(half), 32, true);

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