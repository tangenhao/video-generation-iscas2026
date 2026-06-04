#pragma once

#include "addr_for_transformer.h"
#include "common/insn.h"
#include "common/type_utils.h"
#include "vcu/vcu_opcode.h"

namespace transformer {
namespace mha {

using namespace common::insn;

/** Redirect std output to file or console */
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

int CORE_NUM = 1;
int CLUSTER_NUM = 1; 
int CORE_PER_CLUSTER = CORE_NUM / CLUSTER_NUM;

template<bool DEBUG, bool BIAS = false>
struct MultiHeadAttentionSimpleOp {

  static constexpr int MAX_IFMAP_DEPTH  = 512;
  static constexpr int MAX_WEIGHT_DEPTH = 1024;
  static constexpr int MAX_PSUM_DEPTH   = 512;
  static constexpr int MAX_OFMAP_DEPTH  = 1024;

  int k_group_size;
  int n_group_size;
  int bytes_ifmap;
  int bytes_weight;
  int bytes_psum;
  int bytes_bias;
  int bytes_ofmap;
  int n_group_scale;

  struct Argument {
    int      seq_len;
    int      d_model;
    int      head_num;
    uint64_t input_base_addr;
    uint64_t weight_query_base_addr;
    uint64_t weight_key_base_addr;
    uint64_t weight_value_base_addr;
    uint64_t weight_output_base_addr;
    uint64_t query_temp_base_addr;
    uint64_t key_temp_base_addr;
    uint64_t value_temp_base_addr;
    uint64_t score_temp_base_addr;
    uint64_t probe_temp_base_addr;
    uint64_t output_temp_base_addr;
    uint64_t output_base_addr;
    uint64_t mask_base_addr        = 0;
    uint64_t bias_query_base_addr  = 0;
    uint64_t bias_key_base_addr    = 0;
    uint64_t bias_value_base_addr  = 0;
    uint64_t bias_output_base_addr = 0;
    
  };

  MultiHeadAttentionSimpleOp()
  {
    /** Default float16 * float16 -> float32 -> float16 */
    k_group_size  = 16;
    n_group_size  = 32;
    bytes_ifmap   = 2;
    bytes_weight  = 2;
    bytes_psum    = 4;
    bytes_bias    = 4;
    bytes_ofmap   = 2;
    n_group_scale = 2;
  }

  std::pair<std::vector<instruction>, std::vector<uint64_t>> operator()(const Argument& args)
  {
    std::vector<instruction> insn_series;
    std::vector<uint64_t>    opcode;

    /** Load vcucode for each core */
    insn_series.push_back(load_iteration_2<0>(MHA_VCUCODE_ADDR, 20, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    insn_series.push_back(load_iteration_2<0>(MHA_VCUCODE_ADDR, 20, 0, 0, 0, MASTER_VCUCODE_ADDR + 32, 0));
    insn_series.push_back(load_iteration_2<1>(MHA_VCUCODE_ADDR, 20, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    insn_series.push_back(load_iteration_2<1>(MHA_VCUCODE_ADDR, 20, 0, 0, 0, MASTER_VCUCODE_ADDR + 32, 0));
    insn_series.push_back(load_iteration_2<2>(MHA_VCUCODE_ADDR, 20, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    insn_series.push_back(load_iteration_2<2>(MHA_VCUCODE_ADDR, 20, 0, 0, 0, MASTER_VCUCODE_ADDR + 32, 0));
    insn_series.push_back(load_iteration_2<3>(MHA_VCUCODE_ADDR, 20, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    insn_series.push_back(load_iteration_2<3>(MHA_VCUCODE_ADDR, 20, 0, 0, 0, MASTER_VCUCODE_ADDR + 32, 0));

    /** Load vculut for each core */
    insn_series.push_back(load_iteration_2<0>(EXP_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    insn_series.push_back(load_iteration_2<0>(EXP_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 128, 0));
    insn_series.push_back(load_iteration_2<0>(SWISH_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 32, 0));
    insn_series.push_back(load_iteration_2<0>(SWISH_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 160, 0));
    insn_series.push_back(load_iteration_2<0>(REC_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64, 0));
    insn_series.push_back(load_iteration_2<0>(REC_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 192, 0));
    insn_series.push_back(load_iteration_2<1>(EXP_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    insn_series.push_back(load_iteration_2<1>(EXP_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    insn_series.push_back(load_iteration_2<1>(SWISH_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 32, 0));
    insn_series.push_back(load_iteration_2<1>(SWISH_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 160, 0));
    insn_series.push_back(load_iteration_2<1>(REC_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64, 0));
    insn_series.push_back(load_iteration_2<1>(REC_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 192, 0));
    insn_series.push_back(load_iteration_2<2>(EXP_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    insn_series.push_back(load_iteration_2<2>(EXP_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    insn_series.push_back(load_iteration_2<2>(SWISH_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 32, 0));
    insn_series.push_back(load_iteration_2<2>(SWISH_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 160, 0));
    insn_series.push_back(load_iteration_2<2>(REC_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64, 0));
    insn_series.push_back(load_iteration_2<2>(REC_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 192, 0));
    insn_series.push_back(load_iteration_2<3>(EXP_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    insn_series.push_back(load_iteration_2<3>(EXP_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    insn_series.push_back(load_iteration_2<3>(SWISH_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 32, 0));
    insn_series.push_back(load_iteration_2<3>(SWISH_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 160, 0));
    insn_series.push_back(load_iteration_2<3>(REC_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64, 0));
    insn_series.push_back(load_iteration_2<3>(REC_LUT_ADDR, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 192, 0));

    auto vcu_cfg_insns = vcu_config(0, 2, 0, 0, 0, 0, 0, 1, 0, 0);
    vcu_cfg_insns.set_insn_opcode(25);
    insn_series.push_back(vcu_cfg_insns);
    vcu_cfg_insns.set_insn_opcode(26);
    insn_series.push_back(vcu_cfg_insns);
    vcu_cfg_insns.set_insn_opcode(27);
    insn_series.push_back(vcu_cfg_insns);
    vcu_cfg_insns.set_insn_opcode(28);
    insn_series.push_back(vcu_cfg_insns);
    vcu_cfg_insns.set_insn_opcode(29);
    insn_series.push_back(vcu_cfg_insns);
    vcu_cfg_insns.set_insn_opcode(30);
    insn_series.push_back(vcu_cfg_insns);
    vcu_cfg_insns.set_insn_opcode(31);
    insn_series.push_back(vcu_cfg_insns);
    vcu_cfg_insns.set_insn_opcode(32);
    insn_series.push_back(vcu_cfg_insns);

    this->set_vcucode(opcode);
    this->compute_q(insn_series, args, 1);
    this->compute_k(insn_series, args, 0);
    set_fase_broadcast(insn_series);
    this->compute_qkt(insn_series, args, 1);
    this->softmax(insn_series, args, 0);
    set_broadcast(insn_series);
    this->compute_v(insn_series, args, 0);
    set_fase_broadcast(insn_series);
    this->compute_pv(insn_series, args, 1);
    set_broadcast(insn_series);
    this->compute_o(insn_series, args, 1);
    
    return {insn_series, opcode};
  }

  void set_broadcast(std::vector<instruction>& insn_series) {
    insn_series.push_back(load_iteration_2<0>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<2>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<4>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<6>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
  }

  void set_fase_broadcast(std::vector<instruction>& insn_series) {
    insn_series.push_back(load_iteration_2<0>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<2>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<4>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<6>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
  }

  void set_vcucode(std::vector<uint64_t>& opcode)
  {
    /** bias or copy */
    if (BIAS) {
      /** If BIAS is enabled, generate the code to load bias */
      auto query_code = vcu::asm_vcu_op({"add psum, para, reg0"});
      opcode.insert(opcode.end(), query_code.begin(), query_code.end());
    }
    else {
      auto query_code = vcu::asm_vcu_op({"copy psum, reg0"});
      opcode.insert(opcode.end(), query_code.begin(), query_code.end());
    }

    /** Scale Product */
    auto vcucode = vcu::asm_vcu_op({"config reg0, 0x3e000000", "mul psum reg0, reg1"});
    for (auto code : vcucode) {
      opcode.push_back(code);
    }

    /** softmax */
    vcucode = vcu::asm_vcu_op({
      /** Clean vcures */
      "config reg0, 0.0",  // addr 3

      /** Compute exp2 for all input data */
      "mulc psum, reg0, " + std::to_string(std::log2(exp(1.0f))),  // addr 4
      "exp2 reg0, reg0",                                           // addr 5

      /** Reduce sum to compute sum(exp(x)), for common cases*/
      "redsum psum, reg0, 32",  // addr 6
      "add reg0 resadd, reg1",  // addr 7

      /** Compute reciprocal of sum(exp(x)) */
      "rec resadd, reg0",  // addr 8

      /** Multiply exp(x) by 1/sum(exp(x)) */
      "mul psum resadd, reg0",  // addr 9
    });

    for (int i = 0; i < vcucode.size(); i++) {
      opcode.push_back(vcucode[i]);
    }
  }

  void compute_o(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.d_model / k_group_size;
    int n_groups = args.d_model / n_group_size;

    /** set tile_m to MAX_IFMAP_DEPTH or args.seq_len to fully utilize the ifmap sram */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    /** set block_k_group to MAX_IFMAP_DEPTH / tile_m or k_groups to fully utilize the ifmap sram */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    /** set block_n_group to MAX_WEIGHT_DEPTH / n_group_size / block_k_group or n_groups to fully utilize the weight sram */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);

    /** The number of iterations on each dimension */
    int m_iterations = ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = ceil((double)n_groups / (double)block_n_group);
    int k_iterations = ceil((double)k_groups / (double)block_k_group);

    if (DEBUG) {
      print("======== O Computation Iteration Setting ========");
      print_dec("tile_m", tile_m);
      print_dec("block_k_group", block_k_group);
      print_dec("block_n_group", block_n_group);
      print_dec("m_iterations", m_iterations);
      print_dec("n_iterations", n_iterations);
      print_dec("k_iterations", k_iterations);
    }

    for (int n_iter = 0; n_iter < n_iterations; n_iter += CORE_NUM) {
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
        /** valid_item_seq_len is the actual seq_len for each iteration */
        int valid_item_seq_len = (m_iter * tile_m + tile_m) <= args.seq_len ? tile_m : args.seq_len - m_iter * tile_m;
        for (int k_iter = 0; k_iter < k_iterations; k_iter++) {
          /** valid_item_k_group is the actual k_group_size for each iteration */
          int valid_item_k_group = (k_iter * block_k_group + block_k_group) <= k_groups ? block_k_group : k_groups - k_iter * block_k_group;

          if (DEBUG) {
            print("======== O Computation Iteration ========");
            print_dec("n_iter", n_iter);
            print_dec("m_iter", m_iter);
            print_dec("k_iter", k_iter);
            print_dec("valid_item_seq_len", valid_item_seq_len);
            print_dec("valid_item_k_group", valid_item_k_group);
          }

          /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
          uint64_t input_ddr_addr = (k_iter * block_k_group) * args.seq_len * k_group_size * bytes_ifmap
                                    + m_iter * valid_item_seq_len * k_group_size * bytes_ifmap + args.output_temp_base_addr;
          auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

          /** Compute offset of weight: the weight is stored in the format of [d_model/n_group_size, d_model/k_group_size, n_group_size,
           * k_group_size]*/
          uint64_t weight_ddr_addr = (n_iter * block_n_group) * args.d_model * n_group_size * bytes_weight
                                     + (k_iter * block_k_group) * n_group_size * k_group_size * bytes_weight + args.weight_output_base_addr;
          auto weight_ddr_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_weight);
          auto weight_ddr_offset_1 = split_exp_fra(n_group_size * args.d_model * bytes_weight);

          for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
            /** Load input */
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto load_input = load_iteration_2<0>(input_ddr_addr,
                                                    valid_item_seq_len - 1,
                                                    input_ddr_offset.first,
                                                    input_ddr_offset.second,
                                                    valid_item_k_group - 1,
                                                    MASTER_IFMAP_ADDR,
                                                    0);
              load_input.set_insn_number(0);
              load_input.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_input);
              if (DEBUG) {
                print("======== Load Input for cluster " + std::to_string(cluster) + " core 0========");
                print_hex("input_ddr_addr", input_ddr_addr);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("ddr_offset_0", args.seq_len * k_group_size * bytes_ifmap);
                print_dec("seq_burst_1", valid_item_k_group);
                print_hex("sram_addr", MASTER_IFMAP_ADDR);
              }

              // Load Weight
              auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * 32 * 2,
                                                     31,
                                                     weight_ddr_offset_0.first,
                                                     weight_ddr_offset_0.second,
                                                     valid_item_k_group - 1,
                                                     weight_ddr_offset_1.first,
                                                     weight_ddr_offset_1.second,
                                                     block_n_group - 1,
                                                     MASTER_WEIGHT_ADDR,
                                                     0);
              load_weight.set_insn_number(0);
              load_weight.set_insn_opcode(2 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_weight);
              if (DEBUG) {
                print("======== Load Output Weight for cluster " + std::to_string(cluster) + " core 0========");
                print_hex("weight_ddr_addr", weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * 32 * 2);
                print_dec("seq_burst_0", n_group_size);
                print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                print_dec("seq_burst_1", valid_item_k_group);
                print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                print_dec("seq_burst_2", block_n_group);
                print_hex("sram_addr", MASTER_WEIGHT_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 32 * 2,
                                                      31,
                                                      weight_ddr_offset_0.first,
                                                      weight_ddr_offset_0.second,
                                                      valid_item_k_group - 1,
                                                      weight_ddr_offset_1.first,
                                                      weight_ddr_offset_1.second,
                                                      block_n_group - 1,
                                                      MASTER_WEIGHT_ADDR + 1024,
                                                      0);
                load_weight.set_insn_number(0);
                load_weight.set_insn_opcode(2 + cluster * CORE_PER_CLUSTER);
                insn_series.push_back(load_weight);
                if (DEBUG) {
                  print("======== Load Output Weight for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("weight_ddr_addr", weight_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 32 * 2);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                  print_dec("seq_burst_1", valid_item_k_group);
                  print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                  print_dec("seq_burst_2", block_n_group);
                  print_hex("sram_addr", MASTER_WEIGHT_ADDR + 1024);
                }
              }
            }
          }

          // Compute Output Projection
          for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto q_proj = gemm_execute(2,
                                         2,
                                         1,
                                         1,
                                         valid_item_seq_len - 1,
                                         block_n_group - 1,
                                         valid_item_k_group - 1,
                                         0,
                                         0,
                                         0,
                                         valid_item_k_group * block_n_group - 1,
                                         k_iter != 0);
              q_proj.set_insn_number(0);
              q_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(q_proj);
              if (DEBUG) {
                print("======== Output Projection for cluster " + std::to_string(cluster) + " core 0 ========");
                print_dec("tile_m", valid_item_seq_len);
                print_dec("block_k_group", valid_item_k_group);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto q_proj = gemm_execute(2,
                                          2,
                                          1,
                                          1,
                                          valid_item_seq_len - 1,
                                          block_n_group - 1,
                                          valid_item_k_group - 1,
                                          0,
                                          0,
                                          0,
                                          valid_item_k_group * block_n_group - 1,
                                          k_iter != 0);
                q_proj.set_insn_number(0);
                q_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(q_proj);
                if (DEBUG) {
                  print("======== Output Projection for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_dec("tile_m", valid_item_seq_len);
                  print_dec("block_k_group", valid_item_k_group);
                }
              }
            }
          }
        }
        /** Process bias, and convert parallelism */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          if (BIAS) {
            /** Compute bias ddr offset: the bias is stored in the format of [d_model/n_group_size, n_group_size] */
            uint64_t bias_ddr_addr = n_iter * n_group_size * bytes_bias + args.bias_output_base_addr;

            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto load_bias = load_iteration_2<0>(
                bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias, block_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR, 0);
              load_bias.set_insn_number(0);
              load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_bias);

              if (DEBUG) {
                print("======== Load Output Bias for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias);
                print_dec("seq_burst_0", block_n_group);
                print_hex("ddr_offset", 0);
                print_dec("seq_burst_1", 0);
                print_hex("sram_addr", MASTER_VCUPARA_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto load_bias = load_iteration_2<1>(
                  bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias, block_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR + 256, 0);
                load_bias.set_insn_number(0);
                load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
                insn_series.push_back(load_bias);

                if (DEBUG) {
                  print("======== Load Output Bias for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias);
                  print_dec("seq_burst_0", block_n_group);
                  print_hex("ddr_offset", 0);
                  print_dec("seq_burst_1", 0);
                  print_hex("sram_addr", MASTER_VCUPARA_ADDR + 256);
                }
              }
            }
          }

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                                   vcu_resadd_dtype[kHalf],
                                   vcu_out_dtype[kHalf],
                                   0,
                                   1,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   valid_item_seq_len - 1,
                                   block_n_group - 1,
                                   0,
                                   1,
                                   0,
                                   0,
                                   0);
            vcu.set_insn_number(0);
            vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu);

            if (DEBUG) {
              print("======== VCU for cluster " + std::to_string(cluster) + " core 0 ========");
              print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
              print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
              print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
              print_dec("seq_len", valid_item_seq_len);
              print_dec("block_n_group", block_n_group);
            }

            auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, block_n_group, block_n_group * 2);
            vcu_convert.set_insn_number(0);
            vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu_convert);

            if (DEBUG) {
              print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 0 ========");
              print_dec("num data", valid_item_seq_len);
              print_dec("in channel group", block_n_group);
              print_dec("out channel group", block_n_group * 2);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                                    vcu_resadd_dtype[kHalf],
                                    vcu_out_dtype[kHalf],
                                    0,
                                    1,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    valid_item_seq_len - 1,
                                    block_n_group - 1,
                                    0,
                                    1,
                                    0,
                                    0,
                                    0);
              vcu.set_insn_number(0);
              vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu);

              if (DEBUG) {
                print("======== VCU for cluster " + std::to_string(cluster) + " core 1 ========");
                print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
                print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
                print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
                print_dec("seq_len", valid_item_seq_len);
                print_dec("block_n_group", block_n_group);
              }

              auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, block_n_group, block_n_group * 2);
              vcu_convert.set_insn_number(0);
              vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu_convert);

              if (DEBUG) {
                print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 1 ========");
                print_dec("num data", valid_item_seq_len);
                print_dec("in channel group", block_n_group);
                print_dec("out channel group", block_n_group * 2);
              }
            }            
          }
        }
        /** Store */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          u_int64_t output_temp_ddr_addr = (n_iter * block_n_group * n_group_scale) * args.seq_len * (n_group_size / n_group_scale) * bytes_ofmap
                                    + m_iter * valid_item_seq_len * (n_group_size / n_group_scale) * bytes_ofmap + args.output_base_addr;
          auto input_ddr_offset = split_exp_fra(valid_item_seq_len * (n_group_size / n_group_scale) * bytes_ofmap);

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto store = store_iteration_2<0>(output_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * 2,
                                              valid_item_seq_len - 1,
                                              input_ddr_offset.first,
                                              input_ddr_offset.second,
                                              (block_n_group * n_group_scale) - 1,
                                              MASTER_OFMAP_ADDR,
                                              (n_iter + cluster * CORE_PER_CLUSTER == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
            store.set_insn_number(0);
            store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(store);

            if (DEBUG) {
              print("======== Store Output Temp for cluster " + std::to_string(cluster) + " core 0 ========");
              print_hex("output_temp_ddr_addr", output_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * 2);
              print_dec("seq_burst_0", valid_item_seq_len);
              print_hex("ddr_offset_0", valid_item_seq_len * (n_group_size / n_group_scale) * bytes_ofmap);
              print_dec("seq_burst_1", (block_n_group * n_group_scale));
              print_hex("sram_addr", MASTER_OFMAP_ADDR);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto store = store_iteration_2<1>(output_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 2,
                                                valid_item_seq_len - 1,
                                                input_ddr_offset.first,
                                                input_ddr_offset.second,
                                                (block_n_group * n_group_scale) - 1,
                                                MASTER_OFMAP_ADDR + 2048,
                                                (n_iter + cluster * CORE_PER_CLUSTER + 1 == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
              store.set_insn_number(0);
              store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(store);

              if (DEBUG) {
                print("======== Store Output Temp for cluster " + std::to_string(cluster) + " core 1 ========");
                print_hex("output_temp_ddr_addr", output_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 2);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("ddr_offset_0", valid_item_seq_len * (n_group_size / n_group_scale) * bytes_ofmap);
                print_dec("seq_burst_1", (block_n_group * n_group_scale));
                print_hex("sram_addr", MASTER_OFMAP_ADDR + 2048);
              }
            }            
          }
        }
      }
    }
  }

  void compute_pv(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.seq_len / k_group_size;
    int d_h      = args.d_model / args.head_num;
    int n_groups = d_h / n_group_size;

    /** Compute tiling size */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    /** Feed ifmap sram as much as possible */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    /** Depend on the depth of weight sram and block_k_group computed above, compute block_n_group */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);

    /** The number of iterations on each dimension */
    int m_iterations = ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = ceil((double)n_groups / (double)block_n_group);
    int k_iterations = ceil((double)k_groups / (double)block_k_group);

    if (DEBUG) {
      print("======== PV Computation Iteration Setting ========");
      print_dec("tile_m", tile_m);
      print_dec("block_k_group", block_k_group);
      print_dec("block_n_group", block_n_group);
      print_dec("m_iterations", m_iterations);
      print_dec("n_iterations", n_iterations);
      print_dec("k_iterations", k_iterations);
    }

    for (int head = 0; head < args.head_num; head += CORE_NUM) {
      for (int n_iter = 0; n_iter < n_iterations; n_iter++) {
        for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
          /** valid_item_seq_len is the actual number of items in the last iteration */
          int valid_item_seq_len = (m_iter * tile_m + tile_m) > args.seq_len ? args.seq_len - m_iter * tile_m : tile_m;
          for (int k_iter = 0; k_iter < k_iterations; k_iter++) {
            /** valid_item_k_group is the actual number of items in the last iteration */
            int valid_item_k_group =
              (k_iter * block_k_group + block_k_group) > k_groups ? k_groups - k_iter * block_k_group : block_k_group;

            if (DEBUG) {
              print("======== PV Computation Iteration ========");
              print_dec("head", head);
              print_dec("n_iter", n_iter);
              print_dec("m_iter", m_iter);
              print_dec("k_iter", k_iter);
              print_dec("valid_item_seq_len", valid_item_seq_len);
              print_dec("valid_item_k_group", valid_item_k_group);
            }

            /** Compute offset of input: the input is stored in the format of [head, seq_len/k_group_size, seq_len, k_group_size]*/
            uint64_t input_ddr_addr = (head * args.seq_len * args.seq_len + k_iter * args.seq_len * k_group_size * block_k_group
                                       + m_iter * valid_item_seq_len * k_group_size)
                                        * bytes_ifmap
                                      + args.probe_temp_base_addr;
            auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

            /** Compute offset of weight: the weight is stored in the format of [head, d_h/n_group_size, seq_len/k_group_size,
             * n_group_size, k_group_size]*/
            uint64_t weight_ddr_addr = (head * args.seq_len * d_h + n_iter * block_n_group * args.seq_len * n_group_size
                                        + k_iter * block_k_group * n_group_size * k_group_size)
                                         * bytes_weight
                                       + args.value_temp_base_addr;
            auto weight_ddr_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_weight);
            auto weight_ddr_offset_1 = split_exp_fra(n_group_size * args.seq_len * bytes_weight);

            for (int core = 0; core < CORE_NUM; core++) {
              if (head + core < args.head_num) {
                /** Load Probe */
                auto load_probe = load_iteration_2<0>(input_ddr_addr + core * args.seq_len * args.seq_len * bytes_ifmap,
                                                      valid_item_seq_len - 1,
                                                      input_ddr_offset.first,
                                                      input_ddr_offset.second,
                                                      valid_item_k_group - 1,
                                                      MASTER_IFMAP_ADDR + (core % 2) * 512,
                                                      0);
                load_probe.set_insn_number(0);
                load_probe.set_insn_opcode(1 + (core / 2) * 2);
                insn_series.push_back(load_probe);

                if (DEBUG) {
                  print("======== Load Probe for core id" + std::to_string(core) + " ========");
                  print_hex("input_ddr_addr", input_ddr_addr + core * args.seq_len * args.seq_len * bytes_ifmap);
                  print_dec("seq_burst_0", valid_item_seq_len);
                  print_dec("seq_burst_1", valid_item_k_group);
                  print_hex("ddr_offset_0", args.seq_len * k_group_size * bytes_ifmap);
                }

                /** Load Value */
                auto load_value = load_iteration_3<0>(weight_ddr_addr + core * args.seq_len * d_h * bytes_weight,
                                                      n_group_size - 1,
                                                      weight_ddr_offset_0.first,
                                                      weight_ddr_offset_0.second,
                                                      valid_item_k_group - 1,
                                                      weight_ddr_offset_1.first,
                                                      weight_ddr_offset_1.second,
                                                      block_n_group - 1,
                                                      MASTER_WEIGHT_ADDR + (core % 2) * 1024,
                                                      0);
                load_value.set_insn_number(0);
                load_value.set_insn_opcode(2 + (core / 2) * 2);
                insn_series.push_back(load_value);

                if (DEBUG) {
                  print("======== Load Value for core id" + std::to_string(core) + " ========");
                  print_hex("weight_ddr_addr", weight_ddr_addr + core * args.seq_len * d_h * bytes_weight);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                  print_dec("seq_burst_1", valid_item_k_group);
                  print_hex("ddr_offset_1", n_group_size * args.seq_len * bytes_weight);
                  print_dec("seq_burst_2", block_n_group);
                }

                /** Compute */
                auto compute = gemm_execute(2,
                                            2,
                                            1,
                                            1,
                                            valid_item_seq_len - 1,
                                            block_n_group - 1,
                                            valid_item_k_group - 1,
                                            0,
                                            0,
                                            0,
                                            valid_item_k_group * block_n_group - 1,
                                            k_iter != 0);
                compute.set_insn_number(0);
                compute.set_insn_opcode(17 + core);
                insn_series.push_back(compute);
              }
            }
          }

          /** Convert parallelism */
          for (int core = 0; core < CORE_NUM; core++) {
            if (head + core < args.head_num) {
              auto to_half = vcu_execute(vcu_psum_dtype[kFloat32],
                                         vcu_resadd_dtype[kFloat32],
                                         vcu_out_dtype[kHalf],
                                         0,
                                         1,
                                         0,
                                         0,
                                         0,
                                         0,
                                         0,
                                         valid_item_seq_len - 1,
                                         block_n_group - 1,
                                         0,
                                         1,
                                         0,
                                         0,
                                         0);
              to_half.set_insn_number(0);
              to_half.set_insn_opcode(25 + core);
              insn_series.push_back(to_half);

              if (DEBUG) {
                print("======== Convert to Half for core id" + std::to_string(core) + " ========");
              }

              auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, block_n_group, block_n_group * 2);
              vcu_convert.set_insn_number(0);
              vcu_convert.set_insn_opcode(25 + core);
              insn_series.push_back(vcu_convert);
            }
          }

          /** Store */
          uint64_t output_ddr_addr = (head * args.seq_len * d_h + (n_iter * block_n_group * n_group_scale) * args.seq_len * k_group_size
                                      + m_iter * valid_item_seq_len * k_group_size)
                                       * bytes_ofmap
                                     + args.output_temp_base_addr;
          auto output_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ofmap);
          for (int core = 0; core < CORE_NUM; core++) {
            if (core + head < args.head_num) {
              auto store_output = store_iteration_2<0>(output_ddr_addr + core * args.seq_len * d_h * bytes_ofmap,
                                                       valid_item_seq_len - 1,
                                                       output_ddr_offset.first,
                                                       output_ddr_offset.second,
                                                       block_n_group * n_group_scale - 1,
                                                       MASTER_OFMAP_ADDR + (core % 2) * 1024,
                                                       head + core == args.head_num - 1 && n_iter == n_iterations - 1
                                                         && m_iter == m_iterations - 1 && all_done);
              store_output.set_insn_number(0);
              store_output.set_insn_opcode(9 + core);
              insn_series.push_back(store_output);

              if (DEBUG) {
                print("======== Store Output for core id" + std::to_string(core) + " ========");
                print_hex("output_ddr_addr", output_ddr_addr + core * args.seq_len * d_h * bytes_ofmap);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_dec("seq_burst_1", block_n_group * n_group_scale);
                print_hex("output_ddr_offset", args.seq_len * k_group_size * bytes_ofmap);
              }
            }
          }
        }
      }
    }
  }

  void compute_v(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.d_model / k_group_size;
    int n_groups = args.d_model / n_group_size;

    /** Set tile_m to 32 so that the seq_len_k dimension can easily transformed to n_group_size for QK^T */
    int tile_m = std::min(32, args.seq_len);
    /** Feed ifmap sram as much as possible */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    /** Depend on the depth of weight sram and block_k_group computed above, compute block_n_group */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);

    /** The number of iterations on each dimension */
    int m_iterations = ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = ceil((double)n_groups / (double)block_n_group);
    int k_iterations = ceil((double)k_groups / (double)block_k_group);

    /** Split head when store */
    int d_h                      = args.d_model / args.head_num;
    int n_group_per_d_h          = d_h / (n_group_size / n_group_scale);
    int real_block_n_group       = block_n_group * n_group_scale;
    int block_n_group_split_head = real_block_n_group / n_group_per_d_h;

    if (DEBUG) {
      print("======== V Computation Iteration Setting ========");
      print_dec("tile_m", tile_m);
      print_dec("block_k_group", block_k_group);
      print_dec("block_n_group", block_n_group);
      print_dec("m_iterations", m_iterations);
      print_dec("n_iterations", n_iterations);
      print_dec("k_iterations", k_iterations);
      print_dec("d_h", d_h);
      print_dec("n_group_per_d_h", n_group_per_d_h);
      print_dec("real_block_n_group", real_block_n_group);
      print_dec("block_n_group_split_head", block_n_group_split_head);
    }

    for (int n_iter = 0; n_iter < n_iterations; n_iter += CORE_NUM) {
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
        /** valid_item_seq_len is the actual number of items in the last iteration */
        int valid_item_seq_len = (m_iter * tile_m + tile_m) > args.seq_len ? args.seq_len - m_iter * tile_m : tile_m;
        for (int k_iter = 0; k_iter < k_iterations; k_iter++) {
          /** valid_item_k_group is the actual number of items in the last iteration */
          int valid_item_k_group = (k_iter * block_k_group + block_k_group) > k_groups ? k_groups - k_iter * block_k_group : block_k_group;

          if (DEBUG) {
            print("======== V Computation Iteration ========");
            print_dec("n_iter", n_iter);
            print_dec("m_iter", m_iter);
            print_dec("k_iter", k_iter);
            print_dec("valid_item_seq_len", valid_item_seq_len);
            print_dec("valid_item_k_group", valid_item_k_group);
          }

          /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
          uint64_t input_ddr_addr = (k_iter * block_k_group) * args.seq_len * k_group_size * bytes_ifmap
                                    + m_iter * valid_item_seq_len * k_group_size * bytes_ifmap + args.input_base_addr;
          auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

          /** Compute offset of weight: the weight is stored in the format of [d_model/n_group_size, d_model/k_group_size, n_group_size,
           * k_group_size]*/
          uint64_t weight_ddr_addr = (n_iter * block_n_group) * args.d_model * n_group_size * bytes_weight
                                     + (k_iter * block_k_group) * n_group_size * k_group_size * bytes_weight + args.weight_value_base_addr;
          auto weight_ddr_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_weight);
          auto weight_ddr_offset_1 = split_exp_fra(n_group_size * args.d_model * bytes_weight);
          for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
            /** Load input */
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto load_input = load_iteration_2<0>(input_ddr_addr,
                                                    valid_item_seq_len - 1,
                                                    input_ddr_offset.first,
                                                    input_ddr_offset.second,
                                                    valid_item_k_group - 1,
                                                    MASTER_IFMAP_ADDR,
                                                    0);
              load_input.set_insn_number(0);
              load_input.set_insn_opcode(1 + cluster);
              insn_series.push_back(load_input);

              if (DEBUG) {
                print("======== Load Input for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("input_ddr_addr", input_ddr_addr);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("input_ddr_offset", input_ddr_offset.first);
                print_hex("input_ddr_offset", input_ddr_offset.second);
                print_dec("seq_burst_1", valid_item_seq_len);
              }

              /** Load Weight, each core is responsible for one iteration of n_groups */
              auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * n_group_size * bytes_weight,
                                                     n_group_size - 1,
                                                     weight_ddr_offset_0.first,
                                                     weight_ddr_offset_0.second,
                                                     valid_item_k_group - 1,
                                                     weight_ddr_offset_1.first,
                                                     weight_ddr_offset_1.second,
                                                     block_n_group - 1,
                                                     MASTER_WEIGHT_ADDR,
                                                     0);
              load_weight.set_insn_number(0);
              load_weight.set_insn_opcode(2 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_weight);

              if (DEBUG) {
                print("======== Load Value Weight for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("weight_ddr_addr", weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * n_group_size * bytes_weight);
                print_dec("seq_burst_0", n_group_size);
                print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                print_dec("seq_burst_1", valid_item_k_group);
                print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                print_dec("seq_burst_2", block_n_group);
                print_hex("sram_addr", MASTER_WEIGHT_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * n_group_size * bytes_weight,
                                                      n_group_size - 1,
                                                      weight_ddr_offset_0.first,
                                                      weight_ddr_offset_0.second,
                                                      valid_item_k_group - 1,
                                                      weight_ddr_offset_1.first,
                                                      weight_ddr_offset_1.second,
                                                      block_n_group - 1,
                                                      MASTER_WEIGHT_ADDR,
                                                      0);
                load_weight.set_insn_number(0);
                load_weight.set_insn_opcode(2 + cluster * CORE_PER_CLUSTER);
                insn_series.push_back(load_weight);

                if (DEBUG) {
                  print("======== Load Value Weight for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("weight_ddr_addr", weight_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * n_group_size * bytes_weight);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                  print_dec("seq_burst_1", valid_item_k_group);
                  print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                  print_dec("seq_burst_2", block_n_group);
                  print_hex("sram_addr", MASTER_WEIGHT_ADDR);
                }
              }
            }
          }

          /** Compute Value projection */
          for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              /** each core is responsible for one iteration of n_groups */
              auto v_proj = gemm_execute(2,
                                         2,
                                         1,
                                         1,
                                         valid_item_seq_len - 1,
                                         block_n_group - 1,
                                         valid_item_k_group - 1,
                                         0,
                                         0,
                                         0,
                                         valid_item_k_group * block_n_group - 1,
                                         k_iter != 0);
              v_proj.set_insn_number(0);
              v_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(v_proj);

              if (DEBUG) {
                print("======== Value Projection for cluster " + std::to_string(cluster) + " core 0 ========");
                print_dec("tile_m", valid_item_seq_len);
                print_dec("block_k_group", valid_item_k_group);
                print_dec("block_n_group", block_n_group);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                /** each core is responsible for one iteration of n_groups */
                auto v_proj = gemm_execute(2,
                                          2,
                                          1,
                                          1,
                                          valid_item_seq_len - 1,
                                          block_n_group - 1,
                                          valid_item_k_group - 1,
                                          0,
                                          0,
                                          0,
                                          valid_item_k_group * block_n_group - 1,
                                          k_iter != 0);
                v_proj.set_insn_number(0);
                v_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(v_proj);

                if (DEBUG) {
                  print("======== Value Projection for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_dec("tile_m", valid_item_seq_len);
                  print_dec("block_k_group", valid_item_k_group);
                  print_dec("block_n_group", block_n_group);
                }
              }
            }
          }
        }

        /** Process bias, and convert parallelism */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          if (BIAS) {
            /** Compute bias ddr offset: the bias is stored in the format of [d_model/n_group_size, n_group_size] */
            uint64_t bias_ddr_addr = n_iter * n_group_size * bytes_bias + args.bias_value_base_addr;
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto load_bias = load_iteration_2<0>(
                bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias, block_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR, 0);
              load_bias.set_insn_number(0);
              load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_bias);

              if (DEBUG) {
                print("======== Load Key Bias for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias);
                print_dec("seq_burst_0", block_n_group);
                print_hex("ddr_offset", 0);
                print_dec("seq_burst_1", 0);
                print_hex("sram_addr", MASTER_VCUPARA_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto load_bias = load_iteration_2<0>(
                  bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias, block_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR + 256, 0);
                load_bias.set_insn_number(0);
                load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
                insn_series.push_back(load_bias);

                if (DEBUG) {
                  print("======== Load Value Bias for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias);
                  print_dec("seq_burst_0", block_n_group);
                  print_hex("ddr_offset", 0);
                  print_dec("seq_burst_1", 0);
                  print_hex("sram_addr", MASTER_VCUPARA_ADDR + 256);
                }
              }
            }
          }

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                                   vcu_resadd_dtype[kHalf],
                                   vcu_out_dtype[kHalf],
                                   0,
                                   1,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   valid_item_seq_len - 1,
                                   block_n_group - 1,
                                   0,
                                   1,
                                   0,
                                   0,
                                   0);
            vcu.set_insn_number(0);
            vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu);
            if (DEBUG) {
              print("======== VCU for cluster " + std::to_string(cluster) + " core 0 ========");
              print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
              print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
              print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
              print_dec("seq_len", valid_item_seq_len);
              print_dec("block_n_group", block_n_group);
            }

            for (int inner_n = 0; inner_n < block_n_group; inner_n++) {
              auto transpose = vcu_transpose(2, inner_n * 32, inner_n * 32);
              vcu.set_insn_number(0);
              vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(transpose);
            }

            auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, block_n_group, block_n_group * 2);
            vcu_convert.set_insn_number(0);
            vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu_convert);
            if (DEBUG) {
              print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 0 ========");
              print_dec("num data", valid_item_seq_len);
              print_dec("in channel group", block_n_group);
              print_dec("out channel group", block_n_group * 2);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                                    vcu_resadd_dtype[kHalf],
                                    vcu_out_dtype[kHalf],
                                    0,
                                    1,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    valid_item_seq_len - 1,
                                    block_n_group - 1,
                                    0,
                                    1,
                                    0,
                                    0,
                                    0);
              vcu.set_insn_number(0);
              vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu);
              if (DEBUG) {
                print("======== VCU for cluster " + std::to_string(cluster) + " core 1 ========");
                print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
                print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
                print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
                print_dec("seq_len", valid_item_seq_len);
                print_dec("block_n_group", block_n_group);
              }

              for (int inner_n = 0; inner_n < block_n_group; inner_n++) {
                auto transpose = vcu_transpose(0, inner_n * 32, inner_n * 32);
                vcu.set_insn_number(0);
                vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
              }

              auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, block_n_group, block_n_group * 2);
              vcu_convert.set_insn_number(0);
              vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu_convert);
              if (DEBUG) {
                print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 1 ========");
                print_dec("num data", valid_item_seq_len);
                print_dec("in channel group", block_n_group);
                print_dec("out channel group", block_n_group * 2);
              }
            }
          }
        }

        /** Store output */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            for (int head_iter = 0; head_iter < block_n_group_split_head; head_iter++) {
              int head_number    = (n_iter + cluster * CORE_PER_CLUSTER) / block_n_group_split_head + head_iter;
              int real_head_iter = (n_iter + cluster * CORE_PER_CLUSTER) % block_n_group_split_head;
              /** Compute offset, the key need to be stored as [head, d_model/head/n_group_size, seq_len/k_group_size, n_group_size,
               * k_group_size] */
              // int key_temp_ddr_addr = (head_number * args.seq_len * d_h + m_iter * n_group_per_d_h * n_group_size * k_group_size
              //                          + real_head_iter * n_group_size * k_group_size)
              //                           * bytes_ofmap
              //                         + args.key_temp_base_addr;
              uint64_t value_temp_ddr_addr = (head_number * args.seq_len * d_h + real_head_iter * args.seq_len * n_group_size
                                         + (m_iter * n_group_scale) * n_group_size * k_group_size)
                                          * bytes_ofmap
                                        + args.value_temp_base_addr;
              auto value_temp_offset_0 = split_exp_fra(k_group_size * n_group_size * bytes_ofmap);
              auto value_temp_offset_1 = split_exp_fra(args.seq_len * n_group_size * bytes_ofmap);

              auto store = store_iteration_3<0>(value_temp_ddr_addr,
                                                n_group_size - 1,
                                                value_temp_offset_0.first,
                                                value_temp_offset_0.second,
                                                1,
                                                value_temp_offset_1.first,
                                                value_temp_offset_1.second,
                                                block_n_group_split_head - 1,
                                                MASTER_OFMAP_ADDR + head_iter * valid_item_seq_len * block_n_group,
                                                head_iter == block_n_group_split_head - 1 && n_iter + cluster * CORE_PER_CLUSTER == n_iterations - 1
                                                  && m_iter == m_iterations - 1 && all_done);
              store.set_insn_number(0);
              store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(store);

              if (DEBUG) {
                print("======== Store Value Temp for cluster " + std::to_string(cluster) + " core 0========");
                print_hex("value_temp_ddr_addr", value_temp_ddr_addr);
                print_dec("seq_burst_0", n_group_size);
                print_hex("ddr_offset_0", k_group_size * n_group_size * bytes_ofmap);
                print_dec("seq_burst_1", block_n_group_split_head * n_group_scale);
                print_dec("head_number", head_number);
                print_dec("real_head_iter", real_head_iter);
                print_hex("sram_addr", MASTER_OFMAP_ADDR + head_iter * valid_item_seq_len * block_n_group);
              }
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              for (int head_iter = 0; head_iter < block_n_group_split_head; head_iter++) {
                int head_number    = (n_iter + cluster * CORE_PER_CLUSTER + 1) / block_n_group_split_head + head_iter;
                int real_head_iter = (n_iter + cluster * CORE_PER_CLUSTER + 1) % block_n_group_split_head;
                /** Compute offset, the key need to be stored as [head, seq_len/n_group_size, d_model/head/k_group_size, n_group_size,
                 * k_group_size] */
                uint64_t value_temp_ddr_addr =
                  (head_number * args.seq_len * d_h + real_head_iter * args.seq_len * n_group_size + m_iter * n_group_size * k_group_size)
                    * bytes_ofmap
                  + args.value_temp_base_addr;
                auto value_temp_offset_0 = split_exp_fra(k_group_size * n_group_size * bytes_ofmap);

                auto store = store_iteration_2<0>(value_temp_ddr_addr,
                                                  n_group_size - 1,
                                                  value_temp_offset_0.first,
                                                  value_temp_offset_0.second,
                                                  block_n_group_split_head * n_group_scale - 1,
                                                  MASTER_OFMAP_ADDR + 1024 + head_iter * valid_item_seq_len * block_n_group,
                                                  head_iter == block_n_group_split_head - 1 && n_iter + cluster * CORE_PER_CLUSTER + 1 == n_iterations - 1
                                                    && m_iter == m_iterations - 1 && all_done);
                store.set_insn_number(0);
                store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(store);

                if (DEBUG) {
                  print("======== Store Key Temp for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("value_temp_ddr_addr", value_temp_ddr_addr);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", k_group_size * n_group_size * bytes_ofmap);
                  print_hex("seq_burst_1", n_group_per_d_h * n_group_scale);
                }
              }
            }
          }
        }
      }
    }
  }

  void softmax(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int n_groups = args.seq_len / n_group_size;
    int n_iter   = ceil((double)n_groups / (double)MAX_PSUM_DEPTH);

    if (DEBUG) {
      print("======== Softmax Computation ========");
      print_dec("n_groups", n_groups);
      print_dec("n_iter", n_iter);
      print_dec("seq_len", args.seq_len);
    }

    if (n_groups * args.seq_len <= MAX_PSUM_DEPTH) {

      for (int head = 0; head < args.head_num; head += CORE_NUM) {

        if (DEBUG) {
          print("======== Softmax Computation Iteration ========");
          print_dec("head", head);
        }

        /** Compute offset of input: the input is stored in the format of [h, seq_len_k/n_group_size, seq_len_q, n_group_size]*/
        uint64_t input_ddr_addr   = head * args.seq_len * args.seq_len * bytes_ifmap * 2 + args.score_temp_base_addr;
        auto     input_ddr_offset = split_exp_fra(args.seq_len * n_group_size * bytes_ifmap * 2);
        for (int core = 0; core < CORE_NUM; core++) {
          if (head + core < args.head_num) {
            /** Load input */
            auto load_input = load_iteration_2<0>(input_ddr_addr + core * args.seq_len * args.seq_len * bytes_ifmap * 2,
                                                  args.seq_len * 4 - 1,
                                                  input_ddr_offset.first,
                                                  input_ddr_offset.second,
                                                  n_groups - 1,
                                                  MASTER_PSUM_ADDR + (core % 2) * 2048,
                                                  0);
            load_input.set_insn_number(0);
            load_input.set_insn_opcode(1 + (core / 2));
            insn_series.push_back(load_input);

            if (DEBUG) {
              print("======== Load Psum for core id" + std::to_string(core) + " ========");
              print_hex("input_ddr_addr", input_ddr_addr + core * args.seq_len * args.seq_len * bytes_ifmap * 2);
              print_dec("seq_burst_0", args.seq_len * 4);
              print_hex("input_ddr_offset", input_ddr_offset.first);
              print_hex("input_ddr_offset", input_ddr_offset.second);
              print_dec("seq_burst_1", n_groups);
            }

            /** 0. Clean vcures */
            auto clean_vcures = vcu_execute(vcu_psum_dtype[kFloat32],
                                            vcu_resadd_dtype[kFloat32],
                                            vcu_out_dtype[kFloat32],
                                            VCURES,
                                            1,
                                            3,
                                            0,
                                            0,
                                            0,
                                            0,
                                            (uint64_t)args.seq_len - 1,
                                            0,
                                            0,
                                            0,
                                            0,
                                            0,
                                            0);
            clean_vcures.set_insn_opcode(25 + core);
            insn_series.push_back(clean_vcures);

            /** 1. Compute exp2 for all input data */
            auto exp2 = vcu_execute(vcu_psum_dtype[kFloat32],
                                    vcu_resadd_dtype[kFloat32],
                                    vcu_out_dtype[kFloat32],
                                    PSUM,
                                    2,
                                    4,
                                    0,
                                    0,
                                    0,
                                    0,
                                    (uint64_t)args.seq_len - 1,
                                    (uint64_t)n_groups - 1,
                                    0,
                                    1,
                                    0,
                                    0,
                                    0);
            exp2.set_insn_opcode(25 + core);
            insn_series.push_back(exp2);

            /** 2. Reduce sum to compute sum(exp(x)), for common cases */
            for (int i = 0; i < n_groups; i++) {
              auto redsum = vcu_execute(vcu_psum_dtype[kFloat32],
                                        vcu_resadd_dtype[kFloat32],
                                        vcu_out_dtype[kFloat32],
                                        VCURES,
                                        2,                 // opcode_number
                                        6,                 // opcode_addr
                                        i * args.seq_len,  // psum_in_addr
                                        0,                 // para_in_addr
                                        0,                 // resadd_in_addr
                                        0,                 // ram_out_addr
                                        (uint64_t)args.seq_len - 1,
                                        0,
                                        0,
                                        1,
                                        1,
                                        0,
                                        0);
              redsum.set_insn_opcode(25 + core);
              insn_series.push_back(redsum);
            }

            /** 3. Compute reciprocal of sum(exp(x)) */
            auto reciprocal = vcu_execute(vcu_psum_dtype[kFloat32],
                                          vcu_resadd_dtype[kFloat32],
                                          vcu_out_dtype[kFloat32],
                                          VCURES,
                                          1,  // opcode_number
                                          8,  // opcode_addr
                                          0,  // psum_in_addr
                                          0,  // para_in_addr
                                          0,  // resadd_in_addr
                                          0,  // ram_out_addr
                                          (uint64_t)args.seq_len - 1,
                                          0,
                                          0,
                                          0,
                                          1,
                                          0,
                                          0);
            reciprocal.set_insn_opcode(25 + core);
            insn_series.push_back(reciprocal);

            /** 4. Multiply exp(x) by 1/sum(exp(x)) */
            for (int i = 0; i < n_groups; i++) {
              auto mul = vcu_execute(vcu_psum_dtype[kFloat32],
                                     vcu_resadd_dtype[kFloat32],
                                     vcu_out_dtype[kHalf],
                                     PSUM,
                                     1,
                                     9,
                                     i * args.seq_len,
                                     0,
                                     0,
                                     i * args.seq_len,
                                     (uint64_t)args.seq_len - 1,
                                     0,
                                     0,
                                     1,
                                     1,
                                     0,
                                     0);
              mul.set_insn_opcode(25 + core);
              insn_series.push_back(mul);
            }

            /** Apply Convertion */
            auto convert = vcu_parallelism_conversion(0, 0, 0, args.seq_len, n_groups, n_groups * 2);
            convert.set_insn_opcode(25 + core);
            insn_series.push_back(convert);

            /** Store output */
            auto output_ddr_addr = (head * CORE_NUM + core) * args.seq_len * args.seq_len * bytes_ofmap + args.probe_temp_base_addr;
            auto output_offset   = split_exp_fra(args.seq_len * k_group_size * bytes_ofmap);

            auto store_output = store_iteration_2<0>(output_ddr_addr,
                                                     args.seq_len - 1,
                                                     output_offset.first,
                                                     output_offset.second,
                                                     n_groups * n_group_scale - 1,
                                                     MASTER_OFMAP_ADDR + (core % 2) * 1024,
                                                     head + core == args.head_num - 1 && all_done);

            store_output.set_insn_opcode(9 + core); // 原：9 + core / 2
            insn_series.push_back(store_output);

            if (DEBUG) {
              print("======== Store Attention Probe for core id" + std::to_string(core) + " ========");
              print_hex("output_ddr_addr", output_ddr_addr);
              print_dec("seq_burst_0", args.seq_len);
              print_hex("output_offset", output_offset.first);
              print_hex("output_offset", output_offset.second);
              print_dec("seq_burst_1", n_groups * n_group_scale);
            }
          }
        }
      }
    }
    else {
      std::cout << "Softmax is not supported for this case: n_groups * seq_len > MAX_PSUM_DEPTH" << std::endl;
    }
  }

  void compute_qkt(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int d_h      = args.d_model / args.head_num;
    int k_groups = d_h / k_group_size;
    int n_groups = args.seq_len / n_group_size;

    /** Apply scaled product */
    int32_t scale = 0;
    if (d_h == 64) {
      scale = 0x3e000000;
    }
    else if (d_h == 128) {
      scale = 0x3db504f3;
    }
    else if (d_h == 256) {
      scale = 0x3d800000;
    }

    /** Compute tiling size */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    /** Feed ifmap sram as much as possible */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    /** Depend on the depth of weight sram and block_k_group computed above, compute block_n_group */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);

    /** The number of iterations on each dimension */
    int m_iterations = ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = ceil((double)n_groups / (double)block_n_group);
    int k_iterations = ceil((double)k_groups / (double)block_k_group);

    if (DEBUG) {
      print("======== QK Computation Iteration Setting ========");
      print_dec("tile_m", tile_m);
      print_dec("block_k_group", block_k_group);
      print_dec("block_n_group", block_n_group);
      print_dec("m_iterations", m_iterations);
      print_dec("n_iterations", n_iterations);
      print_dec("k_iterations", k_iterations);
      print_dec("d_h", d_h);
    }

    for (int head = 0; head < args.head_num; head += CORE_NUM) {
      for (int n_iter = 0; n_iter < n_iterations; n_iter++) {
        for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
          /** valid_item_seq_len is the actual seq_len for each iteration */
          int valid_item_seq_len = (m_iter * tile_m + tile_m) <= args.seq_len ? tile_m : args.seq_len - m_iter * tile_m;
          for (int k_iter = 0; k_iter < k_iterations; k_iter++) {
            /** valid_item_k_group is the actual k_group_size for each iteration */
            int valid_item_k_group =
              (k_iter * block_k_group + block_k_group) <= k_groups ? block_k_group : k_groups - k_iter * block_k_group;

            if (DEBUG) {
              print("======== QK Computation Iteration ========");
              print_dec("head", head);
              print_dec("n_iter", n_iter);
              print_dec("m_iter", m_iter);
              print_dec("k_iter", k_iter);
              print_dec("valid_item_seq_len", valid_item_seq_len);
              print_dec("valid_item_k_group", valid_item_k_group);
            }

            /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
            uint64_t input_ddr_addr = head * d_h * args.seq_len * bytes_ifmap
                                      + k_iter * block_k_group * args.seq_len * k_group_size * bytes_ifmap
                                      + m_iter * valid_item_seq_len * k_group_size * bytes_ifmap + args.query_temp_base_addr;
            auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

            /** Compute offset of weight: the weight is stored in the format of [d_model/n_group_size, d_model/k_group_size, n_group_size,
             * k_group_size]*/
            uint64_t weight_ddr_addr = head * args.seq_len * d_h * bytes_weight + n_iter * block_n_group * d_h * n_group_size * bytes_weight
                                       + k_iter * block_k_group * n_group_size * k_group_size * bytes_weight + args.key_temp_base_addr;
            auto weight_ddr_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_weight);
            auto weight_ddr_offset_1 = split_exp_fra(n_group_size * d_h * bytes_weight);

            for (int core = 0; core < CORE_NUM; core++) {
              if (head + core < args.head_num) {
                /** Load Query */
                auto load_query = load_iteration_2<0>(input_ddr_addr + core * args.seq_len * d_h * bytes_ifmap,
                                                      valid_item_seq_len - 1,
                                                      input_ddr_offset.first,
                                                      input_ddr_offset.second,
                                                      valid_item_k_group - 1,
                                                      MASTER_IFMAP_ADDR + (core % 2) * 512,
                                                      0);
                load_query.set_insn_number(0);
                load_query.set_insn_opcode(1 + (core / 2) * 2);   // 原：1 + (core / 2) * 2
                insn_series.push_back(load_query);

                if (DEBUG) {
                  print("======== Load Query for core id" + std::to_string(core) + " ========");
                  print_hex("input_ddr_addr", input_ddr_addr + core * args.seq_len * d_h * bytes_ifmap);
                  print_dec("seq_burst_0", valid_item_seq_len);
                  print_hex("ddr_offset_0", args.seq_len * k_group_size * bytes_ifmap);
                  print_dec("seq_burst_1", valid_item_k_group);
                }

                /** Load Key */
                auto load_key = load_iteration_3<0>(weight_ddr_addr + core * args.seq_len * d_h * bytes_weight,
                                                    n_group_size - 1,
                                                    weight_ddr_offset_0.first,
                                                    weight_ddr_offset_0.second,
                                                    block_k_group - 1,
                                                    weight_ddr_offset_1.first,
                                                    weight_ddr_offset_1.second,
                                                    block_n_group - 1,
                                                    MASTER_WEIGHT_ADDR + (core % 2) * 1024,
                                                    0);
                load_key.set_insn_number(0);
                load_key.set_insn_opcode(2 + (core / 2) * 2);  // 原：2 + (core / 2) * 2
                insn_series.push_back(load_key);

                if (DEBUG) {
                  print("======== Load Key for core id" + std::to_string(core) + " ========");
                  print_hex("weight_ddr_addr", weight_ddr_addr + core * args.seq_len * d_h * bytes_weight);
                  print_dec("n_burst_0", n_group_size);
                  print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                  print_dec("k_burst_0", block_k_group);
                  print_hex("ddr_offset_1", n_group_size * d_h * bytes_weight);
                  print_dec("n_burst_1", block_n_group);
                }

                /** Compute QK^T */
                auto compute_qk = gemm_execute(2,
                                               2,
                                               1,
                                               1,
                                               valid_item_seq_len - 1,
                                               block_n_group - 1,
                                               valid_item_k_group - 1,
                                               0,
                                               0,
                                               0,
                                               valid_item_k_group * block_n_group - 1,
                                               k_iter != 0);
                compute_qk.set_insn_number(0);
                compute_qk.set_insn_opcode(17 + core);
                insn_series.push_back(compute_qk);
              }
            }
          }

          for (int core = 0; core < CORE_NUM; core++) {
            if (head + core < args.head_num) {
              auto apply_scale = vcu_execute(vcu_psum_dtype[kFloat32],
                                             vcu_resadd_dtype[kFloat32],
                                             vcu_out_dtype[kFloat32],
                                             0,
                                             2,
                                             1,
                                             0,
                                             0,
                                             0,
                                             0,
                                             valid_item_seq_len - 1,
                                             block_n_group - 1,
                                             0,
                                             1,
                                             0,
                                             0,
                                             0);
              apply_scale.set_insn_number(0);
              apply_scale.set_insn_opcode(25 + core);
              insn_series.push_back(apply_scale);

              if (DEBUG) {
                print("======== VCU for core " + std::to_string(core) + " ========");
                print_dec("psum_data_type", vcu_psum_dtype[kFloat32]);
                print_dec("resadd_data_type", vcu_resadd_dtype[kFloat32]);
                print_dec("output_data_type", vcu_out_dtype[kFloat32]);
                print_dec("num_data", valid_item_seq_len);
                print_dec("oc_group", block_n_group);
              }
            }
          }

          /** Store output */
          uint64_t output_ddr_addr = (head * args.seq_len * args.seq_len + n_iter * block_n_group * args.seq_len * n_group_size
                                      + m_iter * valid_item_seq_len * n_group_size)
                                       * bytes_ofmap * 2
                                     + args.score_temp_base_addr;
          auto output_ddr_offset = split_exp_fra(args.seq_len * n_group_size * 4);
          for (int core = 0; core < CORE_NUM; core++) {
            /** Store output */
            if (head + core < args.head_num) {
              auto store_output = store_iteration_2<0>(output_ddr_addr + core * args.seq_len * args.seq_len * bytes_ofmap * 4,
                                                       valid_item_seq_len * 4 - 1,
                                                       output_ddr_offset.first,
                                                       output_ddr_offset.second,
                                                       block_n_group - 1,
                                                       MASTER_PSUM_ADDR + (core % 2) * 512,
                                                       head + core == args.head_num - 1 && m_iter == m_iterations - 1
                                                         && n_iter == n_iterations - 1 && all_done);
              store_output.set_insn_number(0);
              store_output.set_insn_opcode(9 + core); // 原：9 + core / 2
              insn_series.push_back(store_output);

              if (DEBUG) {
                print("======== Store Attention Score for core id" + std::to_string(core) + " ========");
                print(store_output);
                print_hex("output_ddr_addr", output_ddr_addr + core * args.seq_len * args.seq_len * bytes_ofmap * 2);
                print_dec("seq_burst_0", valid_item_seq_len * 2);
                print_hex("ddr_offset_0", args.seq_len * (n_group_size / n_group_scale) * bytes_ofmap * 2);
                print_dec("n_burst_0", (block_n_group * n_group_scale));
              }
            }
          }
        }
      }
    }
  }

  void compute_k(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.d_model / k_group_size;
    int n_groups = args.d_model / n_group_size;

    /** Set tile_m to 32 so that the seq_len_k dimension can easily transformed to n_group_size for QK^T */
    int tile_m = std::min(32, args.seq_len);
    /** Feed ifmap sram as much as possible */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    /** Depend on the depth of weight sram and block_k_group computed above, compute block_n_group */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);

    /** The number of iterations on each dimension */
    int m_iterations = ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = ceil((double)n_groups / (double)block_n_group);
    int k_iterations = ceil((double)k_groups / (double)block_k_group);

    /** Split head when store */
    int d_h                      = args.d_model / args.head_num;
    int n_group_per_d_h          = d_h / (n_group_size / n_group_scale);
    int real_block_n_group       = block_n_group * n_group_scale;
    int block_n_group_split_head = real_block_n_group / n_group_per_d_h;

    if (DEBUG) {
      print("======== K Computation Iteration Setting ========");
      print_dec("tile_m", tile_m);
      print_dec("block_k_group", block_k_group);
      print_dec("block_n_group", block_n_group);
      print_dec("m_iterations", m_iterations);
      print_dec("n_iterations", n_iterations);
      print_dec("k_iterations", k_iterations);
      print_dec("d_h", d_h);
      print_dec("n_group_per_d_h", n_group_per_d_h);
      print_dec("real_block_n_group", real_block_n_group);
      print_dec("block_n_group_split_head", block_n_group_split_head);
    }

    for (int n_iter = 0; n_iter < n_iterations; n_iter += CORE_NUM) {
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
        /** valid_item_seq_len is the actual seq_len for each iteration */
        int valid_item_seq_len = (m_iter * tile_m + tile_m) > args.seq_len ? args.seq_len - m_iter * tile_m : tile_m;
        for (int k_iter = 0; k_iter < k_iterations; k_iter++) {
          /** valid_item_k_group is the actual k_group_size for each iteration */
          int valid_item_k_group = (k_iter * block_k_group + block_k_group) > k_groups ? k_groups - k_iter * block_k_group : block_k_group;

          if (DEBUG) {
            print("======== K Computation Iteration ========");
            print_dec("n_iter", n_iter);
            print_dec("m_iter", m_iter);
            print_dec("k_iter", k_iter);
            print_dec("valid_item_seq_len", valid_item_seq_len);
            print_dec("valid_item_k_group", valid_item_k_group);
          }

          /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
          uint64_t input_ddr_addr = (k_iter * block_k_group) * args.seq_len * k_group_size * bytes_ifmap
                                    + m_iter * valid_item_seq_len * k_group_size * bytes_ifmap + args.input_base_addr;
          auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

          /** Compute offset of weight: the weight is stored in the format of [d_model/n_group_size, d_model/k_group_size, n_group_size,
           * k_group_size]*/
          uint64_t weight_ddr_addr = (n_iter * block_n_group) * args.d_model * n_group_size * bytes_weight
                                     + (k_iter * block_k_group) * n_group_size * k_group_size * bytes_weight + args.weight_key_base_addr;
          auto weight_ddr_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_weight);
          auto weight_ddr_offset_1 = split_exp_fra(n_group_size * args.d_model * bytes_weight);

          for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
            /** Load input */
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto load_input = load_iteration_2<0>(input_ddr_addr,
                                                    valid_item_seq_len - 1,
                                                    input_ddr_offset.first,
                                                    input_ddr_offset.second,
                                                    valid_item_k_group - 1,
                                                    MASTER_IFMAP_ADDR,
                                                    0);
              load_input.set_insn_number(0);
              load_input.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_input);

              if (DEBUG) {
                print("======== Load Input for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("input_ddr_addr", input_ddr_addr);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("ddr_offset_0", args.seq_len * k_group_size * bytes_ifmap);
                print_dec("seq_burst_1", valid_item_k_group);
                print_hex("sram_addr", MASTER_IFMAP_ADDR);
              }

              /** Load Weight, each core is responsible for one iteration of n_groups */
              auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * n_group_size * bytes_weight,
                                                     n_group_size - 1,
                                                     weight_ddr_offset_0.first,
                                                     weight_ddr_offset_0.second,
                                                     valid_item_k_group - 1,
                                                     weight_ddr_offset_1.first,
                                                     weight_ddr_offset_1.second,
                                                     block_n_group - 1,
                                                     MASTER_WEIGHT_ADDR,
                                                     0);
              load_weight.set_insn_number(0);
              load_weight.set_insn_opcode(2 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_weight);

              if (DEBUG) {
                print("======== Load Key Weight for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("weight_ddr_addr", weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * n_group_size * bytes_weight);
                print_dec("seq_burst_0", n_group_size);
                print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                print_dec("seq_burst_1", valid_item_k_group);
                print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                print_dec("seq_burst_2", block_n_group);
                print_hex("sram_addr", MASTER_WEIGHT_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                /** Load Weight, each core is responsible for one iteration of n_groups */
                auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * n_group_size * bytes_weight,
                                                      n_group_size - 1,
                                                      weight_ddr_offset_0.first,
                                                      weight_ddr_offset_0.second,
                                                      valid_item_k_group - 1,
                                                      weight_ddr_offset_1.first,
                                                      weight_ddr_offset_1.second,
                                                      block_n_group - 1,
                                                      MASTER_WEIGHT_ADDR + 1024,
                                                      0);
                load_weight.set_insn_number(0);
                load_weight.set_insn_opcode(2 + cluster * CORE_PER_CLUSTER);
                insn_series.push_back(load_weight);

                if (DEBUG) {
                  print("======== Load Key Weight for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("weight_ddr_addr", weight_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * n_group_size * bytes_weight);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                  print_dec("seq_burst_1", valid_item_k_group);
                  print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                  print_dec("seq_burst_2", block_n_group);
                  print_hex("sram_addr", MASTER_WEIGHT_ADDR + 1024);
                }
              }
            }
          }

          /** Compute Key projection */
          for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              /** each core is responsible for one iteration of n_groups */
              auto k_proj = gemm_execute(2,
                                         2,
                                         1,
                                         1,
                                         valid_item_seq_len - 1,
                                         block_n_group - 1,
                                         valid_item_k_group - 1,
                                         0,
                                         0,
                                         0,
                                         valid_item_k_group * block_n_group - 1,
                                         k_iter != 0);
              k_proj.set_insn_number(0);
              k_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(k_proj);

              if (DEBUG) {
                print("======== Key Projection for cluster " + std::to_string(cluster) + " core 0 ========");
                print_dec("tile_m", valid_item_seq_len);
                print_dec("block_k_group", valid_item_k_group);
                print_dec("block_n_group", block_n_group);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                /** each core is responsible for one iteration of n_groups */
                auto k_proj = gemm_execute(2,
                                          2,
                                          1,
                                          1,
                                          valid_item_seq_len - 1,
                                          block_n_group - 1,
                                          valid_item_k_group - 1,
                                          0,
                                          0,
                                          0,
                                          valid_item_k_group * block_n_group - 1,
                                          k_iter != 0);
                k_proj.set_insn_number(0);
                k_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(k_proj);

                if (DEBUG) {
                  print("======== Key Projection for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_dec("tile_m", valid_item_seq_len);
                  print_dec("block_k_group", valid_item_k_group);
                  print_dec("block_n_group", block_n_group);
                }
              }
            }
          }
        }

        /** Process bias, and convert parallelism */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          if (BIAS) {
            /** Compute bias ddr offset: the bias is stored in the format of [d_model/n_group_size, n_group_size] */
            uint64_t bias_ddr_addr = n_iter * n_group_size * bytes_bias + args.bias_key_base_addr;
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto load_bias = load_iteration_2<0>(
                bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias, block_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR, 0);
              load_bias.set_insn_number(0);
              load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_bias);

              if (DEBUG) {
                print("======== Load Key Bias for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias);
                print_dec("seq_burst_0", block_n_group);
                print_hex("ddr_offset", 0);
                print_dec("seq_burst_1", 0);
                print_hex("sram_addr", MASTER_VCUPARA_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto load_bias = load_iteration_2<0>(
                  bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias, block_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR + 256, 0);
                load_bias.set_insn_number(0);
                load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(load_bias);

                if (DEBUG) {
                  print("======== Load Key Bias for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias);
                  print_dec("seq_burst_0", block_n_group);
                  print_hex("ddr_offset", 0);
                  print_dec("seq_burst_1", 0);
                  print_hex("sram_addr", MASTER_VCUPARA_ADDR + 256);
                }
              }
            }
          }

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                                   vcu_resadd_dtype[kHalf],
                                   vcu_out_dtype[kHalf],
                                   0,
                                   1,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   valid_item_seq_len - 1,
                                   block_n_group - 1,
                                   0,
                                   1,
                                   0,
                                   0,
                                   0);
            vcu.set_insn_number(0);
            vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu);
            if (DEBUG) {
              print("======== VCU for cluster " + std::to_string(cluster) + " core 0========");
              print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
              print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
              print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
              print_dec("seq_len", valid_item_seq_len);
              print_dec("block_n_group", block_n_group);
            }

            auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, block_n_group, block_n_group * 2);
            vcu_convert.set_insn_number(0);
            vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu_convert);
            if (DEBUG) {
              print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 0 ========");
              print_dec("num data", valid_item_seq_len);
              print_dec("in channel group", block_n_group);
              print_dec("out channel group", block_n_group * 2);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                                    vcu_resadd_dtype[kHalf],
                                    vcu_out_dtype[kHalf],
                                    0,
                                    1,
                                    0,
                                    0, //psum_in_addr
                                    0,
                                    0,
                                    0, //ram_out_addr
                                    valid_item_seq_len - 1,
                                    block_n_group - 1,
                                    0,
                                    1,
                                    0,
                                    0,
                                    0);
              vcu.set_insn_number(0);
              vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu);
              if (DEBUG) {
                print("======== VCU for cluster " + std::to_string(cluster) + " core 1 ========");
                print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
                print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
                print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
                print_dec("seq_len", valid_item_seq_len);
                print_dec("block_n_group", block_n_group);
              }

              auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, block_n_group, block_n_group * 2);
              vcu_convert.set_insn_number(0);
              vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu_convert);
              if (DEBUG) {
                print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 1 ========");
                print_dec("num data", valid_item_seq_len);
                print_dec("in channel group", block_n_group);
                print_dec("out channel group", block_n_group * 2);
              }
            }
          }
        }

        /** Store */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            for (int head_iter = 0; head_iter < block_n_group_split_head; head_iter++) {
              int head_number    = (n_iter + cluster * CORE_PER_CLUSTER) / block_n_group_split_head + head_iter;
              int real_head_iter = (n_iter + cluster * CORE_PER_CLUSTER) % block_n_group_split_head;
              /** Compute offset, the key need to be stored as [head, seq_len/n_group_size, d_model/head/k_group_size, n_group_size,
               * k_group_size] */
              // int key_temp_ddr_addr =
              //   args.key_temp_base_addr + n_group_size * d_h * m_iter * bytes_ofmap
              //   + args.seq_len * d_h * (head_iter + n_iter * (block_n_group * n_group_scale) + cluster * CORE_PER_CLUSTER) * bytes_ofmap;
              u_int64_t key_temp_ddr_addr = (head_number * args.seq_len * d_h + m_iter * n_group_per_d_h * n_group_size * k_group_size
                                       + real_head_iter * n_group_size * k_group_size)
                                        * bytes_ofmap
                                      + args.key_temp_base_addr;
              auto key_temp_offset_0 = split_exp_fra(k_group_size * n_group_size * bytes_ofmap);

              auto store = store_iteration_2<0>(key_temp_ddr_addr,
                                                n_group_size - 1,
                                                key_temp_offset_0.first,
                                                key_temp_offset_0.second,
                                                block_n_group_split_head * n_group_scale - 1,
                                                MASTER_OFMAP_ADDR + head_iter * valid_item_seq_len * block_n_group,
                                                head_iter == block_n_group_split_head - 1 && n_iter + cluster * CORE_PER_CLUSTER == n_iterations - 1
                                                  && m_iter == m_iterations - 1 && all_done);
              store.set_insn_number(0);
              store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(store);

              if (DEBUG) {
                print("======== Store Key Temp for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("key_temp_ddr_addr", key_temp_ddr_addr);
                print_dec("seq_burst_0", n_group_size);
                print_hex("ddr_offset_0", k_group_size * n_group_size * bytes_ofmap);
                print_dec("seq_burst_1", block_n_group_split_head * n_group_scale);
                print_dec("head_number", head_number);
                print_dec("real_head_iter", real_head_iter);
                print_hex("sram_addr", MASTER_OFMAP_ADDR + head_iter * valid_item_seq_len * block_n_group);
              }
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              for (int head_iter = 0; head_iter < block_n_group_split_head; head_iter++) {
                /** Compute offset, the key need to be stored as [head, seq_len/n_group_size, d_model/head/k_group_size, n_group_size,
                 * k_group_size] */
                int key_temp_ddr_addr =
                  args.key_temp_base_addr + n_group_size * d_h * m_iter * bytes_ofmap
                  + args.seq_len * d_h * (head_iter + n_iter * (block_n_group * n_group_scale) + cluster * CORE_PER_CLUSTER + 1) * bytes_ofmap;
                auto key_temp_offset_0 = split_exp_fra(k_group_size * n_group_size * bytes_ofmap);

                auto store = store_iteration_2<0>(key_temp_ddr_addr,
                                                  n_group_size - 1,
                                                  key_temp_offset_0.first,
                                                  key_temp_offset_0.second,
                                                  n_group_per_d_h * n_group_scale - 1,
                                                  MASTER_OFMAP_ADDR + 1024,
                                                  n_iter + cluster * CORE_PER_CLUSTER + 1 == n_iterations - 1 && m_iter == m_iterations - 1 && all_done);
                store.set_insn_number(0);
                store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(store);

                if (DEBUG) {
                  print("======== Store Key Temp for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("key_temp_ddr_addr", key_temp_ddr_addr);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", k_group_size * n_group_size * bytes_ofmap);
                  print_dec("seq_burst_1", n_group_per_d_h * n_group_scale);
                  print_hex("sram_addr", MASTER_OFMAP_ADDR + 1024);
                }
              }
            }
          }
        }
      }
    }
  }

  void compute_q(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.d_model / k_group_size;
    int n_groups = args.d_model / n_group_size;

    /** set tile_m to MAX_IFMAP_DEPTH or args.seq_len to fully utilize the ifmap sram */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    // int tile_m = 32;
    /** set block_k_group to MAX_IFMAP_DEPTH / tile_m or k_groups to fully utilize the ifmap sram */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    // int block_k_group = 2;
    /** set block_n_group to MAX_WEIGHT_DEPTH / n_group_size / block_k_group or n_groups to fully utilize the weight sram */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);
    // int block_n_group = 1;

    /** The number of iterations on each dimension */
    int m_iterations = ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = ceil((double)n_groups / (double)block_n_group);
    int k_iterations = ceil((double)k_groups / (double)block_k_group);

    if (DEBUG) {
      print("======== Q Computation Iteration Setting ========");
      print_dec("tile_m", tile_m);
      print_dec("block_k_group", block_k_group);
      print_dec("block_n_group", block_n_group);
      print_dec("m_iterations", m_iterations);
      print_dec("n_iterations", n_iterations);
      print_dec("k_iterations", k_iterations);
    }

    for (int n_iter = 0; n_iter < n_iterations; n_iter += CORE_NUM) {
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
        /** valid_item_seq_len is the actual seq_len for each iteration */
        int valid_item_seq_len = (m_iter * tile_m + tile_m) <= args.seq_len ? tile_m : args.seq_len - m_iter * tile_m;
        for (int k_iter = 0; k_iter < k_iterations; k_iter++) {
          /** valid_item_k_group is the actual k_group_size for each iteration */
          int valid_item_k_group = (k_iter * block_k_group + block_k_group) <= k_groups ? block_k_group : k_groups - k_iter * block_k_group;

          if (DEBUG) {
            print("======== Q Computation Iteration ========");
            print_dec("n_iter", n_iter);
            print_dec("m_iter", m_iter);
            print_dec("k_iter", k_iter);
            print_dec("valid_item_seq_len", valid_item_seq_len);
            print_dec("valid_item_k_group", valid_item_k_group);
          }

          /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
          uint64_t input_ddr_addr = (k_iter * block_k_group) * args.seq_len * k_group_size * bytes_ifmap
                                    + m_iter * valid_item_seq_len * k_group_size * bytes_ifmap + args.input_base_addr;
          auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

          /** Compute offset of weight: the weight is stored in the format of [d_model/n_group_size, d_model/k_group_size, n_group_size,
           * k_group_size]*/
          uint64_t weight_ddr_addr = (n_iter * block_n_group) * args.d_model * n_group_size * bytes_weight
                                     + (k_iter * block_k_group) * n_group_size * k_group_size * bytes_weight + args.weight_query_base_addr;
          auto weight_ddr_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_weight);
          auto weight_ddr_offset_1 = split_exp_fra(n_group_size * args.d_model * bytes_weight);

          for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
            /** Load input */
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto load_input = load_iteration_2<0>(input_ddr_addr,
                                                    valid_item_seq_len - 1,
                                                    input_ddr_offset.first,
                                                    input_ddr_offset.second,
                                                    valid_item_k_group - 1,
                                                    MASTER_IFMAP_ADDR,
                                                    0);
              load_input.set_insn_number(0);
              load_input.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_input);
              if (DEBUG) {
                print("======== Load Input for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("input_ddr_addr", input_ddr_addr);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("ddr_offset_0", args.seq_len * k_group_size * bytes_ifmap);
                print_dec("seq_burst_1", valid_item_k_group);
                print_hex("sram_addr", MASTER_IFMAP_ADDR);
              }

              // Load Weight
              auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * block_n_group * args.d_model * n_group_size * bytes_weight,
                                                     31,
                                                     weight_ddr_offset_0.first,
                                                     weight_ddr_offset_0.second,
                                                     valid_item_k_group - 1,
                                                     weight_ddr_offset_1.first,
                                                     weight_ddr_offset_1.second,
                                                     block_n_group - 1,
                                                     MASTER_WEIGHT_ADDR,
                                                     0);
              load_weight.set_insn_number(0);
              load_weight.set_insn_opcode(2 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_weight);
              if (DEBUG) {
                print("======== Load Query Weight for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("weight_ddr_addr", weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * block_n_group * args.d_model * n_group_size * bytes_weight);
                print_dec("seq_burst_0", n_group_size);
                print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                print_dec("seq_burst_1", valid_item_k_group);
                print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                print_dec("seq_burst_2", block_n_group);
                print_hex("sram_addr", MASTER_WEIGHT_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * block_n_group * args.d_model * n_group_size * bytes_weight,
                                                      31,
                                                      weight_ddr_offset_0.first,
                                                      weight_ddr_offset_0.second,
                                                      valid_item_k_group - 1,
                                                      weight_ddr_offset_1.first,
                                                      weight_ddr_offset_1.second,
                                                      block_n_group - 1,
                                                      MASTER_WEIGHT_ADDR + 2048,
                                                      0);
                load_weight.set_insn_number(0);
                load_weight.set_insn_opcode(2 + cluster * CORE_PER_CLUSTER);
                insn_series.push_back(load_weight);
                if (DEBUG) {
                  print("======== Load Query Weight for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("weight_ddr_addr", weight_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * block_n_group * args.d_model * n_group_size * bytes_weight);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                  print_dec("seq_burst_1", valid_item_k_group);
                  print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                  print_dec("seq_burst_2", block_n_group);
                  print_hex("sram_addr", MASTER_WEIGHT_ADDR + 2048);
                }
              }
            }
          }

          // Compute Query Projection
          for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto q_proj = gemm_execute(2,
                                         2,
                                         1,
                                         1,
                                         valid_item_seq_len - 1,
                                         block_n_group - 1,
                                         valid_item_k_group - 1,
                                         0,
                                         0,
                                         0,
                                         valid_item_k_group * block_n_group - 1,
                                         k_iter != 0);
              q_proj.set_insn_number(0);
              q_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(q_proj);
              if (DEBUG) {
                print("======== Query Projection for cluster " + std::to_string(cluster) + " core 0 ========");
                print_dec("tile_m", valid_item_seq_len);
                print_dec("block_k_group", valid_item_k_group);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto q_proj = gemm_execute(2,
                                          2,
                                          1,
                                          1,
                                          valid_item_seq_len - 1,
                                          block_n_group - 1,
                                          valid_item_k_group - 1,
                                          1,
                                          1,
                                          2,
                                          valid_item_k_group * block_n_group - 1,
                                          k_iter != 0);
                q_proj.set_insn_number(0);
                q_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(q_proj);
                if (DEBUG) {
                  print("======== Query Projection for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_dec("tile_m", valid_item_seq_len);
                  print_dec("block_k_group", valid_item_k_group);
                }
              }
            }
          }
        }
        /** Process bias, and convert parallelism */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          if (BIAS) {
            /** Compute bias ddr offset: the bias is stored in the format of [d_model/n_group_size, n_group_size] */
            uint64_t bias_ddr_addr = n_iter * n_group_size * bytes_bias + args.bias_query_base_addr;

            if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
              auto load_bias = load_iteration_2<0>(
                bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias, block_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR, 0);
              load_bias.set_insn_number(0);
              load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_bias);

              if (DEBUG) {
                print("======== Load Query Bias for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias);
                print_dec("seq_burst_0", block_n_group);
                print_hex("ddr_offset", 0);
                print_dec("seq_burst_1", 0);
                print_hex("sram_addr", MASTER_VCUPARA_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto load_bias = load_iteration_2<1>(
                  bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias, block_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR + 256, 0);
                load_bias.set_insn_number(0);
                load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
                insn_series.push_back(load_bias);

                if (DEBUG) {
                  print("======== Load Query Bias for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias);
                  print_dec("seq_burst_0", block_n_group);
                  print_hex("ddr_offset", 0);
                  print_dec("seq_burst_1", 0);
                  print_hex("sram_addr", MASTER_VCUPARA_ADDR + 256);
                }
              }
            }
          }

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                                   vcu_resadd_dtype[kHalf],
                                   vcu_out_dtype[kHalf],
                                   0,
                                   1,
                                   0,
                                   0,
                                   0,
                                   0,
                                   0,
                                   valid_item_seq_len - 1,
                                   block_n_group - 1,
                                   0,
                                   1,
                                   0,
                                   0,
                                   0);
            vcu.set_insn_number(0);
            vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu);

            if (DEBUG) {
              print("======== VCU for cluster " + std::to_string(cluster) + " core 0 ========");
              print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
              print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
              print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
              print_dec("seq_len", valid_item_seq_len);
              print_dec("block_n_group", block_n_group);
            }

            auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, block_n_group, block_n_group * 2);
            vcu_convert.set_insn_number(0);
            vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu_convert);

            if (DEBUG) {
              print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 0 ========");
              print_dec("num data", valid_item_seq_len);
              print_dec("in channel group", block_n_group);
              print_dec("out channel group", block_n_group * 2);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                                    vcu_resadd_dtype[kHalf],
                                    vcu_out_dtype[kHalf],
                                    0,
                                    1,
                                    0,
                                    8192, //psum_in_addr
                                    0,
                                    0,
                                    8192, //ram_out_addr
                                    valid_item_seq_len - 1,
                                    block_n_group - 1,
                                    0,
                                    1,
                                    0,
                                    0,
                                    0);
              vcu.set_insn_number(0);
              vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu);

              if (DEBUG) {
                print("======== VCU for cluster " + std::to_string(cluster) + " core 1 ========");
                print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
                print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
                print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
                print_dec("seq_len", valid_item_seq_len);
                print_dec("block_n_group", block_n_group);
              }

              auto vcu_convert = vcu_parallelism_conversion(0, 8192, 2048, valid_item_seq_len, block_n_group, block_n_group * 2);
              vcu_convert.set_insn_number(0);
              vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu_convert);

              if (DEBUG) {
                print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 1 ========");
                print_dec("num data", valid_item_seq_len);
                print_dec("in channel group", block_n_group);
                print_dec("out channel group", block_n_group * 2);
              }
            }
          }
        }
        /** Store */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          u_int64_t query_temp_ddr_addr = (n_iter * block_n_group * n_group_scale) * args.seq_len * (n_group_size / n_group_scale) * bytes_ofmap
                                    + m_iter * valid_item_seq_len * (n_group_size / n_group_scale) * bytes_ofmap
                                    + args.query_temp_base_addr;
          auto store_ddr_offset = split_exp_fra(args.seq_len * (n_group_size / n_group_scale) * bytes_ofmap);

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto store = store_iteration_2<0>(query_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.seq_len * args.d_model * bytes_ofmap,
                                              valid_item_seq_len - 1,
                                              store_ddr_offset.first,
                                              store_ddr_offset.second,
                                              (block_n_group * n_group_scale) - 1,
                                              MASTER_OFMAP_ADDR,
                                              (n_iter + cluster * CORE_PER_CLUSTER == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
            store.set_insn_number(0);
            store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(store);

            if (DEBUG) {
              print("======== Store Query Temp for cluster " + std::to_string(cluster) + " core 0 ========");
              print_hex("query_temp_ddr_addr", query_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.seq_len * args.d_model * bytes_ofmap);
              print_dec("seq_burst_0", valid_item_seq_len);
              print_hex("ddr_offset_0", args.seq_len * (n_group_size / n_group_scale) * bytes_ofmap);
              print_dec("seq_burst_1", (block_n_group * n_group_scale));
              print_hex("sram_addr", MASTER_OFMAP_ADDR);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto store = store_iteration_2<1>(query_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.seq_len * args.d_model * bytes_ofmap,
                                                valid_item_seq_len - 1,
                                                store_ddr_offset.first,
                                                store_ddr_offset.second,
                                                (block_n_group * n_group_scale) - 1,
                                                MASTER_OFMAP_ADDR + 2048,
                                                (n_iter + cluster * CORE_PER_CLUSTER + 1 == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
              store.set_insn_number(0);
              store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(store);

              if (DEBUG) {
                print("======== Store Query Temp for cluster " + std::to_string(cluster) + " core 1 ========");
                print_hex("query_temp_ddr_addr", query_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.seq_len * args.d_model * bytes_ofmap);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("ddr_offset_0", args.seq_len * (n_group_size / n_group_scale) * bytes_ofmap);
                print_dec("seq_burst_1", (block_n_group * n_group_scale));
                print_hex("sram_addr", MASTER_OFMAP_ADDR + 2048);
              }
            }
          }
        }
      }
    }
  }

  std::pair<int, int> split_exp_fra(int64_t x)
  {
    if (x > 8355840) {
      std::throw_with_nested(std::runtime_error("x is too large"));
    }
    int max_exp = (1 << CLUSTER_NUM) - 1;
    int max_fra = (1 << 8) - 1;
    int exp     = 0;
    while (x > max_fra) {
      x /= 2;
      exp++;
    }
    return {exp, x};
  }
};

}  // namespace mha
}  // namespace transformer