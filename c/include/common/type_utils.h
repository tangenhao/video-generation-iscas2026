#pragma once

#include <cstdint>
#include <map>

enum DType : int32_t {
  kInt4     = 0,
  kInt8     = 1,
  kHalf     = 2,
  kBfloat16 = 3,
  kInt16    = 4,
  kInt32    = 5,
  kFloat32  = 6,
  kBool     = 7
};

enum VcuOutSram : int32_t {
  PSUM   = 0,
  OFMAP  = 1,
  VCURES = 2,
  SCALE  = 3
};

std::map<int, uint64_t> vcu_psum_dtype = {
  {kInt4, 7},  // 无该类型输入
  {kInt8, 7},  // 无该类型输入
  {kHalf, 0},
  {kBfloat16, 1},
  {kInt16, 2},
  {kInt32, 3},
  {kFloat32, 4},
  {kBool, 7}  // 无该类型输入
};

std::map<int, uint64_t> vcu_resadd_dtype = {
  {kInt4, 0},
  {kInt8, 1},
  {kHalf, 4},
  {kBfloat16, 5},
  {kInt16, 2},
  {kInt32, 7},  // 无该类型输入
  {kFloat32, 3},
  {kBool, 7}  // 无该类型输入
};

std::map<int, uint64_t> vcu_out_dtype = {
  {kInt4, 0}, {kInt8, 1}, {kHalf, 4}, {kBfloat16, 5}, {kInt16, 2}, {kInt32, 3}, {kFloat32, 7}, {kBool, 6}  // 无该类型输入
};
