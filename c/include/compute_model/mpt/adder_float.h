#pragma once

#include <cstdint>
#include <fstream>
#include <iostream>
#include <vector>

#include "compute_model/common/fp16.h"

namespace compute_model {
namespace mpt {
namespace adder {

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
 * @brief 浮点加法器，支持浮点乘法结果的累加
 * @param a c=a+b的a
 * @param b c=a+b的b
 * @param debug 是否打印debug信息
 * @return
 *  int32_t, c=a+b的c
 */
int32_t AdderFloat(int32_t& a, int32_t& b, bool debug)
{
  int32_t a_sign = (a >> 29) & 0x1;
  int32_t b_sign = (b >> 29) & 0x1;
  int32_t a_exp  = (a >> 21) & 0xff;
  int32_t b_exp  = (b >> 21) & 0xff;
  int32_t a_frac = a & 0x1fffff;
  int32_t b_frac = b & 0x1fffff;

  bool a_inf  = a_exp == 0xff && a_frac == 0;
  bool b_inf  = b_exp == 0xff && b_frac == 0;
  bool a_nan  = a_exp == 0xff && a_frac != 0;
  bool b_nan  = b_exp == 0xff && b_frac != 0;
  bool a_zero = a_exp == 0 && a_frac == 0;
  bool b_zero = b_exp == 0 && b_frac == 0;

  if (debug) {
    std::cout << "==== INFO - AdderFloat ====" << std::endl;
    std::cout << std::hex << "a: " << a_sign << " " << a_exp << " " << a_frac << std::endl;
    std::cout << "b: " << b_sign << " " << b_exp << " " << b_frac << std::endl;
  }

  // sel
  int32_t exp_cmp      = a_exp == b_exp ? 3 : a_exp > b_exp ? 1 : 0;
  int32_t frac_cmp     = a_frac == b_frac ? 3 : a_frac > b_frac ? 1 : 0;
  int32_t cmp          = ((frac_cmp == 1 && exp_cmp == 3) || (exp_cmp == 1));
  int32_t exp_larger   = exp_cmp == 1 ? a_exp : b_exp;
  int32_t frac_larger  = cmp ? a_frac : b_frac;
  int32_t exp_smaller  = exp_cmp == 1 ? b_exp : a_exp;
  int32_t frac_smaller = cmp ? b_frac : a_frac;
  int32_t exp_diff     = exp_larger - exp_smaller;

  if (debug) {
    std::cout << "exp_cmp: " << exp_cmp << std::endl;
    std::cout << "frac_cmp: " << frac_cmp << std::endl;
    std::cout << "cmp: " << cmp << std::endl;
    std::cout << "exp_larger: " << exp_larger << std::endl;
    std::cout << "frac_larger: " << frac_larger << std::endl;
    std::cout << "exp_smaller: " << exp_smaller << std::endl;
    std::cout << "frac_smaller: " << frac_smaller << std::endl;
    std::cout << "exp_diff: " << exp_diff << std::endl;
  }

  if (debug) {}

  // cal
  int32_t minus_flag         = a_sign ^ b_sign;
  int32_t frac_larger_align  = minus_flag ? ~frac_larger + 1 : frac_larger;
  int32_t frac_smaller_align = exp_diff > 22 ? 0 : frac_smaller >> exp_diff;

  int32_t cal_sign      = cmp ? a_sign : b_sign;
  int32_t cal_exp       = exp_larger;
  int32_t cal_frac_temp = frac_larger_align + frac_smaller_align;
  int32_t cal_frac      = minus_flag ? ~cal_frac_temp + 1 : cal_frac_temp;

  if (debug) {
    std::cout << "minus_flag: " << minus_flag << std::endl;
    std::cout << "frac_larger_align: " << frac_larger_align << std::endl;
    std::cout << "frac_smaller_align: " << frac_smaller_align << std::endl;
    std::cout << "cal_sign: " << cal_sign << std::endl;
    std::cout << "cal_exp: " << cal_exp << std::endl;
    std::cout << "cal_frac: " << cal_frac << std::endl;
  }

  // normalize
  int32_t lzd_o        = lzd<22>(cal_frac & 0x3fffff);
  int32_t shift_number = lzd_o == 0 ? 0 : cal_exp <= lzd_o ? cal_exp - 1 : lzd_o - 1;
  int32_t norm_exp     = lzd_o == 0 && (cal_frac & 0x3fffff) != 0 ? cal_exp + 1 : lzd_o == 1 ? cal_exp : cal_exp - shift_number;
  int32_t norm_frac    = lzd_o == 0 ? (cal_frac >> 1) : lzd_o == 1 ? cal_frac : cal_frac << shift_number;

  if (debug) {
    std::cout << "lzd: " << lzd_o << std::endl;
    std::cout << "shift_number: " << shift_number << std::endl;
    std::cout << "norm_exp: " << norm_exp << std::endl;
    std::cout << "norm_frac: " << norm_frac << std::endl;
  }

  // Final result
  bool overflow = norm_exp >= 0xff;
  bool zero     = (minus_flag && (exp_cmp == 3) && (frac_cmp == 3)) || (a_zero && b_zero);
  bool inf      = (a_inf && !b_nan) || (b_inf && !a_nan) || overflow;
  bool nan      = a_nan || b_nan || (minus_flag && a_inf && b_inf);

  int32_t  o_sign = (inf & a_inf & a_sign) | (inf & b_inf & b_sign) | (!inf & cal_sign);
  int32_t  o_exp  = nan | inf ? 0xff : zero ? 0 : norm_exp;
  int32_t  o_frac = nan ? 0x3fffff : zero | inf ? 0 : norm_frac & 0x1fffff;
  uint32_t result = (o_sign << 29) | (o_exp << 21) | o_frac;
  if (debug) {
    std::cout << "o_sign: " << o_sign << std::endl;
    std::cout << "o_exp: " << o_exp << std::endl;
    std::cout << "o_frac: " << o_frac << std::endl;
  }
  return result;
}
}  // namespace adder
}  // namespace mpt
}  // namespace compute_model