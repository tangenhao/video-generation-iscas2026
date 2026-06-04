#include "func.h" 
#include "fast_activation.h"

extern "C" {

uint32_t tanh_less_precision_approx_c(float x, bool debug)
{
  return compute_model::function::tanh_less_precision_approx(x, debug);
}

uint32_t sigmoid_less_precision_approx_c(float x, bool debug)
{
  return compute_model::function::sigmoid_less_precision_approx(x, debug);
}

uint32_t mish_less_precision_approx_c(float x)
{
  return compute_model::function::mish_less_precision_approx(x);
}

uint32_t swish_less_precision_approx_c(float x)
{
  return compute_model::function::swish_less_precision_approx(x);
}

uint32_t gelu_less_precision_approx_c(float x)
{
  return compute_model::function::gelu_less_precision_approx(x);
}

uint32_t sin16divpi_c(float x)
{
  return compute_model::function::sin16divpi(x);
}

uint32_t cos16divpi_c(float x)
{
  return compute_model::function::cos16divpi(x);
}

uint32_t log2_c(float y)
{
  return compute_model::function::log2(y);
}

uint32_t exp2_c(float y, bool debug)
{
  return compute_model::function::exp2(y, debug);
}

uint32_t reciprocal_c(float y)
{
  return compute_model::function::reciprocal(y);
}

uint32_t rsqrt_c(float y)
{
  return compute_model::function::rsqrt(y);
}

uint32_t tanh_c(float y)
{
  return compute_model::function::tanh(y);
}

}