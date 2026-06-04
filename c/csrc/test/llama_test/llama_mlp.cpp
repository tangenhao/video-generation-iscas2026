#include "common/insn.h"
#include "common/type_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/gemm/gemm.h"
#include "instruction/parser.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include <vector>
#include <cmath>
#include "addr_for_llama.h"

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
  using namespace compute_model::common::fp16;
  
  // MLP配置参数
  int seq_len = 64;          // 序列长度
  int hidden_size = 32;     // 隐藏层大小
  int intermediate_size = 32;
  // int intermediate_size = (8/3 * hidden_size + 256 - 1) / 256 * 256; 
  
  // 硬件相关参数
  int n_group_size = 32;     // 输出通道组大小，对应于GemmOp的n维度
  int k_group_size = 16;     // 输入通道组大小，对应于GemmOp的k维度
  
  int d_model = hidden_size;
  int d_ff = intermediate_size;
  
  int n_group = d_model / n_group_size;        // 输出通道组数
  int n_group_ff = d_ff / n_group_size;        // 中间层输出通道组数
  int k_group = d_model / k_group_size;        // 输入通道组数
  int k_group_ff = d_ff / k_group_size;        // 中间层输入通道组数
  
  // 分块参数
  int tile_m = seq_len;       // 矩阵乘法中M维度的分块大小
  int block_n_group = 1;      // N维度的分块参数
  int block_k_group = 1;      // K维度的分块参数
  
  // DDR基址
  uint64_t input_ddr_base_addr = BLOCK_INPUT_ADDR;
  uint64_t gate_weight_ddr_base_addr = MLP_GATE_WEIGHT_ADDR;
  uint64_t up_weight_ddr_base_addr = MLP_UP_WEIGHT_ADDR;
  uint64_t down_weight_ddr_base_addr = MLP_DOWN_WEIGHT_ADDR;
  uint64_t gate_output_ddr_base_addr = MLP_GATE_OUTPUT_ADDR;
  uint64_t up_output_ddr_base_addr = MLP_UP_OUTPUT_ADDR;
  uint64_t mul_output_ddr_base_addr = MLP_MUL_OUTPUT_ADDR;
  uint64_t final_output_ddr_base_addr = BLOCK_OUTPUT_ADDR;
  uint64_t swish_lut_ddr_base_addr = LLAMA_BLOCK_SWISH_LUT_ADDR;
  uint64_t opcode_ddr_base_addr = LLAMA_BLOCK_VCUCODE_ADDR;
  
  std::cout << "opcode_ddr_base_addr: " << opcode_ddr_base_addr << std::endl;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                数据生成                                                   */
  /* -------------------------------------------------------------------------------------------------------- */
  
  // 输入张量: [k_group, seq_len, k_group_size]
  auto input = randn<half>({k_group, seq_len, k_group_size}, kHalf, -1.0f, 1.0f, 42);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_input_hidden_state.txt", reinterpret_cast<char*>(input.data_ptr()), input.numel() * sizeof(half), 32, true);
  
  // up投影权重: [n_group_ff, k_group, n_group_size, k_group_size]
  auto up_weight = randn<half>({n_group_ff, k_group, n_group_size, k_group_size}, kHalf, -1.0f, 1.0f, 44);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_mlp_up_weight.txt", reinterpret_cast<char*>(up_weight.data_ptr()), up_weight.numel() * sizeof(half), 32, true);

  // gate投影权重: [n_group_ff, k_group, n_group_size, k_group_size]
  auto gate_weight = randn<half>({n_group_ff, k_group, n_group_size, k_group_size}, kHalf, -1.0f, 1.0f, 43);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_mlp_gate_weight.txt", reinterpret_cast<char*>(gate_weight.data_ptr()), gate_weight.numel() * sizeof(half), 32, true);

  // down投影权重: [n_group, k_group_ff, n_group_size, k_group_size]
  auto down_weight = randn<half>({n_group, k_group_ff, n_group_size, k_group_size}, kHalf, -1.0f, 1.0f, 45);
  common::file_utils::saveCharArrayToFormattedTextFile( 
    "../../sim/memory_llama/block_mlp_down_weight.txt", reinterpret_cast<char*>(down_weight.data_ptr()), down_weight.numel() * sizeof(half), 32, true);

  // 初始化输出张量
  auto gate_output = zeros<float>({n_group_ff, seq_len, n_group_size}, kFloat32);
  auto up_output = zeros<float>({n_group_ff, seq_len, n_group_size}, kFloat32);
  auto swish_output = zeros<float>({n_group_ff, seq_len, n_group_size}, kFloat32);
  auto mul_output = zeros<float>({n_group_ff, seq_len, n_group_size}, kFloat32);
  auto final_output = zeros<float>({n_group, seq_len, n_group_size}, kFloat32);
  
  /* -------------------------------------------------------------------------------------------------------- */
  /*                                               模型计算                                                    */
  /* -------------------------------------------------------------------------------------------------------- */
  std::cout << "------------------------------------" << std::endl;
  std::cout << "------------up_output---------------" << std::endl;
  std::cout << "------------------------------------" << std::endl;

  // 1. up投影: up_output = up_proj(x)
  using gemm_up_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, true>;
  gemm_up_t::Arguments up_args = {up_output, input, up_weight, tile_m, block_n_group, block_k_group};
  gemm_up_t up_op;
  up_op(up_args);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/up_output.txt", reinterpret_cast<char*>(up_output.data_ptr()), up_output.numel() * sizeof(float), 32, true);

  // 2. gate投影: gate_output = gate_proj(x)
  std::cout << "------------------------------------" << std::endl;
  std::cout << "------------gate_output---------------" << std::endl;
  std::cout << "------------------------------------" << std::endl;
  using gemm_gate_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, true>;
  gemm_gate_t::Arguments gate_args = {gate_output, input, gate_weight, tile_m, block_n_group, block_k_group};
  gemm_gate_t gate_op;
  gate_op(gate_args);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/gate_output.txt", reinterpret_cast<char*>(gate_output.data_ptr()), gate_output.numel() * sizeof(float), 32, true);

  std::cout << "------------------------------------" << std::endl;
  std::cout << "------------swish_output---------------" << std::endl;
  std::cout << "------------------------------------" << std::endl;
  // 3. fast_swish激活: swish_output = swish(gate_output)
  swish_output = compute_model::function::fast_swish(gate_output);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/swish_output.txt", reinterpret_cast<char*>(swish_output.data_ptr()), swish_output.numel() * sizeof(float), 32, true);

  std::cout << "------------------------------------" << std::endl;
  std::cout << "------------mul_output---------------" << std::endl;
  std::cout << "------------------------------------" << std::endl;
  // 4. 逐元素乘法: mul_output = swish_output * up_output
  for (int oc_iter = 0; oc_iter < n_group_ff; oc_iter++) {
    for (int seq_len_iter = 0; seq_len_iter < seq_len; seq_len_iter++) {
      for (int oc_inner_iter = 0; oc_inner_iter < n_group_size; oc_inner_iter++) {
        mul_output[oc_iter * seq_len * n_group_size + seq_len_iter * n_group_size + oc_inner_iter] = 
        swish_output[oc_iter * seq_len * n_group_size + seq_len_iter * n_group_size + oc_inner_iter] 
        * up_output[oc_iter * seq_len * n_group_size + seq_len_iter * n_group_size + oc_inner_iter];
      }
    }
  }

  // 5. 将mul_output转换为half类型, 然后进行并行度转换
  auto mul_output_half = ToFloat16(mul_output);
  common::file_utils::saveCharArrayToFormattedTextFile(
  "../../sim/memory_llama/mul_output_half.txt", reinterpret_cast<char*>(mul_output_half.data_ptr()), mul_output_half.numel() * sizeof(half), 32, true);

  mul_output_half = ParallelismConvertion32to16(mul_output_half);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/mul_output_converted.txt", reinterpret_cast<char*>(mul_output_half.data_ptr()), mul_output_half.numel() * sizeof(half), 32, true);

  // 6. down投影: final_output = down_proj(mul_output_half)
  std::cout << "------------------------------------" << std::endl;
  std::cout << "------------final_output---------------" << std::endl;
  std::cout << "------------------------------------" << std::endl;
  using gemm_down_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, true>;
  gemm_down_t::Arguments down_args = {final_output, mul_output_half, down_weight, tile_m, block_n_group, block_k_group};
  gemm_down_t down_op;
  down_op(down_args);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_output_hidden_state_ref.txt", reinterpret_cast<char*>(final_output.data_ptr()), final_output.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                               指令生成                                                    */
  /* -------------------------------------------------------------------------------------------------------- */
  
  std::vector<insn::instruction> insn_series;
  
  // 1. 加载Swish LUT表, 配置VCU
  insn_series.push_back(insn::load_iteration_2<0>(swish_lut_ddr_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
  
  using vcu_cfg_t = vcu::VcuConfig;
  vcu_cfg_t::Arguments cfg_args = {0, 0, 1, 2, 3, 0, 0, 0, 0, 0};
  vcu_cfg_t vcu_cfg;
  auto vcu_cfg_insns = vcu_cfg(cfg_args);
  insn_series.insert(insn_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());

  // 2. 加载VCU操作码
  auto vcucode_series = vcu::asm_vcu_op({
    "fastswish psum, reg0",  //fastswish激活
    "mul psum resadd, reg1",  //逐元素乘法
  });
  size_t vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  vcucode_series.resize(vcucode_ddr_lines * 8, 0);
  
  insn_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/vcucode.txt", reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  // 3. 计算up_proj(x) - 使用GemmOp
  using pea_gemm_up_t = pea::GemmOp<0, 0, 0, 0, kHalf, kHalf, kFloat32, kFloat32, true>;
  pea_gemm_up_t::Arguments pea_up_args = {
    seq_len,        // m
    intermediate_size, // n
    hidden_size,    // k
    tile_m,         // tile_m
    block_n_group,  // block_n_group
    block_k_group,  // block_k_group
    input_ddr_base_addr,       // 输入数据地址
    up_weight_ddr_base_addr,   // 权重地址
    up_output_ddr_base_addr,    // 输出地址
    0,  //ifmap_scale_base_addr
    0,  //weight_scale_base_addr
    0,  //outlier_index_base_addr
    0,  //ifmap_mask_base_addr
    0   //all_done
  };
  pea_gemm_up_t pea_up_op;
  auto up_insns = pea_up_op(pea_up_args);
  insn_series.insert(insn_series.end(), up_insns.begin(), up_insns.end());

  // 4. 计算gate_proj(x) - 使用GemmOp,默认insn_opcode = 17 - PEA0
  using pea_gemm_t = pea::GemmOp<0, 0, 0, 0, kHalf, kHalf, kFloat32, kFloat32, true>;
  pea_gemm_t::Arguments pea_gate_args = {
    seq_len,        // m
    intermediate_size,    // n
    hidden_size,    // k
    tile_m,         // tile_m
    block_n_group,  // block_n_group
    block_k_group,  // block_k_group
    input_ddr_base_addr,        // 输入数据地址
    gate_weight_ddr_base_addr,  // 权重地址
    gate_output_ddr_base_addr,   // 输出地址
    0,  //ifmap_scale_base_addr
    0,  //weight_scale_base_addr
    0,  //outlier_index_base_addr
    0,  //ifmap_mask_base_addr
    0   //all_done
  };
  pea_gemm_t pea_gate_op;
  auto gate_insns = pea_gate_op(pea_gate_args);
  insn_series.insert(insn_series.end(), gate_insns.begin(), gate_insns.end());
    
  // 5. 从PSUM_ADDR加载gate_output用于swish激活 (激活函数需要显式加载)
  auto gate_seq_1_offset = split_exp_fra(seq_len * n_group_size * 4);
  // TODO： 后续需要处理容量的问题， gate_output可能超过sram容量
  insn_series.push_back(insn::load_iteration_2<0>(gate_output_ddr_base_addr,
                                              seq_len * 4 - 1,
                                              gate_seq_1_offset.first,
                                              gate_seq_1_offset.second,
                                              n_group_ff - 1,
                                              MASTER_PSUM_ADDR,
                                              0));
                                                   
  // 6. 执行Swish激活
  using vcu_t = vcu::VcuExecute;  // 默认insn_opcode = 25 - VCU0
  vcu_t::Arguments vcu_args = {vcu_psum_dtype[kFloat32],  //psum_data_type
                             vcu_resadd_dtype[kFloat32],  //resadd_para_type
                             vcu_out_dtype[kFloat32],  //data_out_type
                             VcuOutSram::PSUM,      //data_out_ram
                             1,     //opcode_number
                             0,     //opcode_addr
                             0,     //psum_in_addr
                             0,     //para_in_addr
                             0,     //resadd_in_addr
                             0,     //ram_out_addr
                             (uint64_t)seq_len - 1,  //num_data
                             (uint64_t)n_group_ff - 1, //oc_group
                             0};    //para_func
  
  vcu_t vcu_op;
  auto vcu_insns = vcu_op(vcu_args);
  insn_series.insert(insn_series.end(), vcu_insns.begin(), vcu_insns.end());

  // 7. 加载up_output (准备乘法操作)
  auto up_seq_1_offset = split_exp_fra(seq_len * n_group_size * 4);
  
  insn_series.push_back(insn::load_iteration_2<0>(up_output_ddr_base_addr,
                                             seq_len * n_group_size * sizeof(float) / 32 - 1,
                                             up_seq_1_offset.first,
                                             up_seq_1_offset.second,
                                             n_group_ff - 1,
                                             MASTER_VCURES_ADDR,
                                             0));
                                                 
  // 8. 执行乘法操作 (swish_output * up_output), fp32 * fp32 -> fp16
  using vcu_t = vcu::VcuExecute;  // 默认insn_opcode = 25 - VCU0
  vcu_t::Arguments mul_vcu_args = {vcu_psum_dtype[kFloat32],  //psum_data_type
                                  vcu_resadd_dtype[kFloat32],  //resadd_para_type
                                  vcu_out_dtype[kHalf],  //data_out_type
                                  VcuOutSram::PSUM,  //data_out_ram
                                  1,  //opcode_number
                                  1,  //opcode_addr
                                  0,  //psum_in_addr
                                  0,  //para_in_addr
                                  0,  //resadd_in_addr
                                  0,  //ram_out_addr
                                  (uint64_t)seq_len - 1,  //num_data
                                  (uint64_t)n_group_ff - 1, //oc_group
                                  0};    //para_func

  vcu_t mul_vcu_op;
  auto mul_vcu_insns = mul_vcu_op(mul_vcu_args);
  insn_series.insert(insn_series.end(), mul_vcu_insns.begin(), mul_vcu_insns.end());
  
  auto vcu_convert =  // 注意这里是写回ofmap_sram !!!
    insn::vcu_parallelism_conversion(0, 0, 0, seq_len, n_group_ff, n_group_ff * 2); 
  vcu_convert.set_insn_number(0);
  vcu_convert.set_insn_opcode(25);
  insn_series.push_back(vcu_convert); // 并行度转换, [n_group_ff, seq_len, n_group_size] -> [k_group_ff, seq_len, k_group_size]
  
  // 9. 存储乘法结果, fp16
  auto mul_seq_1_offset = split_exp_fra(seq_len * k_group_size * 2);
  insn_series.push_back(insn::store_iteration_2<0>(mul_output_ddr_base_addr,
                                              seq_len * k_group_size * 2 / 32 - 1,
                                              mul_seq_1_offset.first,
                                              mul_seq_1_offset.second,
                                              k_group_ff - 1,
                                              MASTER_OFMAP_ADDR,
                                              0));
  
  // 10. 执行down_proj(mul_output) - 使用GemmOp
  using pea_gemm_down_t = pea::GemmOp<0, 0, 0, 0, kHalf, kHalf, kFloat32, kFloat32, true>;
  pea_gemm_down_t::Arguments pea_down_args = {
    seq_len,          // m
    hidden_size,      // n
    intermediate_size,// k
    tile_m,           // tile_m
    block_n_group,    // block_n_group
    block_k_group,    // block_k_group
    mul_output_ddr_base_addr, // 输入数据地址
    down_weight_ddr_base_addr,  // 权重地址
    final_output_ddr_base_addr,  // 输出地址
    0,  //ifmap_scale_base_addr
    0,  //weight_scale_base_addr
    0,  //outlier_index_base_addr
    0,  //ifmap_mask_base_addr
    1   //all_done
  };
  pea_gemm_down_t pea_down_op;
  auto down_insns = pea_down_op(pea_down_args);
  insn_series.insert(insn_series.end(), down_insns.begin(), down_insns.end());
  
  // 填充指令序列
  common::insn::pad_serial_sync_word(insn_series);
  common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/insn.txt", reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);
  
  // 解析指令
  auto parser = common::insn::instruction_parser(insn_series);
  parser.parse_instruction();
  
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }
  
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
