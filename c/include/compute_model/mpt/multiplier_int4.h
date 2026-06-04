#pragma once

#include <cstdint>
#include <iostream>

namespace compute_model {
namespace mpt {
namespace multiplier {

/*
 * @brief 4bit 无符号乘法器
 * @param a c=a*b的a
 * @param b c=a*b的b
 * @param debug 是否打印debug信息
 * @return
  uint8_t, c=a*b的c
*/
uint8_t MultiplierInt4Unsigned(uint8_t a, uint8_t b, bool debug)
{
  uint8_t a_temp = a & 0xf;
  uint8_t b_temp = b & 0xf;

  if (debug) {
    std::cout << "==== INFO: Original a b ====" << std::endl;
    std::cout << std::hex << "a: " << a_temp << std::endl;
    std::cout << std::hex << "b: " << b_temp << std::endl;
    std::cout << "==== INFO: Result ====" << std::endl;
    std::cout << std::hex << "c: " << ((a_temp * b_temp) & 0xff) << std::endl;
  }
  return (a_temp * b_temp) & 0xff;
}

/*
 * @brief 4bit 有符号乘法器, int4符号位拓展成int8
 * @param a c=a*b的a
 * @param b c=a*b的b
 * @param debug 是否打印debug信息
 * @return
  int16_t, c=a*b的c
*/
int16_t MultiplierInt4Signed(int8_t a, int8_t b, bool debug)
{
  int8_t a_temp = a;
  int8_t b_temp = b;

  if (debug) {
    std::cout << "==== INFO: Original a b ====" << std::endl;
    std::cout << std::hex << "a: " << int(a) << std::endl;
    std::cout << std::hex << "b: " << int(b) << std::endl;
  }

  if (debug) {
    std::cout << "==== INFO: Sign extended a b ====" << std::endl;
    std::cout << std::hex << "a: " << int(a_temp) << std::endl;
    std::cout << std::hex << "b: " << int(b_temp) << std::endl;
  }

  if (debug) {
    std::cout << "==== INFO: Result ====" << std::endl;
    std::cout << std::hex << "c: " << ((a_temp * b_temp)) << std::endl;
  }

  return a_temp * b_temp;
}

}  // namespace multiplier
}  // namespace mpt
}  // namespace compute_model
