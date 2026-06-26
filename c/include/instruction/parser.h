#pragma once

#include "addr.h"
#include "common/insn.h"

namespace common {
namespace insn {

struct instruction_parser {

  std::vector<instruction> instructions;

  instruction_parser(std::vector<instruction>& instructions): instructions(instructions) {}

  std::string get_sram_name(int sram_addr)
  {
    std::string sram_name;
    if (sram_addr < MASTER_IFMAP_ADDR) {
      sram_name = "Register file";
    }
    else if (sram_addr >= MASTER_IFMAP_ADDR && sram_addr < MASTER_IFMAP_SCALE_ADDR) {
      sram_name = "Ifmap";
    }
    else if (sram_addr >= MASTER_IFMAP_SCALE_ADDR && sram_addr < MASTER_WEIGHT_ADDR) {
      sram_name = "Ifmap scale";
    }
    else if (sram_addr >= MASTER_WEIGHT_ADDR && sram_addr < MASTER_WEIGHT_SCALE_ADDR) {
      sram_name = "Weight";
    }
    else if (sram_addr >= MASTER_WEIGHT_SCALE_ADDR && sram_addr < MASTER_OUTLIER_INDEX_ADDR) {
      sram_name = "Weight scale";
    }
    else if (sram_addr >= MASTER_OUTLIER_INDEX_ADDR && sram_addr < MASTER_PSUM_ADDR) {
      sram_name = "Outlier index";
    }
    else if (sram_addr >= MASTER_PSUM_ADDR && sram_addr < MASTER_OFMAP_ADDR) {
      sram_name = "Partial sum";
    }
    else if (sram_addr >= MASTER_OFMAP_ADDR && sram_addr < MASTER_VCUCODE_ADDR) {
      sram_name = "Output feature map";
    }
    else if (sram_addr >= MASTER_VCUCODE_ADDR && sram_addr < MASTER_VCULUT_ADDR) {
      sram_name = "VCU code";
    }
    else if (sram_addr >= MASTER_VCULUT_ADDR && sram_addr < MASTER_VCUPARA_ADDR) {
      sram_name = "VCU LUT";
    }
    else if (sram_addr >= MASTER_VCUPARA_ADDR && sram_addr < MASTER_VCURES_ADDR) {
      sram_name = "VCU para";
    }
    else if (sram_addr >= MASTER_VCURES_ADDR && sram_addr < MASTER_QACT_ADDR) {
      sram_name = "VCU resadd";
    }
    else if (sram_addr >= MASTER_QACT_ADDR) {
      sram_name = "QACT / Ifmap mask";
    }
    return sram_name;
  }

  std::string parser_sync_word(int64_t sync_word) {
    std::string result = "";
    for (int i = 0; i < 32; i++) {
      if (i < 8) {
        if (sync_word & 0x1 == 1) {
          result = result + "load " + std::to_string(i) + ", ";
        }
      }
      else if (i >= 8 && i < 16) {
        if (sync_word & 0x1 == 1) {
          result = result + "store " + std::to_string(i - 8) + ", ";
        }
      }
      else if (i >= 16 && i < 24) {
        if (sync_word & 0x1 == 1) {
          result = result + "pea " + std::to_string(i - 16) + ", ";
        }
      }
      else if (i >= 24) {
        if (sync_word & 0x1 == 1) {
          result = result + "vcu " + std::to_string(i - 24) + ", ";
        }
      }
      sync_word >>= 1;
    }
    return result;
  }

  void parse_instruction(instruction& insn)
  {
    if (insn.get_insn_opcode() == 0) {
      std::cout << "=== Sync instruction: " << insn << " ====" << std::endl;
      if (insn.get_sync_insn_kind() == 0) {
        auto sync_insn = synchronize_indie(insn);
        std::cout << "Synchronize indie" << std::endl;
        std::cout << "Valid instruction number: " << sync_insn.get_valid_insn_number() << std::endl;
        std::cout << "Sync word 0: " << sync_insn.get_sync_word_0() << " " << parser_sync_word(sync_insn.get_sync_word_0()) << std::endl;
        std::cout << "Sync word 1: " << sync_insn.get_sync_word_1() << " " << parser_sync_word(sync_insn.get_sync_word_1()) << std::endl;
        std::cout << "Sync word 2: " << sync_insn.get_sync_word_2() << " " << parser_sync_word(sync_insn.get_sync_word_2()) << std::endl;
        std::cout << "Load highaddr config: " << sync_insn.get_load_highaddr_config() << std::endl;
        std::cout << "Store highaddr config: " << sync_insn.get_store_highaddr_config() << std::endl;
      }
      else if (insn.get_sync_insn_kind() == 1) {
        auto sync_insn = synchronize_cross(insn);
        std::cout << "Synchronize cross" << std::endl;
        std::cout << "Valid instruction number: " << sync_insn.get_valid_insn_number() << std::endl;
        std::cout << "Sync word 0: " << sync_insn.get_sync_word_0() << std::endl;
        std::cout << "Load highaddr: " << sync_insn.get_load_highaddr() << std::endl;
        std::cout << "Store highaddr: " << sync_insn.get_store_highaddr() << std::endl;
      }
    }
    else if (insn.get_insn_opcode() > 0 && insn.get_insn_opcode() <= 8) {
      std::string dma_id = "DMA" + std::to_string(insn.get_insn_opcode() - 1);
      std::cout << "=== Load instruction: " << insn << " ====" << std::endl;
      if (insn.get_load_insn_kind() == 0) {
        auto load_insn = load_iteration_4(insn);
        std::cout << "Load iteration 4 " << dma_id << std::endl;
        std::cout << "DDR addr: " << load_insn.get_ddr_addr() << std::endl;
        std::cout << "Sequential burst 0: " << load_insn.get_sequ_burst_0() << std::endl;
        std::cout << "Hop offset 1 exp: " << load_insn.get_hop_offset_1_exp() << std::endl;
        std::cout << "Hop offset 1 fra: " << load_insn.get_hop_offset_1_fra() << std::endl;
        std::cout << "Hop offset_1: " << (load_insn.get_hop_offset_1_fra() << load_insn.get_hop_offset_1_exp()) << std::endl;
        std::cout << "Sequential burst 1: " << load_insn.get_sequ_burst_1() << std::endl;
        std::cout << "Hop offset 2 exp: " << load_insn.get_hop_offset_2_exp() << std::endl;
        std::cout << "Hop offset 2 fra: " << load_insn.get_hop_offset_2_fra() << std::endl;
        std::cout << "Hop offset_2: " << (load_insn.get_hop_offset_2_fra() << load_insn.get_hop_offset_2_exp()) << std::endl;
        std::cout << "Sequential burst 2: " << load_insn.get_sequ_burst_2() << std::endl;
        std::cout << "Hop offset 3 exp: " << load_insn.get_hop_offset_3_exp() << std::endl;
        std::cout << "Hop offset 3 fra: " << load_insn.get_hop_offset_3_fra() << std::endl;
        std::cout << "Hop offset_3: " << (load_insn.get_hop_offset_3_fra() << load_insn.get_hop_offset_3_exp()) << std::endl;
        std::cout << "Sequential burst 3: " << load_insn.get_sequ_burst_3() << std::endl;
        std::cout << "SRAM addr: " << load_insn.get_sram_addr() << " (" << get_sram_name(load_insn.get_sram_addr()) << ")" << std::endl;
        std::cout << "All done: " << load_insn.get_all_done() << std::endl;
      }
      else if (insn.get_load_insn_kind() == 1) {
        auto load_insn = load_iteration_3(insn);
        std::cout << "Load iteration 3 " << dma_id << std::endl;
        std::cout << "DDR addr: " << load_insn.get_ddr_addr() << std::endl;
        std::cout << "Sequential burst 0: " << load_insn.get_sequ_burst_0() << std::endl;
        std::cout << "Hop offset 1 exp: " << load_insn.get_hop_offset_1_exp() << std::endl;
        std::cout << "Hop offset 1 fra: " << load_insn.get_hop_offset_1_fra() << std::endl;
        std::cout << "Hop offset_1: " << (load_insn.get_hop_offset_1_fra() << load_insn.get_hop_offset_1_exp()) << std::endl;
        std::cout << "Sequential burst 1: " << load_insn.get_sequ_burst_1() << std::endl;
        std::cout << "Hop offset 2 exp: " << load_insn.get_hop_offset_2_exp() << std::endl;
        std::cout << "Hop offset 2 fra: " << load_insn.get_hop_offset_2_fra() << std::endl;
        std::cout << "Hop offset_2: " << (load_insn.get_hop_offset_2_fra() << load_insn.get_hop_offset_2_exp()) << std::endl;
        std::cout << "Sequential burst 2: " << load_insn.get_sequ_burst_2() << std::endl;
        std::cout << "SRAM addr: " << load_insn.get_sram_addr() << " (" << get_sram_name(load_insn.get_sram_addr()) << ")" << std::endl;
        std::cout << "All done: " << load_insn.get_all_done() << std::endl;
      }
      else if (insn.get_load_insn_kind() == 2) {
        auto load_insn = load_iteration_2(insn);
        std::cout << "Load iteration 2 " << dma_id << std::endl;
        std::cout << "DDR addr: " << load_insn.get_ddr_addr() << std::endl;
        std::cout << "Sequential burst 0: " << load_insn.get_sequ_burst_0() << std::endl;
        std::cout << "Hop offset 1 exp: " << load_insn.get_hop_offset_1_exp() << std::endl;
        std::cout << "Hop offset 1 fra: " << load_insn.get_hop_offset_1_fra() << std::endl;
        std::cout << "Hop offset_1: " << (load_insn.get_hop_offset_1_fra() << load_insn.get_hop_offset_1_exp()) << std::endl;
        std::cout << "Sequential burst 1: " << load_insn.get_sequ_burst_1() << std::endl;
        std::cout << "SRAM addr: " << load_insn.get_sram_addr() << " (" << get_sram_name(load_insn.get_sram_addr()) << ")" << std::endl;
        std::cout << "All done: " << load_insn.get_all_done() << std::endl;
      }
    }
    else if (insn.get_insn_opcode() > 8 && insn.get_insn_opcode() <= 16) {
      std::string dma_id = "DMA" + std::to_string(insn.get_insn_opcode() - 9);
      std::cout << "=== Store instruction: " << insn << " ====" << std::endl;
      if (insn.get_store_insn_kind() == 0) {
        auto store_insn = store_iteration_4(insn);
        std::cout << "Store iteration 4 " << dma_id << std::endl;
        std::cout << "DDR addr: " << store_insn.get_ddr_addr() << std::endl;
        std::cout << "Sequential burst 0: " << store_insn.get_sequ_burst_0() << std::endl;
        std::cout << "Hop offset 1 exp: " << store_insn.get_hop_offset_1_exp() << std::endl;
        std::cout << "Hop offset 1 fra: " << store_insn.get_hop_offset_1_fra() << std::endl;
        std::cout << "Hop offset_1: " << (store_insn.get_hop_offset_1_fra() << store_insn.get_hop_offset_1_exp()) << std::endl;
        std::cout << "Sequential burst 1: " << store_insn.get_sequ_burst_1() << std::endl;
        std::cout << "Hop offset 2 exp: " << store_insn.get_hop_offset_2_exp() << std::endl;
        std::cout << "Hop offset 2 fra: " << store_insn.get_hop_offset_2_fra() << std::endl;
        std::cout << "Hop offset_2: " << (store_insn.get_hop_offset_2_fra() << store_insn.get_hop_offset_2_exp()) << std::endl;
        std::cout << "Sequential burst 2: " << store_insn.get_sequ_burst_2() << std::endl;
        std::cout << "Hop offset 3 exp: " << store_insn.get_hop_offset_3_exp() << std::endl;
        std::cout << "Hop offset 3 fra: " << store_insn.get_hop_offset_3_fra() << std::endl;
        std::cout << "Hop offset_3: " << (store_insn.get_hop_offset_3_fra() << store_insn.get_hop_offset_3_exp()) << std::endl;
        std::cout << "Sequential burst 3: " << store_insn.get_sequ_burst_3() << std::endl;
        std::cout << "SRAM addr: " << store_insn.get_sram_addr() << " (" << get_sram_name(store_insn.get_sram_addr()) << ")" << std::endl;
        std::cout << "All done: " << store_insn.get_all_done() << std::endl;
      }
      else if (insn.get_store_insn_kind() > 8 && insn.get_store_insn_kind() <= 15) {
        auto store_insn = store_iteration_3(insn);
        std::cout << "Store iteration 3 " << dma_id << std::endl;
        std::cout << "DDR addr: " << store_insn.get_ddr_addr() << std::endl;
        std::cout << "Sequential burst 0: " << store_insn.get_sequ_burst_0() << std::endl;
        std::cout << "Hop offset 1 exp: " << store_insn.get_hop_offset_1_exp() << std::endl;
        std::cout << "Hop offset 1 fra: " << store_insn.get_hop_offset_1_fra() << std::endl;
        std::cout << "Hop offset_1: " << (store_insn.get_hop_offset_1_fra() << store_insn.get_hop_offset_1_exp()) << std::endl;
        std::cout << "Sequential burst 1: " << store_insn.get_sequ_burst_1() << std::endl;
        std::cout << "Hop offset 2 exp: " << store_insn.get_hop_offset_2_exp() << std::endl;
        std::cout << "Hop offset 2 fra: " << store_insn.get_hop_offset_2_fra() << std::endl;
        std::cout << "Hop offset_2: " << (store_insn.get_hop_offset_2_fra() << store_insn.get_hop_offset_2_exp()) << std::endl;
        std::cout << "Sequential burst 2: " << store_insn.get_sequ_burst_2() << std::endl;
        std::cout << "SRAM addr: " << store_insn.get_sram_addr() << " (" << get_sram_name(store_insn.get_sram_addr()) << ")" << std::endl;
        std::cout << "All done: " << store_insn.get_all_done() << std::endl;
      }
      else if (insn.get_store_insn_kind() == 2) {
        auto store_insn = store_iteration_2(insn);
        std::cout << "Store iteration 2 " << dma_id << std::endl;
        std::cout << "DDR addr: " << store_insn.get_ddr_addr() << std::endl;
        std::cout << "Sequential burst 0: " << store_insn.get_sequ_burst_0() << std::endl;
        std::cout << "Hop offset 1 exp: " << store_insn.get_hop_offset_1_exp() << std::endl;
        std::cout << "Hop offset 1 fra: " << store_insn.get_hop_offset_1_fra() << std::endl;
        std::cout << "Hop offset_1: " << (store_insn.get_hop_offset_1_fra() << store_insn.get_hop_offset_1_exp()) << std::endl;
        std::cout << "Sequential burst 1: " << store_insn.get_sequ_burst_1() << std::endl;
        std::cout << "SRAM addr: " << store_insn.get_sram_addr() << " (" << get_sram_name(store_insn.get_sram_addr()) << ")" << std::endl;
        std::cout << "All done: " << store_insn.get_all_done() << std::endl;
      }
    }
    else if (insn.get_insn_opcode() > 16 && insn.get_insn_opcode() <= 24) {
      std::string pea_id = "PEA" + std::to_string(insn.get_insn_opcode() - 17);
      std::cout << "=== PEA " << pea_id << " instruction: " << insn << " ====" << std::endl;
      if (insn.get_pea_insn_kind() == 0) {
        auto pea_insn = pea_config(insn);
        std::cout << "PEA config" << std::endl;
        std::cout << "Real k groups: " << pea_insn.get_real_k_groups() << std::endl;
        std::cout << "Real n groups: " << pea_insn.get_real_n_groups() << std::endl;
        std::cout << "GEMM type: " << pea_insn.get_gemm_type() << std::endl;
      }
      else if (insn.get_pea_insn_kind() == 1) {
        auto pea_insn = convolution_execute(insn);
        std::cout << "Convoluation execute" << std::endl;
        std::cout << "Ifmap width: " << pea_insn.get_ifmap_width() << std::endl;
        std::cout << "Ifmap height: " << pea_insn.get_ifmap_height() << std::endl;
        std::cout << "Weight width: " << pea_insn.get_weight_width() << std::endl;
        std::cout << "Weight height: " << pea_insn.get_weight_height() << std::endl;
        std::cout << "Psum width: " << pea_insn.get_psum_width() << std::endl;
        std::cout << "Psum height: " << pea_insn.get_psum_height() << std::endl;
        std::cout << "IC group: " << pea_insn.get_ic_group() << std::endl;
        std::cout << "OC group: " << pea_insn.get_oc_group() << std::endl;
        std::cout << "Ifmap highaddr: " << pea_insn.get_ifmap_highaddr() << std::endl;
        std::cout << "Weight highaddr: " << pea_insn.get_weight_highaddr() << std::endl;
        std::cout << "Psum highaddr: " << pea_insn.get_psum_highaddr() << std::endl;
        std::cout << "Pad left: " << pea_insn.get_pad_left() << std::endl;
        std::cout << "Pad top: " << pea_insn.get_pad_top() << std::endl;
        std::cout << "Psum number: " << pea_insn.get_psum_number() << std::endl;
        std::cout << "Psum accumulated: " << pea_insn.get_psum_accumulated() << std::endl;
      }
      else if (insn.get_pea_insn_kind() == 2) {
        auto pea_insn = gemm_execute(insn);
        std::cout << "GEMM execute" << std::endl;
        std::cout << "Tile M: " << pea_insn.get_tile_m() << std::endl;
        std::cout << "N groups: " << pea_insn.get_n_groups() << std::endl;
        std::cout << "K groups: " << pea_insn.get_k_groups() << std::endl;
        std::cout << "Ifmap highaddr: " << pea_insn.get_ifmap_highaddr() << std::endl;
        std::cout << "Weight highaddr: " << pea_insn.get_weight_highaddr() << std::endl;
        std::cout << "Psum highaddr: " << pea_insn.get_psum_highaddr() << std::endl;
        std::cout << "Psum number: " << pea_insn.get_psum_number() << std::endl;
        std::cout << "Psum accumulated: " << pea_insn.get_psum_accumulated() << std::endl;
      }
    }
    else if (insn.get_insn_opcode() > 24 && insn.get_insn_opcode() <= 32) {
      std::string vcu_id = "VCU" + std::to_string(insn.get_insn_opcode() - 25);
      std::cout << "=== VCU " << vcu_id << " instruction: " << insn << " ====" << std::endl;
      if (insn.get_vcu_insn_kind() == 0) {
        auto vcu_insn = vcu_config(insn);
        std::cout << "VCU config" << std::endl;
        std::cout << "Sin/Cos lut base highaddr: " << vcu_insn.get_sin_cos_lut_base_highaddr() << std::endl;
        std::cout << "Reciprocal lut base highaddr: " << vcu_insn.get_reciprocal_lut_base_highaddr() << std::endl;
        std::cout << "Log lut base highaddr: " << vcu_insn.get_log_lut_base_highaddr() << std::endl;
        std::cout << "Exp lut base highaddr: " << vcu_insn.get_exp_lut_base_highaddr() << std::endl;
        std::cout << "Rsqrt lut base highaddr: " << vcu_insn.get_rsqrt_lut_base_highaddr() << std::endl;
        std::cout << "Tanh lut base highaddr: " << vcu_insn.get_tanh_lut_base_highaddr() << std::endl;
        std::cout << "Sigmoid lut base highaddr: " << vcu_insn.get_sigmoid_lut_base_highaddr() << std::endl;
        std::cout << "Swish lut base highaddr: " << vcu_insn.get_swish_lut_base_highaddr() << std::endl;
        std::cout << "Mish lut base highaddr: " << vcu_insn.get_mish_lut_base_highaddr() << std::endl;
        std::cout << "Gelu lut base highaddr: " << vcu_insn.get_gelu_lut_base_highaddr() << std::endl;
      }
      else if (insn.get_vcu_insn_kind() == 1) {
        auto vcu_insn = vcu_execute(insn);
        std::cout << "VCU execute" << std::endl;
        std::cout << "Psum data type: " << vcu_insn.get_psum_data_type() << std::endl;
        std::cout << "Resadd data type: " << vcu_insn.get_resadd_para_type() << std::endl;
        std::cout << "Output data type: " << vcu_insn.get_data_out_type() << std::endl;
        std::cout << "Opcode number: " << vcu_insn.get_opcode_number() << std::endl;
        std::cout << "Opcode address: " << vcu_insn.get_opcode_addr() << std::endl;
        std::cout << "Psum in address: " << vcu_insn.get_psum_in_addr() << std::endl;
        std::cout << "Para in address: " << vcu_insn.get_para_in_addr() << std::endl;
        std::cout << "Resadd in address: " << vcu_insn.get_resadd_in_addr() << std::endl;
        std::cout << "Output address: " << vcu_insn.get_ram_out_addr() << std::endl;
        std::cout << "Num data: " << vcu_insn.get_num_data_cnt() << std::endl;
        std::cout << "OC group: " << vcu_insn.get_oc_group_cnt() << std::endl;
        std::cout << "Para function: " << vcu_insn.get_para_func_cnt() << std::endl;
        std::cout << "Psum sram valid: " << vcu_insn.get_psum_sram_valid() << std::endl;
        std::cout << "Resadd sram valid: " << vcu_insn.get_resadd_sram_valid() << std::endl;
        std::cout << "Para sram valid: " << vcu_insn.get_para_sram_valid() << std::endl;
        std::cout << "Psum address hop: " << vcu_insn.get_psum_addr_hop() << std::endl;
        std::cout << "Acc clear: " << vcu_insn.get_acc_clear() << std::endl;
        std::cout << "Stream enable: " << vcu_insn.get_stream_en() << std::endl;
        std::cout << "Ifmap sram valid: " << vcu_insn.get_ifmap_sram_valid() << std::endl;
        std::cout << "Ifmap in address: " << vcu_insn.get_ifmap_in_addr() << std::endl;
      }
      else if (insn.get_vcu_insn_kind() == 2) {
        auto vcu_insn = vcu_parallelism_conversion(insn);
        std::cout << "VCU Parallelisim Convertion" << std::endl;
        std::cout << "Input data type: " << vcu_insn.get_data_in_bits_type() << std::endl;
        std::cout << "Psum read base address: " << vcu_insn.get_psum_read_base_addr() << std::endl;
        std::cout << "Ofmap write base address: " << vcu_insn.get_ofmap_write_base_addr() << std::endl;
        std::cout << "Num data: " << vcu_insn.get_num_data() << std::endl;
        std::cout << "IC group: " << vcu_insn.get_in_oc_group() << std::endl;
        std::cout << "OC group: " << vcu_insn.get_out_oc_group() << std::endl;
      }
      else if (insn.get_vcu_insn_kind() == 3) {
        auto vcu_insn = maxpool(insn);
        std::cout << "Maxpool" << std::endl;
        std::cout << "Input data type: " << vcu_insn.get_data_in_type() << std::endl;
        std::cout << "Output data type: " << vcu_insn.get_data_out_type() << std::endl;
        std::cout << "Psum width: " << vcu_insn.get_psum_width() << std::endl;
        std::cout << "Psum height: " << vcu_insn.get_psum_height() << std::endl;
        std::cout << "OC group: " << vcu_insn.get_oc_group() << std::endl;
        std::cout << "Kernel width: " << vcu_insn.get_kernel_width() << std::endl;
        std::cout << "Kernel height: " << vcu_insn.get_kernel_height() << std::endl;
        std::cout << "Psum read highaddr: " << vcu_insn.get_psum_read_highaddr() << std::endl;
        std::cout << "Psum write highaddr: " << vcu_insn.get_psum_write_highaddr() << std::endl;
        std::cout << "Pool width: " << vcu_insn.get_pool_width() << std::endl;
        std::cout << "Pool height: " << vcu_insn.get_pool_height() << std::endl;
        std::cout << "Stride width: " << vcu_insn.get_stride_width() << std::endl;
        std::cout << "Stride height: " << vcu_insn.get_stride_height() << std::endl;
        std::cout << "Dilation width: " << vcu_insn.get_dilation_width() << std::endl;
        std::cout << "Dilation height: " << vcu_insn.get_dilation_height() << std::endl;
        std::cout << "Pad left: " << vcu_insn.get_pad_left() << std::endl;
        std::cout << "Pad top: " << vcu_insn.get_pad_top() << std::endl;
      }
      else if (insn.get_vcu_insn_kind() == 4) {
        auto vcu_insn = avgpool(insn);
        std::cout << "Avgpool" << std::endl;
        std::cout << "Input data type: " << vcu_insn.get_data_in_type() << std::endl;
        std::cout << "Output data type: " << vcu_insn.get_data_out_type() << std::endl;
        std::cout << "Psum width: " << vcu_insn.get_psum_width() << std::endl;
        std::cout << "Psum height: " << vcu_insn.get_psum_height() << std::endl;
        std::cout << "OC group: " << vcu_insn.get_oc_group() << std::endl;
        std::cout << "Psum read highaddr: " << vcu_insn.get_psum_read_highaddr() << std::endl;
        std::cout << "Psum write highaddr: " << vcu_insn.get_psum_write_highaddr() << std::endl;
        std::cout << "Kernel width: " << vcu_insn.get_kernel_width() << std::endl;
        std::cout << "Kernel height: " << vcu_insn.get_kernel_height() << std::endl;
        std::cout << "Pool width: " << vcu_insn.get_pool_width() << std::endl;
        std::cout << "Pool height: " << vcu_insn.get_pool_height() << std::endl;
        std::cout << "Stride width: " << vcu_insn.get_stride_width() << std::endl;
        std::cout << "Stride height: " << vcu_insn.get_stride_height() << std::endl;
        std::cout << "Dilation width: " << vcu_insn.get_dilation_width() << std::endl;
        std::cout << "Dilation height: " << vcu_insn.get_dilation_height() << std::endl;
        std::cout << "Pad left: " << vcu_insn.get_pad_left() << std::endl;
        std::cout << "Pad top: " << vcu_insn.get_pad_top() << std::endl;
      }
      else if (insn.get_vcu_insn_kind() == 5) {
        auto vcu_insn = upsample(insn);
        std::cout << "Upsample: " << std::endl;
        std::cout << "Input data type: " << vcu_insn.get_data_in_type() << std::endl;
        std::cout << "Output data type: " << vcu_insn.get_data_out_type() << std::endl;
        std::cout << "Psum width: " << vcu_insn.get_psum_width() << std::endl;
        std::cout << "Psum height: " << vcu_insn.get_psum_height() << std::endl;
        std::cout << "OC group: " << vcu_insn.get_oc_group() << std::endl;
        std::cout << "Psum read highaddr: " << vcu_insn.get_psum_read_highaddr() << std::endl;
        std::cout << "Psum write highaddr: " << vcu_insn.get_psum_write_highaddr() << std::endl;
        std::cout << "Scale width: " << vcu_insn.get_scale_width() << std::endl;
        std::cout << "Scale height: " << vcu_insn.get_scale_height() << std::endl;
        std::cout << "Upsample width: " << vcu_insn.get_upsample_width() << std::endl;
        std::cout << "Upsample height: " << vcu_insn.get_upsample_height() << std::endl;
      }
      else if (insn.get_vcu_insn_kind() == 8) {
        auto vcu_insn = vcu_transpose(insn);
        std::cout << "VCU transpose" << std::endl;
        std::cout << "Psum data width: " << vcu_insn.get_psum_datawidth() << std::endl;
        std::cout << "Psum read base address: " << vcu_insn.get_psum_read_base_addr() << std::endl;
        std::cout << "Psum write base address: " << vcu_insn.get_psum_write_base_addr() << std::endl;
      }
    }
    else if (insn.get_insn_opcode() == 33) {
      std::cout << "=== Empty instruction: " << insn << " ====" << std::endl;
    }
    else {
      std::throw_with_nested(std::runtime_error("Unknown instruction opcode"));
      exit(1);
    }
  }

  void parse_instruction()
  {
    for (auto& insn : instructions) {
      parse_instruction(insn);
    }
  }
};

}  // namespace insn
}  // namespace common
