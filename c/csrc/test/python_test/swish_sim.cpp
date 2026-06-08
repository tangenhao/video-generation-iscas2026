#include "compute_model/common/tensor.h"
#include "compute_model/function/tensor_function.h" // For compute_model::function::swish
#include "common/type_utils.h" // For DType

#include <fstream>
#include <string>
#include <vector>
#include <iostream>
#include <stdexcept> // For std::runtime_error
#include <iomanip>   // For std::fixed, std::setprecision
#include <cstdlib>   // For atoi

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

int main(int argc, char* argv[]) {
    if (argc != 6) {
        std::cerr << "Usage: " << argv[0] << " <oc_group> <num_data> <oc_group_size> <input_bin_path> <output_bin_path>" << std::endl;
        return 1;
    }

    // Parse command-line arguments
    const int oc_group_swish = std::atoi(argv[1]);
    const int num_data_swish = std::atoi(argv[2]); // Represents h*w or seq_len
    const int oc_group_size_swish = std::atoi(argv[3]);
    const std::string input_path = argv[4];
    const std::string output_path = argv[5];

    if (oc_group_swish <= 0 || num_data_swish <= 0 || oc_group_size_swish <= 0) {
        std::cerr << "Error: Dimensions must be positive." << std::endl;
        return 1;
    }

    std::cout << "Swish C++ Simulation (FP32)" << std::endl;
    std::cout << "Parsed params: oc_group=" << oc_group_swish 
              << ", num_data=" << num_data_swish 
              << ", oc_group_size=" << oc_group_size_swish << std::endl;
    
    std::vector<int> shape = {oc_group_swish, num_data_swish, oc_group_size_swish};
    DType dtype = DType::kFloat32;

    std::cout << "\\nFile paths:" << std::endl;
    std::cout << "  Input file: " << input_path << std::endl;
    std::cout << "  Output file: " << output_path << std::endl;

    try {
        // 1. Load input tensor
        std::cout << "\\nLoading input tensor from " << input_path << "..." << std::endl;
        std::vector<float> input_data_vec;
        size_t num_input_elements = static_cast<size_t>(oc_group_swish) * num_data_swish * oc_group_size_swish;
        if (!load_tensor_from_bin<float>(input_path, input_data_vec, num_input_elements)) {
            std::cerr << "Failed to load input tensor." << std::endl;
            return 1;
        }
        compute_model::tensor::Tensor<float> input_tensor(input_data_vec, shape, dtype);
        std::cout << "Input tensor loaded successfully. Shape: {" << input_tensor.shape()[0] << ", "
                  << input_tensor.shape()[1] << ", " << input_tensor.shape()[2] << "}" << std::endl;

        // --- Swish Computation ---
        std::cout << "\\nCalling compute_model::function::swish function..." << std::endl;
        auto output_tensor = compute_model::function::swish<float>(input_tensor);
        std::cout << "Swish computation using library function complete." << std::endl;
        std::cout << "Output tensor shape: {" << output_tensor.shape()[0] << ", "
                  << output_tensor.shape()[1] << ", " << output_tensor.shape()[2] << "}" << std::endl;

        // 3. Save output tensor
        std::cout << "\\nSaving output tensor to " << output_path << "..." << std::endl;
        std::vector<float> output_data_vec;
        const float* output_ptr = output_tensor.data_ptr();
        size_t num_output_elements = output_tensor.numel();

        if (output_ptr && num_output_elements > 0) {
            output_data_vec.assign(output_ptr, output_ptr + num_output_elements);
        } else if (num_output_elements == 0) {
             std::cout << "Output tensor is empty (0 elements)." << std::endl;
        } else { 
            std::cerr << "Output tensor data is null or invalid despite having non-zero elements." << std::endl;
            return 1;
        }

        if (!save_tensor_to_bin<float>(output_path, output_data_vec)) {
            std::cerr << "Failed to save output tensor." << std::endl;
            return 1;
        }
        std::cout << "Swish C++ simulation complete. Output saved to " << output_path << std::endl;

    } catch (const std::runtime_error& e) {
        std::cerr << "Runtime Error: " << e.what() << std::endl;
        return 1;
    } catch (...) {
        std::cerr << "An unknown error occurred." << std::endl;
        return 1;
    }

    return 0;
} 