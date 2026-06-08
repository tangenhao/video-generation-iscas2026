#pragma once

#include <bitset>
#include <cstdint>
#include <ctime>
#include <fstream>
#include <iostream>
#include <random>

#include "compute_model/common/fp16.h"

namespace compute_model {
namespace quant {

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

uint32_t custom_fma(int32_t psum, uint16_t scale, bool debug)
{
  uint32_t sign_psum      = (psum >> 31) & 0x1;
  uint32_t true_form_psum = 0;
  if (sign_psum) {
    true_form_psum = (~(psum & 0x7FFFFFFF) + 1) & 0x7FFFFFFF;
  }
  else {
    true_form_psum = psum;
  }
  uint32_t lzpsum    = lzd<32>(true_form_psum);   // 5bit
  uint32_t frac_psum = 0;                         // 32bit
  frac_psum          = true_form_psum << lzpsum;  // 32bit
  int32_t exp_psum   = 31 - lzpsum;               // 5bit

  if (debug) {
    std::cout << "lzpsum = " << lzpsum << std::endl;
    std::cout << "frac_psum = " << frac_psum << std::endl;
    std::cout << "exp_psum = " << exp_psum << std::endl;
  }

  int32_t sign_scale = (scale >> 15) & 0x1;
  int32_t exp_scale  = ((scale >> 10) & 0x1F);
  int32_t frac_scale = (scale & 0x3FF) | 0x400;

  if (debug) {
    std::cout << "sign_scale = " << sign_scale << std::endl;
    std::cout << "exp_scale = " << exp_scale << std::endl;
    std::cout << "frac_scale = " << frac_scale << std::endl;
  }

  int32_t cal_sign = sign_scale ^ sign_psum;
  int64_t cal_frac = ((int64_t)frac_psum & 0xffffffff) * frac_scale;  // 43bit
  int32_t cal_exp  = exp_psum + exp_scale + 112;                      // 8bit

  if ((scale & 0x7fff) == 0) {
    cal_frac = 0;
    cal_exp  = 0;
  }
  else if (psum == 0) {
    cal_frac = 0;
    cal_exp  = 0;
  }

  if (debug) {
    std::cout << "cal_frac = " << cal_frac << std::endl;
    std::cout << "cal_exp = " << cal_exp << std::endl;
  }

  int32_t shift_number = (((cal_frac >> 40) & 0x7) == 0x1)       ? 0 :
                         (((cal_frac >> 39) & 0xf) == 0x1)       ? 1 :
                         (((cal_frac >> 38) & 0x1f) == 0x1)      ? 2 :
                         (((cal_frac >> 37) & 0x3f) == 0x1)      ? 3 :
                         (((cal_frac >> 36) & 0x7f) == 0x1)      ? 4 :
                         (((cal_frac >> 35) & 0xff) == 0x1)      ? 5 :
                         (((cal_frac >> 34) & 0x1ff) == 0x1)     ? 6 :
                         (((cal_frac >> 33) & 0x3ff) == 0x1)     ? 7 :
                         (((cal_frac >> 32) & 0x7ff) == 0x1)     ? 8 :
                         (((cal_frac >> 31) & 0xfff) == 0x1)     ? 9 :
                         (((cal_frac >> 30) & 0x1fff) == 0x1)    ? 10 :
                         (((cal_frac >> 29) & 0x3fff) == 0x1)    ? 11 :
                         (((cal_frac >> 28) & 0x7fff) == 0x1)    ? 12 :
                         (((cal_frac >> 27) & 0xffff) == 0x1)    ? 13 :
                         (((cal_frac >> 26) & 0x1ffff) == 0x1)   ? 14 :
                         (((cal_frac >> 25) & 0x3ffff) == 0x1)   ? 15 :
                         (((cal_frac >> 24) & 0x7ffff) == 0x1)   ? 16 :
                         (((cal_frac >> 23) & 0xfffff) == 0x1)   ? 17 :
                         (((cal_frac >> 22) & 0x1fffff) == 0x1)  ? 18 :
                         (((cal_frac >> 21) & 0x3fffff) == 0x1)  ? 19 :
                         (((cal_frac >> 20) & 0x7fffff) == 0x1)  ? 20 :
                         (((cal_frac >> 19) & 0xffffff) == 0x1)  ? 21 :
                         (((cal_frac >> 18) & 0x1ffffff) == 0x1) ? 22 :
                         (((cal_frac >> 17) & 0x3ffffff) == 0x1) ? 23 :
                         (((cal_frac >> 16) & 0x7ffffff) == 0x1) ? 24 :
                                                                   0;
  if (debug) {
    std::cout << "shift_number = " << shift_number << std::endl;
  }
  int32_t postshift_exp  = cal_exp - shift_number;
  int64_t postshift_frac = cal_frac << shift_number;
  int64_t frac_norm;
  int32_t exp_norm;

  if (postshift_exp > 0) {
    if (((postshift_frac >> 41) & 0x3) >= 2) {
      frac_norm = (postshift_frac >> 2);
      exp_norm  = postshift_exp + 2;
    }
    else if (((postshift_frac >> 41) & 0x3) == 1) {
      frac_norm = (postshift_frac >> 1);
      exp_norm  = postshift_exp + 1;
    }
    else {
      frac_norm = postshift_frac;
      exp_norm  = postshift_exp;
    }
  }
  else {
    frac_norm = postshift_frac >> (-postshift_exp);
    exp_norm  = 0;
  }

  if (exp_norm > 0xFF) {
    exp_norm  = 0xFF;
    frac_norm = 0;
  }

  if (debug) {
    std::cout << "frac_norm = " << ((frac_norm >> 17) & 0x7FFFFF) << std::endl;
    std::cout << "exp_norm = " << exp_norm << std::endl;
  }

  int32_t res = (cal_sign << 31) | (exp_norm << 23) | ((frac_norm >> 17) & 0x7FFFFF);
  return res;
}

}  // namespace quant
}  // namespace compute_model
