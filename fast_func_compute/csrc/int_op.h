#pragma once
#include <bitset>
#include <stdint.h>
#include <utility>

namespace compute_model {
namespace function {

static void addWithCarry(uint64_t a, uint64_t b, uint64_t& result, uint64_t& carry_output, int64_t carry_in = 0)
{
  result       = a + b + carry_in;
  carry_output = (result < a) ? 1 : ((result < b) ? 1 : 0);  // If overflow occurs, carry is 1
}

static std::pair<uint64_t, int> findFirst32BitsAndIndex(uint64_t high64, uint64_t low64)
{
  std::bitset<64> highBits(high64);  // ������������������������������������1��������������������32������
  std::bitset<64> lowBits(low64);

  for (int i = 63; i >= 0; --i) {
    if (highBits[i]) {
      std::bitset<32> result;
      int             bitIndex = 31;
      for (int j = i; j >= 0 && bitIndex >= 0; --j, --bitIndex) {
        result[bitIndex] = highBits[j];
      }
      for (int j = 63; bitIndex >= 0; --j, --bitIndex) {
        result[bitIndex] = lowBits[j];
      }
      return {result.to_ulong(), 63 - i};
    }
  }

  for (int i = 63; i >= 0; --i) {
    if (lowBits[i]) {
      std::bitset<32> result;
      int             bitIndex = 31;
      for (int j = i; bitIndex >= 0; --j, --bitIndex) {
        result[bitIndex] = lowBits[j];
      }
      return {result.to_ulong(), 63 - i + 64};
    }
  }

  return {0, -1};  // No '1' bit found
}

static std::pair<uint64_t, int> findFirst24BitsAndIndex(uint64_t res64)
{
  std::bitset<64> resBits(res64);  // ��������������1��������������������24��������������������������������
  std::bitset<24> result;
  for (int i = 63; i >= 0; --i) {
    if (resBits[i]) {

      int bitIndex = 23;
      for (int j = i; bitIndex >= 0; --j, --bitIndex) {
        result[bitIndex] = resBits[j];
      }
      return {result.to_ulong(), 63 - i};
    }
  }

  return {0, -1};  // No '1' bit found
}
}  // namespace function
}  // namespace compute_model