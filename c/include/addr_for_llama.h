#pragma once

#include "common/command_line.h"
#include "write_reg.h"

// SRAM DEPTH CONFIGURATION (for vcs simulation)
#define DEFAULT_MAX_IFMAP_DEPTH  512
#define DEFAULT_MAX_WEIGHT_DEPTH 2048
#define DEFAULT_MAX_PSUM_DEPTH   1024
#define DEFAULT_MAX_OFMAP_DEPTH  2048
#define DEFAULT_MAX_VCURES_DEPTH 1024

// Llama Block Specific DDR Addresses
#define INSN_ADDR                        0x0000000
#define BLOCK_INPUT_ADDR                 0x0200000  // Input Hidden State
#define BLOCK_OUTPUT_ADDR                0x0300000  // Output Hidden State

// Weights
#define ATTN_NORM_GAMMA_ADDR             0x0400000
#define ATTN_QUERY_WEIGHT_ADDR           0x0500000
#define ATTN_KEY_WEIGHT_ADDR             0x0600000
#define ATTN_VALUE_WEIGHT_ADDR           0x0700000
#define ATTN_OUTPUT_WEIGHT_ADDR          0x0800000
#define FFN_NORM_GAMMA_ADDR              0x0900000
#define MLP_GATE_WEIGHT_ADDR             0x0A00000
#define MLP_UP_WEIGHT_ADDR               0x0B00000
#define MLP_DOWN_WEIGHT_ADDR             0x0C00000

// Temporary Buffers
#define ATTN_NORM_OUTPUT_ADDR            0x0D00000  // Output of 1st RMSNorm (fp32)
#define ATTN_NORM_OUTPUT_HALF_ADDR       0x0E00000  // Output of 1st RMSNorm (fp16 after conversion for Attn)
#define ATTN_QUERY_TEMP_ADDR             0x0F00000
#define ATTN_KEY_TEMP_ADDR               0x1000000
#define ATTN_VALUE_TEMP_ADDR             0x1100000
#define ATTN_SCORE_TEMP_ADDR             0x1200000
#define ATTN_PROBE_TEMP_ADDR             0x1300000
#define ATTN_OUTPUT_TEMP_ADDR            0x1400000  // Attention raw output
#define ATTN_OUTPUT_PROJ_ADDR            0x1500000  // Final projected output of Attention
#define RESIDUAL_AFTER_ATTN_ADDR         0x1600000  // input_hs + attn_out (fp32)
#define FFN_NORM_OUTPUT_ADDR             0x1700000  // Output of 2nd RMSNorm (fp32)
#define FFN_NORM_OUTPUT_HALF_ADDR        0x1800000  // Output of 2nd RMSNorm (fp16 after conversion for MLP)
#define MLP_GATE_OUTPUT_ADDR             0x1900000
#define MLP_UP_OUTPUT_ADDR               0x1A00000
#define MLP_MUL_OUTPUT_ADDR              0x1B00000
#define MLP_FINAL_PROJ_OUTPUT_ADDR       0x1C00000  // MLP raw output

// VCU Code and LUTs
#define LLAMA_BLOCK_VCUCODE_ADDR         0x1D00000  
#define LLAMA_BLOCK_REC_LUT_ADDR         0x1E00000  
#define LLAMA_BLOCK_LOG_LUT_ADDR         0x1E10000  
#define LLAMA_BLOCK_EXP_LUT_ADDR         0x1E20000  
#define LLAMA_BLOCK_RSQRT_LUT_ADDR       0x1E30000  
#define LLAMA_BLOCK_TANH_LUT_ADDR        0x1E40000  
#define LLAMA_BLOCK_SIGMOID_LUT_ADDR     0x1E50000  
#define LLAMA_BLOCK_MISH_LUT_ADDR        0x1E60000  
#define LLAMA_BLOCK_SWISH_LUT_ADDR       0x1E70000  
#define LLAMA_BLOCK_GELU_LUT_ADDR        0x1E80000  
#define LLAMA_BLOCK_SINCOS_LUT_ADDR      0x1E90000  

// Other Parameters
#define ATTN_FREQ_CLS_ADDR               0x2000000
#define ATTN_MASK_ADDR                   0x2100000

// Old DDR Base Addresses for llama mlp
/*
#define INPUT_ADDR 0x200000
#define GATE_WEIGHT_ADDR 0x400000
#define UP_WEIGHT_ADDR 0x600000
#define DOWN_WEIGHT_ADDR 0x800000
#define GATE_OUTPUT_ADDR 0xa00000
#define UP_OUTPUT_ADDR 0xc00000
#define MUL_OUTPUT_ADDR 0xe00000
#define FINAL_OUTPUT_ADDR 0x1000000
*/

// SRAM Address mapping for AXI Master Interface
#define MASTER_REGFILE_ADDR 0x0
#define MASTER_IFMAP_ADDR 0x10000
#define MASTER_IFMAP_SCALE_ADDR 0x20000
#define MASTER_WEIGHT_ADDR 0x30000
#define MASTER_IFMAPMASK_ADDR 0xc0000
#define MASTER_WEIGHT_SCALE_ADDR 0x40000
#define MASTER_OUTLIER_INDEX_ADDR 0x50000
#define MASTER_PSUM_ADDR 0x60000
#define MASTER_OFMAP_ADDR 0x70000
#define MASTER_VCUCODE_ADDR 0x80000
#define MASTER_VCULUT_ADDR 0x90000
#define MASTER_VCUPARA_ADDR 0xa0000
#define MASTER_VCURES_ADDR 0xb0000

// SRAM Address mapping for AXI Slave Interface
#define SLAVE_REGFILE_ADDR 0x0
#define SLAVE_IFMAP_ADDR 0x400000
#define SLAVE_IFMAP_SCALE_ADDR 0x800000
#define SLAVE_WEIGHT_ADDR 0xc00000
#define SLAVE_WEIGHT_SCALE_ADDR 0x1000000
#define SLAVE_OUTLIER_INDEX_ADDR 0x1400000
#define SLAVE_PSUM_ADDR 0x1800000
#define SLAVE_OFMAP_ADDR 0x1c00000
#define SLAVE_VCUCODE_ADDR 0x2000000
#define SLAVE_VCULUT_ADDR 0x2400000
#define SLAVE_VCUPARA_ADDR 0x2800000
#define SLAVE_VCURES_ADDR 0x2c00000
