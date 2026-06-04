#include "addr.h"
#include "common/insn.h"
#include "common/type_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "vcu/vcu_operation.h"
#include "instruction/vcu_instruction.h"
#include "instruction/parser.h"
#include "compute_model/function/tensor_function.h"
#include "write_reg.h"
#include <vector>
#include <algorithm>
#include <iostream>
#include <cmath>

#define DEBUG true
using namespace compute_model::tensor;
using namespace compute_model::function;

void print_hex(std::string str, float num, std::ostream& os = std::cout)
{
  uint32_t num_uint32 = *reinterpret_cast<uint32_t*>(&num);
  os << std::hex << str << ": 0x" << num_uint32 << std::endl;
}

void print_dec(std::string str, int num, std::ostream& os = std::cout)
{
  os << std::dec << str << ": " << num << std::endl;
}

template<typename T>
std::string to_string_with_precision(const T a_value, const int n = 6)
{
  std::ostringstream out;
  out << std::fixed << std::setprecision(n) << a_value;
  return out.str();
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

  std::cout << "=== RoPE (Rotary Position Embedding) Implementation ===" << std::endl;

  // RoPE配置参数
  int seq_len = 128;           // 序列长度
  int dim = 256;               // 特征维度（必须是偶数，因为要分实部虚部）
  int n_group_size = 32;      // 硬件分组大小

  // 确保维度能被n_group_size整除
  if (dim % n_group_size != 0) {
    std::throw_with_nested(std::runtime_error("dim must be divisible by n_group_size"));
  }
  if (dim % 2 != 0) {
    std::throw_with_nested(std::runtime_error("dim must be even for complex representation"));
  }

  int dim_groups = dim / n_group_size;  // 维度分组数

  // DDR地址配置
  uint64_t data_in_ddr_base_addr = PSUM_ADDR;
  uint64_t freq_cls_ddr_base_addr = VCURES_ADDR;
  uint64_t data_out_ddr_base_addr = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr    = VCUCODE_ADDR;

//   uint64_t input_ddr_base_addr = BLOCK_INPUT_ADDR;
//   uint64_t freq_cls_ddr_base_addr = ATTN_QUERY_TEMP_ADDR;
//   uint64_t input_real_temp_addr = ATTN_KEY_TEMP_ADDR;
//   uint64_t input_imag_temp_addr = input_real_temp_addr + dim_groups * seq_len * n_group_size / 2 * sizeof(float);
//   uint64_t freq_cls_real_temp_addr = ATTN_VALUE_TEMP_ADDR;
//   uint64_t freq_cls_imag_temp_addr = freq_cls_real_temp_addr + dim_groups * seq_len * n_group_size / 2 * sizeof(float);
//   uint64_t output_real_ddr_addr = ATTN_SCORE_TEMP_ADDR;
//   uint64_t output_imag_ddr_addr = output_real_ddr_addr + dim_groups * seq_len * n_group_size / 2 * sizeof(float);
//   uint64_t final_output_ddr_addr = BLOCK_OUTPUT_ADDR;
//   uint64_t vcucode_ddr_addr = LLAMA_BLOCK_VCUCODE_ADDR;

  // SRAM地址配置
  uint64_t psum_read_addr = 0;
  uint64_t psum_write_addr = 0;

  std::cout << "Configuration:" << std::endl;
  print_dec("seq_len", seq_len);
  print_dec("dim", dim);
  print_dec("n_group_size", n_group_size);
  print_dec("dim_groups", dim_groups);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                               Data Generation                                           */
  /* -------------------------------------------------------------------------------------------------------- */

  std::cout << "\n=== Data Generation ===" << std::endl;

  // 生成输入张量: [dim/n_group_size, seq_len, n_group_size]
  auto input = randn<float>({dim_groups, seq_len, n_group_size}, kFloat32, -1.0f, 1.0f, 42);
  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(),
    reinterpret_cast<char*>(input.data_ptr()),
    input.numel() * sizeof(float), 32, true);

  // 生成频率张量: [dim/n_group_size, seq_len, n_group_size]
  auto freq_cls = randn<float>({dim_groups, seq_len, n_group_size}, kFloat32, -1.0f, 1.0f, 43);
  // auto freq_cls = zeros<float>({dim_groups, seq_len, n_group_size}, kFloat32);
  common::file_utils::saveCharArrayToFormattedTextFile(
    res_file.c_str(),
    reinterpret_cast<char*>(freq_cls.data_ptr()),
    freq_cls.numel() * sizeof(float), 32, true);

  std::cout << "Generated input tensor: [" << dim_groups << ", " << seq_len << ", " << n_group_size << "]" << std::endl;
  std::cout << "Generated freq_cls tensor: [" << dim_groups << ", " << seq_len << ", " << n_group_size << "]" << std::endl;

  const int BLOCK_SIZE = 32;  
  int total_rows = seq_len;
  int total_cols = dim;
  int row_blocks = total_rows / BLOCK_SIZE;
  int col_blocks = total_cols / BLOCK_SIZE;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                Reference Generation                                           */
  /* -------------------------------------------------------------------------------------------------------- */

  std::cout << "\n=== Reference Generation ===" << std::endl;

  std::vector<insn::instruction> insn_series;

  // -----------------1. 转置输入和频率张量------------------
  std::cout << "Transposing input and freq_cls tensors..." << std::endl;

  if(DEBUG) {
  std::cout << "Processing " << total_rows << "x" << total_cols << " matrix in "
            << row_blocks << "x" << col_blocks << " blocks of " << BLOCK_SIZE << "x" << BLOCK_SIZE << std::endl;
  }
  /** Reference for input transpose */
  std::cout << "Generating reference for input transpose..." << std::endl;
  auto input_transposed = input; // 转置后的维度是cols×rows
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      uint64_t input_offset = (row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE) * sizeof(float);
      uint64_t output_offset = input_offset;
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx    = temp_block_start + i * BLOCK_SIZE + j;
          int new_idx    = temp_block_start + j * BLOCK_SIZE + i;
          input_transposed[new_idx] = input[ori_idx];
          print_dec("ori_idx", ori_idx);
          print_dec("new_idx", new_idx);
          print_hex("ori_data", input[ori_idx]);
          print_hex("new_data", input_transposed[new_idx]);
        }
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_input_transposed.txt", reinterpret_cast<char*>(input_transposed.data_ptr()),
    input_transposed.numel() * sizeof(float), 32, true); 

  /** Reference for freq_cls transpose */
  std::cout << "Generating reference for freq_cls transpose..." << std::endl;
  auto freq_transposed = freq_cls; // 转置后的维度是cols×rows
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      uint64_t input_offset = (row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE) * sizeof(float);
      uint64_t output_offset = input_offset;
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx    = temp_block_start + i * BLOCK_SIZE + j;
          int new_idx    = temp_block_start + j * BLOCK_SIZE + i;
          freq_transposed[new_idx] = freq_cls[ori_idx];
          print_dec("ori_idx", ori_idx);
          print_dec("new_idx", new_idx);
          print_hex("ori_data", freq_cls[ori_idx]);     
          print_hex("new_data", freq_transposed[new_idx]);
        }
      }
    }
  }
  
    common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_freq_transposed.txt", reinterpret_cast<char*>(freq_transposed.data_ptr()), 
    freq_transposed.numel() * sizeof(float), 32, true);

  // ------------------2. 分离实部和虚部------------------
  std::cout << "\n=== Real/Imaginary Separation ===" << std::endl;

  // 计算分离后的数据大小
  int separated_size = (dim_groups * seq_len * n_group_size) / 2;  // 实部和虚部各占一半

  std::cout << "Separating real and imaginary parts..." << std::endl;
  std::cout << "Each separated tensor size: " << separated_size << " elements" << std::endl;

  // 分离实部和虚部
  auto input_real = zeros<float>({separated_size}, kFloat32);
  auto input_imag = zeros<float>({separated_size}, kFloat32);
  auto freq_real = zeros<float>({separated_size}, kFloat32);
  auto freq_imag = zeros<float>({separated_size}, kFloat32);

  // 模拟分离过程：偶数索引为实部，奇数索引为虚部
  int real_index = 0;
  int imag_index = 0;
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx = temp_block_start + i * BLOCK_SIZE + j;          
          // 32一组交替录入：偶数索引为实部，奇数索引为虚部
          if (i % 2 == 0) {
            // 实部
            input_real[real_index] = input_transposed[ori_idx];
            freq_real[real_index] = freq_transposed[ori_idx];
            real_index++;
          } else {
            // 虚部
            input_imag[imag_index] = input_transposed[ori_idx];
            freq_imag[imag_index] = freq_transposed[ori_idx];
            imag_index++;
          }
          print_dec("ori_idx", ori_idx);
          print_dec("real_index", real_index);
          print_dec("imag_index", imag_index);
          print_hex("input_transposed", input_transposed[ori_idx]);
          print_hex("freq_transposed", freq_transposed[ori_idx]);
        }
      }
    }
  }
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_input_real.txt", reinterpret_cast<char*>(input_real.data_ptr()), input_real.numel() * sizeof(float), 32, true);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_input_imag.txt", reinterpret_cast<char*>(input_imag.data_ptr()), input_imag.numel() * sizeof(float), 32, true);    
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_freq_real.txt", reinterpret_cast<char*>(freq_real.data_ptr()), freq_real.numel() * sizeof(float), 32, true);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_freq_imag.txt", reinterpret_cast<char*>(freq_imag.data_ptr()), freq_imag.numel() * sizeof(float), 32, true);

  // ----------------3. RoPE计算------------------
  std::cout << "\n=== RoPE Computation ===" << std::endl;

  // q_real' =  q_real * cos θ   –   q_imag * sin θ
  // q_imag' =  q_real * sin θ   +   q_imag * cos θ

  auto cos_values = freq_real;
  auto sin_values = freq_imag;

  auto output_real = zeros<float>({separated_size}, kFloat32);
  auto output_imag = zeros<float>({separated_size}, kFloat32);

  std::cout << "Computing reference output for RoPE..." << std::endl;
  output_real = mul_elementwise<float>(input_real, cos_values) - mul_elementwise(input_imag, sin_values);
  output_imag = mul_elementwise<float>(input_real, sin_values) + mul_elementwise(input_imag, cos_values);

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_output_real_ref.txt", reinterpret_cast<char*>(output_real.data_ptr()), output_real.numel() * sizeof(float), 32, true);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_output_imag_ref.txt", reinterpret_cast<char*>(output_imag.data_ptr()), output_imag.numel() * sizeof(float), 32, true);

  // ----------------4. 数据重排并转置------------------

  std::cout << "\n=== Data Rearrangement: Concat and Transpose ===" << std::endl;

  // 将实部和虚部重新组合成原始的数据布局 [dim/n_group_size, seq_len, n_group_size]
  auto final_output_concat = zeros<float>({dim_groups, seq_len, n_group_size}, kFloat32);

  std::cout << "Reconstructing final output tensor..." << std::endl;
  std::cout << "Final output shape: [" << dim_groups << ", " << seq_len << ", " << n_group_size << "]" << std::endl;

  // 重新组合：将实部和虚部交错排列 - 与分离过程相逆
  int final_real_index = 0;
  int final_imag_index = 0;
  
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
          int ori_idx = temp_block_start + i * BLOCK_SIZE + j;
          
          // 偶数索引写入实部，奇数索引写入虚部
          if (i % 2 == 0) {
            // 偶数行写入实部数据
            if (final_real_index < separated_size) {
              final_output_concat[ori_idx] = output_real[final_real_index];
              print_dec("Writing real at ori_idx", ori_idx);
              print_dec("real_index", final_real_index);
              print_hex("output_real", output_real[final_real_index]);
              final_real_index++;
            }
          } else {
            // 奇数行写入虚部数据
            if (final_imag_index < separated_size) {
              final_output_concat[ori_idx] = output_imag[final_imag_index];
              print_dec("Writing imag at ori_idx", ori_idx);
              print_dec("imag_index", final_imag_index);
              print_hex("output_imag", output_imag[final_imag_index]);
              final_imag_index++;
            }
          }
        }
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory/rope_output_concat.txt", reinterpret_cast<char*>(final_output_concat.data_ptr()), final_output_concat.numel() * sizeof(float), 32, true);

  // 最后需要对重组后的数据进行转置，恢复到原始的布局 [dim_groups, seq_len, n_group_size]
  auto final_output_transposed = zeros<float>({dim_groups, seq_len, n_group_size}, kFloat32);
  
  std::cout << "Transposing concatenated data back to original layout..." << std::endl;
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int temp_block_start = row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE;
      for (int i = 0; i < BLOCK_SIZE; ++i) {
        for (int j = 0; j < BLOCK_SIZE; ++j) {
            int original_idx = temp_block_start + i * BLOCK_SIZE + j;
            int target_idx = temp_block_start + j * BLOCK_SIZE + i;
            final_output_transposed[target_idx] = final_output_concat[original_idx];
            if(DEBUG){
                print_dec("Transpose: original_idx", original_idx);
                print_dec("Transpose: target_idx", original_idx);  
                print_hex("Transpose: data", final_output_concat[original_idx]);
            }
        }
      }
    }
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(final_output_transposed.data_ptr()), final_output_transposed.numel() * sizeof(float), 32, true);

  std::cout << "Result reconstruction completed!" << std::endl;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                Insn Generation                                             */
  /* -------------------------------------------------------------------------------------------------------- */
  
  // -------------1. Transpose Input and Freq_Cls-------------
  /** Transpose input */
  uint64_t psum_sram_read_addr  = 0;
  uint64_t psum_sram_write_addr = 0;
  
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      // int all_done = (row_block_id == row_blocks - 1) && (col_block_id == col_blocks - 1);
      std::cout << "Processing block (" << row_block_id << "," << col_block_id << ") " << std::endl;
      
      // 计算输入和输出在DDR中的地址偏移
      uint64_t input_offset = (row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE) * sizeof(float);
      uint64_t output_offset = input_offset;

      uint64_t load_addr = data_in_ddr_base_addr + input_offset;  //data_in_ddr_base_addr
      uint64_t sram_load_addr = MASTER_PSUM_ADDR + psum_sram_read_addr * sizeof(float);
      insn_series.push_back(insn::load_iteration_2<0>(load_addr, BLOCK_SIZE * BLOCK_SIZE / 8 - 1, 0, 0, 0, sram_load_addr, 0));

      // VCU Transpose指令
      using vcu_transpose_t           = vcu::VcuTranspose;
      vcu_transpose_t::Arguments args = {3, psum_sram_read_addr, psum_sram_write_addr};
      vcu_transpose_t            vcu_transpose;
      auto                       vcu_transpose_insn = vcu_transpose(args);
      insn_series.insert(insn_series.end(), vcu_transpose_insn.begin(), vcu_transpose_insn.end());

      // Store指令：将转置结果从SRAM存储到DDR
      uint64_t store_addr = data_in_ddr_base_addr + output_offset;   //写回原地址
      uint64_t sram_store_addr = MASTER_PSUM_ADDR + psum_sram_write_addr;
      insn_series.push_back(insn::store_iteration_2<0>(store_addr, BLOCK_SIZE * BLOCK_SIZE / 8 - 1, 0, 0, 0, sram_store_addr, 0));
    }
  }

  /** Transpose freq_cls */
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      // int all_done = (row_block_id == row_blocks - 1) && (col_block_id == col_blocks - 1);
      std::cout << "Processing block (" << row_block_id << "," << col_block_id << ") " << std::endl;
      
      // 计算输入和输出在DDR中的地址偏移
      uint64_t input_offset = (row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE) * sizeof(float);
      uint64_t output_offset = input_offset;

      uint64_t load_addr = freq_cls_ddr_base_addr + input_offset;   //freq_cls_ddr_base_addr
      uint64_t sram_load_addr = MASTER_PSUM_ADDR + psum_sram_read_addr * sizeof(float);
      insn_series.push_back(insn::load_iteration_2<0>(load_addr, BLOCK_SIZE * BLOCK_SIZE * 4 / 32 - 1, 0, 0, 0, sram_load_addr, 0));

      // VCU Transpose指令
      using vcu_transpose_t           = vcu::VcuTranspose;
      vcu_transpose_t::Arguments args = {3, psum_sram_read_addr, psum_sram_write_addr};
      vcu_transpose_t            vcu_transpose;
      auto                       vcu_transpose_insn = vcu_transpose(args);
      insn_series.insert(insn_series.end(), vcu_transpose_insn.begin(), vcu_transpose_insn.end());

      // Store指令：将转置结果从SRAM存储到DDR
      uint64_t store_addr = freq_cls_ddr_base_addr + output_offset;  //写回原地址
      uint64_t sram_store_addr = MASTER_PSUM_ADDR + psum_sram_write_addr;
      insn_series.push_back(insn::store_iteration_2<0>(store_addr, BLOCK_SIZE * BLOCK_SIZE * 4 / 32 - 1, 0, 0, 0, sram_store_addr, 0));
    }
  }

    /** -----------------Set VcuCode for RoPE------------------ */
  auto vcucode_series = vcu::asm_vcu_op({         
    /** 0: -input_imag * freq_imag, sign change */
    "mulc psum, reg0, " + to_string_with_precision(-1.00000f, 7),     
    "mul reg0 resadd, reg1",  // -input_imag * freq_imag, write to resadd(temp_offset)

    /** 2: input_real * freq_real */
    "mul psum resadd, reg2", // input_real * freq_real, write to psum(temp_offset)

    /** 3: Compute real for RoPE */
    "add psum resadd, reg3", // input_real * freq_real - input_real * freq_imag, write to psum(psum_output_real_addr)

    /** 4: input_real * freq_imag */
    "mul psum resadd, reg4", // input_real * freq_imag, write to resadd(temp_offset)

    /** 5: input_imag * freq_real */
    "mul psum resadd, reg5", // input_imag * freq_real, write to psum(temp_offset)

    /** 6: Compute imag for RoPE */
    "add psum resadd, reg6" // input_imag * freq_real + input_real * freq_imag, write to psum(psum_output_imag_addr)
  });

  size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  vcucode_series.resize(vcucode_ddr_lines * 8, 0);
  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);
  
  insn_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  //  --------------2. Split Real and Imag-----------------
  /** Split real and imag */
  auto ddr_hop_offset = split_exp_fra(2 * BLOCK_SIZE * sizeof(float));
  auto split_data_size = seq_len * dim / 2 * sizeof(float);
  auto split_data_num  = seq_len * dim / 2; 
  uint64_t input_real_sram_addr = MASTER_PSUM_ADDR;
  uint64_t input_imag_sram_addr = MASTER_PSUM_ADDR + split_data_size / 32;
  uint64_t freq_real_sram_addr = MASTER_VCURES_ADDR;
  uint64_t freq_imag_sram_addr = MASTER_VCURES_ADDR + split_data_size / 32;

  /** Load input_real, input_imag, freq_real, freq_imag */
  insn_series.push_back(insn::load_iteration_2<0>(
    data_in_ddr_base_addr, 
    BLOCK_SIZE * sizeof(float) / 32 - 1, 
    ddr_hop_offset.first, 
    ddr_hop_offset.second, 
    row_blocks * col_blocks * BLOCK_SIZE / 2 - 1, 
    input_real_sram_addr, 0));
  
  insn_series.push_back(insn::load_iteration_2<0>(
    data_in_ddr_base_addr + BLOCK_SIZE * sizeof(float), 
    BLOCK_SIZE * sizeof(float) / 32 - 1, 
    ddr_hop_offset.first, 
    ddr_hop_offset.second, 
    row_blocks * col_blocks * BLOCK_SIZE / 2 - 1, 
    input_imag_sram_addr, 0));

  insn_series.push_back(insn::load_iteration_2<0>(
    freq_cls_ddr_base_addr, 
    BLOCK_SIZE * sizeof(float) / 32 - 1, 
    ddr_hop_offset.first, 
    ddr_hop_offset.second, 
    row_blocks * col_blocks * BLOCK_SIZE / 2 - 1, 
    freq_real_sram_addr, 0));

  insn_series.push_back(insn::load_iteration_2<0>(
    freq_cls_ddr_base_addr + BLOCK_SIZE * sizeof(float), 
    BLOCK_SIZE * sizeof(float) / 32 - 1, 
    ddr_hop_offset.first, 
    ddr_hop_offset.second, 
    row_blocks * col_blocks * BLOCK_SIZE / 2 - 1, 
    freq_imag_sram_addr, 0));
                          

  /** --------------VCU Execute------------- */
  using namespace common::insn;
  uint64_t psum_input_real_addr = 0;
  uint64_t psum_input_imag_addr = psum_input_real_addr + split_data_num / 32;
  uint64_t resadd_freq_real_addr = 0;
  uint64_t resadd_freq_imag_addr = resadd_freq_real_addr + split_data_num / 32;
  uint64_t temp_offset = 2 * split_data_num / 32;
  uint64_t psum_output_real_addr = 3 * split_data_num / 32; // PSUM output real
  uint64_t psum_output_imag_addr = 4 * split_data_num / 32; // PSUM output imag

  // VCU Config
  auto vcu_cfg_insns = vcu_config(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  insn_series.push_back(vcu_cfg_insns);

  /** step1. Prepare Value of -input_imag * freq_imag*/
  auto vcu_execute_step1 = vcu_execute(vcu_psum_dtype[kFloat32],
                                vcu_resadd_dtype[kFloat32],
                                vcu_out_dtype[kFloat32],
                                VCURES,
                                2,  // opcode_number
                                0,  // opcode_addr
                                psum_input_imag_addr,  // psum_in_addr
                                0,  // para_in_addr
                                resadd_freq_imag_addr,  // resadd_in_addr
                                temp_offset,  // ram_out_addr
                                split_data_num / 32 - 1,  // num_data
                                0,
                                0);
  insn_series.push_back(vcu_execute_step1);

  /** step2. input_real * freq_real */
  auto vcu_execute_step2 = vcu_execute(vcu_psum_dtype[kFloat32],
                                vcu_resadd_dtype[kFloat32],
                                vcu_out_dtype[kFloat32],
                                PSUM,
                                1,  // opcode_number
                                2,  // opcode_addr
                                psum_input_real_addr,  // psum_in_addr
                                0,  // para_in_addr
                                resadd_freq_real_addr,  // resadd_in_addr
                                temp_offset,  // ram_out_addr 
                                split_data_num / 32 - 1,  // num_data
                                0,
                                0);
  insn_series.push_back(vcu_execute_step2);

  /** step3. Compute real for RoPE */
  auto vcu_execute_step3 = vcu_execute(vcu_psum_dtype[kFloat32],
                                vcu_resadd_dtype[kFloat32],
                                vcu_out_dtype[kFloat32],
                                PSUM,
                                1,  // opcode_number
                                3,  // opcode_addr
                                temp_offset,  // psum_in_addr
                                0,  // para_in_addr
                                temp_offset,  // resadd_in_addr
                                psum_output_real_addr,  // ram_out_addr 
                                split_data_num / 32 - 1,  // num_data
                                0,
                                0);
  insn_series.push_back(vcu_execute_step3);
  
  /** step4. input_real * freq_imag */
  auto vcu_execute_step4 = vcu_execute(vcu_psum_dtype[kFloat32],
                                vcu_resadd_dtype[kFloat32],
                                vcu_out_dtype[kFloat32],
                                VCURES,
                                1,  // opcode_number
                                4,  // opcode_addr
                                psum_input_real_addr,  // psum_in_addr
                                0,  // para_in_addr
                                resadd_freq_imag_addr,  // resadd_in_addr
                                temp_offset,  // ram_out_addr 
                                split_data_num / 32 - 1,  // num_data
                                0,
                                0);
  insn_series.push_back(vcu_execute_step4);

  /** step5. input_imag * freq_real */
  auto vcu_execute_step5 = vcu_execute(vcu_psum_dtype[kFloat32],
                                vcu_resadd_dtype[kFloat32],
                                vcu_out_dtype[kFloat32],
                                PSUM,
                                1,  // opcode_number
                                5,  // opcode_addr
                                psum_input_imag_addr,  // psum_in_addr
                                0,  // para_in_addr
                                resadd_freq_real_addr,  // resadd_in_addr
                                temp_offset,  // ram_out_addr 
                                split_data_num / 32 - 1,  // num_data
                                0,
                                0);
  insn_series.push_back(vcu_execute_step5);

  /** step6. Compute imag for RoPE */
  auto vcu_execute_step6 = vcu_execute(vcu_psum_dtype[kFloat32],
                                vcu_resadd_dtype[kFloat32],
                                vcu_out_dtype[kFloat32],
                                PSUM,
                                1,  // opcode_number
                                6,  // opcode_addr
                                temp_offset,  // psum_in_addr
                                0,  // para_in_addr
                                temp_offset,  // resadd_in_addr
                                psum_output_imag_addr,  // ram_out_addr 
                                split_data_num / 32 - 1,  // num_data
                                0,
                                0);
  insn_series.push_back(vcu_execute_step6);


  // 写回
  auto output_real_sram_addr = MASTER_PSUM_ADDR + 3 * split_data_size / 32;
  auto output_imag_sram_addr = output_real_sram_addr + split_data_size / 32;
  insn_series.push_back(insn::store_iteration_2<0>(
    data_out_ddr_base_addr,
    BLOCK_SIZE * sizeof(float) / 32 - 1,
    ddr_hop_offset.first,
    ddr_hop_offset.second,
    row_blocks * col_blocks * BLOCK_SIZE / 2 - 1,
    output_real_sram_addr, 0));
  insn_series.push_back(insn::store_iteration_2<0>(
    data_out_ddr_base_addr + BLOCK_SIZE * sizeof(float),
    BLOCK_SIZE * sizeof(float) / 32 - 1,
    ddr_hop_offset.first,
    ddr_hop_offset.second,
    row_blocks * col_blocks * BLOCK_SIZE / 2 - 1,
    output_imag_sram_addr, 0));

  /** --------------Rearrange and Transpose------------- */
  
  for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
    for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
      int all_done = (row_block_id == row_blocks - 1) && (col_block_id == col_blocks - 1);
      std::cout << "Processing block (" << row_block_id << "," << col_block_id << ") " << std::endl;
      
      // 计算输入和输出在DDR中的地址偏移
      uint64_t input_offset = (row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE) * sizeof(float);
      uint64_t output_offset = input_offset;

      uint64_t load_addr = data_out_ddr_base_addr + input_offset;  //data_in_ddr_base_addr
      uint64_t sram_load_addr = MASTER_PSUM_ADDR + psum_sram_read_addr * sizeof(float);
      insn_series.push_back(insn::load_iteration_2<0>(load_addr, BLOCK_SIZE * BLOCK_SIZE / 8 - 1, 0, 0, 0, sram_load_addr, 0));

      // VCU Transpose指令
      using vcu_transpose_t           = vcu::VcuTranspose;
      vcu_transpose_t::Arguments args = {3, psum_sram_read_addr, psum_sram_write_addr};
      vcu_transpose_t            vcu_transpose;
      auto                       vcu_transpose_insn = vcu_transpose(args);
      insn_series.insert(insn_series.end(), vcu_transpose_insn.begin(), vcu_transpose_insn.end());

      // Store指令：将转置结果从SRAM存储到DDR
      uint64_t store_addr = data_out_ddr_base_addr + output_offset;   //写回原地址
      uint64_t sram_store_addr = MASTER_PSUM_ADDR + psum_sram_write_addr;
      insn_series.push_back(insn::store_iteration_2<0>(store_addr, BLOCK_SIZE * BLOCK_SIZE / 8 - 1, 0, 0, 0, sram_store_addr, all_done));
    }
  }

  // 添加同步字
  common::insn::pad_serial_sync_word(insn_series);

  // 输出指令
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  // 写入指令文件
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  // 写入寄存器配置
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
