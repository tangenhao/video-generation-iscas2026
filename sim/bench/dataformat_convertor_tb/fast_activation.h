#pragma once

#include "compute_model/function/int_op.h"
#include "compute_model/function/query.h"

#include <cmath>
#include <cstdint>
#include <limits.h>
#include <vector>

namespace compute_model {
namespace function {

static uint32_t get_exp(float x)
{
  uint32_t bits = *((uint32_t*)&x);
  uint32_t exp  = (bits >> 23) & 0xFF;  // Extract the 8 exponent bits
  return exp;
}

static uint32_t get_man(float x)
{
  uint32_t bits = *((uint32_t*)&x);
  uint32_t man  = bits & 0x007FFFFFU;  // Extract the 23 mantissa bits
  return man;
}

static void get_sign_exp_man(float x, uint32_t& sign, uint32_t& exp, uint32_t& man)
{
  uint32_t bits = *((uint32_t*)&x);
  sign          = bits >> 31;           // Extract the 8 exponent bits
  exp           = (bits >> 23) & 0xFF;  // Extract the 8 exponent bits
  man           = bits & 0x7FFFFF;      // Extract the 23 mantissa bits
}

static bool isNotDenormal(float value)
{
  return std::fpclassify(value) != FP_SUBNORMAL;
}

uint32_t tanh_less_precision_approx(float x, bool debug = false)
{
  int        m = 3, t_ref = 21, p_ref = 12, q_ref = 10;
  const int  t = 21;
  const int  p = 12;
  const int  q = 10;
  uint32_t   result;
  BinaryBase bb;
  bb.value        = x;
  int      real_E = bb.stBinary.exp - 127;  
  uint32_t dx     = (bb.stBinary.x1 << (23 - m)) + bb.stBinary.x2;
  dx |= 0x800000U;  

  dx = dx >> 1;  

  uint32_t x2        = 0;
  uint32_t query_idx = 0;
  uint64_t taylor_items[EXPAND_ITEM_NUM];
  if (bb.stBinary.sign == 0)  
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = tanh_less_precision_database[192];
        taylor_items[1] = tanh_less_precision_database[193];
        taylor_items[2] = tanh_less_precision_database[194];
      }
      else
        assert(0 && "error coefficients");
    }
    
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = tanh_less_precision_database[query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = tanh_less_precision_database[query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = tanh_less_precision_database[query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
    else if (real_E > 2) {
      x2 = 0;
      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = tanh_less_precision_database[381];
        taylor_items[1] = tanh_less_precision_database[382];
        taylor_items[2] = tanh_less_precision_database[383];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = tanh_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = tanh_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = tanh_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
  else if (real_E + 23 < 0) {
    dx = 0;
    x2 = 0;
    
    if (t == t_ref && p == p_ref && q == q_ref) {
      taylor_items[0] = tanh_less_precision_database[0];
      taylor_items[1] = tanh_less_precision_database[1];
      taylor_items[2] = tanh_less_precision_database[2];
    }
    else
      assert(0 && "error coefficients");
  }
  
  else if (real_E + 3 < 0) {
    dx = dx >> (-3 - real_E);  

    /*query_idx = (dx << 9) >> (32 - m);
    x2 = (dx << (m + 9)) >> (m + 9);*/
    query_idx = (dx << 10) >> (32 - m);
    x2        = (dx << (m + 10)) >> (m + 10);

    
    if (t == t_ref && p == p_ref && q == q_ref) {
      taylor_items[0] = tanh_less_precision_database[query_idx * EXPAND_ITEM_NUM];
      taylor_items[1] = tanh_less_precision_database[query_idx * EXPAND_ITEM_NUM + 1];
      taylor_items[2] = tanh_less_precision_database[query_idx * EXPAND_ITEM_NUM + 2];
    }
    else
      assert(0 && "error coefficients");
  }
  else if (real_E > 2) {
    x2 = 0;
    
    if (t == t_ref && p == p_ref && q == q_ref) {
      taylor_items[0] = tanh_less_precision_database[189];
      taylor_items[1] = tanh_less_precision_database[190];
      taylor_items[2] = tanh_less_precision_database[191];
    }
    else
      assert(0 && "error coefficients");
  }
  else {
    
    query_idx = bb.stBinary.x1;
    x2        = bb.stBinary.x2;
    x2        = x2 >> 1;

    
    if (t == t_ref && p == p_ref && q == q_ref) {
      taylor_items[0] = tanh_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM];
      taylor_items[1] = tanh_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 1];
      taylor_items[2] = tanh_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 2];
    }
    else
      assert(0 && "error coefficients");
  }

  if (debug) {
    std::cout << std::hex << "input = " << *(uint32_t*)(&x) << std::endl;
    std::cout << std::hex << "query_idx = " << query_idx << std::endl;
    std::cout << std::hex << "c0 = " << taylor_items[0] << std::endl;
    std::cout << "c1 = " << taylor_items[1] << std::endl;
    std::cout << "c2 = " << taylor_items[2] << std::endl;
    std::cout << "x2 = " << x2 << std::endl;
  }

  // t = 25;p=15;q=10;
  // 2^{-t} * C0 + 2^{-p}* C1 * x2 + 2^{-q} * C2 * x2^2 = sum
  // t = 25           p + 23 = 38            q + 46 = 56
  // error < 2^{-23}
  int max_bits = std::max(t, p + 22);
  max_bits     = std::max(max_bits, q + 44);

  int64_t second_order_item = int64_t(taylor_items[2] * x2) * int64_t(x2);

  int64_t first_order_item = taylor_items[1] * int64_t(x2);

  int64_t zero_order_item = taylor_items[0];

  int64_t sum_item;

  
  sum_item = (zero_order_item << (max_bits - t)) + (first_order_item << (max_bits - p - 22))
             - (second_order_item << (max_bits - q - 44));

  if (debug) {
    std::cout << "second_order_item = " << second_order_item << std::endl;
    std::cout << "first_order_item = " << first_order_item << std::endl;
    std::cout << "zero_order_item = " << zero_order_item << std::endl;
    std::cout << "(max_bits - t) = " << (max_bits - t) << std::endl;
    std::cout << "(max_bits - p - 22) = " << (max_bits - p - 22) << std::endl;
    std::cout << "(max_bits - q - 44) = " << (max_bits - q - 44) << std::endl;
    std::cout << "(zero_order_item << (max_bits - t)) = " << (zero_order_item << (max_bits - t)) << std::endl;
    std::cout << "(first_order_item << (max_bits - p - 22)) = " << (first_order_item << (max_bits - p - 22)) << std::endl;
    std::cout << "(second_order_item << (max_bits - q - 44)) = " << (second_order_item << (max_bits - q - 44)) << std::endl;
    std::cout << "sum_item = " << sum_item << std::endl;
  }

  // if (sum_item < 0)
  //     printf("%f\n", x);

  BinaryBase result_int;
  auto       result_pair = findFirst24BitsAndIndex(sum_item);  // ������

  uint32_t res_man = result_pair.first;  // 24 bit
  if (!res_man)
    result = 0;
  else {
    res_man &= 0x7fffffU;  // get 23 bit.

    if (bb.stBinary.sign)
      result_int.stBinary.sign = 1;
    else
      result_int.stBinary.sign = 0;
    result_int.stBinary.x1  = res_man >> (23 - m);
    result_int.stBinary.x2  = (res_man << (m + 9)) >> (m + 9);
    result_int.stBinary.exp = 127 + 63 - result_pair.second - max_bits;
    result                  = result_int.bin_f;
  }
  if (debug) {
    std::cout << "result = " << result << std::endl;
  }
  return result;
}

uint32_t sigmoid_less_precision_approx(float x, bool debug = false)
{
  int        m = 3, t_ref = 21, p_ref = 12, q_ref = 10;
  const int  t      = 21;
  const int  p      = 12;
  const int  q      = 10;
  uint32_t   result = 0;
  BinaryBase bb;
  bb.value        = x;
  int      real_E = bb.stBinary.exp - 127;  
  uint32_t dx     = (bb.stBinary.x1 << (23 - m)) + bb.stBinary.x2;
  dx |= 0x800000U;  
  // dx &= 0xFFFFFEU;
  dx = dx >> 1;  

  uint32_t x2        = 0;
  uint32_t query_idx = 0;
  uint64_t taylor_items[EXPAND_ITEM_NUM];

  if (bb.stBinary.sign == 0)  
  {
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = sigmoid_less_precision_database[192];
        taylor_items[1] = sigmoid_less_precision_database[193];
        taylor_items[2] = sigmoid_less_precision_database[194];
      }
      else
        assert(0 && "error coefficients");
    }
    
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = sigmoid_less_precision_database[query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = sigmoid_less_precision_database[query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = sigmoid_less_precision_database[query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
    else if (real_E > 3) {
      x2 = 0;
      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = sigmoid_less_precision_database[381];
        taylor_items[1] = sigmoid_less_precision_database[382];
        taylor_items[2] = sigmoid_less_precision_database[383];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = sigmoid_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = sigmoid_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = sigmoid_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
  }
  else {
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = sigmoid_less_precision_database[0];
        taylor_items[1] = sigmoid_less_precision_database[1];
        taylor_items[2] = sigmoid_less_precision_database[2];
      }
      else
        assert(0 && "error coefficients");
    }
    
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = sigmoid_less_precision_database[query_idx * EXPAND_ITEM_NUM];
        taylor_items[1] = sigmoid_less_precision_database[query_idx * EXPAND_ITEM_NUM + 1];
        taylor_items[2] = sigmoid_less_precision_database[query_idx * EXPAND_ITEM_NUM + 2];
      }
      else
        assert(0 && "error coefficients");
    }
    else if (real_E > 3) {
      x2 = 0;
      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = sigmoid_less_precision_database[189];
        taylor_items[1] = sigmoid_less_precision_database[190];
        taylor_items[2] = sigmoid_less_precision_database[191];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = sigmoid_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM];
        taylor_items[1] = sigmoid_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 1];
        taylor_items[2] = sigmoid_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 2];
      }
      else
        assert(0 && "error coefficients");
    }
  }

  if (debug) {
    std::cout << std::hex << "input = " << *(uint32_t*)(&x) << std::endl;
    std::cout << "query_idx = " << query_idx << std::endl;
    std::cout << "c0 = " << taylor_items[0] << std::endl;
    std::cout << "c1 = " << taylor_items[1] << std::endl;
    std::cout << "c2 = " << taylor_items[2] << std::endl;
  }
  // t = 25;p=15;q=10;
  // 2^{-t} * C0 + 2^{-p}* C1 * x2 + 2^{-q} * C2 * x2^2 = sum
  // t = 25           p + 23 = 38            q + 46 = 56
  // error < 2^{-23}
  int max_bits = std::max(t, p + 22);
  max_bits     = std::max(max_bits, q + 44);

  int64_t second_order_item = int64_t(taylor_items[2] * x2) * int64_t(x2);

  int64_t first_order_item = taylor_items[1] * int64_t(x2);

  int64_t zero_order_item = taylor_items[0];

  int64_t sum_item;

  if (debug) {
    std::cout << "second_order_item = " << second_order_item << std::endl;
    std::cout << "first_order_item = " << first_order_item << std::endl;
    std::cout << "zero_order_item = " << zero_order_item << std::endl;
  }

  if (bb.stBinary.sign == 0)
    
    sum_item = (zero_order_item << (max_bits - t)) + (first_order_item << (max_bits - p - 22))
               - (second_order_item << (max_bits - q - 44));
  else
    
    sum_item = (zero_order_item << (max_bits - t)) - (first_order_item << (max_bits - p - 22))
               + (second_order_item << (max_bits - q - 44));

  if (sum_item < 0)
    printf("%f\n", x);

  if (debug) {
    std::cout << "sum_item = " << sum_item << std::endl;
  }

  BinaryBase result_int;
  auto       result_pair = findFirst24BitsAndIndex(sum_item);  // ������

  uint32_t res_man = result_pair.first;  // 24 bit
  if (!res_man)
    result = 0;
  else {
    res_man &= 0x7fffffU;  // get 23 bit.

    result_int.stBinary.sign = 0;
    result_int.stBinary.x1   = res_man >> (23 - m);
    result_int.stBinary.x2   = (res_man << (m + 9)) >> (m + 9);
    result_int.stBinary.exp  = 127 + 63 - result_pair.second - max_bits;
    result                   = result_int.bin_f;
  }

  return result;
}

uint32_t swish_less_precision_approx(float x)
{
  int        m = 3, t_ref = 21, p_ref = 12, q_ref = 10;
  const int  t      = 21;
  const int  p      = 12;
  const int  q      = 10;
  uint32_t   result = 0;
  BinaryBase bb;
  bb.value = x;
  // printf("x=%f, int_x=%x", x, bb.bin_f);
  int      real_E = bb.stBinary.exp - 127;  // ��������
  uint32_t dx     = (bb.stBinary.x1 << (23 - m)) + bb.stBinary.x2;
  dx |= 0x800000U;  // ��������24������������1����������������������������������������1��������������������������1
  // dx &= 0xFFFFFEU;
  dx = dx >> 1;  // ��19����x2

  uint32_t x2        = 0;
  uint32_t query_idx = 0;
  uint64_t taylor_items[EXPAND_ITEM_NUM];
  if (bb.stBinary.sign == 0)  // ����
  {
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[192];
        taylor_items[1] = swish_less_precision_database[193];
        taylor_items[2] = swish_less_precision_database[194];
      }
      else
        assert(0 && "error coefficients");
    }
    // ��������[0,0.125]��
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  // ����

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = swish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = swish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
    else if (real_E > 3) {
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[381];
        taylor_items[1] = swish_less_precision_database[382];
        taylor_items[2] = swish_less_precision_database[383];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      // ��������
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = swish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = swish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
  }
  else {
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[0];
        taylor_items[1] = swish_less_precision_database[1];
        taylor_items[2] = swish_less_precision_database[2];
      }
      else
        assert(0 && "error coefficients");
    }
    // ��������-[0,0.125]��
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  // ����

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[query_idx * EXPAND_ITEM_NUM];
        taylor_items[1] = swish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 1];
        taylor_items[2] = swish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 2];
      }
      else
        assert(0 && "error coefficients");
    }
    // ����-16
    else if (real_E > 3) {
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[189];
        taylor_items[1] = swish_less_precision_database[190];
        taylor_items[2] = swish_less_precision_database[191];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      // ��������
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM];
        taylor_items[1] = swish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 1];
        taylor_items[2] = swish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 2];
      }
      else
        assert(0 && "error coefficients");
    }
  }
  // t = 25;p=15;q=10;
  // 2^{-t} * C0 + 2^{-p}* C1 * x2 + 2^{-q} * C2 * x2^2 = sum
  // t = 25           p + 23 = 38            q + 46 = 56
  // error < 2^{-23}
  int max_bits = std::max(t, p + 22);
  max_bits     = std::max(max_bits, q + 44);

  int64_t second_order_item = int64_t(taylor_items[2] * x2) * int64_t(x2);

  int64_t first_order_item = taylor_items[1] * int64_t(x2);

  int64_t zero_order_item = taylor_items[0];

  int64_t sum_item;

  if (bb.stBinary.sign == 0)
    sum_item = (zero_order_item << (max_bits - t)) + (first_order_item << (max_bits - p - 22))
               + (second_order_item << (max_bits - q - 44));
  else
    // ������������������������
    sum_item = (zero_order_item << (max_bits - t)) - (first_order_item << (max_bits - p - 22))
               - (second_order_item << (max_bits - q - 44));

  if (sum_item < 0)
    printf("%f\n", x);

  if (bb.stBinary.sign == 0 && real_E > 3)
    result = bb.bin_f;
  else {
    BinaryBase result_int;
    // printf("sum_item: %d\n", sum_item);
    auto result_pair = findFirst24BitsAndIndex(sum_item);  // ������

    // ������
    uint32_t res_man = result_pair.first;  // 24 bit
    // printf("res_man: %x\n", res_man);
    if (!res_man)
      result = 0;
    else {
      res_man &= 0x7fffffU;  // get 23 bit.

      if (bb.stBinary.sign)
        result_int.stBinary.sign = 1;
      else
        result_int.stBinary.sign = 0;
      result_int.stBinary.x1  = res_man >> (23 - m);
      result_int.stBinary.x2  = (res_man << (m + 9)) >> (m + 9);
      result_int.stBinary.exp = 127 + 63 - result_pair.second - max_bits;
      // printf("exp: %d\n", result_int.stBinary.exp);
      result = result_int.bin_f;
      // printf("result: %x\n", result);
    }
  }
  return result;
}

uint32_t mish_less_precision_approx(float x)
{
  int        m = 3, t_ref = 21, p_ref = 12, q_ref = 10;
  const int  t      = 21;
  const int  p      = 12;
  const int  q      = 10;
  uint32_t   result = 0;
  BinaryBase bb;
  bb.value        = x;
  int      real_E = bb.stBinary.exp - 127;  // ��������
  uint32_t dx     = (bb.stBinary.x1 << (23 - m)) + bb.stBinary.x2;
  dx |= 0x800000U;  // ��������24������������1����������������������������������������1��������������������������1
  // dx &= 0xFFFFFEU;
  dx = dx >> 1;  // ��19����x2

  uint32_t x2        = 0;
  uint32_t query_idx = 0;
  uint64_t taylor_items[EXPAND_ITEM_NUM];
  if (bb.stBinary.sign == 0)  // ����
  {
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = mish_less_precision_database[192];
        taylor_items[1] = mish_less_precision_database[193];
        taylor_items[2] = mish_less_precision_database[194];
      }
      else
        assert(0 && "error coefficients");
    }
    // ��������[0,0.125]��
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  // ����

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = mish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = mish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = mish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
    else if (real_E > 3) {
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = mish_less_precision_database[381];
        taylor_items[1] = mish_less_precision_database[382];
        taylor_items[2] = mish_less_precision_database[383];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      // ��������
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = mish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = mish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = mish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
  }
  else {
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = mish_less_precision_database[0];
        taylor_items[1] = mish_less_precision_database[1];
        taylor_items[2] = mish_less_precision_database[2];
      }
      else
        assert(0 && "error coefficients");
    }
    // ��������-[0,0.125]��
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  // ����

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = mish_less_precision_database[query_idx * EXPAND_ITEM_NUM];
        taylor_items[1] = mish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 1];
        taylor_items[2] = mish_less_precision_database[query_idx * EXPAND_ITEM_NUM + 2];
      }
      else
        assert(0 && "error coefficients");
    }
    // ����-16
    else if (real_E > 3) {
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[189];
        taylor_items[1] = swish_less_precision_database[190];
        taylor_items[2] = swish_less_precision_database[191];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      // ��������
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = mish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM];
        taylor_items[1] = mish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 1];
        taylor_items[2] = mish_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 2];
      }
      else
        assert(0 && "error coefficients");
    }
  }
  // t = 25;p=15;q=10;
  // 2^{-t} * C0 + 2^{-p}* C1 * x2 + 2^{-q} * C2 * x2^2 = sum
  // t = 25           p + 23 = 38            q + 46 = 56
  // error < 2^{-23}
  int max_bits = std::max(t, p + 22);
  max_bits     = std::max(max_bits, q + 44);

  int64_t second_order_item = int64_t(taylor_items[2] * x2) * int64_t(x2);

  int64_t first_order_item = taylor_items[1] * int64_t(x2);

  int64_t zero_order_item = taylor_items[0];

  int64_t sum_item;

  if (bb.stBinary.sign == 0)
    sum_item = (zero_order_item << (max_bits - t)) + (first_order_item << (max_bits - p - 22))
               + (second_order_item << (max_bits - q - 44));
  else
    sum_item = (zero_order_item << (max_bits - t)) - (first_order_item << (max_bits - p - 22))
               - (second_order_item << (max_bits - q - 44));

  if (sum_item < 0)
    printf("%f\n", x);

  if (bb.stBinary.sign == 0 && real_E > 3)
    result = bb.bin_f;
  else {
    BinaryBase result_int;
    auto       result_pair = findFirst24BitsAndIndex(sum_item);  // ������

    // ������
    uint32_t res_man = result_pair.first;  // 24 bit
    if (!res_man)
      result = 0;
    else {
      res_man &= 0x7fffffU;  // get 23 bit.

      if (bb.stBinary.sign)
        result_int.stBinary.sign = 1;
      else
        result_int.stBinary.sign = 0;
      result_int.stBinary.x1  = res_man >> (23 - m);
      result_int.stBinary.x2  = (res_man << (m + 9)) >> (m + 9);
      result_int.stBinary.exp = 127 + 63 - result_pair.second - max_bits;
      result                  = result_int.bin_f;
    }
  }
  return result;
}

uint32_t gelu_less_precision_approx(float x)
{
  int        m = 3, t_ref = 21, p_ref = 12, q_ref = 10;
  const int  t      = 21;
  const int  p      = 12;
  const int  q      = 10;
  uint32_t   result = 0;
  BinaryBase bb;
  bb.value        = x;
  int      real_E = bb.stBinary.exp - 127;  // ��������
  uint32_t dx     = (bb.stBinary.x1 << (23 - m)) + bb.stBinary.x2;
  dx |= 0x800000U;  // ��������24������������1����������������������������������������1��������������������������1
  // dx &= 0xFFFFFEU;
  dx = dx >> 1;  // ��19����x2

  uint32_t x2        = 0;
  uint32_t query_idx = 0;
  uint64_t taylor_items[EXPAND_ITEM_NUM];
  if (bb.stBinary.sign == 0)  // ����
  {
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = gelu_less_precision_database[192];
        taylor_items[1] = gelu_less_precision_database[193];
        taylor_items[2] = gelu_less_precision_database[194];
      }
      else
        assert(0 && "error coefficients");
    }
    // ��������[0,0.125]��
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  // ����

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = gelu_less_precision_database[query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = gelu_less_precision_database[query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = gelu_less_precision_database[query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
    else if (real_E > 3) {
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = gelu_less_precision_database[381];
        taylor_items[1] = gelu_less_precision_database[382];
        taylor_items[2] = gelu_less_precision_database[383];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      // ��������
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = gelu_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 192];
        taylor_items[1] = gelu_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 193];
        taylor_items[2] = gelu_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 194];
      }
      else
        assert(0 && "error coefficients");
    }
  }
  else {
    if (real_E + 23 < 0) {
      dx = 0;
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = gelu_less_precision_database[0];
        taylor_items[1] = gelu_less_precision_database[1];
        taylor_items[2] = gelu_less_precision_database[2];
      }
      else
        assert(0 && "error coefficients");
    }
    // ��������-[0,0.125]��
    else if (real_E + 3 < 0) {
      dx = dx >> (-3 - real_E);  // ����

      /*query_idx = (dx << 9) >> (32 - m);
      x2 = (dx << (m + 9)) >> (m + 9);*/
      query_idx = (dx << 10) >> (32 - m);
      x2        = (dx << (m + 10)) >> (m + 10);

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = gelu_less_precision_database[query_idx * EXPAND_ITEM_NUM];
        taylor_items[1] = gelu_less_precision_database[query_idx * EXPAND_ITEM_NUM + 1];
        taylor_items[2] = gelu_less_precision_database[query_idx * EXPAND_ITEM_NUM + 2];
      }
      else
        assert(0 && "error coefficients");
    }
    // ����-16
    else if (real_E > 3) {
      x2 = 0;
      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = swish_less_precision_database[189];
        taylor_items[1] = swish_less_precision_database[190];
        taylor_items[2] = swish_less_precision_database[191];
      }
      else
        assert(0 && "error coefficients");
    }
    else {
      // ��������
      query_idx = bb.stBinary.x1;
      x2        = bb.stBinary.x2;
      x2        = x2 >> 1;

      // ����t��p��q��������������������database����������
      if (t == t_ref && p == p_ref && q == q_ref) {
        taylor_items[0] = gelu_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM];
        taylor_items[1] = gelu_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 1];
        taylor_items[2] = gelu_less_precision_database[(real_E + 4) * 24 + query_idx * EXPAND_ITEM_NUM + 2];
      }
      else
        assert(0 && "error coefficients");
    }
  }
  // t = 25;p=15;q=10;
  // 2^{-t} * C0 + 2^{-p}* C1 * x2 + 2^{-q} * C2 * x2^2 = sum
  // t = 25           p + 23 = 38            q + 46 = 56
  // error < 2^{-23}
  int max_bits = std::max(t, p + 22);
  max_bits     = std::max(max_bits, q + 44);

  int64_t second_order_item = int64_t(taylor_items[2] * x2) * int64_t(x2);

  int64_t first_order_item = taylor_items[1] * int64_t(x2);

  int64_t zero_order_item = taylor_items[0];

  int64_t sum_item;

  if (bb.stBinary.sign == 0)
    sum_item = (zero_order_item << (max_bits - t)) + (first_order_item << (max_bits - p - 22))
               + (second_order_item << (max_bits - q - 44));
  else
    sum_item = (zero_order_item << (max_bits - t)) - (first_order_item << (max_bits - p - 22))
               - (second_order_item << (max_bits - q - 44));

  if (sum_item < 0)
    printf("%f\n", x);

  if (bb.stBinary.sign == 0 && real_E > 3)
    result = bb.bin_f;
  else {
    BinaryBase result_int;
    auto       result_pair = findFirst24BitsAndIndex(sum_item);  // ������

    // ������
    uint32_t res_man = result_pair.first;  // 24 bit
    if (!res_man)
      result = 0;
    else {
      res_man &= 0x7fffffU;  // get 23 bit.

      if (bb.stBinary.sign)
        result_int.stBinary.sign = 1;
      else
        result_int.stBinary.sign = 0;
      result_int.stBinary.x1  = res_man >> (23 - m);
      result_int.stBinary.x2  = (res_man << (m + 9)) >> (m + 9);
      result_int.stBinary.exp = 127 + 63 - result_pair.second - max_bits;
      result                  = result_int.bin_f;
    }
  }
  return result;
}

}  // namespace function
}  // namespace compute_model