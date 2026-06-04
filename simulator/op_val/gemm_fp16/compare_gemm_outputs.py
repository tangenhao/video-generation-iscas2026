import numpy as np
import os
import sys
import torch # Still used by plot_utils for cosine similarity if not removed there
import argparse # Import argparse
import json # Import json

# Add common_utils to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../common_utils')))
from data_gen import load_tensor_from_bin
from plot_utils import (
    calculate_numerical_metrics,
    print_numerical_metrics_report,
    plot_scatter_comparison,
    plot_error_histogram,
    generate_outlier_analysis_and_plots
)

# Ensure the charts directory exists
# CHARTS_DIR = os.path.join(os.path.dirname(__file__), 'results', 'charts')
# os.makedirs(CHARTS_DIR, exist_ok=True) # Will be handled by main

def main():
    parser = argparse.ArgumentParser(description="Compare GEMM outputs (PyTorch vs C++)")
    parser.add_argument("--M", type=int, required=True, help="M dimension")
    parser.add_argument("--K", type=int, required=True, help="K dimension")
    parser.add_argument("--N", type=int, required=True, help="N dimension")
    parser.add_argument("--ref_fp16_path", type=str, required=True, help="Path to PyTorch FP16 reference output .bin file")
    parser.add_argument("--cpp_fp16_path", type=str, required=True, help="Path to C++ (DUT) FP16 output .bin file")
    parser.add_argument("--ref_fp32_path", type=str, help="Optional: Path to PyTorch FP32 reference output .bin file")
    parser.add_argument("--charts_dir", type=str, default=os.path.join(os.path.dirname(__file__), 'results', 'charts'), help="Directory to save plots")
    parser.add_argument("--epsilon", type=float, default=1e-7, help="Epsilon for relative error calculation")
    parser.add_argument("--output_accuracy_json", type=str, help="Path to save the accuracy metrics JSON file.")
    parser.add_argument("--outlier_abs_threshold", type=float, default=1e-3, help="Absolute error threshold for outlier detection")
    parser.add_argument("--outlier_rel_threshold", type=float, default=0.01, help="Relative error threshold for outlier detection")
    parser.add_argument("--enable_outlier_analysis", action="store_true", help="Enable detailed outlier analysis and visualization")

    args = parser.parse_args()

    os.makedirs(args.charts_dir, exist_ok=True)

    output_shape = (args.M, args.N)
    output_dtype_pytorch_fp16 = np.float16
    # Assuming C++ output is FP16 (it might be saved as FP32 and loaded as such, then cast)
    # For the primary comparison, we expect both to be evaluated at FP16.
    # The actual dtype of the C++ file will be used for loading, then cast to FP16.
    cpp_output_load_dtype = np.float32 # Default assumption, gemm_sim.cpp saves accumulator type (float)

    print(f"Comparing PyTorch (ref_fp16) output: {args.ref_fp16_path}")
    print(f"With C++ (DUT_fp16) output:         {args.cpp_fp16_path}")

    # Load the reference tensor (from PyTorch FP16)
    if not os.path.exists(args.ref_fp16_path):
        print(f"Error: Reference FP16 output file not found: {args.ref_fp16_path}")
        sys.exit(1)
    tensor_ref_fp16 = load_tensor_from_bin(args.ref_fp16_path, dtype=output_dtype_pytorch_fp16, shape=output_shape)

    # Load the Device Under Test tensor (from C++ simulation, assumed FP16 output)
    if not os.path.exists(args.cpp_fp16_path):
        print(f"Error: C++ output file not found: {args.cpp_fp16_path}")
        sys.exit(1)
    # Try to determine actual dtype from file or assume FP32 then cast.
    # For gemm_sim.cpp, output is float, so load as float32 then cast to float16.
    tensor_cpp_loaded = load_tensor_from_bin(args.cpp_fp16_path, dtype=cpp_output_load_dtype, shape=output_shape)
    tensor_cpp_fp16 = tensor_cpp_loaded.astype(np.float16) # Cast to fp16 for comparison

    print(f"Loaded reference FP16 tensor shape: {tensor_ref_fp16.shape}, dtype: {tensor_ref_fp16.dtype}")
    print(f"Loaded C++ tensor (loaded as {tensor_cpp_loaded.dtype}, cast to {tensor_cpp_fp16.dtype}) shape: {tensor_cpp_fp16.shape}")

    # --- Primary Comparison: PyTorch FP16 ref vs C++ FP16 output ---
    print("\n--- Comparing PyTorch FP16 Reference vs C++ FP16 Output ---")
    
    # Enable outlier analysis if requested
    outlier_abs_threshold = args.outlier_abs_threshold if args.enable_outlier_analysis else None
    outlier_rel_threshold = args.outlier_rel_threshold if args.enable_outlier_analysis else None
    outlier_output_dir = args.charts_dir if args.enable_outlier_analysis else None
    
    metrics_fp16 = calculate_numerical_metrics(
        tensor_ref_fp16, tensor_cpp_fp16, 
        epsilon_for_relative_error=args.epsilon,
        outlier_absolute_threshold=outlier_abs_threshold,
        outlier_relative_threshold=outlier_rel_threshold,
        output_dir=outlier_output_dir
    )
    print_numerical_metrics_report(metrics_fp16)

    if args.output_accuracy_json:
        accuracy_data = {
            "op_type": "gemm",
            "precision_dut": "fp16", # Assuming DUT (C++ output) is intended to be FP16
            "precision_ref": "fp16",
            "dimensions": {"M": args.M, "K": args.K, "N": args.N},
            "metrics": {
                "max_absolute_error": metrics_fp16["max_absolute_error"],
                "mean_absolute_error": metrics_fp16["mae"],
                "max_relative_error": metrics_fp16["max_relative_error"],
                "mean_relative_error": metrics_fp16["mean_relative_error"],
                "cosine_similarity": metrics_fp16["cosine_similarity"],
                "mse": metrics_fp16["mse"]
            }
        }
        # Ensure the directory for the JSON file exists
        json_output_dir = os.path.dirname(args.output_accuracy_json)
        if json_output_dir:
            os.makedirs(json_output_dir, exist_ok=True)
        
        with open(args.output_accuracy_json, 'w') as f:
            json.dump(accuracy_data, f, indent=4)
        print(f"Accuracy JSON saved to: {args.output_accuracy_json}")

    plot_scatter_comparison(
        tensor_cpp_fp16, 
        tensor_ref_fp16, 
        title="GEMM FP16: C++ Output vs. PyTorch Reference",
        save_path=os.path.join(args.charts_dir, "gemm_fp16_scatter_comparison.png")
    )
    print(f"Scatter comparison plot saved to {os.path.join(args.charts_dir, 'gemm_fp16_scatter_comparison.png')}")

    plot_error_histogram(
        metrics_fp16['absolute_error_array'], 
        title="GEMM FP16: Absolute Error Distribution (Ref vs DUT)",
        save_path=os.path.join(args.charts_dir, "gemm_fp16_abs_error_hist.png")
    )
    print(f"Absolute error histogram saved to {os.path.join(args.charts_dir, 'gemm_fp16_abs_error_hist.png')}")

    plot_error_histogram(
        metrics_fp16['relative_error_array'], 
        title=f"GEMM FP16: Relative Error Distribution (Ref vs DUT, eps={metrics_fp16['epsilon_for_relative_error']:.1e})",
        save_path=os.path.join(args.charts_dir, "gemm_fp16_rel_error_hist.png")
    )
    print(f"Relative error histogram saved to {os.path.join(args.charts_dir, 'gemm_fp16_rel_error_hist.png')}")

    # --- Optional Comparison: PyTorch FP32 ref vs C++ FP16 output (cast to FP32) ---
    if args.ref_fp32_path:
        if not os.path.exists(args.ref_fp32_path):
            print(f"\nWarning: PyTorch FP32 reference file specified but not found: {args.ref_fp32_path}")
        else:
            print("\n--- Comparing PyTorch FP32 Reference vs C++ FP16 Output (cast to FP32) ---")
            tensor_ref_fp32 = load_tensor_from_bin(args.ref_fp32_path, dtype=np.float32, shape=output_shape)
            print(f"Loaded PyTorch FP32 reference tensor shape: {tensor_ref_fp32.shape}, dtype: {tensor_ref_fp32.dtype}")
            
            # Cast C++ FP16 output to FP32 for this comparison
            tensor_cpp_fp16_as_fp32 = tensor_cpp_fp16.astype(np.float32)
            
            metrics_fp32_ref = calculate_numerical_metrics(tensor_ref_fp32, tensor_cpp_fp16_as_fp32, epsilon_for_relative_error=args.epsilon)
            print_numerical_metrics_report(metrics_fp32_ref)

            plot_scatter_comparison(
                tensor_cpp_fp16_as_fp32, 
                tensor_ref_fp32, 
                title="GEMM C++FP16out(->FP32) vs. PyTorch FP32 Reference",
                save_path=os.path.join(args.charts_dir, "gemm_cpp_fp16_to_fp32_vs_pytorch_fp32_scatter.png")
            )
            print(f"Scatter plot saved to {os.path.join(args.charts_dir, 'gemm_cpp_fp16_to_fp32_vs_pytorch_fp32_scatter.png')}")

            plot_error_histogram(
                metrics_fp32_ref['absolute_error_array'], 
                title="GEMM C++FP16out(->FP32) vs. PyTorch FP32 Ref: Abs Error",
                save_path=os.path.join(args.charts_dir, "gemm_cpp_fp16_to_fp32_vs_pytorch_fp32_abs_err_hist.png")
            )
            print(f"Absolute error histogram saved to {os.path.join(args.charts_dir, 'gemm_cpp_fp16_to_fp32_vs_pytorch_fp32_abs_err_hist.png')}")

            plot_error_histogram(
                metrics_fp32_ref['relative_error_array'], 
                title=f"GEMM C++FP16out(->FP32) vs. PyTorch FP32 Ref: Rel Error (eps={metrics_fp32_ref['epsilon_for_relative_error']:.1e})",
                save_path=os.path.join(args.charts_dir, "gemm_cpp_fp16_to_fp32_vs_pytorch_fp32_rel_err_hist.png")
            )
            print(f"Relative error histogram saved to {os.path.join(args.charts_dir, 'gemm_cpp_fp16_to_fp32_vs_pytorch_fp32_rel_err_hist.png')}")
    else:
        print("\nNote: PyTorch FP32 reference path not provided, skipping comparison against PyTorch FP32 reference.")

    print("\nComparison script finished.")

if __name__ == '__main__':
    main() 