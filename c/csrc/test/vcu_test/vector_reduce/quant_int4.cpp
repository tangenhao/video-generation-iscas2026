#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include <vector>

std::pair<int, int> split_exp_fra(int64_t x)
{
  if (x > 8355840) {
    std::throw_with_nested(std::runtime_error("x is too large"));
  }
  int max_exp = (1 << 4) - 1;
  int max_fra = (1 << 8) - 1;
  int exp     = 0;
  while (x > max_fra) {
    x /= 2;
    exp++;
  }
  return {exp, x};
}

template<typename T>
std::string to_string_with_precision(const T a_value, const int n = 6)
{
  int                nn = n;
  std::ostringstream out;
  out << std::fixed << std::setprecision(nn) << a_value;
  return out.str();
}

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;

  int   seq_len       = 10;
  int   d_model       = 128;
  int   oc_group_size = 32;
  int   oc_group      = d_model / oc_group_size;
  float threshold     = 6.0;

  uint64_t rec_lut_ddr_base_addr   = REC_LUT_ADDR;
  uint64_t log_lut_ddr_base_addr   = LOG_LUT_ADDR;
  uint64_t exp_lut_ddr_base_addr   = EXP_LUT_ADDR;
  uint64_t rsqrt_lut_ddr_base_addr = RSQRT_LUT_ADDR;
  uint64_t data_in_ddr_base_addr   = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  auto data_in = randn<float>({oc_group, seq_len, oc_group_size}, kFloat32, -6.1f, 6.1f, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  auto outlier_index = zeros<int8_t>({oc_group, seq_len, oc_group_size}, kInt8);
  auto data_out_temp = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);
  auto data_out      = zeros<int8_t>({oc_group, seq_len, oc_group_size}, kInt8);
  auto scale         = zeros<float>({oc_group / 2, seq_len, oc_group_size}, kFloat32);

  for (int i = 0; i < oc_group / 2; ++i) {
    for (int j = 0; j < seq_len; ++j) {
      float         row_max_normal  = -1e9;
      float         row_max_outlier = -1e9;
      Tensor<float> row             = zeros<float>({oc_group_size * 2}, kFloat32);

      for (int l = 0; l < 2; ++l) {
        for (int k = 0; k < oc_group_size; ++k) {
          row[l * oc_group_size + k] = data_in[(i * 2 + l) * seq_len * oc_group_size + j * oc_group_size + k];
        }
      }
      std::cout << "row: " << i << " " << j << " " << std::endl;
      row.print_hex(256, true);

      Tensor<float> row_abs = row.abs();
      row_abs.print_hex(256, true);

      Tensor<float> outlier = zeros<float>({oc_group_size * 2}, kFloat32);
      Tensor<float> normal  = zeros<float>({oc_group_size * 2}, kFloat32);
      for (int l = 0; l < 2; ++l) {
        for (int k = 0; k < oc_group_size; ++k) {
          if (row_abs[l * oc_group_size + k] > threshold) {
            outlier[l * oc_group_size + k] = row[l * oc_group_size + k];

            outlier_index[(i * 2 + l) * seq_len * oc_group_size + j * oc_group_size + k] = 1;
          }
          else {
            normal[l * oc_group_size + k] = row[l * oc_group_size + k];
          }
        }
      }
      outlier.print_hex(256, true);
      normal.print_hex(256, true);

      for (int l = 0; l < 2; ++l) {
        for (int k = 0; k < oc_group_size; ++k) {
          row_max_normal = std::max(row_max_normal, normal[l * oc_group_size + k]);
        }
        std::cout << std::hex << "row_max_normal: " << *(uint32_t*)(&row_max_normal) << std::endl;
        for (int k = 0; k < oc_group_size; ++k) {
          row_max_outlier = std::max(row_max_outlier, outlier[l * oc_group_size + k]);
        }
        std::cout << std::hex << "row_max_normal: " << *(uint32_t*)(&row_max_outlier) << std::endl;
      }

      scale[i * seq_len * oc_group_size + j * oc_group_size]     = 127 * compute_model::function::reciprocal_c(row_max_normal);
      scale[i * seq_len * oc_group_size + j * oc_group_size + 1] = 127 * compute_model::function::reciprocal_c(row_max_outlier);

      for (int l = 0; l < 2; ++l) {
        for (int k = 0; k < oc_group_size; ++k) {
          if (outlier_index[(i * 2 + l) * seq_len * oc_group_size + j * oc_group_size + k] == 1) {
            data_out_temp[(i * 2 + l) * seq_len * oc_group_size + j * oc_group_size + k] =
              data_in[(i * 2 + l) * seq_len * oc_group_size + j * oc_group_size + k]
              * (127 * compute_model::function::reciprocal_c(row_max_outlier));
          }
          else {
            data_out_temp[(i * 2 + l) * seq_len * oc_group_size + j * oc_group_size + k] =
              data_in[(i * 2 + l) * seq_len * oc_group_size + j * oc_group_size + k]
              * (127 * compute_model::function::reciprocal_c(row_max_normal));
          }
        }
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/data_out_temp.txt", (char*)data_out_temp.data_ptr(), data_out_temp.numel() * sizeof(float), 32, true);

  data_out      = ToInt4(data_out_temp);
  data_out      = ParallelismConvertion32to64(data_out);
  outlier_index = ParallelismConvertion32to64(outlier_index);

  auto         ifmap_scale     = ToFloat16(scale);
  Tensor<half> ifmap_scale_pad = zeros<half>({oc_group / 2, seq_len, 16}, kHalf);
  for (int i = 0; i < oc_group / 2; i++) {
    for (int j = 0; j < seq_len; j++) {
      for (int k = 0; k < 16; k++) {
        if (k == 0) {
          ifmap_scale_pad[i * seq_len * 16 + j * 16 + k] = ifmap_scale[i * seq_len * oc_group_size + j * oc_group_size + k];
        }
        if (k == 1) {
          ifmap_scale_pad[i * seq_len * 16 + j * 16 + k] = ifmap_scale[i * seq_len * oc_group_size + j * oc_group_size + k];
        }
      }
    }
  }

  auto outlier_index_pad = zeros<int8_t>({oc_group / 2, seq_len, oc_group_size}, kInt8);
  for (int i = 0; i < oc_group / 2; i++) {
    for (int j = 0; j < seq_len; j++) {
      for (int l = 0; l < (oc_group_size * 2) / 8; l++) {
        int8_t num = 0;
        for (int c = 0; c < 8; ++c) {
          num |= (outlier_index[i * seq_len * (oc_group_size * 2) + j * (oc_group_size * 2) + l * 8 + c] << c);
        }
        outlier_index_pad[i * seq_len * oc_group_size + j * oc_group_size + l] = num;
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/outlier_index.txt", (char*)outlier_index_pad.data_ptr(), outlier_index_pad.numel() * sizeof(int8_t), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/ifmap_scale.txt", (char*)ifmap_scale_pad.data_ptr(), ifmap_scale_pad.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out.data_ptr()), data_out.numel() * sizeof(int4_t), 64, true, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */

  auto vcucode_series = vcu::asm_vcu_op({
    /* 0. config reg 0 as threshold*/
    "config reg0, " + to_string_with_precision(threshold),
    "config reg1, " + to_string_with_precision(0),
    "config reg2, 0x1",
    "config reg11, " + to_string_with_precision(1),

    /* 1. abs, store to vcures*/
    "absm psum, reg10",

    /* 2. compare with threshold, get outlier_index, store to psum*/
    "compgeq resadd, reg0, reg2, reg1, reg3",
    "outlier_compress reg3, reg4",
    "rdcrossoc 1",
    "compgeq resadd, reg0, reg2, reg1, reg3",
    "outlier_compress reg3, reg5",
    "maskb reg5, reg4, 0, 2",

    /* 3.1 Compute scale, store to ofmap*/
    "compgeq resadd, reg0, reg1, resadd, reg3",  // reg3 = resadd > threshold ? 0 : resadd
    "redmax reg3, reg4, 32",                     // reg4 = reduce_max(reg3)
    "rdcrossoc 1",
    "compgeq resadd, reg0, reg1, resadd, reg3",  // reg3 = resadd > threshold ? 0 : resadd
    "redmax reg3, reg5, 32",                     // reg5 = reduce_max(reg3)
    "compgeq reg5, reg4, reg5, reg4, reg4",      // reg4 = reg5 > reg4 ? reg5 : reg4
    "rec reg4, reg4",                            // reg4 = 1 / reg4
    "mulc reg4, reg4, " + std::to_string(127),   // reg4 = 127 * reg4
    "rdcrossoc 0",
    "compgeq resadd, reg0, resadd, reg1, reg5",  // reg5 = resadd > threshold ? resadd : 0
    "redmax reg5, reg6, 32",                     // reg6 = reduce_max(reg5)
    "rdcrossoc 1",
    "compgeq resadd, reg0, resadd, reg1, reg5",  // reg5 = resadd > threshold ? resadd : 0
    "redmax reg5, reg7, 32",                     // reg6 = reduce_max(reg5)
    "compgeq reg7, reg6, reg7, reg6, reg6",      // reg5 = resadd > threshold ? resadd : 0
    "compgreat reg6, reg1, reg6, reg11, reg6",   // reg6 = reg6 > threshold ? 1.0 : reg6
    "rec reg6, reg6",                            // reg6 = 1 / reg6
    "mulc reg6, reg6, " + std::to_string(127),   // reg6 = 127 * reg6
    "copy reg1, reg13",                          // reg1 = reg4 & 0x2
    "maskb reg6, reg13, 0, 2",                   // reg1 = reg6 & 0x1
    "maskb reg4, reg13, 1, 1",                   // reg1 = reg4 & 0x2
    "wrcrossoc 0, 1, 4, reg13",                  // write reg1 to ofmap, dtype=float16

    /* 3.2 Quant */
    "compgeq resadd, reg0, reg1, psum, reg3",  // reg3 = resdd > threshold ? psum : 0
    "compgeq resadd, reg0, psum, reg1, reg5",  // reg5 = psum > threshold ? psum : 0
    "mul reg3 reg4, reg3",                     // reg3 = reg3 * reg4
    "mul reg5 reg6, reg5",                     // reg5 = reg5 * reg6
    "add reg3 reg5, reg3",                     // reg3 = reg3 + reg5
    "wrcrossoc 1, 0, 0, reg3",                 // write reg3 to psum, dtype=int4
    "rdcrossoc 0",
    "compgeq resadd, reg0, reg1, psum, reg3",  // reg3 = resdd > threshold ? psum : 0
    "compgeq resadd, reg0, psum, reg1, reg5",  // reg5 = psum > threshold ? psum : 0
    "mul reg3 reg4, reg3",                     // reg3 = reg3 * reg4
    "mul reg5 reg6, reg5",                     // reg5 = reg5 * reg6
    "add reg3 reg5, reg3"                      // reg3 = reg3 + reg5
  });

  auto   num_vcucodes      = vcucode_series.size();
  size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  vcucode_series.resize(vcucode_ddr_lines * 8, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  std::vector<insn::instruction> insn_series;

  insn_series.push_back(insn::load_iteration_2<0>(rec_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));

  insn_series.push_back(
    insn::load_iteration_2<0>(log_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64 * 128 / 256, 0));

  insn_series.push_back(
    insn::load_iteration_2<0>(exp_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 2 * 64 * 128 / 256, 0));

  insn_series.push_back(
    insn::load_iteration_2<0>(rsqrt_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 3 * 64 * 128 / 256, 0));

  insn_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  auto seq_1_offset = split_exp_fra(seq_len * oc_group_size * 4);

  insn_series.push_back(insn::load_iteration_2<0>(
    data_in_ddr_base_addr, seq_len * 4 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_PSUM_ADDR, 0));

  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);
  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());

  using vcu_t = vcu::VcuExecute;
  vcu_t vcu_op;

  /* 0. config */
  vcu_t::Arguments config_args = {0b111,            // psum_data_type
                                  0b011,            // resadd_para_type
                                  0b111,            // data_out_type
                                  0b10,             // data_out_ram
                                  4,                // opcode_number
                                  0,                // opcode_addr
                                  0b0000000000000,  // psum_in_addr
                                  0b000000,         // para_in_addr
                                  0b000000000000,   // resadd_in_addr
                                  0b0000000000000,  // ram_out_addr
                                  0,                // seq_len
                                  0,                // oc_group
                                  0b00,             // para_func
                                  0,
                                  0,
                                  0};
  auto             config_insn = vcu_op(config_args);
  insn_series.insert(insn_series.end(), config_insn.begin(), config_insn.end());

  /* 1. abs */
  vcu_t::Arguments abs_args  = {0b111,                   // psum_data_type
                                0b011,                   // resadd_para_type
                                0b111,                   // data_out_type
                                0b10,                    // data_out_ram
                                1,                       // opcode_number
                                4,                       // opcode_addr
                                0b0000000000000,         // psum_in_addr
                                0b000000,                // para_in_addr
                                0b000000000000,          // resadd_in_addr
                                0b0000000000000,         // ram_out_addr
                                (uint64_t)seq_len - 1,   // seq_len
                                (uint64_t)oc_group - 1,  // oc_group
                                0b00,                    // para_func
                                1,
                                0,
                                0};
  auto             abs_insns = vcu_op(abs_args);
  insn_series.insert(insn_series.end(), abs_insns.begin(), abs_insns.end());
  /* 2. Get outlier_index */
  vcu_t::Arguments outlier_index_args  = {0b111,                         // psum_data_type
                                          0b011,                         // resadd_para_type
                                          0b111,                         // data_out_type
                                          0,                             // data_out_ram
                                          6,                             // opcode_number
                                          5,                             // opcode_addr
                                          0b0000000000000,               // psum_in_addr
                                          0b000000,                      // para_in_addr
                                          0b000000000000,                // resadd_in_addr
                                          (uint64_t)seq_len * oc_group,  // ram_out_addr
                                          (uint64_t)seq_len - 1,         // seq_len
                                          (uint64_t)oc_group - 2,        // oc_group
                                          0b00,                          // para_func
                                          0,
                                          1,
                                          0,
                                          1};
  auto             outlier_index_insns = vcu_op(outlier_index_args);
  insn_series.insert(insn_series.end(), outlier_index_insns.begin(), outlier_index_insns.end());

  seq_1_offset = split_exp_fra(seq_len * oc_group_size);
  for (int i = 0; i < oc_group / 2; ++i) {
    insn_series.push_back(insn::store_iteration_2<0>(data_out_ddr_base_addr + 0x10000 + i * seq_len * oc_group_size,
                                                     seq_len - 1,
                                                     0,
                                                     0,
                                                     0,
                                                     MASTER_PSUM_ADDR + seq_len * oc_group + i * 2 * seq_len,
                                                     0));
  }

  /* 3.1 Compute scale */
  vcu_t::Arguments scale_index_args  = {0b111,                   // psum_data_type
                                        0b011,                   // resadd_para_type
                                        0,                       // data_out_type
                                        0,                       // data_out_ram
                                        34,                      // opcode_number
                                        11,                      // opcode_addr
                                        0b0000000000000,         // psum_in_addr
                                        0b000000,                // para_in_addr
                                        0b000000000000,          // resadd_in_addr
                                        0b0000000000000,         // ram_out_addr
                                        (uint64_t)seq_len - 1,   // seq_len
                                        (uint64_t)oc_group - 2,  // oc_group
                                        0b00,                    // para_func
                                        1,
                                        1,
                                        0,
                                        1};
  auto             scale_index_insns = vcu_op(scale_index_args);
  insn_series.insert(insn_series.end(), scale_index_insns.begin(), scale_index_insns.end());

  // 3.2 parallelism convertion
  using vcu_convertion_t                      = vcu::VcuParallelismConvertion;
  vcu_convertion_t::Arguments convertion_args = {1, 0, 0x28, (uint64_t)seq_len, (uint64_t)oc_group, (uint64_t)oc_group / 2};
  vcu_convertion_t            vcu_convertion;
  auto                        vcu_convertion_insn = vcu_convertion(convertion_args);
  insn_series.insert(insn_series.end(), vcu_convertion_insn.begin(), vcu_convertion_insn.end());

  // 4: Store scale
  for (int i = 0; i < oc_group / 2; ++i) {
    insn_series.push_back(insn::store_iteration_2<0>(
      data_out_ddr_base_addr + 0x20000 + i * seq_len * oc_group_size, seq_len - 1, 0, 0, 0, MASTER_OFMAP_ADDR + i * 2 * seq_len, 0));
  }

  /* 5. Store */
  insn_series.push_back(insn::store_iteration_2<0>(data_out_ddr_base_addr,
                                                   seq_len - 1,
                                                   seq_1_offset.first,
                                                   seq_1_offset.second,
                                                   oc_group / 2 - 1,
                                                   MASTER_OFMAP_ADDR + seq_len * oc_group,
                                                   1));

  common::insn::pad_serial_sync_word(insn_series);

  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

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
             PSUM_STORE_256,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}