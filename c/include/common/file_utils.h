#pragma once

#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>

namespace common {
namespace file_utils {

int saveCharArrayToBinFile(const char* filename, const char* data, size_t dataSize)
{
  FILE* file = fopen(filename, "wb");
  if (file == NULL) {
    perror("Error opening file");
    return 1;
  }

  size_t written = fwrite(data, sizeof(char), dataSize, file);
  if (written != dataSize) {
    perror("Error writing to file");
    fclose(file);
    return 1;
  }

  fclose(file);
  return 0;
}

int saveCharArrayToTextFile(const char* filename, const char* data, size_t dataSize)
{
  FILE* file = fopen(filename, "w");
  if (file == NULL) {
    perror("Error opening file");
    return 1;
  }

  for (size_t i = 0; i < dataSize; i++) {
    if (fprintf(file, "%02x\n", (unsigned char)data[i]) < 0) {
      perror("Error writing to file");
      fclose(file);
      return 1;
    }
  }

  fclose(file);
  return 0;
}

int saveCharArrayToFormattedTextFile(
  const char* filename, const char* data, size_t dataSize, size_t bytesPerLine, bool rightLow, bool int4 = false)
{
  std::ofstream file;
  file.open(filename);

  if (rightLow) {
    std::stringstream ss;
    std::string       result, tmp;

    for (int i = 0; i < dataSize; ++i) {
      if (i % bytesPerLine == 0) {
        result.clear();
      }
      ss.clear();
      if (int4) {
        ss << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data[i] & 0xf);
      }
      else {
        ss << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)data[i] & 0xff);
      }
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
      if (int4) {
        file << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data[i] & 0xf) << std::endl;
      }
      else {
        file << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data[i] & 0xff) << std::endl;
      }
    }
  }
  return 0;
}

int saveCharArrayToFormattedTextFileSplitTwoDDR(std::ofstream&     ofs0,
                                                std::ofstream&     ofs1,
                                                void*              data,
                                                size_t             dataSize,
                                                size_t             bytesPerLine,
                                                bool               rightLow,
                                                std::ios::openmode mode = std::ios::out,
                                                bool               int4 = false)
{
  const char* data_char = reinterpret_cast<const char*>(data);

  if (rightLow) {
    std::stringstream ss0;
    std::stringstream ss1;
    std::string       result0, tmp0;
    std::string       result1, tmp1;

    for (int i = 0; i < dataSize; ++i) {
      if (i % bytesPerLine == 0) {
        result0.clear();
        result1.clear();
      }
      if (i % bytesPerLine < bytesPerLine / 2) {
        ss0.clear();
        if (int4) {
          ss0 << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data_char[i] & 0xf);
        }
        else {
          ss0 << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)data_char[i] & 0xff);
        }
        ss0 >> tmp0;
        result0 = tmp0 + result0;
      }
      else {
        ss1.clear();
        if (int4) {
          ss1 << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data_char[i] & 0xf);
        }
        else {
          ss1 << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)data_char[i] & 0xff);
        }
        ss1 >> tmp1;
        result1 = tmp1 + result1;
      }
      if (i % bytesPerLine == bytesPerLine - 1) {
        ofs0 << result0 << std::endl;
        ofs1 << result1 << std::endl;
      }
    }
  }
  else {
    for (int i = 0; i < dataSize; ++i) {
      if (i % bytesPerLine < bytesPerLine / 2) {
        if (int4) {
          ofs0 << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data_char[i] & 0xf) << std::endl;
        }
        else {
          ofs0 << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)data_char[i] & 0xff) << std::endl;
        }
      }
      else {
        if (int4) {
          ofs1 << std::setfill('0') << std::setw(1) << std::hex << ((int32_t)data_char[i] & 0xf) << std::endl;
        }
        else {
          ofs1 << std::setfill('0') << std::setw(2) << std::hex << ((int32_t)data_char[i] & 0xff) << std::endl;
        }
      }
    }
    return 0;
  }
  return 0;
}

int saveBoolArrayToFormattedTextFileSplitTwoDDR(std::ofstream&     ofs0,
                                                std::ofstream&     ofs1,
                                                void*              data,
                                                size_t             dataSize,
                                                size_t             bytesPerLine,
                                                bool               rightLow,
                                                std::ios::openmode mode = std::ios::out)
{
  const char* data_char = reinterpret_cast<const char*>(data);

  if (rightLow) {
    std::stringstream ss0;
    std::stringstream ss1;
    std::string       result0, tmp0;
    std::string       result1, tmp1;

    for (int i = 0; i < dataSize; ++i) {
      if (i % bytesPerLine == 0) {
        result0.clear();
        result1.clear();
      }
      if (i % bytesPerLine < bytesPerLine / 2) {
        ss0.clear();
        ss0 << (data_char[i] ? "1" : "0");
        ss0 >> tmp0;
        result0 = tmp0 + result0;
      }
      else {
        ss1.clear();
        ss1 << (data_char[i] ? "1" : "0");
        ss1 >> tmp1;
        result1 = tmp1 + result1;
      }
      if (i % bytesPerLine == bytesPerLine - 1) {
        ofs0 << result0 << std::endl;
        ofs1 << result1 << std::endl;
      }
    }
  }
  else {
    for (int i = 0; i < dataSize; ++i) {
      if (i % bytesPerLine < bytesPerLine / 2) {
        ofs0 << (data_char[i] ? 1 : 0) << std::endl;
      }
      else {
        ofs1 << (data_char[i] ? 1 : 0) << std::endl;
      }
    }
    return 0;
  }
  return 0;
}
}  // namespace file_utils
}  // namespace common