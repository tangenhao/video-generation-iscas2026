#include "addr_for_stdit.h"
#include "common/insn.h"
#include "compute_model/common/fp16.h"
#include "compute_model/common/tensor.h"
#include "compute_model/function/reduce.h"
#include "compute_model/function/tensor_function.h"
#include "stdit/gemm_i8w8.h"
#include "vcu/vcu_insn.h"
#include "vcu/vcu_opcode.h"
#include "write_reg.h"
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <string>
#include <vector>

using compute_model::common::fp16::half;

std::string fp16_hex(half value)
{
  std::ostringstream oss;
  oss << "0x" << std::hex << std::setw(4) << std::setfill('0') << value.storage;
  return oss.str();
}

std::string u8_hex(uint8_t value)
{
  std::ostringstream oss;
  oss << "0x" << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(value);
  return oss.str();
}

std::string fp32_hex(float value)
{
  uint32_t bits = 0;
  static_assert(sizeof(bits) == sizeof(value), "float must be 32-bit");
  std::memcpy(&bits, &value, sizeof(bits));

  std::ostringstream oss;
  oss << "0x" << std::hex << std::setw(8) << std::setfill('0') << bits;
  return oss.str();
}

std::string signed_hex(int64_t value, int bits)
{
  assert(bits > 0 && bits <= 63);
  uint64_t mask = (uint64_t{1} << bits) - 1;
  int      digits = (bits + 3) / 4;

  std::ostringstream oss;
  oss << "0x" << std::hex << std::setw(digits) << std::setfill('0') << (static_cast<uint64_t>(value) & mask);
  return oss.str();
}

template<typename T>
void dump_signed_hex_vector(std::ofstream& ofs, const char* name, const std::vector<T>& values, int bits)
{
  ofs << "    " << name << "[" << std::dec << values.size() << "] s" << bits << " =";
  for (const auto& value : values) {
    ofs << " " << signed_hex(static_cast<int64_t>(value), bits);
  }
  ofs << "\n";
}

int8_t fp16_to_int8_quant_golden(half value)
{
  uint16_t in_data = value.storage;

  bool     f_sign = (in_data >> 15) & 0x1;
  uint16_t f_exp  = (in_data >> 10) & 0x1f;
  uint16_t f_frac = in_data & 0x03ff;

  bool zero   = (f_exp == 0) && (f_frac == 0);
  bool nan    = (f_exp == 0x1f) && (f_frac != 0);
  bool normal = f_exp != 0;

  int f_exp_ext     = static_cast<int>(f_exp) - 15;
  bool in_round     = normal && (f_exp_ext >= -1) && (f_exp_ext <= 6);
  bool overflow     = normal && (f_exp_ext >= 7);
  int  magnitude    = 0;

  if (nan || zero) {
    magnitude = 0;
  }
  else if (overflow) {
    magnitude = f_sign ? 128 : 127;
  }
  else if (in_round) {
    uint16_t significand     = 0x0400 | f_frac;
    uint16_t significand_ext = significand;
    int      right_shift     = 10 - f_exp_ext;
    int      int_part        = significand_ext >> right_shift;
    int      frac_mask       = (1 << right_shift) - 1;
    int      frac_part       = significand_ext & frac_mask;
    int      half_part       = 1 << (right_shift - 1);
    bool     round_inc       = (frac_part > half_part) || ((frac_part == half_part) && (int_part & 0x1));
    magnitude                = int_part + (round_inc ? 1 : 0);
  }

  magnitude = f_sign ? std::min(magnitude, 128) : std::min(magnitude, 127);
  return static_cast<int8_t>(f_sign ? -magnitude : magnitude);
}

void print_bytes_right_low(const char* title, const void* data, size_t data_size, size_t bytes_per_line)
{
  const uint8_t* bytes = reinterpret_cast<const uint8_t*>(data);
  std::cout << title << " (rightLow, " << bytes_per_line << "B/line):\n";
  for (size_t base = 0; base < data_size; base += bytes_per_line) {
    size_t line_bytes = std::min(bytes_per_line, data_size - base);
    std::cout << "  [" << std::dec << std::setw(4) << (base / bytes_per_line) << "] 0x";
    for (size_t i = 0; i < line_bytes; ++i) {
      size_t idx = base + line_bytes - 1 - i;
      std::cout << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(bytes[idx]);
    }
    std::cout << std::dec << std::setfill(' ') << "\n";
  }
}

half abs_half(half value)
{
  return half(static_cast<uint16_t>(value.storage & 0x7fff));
}

std::pair<int, int> split_exp_fra(int64_t x)
{
  if (x > 8355840) {
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

compute_model::tensor::Tensor<int32_t> gemm_i8w8_bias_golden(const compute_model::tensor::Tensor<int8_t>& ifmap,
                                                             const compute_model::tensor::Tensor<int8_t>& weight,
                                                             int m,
                                                             int n,
                                                             int k,
                                                             int n_group_size,
                                                             int k_group_size)
{
  using compute_model::tensor::Tensor;

  int n_group = (n + n_group_size - 1) / n_group_size;
  int k_group = (k + k_group_size - 1) / k_group_size;

  assert(ifmap.data.size() == static_cast<size_t>(k_group * m * k_group_size));
  assert(weight.data.size() == static_cast<size_t>(n_group * k_group * n_group_size * k_group_size));

  Tensor<int32_t> ofmap({n_group, m, n_group_size}, kInt32);

  for (int m_idx = 0; m_idx < m; ++m_idx) {
    for (int n_group_idx = 0; n_group_idx < n_group; ++n_group_idx) {
      for (int n_inner = 0; n_inner < n_group_size; ++n_inner) {
        int     n_idx = n_group_idx * n_group_size + n_inner;
        int32_t acc   = 0;

        if (n_idx < n) {
          for (int k_group_idx = 0; k_group_idx < k_group; ++k_group_idx) {
            for (int k_inner = 0; k_inner < k_group_size; ++k_inner) {
              int k_idx = k_group_idx * k_group_size + k_inner;
              if (k_idx >= k) {
                continue;
              }

              size_t ifmap_idx =
                (static_cast<size_t>(m_idx) * k_group + k_group_idx) * k_group_size + k_inner;
              size_t weight_idx =
                (((static_cast<size_t>(n_group_idx) * k_group + k_group_idx) * n_group_size + n_inner) * k_group_size) + k_inner;
              acc += static_cast<int32_t>(ifmap.data[ifmap_idx]) * static_cast<int32_t>(weight.data[weight_idx]);
            }
          }
        }

        size_t ofmap_idx = (static_cast<size_t>(n_group_idx) * m + m_idx) * n_group_size + n_inner;
        ofmap.data[ofmap_idx] = acc;
      }
    }
  }

  return ofmap;
}

half fp16_add_golden(half lhs, half rhs)
{
  return half(static_cast<float>(lhs) + static_cast<float>(rhs));
}

half fp16_mul_golden(half lhs, half rhs)
{
  return half(static_cast<float>(lhs) * static_cast<float>(rhs));
}

half dequant_bias_lane_golden(int32_t ofmap_int32, half scale, half bias)
{
  half ofmap_fp16 = half(static_cast<float>(ofmap_int32));
  half mul_fp16   = fp16_mul_golden(ofmap_fp16, scale);
  return fp16_add_golden(mul_fp16, bias);
}

compute_model::tensor::Tensor<half> gemm_i8w8_dequant_bias_golden(const compute_model::tensor::Tensor<int32_t>& ofmap_int32,
                                                                  const compute_model::tensor::Tensor<half>& scale,
                                                                  const compute_model::tensor::Tensor<half>& bias,
                                                                  int m,
                                                                  int n_group,
                                                                  int n_group_size)
{
  using compute_model::tensor::Tensor;

  assert(ofmap_int32.data.size() == static_cast<size_t>(n_group * m * n_group_size));
  assert(scale.data.size() == static_cast<size_t>(m * n_group * n_group_size));
  assert(bias.data.size() == static_cast<size_t>(n_group * n_group_size));

  Tensor<half> ofmap_fp16({n_group, m, n_group_size}, kHalf);

  for (int m_idx = 0; m_idx < m; ++m_idx) {
    for (int n_group_idx = 0; n_group_idx < n_group; ++n_group_idx) {
      for (int n_inner = 0; n_inner < n_group_size; ++n_inner) {
        size_t ofmap_idx = (static_cast<size_t>(n_group_idx) * m + m_idx) * n_group_size + n_inner;
        size_t scale_idx = (static_cast<size_t>(m_idx) * n_group + n_group_idx) * n_group_size + n_inner;
        size_t bias_idx  = static_cast<size_t>(n_group_idx) * n_group_size + n_inner;

        ofmap_fp16[ofmap_idx] = dequant_bias_lane_golden(ofmap_int32.data[ofmap_idx], scale.data[scale_idx], bias.data[bias_idx]);
      }
    }
  }

  return ofmap_fp16;
}

std::vector<int8_t> make_weight_ddr_4_channel(const compute_model::tensor::Tensor<int8_t>& weight,
                                              int n_group,
                                              int k_group,
                                              int n_group_size,
                                              int k_group_size,
                                              int block_k_group)
{
  constexpr int weight_dma_channels = 4;

  assert(n_group_size % weight_dma_channels == 0);
  assert(k_group % block_k_group == 0);
  assert(weight.data.size() == static_cast<size_t>(n_group * k_group * n_group_size * k_group_size));

  int n_group_size_per_channel = n_group_size / weight_dma_channels;
  int k_blocks                 = k_group / block_k_group;

  std::vector<int8_t> weight_ddr;
  weight_ddr.reserve(weight.data.size());

  for (int n_group_idx = 0; n_group_idx < n_group; ++n_group_idx) {
    for (int k_block_idx = 0; k_block_idx < k_blocks; ++k_block_idx) {
      for (int channel_idx = 0; channel_idx < weight_dma_channels; ++channel_idx) {
        for (int k_block_inner = 0; k_block_inner < block_k_group; ++k_block_inner) {
          int k_group_idx = k_block_idx * block_k_group + k_block_inner;

          for (int n_inner_channel = 0; n_inner_channel < n_group_size_per_channel; ++n_inner_channel) {
            int n_inner = channel_idx * n_group_size_per_channel + n_inner_channel;

            for (int k_inner = 0; k_inner < k_group_size; ++k_inner) {
              size_t weight_idx =
                (((static_cast<size_t>(n_group_idx) * k_group + k_group_idx) * n_group_size + n_inner) * k_group_size) + k_inner;
              weight_ddr.push_back(weight.data[weight_idx]);
            }
          }
        }
      }
    }
  }

  assert(weight_ddr.size() == weight.data.size());
  return weight_ddr;
}

void dump_gemm_i8w8_bias_mpt_trace(const compute_model::tensor::Tensor<int8_t>& ifmap,
                                   const compute_model::tensor::Tensor<int8_t>& weight,
                                   int m,
                                   int n,
                                   int k,
                                   int n_group_size,
                                   int k_group_size,
                                   const std::string& filename,
                                   int m_begin,
                                   int m_count,
                                   int n_group_begin,
                                   int n_group_count,
                                   int k_group_begin,
                                   int k_group_count)
{
  int n_group = (n + n_group_size - 1) / n_group_size;
  int k_group = (k + k_group_size - 1) / k_group_size;

  int m_end       = std::min(m, m_begin + m_count);
  int n_group_end = std::min(n_group, n_group_begin + n_group_count);
  int k_group_end = std::min(k_group, k_group_begin + k_group_count);

  assert(ifmap.data.size() == static_cast<size_t>(k_group * m * k_group_size));
  assert(weight.data.size() == static_cast<size_t>(n_group * k_group * n_group_size * k_group_size));
  assert(n_group_size == 36);
  assert(k_group_size == 36);

  std::ofstream ofs(filename);
  assert(ofs.is_open());
  ofs << "# gemm_i8w8_bias mpt trace\n";
  ofs << "# ifmap layout: [m][k_group][k_group_size]\n";
  ofs << "# weight layout: [n_group][k_group][n_group_size][k_group_size]\n";
  ofs << "# tile order follows pea.v: m -> n_group -> k_group, with 36 mpt lanes per tile\n";
  ofs << "# hex is signed two's-complement, printed with the RTL signal width\n";
  ofs << "# add tree: mul[36] -> add_result_0[18] -> add_result_1[9] -> add_result_2[4] + tail -> add_result_3[2] -> add_result_4 -> add_result_5 -> acc\n\n";

  for (int m_idx = m_begin; m_idx < m_end; ++m_idx) {
    for (int n_group_idx = n_group_begin; n_group_idx < n_group_end; ++n_group_idx) {
      std::vector<int64_t> acc(n_group_size, 0);

      for (int n_inner = 0; n_inner < n_group_size; ++n_inner) {
        int n_idx = n_group_idx * n_group_size + n_inner;
        if (n_idx >= n) {
          continue;
        }

        for (int k_group_idx = 0; k_group_idx < k_group_begin; ++k_group_idx) {
          for (int k_inner = 0; k_inner < k_group_size; ++k_inner) {
            int k_idx = k_group_idx * k_group_size + k_inner;
            if (k_idx >= k) {
              continue;
            }

            size_t ifmap_idx = (static_cast<size_t>(m_idx) * k_group + k_group_idx) * k_group_size + k_inner;
            size_t weight_idx =
              (((static_cast<size_t>(n_group_idx) * k_group + k_group_idx) * n_group_size + n_inner) * k_group_size) + k_inner;
            acc[n_inner] += static_cast<int64_t>(ifmap.data[ifmap_idx]) * static_cast<int64_t>(weight.data[weight_idx]);
          }
        }
      }

      for (int k_group_idx = k_group_begin; k_group_idx < k_group_end; ++k_group_idx) {
        size_t ifmap_base = (static_cast<size_t>(m_idx) * k_group + k_group_idx) * k_group_size;

        std::vector<int8_t> ifmap_vec(k_group_size, 0);
        for (int k_inner = 0; k_inner < k_group_size; ++k_inner) {
          int k_idx = k_group_idx * k_group_size + k_inner;
          ifmap_vec[k_inner] = (k_idx < k) ? ifmap.data[ifmap_base + k_inner] : 0;
        }

        ofs << "TILE m=" << std::dec << m_idx
            << " n_group=" << n_group_idx
            << " k_group=" << k_group_idx
            << " ifmap_elem_base=" << ifmap_base << "\n";
        dump_signed_hex_vector(ofs, "ifmap_regfile", ifmap_vec, 8);

        for (int n_inner = 0; n_inner < n_group_size; ++n_inner) {
          int    n_idx       = n_group_idx * n_group_size + n_inner;
          size_t weight_base = (((static_cast<size_t>(n_group_idx) * k_group + k_group_idx) * n_group_size + n_inner) * k_group_size);

          std::vector<int8_t> weight_vec(k_group_size, 0);
          std::vector<int>    mul(36, 0);
          std::vector<int>    add0(18, 0);
          std::vector<int>    add1(9, 0);
          std::vector<int>    add2(4, 0);
          std::vector<int>    add3(2, 0);

          for (int k_inner = 0; k_inner < k_group_size; ++k_inner) {
            int k_idx = k_group_idx * k_group_size + k_inner;
            weight_vec[k_inner] = (n_idx < n && k_idx < k) ? weight.data[weight_base + k_inner] : 0;
            mul[k_inner] = static_cast<int>(ifmap_vec[k_inner]) * static_cast<int>(weight_vec[k_inner]);
          }

          for (int i = 0; i < 18; ++i) {
            add0[i] = mul[2 * i] + mul[2 * i + 1];
          }
          for (int i = 0; i < 8; ++i) {
            add1[i] = add0[2 * i] + add0[2 * i + 1];
          }
          add1[8] = add0[16] + add0[17];

          for (int i = 0; i < 4; ++i) {
            add2[i] = add1[2 * i] + add1[2 * i + 1];
          }

          for (int i = 0; i < 2; ++i) {
            add3[i] = add2[2 * i] + add2[2 * i + 1];
          }

          int     add4       = add3[0] + add3[1];
          int     add1_tail  = add1[8];
          int     add5       = add4 + add1_tail;
          int64_t acc_before = acc[n_inner];
          int64_t acc_after  = acc_before + add5;
          acc[n_inner]       = acc_after;

          ofs << "  LANE n_inner=" << std::setw(2) << std::setfill('0') << n_inner << std::setfill(' ')
              << " n_idx=" << std::setw(4) << n_idx
              << " weight_elem_base=" << weight_base
              << "\n";
          dump_signed_hex_vector(ofs, "weight_regfile", weight_vec, 8);
          dump_signed_hex_vector(ofs, "mul_result_reg", mul, 16);
          dump_signed_hex_vector(ofs, "add_result_0_reg", add0, 17);
          dump_signed_hex_vector(ofs, "add_result_1_reg", add1, 18);
          dump_signed_hex_vector(ofs, "add_result_2_reg", add2, 19);
          dump_signed_hex_vector(ofs, "add_result_3_reg", add3, 20);
          ofs << "    add_result_4_reg s21 = " << signed_hex(add4, 21) << "\n";
          ofs << "    add_result_1_tail_reg_d2 s18 = " << signed_hex(add1_tail, 18) << "\n";
          ofs << "    add_result_5_reg s22 = " << signed_hex(add5, 22) << "\n";
          ofs << "    add_result_acc before/after s32 = "
              << signed_hex(acc_before, 32) << " -> " << signed_hex(acc_after, 32) << "\n";
        }

        ofs << "\n";
      }
    }
  }
}

void dump_dequant_bias_vcu_trace(const compute_model::tensor::Tensor<int32_t>& ofmap_int32,
                                 const compute_model::tensor::Tensor<half>& scale,
                                 const compute_model::tensor::Tensor<half>& bias,
                                 const compute_model::tensor::Tensor<half>& ofmap_fp16,
                                 int m,
                                 int n,
                                 int n_group,
                                 int n_group_size,
                                 const std::string& filename)
{
  constexpr int dequant_sram_depth = 128;
  constexpr int vecmul_sram_depth  = 32;
  constexpr int vecadd_sram_depth  = 32;
  constexpr int vcuofmap_sram_depth = 64;

  assert(ofmap_int32.data.size() == static_cast<size_t>(n_group * m * n_group_size));
  assert(scale.data.size() == static_cast<size_t>(m * n_group * n_group_size));
  assert(bias.data.size() == static_cast<size_t>(n_group * n_group_size));
  assert(ofmap_fp16.data.size() == static_cast<size_t>(n_group * m * n_group_size));

  std::ofstream ofs(filename);
  assert(ofs.is_open());

  ofs << "# gemm_i8w8 dequant + bias VCU trace\n";
  ofs << "# RTL path: dequant_rdata int32 lane -> int2fp32 -> fp32_to_fp16 -> fma ifmap, para, resadd, reg0\n";
  ofs << "# FMA is modeled as IEEE rounded fp16 multiply followed by IEEE rounded fp16 add, matching rtl/vcu/fpu stream-fuse path.\n";
  ofs << "# Text memory files are rightLow: lane0 is the low bits of the bus and appears at the right side of each 32B line.\n";
  ofs << "# Layouts: dequant/ofmap_int32 [n_group][m][36], scale [m][n_group][36], bias [n_group][36], ofmap_fp16 [n_group][m][36]\n\n";

  for (int m_idx = 0; m_idx < m; ++m_idx) {
    for (int n_group_idx = 0; n_group_idx < n_group; ++n_group_idx) {
      int dequant_addr = (m_idx * n_group + n_group_idx) % dequant_sram_depth;
      int para_addr    = (m_idx * n_group + n_group_idx) % vecmul_sram_depth;
      int resadd_addr  = n_group_idx % vecadd_sram_depth;
      int ofmap_addr   = n_group_idx % vcuofmap_sram_depth;

      ofs << "VCU_TILE m=" << std::dec << m_idx
          << " n_group=" << n_group_idx
          << " dequant_raddr=" << dequant_addr
          << " vcupara_raddr=" << para_addr
          << " vcures_raddr=" << resadd_addr
          << " ofmap_waddr=" << ofmap_addr << "\n";

      ofs << "  lane order below is Verilog low-to-high: [16/32*(lane+1)-1 : 16/32*lane]\n";

      for (int lane = 0; lane < n_group_size; ++lane) {
        int    n_idx      = n_group_idx * n_group_size + lane;
        size_t ofmap_idx  = (static_cast<size_t>(n_group_idx) * m + m_idx) * n_group_size + lane;
        size_t scale_idx  = (static_cast<size_t>(m_idx) * n_group + n_group_idx) * n_group_size + lane;
        size_t bias_idx   = static_cast<size_t>(n_group_idx) * n_group_size + lane;
        int32_t acc_int32 = ofmap_int32.data[ofmap_idx];
        float  acc_fp32   = static_cast<float>(acc_int32);
        half   acc_fp16   = half(acc_fp32);
        half   mul_fp16   = fp16_mul_golden(acc_fp16, scale.data[scale_idx]);
        half   out_fp16   = fp16_add_golden(mul_fp16, bias.data[bias_idx]);

        ofs << "  lane=" << std::setw(2) << std::setfill('0') << lane << std::setfill(' ')
            << " n=" << std::setw(4) << n_idx
            << " valid=" << (n_idx < n ? 1 : 0)
            << " idx(ofmap,scale,bias)=" << ofmap_idx << "," << scale_idx << "," << bias_idx
            << " int32=" << std::dec << acc_int32
            << "(" << signed_hex(acc_int32, 32) << ")"
            << " int2fp32=" << fp32_hex(acc_fp32)
            << " dequant_fp16=" << fp16_hex(acc_fp16)
            << " scale=" << fp16_hex(scale.data[scale_idx])
            << " bias=" << fp16_hex(bias.data[bias_idx])
            << " mul_fp16=" << fp16_hex(mul_fp16)
            << " out_fp16=" << fp16_hex(out_fp16);

        if (out_fp16.storage != ofmap_fp16.data[ofmap_idx].storage) {
          ofs << " golden_tensor_mismatch=" << fp16_hex(ofmap_fp16.data[ofmap_idx]);
        }
        ofs << "\n";
      }

      ofs << "\n";
    }
  }
}

//block_k_group需要>=8且为偶数，因为k_group_size和n_group_size都是36，axi_data_width=256，k_group_size*n_group_size/axi_data_width=36*36/32=40.5，block_k_group必须为偶数才能保证每个block_k_group的weight数据可以被4通道的axi_data_width=32对齐

int main(int argc, const char** argv)
{
  using namespace common;
  using namespace compute_model::tensor;

  int      m                    = 2;
  int      n                    = 144;
  int      k                    = 576;
  int      n_group_size         = 36;
  int      k_group_size         = 36;
  int      n_group              = n / n_group_size;  //store时，n_group_size=36，需要seq_0_burst为整数
  int      k_group              = k / k_group_size;  //k_group/block_k_group需要>=1，因为有bias和dequant（scale）需要load
  int      block_n_group        = 4;
  int      block_k_group        = 8; //block_k_group需要>=8且为偶数
  int      tile_m               = 1;
  bool     dump_mpt_trace       = true;
  int      trace_m_begin        = 0;
  int      trace_m_count        = m;
  int      trace_n_group_begin  = 0;
  int      trace_n_group_count  = n_group;
  int      trace_k_group_begin  = 0;
  int      trace_k_group_count  = k_group;
  std::string mpt_trace_file    = "gemm_i8w8_288_bias_mpt_trace.txt";
  std::string dequant_trace_file = "gemm_i8w8_288_bias_dequant_vcu_trace.txt";
  std::string dequant_int32_file = "../../sim/memory/dequant_int32.txt";

  uint64_t ifmap_base_addr      = QACT_ADDR;
  uint64_t weight_base_addr     = WEIGHT_ADDR;
  uint64_t ofmap_base_addr      = OFMAP_ADDR;
  uint64_t opcode_ddr_base_addr = VCUCODE_ADDR;
  uint64_t bias_base_addr       = VCURES_ADDR;
  uint64_t scale_base_addr      = VCUPARA_ADDR;

  std::vector<std::string> opcode = { "fma ifmap, para, resadd, reg0",};

  assert(block_k_group >= 8 && block_k_group % 2 == 0);
  assert(k_group/block_k_group >= 1);
  // assert(n_group >= 4);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 insn gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  using gemm_t = stdit::gemm::insn_gen<true>;
  gemm_t::Arguments args = {
    m,
    n,
    k,
    tile_m,
    n_group_size,
    k_group_size,
    block_n_group,
    block_k_group,
    ifmap_base_addr,
    weight_base_addr,
    ofmap_base_addr,
    opcode_ddr_base_addr,
    bias_base_addr,
    scale_base_addr,
    opcode
  };
  gemm_t gemm_op;
  auto   temp           = gemm_op(args);
  auto   insn_series    = temp.first;
  auto   vcucode_series = temp.second;
  
  for (auto& insn : insn_series) {
    std::cout << insn.to_string() << std::endl;
  }

  common::file_utils::saveCharArrayToFormattedTextFile(
    insn_file.c_str(), reinterpret_cast<char*>(insn_series.data()), insn_series.size() * sizeof(common::insn::instruction), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    opcode_file.c_str(), reinterpret_cast<char*>(vcucode_series.data()), vcucode_series.size() * sizeof(uint64_t), 32, true);

  /* -------------------------------------------------------------------------------------------------------- */
  /*                                                 data gen                                                 */
  /* -------------------------------------------------------------------------------------------------------- */

  auto ifmap  = randn<int8_t>({m, k_group, k_group_size}, kInt8, -128.0f, 127.0f, 0);
  auto weight = randn<int8_t>({n_group, k_group, n_group_size, k_group_size}, kInt8, -128.0f, 127.0f, 100);
  auto ofmap  = gemm_i8w8_bias_golden(ifmap, weight, m, n, k, n_group_size, k_group_size);
  auto weight_ddr = make_weight_ddr_4_channel(weight, n_group, k_group, n_group_size, k_group_size, block_k_group);

  if (dump_mpt_trace) {
    dump_gemm_i8w8_bias_mpt_trace(ifmap,
                                  weight,
                                  m,
                                  n,
                                  k,
                                  n_group_size,
                                  k_group_size,
                                  mpt_trace_file,
                                  trace_m_begin,
                                  trace_m_count,
                                  trace_n_group_begin,
                                  trace_n_group_count,
                                  trace_k_group_begin,
                                  trace_k_group_count);
    std::cout << "Saved MPT trace to " << mpt_trace_file << std::endl;
  }

  auto scale      = randn<half>({m, n_group, n_group_size}, kHalf, half(0.25f), half(1.0f), 200);
  auto bias       = randn<half>({n_group, n_group_size}, kHalf, half(0.0f), half(1.0f), 300);
  auto ofmap_fp16 = gemm_i8w8_dequant_bias_golden(ofmap, scale, bias, m, n_group, n_group_size);

  dump_dequant_bias_vcu_trace(ofmap,
                              scale,
                              bias,
                              ofmap_fp16,
                              m,
                              n,
                              n_group,
                              n_group_size,
                              dequant_trace_file);
  std::cout << "Saved dequant+bias VCU trace to " << dequant_trace_file << std::endl;

  common::file_utils::saveCharArrayToFormattedTextFile(
    qact_file.c_str(), reinterpret_cast<char*>(ifmap.data_ptr()), ifmap.numel() * sizeof(int8_t), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    weight_file.c_str(), reinterpret_cast<char*>(weight_ddr.data()), weight_ddr.size() * sizeof(int8_t), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    dequant_int32_file.c_str(), reinterpret_cast<char*>(ofmap.data_ptr()), ofmap.numel() * sizeof(int32_t), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    ofmap_file.c_str(), reinterpret_cast<char*>(ofmap_fp16.data_ptr()), ofmap_fp16.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    para_file.c_str(), reinterpret_cast<char*>(scale.data_ptr()), scale.numel() * sizeof(half), 32, true);

  common::file_utils::saveCharArrayToFormattedTextFile(
    res_file.c_str(), reinterpret_cast<char*>(bias.data_ptr()), bias.numel() * sizeof(half), 32, true);

  write_regs(reg_cfg_file.c_str(),
             0,
             insn_series.size() * sizeof(common::insn::instruction) / 32,
             32,
             0,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             NO_BROADCAST,
             PSUM_LOAD_1024,
             PSUM_STORE_1024,
             VCURES_LOAD_1024,
             IFMAP_MASK_LOAD_32,
             1);

  return 0;
}
