#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h"
#include "compute_model/conv/conv2d.h"
#include "compute_model/gemm/gemm.h"
#include "compute_model/transformer/rmsnorm.h"
#include "compute_model/transformer/llama_mlp.h"
#include "compute_model/transformer/mha.h"
#include "compute_model/transformer/softmax.h"
#include "compute_model/transformer/llama_block.h"
#include "pea/pea_insn.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_operation.h"
#include "transformer/rmsnorm.h"
#include "transformer/llama_mlp.h"
#include "transformer/llama_attention.h"
#include "transformer/softmax.h"
#include "transformer/llama_block.h"
#include "common/file_utils.h"
#include "compute_model/common/fp16.h"
#include "addr.h"
#include "addr_for_llama.h"

// cmake parameter
#ifdef DEBUG_MODE
  #define _DEBUG true
#else
  #define _DEBUG false  
#endif

// namespace
using namespace common::insn;

std::pair<int, int> split_exp_fra(int64_t x)
{
  if (x > 835584000) {
    std::throw_with_nested(std::runtime_error("x is too large"));
  }
  int max_exp = (1 << 4) - 1;
  int max_fra = (1 << 8) - 1;
  int exp     = 0;
  while (x > max_fra) {
    x /= 2;
    exp++;
  }
  return {exp, x};
}

extern "C" {

void gen_random_data(void* data, int size, int32_t dtype, int seed, int min, int max)
{
  if (dtype == kHalf) { 
    using half = compute_model::common::fp16::half;
    auto data_vec = compute_model::tensor::randn<half>({size}, (DType)dtype, min, max, seed);
    for (int i = 0; i < size; i++) {
      ((half*)data)[i] = data_vec[i];
    }
  }
  else if (dtype == kFloat32) {
    auto data_vec = compute_model::tensor::randn<float>({size}, (DType)dtype, min, max, seed);
    for (int i = 0; i < size; i++) {
      ((float*)data)[i] = data_vec[i];
    }
  }
  else if (dtype == kInt8) {
    auto data_vec = compute_model::tensor::randn<int8_t>({size}, (DType)dtype, min, max, seed);
    for (int i = 0; i < size; i++) {
      ((int8_t*)data)[i] = data_vec[i];
    }
  }
}

void float_to_half(void* output,
                   void* input,
                   int size)
{
  using namespace compute_model::tensor;
  using namespace compute_model::common::fp16;
  auto input_vec = zeros<float>({size}, kFloat32);

  for (int i = 0; i < size; i++) {
    input_vec[i] = ((float*)input)[i];
  }

  auto output_vec = ToFloat16(input_vec);

  for (int i = 0; i < size; i++) {
    ((half*)output)[i] = output_vec[i];
  }

}

void half_to_float(void* output,
                   void* input,
                   int size)
{
  using namespace compute_model::tensor;
  using namespace compute_model::common::fp16;
  auto input_vec = zeros<half>({size}, kHalf);

  for (int i = 0; i < size; i++) {
    input_vec[i] = ((half*)input)[i];
  }

  auto output_vec = ToFloat32(input_vec);

  for (int i = 0; i < size; i++) {
    ((float*)output)[i] = output_vec[i];
  }
}

void Add_Elementwise_Sim(void* output,
                     void* input1,
                     void* input2,
                     int size,
                     int32_t dtype)
{
  using namespace compute_model::tensor;
  using namespace compute_model::function;

  auto output_vec = zeros<float>({size}, kFloat32);
  auto input1_vec = zeros<float>({size}, kFloat32);
  auto input2_vec = zeros<float>({size}, kFloat32);

  assert((DType)dtype == kFloat32);

  for (int i = 0; i < size; i++) {
    output_vec[i] = ((float*)output)[i];
    input1_vec[i] = ((float*)input1)[i];
    input2_vec[i] = ((float*)input2)[i];
  }

  output_vec = add_elementwise(input1_vec, input2_vec);
  for (int i = 0; i < size; i++) {
    ((float*)output)[i] = output_vec[i];
  }  
}

void Mul_Elementwise_Sim(void* output,
                         void* input1,
                         void* input2,
                         int size,
                         int32_t dtype)
{
  using namespace compute_model::tensor;
  using namespace compute_model::function;
  auto output_vec = zeros<float>({size}, kFloat32);
  auto input1_vec = zeros<float>({size}, kFloat32);
  auto input2_vec = zeros<float>({size}, kFloat32);

  assert((DType)dtype == kFloat32);

  for (int i = 0; i < size; i++) {
    output_vec[i] = ((float*)output)[i];
    input1_vec[i] = ((float*)input1)[i];
    input2_vec[i] = ((float*)input2)[i];
  }

  output_vec = mul_elementwise(input1_vec, input2_vec);
  for (int i = 0; i < size; i++) {
    ((float*)output)[i] = output_vec[i];
  }
}

void Conv2dSim(void*  ofmap,
              void*  ifmap,
              void*  weight,
              int32_t dtype,
              int    h,
              int    w,
              int    kh,
              int    kw,
              int     pad_h,
              int     pad_w,
              int     stride_h,
              int     stride_w,
              int     ic_group,
              int     oc_group,
              int     dilation_h,
              int     dilation_w,
              int     ifmap_block_h,
              int     ifmap_block_w)
{
  if ((DType)dtype == kHalf) {
    using half = compute_model::common::fp16::half;
    using conv2d_sim_t = compute_model::conv2d::Conv2dSim<0, false, false, false, half, half, float, half, false>;
    auto ofmap_vec = compute_model::tensor::zeros<half>({oc_group, h, w, 16}, kHalf);
    auto ifmap_vec = compute_model::tensor::zeros<half>({ic_group, h, w, 32}, kHalf);
    auto weight_vec = compute_model::tensor::zeros<half>({oc_group, ic_group, kh, kw, 32, 32}, kHalf);
    for (int i = 0; i < ic_group * h * w * 32; i++) {
      ifmap_vec[i] = ((half*)ifmap)[i];
    }

    for (int i = 0; i < oc_group * ic_group * kh * kw * 32 * 32; i++) {
      weight_vec[i] = ((half*)weight)[i];
    }

    typename conv2d_sim_t::Arguments args = {
      ofmap_vec, ifmap_vec, weight_vec, stride_h, stride_w, pad_h, pad_w, dilation_h, dilation_w, ifmap_block_h, ifmap_block_w, kh, kw, 1, 1};

    conv2d_sim_t conv2d_sim_op;
    conv2d_sim_op(args);

    for (int i = 0; i < oc_group * h * w * 32; i++) {
      ((half*)ofmap)[i] = ofmap_vec[i];
    }

  }
  else if ((DType)dtype == kInt8) {
    using conv2d_sim_t = compute_model::conv2d::Conv2dSim<0, false, false, false, int8_t, int8_t, int32_t, int8_t, false>;
    auto ofmap_vec = compute_model::tensor::zeros<int8_t>({oc_group, h, w, 16}, kInt8);
    auto ifmap_vec = compute_model::tensor::zeros<int8_t>({ic_group, h, w, 32}, kInt8);
    auto weight_vec = compute_model::tensor::zeros<int8_t>({oc_group, ic_group, kh, kw, 32, 32}, kInt8);
    for (int i = 0; i < ic_group * h * w * 32; i++) {
      ifmap_vec[i] = ((int8_t*)ifmap)[i];
    }

    for (int i = 0; i < oc_group * ic_group * kh * kw * 32 * 32; i++) {
      weight_vec[i] = ((int8_t*)weight)[i];
    }

    typename conv2d_sim_t::Arguments args = {
      ofmap_vec, ifmap_vec, weight_vec, stride_h, stride_w, pad_h, pad_w, dilation_h, dilation_w, ifmap_block_h, ifmap_block_w, kh, kw, 1, 1};

    conv2d_sim_t conv2d_sim_op;
    conv2d_sim_op(args);

    for (int i = 0; i < oc_group * h * w * 32; i++) {
      ((int8_t*)ofmap)[i] = ofmap_vec[i];
    }
  }
}

void GemmSim(
    void* output,     // [n_group, m, n_group_size] 
    void* ifmap,      // [k_group, m, k_group_size]
    void* weight,     // [n_group, k_group, n_group_size, k_group_size]
    int m,
    int n, 
    int k,
    int tile_m,
    int block_n_group,
    int block_k_group)
{
  using namespace compute_model::tensor;
  using namespace compute_model::common::fp16;
  using namespace compute_model::gemm;

  int n_group_size = 32;
  int k_group_size = 16;
  int n_group = n / n_group_size;
  int k_group = k / k_group_size;

  auto ifmap_tensor = zeros<half>({k_group, m, k_group_size}, kHalf);
  auto weight_tensor = zeros<half>({n_group, k_group, n_group_size, k_group_size}, kHalf);
  auto output_tensor = zeros<float>({n_group, m, n_group_size}, kFloat32);

  // Copy input data
  memcpy(ifmap_tensor.data_ptr(), ifmap, ifmap_tensor.numel() * sizeof(half));
  memcpy(weight_tensor.data_ptr(), weight, weight_tensor.numel() * sizeof(half));

  using gemm_sim_t = compute_model::gemm::GemmSim<0, 0, false, false, half, half, float, float, false>;
  typename gemm_sim_t::Arguments args = {
    output_tensor, ifmap_tensor, weight_tensor, tile_m, block_n_group, block_k_group
  };

  gemm_sim_t gemm_sim_op;
  gemm_sim_op(args);

  // Copy output data
  memcpy(output, output_tensor.data_ptr(), output_tensor.numel() * sizeof(float));
}

void RMSNormSim(void* output,
                void* input,
                void* gamma,
                int seq_len,
                int d_model,
                float epsilon = 1e-6f,
                int32_t dtype = kFloat32)
{
  int oc_group_size = 32;
  int oc_group = d_model / oc_group_size;

  using namespace compute_model::tensor;
  using namespace compute_model::transformer::rmsnorm;
  
  assert((DType)dtype == kFloat32); 

  auto input_vec = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);
  auto gamma_vec = zeros<float>({oc_group, oc_group_size}, kFloat32);
  auto output_vec = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);

  for (int i = 0; i < oc_group * seq_len * oc_group_size; i++) {
    input_vec[i] = ((float*)input)[i];
  }

  for (int i = 0; i < oc_group * oc_group_size; i++) {
    gamma_vec[i] = ((float*)gamma)[i];
  }
  
  apply_rmsnorm<float, false>(input_vec, output_vec, gamma_vec, epsilon);

  for (int i = 0; i < oc_group * seq_len * oc_group_size; i++) {
    ((float*)output)[i] = output_vec[i];
  }
}

void SoftmaxSim(
    void* output,     // [oc_group, seq_len, oc_group_size]
    void* input,      // [oc_group, seq_len, oc_group_size]
    int oc_group,
    int seq_len,
    int oc_group_size = 32)
{
  using namespace compute_model::tensor;
  using namespace compute_model::transformer::softmax;

  auto input_tensor = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);
  auto output_tensor = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);

  // Copy input data
  memcpy(input_tensor.data_ptr(), input, input_tensor.numel() * sizeof(float));

  apply_softmax<float, false>(input_tensor, output_tensor);

  // Copy output data
  memcpy(output, output_tensor.data_ptr(), output_tensor.numel() * sizeof(float));
}

void LlamaMlpSim(void* output,
                void* input,
                void* gate_weight,
                void* up_weight,
                void* down_weight,
                int seq_len,
                int hidden_size,
                int intermediate_size)
{
  using namespace compute_model::tensor;
  using namespace compute_model::transformer::llama_mlp;

  int n_group_size = 32;
  int k_group_size = 16;
  int d_model = hidden_size;
  int d_ff = intermediate_size;

  int n_group = d_model / n_group_size;
  int n_group_ff = d_ff / n_group_size;
  int k_group = d_model / k_group_size;
  int k_group_ff = d_ff / k_group_size;

  auto input_vec = zeros<half>({k_group, seq_len, k_group_size}, kHalf);
  auto gate_weight_vec = zeros<half>({n_group_ff, k_group, n_group_size, k_group_size}, kHalf);
  auto up_weight_vec = zeros<half>({n_group_ff, k_group, n_group_size, k_group_size}, kHalf);
  auto down_weight_vec = zeros<half>({n_group, k_group_ff, n_group_size, k_group_size}, kHalf);
  auto output_vec = zeros<float>({n_group, seq_len, n_group_size}, kFloat32);

  for (int i = 0; i < k_group * seq_len * k_group_size; i++) {
    input_vec[i] = ((half*)input)[i];
  }

  for (int i = 0; i < n_group_ff * k_group * n_group_size * k_group_size; i++) {
    gate_weight_vec[i] = ((half*)gate_weight)[i];
  }

  for (int i = 0; i < n_group_ff * k_group * n_group_size * k_group_size; i++) {
    up_weight_vec[i] = ((half*)up_weight)[i];
  }

  for (int i = 0; i < n_group * k_group_ff * n_group_size * k_group_size; i++) {
    down_weight_vec[i] = ((half*)down_weight)[i];
  }

  apply_llama_mlp<half, half, float, false>(input_vec, output_vec, gate_weight_vec, up_weight_vec, down_weight_vec);

  for (int i = 0; i < n_group * seq_len * n_group_size; i++) {
    ((float*)output)[i] = output_vec[i];
  }
}

void LlamaBlockSim(void* output_hidden_state,
                   void* input_hidden_state,
                   void* attn_norm_gamma,
                   void* ffn_norm_gamma,
                   void* query_weight,
                   void* key_weight,
                   void* value_weight,
                   void* output_proj_weight,
                   void* gate_weight,
                   void* up_weight,
                   void* down_weight,
                   int seq_len,
                   int hidden_size,
                   int intermediate_size,
                   int num_attention_heads,
                   float rmsnorm_epsilon)
{
  using namespace compute_model::tensor;
  using namespace compute_model::transformer::llama_block;
  using namespace compute_model::common::fp16;

  // Constants for tensor organization
  int oc_group_size = 32;  // For fp32 tensors
  int oc_group_size_hf = 16;  // For fp16 tensors
  int oc_group = hidden_size / oc_group_size;
  int oc_group_hf = hidden_size / oc_group_size_hf;
  int ff_group = intermediate_size / oc_group_size;
  int ff_group_hf = intermediate_size / oc_group_size_hf;

  // Create input tensors (fp32, group_size = 32)
  auto input_tensor = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);
  auto output_tensor = zeros<float>({oc_group, seq_len, oc_group_size}, kFloat32);
  
  // RMSNorm parameters (fp32, group_size = 32)
  auto attn_norm_tensor = zeros<float>({oc_group, oc_group_size}, kFloat32);
  auto ffn_norm_tensor = zeros<float>({oc_group, oc_group_size}, kFloat32);
  
  // Attention weights (fp16, n_group_size = 32, k_group_size = 16)
  auto query_weight_tensor = zeros<half>({oc_group, oc_group_hf, oc_group_size, oc_group_size_hf}, kHalf);
  auto key_weight_tensor = zeros<half>({oc_group, oc_group_hf, oc_group_size, oc_group_size_hf}, kHalf);
  auto value_weight_tensor = zeros<half>({oc_group, oc_group_hf, oc_group_size, oc_group_size_hf}, kHalf);
  auto output_proj_weight_tensor = zeros<half>({oc_group, oc_group_hf, oc_group_size, oc_group_size_hf}, kHalf);
  
  // MLP weights (fp16, n_group_size = 32, k_group_size = 16)
  auto gate_weight_tensor = zeros<half>({ff_group, oc_group_hf, oc_group_size, oc_group_size_hf}, kHalf);
  auto up_weight_tensor = zeros<half>({ff_group, oc_group_hf, oc_group_size, oc_group_size_hf}, kHalf);
  auto down_weight_tensor = zeros<half>({oc_group, ff_group_hf, oc_group_size, oc_group_size_hf}, kHalf);

  // Copy input data
  for (int i = 0; i < oc_group * seq_len * oc_group_size; i++) {
    input_tensor[i] = ((float*)input_hidden_state)[i];
  }
  
  // Copy RMSNorm parameters
  for (int i = 0; i < oc_group * oc_group_size; i++) {
    attn_norm_tensor[i] = ((float*)attn_norm_gamma)[i];
    ffn_norm_tensor[i] = ((float*)ffn_norm_gamma)[i];
  }
  
  // Copy attention weights
  for (int i = 0; i < oc_group * oc_group_hf * oc_group_size * oc_group_size_hf; i++) {
    query_weight_tensor[i] = ((half*)query_weight)[i];
    key_weight_tensor[i] = ((half*)key_weight)[i];
    value_weight_tensor[i] = ((half*)value_weight)[i];
    output_proj_weight_tensor[i] = ((half*)output_proj_weight)[i];
  }
  
  // Copy MLP weights
  for (int i = 0; i < ff_group * oc_group_hf * oc_group_size * oc_group_size_hf; i++) {
    gate_weight_tensor[i] = ((half*)gate_weight)[i];
    up_weight_tensor[i] = ((half*)up_weight)[i];
  }
  
  for (int i = 0; i < oc_group * ff_group_hf * oc_group_size * oc_group_size_hf; i++) {
    down_weight_tensor[i] = ((half*)down_weight)[i];
  }

  // Apply Llama Block
  apply_llama_block<float, half, false>(
    input_tensor, output_tensor,
    attn_norm_tensor, ffn_norm_tensor,
    query_weight_tensor, key_weight_tensor, value_weight_tensor, output_proj_weight_tensor,
    gate_weight_tensor, up_weight_tensor, down_weight_tensor,
    num_attention_heads, rmsnorm_epsilon
  );

  // Copy output data
  for (int i = 0; i < oc_group * seq_len * oc_group_size; i++) {
    ((float*)output_hidden_state)[i] = output_tensor[i];
  }
}
  
uint64_t Add_Elementwise(const char* insn_file_name,
                         const char* vcucode_file_name,
                         int seq_len,
                         int d_model,
                         int tile_m,
                         int block_oc_group,
                         int32_t dtype,
                         uint64_t input1_ddr_base_address,
                         uint64_t input2_ddr_base_address,
                         uint64_t output_ddr_base_address,
                         uint64_t vcu_code_ddr_base_address,
                         int all_done)
{
  using namespace vcu::operation;

  SingleVCUOp<> add_op;
  SingleVCUOp<>::Argument args;
  args.seq_len = seq_len;
  args.d_model = d_model;
  args.tile_m = tile_m;
  args.block_oc_group = block_oc_group;
  args.dtype = (DType)dtype;
  args.op_type = OP_TYPE::ADD;

  args.input1_base_addr = input1_ddr_base_address;
  args.input2_base_addr = input2_ddr_base_address;
  args.output_base_addr = output_ddr_base_address;
  args.vcu_code_addr = vcu_code_ddr_base_address;
  args.all_done = (uint64_t)all_done;

  auto result = add_op(args);
  auto insn_series = result.first;
  auto vcucode_series = result.second;

  common::insn::pad_serial_sync_word(insn_series);

#ifdef SIM_MODE
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction),
    32,
    true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t),
    32, true);
#else
  common::file_utils::saveCharArrayToBinFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction));

  common::file_utils::saveCharArrayToBinFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t));
#endif

  return insn_series.size();
}

uint64_t Mul_Elementwise(const char* insn_file_name,
                         const char* vcucode_file_name,
                         int seq_len,
                         int d_model,
                         int tile_m,
                         int block_oc_group,
                         int32_t dtype,
                         uint64_t input1_ddr_base_address,
                         uint64_t input2_ddr_base_address,
                         uint64_t output_ddr_base_address,
                         uint64_t vcu_code_ddr_base_address,
                         int all_done)
{
  using namespace vcu::operation;

  SingleVCUOp<> mul_op;
  SingleVCUOp<>::Argument args;
  args.seq_len = seq_len;
  args.d_model = d_model;
  args.tile_m = tile_m;
  args.block_oc_group = block_oc_group;
  args.dtype = (DType)dtype;
  args.op_type = OP_TYPE::MUL;

  args.input1_base_addr = input1_ddr_base_address;
  args.input2_base_addr = input2_ddr_base_address;
  args.output_base_addr = output_ddr_base_address;
  args.vcu_code_addr = vcu_code_ddr_base_address;
  args.all_done = (uint64_t)all_done;

  auto result = mul_op(args);
  auto insn_series = result.first;
  auto vcucode_series = result.second;

  common::insn::pad_serial_sync_word(insn_series);

#ifdef SIM_MODE
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction),
    32,
    true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t),
    32, true);
#else
  common::file_utils::saveCharArrayToBinFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction));

  common::file_utils::saveCharArrayToBinFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t));
#endif

  return insn_series.size();
}


uint64_t Conv2d(const char* insn_file_name,
                         int h,
                         int w,
                         int kernel_h,
                         int kernel_w,
                         int padding_h,
                         int padding_w,
                         int stride_h,
                         int stride_w,
                         int ic_group,
                         int oc_group,
                         int dilation_h,
                         int dilation_w,
                         int ifmap_block_h,
                         int ifmap_block_w,
                         uint64_t ifmap_ddr_base_address,
                         uint64_t weight_ddr_base_address,
                         uint64_t ofmap_ddr_base_address,
                         uint64_t ifmap_scale_ddr_base_address,
                         uint64_t weight_scale_ddr_base_address,
                         uint64_t outlier_index_ddr_base_address,
                         uint64_t ifmap_mask_ddr_base_address,
                         int all_done)
{
  int ic_group_size = 32;
  int oc_group_size = 32;

  using conv2d_t = pea::Conv2dOp<>;
  conv2d_t::Arguments args = {
    h,
    w,
    kernel_h,
    kernel_w,
    (ic_group * ic_group_size),
    (oc_group * oc_group_size),
    stride_h,
    stride_w,
    padding_h,
    padding_w,
    dilation_h,
    dilation_w,
    ifmap_block_h,
    ifmap_block_w,
    kernel_h,
    kernel_w,
    1,
    1,
    ifmap_ddr_base_address,
    weight_ddr_base_address,
    ofmap_ddr_base_address,
    ifmap_scale_ddr_base_address,
    weight_scale_ddr_base_address,
    outlier_index_ddr_base_address,
    ifmap_mask_ddr_base_address,
    all_done
  };

  conv2d_t conv2d_op;
  auto insn_series = conv2d_op(args);
  common::insn::pad_serial_sync_word(insn_series);

#ifdef SIM_MODE
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction),
    32,
    true);
#else
  common::file_utils::saveCharArrayToBinFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction));
#endif

  return insn_series.size();
}

uint64_t Gemm(const char* insn_file_name,
              int m,
              int n,
              int k,
              int tile_m,
              int block_n_group,
              int block_k_group,
              uint64_t ifmap_addr,
              uint64_t weight_addr,
              uint64_t output_addr,
              int all_done)
{
  using gemm_t = pea::GemmOp<0, 0, 0, 0, kHalf, kHalf, kFloat32, kFloat32, _DEBUG>;
  typename gemm_t::Arguments args = {
    m, n, k, tile_m, block_n_group, block_k_group,
    ifmap_addr, weight_addr, output_addr, 0, 0, 0, 0, (uint64_t)all_done
  };

  gemm_t gemm_op;
  auto insn_series = gemm_op(args);
  
  pad_serial_sync_word(insn_series);

#ifdef SIM_MODE
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(instruction),
    32, true);
#else
  common::file_utils::saveCharArrayToBinFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(instruction));
#endif

  return insn_series.size();
}

uint64_t RMSNorm(const char* insn_file_name,
                const char* vcucode_file_name,
                int seq_len,
                int d_model,
                int tile_m,
                int block_oc_group,
                float epsilon,
                int32_t dtype,
                uint64_t input_ddr_base_address,
                uint64_t gamma_ddr_base_address,
                uint64_t output_ddr_base_address,
                uint64_t vcucode_ddr_base_address,
                uint64_t rec_lut_ddr_base_address,
                uint64_t log_lut_ddr_base_address,
                uint64_t exp_lut_ddr_base_address,
                uint64_t rsqrt_lut_ddr_base_address,
                int all_done)
{
  using rmsnorm_t = transformer::rmsnorm::RMSNormOp<_DEBUG>;
  typename rmsnorm_t::Argument args = {
    seq_len,
    d_model,
    tile_m,
    block_oc_group,
    epsilon,
    (DType)dtype,
    input_ddr_base_address,
    gamma_ddr_base_address,
    output_ddr_base_address,
    vcucode_ddr_base_address,
    rec_lut_ddr_base_address,
    log_lut_ddr_base_address,
    exp_lut_ddr_base_address,
    rsqrt_lut_ddr_base_address,
    (uint64_t)all_done
  };
  
  rmsnorm_t rmsnorm_op;
  auto result = rmsnorm_op(args);
  auto insn_series = result.first;
  auto vcucode_series = result.second;
  common::insn::pad_serial_sync_word(insn_series);

#ifdef SIM_MODE
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction),
    32, true);
    
  common::file_utils::saveCharArrayToFormattedTextFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t),
    32, true);
#else
  common::file_utils::saveCharArrayToBinFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction));
    
  common::file_utils::saveCharArrayToBinFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t));
#endif

  return insn_series.size();
}

int Softmax(const char* insn_file_name,
          const char* vcucode_file_name,
          int seq_len,
          int d_model,
          int tile_m,
          int block_oc_group,
          uint64_t input_addr,
          uint64_t output_addr,
          uint64_t vcu_code_addr,
          uint64_t exp_lut_addr,
          uint64_t rec_lut_addr,
          int all_done)
{
  using softmax_t = transformer::softmax::SoftmaxOp<_DEBUG>;
  typename softmax_t::Argument args = {
    .seq_len = seq_len,
    .d_model = d_model,
    .tile_m = tile_m,
    .block_oc_group = block_oc_group,
    .dtype = kFloat32,
    .input_base_addr = input_addr,
    .output_base_addr = output_addr,
    .vcu_code_base_addr = vcu_code_addr,
    .rec_lut_base_addr = rec_lut_addr,
    .exp_lut_base_addr = exp_lut_addr,
    .all_done = (uint64_t)all_done
  };

  softmax_t softmax_op;
  auto result = softmax_op(args);
  auto insn_series = result.first;
  auto vcucode_series = result.second;

  pad_serial_sync_word(insn_series);

#ifdef SIM_MODE
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(instruction),
    32, true);
    
  common::file_utils::saveCharArrayToFormattedTextFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t),
    32, true);
#else
  common::file_utils::saveCharArrayToBinFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(instruction));
    
  common::file_utils::saveCharArrayToBinFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t));
#endif

  return insn_series.size();
}

uint64_t LlamaMlp(const char* insn_file_name,
                const char* vcucode_file_name,
                int seq_len,
                int hidden_size,
                int intermediate_size,
                uint64_t input_ddr_base_address,
                uint64_t gate_weight_ddr_base_address,
                uint64_t up_weight_ddr_base_address,
                uint64_t down_weight_ddr_base_address,
                uint64_t gate_output_ddr_base_address,
                uint64_t up_output_ddr_base_address,
                uint64_t mul_output_ddr_base_address,
                uint64_t final_output_ddr_base_address,
                uint64_t vcu_code_ddr_base_address,
                uint64_t swish_lut_ddr_base_address,
                int all_done)
{
  using llama_mlp_t = transformer::llama_mlp::LlamaMlpOp<_DEBUG>;
  typename llama_mlp_t::Argument args = {
    seq_len,
    hidden_size,
    intermediate_size,
    input_ddr_base_address,
    gate_weight_ddr_base_address,
    up_weight_ddr_base_address,
    down_weight_ddr_base_address,
    gate_output_ddr_base_address,
    up_output_ddr_base_address,
    mul_output_ddr_base_address,
    final_output_ddr_base_address,
    vcu_code_ddr_base_address,
    swish_lut_ddr_base_address,
    (uint64_t)all_done
  };

  llama_mlp_t llama_mlp_op;
  auto result = llama_mlp_op(args);
  auto insn_series = result.first;
  auto vcucode_series = result.second;
  common::insn::pad_serial_sync_word(insn_series);

#ifdef SIM_MODE
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction),
    32,
    true);
    
  common::file_utils::saveCharArrayToFormattedTextFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t),
    32,
    true);
#else
  common::file_utils::saveCharArrayToBinFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction));
    
  common::file_utils::saveCharArrayToBinFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t));
#endif
  return insn_series.size();
}

uint64_t LlamaBlock(const char* insn_file_name,
                    const char* vcucode_file_name,
                    int seq_len,
                    int hidden_size,
                    int intermediate_size,
                    int num_attention_heads,
                    float rmsnorm_epsilon,
                    int32_t hidden_dtype,
                    int32_t weight_dtype,
                    uint64_t input_hidden_state_addr,
                    uint64_t final_output_hidden_state_addr,
                    // RoPE and Mask Parameters
                    uint64_t freq_cls_base_addr,    
                    uint64_t mask_base_addr,        
                    // Weight Address
                    uint64_t attn_norm_gamma_addr, // RMSNorm before Attention
                    uint64_t attn_query_weight_addr,
                    uint64_t attn_key_weight_addr,
                    uint64_t attn_value_weight_addr,
                    uint64_t attn_output_weight_addr,
                    uint64_t ffn_norm_gamma_addr,  // RMSNorm before MLP
                    uint64_t mlp_gate_weight_addr,
                    uint64_t mlp_up_weight_addr,
                    uint64_t mlp_down_weight_addr,
                    // Temporary Storage Addresses 
                    uint64_t attn_norm_output_addr,         // Output of 1st RMSNorm
                    uint64_t attn_query_temp_addr,             // Temp for Q projection in Attention
                    uint64_t attn_key_temp_addr,               // Temp for K projection in Attention
                    uint64_t attn_value_temp_addr,             // Temp for V projection in Attention
                    uint64_t attn_score_temp_addr,             // Temp for QK^T scores in Attention
                    uint64_t attn_probe_temp_addr,             // Temp for Softmax output (probe) in Attention
                    uint64_t attn_output_temp_addr,        // Output of Attention (before projection)
                    uint64_t attn_output_proj_addr,             // Final projected output of Attention
                    uint64_t residual_after_attn_addr,    // Output of 1st residual add (input_hs + attn_out)
                    uint64_t ffn_norm_output_addr,          // Output of 2nd RMSNorm
                    uint64_t mlp_gate_output_addr,        // Temp for gate projection in MLP
                    uint64_t mlp_up_output_addr,          // Temp for up projection in MLP
                    uint64_t mlp_mul_output_addr,         // Temp for SiLU * Up_proj in MLP
                    uint64_t mlp_final_proj_output_addr, // Output of MLP (before 2nd residual)
                    // VCU code Addresses
                    uint64_t vcu_code_llama_block_addr, // Can reuse the same VCU code if op is identical
                    uint64_t rec_lut_addr,          // For RMSNorm
                    uint64_t log_lut_addr,          // For RMSNorm
                    uint64_t exp_lut_addr,          // For Attention (softmax)
                    uint64_t rsqrt_lut_addr,        // For RMSNorm
                    uint64_t swish_lut_addr,       // For MLP
                    int all_done)
{
  using llama_block_t =  transformer::llama_block::LlamaBlockOp<_DEBUG>;
  typename llama_block_t::Argument args = {
    .seq_len = seq_len,
    .hidden_size = hidden_size,
    .intermediate_size = intermediate_size,
    .num_attention_heads = num_attention_heads,
    .rmsnorm_epsilon = rmsnorm_epsilon,
    .hidden_dtype = (DType)hidden_dtype,
    .weight_dtype = (DType)weight_dtype,
    
    // DDR Addresses from addr_for_llama.h
    .input_hidden_state_addr = input_hidden_state_addr,
    .final_output_hidden_state_addr = final_output_hidden_state_addr,
    
    // RoPE and Mask parameters
    .freq_cls_base_addr = freq_cls_base_addr,
    .mask_base_addr = mask_base_addr,
    
    // Weight addresses
    .attn_norm_gamma_addr = attn_norm_gamma_addr,
    .attn_query_weight_addr = attn_query_weight_addr,
    .attn_key_weight_addr = attn_key_weight_addr,
    .attn_value_weight_addr = attn_value_weight_addr,
    .attn_output_weight_addr = attn_output_weight_addr,
    .ffn_norm_gamma_addr = ffn_norm_gamma_addr,
    .mlp_gate_weight_addr = mlp_gate_weight_addr,
    .mlp_up_weight_addr = mlp_up_weight_addr,
    .mlp_down_weight_addr = mlp_down_weight_addr,

    // Temporary storage addresses
    .attn_norm_output_addr = attn_norm_output_addr,
    .attn_query_temp_addr = attn_query_temp_addr,
    .attn_key_temp_addr = attn_key_temp_addr,
    .attn_value_temp_addr = attn_value_temp_addr,
    .attn_score_temp_addr = attn_score_temp_addr,
    .attn_probe_temp_addr = attn_probe_temp_addr,
    .attn_output_temp_addr = attn_output_temp_addr,
    .attn_output_proj_addr = attn_output_proj_addr,
    .residual_after_attn_addr = residual_after_attn_addr,
    .ffn_norm_output_addr = ffn_norm_output_addr,
    .mlp_gate_output_addr = mlp_gate_output_addr,
    .mlp_up_output_addr = mlp_up_output_addr,
    .mlp_mul_output_addr = mlp_mul_output_addr,
    .mlp_final_proj_output_addr = mlp_final_proj_output_addr,
    
    // VCU code and LUT addresses
    .vcu_code_llama_block_addr = vcu_code_llama_block_addr,
    .rec_lut_addr = rec_lut_addr,
    .log_lut_addr = log_lut_addr,
    .exp_lut_addr = exp_lut_addr,
    .rsqrt_lut_addr = rsqrt_lut_addr,
    .swish_lut_addr = swish_lut_addr,
    
    .all_done = (uint64_t)all_done
  };

  llama_block_t llama_block_op;
  auto result = llama_block_op(args);
  auto insn_series = result.first;
  auto vcucode_series = result.second;

  common::insn::pad_serial_sync_word(insn_series);

#ifdef SIM_MODE
  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction),
    32, true);
    
  common::file_utils::saveCharArrayToFormattedTextFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t),
    32, true);
#else
  common::file_utils::saveCharArrayToBinFile(
    insn_file_name,
    reinterpret_cast<char*>(insn_series.data()),
    insn_series.size() * sizeof(common::insn::instruction));
    
  common::file_utils::saveCharArrayToBinFile(
    vcucode_file_name,
    reinterpret_cast<char*>(vcucode_series.data()),
    vcucode_series.size() * sizeof(uint64_t));
#endif

  return insn_series.size();
}

}  // extern "C"