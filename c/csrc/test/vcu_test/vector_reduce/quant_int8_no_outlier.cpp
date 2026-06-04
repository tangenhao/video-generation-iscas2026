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

  int   seq_len       = 8;
  int   d_model       = 256;
  int   oc_group_size = 32;
  int   oc_group      = d_model / oc_group_size;

  uint64_t rec_lut_ddr_base_addr   = REC_LUT_ADDR;
  uint64_t log_lut_ddr_base_addr   = LOG_LUT_ADDR;
  uint64_t exp_lut_ddr_base_addr   = EXP_LUT_ADDR;
  uint64_t rsqrt_lut_ddr_base_addr = RSQRT_LUT_ADDR;
  uint64_t data_in_ddr_base_addr   = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  auto data_in = randn<float>({oc_group, seq_len, oc_group_size}, kFloat32, -10.0f, 10.0f, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  auto data_out_temp = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);
  auto data_out      = zeros<int8_t>({oc_group, seq_len, oc_group_size}, kInt8);
  auto scale         = zeros<float>({oc_group, seq_len}, kFloat32);

  for (int i = 0; i < oc_group; ++i) {
    for (int j = 0; j < seq_len; ++j) {
      float         row_max_normal  = -1e9;
      Tensor<float> row             = zeros<float>({oc_group_size}, kFloat32);
      for (int k = 0; k < oc_group_size; ++k) {
        row[k] = data_in[i * seq_len * oc_group_size + j * oc_group_size + k];
      }
      Tensor<float> row_abs = row.abs();
      Tensor<float> normal  = zeros<float>({oc_group_size}, kFloat32);
      for (int k = 0; k < oc_group_size; ++k) {
        normal[k] = row_abs[k]; 
      }
      for (int k = 0; k < oc_group_size; ++k) {
        row_max_normal = std::max(row_max_normal, normal[k]);
      }

      scale[i * seq_len + j] = 127 * compute_model::function::reciprocal_c(row_max_normal);

      for (int k = 0; k < oc_group_size; ++k) {
        data_out_temp[i * seq_len * oc_group_size + j * oc_group_size + k] =
          data_in[i * seq_len * oc_group_size + j * oc_group_size + k] * (127 * compute_model::function::reciprocal_c(row_max_normal));
      }
    }
  }

  data_out = ToInt8(data_out_temp);
  // std::cout << std::hex << "data_out:" << data_out << std::endl;

  auto ifmap_scale = ToFloat16(scale);
  // std::cout << "ifmap_scale:" << ifmap_scale << std::endl;

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/ifmap_scale.txt", (char*)ifmap_scale.data_ptr(), ifmap_scale.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out.data_ptr()), data_out.numel() * sizeof(int8_t), 32, true);
  // common::file_utils::saveCharArrayToFormattedTextFile(
  //   ofmap_file.c_str(), reinterpret_cast<char*>(data_out_temp.data_ptr()), data_out_temp.numel() * sizeof(float), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */

  auto vcucode_series = vcu::asm_vcu_op({
    /* Compute scale, store to ofmap */
    "absm psum, reg1",
    "redmax reg1, reg2, 32",                     
    "rec reg2, reg3",                            
    "mulc reg3, reg0, " + std::to_string(127),   
    /* Change fp32 into fp16 */
    "copy resadd, reg0",
    /* Quant */
    "mul psum resadd, reg1"
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

  insn_series.push_back(insn::load_iteration_2(rec_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));

  insn_series.push_back(insn::load_iteration_2(log_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64 * 128 / 256, 0));

  insn_series.push_back(
    insn::load_iteration_2(exp_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 2 * 64 * 128 / 256, 0));

  insn_series.push_back(
    insn::load_iteration_2(rsqrt_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 3 * 64 * 128 / 256, 0));

  insn_series.push_back(insn::load_iteration_2(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  auto seq_1_offset = split_exp_fra(seq_len * oc_group_size * 4);
  auto seq_2_offset = split_exp_fra(seq_len * oc_group_size * 2);
  auto seq_3_offset = split_exp_fra(seq_len * oc_group_size);

  insn_series.push_back(insn::load_iteration_2(
    data_in_ddr_base_addr, seq_len * 4 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_PSUM_ADDR, 0));

  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);
  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());

  using vcu_t = vcu::VcuExecute;
  vcu_t vcu_op;
  
  /* Compute scale, store to resadd */
  vcu_t::Arguments scale_args = {0b100,                  // psum_data_type(fp32)
                                 0b011,                  // resadd_para_type(fp32)
                                 0b111,                  // data_out_type(fp32)
                                 0b10,                   // data_out_ram(resadd) 
                                 4,                      // opcode_number
                                 0,                      // opcode_addr
                                 0b0000000000000,        // psum_in_addr
                                 0b000000,               // para_in_addr
                                 0b000000000000,         // resadd_in_addr
                                 0b0000000000000,        // ram_out_addr
                                 (uint64_t)seq_len - 1,  // seq_len
                                 (uint64_t)oc_group - 1, // oc_group
                                 0b00,                   // para_func
                                 1,
                                 0,
                                 0};
  auto             scale_insn = vcu_op(scale_args);
  insn_series.insert(insn_series.end(), scale_insn.begin(), scale_insn.end());

  /* Change fp32 into fp16 */
  vcu_t::Arguments copy_args = {0b100,                  // psum_data_type(fp32)
                                0b011,                  // resadd_para_type(fp32)
                                0b100,                  // data_out_type(fp16)
                                0b01,                   // data_out_ram(ofmap) 
                                1,                      // opcode_number
                                4,                      // opcode_addr
                                0b0000000000000,        // psum_in_addr
                                0b000000,               // para_in_addr
                                0b000000000000,         // resadd_in_addr
                                0b0000000000000,        // ram_out_addr
                                (uint64_t)seq_len - 1,  // seq_len
                                (uint64_t)oc_group - 1, // oc_group
                                0b00,                   // para_func
                                1,
                                1,
                                0};
  auto             copy_insn = vcu_op(copy_args);
  insn_series.insert(insn_series.end(), copy_insn.begin(), copy_insn.end());

  /* Store scale */
  insn_series.push_back(insn::store_iteration_2(
    data_out_ddr_base_addr + 0x20000, seq_len * 2- 1, seq_2_offset.first, seq_2_offset.second, oc_group - 1, MASTER_OFMAP_ADDR, 0));

  /* Quant */
  vcu_t::Arguments quant_args = {0b100,                  // psum_data_type(fp32)
                                 0b011,                  // resadd_para_type(fp32)
                                 0b001,                  // data_out_type(int8)
                                 0b01,                   // data_out_ram(ofmap)
                                 1,                      // opcode_number
                                 5,                      // opcode_addr
                                 0b0000000000000,        // psum_in_addr
                                 0b000000,               // para_in_addr
                                 0b000000000000,         // resadd_in_addr
                                 0b0000000000000,        // ram_out_addr
                                 (uint64_t)seq_len - 1,  // seq_len
                                 (uint64_t)oc_group - 1, // oc_group
                                 0b00,                   // para_func
                                 1,
                                 1,
                                 0};
  auto             quant_insns = vcu_op(quant_args);
  insn_series.insert(insn_series.end(), quant_insns.begin(), quant_insns.end());

  /* Store output */
  insn_series.push_back(insn::store_iteration_2(
    data_out_ddr_base_addr, seq_len - 1, seq_3_offset.first, seq_3_offset.second, oc_group - 1, MASTER_OFMAP_ADDR, 1));

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
             PSUM_STORE_1024,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}