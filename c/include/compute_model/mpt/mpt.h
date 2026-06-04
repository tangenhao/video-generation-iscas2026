#pragma once

#include <cstdint>
#include <iostream>

#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/gen_data.h"
#include "compute_model/mpt/adder_float.h"
#include "compute_model/mpt/multiplier_fp16.h"
#include "compute_model/mpt/multiplier_int4.h"

namespace compute_model {
namespace mpt {
int32_t MptInt4(int8_t* a, int8_t* b, int32_t bias, bool debug)
{
  int32_t  result     = 0;
  int32_t* mul_result = new int32_t[64];
  for (int i = 0; i < 64; i++) {
    mul_result[i] = (int32_t)a[i] * (int32_t)b[i];
  }

  if (debug) {
    std::cout << "==== INFO - MULTIPLIER INPUT AND RESULT ====" << std::endl;
    for (int i = 0; i < 64; i++) {
      std::cout << "a[" << std::dec << i << std::hex << "] = " << (int32_t)a[i] << std::endl;
    }
    for (int i = 0; i < 64; i++) {
      std::cout << "b[" << std::dec << i << std::hex << "] = " << (int32_t)b[i] << std::endl;
    }
    for (int i = 0; i < 64; i++) {
      std::cout << "mul_result[" << std::dec << i << std::hex << "] = " << mul_result[i] << std::endl;
    }
  }

  int32_t* add_result_0 = new int32_t[32];
  for (int i = 0; i < 8; i++) {
    add_result_0[4 * i]     = mul_result[8 * i] + mul_result[8 * i + 4];
    add_result_0[4 * i + 1] = mul_result[8 * i + 1] + mul_result[8 * i + 5];
    add_result_0[4 * i + 2] = mul_result[8 * i + 2] + mul_result[8 * i + 6];
    add_result_0[4 * i + 3] = mul_result[8 * i + 3] + mul_result[8 * i + 7];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 32; i++) {
      std::cout << "add_result_0[" << i << "] = " << add_result_0[i] << std::endl;
    }
  }

  int32_t* add_result_1 = new int32_t[16];
  for (int i = 0; i < 4; i++) {
    add_result_1[4 * i]     = add_result_0[8 * i] + add_result_0[8 * i + 4];
    add_result_1[4 * i + 1] = add_result_0[8 * i + 1] + add_result_0[8 * i + 5];
    add_result_1[4 * i + 2] = add_result_0[8 * i + 2] + add_result_0[8 * i + 6];
    add_result_1[4 * i + 3] = add_result_0[8 * i + 3] + add_result_0[8 * i + 7];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 16; i++) {
      std::cout << "add_result_1[" << i << "] = " << add_result_1[i] << std::endl;
    }
  }

  int32_t* add_result_2 = new int32_t[8];
  for (int i = 0; i < 2; i++) {
    add_result_2[4 * i]     = add_result_1[8 * i] + add_result_1[8 * i + 4];
    add_result_2[4 * i + 1] = add_result_1[8 * i + 1] + add_result_1[8 * i + 5];
    add_result_2[4 * i + 2] = add_result_1[8 * i + 2] + add_result_1[8 * i + 6];
    add_result_2[4 * i + 3] = add_result_1[8 * i + 3] + add_result_1[8 * i + 7];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 8; i++) {
      std::cout << "add_result_2[" << i << "] = " << add_result_2[i] << std::endl;
    }
  }

  int32_t* add_result_3 = new int32_t[3];
  for (int i = 0; i < 1; i++) {
    add_result_3[4 * i]     = add_result_2[8 * i] + add_result_2[8 * i + 4];
    add_result_3[4 * i + 1] = add_result_2[8 * i + 1] + add_result_2[8 * i + 5];
    add_result_3[4 * i + 2] = add_result_2[8 * i + 2] + add_result_2[8 * i + 6];
    add_result_3[4 * i + 3] = add_result_2[8 * i + 3] + add_result_2[8 * i + 7];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 4; i++) {
      std::cout << "add_result_3[" << i << "] = " << add_result_3[i] << std::endl;
    }
  }

  int32_t* add_result_4 = new int32_t[2];
  add_result_4[0]       = add_result_3[0] + add_result_3[2];
  add_result_4[1]       = add_result_3[1] + add_result_3[3];

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 2; i++) {
      std::cout << "add_result_4[" << i << "] = " << add_result_4[i] << std::endl;
    }
  }

  result = add_result_4[0] + add_result_4[1];

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    std::cout << "result = " << result << std::endl;
  }

  delete[] mul_result;
  delete[] add_result_0;
  delete[] add_result_1;
  delete[] add_result_2;
  delete[] add_result_3;
  delete[] add_result_4;

  result = result + bias;

  if (debug) {
    std::cout << "==== INFO - FINAL RESULT ====" << std::endl;
    std::cout << "result = " << result << std::endl;
  }

  return result;
}

int32_t MptInt8(int8_t* a, int8_t* b, int32_t bias, bool debug)
{
  int32_t result = 0;

  uint32_t* mul_result = new uint32_t[32];
  for (int i = 0; i < 32; i++) {
    mul_result[i] = (uint32_t)a[i] * (uint32_t)b[i];
  }

  if (debug) {
    std::cout << "==== INFO - MULTIPLIER INPUT AND RESULT ====" << std::endl;
    for (int i = 0; i < 32; i++) {
      std::cout << "a[" << std::dec << i << std::hex << "] = " << (int)a[i] << std::endl;
    }
    for (int i = 0; i < 32; i++) {
      std::cout << "b[" << std::dec << i << std::hex << "] = " << (int)b[i] << std::endl;
    }
    for (int i = 0; i < 32; i++) {
      std::cout << "mul_result[" << std::dec << i << std::hex << "] = " << mul_result[i] << std::endl;
    }
  }

  int32_t* add_result_0 = new int32_t[16];
  for (int i = 0; i < 8; i++) {
    add_result_0[2 * i]     = mul_result[4 * i] + mul_result[4 * i + 2];
    add_result_0[2 * i + 1] = mul_result[4 * i + 1] + mul_result[4 * i + 3];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 16; i++) {
      std::cout << "add_result_0[" << i << "] = " << add_result_0[i] << std::endl;
    }
  }

  int32_t* add_result_1 = new int32_t[8];
  for (int i = 0; i < 4; i++) {
    add_result_1[2 * i]     = add_result_0[4 * i] + add_result_0[4 * i + 2];
    add_result_1[2 * i + 1] = add_result_0[4 * i + 1] + add_result_0[4 * i + 3];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 8; i++) {
      std::cout << "add_result_1[" << i << "] = " << add_result_1[i] << std::endl;
    }
  }

  int32_t* add_result_2 = new int32_t[4];

  for (int i = 0; i < 2; i++) {
    add_result_2[2 * i]     = add_result_1[4 * i] + add_result_1[4 * i + 2];
    add_result_2[2 * i + 1] = add_result_1[4 * i + 1] + add_result_1[4 * i + 3];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 4; i++) {
      std::cout << "add_result_2[" << i << "] = " << add_result_2[i] << std::endl;
    }
  }

  int32_t* add_result_3 = new int32_t[2];
  for (int i = 0; i < 1; i++) {
    add_result_3[2 * i]     = add_result_2[4 * i] + add_result_2[4 * i + 2];
    add_result_3[2 * i + 1] = add_result_2[4 * i + 1] + add_result_2[4 * i + 3];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 2; i++) {
      std::cout << "add_result_3[" << i << "] = " << add_result_3[i] << std::endl;
    }
  }

  result = add_result_3[0] + add_result_3[1];

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    std::cout << "result = " << result << std::endl;
  }

  delete[] mul_result;
  delete[] add_result_0;
  delete[] add_result_1;
  delete[] add_result_2;
  delete[] add_result_3;

  result = result + bias;

  if (debug) {
    std::cout << "==== INFO - FINAL RESULT ====" << std::endl;
    std::cout << "result = " << result << std::endl;
  }

  return result;
}

float MptFloat(uint16_t* a, uint16_t* b, float bias, int8_t mode_a, int8_t mode_b, bool mode_accumulator, bool debug)
{

  int32_t* result_mul = new int32_t[16];
  for (int i = 0; i < 16; i++) {
    result_mul[i] = mpt::multiplier::MultiplierFloat16Fused(a[i], b[i], mode_a, mode_b, debug);
  }

  if (debug) {
    std::cout << "==== INFO - MULTIPLIER INPUT AND RESULT ====" << std::endl;
    for (int i = 0; i < 16; i++) {
      std::cout << "a[" << i << "] = " << std::hex << a[i] << std::endl;
    }
    for (int i = 0; i < 16; i++) {
      std::cout << "b[" << i << "] = " << std::hex << b[i] << std::endl;
    }
    for (int i = 0; i < 16; i++) {
      std::cout << "result_mul[" << i << "] = " << result_mul[i] << std::endl;
    }
  }

  int32_t* result_add_0 = new int32_t[8];
  for (int i = 0; i < 8; i++) {
    result_add_0[i] = mpt::adder::AdderFloat(result_mul[i * 2], result_mul[i * 2 + 1], false);
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 8; i++) {
      std::cout << "result_add_0[" << i << "] = " << std::hex << result_add_0[i] << std::endl;
    }
  }

  int32_t* result_add_1 = new int32_t[4];
  for (int i = 0; i < 4; i++) {
    result_add_1[i] = mpt::adder::AdderFloat(result_add_0[i * 2], result_add_0[i * 2 + 1], false);
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 4; i++) {
      std::cout << "result_add_1[" << i << "] = " << std::hex << result_add_1[i] << std::endl;
    }
  }

  int32_t* result_add_2 = new int32_t[2];
  for (int i = 0; i < 2; i++) {
    result_add_2[i] = mpt::adder::AdderFloat(result_add_1[i * 2], result_add_1[i * 2 + 1], false);
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 2; i++) {
      std::cout << "result_add_2[" << i << "] = " << std::hex << result_add_2[i] << std::endl;
    }
  }

  int32_t result_add_3 = mpt::adder::AdderFloat(result_add_2[0], result_add_2[1], false);

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    std::cout << "result_add_3 = " << std::hex << result_add_3 << std::endl;
  }

  uint32_t result_float_bits = ((result_add_3 & 0x20000000) << 2) | ((result_add_3 & 0x1fe00000) << 2) | ((result_add_3 & 0x000fffff) << 3);
  // std::cout << "result_float_bits = " << std::hex << result_float_bits << std::endl;
  float result_float = *(float*)&result_float_bits;

  delete[] result_mul;
  delete[] result_add_0;
  delete[] result_add_1;
  delete[] result_add_2;

  if (debug) {

    std::cout << "result_float = " << result_float << std::endl;
    std::cout << "result_float = " << *(uint32_t*)&result_float << std::endl;
  }

  result_float = result_float + bias;

  if (debug) {
    std::cout << "==== INFO - FINAL RESULT ====" << std::endl;
    std::cout << "bias = " << bias << std::endl;
    std::cout << "result_float_add_bias = " << result_float << std::endl;
    std::cout << "result_float_add_bias = " << *(uint32_t*)&result_float << std::endl;
  }
  return result_float;
}

int32_t MptInt16(int16_t* a, int16_t* b, int32_t bias, bool debug)
{
  int32_t result = 0;

  int32_t* mul_result = new int32_t[16];
  for (int i = 0; i < 16; i++) {
    mul_result[i] = (int32_t)a[i] * (int32_t)b[i];
  }

  if (debug) {
    std::cout << "==== INFO - MULTIPLIER INPUT AND RESULT ====" << std::endl;
    for (int i = 0; i < 16; i++) {
      std::cout << "a[" << std::dec << i << std::hex << "] = " << (int32_t)a[i] << std::endl;
    }
    for (int i = 0; i < 16; i++) {
      std::cout << "b[" << std::dec << i << std::hex << "] = " << (int32_t)b[i] << std::endl;
    }
    for (int i = 0; i < 16; i++) {
      std::cout << "mul_result[" << std::dec << i << std::hex << "] = " << mul_result[i] << std::endl;
    }
  }

  int32_t* add_result_0 = new int32_t[8];
  for (int i = 0; i < 8; i++) {
    add_result_0[i] = mul_result[2 * i] + mul_result[2 * i + 1];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 8; i++) {
      std::cout << "add_result_0[" << i << "] = " << add_result_0[i] << std::endl;
    }
  }

  int32_t* add_result_1 = new int32_t[4];
  for (int i = 0; i < 4; i++) {
    add_result_1[i] = add_result_0[2 * i] + add_result_0[2 * i + 1];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 4; i++) {
      std::cout << "add_result_1[" << i << "] = " << add_result_1[i] << std::endl;
    }
  }

  int32_t* add_result_2 = new int32_t[2];
  for (int i = 0; i < 2; i++) {
    add_result_2[i] = add_result_1[2 * i] + add_result_1[2 * i + 1];
  }

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    for (int i = 0; i < 2; i++) {
      std::cout << "add_result_2[" << i << "] = " << add_result_2[i] << std::endl;
    }
  }

  result = add_result_2[0] + add_result_2[1];

  if (debug) {
    std::cout << "==== INFO - ADDER RESULT ====" << std::endl;
    std::cout << "result = " << result << std::endl;
  }

  delete[] mul_result;
  delete[] add_result_0;
  delete[] add_result_1;
  delete[] add_result_2;

  result = result + bias;

  if (debug) {
    std::cout << "==== INFO - FINAL RESULT ====" << std::endl;
    std::cout << "result = " << result << std::endl;
  }

  return result;
}
}  // namespace mpt
}  // namespace compute_model
