#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include <iomanip>
#include <sstream>
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

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;

  int seq_len       = 10;
  int d_model       = 128;
  int oc_group_size = 32;
  int oc_group      = d_model / oc_group_size;
  int bytes_input   = 2;

  uint64_t data_in_ddr_base_addr    = IFMAP_ADDR;
  uint64_t data_add_ddr_base_addr   = VCURES_ADDR;
  uint64_t data_mul_ddr_base_addr   = VCUPARA_ADDR;
  uint64_t data_out_ddr_base_addr   = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr     = VCUCODE_ADDR;

  // 生成三个随机输入数据
  auto data_in1 = randn<half>({oc_group, seq_len, oc_group_size}, kHalf, half(-1.0f), half(1.0f), 0);
  auto data_in2 = randn<half>({oc_group, seq_len, oc_group_size}, kHalf, half(-1.0f), half(1.0f), 1);
  auto data_in3 = randn<half>({oc_group, seq_len, oc_group_size}, kHalf, half(-1.0f), half(1.0f), 2);

  // 执行element-wise FMA运算
  Tensor<half> data_out({oc_group, seq_len, oc_group_size}, kHalf);
  for (int i = 0; i < data_out.numel(); ++i) {
    data_out[i] = half(static_cast<float>(data_in1[i]) * static_cast<float>(data_in3[i]) + static_cast<float>(data_in2[i]));
  }

  auto fp16_hex = [](half value) {
    std::ostringstream oss;
    oss << "0x" << std::hex << std::setw(4) << std::setfill('0') << value.storage;
    return oss.str();
  };

  std::cout << "\n================ fma elementwise pipeline golden ================\n";
  std::cout << "shape: oc_group=" << oc_group << ", seq_len=" << seq_len << ", lane=" << oc_group_size << "\n";
  std::cout << "dtype: input1 fp16 * input3 fp16 + input2 fp16 -> output fp16\n";
  for (int row = 0; row < oc_group * seq_len; ++row) {
    int group = row / seq_len;
    int seq   = row % seq_len;
    std::cout << "  row[" << std::setw(2) << row << "] oc=" << std::setw(2) << group << " seq=" << std::setw(2) << seq
              << " input1:";
    for (int lane = 0; lane < oc_group_size; ++lane) {
      std::cout << " " << fp16_hex(data_in1[row * oc_group_size + lane]);
    }
    std::cout << "\n";

    std::cout << "  row[" << std::setw(2) << row << "] oc=" << std::setw(2) << group << " seq=" << std::setw(2) << seq
              << " input2:";
    for (int lane = 0; lane < oc_group_size; ++lane) {
      std::cout << " " << fp16_hex(data_in2[row * oc_group_size + lane]);
    }
    std::cout << "\n";

    std::cout << "  row[" << std::setw(2) << row << "] oc=" << std::setw(2) << group << " seq=" << std::setw(2) << seq
              << " input3:";
    for (int lane = 0; lane < oc_group_size; ++lane) {
      std::cout << " " << fp16_hex(data_in3[row * oc_group_size + lane]);
    }
    std::cout << "\n";

    std::cout << "  row[" << std::setw(2) << row << "] oc=" << std::setw(2) << group << " seq=" << std::setw(2) << seq
              << " output:";
    for (int lane = 0; lane < oc_group_size; ++lane) {
      std::cout << " " << fp16_hex(data_out[row * oc_group_size + lane]);
    }
    std::cout << "\n";
  }
  std::cout << "=================================================================\n\n";

  common::file_utils::saveCharArrayToFormattedTextFile(
    ifmap_file.c_str(), reinterpret_cast<char*>(data_in1.data_ptr()), data_in1.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    res_file.c_str(), reinterpret_cast<char*>(data_in2.data_ptr()), data_in2.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(data_in3.data_ptr()), data_in3.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), (char*)data_out.data_ptr(), data_out.numel() * sizeof(half), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */
  // fma src_a, src_b, src_c, dst
  auto vcucode_series = vcu::asm_vcu_op({
    "fma ifmap, para, resadd, reg0",  // elementwise add - psum + resadd -> reg0
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

  auto seq_1_offset = split_exp_fra(seq_len * oc_group_size * bytes_input);

  // 加载第一个输入数据
  insn_series.push_back(insn::load_iteration_2<0>(
    data_in_ddr_base_addr, seq_len * bytes_input * oc_group_size / 32 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_IFMAP_ADDR, 0));

  // 加载第二个输入数据
  insn_series.push_back(insn::load_iteration_2<0>(
    data_add_ddr_base_addr, seq_len * bytes_input * oc_group_size / 32 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_VCURES_ADDR, 0));

  // 加载第三个输入数据
  insn_series.push_back(insn::load_iteration_2<0>(
    data_mul_ddr_base_addr, seq_len * bytes_input * oc_group_size / 32 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_VCUPARA_ADDR, 0));



  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);
  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());

  using vcu_t = vcu::VcuExecute;
  vcu_t vcu_op;

  vcu_t::Arguments add_args;
  for (uint64_t i = 0; i < oc_group; ++i) {
    add_args               = {0b100,                   // psum_data_typepe
                              0b011,                   // resadd_para_typtype
                              0b111,                   // data_out_typee
                              0b00,                    // data_out_ram
                              1,                       // opcode_numberr
                              0b0000000,               // opcode_addr
                              0b0000000000000,         // psum_in_addr
                              (uint64_t)(i*seq_len),   // para_in_addr
                              (uint64_t)(i*seq_len),   // resadd_in_addrdr
                              0b0000000000000,         // ram_out_addr
                              (uint64_t)seq_len - 1,   // seq_len
                              (uint64_t)oc_group - 1,  // oc_group
                              0b00,                    // para_func
                              0,                       // psum_sram_valid
                              1,                       // resadd_sram_valid
                              1,                       // para_sram_valid
                              0,                       // psum_addr_hop
                              0,                       // acc_clear
                              1,                       // stream_en
                              1,                       // ifmap_sram_valid
                              (uint64_t)(i*seq_len)    // ifmap_in_addr   
                            };
    auto add_insns = vcu_op(add_args);
    insn_series.insert(insn_series.end(), add_insns.begin(), add_insns.end());
  }


  // 存储结果
  insn_series.push_back(insn::store_iteration_2<0>(
    data_out_ddr_base_addr, seq_len * bytes_input * oc_group_size / 32 - 1, seq_1_offset.first, seq_1_offset.second, oc_group - 1, MASTER_PSUM_ADDR, 1));

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
