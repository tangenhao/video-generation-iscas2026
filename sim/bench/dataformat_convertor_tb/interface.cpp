#include "func.h"
#include <svdpi.h>

using namespace compute_model::function;

extern "C" {

  void log2_c(
    svBitVecVal* input,
    svBitVecVal* output,
  ) {
    for (int i = 0; i < 32; i++) {
      float in = *(float*)(input + i * 32);
      float out = compute_model::function::log2(in);
      *(float*)(output + i * 32) = out;
    }
  }
}