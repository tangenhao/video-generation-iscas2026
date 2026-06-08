#pragma once
#include "exp2_table.h"
#include "log2_table.h"
#include "reciprocal_table.h"
#include "rsqrt_table.h"
#include "sin_table.h"
#include <math.h>
#include <stdint.h>

namespace compute_model {
namespace function {

static inline uint32_t asuint(float f)
{
  union {
    float    f;
    uint32_t i;
  } u = {f};
  return u.i;
}

static inline float asfloat(uint32_t i)
{
  union {
    uint32_t i;
    float    f;
  } u = {i};
  return u.f;
}

#define fp32_sign(a) ((unsigned int)((a) >> 31))
#define fp32_exp(a) (((a) >> 23) & 0xff)
#define fp32_frac(a) ((a) & 0x007fffff)

float exp2(float y, bool debug = false)
{
  uint32_t y_int, y_sign, y_exp, y_frac;
  y_int  = asuint(y);
  y_sign = fp32_sign(y_int);
  y_exp  = fp32_exp(y_int);
  y_frac = fp32_frac(y_int);

  uint32_t out;
  if (y_exp == 0xff) {
    if (y_frac == 0) {
      out = (y_sign & 0x1) ? 0x0 : 0x7f800000;
      return asfloat(out);
    }
    else {
      out = (y_sign & 0x1) ? 0xffffffff : 0x7fffffff;
      return asfloat(out);
    }
  }
  else {
  }

  uint32_t out_sign, out_exp, out_frac;

  out_sign = 0x0;

  uint32_t norm_frac;
  int      norm_exp;
  norm_frac = (y_exp == 0) ? y_frac : (y_frac | (1 << 23));

  if ((y_exp > 0x85) && (y_sign == 0)) {
    out = 0x7f800000;
    return asfloat(out);
  }
  else if ((y_exp > 0x86) && (y_sign == 1)) {
    out = 0x0;
    return asfloat(out);
  }
  else if (y_exp < 0x67) {
    out = 0x3F800000;
    return asfloat(out);
  }
  else {
  }

  while (y_exp > 127) {
    norm_frac <<= 1;
    y_exp -= 1;
  }
  while (y_exp < 127) {
    norm_frac >>= 1;
    y_exp += 1;
  }

  if (y_sign) {
    norm_exp =
      ((norm_frac & 0x7fffff) == 0) ? (127 - (norm_frac >> 23)) : (127 - (norm_frac >> 23) - 1);  // 让小数是正的
  }
  else {
    norm_exp = (((norm_frac >> 23) & 0x7f) + 127) & 0xff;
  }

  uint32_t index;
  uint64_t x_int, x_int_2;

  norm_frac = y_sign ? (((~norm_frac) + 1) & 0x7fffff) : norm_frac;
  index     = (norm_frac >> 16) & 0x7f;
  x_int     = (norm_frac & 0xffff) << 3;  // 23bit小数 -> 26bit小数
  x_int_2   = x_int * x_int;              // 52bit小数

  int64_t c0, c1, c2;
  c0 = EXP2_C0_TABLE[index];  //  c0 24 bit小数 1bit整数  +
  c1 = EXP2_C1_TABLE[index];  //  c1 15 bit小数 1bit整数  +
  c2 = EXP2_C2_TABLE[index];  //  c2 10 bit小数           +

  if (debug) {
    std::cout << "index: " << index << std::endl;
    std::cout << "c0: " << c0 << std::endl;
    std::cout << "c1: " << c1 << std::endl;
    std::cout << "c2: " << c2 << std::endl;
  }

  int64_t mul_out;
  mul_out = (c0 << 38) + ((c1 * x_int) << 21) + c2 * x_int_2;  // 对齐小数点

  uint32_t frac_round_before;

  while (((mul_out >> 62) & 0x1) != 0x1) {
    mul_out <<= 1;
    norm_exp -= 1;
  }

  if (norm_exp < 1) {
    while (norm_exp < 1) {
      mul_out >>= 1;
      norm_exp += 1;
    }
    norm_exp = 0;
  }

  frac_round_before = (mul_out >> 39) & 0x7fffff;
  if (((mul_out >> 38) & 0x1 == 1) && ((mul_out & 0x3fffffffff) != 0)) {
    out_frac = frac_round_before + 1;
  }
  else {
    out_frac = frac_round_before;
  }

  if ((frac_round_before == 0x7fffff) && ((out_frac & 0x7fffff) == 0)) {
    norm_exp += 1;
  }
  else {
  }

  out_exp = norm_exp & 0xff;

  if (out_exp == 0xff) {
    out = 0x7f800000;
    return asfloat(out);
  }
  else {
    out = (out_sign << 31) | (out_exp << 23) | out_frac;
    return asfloat(out);
  }
}

float log2(float y, bool debug = false)
{
  uint32_t y_int, y_sign, y_exp, y_frac;
  y_int  = asuint(y);
  y_sign = fp32_sign(y_int);
  y_exp  = fp32_exp(y_int);
  y_frac = fp32_frac(y_int);

  uint32_t out_sign, out_exp, out_frac;
  uint32_t out;

  uint32_t norm_frac;
  uint32_t mask = 1 << 23;
  int      norm_exp;

  if (y_sign & 0x1) {
    out = 0xffffffff;
    return asfloat(out);
  }
  else if ((y_exp == 0) && (y_frac == 0)) {
    out = 0xff800000;
    return asfloat(out);
  }
  else if (y_exp == 0xff) {
    out = (y_frac == 0) ? 0x7f800000 : 0x7fffffff;
    return asfloat(out);
  }
  else {
  }

  if (y_exp == 0) {
    norm_exp = -126;
    while ((y_frac & mask) != 0x800000) {
      y_frac <<= 1;
      norm_exp -= 1;
    }
    norm_frac = y_frac;
  }
  else {
    norm_exp  = y_exp - 127;
    norm_frac = (y_frac | (1 << 23));
  }

  out_sign = (norm_exp < 0) ? 0x1 : 0x0;

  uint64_t result_int, result_frac, result;
  result_int = (norm_exp < 0) ? (((norm_frac & 0x7fffff) == 0) ? (-norm_exp) : ((-norm_exp) - 1)) : norm_exp;

  uint32_t index;
  uint64_t x_int, x_int_2;
  index   = (norm_frac >> 16) & 0x7f;
  x_int   = (norm_frac & 0xffff) << 3;  // 23bit小数 -> 26bit小数
  x_int_2 = x_int * x_int;              // 52bit小数

  int64_t c0, c1, c2;
  c0 = LOG2_C0_TABLE[index];  //  c0 24 bit小数 1bit整数  +
  c1 = LOG2_C1_TABLE[index];  //  c1 15 bit小数           +
  c2 = LOG2_C2_TABLE[index];  //  c2 10 bit小数           -

  if (debug) {
    std::cout << std::hex << "index: " << index << std::endl;
    std::cout << "c0: " << c0 << std::endl;
    std::cout << "c1: " << c1 << std::endl;
    std::cout << "c2: " << c2 << std::endl;
  }

  int64_t mul_out;
  mul_out = (c0 << 38) + ((c1 * x_int) << 21) - c2 * x_int_2;  // 对齐小数点

  if (debug) {
    std::cout << "mul_out: " << mul_out << std::endl;
  }

  uint64_t frac_round_before;

  frac_round_before = (mul_out >> 8) & 0x3fffffffffffff;
  if (((mul_out >> 7) & 0x1 == 1) && ((mul_out & 0x7f) != 0)) {
    result_frac = frac_round_before + 1;
  }
  else {
    result_frac = frac_round_before;
  }

  if (debug) {
    std::cout << "result_frac: " << result_frac << std::endl;
  }

  result_frac = out_sign ? (((1ULL << 54) - result_frac) & 0x3fffffffffffff) : result_frac;
  result      = (result_int << 54) | result_frac;

  if (debug) {
    std::cout << "result_int: " << result_int << std::endl;
    std::cout << "result_frac: " << result_frac << std::endl;
    std::cout << "result: " << result << std::endl;
  }

  out_exp = 134;

  if (result == 0) {
    return 0;
  }
  else {
    while (((result >> 61) & 0x1) != 0x1) {
      result <<= 1;
      out_exp -= 1;
    }
    out_frac = (result >> 38) & 0x7fffff;
    out      = (out_sign << 31) | (out_exp << 23) | out_frac;
    return asfloat(out);
  }
}

float reciprocal(float y, bool debug = false)
{
  uint32_t y_int, y_sign, y_exp, y_frac;
  y_int  = asuint(y);
  y_sign = fp32_sign(y_int);
  y_exp  = fp32_exp(y_int);
  y_frac = fp32_frac(y_int);

  uint32_t out_sign, out_exp, out_frac;
  uint32_t out;
  out_sign = y_sign;

  uint32_t norm_frac;
  int32_t  norm_exp;
  norm_exp      = y_exp;
  uint32_t mask = 1 << 23;
  if (y_exp == 0xff) {
    if (y_frac == 0) {
      out = (y_sign << 31);
      return asfloat(out);
    }
    else {
      out = (y_sign << 31) | 0x7fffffff;
      return asfloat(out);
    }
  }
  if (y_exp == 0x0) {
    if ((((y_frac >> 21) & 0x3) == 0) || (y_frac == 0x200000)) {
      out = (y_sign << 31) | 0x7f800000;
      return asfloat(out);
    }
    else {
      norm_exp = -126;
      while ((y_frac & mask) != 0x800000) {
        y_frac <<= 1;
        norm_exp -= 1;
      }
      norm_frac = y_frac;
    }
  }
  else {
    norm_exp -= 0x7F;
    norm_frac = y_frac | (1 << 23);
  }

  norm_exp = 127 - norm_exp;

  if (debug) {
    std::cout << "norm_exp: " << norm_exp << std::endl;
    std::cout << "norm_frac: " << norm_frac << std::endl;
  }

  uint32_t index;
  uint64_t x_int, x_int_2;
  index   = (norm_frac >> 16) & 0x7f;
  x_int   = (norm_frac & 0xffff) << 3;  // 23bit小数 -> 26bit小数
  x_int_2 = x_int * x_int;              // 52bit小数

  int64_t c0, c1, c2;
  c0 = REC_C0_TABLE[index];  //  c0 24 bit小数 1bit整数  +
  c1 = REC_C1_TABLE[index];  //  c1 15 bit小数           -
  c2 = REC_C2_TABLE[index];  //  c2 10 bit小数           +

  if (debug) {
    std::cout << "index: " << index << std::endl;
    std::cout << "c0: " << c0 << std::endl;
    std::cout << "c1: " << c1 << std::endl;
    std::cout << "c2: " << c2 << std::endl;
  }

  int64_t mul_out;
  mul_out = (c0 << 38) - ((c1 * x_int) << 21) + c2 * x_int_2;  // 对齐小数点

  uint32_t frac_round_before;

  while (((mul_out >> 62) & 0x1) != 0x1) {
    mul_out <<= 1;
    norm_exp -= 1;
  }

  if (norm_exp < 1) {
    while (norm_exp < 1) {
      mul_out >>= 1;
      norm_exp += 1;
    }
    norm_exp = 0;
  }

  frac_round_before = (mul_out >> 39) & 0x7fffff;
  if (((mul_out >> 38) & 0x1 == 1) && ((mul_out & 0x3fffffffff) != 0)) {
    out_frac = frac_round_before + 1;
  }
  else {
    out_frac = frac_round_before;
  }

  if ((frac_round_before == 0x7fffff) && ((out_frac & 0x7fffff) == 0)) {
    norm_exp += 1;
  }
  else {
  }

  out_exp = norm_exp & 0xff;

  out = (out_sign << 31) | (out_exp << 23) | out_frac;
  return asfloat(out);
}

float rsqrt(float y)
{
  uint32_t y_int, y_sign, y_exp, y_frac, mask;
  y_int  = asuint(y);
  y_sign = fp32_sign(y_int);
  y_exp  = fp32_exp(y_int);
  y_frac = fp32_frac(y_int);

  mask = 1 << 23;

  uint32_t out_sign, out_exp, out_frac;
  uint32_t out;

  int real_exp, i, even_exp, result_exp_value;

  if (y_exp == 0x0) {
    if (y_frac == 0) {
      out = y_sign ? 0xff800000 : 0x7f800000;
      return asfloat(out);
    }
    else {
    }
  }
  else if (y_sign == 0x1) {
    out = 0xffffffff;
    return asfloat(out);
  }
  else if (y_exp == 0xff) {
    if (y_frac == 0) {
      out = 0x0;
      return asfloat(out);
    }
    else {
      out = 0x7fffffff;
      return asfloat(out);
    }
  }
  else {
  }

  uint32_t mantissa;
  if (y_exp == 0x0) {
    real_exp = -126;
    int32_t shift_num;

    while ((y_frac & mask) != 0x800000) {
      y_frac <<= 1;
      real_exp -= 1;
    }

    mantissa = y_frac;
  }
  else {
    mantissa = 1 << 23 | y_frac;
    real_exp = y_exp - 127;
  }

  uint32_t norm_frac;
  int32_t  norm_exp;
  uint32_t index;
  int64_t  c0, c1, c2;

  norm_frac = mantissa;
  if (real_exp & 0b1 == 1) {
    even_exp = real_exp - 1;
    // norm_frac = mantissa << 1;
    index = (1 << 6) + ((norm_frac >> 17) & 0x3f);
    c0    = RSQRT_C0_TABLE[index];  //  c0 24 bit小数 1bit整数  +
    c1    = RSQRT_C1_TABLE[index];  //  c1 15 bit小数           -
    c2    = RSQRT_C2_TABLE[index];  //  c2 10 bit小数           +
  }
  else {
    even_exp = real_exp;
    // norm_frac = mantissa;
    index = (norm_frac >> 17) & 0x3f;
    c0    = RSQRT_C0_TABLE[index];  //  c0 24 bit小数 1bit整数  +
    c1    = RSQRT_C1_TABLE[index];  //  c1 15 bit小数           -
    c2    = RSQRT_C2_TABLE[index];  //  c2 10 bit小数           +
  }

  norm_exp = 127 - even_exp / 2;

  uint64_t x_int, x_int_2;
  x_int   = (norm_frac & 0x1ffff) << 3;  // 23bit小数 -> 26bit小数
  x_int_2 = x_int * x_int;               // 52bit小数

  int64_t mul_out;
  mul_out = (c0 << 38) - ((c1 * x_int) << 21) + c2 * x_int_2;  // 对齐小数点

  uint32_t frac_round_before;

  out_sign = 0x0;
  while (((mul_out >> 62) & 0x1) != 0x1) {
    mul_out <<= 1;
    norm_exp -= 1;
  }

  frac_round_before = (mul_out >> 39) & 0x7fffff;
  if (((mul_out >> 38) & 0x1 == 1) && ((mul_out & 0x3fffffffff) != 0)) {
    out_frac = frac_round_before + 1;
  }
  else {
    out_frac = frac_round_before;
  }

  if ((frac_round_before == 0x7fffff) && ((out_frac & 0x7fffff) == 0)) {
    norm_exp += 1;
  }
  else {
  }

  out_exp = norm_exp & 0xff;

  out = (out_sign << 31) | (out_exp << 23) | out_frac;
  return asfloat(out);
}

float sin16divpi(float x, bool debug = false)
{

  uint32_t x_sign, x_exp, x_frac;
  x_sign = fp32_sign(asuint(x));
  x_exp  = fp32_exp(asuint(x));
  x_frac = fp32_frac(asuint(x));

  uint32_t out;
  if (x_exp == 0xff) {
    if (x_frac == 0x0) {
      out = 0xffffffff;
      return asfloat(out);
    }
    else {
      out = (x_sign << 31) | 0x7fffffff;
      return asfloat(out);
    }
  }
  else {
  }
  float norm_input;
  norm_input = asfloat(0x40A2F983) * x;  // asfloat(0x3e22f983) * x;

  uint32_t norm_int;
  norm_int = asuint(norm_input);

  uint32_t norm_sign, norm_exp;
  uint64_t norm_frac;
  norm_sign = fp32_sign(norm_int);
  norm_exp  = fp32_exp(norm_int);
  norm_frac = fp32_frac(norm_int);

  if (debug) {
    std::cout << std::hex << "norm_int = " << norm_int << std::endl;
    std::cout << "norm_sign = " << norm_sign << std::endl;
    std::cout << "norm_exp = " << norm_exp << std::endl;
    std::cout << "norm_frac = " << norm_frac << std::endl;
  }

  uint32_t norm_mantissa;

  if (norm_exp != 0x0) {
    norm_mantissa = norm_frac | (1 << 23);
  }
  else {
    norm_mantissa = norm_frac;
  }

  while (norm_exp > 0x7F) {
    norm_mantissa <<= 1;
    norm_exp -= 1;
  }
  while (norm_exp < 0x7F) {
    norm_mantissa >>= 1;
    norm_exp += 1;
  }

  uint32_t quad, index;
  quad = (norm_mantissa >> 26) & 0x3;

  uint32_t in_fraction;
  in_fraction = norm_mantissa & 0x3ffffff;  // n  26

  if (debug) {
    std::cout << "quad = " << quad << std::endl;
    std::cout << "in_fraction = " << in_fraction << std::endl;
  }

  if (in_fraction == 0) {
    switch (quad) {
      case 0x0:
        return 0;
      case 0x1:
        if (norm_sign & 0x1) {
          return -1;
        }
        else {
          return 1;
        }
      case 0x2:
        return 0;
      case 0x3:
        if (norm_sign & 0x1) {
          return 1;
        }
        else {
          return -1;
        }
    }
  }
  else {
  }

  int odd_quadrant = quad & 0x1;         // quadrants 1 and 3 are mirrors of 0 and 2
  int neg_quadrant = (quad >> 1) & 0x1;  // quadrants 2 and 3 have negative outputs

  int64_t x_int;
  in_fraction = odd_quadrant ? ((1 << 26) - in_fraction) : in_fraction;
  index       = (in_fraction >> 19) & 0x7f;
  x_int       = in_fraction & 0x7ffff;

  int64_t c0, c1, c2;
  c0 = SIN_C0_TABLE[index];  //  c0 24 bit小数
  c1 = SIN_C1_TABLE[index];  //  c1 15 bit小数 1bit整数  +
  c2 = SIN_C2_TABLE[index];  //  c2 10 bit小数 1bit整数 -

  int64_t x_int_2;
  x_int_2 = x_int * x_int;  // 2nbit 46
  // c2 * x_int_2 52+10  62bit小数，1bit整数
  // c1 * x_int   26+15  41bit小数，1bit整数

  int64_t mul_out;
  // mul_out = ( c0 << 14) + ((c1 * x_int) << 9) - c2 * x_int_2; //对齐小数点
  mul_out = (c0 << 38) + ((c1 * x_int) << 21) - c2 * x_int_2;  // 对齐小数点

  uint32_t out_sign, out_exp, out_frac;
  uint32_t frac_round_before;

  out_sign = neg_quadrant ^ norm_sign;
  out_exp  = 0x7F;
  if (mul_out == 0) {
    return 0;
  }
  else {
  }

  while (((mul_out >> 62) & 0x1) != 0x1) {
    mul_out <<= 1;
    out_exp -= 1;
  }

  frac_round_before = (mul_out >> 39) & 0x7fffff;
  if (((mul_out >> 38) & 0x1 == 1) && ((mul_out & 0x3fffffffff) != 0)) {
    out_frac = frac_round_before + 1;
  }
  else {
    out_frac = frac_round_before;
  }

  if ((frac_round_before == 0x7fffff) && ((out_frac & 0x7fffff) == 0)) {
    out_exp += 1;
  }
  else {
  }

  out = (out_sign << 31) | (out_exp << 23) | (out_frac & 0x7fffff);
  return asfloat(out);
}

float cos16divpi(float x)
{
  uint32_t x_sign, x_exp, x_frac;
  x_sign = fp32_sign(asuint(x));
  x_exp  = fp32_exp(asuint(x));
  x_frac = fp32_frac(asuint(x));

  uint32_t out;
  if (x_exp == 0xff) {
    if (x_frac == 0x0) {
      out = 0xffffffff;
      return asfloat(out);
    }
    else {
      out = (x_sign << 31) | 0x7fffffff;
      return asfloat(out);
    }
  }
  else {
  }

  float norm_input;
  norm_input = asfloat(0x40A2F983) * x;  // asfloat(0x3e22f983) * x;

  uint32_t norm_int;
  norm_int = asuint(norm_input);

  uint32_t norm_sign, norm_exp;
  uint64_t norm_frac;
  norm_sign = 0x0;
  norm_exp  = fp32_exp(norm_int);
  norm_frac = fp32_frac(norm_int);

  uint32_t norm_mantissa;
  if (norm_exp != 0x0) {
    norm_mantissa = norm_frac | (1 << 23);
  }
  else {
    norm_mantissa = norm_frac;
  }

  while (norm_exp > 0x7F) {
    norm_mantissa <<= 1;
    norm_exp -= 1;
  }
  while (norm_exp < 0x7F) {
    norm_mantissa >>= 1;
    norm_exp += 1;
  }

  uint32_t quad, index;
  quad = ((norm_mantissa >> 26) + 1) & 0x3;

  uint32_t in_fraction;
  in_fraction = norm_mantissa & 0x3ffffff;  // n  26

  if (in_fraction == 0) {
    switch (quad) {
      case 0x0:
        return 0;
      case 0x1:
        if (norm_sign & 0x1) {
          return -1;
        }
        else {
          return 1;
        }
      case 0x2:
        return 0;
      case 0x3:
        if (norm_sign & 0x1) {
          return 1;
        }
        else {
          return -1;
        }
    }
  }
  else {
  }

  int odd_quadrant = quad & 0x1;         // quadrants 1 and 3 are mirrors of 0 and 2
  int neg_quadrant = (quad >> 1) & 0x1;  // quadrants 2 and 3 have negative outputs

  int64_t x_int;
  in_fraction = odd_quadrant ? ((1 << 26) - in_fraction) : in_fraction;
  index       = (in_fraction >> 19) & 0x7f;
  x_int       = in_fraction & 0x7ffff;

  int64_t c0, c1, c2;
  c0 = SIN_C0_TABLE[index];  //  c0 24 bit小数
  c1 = SIN_C1_TABLE[index];  //  c1 15 bit小数 1bit整数  +
  c2 = SIN_C2_TABLE[index];  //  c2 10 bit小数 1bit整数 -

  int64_t x_int_2;
  x_int_2 = x_int * x_int;  // 2nbit 46
  // c2 * x_int_2 52+10  62bit小数，1bit整数
  // c1 * x_int   26+15  41bit小数，1bit整数

  int64_t mul_out;
  // mul_out = ( c0 << 14) + ((c1 * x_int) << 9) - c2 * x_int_2; //对齐小数点
  mul_out = (c0 << 38) + ((c1 * x_int) << 21) - c2 * x_int_2;  // 对齐小数点

  uint32_t out_sign, out_exp, out_frac;
  uint32_t frac_round_before;

  out_sign = neg_quadrant ^ norm_sign;
  out_exp  = 0x7F;
  if (mul_out == 0) {
    return 0;
  }
  else {
  }

  while (((mul_out >> 62) & 0x1) != 0x1) {
    mul_out <<= 1;
    out_exp -= 1;
  }

  frac_round_before = (mul_out >> 39) & 0x7fffff;
  if (((mul_out >> 38) & 0x1 == 1) && ((mul_out & 0x3fffffffff) != 0)) {
    out_frac = frac_round_before + 1;
  }
  else {
    out_frac = frac_round_before;
  }

  if ((frac_round_before == 0x7fffff) && ((out_frac & 0x7fffff) == 0)) {
    out_exp += 1;
  }
  else {
  }

  out = (out_sign << 31) | (out_exp << 23) | (out_frac & 0x7fffff);
  return asfloat(out);
}

float tanh(float y, bool debug = false)
{
  uint32_t y_int, y_sign, y_exp, y_frac;
  y_int  = asuint(y);
  y_sign = fp32_sign(y_int);
  y_exp  = fp32_exp(y_int);
  y_frac = fp32_frac(y_int);

  if (debug) {
    std::cout << std::hex << "y_int: " << (*(uint32_t*)(&y_int)) << std::endl;
    std::cout << "y_sign: " << (*(uint32_t*)(&y_sign)) << std::endl;
    std::cout << "y_exp: " << (*(uint32_t*)(&y_exp)) << std::endl;
    std::cout << "y_frac: " << (*(uint32_t*)(&y_frac)) << std::endl;
  }

  uint32_t out, out_sign, out_exp, out_frac;
  if (y_exp == 0xff) {
    if (y_frac == 0) {
      out = (y_sign << 31) | 0x3F800000;
      return asfloat(out);
    }
    else {
      out = (y_sign & 0x1) ? 0xffffffff : 0x7fffffff;
      return asfloat(out);
    }
  }

  if ((y_int & 0x7fffffff) == 0) {
    return y;
  }

  if ((y_int & 0x7fffffff) < 0x3D800000) {
    float mul_1 = (float)((double)-1.0) / ((double)3.0);
    float y_2   = y * y;
    float y_3   = y_2 * y;
    float result = fmaf(y_3, mul_1, y);
    if (debug) {
      std::cout << "Enter y_int < 0x3D800000" << std::endl;
      std::cout << "y: " << (*(uint32_t*)(&y)) << std::endl;
      std::cout << "y_2: " << (*(uint32_t*)(&y_2)) << std::endl;
      std::cout << "y_3: " << (*(uint32_t*)(&y_3)) << std::endl;
      std::cout << "result: " << (*(uint32_t*)(&result)) << std::endl;

    }

    return result;
  }
  else if ((y_int & 0x7fffffff) > 0x41102CB4) {
    out = (y_sign << 31) | 0x3F800000;
    return asfloat(out);
  }
  else {
    float log2_e  = asfloat(1069066811);
    float in      = y * log2_e;
    float e_x     = exp2(in);
    float e_x_inv = exp2(-in);

    float add_out = e_x + e_x_inv;
    float sub_out = e_x - e_x_inv;

    // out = asuint(sub_out/add_out);
    // return sub_out/add_out;

    if (debug) {
      std::cout << "in: " << (*(uint32_t*)(&in)) << std::endl;
      std::cout << "e_x: " << (*(uint32_t*)(&e_x)) << std::endl;
      std::cout << "e_x_inv: " << (*(uint32_t*)(&e_x_inv)) << std::endl;
      std::cout << "add_out: " << (*(uint32_t*)(&add_out)) << std::endl;
      std::cout << "sub_out: " << (*(uint32_t*)(&sub_out)) << std::endl;
    }
    return sub_out * reciprocal(add_out);
  }
}

float fma(float a, float b, float c)
{
  return fmaf(a, b, c);
}

}  // namespace function
}  // namespace compute_model