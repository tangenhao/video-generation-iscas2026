#include "common/insn.h"
#include "common/type_utils.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/transformer/llama_block.h" 
#include "transformer/llama_block.h"           
#include "instruction/parser.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include "addr_for_llama.h"

#include <vector>
#include <iostream>
#include <string>

int main(int argc, const char** argv) {
    using namespace common;
    using namespace compute_model::tensor;
    using namespace compute_model::common::fp16;
    using namespace compute_model::function; 

    // Block Configuration
    int seq_len = 32;
    int d_model = 64;         // hidden_size
    int intermediate_size = 256;  // MLP intermediate size
    int head_num = 2;
    float rmsnorm_epsilon = 1e-6f;
    DType hidden_dtype_ref = kFloat32; // For compute_model reference path
    DType weight_dtype_ref = kHalf;   

    DType hidden_dtype = kFloat32; // For instruction generation (main path, RMSNorm in fp32)
    DType weight_dtype = kHalf;   

    int n_group_size = 32; 
    int k_group_size = 16;

    /* -------------------------------------------------------------------------------------------------------- */
    /*                                           Data Generation                                                */
    /* -------------------------------------------------------------------------------------------------------- */
    std::cout << "Generating random data..." << std::endl;

    // Input Hidden State: [d_model/n_group_size, seq_len, n_group_size]
    auto input_hidden_state_fp32 = randn<float>({d_model / n_group_size, seq_len, n_group_size}, hidden_dtype_ref, -0.1f, 0.1f, 1);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_input_hidden_state.txt", reinterpret_cast<char*>(input_hidden_state_fp32.data_ptr()), input_hidden_state_fp32.numel() * sizeof(float), 32, true);

    // --- RMSNorm Para ---
    auto attn_norm_gamma_fp32 = randn<float>({d_model / n_group_size, n_group_size}, hidden_dtype_ref, -0.1f, 0.1f, 100);
    auto ffn_norm_gamma_fp32 = randn<float>({d_model / n_group_size, n_group_size}, hidden_dtype_ref, -0.1f, 0.1f, 200);
    common::file_utils::saveCharArrayToFormattedTextFile(
    "../../sim/memory_llama/block_attn_norm_gamma.txt", reinterpret_cast<char*>(attn_norm_gamma_fp32.data_ptr()), attn_norm_gamma_fp32.numel() * sizeof(float), 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_ffn_norm_gamma.txt", reinterpret_cast<char*>(ffn_norm_gamma_fp32.data_ptr()), ffn_norm_gamma_fp32.numel() * sizeof(float), 32, true);

    // --- Attention Weights ---
    auto query_weight_h = randn<half>({d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, weight_dtype_ref, -0.1f, 0.1f, 300);
    auto key_weight_h   = randn<half>({d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, weight_dtype_ref, -0.1f, 0.1f, 400);
    auto value_weight_h = randn<half>({d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, weight_dtype_ref, -0.1f, 0.1f, 500);
    auto attn_output_weight_h = randn<half>({d_model/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, weight_dtype_ref, -0.1f, 0.1f, 600);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_attn_query_weight.txt", reinterpret_cast<char*>(query_weight_h.data_ptr()), query_weight_h.numel() * sizeof(half), 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_attn_key_weight.txt", reinterpret_cast<char*>(key_weight_h.data_ptr()), key_weight_h.numel() * sizeof(half), 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_attn_value_weight.txt", reinterpret_cast<char*>(value_weight_h.data_ptr()), value_weight_h.numel() * sizeof(half), 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_attn_output_weight.txt", reinterpret_cast<char*>(attn_output_weight_h.data_ptr()), attn_output_weight_h.numel() * sizeof(half), 32, true);

    // --- MLP Weights ---
    auto mlp_gate_weight_h = randn<half>({intermediate_size/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, weight_dtype_ref, -0.1f, 0.1f, 700);
    auto mlp_up_weight_h   = randn<half>({intermediate_size/n_group_size, d_model/k_group_size, n_group_size, k_group_size}, weight_dtype_ref, -0.1f, 0.1f, 800);
    auto mlp_down_weight_h = randn<half>({d_model/n_group_size, intermediate_size/k_group_size, n_group_size, k_group_size}, weight_dtype_ref, -0.1f, 0.1f, 900);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_mlp_gate_weight.txt", reinterpret_cast<char*>(mlp_gate_weight_h.data_ptr()), mlp_gate_weight_h.numel() * sizeof(half), 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_mlp_up_weight.txt", reinterpret_cast<char*>(mlp_up_weight_h.data_ptr()), mlp_up_weight_h.numel() * sizeof(half), 32, true);
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_mlp_down_weight.txt", reinterpret_cast<char*>(mlp_down_weight_h.data_ptr()), mlp_down_weight_h.numel() * sizeof(half), 32, true);

    // Output tensor for reference computation (fp32)
    auto output_hidden_state_ref_fp32 = zeros<float>({d_model / n_group_size, seq_len, n_group_size}, hidden_dtype_ref);

    /* -------------------------------------------------------------------------------------------------------- */
    /*                           Reference Output Generation                                                    */
    /* -------------------------------------------------------------------------------------------------------- */
    std::cout << "Generating reference output..." << std::endl;
    using namespace compute_model::transformer::llama_block;
    apply_llama_block<float, half, true>(
        input_hidden_state_fp32, 
        output_hidden_state_ref_fp32,
        attn_norm_gamma_fp32, 
        ffn_norm_gamma_fp32,
        query_weight_h, 
        key_weight_h, 
        value_weight_h, 
        attn_output_weight_h,
        mlp_gate_weight_h, 
        mlp_up_weight_h, 
        mlp_down_weight_h,
        head_num, 
        rmsnorm_epsilon
    );
    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/block_output_hidden_state_ref.txt", reinterpret_cast<char*>(output_hidden_state_ref_fp32.data_ptr()), output_hidden_state_ref_fp32.numel() * sizeof(float), 32, true);

    /* -------------------------------------------------------------------------------------------------------- */
    /*                               Generate Instructions                                                      */
    /* -------------------------------------------------------------------------------------------------------- */
    std::cout << "Generating hardware instructions..." << std::endl;
    transformer::llama_block::LlamaBlockOp<true> llama_block_op; // DEBUG

    llama_block_op.bytes_hidden_state = 4;
    llama_block_op.oc_group_size_temp = 32; 

    transformer::llama_block::LlamaBlockOp<true>::Argument llama_block_args = {
        .seq_len = seq_len,
        .hidden_size = d_model,
        .intermediate_size = intermediate_size,
        .num_attention_heads = head_num,
        .rmsnorm_epsilon = rmsnorm_epsilon,
        .hidden_dtype = hidden_dtype, // kFloat32
        .weight_dtype = weight_dtype, // KHalf

        .input_hidden_state_addr = BLOCK_INPUT_ADDR,
        .final_output_hidden_state_addr = BLOCK_OUTPUT_ADDR,

        .freq_cls_base_addr = ATTN_FREQ_CLS_ADDR,
        .mask_base_addr = ATTN_MASK_ADDR,

        .attn_norm_gamma_addr = ATTN_NORM_GAMMA_ADDR,
        .attn_query_weight_addr = ATTN_QUERY_WEIGHT_ADDR,
        .attn_key_weight_addr = ATTN_KEY_WEIGHT_ADDR,
        .attn_value_weight_addr = ATTN_VALUE_WEIGHT_ADDR,
        .attn_output_weight_addr = ATTN_OUTPUT_WEIGHT_ADDR,
        .ffn_norm_gamma_addr = FFN_NORM_GAMMA_ADDR,
        .mlp_gate_weight_addr = MLP_GATE_WEIGHT_ADDR,
        .mlp_up_weight_addr = MLP_UP_WEIGHT_ADDR,
        .mlp_down_weight_addr = MLP_DOWN_WEIGHT_ADDR,

        .attn_norm_output_addr = ATTN_NORM_OUTPUT_ADDR, // RMSNorm output (fp32)
        .attn_query_temp_addr = ATTN_QUERY_TEMP_ADDR,
        .attn_key_temp_addr = ATTN_KEY_TEMP_ADDR,
        .attn_value_temp_addr = ATTN_VALUE_TEMP_ADDR,
        .attn_score_temp_addr = ATTN_SCORE_TEMP_ADDR,
        .attn_probe_temp_addr = ATTN_PROBE_TEMP_ADDR,
        .attn_output_temp_addr = ATTN_OUTPUT_TEMP_ADDR,
        .attn_output_proj_addr = ATTN_OUTPUT_PROJ_ADDR,
        .residual_after_attn_addr = RESIDUAL_AFTER_ATTN_ADDR,
        .ffn_norm_output_addr = FFN_NORM_OUTPUT_ADDR, // RMSNorm output (fp32)
        .mlp_gate_output_addr = MLP_GATE_OUTPUT_ADDR,
        .mlp_up_output_addr = MLP_UP_OUTPUT_ADDR,
        .mlp_mul_output_addr = MLP_MUL_OUTPUT_ADDR,
        .mlp_final_proj_output_addr = MLP_FINAL_PROJ_OUTPUT_ADDR,

        .vcu_code_llama_block_addr = LLAMA_BLOCK_VCUCODE_ADDR, // Use macro directly 

        .rec_lut_addr = LLAMA_BLOCK_REC_LUT_ADDR, 
        .log_lut_addr = LLAMA_BLOCK_LOG_LUT_ADDR,
        .exp_lut_addr = LLAMA_BLOCK_EXP_LUT_ADDR,
        .rsqrt_lut_addr = LLAMA_BLOCK_RSQRT_LUT_ADDR,
        .swish_lut_addr = LLAMA_BLOCK_SWISH_LUT_ADDR, 
        .all_done = 1
    };

    auto llama_block_pack = llama_block_op(llama_block_args);
    auto insn_series = llama_block_pack.first;
    auto vcucode_series = llama_block_pack.second; 
                                          
    // pad serial sync word
    common::insn::pad_serial_sync_word(insn_series);
    // parse instructions
    auto parser = common::insn::instruction_parser(insn_series);     
    parser.parse_instruction();

    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/vcucode.txt", 
        reinterpret_cast<char*>(vcucode_series.data()), 
        vcucode_series.size() * sizeof(uint64_t), 32, true);

    common::file_utils::saveCharArrayToFormattedTextFile(
        "../../sim/memory_llama/insn.txt", reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);
    

   
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
