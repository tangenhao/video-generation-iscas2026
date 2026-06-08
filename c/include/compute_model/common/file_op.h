#pragma once

#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>

namespace compute_model {
namespace common {
namespace file_op {

/*
 * @brief 按照指定格式打印数据
 * @param data 输入数据指针
 * @param size 数据长度
 * @param dtype 数据类型, 0为int4, 1为int8, 2为int32
 * @param parallelism, 并行度, 一行输出的数据个数
 */
void PrintTxt(void* data, uint32_t size, uint32_t dtype, uint32_t parallelism)
{
  uint8_t*  buf8  = (uint8_t*)data;
  uint32_t* buf32 = (uint32_t*)data;

  std::stringstream ss;
  std::string       result, tmp;
  for (int i = 0; i < size; ++i) {
    if (i % parallelism == 0) {
      result.clear();
    }
    if (dtype == 0) {
      ss.clear();
      ss << std::setfill('0') << std::setw(1) << std::hex << (int32_t)buf8[i];
      ss >> tmp;
    }
    else if (dtype == 1) {
      ss.clear();
      ss << std::setfill('0') << std::setw(2) << std::hex << (int32_t)buf8[i];
      ss >> tmp;
    }
    else if (dtype == 2) {
      ss.clear();
      ss << std::setfill('0') << std::setw(8) << std::hex << (int32_t)buf32[i];
      ss >> tmp;
    }
    result = tmp + result;
    if (i % parallelism == parallelism - 1) {
      std::cout << std::hex << result << std::endl;
    }
  }
}

/*
 * @brief 按照指定格式将数据保存到txt文件中
 * @param data 输入数据指针
 * @param size 数据长度
 * @param path txt文件路径
 * @param dtype 数据类型, 0为int4, 1为int8, 2为int32
 * @param parallelism 并行度, 一行输出的数据个数
 * @param mode 打开文件的模式, 与std::ofstream的open函数参数相同, 支持std::ios::app, std::ios::out等
 */
void SaveTxt(void* data, uint32_t size, const char* path, uint32_t dtype, uint32_t parallelism, std::ios_base::openmode mode)
{
  uint8_t*  buf8  = (uint8_t*)data;
  uint32_t* buf32 = (uint32_t*)data;

  std::ofstream file;
  file.open(path, mode);
  std::stringstream ss;
  std::string       result, tmp;
  for (int i = 0; i < size; ++i) {
    if (i % parallelism == 0) {
      result.clear();
    }
    if (dtype == 0) {
      ss.clear();
      ss << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)buf8[i] & 0xf);
      ss >> tmp;
    }
    else if (dtype == 1) {
      ss.clear();
      ss << std::setfill('0') << std::setw(2) << std::hex << (int32_t)buf8[i];
      ss >> tmp;
    }
    else if (dtype == 2) {
      ss.clear();
      ss << std::setfill('0') << std::setw(8) << std::hex << (int32_t)buf32[i];
      ss >> tmp;
    }
    result = tmp + result;
    if (i % parallelism == parallelism - 1) {
      file << result << std::endl;
    }
  }
  file.close();
}

}  // namespace file_op
}  // namespace common
}  // namespace compute_model