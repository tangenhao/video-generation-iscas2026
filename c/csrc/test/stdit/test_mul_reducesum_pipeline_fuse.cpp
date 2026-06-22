#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
// #include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include <algorithm>
#include <cstdint>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <vector>

using compute_model::common::fp16::half;

std::string fp16_hex(half value)
{
  std::ostringstream oss;
  oss << "0x" << std::hex << std::setw(4) << std::setfill('0') << value.storage;
  return oss.str();
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

std::pair<int, int> split_exp_fra(int64_t x)
{
  if (x > 8355840) {
    throw std::runtime_error("x is too large");
  }
  int max_fra = (1 << 8) - 1;
  int exp     = 0;
  while (x > max_fra) {
    x /= 2;
    exp++;
  }
  return {exp, static_cast<int>(x)};
}

half add_half(half lhs, half rhs)
{
  return half(static_cast<float>(lhs) + static_cast<float>(rhs));
}

half reduce_tree_32(std::vector<half> values)
{
  while (values.size() > 1) {
    std::vector<half> next;
    next.reserve(values.size() / 2);
    for (size_t i = 0; i < values.size(); i += 2) {
      next.push_back(add_half(values[i], values[i + 1]));
    }
    values.swap(next);
  }
  return values[0];
}

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;

  // Pair-fuse target:
  //   stream_en = 1 && opcode_number = 2
  //   code0 = stream MUL, code1 = REDUCE_SUM
  // Each execute consumes d_model / 32 beats. The second execute starts from
  // the next sequence row with acc_clear=1. If the stream accumulator is not
  // cleared, seq1 becomes seq0 + seq1 instead of seq1.
  int seq_len       = 2;
  int d_model       = 1152;
  int oc_group_size = 32;
  int oc_group      = d_model / oc_group_size;

  uint64_t psum_data_type        = vcu_psum_dtype.at(kHalf);
  uint64_t resadd_para_type      = vcu_resadd_dtype.at(kHalf);
  uint64_t data_out_type         = vcu_out_dtype.at(kHalf);
  uint64_t para_func             = 0b00;
  uint64_t bytes_input           = sizeof(half);
  uint64_t bytes_output          = sizeof(half);
  uint64_t data_in_ddr_base_addr = IFMAP_ADDR;
  uint64_t data_para_ddr_base_addr = VCUPARA_ADDR;
  uint64_t data_out_ddr_base_addr  = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 data gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  auto data_in = randn<half>({seq_len, oc_group, oc_group_size}, kHalf, half(0.25f), half(1.0f), 0);
  auto data_para_random = randn<half>({seq_len, oc_group, oc_group_size}, kHalf, half(0.001f), half(0.004f), 1);
  Tensor<half> data_para({seq_len, oc_group, oc_group_size}, kHalf);
  Tensor<half> mul_golden({seq_len, oc_group, oc_group_size}, kHalf);
  Tensor<half> data_out({seq_len, 1, oc_group_size}, kHalf);
  std::vector<half> seq_sum(seq_len);

  for (int seq = 0; seq < seq_len; ++seq) {
    for (int group = 0; group < oc_group; ++group) {
      for (int lane = 0; lane < oc_group_size; ++lane) {
        int idx = (seq * oc_group + group) * oc_group_size + lane;
        data_para[idx] = seq == 0 ? data_para_random[idx] : half(-static_cast<float>(data_para_random[idx]));
      }
    }
  }

  for (int seq = 0; seq < seq_len; ++seq) {
    half sum(0.0f);
    for (int group = 0; group < oc_group; ++group) {
      std::vector<half> group_values;
      group_values.reserve(oc_group_size);
      for (int lane = 0; lane < oc_group_size; ++lane) {
        int idx         = (seq * oc_group + group) * oc_group_size + lane;
        mul_golden[idx] = data_in[idx] * data_para[idx];
        group_values.push_back(mul_golden[idx]);
      }
      sum = add_half(reduce_tree_32(group_values), sum);
    }
    seq_sum[seq] = sum;
    for (int lane = 0; lane < oc_group_size; ++lane) {
      data_out[seq * oc_group_size + lane] = sum;
    }
  }

  half seq1_with_stale_acc = half(static_cast<float>(seq_sum[0]) + static_cast<float>(seq_sum[1]));

  std::cout << std::fixed << std::setprecision(6);
  std::cout << "\n================ mul -> reduce_sum pair-fuse golden ================\n";
  std::cout << "shape: seq_len=" << seq_len << ", d_model=" << d_model << ", oc_group=" << oc_group
            << ", lanes/beat=" << oc_group_size << "\n";
  std::cout << "dtype: fp16, stream_en=1, opcode_number=2, code0=mul ifmap para, code1=redsum reg0\n";
  std::cout << "beats per execute: " << oc_group << " (RTL consumes 32 lanes/cycle)\n";
  std::cout << "acc_clear check: seq1 expected " << fp16_hex(seq_sum[1]) << " (" << static_cast<float>(seq_sum[1])
            << "), stale-acc failure would be " << fp16_hex(seq1_with_stale_acc) << " ("
            << static_cast<float>(seq1_with_stale_acc) << ")\n";
  for (int seq = 0; seq < seq_len; ++seq) {
    int base = seq * oc_group * oc_group_size;
    std::cout << "  seq[" << seq << "] group[0] ifmap :";
    for (int lane = 0; lane < oc_group_size; ++lane) {
      std::cout << " " << fp16_hex(data_in[base + lane]);
    }
    std::cout << "\n";

    std::cout << "  seq[" << seq << "] group[0] para  :";
    for (int lane = 0; lane < oc_group_size; ++lane) {
      std::cout << " " << fp16_hex(data_para[base + lane]);
    }
    std::cout << "\n";

    std::cout << "  seq[" << seq << "] group[0] mul   :";
    for (int lane = 0; lane < oc_group_size; ++lane) {
      std::cout << " " << fp16_hex(mul_golden[base + lane]);
    }
    std::cout << "\n";

    std::cout << "  seq[" << seq << "] redsum over d_model: " << fp16_hex(seq_sum[seq]) << " ("
              << static_cast<float>(seq_sum[seq]) << "), broadcast to 32 lanes\n";
  }
  print_bytes_right_low("IFMAP fp16 DDR/wave hex", data_in.data_ptr(), data_in.numel() * sizeof(half), 32);
  print_bytes_right_low("VCUPARA fp16 DDR/wave hex", data_para.data_ptr(), data_para.numel() * sizeof(half), 32);
  print_bytes_right_low("MUL fp16 golden DDR/wave hex", mul_golden.data_ptr(), mul_golden.numel() * sizeof(half), 32);
  print_bytes_right_low("REDSUM fp16 OFMAP golden DDR/wave hex", data_out.data_ptr(), data_out.numel() * sizeof(half), 32);
  std::cout << "====================================================================\n\n";

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(data_para.data_ptr()), data_para.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile("../../sim/memory/mul_golden.txt",
                                                       reinterpret_cast<char*>(mul_golden.data_ptr()),
                                                       mul_golden.numel() * sizeof(half),
                                                       32,
                                                       true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out.data_ptr()), data_out.numel() * sizeof(half), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */

  auto vcucode_series = vcu::asm_vcu_op({
    "mul ifmap para, reg0",
    "redsum reg0, reg11, 32",
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

  auto seq_in_offset  = split_exp_fra(oc_group * oc_group_size * bytes_input);
  auto seq_out_offset = split_exp_fra(oc_group_size * bytes_output);

  insn_series.push_back(insn::load_iteration_2<0>(data_in_ddr_base_addr,
                                                  oc_group * bytes_input * oc_group_size / 32 - 1,
                                                  seq_in_offset.first,
                                                  seq_in_offset.second,
                                                  seq_len - 1,
                                                  MASTER_IFMAP_ADDR,
                                                  0));

  insn_series.push_back(insn::load_iteration_2<0>(data_para_ddr_base_addr,
                                                  oc_group * bytes_input * oc_group_size / 32 - 1,
                                                  seq_in_offset.first,
                                                  seq_in_offset.second,
                                                  seq_len - 1,
                                                  MASTER_VCUPARA_ADDR,
                                                  0));

  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);

  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());

  using vcu_t = vcu::VcuExecute;
  vcu_t vcu_op;

  for (uint64_t seq = 0; seq < static_cast<uint64_t>(seq_len); ++seq) {
    uint64_t seq_base_addr = seq * oc_group;
    vcu_t::Arguments args = {
      psum_data_type,
      resadd_para_type,
      data_out_type,
      VcuOutSram::PSUM,  // data_out_ram
      num_vcucodes,     // opcode_number: pair-fuse trigger requires 2
      0,                // opcode_addr
      0,                // psum_in_addr
      seq_base_addr,    // para_in_addr
      0,                // resadd_in_addr
      seq,              // ram_out_addr
      (uint64_t)oc_group - 1, // num_data: d_model / 32 beats
      0,                // oc_group
      para_func,
      0,                // psum_sram_valid
      0,                // resadd_sram_valid
      1,                // para_sram_valid
      0,                // psum_addr_hop
      1,                // acc_clear
      1,                // stream_en
      1,                // ifmap_sram_valid
      seq_base_addr     // ifmap_in_addr
    };
    auto vcu_insns = vcu_op(args);
    insn_series.insert(insn_series.end(), vcu_insns.begin(), vcu_insns.end());
  }

  insn_series.push_back(insn::store_iteration_2<0>(data_out_ddr_base_addr,
                                                   bytes_output * oc_group_size / 32 - 1,
                                                   seq_out_offset.first,
                                                   seq_out_offset.second,
                                                   seq_len - 1,
                                                   MASTER_PSUM_ADDR,
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