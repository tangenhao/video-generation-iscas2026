#include "addr.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include <vector>
#include <algorithm>

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

void print_hex(std::string str, float num, std::ostream& os = std::cout)
{
  uint32_t num_uint32 = *reinterpret_cast<uint32_t*>(&num);
  os << std::hex << str << ": 0x" << num_uint32 << std::endl;
}

void print_dec(std::string str, int num, std::ostream& os = std::cout)
{
  os << std::dec << str << ": " << num << std::endl;
}

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;

  uint64_t data_in_ddr_base_addr  = PSUM_ADDR;
  uint64_t data_out_ddr_base_addr = OFMAP_ADDR;

  uint64_t psum_sram_read_addr  = 8192;
  uint64_t psum_sram_write_addr = 0;

  int rows = 64;
  int cols = 128;
  auto data = randn<float>({rows, cols}, kFloat32, -1.0f, 1.0f, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data.data_ptr()), data.numel() * sizeof(float), 32, true);

  std::vector<insn::instruction> insn_series;

  // VCU转置块处理：将输入矩阵按32x32块分割并逐块转置
  const int BLOCK_SIZE = 32;  // VCU转置单元每次处理的块大小
  int row_blocks = rows / BLOCK_SIZE; 
  int col_blocks = cols / BLOCK_SIZE; 

  std::cout << "Processing " << rows << "x" << cols << " matrix in " 
            << row_blocks << "x" << col_blocks << " blocks of " << BLOCK_SIZE << "x" << BLOCK_SIZE << std::endl;

  // 为每个32x32块生成指令序列
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int all_done = (row_block_id == row_blocks - 1) && (col_block_id == col_blocks - 1);
      std::cout << "Processing block (" << row_block_id << "," << col_block_id << ") " << std::endl;
      
      // 计算输入和输出在DDR中的地址偏移
      uint64_t input_offset = (row_block_id * BLOCK_SIZE * cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE) * sizeof(float);
      uint64_t output_offset = input_offset;

      uint64_t load_addr = data_in_ddr_base_addr + input_offset;
      uint64_t sram_load_addr = MASTER_PSUM_ADDR + psum_sram_read_addr * sizeof(float);
      insn_series.push_back(insn::load_iteration_2<0>(load_addr, BLOCK_SIZE * BLOCK_SIZE / 8 - 1, 0, 0, 0, sram_load_addr, 0));

      // VCU Transpose指令
      using vcu_transpose_t           = vcu::VcuTranspose;
      vcu_transpose_t::Arguments args = {3, psum_sram_read_addr, psum_sram_write_addr};
      vcu_transpose_t            vcu_transpose;
      auto                       vcu_transpose_insn = vcu_transpose(args);
      insn_series.insert(insn_series.end(), vcu_transpose_insn.begin(), vcu_transpose_insn.end());

      // Store指令：将转置结果从SRAM存储到DDR
      uint64_t store_addr = data_out_ddr_base_addr + output_offset;
      uint64_t sram_store_addr = MASTER_PSUM_ADDR + psum_sram_write_addr;
      insn_series.push_back(insn::store_iteration_2<0>(store_addr, BLOCK_SIZE * BLOCK_SIZE / 8 - 1, 0, 0, 0, sram_store_addr, all_done));
    }
  }

  common::insn::pad_serial_sync_word(insn_series);

  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  auto ofmap = data; // 转置后的维度是cols×rows
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx    = temp_block_start + i * BLOCK_SIZE + j;
          int new_idx    = temp_block_start + j * BLOCK_SIZE + i;
          ofmap[new_idx] = data[ori_idx];
          print_dec("ori_idx", ori_idx);
          print_dec("new_idx", new_idx);
          print_hex("ori_data", data[ori_idx]);
          print_hex("new_data", ofmap[new_idx]);
        }
      }
    }
  }

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