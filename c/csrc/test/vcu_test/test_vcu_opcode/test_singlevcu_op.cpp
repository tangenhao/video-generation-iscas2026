#include "vcu/vcu_operation.h"
#include "common/file_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "common/insn.h"
#include "addr.h"
#include "write_reg.h"

int main(int argc, const char** argv) 
{
  using namespace common;
  using namespace compute_model::tensor;
  using namespace compute_model::common::fp16;

  // 配置参数
  int seq_len = 10;
  int tile_m = 2;
  int block_oc_group = 1;
  int d_model = 128;
  int oc_group_size = 32;
  int oc_group = d_model / oc_group_size;

  auto data_in1 = randn<float>({oc_group, seq_len, oc_group_size}, kFloat32, -1.0f, 1.0f, 0);
  common::file_utils::saveCharArrayToFormattedTextFile(
    psum_file.c_str(), reinterpret_cast<char*>(data_in1.data_ptr()), data_in1.numel() * sizeof(float), 32, true);
  auto data_in2 = randn<float>({oc_group, seq_len, oc_group_size}, kFloat32, -1.0f, 1.0f, 1);
  common::file_utils::saveCharArrayToFormattedTextFile(
    res_file.c_str(), reinterpret_cast<char*>(data_in2.data_ptr()), data_in2.numel() * sizeof(float), 32, true);
  

  /* -------------------------------------------------------------------------------------------------------- */
  /*                           Reference Output Generation                                                    */
  /* -------------------------------------------------------------------------------------------------------- */
  
  using namespace compute_model::tensor;
  using namespace compute_model::function;

  /** ParallelismConvertion32to16 */
  // auto data_out = zeros<half>({oc_group * 2, seq_len, oc_group_size / 2}, kHalf);
  // auto data_out_ref = ToFloat16(data_in1);
  // data_out_ref = ParallelismConvertion32to16(data_out_ref);

  /** mul_elementwise */
  // auto data_out = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);
  // auto data_out_ref = mul_elementwise(data_in1, data_in2);
  /** add_elementwise */
  auto data_out = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);
  auto data_out_ref = add_elementwise(data_in1, data_in2);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(data_out_ref.data_ptr()), data_out_ref.numel() * sizeof(float), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                               Generate Instructions                                                                  */
  /* -------------------------------------------------------------------------------------------------------- */

  /** create vcu op */
  vcu::operation::SingleVCUOp<> mul_op;
  
  /** basic parameters */
  vcu::operation::SingleVCUOp<>::Argument args;
  args.seq_len = seq_len;
  args.d_model = d_model;
  args.tile_m = tile_m;
  args.block_oc_group = block_oc_group;
  args.dtype = kFloat32;
  args.op_type = vcu::operation::OP_TYPE::ADD;

  /** address settings */
  args.input1_base_addr = PSUM_ADDR;
  args.input2_base_addr = VCURES_ADDR;
  args.output_base_addr = OFMAP_ADDR;
  args.vcu_code_addr = VCUCODE_ADDR;

  /** generate instructions and opcode */
  auto result = mul_op(args);
  auto insn_series = result.first;
  auto vcucode_series = result.second;

  common::insn::pad_serial_sync_word(insn_series);

  /** save opcode */
  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), 
    reinterpret_cast<char*>(vcucode_series.data()), 
    vcucode_series.size() * sizeof(uint64_t), 
    32, true);
    
  /** save instructions */
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), 
    reinterpret_cast<char*>(insn_series.data()), 
    insn_series.size() * sizeof(common::insn::instruction), 
    32, true);
    
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


