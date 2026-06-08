#pragma once

#include <cassert>
#include <cstdint>
#include <iostream>

namespace compute_model {

namespace common {
namespace bf16 {

uint16_t FromFloatBits(uint32_t f)
{
  uint32_t f_sign, f_exp, f_frac;
  uint16_t h_sign, h_exp, h_frac;

  f_sign = (f >> 31) & 0x1;
  f_exp  = (f >> 23) & 0xff;
  f_frac = f & 0x7fffff;

  uint32_t G, R, S;
  G = (f >> 16) & 0x1;
  R = (f >> 15) & 0x1;
  S = ~((f & 0x7fff) == 0);

  uint32_t h_exp_carry_p;
  uint32_t h_carry;
  uint32_t frac_save;

  frac_save     = (f >> 16) & 0x7f;
  h_exp_carry_p = (frac_save == 0x7f);
  h_carry       = R & (G | S);

  h_sign = f_sign;
  h_frac = (h_carry & h_exp_carry_p) ? 0 : (h_carry ? frac_save + 1 : frac_save);

  h_exp = (h_carry & h_exp_carry_p) ? f_exp + 1 : f_exp;

  uint32_t outlier_sign;
  outlier_sign = (f_exp == 0xff);

  uint16_t h_temp = (h_sign << 15) | (h_exp << 7) | h_frac;
  uint16_t out    = outlier_sign ? ((f >> 16) & 0xffff) : h_temp;
  return out;
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
        uint16_t ret = (uint16_t)(0x7f80u + (d_sig >> 45));
        /* ...but make sure it stays a NaN */
        if (ret == 0x7f80u) {
          ret++;
        }
        return h_sgn + ret;
      }
      else {
        /* signed inf */
        return h_sgn + 0x7f80u;
      }
    }
    else {
      return h_sgn + 0x7f80u;
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

    h_sig = (uint16_t)(d_sig >> 56);
    /*
     * If the rounding causes a bit to spill into h_exp, it will
     * increment h_exp from zero to one and h_sig will be zero.
     * This is the correct result.
     */
    return h_sgn + h_sig;
  }

  /* Regular case with no overflow or underflow */
  h_exp = (uint16_t)((d_exp - 0x3800000000000000ULL) >> 45);
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

  h_sig = (uint16_t)(d_sig >> 45);

  /*
   * If the rounding causes a bit to spill into h_exp, it will
   * increment h_exp by one and h_sig will be zero.  This is the
   * correct result.  h_exp may increment to 15, at greatest, in
   * which case the result overflows to a signed inf.
   */

  return h_sgn + h_exp + h_sig;
}

uint32_t ToFloatBits(uint16_t h)
{
  uint16_t h_exp = (h & 0x7f80u);
  uint32_t f_sgn = ((uint32_t)h & 0x8000u) << 16;
  switch (h_exp) {
    case 0x0000u: {  // 0 or subnormal
      uint16_t h_sig = (h & 0x7f);
      // Signed zero
      if (h_sig == 0) {
        return f_sgn;
      }
      // Subnormal
      h_sig <<= 1;
      while ((h_sig & 0x080u) == 0) {
        h_sig <<= 1;
        h_exp++;
      }
      uint32_t f_exp = ((uint32_t)h_exp) << 23;
      uint32_t f_sig = ((uint32_t)(h_sig & 0x07fu)) << 16;
      return f_sgn + f_exp + f_sig;
    }
    case 0x7f80u:  // inf or NaN
      // All-ones exponent and a copy of the significand
      return f_sgn + 0x7f800000u + (((uint32_t)(h & 0x07fu)) << 16);
    default:  // normalized
      // Just need to adjust the exponent and shift
      return f_sgn + (((uint32_t)(h & 0x7fffu)) << 16);
  }
}

uint64_t ToDoubleBits(uint16_t h)
{
  uint16_t h_exp = (h & 0x7f80u);
  uint64_t d_sgn = ((uint64_t)h & 0x8000u) << 48;
  switch (h_exp) {
    case 0x0000u: {  // 0 or subnormal
      uint16_t h_sig = (h & 0x07fu);
      // Signed zero
      if (h_sig == 0) {
        return d_sgn;
      }
      // Subnormal
      h_sig <<= 1;
      while ((h_sig & 0x080u) == 0) {
        h_sig <<= 1;
        h_exp++;
      }
      uint64_t d_exp = ((uint64_t)(1023 - 127 - h_exp)) << 52;
      uint64_t d_sig = ((uint64_t)(h_sig & 0x07fu)) << 42;
      return d_sgn + d_exp + d_sig;
    }
    case 0x7f80u:  // inf or NaN
      // All-ones exponent and a copy of the significand
      return d_sgn + 0x7ff0000000000000ULL + (((uint64_t)(h & 0x07fu)) << 42);
    default:  // normalized
      // Just need to adjust the exponent and shift
      return d_sgn + (((uint64_t)(h & 0x7fffu) + 0xfc000u) << 42);
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
  return ((((a >> 7) & 0b11111111) == 0xff) && ((a & 0b1111111) != 0)) ? true : false;
}

inline bool is_inf(uint16_t a)
{
  return ((((a >> 7) & 0b11111111) == 0xff) && ((a & 0b1111111) == 0)) ? true : false;
}

inline bool is_zero(uint16_t a)
{
  return ((((a >> 7) & 0b11111111) == 0) && ((a & 0b1111111) == 0)) ? true : false;
}

typedef struct bfloat16 {

  uint16_t storage;

  bfloat16(): storage(0) {}

  bfloat16(const uint16_t& h): storage(h) {}

  bfloat16(const uint32_t& h): storage(uint16_t(h)) {}

  bfloat16(const int32_t& h): storage(uint16_t(h)) {}

  bfloat16(const float& f): storage(FromFloatBits(FloatToBits(f))) {}

  bfloat16(const double& d): storage(FromDoubleBits(DoubleToBits(d))) {}

  bfloat16& operator=(const uint16_t& h)
  {
    storage = h;
    return *this;
  }

  bfloat16& operator=(const float& f)
  {
    storage = FromFloatBits(FloatToBits(f));
    return *this;
  }

  bfloat16& operator=(const double& d)
  {
    storage = FromDoubleBits(DoubleToBits(d));
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

  friend std::ostream& operator<<(std::ostream& os, const bfloat16& h)
  {
    os << (float)h;
    return os;
  }

  friend std::istream& operator>>(std::istream& is, bfloat16& h)
  {
    float f;
    is >> f;
    h = f;
    return is;
  }

  friend bool operator==(const bfloat16& a, const bfloat16& b)
  {
    return (a.storage == b.storage) ? true : false;
  }

  friend bool operator!=(const bfloat16& a, const bfloat16& b)
  {
    return (a.storage != b.storage) ? true : false;
  }

  friend bool operator<(const bfloat16& a, const bfloat16& b)
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

  friend bool operator>(const bfloat16& a, const bfloat16& b)
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

  friend bool operator<=(const bfloat16& a, const bfloat16& b)
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

  friend bool operator>=(const bfloat16& a, const bfloat16& b)
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

  bfloat16& operator<<(const int& shift)
  {
    storage = storage << shift;
    return *this;
  }

  bfloat16& operator>>(const int& shift)
  {
    storage = storage >> shift;
    return *this;
  }

  friend bool is_nan(const bfloat16& a)
  {
    return ((((a.storage >> 10) & 0b11111) == 0x1f) && ((a.storage & 0b1111111111) != 0)) ? true : false;
  }

  friend bool is_inf(const bfloat16& a)
  {
    return ((((a.storage >> 10) & 0b11111) == 0x1f) && ((a.storage & 0b1111111111) == 0)) ? true : false;
  }

  friend bool is_zero(const bfloat16& a)
  {
    return ((((a.storage >> 10) & 0b11111) == 0) && ((a.storage & 0b1111111111) == 0)) ? true : false;
  }

} bfloat16;
}  // namespace bf16
}  // namespace common
}  // namespace compute_model