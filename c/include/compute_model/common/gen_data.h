#pragma once

#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include <ctime>
#include <iostream>
#include <random>

namespace compute_model {
namespace common {
namespace gen_data {

/*
 * @brief 生成int16随机数
 * @param data 输出数据指针
 * @param size 数据长度
 * @param seed 随机数种子
 */
void GenInt16Data(int16_t* data, int32_t size, int64_t seed)
{
  std::cout << std::hex << "==== INFO: Generate int16 data from random seed 0x" << seed << " ====" << std::endl;
  std::uniform_int_distribution<> dis(-32768, 32767);
  std::default_random_engine      e(seed);

  for (int i = 0; i < size; i++)
    data[i] = (int16_t)dis(e);
}

/*
 * @brief 生成int8随机数
 * @param data 输出数据指针
 * @param size 数据长度
 * @param seed 随机数种子
 */
void GenInt8Data(int8_t* data, int32_t size, int64_t seed)
{
  std::cout << std::hex << "==== INFO: Generate int8 data from random seed 0x" << seed << " ====" << std::endl;
  std::uniform_int_distribution<> dis(-128, 127);
  std::default_random_engine      e(seed);

  for (int i = 0; i < size; i++)
    data[i] = (int8_t)dis(e);
}

/*
 * @brief 生成int4随机数, 但用int8表示
 * @param data 输出数据指针
 * @param size 数据长度
 * @param seed 随机数种子
 */
void GenInt4Data(int8_t* data, int32_t size, int64_t seed)
{
  std::cout << std::hex << "==== INFO: Generate int8 data from random seed 0x" << seed << " ====" << std::endl;
  std::uniform_int_distribution<> dis(-8, 7);
  std::default_random_engine      e(seed);

  for (int i = 0; i < size; i++)
    data[i] = (int8_t)dis(e);
}

/*
 * @brief 生成binray随机数
 * @param data 输出数据指针
 * @param size 数据长度
 * @param seed 随机数种子
 */
void GenBinaryData(bool* data, int32_t size, int64_t seed)
{
  std::cout << std::hex << "==== INFO: Generate binray data from random seed 0x" << seed << " ====" << std::endl;
  std::uniform_int_distribution<> dis(0, 1);
  std::default_random_engine      e(seed);

  for (int i = 0; i < size; i++)
    data[i] = (int8_t)dis(e);
}

/*Z
 * @brief 生成全0数据, int8格式
 * @param data 输出数据指针
 * @param size 数据长度
 */
void GenZeroData(int8_t* data, int32_t size)
{
  for (int i = 0; i < size; i++)
    data[i] = 0;
}

/*
 * @brief 生成全0数据, int32格式
 * @param data 输出数据指针
 * @param size 数据长度
 */
void GenZeroData(int32_t* data, int32_t size)
{
  for (int i = 0; i < size; i++)
    data[i] = 0;
}

float RandomFloat()
{
  std::random_device               rd;
  std::mt19937                     gen(rd());
  std::uniform_real_distribution<> distrib(-1.0, 1.0);
  return distrib(gen);
}

#define FLOAT *(float*)

/*
 * @brief 生成正非规格化单精度浮点数
 * @return float格式, 非规格化单精度浮点正数
 */
float RandomDenormalNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x0, 0x007fffff);
  uint32_t                        num = distrib(gen);
  return FLOAT(&(num));
}

/*
 * @brief 生成正非规格化浮点数
 * @return uint32_t, 非规格化浮点正数, 加法器的float30格式, 1-bit sign, 8-bit exponent, 21-bit fraction
 */
uint32_t AdderRandomDenormalNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib_fraction(0, 0xfffff);

  uint32_t fraction = distrib_fraction(gen);
  return (1 << 29) | (1 << 21) | fraction;
}

/*
 * @brief 生成负非规格化单精度浮点数
 * @return float格式, 非规格化单精度浮点负数
 */
float RandomDenormalPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x80000000, 0x807fffff);
  uint32_t                        num = distrib(gen);
  return FLOAT(&(num));
}

/*
 * @brief 生成负非规格化浮点数
 * @return uint32_t, 非规格化浮点负数, 加法器的float30格式, 1-bit sign, 8-bit exponent, 21-bit fraction
 */
uint32_t AdderRandomDenormalPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib_fraction(0, 0xfffff);

  uint32_t fraction = distrib_fraction(gen);
  return ((1 << 21) | fraction);
}

/*
 * @brief 生成正非规格化单精度浮点数
 * @return float格式, 规格化单精度浮点正数
 */
float RandomNormalPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x00800000, 0x7f7fffff);
  uint32_t                        num = distrib(gen);
  return FLOAT(&(num));
}

/*
 * @brief 生成正非规格化浮点数
 * @return uint32_t, 正非规格化浮点数, 加法器的float30格式, 1-bit sign, 8-bit exponent, 21-bit fraction
 */
uint32_t AdderRandomNormalPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib_fraction(0x200000, 0x1fdfffff);

  uint32_t fraction = distrib_fraction(gen);
  return fraction;
}

/*
 * @brief 生成负规格化单精度浮点数
 * @return float格式, 规格化单精度浮点负数
 */
float RandomNormalNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x80800000, 0xff7fffff);
  uint32_t                        num = distrib(gen);
  return FLOAT(&(num));
}

/*
 * @brief 生成负规格化浮点数
 * @return uint32_t, 负单精度浮点数, 加法器的float30格式, 1-bit sign, 8-bit exponent, 21-bit fraction
 */
uint32_t AdderRandomNormalNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib_fraction(0x200000, 0x1fdfffff);

  uint32_t fraction = distrib_fraction(gen);
  return (1 << 29) | fraction;
}

/*
 * @brief 生成单精度浮点数正无穷
 * @return float格式, 单精度浮点数正无穷
 */
float RandomInfPositive()
{
  uint32_t num = 0x7f800000;
  return FLOAT(&(num));
}

/*
 * @brief 生成浮点数正无穷
 * @return uint32_t, 浮点数正无穷, 加法器的float30格式, 1-bit sign, 8-bit exponent, 21-bit fraction
 */
uint32_t AdderRandomInfPositive()
{
  return 0x1fe00000;
}

/*
 * @brief 生成单精度浮点数负无穷
 * @return float格式, 单精度浮点数负无穷
 */
float RandomInfNegative()
{
  uint32_t num = 0xff800000;
  return FLOAT(&(num));
}

/*
 * @brief 生成浮点数负无穷
 * @return uint32_t, 浮点数负无穷, 加法器的float30格式, 1-bit sign, 8-bit exponent, 21-bit fraction
 */
uint32_t AdderRandomInfNegative()
{
  return 0x3fe00000;
}

/*
 * @brief 生成单精度浮点数正nan
 * @return float格式, 单精度浮点数正nan
 */
float RandomNanPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x7f800001, 0x7fffffff);
  uint32_t                        num = distrib(gen);
  return FLOAT(&(num));
}

/*
 * @brief 生成浮点数正nan
 * @return uint32_t格式, 浮点数正nan, 加法器的float30格式, 1-bit sign, 8-bit exponent, 21-bit fraction
 */
uint32_t AdderRandomNanPositive()
{
  return 0x1fffffff;
}

/*
 * @brief 生成单精度浮点数负nan
 * @return float格式, 单精度浮点数负nan
 */
float RandomNanNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0xff800001, 0xffffffff);
  uint32_t                        num = distrib(gen);
  return FLOAT(&(num));
}

/*
 * @brief 生成浮点数负nan
 * @return uint32_t格式, 浮点数负nan, 加法器的float30格式, 1-bit sign, 8-bit exponent, 21-bit fraction
 */
uint32_t AdderRandomNanNegative()
{
  return 0x3fffffff;
}

fp16::half RandomDenormalHalfPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x0, 0x03ff);
  uint16_t                        num = distrib(gen);
  return fp16::half(num);
}

fp16::half RandomDenormalHalfNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x8000, 0x83ff);
  uint16_t                        num = distrib(gen);
  return fp16::half(num);
}

fp16::half RandomNormalHalfPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x0400, 0x7bff);
  uint16_t                        num = distrib(gen);
  return fp16::half(num);
}

fp16::half RandomNormalHalfNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x8400, 0xfbff);
  uint16_t                        num = distrib(gen);
  return fp16::half(num);
}

fp16::half RandomInfHalfPositive()
{
  return fp16::half(0x7c00);
}

fp16::half RandomInfHalfNegative()
{
  return fp16::half(0xfc00);
}

fp16::half RandomNanHalfPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x7c01, 0x7fff);
  uint16_t                        num = distrib(gen);
  return fp16::half(num);
}

fp16::half RandomNanHalfNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0xfc01, 0xffff);
  uint16_t                        num = distrib(gen);
  return fp16::half(num);
}

bf16::bfloat16 RandomDenormalBFloatPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x0, 0x7f);
  uint16_t                        num = distrib(gen);
  return bf16::bfloat16(num);
}

bf16::bfloat16 RandomDenormalBFloatNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x8000, 0x80ff);
  uint16_t                        num = distrib(gen);
  return bf16::bfloat16(num);
}

bf16::bfloat16 RandomNormalBFloatPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x0, 0x7f7f);
  uint16_t                        num = distrib(gen);
  return bf16::bfloat16(num);
}

bf16::bfloat16 RandomNormalBFloatNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x8000, 0x807f);
  uint16_t                        num = distrib(gen);
  return bf16::bfloat16(num);
}

bf16::bfloat16 RandomInfBFloatPositive()
{
  return bf16::bfloat16(0x7f80);
}

bf16::bfloat16 RandomInfBFloatNegative()
{
  return bf16::bfloat16(0xff80);
}

bf16::bfloat16 RandomNanBFloatPositive()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0x7f81, 0x7fff);
  uint16_t                        num = distrib(gen);
  return bf16::bfloat16(num);
}

bf16::bfloat16 RandomNanBFloatNegative()
{
  std::random_device              rd;
  std::mt19937                    gen(rd());
  std::uniform_int_distribution<> distrib(0xff81, 0xffff);
  uint16_t                        num = distrib(gen);
  return bf16::bfloat16(num);
}

}  // namespace gen_data
}  // namespace common
}  // namespace compute_model