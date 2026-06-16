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
#include <algorithm>
#include <cstdint>
#include <iomanip>
#include <sstream>
#include <vector>

using compute_model::common::fp16::half;

std::string fp16_hex(half value)
{
  std::ostringstream oss;
  oss << "0x" << std::hex << std::setw(4) << std::setfill('0') << value.storage;
  return oss.str();
}

std::string u8_hex(uint8_t value)
{
  std::ostringstream oss;
  oss << "0x" << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(value);
  return oss.str();
}

int8_t fp16_to_int8_quant_golden(half value)
{
  uint16_t in_data = value.storage;

  bool     f_sign = (in_data >> 15) & 0x1;
  uint16_t f_exp  = (in_data >> 10) & 0x1f;
  uint16_t f_frac = in_data & 0x03ff;

  bool zero   = (f_exp == 0) && (f_frac == 0);
  bool nan    = (f_exp == 0x1f) && (f_frac != 0);
  bool normal = f_exp != 0;

  int f_exp_ext     = static_cast<int>(f_exp) - 15;
  bool in_round     = normal && (f_exp_ext >= -1) && (f_exp_ext <= 6);
  bool overflow     = normal && (f_exp_ext >= 7);
  int  magnitude    = 0;

  if (nan || zero) {
    magnitude = 0;
  }
  else if (overflow) {
    magnitude = f_sign ? 128 : 127;
  }
  else if (in_round) {
    uint16_t significand     = 0x0400 | f_frac;
    uint16_t significand_ext = significand;
    int      right_shift     = 10 - f_exp_ext;
    int      int_part        = significand_ext >> right_shift;
    int      frac_mask       = (1 << right_shift) - 1;
    int      frac_part       = significand_ext & frac_mask;
    int      half_part       = 1 << (right_shift - 1);
    bool     round_inc       = (frac_part > half_part) || ((frac_part == half_part) && (int_part & 0x1));
    magnitude                = int_part + (round_inc ? 1 : 0);
  }

  magnitude = f_sign ? std::min(magnitude, 128) : std::min(magnitude, 127);
  return static_cast<int8_t>(f_sign ? -magnitude : magnitude);
}

void print_bytes_right_low(const char* title, const void* data, size_t data_size, size_t bytes_per_line)
{
  const uint8_t* bytes = reinterpret_cast<const uint8_t*>(data);
  std::cout << title << " (rightLow, " << bytes_per_line << "B/line):\n";
  for (size_t base = 0; base < data_size; base += bytes_per_line) {
    size_t line_bytes = std::min(bytes_per_line, data_size - base);
    std::cout << "  [" << std::dec << std::setw(4) << (base / bytes_per_line) << "] 0x";
    for (size_t i = 0; i < line_bytes; ++i) {
      size_t idx = base + line_bytes - 1 - i;
      std::cout << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(bytes[idx]);
    }
    std::cout << std::dec << std::setfill(' ') << "\n";
  }
}

half abs_half(half value)
{
  return half(static_cast<uint16_t>(value.storage & 0x7fff));
}

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

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;

  // fuse mode：stream_en=1 && opcode_number=2 时读取两条 vcucode，并识别 pair-fuse：
  // code0 = stream ewise/FPU op，code1 = reduce_sum/max
  // 增加 stream_ewise_reduce 旁路。ABS/INV 这类 reverse 输出、以及 MUL 输出，不再走 stream ewise 写回，而是直接压进现有 reduce tree。第二条 reduce opcode 提供 reduce 类型和 dst
  // opcode_number = 2; stream_en = 1;

  int seq_len              = 1;
  int d_model              = 1152;
  int d_model_weight       = 1152;
  int oc_group_size        = 36;
  int oc_group             = d_model / oc_group_size;
  int oc_group_weight      = d_model_weight / oc_group_size;

  uint64_t psum_data_type        = vcu_psum_dtype.at(kHalf);
  uint64_t resadd_para_type      = vcu_resadd_dtype.at(kHalf);
  uint64_t para_func        = 0b00;
  uint64_t bytes_input      = sizeof(half);
  uint64_t bytes_output     = sizeof(int8_t);

  uint64_t data_in1_ddr_base_addr  = IFMAP_ADDR;
  uint64_t data_in2_ddr_base_addr  = VCUPARA_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 data gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  auto data_in = randn<half>({oc_group, seq_len, oc_group_size}, kHalf, half(-2.0f), half(2.0f), 0);
  auto data_para = randn<half>({oc_group_weight, seq_len, oc_group_size}, kHalf, half(0.5f), half(1.5f), 0);

  Tensor<half>   abs_data({oc_group, seq_len, oc_group_size}, kHalf);
  Tensor<half>   redmax_data({oc_group, seq_len, oc_group_size}, kHalf);
  Tensor<half>   quant_fp16({oc_group, seq_len, oc_group_size}, kHalf);
  Tensor<int8_t> data_out({oc_group, seq_len, oc_group_size}, kInt8);
  Tensor<half>   scale_data({oc_group_weight, seq_len, oc_group_size}, kHalf);

  half              max_abs = abs_half(data_in[0]);
  std::vector<half> row_abs_max(oc_group * seq_len);
  for (int row = 0; row < oc_group * seq_len; ++row) {
    half row_max = abs_half(data_in[row * oc_group_size]);
    for (int j = 0; j < oc_group_size; ++j) {
      int  idx       = row * oc_group_size + j;
      half abs_value = abs_half(data_in[idx]);
      abs_data[idx]  = abs_value;
      if (static_cast<float>(abs_value) > static_cast<float>(row_max)) {
        row_max = abs_value;
      }
      if (static_cast<float>(abs_value) > static_cast<float>(max_abs)) {
        max_abs = abs_value;
      }
    }
    row_abs_max[row] = row_max;
    for (int j = 0; j < oc_group_size; ++j) {
      redmax_data[row * oc_group_size + j] = row_max;
    }
  }

  half inv_127(static_cast<uint16_t>(0x2008));
  half ascale     = max_abs * inv_127;
  half inv_ascale = static_cast<float>(ascale) == 0.0f ? half(0.0f) : half(1.0f / static_cast<float>(ascale));

  for (int i = 0; i < data_out.numel(); ++i) {
    quant_fp16[i]      = data_in[i] * inv_ascale;
    data_out[i]        = fp16_to_int8_quant_golden(quant_fp16[i]);
  }

  for (int i = 0; i < scale_data.numel(); ++i) {
    scale_data[i] = ascale * data_para[i];
  }

  std::cout << std::fixed << std::setprecision(6);
  std::cout << "\n================ quant fp16->int8 golden ================\n";
  std::cout << "shape: oc_group=" << oc_group << ", seq_len=" << seq_len << ", oc_group_size=" << oc_group_size << "\n";
  std::cout << "input dtype: fp16, output dtype: int8\n";
  std::cout << "round: round_to_nearest_even, clamp: saturate_s8 [-128, 127]\n";
  std::cout << "step0: abs(ifmap) -> psum\n";
  std::cout << "step1: redmax(psum) -> global max_abs = " << fp16_hex(max_abs) << " (" << static_cast<float>(max_abs) << ")\n";
  std::cout << "step2: ascale=max_abs*0x2008 = " << fp16_hex(ascale) << " (" << static_cast<float>(ascale)
            << "), inv_ascale=rec(ascale) = " << fp16_hex(inv_ascale) << " (" << static_cast<float>(inv_ascale) << ")\n";
  std::cout << "step3: scale=ascale*wscale, weight_scale groups=" << oc_group_weight << "\n";
  std::cout << "step4: qact=round_even_saturate_s8(fp16(ifmap*inv_ascale))\n";
  std::cout << "row abs max values:\n";
  for (int row = 0; row < oc_group * seq_len; ++row) {
    std::cout << "  row[" << std::setw(2) << row << "] abs_max = " << fp16_hex(row_abs_max[row]) << " (" << std::setw(10)
              << static_cast<float>(row_abs_max[row]) << ")\n";
  }
  std::cout << "per-row lane hex (* marks global abs max):\n";
  for (int row = 0; row < oc_group * seq_len; ++row) {
    std::cout << "  row[" << std::setw(2) << row << "] ifmap_fp16:";
    for (int j = 0; j < oc_group_size; ++j) {
      int  idx           = row * oc_group_size + j;
      bool is_global_max = abs_data[idx].storage == max_abs.storage;
      std::cout << " " << (is_global_max ? "*" : " ") << fp16_hex(data_in[idx]);
    }
    std::cout << "\n";

    std::cout << "  row[" << std::setw(2) << row << "] abs_fp16  :";
    for (int j = 0; j < oc_group_size; ++j) {
      int idx = row * oc_group_size + j;
      std::cout << "  " << fp16_hex(abs_data[idx]);
    }
    std::cout << "\n";

    std::cout << "  row[" << std::setw(2) << row << "] redmax32  :";
    for (int j = 0; j < oc_group_size; ++j) {
      int idx = row * oc_group_size + j;
      std::cout << "  " << fp16_hex(redmax_data[idx]);
    }
    std::cout << "\n";

    std::cout << "  row[" << std::setw(2) << row << "] q_fp16    :";
    for (int j = 0; j < oc_group_size; ++j) {
      int idx = row * oc_group_size + j;
      std::cout << "  " << fp16_hex(quant_fp16[idx]);
    }
    std::cout << "\n";

    std::cout << "  row[" << std::setw(2) << row << "] q_int8    :";
    for (int j = 0; j < oc_group_size; ++j) {
      int idx = row * oc_group_size + j;
      std::cout << "  " << u8_hex(static_cast<uint8_t>(data_out[idx]));
    }
    std::cout << "\n";

    if (row < oc_group_weight * seq_len) {
      std::cout << "  row[" << std::setw(2) << row << "] wscale    :";
      for (int j = 0; j < oc_group_size; ++j) {
        int idx = row * oc_group_size + j;
        std::cout << "  " << fp16_hex(data_para[idx]);
      }
      std::cout << "\n";

      std::cout << "  row[" << std::setw(2) << row << "] as*wscale :";
      for (int j = 0; j < oc_group_size; ++j) {
        int idx = row * oc_group_size + j;
        std::cout << "  " << fp16_hex(scale_data[idx]);
      }
      std::cout << "\n";
    }
  }
  print_bytes_right_low("IFMAP fp16 DDR/wave hex", data_in.data_ptr(), data_in.numel() * sizeof(half), 32);
  print_bytes_right_low("VCUPARA wscale fp16 DDR/wave hex", data_para.data_ptr(), data_para.numel() * sizeof(half), 32);
  print_bytes_right_low("STEP0 abs fp16 DDR/wave hex", abs_data.data_ptr(), abs_data.numel() * sizeof(half), 32);
  print_bytes_right_low("STEP1 redmax per 32-lane group fp16 DDR/wave hex", redmax_data.data_ptr(), redmax_data.numel() * sizeof(half), 32);
  print_bytes_right_low("STEP3 ascale*wscale fp16 DDR/wave hex", scale_data.data_ptr(), scale_data.numel() * sizeof(half), 32);
  print_bytes_right_low("STEP4 qact int8 OFMAP golden DDR/wave hex", data_out.data_ptr(), data_out.numel() * sizeof(int8_t), 32);
  std::cout << "==========================================================\n\n";

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(data_para.data_ptr()), data_para.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/abs_ifmap_golden.txt", reinterpret_cast<char*>(abs_data.data_ptr()), abs_data.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/redmax_golden.txt", reinterpret_cast<char*>(redmax_data.data_ptr()), redmax_data.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/scale_golden.txt", reinterpret_cast<char*>(scale_data.data_ptr()), scale_data.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/qact_fp16_before_quant.txt", reinterpret_cast<char*>(quant_fp16.data_ptr()), quant_fp16.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out.data_ptr()), data_out.numel() * sizeof(int8_t), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */

  auto vcucode_series = vcu::asm_vcu_op({
    "absm ifmap, reg0",       // num_data_cnt=dim//32, write to psum0
    "redmax psum, reg0, 32",  // num_data_cnt=dim//32, write to reg0

    "mulc reg0, reg0, 0x2008", // num_data_cnt=1-1, write to reg0 (reg0=ascale)
    "rec reg0, reg2",         // num_data_cnt=1-1, write to reg2 (reg2=1/ascale)
    
    "mul reg0 para, reg1",    // num_data_cnt=dim_weight//32, write to scale

    "mul ifmap reg2, reg0", // num_data_cnt=dim//32, write to qact, data_out为int8; （round和clamp在data_out_convert.v中进行）
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

  insn_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  auto seq_in_offset   = split_exp_fra(d_model * bytes_input);
  auto seq_para_offset = split_exp_fra(d_model * bytes_input);
  auto seq_out_offset  = split_exp_fra(d_model * bytes_output);

  insn_series.push_back(insn::load_iteration_2<0>(data_in1_ddr_base_addr,
                                                  d_model * bytes_input / 32 - 1,
                                                  seq_in_offset.first,
                                                  seq_in_offset.second,
                                                  seq_len - 1,
                                                  MASTER_IFMAP_ADDR,
                                                  0));

  insn_series.push_back(insn::load_iteration_2<0>(data_in2_ddr_base_addr,
                                                  d_model * bytes_input / 32 - 1,
                                                  seq_para_offset.first,
                                                  seq_para_offset.second,
                                                  seq_len - 1,
                                                  MASTER_VCUPARA_ADDR,
                                                  0));                                                

  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);

  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());
  using vcu_t           = vcu::VcuExecute;
  vcu_t vcu_op;

  //0: |x_in| + redmax(|x_in|)
  vcu_t::Arguments step_0_config_args = {
    psum_data_type,
    resadd_para_type,
    vcu_out_dtype.at(kHalf),  // data_out_type
    VcuOutSram::PSUM,         // data_out_ram
    2,                        // opcode_number
    0,                        // opcode_addr
    0,                        // psum_in_addr
    0,                        // para_in_addr
    0,                        // resadd_in_addr  
    0,                        // ram_out_addr   
    (uint64_t)oc_group - 1,   // num_data_cnt
    (uint64_t)oc_group - 1,   // oc_group
    para_func,                // para_func
    0,                        // psum_sram_valid
    0,                        // resadd_sram_valid
    0,                        // para_sram_valid
    0,                        // psum_addr_hop
    0,                        // acc_clear
    1,                        // stream_en
    1,                        // ifmap_sram_valid
    0                         // ifmap_in_addr
  };
  auto             step_0_config_insns = vcu_op(step_0_config_args);
  insn_series.insert(insn_series.end(), step_0_config_insns.begin(), step_0_config_insns.end());

  //1: ascale(reg0)=max/127, recip(ascale, reg2)
  vcu_t::Arguments step_1_config_args = {
    psum_data_type,
    resadd_para_type,
    vcu_out_dtype.at(kHalf),  // data_out_type
    VcuOutSram::PSUM,         // data_out_ram
    2,                        // opcode_number
    2,                        // opcode_addr
    0,                        // psum_in_addr
    0,                        // para_in_addr
    0,                        // resadd_in_addr  
    0,                        // ram_out_addr   
    (uint64_t)1 - 1,          // num_data_cnt
    (uint64_t)1 - 1,          // oc_group
    para_func,                // para_func
    0,                        // psum_sram_valid
    0,                        // resadd_sram_valid
    0,                        // para_sram_valid
    0,                        // psum_addr_hop
    0,                        // acc_clear
    0,                        // stream_en
    0,                        // ifmap_sram_valid
    0                         // ifmap_in_addr
  };
  auto             step_1_config_insns = vcu_op(step_1_config_args);
  insn_series.insert(insn_series.end(), step_1_config_insns.begin(), step_1_config_insns.end());

  //2: ascale*wscale(reg1), store to scale.
  vcu_t::Arguments step_2_config_args = {
    psum_data_type,
    resadd_para_type,
    vcu_out_dtype.at(kHalf),  // data_out_type
    VcuOutSram::SCALE,        // data_out_ram
    1,                        // opcode_number
    4,                        // opcode_addr
    0,                        // psum_in_addr
    0,                        // para_in_addr
    0,                        // resadd_in_addr  
    0,                        // ram_out_addr   
    (uint64_t)oc_group_weight - 1, // num_data_cnt
    (uint64_t)oc_group_weight - 1, // oc_group
    para_func,                // para_func
    0,                        // psum_sram_valid
    0,                        // resadd_sram_valid
    1,                        // para_sram_valid
    0,                        // psum_addr_hop
    1,                        // acc_clear
    1,                        // stream_en
    0,                        // ifmap_sram_valid
    0                         // ifmap_in_addr
  };
  auto             step_2_config_insns = vcu_op(step_2_config_args);
  insn_series.insert(insn_series.end(), step_2_config_insns.begin(), step_2_config_insns.end());

  //3: x_in*inv_scale, store to qact.
  vcu_t::Arguments step_3_config_args = {
    psum_data_type,
    resadd_para_type,
    vcu_out_dtype.at(kInt8),  // data_out_type
    VcuOutSram::SCALE,        // data_out_ram
    1,                        // opcode_number
    5,                        // opcode_addr
    0,                        // psum_in_addr
    0,                        // para_in_addr
    0,                        // resadd_in_addr  
    0,                        // ram_out_addr   
    (uint64_t)oc_group - 1,   // num_data_cnt
    (uint64_t)oc_group - 1,   // oc_group
    para_func,                // para_func
    0,                        // psum_sram_valid
    0,                        // resadd_sram_valid
    0,                        // para_sram_valid
    0,                        // psum_addr_hop
    1,                        // acc_clear
    1,                        // stream_en
    1,                        // ifmap_sram_valid
    0                         // ifmap_in_addr
  };
  auto             step_3_config_insns = vcu_op(step_3_config_args);
  insn_series.insert(insn_series.end(), step_3_config_insns.begin(), step_3_config_insns.end());


  insn_series.push_back(insn::store_iteration_2<0>(data_out_ddr_base_addr,
                                                   d_model * bytes_output / 32 - 1,
                                                   seq_out_offset.first,
                                                   seq_out_offset.second,
                                                   seq_len - 1,
                                                   MASTER_OFMAP_ADDR,
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
             PSUM_STORE_1024,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}
