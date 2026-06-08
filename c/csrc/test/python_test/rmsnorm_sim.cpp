#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <stdexcept> // For std::runtime_error
#include <cmath>     // For fabs, pow, sqrt if any direct math is needed (though rmsnorm.h handles it)
#include <cstdlib>   // For atoi, atof

// NPUGen3 compute model headers
#include "compute_model/common/tensor.h"
#include "compute_model/transformer/rmsnorm.h" // RMSNorm specific header
// Note: fp16.h is not strictly needed here as we are doing FP32 RMSNorm

// Helper function to load tensor data from a .bin file (copied from gemm_sim.cpp for now)
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

// Helper function to save tensor data to a .bin file (copied from gemm_sim.cpp for now)
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

int main(int argc, char* argv[]) {
    if (argc != 8) {
        std::cerr << "Usage: " << argv[0] << " <seq_len> <d_model> <oc_group_size> <epsilon> <input_bin_path> <gamma_bin_path> <output_bin_path>" << std::endl;
        return 1;
    }

    // Parse command-line arguments
    const int seq_len_rmsnorm = std::atoi(argv[1]);
    const int d_model_rmsnorm = std::atoi(argv[2]);
    const int oc_group_size_rmsnorm = std::atoi(argv[3]);
    const float epsilon = std::atof(argv[4]);
    const std::string input_bin_file = argv[5];
    const std::string gamma_bin_file = argv[6];
    const std::string output_cpp_bin_file = argv[7];

    if (d_model_rmsnorm <= 0 || seq_len_rmsnorm <= 0 || oc_group_size_rmsnorm <= 0) {
        std::cerr << "Error: Dimensions must be positive." << std::endl;
        return 1;
    }
    if (epsilon <= 0) {
        std::cerr << "Error: Epsilon must be positive." << std::endl;
        return 1;
    }

    if (d_model_rmsnorm % oc_group_size_rmsnorm != 0) {
        std::cerr << "d_model_rmsnorm (" << d_model_rmsnorm 
                  << ") must be divisible by oc_group_size_rmsnorm (" << oc_group_size_rmsnorm << ")" << std::endl;
        return 1;
    }
    const int oc_group_rmsnorm = d_model_rmsnorm / oc_group_size_rmsnorm;

    std::cout << "RMSNorm C++ Simulation (FP32)" << std::endl;
    std::cout << "Parsed params: seq_len=" << seq_len_rmsnorm << ", d_model=" << d_model_rmsnorm 
              << ", oc_group_size=" << oc_group_size_rmsnorm << ", oc_group=" << oc_group_rmsnorm
              << ", epsilon=" << epsilon << std::endl;
    std::cout << "Input file: " << input_bin_file << std::endl;
    std::cout << "Gamma file: " << gamma_bin_file << std::endl;
    std::cout << "Output file: " << output_cpp_bin_file << std::endl;

    // --- Load flat input data from .bin files ---
    std::vector<float> input_flat_data;
    std::vector<float> gamma_flat_data;

    std::cout << "Loading input from: " << input_bin_file << std::endl;
    size_t expected_input_elements = static_cast<size_t>(oc_group_rmsnorm) * seq_len_rmsnorm * oc_group_size_rmsnorm;
    if (!load_tensor_from_bin(input_bin_file, input_flat_data, expected_input_elements)) {
        std::cerr << "Failed to load input tensor." << std::endl;
        return 1;
    }
    std::cout << "Loaded input_flat_data with " << input_flat_data.size() << " elements." << std::endl;

    std::cout << "Loading gamma from: " << gamma_bin_file << std::endl;
    size_t expected_gamma_elements = static_cast<size_t>(d_model_rmsnorm);
    if (!load_tensor_from_bin(gamma_bin_file, gamma_flat_data, expected_gamma_elements)) {
        std::cerr << "Failed to load gamma tensor." << std::endl;
        return 1;
    }
    std::cout << "Loaded gamma_flat_data with " << gamma_flat_data.size() << " elements." << std::endl;

    // --- Create compute_model::tensor::Tensor objects ---
    // Input tensor shape: {oc_group, seq_len, oc_group_size}
    compute_model::tensor::Tensor<float> input_tensor(input_flat_data, 
                                                    {oc_group_rmsnorm, seq_len_rmsnorm, oc_group_size_rmsnorm}, 
                                                    kFloat32);
    // Gamma tensor shape: {d_model} which is {oc_group * oc_group_size}
    // The rmsnorm function expects gamma as a 1D tensor of size d_model implicitly, or {oc_group, oc_group_size} for indexing.
    // For simplicity with the rmsnorm function, providing it as {d_model_rmsnorm} is fine, as it's indexed flatly.
    // However, the function comment and access pattern gamma[oc_iter * oc_group_size + oc_inner_iter] suggest
    // that if gamma is passed as a 1D tensor, its elements must correspond to the flattened {oc_group, oc_group_size} view.
    // Since our Python script saves gamma as (d_model,), passing it as {d_model_rmsnorm} is most direct.
    // The C++ function apply_rmsnorm internally calculates d_model and then accesses gamma[oc_iter * oc_group_size + oc_inner_iter]
    // which effectively means it expects gamma to be laid out as if it were {oc_group, oc_group_size} then flattened, or just {d_model}. 
    // This is consistent with gamma having d_model elements.
    compute_model::tensor::Tensor<float> gamma_tensor(gamma_flat_data, 
                                                    {d_model_rmsnorm}, // Shape (d_model)
                                                    kFloat32);

    std::cout << "Created input_tensor with shape: " << input_tensor.shape_[0] << "x" << input_tensor.shape_[1] << "x" << input_tensor.shape_[2] << std::endl;
    std::cout << "Created gamma_tensor with shape: " << gamma_tensor.shape_[0] << std::endl;

    // --- Instantiate and run RMSNorm --- 
    // The rmsnorm.h provides a convenient wrapper `rmsnorm(...)` that returns the output tensor.
    std::cout << "Running RMSNorm (FP32)..." << std::endl;
    compute_model::tensor::Tensor<float> output_tensor = 
        compute_model::transformer::rmsnorm::rmsnorm(input_tensor, gamma_tensor, epsilon);
    std::cout << "RMSNorm finished." << std::endl;

    std::cout << "Output tensor shape: " << output_tensor.shape_[0] << "x" << output_tensor.shape_[1] << "x" << output_tensor.shape_[2] << std::endl;
    std::cout << "Output tensor num elements: " << output_tensor.numel() << std::endl;

    // --- Save the C++ output to .bin file ---
    // The output_tensor.data is already a std::vector<float> in the correct flat row-major order
    // corresponding to its shape {oc_group, seq_len, oc_group_size}.
    std::cout << "Saving C++ RMSNorm output to: " << output_cpp_bin_file << std::endl;
    if (!save_tensor_to_bin(output_cpp_bin_file, output_tensor.data)) {
        std::cerr << "Failed to save C++ RMSNorm output." << std::endl;
        return 1;
    }
    std::cout << "C++ RMSNorm output saved successfully." << std::endl;

    return 0;
} 