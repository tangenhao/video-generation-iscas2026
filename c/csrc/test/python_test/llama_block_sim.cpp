#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stdexcept>
#include <cmath>
#include <cstdlib>
#include <chrono>

// NPUGen3 compute model headers
#include "compute_model/common/tensor.h"
#include "compute_model/transformer/llama_block.h"
#include "compute_model/common/fp16.h"

using namespace compute_model::tensor;
using namespace compute_model::common::fp16;

// Helper function to load tensor data from a .bin file
template<typename T>
bool load_tensor_from_bin(const std::string& filename, std::vector<T>& data_vec, size_t expected_elements) {
    std::ifstream infile(filename, std::ios::binary);
    if (!infile.is_open()) {
        std::cerr << "Error opening file: " << filename << std::endl;
        return false;
    }
    infile.seekg(0, std::ios::end);
    size_t length = infile.tellg();
    infile.seekg(0, std::ios::beg);
    if (length != expected_elements * sizeof(T)) {
        std::cerr << "Error: File size " << length << " bytes does not match expected size "
                  << expected_elements * sizeof(T) << " bytes for " << expected_elements << " elements (" << filename << ")." << std::endl;
        infile.close();
        return false;
    }
    data_vec.resize(expected_elements);
    infile.read(reinterpret_cast<char*>(data_vec.data()), length);
    if (!infile) {
        std::cerr << "Error reading data from file: " << filename << std::endl;
        infile.close();
        return false;
    }
    infile.close();
    return true;
}

// Helper function to save tensor data to a .bin file
template<typename T>
bool save_tensor_to_bin(const std::string& filename, const std::vector<T>& data_vec) {
    std::ofstream outfile(filename, std::ios::binary);
    if (!outfile.is_open()) {
        std::cerr << "Error opening file for writing: " << filename << std::endl;
        return false;
    }
    outfile.write(reinterpret_cast<const char*>(data_vec.data()), data_vec.size() * sizeof(T));
    if (!outfile) {
        std::cerr << "Error writing data to file: " << filename << std::endl;
        outfile.close();
        return false;
    }
    outfile.close();
    return true;
}

void print_usage(const char* program_name) {
    std::cout << "Usage: " << program_name 
              << " --seq_len <seq_len> --d_model <d_model> --intermediate_size <intermediate_size> --head_num <head_num>"
              << " --input_path <input_path> --attn_norm_gamma_path <attn_norm_gamma_path> --ffn_norm_gamma_path <ffn_norm_gamma_path>"
              << " --query_weight_path <query_weight_path> --key_weight_path <key_weight_path> --value_weight_path <value_weight_path>"
              << " --output_proj_weight_path <output_proj_weight_path> --gate_weight_path <gate_weight_path> --up_weight_path <up_weight_path>"
              << " --down_weight_path <down_weight_path> --output_path <output_path>" << std::endl;
}

int main(int argc, char* argv[]) {
    // Default parameters
    int seq_len = 32;
    int d_model = 128;
    int intermediate_size = 128;
    int head_num = 2;
    float rmsnorm_epsilon = 1e-6f;
    int n_group_size = 32;  // FP32 parallelism
    int k_group_size = 16;  // FP16 parallelism
    
    std::string input_path, attn_norm_gamma_path, ffn_norm_gamma_path;
    std::string query_weight_path, key_weight_path, value_weight_path, output_proj_weight_path;
    std::string gate_weight_path, up_weight_path, down_weight_path;
    std::string output_path;

    // Parse command line arguments
    for (int i = 1; i < argc; i += 2) {
        if (i + 1 >= argc) {
            print_usage(argv[0]);
            return 1;
        }
        std::string arg = argv[i];
        std::string value = argv[i + 1];

        if (arg == "--seq_len") {
            seq_len = std::atoi(value.c_str());
        } else if (arg == "--d_model") {
            d_model = std::atoi(value.c_str());
        } else if (arg == "--intermediate_size") {
            intermediate_size = std::atoi(value.c_str());
        } else if (arg == "--head_num") {
            head_num = std::atoi(value.c_str());
        } else if (arg == "--input_path") {
            input_path = value;
        } else if (arg == "--attn_norm_gamma_path") {
            attn_norm_gamma_path = value;
        } else if (arg == "--ffn_norm_gamma_path") {
            ffn_norm_gamma_path = value;
        } else if (arg == "--query_weight_path") {
            query_weight_path = value;
        } else if (arg == "--key_weight_path") {
            key_weight_path = value;
        } else if (arg == "--value_weight_path") {
            value_weight_path = value;
        } else if (arg == "--output_proj_weight_path") {
            output_proj_weight_path = value;
        } else if (arg == "--gate_weight_path") {
            gate_weight_path = value;
        } else if (arg == "--up_weight_path") {
            up_weight_path = value;
        } else if (arg == "--down_weight_path") {
            down_weight_path = value;
        } else if (arg == "--output_path") {
            output_path = value;
        } else {
            std::cerr << "Unknown argument: " << arg << std::endl;
            print_usage(argv[0]);
            return 1;
        }
    }

    // Validate required parameters
    if (input_path.empty() || attn_norm_gamma_path.empty() || ffn_norm_gamma_path.empty() ||
        query_weight_path.empty() || key_weight_path.empty() || value_weight_path.empty() ||
        output_proj_weight_path.empty() || gate_weight_path.empty() || up_weight_path.empty() ||
        down_weight_path.empty() || output_path.empty()) {
        std::cerr << "Error: Missing required arguments." << std::endl;
        print_usage(argv[0]);
        return 1;
    }

    if (d_model % n_group_size != 0 || intermediate_size % n_group_size != 0) {
        std::cerr << "Error: d_model and intermediate_size must be divisible by n_group_size." << std::endl;
        return 1;
    }

    std::cout << "Llama Block Simulation Parameters:" << std::endl;
    std::cout << "seq_len: " << seq_len << ", d_model: " << d_model << ", intermediate_size: " << intermediate_size << ", head_num: " << head_num << std::endl;
    std::cout << "n_group_size: " << n_group_size << ", k_group_size: " << k_group_size << std::endl;

    // Calculate dimensions
    int oc_group = d_model / n_group_size;
    int ic_group_attn = d_model / k_group_size;
    int oc_group_mlp = intermediate_size / n_group_size;
    int ic_group_mlp = intermediate_size / k_group_size;

    // Input hidden state: [oc_group, seq_len, n_group_size]
    size_t input_size = oc_group * seq_len * n_group_size;
    std::vector<float> input_data;
    
    // RMSNorm gammas: [oc_group, n_group_size]
    size_t gamma_size = oc_group * n_group_size;
    std::vector<float> attn_norm_gamma_data, ffn_norm_gamma_data;

    // Attention weights: [oc_group, ic_group_attn, n_group_size, k_group_size]
    size_t attn_weight_size = oc_group * ic_group_attn * n_group_size * k_group_size;
    std::vector<half> query_weight_data, key_weight_data, value_weight_data, output_proj_weight_data;

    // MLP weights
    size_t gate_up_weight_size = oc_group_mlp * ic_group_attn * n_group_size * k_group_size;
    size_t down_weight_size = oc_group * ic_group_mlp * n_group_size * k_group_size;
    std::vector<half> gate_weight_data, up_weight_data, down_weight_data;

    // Load all input data
    std::cout << "Loading input data..." << std::endl;
    if (!load_tensor_from_bin(input_path, input_data, input_size)) return 1;
    if (!load_tensor_from_bin(attn_norm_gamma_path, attn_norm_gamma_data, gamma_size)) return 1;
    if (!load_tensor_from_bin(ffn_norm_gamma_path, ffn_norm_gamma_data, gamma_size)) return 1;
    if (!load_tensor_from_bin(query_weight_path, query_weight_data, attn_weight_size)) return 1;
    if (!load_tensor_from_bin(key_weight_path, key_weight_data, attn_weight_size)) return 1;
    if (!load_tensor_from_bin(value_weight_path, value_weight_data, attn_weight_size)) return 1;
    if (!load_tensor_from_bin(output_proj_weight_path, output_proj_weight_data, attn_weight_size)) return 1;
    if (!load_tensor_from_bin(gate_weight_path, gate_weight_data, gate_up_weight_size)) return 1;
    if (!load_tensor_from_bin(up_weight_path, up_weight_data, gate_up_weight_size)) return 1;
    if (!load_tensor_from_bin(down_weight_path, down_weight_data, down_weight_size)) return 1;

    std::cout << "Data loaded successfully. Creating tensors..." << std::endl;

    // Create tensors
    Tensor<float> input_tensor(input_data.data(), {oc_group, seq_len, n_group_size}, kFloat32);
    Tensor<float> attn_norm_gamma_tensor(attn_norm_gamma_data.data(), {oc_group, n_group_size}, kFloat32);
    Tensor<float> ffn_norm_gamma_tensor(ffn_norm_gamma_data.data(), {oc_group, n_group_size}, kFloat32);

    Tensor<half> query_weight_tensor(query_weight_data.data(), {oc_group, ic_group_attn, n_group_size, k_group_size}, kHalf);
    Tensor<half> key_weight_tensor(key_weight_data.data(), {oc_group, ic_group_attn, n_group_size, k_group_size}, kHalf);
    Tensor<half> value_weight_tensor(value_weight_data.data(), {oc_group, ic_group_attn, n_group_size, k_group_size}, kHalf);
    Tensor<half> output_proj_weight_tensor(output_proj_weight_data.data(), {oc_group, ic_group_attn, n_group_size, k_group_size}, kHalf);

    Tensor<half> gate_weight_tensor(gate_weight_data.data(), {oc_group_mlp, ic_group_attn, n_group_size, k_group_size}, kHalf);
    Tensor<half> up_weight_tensor(up_weight_data.data(), {oc_group_mlp, ic_group_attn, n_group_size, k_group_size}, kHalf);
    Tensor<half> down_weight_tensor(down_weight_data.data(), {oc_group, ic_group_mlp, n_group_size, k_group_size}, kHalf);

    // Create output tensor
    Tensor<float> output_tensor({oc_group, seq_len, n_group_size}, kFloat32);

    std::cout << "Running Llama Block computation..." << std::endl;

    // Measure performance
    auto start_time = std::chrono::high_resolution_clock::now();
    
    // Apply llama block 
    compute_model::transformer::llama_block::apply_llama_block<float, half, false>(
        input_tensor,
        output_tensor,
        attn_norm_gamma_tensor,
        ffn_norm_gamma_tensor,
        query_weight_tensor,
        key_weight_tensor,
        value_weight_tensor,
        output_proj_weight_tensor,
        gate_weight_tensor,
        up_weight_tensor,
        down_weight_tensor,
        head_num,
        rmsnorm_epsilon
    );

    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);
    
    double execution_time_ms = duration.count() / 1000.0;
    double tokens_per_sec = seq_len / (duration.count() / 1e6);
    
    std::cout << "Llama Block computation completed." << std::endl;
    std::cout << "Execution time: " << execution_time_ms << " ms" << std::endl;
    std::cout << "Throughput: " << tokens_per_sec << " tokens/sec" << std::endl;

    // Save output
    std::cout << "Saving output to: " << output_path << std::endl;
    std::vector<float> output_data(output_tensor.data_ptr(), output_tensor.data_ptr() + output_tensor.numel());
    if (!save_tensor_to_bin(output_path, output_data)) {
        return 1;
    }

    std::cout << "Llama Block simulation completed successfully." << std::endl;
    std::cout << "Output shape: [" << oc_group << ", " << seq_len << ", " << n_group_size << "]" << std::endl;
    std::cout << "Output saved to: " << output_path << std::endl;

    return 0;
}
