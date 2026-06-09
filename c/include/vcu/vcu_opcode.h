#pragma once

#include <cstdint>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <sstream>
#include <string>
#include <vector>
#include "compute_model/common/fp16.h"

namespace vcu {

enum OPCODE
{
  add                 = 0b000001,  // add
  mul                 = 0b000010,  // mul
  fma                 = 0b000011,  // fma
  comp_great_eq       = 0b000100,  // compgeq
  comp_less           = 0b000101,  // compless
  divm                = 0b000110,  // divm
  sqrt                = 0b000111,  // sqrt
  sin                 = 0b001000,  // sin
  cos                 = 0b001001,  // cos
  reciprocal          = 0b001010,  // rec
  log2                = 0b001011,  // log2
  exp2                = 0b001100,  // exp2
  rsqrt               = 0b001101,  // rsqrt
  masked_broadcast    = 0b001110,  // maskb
  masked_copy         = 0b001111,  // maskc
  reduce_sum          = 0b010000,  // redsum
  reduce_max          = 0b010001,  // redmax
  reduce_min          = 0b010010,  // redmin
  config              = 0b010011,  // config
  loop                = 0b010100,  // loop
  add_constant        = 0b010101,  // addc
  mul_constant        = 0b010110,  // mulc
  div_constant        = 0b010111,  // divc
  inv                 = 0b011000,  // inv
  absm                = 0b011001,  // absm
  copy                = 0b011010,  // copy
  tanh                = 0b011101,  // tanh
  tanh_fast           = 0b100010,  // fasttanh
  sigmoid_fast        = 0b100011,  // fastsig
  swish_fast          = 0b100100,  // fastswish
  mish_fast           = 0b100101,  // fastmish
  gelu_fast           = 0b100110,  // fastgelu
  change_para         = 0b100111,  // chpara
  softplus            = 0b101000,  // softplus
  selu                = 0b101001,  // selu
  outlier_compress    = 0b101010,  // outlier_compress
  comp_great          = 0b101011,  // compgreat
  comp_less_eq        = 0b101100,  // compleq
  read_cross_ocgroup  = 0b101101,  // read_cross_ocgroup
  write_cross_ocgroup = 0b101110   // write_cross_ocgroup
};

enum SRC_REG
{
  iteration_reg_0  = 0b0000000,  // reg0
  iteration_reg_1  = 0b0000001,  // reg1
  iteration_reg_2  = 0b0000010,  // reg2
  iteration_reg_3  = 0b0000011,  // reg3
  iteration_reg_4  = 0b0000100,  // reg4
  iteration_reg_5  = 0b0000101,  // reg5
  iteration_reg_6  = 0b0000110,  // reg6
  iteration_reg_7  = 0b0000111,  // reg7
  iteration_reg_8  = 0b0001000,  // reg8
  iteration_reg_9  = 0b0001001,  // reg9
  iteration_reg_10 = 0b0001010,  // reg10
  iteration_reg_11 = 0b0001011,  // reg11
  iteration_reg_12 = 0b0001100,  // reg12
  iteration_reg_13 = 0b0001101,  // reg13
  iteration_reg_14 = 0b0001110,  // reg14
  iteration_reg_15 = 0b0001111,  // reg15
  psum_ram         = 0b1000000,  // psum
  resadd_ram       = 0b1000001,  // resadd
  para_ram         = 0b1000010,  // para
  ifmap_ram        = 0b1000011   // ifmap
};

uint64_t as_op(uint64_t operation, uint64_t src, uint64_t dst)
{
  return ((operation & 0x3f) << 0) | ((src & 0x7f) << 6) | ((dst & 0x3f) << 13);
}

uint64_t as_op(uint64_t operation, uint64_t src_a, uint64_t src_b, uint64_t dst)
{
  return ((operation & 0x3f) << 0) | ((src_a & 0x7f) << 6) | ((dst & 0x3f) << 13) | ((src_b & 0x7f) << 19);
}

uint64_t as_op(uint64_t operation, uint64_t src_a, uint64_t src_b, uint64_t src_c, uint64_t dst)
{
  return ((operation & 0x3f) << 0) | ((src_a & 0x7f) << 6) | ((dst & 0x3f) << 13) | ((src_b & 0x7f) << 19) | ((src_c & 0x7f) << 26);
}

uint64_t as_op(uint64_t operation, uint64_t src_a, uint64_t src_b, uint64_t src_c, uint64_t src_d, uint64_t dst)
{
  return ((operation & 0x3f) << 0) | ((src_a & 0x7f) << 6) | ((dst & 0x3f) << 13) | ((src_b & 0x7f) << 19) | ((src_c & 0x7f) << 26)
         | ((src_d & 0x7f) << 33);
}

uint64_t as_op(uint64_t operation, uint64_t dst, float data)
{
  uint64_t data_bits = 0;
  std::memcpy(&data_bits, &data, sizeof(float));
  return ((operation & 0x3f) << 0) | ((dst & 0x3f) << 6) | ((data_bits & 0xffffffff) << 12);
}

uint64_t maskb(uint64_t src, uint64_t dst, uint64_t mask, uint64_t receive_id)
{
  return ((masked_broadcast & 0x3f) << 0) | ((src & 0x7f) << 6) | ((dst & 0x3f) << 13) | ((mask & 0x3f) << 19)
         | ((receive_id & 0xffffffff) << 25);
}

uint64_t maskc(uint64_t src, uint64_t dst, uint64_t mask)
{
  return ((masked_broadcast & 0x3f) << 0) | ((src & 0x7f) << 6) | ((dst & 0x3f) << 13) | ((mask & 0xffffffff) << 19);
}

uint64_t reduce(uint64_t operation, uint64_t src, uint64_t dst, uint64_t valid_items)
{
  return ((operation & 0x3f) << 0) | ((src & 0x7f) << 6) | ((dst & 0x3f) << 13) | ((valid_items & 0x3f) << 19);
}

uint64_t loop_(uint64_t times, uint64_t initial, uint64_t end, uint64_t loop_addr)
{
  return ((loop & 0x3f) << 0) | ((times & 0xffffffff) << 6) | ((initial & 0x7f) << 38) | ((end & 0x7f) << 45) | ((loop_addr & 0x7f) << 52);
}

uint64_t imm(uint64_t constant, uint64_t src, uint64_t dst, uint16_t data_bits)
{
  return ((constant & 0x3f) << 0) | ((src & 0x7f) << 6) | ((dst & 0x3f) << 13) | ((uint64_t(data_bits) & 0xffff) << 19);
}

std::string trim_copy(const std::string& str)
{
  const auto begin = str.find_first_not_of(" \t\n\r");
  if (begin == std::string::npos) {
    return "";
  }
  const auto end = str.find_last_not_of(" \t\n\r");
  return str.substr(begin, end - begin + 1);
}

uint16_t fp16_imm_decode(const std::string& data_s)
{
  const std::string data = trim_copy(data_s);
  if (data.size() > 2 && data[0] == '0' && (data[1] == 'x' || data[1] == 'X')) {
    const auto raw = std::stoul(data, nullptr, 16);
    if (raw > 0xffff) {
      throw std::runtime_error("VCU fp16 immediate hex literal exceeds 16 bits: " + data);
    }
    return static_cast<uint16_t>(raw);
  }

  using half = compute_model::common::fp16::half;
  return half(std::stof(data)).storage;
}

uint64_t read_cross_ocgroup_op(int32_t sign)
{
  return ((read_cross_ocgroup & 0x3f) << 0) | ((sign & 0x1) << 6);
}

uint64_t write_cross_ocgroup_op(int32_t sign, int32_t sram_id, int32_t dtype, int dst)
{
  return ((write_cross_ocgroup & 0x3f) << 0) | ((sign & 0x1) << 6) | ((sram_id & 0x3) << 7) | ((dtype & 0x7) << 9) | ((dst & 0x3f) << 13);
}

uint64_t opcode_decode(std::string opcode)
{
  if (opcode == "add")
    return add;
  if (opcode == "mul")
    return mul;
  if (opcode == "fma")
    return fma;
  if (opcode == "compgeq")
    return comp_great_eq;
  if (opcode == "compless")
    return comp_less;
  if (opcode == "divm")
    return divm;
  if (opcode == "sqrt")
    return sqrt;
  if (opcode == "sin")
    return sin;
  if (opcode == "cos")
    return cos;
  if (opcode == "rec")
    return reciprocal;
  if (opcode == "log2")
    return log2;
  if (opcode == "exp2")
    return exp2;
  if (opcode == "rsqrt")
    return rsqrt;
  if (opcode == "maskb")
    return masked_broadcast;
  if (opcode == "maskc")
    return masked_copy;
  if (opcode == "redsum")
    return reduce_sum;
  if (opcode == "redmax")
    return reduce_max;
  if (opcode == "redmin")
    return reduce_min;
  if (opcode == "config")
    return config;
  if (opcode == "loop")
    return loop;
  if (opcode == "addc")
    return add_constant;
  if (opcode == "mulc")
    return mul_constant;
  if (opcode == "divc")
    return div_constant;
  if (opcode == "inv")
    return inv;
  if (opcode == "absm")
    return absm;
  if (opcode == "copy")
    return copy;
  if (opcode == "tanh")
    return tanh;
  if (opcode == "fasttanh")
    return tanh_fast;
  if (opcode == "fastsig")
    return sigmoid_fast;
  if (opcode == "fastswish")
    return swish_fast;
  if (opcode == "fastmish")
    return mish_fast;
  if (opcode == "fastgelu")
    return gelu_fast;
  if (opcode == "chpara")
    return change_para;
  if (opcode == "softplus")
    return softplus;
  if (opcode == "selu")
    return selu;
  if (opcode == "outlier_compress")
    return outlier_compress;
  if (opcode == "compgreat")
    return comp_great;
  if (opcode == "compleq")
    return comp_less_eq;
  if (opcode == "rdcrossoc")
    return read_cross_ocgroup;
  if (opcode == "wrcrossoc")
    return write_cross_ocgroup;
  std::runtime_error("Invalid opcode");
  return 0;
}

uint64_t src_decode(std::string src)
{
  if (src == "reg0")
    return iteration_reg_0;
  if (src == "reg1")
    return iteration_reg_1;
  if (src == "reg2")
    return iteration_reg_2;
  if (src == "reg3")
    return iteration_reg_3;
  if (src == "reg4")
    return iteration_reg_4;
  if (src == "reg5")
    return iteration_reg_5;
  if (src == "reg6")
    return iteration_reg_6;
  if (src == "reg7")
    return iteration_reg_7;
  if (src == "reg8")
    return iteration_reg_8;
  if (src == "reg9")
    return iteration_reg_9;
  if (src == "reg10")
    return iteration_reg_10;
  if (src == "reg11")
    return iteration_reg_11;
  if (src == "reg12")
    return iteration_reg_12;
  if (src == "reg13")
    return iteration_reg_13;
  if (src == "reg14")
    return iteration_reg_14;
  if (src == "reg15")
    return iteration_reg_15;
  if (src == "psum")
    return psum_ram;
  if (src == "resadd")
    return resadd_ram;
  if (src == "para")
    return para_ram;
  if (src == "ifmap")
    return ifmap_ram;
  std::runtime_error("Invalid src");
  return 0;
}

uint64_t dst_decode(std::string dst)
{
  if (dst == "reg0")
    return iteration_reg_0;
  if (dst == "reg1")
    return iteration_reg_1;
  if (dst == "reg2")
    return iteration_reg_2;
  if (dst == "reg3")
    return iteration_reg_3;
  if (dst == "reg4")
    return iteration_reg_4;
  if (dst == "reg5")
    return iteration_reg_5;
  if (dst == "reg6")
    return iteration_reg_6;
  if (dst == "reg7")
    return iteration_reg_7;
  if (dst == "reg8")
    return iteration_reg_8;
  if (dst == "reg9")
    return iteration_reg_9;
  if (dst == "reg10")
    return iteration_reg_10;
  if (dst == "reg11")
    return iteration_reg_11;
  if (dst == "reg12")
    return iteration_reg_12;
  if (dst == "reg13")
    return iteration_reg_13;
  if (dst == "reg14")
    return iteration_reg_14;
  if (dst == "reg15")
    return iteration_reg_15;
  std::runtime_error("Invalid dst");
  return 0;
}

std::vector<uint64_t> asm_vcu_op(std::vector<std::string> code, bool debug = false)
{
  std::vector<uint64_t> opcodes;
  for (auto line : code) {
    std::string op = line.substr(0, line.find(" "));
    if (op == "add" || op == "mul" || op == "divm") {  //"add src_a src_b, dst"
      std::string src_a = line.substr(line.find(" ") + 1, line.find(" ", line.find(" ") + 1) - line.find(" ") - 1);
      std::string src_b = line.substr(line.find(" ", line.find(" ") + 1) + 1, line.find(",") - line.find(" ", line.find(" ") + 1) - 1);
      std::string dst   = line.substr(line.find("", line.find(",") + 1) + 1);
      if (debug) {
        std::cout << "op: " << op << " src_a: " << src_a << " src_b: " << src_b << " dst: " << dst << std::endl;
      }
      opcodes.push_back(as_op(opcode_decode(op), src_decode(src_a), src_decode(src_b), dst_decode(dst)));
    }
    else if (op == "sin" || op == "cos" || op == "exp2" || op == "log2" || op == "absm" || op == "inv" || op == "sqrt" || op == "rsqrt"
             || op == "rec" || op == "copy" || op == "tanh" || op == "fasttanh" || op == "fastsig" || op == "fastswish" || op == "fastmish"
             || op == "fastgelu" || op == "outlier_compress") {
      std::string src = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string dst = line.substr(line.find(" ", line.find(",") + 1) + 1);
      if (debug) {
        std::cout << "op: " << op << " src: " << src << " dst: " << dst << std::endl;
      }
      opcodes.push_back(as_op(opcode_decode(op), src_decode(src), dst_decode(dst)));
    }
    else if (op == "fma") {  //"fma src_a, src_b, src_c, dst"
      std::string src_a = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string src_b =
        line.substr(line.find(" ", line.find(",") + 1) + 1, line.find(",", line.find(",") + 1) - line.find(" ", line.find(",") + 1) - 1);
      std::string src_c = line.substr(line.find(",", line.find(",") + 1) + 2,
                                      line.find(",", line.find(",", line.find(",") + 1) + 1) - line.find(",", line.find(",") + 1) - 2);
      std::string dst   = line.substr(line.find(",", line.find(",", line.find(",") + 1) + 1) + 2);
      if (debug) {
        std::cout << "op: " << op << " src_a: " << src_a << " src_b: " << src_b << " src_c: " << src_c << " dst: " << dst << std::endl;
      }
      opcodes.push_back(as_op(opcode_decode(op), src_decode(src_a), src_decode(src_b), src_decode(src_c), dst_decode(dst)));
    }
    else if (op == "compgeq" || op == "compleq" || op == "compgreat" || op == "compless") {  // "complg src_a, src_b, src_c, src_d, dst"
      std::string src_a = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string src_b =
        line.substr(line.find(" ", line.find(",") + 1) + 1, line.find(",", line.find(",") + 1) - line.find(" ", line.find(",") + 1) - 1);
      std::string src_c = line.substr(line.find(",", line.find(",") + 1) + 2,
                                      line.find(",", line.find(",", line.find(",") + 1) + 1) - line.find(",", line.find(",") + 1) - 2);
      std::string src_d = line.substr(line.find(",", line.find(",", line.find(",") + 1) + 1) + 2,
                                      line.find(",", line.find(",", line.find(",", line.find(",") + 1) + 1) + 1)
                                        - line.find(",", line.find(",", line.find(",") + 1) + 1) - 2);
      std::string dst   = line.substr(line.find(",", line.find(",", line.find(",", line.find(",") + 1) + 1) + 1) + 2);
      if (debug) {
        std::cout << "op: " << op << " src_a: " << src_a << " src_b: " << src_b << " src_c: " << src_c << " src_d: " << src_d
                  << " dst: " << dst << std::endl;
      }
      opcodes.push_back(
        as_op(opcode_decode(op), src_decode(src_a), src_decode(src_b), src_decode(src_c), src_decode(src_d), dst_decode(dst)));
    }
    else if (op == "maskb") {  //"maskb src, dst, mask, receive_id"
      std::string src = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string dst =
        line.substr(line.find(" ", line.find(",") + 1) + 1, line.find(",", line.find(",") + 1) - line.find(" ", line.find(",") + 1) - 1);
      std::string mask         = line.substr(line.find(",", line.find(",") + 1) + 2);
      std::string receive_id   = line.substr(line.find(",", line.find(mask) + 1) + 2);
      uint32_t    mask_i       = std::stoi(mask);
      uint32_t    receive_id_i = std::stoi(receive_id);
      if (debug) {
        std::cout << "op: " << op << " src: " << src << " dst: " << dst << " mask: " << mask << " receive_id: " << receive_id << std::endl;
      }
      opcodes.push_back(maskb(src_decode(src), dst_decode(dst), mask_i, receive_id_i));
    }
    else if (op == "maskc") {  //"maskb src, dst, mask"
      std::string src = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string dst =
        line.substr(line.find(" ", line.find(",") + 1) + 1, line.find(",", line.find(",") + 1) - line.find(" ", line.find(",") + 1) - 1);
      std::string mask   = line.substr(line.find(",", line.find(",") + 1) + 2);
      uint32_t    mask_i = std::stoi(mask);
      if (debug) {
        std::cout << "op: " << op << " src: " << src << " dst: " << dst << " mask: " << mask << std::endl;
      }
      opcodes.push_back(maskc(src_decode(src), dst_decode(dst), mask_i));
    }
    else if (op == "redsum" || op == "redmax" || op == "redmin") {  // "redsum src, dst, valid_items"
      std::string src = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string dst =
        line.substr(line.find(" ", line.find(",") + 1) + 1, line.find(",", line.find(",") + 1) - line.find(" ", line.find(",") + 1) - 1);
      std::string valid_items   = line.substr(line.find(",", line.find(",") + 1) + 2);
      int         valid_items_i = std::stoi(valid_items);
      if (debug) {
        std::cout << "op: " << op << " src: " << src << " dst: " << dst << " valid_items: " << valid_items << std::endl;
      }
      opcodes.push_back(reduce(opcode_decode(op), src_decode(src), dst_decode(dst), valid_items_i));
    }
    else if (op == "loop") {  // "loop times, initial, end, loop_addr"
      std::string times = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string initial =
        line.substr(line.find(" ", line.find(",") + 1) + 1, line.find(",", line.find(",") + 1) - line.find(" ", line.find(",") + 1) - 1);
      std::string end       = line.substr(line.find(",", line.find(",") + 1) + 2,
                                    line.find(",", line.find(",", line.find(",") + 1) + 1) - line.find(",", line.find(",") + 1) - 2);
      std::string loop_addr = line.substr(line.find(",", line.find(",", line.find(",") + 1) + 1) + 2);
      if (debug) {
        std::cout << "op: " << op << " times: " << times << " initial: " << initial << " end: " << end << " loop_addr: " << loop_addr
                  << std::endl;
      }
      opcodes.push_back(loop_(std::stoi(times), std::stoi(initial), std::stoi(end), std::stoi(loop_addr)));
    }
    else if (op == "addc" || op == "mulc" || op == "divc") {
      std::string src = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string dst =
        line.substr(line.find(" ", line.find(",") + 1) + 1, line.find(",", line.find(",") + 1) - line.find(" ", line.find(",") + 1) - 1);
      std::string data_s = line.substr(line.find(" ", line.find(",", line.find(",") + 1) + 1) + 1);
      uint16_t    data   = fp16_imm_decode(data_s);
      if (debug) {
        std::cout << "op: " << op << " src: " << src << " dst: " << dst << " data_fp16: 0x" << std::hex << data << std::dec
                  << std::endl;
      }
      opcodes.push_back(imm(opcode_decode(op), src_decode(src), dst_decode(dst), data));
    }
    else if (op == "chpara") {
      opcodes.push_back(change_para);
    }
    else if (op == "rdcrossoc") {
      std::string sign = line.substr(line.find(" ") + 1);
      opcodes.push_back(read_cross_ocgroup_op(std::stoi(sign)));
    }
    else if (op == "wrcrossoc") {
      std::string sign = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string sram =
        line.substr(line.find(" ", line.find(",") + 1) + 1, line.find(",", line.find(",") + 1) - line.find(" ", line.find(",") + 1) - 1);
      std::string dtype = line.substr(line.find(",", line.find(",") + 1) + 2);
      std::string dst   = line.substr(line.find(",", line.find(",", line.find(",") + 1) + 1) + 2);
      opcodes.push_back(write_cross_ocgroup_op(std::stoi(sign), std::stoi(sram), std::stoi(dtype), dst_decode(dst)));
    }
    else if (op == "config") {
      std::string dst    = line.substr(line.find(" ") + 1, line.find(",") - line.find(" ") - 1);
      std::string data_s = line.substr(line.find(" ", line.find(dst) + 1) + 1);
      if (data_s.find("0x") != std::string::npos) {
        uint32_t data = std::stol(data_s, nullptr, 16);
        opcodes.push_back(as_op(opcode_decode(op), dst_decode(dst), *(float*)(&data)));
        if(debug){
          std::cout << "op: " << op << " dst: " << dst << " data: " << data << std::endl;
        }
      }
      else {
        float             data;
        std::stringstream ss;
        ss << data_s;
        ss >> data;
        opcodes.push_back(as_op(opcode_decode(op), dst_decode(dst), data));
      }
    }
    else {
      std::runtime_error("Invalid opcode");
    }
  }

  return opcodes;
}

}  // namespace vcu
