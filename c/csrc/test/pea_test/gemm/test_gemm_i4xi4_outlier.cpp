#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/subbyte.h"
#include "compute_model/common/tensor.h"
#include "compute_model/gemm/gemm.h"
#include "pea/pea_insn.h"
#include <vector>

int main(int argc, const char** argv)
{
  int m             = 32;
  int n_group       = 1;
  int k_group       = 2;
  int n_group_size  = 32;
  int k_group_size  = 64;
  int n             = n_group * n_group_size;
  int k             = k_group * k_group_size;
  int tile_m        = 16;
  int block_n_group = 1;
  int block_k_group = 1;

  using gemm_t           = pea::GemmOp<0, 0, 0, true, kInt4, kInt4, kFloat32, kFloat32, true>;
  gemm_t::Arguments args = {m,
                            n,
                            k,
                            tile_m,
                            block_n_group,
                            block_k_group,
                            IFMAP_ADDR,
                            WEIGHT_ADDR,
                            OFMAP_ADDR,
                            IFMAP_SCALE_ADDR,
                            WEIGHT_SCALE_ADDR,
                            OUTLIER_INDEX_ADDR};

  gemm_t gemm_op;
  auto   insn_series = gemm_op(args);

  common::insn::pad_serial_sync_word(insn_series);
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  using namespace compute_model::common::subbyte;
  using namespace compute_model::tensor;
  using namespace compute_model::common::fp16;

  auto ifmap         = randn<int4_t>({k_group, m, k_group_size}, kHalf, -8.0f, 7.0f, 0);
  auto weight        = randn<int4_t>({n_group, k_group, n_group_size, k_group_size}, kHalf, -8.0f, 7.0f, 100);
  auto ofmap         = zeros<float>({n_group, m, n_group_size}, kInt32);
  auto ifmap_scale   = randn<half>({m}, kHalf, -1.0f, 1.0f, 0);
  auto weight_scale  = randn<half>({n_group, n_group_size}, kHalf, -1.0f, 1.0f, 0);
  auto outlier_index = randn<int8_t>({k_group, m, k_group_size}, kInt8, 0, 2, 0);
  auto outlier_scale = randn<half>({m}, kHalf, -1.0f, 1.0f, 0);

  using gemm_sim_t               = compute_model::gemm::GemmSim<0, 0, false, true, int4_t, int4_t, float, float, true>;
  gemm_sim_t::Arguments args_sim = {
    ofmap, ifmap, weight, tile_m, block_n_group, block_k_group, Tensor<int8_t>(), ifmap_scale, weight_scale, outlier_index, outlier_scale};

  gemm_sim_t gemm_sim_op;
  gemm_sim_op(args_sim);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), (char*)ifmap.data_ptr(), ifmap.numel() * sizeof(int4_t), 64, true, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    weight_file.c_str(), reinterpret_cast<char*>(weight.data_ptr()), weight.numel() * sizeof(int4_t), 64, true, true);

  Tensor<half> ifmap_scale_pad({m, 16}, kHalf);
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < 16; j++) {
      if (j == 0) {
        ifmap_scale_pad[i * 16 + j] = ifmap_scale[i];
      }
      if (j == 1) {
        ifmap_scale_pad[i * 16 + j] = outlier_scale[i];
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/ifmap_scale.txt", (char*)ifmap_scale_pad.data_ptr(), ifmap_scale_pad.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/weight_scale.txt", (char*)weight_scale.data_ptr(), weight_scale.numel() * sizeof(half), 32, true);

  auto outlier_index_pad_temp = zeros<int8_t>({k_group, m, k_group_size}, kInt8);
  for (int i = 0; i < k_group; i++) {
    for (int j = 0; j < m; j++) {
      for (int l = 0; l < k_group_size / 8; l++) {
        int8_t num = 0;
        for (int c = 0; c < 8; ++c) {
          num |= (outlier_index[i * m * k_group_size + j * k_group_size + l * 8 + c] << c);
        }
        outlier_index_pad_temp[i * m * k_group_size + j * k_group_size + l] = num;
      }
    }
  }
  // std::cout << outlier_index_pad_temp << std::endl;

  auto outlier_index_pad = zeros<int8_t>({k_group, m, 32}, kInt8);
  for (int i = 0; i < k_group; i++) {
    for (int j = 0; j < m; j++) {
      for (int l = 0; l < 32; l++) {
        outlier_index_pad[i * m * 32 + j * 32 + l] = outlier_index_pad_temp[i * m * k_group_size + j * k_group_size + l];
      }
    }
  }

  // std::cout << outlier_index_pad_temp << std::endl;

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/outlier_index.txt",
                                                       reinterpret_cast<char*>(outlier_index_pad.data_ptr()),
                                                       outlier_index_pad_temp.numel() * sizeof(int8_t),
                                                       32,
                                                       true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(ofmap.data_ptr()), ofmap.numel() * sizeof(int32_t), 32, true);

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