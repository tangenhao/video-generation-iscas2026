#pragma once

#include <cassert>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <map>

namespace compute_model {
namespace common {
namespace fp16 {

uint16_t FromFloatBits(uint32_t f)
{
  uint32_t f_exp, f_sig;
  uint16_t h_sgn, h_exp, h_sig;

  h_sgn = (uint16_t)((f & 0x80000000u) >> 16);
  f_exp = (f & 0x7f800000u);

  /* Exponent overflow/NaN converts to signed inf/NaN */
  if (f_exp >= 0x47800000u) {
    if (f_exp == 0x7f800000u) {
      /* Inf or NaN */
      f_sig = (f & 0x007fffffu);
      if (f_sig != 0) {
        /* NaN - propagate the flag in the significand... */
        uint16_t ret = (uint16_t)(0x7c00u + (f_sig >> 13));
        /* ...but make sure it stays a NaN */
        if (ret == 0x7c00u) {
          ret++;
        }
        return h_sgn + ret;
      }
      else {
        /* signed inf */
        return (uint16_t)(h_sgn + 0x7c00u);
      }
    }
    else {
      return (uint16_t)(h_sgn + 0x7c00u);
    }
  }

  /* Exponent underflow converts to a subnormal half or signed zero */
  if (f_exp <= 0x38000000u) {
    /*
     * Signed zeros, subnormal floats, and floats with small
     * exponents all convert to signed zero half-floats.
     */
    if (f_exp < 0x33000000u) {
      return h_sgn;
    }
    /* Make the subnormal significand */
    f_exp >>= 23;
    f_sig = (0x00800000u + (f & 0x007fffffu));
    /*
     * Usually the significand is shifted by 13. For subnormals an
     * additional shift needs to occur. This shift is one for the largest
     * exponent giving a subnormal `f_exp = 0x38000000 >> 23 = 112`, which
     * offsets the new first bit. At most the shift can be 1+10 bits.
     */
    f_sig >>= (113 - f_exp);
    /* Handle rounding by adding 1 to the bit beyond half precision */
    /*
     * If the last bit in the half significand is 0 (already even), and
     * the remaining bit pattern is 1000...0, then we do not add one
     * to the bit after the half significand. However, the (113 - f_exp)
     * shift can lose up to 11 bits, so the || checks them in the original.
     * In all other cases, we can just add one.
     */
    if (((f_sig & 0x00003fffu) != 0x00001000u) || (f & 0x000007ffu)) {
      f_sig += 0x00001000u;
    }
    h_sig = (uint16_t)(f_sig >> 13);
    /*
     * If the rounding causes a bit to spill into h_exp, it will
     * increment h_exp from zero to one and h_sig will be zero.
     * This is the correct result.
     */
    return (uint16_t)(h_sgn + h_sig);
  }

  /* Regular case with no overflow or underflow */
  h_exp = (uint16_t)((f_exp - 0x38000000u) >> 13);
  /* Handle rounding by adding 1 to the bit beyond half precision */
  f_sig = (f & 0x007fffffu);
  /*
   * If the last bit in the half significand is 0 (already even), and
   * the remaining bit pattern is 1000...0, then we do not add one
   * to the bit after the half significand.  In all other cases, we do.
   */
  if ((f_sig & 0x00003fffu) != 0x00001000u) {
    f_sig += 0x00001000u;
  }
  h_sig = (uint16_t)(f_sig >> 13);
  /*
   * If the rounding causes a bit to spill into h_exp, it will
   * increment h_exp by one and h_sig will be zero.  This is the
   * correct result.  h_exp may increment to 15, at greatest, in
   * which case the result overflows to a signed inf.
   */
  return h_sgn + h_exp + h_sig;
}

uint16_t FromDoubleBits(uint64_t d)
{
  uint64_t d_exp, d_sig;
  uint16_t h_sgn, h_exp, h_sig;

  h_sgn = (d & 0x8000000000000000ULL) >> 48;
  d_exp = (d & 0x7ff0000000000000ULL);

  /* Exponent overflow/NaN converts to signed inf/NaN */
  if (d_exp >= 0x40f0000000000000ULL) {
    if (d_exp == 0x7ff0000000000000ULL) {
      /* Inf or NaN */
      d_sig = (d & 0x000fffffffffffffULL);
      if (d_sig != 0) {
        /* NaN - propagate the flag in the significand... */
        uint16_t ret = (uint16_t)(0x7c00u + (d_sig >> 42));
        /* ...but make sure it stays a NaN */
        if (ret == 0x7c00u) {
          ret++;
        }
        return h_sgn + ret;
      }
      else {
        /* signed inf */
        return h_sgn + 0x7c00u;
      }
    }
    else {
      return h_sgn + 0x7c00u;
    }
  }

  /* Exponent underflow converts to subnormal half or signed zero */
  if (d_exp <= 0x3f00000000000000ULL) {
    /*
     * Signed zeros, subnormal floats, and floats with small
     * exponents all convert to signed zero half-floats.
     */
    if (d_exp < 0x3e60000000000000ULL) {
      return h_sgn;
    }
    /* Make the subnormal significand */
    d_exp >>= 52;
    d_sig = (0x0010000000000000ULL + (d & 0x000fffffffffffffULL));
    /*
     * Unlike floats, doubles have enough room to shift left to align
     * the subnormal significand leading to no loss of the last bits.
     * The smallest possible exponent giving a subnormal is:
     * `d_exp = 0x3e60000000000000 >> 52 = 998`. All larger subnormals are
     * shifted with respect to it. This adds a shift of 10+1 bits the final
     * right shift when comparing it to the one in the normal branch.
     */
    assert(d_exp - 998 >= 0);
    d_sig <<= (d_exp - 998);
    /* Handle rounding by adding 1 to the bit beyond half precision */

    /*
     * If the last bit in the half significand is 0 (already even), and
     * the remaining bit pattern is 1000...0, then we do not add one
     * to the bit after the half significand.  In all other cases, we do.
     */
    if ((d_sig & 0x003fffffffffffffULL) != 0x0010000000000000ULL) {
      d_sig += 0x0010000000000000ULL;
    }

    h_sig = (uint16_t)(d_sig >> 53);
    /*
     * If the rounding causes a bit to spill into h_exp, it will
     * increment h_exp from zero to one and h_sig will be zero.
     * This is the correct result.
     */
    return h_sgn + h_sig;
  }

  /* Regular case with no overflow or underflow */
  h_exp = (uint16_t)((d_exp - 0x3f00000000000000ULL) >> 42);
  /* Handle rounding by adding 1 to the bit beyond half precision */
  d_sig = (d & 0x000fffffffffffffULL);

  /*
   * If the last bit in the half significand is 0 (already even), and
   * the remaining bit pattern is 1000...0, then we do not add one
   * to the bit after the half significand.  In all other cases, we do.
   */
  if ((d_sig & 0x000007ffffffffffULL) != 0x0000020000000000ULL) {
    d_sig += 0x0000020000000000ULL;
  }

  h_sig = (uint16_t)(d_sig >> 42);

  /*
   * If the rounding causes a bit to spill into h_exp, it will
   * increment h_exp by one and h_sig will be zero.  This is the
   * correct result.  h_exp may increment to 15, at greatest, in
   * which case the result overflows to a signed inf.
   */

  return h_sgn + h_exp + h_sig;
}

uint64_t ToDoubleBits(uint16_t h)
{
  uint16_t h_exp = (h & 0x7c00u);
  uint64_t d_sgn = ((uint64_t)h & 0x8000u) << 48;
  switch (h_exp) {
    case 0x0000u: {  // 0 or subnormal
      uint16_t h_sig = (h & 0x03ffu);
      // Signed zero
      if (h_sig == 0) {
        return d_sgn;
      }
      // Subnormal
      h_sig <<= 1;
      while ((h_sig & 0x0400u) == 0) {
        h_sig <<= 1;
        h_exp++;
      }
      uint64_t d_exp = ((uint64_t)(1023 - 15 - h_exp)) << 52;
      uint64_t d_sig = ((uint64_t)(h_sig & 0x03ffu)) << 42;
      return d_sgn + d_exp + d_sig;
    }
    case 0x7c00u:  // inf or NaN
      // All-ones exponent and a copy of the significand
      return d_sgn + 0x7ff0000000000000ULL + (((uint64_t)(h & 0x03ffu)) << 42);
    default:  // normalized
      // Just need to adjust the exponent and shift
      return d_sgn + (((uint64_t)(h & 0x7fffu) + 0xfc000u) << 42);
  }
}

uint32_t ToFloatBits(uint16_t h)
{
  uint16_t h_exp = (h & 0x7c00u);
  uint32_t f_sgn = ((uint32_t)h & 0x8000u) << 16;
  switch (h_exp) {
    case 0x0000u: {  // 0 or subnormal
      uint16_t h_sig = (h & 0x03ffu);
      // Signed zero
      if (h_sig == 0) {
        return f_sgn;
      }
      // Subnormal
      h_sig <<= 1;
      while ((h_sig & 0x0400u) == 0) {
        h_sig <<= 1;
        h_exp++;
      }
      uint32_t f_exp = ((uint32_t)(127 - 15 - h_exp)) << 23;
      uint32_t f_sig = ((uint32_t)(h_sig & 0x03ffu)) << 13;
      return f_sgn + f_exp + f_sig;
    }
    case 0x7c00u:  // inf or NaN
      // All-ones exponent and a copy of the significand
      return f_sgn + 0x7f800000u + (((uint32_t)(h & 0x03ffu)) << 13);
    default:  // normalized
      // Just need to adjust the exponent and shift
      return f_sgn + (((uint32_t)(h & 0x7fffu) + 0x1c000u) << 13);
  }
}

inline uint32_t FloatToBits(float fNum)
{
  return *((uint32_t*)&fNum);
}

inline uint64_t DoubleToBits(double dNum)
{
  return *((uint64_t*)&dNum);
}

inline float BitsToFloat(uint32_t fBits)
{
  return *((float*)&fBits);
}

inline float BitsToDouble(uint64_t dBits)
{
  return *((double*)&dBits);
}

inline bool is_nan(uint16_t a)
{
  return ((((a >> 10) & 0b11111) == 0x1f) && ((a & 0b1111111111) != 0)) ? true : false;
}

inline bool is_inf(uint16_t a)
{
  return ((((a >> 10) & 0b11111) == 0x1f) && ((a & 0b1111111111) == 0)) ? true : false;
}

inline bool is_zero(uint16_t a)
{
  return ((((a >> 10) & 0b11111) == 0) && ((a & 0b1111111111) == 0)) ? true : false;
}

typedef struct half {

  uint16_t storage;

  half(): storage(0) {}

  half(const uint16_t& sign, const uint16_t& exp, const uint16_t& frac): storage((sign << 15) | (exp << 10) | frac) {}

  half(const uint16_t& h): storage(h) {}

  half(const uint32_t& h): storage(uint16_t(h)) {}

  half(const int32_t& h): storage(uint16_t(h)) {}

  half(const float& f): storage(FromFloatBits(FloatToBits(f))) {}

  half(const double& d): storage(FromDoubleBits(DoubleToBits(d))) {}

  half& operator=(const uint16_t& h)
  {
    storage = h;
    return *this;
  }

  half& operator=(const float& f)
  {
    storage = FromFloatBits(FloatToBits(f));
    return *this;
  }

  half& operator=(const double& d)
  {
    storage = FromDoubleBits(DoubleToBits(d));
    return *this;
  }

  half& operator=(const int8_t& i)
  {
    storage = uint16_t(i);
    return *this;
  }

  operator float() const
  {
    return BitsToFloat(ToFloatBits(storage));
  }

  operator double() const
  {
    return BitsToDouble(ToDoubleBits(storage));
  }

  friend std::ostream& operator<<(std::ostream& os, const half& h)
  {
    os << (float)h;
    return os;
  }

  friend std::istream& operator>>(std::istream& is, half& h)
  {
    float f;
    is >> f;
    h = f;
    return is;
  }

  friend bool operator==(const half& a, const half& b)
  {
    return (a.storage == b.storage) ? true : false;
  }

  friend bool operator!=(const half& a, const half& b)
  {
    return (a.storage != b.storage) ? true : false;
  }

  friend bool operator<(const half& a, const half& b)
  {
    int a_sign = (a.storage >> 15) & 0b1;
    int b_sign = (b.storage >> 15) & 0b1;

    if (a_sign == 0 && b_sign == 1)
      return false;
    else if (a_sign == 1 && b_sign == 0)
      return true;
    else if (a_sign == 0 && b_sign == 0)
      return (a.storage < b.storage) ? true : false;
    else
      return (a.storage > b.storage) ? true : false;
  }

  friend bool operator>(const half& a, const half& b)
  {
    int a_sign = (a.storage >> 15) & 0b1;
    int b_sign = (b.storage >> 15) & 0b1;

    if (a_sign == 0 && b_sign == 1)
      return true;
    else if (a_sign == 1 && b_sign == 0)
      return false;
    else if (a_sign == 0 && b_sign == 0)
      return (a.storage > b.storage) ? true : false;
    else
      return (a.storage < b.storage) ? true : false;
  }

  friend bool operator<=(const half& a, const half& b)
  {
    int a_sign = (a.storage >> 15) & 0b1;
    int b_sign = (b.storage >> 15) & 0b1;

    if (a_sign == 0 && b_sign == 1)
      return false;
    else if (a_sign == 1 && b_sign == 0)
      return true;
    else if (a_sign == 0 && b_sign == 0)
      return (a.storage <= b.storage) ? true : false;
    else
      return (a.storage >= b.storage) ? true : false;
  }

  friend bool operator>=(const half& a, const half& b)
  {
    int a_sign = (a.storage >> 15) & 0b1;
    int b_sign = (b.storage >> 15) & 0b1;

    if (a_sign == 0 && b_sign == 1)
      return true;
    else if (a_sign == 1 && b_sign == 0)
      return false;
    else if (a_sign == 0 && b_sign == 0)
      return (a.storage >= b.storage) ? true : false;
    else
      return (a.storage <= b.storage) ? true : false;
  }

  friend bool is_nan(const half& a)
  {
    return ((((a.storage >> 10) & 0b11111) == 0x1f) && ((a.storage & 0b1111111111) != 0)) ? true : false;
  }

  friend bool is_inf(const half& a)
  {
    return ((((a.storage >> 10) & 0b11111) == 0x1f) && ((a.storage & 0b1111111111) == 0)) ? true : false;
  }

  friend bool is_zero(const half& a)
  {
    return ((((a.storage >> 10) & 0b11111) == 0) && ((a.storage & 0b1111111111) == 0)) ? true : false;
  }

  friend half __hmul(const half& a, const half& b, bool debug)
  {
    if (a.storage == 0 || b.storage == 0) {
      return (uint16_t)((0) | ((a.storage & 0x8000) ^ (b.storage & 0x8000)));
    }

    int32_t a_frac, b_frac, c_frac;
    int32_t a_sign, b_sign, c_sign;
    int32_t a_exp, b_exp, c_exp;

    // 0. unpack
    a_sign = (a.storage >> 15) & 0x1;
    a_exp  = (a.storage >> 10) & 0x1f;
    a_frac = a.storage & 0x3ff;
    b_sign = (b.storage >> 15) & 0x1;
    b_exp  = (b.storage >> 10) & 0x1f;
    b_frac = b.storage & 0x3ff;

    // 1. prenorm
    if (a_exp == 0) {
      a_exp  = 1;
      a_frac = a_frac;
    }
    else {
      a_exp  = a_exp;
      a_frac = (a_frac | 0x400);
    }

    if (b_exp == 0) {
      b_exp  = 1;
      b_frac = b_frac;
    }
    else {
      b_exp  = b_exp;
      b_frac = (b_frac | 0x400);
    }

    // 2. sign
    c_sign = a_sign ^ b_sign;

    // 3. exp
    c_exp = a_exp + b_exp - 15;

    // 4. frac
    c_frac = a_frac * b_frac;

    uint32_t shift_number = (((c_frac >> 19) & 0x7) == 0x1)   ? 1 :
                            (((c_frac >> 18) & 0xf) == 0x1)   ? 2 :
                            (((c_frac >> 17) & 0x1f) == 0x1)  ? 3 :
                            (((c_frac >> 16) & 0x3f) == 0x1)  ? 4 :
                            (((c_frac >> 15) & 0x7f) == 0x1)  ? 5 :
                            (((c_frac >> 14) & 0xff) == 0x1)  ? 6 :
                            (((c_frac >> 13) & 0x1ff) == 0x1) ? 7 :
                            (((c_frac >> 12) & 0x3ff) == 0x1) ? 8 :
                            (((c_frac >> 11) & 0x7ff) == 0x1) ? 9 :
                            (((c_frac >> 10) & 0xfff) == 0x1) ? 10 :
                                                                0;
    int32_t  exp_shift;
    uint32_t frac_shift;
    exp_shift  = c_exp - shift_number;
    frac_shift = c_frac << shift_number;
    frac_shift <<= 10;

    int32_t  exp_norm;
    uint32_t frac_norm, retain_frac, truncation_frac;
    // 6. round and pack
    if (exp_shift > 0) {
      if ((frac_shift >> 31) & 0x1 == 1) {
        exp_norm        = exp_shift + 1;
        frac_norm       = frac_shift;
        retain_frac     = (frac_norm >> 21) & 0x7ff;
        truncation_frac = frac_norm & 0x1fffff;
      }
      else {
        exp_norm        = exp_shift;
        frac_norm       = frac_shift;
        retain_frac     = (frac_norm >> 20) & 0xfff;
        truncation_frac = ((frac_norm & 0xfffff) << 1);
      }
    }
    else {
      frac_norm       = frac_shift >> (-exp_shift);
      exp_norm        = 0;
      retain_frac     = (frac_norm >> 21) & 0x7ff;
      truncation_frac = frac_norm & 0x1fffff;
    }

    uint32_t frac_roundoff_first;
    if (truncation_frac > 0x100000) {
      frac_roundoff_first = retain_frac + 1;
    }
    else if (truncation_frac == 0x100000) {
      if (retain_frac & 0x1 == 1) {
        frac_roundoff_first = retain_frac + 1;
      }
      else {
        frac_roundoff_first = retain_frac;
      }
    }
    else {
      frac_roundoff_first = retain_frac;
    }

    uint32_t frac_roundoff_second;
    if (exp_norm == 0) {
      if (((frac_roundoff_first >> 10) & 0x1) == 1) {
        exp_norm += 1;
        frac_roundoff_second = frac_roundoff_first & 0x3ff;
      }
      else {
        frac_roundoff_second = frac_roundoff_first & 0x3ff;
      }
    }
    else {
      if (((frac_roundoff_first >> 11) & 0x1) == 1) {
        exp_norm += 1;
        frac_roundoff_second = (frac_roundoff_first >> 1) & 0x3ff;
      }
      else {
        frac_roundoff_second = frac_roundoff_first & 0x3ff;
      }
    }

    if (exp_norm > 0x1e) {
      if (c_sign == 1)
        return (uint16_t)0xfbff;
      else
        return (uint16_t)0x7bff;
    }
    else {
      return (uint16_t)(((c_sign & 0x1) << 15) + ((exp_norm & 0x1f) << 10) + (frac_roundoff_second & 0x3ff));
    }
  }

  half& operator*=(const half& b)
  {
    *this = __hmul(*this, b, false);
    return *this;
  }

  friend half operator*(const half& a, const half& b)
  {
    return __hmul(a, b, false);
  }

  friend half operator*(const half& a, const float& b)
  {
    return __hmul(a, half(b), false);
  }

  friend half operator*(const float& a, const half& b)
  {
    return __hmul(half(a), b, false);
  }

  friend half operator*(const half& a, const int& b)
  {
    return __hmul(a, float(b), false);
  }

  friend half operator*(const int& a, const half& b)
  {
    return __hmul(float(a), b, false);
  }

} half;

half __hmul(const half& a, const half& b, bool debug = false);

}  // namespace fp16
}  // namespace common
}  // namespace compute_model