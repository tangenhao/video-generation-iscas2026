#pragma once

#include <iostream>
#include <string>

namespace common {

inline void assert_with_message(bool condition, std::string message)
{
  try {
    assert(condition);
  }
  catch (...) {
    std::cerr << __FILE__ << ":" << __LINE__ << " " << message << std::endl;
    throw;
  }
}

inline bool print_if_false(const bool assertion, std::string message)
{
  if (!assertion) {
    std::cout << message << std::endl;
  }
  return assertion;
}

}  // namespace common