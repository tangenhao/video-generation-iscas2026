#include <cstdint>
#include <svdpi.h>
#include <iostream>

extern "C"
{
  void int4tofloat(
      const svBitVecVal *in,
      svBitVecVal *out)
  {
    int32_t in_val = *(int32_t *)in;
    float out_val = (float)in_val;
    *out = *(svBitVecVal *)(&out_val);
  }

  void FromFloatBits(const svBitVecVal *in,
                     svBitVecVal *out,
                     svBitVecVal *debug)
  {
    uint32_t f = *(uint32_t *)in;
    uint16_t data;

    uint32_t f_exp, f_sig;
    uint16_t h_sgn, h_exp, h_sig;

    h_sgn = (uint16_t)((f & 0x80000000u) >> 16);
    f_exp = (f & 0x7f800000u);

    /* Exponent overflow/NaN converts to signed inf/NaN */
    if (f_exp >= 0x47800000u)
    {
      if (f_exp == 0x7f800000u)
      {
        /* Inf or NaN */
        f_sig = (f & 0x007fffffu);
        if (f_sig != 0)
        {
          /* NaN - propagate the flag in the significand... */
          uint16_t ret = (uint16_t)(0x7c00u + (f_sig >> 13));
          /* ...but make sure it stays a NaN */
          if (ret == 0x7c00u)
          {
            ret++;
          }
          data = h_sgn + ret;
          *(uint16_t *)out = data;
          return;
        }
        else
        {
          /* signed inf */
          data = (uint16_t)(h_sgn + 0x7c00u);
          *(uint16_t *)out = data;
          return;
        }
      }
      else
      {
        data = (uint16_t)(h_sgn + 0x7c00u);
        *(uint16_t *)out = data;
        return;
      }
    }

    /* Exponent underflow converts to a subnormal half or signed zero */
    if (f_exp <= 0x38000000u)
    {
      /*
       * Signed zeros, subnormal floats, and floats with small
       * exponents all convert to signed zero half-floats.
       */
      if (f_exp < 0x33000000u)
      {
        data = h_sgn;
        *(uint16_t *)out = data;
        return;
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
      if (*(uint16_t *)debug)
      {
        std::cout << std::hex << f_sig << std::endl;
      }
      if (((f_sig & 0x00003fffu) != 0x00001000u) || (f & 0x000007ffu))
      {
        f_sig += 0x00001000u;
      }
      if (*(uint16_t *)debug)
      {
        std::cout << std::hex << f_sig << std::endl;
      }
      h_sig = (uint16_t)(f_sig >> 13);
      if (*(uint16_t *)debug)
      {
        std::cout << std::hex << h_sig << std::endl;
      }
      /*
       * If the rounding causes a bit to spill into h_exp, it will
       * increment h_exp from zero to one and h_sig will be zero.
       * This is the correct result.
       */
      data = h_sgn + h_sig;
      *(uint16_t *)out = data;
      return;
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
    if ((f_sig & 0x00003fffu) != 0x00001000u)
    {
      f_sig += 0x00001000u;
    }
    h_sig = (uint16_t)(f_sig >> 13);
    /*
     * If the rounding causes a bit to spill into h_exp, it will
     * increment h_exp by one and h_sig will be zero.  This is the
     * correct result.  h_exp may increment to 15, at greatest, in
     * which case the result overflows to a signed inf.
     */
    data = h_sgn + h_exp + h_sig;
    *(uint16_t *)out = data;
    return;
  }

  void FromFloatBits_bf(
      const svBitVecVal *in,
      svBitVecVal *out,
      svBitVecVal *debug)
  {

    uint32_t f = *(uint32_t *)in;

    uint32_t f_sign, f_exp, f_frac;
    uint16_t h_sign, h_exp, h_frac;

    f_sign = (f >> 31) & 0x1;
    f_exp = (f >> 23) & 0xff;
    f_frac = f & 0x7fffff;

    uint32_t G, R, S;
    G = (f >> 16) & 0x1;
    R = (f >> 15) & 0x1;
    S = ~((f & 0x7fff) == 0);

    uint32_t h_exp_carry_p;
    uint32_t h_carry;
    uint32_t frac_save;

    frac_save = (f >> 16) & 0x7f;
    h_exp_carry_p = (frac_save == 0x7f);
    h_carry = R & (G | S);

    h_sign = f_sign;
    h_frac = (h_carry & h_exp_carry_p) ? 0 : (h_carry ? frac_save + 1 : frac_save);

    h_exp = (h_carry & h_exp_carry_p) ? f_exp + 1 : f_exp;

    uint32_t outlier_sign;
    outlier_sign = (f_exp == 0xff);

    uint16_t h_temp = (h_sign << 15) | (h_exp << 7) | h_frac;
    uint16_t data = outlier_sign ? ((f >> 16) & 0xffff) : h_temp;
    *out = data;
  }

  void ToInt(
      const svBitVecVal *in,
      svBitVecVal *out)
  {
    float in_val = *(float *)in;
    int32_t out_val = (int32_t)in_val;
    *out = *(svBitVecVal *)(&out_val);
  }
}