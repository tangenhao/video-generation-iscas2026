#pragma once

#include "addr_for_llama.h"
#include "common/insn.h"
#include "common/type_utils.h"
#include "vcu/vcu_opcode.h"
#include "vcu/vcu_insn.h"
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <cmath>

namespace transformer {
namespace rope_embedding {

using namespace common::insn;

void print_dec(std::string str, int num, std::ostream& os = std::cout)
{
  os << std::dec << str << ": " << num << std::endl;
}

void print_hex(std::string str, uint64_t num, std::ostream& os = std::cout)
{
  os << std::hex << str << ": 0x" << num << std::endl;
}

void print(std::string str, std::ostream& os = std::cout)
{
  os << str << std::endl;
}

void print(instruction insn, std::ostream& os = std::cout)
{
  os << insn << std::endl;
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

template<bool DEBUG = false>
struct RopeEmbeddingOp {

  static constexpr int BLOCK_SIZE = 32;  // 转置块大小
  static constexpr int MAX_PSUM_DEPTH = DEFAULT_MAX_PSUM_DEPTH;
  static constexpr int MAX_VCURES_DEPTH = DEFAULT_MAX_VCURES_DEPTH;      

  int n_group_size;     
  int bytes_data;       
  int tile_m;
  int tile_dim_groups;

  struct Argument {
    int seq_len;                       
    int dim;                          
    uint64_t input_base_addr;         // 输入数据DDR基址
    uint64_t freq_cls_base_addr;      // 频率张量DDR基址 
    uint64_t output_base_addr;        
    uint64_t vcu_code_base_addr;      
    uint64_t all_done = 1;            
  };

  RopeEmbeddingOp()
  {
    /** Default fp32 */
    n_group_size = 32;
    bytes_data = 4;   // float32
    tile_m = 32;
    tile_dim_groups = 1;
  }

  std::pair<std::vector<instruction>, std::vector<uint64_t>> operator()(const Argument& args)
  {
    std::vector<instruction> insn_series;
    std::vector<uint64_t> vcucode_series;

    // 参数验证
    if (args.dim % n_group_size != 0) {
      std::throw_with_nested(std::runtime_error("dim must be divisible by n_group_size"));
    }
    if (args.dim % 2 != 0) {
      std::throw_with_nested(std::runtime_error("dim must be even for complex representation"));
    }

    this->set_vcucode(vcucode_series);
    size_t vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
    size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
    vcucode_series.resize(vcucode_ddr_lines * 8, 0);
    
    /** Load vcu code */
    insn_series.push_back(load_iteration_2<0>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    
    /** VCU Config */
    using vcu_cfg_t = vcu::VcuConfig;
    vcu_cfg_t::Arguments cfg_args = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    vcu_cfg_t vcu_cfg;
    auto vcu_cfg_insns = vcu_cfg(cfg_args);
    insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());
    
    /** Compute RoPE */
    this->compute_rope_embedding(insn_series, vcucode_series, args);
    
    return {insn_series, vcucode_series};
  }

  void set_vcucode(std::vector<uint64_t>& vcucode_series)
  {
    /** RoPE computation VCU codes */
    auto rope_code = vcu::asm_vcu_op({         
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
    for (auto code : rope_code) {
      vcucode_series.push_back(code);
    }
  }

  void compute_rope_embedding(std::vector<instruction>& insn_series, const std::vector<uint64_t>& vcucode_series, const Argument& args)
  {
    int dim_groups = args.dim / n_group_size;        // 维度分组数
    int total_rows = args.seq_len;
    int total_cols = args.dim;
    int row_blocks = total_rows / BLOCK_SIZE;
    int col_blocks = total_cols / BLOCK_SIZE;

    if (DEBUG) {
      print_dec("seq_len", args.seq_len);
      print_dec("dim", args.dim);
      print_dec("n_group_size", n_group_size);
      print_dec("dim_groups", dim_groups);
      print_dec("row_blocks", row_blocks);
      print_dec("col_blocks", col_blocks);
    }
    
    /** Step 1. Transpose Input and Freq_Cls */
    this->transpose_data(insn_series, args.input_base_addr, row_blocks, col_blocks, total_cols);
    this->transpose_data(insn_series, args.freq_cls_base_addr, row_blocks, col_blocks, total_cols);
    
    /** Step 2. Split Real and Imaginary Parts and Execute RoPE */
    this->execute_rope_computation(insn_series, args);
    
    /** Step 3. Rearrange and Transpose Final Output */
    // Note: Restore the original frequency tensor, so we can reuse it for the next RoPE computation
    this->transpose_data(insn_series, args.freq_cls_base_addr, row_blocks, col_blocks, total_cols);
    this->transpose_data(insn_series, args.output_base_addr, row_blocks, col_blocks, total_cols, args.all_done);
  }

private:
  void transpose_data(std::vector<instruction>& insn_series, uint64_t ddr_base_addr, 
                     int row_blocks, int col_blocks, int total_cols, uint64_t all_done = 0)
  {
    uint64_t psum_sram_read_addr = 0;
    uint64_t psum_sram_write_addr = 0;
    
    for (int row_block_id = 0; row_block_id < row_blocks; ++row_block_id) {
      for (int col_block_id = 0; col_block_id < col_blocks; ++col_block_id) {
        uint64_t is_last_block = ((row_block_id == row_blocks - 1) && (col_block_id == col_blocks - 1)) ? all_done : 0;
        
        // 计算地址偏移
        uint64_t input_offset = (row_block_id * BLOCK_SIZE * total_cols + col_block_id * BLOCK_SIZE * BLOCK_SIZE) * bytes_data;
        
        // Load指令
        uint64_t load_addr = ddr_base_addr + input_offset;
        uint64_t sram_load_addr = MASTER_PSUM_ADDR + psum_sram_read_addr * bytes_data;
        insn_series.push_back(load_iteration_2<0>(load_addr, BLOCK_SIZE * BLOCK_SIZE * bytes_data / 32 - 1, 0, 0, 0, sram_load_addr, 0));

        // VCU Transpose指令
        using vcu_transpose_t = vcu::VcuTranspose;
        vcu_transpose_t::Arguments args = {3, psum_sram_read_addr, psum_sram_write_addr};
        vcu_transpose_t vcu_transpose;
        auto vcu_transpose_insn = vcu_transpose(args);
        insn_series.insert(insn_series.end(), vcu_transpose_insn.begin(), vcu_transpose_insn.end());

        // Store指令
        uint64_t store_addr = ddr_base_addr + input_offset;
        uint64_t sram_store_addr = MASTER_PSUM_ADDR + psum_sram_write_addr;
        insn_series.push_back(store_iteration_2<0>(store_addr, BLOCK_SIZE * BLOCK_SIZE * bytes_data / 32 - 1, 0, 0, 0, sram_store_addr, is_last_block));
      }
    }
  }

  void execute_rope_computation(std::vector<instruction>& insn_series, const Argument& args)
  {    
    /** Compute Tile Size to Fit SRAM Capacity */
    // MAX_PSUM_DEPTH / 2, because we need store real and imag parts separately
    // tile_m = 32; // for test
    tile_m = std::min(std::min(MAX_PSUM_DEPTH / 2, MAX_VCURES_DEPTH), args.seq_len);
    tile_dim_groups = std::min(std::min(MAX_PSUM_DEPTH / 2, MAX_VCURES_DEPTH) / tile_m, args.dim / n_group_size);
    // tile_dim_groups = 2;

    // 分块迭代参数
    int m_iterations = std::ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = std::ceil((double)(args.dim / n_group_size) / (double)tile_dim_groups);
    
    if (DEBUG) {
      print("======= RoPE Computation Parameters =======");
      print_dec("tile_m", tile_m);
      print_dec("tile_dim_groups", tile_dim_groups);
      print_dec("m_iterations", m_iterations);
      print_dec("n_iterations", n_iterations);
    }

    for (int n_iter = 0; n_iter < n_iterations; n_iter++) {
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
        
        // 计算当前块的实际大小
        int valid_item_seq_len = std::min(tile_m, args.seq_len - m_iter * tile_m);
        int valid_item_dim_groups = std::min(tile_dim_groups, args.dim / n_group_size - n_iter * tile_dim_groups);
                
        int split_data_num = valid_item_seq_len * valid_item_dim_groups * n_group_size / 2;  // 实部/虚部数据量
                
        if (DEBUG) {
          print_dec("=== Processing tile index ===", n_iter * m_iterations + m_iter);
          print_dec("valid_item_seq_len", valid_item_seq_len);
          print_dec("valid_item_dim_groups", valid_item_dim_groups);
          print_dec("split_data_num", split_data_num);
        }
        
        // 执行当前块的RoPE计算
        this->execute_rope_block(insn_series, args, m_iter, n_iter, 
                                valid_item_seq_len, valid_item_dim_groups, split_data_num);
      }
    }
  }

  private:
  void execute_rope_block(std::vector<instruction>& insn_series, const Argument& args,
                       int m_iter, int n_iter, int valid_item_seq_len, int valid_item_dim_groups, uint64_t split_data_num)
  {
    // SRAM地址配置
    uint64_t input_real_sram_addr = MASTER_PSUM_ADDR;
    uint64_t input_imag_sram_addr = MASTER_PSUM_ADDR + split_data_num * bytes_data / 32;
    uint64_t freq_real_sram_addr = MASTER_VCURES_ADDR;
    uint64_t freq_imag_sram_addr = MASTER_VCURES_ADDR + split_data_num * bytes_data / 32;
    
    // 计算当前块需要处理的子块数量
    int tile_row_blocks = valid_item_seq_len / BLOCK_SIZE;
    int tile_col_blocks = valid_item_dim_groups * n_group_size / BLOCK_SIZE;
    
    // 计算DDR地址偏移 [dim_groups, seq_len, n_group_size] 
    uint64_t input_n_offset = n_iter * tile_dim_groups * args.seq_len * n_group_size * bytes_data;
    uint64_t input_m_offset = m_iter * tile_m * n_group_size * bytes_data;

    auto input_ddr_offset_0 = split_exp_fra(2 * BLOCK_SIZE * bytes_data);
    auto input_ddr_offset_1 = split_exp_fra(args.seq_len * n_group_size * bytes_data);
    
    if (DEBUG){
      print("=== Load Data for Current Tile ===");
      print_dec("m_iter", m_iter);
      print_dec("n_iter", n_iter);
      print_dec("tile_row_blocks", tile_row_blocks);
      print_dec("tile_col_blocks", tile_col_blocks);
      print_hex("input_m_offset", input_m_offset);
      print_hex("input_n_offset", input_n_offset);
      print_hex("input_ddr_offset_0", 2 * BLOCK_SIZE * bytes_data);
      print_hex("input_ddr_offset_1", args.seq_len * n_group_size * bytes_data);
    }

    /** Load data */
    // Load input real part
    insn_series.push_back(load_iteration_3<0>(
      args.input_base_addr + input_m_offset + input_n_offset, 
      BLOCK_SIZE * bytes_data / 32 - 1, 
      input_ddr_offset_0.first, 
      input_ddr_offset_0.second, 
      tile_row_blocks * BLOCK_SIZE / 2 - 1,
      input_ddr_offset_1.first, 
      input_ddr_offset_1.second,
      tile_col_blocks - 1,
      input_real_sram_addr, 0));
    
    // Load input imaginary part  
    insn_series.push_back(load_iteration_3<0>(
      args.input_base_addr + input_m_offset + input_n_offset + BLOCK_SIZE * bytes_data, 
      BLOCK_SIZE * bytes_data / 32 - 1, 
      input_ddr_offset_0.first, 
      input_ddr_offset_0.second, 
      tile_row_blocks * BLOCK_SIZE / 2 - 1,
      input_ddr_offset_1.first, 
      input_ddr_offset_1.second,
      tile_col_blocks - 1,
      input_imag_sram_addr, 0));

    // Load freq real part
    insn_series.push_back(load_iteration_3<0>(
      args.freq_cls_base_addr + input_m_offset + input_n_offset, 
      BLOCK_SIZE * bytes_data / 32 - 1, 
      input_ddr_offset_0.first, 
      input_ddr_offset_0.second, 
      tile_row_blocks * BLOCK_SIZE / 2 - 1,
      input_ddr_offset_1.first, 
      input_ddr_offset_1.second,
      tile_col_blocks - 1,
      freq_real_sram_addr, 0));

    // Load freq imaginary part
    insn_series.push_back(load_iteration_3<0>(
      args.freq_cls_base_addr + input_m_offset + input_n_offset + BLOCK_SIZE * bytes_data, 
      BLOCK_SIZE * bytes_data / 32 - 1, 
      input_ddr_offset_0.first, 
      input_ddr_offset_0.second, 
      tile_row_blocks * BLOCK_SIZE / 2 - 1,
      input_ddr_offset_1.first, 
      input_ddr_offset_1.second,
      tile_col_blocks - 1,
      freq_imag_sram_addr, 0));

    /** 执行当前块的VCU运算 */
    this->execute_rope_vcu_operations(insn_series, args, 
                                      m_iter, n_iter, valid_item_seq_len, valid_item_dim_groups, 
                                      split_data_num);
  }

  void execute_rope_vcu_operations(std::vector<instruction>& insn_series, const Argument& args,
                                      int m_iter, int n_iter, int valid_item_seq_len, int valid_item_dim_groups,
                                      uint64_t split_data_num)
  {
    /** ===========VCU Execute for RoPE computation=========== */
    
    // VCU SRAM地址分配
    uint64_t psum_input_real_addr = 0;
    uint64_t psum_input_imag_addr = psum_input_real_addr + split_data_num / 32;
    uint64_t resadd_freq_real_addr = 0;
    uint64_t resadd_freq_imag_addr = resadd_freq_real_addr + split_data_num / 32;
    uint64_t temp_offset = 2 * split_data_num / 32;
    uint64_t psum_output_real_addr = 3 * split_data_num / 32;  // PSUM output real
    uint64_t psum_output_imag_addr = 4 * split_data_num / 32;  // PSUM output imag

    if(DEBUG){
      print("=== VCU SRAM Address Allocation ===");
      print_hex("psum_input_real_addr", psum_input_real_addr);
      print_hex("psum_input_imag_addr", psum_input_imag_addr);
      print_hex("resadd_freq_real_addr", resadd_freq_real_addr);
      print_hex("resadd_freq_imag_addr", resadd_freq_imag_addr);
      print_hex("temp_offset", temp_offset);
      print_hex("psum_output_real_addr", psum_output_real_addr);
      print_hex("psum_output_imag_addr", psum_output_imag_addr);
    }

    /** step1. Prepare Value of -input_imag * freq_imag */
    using vcu_t = vcu::VcuExecute;
    vcu_t::Arguments vcu_step1_args = {
      vcu_psum_dtype[kFloat32],      // psum_data_type
      vcu_resadd_dtype[kFloat32],    // resadd_para_type
      vcu_out_dtype[kFloat32],       // data_out_type
      VcuOutSram::VCURES,            // data_out_ram
      2,                             // opcode_number
      0,                             // opcode_addr
      psum_input_imag_addr,          // psum_in_addr
      0,                             // para_in_addr
      resadd_freq_imag_addr,         // resadd_in_addr
      temp_offset,                   // ram_out_addr
      split_data_num / 32 - 1,  // num_data
      0,                             // oc_group
      0                              // para_func
    };
    vcu_t vcu_step1_op;
    auto vcu_step1_insns = vcu_step1_op(vcu_step1_args);
    insn_series.insert(insn_series.end(), vcu_step1_insns.begin(), vcu_step1_insns.end());

    /** step2. input_real * freq_real */
    vcu_t::Arguments vcu_step2_args = {
      vcu_psum_dtype[kFloat32],      // psum_data_type
      vcu_resadd_dtype[kFloat32],    // resadd_para_type
      vcu_out_dtype[kFloat32],       // data_out_type
      VcuOutSram::PSUM,              // data_out_ram
      1,                             // opcode_number
      2,                             // opcode_addr
      psum_input_real_addr,          // psum_in_addr
      0,                             // para_in_addr
      resadd_freq_real_addr,         // resadd_in_addr
      temp_offset,                   // ram_out_addr
      split_data_num / 32 - 1,  // num_data
      0,                             // oc_group
      0                              // para_func
    };
    vcu_t vcu_step2_op;
    auto vcu_step2_insns = vcu_step2_op(vcu_step2_args);
    insn_series.insert(insn_series.end(), vcu_step2_insns.begin(), vcu_step2_insns.end());

    /** step3. Compute real for RoPE */
    vcu_t::Arguments vcu_step3_args = {
      vcu_psum_dtype[kFloat32],      // psum_data_type
      vcu_resadd_dtype[kFloat32],    // resadd_para_type
      vcu_out_dtype[kFloat32],       // data_out_type
      VcuOutSram::PSUM,              // data_out_ram
      1,                             // opcode_number
      3,                             // opcode_addr
      temp_offset,                   // psum_in_addr
      0,                             // para_in_addr
      temp_offset,                   // resadd_in_addr
      psum_output_real_addr,         // ram_out_addr
      split_data_num / 32 - 1,  // num_data
      0,                             // oc_group
      0                              // para_func
    };
    vcu_t vcu_step3_op;
    auto vcu_step3_insns = vcu_step3_op(vcu_step3_args);
    insn_series.insert(insn_series.end(), vcu_step3_insns.begin(), vcu_step3_insns.end());
    
    /** step4. input_real * freq_imag */
    vcu_t::Arguments vcu_step4_args = {
      vcu_psum_dtype[kFloat32],      // psum_data_type
      vcu_resadd_dtype[kFloat32],    // resadd_para_type
      vcu_out_dtype[kFloat32],       // data_out_type
      VcuOutSram::VCURES,            // data_out_ram
      1,                             // opcode_number
      4,                             // opcode_addr
      psum_input_real_addr,          // psum_in_addr
      0,                             // para_in_addr
      resadd_freq_imag_addr,         // resadd_in_addr
      temp_offset,                   // ram_out_addr
      split_data_num / 32 - 1,  // num_data
      0,                             // oc_group
      0                              // para_func
    };
    vcu_t vcu_step4_op;
    auto vcu_step4_insns = vcu_step4_op(vcu_step4_args);
    insn_series.insert(insn_series.end(), vcu_step4_insns.begin(), vcu_step4_insns.end());

    /** step5. input_imag * freq_real */
    vcu_t::Arguments vcu_step5_args = {
      vcu_psum_dtype[kFloat32],      // psum_data_type
      vcu_resadd_dtype[kFloat32],    // resadd_para_type
      vcu_out_dtype[kFloat32],       // data_out_type
      VcuOutSram::PSUM,              // data_out_ram
      1,                             // opcode_number
      5,                             // opcode_addr
      psum_input_imag_addr,          // psum_in_addr
      0,                             // para_in_addr
      resadd_freq_real_addr,         // resadd_in_addr
      temp_offset,                   // ram_out_addr
      split_data_num / 32 - 1,  // num_data
      0,                             // oc_group
      0                              // para_func
    };
    vcu_t vcu_step5_op;
    auto vcu_step5_insns = vcu_step5_op(vcu_step5_args);
    insn_series.insert(insn_series.end(), vcu_step5_insns.begin(), vcu_step5_insns.end());

    /** step6. Compute imag for RoPE */
    vcu_t::Arguments vcu_step6_args = {
      vcu_psum_dtype[kFloat32],      // psum_data_type
      vcu_resadd_dtype[kFloat32],    // resadd_para_type
      vcu_out_dtype[kFloat32],       // data_out_type
      VcuOutSram::PSUM,              // data_out_ram
      1,                             // opcode_number
      6,                             // opcode_addr
      temp_offset,                   // psum_in_addr
      0,                             // para_in_addr
      temp_offset,                   // resadd_in_addr
      psum_output_imag_addr,         // ram_out_addr
      split_data_num / 32 - 1,  // num_data
      0,                             // oc_group
      0                              // para_func
    };
    vcu_t vcu_step6_op;
    auto vcu_step6_insns = vcu_step6_op(vcu_step6_args);
    insn_series.insert(insn_series.end(), vcu_step6_insns.begin(), vcu_step6_insns.end());

    auto output_real_sram_addr = MASTER_PSUM_ADDR + 3 * split_data_num * bytes_data / 32;
    auto output_imag_sram_addr = output_real_sram_addr + split_data_num * bytes_data / 32;

    /** =================Store results================= */
    // 计算当前块需要处理的子块数量
    int tile_row_blocks = valid_item_seq_len / BLOCK_SIZE;
    int tile_col_blocks = valid_item_dim_groups * n_group_size / BLOCK_SIZE;

    uint64_t output_n_offset = n_iter * tile_dim_groups * args.seq_len * n_group_size * bytes_data;
    uint64_t output_m_offset = m_iter * tile_m * n_group_size * bytes_data;
    auto output_ddr_offset_0 = split_exp_fra(2 * BLOCK_SIZE * bytes_data);
    auto output_ddr_offset_1 = split_exp_fra(args.seq_len * n_group_size * bytes_data);

    // Store real part
    insn_series.push_back(store_iteration_3<0>(
      args.output_base_addr + output_m_offset + output_n_offset,
      BLOCK_SIZE * bytes_data / 32 - 1,
      output_ddr_offset_0.first,
      output_ddr_offset_0.second,
      tile_row_blocks * BLOCK_SIZE / 2 - 1,
      output_ddr_offset_1.first,
      output_ddr_offset_1.second,
      tile_col_blocks - 1,
      output_real_sram_addr, 0));
      
    // Store imaginary part
    insn_series.push_back(store_iteration_3<0>(
      args.output_base_addr + output_m_offset + output_n_offset + BLOCK_SIZE * bytes_data,
      BLOCK_SIZE * bytes_data / 32 - 1,
      output_ddr_offset_0.first,
      output_ddr_offset_0.second,
      tile_row_blocks * BLOCK_SIZE / 2 - 1,
      output_ddr_offset_1.first,
      output_ddr_offset_1.second,
      tile_col_blocks - 1,
      output_imag_sram_addr, 0));

    if(DEBUG){
      print("=== Store Output for Current Tile ===");
      print_hex("output_m_offset", output_m_offset);
      print_hex("output_n_offset", output_n_offset);
      print_hex("output_ddr_offset_0", 2 * BLOCK_SIZE * bytes_data);
      print_hex("output_ddr_offset_1", args.seq_len * n_group_size * bytes_data);
    }
  }
};

} // namespace rope_embedding
} // namespace transformer