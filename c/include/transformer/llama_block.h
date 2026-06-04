#pragma once

#include "transformer/llama_attention.h"
#include "transformer/llama_mlp.h"
#include "transformer/rmsnorm.h"
#include "vcu/vcu_operation.h" 
#include "common/insn.h"
#include "addr_for_llama.h" // 需要重新调整地址
#include <vector>
#include <string>
#include <iostream> 
#include <cmath>    


namespace transformer {
namespace llama_block {
using namespace common::insn;

void print_dec(std::string str, int num, std::ostream& os = std::cout) {
    os << std::dec << str << ": " << num << std::endl;
}
void print_hex(std::string str, uint64_t num, std::ostream& os = std::cout) {
    os << std::hex << str << ": 0x" << num << std::endl;
}

template<bool DEBUG = false>
struct LlamaBlockOp {

    static constexpr int MAX_IFMAP_DEPTH  = DEFAULT_MAX_IFMAP_DEPTH;
    static constexpr int MAX_WEIGHT_DEPTH = DEFAULT_MAX_WEIGHT_DEPTH;
    static constexpr int MAX_PSUM_DEPTH   = DEFAULT_MAX_PSUM_DEPTH;
    static constexpr int MAX_OFMAP_DEPTH  = DEFAULT_MAX_OFMAP_DEPTH;
    static constexpr int MAX_VCURES_DEPTH = DEFAULT_MAX_VCURES_DEPTH;

    int bytes_hidden_state; 
    int oc_group_size_temp; 

    struct Argument {
        int seq_len;
        int hidden_size;        // d_model
        int intermediate_size;  // For MLP
        int num_attention_heads;
        float rmsnorm_epsilon;
        DType hidden_dtype;       
        DType weight_dtype;       

        uint64_t input_hidden_state_addr;
        uint64_t final_output_hidden_state_addr;

        uint64_t freq_cls_base_addr;    // RoPE Parameters
        uint64_t mask_base_addr;        // Causal Mask 

        // Weight Address
        uint64_t attn_norm_gamma_addr; // RMSNorm before Attention
        uint64_t attn_query_weight_addr;
        uint64_t attn_key_weight_addr;
        uint64_t attn_value_weight_addr;
        uint64_t attn_output_weight_addr;
        uint64_t ffn_norm_gamma_addr;  // RMSNorm before MLP
        uint64_t mlp_gate_weight_addr;
        uint64_t mlp_up_weight_addr;
        uint64_t mlp_down_weight_addr;

        // Temporary Storage Addresses 
        uint64_t attn_norm_output_addr;         // Output of 1st RMSNorm
        uint64_t attn_query_temp_addr;             // Temp for Q projection in Attention
        uint64_t attn_key_temp_addr;               // Temp for K projection in Attention
        uint64_t attn_value_temp_addr;             // Temp for V projection in Attention
        uint64_t attn_score_temp_addr;             // Temp for QK^T scores in Attention
        uint64_t attn_probe_temp_addr;             // Temp for Softmax output (probe) in Attention
        uint64_t attn_output_temp_addr;        // Output of Attention (before projection)
        uint64_t attn_output_proj_addr;             // Final projected output of Attention
        uint64_t residual_after_attn_addr;    // Output of 1st residual add (input_hs + attn_out)
        uint64_t ffn_norm_output_addr;          // Output of 2nd RMSNorm
        uint64_t mlp_gate_output_addr;        // Temp for gate projection in MLP
        uint64_t mlp_up_output_addr;          // Temp for up projection in MLP
        uint64_t mlp_mul_output_addr;         // Temp for SiLU * Up_proj in MLP
        uint64_t mlp_final_proj_output_addr; // Output of MLP (before 2nd residual)

        // VCU code Addresses
        uint64_t vcu_code_llama_block_addr; // Can reuse the same VCU code if op is identical

        // LUT Addresses
        uint64_t rec_lut_addr;          // For RMSNorm
        uint64_t log_lut_addr;          // For RMSNorm
        uint64_t exp_lut_addr;          // For Attention (softmax)
        uint64_t rsqrt_lut_addr;        // For RMSNorm
        uint64_t swish_lut_addr;        // For MLP

        uint64_t all_done = 1; 
    };

    LlamaBlockOp() {
        bytes_hidden_state = 4; 
        oc_group_size_temp = 32; 
    }

    std::pair<std::vector<instruction>, std::vector<uint64_t>> operator()(const Argument& args) {
        std::vector<instruction> insn_series;
        std::vector<uint64_t> vcucode_series_block; 

        uint64_t vcu_code_current_addr = args.vcu_code_llama_block_addr;

        /** Step1: set tile for rmsnorm */
        int tile_m_rmsnorm = std::min(std::min(MAX_VCURES_DEPTH, MAX_PSUM_DEPTH), args.seq_len);
        // int tile_m_rmsnorm = 32;
        int block_oc_group_rmsnorm = std::min(std::min(MAX_VCURES_DEPTH, MAX_PSUM_DEPTH) / tile_m_rmsnorm, args.hidden_size / oc_group_size_temp);
        // int block_oc_group_rmsnorm = 4;

        /** Step2: set tile for fp32->fp16 and parallesim convertion */
        int tile_m_convert = std::min(std::min(MAX_OFMAP_DEPTH / 2, MAX_PSUM_DEPTH), args.seq_len);
        // int tile_m_convert = 32;
        int block_oc_group_convert = std::min(MAX_OFMAP_DEPTH / tile_m_convert / 2, std::min(MAX_PSUM_DEPTH / tile_m_convert, args.hidden_size / oc_group_size_temp));
        // int block_oc_group_convert = 1;

        /** Step3: set tile for addition */
        int tile_m_add = std::min(std::min(MAX_VCURES_DEPTH, MAX_PSUM_DEPTH), args.seq_len);
        // int tile_m_add = 32;
        int block_oc_group_add = std::min(std::min(MAX_VCURES_DEPTH, MAX_PSUM_DEPTH) / tile_m_add, args.hidden_size / oc_group_size_temp);
        // int block_oc_group_add = 4;

        /** --- RMSNorm before Attention --- */
        if (DEBUG) std::cout << "LlamaBlock: Generating RMSNorm (Attention) instructions..." << std::endl;
        using rmsnorm_t = transformer::rmsnorm::RMSNormOp<DEBUG>;
        rmsnorm_t attn_rmsnorm_op;
        typename rmsnorm_t::Argument attn_norm_args = {
            .seq_len = args.seq_len,
            .d_model = args.hidden_size,
            .tile_m = tile_m_rmsnorm, 
            .block_oc_group = block_oc_group_rmsnorm, 
            .epsilon = args.rmsnorm_epsilon,
            .dtype = args.hidden_dtype, 
            .input_base_addr = args.input_hidden_state_addr,
            .gamma_base_addr = args.attn_norm_gamma_addr,
            .output_base_addr = args.attn_norm_output_addr,
            .vcu_code_addr = vcu_code_current_addr,
            .rec_lut_ddr_base_addr = args.rec_lut_addr,
            .log_lut_ddr_base_addr = args.log_lut_addr,
            .exp_lut_ddr_base_addr = args.exp_lut_addr,
            .rsqrt_lut_ddr_base_addr = args.rsqrt_lut_addr,
            .all_done = 0 
        };
        auto attn_norm_pack = attn_rmsnorm_op(attn_norm_args);
        insn_series.insert(insn_series.end(), attn_norm_pack.first.begin(), attn_norm_pack.first.end());
        vcucode_series_block.insert(vcucode_series_block.end(), attn_norm_pack.second.begin(), attn_norm_pack.second.end());
        vcu_code_current_addr += attn_norm_pack.second.size() * sizeof(uint64_t);

        /** fp32, group_size = 32 -> fp16, group_size = 16 */
        using vcu_convert_t = vcu::operation::SingleVCUOp<DEBUG>;
        vcu_convert_t vcu_convert;
        typename vcu_convert_t::Argument vcu_convert_args = {
            .seq_len = args.seq_len,
            .d_model = args.hidden_size,
            .tile_m = tile_m_convert,
            .block_oc_group = block_oc_group_convert,
            .dtype = args.hidden_dtype,
            .op_type = vcu::operation::OP_TYPE::CONVERT,
            .input1_base_addr = args.attn_norm_output_addr,
            .output_base_addr = args.ffn_norm_output_addr,  // Address Reuse, attn_hf -> ffn_hf
            .vcu_code_addr = vcu_code_current_addr,
            .all_done = 0
        };
        auto vcu_convert_pack = vcu_convert(vcu_convert_args);
        insn_series.insert(insn_series.end(), vcu_convert_pack.first.begin(), vcu_convert_pack.first.end());
        vcucode_series_block.insert(vcucode_series_block.end(), vcu_convert_pack.second.begin(), vcu_convert_pack.second.end());
        vcu_code_current_addr += vcu_convert_pack.second.size() * sizeof(uint64_t);

        /** --- Llama Attention --- */
        if (DEBUG) std::cout << "LlamaBlock: Generating Llama Attention instructions..." << std::endl;
        using llama_attention_t = transformer::mha::LlamaAttentionOp<DEBUG, false>;
        llama_attention_t llama_attention_op; // BIAS=false default
        typename llama_attention_t::Argument attn_args = {
            .seq_len = args.seq_len,
            .d_model = args.hidden_size,
            .head_num = args.num_attention_heads,
            .input_base_addr = args.ffn_norm_output_addr,  // Address Reuse, attn_hf -> ffn_hf
            .weight_query_base_addr = args.attn_query_weight_addr,
            .weight_key_base_addr = args.attn_key_weight_addr,
            .weight_value_base_addr = args.attn_value_weight_addr,
            .weight_output_base_addr = args.attn_output_weight_addr,
            .query_temp_base_addr = args.attn_query_temp_addr,
            .key_temp_base_addr = args.attn_key_temp_addr,
            .value_temp_base_addr = args.attn_value_temp_addr,
            .score_temp_base_addr = args.attn_score_temp_addr,
            .probe_temp_base_addr = args.attn_probe_temp_addr,
            .output_temp_base_addr = args.attn_output_temp_addr, // Output before projection
            .output_base_addr = args.attn_output_proj_addr, // final projected output
            .freq_cls_base_addr = args.freq_cls_base_addr, 
            .mask_base_addr = args.mask_base_addr, 
            .vcu_code_base_addr = vcu_code_current_addr,
            .exp_lut_base_addr = args.exp_lut_addr,
            .rec_lut_base_addr = args.rec_lut_addr,
            .all_done = 0
        };
        auto attn_pack = llama_attention_op(attn_args);
        insn_series.insert(insn_series.end(), attn_pack.first.begin(), attn_pack.first.end());
        vcucode_series_block.insert(vcucode_series_block.end(), attn_pack.second.begin(), attn_pack.second.end());
        vcu_code_current_addr += attn_pack.second.size() * sizeof(uint64_t);

        /** --- First Residual Connection: input_hidden_state + attention_output --- */
        if (DEBUG) std::cout << "LlamaBlock: Generating 1st Residual Addition instructions..." << std::endl;
        using residual_add1_t = vcu::operation::SingleVCUOp<DEBUG>;
        residual_add1_t residual_add1_op;
        typename residual_add1_t::Argument res_add1_args = {
            .seq_len = args.seq_len,
            .d_model = args.hidden_size,
            .tile_m = tile_m_add,
            .block_oc_group = block_oc_group_add,
            .dtype = args.hidden_dtype,
            .op_type = vcu::operation::OP_TYPE::ADD,
            .input1_base_addr = args.input_hidden_state_addr,
            .input2_base_addr = args.attn_output_proj_addr,
            .output_base_addr = args.residual_after_attn_addr,
            .vcu_code_addr = vcu_code_current_addr, // VCU code for ADD
            .all_done = 0
        };
        auto res_add1_pack = residual_add1_op(res_add1_args);
        insn_series.insert(insn_series.end(), res_add1_pack.first.begin(), res_add1_pack.first.end());
        vcucode_series_block.insert(vcucode_series_block.end(), res_add1_pack.second.begin(), res_add1_pack.second.end());
        vcu_code_current_addr += res_add1_pack.second.size() * sizeof(uint64_t);

        /** --- RMSNorm before MLP --- */
        if (DEBUG) std::cout << "LlamaBlock: Generating RMSNorm (MLP) instructions..." << std::endl;
        using ffn_rmsnorm_t = transformer::rmsnorm::RMSNormOp<DEBUG>;
        ffn_rmsnorm_t ffn_rmsnorm_op;
        typename ffn_rmsnorm_t::Argument ffn_norm_args = {
            .seq_len = args.seq_len,
            .d_model = args.hidden_size,
            .tile_m = tile_m_rmsnorm,
            .block_oc_group = block_oc_group_rmsnorm,
            .epsilon = args.rmsnorm_epsilon,
            .dtype = args.hidden_dtype, 
            .input_base_addr = args.residual_after_attn_addr, // Input is output of 1st residual
            .gamma_base_addr = args.ffn_norm_gamma_addr,
            .output_base_addr = args.ffn_norm_output_addr,
            .vcu_code_addr = vcu_code_current_addr, 
            .rec_lut_ddr_base_addr = args.rec_lut_addr,
            .log_lut_ddr_base_addr = args.log_lut_addr,
            .exp_lut_ddr_base_addr = args.exp_lut_addr,
            .rsqrt_lut_ddr_base_addr = args.rsqrt_lut_addr,
            .all_done = 0
        };
        auto ffn_norm_pack = ffn_rmsnorm_op(ffn_norm_args);
        insn_series.insert(insn_series.end(), ffn_norm_pack.first.begin(), ffn_norm_pack.first.end());
        vcucode_series_block.insert(vcucode_series_block.end(), ffn_norm_pack.second.begin(), ffn_norm_pack.second.end());
        vcu_code_current_addr += ffn_norm_pack.second.size() * sizeof(uint64_t);

        /** fp32, group_size = 32 -> fp16, group_size = 16 */
        vcu_convert_args = {
            .seq_len = args.seq_len,
            .d_model = args.hidden_size,
            .tile_m = tile_m_convert,
            .block_oc_group = block_oc_group_convert,
            .dtype = args.hidden_dtype,
            .op_type = vcu::operation::OP_TYPE::CONVERT,
            .input1_base_addr = args.ffn_norm_output_addr,
            .output_base_addr = args.attn_norm_output_addr,  // Address Reuse, ffn_hf -> attn_hf
            .vcu_code_addr = vcu_code_current_addr,
            .all_done = 0
        };
        vcu_convert_pack = vcu_convert(vcu_convert_args);
        insn_series.insert(insn_series.end(), vcu_convert_pack.first.begin(), vcu_convert_pack.first.end());
        vcucode_series_block.insert(vcucode_series_block.end(), vcu_convert_pack.second.begin(), vcu_convert_pack.second.end());
        vcu_code_current_addr += vcu_convert_pack.second.size() * sizeof(uint64_t);

        /** --- Llama MLP --- */
        if (DEBUG) std::cout << "LlamaBlock: Generating Llama MLP instructions..." << std::endl;
        using llama_mlp_t = transformer::llama_mlp::LlamaMlpOp<DEBUG>;
        llama_mlp_t llama_mlp_op;
        typename llama_mlp_t::Argument mlp_args = {
            .seq_len = args.seq_len,
            .hidden_size = args.hidden_size,
            .intermediate_size = args.intermediate_size,
            .input_base_addr = args.attn_norm_output_addr,  // Address Reuse, ffn_hf -> attn_hf
            .gate_weight_base_addr = args.mlp_gate_weight_addr,
            .up_weight_base_addr = args.mlp_up_weight_addr,
            .down_weight_base_addr = args.mlp_down_weight_addr,
            .gate_output_base_addr = args.mlp_gate_output_addr,
            .up_output_base_addr = args.mlp_up_output_addr,
            .mul_output_base_addr = args.mlp_mul_output_addr,
            .final_output_base_addr = args.mlp_final_proj_output_addr, 
            .vcu_code_base_addr = vcu_code_current_addr,
            .swish_lut_base_addr = args.swish_lut_addr, // MLP uses LUT for Swish
            .all_done = 0 
        };
        auto mlp_pack = llama_mlp_op(mlp_args);
        insn_series.insert(insn_series.end(), mlp_pack.first.begin(), mlp_pack.first.end());
        vcucode_series_block.insert(vcucode_series_block.end(), mlp_pack.second.begin(), mlp_pack.second.end());
        vcu_code_current_addr += mlp_pack.second.size() * sizeof(uint64_t);

        /** --- Second Residual Connection: residual_after_attn + mlp_output --- */
        if (DEBUG) std::cout << "LlamaBlock: Generating 2nd Residual Addition instructions..." << std::endl;
        using residual_add2_t = vcu::operation::SingleVCUOp<DEBUG>;
        residual_add2_t residual_add2_op;
        typename residual_add2_t::Argument res_add2_args = {
            .seq_len = args.seq_len,
            .d_model = args.hidden_size,
            .tile_m = tile_m_add,
            .block_oc_group = block_oc_group_add,
            .dtype = args.hidden_dtype,
            .op_type = vcu::operation::OP_TYPE::ADD,
            .input1_base_addr = args.residual_after_attn_addr,
            .input2_base_addr = args.mlp_final_proj_output_addr, // Output from MLP's down projection
            .output_base_addr = args.final_output_hidden_state_addr, // Final output of the block
            .vcu_code_addr = vcu_code_current_addr, // Can reuse ADD VCU code
            .all_done = args.all_done 
        };
        auto res_add2_pack = residual_add2_op(res_add2_args);
        insn_series.insert(insn_series.end(), res_add2_pack.first.begin(), res_add2_pack.first.end());
        vcucode_series_block.insert(vcucode_series_block.end(), res_add2_pack.second.begin(), res_add2_pack.second.end());
        
        if (DEBUG) std::cout << "LlamaBlock: Instruction generation complete." << std::endl;
        return {insn_series, vcucode_series_block}; // vcucode_series_block might be empty if sub-ops handle their VCU codes
    }
};

} // namespace llama_block
} // namespace transformer
