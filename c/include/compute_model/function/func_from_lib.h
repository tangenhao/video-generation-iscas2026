#pragma once

#include <dlfcn.h>
#include <iostream>

namespace compute_model {
namespace function {

void* get_handle(const char* lib_name)
{
  void* handle = dlopen(lib_name, RTLD_LAZY);
  if (!handle) {
    const char* alternative_paths[] = {
      "../lib/libfunc.so",  // 原始相对路径（向后兼容）
      "./lib/libfunc.so",  // 当前目录
      "./libfunc.so",  
      NULL
    };
    
    for (int i = 0; alternative_paths[i] != NULL && !handle; i++) {
      handle = dlopen(alternative_paths[i], RTLD_LAZY);
    }
    
    if (!handle) {
      printf("Open %s failed: %s\n", lib_name, dlerror());
      printf("Tried paths:\n");
      printf("  - %s (via LD_LIBRARY_PATH)\n", lib_name);
      for (int i = 0; alternative_paths[i] != NULL; i++) {
        printf("  - %s\n", alternative_paths[i]);
      }
      printf("Please ensure libfunc.so is in your LD_LIBRARY_PATH or one of the above paths.\n");
      exit(-1);
      return nullptr;
    }
  }
  return handle;
}

// 考虑后续部署需要，不采用相对路径
// dlopen 会优先到LD_LIBRARY_PATH查找，然后才是上述给出的路径
void* handle = get_handle("libfunc.so");

typedef uint32_t (*tanh_less_precision_approx_c_t)(float x, bool debug);
typedef uint32_t (*sigmoid_less_precision_approx_c_t)(float x, bool debug);
typedef uint32_t (*mish_less_precision_approx_c_t)(float x);
typedef uint32_t (*swish_less_precision_approx_c_t)(float x);
typedef uint32_t (*gelu_less_precision_approx_c_t)(float x);
typedef float (*sin16divpi_c_t)(float x);
typedef float (*cos16divpi_c_t)(float x);
typedef float (*log2_c_t)(float y);
typedef float (*exp2_c_t)(float y, bool debug);
typedef float (*reciprocal_c_t)(float y);
typedef float (*rsqrt_c_t)(float y);
typedef float (*tanh_c_t)(float y);

tanh_less_precision_approx_c_t get_tanh_less_precision_approx_c()
{
  tanh_less_precision_approx_c_t tanh_less_precision_approx_c =
    (tanh_less_precision_approx_c_t)dlsym(handle, "tanh_less_precision_approx_c");
  if (!tanh_less_precision_approx_c) {
    printf("Get tanh_less_precision_approx_c failed\n");
    exit(-1);
  }
  return tanh_less_precision_approx_c;
}

tanh_less_precision_approx_c_t tanh_less_precision_approx_c = get_tanh_less_precision_approx_c();

sigmoid_less_precision_approx_c_t get_sigmoid_less_precision_approx_c()
{
  sigmoid_less_precision_approx_c_t sigmoid_less_precision_approx_c =
    (sigmoid_less_precision_approx_c_t)dlsym(handle, "sigmoid_less_precision_approx_c");
  if (!sigmoid_less_precision_approx_c) {
    printf("Get sigmoid_less_precision_approx_c failed\n");
    exit(-1);
  }
  return sigmoid_less_precision_approx_c;
}

sigmoid_less_precision_approx_c_t sigmoid_less_precision_approx_c = get_sigmoid_less_precision_approx_c();

mish_less_precision_approx_c_t get_mish_less_precision_approx_c()
{
  mish_less_precision_approx_c_t mish_less_precision_approx_c =
    (mish_less_precision_approx_c_t)dlsym(handle, "mish_less_precision_approx_c");
  if (!mish_less_precision_approx_c) {
    printf("Get mish_less_precision_approx_c failed\n");
    exit(-1);
  }
  return mish_less_precision_approx_c;
}

mish_less_precision_approx_c_t mish_less_precision_approx_c = get_mish_less_precision_approx_c();

swish_less_precision_approx_c_t get_swish_less_precision_approx_c()
{
  swish_less_precision_approx_c_t swish_less_precision_approx_c =
    (swish_less_precision_approx_c_t)dlsym(handle, "swish_less_precision_approx_c");
  if (!swish_less_precision_approx_c) {
    printf("Get swish_less_precision_approx_c failed\n");
    exit(-1);
  }
  return swish_less_precision_approx_c;
}

swish_less_precision_approx_c_t swish_less_precision_approx_c = get_swish_less_precision_approx_c();

gelu_less_precision_approx_c_t get_gelu_less_precision_approx_c()
{
  gelu_less_precision_approx_c_t gelu_less_precision_approx_c =
    (gelu_less_precision_approx_c_t)dlsym(handle, "gelu_less_precision_approx_c");
  if (!gelu_less_precision_approx_c) {
    printf("Get gelu_less_precision_approx_c failed\n");
    exit(-1);
  }
  return gelu_less_precision_approx_c;
}

gelu_less_precision_approx_c_t gelu_less_precision_approx_c = get_gelu_less_precision_approx_c();

sin16divpi_c_t get_sin16divpi_c()
{
  sin16divpi_c_t sin16divpi_c = (sin16divpi_c_t)dlsym(handle, "sin16divpi_c");
  if (!sin16divpi_c) {
    printf("Get sin16divpi_c failed\n");
    exit(-1);
  }
  return sin16divpi_c;
}

sin16divpi_c_t sin16divpi_c = get_sin16divpi_c();

cos16divpi_c_t get_cos16divpi_c()
{
  cos16divpi_c_t cos16divpi_c = (cos16divpi_c_t)dlsym(handle, "cos16divpi_c");
  if (!cos16divpi_c) {
    printf("Get cos16divpi_c failed\n");
    exit(-1);
  }
  return cos16divpi_c;
}

cos16divpi_c_t cos16divpi_c = get_cos16divpi_c();

log2_c_t get_log2_c()
{
  log2_c_t log2_c = (log2_c_t)dlsym(handle, "log2_c");
  if (!log2_c) {
    printf("Get log2_c failed\n");
    exit(-1);
  }
  return log2_c;
}

log2_c_t log2_c = get_log2_c();

exp2_c_t get_exp2_c()
{
  exp2_c_t exp2_c = (exp2_c_t)dlsym(handle, "exp2_c");
  if (!exp2_c) {
    printf("Get exp2_c failed\n");
    exit(-1);
  }
  return exp2_c;
}

exp2_c_t exp2_c = get_exp2_c();

reciprocal_c_t get_reciprocal_c()
{
  reciprocal_c_t reciprocal_c = (reciprocal_c_t)dlsym(handle, "reciprocal_c");
  if (!reciprocal_c) {
    printf("Get reciprocal_c failed\n");
    exit(-1);
  }
  return reciprocal_c;
}

reciprocal_c_t reciprocal_c = get_reciprocal_c();

rsqrt_c_t get_rsqrt_c()
{
  rsqrt_c_t rsqrt_c = (rsqrt_c_t)dlsym(handle, "rsqrt_c");
  if (!rsqrt_c) {
    printf("Get rsqrt_c failed\n");
    exit(-1);
  }
  return rsqrt_c;
}

rsqrt_c_t rsqrt_c = get_rsqrt_c();

tanh_c_t get_tanh_c()
{
  tanh_c_t tanh_c = (tanh_c_t)dlsym(handle, "tanh_c");
  if (!tanh_c) {
    printf("Get tanh_c failed\n");
    exit(-1);
  }
  return tanh_c;
}

tanh_c_t tanh_c = get_tanh_c();

}  // namespace function
}  // namespace compute_model
