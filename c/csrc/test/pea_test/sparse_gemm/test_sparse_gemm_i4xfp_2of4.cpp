#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/gemm/gemm.h"
#include "compute_model/sparse/sparse.h"
#include "pea/pea_insn.h"
#include "write_reg.h"
#include <vector>

int main(int argc, const char** argv)
{
  int m             = 64;
  int n_group       = 1;
  int k_group       = 16;
  int n_group_size  = 32;
  int k_group_size  = 16;
  int n             = n_group * n_group_size;
  int k             = k_group * k_group_size;
  int tile_m        = 32;
  int block_n_group = 1;
  int block_k_group = 1;

  const int SPARSE_ENABLE = 1;

  int sparse_ratio = 2;

  using gemm_t           = pea::GemmOp<SPARSE_ENABLE, 0, 0, 0, kInt4, kHalf, kFloat32, kFloat32, false>;
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
                            OUTLIER_INDEX_ADDR,
                            IFMAPMASK_ADDR};

  gemm_t gemm_op;
  auto   insn_series = gemm_op(args);
  common::insn::pad_serial_sync_word(insn_series);
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  using namespace compute_model::common::fp16;
  using namespace compute_model::common::bf16;
  using namespace compute_model::common::subbyte;
  using namespace compute_model::tensor;
  using namespace compute_model::sparse;

  auto ifmap        = randn<int4_t>({k_group / 4, m, k_group_size * 4}, kHalf, -8.0f, 7.0f, 0);
  auto weight_dense = randn<half>({n_group, k_group, n_group_size, k_group_size}, kHalf, -1.0f, 1.0f, 100);
  auto ofmap        = zeros<float>({n_group, m, n_group_size}, kFloat32);
  auto ifmap_mask   = GenIfmapMask(n_group, k_group, n_group_size, k_group_size, SPARSE_ENABLE, 0);

  auto weight_sparse          = weightetZero(weight_dense, ifmap_mask, sparse_ratio);
  auto weight_sparse_compress = WeightProcess(weight_dense, ifmap_mask, sparse_ratio);
  auto ifmap_transform        = TransformIfmap(ifmap, sparse_ratio);
  auto ifmap_mask_transform   = IfmapMaskProcess(ifmap_mask, sparse_ratio);

  using gemm_sim_t               = compute_model::gemm::GemmSim<SPARSE_ENABLE, false, false, false, int4_t, half, float, float, true>;
  gemm_sim_t::Arguments args_sim = {
    ofmap, ifmap_transform, weight_sparse_compress, tile_m, block_n_group, block_k_group, ifmap_mask_transform};

  gemm_sim_t gemm_sim_op;
  gemm_sim_op(args_sim);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), (char*)ifmap.data_ptr(), ifmap.numel() * sizeof(int4_t), 64, true, true);

  common::file_utils::saveCharArrayToFormattedTextFile(weight_file.c_str(),
                                                       reinterpret_cast<char*>(weight_sparse_compress.data_ptr()),
                                                       weight_sparse_compress.numel() * sizeof(half),
                                                       32,
                                                       true);

  auto ifmap_mask_compress = zeros<int8_t>({n_group, (k_group / sparse_ratio), m, n_group_size * (k_group_size / 8) * sparse_ratio}, kInt8);
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
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}