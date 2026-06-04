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

template<bool DEBUG>
struct FusedMultiHeadAttentionOp {
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
  };

  FusedMultiHeadAttentionOp()
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
    this->compute_qk(insn_series, args, 0);

    return {insn_series, opcode};
  }

  void set_broadcast(std::vector<instruction>& insn_series)
  {
    insn_series.push_back(load_iteration_2<0>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<2>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<4>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<6>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
  }

  void set_fase_broadcast(std::vector<instruction>& insn_series)
  {
    insn_series.push_back(load_iteration_2<0>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<2>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<4>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    insn_series.push_back(load_iteration_2<6>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
  }

  void set_vcucode(std::vector<uint64_t>& opcode)
  {
    auto query_code = vcu::asm_vcu_op({"copy psum, reg0"});
    opcode.insert(opcode.end(), query_code.begin(), query_code.end());

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

  void compute_qk(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    auto round_off = [](int x, int y) { return (x + y - 1) / y; };
    int  k_groups  = args.d_model / k_group_size;
    int  n_groups  = args.d_model / n_group_size;

    /* --------------------------------------- set iteration boundaryies -------------------------------------- */
    /** Set tile_m to 32 so that we can compute query, key and value at one time */
    int tile_m = std::min(32, args.seq_len);
    /** Set block_k_group to MAX_IFMAP_DEPTH / tile_m to fully utilize the ifmap sram */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    /** Set block_n_group to MAX_WEIGHT_DEPTH / n_group_size / block_k_group or n_groups to fully utilize the weight sram */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);
    /** Set weight_reuse_time to MAX_PSUM_DEPTH / tile_m / block_n_group to fully utilize the psum sram */
    int weight_reuse = MAX_PSUM_DEPTH / tile_m / block_n_group;

    /** Set the number of iterations */
    int m_iterations = round_off(args.seq_len, tile_m * weight_reuse);
    int k_iterations = round_off(k_groups, block_k_group);
    int n_iterations = round_off(n_groups, block_n_group);

    if (DEBUG) {
      print("======== QK Computation Iteration Setting ========");
      print_dec("tile_m", tile_m);
      print_dec("block_k_group", block_k_group);
      print_dec("block_n_group", block_n_group);
      print_dec("weight_reuse", weight_reuse);
      print_dec("m_iterations", m_iterations);
      print_dec("k_iterations", k_iterations);
      print_dec("n_iterations", n_iterations);
    }

    /* -------------------------------------------- Start Iteration ------------------------------------------- */
    for (int n_iter = 0; n_iter < n_iterations; n_iter += 3) {
      int current_n = n_iter * block_n_group;
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) {
        for (int k_iter = 0; k_iter < k_iterations; k_iter++) {
          int current_k = k_iter * block_k_group;

          /** Compute offset of Query weight */
          uint64_t weight_query_offset = (current_k * n_group_size * k_group_size + current_n * args.d_model * n_group_size) * bytes_weight
                                         + args.weight_query_base_addr;
          auto weight_query_ddr_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_weight);
          auto weight_query_ddr_offset_1 = split_exp_fra(args.d_model * n_group_size * bytes_weight);

          /** Compute offset of Key weight */
          uint64_t weight_key_offset =
            (current_k * n_group_size * k_group_size + current_n * args.d_model * n_group_size) * bytes_weight + args.weight_key_base_addr;
          auto weight_key_ddr_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_weight);
          auto weight_key_ddr_offset_1 = split_exp_fra(args.d_model * n_group_size * bytes_weight);

          /** Load weight */
          for (int core = 0; core < 6; core++) {
            if (core < 3) {
              if ((n_iter + core) * block_n_group < n_iterations) {
                auto load_query_weight = load_iteration_3<1>(weight_query_offset + core * args.d_model * n_group_size * bytes_weight,
                                                             31,
                                                             weight_query_ddr_offset_0.first,
                                                             weight_query_ddr_offset_0.second,
                                                             block_k_group - 1,
                                                             weight_query_ddr_offset_1.first,
                                                             weight_query_ddr_offset_1.second,
                                                             block_n_group - 1,
                                                             MASTER_WEIGHT_ADDR + (core % 2) * 1024,
                                                             0);
                load_query_weight.set_insn_opcode(2 + (core / 2) * 2);
                insn_series.push_back(load_query_weight);

                if (DEBUG) {
                  print("======== Load Query Weight for core " + std::to_string(core) + " ========");
                  print_dec("core", core);
                  print_hex("current_n_group", (n_iter + core) * block_n_group);
                  print_hex("current_k_group", k_iter * block_k_group);
                  print_hex("weight_ddr_addr", weight_query_offset + core * args.d_model * n_group_size * bytes_weight);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                  print_dec("seq_burst_1", block_k_group);
                  print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                  print_dec("seq_burst_2", block_n_group);
                  print_hex("sram_addr", MASTER_WEIGHT_ADDR + (core % 2) * 1024);
                }
              }
            }
            else {
              if ((n_iter + core - 3) * block_n_group < n_iterations) {
                auto load_key_weight = load_iteration_3<1>(weight_key_offset + (core - 3) * args.d_model * n_group_size * bytes_weight,
                                                           31,
                                                           weight_key_ddr_offset_0.first,
                                                           weight_key_ddr_offset_0.second,
                                                           block_k_group - 1,
                                                           weight_key_ddr_offset_1.first,
                                                           weight_key_ddr_offset_1.second,
                                                           block_n_group - 1,
                                                           MASTER_WEIGHT_ADDR + (core % 2) * 1024,
                                                           0);
                load_key_weight.set_insn_opcode(2 + (core / 2) * 2);
                insn_series.push_back(load_key_weight);

                if (DEBUG) {
                  print("======== Load Key Weight for core " + std::to_string(core) + " ========");
                  print_dec("core", core);
                  print_hex("current_n_group", (n_iter + core - 3) * block_n_group);
                  print_hex("current_k_group", k_iter * block_k_group);
                  print_hex("weight_ddr_addr", weight_key_offset + (core - 3) * args.d_model * n_group_size * bytes_weight);
                  print_dec("seq_burst_0", n_group_size);
                  print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_weight);
                  print_dec("seq_burst_1", block_k_group);
                  print_hex("ddr_offset_1", n_group_size * args.d_model * bytes_weight);
                  print_dec("seq_burst_2", block_n_group);
                  print_hex("sram_addr", MASTER_WEIGHT_ADDR + (core % 2) * 1024);
                }
              }
            }
          }
          for (int r_iter = 0; r_iter < weight_reuse; r_iter++) {
            int current_m = m_iter * tile_m * weight_reuse + r_iter * tile_m;
            if (current_m < args.seq_len) {
              int valid_items_m = current_m + tile_m > args.seq_len ? args.seq_len - current_m : tile_m;

              /** Compute offset of input */
              uint64_t input_offset =
                (current_m * k_group_size + current_k * k_group_size * args.seq_len) * bytes_ifmap + args.input_base_addr;
              auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

              /** Load input */
              for (int cluster = 0; cluster < 3; cluster++) {
                if (n_iter * block_n_group + cluster < n_iterations) {
                  auto load_input = load_iteration_2<0>(input_offset,
                                                        valid_items_m - 1,
                                                        input_ddr_offset.first,
                                                        input_ddr_offset.second,
                                                        block_k_group - 1,
                                                        MASTER_IFMAP_ADDR,
                                                        0);
                  load_input.set_insn_opcode(1 + cluster * 2);
                  insn_series.push_back(load_input);

                  if (DEBUG) {
                    print("======== Load Input for cluster " + std::to_string(cluster) + " ========");
                    print_dec("cluster", cluster);
                    print_hex("current_n_group", n_iter * block_n_group + cluster);
                    print_hex("current_k_group", k_iter * block_k_group);
                    print_hex("input_ddr_addr", input_offset + cluster * args.d_model * n_group_size * bytes_ifmap);
                    print_dec("seq_burst", n_group_size);
                    print_hex("ddr_offset", args.seq_len * k_group_size * bytes_ifmap);
                    print_hex("sram_addr", MASTER_IFMAP_ADDR);
                  }
                }
              }

              /** Compute projection */
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
    int max_exp = (1 << 4) - 1;
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