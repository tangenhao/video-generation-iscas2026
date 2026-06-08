#pragma once

#include <cstdint>

namespace compute_model {
namespace common {
namespace subbyte {

typedef struct int4_t {
  int8_t storage;

  int4_t(): storage(0) {}

  int4_t(int8_t s): storage(s) {}

  int4_t(int16_t s): storage(s) {}

  int4_t(int32_t s): storage(s) {}

  int4_t(int64_t s): storage(s) {}

  int4_t(float s): storage(s) {}

  operator int8_t() const
  {
    return storage;
  }

  operator int16_t() const
  {
    return storage;
  }

  operator int32_t() const
  {
    return storage;
  }

  operator int64_t() const
  {
    return storage;
  }

  operator float() const
  {
    return storage;
  }
} int4_t;

}  // namespace subbyte
}  // namespace common
}  // namespace compute_model