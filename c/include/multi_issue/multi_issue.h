#pragma once

#include "common/assert_with_message.h"
#include "common/insn.h"
#include "instruction/parser.h"
#include <cassert>

namespace multi_issue {

using namespace common;

bool check_vcu_enable(std::vector<insn::instruction>& instructions)
{
  for (auto& iter : instructions) {
    if (iter.get_insn_opcode() >= 19 && iter.get_insn_opcode() <= 34) {
      return true;
    }
  }
  return false;
}

bool check_vcures_enable(std::vector<insn::instruction>& instructions)
{
  bool vcures_enable = false;
  if (!check_vcu_enable(instructions)) {
    return false;
  }
  else {
    for (int i = 0; i < instructions.size(); i++) {
      if (instructions[i].get_insn_opcode() == 19) {
        insn::vcu_execute temp = insn::vcu_execute(instructions[i]);
        if (temp.get_insn_kind() == 1 && temp.get_resadd_sram_valid()) {
          vcures_enable = true;
        }
      }
    }
  }
  return vcures_enable;
}

bool check_vcupara_enable(std::vector<insn::instruction>& instructions)
{
  bool vcupara_enable = false;
  if (!check_vcu_enable(instructions)) {
    return false;
  }
  else {
    for (int i = 0; i < instructions.size(); i++) {
      if (instructions[i].get_insn_opcode() == 19) {
        insn::vcu_execute temp = insn::vcu_execute(instructions[i]);
        if (temp.get_insn_kind() == 1 && temp.get_para_sram_valid()) {
          vcupara_enable = true;
        }
      }
    }
  }
  return vcupara_enable;
}

bool conv_insn(std::vector<insn::instruction>& instructions)
{
  bool conv_enable = false;
  for (int i = 0; i < instructions.size(); i++) {
    if (instructions[i].get_insn_opcode() == 3 && instructions[i].get_pea_insn_kind() == 1) {
      conv_enable = true;
    }
  }
  return conv_enable;
}

bool gemm_insn(std::vector<insn::instruction>& instructions)
{
  bool gemm_enable = false;
  for (int i = 0; i < instructions.size(); i++) {
    if (instructions[i].get_insn_opcode() == 3 && instructions[i].get_pea_insn_kind() == 2) {
      gemm_enable = true;
    }
  }
  return gemm_enable;
}

bool check_pvsq_enable(std::vector<insn::instruction>& instructions)
{
  bool pvsq_enable = false;
  for (int i = 0; i < instructions.size(); i++) {
    if (instructions[i].get_insn_opcode() == 3 && instructions[i].get_pea_insn_kind() == 1) {
      auto conv_insn = insn::convolution_execute(instructions[i]);
      if ((conv_insn.get_type_a() == kInt4 && conv_insn.get_type_b() == kInt4 && conv_insn.get_type_accumulator() == kFloat32)
          || (conv_insn.get_type_a() == kInt4 && conv_insn.get_type_b() == kInt8 && conv_insn.get_type_accumulator() == kFloat32)
          || (conv_insn.get_type_a() == kInt8 && conv_insn.get_type_b() == kInt4 && conv_insn.get_type_accumulator() == kFloat32)
          || (conv_insn.get_type_a() == kInt8 && conv_insn.get_type_b() == kInt8 && conv_insn.get_type_accumulator() == kFloat32)) {
        pvsq_enable = true;
      }
    }
    else if (instructions[i].get_insn_opcode() == 3 && instructions[i].get_pea_insn_kind() == 2) {
      auto gemm_insn = insn::gemm_execute(instructions[i]);
      if ((gemm_insn.get_type_a() == kInt4 && gemm_insn.get_type_b() == kInt4 && gemm_insn.get_type_accumulator() == kFloat32)
          || (gemm_insn.get_type_a() == kInt4 && gemm_insn.get_type_b() == kInt8 && gemm_insn.get_type_accumulator() == kFloat32)
          || (gemm_insn.get_type_a() == kInt8 && gemm_insn.get_type_b() == kInt4 && gemm_insn.get_type_accumulator() == kFloat32)
          || (gemm_insn.get_type_a() == kInt8 && gemm_insn.get_type_b() == kInt8 && gemm_insn.get_type_accumulator() == kFloat32)) {
        pvsq_enable = true;
      }
    }
  }
  return pvsq_enable;
}

bool check_sparse_enable(std::vector<insn::instruction>& instructions)
{
  (void)instructions;
  return false;
}

bool check_outlier_enable(std::vector<insn::instruction>& instructions)
{
  (void)instructions;
  return false;
}

bool check_conversion_enable(std::vector<insn::instruction>& instructions)
{
  bool conversion_enable = false;
  for (int i = 0; i < instructions.size(); i++) {
    if (instructions[i].get_insn_opcode() == 19 && instructions[i].get_vcu_insn_kind() == 2) {
      conversion_enable = true;
    }
  }
  return conversion_enable;
}

void pad_parallel_sync_word(std::vector<insn::instruction>& instructions, bool debug = false)
{
  bool vcu_enable        = check_vcu_enable(instructions);
  bool vcures_enable     = check_vcures_enable(instructions);
  bool vcupara_enable    = check_vcupara_enable(instructions);
  bool conversion_enable = check_conversion_enable(instructions);

  bool pvsq_enable    = check_pvsq_enable(instructions);
  bool sparse_enable  = check_sparse_enable(instructions);
  bool outlier_enable = check_outlier_enable(instructions);

  bool type_is_conv = conv_insn(instructions);
  bool type_is_gemm = gemm_insn(instructions);

  std::vector<insn::instruction> new_instruction;
  std::vector<long>              sync_word;
  std::vector<insn::instruction> new_instruction_pad_sync;

  int current_insn_ptr = 0;

  if (type_is_conv) {
    if (debug) {
      std::cout << "==== Pad Parallel Sync Words for Convolution instruction ====" << std::endl;
      std::cout << "VCU Enable: " << vcu_enable << std::endl;
      std::cout << "VCU ResAdd Enable: " << vcures_enable << std::endl;
      std::cout << "VCU Para Enable: " << vcupara_enable << std::endl;
      std::cout << "PVSQ Enable: " << pvsq_enable << std::endl;
      std::cout << "Sparse Enable: " << sparse_enable << std::endl;
      auto parser = common::insn::instruction_parser(instructions);
      parser.parse_instruction();
    }
    if (vcu_enable) {
      /** The first instruction is always pea config */
      assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 3,
                            std::to_string(current_insn_ptr) + "th instruction is not pea instruction"));
      assert(print_if_false(instructions[current_insn_ptr].get_pea_insn_kind() == 0,
                            std::to_string(current_insn_ptr) + "th instruction is not pea config instruction"));
      new_instruction.push_back(instructions[current_insn_ptr]);
      current_insn_ptr += 1;

      /** Then load vcu lut through dma0, and set insn number */
      assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                            std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
      auto load_vcu_lut = insn::load_iteration_2(instructions[1]);
      int  sram_addr    = load_vcu_lut.get_sram_addr();
      assert(print_if_false(sram_addr == MASTER_VCULUT_ADDR,
                            std::to_string(current_insn_ptr) + "th instruction is not load vcu lut instruction"));
      new_instruction.push_back(instructions[current_insn_ptr]);
      current_insn_ptr += 1;

      /** Check if the lut is configured as fast activation,
       * if so, load lut performs once,
       * otherwise, load lut four times */
      auto load_vcu_lut_1 = insn::load_iteration_2(instructions[current_insn_ptr]);
      if (load_vcu_lut_1.get_sram_addr() == MASTER_VCULUT_ADDR + 128) {
        load_vcu_lut.set_insn_number(3);
        new_instruction.push_back(instructions[current_insn_ptr]);
        current_insn_ptr += 1;
        new_instruction.push_back(instructions[current_insn_ptr]);
        current_insn_ptr += 1;
        new_instruction.push_back(instructions[current_insn_ptr]);
        current_insn_ptr += 1;
        new_instruction.push_back(instructions[current_insn_ptr]);
        current_insn_ptr += 1;
      }
      else {
        load_vcu_lut.set_insn_number(0);
      }

      /** Load vcu code
       * set dma 1 load vcu code
       */
      assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                            std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
      auto load_vcu_code = insn::load_iteration_2(instructions[current_insn_ptr]);
      assert(print_if_false(load_vcu_code.get_sram_addr() == MASTER_VCUCODE_ADDR,
                            std::to_string(current_insn_ptr) + "th instruction is not load vcu code instruction"));
      load_vcu_code.set_insn_opcode(35);
      load_vcu_code.set_ddr_addr(load_vcu_code.get_ddr_addr() | 0x2000000000);
      new_instruction.push_back(load_vcu_code);
      current_insn_ptr += 1;

      /**Vcu Config */
      assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 19,
                            std::to_string(current_insn_ptr) + "th instruction is not vcu config instruction"));
      auto vcu_config = insn::vcu_config(instructions[current_insn_ptr]);
      new_instruction.push_back(instructions[current_insn_ptr]);
      current_insn_ptr += 1;
      sync_word.push_back(0x400040005);

      int load_pingpong = 0;
      int pea_pingpong  = 0;

      int num_blocks    = 0;
      int num_oc_groups = 0;
      /** Count the number of blocks in h w and ic_group */
      for (int i = current_insn_ptr; i < instructions.size(); ++i) {
        if (instructions[i].get_insn_opcode() == 3 && instructions[i].get_pea_insn_kind() == 1) {
          num_blocks += 1;
        }
        if (instructions[i].get_insn_opcode() == 19) {
          break;
        }
      }
      for (int i = current_insn_ptr; i < instructions.size(); ++i) {
        if (instructions[i].get_insn_opcode() == 19 && instructions[i].get_vcu_insn_kind() == 1) {
          num_oc_groups += 1;
        }
      }

      if (debug) {
        std::cout << "Number of blocks: " << num_blocks << std::endl;
        std::cout << "Number of oc groups: " << num_oc_groups << std::endl;
      }

      for (int oc = 0; oc < num_oc_groups; ++oc) {
        for (int block = 0; block < num_blocks + 1; ++block) {
          /** The first sync word: load ifmap and weight */
          if (block == 0 && oc == 0) {
            sync_word.push_back(0x400000001);
            assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                  std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
            new_instruction.push_back(instructions[current_insn_ptr]);
            current_insn_ptr += 1;
            assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                  std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
            auto load_weight = insn::load_iteration_4(instructions[current_insn_ptr]);
            assert(print_if_false(load_weight.get_sram_addr() == MASTER_WEIGHT_ADDR,
                                  std::to_string(current_insn_ptr) + "th instruction is not load weight instruction"));
            load_weight.set_insn_opcode(35);
            load_weight.set_ddr_addr(load_weight.get_ddr_addr() | 0x2000000000);
            new_instruction.push_back(load_weight);
            current_insn_ptr += 1;
            load_pingpong = 1;
          }
          /** The last block */
          else if ((block == num_blocks && oc == 0) || (block == num_blocks - 1 && oc != 0)) {
            sync_word.push_back(0x400000005);

            assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 3,
                                  std::to_string(current_insn_ptr) + "th instruction is not pea instruction"));
            insn::convolution_execute pea_insn = insn::convolution_execute(instructions[current_insn_ptr]);
            current_insn_ptr += 1;
            assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                  std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
            auto load_vcupara = insn::load_iteration_3(instructions[current_insn_ptr]);
            assert(print_if_false(load_vcupara.get_sram_addr() == MASTER_VCUPARA_ADDR,
                                  std::to_string(current_insn_ptr) + "th instruction is not load vcupara instruction"));
            current_insn_ptr += 1;
            assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                  std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
            auto load_vcures = insn::load_iteration_4(instructions[current_insn_ptr]);
            load_vcures.set_insn_opcode(35);
            load_vcures.set_ddr_addr(load_vcures.get_ddr_addr() | 0x2000000000);
            assert(print_if_false(load_vcures.get_sram_addr() == MASTER_VCURES_ADDR,
                                  std::to_string(current_insn_ptr) + "th instruction is not load vcures instruction"));
            current_insn_ptr += 1;

            /** Ping pong */
            if (load_pingpong) {
              pea_insn.set_ifmap_highaddr(0);
              pea_insn.set_weight_highaddr(0);
            }
            else {
              pea_insn.set_ifmap_highaddr(1);
              pea_insn.set_weight_highaddr(1);
            }

            if (pea_pingpong) {
              pea_insn.set_psum_highaddr(1);
            }
            else {
              pea_insn.set_psum_highaddr(0);
            }

            if (debug) {
              std::cout << "========================================================================" << std::endl;
              std::cout << "oc = " << oc << ", block = " << block << std::endl;
              std::cout << "pea_pingpong = " << pea_pingpong << std::endl;
              std::cout << "pea_insn.ifmap_highaddr = " << pea_insn.get_ifmap_highaddr() << std::endl;
              std::cout << "pea_insn.weight_highaddr = " << pea_insn.get_weight_highaddr() << std::endl;
            }

            load_vcupara.set_insn();
            load_vcures.set_insn();
            pea_insn.set_insn();
            new_instruction.push_back(pea_insn);
            new_instruction.push_back(load_vcupara);
            new_instruction.push_back(load_vcures);

            if (oc != 0) {
              block += 1;
            }
          }
          else {
            if (oc != 0 && block == 0) {
              sync_word.push_back(0x400000007);

              assert(print_if_false(instructions[current_insn_ptr - 3].get_insn_opcode() == 2,
                                    std::to_string(current_insn_ptr - 3) + "th instruction is not store instruction"));
              new_instruction.push_back(instructions[current_insn_ptr - 3]);

              assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 3,
                                    std::to_string(current_insn_ptr) + "th instruction is not pea instruction"));
              insn::convolution_execute pea_insn = insn::convolution_execute(instructions[current_insn_ptr]);
              current_insn_ptr += 1;
              assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                    std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
              auto load_ifmap = insn::load_iteration_3(instructions[current_insn_ptr]);
              assert(print_if_false(load_ifmap.get_sram_addr() == MASTER_IFMAP_ADDR,
                                    std::to_string(current_insn_ptr) + "th instruction is not load ifmap instruction"));
              current_insn_ptr += 1;
              assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                    std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
              auto load_weight = insn::load_iteration_4(instructions[current_insn_ptr]);
              load_weight.set_insn_opcode(35);
              load_weight.set_ddr_addr(load_weight.get_ddr_addr() | 0x2000000000);
              assert(print_if_false(load_weight.get_sram_addr() == MASTER_WEIGHT_ADDR,
                                    std::to_string(current_insn_ptr) + "th instruction is not load weight instruction"));
              current_insn_ptr += 1;

              /** Ping pong */
              if (load_pingpong) {
                int current_ifmap_addr  = load_ifmap.get_sram_addr();
                int current_weight_addr = load_weight.get_sram_addr();

                load_ifmap.set_sram_addr(current_ifmap_addr + 256 * 16);
                load_weight.set_sram_addr(current_weight_addr + 512 * 16);

                pea_insn.set_ifmap_highaddr(0);
                pea_insn.set_weight_highaddr(0);
              }
              else {
                pea_insn.set_ifmap_highaddr(1);
                pea_insn.set_weight_highaddr(1);
              }

              if (pea_pingpong) {
                pea_insn.set_psum_highaddr(1);
              }
              else {
                pea_insn.set_psum_highaddr(0);
              }

              if (debug) {
                std::cout << "========================================================================" << std::endl;
                std::cout << "oc = " << oc << ", block = " << block << std::endl;
                std::cout << "load_pingpong = " << load_pingpong << std::endl;
                std::cout << "pea_pingpong = " << pea_pingpong << std::endl;
                std::cout << "load_ifmap.sram_addr = " << load_ifmap.get_sram_addr() << std::endl;
                std::cout << "load_weight.sram_addr = " << load_weight.get_sram_addr() << std::endl;
                std::cout << "pea_insn.ifmap_highaddr = " << pea_insn.get_ifmap_highaddr() << std::endl;
                std::cout << "pea_insn.weight_highaddr = " << pea_insn.get_weight_highaddr() << std::endl;
                std::cout << "Pad store instruction" << std::endl;
              }

              load_ifmap.set_insn();
              load_weight.set_insn();
              pea_insn.set_insn();
              new_instruction.push_back(pea_insn);
              new_instruction.push_back(load_ifmap);
              new_instruction.push_back(load_weight);

              load_pingpong = load_pingpong == 0 ? 1 : 0;
            }
            else {
              sync_word.push_back(0x400000005);
              assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 3,
                                    std::to_string(current_insn_ptr) + "th instruction is not pea instruction"));
              insn::convolution_execute pea_insn = insn::convolution_execute(instructions[current_insn_ptr]);
              current_insn_ptr += 1;

              assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                    std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
              auto load_ifmap = insn::load_iteration_3(instructions[current_insn_ptr]);
              assert(print_if_false(load_ifmap.get_sram_addr() == MASTER_IFMAP_ADDR,
                                    std::to_string(current_insn_ptr) + "th instruction is not load ifmap instruction"));

              current_insn_ptr += 1;

              assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                    std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
              auto load_weight = insn::load_iteration_4(instructions[current_insn_ptr]);
              load_weight.set_insn_opcode(35);
              load_weight.set_ddr_addr(load_weight.get_ddr_addr() | 0x2000000000);
              assert(print_if_false(load_weight.get_sram_addr() == MASTER_WEIGHT_ADDR,
                                    std::to_string(current_insn_ptr) + "th instruction is not load weight instruction"));
              current_insn_ptr += 1;

              /** Ping pong */
              if (load_pingpong) {
                int current_ifmap_addr  = load_ifmap.get_sram_addr();
                int current_weight_addr = load_weight.get_sram_addr();

                load_ifmap.set_sram_addr(current_ifmap_addr + 256 * 16);
                load_weight.set_sram_addr(current_weight_addr + 512 * 16);

                pea_insn.set_ifmap_highaddr(0);
                pea_insn.set_weight_highaddr(0);
              }
              else {
                pea_insn.set_ifmap_highaddr(1);
                pea_insn.set_weight_highaddr(1);
              }

              if (pea_pingpong) {
                pea_insn.set_psum_highaddr(1);
              }
              else {
                pea_insn.set_psum_highaddr(0);
              }

              if (debug) {
                std::cout << "========================================================================" << std::endl;
                std::cout << "oc = " << oc << ", block = " << block << std::endl;
                std::cout << "load_pingpong = " << load_pingpong << std::endl;
                std::cout << "pea_pingpong = " << pea_pingpong << std::endl;
                std::cout << "load_ifmap.sram_addr = " << load_ifmap.get_sram_addr() << std::endl;
                std::cout << "load_weight.sram_addr = " << load_weight.get_sram_addr() << std::endl;
                std::cout << "pea_insn.ifmap_highaddr = " << pea_insn.get_ifmap_highaddr() << std::endl;
                std::cout << "pea_insn.weight_highaddr = " << pea_insn.get_weight_highaddr() << std::endl;
              }

              load_ifmap.set_insn();
              load_weight.set_insn();
              pea_insn.set_insn();
              new_instruction.push_back(pea_insn);
              new_instruction.push_back(load_ifmap);
              new_instruction.push_back(load_weight);
              load_pingpong = load_pingpong == 0 ? 1 : 0;
            }
          }
        }
        if (oc == num_oc_groups - 1) {
          sync_word.push_back(0x40000);
          auto vcu_insn = insn::vcu_execute(instructions[current_insn_ptr]);
          if (!pea_pingpong) {
            vcu_insn.set_psum_in_addr(0);
            vcu_insn.set_ram_out_addr(256 * 16);
          }
          else {
            vcu_insn.set_psum_in_addr(256 * 16);
            vcu_insn.set_ram_out_addr(0);
          }
          current_insn_ptr += 1;
          if (conversion_enable) {
            vcu_insn.set_insn_number(1);
            vcu_insn.set_insn();
            auto vcu_convert = insn::vcu_parallelism_conversion(instructions[current_insn_ptr]);
            new_instruction.push_back(vcu_insn);

            if (!pea_pingpong) {
              vcu_convert.set_psum_read_base_addr(256 * 16);
            }
            else {
              vcu_convert.set_psum_read_base_addr(0);
            }

            new_instruction.push_back(vcu_convert);
            current_insn_ptr += 1;
          }
          assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 2,
                                std::to_string(current_insn_ptr) + "th instruction is not store instruction"));
          new_instruction.push_back(instructions[current_insn_ptr]);
          sync_word.push_back(0x2);
        }
        else {
          sync_word.push_back(0x400040001);

          assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 19,
                                std::to_string(current_insn_ptr) + "th instruction is not vcu config instruction"));
          auto vcu_insn = insn::vcu_execute(instructions[current_insn_ptr]);
          current_insn_ptr += 1;

          if (!pea_pingpong) {
            vcu_insn.set_psum_in_addr(0);
            vcu_insn.set_ram_out_addr(256 * 16);
          }
          else {
            vcu_insn.set_psum_in_addr(256 * 16);
            vcu_insn.set_ram_out_addr(0);
          }

          if (conversion_enable) {
            vcu_insn.set_insn_number(1);
            auto vcu_convert = insn::vcu_parallelism_conversion(instructions[current_insn_ptr]);
            vcu_insn.set_insn();
            new_instruction.push_back(vcu_insn);

            if (!pea_pingpong) {
              vcu_convert.set_psum_read_base_addr(256 * 16);
            }
            else {
              vcu_convert.set_psum_read_base_addr(0);
            }

            new_instruction.push_back(vcu_convert);
            current_insn_ptr += 2;
          }
          assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
          auto load_ifmap = insn::load_iteration_3(instructions[current_insn_ptr]);
          assert(print_if_false(load_ifmap.get_sram_addr() == MASTER_IFMAP_ADDR,
                                std::to_string(current_insn_ptr) + "th instruction is not load ifmap instruction"));
          current_insn_ptr += 1;
          assert(print_if_false(instructions[current_insn_ptr].get_insn_opcode() == 1,
                                std::to_string(current_insn_ptr) + "th instruction is not load instruction"));
          auto load_weight = insn::load_iteration_4(instructions[current_insn_ptr]);
          load_weight.set_insn_opcode(35);
          load_weight.set_ddr_addr(load_weight.get_ddr_addr() | 0x2000000000);
          assert(print_if_false(load_weight.get_sram_addr() == MASTER_WEIGHT_ADDR,
                                std::to_string(current_insn_ptr) + "th instruction is not load weight instruction"));
          current_insn_ptr += 1;

          /** Ping pong */
          if (load_pingpong) {
            int current_ifmap_addr  = load_ifmap.get_sram_addr();
            int current_weight_addr = load_weight.get_sram_addr();

            load_ifmap.set_sram_addr(current_ifmap_addr + 256 * 16);
            load_weight.set_sram_addr(current_weight_addr + 512 * 16);
          }

          if (debug) {
            std::cout << "========================================================================" << std::endl;
            std::cout << "oc = " << oc << " vcu + load ifmap & weight" << std::endl;
            std::cout << "load_pingpong = " << load_pingpong << std::endl;
            std::cout << "load_ifmap.sram_addr = " << load_ifmap.get_sram_addr() << std::endl;
            std::cout << "load_weight.sram_addr = " << load_weight.get_sram_addr() << std::endl;
          }

          load_ifmap.set_insn();
          load_weight.set_insn();
          new_instruction.push_back(load_ifmap);
          new_instruction.push_back(load_weight);
          pea_pingpong  = pea_pingpong == 0 ? 1 : 0;
          load_pingpong = load_pingpong == 0 ? 1 : 0;
        }
      }

      /** Pad sync instructions */
      std::vector<insn::instruction> sync_insns;

      int num_sync_word  = sync_word.size();
      int num_sync_insns = (num_sync_word + 2) / 3;
      int left_sync_word = num_sync_word % 3;

      for (int i = 0; i < num_sync_insns; i++) {
        if (left_sync_word == 0) {
          new_instruction_pad_sync.push_back(
            insn::synchronize_indie(3, sync_word[i * 3 + 2], sync_word[i * 3 + 1], sync_word[i * 3], 0, 0));
        }
        else {
          if (i != num_sync_word - 1) {
            new_instruction_pad_sync.push_back(
              insn::synchronize_indie(3, sync_word[i * 3 + 2], sync_word[i * 3 + 1], sync_word[i * 3], 0, 0));
          }
          else {
            if (left_sync_word == 1) {
              new_instruction_pad_sync.push_back(insn::synchronize_indie(1, 0, 0, sync_word[i * 3], 0, 0));
            }
            else {
              new_instruction_pad_sync.push_back(insn::synchronize_indie(2, 0, sync_word[i * 3 + 1], sync_word[i * 3], 0, 0));
            }
          }
        }
      }

      if (sync_insns.size() < 32) {
        for (auto iter : sync_insns) {
          new_instruction_pad_sync.push_back(iter);
        }
        new_instruction_pad_sync.insert(new_instruction_pad_sync.end(), new_instruction.begin(), new_instruction.end());
      }

      if (debug) {
        std::cout << "==== New instruction with Pad Parallel Sync Words ====" << std::endl;
        auto parser = common::insn::instruction_parser(new_instruction_pad_sync);
        parser.parse_instruction();
      }
    }
  }

  if (new_instruction_pad_sync.size() % 2 != 0) {
    new_instruction_pad_sync.push_back(insn::empty());
  }

  instructions = new_instruction_pad_sync;
}
};  // namespace multi_issue
