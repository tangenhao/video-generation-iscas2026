#pragma once

#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <vector>

#include "addr_for_stdit.h"
#include "common/cfg.h"
#include "common/file_utils.h"
#include "common/insn.h"
#include "common/read_cfg.h"

#include "common/type_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include <string>

namespace stdit {
namespace quant {

using namespace common;

template<bool READ_FROM_IFMAP_SRAM_          = false,
         bool DEBUG_                         = false>
struct insn_gen {
  static constexpr bool READ_FROM_IFMAP_SRAM = READ_FROM_IFMAP_SRAM_;
  static constexpr int  DEBUG                = DEBUG_;

  int k_group_size;
  int n_group_size;
  
  float bytes_ifmap;
  float bytes_weight;
  float bytes_ofmap;


  struct Arguments {
    int      m;
    int      n;
    int      k;
    int      tile_m;
    int      block_n_group;
    int      block_k_group;
    uint64_t ifmap_base_addr;
    uint64_t weight_base_addr;
    uint64_t ofmap_base_addr;
    uint64_t opcode_ddr_base_addr ;
    uint64_t ifmap_scale_base_addr   ;
    uint64_t weight_scale_base_addr  ;
    uint64_t bias_base_addr ;
    uint64_t resmul_base_addr ;
    uint64_t resadd_base_addr ;
    int      subvec_size    ;
    int      num_cc         ;
    int      ff_enable      ;
    bool     weight_uram_overflow;
    bool     act_overflow   ;
    bool     mem_l2_act_type; //0:int4 1:fp16
    //vcu
    uint64_t rank = 32  ;
    vcu::VcuConfig::Arguments vcu_cfg_args;

    uint64_t outlier_index_base_addr = 0;
    uint64_t ifmap_mask_base_addr    = 0;
    uint64_t all_done                = 0;
    
  };

  insn_gen()
  {
    
    k_group_size = 32;
    n_group_size = 32;
    bytes_ifmap  = 2;
    bytes_weight = 1;
    bytes_ofmap  = 2;
    
  }

  std::pair<std::vector<insn::instruction>, std::vector<uint64_t>> operator()(const Arguments& args)
  {
    std::vector<insn::instruction> instruction_series;
    std::vector<uint64_t> vcucode_series;  // 声明在循环外部

    int subvec = args.subvec_size;
    int num_cc = args.num_cc;
    int kg_eff = n_group_size / subvec;  // effective subcodebooks per 32-K group
    float eff_bytes_cbpp = bytes_cbpp * subvec;
    float eff_bytes_cbw  = bytes_cbw * subvec;
    int64_t hop_cbpp     = int64_t(eff_bytes_cbpp * num_cc);
    int64_t hop_cbw      = int64_t(eff_bytes_cbw  * num_cc);

    int m_iterations = ceil((double)args.m / (double)args.tile_m);
    int n_group      = ceil((double)args.n / (double)n_group_size);
    int k_group      = ceil((double)args.k / (double)(k_group_size));
    int ff_enable    = args.ff_enable;
    bool weight_uram_overflow = args.weight_uram_overflow;
    bool act_overflow = args.act_overflow;
    bool mem_l2_act_type = args.mem_l2_act_type;

    if (DEBUG) {
      std::cout << "m_iterations: " << m_iterations << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
      std::cout << "subvec_size: " << subvec << std::endl;
      std::cout << "kg_eff (per 32-K): " << kg_eff << std::endl;
    }

    int64_t m_start;
    int64_t m_start_ifmap;
    int64_t i_ic, k_oc, k_ic;
    uint64_t sw_front = 0;
    uint64_t vcu_work_en = 0;
    uint64_t sw_back  = 0;

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                opcode gen                                                */
  /* -------------------------------------------------------------------------------------------------------- */
  // 1. quant_1: abs->redmax, ascale=mulc(max*(1/127),reg1), mul(ascale*wscale) -> scale(pea)
  // 2. rec(ascale,reg1)->mul(psum(x_fp)*reg1, x*ascale)->clamp->round->qact(pea)
  auto vcucode_series = vcu::asm_vcu_op({
    "absm ifmap, reg0",       // num_data_cnt=dim//32, write to psum0
    "redmax psum, reg0, 32",  // num_data_cnt=dim//32, write to reg0

    "mulc reg0, reg0, 0x2008" // num_data_cnt=1-1, write to reg0 (reg0=ascale)
    "rec reg0, reg2",         // num_data_cnt=1-1, write to reg2 (reg2=1/ascale)

    "mul reg0 para, reg1",    // num_data_cnt=dim_weight//32, write to scale (最低16bits为ascale*wscale)

    "mul ifmap, reg2, reg0", // num_data_cnt=dim//32, write to qact, data_out为int8； （round和clamp在data_out_convert.v中进行）
  });

  auto   num_vcucodes      = vcucode_series.size();
  size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
  size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
  vcucode_series.resize(vcucode_ddr_lines * 8, 0);

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  instruction_series.push_back(insn::load_iteration_2<0>(opcode_ddr_base_addr, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                vcu_insn gen                                              */
  /* -------------------------------------------------------------------------------------------------------- */
  
    int ifmap_ddr_offset, weight_ddr_offset, ofmap_ddr_offset;
    int ifmap_scale_ddr_offset, weight_scale_ddr_offset;
    int lowrank_1_ddr_offset, lowrank_2_ddr_offset;
    int bias_ddr_offset, resmul_ddr_offset, resadd_ddr_offset;
    int block_lowrank_2_group;
    int n_iterations = ceil((double)n_group / (double)args.block_n_group);
    int k_iterations = ceil((double)k_group / (double)args.block_k_group);

    if (READ_FROM_IFMAP_SRAM) {
      instruction_series.push_back(LoadIfmap(args.ifmap_base_addr, k_group_size, bytes_ifmap, args.block_k_group, k_iterations));
      
    }


    for (int m_iter = 0; m_iter < m_iterations; ++m_iter) {
      for (int n_iter = 0; n_iter < n_iterations; ++n_iter) {
        for (int k_iter = 0; k_iter < k_iterations; ++k_iter) {





          
          m_start = m_iter * args.tile_m;
          k_oc    = std::min(n_group - (n_iter * args.block_n_group), args.block_n_group);
          i_ic = std::min(k_group - (k_iter * args.block_k_group), args.block_k_group);
          k_ic = std::min((k_group - (k_iter * args.block_k_group)) * 2, args.block_k_group * 2);

          if (m_iter>0) {
            m_start_ifmap = (m_iter+1) * args.tile_m ; 
          }
          else {
            m_start_ifmap = m_iter * args.tile_m ;
          }

          ifmap_ddr_offset = int64_t((bytes_ifmap * k_group_size * args.tile_m * 4 * k_iter) + (m_start_ifmap * bytes_ifmap * k_group_size * k_group));
 
          ifmap_scale_ddr_offset   = int64_t((m_start) * 32);

          weight_ddr_offset = int64_t(bytes_weight * (n_group_size/subvec) * (k_group_size)
                                      * k_group * (n_iter * args.block_n_group)
                                         + ((k_iter * args.block_k_group) * bytes_weight * (n_group_size/subvec) * (k_group_size)*2  ));

          weight_scale_ddr_offset = int64_t(n_group_size * 32 * n_iter);
          // ofmap_ddr_offset        = int64_t(bytes_ofmap * n_group_size * (args.m * (n_iter) + m_start));
          ofmap_ddr_offset        = int64_t((bytes_ofmap * k_group_size * args.tile_m * n_iter) + (m_start * bytes_ofmap * k_group_size * k_group));

          //vcu
          lowrank_1_ddr_offset = int64_t(bytes_lowrank * k_group_size * rank * k_iter * 4);
          lowrank_2_ddr_offset = int64_t(bytes_lowrank * n_group_size * rank * n_iter * 4);
          bias_ddr_offset = int64_t(bytes_bias * n_group_size * n_iter * 4);
          resmul_ddr_offset = int64_t((bytes_resmul * n_group_size * args.tile_m * n_iter * 4) + (m_start * bytes_resmul * n_group_size * n_group));
          resadd_ddr_offset = int64_t((bytes_resadd * n_group_size * args.tile_m * n_iter * 4) + (m_start * bytes_resadd * n_group_size * n_group));

          //start:同步字
          
          if (n_iter == 0 && k_iter == 0) {
            sw_front = ((uint64_t)1u << 0) | ((uint64_t)1u << 16) | ((uint64_t)1u << 24); //load_0 + pea_0 + vcu_0 (actually all pea + vcu)
            instruction_series.push_back(insn::synchronize_indie(1, 0, 0, sw_front, 0, 0));
          }

          // if ((m_iter == m_iterations-1 ) && n_iter == 0 && k_iter == 0) {
          //   sw_front = ((uint64_t)1u << 0) | (uint64_t)1u << 16) | ((uint64_t)1u << 24); //pea_0 + vcu_0   (actually all pea + vcu)
          //   instruction_series.push_back(insn::synchronize_indie(1, 0, 0, sw_front, 0, 0));
          // }
          
          if (k_iter == k_iterations - 1) {
            sw_back = ((uint64_t)1u << 8); //store_0 (actually all output-sram)
            instruction_series.push_back(insn::synchronize_indie(1, 0, 0, sw_back, 0, 0));
          }
          //end:同步字

          // load ifmap once per (m_iter, k_iter), reuse across all n_iter
          int all_done_ifmap = 0;

          // if ((subvec == 2 && ff_enable == 1) == false ){
          //   if ((m_iter > 1) && n_iter == 0 && k_iter == k_iterations/4 - 1) {
          //     all_done_ifmap = 1;
          //   }
          // }

          if (n_iter == 0) {

            if (TYPE_ACCUMULATOR == (kHalf) && k_iter < (k_iterations/32 + 1)) {
              instruction_series.push_back(LoadIfmapScale(args.ifmap_scale_base_addr + ifmap_scale_ddr_offset, args.tile_m, 0));
            }

            //第一次读两行，后面读一行
            if (m_iter == 0 && k_iter < (k_iterations/2)) {
              instruction_series.push_back(LoadIfmap(args.ifmap_base_addr + ifmap_ddr_offset, k_group, args.m, i_ic, args.tile_m, MASTER_IFMAP_ADDR, 0));
            }
            // if ((m_iter > 1) && k_iter < (k_iterations/4)) {
            if ((m_iter > 0 && m_iter < m_iterations - 1) && k_iter < (k_iterations/4)) {
              instruction_series.push_back(LoadIfmap(args.ifmap_base_addr + ifmap_ddr_offset, k_group, args.m, i_ic, args.tile_m, MASTER_IFMAP_ADDR, all_done_ifmap));
            }
          }

          

            auto   num_vcucodes      = vcucode_series.size();
            size_t vcucode_bytes     = vcucode_series.size() * sizeof(uint64_t);
            size_t vcucode_ddr_lines = (vcucode_bytes + 31) / 32;
            vcucode_series.resize(vcucode_ddr_lines * 8, 0);

            if (DEBUG) {
              std::cout << "num_vcucodes: " << num_vcucodes << std::endl;
              std::cout << "vcucode_bytes: " << vcucode_bytes << std::endl;
              std::cout << "vcucode_ddr_lines: " << vcucode_ddr_lines << std::endl;
            }
            instruction_series.push_back(insn::load_iteration_2(VCUCODE_ADDR, vcucode_ddr_lines - 1, 0, 0, 0, MASTER_VCUCODE_ADDR, 0));
          }

          // load weight scale
          // For per vector scale quantization (per n_iter)
          if (TYPE_ACCUMULATOR == (kHalf) && m_iter == 0 && k_iter == 0 && n_iter < (n_iterations/16)) {
            instruction_series.push_back(
              LoadWeightScale(args.weight_scale_base_addr + weight_scale_ddr_offset, n_group, k_group, k_oc, n_group_size));
          }

          //load lowrank matrices
          if ( m_iter == 0 && n_iter == 0 && k_iter < (k_iterations/4)) {
            int lowrank_1_seq_0_burst = int64_t((bytes_lowrank * k_group_size * rank * 4) / 32);
            instruction_series.push_back(LoadLowrank(args.lowrank_1_base_addr + lowrank_1_ddr_offset, lowrank_1_seq_0_burst, k_group, k_oc, 1, MASTER_LOWRANK_1_ADDR, 0));
          }
          
          if ( m_iter == 0 && k_iter == k_iterations - 1 && n_iter < (n_iterations/4)) {
            int lowrank_2_seq_0_burst = int64_t((bytes_lowrank * n_group_size * rank * 4) / 32);
            instruction_series.push_back(LoadLowrank(args.lowrank_2_base_addr + lowrank_2_ddr_offset, lowrank_2_seq_0_burst, n_group, k_oc, 2, MASTER_LOWRANK_2_ADDR, 0));
          }

          // load cbpp and cbw once per (m_iter, n_iter), reuse across all k_iter
          if ( m_iter == 0 && n_iter == 0 && k_iter < (k_iterations/2)) {
            int subcb_cnt = kg_eff * 2 * i_ic;  // per k_iter, transfer kg_eff subcodebooks; scale with block_k_group if >1
            int64_t cbpp_ddr_offset = hop_cbpp * kg_eff * 2 * (k_iter * args.block_k_group) ;
            int64_t cbw_ddr_offset  = hop_cbw  * kg_eff * 2 * (k_iter * args.block_k_group) ;
            int64_t cbw_seq_0_burst = hop_cbw / 32;
            int64_t cbpp_seq_0_burst = hop_cbpp / 32;

            instruction_series.push_back(LoadCbW (args.cbw_base_addr  + cbw_ddr_offset,  hop_cbw,  subcb_cnt, cbw_seq_0_burst));
            instruction_series.push_back(LoadCbPP(args.cbpp_base_addr + cbpp_ddr_offset, hop_cbpp, subcb_cnt, cbpp_seq_0_burst));
            
          }

          // if ( m_iter == 0 && k_iter==0 && n_iter < (n_iterations/2) ) {
          //   int subcb_cnt = kg_eff * 2;  
          //   int64_t cbpp_ddr_offset = (hop_cbpp * subcb_cnt * n_iter);
          //   int64_t cbw_ddr_offset  = (hop_cbw  * subcb_cnt * n_iter);
          //   int64_t cbw_seq_0_burst = hop_cbw / 32;
          //   int64_t cbpp_seq_0_burst = hop_cbpp / 32;

          //   instruction_series.push_back(LoadCbW (args.cbw_base_addr  + cbw_ddr_offset,  hop_cbw,  subcb_cnt, cbw_seq_0_burst));
          //   instruction_series.push_back(LoadCbPP(args.cbpp_base_addr + cbpp_ddr_offset, hop_cbpp, subcb_cnt, cbpp_seq_0_burst));
            
          // }

          // load weight:
          // 1. ff and subvector == 2
          // 2. non(ff and subvector == 2) : load weight once per (m_iter), reuse across all m_iter
          int all_done_weight = 0;

          if (subvec == 2 && ff_enable == 1) {
            // int real_weight_k_group = (args.k / subvec) / k_group_size;
            if (k_iter == k_iterations/2 - 1 && n_iter == n_iterations - 1) {
              all_done_weight = 1;
            }
            if (k_iter < k_iterations/2 ) {
              instruction_series.push_back(LoadWeight(args.weight_base_addr + weight_ddr_offset, n_group, k_group, k_oc, 1, all_done_weight));
            }
          }
          else {
            if (m_iter == 0) {
              if (k_iter == k_iterations/2 - 1 && n_iter == n_iterations - 1) {
                all_done_weight = 1;
              }
              // int real_weight_k_group = (args.k / subvec) / k_group_size;
              if (k_iter < k_iterations/2 ) {
                instruction_series.push_back(LoadWeight(args.weight_base_addr + weight_ddr_offset, n_group, k_group, k_oc, 1, all_done_weight));
              }
            }
          }

          //load bias, resmul,resadd
          int all_done_resadd = 0;

          if ((subvec == 2 && ff_enable == 1) == false ){
            if ((m_iter >= 1) && k_iter == 0 && n_iter == n_iterations/4 - 1) {
              all_done_resadd = 1;
            }
          }

          if (k_iter == 0) {
            // load bias
            if (TYPE_ACCUMULATOR == (kHalf) && m_iter == 0 && n_iter < (n_iterations/4)) {
              int bias_seq_0_burst = int64_t((bytes_bias * n_group_size * 4) / 32);
              instruction_series.push_back(LoadBias(args.bias_base_addr + bias_ddr_offset, bias_seq_0_burst, 0, 0, 0, 0));
            }

            // load resmul, resadd
            if (n_iter < (n_iterations/4)) {
              // load resmul
              int resmul_seq_0_burst = int64_t((bytes_resmul * n_group_size * args.tile_m * 4) / 32);
              instruction_series.push_back(LoadResMul(args.resmul_base_addr + resmul_ddr_offset, resmul_seq_0_burst, k_group, args.m, i_ic, MASTER_VCUPARA_ADDR, 0));

              // load resadd
              int resadd_seq_0_burst = int64_t((bytes_resadd * n_group_size * args.tile_m * 4) / 32);
              instruction_series.push_back(LoadResAdd(args.resadd_base_addr + resadd_ddr_offset, resadd_seq_0_burst, k_group, args.m, i_ic, MASTER_VCUPARA_ADDR, all_done_resadd));
            }
          }
          
          //只写一次，此后一直复用
          if(m_iter == 0 && k_iter == 0 && n_iter == 0)
          {
            int psum_number = i_ic * k_oc * 2;
            instruction_series.push_back(insn::gemm_execute(TYPE_A,
                                                            TYPE_B,
                                                            TYPE_ACCUMULATOR - 5,
                                                            TYPE_OUTPUT - 5,
                                                            m_iterations,
                                                            k_oc - 1,
                                                            k_ic - 1,
                                                            0,
                                                            0,
                                                            0,
                                                            psum_number - 1,
                                                            k_iter != 0,
                                                            subvec,
                                                            kg_eff*n_group,
                                                            n_group,
                                                            k_group,
                                                            weight_uram_overflow,
                                                            act_overflow,
                                                            mem_l2_act_type));

          }

          //vcu lowrank mm insn
          using vcu_cfg_t = vcu::VcuConfig;
          vcu_cfg_t vcu_cfg;
          
          using vcu_t = vcu::VcuExecute;
          vcu_t vcu_op;

          //temp = qact * ascales * lr_1
          if (n_iter == 0)
          {
            if (m_iter == 0 && k_iter == 0)
            {
              auto vcu_cfg_insns = vcu_cfg(args.vcu_cfg_args);
              instruction_series.insert(instruction_series.end(), vcu_cfg_insns.begin(), vcu_cfg_insns.end());
            }
            
          /** ============ Step 0-0: dequant ============*/
            vcu_t::Arguments step_0_0_config_args  = {
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_resadd_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                 
              VcuOutSram::PSUM, 
              1,                      // opcode_number
              0,                      // opcode_addr
              0,                      // psum_in_addr
              0,                      // para_in_addr
              0,                      // resadd_in_addr
              0,                      // vcu_in_1_in_addr
              0,                      // ram_out_addr
              1-1,                    // num_data_cnt
              0,                      // oc_group
              0,                      // para_func_cnt
              0,                      // psum_sram_valid  
              0,                      // resadd_sram_valid
              0,                      // para_sram_valid  
              0,                      // lr_sram_valid  
              1,                      // in0_sram_valid 
              1,                      // in1_sram_valid 
              0,                      // psum_in1_addr_no_hop
              0,                      // sram_change_psum_flag
              0                       //all_done 
            };
            auto step_0_0_config_insns = vcu_op(step_0_0_config_args);
            instruction_series.insert(instruction_series.end(), step_0_0_config_insns.begin(), step_0_0_config_insns.end());

          /** ============ Step 0-1: mul ============*/
            vcu_t::Arguments step_0_1_config_args  = {
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_resadd_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                 
              VcuOutSram::PSUM, 
              1,                      // opcode_number
              1,                      // opcode_addr
              0,                      // psum_in_addr
              0,                      // para_in_addr
              0,                      // resadd_in_addr
              0,                      // vcu_in_1_in_addr
              0,                      // ram_out_addr
              (uint64_t)args.tile_m - 1,        // num_data_cnt
              0,                      // oc_group
              0,                      // para_func_cnt
              0,                      // psum_sram_valid  
              0,                      // resadd_sram_valid
              0,                      // para_sram_valid  
              1,                      // lr_sram_valid  
              0,                      // in0_sram_valid 
              0,                      // in1_sram_valid 
              0,                      // psum_in1_addr_no_hop
              0,                      // sram_change_psum_flag
              0                       //all_done 
            };
            auto step_0_1_config_insns = vcu_op(step_0_1_config_args);
            instruction_series.insert(instruction_series.end(), step_0_1_config_insns.begin(), step_0_1_config_insns.end());
          
          /** ============ Step 1: reducesum + add ============*/
          uint64_t psum_in1_addr_no_hop;

          if (k_iter == k_iterations - 1)
          {
            psum_in1_addr_no_hop = 1;
          }
          else
          {
            psum_in1_addr_no_hop = 0;
          }

          vcu_t::Arguments step_1_config_args  = {
            vcu_out_dtype.at(TYPE_ACCUMULATOR),                  
            vcu_resadd_dtype.at(TYPE_ACCUMULATOR),                  
            vcu_out_dtype.at(TYPE_ACCUMULATOR),                 
            VcuOutSram::IN1, 
            2,                      // opcode_number
            2,                      // opcode_addr
            0,                      // psum_in_addr
            0,                      // para_in_addr
            0,                      // resadd_in_addr
            0,                      // vcu_in_1_in_addr
            0,                      // ram_out_addr
            (uint64_t)args.tile_m - 1,        // num_data_cnt
            0,                      // oc_group
            0,                      // para_func_cnt
            1,                      // psum_sram_valid  
            0,                      // resadd_sram_valid
            0,                      // para_sram_valid  
            0,                      // lr_sram_valid  
            0,                      // in0_sram_valid 
            1,                      // in1_sram_valid 
            psum_in1_addr_no_hop,   // psum_in1_addr_no_hop 
            1,                      // sram_change_psum_flag 
            0,                       //all_done 
            0,                       //psum_addr_hop   
            1,                        //acc_clear       
            1                        //stream_reduce_en
          };
          auto step_1_config_insns = vcu_op(step_1_config_args);
          instruction_series.insert(instruction_series.end(), step_1_config_insns.begin(), step_1_config_insns.end());
          }
          
          //low_rank_out = qact * ascales * lr_1 * lr_2
          //pea_out + low_rank_out -> ofmap_sram
          if (k_iter == k_iterations - 1)
          {
            /** ============ Step 2: copy + mul ============*/

            if (n_iter == 0)
            {
              vcu_t::Arguments step_2_0_config_args  = {
                vcu_out_dtype.at(TYPE_ACCUMULATOR),                  
                vcu_resadd_dtype.at(TYPE_ACCUMULATOR),                  
                vcu_out_dtype.at(TYPE_ACCUMULATOR),                 
                VcuOutSram::PSUM, 
                1,                      // opcode_number
                4,                      // opcode_addr
                0,                      // psum_in_addr
                0,                      // para_in_addr
                0,                      // resadd_in_addr
                0,                      // vcu_in_1_in_addr
                0,                      // ram_out_addr
                1-1,                    // num_data_cnt
                0,                      // oc_group
                0,                      // para_func_cnt
                0,                      // psum_sram_valid  
                0,                      // resadd_sram_valid
                0,                      // para_sram_valid  
                0,                      // lr_sram_valid  
                0,                      // in0_sram_valid 
                1,                      // in1_sram_valid 
                1,                      // psum_in1_addr_no_hop
                1,                      // sram_change_psum_flag
                0                       //all_done 
              };
              auto step_2_0_config_insns = vcu_op(step_2_0_config_args);
              instruction_series.insert(instruction_series.end(), step_2_0_config_insns.begin(), step_2_0_config_insns.end());
            }
            
            //mul
            vcu_t::Arguments step_2_1_config_args  = {
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_resadd_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                 
              VcuOutSram::PSUM, 
              1,                      // opcode_number
              5,                      // opcode_addr
              0,                      // psum_in_addr
              0,                      // para_in_addr
              0,                      // resadd_in_addr
              0,                      // vcu_in_1_in_addr
              0,                      // ram_out_addr
              (uint64_t)args.tile_m - 1,        // num_data_cnt
              0,                      // oc_group
              0,                      // para_func_cnt
              0,                      // psum_sram_valid  
              0,                      // resadd_sram_valid
              0,                      // para_sram_valid  
              1,                      // lr_sram_valid  
              0,                      // in0_sram_valid 
              0,                      // in1_sram_valid 
              0,                      // psum_in1_addr_no_hop   vcu_offset=1,copy指令读取串转并后的数据
              0,                      // sram_change_psum_flag  
              0                       //all_done 
            };
            auto step_2_1_config_insns = vcu_op(step_2_1_config_args);
            instruction_series.insert(instruction_series.end(), step_2_1_config_insns.begin(), step_2_1_config_insns.end());

            /** ============ Step 4: reducesum ============*/
            vcu_t::Arguments step_3_config_args  = {
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_resadd_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                 
              VcuOutSram::IN1, 
              1,                      // opcode_number
              6,                      // opcode_addr
              0,                      // psum_in_addr
              0,                      // para_in_addr
              0,                      // resadd_in_addr
              0,                      // vcu_in_1_in_addr
              256,                    // ram_out_addr
              (uint64_t)args.tile_m - 1,        // num_data_cnt
              0,                      // oc_group
              0,                      // para_func_cnt
              1,                      // psum_sram_valid  
              0,                      // resadd_sram_valid
              0,                      // para_sram_valid  
              0,                      // lr_sram_valid  
              0,                      // in0_sram_valid 
              0,                      // in1_sram_valid 
              1,                      // psum_in1_addr_no_hop  
              1,                      // sram_change_psum_flag  
              0                       //all_done 
            };
            auto step_3_config_insns = vcu_op(step_3_config_args);
            instruction_series.insert(instruction_series.end(), step_3_config_insns.begin(), step_3_config_insns.end());
            
            //pea_out + low_rank_out -> ofmap_sram
            /** ============ Step 5: add ============*/
            uint64_t vcu_all_done;

            if (n_iter == n_iterations - 1 && k_iter == k_iterations - 1)
            {
              vcu_all_done = 1;
            }
            else
            {
              vcu_all_done = 0;
            }
            
            vcu_t::Arguments step_4_config_args  = {
              1,     //psum_data_type: 0->VCU_PSUM; 1->VCU_PEA; 2->write to mem_l1_pe
              vcu_resadd_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                 
              VcuOutSram::PSUM, 
              3,                      // opcode_number
              7,                      // opcode_addr
              (uint64_t)n_iter,       // psum_in_addr
              (uint64_t)(n_iter%256) + 256, // para_in_addr (resmul: in vcupara sram addr[256-512])
              (uint64_t)(n_iter%256),       // resadd_in_addr (bias: in vcuresadd sram addr[0-255])
              256,                    // vcu_in_1_in_addr
              0,                      // ram_out_addr
              1 - 1,                  // num_data_cnt
              0,                      // oc_group
              0,                      // para_func_cnt
              1,                      // psum_sram_valid  
              1,                      // resadd_sram_valid
              1,                      // para_sram_valid  
              0,                      // lr_sram_valid  
              0,                      // in0_sram_valid 
              1,                      // in1_sram_valid 
              1,                      // psum_in1_addr_no_hop  
              1,                      // sram_change_psum_flag  
              0                       //all_done 
            };
            auto step_4_config_insns = vcu_op(step_4_config_args);
            instruction_series.insert(instruction_series.end(), step_4_config_insns.begin(), step_4_config_insns.end());

            vcu_t::Arguments step_5_config_args  = {
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_resadd_dtype.at(TYPE_ACCUMULATOR),                  
              vcu_out_dtype.at(TYPE_ACCUMULATOR),                 
              VcuOutSram::OFMAP, 
              1,                      // opcode_number
              10,                      // opcode_addr
              0,                      // psum_in_addr
              0,                                  // para_in_addr 
              (uint64_t)(n_iter%256) + 256,       // resadd_in_addr (resadd: in vcuresadd sram addr[256-511])
              0,                                  // vcu_in_1_in_addr
              (uint64_t)n_iter,                   // ram_out_addr
              1 - 1,                  // num_data_cnt
              0,                      // oc_group
              0,                      // para_func_cnt
              1,                      // psum_sram_valid  
              1,                      // resadd_sram_valid
              0,                      // para_sram_valid  
              0,                      // lr_sram_valid  
              0,                      // in0_sram_valid 
              0,                      // in1_sram_valid 
              0,                      // psum_in1_addr_no_hop  
              0,                      // sram_change_psum_flag  
              vcu_all_done            //all_done 
            };
            auto step_5_config_insns = vcu_op(step_5_config_args);
            instruction_series.insert(instruction_series.end(), step_5_config_insns.begin(), step_5_config_insns.end());
            
          }

          int store_all_done=1;

          // if (n_iter == n_iterations - 1 && k_iter == k_iterations - 1)
          // {
          //   store_all_done = 1;
          // }
          // else
          // {
          //   store_all_done = 0;
          // }
          
          // store only when a full ofmap tile is ready (i.e., at the last k_iter)
          if (k_iter == k_iterations - 1) {
            instruction_series.push_back(Store(args.ofmap_base_addr + ofmap_ddr_offset,
                                               n_group,
                                               args.m,
                                               args.block_n_group,
                                               args.tile_m,
                                               store_all_done));
          }
          
        }
        if (DEBUG) {
          std::cout << "m_iter: " << m_iter << " m_iterations: " << m_iterations << std::endl;
          std::cout << "n_iter: " << n_iter << " n_iterations: " << n_iterations << std::endl;
        }
        
      }
    }

    return std::make_pair(instruction_series, vcucode_series);
  }

  private:
  insn::instruction LoadIfmap(int64_t ddr_base_addr, int64_t k_group_size, int64_t bytes_ifmap, int64_t block_k_group, int64_t k_group)
  {
    auto seq_1_offset = split_exp_fra(block_k_group * k_group_size * bytes_ifmap);
    
    if (DEBUG) {
      std::cout << "======== Load Ifmap ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "m: " << m << std::endl;
      std::cout << "tile_m: " << tile_m << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << tile_m*2 << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_k_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    return insn::load_iteration_2<0>(ddr_base_addr, block_k_group * bytes_ifmap * k_group_size / 32 - 1, seq_1_offset.first, seq_1_offset.second, k_group - 1, MASTER_IFMAP_ADDR, 0);
  }

  insn::instruction LoadWeight(int64_t ddr_base_addr, int n_group, int k_group, int block_n_group, int block_k_group, int all_done_weight)
  {
    // (n_group, k_group, 32, 32)
    auto seq_1_offset = split_exp_fra(bytes_weight * k_group_size * n_group_size);
    auto seq_2_offset = split_exp_fra(bytes_weight * k_group_size * n_group_size * k_group);

    if (DEBUG) {
      std::cout << "======== Load Weight ========" << std::endl;
      std::cout << std::hex << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "k_group: " << k_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << n_group_size << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_k_group << std::endl;
      std::cout << "seq_2_hop_exp: " << seq_2_offset.first << std::endl;
      std::cout << "seq_2_hop_fra: " << seq_2_offset.second << std::endl;
      std::cout << "seq_2_burst: " << block_n_group << std::endl;
      std::cout << "all_done_weight: " << all_done_weight << std::endl;
      std::cout << "==========================" << std::endl;
    }
    return insn::load_iteration_3<1>(ddr_base_addr,
                                     n_group_size - 1,
                                     seq_1_offset.first,
                                     seq_1_offset.second,
                                     block_k_group - 1,
                                     seq_2_offset.first,
                                     seq_2_offset.second,
                                     block_n_group - 1,
                                     MASTER_WEIGHT_ADDR,
                                     all_done_weight);
  }

  insn::instruction LoadWeightScale(int64_t ddr_base_addr, int n_group, int k_group, int64_t block_n_group, int n_group_size)
  {
    auto seq_1_offset = split_exp_fra(n_group_size);

    if (DEBUG) {
      std::cout << "======== Load Weight Scale ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << n_group_size - 1 << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_n_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    auto load_insn =
      insn::load_iteration_3<1>(ddr_base_addr, n_group_size  - 1, 0, 0, block_n_group - 1, 0, 0, 0, MASTER_WEIGHT_SCALE_ADDR, 0);
    return load_insn;
  }

  insn::instruction LoadBias(int64_t ddr_base_addr, int64_t seq_0_burst, int n_group, int k_group, int64_t block_n_group, int n_group_size)
  {
    auto seq_1_offset = split_exp_fra(n_group_size);

    if (DEBUG) {
      std::cout << "======== Load Bias ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << seq_0_burst << std::endl;
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_n_group << std::endl;
      std::cout << "==========================" << std::endl;
    }

    return insn::load_iteration_2(ddr_base_addr, seq_0_burst - 1, seq_1_offset.first, seq_1_offset.second, 0, MASTER_BIAS_ADDR, 0);
  }
  

  insn::instruction Store(int64_t ddr_base_addr, int64_t n_group, int64_t m, int64_t block_n_group, int64_t tile_m, int all_done)
  {
    auto seq_1_offset = split_exp_fra(bytes_ofmap * k_group_size * tile_m);

    if (DEBUG) {
      std::cout << "======== Store ========" << std::endl;
      std::cout << "ddr_base_addr: " << ddr_base_addr << std::endl;
      std::cout << "n_group: " << n_group << std::endl;
      std::cout << "m: " << m << std::endl;
      std::cout << "block_n_group: " << block_n_group << std::endl;
      std::cout << "tile_m: " << tile_m << std::endl;
      std::cout << "all_done: " << all_done << std::endl;
      std::cout << "== Config Parameters ==" << std::endl;
      std::cout << "seq_0_burst: " << 512 << std::endl;  //OFMAP SRAM Depth is 512 (with 256bits data width)
      std::cout << "seq_1_hop_exp: " << seq_1_offset.first << std::endl;
      std::cout << "seq_1_hop_fra: " << seq_1_offset.second << std::endl;
      std::cout << "seq_1_burst: " << block_n_group << std::endl;
    }

    return insn::store_iteration_2(
      ddr_base_addr, (tile_m * k_group_size * bytes_ofmap/32 ) - 1, seq_1_offset.first, seq_1_offset.second, block_n_group - 1, MASTER_OFMAP_ADDR, all_done);
    // return insn::store_iteration_2(
    //   ddr_base_addr, 16 - 1, seq_1_offset.first, seq_1_offset.second, block_n_group - 1, MASTER_OFMAP_ADDR, all_done);
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
}
}
