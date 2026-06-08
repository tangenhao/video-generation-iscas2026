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

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;

  int h = 14;
  int w = 14;

  uint64_t psum_data_type   = 0b100;
  uint64_t resadd_para_type = 0b111;
  uint64_t data_out_type    = 0b111;
  uint64_t data_out_ram     = 0b0;
  uint64_t opcode_number    = 0b0001000;
  uint64_t opcode_addr      = 0b0000000;
  uint64_t psum_in_addr     = 0x0;
  uint64_t para_in_addr     = 0b000000;
  uint64_t resadd_in_addr   = 0b000000000000;
  uint64_t ram_out_addr     = 0x0000;
  int      num_data         = h * w;
  int      oc_group         = 0b0010;
  uint64_t para_func        = 0b00;

  uint64_t gelu_lut_ddr_base_addr = GELU_LUT_ADDR;
  uint64_t data_in_ddr_base_addr  = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr   = VCUCODE_ADDR;

  common::CommandLine cmd(argc, argv);
  if (cmd.check_cmd_line_flag("help")) {
    std::cout << "Usage: " << argv[0] << "\nOptions:\n"
              << "  --help                            If specified, print this message\n"
              << "  --save_bin                        If specified, save the data in binary format, default is " << false << "\n"
              << "  --h=<int>                         Height of the input tensor, default is " << h << "\n"
              << "  --w=<int>                         Width of the input tensor, default is " << w << "\n"
              << "  --oc_group=<int>                  Number of output channels, default is " << oc_group << "\n"
              << "  --insn_file=<string>              File to save the insnstruction, default is " << insn_file << "\n"
              << "  --opcode_file=<string>            File to save the opcode, default is " << opcode_file << "\n"
              << "  --psum_file=<string>              File to save the psum, default is " << psum_file << "\n"
              << "  --ofmap_file=<string>             File to save the ofmap, default is " << ofmap_file << "\n"
              << "  --reg_cfg_file=<string>           File to save the register configuration, default is " << reg_cfg_file << "\n"
              << "  --gelu_lut_ddr_base_addr=<long>   Base address of the sin_cos_lut in hex, default is " << gelu_lut_ddr_base_addr << "\n"
              << "  --data_in_base_addr=<long>        Base address of the input data in hex, default is " << data_in_ddr_base_addr << "\n"
              << "  --data_out_base_addr=<long>       Base address of the output data in hex, default is " << data_out_ddr_base_addr << "\n"
              << "  --opcode_base_addr=<long>         Base address of the opcode in hex, default is " << opcode_ddr_base_addr << "\n";
    return 0;
  }

  cmd.get_cmd_line_argument("h", h);
  cmd.get_cmd_line_argument("w", w);
  cmd.get_cmd_line_argument("oc_group", oc_group);
  cmd.get_cmd_line_argument("num_data", num_data);
  cmd.get_cmd_line_argument("opcode_file", opcode_file);
  cmd.get_cmd_line_argument("psum_file", psum_file);
  cmd.get_cmd_line_argument("ofmap_file", ofmap_file);
  cmd.get_cmd_line_argument("insn_file", insn_file);
  cmd.get_cmd_line_argument("reg_cfg_file", reg_cfg_file);
  cmd.get_cmd_line_argument("gelu_lut_ddr_base_addr", gelu_lut_ddr_base_addr);
  cmd.get_cmd_line_argument("data_in_base_addr", data_in_ddr_base_addr);
  cmd.get_cmd_line_argument("data_out_base_addr", data_out_ddr_base_addr);
  cmd.get_cmd_line_argument("opcode_base_addr", opcode_ddr_base_addr);
  save_bin = cmd.check_cmd_line_flag("save_bin");

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 data gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  auto data_in = randn<float>({oc_group, num_data, 32}, kFloat32, -1.0f, 1.0f, 0);

  auto data_out = compute_model::function::fast_gelu(data_in);

  if (save_bin) {
    common::file_utils::saveCharArrayToBinFile(
      psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float));
    common::file_utils::saveCharArrayToBinFile(
      ofmap_file.c_str(), reinterpret_cast<char*>(data_out.data_ptr()), data_out.numel() * sizeof(float));
  }
  else {
    common::file_utils::saveCharArrayToFormattedTextFile(
      psum_file.c_str(), reinterpret_cast<char*>(data_in.data_ptr()), data_in.numel() * sizeof(float), 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(
      ofmap_file.c_str(), (char*)data_out.data_ptr(), data_out.numel() * sizeof(float), 32, true);
  }

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */

  auto vcucode_series = vcu::asm_vcu_op({"fastgelu psum, reg0"});

  auto   num_vcucodes      = vcucode_series.size();
  size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  vcucode_series.resize(vcucode_ddr_lines * 8, 0);

  if (save_bin) {
    common::file_utils::saveCharArrayToBinFile(
      opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t));
  }
  else {
    common::file_utils::saveCharArrayToFormattedTextFile(
      opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);
  }
  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  std::vector<insn::instruction> insn_series;

  insn_series.push_back(insn::load_iteration_2<0>(gelu_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));

  insn_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  auto seq_1_offset = split_exp_fra(w * 32 * 4);
  auto seq_2_offset = split_exp_fra(h * w * 32 * 4);

  insn_series.push_back(insn::load_iteration_3<0>(data_in_ddr_base_addr,
                                                  w * 4 - 1,
                                                  seq_1_offset.first,
                                                  seq_1_offset.second,
                                                  h - 1,
                                                  seq_2_offset.first,
                                                  seq_2_offset.second,
                                                  oc_group - 1,
                                                  MASTER_PSUM_ADDR,
                                                  0));

  using vcu_cfg_t               = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t            vcu_cfg;
  auto                 vcu_cfg_insns = vcu_cfg(cfg_args);

  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());
  using vcu_t           = vcu::VcuExecute;
  vcu_t::Arguments args = {psum_data_type,
                           resadd_para_type,
                           data_out_type,
                           data_out_ram,
                           num_vcucodes,
                           opcode_addr,
                           psum_in_addr,
                           para_in_addr,
                           resadd_in_addr,
                           ram_out_addr,
                           (uint64_t)num_data - 1,
                           (uint64_t)oc_group - 1,
                           para_func};

  vcu_t vcu_op;
  auto  vcu_insns = vcu_op(args);

  insn_series.insert(insn_series.end(), vcu_insns.begin(), vcu_insns.end());

  insn_series.push_back(insn::store_iteration_3<0>(data_out_ddr_base_addr,
                                                   w * 4 - 1,
                                                   seq_1_offset.first,
                                                   seq_1_offset.second,
                                                   h - 1,
                                                   seq_2_offset.first,
                                                   seq_2_offset.second,
                                                   oc_group - 1,
                                                   MASTER_PSUM_ADDR,
                                                   1));
  common::insn::pad_serial_sync_word(insn_series);

  if (save_bin) {
    common::file_utils::saveCharArrayToBinFile(
      insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction));
  }
  else {
    common::file_utils::saveCharArrayToFormattedTextFile(
      insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);
  }
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