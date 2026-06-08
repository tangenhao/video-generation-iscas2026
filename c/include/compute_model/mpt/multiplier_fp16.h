#pragma once

#include <bitset>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <vector>

#include "compute_model/common/fp16.h"
#include "compute_model/mpt/multiplier_int4.h"

namespace compute_model {
namespace mpt {
namespace multiplier {

template<int BITS>
uint32_t lzd(uint32_t num)
{
  uint32_t cnt  = 0;
  uint32_t mask = (1 << (BITS - 1));
  if (num == 0) {
    return 0;
  }
  while ((num & mask) == 0) {
    cnt++;
    mask >>= 1;
  }
  return cnt;
}

/*
 * @brief Unpacks a 16-bit floating point number.
 * @param a 16-bit number.
 * @param mode 0-Float16, 1-BFloat16
 * @return Unpacked number.
 */
std::vector<int16_t> Unpack(uint16_t a, uint8_t mode, bool debug)
{
  bool    unpack_float = mode >> 1;
  int16_t unpack_sign  = 0;
  int16_t unpack_exp   = 0;
  int16_t unpack_frac  = 0;
  if (debug) {
    std::cout << "==== INFO - Unpack ====\n";
  }
  std::bitset<2> mode_bits(mode);
  if (unpack_float) {
    uint16_t a_sign = (a >> 15) & 0x1;
    uint16_t a_exp  = mode_bits[0] ? (a >> 7) & 0xFF : (a >> 10) & 0x1F;
    uint16_t a_frac = mode_bits[0] ? ((a & 0x7F) << 3) : a & 0x3FF;

    bool unnorm = a_exp == 0 && a_frac != 0;
    bool inf    = mode_bits[0] ? a_exp == 0xff && a_frac == 0 : a_exp == 0x1f && a_frac == 0;
    bool nan    = mode_bits[0] ? a_exp == 0xff && a_frac != 0 : a_exp == 0x1f && a_frac != 0;
    bool zero   = a_exp == 0 && a_frac == 0;

    unpack_sign = a_sign;
    unpack_exp  = zero ? 0 : unnorm ? 1 : (inf | nan) ? 0xff : a_exp;
    unpack_frac = zero ? 0 : unnorm ? a_frac : inf ? 0 : (a_frac | 0x400);
    // unpack_exp  = unnorm ? unpack_exp : mode_bits[0] ? unpack_exp - 127 : unpack_exp - 15;
    if (debug) {
      std::cout << "==== INFO - Unpack Float ==== \n";
      std::cout << std::hex << "a: " << a << std::endl;
      std::cout << "Unnorm: " << unnorm << std::endl;
      std::cout << "Unpacked a sign: " << unpack_sign << std::endl;
      std::cout << "Unpacked a exp: " << unpack_exp << std::endl;
      std::cout << "Unpacked a frac: " << unpack_frac << std::endl;
    }
  }
  else {
    if (!mode_bits[0]) {
      if (debug) {
        std::cout << "==== INFO - Unpack Int4 ==== \n";
        std::cout << std::hex << "a: " << a << std::endl;
      }
      if (a == 0) {
        unpack_sign = 0;
        unpack_exp  = 0;
        unpack_frac = 0;
      }
      else if (a == 0xfff8 || a == 8) {
        unpack_sign = 1;
        unpack_exp  = 18;
        unpack_frac = 0x400;
      }
      else {
        unpack_sign             = (a >> 3) & 0x1;
        int32_t  true_form_int4 = unpack_sign ? (~(a & 0x7) + 1) & 0x7 : a;
        uint32_t lzd_int4       = lzd<4>(true_form_int4);
        uint32_t frac_int4      = true_form_int4 << (lzd_int4 + 7);
        uint32_t exp_int4       = 18 - lzd_int4;
        unpack_frac             = frac_int4 & 0xFFF;
        unpack_exp              = exp_int4;
        if (debug) {
          std::cout << "True form: " << true_form_int4 << std::endl;
          std::cout << "LZD: " << lzd_int4 << std::endl;
        }
      }
      if (debug) {
        std::cout << "Unpacked a sign: " << unpack_sign << std::endl;
        std::cout << "Unpacked a exp: " << unpack_exp << std::endl;
        std::cout << "Unpacked a frac: " << unpack_frac << std::endl;
      }
    }
    else {
      if (debug) {
        std::cout << "==== INFO - Unpack Int8 ==== \n";
        std::cout << std::hex << "a: " << a << std::endl;
      }
      if (a == 0) {
        unpack_sign = 0;
        unpack_exp  = 0;
        unpack_frac = 0;
      }
      else if (a == 0xff80 || a == 0x80) {
        unpack_sign = 1;
        unpack_exp  = 22;
        unpack_frac = 0x400;
      }
      else {
        unpack_sign             = (a >> 7) & 0x1;
        int32_t  true_form_int8 = unpack_sign ? (~(a & 0x7F) + 1) & 0x7F : a;
        uint32_t lzd_int8       = lzd<8>(true_form_int8);
        uint32_t frac_int8      = true_form_int8 << (lzd_int8 + 3);
        uint32_t exp_int8       = 7 - lzd_int8 + 15;
        unpack_exp              = exp_int8;
        unpack_frac             = frac_int8 & 0xFFF;
        if (debug) {
          std::cout << "True form: " << true_form_int8 << std::endl;
          std::cout << "LZD: " << lzd_int8 << std::endl;
        }
      }
      if (debug) {
        std::cout << "Unpacked a sign: " << unpack_sign << std::endl;
        std::cout << "Unpacked a exp: " << unpack_exp << std::endl;
        std::cout << "Unpacked a frac: " << unpack_frac << std::endl;
      }
    }
  }

  return {unpack_sign, unpack_exp, unpack_frac};
}

/*
 * @brief Multiplies two 16-bit floating point numbers, fused with two int8 multipliers and four int4 multipliers.
 * @param a First 16-bit number.
 * @param b Second 16-bit number.
 * @param a_mode 0-Int4, 1-Int8, 2-Float16, 3-BFloat16, 4-Int16
 * @param b_mode 0-Int4, 1-Int8, 2-Float16, 3-BFloat16, 4-Int16
 * @param debug Enable debug mode.
 * @return 32-bit fused result.
 */
uint32_t MultiplierFloat16Fused(uint16_t a, uint16_t b, int8_t a_mode, int8_t b_mode, bool debug)
{
  // Unpack
  std::bitset<2> a_mode_bits(a_mode);
  std::bitset<2> b_mode_bits(b_mode);
  std::bitset<1> compute_mode = a_mode_bits[1] | b_mode_bits[1];

  if (a_mode == 4 && b_mode == 4) {
    return (int32_t)a * (int32_t)b;
  }
  else if ((a_mode == 4 && b_mode != 4) || (a_mode != 4 && b_mode == 4)) {
    std::throw_with_nested(std::runtime_error("MultiplierFloat16Fused: Invalid mode combination"));
  }

  int8_t a_0 = 0;
  int8_t a_1 = 0;
  int8_t a_2 = 0;
  int8_t a_3 = 0;

  int8_t b_0 = 0;
  int8_t b_1 = 0;
  int8_t b_2 = 0;
  int8_t b_3 = 0;

  uint16_t a_sign = 0;
  int16_t  a_exp  = 0;
  uint16_t a_frac = 0;

  uint16_t b_sign = 0;
  int16_t  b_exp  = 0;
  uint16_t b_frac = 0;

  int32_t cal_exp;

  uint16_t o_sign = 0;
  int16_t  o_exp  = 0;
  uint32_t o_frac = 0;

  uint32_t result;

  if (compute_mode.to_ulong()) {
    auto a_unpacked = Unpack(a, a_mode, debug);
    auto b_unpacked = Unpack(b, b_mode, debug);
    if (debug) {
      std::cout << "==== INFO - Unpacked ====\n";
      std::cout << "Unpacked a sign: " << a_unpacked[0] << std::endl;
      std::cout << "Unpacked a exp: " << a_unpacked[1] << std::endl;
      std::cout << "Unpacked a frac: " << a_unpacked[2] << std::endl;
      std::cout << "Unpacked b sign: " << b_unpacked[0] << std::endl;
      std::cout << "Unpacked b exp: " << b_unpacked[1] << std::endl;
      std::cout << "Unpacked b frac: " << b_unpacked[2] << std::endl;
    }
    a_sign = a_unpacked[0];  // 1-bit
    a_exp  = a_unpacked[1];  // 8-bit
    a_frac = a_unpacked[2];  // 11-bit

    b_sign = b_unpacked[0];  // 1-bit
    b_exp  = b_unpacked[1];  // 8-bit
    b_frac = b_unpacked[2];  // 11-bit

    // Sign xor
    o_sign = a_sign ^ b_sign;  // 1-bit

    uint8_t sel_mode = (((a_mode == 3) << 1) | (b_mode == 3));
    int32_t exp_adj  = sel_mode == 3 ? -127 : sel_mode == 0 ? 97 : -15;

    // Exponent add
    cal_exp = a_exp + b_exp + exp_adj;  // 9-bit

    if (debug) {
      std::cout << "==== INFO - Exp process ====\n";
      std::cout << "sel_mode: " << (int32_t)sel_mode << std::endl;
      std::cout << "exp_adj: " << (int32_t)exp_adj << std::endl;
      std::cout << "cal_exp: " << cal_exp << std::endl;
    }

    // Preprocess fraction
    a_0 = a_frac & 0xf;
    a_1 = (a_frac >> 4) & 0xf;
    a_2 = (a_frac >> 8) & 0xf;
    a_3 = a_0;

    b_0 = b_frac & 0xf;
    b_1 = (b_frac >> 4) & 0xf;
    b_2 = (b_frac >> 8) & 0xf;
    b_3 = b_0;
  }
  else {
    a_0 = a & 0xf;
    a_1 = (a >> 4) & 0xf;
    a_2 = (a >> 8) & 0xf;
    a_3 = (a >> 12) & 0xf;

    b_0 = b & 0xf;
    b_1 = (b >> 4) & 0xf;
    b_2 = (b >> 8) & 0xf;
    b_3 = (b >> 12) & 0xf;
    if (a_mode == 0 && b_mode == 0) {
      if (a_0 & 0x8)
        a_0 = a_0 | 0xf0;
      if (a_1 & 0x8)
        a_1 = a_1 | 0xf0;
      if (a_2 & 0x8)
        a_2 = a_2 | 0xf0;
      if (a_3 & 0x8)
        a_3 = a_3 | 0xf0;
      if (b_0 & 0x8)
        b_0 = b_0 | 0xf0;
      if (b_1 & 0x8)
        b_1 = b_1 | 0xf0;
      if (b_2 & 0x8)
        b_2 = b_2 | 0xf0;
      if (b_3 & 0x8)
        b_3 = b_3 | 0xf0;
    }
    else if (a_mode == 1 && b_mode == 1) {
      if (a_1 & 0x8)
        a_1 = a_1 | 0xf0;
      if (a_3 & 0x8)
        a_3 = a_3 | 0xf0;
      if (b_1 & 0x8)
        b_1 = b_1 | 0xf0;
      if (b_3 & 0x8)
        b_3 = b_3 | 0xf0;
    }
    else {
      if (a_mode == 1) {
        if (a_1 & 0x8) {
          a_1 = a_1 | 0xf0;
        }
        if (a_3 & 0x8) {
          a_3 = a_3 | 0xf0;
        }
        if (b_0 & 0x8) {
          b_1 = 0xff;
        }
        if (b_2 & 0x8) {
          b_3 = 0xff;
        }
      }

      if (b_mode == 1) {
        if (b_1 & 0x8) {
          b_1 = b_1 | 0xf0;
        }
        if (b_3 & 0x8) {
          b_3 = b_3 | 0xf0;
        }
        if (a_0 & 0x8) {
          a_1 = 0xff;
        }
        if (a_2 & 0x8) {
          a_3 = 0xff;
        }
      }
    }
  }

  if (debug) {
    if (compute_mode.to_ulong()) {
      std::cout << "==== INFO - Multiplicand Float Mode ==== \n";
    }
    else {
      if (a_mode == 0) {
        std::cout << "==== INFO - Multiplicand Int4 Mode ==== \n";
      }
      else {
        std::cout << "==== INFO - Multiplicand Int8 Mode ==== \n";
      }
      std::cout << "a: " << std::hex << a << std::endl;
      std::cout << "b: " << std::hex << b << std::endl;
    }
    std::cout << std::hex << "a_0: " << (int32_t)a_0 << std::endl;
    std::cout << std::hex << "a_1: " << (int32_t)a_1 << std::endl;
    std::cout << std::hex << "a_2: " << (int32_t)a_2 << std::endl;
    std::cout << std::hex << "a_3: " << (int32_t)a_3 << std::endl;

    std::cout << std::hex << "b_0: " << (int32_t)b_0 << std::endl;
    std::cout << std::hex << "b_1: " << (int32_t)b_1 << std::endl;
    std::cout << std::hex << "b_2: " << (int32_t)b_2 << std::endl;
    std::cout << std::hex << "b_3: " << (int32_t)b_3 << std::endl;
  }

  // Multiplication
  int16_t mul_0 = MultiplierInt4Signed(a_0, b_0, false);
  int16_t mul_1 = MultiplierInt4Signed(a_0, b_1, false);
  int16_t mul_2 = MultiplierInt4Signed(a_1, b_0, false);
  int16_t mul_3 = MultiplierInt4Signed(a_1, b_1, false);
  int16_t mul_4 = MultiplierInt4Signed(a_2, b_2, false);
  int16_t mul_5 = MultiplierInt4Signed(a_2, b_3, false);
  int16_t mul_6 = MultiplierInt4Signed(a_3, b_2, false);
  int16_t mul_7 = MultiplierInt4Signed(a_3, b_3, false);
  int16_t mul_8 = MultiplierInt4Signed(a_2, b_1, false);
  int16_t mul_9 = MultiplierInt4Signed(a_1, b_2, false);

  if (debug) {
    std::cout << "==== INFO - Multiplication result ====\n";
    std::cout << std::hex << "mul_0: " << (int32_t)mul_0 << std::endl;
    std::cout << std::hex << "mul_1: " << (int32_t)mul_1 << std::endl;
    std::cout << std::hex << "mul_2: " << (int32_t)mul_2 << std::endl;
    std::cout << std::hex << "mul_3: " << (int32_t)mul_3 << std::endl;
    std::cout << std::hex << "mul_4: " << (int32_t)mul_4 << std::endl;
    std::cout << std::hex << "mul_5: " << (int32_t)mul_5 << std::endl;
    std::cout << std::hex << "mul_6: " << (int32_t)mul_6 << std::endl;
    std::cout << std::hex << "mul_7: " << (int32_t)mul_7 << std::endl;
    std::cout << std::hex << "mul_8: " << (int32_t)mul_8 << std::endl;
    std::cout << std::hex << "mul_9: " << (int32_t)mul_9 << std::endl;
  }

  if (compute_mode.to_ulong()) {
    // Post process fraction
    uint32_t cal_frac = mul_0 + (mul_1 << 4) + (mul_2 << 4) + (mul_3 << 8) + (mul_5 << 8) + (mul_6 << 8) + (mul_4 << 16) + (mul_8 << 12)
                        + (mul_9 << 12);  // 22-bit
    if (debug) {
      std::cout << "==== INFO - Frac result ==== \n";
      std::cout << "cal_frac: " << cal_frac << std::endl;
    }

    // Normalize
    std::bitset<10> cal_exp_bits(cal_exp);
    bool            unnorm_cal = cal_exp_bits[9]
                      || !(cal_exp_bits[8] | cal_exp_bits[7] | cal_exp_bits[6] | cal_exp_bits[5] | cal_exp_bits[4] | cal_exp_bits[3]
                           | cal_exp_bits[2] | cal_exp_bits[1] | cal_exp_bits[0]);
    int32_t  lzd_o        = lzd<22>(cal_frac & 0x3fffff);
    int32_t  shift_number = cal_exp <= lzd_o ? cal_exp - 1 : lzd_o - 1;
    uint32_t exp_neg      = -cal_exp + 1;
    uint32_t norm_exp     = unnorm_cal ? 1 : lzd_o == 0 ? cal_exp + 1 : lzd_o == 1 ? cal_exp : cal_exp - shift_number;
    uint32_t norm_frac    = unnorm_cal ? exp_neg >= 22 ? 0 : cal_frac >> exp_neg :
                            lzd_o == 0 ? cal_frac >> 1 :
                            lzd_o == 1 ? cal_frac :
                                         cal_frac << shift_number;

    if (debug) {
      std::cout << "==== INFO - Normalize result ==== \n";
      std::cout << "norm_exp: " << norm_exp << std::endl;
      std::cout << "norm_frac: " << norm_frac << std::endl;
      std::cout << "unnorm_cal: " << unnorm_cal << std::endl;
      std::cout << "lzd_o: " << lzd_o << std::endl;
      std::cout << "shift_number: " << shift_number << std::endl;
      std::cout << "exp_neg: " << exp_neg << std::endl;
    }

    // Final result
    std::bitset<9> norm_exp_bits(norm_exp);
    bool           overflow;
    overflow = norm_exp_bits[8]
               | (norm_exp_bits[7] & norm_exp_bits[6] & norm_exp_bits[5] & norm_exp_bits[4] & norm_exp_bits[3] & norm_exp_bits[2]
                  & norm_exp_bits[1] & norm_exp_bits[0]);
    bool a_zero = (a & 0x7fff) == 0;
    bool b_zero = (b & 0x7fff) == 0;
    bool zero   = a_zero | b_zero;
    bool a_inf  = a_mode == 2 ? (a & 0x7fff) == 0x7c00 : a_mode == 3 ? (a & 0x7fff) == 0x7f80 : false;
    bool b_inf  = b_mode == 2 ? (b & 0x7fff) == 0x7c00 : b_mode == 3 ? (b & 0x7fff) == 0x7f80 : false;
    bool inf    = a_inf | b_inf;
    bool a_nan  = a_mode == 2 ? (a & 0x7fff) > 0x7c00 : a_mode == 3 ? (a & 0x7fff) > 0x7f80 : false;
    bool b_nan  = b_mode == 2 ? (b & 0x7fff) > 0x7c00 : b_mode == 3 ? (b & 0x7fff) > 0x7f80 : false;
    bool nan    = a_nan | b_nan;
    o_exp       = zero ? 0 : (inf | nan | overflow) ? 0xff : norm_exp & 0xff;
    o_frac      = zero ? 0 : inf ? 0 : overflow ? 0 : nan ? 0x400000 : norm_frac & 0x3fffff;
    if (debug) {
      std::cout << "==== INFO - Final result ==== \n";
      std::cout << "zero: " << zero << std::endl;
      std::cout << "inf: " << inf << std::endl;
      std::cout << "nan: " << nan << std::endl;
      std::cout << "overflow: " << overflow << std::endl;
      std::cout << "o_sign: " << o_sign << std::endl;
      std::cout << "o_exp: " << o_exp << std::endl;
      std::cout << "o_frac: " << o_frac << std::endl;
    }
    result = (o_sign << 29) | (o_exp << 21) | o_frac;
  }
  else {
    bool compute_int4 = (a_mode == 0 && b_mode == 0);
    if (compute_int4) {
      result = (mul_0 & 0xff) | ((mul_3 & 0xff) << 8) | ((mul_4 & 0xff) << 16) | ((mul_7 & 0xff) << 24);
    }
    else {
      int32_t result_1 = mul_0 + (mul_1 << 4) + (mul_2 << 4) + (mul_3 << 8);
      int32_t result_2 = mul_4 + (mul_5 << 4) + (mul_6 << 4) + (mul_7 << 8);
      result           = result_1 | (result_2 << 16);
      if (debug) {
        std::cout << "==== INFO - Final result ==== \n";
        std::cout << std::hex << "result_1: " << result_1 << std::endl;
        std::cout << "result_2: " << result_2 << std::endl;
      }
    }
  }
  return result;
}

uint32_t mul_align(uint16_t a, uint16_t b, uint16_t mode, bool debug)
{
  uint32_t unnorm_a = (((mode >> 2) & 0x1) == 1) ? ((a >> 10) & 0x1f) != 0 : ((a >> 7) & 0xff) != 0;
  uint32_t unnorm_b = (((mode >> 1) & 0x1) == 1) ? ((b >> 10) & 0x1f) != 0 : ((b >> 7) & 0xff) != 0;
  uint32_t a_sign   = (a >> 15) & 0x1;
  uint32_t b_sign   = (b >> 15) & 0x1;
  uint32_t a_exp    = (((mode >> 2) & 0x1) == 1) ? ((unnorm_a == 0) ? 1 : ((a >> 10) & 0x1f)) : ((unnorm_a == 0) ? 1 : (a >> 7) & 0xff);
  uint32_t b_exp    = (((mode >> 1) & 0x1) == 1) ? ((unnorm_b == 0) ? 1 : ((b >> 10) & 0x1f)) : ((unnorm_b == 0) ? 1 : (b >> 7) & 0xff);
  uint32_t a_frac   = (((mode >> 2) & 0x1) == 1) ? ((unnorm_a == 0) ? (a & 0x3ff) : ((a & 0x3ff)) + 1024) :
                                                   ((unnorm_a == 0) ? ((a & 0x7f) << 3) : (((a & 0x7f) << 3) + 1024));
  uint32_t b_frac   = (((mode >> 1) & 0x1) == 1) ? ((unnorm_b == 0) ? (b & 0x3ff) : ((b & 0x3ff)) + 1024) :
                                                   ((unnorm_b == 0) ? ((b & 0x7f) << 3) : (((b & 0x7f) << 3) + 1024));
  uint32_t a_zero   = (a & 0x7fff) == 0;
  uint32_t b_zero   = (b & 0x7fff) == 0;

  if (debug) {
    std::cout << "==== INFO - Unpacked ====\n";
    std::cout << "a_sign: " << a_sign << std::endl;
    std::cout << "a_exp: " << a_exp << std::endl;
    std::cout << "a_frac: " << a_frac << std::endl;
    std::cout << "b_sign: " << b_sign << std::endl;
    std::cout << "b_exp: " << b_exp << std::endl;
    std::cout << "b_frac: " << b_frac << std::endl;
  }

  uint32_t o_sign = a_sign ^ b_sign;

  int32_t cal_tmp_exp = a_exp + b_exp;
  int32_t cal_exp_ff  = cal_tmp_exp - 15;
  int32_t cal_exp_fb  = cal_tmp_exp - 127;
  int32_t cal_exp_bb  = cal_tmp_exp - 239;
  int32_t cal_exp     = (((mode >> 1) & 0x3) == 0x3) ? cal_exp_ff : (((mode >> 1) & 0x3) == 0x0) ? cal_exp_bb : cal_exp_fb;

  uint32_t cal_frac       = a_frac * b_frac;
  uint32_t cal_exp_neg_ff = ((16 - cal_tmp_exp) & 0x1ff);
  uint32_t cal_exp_neg_fb = ((128 - cal_tmp_exp) & 0x1ff);
  uint32_t cal_exp_neg_bb = ((240 - cal_tmp_exp) & 0x1ff);
  uint32_t cal_exp_neg    = (((mode >> 1) & 0x3) == 0x3) ? cal_exp_neg_ff : (((mode >> 1) & 0x3) == 0x0) ? cal_exp_neg_bb : cal_exp_neg_fb;
  if (debug) {
    std::cout << "==== INFO - Cal ====\n";
    std::cout << "cal_tmp_exp: " << cal_tmp_exp << std::endl;
    std::cout << "cal_exp: " << cal_exp << std::endl;
    std::cout << "cal_frac: " << cal_frac << std::endl;
    std::cout << "cal_exp_neg: " << cal_exp_neg << std::endl;
  }
  uint32_t unnorm_cal       = (((cal_exp >> 9) & 0x1) == 1) || ((cal_exp & 0x1ff) == 0);
  uint32_t unnorm_shift_exp = ((cal_exp - 1) & 0xff);
  uint32_t normshift_exp    = ((cal_frac >> 19) & 0x1 == 1)       ? (cal_exp > 1) ? 1 : unnorm_shift_exp :
                              (((cal_frac >> 18) & 0x3) == 0x1)   ? (cal_exp > 2) ? 2 : unnorm_shift_exp :
                              (((cal_frac >> 17) & 0x7) == 0x1)   ? (cal_exp > 3) ? 3 : unnorm_shift_exp :
                              (((cal_frac >> 16) & 0xf) == 0x1)   ? (cal_exp > 4) ? 4 : unnorm_shift_exp :
                              (((cal_frac >> 15) & 0x1f) == 0x1)  ? (cal_exp > 5) ? 5 : unnorm_shift_exp :
                              (((cal_frac >> 14) & 0x3f) == 0x1)  ? (cal_exp > 6) ? 6 : unnorm_shift_exp :
                              (((cal_frac >> 13) & 0x7f) == 0x1)  ? (cal_exp > 7) ? 7 : unnorm_shift_exp :
                              (((cal_frac >> 12) & 0xff) == 0x1)  ? (cal_exp > 8) ? 8 : unnorm_shift_exp :
                              (((cal_frac >> 11) & 0x1ff) == 0x1) ? (cal_exp > 9) ? 9 : unnorm_shift_exp :
                              (((cal_frac >> 10) & 0x3ff) == 0x1) ? (cal_exp > 10) ? 10 : unnorm_shift_exp :
                              (cal_exp > 11)                      ? 11 :
                                                                    unnorm_shift_exp;
  if (debug) {
    std::cout << "==== INFO - Norm shift ====\n";
    std::cout << "unnorm_cal: " << unnorm_cal << std::endl;
    std::cout << "unnorm_shift_exp: " << unnorm_shift_exp << std::endl;
    std::cout << "normshift_exp: " << normshift_exp << std::endl;
  }
  uint32_t norm_exp  = unnorm_cal                        ? 1 :
                       (((cal_frac >> 21) & 0x1) == 0x1) ? (cal_exp + 1) :
                       (((cal_frac >> 20) & 0x3) == 0x1) ? cal_exp :
                                                           cal_exp - normshift_exp;
  uint32_t norm_fra  = unnorm_cal                        ? cal_exp_neg >= 22 ? 0 : cal_frac >> cal_exp_neg :
                       (((cal_frac >> 21) & 0x1) == 0x1) ? (cal_frac >> 1) :
                       (((cal_frac >> 20) & 0x3) == 0x1) ? cal_frac :
                                                           cal_frac << normshift_exp;
  uint32_t zero_flag = a_zero || b_zero;
  uint32_t overflow  = ((norm_exp >> 8) & 0x1) || ((norm_exp & 0xff) == 0xff);
  uint32_t o_exp     = zero_flag ? 1 : overflow ? 0xff : (norm_exp & 0xff);
  uint32_t o_frac    = zero_flag ? 0 : overflow ? 0x10000 : (norm_fra & 0x1fffff);
  if (debug) {
    std::cout << "==== INFO - Norm result ====\n";
    std::cout << "norm_exp: " << norm_exp << std::endl;
    std::cout << "norm_fra: " << norm_fra << std::endl;
    std::cout << "zero_flag: " << zero_flag << std::endl;
    std::cout << "==== INFO - Result ====\n";
    std::cout << "o_sign: " << o_sign << std::endl;
    std::cout << "o_exp: " << o_exp << std::endl;
    std::cout << "o_frac: " << o_frac << std::endl;
  }

  return (o_sign << 29) + (o_exp << 21) + o_frac;
}

common::fp16::half Int4ToFp16(int8_t a, bool debug)
{
  if (a == 0) {
    return 0;
  }
  else if (a == -8) {
    return common::fp16::half(1, 18, 0);
  }
  else {
    int16_t  unpack_sign = (a >> 3) & 0x1;
    int16_t  true_form   = unpack_sign ? (~(a & 0x7) + 1) & 0x7 : a;
    uint32_t lzd_int4    = lzd<4>(true_form);
    uint32_t frac        = true_form << (lzd_int4 + 7);
    uint32_t exp         = 3 - lzd_int4;
    int16_t  unpack_exp  = exp + 15;
    int16_t  unpack_frac = frac & 0x3FF;

    if (debug) {
      std::cout << std::dec << "true_form: " << true_form << "\n";
      std::cout << "lzd: " << lzd_int4 << "\n";
      std::cout << "unpack sign: " << unpack_sign << std::endl;
      std::cout << "unpack exp: " << unpack_exp << std::endl;
      std::cout << "unpack frac: " << unpack_frac << std::endl;
    }

    return common::fp16::half(unpack_sign, unpack_exp, unpack_frac);
  }
  return 0;
}

common::fp16::half Int8ToFp16(int8_t a, bool debug)
{
  if (a == -128) {
    return common::fp16::half(1, 22, 0);
  }
  else if (a == 0) {
    return 0;
  }
  else {
    int16_t  unpack_sign = (a >> 7) & 0x1;
    uint16_t true_form   = unpack_sign ? (~(a & 0x7f) + 1) & 0x7f : a;
    uint32_t lzd_int8    = lzd<8>(true_form);
    uint32_t frac        = true_form << (lzd_int8 + 3);
    uint32_t exp         = 7 - lzd_int8;
    int16_t  unpack_exp  = exp + 15;
    int16_t  unpack_frac = frac & 0x3FF;
    if (debug) {
      std::cout << std::dec << "true_form: " << true_form << "\n";
      std::cout << "lzd: " << lzd_int8 << "\n";
      std::cout << "unpack sign: " << unpack_sign << std::endl;
      std::cout << "unpack exp: " << unpack_exp << std::endl;
      std::cout << "unpack frac: " << unpack_frac << std::endl;
    }
    return common::fp16::half(unpack_sign, unpack_exp, unpack_frac);
  }
  return 0;
}

float Recover(int32_t a)
{
  uint32_t bits;
  std::cout << "sign: " << ((a >> 29) & 0x1) << std::endl;
  std::cout << "exp: " << ((a >> 21) & 0xff) << std::endl;
  std::cout << "frac: " << (a & 0x1fffff) << std::endl;
  bits = ((a & 0x20000000) << 2) | ((a & 0x1fe00000) << 2) | ((a & 0x000fffff) << 3);
  return *(float*)&bits;
}

}  // namespace multiplier
}  // namespace mpt
}  // namespace compute_model