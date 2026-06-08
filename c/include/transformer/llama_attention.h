#pragma once

#include "common/insn.h"
#include "common/type_utils.h"
#include "vcu/vcu_opcode.h"
#include "transformer/rope_embedding.h"
#include "transformer/softmax.h"
#include "vcu/vcu_operation.h"
#include "common/type_utils.h"
#include "addr_for_transformer.h"
#include "cmath"

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

/** Convert float to hex string */
std::string float_to_hex_string(float value)
{
  uint32_t as_int;
  std::memcpy(&as_int, &value, sizeof(float));
  std::stringstream ss;
  ss << std::hex << std::setw(8) << std::setfill('0') << as_int;
  return "0x" + ss.str();
}

int CORE_NUM = 1;
int CLUSTER_NUM = 1; 
int CORE_PER_CLUSTER = CORE_NUM / CLUSTER_NUM;

template<bool DEBUG, bool BIAS = false, bool MASK = true, bool RoPE = true>
struct LlamaAttentionOp {

  static constexpr int MAX_IFMAP_DEPTH  = DEFAULT_MAX_IFMAP_DEPTH;
  static constexpr int MAX_WEIGHT_DEPTH = DEFAULT_MAX_WEIGHT_DEPTH;
  static constexpr int MAX_PSUM_DEPTH   = DEFAULT_MAX_PSUM_DEPTH;
  static constexpr int MAX_OFMAP_DEPTH  = DEFAULT_MAX_OFMAP_DEPTH;

  int k_group_size;
  int n_group_size;
  int bytes_ifmap;
  int bytes_weight;
  int bytes_psum;
  int bytes_bias;
  int bytes_half;
  int bytes_float;
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
    uint64_t freq_cls_base_addr    = 0;
    uint64_t mask_base_addr        = 0;
    uint64_t bias_query_base_addr  = 0;
    uint64_t bias_key_base_addr    = 0;
    uint64_t bias_value_base_addr  = 0;
    uint64_t bias_output_base_addr = 0;
    uint64_t vcu_code_base_addr    = MHA_VCUCODE_ADDR;
    uint64_t exp_lut_base_addr     = EXP_LUT_ADDR;
    uint64_t rec_lut_base_addr     = REC_LUT_ADDR;
    uint64_t all_done              = 1;
  };

  LlamaAttentionOp()
  {
    /** Default float16 * float16 -> float32 -> float16 */
    k_group_size  = 16;
    n_group_size  = 32;
    bytes_ifmap   = 2;
    bytes_weight  = 2;
    bytes_psum    = 4;
    bytes_bias    = 4;
    bytes_half    = 2;
    bytes_float   = 4;
    n_group_scale = 2;
  }

  std::pair<std::vector<instruction>, std::vector<uint64_t>> operator()(const Argument& args)
  {
    std::vector<instruction> insn_series;
    std::vector<uint64_t>    vcucode_series;

    this->set_vcucode(vcucode_series, args);
    size_t vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
    size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
    vcucode_series.resize(vcucode_ddr_lines * 8, 0);

    this->compute_q(insn_series, args, 0);
    this->q_rope_embedding(insn_series, args, 0);
    refresh_vcucode_and_lut_sram(insn_series, args, vcucode_ddr_lines);
    this->compute_k(insn_series, args, 0);
    this->k_rope_embedding_and_transform(insn_series, args, 0);
    refresh_vcucode_and_lut_sram(insn_series, args, vcucode_ddr_lines);
    set_fase_broadcast(insn_series);
    this->compute_qkt(insn_series, args, 0);
    this->causal_mask(insn_series, args, 0);
    refresh_vcucode_and_lut_sram(insn_series, args, vcucode_ddr_lines);
    this->softmax(insn_series, args, 0);
    refresh_vcucode_and_lut_sram(insn_series, args, vcucode_ddr_lines);
    set_broadcast(insn_series);
    this->compute_v(insn_series, args, 0);
    set_fase_broadcast(insn_series);
    this->compute_pv(insn_series, args, 0);
    set_broadcast(insn_series);
    this->compute_o(insn_series, args, args.all_done);
    
    return {insn_series, vcucode_series};
  }

  void refresh_vcucode_and_lut_sram(std::vector<instruction>& insn_series, const Argument& args, size_t vcucode_ddr_lines){
    /** Load vcucode for each core */
    insn_series.push_back(load_iteration_2<0>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    // insn_series.push_back(load_iteration_2<0>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR + 32, 0));
    // insn_series.push_back(load_iteration_2<1>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    // insn_series.push_back(load_iteration_2<1>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR + 32, 0));
    // insn_series.push_back(load_iteration_2<2>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    // insn_series.push_back(load_iteration_2<2>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR + 32, 0));
    // insn_series.push_back(load_iteration_2<3>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
    // insn_series.push_back(load_iteration_2<3>(args.vcu_code_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR + 32, 0));

    /** Load vculut for each core */
    insn_series.push_back(load_iteration_2<0>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    // insn_series.push_back(load_iteration_2<0>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 128, 0));
    insn_series.push_back(load_iteration_2<0>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64, 0));
    // insn_series.push_back(load_iteration_2<0>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 192, 0));
    // insn_series.push_back(load_iteration_2<1>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    // insn_series.push_back(load_iteration_2<1>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    // insn_series.push_back(load_iteration_2<1>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64, 0));
    // insn_series.push_back(load_iteration_2<1>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 192, 0));
    // insn_series.push_back(load_iteration_2<2>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    // insn_series.push_back(load_iteration_2<2>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    // insn_series.push_back(load_iteration_2<2>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64, 0));
    // insn_series.push_back(load_iteration_2<2>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 192, 0));
    // insn_series.push_back(load_iteration_2<3>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    // insn_series.push_back(load_iteration_2<3>(args.exp_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR, 0));
    // insn_series.push_back(load_iteration_2<3>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 64, 0));
    // insn_series.push_back(load_iteration_2<3>(args.rec_lut_base_addr, 64 * 128 / 256 - 1, 0, 0, 0, MASTER_VCULUT_ADDR + 192, 0));

    auto vcu_cfg_insns = vcu_config(0, 2, 0, 0, 0, 0, 0, 0, 0, 0);
    vcu_cfg_insns.set_insn_opcode(25);
    insn_series.push_back(vcu_cfg_insns);
    // vcu_cfg_insns.set_insn_opcode(26);
    // insn_series.push_back(vcu_cfg_insns);
    // vcu_cfg_insns.set_insn_opcode(27);
    // insn_series.push_back(vcu_cfg_insns);
    // vcu_cfg_insns.set_insn_opcode(28);
    // insn_series.push_back(vcu_cfg_insns);
    // vcu_cfg_insns.set_insn_opcode(29);
    // insn_series.push_back(vcu_cfg_insns);
    // vcu_cfg_insns.set_insn_opcode(30);
    // insn_series.push_back(vcu_cfg_insns);
    // vcu_cfg_insns.set_insn_opcode(31);
    // insn_series.push_back(vcu_cfg_insns);
    // vcu_cfg_insns.set_insn_opcode(32);
    // insn_series.push_back(vcu_cfg_insns);
  }

  void set_broadcast(std::vector<instruction>& insn_series) {
    insn_series.push_back(load_iteration_2<0>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    // insn_series.push_back(load_iteration_2<2>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    // insn_series.push_back(load_iteration_2<4>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    // insn_series.push_back(load_iteration_2<6>(CFG_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
  }

  void set_fase_broadcast(std::vector<instruction>& insn_series) {
    insn_series.push_back(load_iteration_2<0>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    // insn_series.push_back(load_iteration_2<2>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    // insn_series.push_back(load_iteration_2<4>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
    // insn_series.push_back(load_iteration_2<6>(CFG_FALSE_BROADCAST_ADDR, 0, 0, 0, 0, 0xa0, 0));
  }

  void set_vcucode(std::vector<uint64_t>& vcucode_series, const Argument& args)
  {
    /** bias or copy */ // addr 0
    if (BIAS) {
      /** If BIAS is enabled, generate the code to load bias */
      auto query_code = vcu::asm_vcu_op({"add psum, para, reg0"});
      vcucode_series.insert(vcucode_series.end(), query_code.begin(), query_code.end());
    }
    else {
      auto query_code = vcu::asm_vcu_op({"copy psum, reg0"});
      vcucode_series.insert(vcucode_series.end(), query_code.begin(), query_code.end());
    }

    /** Scale Product */ // addr 1
    int d_h = args.d_model / args.head_num;
    auto scale = float_to_hex_string(1.0f / std::sqrt(d_h)); // return string '0x........'
    auto vcucode = vcu::asm_vcu_op({"config reg0, " + scale, "mul psum reg0, reg1"});
    for (auto code : vcucode) {
      vcucode_series.push_back(code);
    }

    // pad vcucode to 1 lines (4 opcode per line)
    size_t vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
    size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
    vcucode_series.resize(vcucode_ddr_lines * 4, 0);

    /** Softmax*/
    transformer::softmax::SoftmaxOp<DEBUG> softmax_op;
    softmax_op.set_vcucode(vcucode_series); //  addr 4 (7 opcodes)

    // pad vcucode to 1+2=3 lines (4 opcode per line)
    vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
    vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
    vcucode_series.resize(vcucode_ddr_lines * 4, 0);

    if(RoPE && MASK){
      /** RoPE Embedding and fp32 -> fp16 conversion*/
      transformer::rope_embedding::RopeEmbeddingOp<DEBUG> rope_op;
      rope_op.set_vcucode(vcucode_series); //  addr 12 (7 opcodes)

      // pad vcucode to 3+2=5 lines (4 opcode per line)
      vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
      vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
      vcucode_series.resize(vcucode_ddr_lines * 4, 0);

      auto convert_code = vcu::asm_vcu_op({"copy psum, reg0"}); // addr 20
      vcucode_series.insert(vcucode_series.end(), convert_code.begin(), convert_code.end());

      // pad vcucode to 5+1=6 lines (4 opcode per line)
      vcucode_bytes = vcucode_series.size() * sizeof(uint64_t);
      vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
      vcucode_series.resize(vcucode_ddr_lines * 4, 0);

      /** Add Casual Mask */
      auto add_code = vcu::asm_vcu_op({"add psum resadd, reg0"}); // addr 24
      vcucode_series.insert(vcucode_series.end(), add_code.begin(), add_code.end());
    }    
  }

  /** Compute O
   * @input: [d_model/k_group_size, seq_len, k_group_size], fp16
   * @weight: [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size], fp16
   * @output: [seq_len, d_model/n_group_size, n_group_size], fp32
   * @process: fp32, n_group_size; 留待后续残差加法
   */
  void compute_o(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.d_model / k_group_size;
    int n_groups = args.d_model / n_group_size;

    /** set tile_m to MAX_IFMAP_DEPTH or args.seq_len to fully utilize the ifmap sram */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    // int tile_m = 32;
    /** set block_k_group to MAX_IFMAP_DEPTH / tile_m or k_groups to fully utilize the ifmap sram */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    // int block_k_group = 8;
    /** set block_n_group to MAX_WEIGHT_DEPTH / n_group_size / block_k_group or n_groups to fully utilize the weight sram */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);
    // int block_n_group = 4;

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
      /** valid_item_n_group is the actual n_group_size for each iteration */
      int valid_item_n_group = (n_iter * block_n_group + block_n_group) <= n_groups ? block_n_group : n_groups - n_iter * block_n_group;
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
            print_dec("valid_item_n_group", valid_item_n_group);
          }

          /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
          uint64_t input_ddr_addr = (k_iter * block_k_group) * args.seq_len * k_group_size * bytes_ifmap
                                    + m_iter * tile_m * k_group_size * bytes_ifmap + args.output_temp_base_addr;
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
                                                     valid_item_n_group - 1,
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
                print_dec("seq_burst_2", valid_item_n_group);
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
                                                      valid_item_n_group - 1,
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
                  print_dec("seq_burst_2", valid_item_n_group);
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
                                         valid_item_n_group - 1,
                                         valid_item_k_group - 1,
                                         0,
                                         0,
                                         0,
                                         valid_item_k_group * valid_item_n_group - 1,
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
                                          valid_item_n_group - 1,
                                          valid_item_k_group - 1,
                                          0,
                                          0,
                                          0,
                                          valid_item_k_group * valid_item_n_group - 1,
                                          k_iter != 0);
                q_proj.set_insn_number(0);
                q_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(q_proj);
                if (DEBUG) {
                  print("======== Output Projection for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_dec("tile_m", valid_item_seq_len);
                  print_dec("block_k_group", valid_item_k_group);
                  print_dec("block_n_group", valid_item_n_group);
                }
              }
            }
          }
        }
        /** Process bias, and convert parallelism */
        // for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
        //   if (BIAS) {
        //     /** Compute bias ddr offset: the bias is stored in the format of [d_model/n_group_size, n_group_size] */
        //     uint64_t bias_ddr_addr = n_iter * n_group_size * bytes_bias + args.bias_output_base_addr;

        //     if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
        //       auto load_bias = load_iteration_2<0>(
        //         bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias, valid_item_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR, 0);
        //       load_bias.set_insn_number(0);
        //       load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
        //       insn_series.push_back(load_bias);

        //       if (DEBUG) {
        //         print("======== Load Output Bias for cluster " + std::to_string(cluster) + " core 0 ========");
        //         print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias);
        //         print_dec("seq_burst_0", valid_item_n_group);
        //         print_hex("ddr_offset", 0);
        //         print_dec("seq_burst_1", 0);
        //         print_hex("sram_addr", MASTER_VCUPARA_ADDR);
        //       }
        //     }
        //     if (CORE_PER_CLUSTER == 2){
        //       if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
        //         auto load_bias = load_iteration_2<1>(
        //           bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias, valid_item_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR + 256, 0);
        //         load_bias.set_insn_number(0);
        //         load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
        //         insn_series.push_back(load_bias);

        //         if (DEBUG) {
        //           print("======== Load Output Bias for cluster " + std::to_string(cluster) + " core 1 ========");
        //           print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias);
        //           print_dec("seq_burst_0", valid_item_n_group);
        //           print_hex("ddr_offset", 0);
        //           print_dec("seq_burst_1", 0);
        //           print_hex("sram_addr", MASTER_VCUPARA_ADDR + 256);
        //         }
        //       }
        //     }
        //   }

        //   if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
        //     auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
        //                            vcu_resadd_dtype[kHalf],
        //                            vcu_out_dtype[kHalf],
        //                            0,
        //                            1,
        //                            0,
        //                            0,
        //                            0,
        //                            0,
        //                            0,
        //                            valid_item_seq_len - 1,
        //                            valid_item_n_group - 1,
        //                            0,
        //                            1,
        //                            0,
        //                            0,
        //                            0);
        //     vcu.set_insn_number(0);
        //     vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
        //     insn_series.push_back(vcu);

        //     if (DEBUG) {
        //       print("======== VCU for cluster " + std::to_string(cluster) + " core 0 ========");
        //       print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
        //       print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
        //       print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
        //       print_dec("seq_len", valid_item_seq_len);
        //       print_dec("block_n_group", valid_item_n_group);
        //     }

        //     auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
        //     vcu_convert.set_insn_number(0);
        //     vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
        //     insn_series.push_back(vcu_convert);

        //     if (DEBUG) {
        //       print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 0 ========");
        //       print_dec("num data", valid_item_seq_len);
        //       print_dec("in channel group", valid_item_n_group);
        //       print_dec("out channel group", valid_item_n_group * 2);
        //     }
        //   }
        //   if (CORE_PER_CLUSTER == 2){
        //     if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
        //       auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
        //                             vcu_resadd_dtype[kHalf],
        //                             vcu_out_dtype[kHalf],
        //                             0,
        //                             1,
        //                             0,
        //                             0,
        //                             0,
        //                             0,
        //                             0,
        //                             valid_item_seq_len - 1,
        //                             valid_item_n_group - 1,
        //                             0,
        //                             1,
        //                             0,
        //                             0,
        //                             0);
        //       vcu.set_insn_number(0);
        //       vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
        //       insn_series.push_back(vcu);

        //       if (DEBUG) {
        //         print("======== VCU for cluster " + std::to_string(cluster) + " core 1 ========");
        //         print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
        //         print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
        //         print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
        //         print_dec("seq_len", valid_item_seq_len);
        //         print_dec("block_n_group", valid_item_n_group);
        //       }

        //       auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
        //       vcu_convert.set_insn_number(0);
        //       vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
        //       insn_series.push_back(vcu_convert);

        //       if (DEBUG) {
        //         print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 1 ========");
        //         print_dec("num data", valid_item_seq_len);
        //         print_dec("in channel group", valid_item_n_group);
        //         print_dec("out channel group", valid_item_n_group * 2);
        //       }
        //     }            
        //   }
        // }

        /** Store */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          u_int64_t output_temp_ddr_addr = (n_iter * block_n_group) * args.seq_len * (n_group_size) * bytes_float
                                    + m_iter * tile_m * (n_group_size) * bytes_float + args.output_base_addr;
          auto store_ddr_offset = split_exp_fra(args.seq_len * (n_group_size) * bytes_float);

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto store = store_iteration_2<0>(output_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * bytes_float,
                                              valid_item_seq_len * n_group_size * bytes_float / 32 - 1,
                                              store_ddr_offset.first,
                                              store_ddr_offset.second,
                                              (valid_item_n_group) - 1,
                                              MASTER_PSUM_ADDR,
                                              (n_iter + cluster * CORE_PER_CLUSTER == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
            store.set_insn_number(0);
            store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(store);

            if (DEBUG) {
              print("======== Store Output Temp for cluster " + std::to_string(cluster) + " core 0 ========");
              print_hex("output_temp_ddr_addr", output_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * bytes_float);
              print_dec("seq_burst_0", valid_item_seq_len);
              print_hex("ddr_offset_0", args.seq_len * (n_group_size) * bytes_float);
              print_dec("seq_burst_1", (valid_item_n_group));
              print_hex("sram_addr", MASTER_PSUM_ADDR);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto store = store_iteration_2<1>(output_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 2,
                                                valid_item_seq_len - 1,
                                                store_ddr_offset.first,
                                                store_ddr_offset.second,
                                                (valid_item_n_group * n_group_scale) - 1,
                                                MASTER_OFMAP_ADDR + 2048,
                                                (n_iter + cluster * CORE_PER_CLUSTER + 1 == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
              store.set_insn_number(0);
              store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(store);

              if (DEBUG) {
                print("======== Store Output Temp for cluster " + std::to_string(cluster) + " core 1 ========");
                print_hex("output_temp_ddr_addr", output_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 2);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("ddr_offset_0", valid_item_seq_len * (n_group_size / n_group_scale) * bytes_half);
                print_dec("seq_burst_1", (valid_item_n_group * n_group_scale));
                print_hex("sram_addr", MASTER_OFMAP_ADDR + 2048);
              }
            }            
          }
        }
      }
    }
  }

  /** Compute pv (Probe * Value) for each head
   * @input: [head_num, seq_len/k_group_size, seq_len, k_group_size], fp16
   * @weight: [head_num, d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size], fp16
   * @output: [head_num, d_h/k_group_size, seq_len, k_group_size], fp16
   *  equals to store in [d_model/k_group_size, seq_len, k_group_size]
   * @process: fp32 -> fp16, parallelism conversion
   */
  void compute_pv(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = ceil((double)args.seq_len / (double)k_group_size);
    int d_h      = args.d_model / args.head_num;
    int n_groups = d_h / n_group_size;

    /** Compute tiling size */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    // int tile_m = 32;
    /** Feed ifmap sram as much as possible */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    // int block_k_group = 2;
    /** Depend on the depth of weight sram and block_k_group computed above, compute block_n_group */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, std::min(n_groups, MAX_PSUM_DEPTH / tile_m));
    // int block_n_group = 4;

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
      /** valid_item_n_group is the actual n_group_size for each iteration */
      int valid_item_n_group = (n_iter * block_n_group + block_n_group) <= n_groups ? block_n_group : n_groups - n_iter * block_n_group;
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
              print_dec("valid_item_n_group", valid_item_n_group);
            }

            /** Compute offset of input: the input is stored in the format of [head_num, seq_len/k_group_size, seq_len, k_group_size]*/
            uint64_t input_ddr_addr = (head * args.seq_len * args.seq_len + k_iter * args.seq_len * k_group_size * block_k_group
                                       + m_iter * tile_m * k_group_size)
                                        * bytes_ifmap
                                      + args.query_temp_base_addr;  // Address Reuse, probe_hf -> query_temp
            auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

            /** Compute offset of weight: the weight is stored in the format of [head_num, d_h/n_group_size, seq_len/k_group_size,
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
                                                      valid_item_n_group - 1,
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
                  print_dec("seq_burst_2", valid_item_n_group);
                }

                /** Compute */
                auto compute = gemm_execute(2,
                                            2,
                                            1,
                                            1,
                                            valid_item_seq_len - 1,
                                            valid_item_n_group - 1,
                                            valid_item_k_group - 1,
                                            0,
                                            0,
                                            0,
                                            valid_item_k_group * valid_item_n_group - 1,
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
                                         valid_item_n_group - 1,
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

              auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
              vcu_convert.set_insn_number(0);
              vcu_convert.set_insn_opcode(25 + core);
              insn_series.push_back(vcu_convert);
            }
          }

          /** Store */
          uint64_t output_ddr_addr = (head * args.seq_len * d_h + (n_iter * block_n_group * n_group_scale) * args.seq_len * k_group_size
                                      + m_iter * tile_m * k_group_size)
                                       * bytes_half
                                     + args.output_temp_base_addr;
          auto output_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_half);
          for (int core = 0; core < CORE_NUM; core++) {
            if (core + head < args.head_num) {
              auto store_output = store_iteration_2<0>(output_ddr_addr + core * args.seq_len * d_h * bytes_half,
                                                       valid_item_seq_len - 1,
                                                       output_ddr_offset.first,
                                                       output_ddr_offset.second,
                                                       valid_item_n_group * n_group_scale - 1,
                                                       MASTER_OFMAP_ADDR + (core % 2) * 1024,
                                                       head + core == args.head_num - 1 && n_iter == n_iterations - 1
                                                         && m_iter == m_iterations - 1 && all_done);
              store_output.set_insn_number(0);
              store_output.set_insn_opcode(9 + core);
              insn_series.push_back(store_output);

              if (DEBUG) {
                print("======== Store Output for core id" + std::to_string(core) + " ========");
                print_hex("output_ddr_addr", output_ddr_addr + core * args.seq_len * d_h * bytes_half);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_dec("seq_burst_1", valid_item_n_group * n_group_scale);
                print_hex("output_ddr_offset", args.seq_len * k_group_size * bytes_half);
              }
            }
          }
        }
      }
    }
  }

  /** Compute V 
   * @input: [d_model/k_group_size, seq_len, k_group_size], fp16
   * @weight: [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size], fp16
   * @output: [head_num, d_h/k_group_size, seq_len/k_group_size, n_group_size, k_group_size], fp16
   * @process: fp32, n_group_size -> transpose -> (parallesim conversion)fp16, k_group_size -> transform
   * Note: transform过程形状变化如下: [seq_len/k_group_size, d_model, k_group_size] ->
          [head_num, d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size]
  */
  void compute_v(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.d_model / k_group_size;
    int n_groups = args.d_model / n_group_size;

    /** Set tile_m to 32 so that the seq_len_k dimension can be transposed */
    int tile_m = std::min(32, args.seq_len);
    // int tile_m = 32;
    /** Feed ifmap sram as much as possible */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, std::min(k_groups, MAX_WEIGHT_DEPTH / n_group_size / 4));  // block_n_group >= 4
    // int block_k_group = 8;
    /** Depend on the depth of weight sram and block_k_group computed above, compute block_n_group */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, std::min(n_groups, MAX_PSUM_DEPTH / tile_m));
    // int block_n_group = 4;

    /** The number of iterations on each dimension */
    int m_iterations = ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = ceil((double)n_groups / (double)block_n_group);
    int k_iterations = ceil((double)k_groups / (double)block_k_group);

    /** Split head parameters */
    int d_h = args.d_model / args.head_num;
    int n_group_per_d_h = d_h / n_group_size;
    int block_group_split_head_num = block_n_group / n_group_per_d_h; 
    assert (block_group_split_head_num > 0 && "block_group_split_head_num should be greater than 0");

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
      print_dec("block_group_split_head_num", block_group_split_head_num);
    }

    for (int n_iter = 0; n_iter < n_iterations; n_iter += CORE_NUM) {
      /** valid_item_n_group is the actual n_group_size for each iteration */
      int valid_item_n_group = (n_iter * block_n_group + block_n_group) <= n_groups ? block_n_group : n_groups - n_iter * block_n_group;
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
            print_dec("valid_item_n_group", valid_item_n_group);
          }

          /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
          uint64_t input_ddr_addr = (k_iter * block_k_group) * args.seq_len * k_group_size * bytes_ifmap
                                    + m_iter * tile_m * k_group_size * bytes_ifmap + args.input_base_addr;
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
              auto load_weight = load_iteration_3<1>(weight_ddr_addr + (cluster * CORE_PER_CLUSTER) * valid_item_n_group * args.d_model * n_group_size * bytes_weight,
                                                     n_group_size - 1,
                                                     weight_ddr_offset_0.first,
                                                     weight_ddr_offset_0.second,
                                                     valid_item_k_group - 1,
                                                     weight_ddr_offset_1.first,
                                                     weight_ddr_offset_1.second,
                                                     valid_item_n_group - 1,
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
                print_dec("seq_burst_2", valid_item_n_group);
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
                                                      valid_item_n_group - 1,
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
                  print_dec("seq_burst_2", valid_item_n_group);
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
                                         valid_item_n_group - 1,
                                         valid_item_k_group - 1,
                                         0,
                                         0,
                                         0,
                                         valid_item_k_group * valid_item_n_group - 1,
                                         k_iter != 0);
              v_proj.set_insn_number(0);
              v_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(v_proj);

              if (DEBUG) {
                print("======== Value Projection for cluster " + std::to_string(cluster) + " core 0 ========");
                print_dec("tile_m", valid_item_seq_len);
                print_dec("block_k_group", valid_item_k_group);
                print_dec("block_n_group", valid_item_n_group);
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
                                          valid_item_n_group - 1,
                                          valid_item_k_group - 1,
                                          0,
                                          0,
                                          0,
                                          valid_item_k_group * valid_item_n_group - 1,
                                          k_iter != 0);
                v_proj.set_insn_number(0);
                v_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(v_proj);

                if (DEBUG) {
                  print("======== Value Projection for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_dec("tile_m", valid_item_seq_len);
                  print_dec("block_k_group", valid_item_k_group);
                  print_dec("block_n_group", valid_item_n_group);
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
                bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias, valid_item_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR, 0);
              load_bias.set_insn_number(0);
              load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(load_bias);

              if (DEBUG) {
                print("======== Load Key Bias for cluster " + std::to_string(cluster) + " core 0 ========");
                print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias);
                print_dec("seq_burst_0", valid_item_n_group);
                print_hex("ddr_offset", 0);
                print_dec("seq_burst_1", 0);
                print_hex("sram_addr", MASTER_VCUPARA_ADDR);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto load_bias = load_iteration_2<0>(
                  bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias, valid_item_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR + 256, 0);
                load_bias.set_insn_number(0);
                load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
                insn_series.push_back(load_bias);

                if (DEBUG) {
                  print("======== Load Value Bias for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias);
                  print_dec("seq_burst_0", valid_item_n_group);
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
                                   valid_item_n_group - 1,
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
              print_dec("block_n_group", valid_item_n_group);
            }

            for (int inner_n = 0; inner_n < valid_item_n_group; inner_n++) {
              auto transpose = vcu_transpose(2, inner_n * 32, inner_n * 32);
              vcu.set_insn_number(0);
              vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(transpose);
            }

            auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
            vcu_convert.set_insn_number(0);
            vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(vcu_convert);
            if (DEBUG) {
              print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 0 ========");
              print_dec("num data", valid_item_seq_len);
              print_dec("in channel group", valid_item_n_group);
              print_dec("out channel group", valid_item_n_group * 2);
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
                                    valid_item_n_group - 1,
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
                print_dec("block_n_group", valid_item_n_group);
              }

              for (int inner_n = 0; inner_n < valid_item_n_group; inner_n++) {
                auto transpose = vcu_transpose(0, inner_n * 32, inner_n * 32);
                vcu.set_insn_number(0);
                vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
              }

              auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
              vcu_convert.set_insn_number(0);
              vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(vcu_convert);
              if (DEBUG) {
                print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 1 ========");
                print_dec("num data", valid_item_seq_len);
                print_dec("in channel group", valid_item_n_group);
                print_dec("out channel group", valid_item_n_group * 2);
              }
            }
          }
        }

        /** -------------------Store with head splitting like k_transform------------------- */
        for (int block_head_iter = 0; block_head_iter < block_group_split_head_num; block_head_iter++) {
          for(int n_group_d_h_iter = 0; n_group_d_h_iter < n_group_per_d_h; n_group_d_h_iter++) {
            int iter_num = block_head_iter * n_group_per_d_h + n_group_d_h_iter;
            int head_number = n_iter * block_group_split_head_num + block_head_iter;
            
            /** input: [seq_len/k_group_size, d_model, k_group_size] , fp16
               Compute offset, the value need to be stored as 
              [head_num, d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size] */
            // note: valid_item_seq_len = tile_m = 32  
            uint64_t value_temp_ddr_addr = (head_number * args.seq_len * d_h + 
                                          n_group_d_h_iter * args.seq_len * n_group_size + 
                                          m_iter * (valid_item_seq_len / k_group_size) * n_group_size * k_group_size) * bytes_half
                                          + args.value_temp_base_addr;
            int size_per_iter = (valid_item_seq_len / k_group_size) * n_group_size * k_group_size * bytes_half;
            auto value_temp_offset_0 = split_exp_fra(size_per_iter);

            auto store = store_iteration_2<0>(value_temp_ddr_addr,
                                              size_per_iter / 32 - 1,
                                              value_temp_offset_0.first,
                                              value_temp_offset_0.second,
                                              0,
                                              MASTER_OFMAP_ADDR + iter_num * size_per_iter / 32,
                                              n_group_d_h_iter ==  n_group_per_d_h - 1 && 
                                                block_head_iter == block_group_split_head_num - 1 
                                                && n_iter == n_iterations - 1
                                                && m_iter == m_iterations - 1 && all_done);
            store.set_insn_number(0);
            insn_series.push_back(store);

            if (DEBUG) {
              print("======== Store Value Temp with Transform ========");
              print_hex("value_temp_ddr_addr", value_temp_ddr_addr);
              print_dec("seq_burst_0", size_per_iter / 32 - 1);
              print_hex("ddr_offset_0", size_per_iter);
              print_dec("seq_burst_1", 0);
              print_dec("head_number", head_number);
              print_hex("sram_addr", MASTER_OFMAP_ADDR + iter_num * size_per_iter / 32);
            }
          }
        }
      }
    }
  }

  /** Softmax computation
   * @input: [head_num, seq_len/n_group_size, seq_len, n_group_size], fp32
   * @output: [head_num, seq_len/k_group_size, seq_len, k_group_size], fp16
   * @process: softmax; fp32 -> fp16; parallelism conversion
   *           
   */
  void softmax(std::vector<instruction>& insn_series, const Argument& args, uint64_t all_done)
  {
    for (int head = 0; head < args.head_num; head++){
      /** Config Softmax */
      int oc_groups = args.seq_len / n_group_size;
      int tile_m = std::min(MAX_PSUM_DEPTH, args.seq_len);
      int block_oc_group = std::min(MAX_PSUM_DEPTH / tile_m, oc_groups);
      uint64_t vcu_code_current_addr = args.vcu_code_base_addr + 4 * sizeof(uint64_t);

      using SoftmaxOp_t = transformer::softmax::SoftmaxOp<DEBUG>;
      SoftmaxOp_t softmax_op;

      // compute head offset
      uint64_t head_offset = head * args.seq_len * args.seq_len * bytes_float;

      // config softmax
      typename SoftmaxOp_t::Argument softmax_args = {
        .seq_len = args.seq_len,
        .d_model = args.seq_len,
        .tile_m = tile_m,
        .block_oc_group = block_oc_group,
        .dtype = kFloat32,
        .input_base_addr = args.score_temp_base_addr + head_offset,
        .output_base_addr = args.probe_temp_base_addr + head_offset,
        .vcu_code_base_addr = vcu_code_current_addr,
        .rec_lut_base_addr = args.rec_lut_base_addr,
        .exp_lut_base_addr = args.exp_lut_base_addr,
        .all_done = 0
      };
      auto softmax_pack = softmax_op(softmax_args);
      insn_series.insert(insn_series.end(), softmax_pack.first.begin(), softmax_pack.first.end());

      /** set tile_m to fully utilize the psum and ofamp sram */  // 后面再做进一步深度逻辑处理，先用ofmap depth作为限制以免并行度转换出错
      tile_m = std::min(std::min(MAX_OFMAP_DEPTH / 2, MAX_PSUM_DEPTH), args.seq_len);
      /** set block_oc_group to MAX_OFMAP_DEPTH / tile_m or oc_groups to fully utilize the psum sram */
      block_oc_group = std::min(MAX_OFMAP_DEPTH / tile_m / 2, std::min(MAX_PSUM_DEPTH / tile_m, oc_groups));

      vcu_code_current_addr = args.vcu_code_base_addr; // point to the start of vcu code (copy only)
      // compute offset of input and output
      uint64_t probe_input_addr = head * args.seq_len * args.seq_len * bytes_float + args.probe_temp_base_addr;
      uint64_t probe_output_addr = head * args.seq_len * args.seq_len * bytes_half + args.query_temp_base_addr;  // Address Reuse, probe_hf -> query_temp

      /** fp32, group_size = 32 -> fp16, group_size = 16 */
      using vcu_convert_t = vcu::operation::SingleVCUOp<DEBUG>;
      vcu_convert_t vcu_convert;
      typename vcu_convert_t::Argument vcu_convert_args = {
          .seq_len = args.seq_len,
          .d_model = args.seq_len,
          .tile_m = tile_m,
          .block_oc_group = block_oc_group,
          .dtype = kFloat32,
          .op_type = vcu::operation::OP_TYPE::CONVERT,
          .input1_base_addr = probe_input_addr,
          .output_base_addr = probe_output_addr,  
          .vcu_code_addr = vcu_code_current_addr,
          .all_done = all_done && (head == args.head_num - 1)
      };
      auto vcu_convert_pack = vcu_convert(vcu_convert_args);
      insn_series.insert(insn_series.end(), vcu_convert_pack.first.begin(), vcu_convert_pack.first.end());
    } // end of head loop
  }

  /** QK computation
   * @input: Query [head_num, d_h/k_group_size, seq_len, k_group_size], fp16
   *         Key   [head_num, seq_len/n_group_size, d_h/k_group_size, n_group_size, k_group_size], fp16
   * @output: Score [head_num, seq_len/n_group_size, seq_len, n_group_size], fp32
   */
  void compute_qkt(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int d_h      = args.d_model / args.head_num;
    int k_groups = d_h / k_group_size;
    int n_groups = args.seq_len / n_group_size;

    /** Compute tiling size */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    // int tile_m = 32;
    /** Feed ifmap sram as much as possible */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    // int block_k_group = 8;
    /** Depend on the depth of weight sram and block_k_group computed above, compute block_n_group */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);
    // int block_n_group = 4;

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
        /** valid_item_n_group is the actual n_group_size for each iteration */
        int valid_item_n_group = (n_iter * block_n_group + block_n_group) <= n_groups ? block_n_group : n_groups - n_iter * block_n_group;
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
              print_dec("valid_item_n_group", valid_item_n_group);
            }

            /** Compute offset of input(Query): the input is stored in the format of [head_num, d_h/k_group_size, seq_len, k_group_size]*/
            uint64_t input_ddr_addr = head * d_h * args.seq_len * bytes_ifmap
                                      + k_iter * block_k_group * args.seq_len * k_group_size * bytes_ifmap
                                      + m_iter * tile_m * k_group_size * bytes_ifmap + args.value_temp_base_addr;  // Address Reuse, query_hf -> value_temp
            auto input_ddr_offset = split_exp_fra(args.seq_len * k_group_size * bytes_ifmap);

            /** Compute offset of weight(Key): the weight is stored in the format of [head_num, seq_len/n_group_size, d_h/k_group_size, n_group_size,
              k_group_size]*/
            uint64_t weight_ddr_addr = head * args.seq_len * d_h * bytes_weight + n_iter * block_n_group * d_h * n_group_size * bytes_weight
                                       + k_iter * block_k_group * n_group_size * k_group_size * bytes_weight + args.query_temp_base_addr;  // Address Reuse, key_hf -> query_temp
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
                                                    valid_item_n_group - 1,
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
                  print_dec("n_burst_1", valid_item_n_group);
                }

                /** Compute QK^T */
                auto compute_qk = gemm_execute(2,
                                               2,
                                               1,
                                               1,
                                               valid_item_seq_len - 1,
                                               valid_item_n_group - 1,
                                               valid_item_k_group - 1,
                                               0,
                                               0,
                                               0,
                                               valid_item_k_group * valid_item_n_group - 1,
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
                                             valid_item_n_group - 1,
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
                print_dec("oc_group", valid_item_n_group);
              }
            }
          }

          /** Store output */
          uint64_t output_ddr_addr = (head * args.seq_len * args.seq_len + n_iter * block_n_group * args.seq_len * n_group_size
                                      + m_iter * tile_m * n_group_size) * bytes_float
                                     + args.score_temp_base_addr;
          auto output_ddr_offset = split_exp_fra(args.seq_len * n_group_size * bytes_float);
          for (int core = 0; core < CORE_NUM; core++) {
            /** Store output */
            if (head + core < args.head_num) {
              auto store_output = store_iteration_2<0>(output_ddr_addr + core * args.seq_len * args.seq_len * bytes_float,
                                                       valid_item_seq_len * bytes_float - 1,
                                                       output_ddr_offset.first,
                                                       output_ddr_offset.second,
                                                       valid_item_n_group - 1,
                                                       MASTER_PSUM_ADDR + (core % 2) * 512,
                                                       head + core == args.head_num - 1 && m_iter == m_iterations - 1
                                                         && n_iter == n_iterations - 1 && all_done);
              store_output.set_insn_number(0);
              store_output.set_insn_opcode(9 + core); // 原：9 + core / 2
              insn_series.push_back(store_output);
            }
          }
        }
      }
    }
  }

  /** Compute K
   * @input: [d_model/k_group_size, seq_len, k_group_size], fp16
   * @weight: [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size], fp16
   * @output: [d_model/n_group_size, seq_len, n_group_size], fp32
   * @process: 先不进行fp32-> fp16以及并行度转换，留待后续RoPE Embedding。
   */
  void compute_k(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.d_model / k_group_size;
    int n_groups = args.d_model / n_group_size;

    /** set tile_m to MAX_IFMAP_DEPTH or args.seq_len to fully utilize the ifmap sram */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    // int tile_m = 32;
    /** set block_k_group to MAX_IFMAP_DEPTH / tile_m or k_groups to fully utilize the ifmap sram */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    // int block_k_group = 8;
    /** set block_n_group to MAX_WEIGHT_DEPTH / n_group_size / block_k_group or n_groups to fully utilize the weight sram */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);
    // int block_n_group = 4;

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
      /** valid_item_n_group is the actual n_group_size for each iteration */
      int valid_item_n_group = (n_iter * block_n_group + block_n_group) <= n_groups ? block_n_group : n_groups - n_iter * block_n_group;
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
            print_dec("valid_item_n_group", valid_item_n_group);
          }

          /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
          uint64_t input_ddr_addr = (k_iter * block_k_group) * args.seq_len * k_group_size * bytes_ifmap
                                    + m_iter * tile_m * k_group_size * bytes_ifmap + args.input_base_addr;
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
                                                     valid_item_n_group - 1,
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
                print_dec("seq_burst_2", valid_item_n_group);
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
                                                      valid_item_n_group - 1,
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
                  print_dec("seq_burst_2", valid_item_n_group);
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
                                         valid_item_n_group - 1,
                                         valid_item_k_group - 1,
                                         0,
                                         0,
                                         0,
                                         valid_item_k_group * valid_item_n_group - 1,
                                         k_iter != 0);
              k_proj.set_insn_number(0);
              k_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(k_proj);

              if (DEBUG) {
                print("======== Key Projection for cluster " + std::to_string(cluster) + " core 0 ========");
                print_dec("tile_m", valid_item_seq_len);
                print_dec("block_k_group", valid_item_k_group);
                print_dec("block_n_group", valid_item_n_group);
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
                                          valid_item_n_group - 1,
                                          valid_item_k_group - 1,
                                          0,
                                          0,
                                          0,
                                          valid_item_k_group * valid_item_n_group - 1,
                                          k_iter != 0);
                k_proj.set_insn_number(0);
                k_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(k_proj);

                if (DEBUG) {
                  print("======== Key Projection for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_dec("tile_m", valid_item_seq_len);
                  print_dec("block_k_group", valid_item_k_group);
                  print_dec("block_n_group", valid_item_n_group);
                }
              }
            }
          }
        }

        /** Process bias, and convert parallelism */
        // for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
        //   if (BIAS) {
        //     /** Compute bias ddr offset: the bias is stored in the format of [d_model/n_group_size, n_group_size] */
        //     uint64_t bias_ddr_addr = n_iter * n_group_size * bytes_bias + args.bias_key_base_addr;
        //     if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
        //       auto load_bias = load_iteration_2<0>(
        //         bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias, valid_item_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR, 0);
        //       load_bias.set_insn_number(0);
        //       load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
        //       insn_series.push_back(load_bias);

        //       if (DEBUG) {
        //         print("======== Load Key Bias for cluster " + std::to_string(cluster) + " core 0 ========");
        //         print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias);
        //         print_dec("seq_burst_0", valid_item_n_group);
        //         print_hex("ddr_offset", 0);
        //         print_dec("seq_burst_1", 0);
        //         print_hex("sram_addr", MASTER_VCUPARA_ADDR);
        //       }
        //     }
        //     if (CORE_PER_CLUSTER == 2){
        //       if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
        //         auto load_bias = load_iteration_2<0>(
        //           bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias, valid_item_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR + 256, 0);
        //         load_bias.set_insn_number(0);
        //         load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER + 1);
        //         insn_series.push_back(load_bias);

        //         if (DEBUG) {
        //           print("======== Load Key Bias for cluster " + std::to_string(cluster) + " core 1 ========");
        //           print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias);
        //           print_dec("seq_burst_0", valid_item_n_group);
        //           print_hex("ddr_offset", 0);
        //           print_dec("seq_burst_1", 0);
        //           print_hex("sram_addr", MASTER_VCUPARA_ADDR + 256);
        //         }
        //       }
        //     }
        //   }

        //   if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
        //     auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
        //                            vcu_resadd_dtype[kHalf],
        //                            vcu_out_dtype[kHalf],
        //                            0,
        //                            1,
        //                            0,
        //                            0,
        //                            0,
        //                            0,
        //                            0,
        //                            valid_item_seq_len - 1,
        //                            valid_item_n_group - 1,
        //                            0,
        //                            1,
        //                            0,
        //                            0,
        //                            0);
        //     vcu.set_insn_number(0);
        //     vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
        //     insn_series.push_back(vcu);
        //     if (DEBUG) {
        //       print("======== VCU for cluster " + std::to_string(cluster) + " core 0========");
        //       print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
        //       print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
        //       print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
        //       print_dec("seq_len", valid_item_seq_len);
        //       print_dec("block_n_group", valid_item_n_group);
        //     }

        //     auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
        //     vcu_convert.set_insn_number(0);
        //     vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
        //     insn_series.push_back(vcu_convert);
        //     if (DEBUG) {
        //       print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 0 ========");
        //       print_dec("num data", valid_item_seq_len);
        //       print_dec("in channel group", valid_item_n_group);
        //       print_dec("out channel group", valid_item_n_group * 2);
        //     }
        //   }
        //   if (CORE_PER_CLUSTER == 2){
        //     if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
        //       auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
        //                             vcu_resadd_dtype[kHalf],
        //                             vcu_out_dtype[kHalf],
        //                             0,
        //                             1,
        //                             0,
        //                             0, //psum_in_addr
        //                             0,
        //                             0,
        //                             0, //ram_out_addr
        //                             valid_item_seq_len - 1,
        //                             valid_item_n_group - 1,
        //                             0,
        //                             1,
        //                             0,
        //                             0,
        //                             0);
        //       vcu.set_insn_number(0);
        //       vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
        //       insn_series.push_back(vcu);
        //       if (DEBUG) {
        //         print("======== VCU for cluster " + std::to_string(cluster) + " core 1 ========");
        //         print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
        //         print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
        //         print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
        //         print_dec("seq_len", valid_item_seq_len);
        //         print_dec("block_n_group", valid_item_n_group);
        //       }

        //       auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
        //       vcu_convert.set_insn_number(0);
        //       vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
        //       insn_series.push_back(vcu_convert);
        //       if (DEBUG) {
        //         print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 1 ========");
        //         print_dec("num data", valid_item_seq_len);
        //         print_dec("in channel group", valid_item_n_group);
        //         print_dec("out channel group", valid_item_n_group * 2);
        //       }
        //     }
        //   }
        // }

        /** Store */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          u_int64_t key_temp_ddr_addr = (n_iter * block_n_group) * args.seq_len * (n_group_size) * bytes_float
                                    + m_iter * tile_m * (n_group_size) * bytes_float + args.key_temp_base_addr;
          auto store_ddr_offset = split_exp_fra(args.seq_len * (n_group_size) * bytes_float);

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto store = store_iteration_2<0>(key_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * bytes_float,
                                              valid_item_seq_len * n_group_size * bytes_float / 32 - 1,
                                              store_ddr_offset.first,
                                              store_ddr_offset.second,
                                              (valid_item_n_group) - 1,
                                              MASTER_PSUM_ADDR,
                                              (n_iter + cluster * CORE_PER_CLUSTER == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
            store.set_insn_number(0);
            store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(store);

            if (DEBUG) {
              print("======== Store Key Temp for cluster " + std::to_string(cluster) + " core 0 ========");
              print_hex("key_temp_ddr_addr", key_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * bytes_float);
              print_dec("seq_burst_0", valid_item_seq_len);
              print_hex("ddr_offset_0", args.seq_len * (n_group_size) * bytes_float);
              print_dec("seq_burst_1", (valid_item_n_group));
              print_hex("sram_addr", MASTER_PSUM_ADDR);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto store = store_iteration_2<1>(key_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 2,
                                                valid_item_seq_len - 1,
                                                store_ddr_offset.first,
                                                store_ddr_offset.second,
                                                (valid_item_n_group * n_group_scale) - 1,
                                                MASTER_OFMAP_ADDR + 2048,
                                                (n_iter + cluster * CORE_PER_CLUSTER + 1 == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
              store.set_insn_number(0);
              store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(store);

              if (DEBUG) {
                print("======== Store Key Temp for cluster " + std::to_string(cluster) + " core 1 ========");
                print_hex("key_temp_ddr_addr", key_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 2);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("ddr_offset_0", valid_item_seq_len * (n_group_size / n_group_scale) * bytes_half);
                print_dec("seq_burst_1", (valid_item_n_group * n_group_scale));
                print_hex("sram_addr", MASTER_OFMAP_ADDR + 2048);
              }
            }            
          }
        }
      }
    }
  }

  /** Compute Q
   * @input: [d_model/k_group_size, seq_len, k_group_size], fp16
   * @weight: [d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size], fp16
   * @output: [d_model/n_group_size, seq_len, n_group_size], fp32
   * @process: 先不进行fp32-> fp16以及并行度转换，留待后续RoPE Embedding。
   */
  void compute_q(std::vector<instruction>& insn_series, const Argument& args, int all_done)
  {
    int k_groups = args.d_model / k_group_size;
    int n_groups = args.d_model / n_group_size;

    /** set tile_m to MAX_IFMAP_DEPTH or args.seq_len to fully utilize the ifmap sram */
    int tile_m = std::min(MAX_IFMAP_DEPTH, args.seq_len);
    // int tile_m = 32;
    /** set block_k_group to MAX_IFMAP_DEPTH / tile_m or k_groups to fully utilize the ifmap sram */
    int block_k_group = std::min(MAX_IFMAP_DEPTH / tile_m, k_groups);
    // int block_k_group = 8;
    /** set block_n_group to MAX_WEIGHT_DEPTH / n_group_size / block_k_group or n_groups to fully utilize the weight sram */
    int block_n_group = std::min(MAX_WEIGHT_DEPTH / n_group_size / block_k_group, n_groups);
    // int block_n_group = 4;

    // int tile_m = 64;
    // int block_k_group = 4;
    // int block_n_group = 3; // for tile test

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
      /** valid_item_n_group is the actual n_group_size for each iteration */
      int valid_item_n_group = (n_iter * block_n_group + block_n_group) <= n_groups ? block_n_group : n_groups - n_iter * block_n_group;
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
            print_dec("valid_item_n_group", valid_item_n_group);
          }

          /** Compute offset of input: the input is stored in the format of [d_model/k_group_size, seq_len, k_group_size]*/
          uint64_t input_ddr_addr = (k_iter * block_k_group) * args.seq_len * k_group_size * bytes_ifmap
                                    + m_iter * tile_m * k_group_size * bytes_ifmap + args.input_base_addr;
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
                                                     n_group_size - 1,
                                                     weight_ddr_offset_0.first,
                                                     weight_ddr_offset_0.second,
                                                     valid_item_k_group - 1,
                                                     weight_ddr_offset_1.first,
                                                     weight_ddr_offset_1.second,
                                                     valid_item_n_group - 1,
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
                print_dec("seq_burst_2", valid_item_n_group);
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
                                                      valid_item_n_group - 1,
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
                  print_dec("seq_burst_2", valid_item_n_group);
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
                                         valid_item_n_group - 1,
                                         valid_item_k_group - 1,
                                         0,
                                         0,
                                         0,
                                         valid_item_k_group * valid_item_n_group - 1,
                                         k_iter != 0);
              q_proj.set_insn_number(0);
              q_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER);
              insn_series.push_back(q_proj);
              if (DEBUG) {
                print("======== Query Projection for cluster " + std::to_string(cluster) + " core 0 ========");
                print_dec("tile_m", valid_item_seq_len);
                print_dec("block_k_group", valid_item_k_group);
                print_dec("block_n_group", valid_item_n_group);
              }
            }
            if (CORE_PER_CLUSTER == 2){
              if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
                auto q_proj = gemm_execute(2,
                                          2,
                                          1,
                                          1,
                                          valid_item_seq_len - 1,
                                          valid_item_n_group - 1,
                                          valid_item_k_group - 1,
                                          1,
                                          1,
                                          2,
                                          valid_item_k_group * valid_item_n_group - 1,
                                          k_iter != 0);
                q_proj.set_insn_number(0);
                q_proj.set_insn_opcode(17 + cluster * CORE_PER_CLUSTER + 1);
                insn_series.push_back(q_proj);
                if (DEBUG) {
                  print("======== Query Projection for cluster " + std::to_string(cluster) + " core 1 ========");
                  print_dec("tile_m", valid_item_seq_len);
                  print_dec("block_k_group", valid_item_k_group);
                  print_dec("block_n_group", valid_item_n_group);
                }
              }
            }
          }
        }

        // /** Process bias, and convert parallelism */
        // for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
        //   if (BIAS) {
        //     /** Compute bias ddr offset: the bias is stored in the format of [d_model/n_group_size, n_group_size] */
        //     uint64_t bias_ddr_addr = n_iter * n_group_size * bytes_bias + args.bias_query_base_addr;

        //     if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
        //       auto load_bias = load_iteration_2<0>(
        //         bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias, valid_item_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR, 0);
        //       load_bias.set_insn_number(0);
        //       load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
        //       insn_series.push_back(load_bias);

        //       if (DEBUG) {
        //         print("======== Load Query Bias for cluster " + std::to_string(cluster) + " core 0 ========");
        //         print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER) * n_group_size * bytes_bias);
        //         print_dec("seq_burst_0", valid_item_n_group);
        //         print_hex("ddr_offset", 0);
        //         print_dec("seq_burst_1", 0);
        //         print_hex("sram_addr", MASTER_VCUPARA_ADDR);
        //       }
        //     }
        //     if (CORE_PER_CLUSTER == 2){
        //       if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
        //         auto load_bias = load_iteration_2<1>(
        //           bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias, valid_item_n_group - 1, 0, 0, 0, MASTER_VCUPARA_ADDR + 256, 0);
        //         load_bias.set_insn_number(0);
        //         load_bias.set_insn_opcode(1 + cluster * CORE_PER_CLUSTER);
        //         insn_series.push_back(load_bias);

        //         if (DEBUG) {
        //           print("======== Load Query Bias for cluster " + std::to_string(cluster) + " core 1 ========");
        //           print_hex("bias_ddr_addr", bias_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * n_group_size * bytes_bias);
        //           print_dec("seq_burst_0", valid_item_n_group);
        //           print_hex("ddr_offset", 0);
        //           print_dec("seq_burst_1", 0);
        //           print_hex("sram_addr", MASTER_VCUPARA_ADDR + 256);
        //         }
        //       }
        //     }
        //   }

        //   if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
        //     auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
        //                            vcu_resadd_dtype[kHalf],
        //                            vcu_out_dtype[kHalf],
        //                            0,
        //                            1,
        //                            0,
        //                            0,
        //                            0,
        //                            0,
        //                            0,
        //                            valid_item_seq_len - 1,
        //                            valid_item_n_group - 1,
        //                            0,
        //                            1,
        //                            0,
        //                            0,
        //                            0);
        //     vcu.set_insn_number(0);
        //     vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
        //     insn_series.push_back(vcu);

        //     if (DEBUG) {
        //       print("======== VCU for cluster " + std::to_string(cluster) + " core 0 ========");
        //       print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
        //       print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
        //       print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
        //       print_dec("seq_len", valid_item_seq_len);
        //       print_dec("block_n_group", valid_item_n_group);
        //     }

        //     auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
        //     vcu_convert.set_insn_number(0);
        //     vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER);
        //     insn_series.push_back(vcu_convert);

        //     if (DEBUG) {
        //       print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 0 ========");
        //       print_dec("num data", valid_item_seq_len);
        //       print_dec("in channel group", valid_item_n_group);
        //       print_dec("out channel group", valid_item_n_group * 2);
        //     }
        //   }
        //   if (CORE_PER_CLUSTER == 2){
        //     if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
        //       auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
        //                             vcu_resadd_dtype[kHalf],
        //                             vcu_out_dtype[kHalf],
        //                             0,
        //                             1,
        //                             0,
        //                             8192, //psum_in_addr
        //                             0,
        //                             0,
        //                             8192, //ram_out_addr
        //                             valid_item_seq_len - 1,
        //                             valid_item_n_group - 1,
        //                             0,
        //                             1,
        //                             0,
        //                             0,
        //                             0);
        //       vcu.set_insn_number(0);
        //       vcu.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
        //       insn_series.push_back(vcu);

        //       if (DEBUG) {
        //         print("======== VCU for cluster " + std::to_string(cluster) + " core 1 ========");
        //         print("psum_dtype: " + std::to_string(vcu_psum_dtype[kFloat32]));
        //         print("resadd_dtype: " + std::to_string(vcu_resadd_dtype[kHalf]));
        //         print("out_dtype: " + std::to_string(vcu_out_dtype[kHalf]));
        //         print_dec("seq_len", valid_item_seq_len);
        //         print_dec("block_n_group", valid_item_n_group);
        //       }

        //       auto vcu_convert = vcu_parallelism_conversion(0, 8192, 2048, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
        //       vcu_convert.set_insn_number(0);
        //       vcu_convert.set_insn_opcode(25 + cluster * CORE_PER_CLUSTER + 1);
        //       insn_series.push_back(vcu_convert);

        //       if (DEBUG) {
        //         print("======== VCU Conversion for cluster " + std::to_string(cluster) + " core 1 ========");
        //         print_dec("num data", valid_item_seq_len);
        //         print_dec("in channel group", valid_item_n_group);
        //         print_dec("out channel group", valid_item_n_group * 2);
        //       }
        //     }
        //   }
        // }
        /** Store */
        for (int cluster = 0; cluster < CLUSTER_NUM; cluster++) {
          u_int64_t query_temp_ddr_addr = (n_iter * block_n_group) * args.seq_len * (n_group_size) * bytes_float
                                    + m_iter * tile_m * (n_group_size) * bytes_float + args.query_temp_base_addr;
          auto store_ddr_offset = split_exp_fra(args.seq_len * (n_group_size) * bytes_float);

          if (n_iter + cluster * CORE_PER_CLUSTER < n_iterations) {
            auto store = store_iteration_2<0>(query_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * bytes_float,
                                              valid_item_seq_len * n_group_size * bytes_float / 32 - 1,
                                              store_ddr_offset.first,
                                              store_ddr_offset.second,
                                              (valid_item_n_group) - 1,
                                              MASTER_PSUM_ADDR,
                                              (n_iter + cluster * CORE_PER_CLUSTER == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
            store.set_insn_number(0);
            store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER);
            insn_series.push_back(store);

            if (DEBUG) {
              print("======== Store Query Temp for cluster " + std::to_string(cluster) + " core 0 ========");
              print_hex("query_temp_ddr_addr", query_temp_ddr_addr + (cluster * CORE_PER_CLUSTER) * args.d_model * bytes_float);
              print_dec("seq_burst_0", valid_item_seq_len);
              print_hex("ddr_offset_0", args.seq_len * (n_group_size) * bytes_float);
              print_dec("seq_burst_1", (valid_item_n_group));
              print_hex("sram_addr", MASTER_PSUM_ADDR);
            }
          }
          if (CORE_PER_CLUSTER == 2){
            if (n_iter + cluster * CORE_PER_CLUSTER + 1 < n_iterations) {
              auto store = store_iteration_2<1>(query_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 2,
                                                valid_item_seq_len - 1,
                                                store_ddr_offset.first,
                                                store_ddr_offset.second,
                                                (valid_item_n_group * n_group_scale) - 1,
                                                MASTER_OFMAP_ADDR + 2048,
                                                (n_iter + cluster * CORE_PER_CLUSTER + 1 == n_iterations - 1) && (m_iter == m_iterations - 1) && all_done);
              store.set_insn_number(0);
              store.set_insn_opcode(9 + cluster * CORE_PER_CLUSTER + 1);
              insn_series.push_back(store);

              if (DEBUG) {
                print("======== Store Query Temp for cluster " + std::to_string(cluster) + " core 1 ========");
                print_hex("query_temp_ddr_addr", query_temp_ddr_addr + (cluster * CORE_PER_CLUSTER + 1) * args.d_model * 2);
                print_dec("seq_burst_0", valid_item_seq_len);
                print_hex("ddr_offset_0", valid_item_seq_len * (n_group_size / n_group_scale) * bytes_half);
                print_dec("seq_burst_1", (valid_item_n_group * n_group_scale));
                print_hex("sram_addr", MASTER_OFMAP_ADDR + 2048);
              }
            }            
          }
        }
      }
    }
  }

  /** q_rope_embedding
   * @input: (d_model/n_group_size, seq_len, n_group_size), fp32
   * @output: (d_model/k_group_size, seq_len, k_group_size), fp16
   * @process: RoPE Embedding; fp32 -> fp16; 并行度转换
   */
  void q_rope_embedding(std::vector<instruction>& insn_series, const Argument& args ,uint64_t all_done){
    /** RoPE Embedding */
    using RopeEmbeddingOpClass = transformer::rope_embedding::RopeEmbeddingOp<DEBUG>;
    RopeEmbeddingOpClass rope_embedding_op;

    uint64_t vcu_code_current_addr = args.vcu_code_base_addr + 12 * sizeof(uint64_t);
    // 配置参数
    typename RopeEmbeddingOpClass::Argument rope_args;
    rope_args.seq_len = args.seq_len;
    rope_args.dim = args.d_model;
    rope_args.input_base_addr = args.query_temp_base_addr;
    rope_args.freq_cls_base_addr = args.freq_cls_base_addr;
    rope_args.output_base_addr = args.query_temp_base_addr;
    rope_args.vcu_code_base_addr = vcu_code_current_addr; // addr 12
    rope_args.all_done = all_done;

    auto rope_pack = rope_embedding_op(rope_args);
    insn_series.insert(insn_series.end(), rope_pack.first.begin(), rope_pack.first.end());
    vcu_code_current_addr = args.vcu_code_base_addr + 20 * sizeof(uint64_t); // addr 20

    int oc_groups = args.d_model / n_group_size;
    /** set tile_m to fully utilize the psum and ofamp sram */  // 后面再做进一步深度逻辑处理，先用ofmap depth作为限制以免并行度转换出错
    int tile_m = std::min(std::min(MAX_OFMAP_DEPTH / 2, MAX_PSUM_DEPTH), args.seq_len);
    /** set block_oc_group to MAX_OFMAP_DEPTH / tile_m or oc_groups to fully utilize the psum sram */
    int block_oc_group = std::min(MAX_OFMAP_DEPTH / tile_m / 2, std::min(MAX_PSUM_DEPTH / tile_m, oc_groups));

    /** fp32, group_size = 32 -> fp16, group_size = 16 */
    using vcu_convert_t = vcu::operation::SingleVCUOp<DEBUG>;
    vcu_convert_t vcu_convert;
    typename vcu_convert_t::Argument vcu_convert_args = {
        .seq_len = args.seq_len,
        .d_model = args.d_model,
        .tile_m = tile_m,
        .block_oc_group = block_oc_group,
        .dtype = kFloat32,
        .op_type = vcu::operation::OP_TYPE::CONVERT,
        .input1_base_addr = args.query_temp_base_addr,
        .output_base_addr = args.value_temp_base_addr,  // Address Reuse, query_hf -> value_temp
        .vcu_code_addr = vcu_code_current_addr,
        .all_done = all_done
    };
    auto vcu_convert_pack = vcu_convert(vcu_convert_args);
    insn_series.insert(insn_series.end(), vcu_convert_pack.first.begin(), vcu_convert_pack.first.end());
  }

  /** k_rope_embedding_and_transform
   * @input: (d_model/n_group_size, seq_len, n_group_size), fp32
   * @output: (head_num, seq_len/n_group_size, d_h/k_group_size, n_group_size, k_group_size), fp16
   * @process: RoPE Embedding; fp32 -> fp16; 并行度转换
   *            reshape to (head_num, seq_len/n_group_size, d_h/k_group_size, n_group_size, k_group_size)
   */
  void k_rope_embedding_and_transform(std::vector<instruction>& insn_series, const Argument& args ,int all_done){
    /** --------------------RoPE Embedding-------------------- */
    using RopeEmbeddingOpClass = transformer::rope_embedding::RopeEmbeddingOp<DEBUG>;
    RopeEmbeddingOpClass rope_embedding_op;

    uint64_t vcu_code_current_addr = args.vcu_code_base_addr + 12 * sizeof(uint64_t);
    // 配置参数
    typename RopeEmbeddingOpClass::Argument rope_args;
    rope_args.seq_len = args.seq_len;
    rope_args.dim = args.d_model;
    rope_args.input_base_addr = args.key_temp_base_addr;
    rope_args.freq_cls_base_addr = args.freq_cls_base_addr;
    rope_args.output_base_addr = args.key_temp_base_addr;
    rope_args.vcu_code_base_addr = vcu_code_current_addr; // addr 12
    rope_args.all_done = all_done;

    auto rope_pack = rope_embedding_op(rope_args);
    insn_series.insert(insn_series.end(), rope_pack.first.begin(), rope_pack.first.end());
    vcu_code_current_addr = args.vcu_code_base_addr + 20 * sizeof(uint64_t); // addr 20

    /** --------------fp32, group_size = 32 -> fp16, group_size = 16 -------------*/
    
    int n_group = args.d_model / n_group_size;
    int bytes_input = bytes_float;
    int bytes_output = bytes_half;

    /** compute iterations */
    int tile_m = std::min(32, args.seq_len);
    // [mark] use ofmap depth to limit the block_n_group to avoid parallelism conversion error
    int block_n_group = std::min(MAX_OFMAP_DEPTH / tile_m / 2, std::min(MAX_PSUM_DEPTH / tile_m, n_group));   
    // int block_n_group = 4;
    int m_iterations = std::ceil((double)args.seq_len / (double)tile_m);
    int n_iterations = std::ceil((double)n_group / (double)block_n_group);

    /** Split head parameters */
    int d_h = args.d_model / args.head_num;
    int k_group_per_d_h = d_h / k_group_size;
    int block_k_group =  block_n_group * n_group_scale; 
    int block_group_split_head_num = block_k_group / k_group_per_d_h; 
    assert (block_group_split_head_num > 0 && "block_group_split_head_num should be greater than 0");
    
    if (DEBUG) {
      print("======== K RoPE and Transform Setting ========");
      print_dec("tile_m", tile_m);
      print_dec("block_n_group", block_n_group);
      print_dec("m_iterations", m_iterations);
      print_dec("n_iterations", n_iterations);
      print_dec("d_h", d_h);
      print_dec("k_group_per_d_h", k_group_per_d_h);
      print_dec("block_k_group", block_k_group);
      print_dec("block_group_split_head_num", block_group_split_head_num);
    }

    for (int n_iter = 0; n_iter < n_iterations; n_iter++) {
      for (int m_iter = 0; m_iter < m_iterations; m_iter++) { 
        /** compute valid item */
        uint64_t valid_item_seq_len = (m_iter * tile_m + tile_m) <= args.seq_len ? 
                                     tile_m : args.seq_len - m_iter * tile_m;
        uint64_t valid_item_n_group = (n_iter * block_n_group + block_n_group) <= n_group ? 
                                      block_n_group : n_group - n_iter * block_n_group;

        if (DEBUG) {
          print("======== K RoPE and Transform Iteration ========");
          print_dec("n_iter", n_iter);
          print_dec("m_iter", m_iter);
          print_dec("valid_item_seq_len", valid_item_seq_len);
          print_dec("valid_item_n_group", valid_item_n_group);
        }
        
        /** compute input address offset */
        uint64_t input_ddr_addr = (n_iter * block_n_group) * args.seq_len * n_group_size * bytes_input
                                  + m_iter * valid_item_seq_len * n_group_size * bytes_input + args.key_temp_base_addr;
        auto input_ddr_offset = split_exp_fra(args.seq_len * n_group_size * bytes_input);
        
        /** load input */
        auto load_input = load_iteration_2<0>(input_ddr_addr,
                                              valid_item_seq_len * n_group_size * bytes_input / 32 - 1,
                                              input_ddr_offset.first,
                                              input_ddr_offset.second,
                                              valid_item_n_group - 1,
                                              MASTER_PSUM_ADDR, 0);
        insn_series.push_back(load_input);
                
        /** execute vcu for fp32 to fp16 conversion */
        auto vcu = vcu_execute(vcu_psum_dtype[kFloat32],
                              vcu_resadd_dtype[kHalf],
                              vcu_out_dtype[kHalf],
                              0,
                              1,
                              20,  // addr 20
                              0,
                              0,
                              0,
                              0,
                              valid_item_seq_len - 1,
                              valid_item_n_group - 1,
                              0,
                              1,
                              0,
                              0,
                              0);
        vcu.set_insn_number(0);
        vcu.set_insn_opcode(25);
        insn_series.push_back(vcu);

        auto vcu_convert = vcu_parallelism_conversion(0, 0, 0, valid_item_seq_len, valid_item_n_group, valid_item_n_group * 2);
        vcu_convert.set_insn_number(0);
        vcu_convert.set_insn_opcode(25);
        insn_series.push_back(vcu_convert);

        /** -------------------Store with head splitting like k_transform------------------- */
        for (int block_head_iter = 0; block_head_iter < block_group_split_head_num; block_head_iter++) {
          int head_number = n_iter * block_group_split_head_num + block_head_iter;
          
          /** Compute offset, the key need to be stored as [head_num, seq_len/n_group_size, d_h/k_group_size, n_group_size, k_group_size] */
          uint64_t key_temp_ddr_addr = (head_number * args.seq_len * d_h + 
                                        m_iter * k_group_per_d_h * n_group_size * k_group_size) * bytes_half
                                       + args.query_temp_base_addr;  // Address Reuse, key_hf -> query_temp
          auto key_temp_offset_0 = split_exp_fra(n_group_size * k_group_size * bytes_half);

          auto store = store_iteration_2<0>(key_temp_ddr_addr,
                                           n_group_size - 1,
                                           key_temp_offset_0.first,
                                           key_temp_offset_0.second,
                                           k_group_per_d_h - 1,
                                           MASTER_OFMAP_ADDR + block_head_iter * k_group_per_d_h * valid_item_seq_len,
                                           block_head_iter == block_group_split_head_num - 1 && n_iter == n_iterations - 1
                                             && m_iter == m_iterations - 1 && all_done);
          store.set_insn_number(0);
          insn_series.push_back(store);

          if (DEBUG) {
            print("======== Store Key Temp after RoPE and Transform ========");
            print_hex("key_temp_ddr_addr", key_temp_ddr_addr);
            print_dec("seq_burst_0", n_group_size - 1);
            print_hex("ddr_offset_0", n_group_size * k_group_size * bytes_half);
            print_dec("seq_burst_1", k_group_per_d_h - 1);
            print_dec("head_number", head_number);
            print_hex("sram_addr", MASTER_OFMAP_ADDR + block_head_iter * k_group_per_d_h * valid_item_n_group);
          }
        }
      }
    }
  }
  
  /** Causal Mask*/
  /** @input: (head_num, seq_len/n_group_size, seq_len, n_group_size), fp32
   * @mask: (head_num, seq_len/n_group_size, seq_len, n_group_size), fp32
   * @output: (head_num, seq_len/n_group_size, seq_len, n_group_size), fp32
   */
  void causal_mask(std::vector<instruction>& insn_series, const Argument& args, uint64_t all_done)
  {
    /** set tile_m to MAX_PSUM_DEPTH or args.seq_len to fully utilize the psum sram */
    int tile_m = std::min(MAX_PSUM_DEPTH, args.seq_len);
    /** set block_oc_group to MAX_PSUM_DEPTH / tile_m or args.seq_len / n_group_size to fully utilize the psum sram */
    int block_oc_group = std::min(MAX_PSUM_DEPTH / tile_m, args.seq_len / n_group_size);

    uint64_t vcu_code_current_addr = args.vcu_code_base_addr + 24 * sizeof(uint64_t); // addr 24
    using add_mask_t = vcu::operation::SingleVCUOp<DEBUG>;
    add_mask_t add_mask_op;

    for (int head = 0; head < args.head_num; head++) {
      /** Configure the arguments for the ADD operation */
      uint64_t current_mask_ddr_addr = head * args.seq_len * args.seq_len * bytes_float + args.mask_base_addr;
      uint64_t current_score_temp_ddr_addr = head * args.seq_len * args.seq_len * bytes_float + args.score_temp_base_addr;

      typename add_mask_t::Argument add_mask_args = {
        .seq_len = args.seq_len,
        .d_model = args.seq_len,
        .tile_m = tile_m,
        .block_oc_group = block_oc_group,
        .dtype = kFloat32,
        .op_type = vcu::operation::OP_TYPE::ADD,
        .input1_base_addr = current_score_temp_ddr_addr,
        .input2_base_addr = current_mask_ddr_addr,
        .output_base_addr = current_score_temp_ddr_addr,
        .vcu_code_addr = vcu_code_current_addr, // VCU code for ADD
        .all_done = (head == args.head_num - 1) && all_done
      };
      auto add_mask_pack = add_mask_op(add_mask_args);
      insn_series.insert(insn_series.end(), add_mask_pack.first.begin(), add_mask_pack.first.end());
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