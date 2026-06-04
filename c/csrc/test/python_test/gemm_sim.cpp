#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <numeric> // For std::iota if needed later
#include <algorithm> // For std::sort or other algorithms if needed
#include <stdexcept> // For std::runtime_error
#include <sstream> // For parsing command line arguments

// NPUGen3 compute model headers
#include "compute_model/common/tensor.h"
#include "compute_model/gemm/gemm.h"
#include "compute_model/common/fp16.h" // For half type

// Define data type alias for convenience
using half = compute_model::common::fp16::half;

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
                  << expected_elements * sizeof(T) << " bytes for " << expected_elements << " elements." << " File: " << filename << std::endl;
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
    // Ensure directory exists
    std::string dir_path = "";
    size_t last_slash_idx = filename.rfind('/');
    if (std::string::npos != last_slash_idx) {
        dir_path = filename.substr(0, last_slash_idx);
        // Crude way to ensure directory exists, better to use std::filesystem if available (C++17)
        // For now, assume Python script calling this will handle dir creation if needed, 
        // or that the path is simple enough.
        // For robustness, one might use: system(("mkdir -p " + dir_path).c_str());
        // However, that's not ideal. Python side is better for this.
    }

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

// Forward declaration for data rearrangement functions
std::vector<half> rearrange_ifmap_for_cpp(const std::vector<half>& flat_ifmap, int M, int K, int k_group_size);
std::vector<half> rearrange_weight_for_cpp(const std::vector<half>& flat_weight, int K, int N, int k_group_size, int n_group_size);
std::vector<float> rearrange_ofmap_from_cpp(const std::vector<float>& cpp_ofmap_data, int M, int N, int n_group_size);


int main(int argc, char* argv[]) {
    if (argc < 7) {
        std::cerr << "Usage: " << argv[0] << " <M> <K_GEMM> <N_GEMM> <ifmap_bin_file_path> <weight_bin_file_path> <ofmap_bin_file_path> [k_group_size_override] [n_group_size_override]" << std::endl;
        std::cerr << "Example: " << argv[0] << " 128 256 512 ../../simulator/op_val/gemm_fp16/data/ifmap_m128_k256.bin ../../simulator/op_val/gemm_fp16/data/weight_k256_n512.bin ../../simulator/op_val/gemm_fp16/data/cpp_gemm_fp16_m128_k256_n512.bin" << std::endl;
        return 1;
    }

    int M, K_GEMM, N_GEMM;
    std::string ifmap_bin_file, weight_bin_file, ofmap_cpp_bin_file;
    int k_group_size = 16; // Default, for half type
    int n_group_size = 32; // Default, for half type

    try {
        M = std::stoi(argv[1]);
        K_GEMM = std::stoi(argv[2]);
        N_GEMM = std::stoi(argv[3]);
        ifmap_bin_file = argv[4];
        weight_bin_file = argv[5];
        ofmap_cpp_bin_file = argv[6];
        if (argc > 7) {
            k_group_size = std::stoi(argv[7]);
        }
        if (argc > 8) {
            n_group_size = std::stoi(argv[8]);
        }
    } catch (const std::exception& e) {
        std::cerr << "Error parsing command line arguments: " << e.what() << std::endl;
        return 1;
    }

    if (K_GEMM % k_group_size != 0) {
        std::cerr << "K_GEMM (" << K_GEMM << ") must be divisible by k_group_size (" << k_group_size << ")" << std::endl;
        return 1;
    }
    if (N_GEMM % n_group_size != 0) {
        std::cerr << "N_GEMM (" << N_GEMM << ") must be divisible by n_group_size (" << n_group_size << ")" << std::endl;
        return 1;
    }

    const int k_group = K_GEMM / k_group_size;
    const int n_group = N_GEMM / n_group_size;

    std::cout << "GEMM C++ Simulation (Parameterized)" << std::endl;
    std::cout << "M=" << M << ", K=" << K_GEMM << ", N=" << N_GEMM << std::endl;
    std::cout << "k_group_size=" << k_group_size << ", n_group_size=" << n_group_size << std::endl;
    std::cout << "k_group (K_GEMM / k_group_size)=" << k_group << std::endl;
    std::cout << "n_group (N_GEMM / n_group_size)=" << n_group << std::endl;
    std::cout << "Ifmap path: " << ifmap_bin_file << std::endl;
    std::cout << "Weight path: " << weight_bin_file << std::endl;
    std::cout << "Ofmap path: " << ofmap_cpp_bin_file << std::endl;

    // --- Load flat input data from .bin files ---
    std::vector<half> ifmap_flat_data;
    std::vector<half> weight_flat_data;

    std::cout << "Loading ifmap from: " << ifmap_bin_file << std::endl;
    if (!load_tensor_from_bin(ifmap_bin_file, ifmap_flat_data, static_cast<size_t>(M) * K_GEMM)) {
        return 1;
    }
    std::cout << "Loaded ifmap_flat_data with " << ifmap_flat_data.size() << " elements." << std::endl;

    std::cout << "Loading weight from: " << weight_bin_file << std::endl;
    if (!load_tensor_from_bin(weight_bin_file, weight_flat_data, static_cast<size_t>(K_GEMM) * N_GEMM)) {
        return 1;
    }
    std::cout << "Loaded weight_flat_data with " << weight_flat_data.size() << " elements." << std::endl;

    // --- Rearrange flat data to C++ GemmSim expected layout ---
    std::vector<half> ifmap_cpp_layout_data = rearrange_ifmap_for_cpp(ifmap_flat_data, M, K_GEMM, k_group_size);
    std::vector<half> weight_cpp_layout_data = rearrange_weight_for_cpp(weight_flat_data, K_GEMM, N_GEMM, k_group_size, n_group_size);
    
    std::cout << "Rearranged ifmap_cpp_layout_data to size: " << ifmap_cpp_layout_data.size() << std::endl;
    std::cout << "Rearranged weight_cpp_layout_data to size: " << weight_cpp_layout_data.size() << std::endl;


    // --- Create compute_model::tensor::Tensor objects ---
    // Ifmap tensor shape: {k_group, M, k_group_size}
    compute_model::tensor::Tensor<half> ifmap_tensor(ifmap_cpp_layout_data, {k_group, M, k_group_size}, kHalf);
    // Weight tensor shape: {n_group, k_group, n_group_size, k_group_size}
    compute_model::tensor::Tensor<half> weight_tensor(weight_cpp_layout_data, {n_group, k_group, n_group_size, k_group_size}, kHalf);
    // Ofmap tensor shape for C++ sim: {n_group, M, n_group_size} (Output type half, Accumulator half)
    compute_model::tensor::Tensor<float> ofmap_tensor({n_group, M, n_group_size}, kFloat32);
    
    std::cout << "Created ifmap_tensor with shape: " << ifmap_tensor.shape_[0] << "x" << ifmap_tensor.shape_[1] << "x" << ifmap_tensor.shape_[2] << std::endl;
    std::cout << "Created weight_tensor with shape: " << weight_tensor.shape_[0] << "x" << weight_tensor.shape_[1] << "x" << weight_tensor.shape_[2] << "x" << weight_tensor.shape_[3] << std::endl;
    std::cout << "Created ofmap_tensor with shape: " << ofmap_tensor.shape_[0] << "x" << ofmap_tensor.shape_[1] << "x" << ofmap_tensor.shape_[2] << std::endl;


    // --- Instantiate and run GemmSim ---
    // For FP16 in, FP16 out: TYPE_A=half, TYPE_B=half, TYPE_ACCUMULATOR=half, TYPE_OUTPUT=half
    // The 'false' at the end is for DEBUG_ template parameter in GemmSim
    compute_model::gemm::GemmSim<0, false, false, false, half, half, float, float, false> gemm_simulator;

    int tile_m_param = M;
    int block_n_group_param = n_group; 
    int block_k_group_param = k_group;

    compute_model::gemm::GemmSim<0, false, false, false, half, half, float, float, false>::Arguments args_sim = {
        ofmap_tensor,
        ifmap_tensor,
        weight_tensor,
        tile_m_param,
        block_n_group_param,
        block_k_group_param
    };

    std::cout << "Running GemmSim..." << std::endl;
    gemm_simulator(args_sim);
    std::cout << "GemmSim finished." << std::endl;

    // --- Rearrange C++ ofmap data back to flat (M x N) layout ---
    std::vector<float> ofmap_flat_output_data = rearrange_ofmap_from_cpp(ofmap_tensor.data, M, N_GEMM, n_group_size);
    std::cout << "Rearranged ofmap_flat_output_data to size: " << ofmap_flat_output_data.size() << std::endl;


    // --- Save the flat C++ output to .bin file ---
    std::cout << "Saving C++ GEMM output to: " << ofmap_cpp_bin_file << std::endl;
    if (!save_tensor_to_bin(ofmap_cpp_bin_file, ofmap_flat_output_data)) {
        return 1;
    }
    std::cout << "C++ GEMM output saved successfully." << std::endl;

    return 0;
}


// --- Implementations for data rearrangement functions ---

// Rearranges flat Ifmap (M x K_GEMM, row-major) to C++ GemmSim expected layout ({k_group, M, k_group_size})
// K_GEMM = k_group * k_group_size
std::vector<half> rearrange_ifmap_for_cpp(const std::vector<half>& flat_ifmap, int M, int K_GEMM, int k_group_size) {
    if (K_GEMM % k_group_size != 0) {
        throw std::runtime_error("K_GEMM must be divisible by k_group_size for ifmap rearrangement.");
    }
    int k_group = K_GEMM / k_group_size;
    std::vector<half> cpp_layout_ifmap(static_cast<size_t>(k_group) * M * k_group_size);

    for (int m_idx = 0; m_idx < M; ++m_idx) {
        for (int k_gemm_idx = 0; k_gemm_idx < K_GEMM; ++k_gemm_idx) {
            int current_k_group = k_gemm_idx / k_group_size;
            int k_in_group_idx = k_gemm_idx % k_group_size;
            
            size_t src_idx = static_cast<size_t>(m_idx) * K_GEMM + k_gemm_idx;
            
            size_t dest_idx = static_cast<size_t>(current_k_group) * M * k_group_size + 
                              static_cast<size_t>(m_idx) * k_group_size + 
                              k_in_group_idx;
            
            if (src_idx < flat_ifmap.size() && dest_idx < cpp_layout_ifmap.size()) {
                cpp_layout_ifmap[dest_idx] = flat_ifmap[src_idx];
            } else {
                 throw std::runtime_error("Index out of bounds during ifmap rearrangement.");
            }
        }
    }
    return cpp_layout_ifmap;
}

// Rearranges flat Weight (K_GEMM x N_GEMM, row-major) to C++ GemmSim expected layout ({n_group, k_group, n_group_size, k_group_size})
// K_GEMM = k_group * k_group_size
// N_GEMM = n_group * n_group_size
std::vector<half> rearrange_weight_for_cpp(const std::vector<half>& flat_weight, int K_GEMM, int N_GEMM, int k_group_size, int n_group_size) {
    if (K_GEMM % k_group_size != 0) {
        throw std::runtime_error("K_GEMM must be divisible by k_group_size for weight rearrangement.");
    }
    if (N_GEMM % n_group_size != 0) {
        throw std::runtime_error("N_GEMM must be divisible by n_group_size for weight rearrangement.");
    }
    int k_group = K_GEMM / k_group_size;
    int n_group = N_GEMM / n_group_size;
    std::vector<half> cpp_layout_weight(static_cast<size_t>(n_group) * k_group * n_group_size * k_group_size);

    for (int k_gemm_idx = 0; k_gemm_idx < K_GEMM; ++k_gemm_idx) {
        for (int n_gemm_idx = 0; n_gemm_idx < N_GEMM; ++n_gemm_idx) {
            int current_k_group = k_gemm_idx / k_group_size;
            int k_in_group_idx = k_gemm_idx % k_group_size;
            int current_n_group = n_gemm_idx / n_group_size;
            int n_in_group_idx = n_gemm_idx % n_group_size;

            size_t src_idx = static_cast<size_t>(k_gemm_idx) * N_GEMM + n_gemm_idx;

            size_t dest_idx = static_cast<size_t>(current_n_group) * k_group * n_group_size * k_group_size +
                              static_cast<size_t>(current_k_group) * n_group_size * k_group_size +
                              static_cast<size_t>(n_in_group_idx) * k_group_size +
                              k_in_group_idx;
            
            if (src_idx < flat_weight.size() && dest_idx < cpp_layout_weight.size()) {
                cpp_layout_weight[dest_idx] = flat_weight[src_idx];
            } else {
                throw std::runtime_error("Index out of bounds during weight rearrangement.");
            }
        }
    }
    return cpp_layout_weight;
}

// Rearranges C++ GemmSim Ofmap ({n_group, M, n_group_size}, data in ofmap_tensor.data) to flat (M x N_GEMM, row-major)
// N_GEMM = n_group * n_group_size
std::vector<float> rearrange_ofmap_from_cpp(const std::vector<float>& cpp_ofmap_data, int M, int N_GEMM, int n_group_size) {
    if (N_GEMM % n_group_size != 0) {
        throw std::runtime_error("N_GEMM must be divisible by n_group_size for ofmap rearrangement.");
    }
    int n_group = N_GEMM / n_group_size;
    std::vector<float> flat_ofmap(static_cast<size_t>(M) * N_GEMM);

    size_t expected_cpp_data_size = static_cast<size_t>(n_group) * M * n_group_size;
    if (cpp_ofmap_data.size() != expected_cpp_data_size) {
         throw std::runtime_error("cpp_ofmap_data size mismatch. Expected: " + std::to_string(expected_cpp_data_size) + ", Got: " + std::to_string(cpp_ofmap_data.size()));
    }

    for (int m_idx = 0; m_idx < M; ++m_idx) {
        for (int n_gemm_idx = 0; n_gemm_idx < N_GEMM; ++n_gemm_idx) {
            int current_n_group = n_gemm_idx / n_group_size;
            int n_in_group_idx = n_gemm_idx % n_group_size;

            size_t src_idx = static_cast<size_t>(current_n_group) * M * n_group_size +
                             static_cast<size_t>(m_idx) * n_group_size +
                             n_in_group_idx;
            
            size_t dest_idx = static_cast<size_t>(m_idx) * N_GEMM + n_gemm_idx;

            if (src_idx < cpp_ofmap_data.size() && dest_idx < flat_ofmap.size()) {
                flat_ofmap[dest_idx] = cpp_ofmap_data[src_idx];
            } else {
                throw std::runtime_error("Index out of bounds during ofmap rearrangement.");
            }
        }
    }
    return flat_ofmap;
}