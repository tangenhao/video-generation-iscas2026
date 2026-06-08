#pragma once

#include "common/type_utils.h"
#include "compute_model/common/bf16.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/subbyte.h"
#include <cassert>
#include <cmath>
#include <cstdint>
#include <ctime>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <random>
#include <typeinfo>
#include <vector>

namespace compute_model {
namespace tensor {

template<typename T>
void print(const std::vector<T>& ve, std::string delimiter = ",", std::string parenthese = "{}")
{
  std::cout << parenthese[0];
  std::string delim;
  if (delimiter == " ")
    delimiter.clear();
  for (auto& item : ve) {
    std::cout << delim << item;
    delim = delimiter + " ";
  }
  std::cout << parenthese[1];
}

template<typename T>
void print(std::ostream& os, const std::vector<T>& ve, std::string delimiter = ",", std::string parenthese = "{}", int dtype = kFloat32)
{
  os << parenthese[0];
  std::string delim;
  if (delimiter == " ")
    delimiter.clear();
  for (auto& item : ve) {
    if (dtype == kInt8 || dtype == kInt4) {
      os << delim << (int32_t)(float)item;
    }
    else {
      os << delim << item;
    }
    delim = delimiter + " ";
  }
  os << parenthese[1];
}

template<typename T>
struct Tensor {
  std::vector<T>   data;
  std::vector<int> shape_;
  DType            dtype;

  Tensor(): dtype(kInt8)
  {
    data = std::vector<T>();
  }

  Tensor(T* data, std::vector<int> shape_, DType dtype): shape_(shape_), dtype(dtype)
  {
    int size = 1;
    for (auto dim : shape_) {
      size *= dim;
    }
    this->data = std::vector<T>(size);
    for (int i = 0; i < size; ++i) {
      this->data[i] = data[i];
    }
  }

  Tensor(std::vector<T> data, std::vector<int> shape_, DType dtype): data(data), shape_(shape_), dtype(dtype) {}

  Tensor(std::vector<int> shape_, DType dtype): shape_(shape_), dtype(dtype)
  {
    try {
      bool valid_shape = true;
      for (auto dim : shape_) {
        if (dim <= 0) {
          valid_shape = false;
          break;
        }
      }
      if (!valid_shape)
        throw std::runtime_error("Invalid shape.");
    }
    catch (const std::exception& e) {
      std::cout << e.what() << std::endl;
      std::cout << "shape: ";
      print<int>(shape_);
      std::cout << std::endl;
      std::cout << "The shape should be positive." << std::endl;
      throw;
    }

    int size = 1;
    for (auto dim : shape_) {
      size *= dim;
    }
    this->data = std::vector<T>(size);
  }

  std::string getDtypeName(int dtype) const
  {
    switch (dtype) {
      case kInt4:
        return "kInt4";
      case kInt8:
        return "kInt8";
      case kHalf:
        return "kHalf";
      case kBfloat16:
        return "kBfloat16";
      case kInt32:
        return "kInt32";
      default:
        return "kInt8";
    }
  }

  std::string getDtypeName() const
  {
    switch (this->dtype) {
      case kInt8:
        return "kInt8";
      case kHalf:
        return "kHalf";
      case kBfloat16:
        return "kBfloat16";
      case kInt32:
        return "kInt32";
      case kInt16:
        return "kInt16";
      case kFloat32:
        return "kFloat32";
      default:
        return "kInt8";
    }
  }

  T* data_ptr()
  {
    return (T*)(data.data());
  }

  template<typename U>
  U* data_ptr()
  {
    return (U*)(data.data());
  }

  std::string size()
  {
    std::string result = "[";
    for (auto i : shape_) {
      result += std::to_string(i) + ", ";
    }
    result.pop_back();
    result.pop_back();
    result += "]";
    return result;
  }

  int numel()
  {
    int result = 1;
    for (auto i : shape_) {
      result *= i;
    }
    return result;
  }

  void unsqueeze(int dim)
  {
    try {
      if (dim < 0 || dim > shape_.size())
        throw std::runtime_error("Invalid dim.");
    }
    catch (const std::exception& e) {
      std::cout << e.what() << std::endl;
      std::cout << "dim: " << dim << std::endl;
      std::cout << "The dim should be in the range of [0, " << shape_.size() << "]." << std::endl;
      throw;
    }
    shape_.insert(shape_.begin() + dim, 1);
  }

  friend std::ostream& operator<<(std::ostream& os, const Tensor& t)
  {
    if (t.shape_.size() == 1) {
      print<T>(os, t.data, ",", "{}", t.dtype);
      os << ", Shape: ";
      print(os, t.shape_, ",", "{}");
      os << ", Dtype: " << t.getDtypeName();
    }
    else if (t.shape_.size() == 2) {
      os << "[";
      for (int i = 0; i < t.shape_[0]; ++i) {
        auto sub = std::vector<T>(t.data.begin() + i * t.shape_[1], t.data.begin() + (i + 1) * t.shape_[1]);
        print<T>(os, sub, ",", "[]", t.dtype);
        if (i != t.shape_[0] - 1)
          os << "," << std::endl;
        else
          os << "]";
      }
      os << ", Shape: ";
      print(os, t.shape_, ",", "{}");
      os << ", Dtype: " << t.getDtypeName();
    }
    else if (t.shape_.size() == 3) {
      os << "[";
      for (int i = 0; i < t.shape_[0]; ++i) {
        os << "[";
        for (int j = 0; j < t.shape_[1]; ++j) {
          auto sub = std::vector<T>(t.data.begin() + i * t.shape_[1] * t.shape_[2] + j * t.shape_[2],
                                    t.data.begin() + i * t.shape_[1] * t.shape_[2] + (j + 1) * t.shape_[2]);
          print<T>(os, sub, ",", "[]", t.dtype);
          if (j != t.shape_[1] - 1)
            os << "," << std::endl;
          else
            os << "]";
        }
        if (i != t.shape_[0] - 1)
          os << "," << std::endl;
        else
          os << "]";
      }
      os << ", Shape: ";
      print(os, t.shape_, ",", "{}");
      os << ", Dtype: " << t.getDtypeName();
    }
    else if (t.shape_.size() == 4) {
      os << "[";
      for (int i = 0; i < t.shape_[0]; ++i) {
        os << "[";
        for (int j = 0; j < t.shape_[1]; ++j) {
          os << "[";
          for (int k = 0; k < t.shape_[2]; ++k) {
            auto sub = std::vector<T>(
              t.data.begin() + i * t.shape_[1] * t.shape_[2] * t.shape_[3] + j * t.shape_[2] * t.shape_[3] + k * t.shape_[3],
              t.data.begin() + i * t.shape_[1] * t.shape_[2] * t.shape_[3] + j * t.shape_[2] * t.shape_[3] + (k + 1) * t.shape_[3]);
            print<T>(os, sub, ",", "[]", t.dtype);
            if (k != t.shape_[2] - 1)
              os << "," << std::endl;
            else
              os << "]";
          }
          if (j != t.shape_[1] - 1)
            os << "," << std::endl;
          else
            os << "]" << std::endl;
        }
        if (i != t.shape_[0] - 1)
          os << "," << std::endl;
        else
          os << "]";
      }
      os << ", Shape: ";
      print(os, t.shape_, ",", "{}");
      os << ", Dtype: " << t.getDtypeName();
    }
    else if (t.shape_.size() == 5) {
      os << "[";
      for (int i = 0; i < t.shape_[0]; ++i) {
        os << "[";
        for (int j = 0; j < t.shape_[1]; ++j) {
          os << "[";
          for (int k = 0; k < t.shape_[2]; ++k) {
            os << "[";
            for (int l = 0; l < t.shape_[3]; ++l) {
              auto sub =
                std::vector<T>(t.data.begin() + i * t.shape_[1] * t.shape_[2] * t.shape_[3] * t.shape_[4]
                                 + j * t.shape_[2] * t.shape_[3] * t.shape_[4] + k * t.shape_[3] * t.shape_[4] + l * t.shape_[4],
                               t.data.begin() + i * t.shape_[1] * t.shape_[2] * t.shape_[3] * t.shape_[4]
                                 + j * t.shape_[2] * t.shape_[3] * t.shape_[4] + k * t.shape_[3] * t.shape_[4] + (l + 1) * t.shape_[4]);
              print<T>(os, sub, ",", "[]", t.dtype);
              if (l != t.shape_[3] - 1)
                os << "," << std::endl;
              else
                os << "]";
            }
            if (k != t.shape_[2] - 1)
              os << "," << std::endl;
            else
              os << "]";
          }
          if (j != t.shape_[1] - 1)
            os << "," << std::endl;
          else
            os << "]" << std::endl;
        }
        if (i != t.shape_[0] - 1)
          os << "," << std::endl;
        else
          os << "]";
      }
      os << ", Shape: ";
      print(os, t.shape_, ",", "{}");
      os << ", Dtype: " << t.getDtypeName();
    }
    else if (t.shape_.size() == 6) {
      os << "[";
      for (int i = 0; i < t.shape_[0]; ++i) {
        os << "[";
        for (int j = 0; j < t.shape_[1]; ++j) {
          os << "[";
          for (int k = 0; k < t.shape_[2]; ++k) {
            os << "[";
            for (int l = 0; l < t.shape_[3]; ++l) {
              os << "[";
              for (int m = 0; m < t.shape_[4]; ++m) {
                auto sub =
                  std::vector<T>(t.data.begin() + i * t.shape_[1] * t.shape_[2] * t.shape_[3] * t.shape_[4] * t.shape_[5]
                                   + j * t.shape_[2] * t.shape_[3] * t.shape_[4] * t.shape_[5] + k * t.shape_[3] * t.shape_[4] * t.shape_[5]
                                   + l * t.shape_[4] * t.shape_[5] + m * t.shape_[5],
                                 t.data.begin() + i * t.shape_[1] * t.shape_[2] * t.shape_[3] * t.shape_[4] * t.shape_[5]
                                   + j * t.shape_[2] * t.shape_[3] * t.shape_[4] * t.shape_[5] + k * t.shape_[3] * t.shape_[4] * t.shape_[5]
                                   + l * t.shape_[4] * t.shape_[5] + (m + 1) * t.shape_[5]);
                print<T>(os, sub, ",", "[]", t.dtype);
                if (m != t.shape_[4] - 1)
                  os << "," << std::endl;
                else
                  os << "]";
              }
              if (l != t.shape_[3] - 1)
                os << "," << std::endl;
              else
                os << "]";
            }
            if (k != t.shape_[2] - 1)
              os << "," << std::endl;
            else
              os << "]";
          }
          if (j != t.shape_[1] - 1)
            os << "," << std::endl;
          else
            os << "]" << std::endl;
        }
        if (i != t.shape_[0] - 1)
          os << "," << std::endl;
        else
          os << "]";
      }
      os << ", Shape: ";
      print(os, t.shape_, ",", "{}");
      os << ", Dtype: " << t.getDtypeName();
    }
    else if (t.shape_.size() == 7) {
      os << "[";
      for (int i = 0; i < t.shape_[0]; ++i) {
        os << "[";
        for (int j = 0; j < t.shape_[1]; ++j) {
          os << "[";
          for (int k = 0; k < t.shape_[2]; ++k) {
            os << "[";
            for (int l = 0; l < t.shape_[3]; ++l) {
              os << "[";
              for (int m = 0; m < t.shape_[4]; ++m) {
                os << "[";
                for (int n = 0; n < t.shape_[5]; ++n) {
                  auto sub =
                    std::vector<T>(t.data.begin() + i * t.shape_[1] * t.shape_[2] * t.shape_[3] * t.shape_[4] * t.shape_[5] * t.shape_[6]
                                     + j * t.shape_[2] * t.shape_[3] * t.shape_[4] * t.shape_[5] * t.shape_[6]
                                     + k * t.shape_[3] * t.shape_[4] * t.shape_[5] * t.shape_[6]
                                     + l * t.shape_[4] * t.shape_[5] * t.shape_[6] + m * t.shape_[5] * t.shape_[6] + n * t.shape_[6],
                                   t.data.begin() + i * t.shape_[1] * t.shape_[2] * t.shape_[3] * t.shape_[4] * t.shape_[5] * t.shape_[6]
                                     + j * t.shape_[2] * t.shape_[3] * t.shape_[4] * t.shape_[5] * t.shape_[6]
                                     + k * t.shape_[3] * t.shape_[4] * t.shape_[5] * t.shape_[6]
                                     + l * t.shape_[4] * t.shape_[5] * t.shape_[6] + m * t.shape_[5] * t.shape_[6] + (n + 1) * t.shape_[6]);
                  print<T>(os, sub, ",", "[]", t.dtype);
                  if (n != t.shape_[5] - 1)
                    os << "," << std::endl;
                  else
                    os << "]";
                }
                if (m != t.shape_[4] - 1)
                  os << "," << std::endl;
                else
                  os << "]";
              }
              if (l != t.shape_[3] - 1)
                os << "," << std::endl;
              else
                os << "]";
            }
            if (k != t.shape_[2] - 1)
              os << "," << std::endl;
            else
              os << "]";
          }
          if (j != t.shape_[1] - 1)
            os << "," << std::endl;
          else
            os << "]" << std::endl;
        }
        if (i != t.shape_[0] - 1)
          os << "," << std::endl;
        else
          os << "]";
      }
      os << ", Shape: ";
      print(os, t.shape_, ",", "{}");
      os << ", Dtype: " << t.getDtypeName();
    }
    else {
      os << "Not implemented yet.";
      throw std::runtime_error("Not implemented yet.");
    }
    return os;
  }

  std::vector<int> shape()
  {
    return shape_;
  }

  int shape(int dim) const
  {
    try {
      if (dim < 0 || dim >= shape_.size())
        throw std::runtime_error("Invalid dim.");
      return shape_[dim];
    }
    catch (const std::exception& e) {
      std::cout << e.what() << std::endl;
      std::cout << "dim: " << dim << std::endl;
      std::cout << "The dim should be in the range of [0, " << shape_.size() - 1 << "]." << std::endl;
      throw;
    }
  }

  using iterator               = typename std::vector<T>::iterator;
  using const_iterator         = typename std::vector<T>::const_iterator;
  using reverse_iterator       = typename std::vector<T>::reverse_iterator;
  using const_reverse_iterator = typename std::vector<T>::const_reverse_iterator;

  iterator begin()
  {
    return data.begin();
  }

  iterator end()
  {
    return data.end();
  }

  const_iterator cbegin() const
  {
    return data.cbegin();
  }

  const_iterator cend() const
  {
    return data.cend();
  }

  reverse_iterator rbegin()
  {
    return data.rbegin();
  }

  reverse_iterator rend()
  {
    return data.rend();
  }

  const_reverse_iterator crbegin() const
  {
    return data.crbegin();
  }

  const_reverse_iterator crend() const
  {
    return data.crend();
  }

  T& operator[](int index)
  {
    return data[index];
  }

  const T& operator[](const int index) const
  {
    return data[index];
  }

  // Tensor operator+(const Tensor& t)
  // {
  //   assert(shape_ == t.shape_);
  //   assert(dtype == t.dtype);
  //   Tensor result(shape_, dtype);
  //   for (int i = 0; i < data.size(); i++) {
  //     result[i] = data[i] + t[i];
  //   }
  //   return result;
  // }

  Tensor operator+(const Tensor& t)
  {
    Tensor result(shape_, dtype);
    if (shape_ != t.shape_) {
      if (shape_.size() == 4) {
        assert(shape_[0] == t.shape_[0]);
        assert(t.shape_[1] == 1);
        assert(t.shape_[2] == 1);
        assert(shape_[3] == t.shape_[3]);
        // std::cout << "shape_[0]: " << shape_[0] << std::endl;
        // std::cout << "shape_[1]: " << shape_[1] << std::endl;
        // std::cout << "shape_[2]: " << shape_[2] << std::endl;
        // std::cout << "shape_[3]: " << shape_[3] << std::endl;
        int index = 0;
        for (int oc_group = 0; oc_group < shape_[0]; oc_group++) {
          for (int w = 0; w < shape_[1]; w++) {
            for (int h = 0; h < shape_[2]; h++) {
              for (int num = 0; num < shape_[3]; num++) {
                index         = oc_group * (shape_[1]) * (shape_[2]) * (shape_[3]) + w * (shape_[2]) * (shape_[3]) + h * (shape_[3]) + num;
                result[index] = data[index] + t[oc_group * (shape_[3]) + num];
              }
            }
          }
        }
      }
      else if (shape_.size() == 3) {
        assert(shape_[0] == t.shape_[0]);
        assert(t.shape_[1] == 1);
        assert(shape_[2] == t.shape_[2]);
        // std::cout << "shape_[0]: " << shape_[0] << std::endl;
        // std::cout << "shape_[1]: " << shape_[1] << std::endl;
        // std::cout << "shape_[2]: " << shape_[2] << std::endl;
        // std::cout << "shape_[3]: " << shape_[3] << std::endl;
        int index = 0;
        for (int oc_group = 0; oc_group < shape_[0]; oc_group++) {
          for (int m = 0; m < shape_[1]; m++) {
            for (int num = 0; num < shape_[2]; num++) {
              index         = oc_group * (shape_[1]) * (shape_[2]) + m * (shape_[2]) + num;
              result[index] = data[index] + t[oc_group * (shape_[2]) + num];
            }
          }
        }
      }
    }
    else {
      for (int i = 0; i < data.size(); i++) {
        result[i] = data[i] + t[i];
      }
    }
    return result;
  }

  Tensor operator+(const T& t)
  {
    Tensor result(shape_, dtype);
    for (int i = 0; i < data.size(); i++) {
      result[i] = data[i] + t;
    }
    return result;
  }

  Tensor operator-(const Tensor& t)
  {
    Tensor result(shape_, dtype);
    if (shape_ != t.shape_) {
      assert(shape_[0] == t.shape_[0]);
      assert(t.shape_[1] == 1);
      assert(t.shape_[2] == 1);
      assert(shape_[3] == t.shape_[3]);
      // std::cout << "shape_[0]: " << shape_[0] << std::endl;
      // std::cout << "shape_[1]: " << shape_[1] << std::endl;
      // std::cout << "shape_[2]: " << shape_[2] << std::endl;
      // std::cout << "shape_[3]: " << shape_[3] << std::endl;
      int index = 0;
      for (int oc_group = 0; oc_group < shape_[0]; oc_group++) {
        for (int w = 0; w < shape_[1]; w++) {
          for (int h = 0; h < shape_[2]; h++) {
            for (int num = 0; num < shape_[3]; num++) {
              index         = oc_group * (shape_[1]) * (shape_[2]) * (shape_[3]) + w * (shape_[2]) * (shape_[3]) + h * (shape_[3]) + num;
              result[index] = data[index] - t[oc_group * (shape_[3]) + num];
            }
          }
        }
      }
    }
    else {
      for (int i = 0; i < data.size(); i++) {
        result[i] = data[i] - t[i];
      }
    }
    return result;
  }

  Tensor operator-(const T& t)
  {
    Tensor result(shape_, dtype);
    for (int i = 0; i < data.size(); i++) {
      result[i] = data[i] - t;
    }
    return result;
  }

  Tensor operator*(const Tensor& t)
  {
    Tensor result(shape_, dtype);
    if (shape_ != t.shape_) {
      assert(shape_[0] == t.shape_[0]);
      assert(t.shape_[1] == 1);
      assert(t.shape_[2] == 1);
      assert(shape_[3] == t.shape_[3]);
      int index = 0;
      for (int oc_group = 0; oc_group < shape_[0]; oc_group++) {
        for (int w = 0; w < shape_[1]; w++) {
          for (int h = 0; h < shape_[2]; h++) {
            for (int num = 0; num < shape_[3]; num++) {
              index         = oc_group * (shape_[1]) * (shape_[2]) * (shape_[3]) + w * (shape_[2]) * (shape_[3]) + h * (shape_[3]) + num;
              result[index] = data[index] * t[oc_group * (shape_[3]) + num];
            }
          }
        }
      }
    }
    else {
      for (int i = 0; i < data.size(); i++) {
        result[i] = data[i] * t[i];
      }
    }
    return result;
  }

  Tensor operator*(const T& t)
  {
    Tensor result(shape_, dtype);
    for (int i = 0; i < data.size(); i++) {
      result[i] = data[i] * t;
    }
    return result;
  }

  Tensor operator/(const T& t)
  {
    Tensor result(shape_, dtype);
    for (int i = 0; i < data.size(); i++) {
      result[i] = data[i] / t;
    }
    return result;
  }

  Tensor operator/(const Tensor& t)
  {
    Tensor result(shape_, dtype);
    if (shape_ != t.shape_) {
      assert(shape_[0] == t.shape_[0]);
      assert(t.shape_[1] == 1);
      assert(t.shape_[2] == 1);
      assert(shape_[3] == t.shape_[3]);
      int index = 0;
      for (int oc_group = 0; oc_group < shape_[0]; oc_group++) {
        for (int w = 0; w < shape_[1]; w++) {
          for (int h = 0; h < shape_[2]; h++) {
            for (int num = 0; num < shape_[3]; num++) {
              index         = oc_group * (shape_[1]) * (shape_[2]) * (shape_[3]) + w * (shape_[2]) * (shape_[3]) + h * (shape_[3]) + num;
              result[index] = data[index] / t[oc_group * (shape_[3]) + num];
            }
          }
        }
      }
    }
    else {
      for (int i = 0; i < data.size(); i++) {
        result[i] = data[i] / t[i];
      }
    }
    return result;
  }

  Tensor& abs()
  {
    for (int i = 0; i < data.size(); i++) {
      data[i] = std::abs(data[i]);
    }
    return *this;
  }

  void save_hex(std::string filename, size_t bytesPerLine, bool rightLow)
  {
    std::ofstream file;
    file.open(filename);

    size_t dataSize = data.size() * 4;
    char*  data_ptr = reinterpret_cast<char*>(this->data_ptr());

    if (rightLow) {
      std::stringstream ss;
      std::string       result, tmp;

      for (int i = 0; i < dataSize; ++i) {
        if (i % bytesPerLine == 0) {
          result.clear();
        }
        ss.clear();
        ss << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)data_ptr[i] & 0xff);
        ss >> tmp;
        result = tmp + result;
        if (i % bytesPerLine == bytesPerLine - 1) {
          file << result << std::endl;
        }
      }
      file.close();
    }
    else {
      for (int i = 0; i < dataSize; ++i) {
        file << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data[i] & 0xff) << std::endl;
      }
      file.close();
    }
  }

  void print_hex(size_t bytesPerLine, bool rightLow)
  {
    size_t dataBytes;
    if (dtype == kInt8 || dtype == kInt4) {
      dataBytes = 1;
    }
    else if (dtype == kHalf || dtype == kBfloat16 || dtype == kInt16) {
      dataBytes = 2;
    }
    else if (dtype == kInt32 || dtype == kFloat32) {
      dataBytes = 4;
    }
    else {
      dataBytes = 1;
    }
    size_t dataSize = data.size() * dataBytes;
    char*  data_ptr = reinterpret_cast<char*>(this->data_ptr());

    if (rightLow) {
      std::stringstream ss;
      std::string       result, tmp;

      for (int i = 0; i < dataSize; ++i) {
        if (i % bytesPerLine == 0) {
          result.clear();
        }
        ss.clear();
        ss << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)data_ptr[i] & 0xff);
        ss >> tmp;
        result = tmp + result;
        if (i % bytesPerLine == bytesPerLine - 1) {
          std::cout << result << std::endl;
        }
      }
    }
    else {
      for (int i = 0; i < dataSize; ++i) {
        std::cout << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data[i] & 0xff) << std::endl;
      }
    }
  }
};

using namespace common::fp16;
using namespace common::bf16;

template<typename T>
Tensor<T> zeros(std::vector<int> shape_, DType dtype)
{
  Tensor<T> result;
  result.shape_ = shape_;
  result.dtype  = dtype;
  int size      = 1;
  for (auto i : shape_) {
    size *= i;
  }
  for (int i = 0; i < size; ++i) {
    result.data.push_back(0);
  }
  return result;
}

template<typename T>
Tensor<T> ones(std::vector<int> shape_, DType dtype)
{
  Tensor<T> result;
  result.shape_ = shape_;
  result.dtype  = dtype;
  int size      = 1;
  for (auto i : shape_) {
    size *= i;
  }
  for (int i = 0; i < size; ++i) {
    result.data.push_back(1.0);
  }
  return result;
}

template<typename T>
Tensor<T> randn(std::vector<int> shape_, DType dtype, T min, T max, int64_t seed)
{
  try {
    if (typeid(T) == typeid(int32_t) || typeid(T) == typeid(int8_t) || typeid(T) == typeid(int16_t) || typeid(T) == typeid(bool)) {
      std::uniform_real_distribution<float> u(min, max);
      std::default_random_engine            e(seed);
      Tensor<T>                             result;
      result.shape_ = shape_;
      result.dtype  = dtype;
      int size      = 1;
      for (auto i : shape_) {
        size *= i;
      }
      for (int i = 0; i < size; ++i) {
        result.data.push_back(u(e));
      }
      return result;
    }
    else if (dtype == kBfloat16 || dtype == kHalf) {
      std::uniform_real_distribution<float> u((float)min, (float)max);
      std::default_random_engine            e(seed);
      Tensor<T>                             result;
      result.shape_ = shape_;
      result.dtype  = dtype;
      int size      = 1;
      for (auto i : shape_) {
        size *= i;
      }
      for (int i = 0; i < size; ++i) {
        result.data.push_back(u(e));
      }
      return result;
    }
    else if (dtype == kFloat32) {
      std::uniform_real_distribution<float> u(min, max);
      std::default_random_engine            e(seed);
      Tensor<T>                             result;
      result.shape_ = shape_;
      result.dtype  = dtype;
      int size      = 1;
      for (auto i : shape_) {
        size *= i;
      }
      for (int i = 0; i < size; ++i) {
        result.data.push_back(u(e));
      }
      return result;
    }
    else {
      throw std::runtime_error("Unsupported dtype");
    }
  }
  catch (const std::exception& e) {
    std::cerr << e.what() << '\n';
  }

  return Tensor<T>();
}

template Tensor<half> zeros<half>(std::vector<int> shape_, DType dtype);

template Tensor<int32_t> zeros<int32_t>(std::vector<int> shape_, DType dtype);

template Tensor<bfloat16> zeros<bfloat16>(std::vector<int> shape_, DType dtype);

template Tensor<int8_t> zeros<int8_t>(std::vector<int> shape_, DType dtype);

template Tensor<int16_t> zeros<int16_t>(std::vector<int> shape_, DType dtype);

template Tensor<float> zeros<float>(std::vector<int> shape_, DType dtype);

template Tensor<half> ones<half>(std::vector<int> shape_, DType dtype);

template Tensor<int32_t> ones<int32_t>(std::vector<int> shape_, DType dtype);

template Tensor<bfloat16> ones<bfloat16>(std::vector<int> shape_, DType dtype);

template Tensor<int8_t> ones<int8_t>(std::vector<int> shape_, DType dtype);

template Tensor<int16_t> ones<int16_t>(std::vector<int> shape_, DType dtype);

template Tensor<float> ones<float>(std::vector<int> shape_, DType dtype);

template Tensor<half> randn<half>(std::vector<int> shape_, DType dtype, half min, half max, int64_t seed);

template Tensor<int32_t> randn<int32_t>(std::vector<int> shape_, DType dtype, int32_t min, int32_t max, int64_t seed);

template Tensor<bfloat16> randn<bfloat16>(std::vector<int> shape_, DType dtype, bfloat16 min, bfloat16 max, int64_t seed);

template Tensor<int8_t> randn<int8_t>(std::vector<int> shape_, DType dtype, int8_t min, int8_t max, int64_t seed);

template Tensor<int16_t> randn<int16_t>(std::vector<int> shape_, DType dtype, int16_t min, int16_t max, int64_t seed);

template Tensor<float> randn<float>(std::vector<int> shape_, DType dtype, float min, float max, int64_t seed);

template Tensor<bool> randn<bool>(std::vector<int> shape_, DType dtype, bool min, bool max, int64_t seed);

Tensor<int8_t> ToInt8(Tensor<float> data)
{
  Tensor<int8_t> result(data.shape_, kInt8);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = static_cast<int8_t>(data[i]);
  }
  return result;
}

Tensor<int8_t> ToInt4(Tensor<float> data)
{
  Tensor<int8_t> result(data.shape_, kInt4);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = static_cast<int8_t>(data[i]) & 0x0f;
  }
  return result;
}

Tensor<int16_t> ToInt16(Tensor<float> data)
{
  Tensor<int16_t> result(data.shape_, kInt16);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = static_cast<int16_t>(data[i]);
  }
  return result;
}

Tensor<compute_model::common::fp16::half> ToFloat16(Tensor<float> data)
{
  Tensor<compute_model::common::fp16::half> result(data.shape_, kHalf);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = (compute_model::common::fp16::half)(data[i]);
  }
  return result;
}

Tensor<compute_model::common::bf16::bfloat16> ToBfloat16(Tensor<float> data)
{
  Tensor<compute_model::common::bf16::bfloat16> result(data.shape_, kBfloat16);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = (compute_model::common::bf16::bfloat16)(data[i]);
  }
  return result;
}

using namespace compute_model::common::subbyte;
Tensor<float> ToFloat32(Tensor<int4_t> data)
{
  Tensor<float> result(data.shape_, kFloat32);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = static_cast<float>(data[i]);
  }
  return result;
}

Tensor<float> ToFloat32(Tensor<int8_t> data)
{
  Tensor<float> result(data.shape_, kFloat32);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = static_cast<float>(data[i]);
  }
  return result;
}

Tensor<float> ToFloat32(Tensor<int16_t> data)
{
  Tensor<float> result(data.shape_, kFloat32);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = static_cast<float>(data[i]);
  }
  return result;
}

Tensor<float> ToFloat32(Tensor<compute_model::common::fp16::half> data)
{
  Tensor<float> result(data.shape_, kFloat32);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = compute_model::common::fp16::BitsToFloat(compute_model::common::fp16::ToFloatBits(data[i].storage));
  }
  return result;
}

Tensor<float> ToFloat32(Tensor<compute_model::common::bf16::bfloat16> data)
{
  Tensor<float> result(data.shape_, kFloat32);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = compute_model::common::bf16::BitsToFloat(compute_model::common::bf16::ToFloatBits(data[i].storage));
  }
  return result;
}

Tensor<float> ToFloat32(Tensor<int32_t> data)
{
  Tensor<float> result(data.shape_, kFloat32);
  for (int i = 0; i < data.numel(); ++i) {
    result[i] = static_cast<float>(data[i]);
  }
  return result;
}

template<typename T>
Tensor<T> ParallelismConvertion32to64(Tensor<T>& in)
{
  if (in.shape_.size() == 4) {
    int oc_group      = in.shape(0);
    int h             = in.shape(1);
    int w             = in.shape(2);
    int oc_group_size = in.shape(3);

    auto out = zeros<T>({oc_group / 2, h, w, oc_group_size * 2}, in.dtype);

    int num_data = h * w;

    for (int i = 0; i < oc_group; ++i) {
      for (int j = 0; j < num_data; ++j) {
        for (int k = 0; k < oc_group_size; ++k) {
          int ori_idx   = i * num_data * oc_group_size + j * oc_group_size + k;
          int dst_data  = (i / 2) * num_data * (oc_group_size * 2) + j * (oc_group_size * 2) + k + i % 2 * (oc_group_size);
          out[dst_data] = in[ori_idx];
        }
      }
    }
    return out;
  }
  else if (in.shape_.size() == 3) {
    int oc_group      = in.shape(0);
    int num_data      = in.shape(1);
    int oc_group_size = in.shape(2);

    auto out = zeros<T>({oc_group / 2, num_data, oc_group_size * 2}, in.dtype);

    for (int i = 0; i < oc_group; ++i) {
      for (int j = 0; j < num_data; ++j) {
        for (int k = 0; k < oc_group_size; ++k) {
          int ori_idx   = i * num_data * oc_group_size + j * oc_group_size + k;
          int dst_data  = (i / 2) * num_data * (oc_group_size * 2) + j * (oc_group_size * 2) + k + i % 2 * (oc_group_size);
          out[dst_data] = in[ori_idx];
        }
      }
    }
    return out;
  }
  return Tensor<T>();
}

template<typename T>
Tensor<T> ParallelismConvertion32to16(Tensor<T>& in)
{
  if (in.shape_.size() == 4) {
    int oc_group      = in.shape(0);
    int h             = in.shape(1);
    int w             = in.shape(2);
    int oc_group_size = in.shape(3);

    auto out = zeros<T>({oc_group * 2, h, w, oc_group_size / 2}, in.dtype);

    int num_data = h * w;

    for (int i = 0; i < oc_group; ++i) {
      for (int j = 0; j < num_data; ++j) {
        for (int k = 0; k < oc_group_size; ++k) {
          int ori_idx = i * num_data * oc_group_size + j * oc_group_size + k;
          int dst_idx;
          if (k < (oc_group_size / 2)) {
            dst_idx = 2 * i * num_data * (oc_group_size / 2) + j * (oc_group_size / 2) + k;
          }
          else {
            dst_idx = (2 * i + 1) * num_data * (oc_group_size / 2) + j * (oc_group_size / 2) + k - (oc_group_size / 2);
          }
          out[dst_idx] = in[ori_idx];
        }
      }
    }
    return out;
  }
  else if (in.shape_.size() == 3) {
    int oc_group      = in.shape(0);
    int num_data      = in.shape(1);
    int oc_group_size = in.shape(2);

    auto out = zeros<T>({oc_group * 2, num_data, oc_group_size / 2}, in.dtype);

    for (int i = 0; i < oc_group; ++i) {
      for (int j = 0; j < num_data; ++j) {
        for (int k = 0; k < oc_group_size; ++k) {
          int ori_idx = i * num_data * oc_group_size + j * oc_group_size + k;
          int dst_idx;
          if (k < (oc_group_size / 2)) {
            dst_idx = 2 * i * num_data * (oc_group_size / 2) + j * (oc_group_size / 2) + k;
          }
          else {
            dst_idx = (2 * i + 1) * num_data * (oc_group_size / 2) + j * (oc_group_size / 2) + k - (oc_group_size / 2);
          }
          out[dst_idx] = in[ori_idx];
        }
      }
    }
    return out;
  }
  return Tensor<T>();
}

}  // namespace tensor
}  // namespace compute_model