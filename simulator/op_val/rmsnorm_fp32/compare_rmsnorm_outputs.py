import numpy as np
import os
import sys
import torch # For cosine similarity
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
# os.makedirs(CHARTS_DIR, exist_ok=True) # Handled in main

def main():
    parser = argparse.ArgumentParser(description="Compare RMSNorm FP32 outputs (PyTorch vs C++)")
    parser.add_argument("--seq_len", type=int, required=True, help="Sequence length dimension")
    parser.add_argument("--d_model", type=int, required=True, help="Model dimension (oc_group * oc_group_size)")
    parser.add_argument("--oc_group_size", type=int, required=True, help="Size of oc_group (feature dimension per group)")
    parser.add_argument("--ref_path", type=str, required=True, help="Path to PyTorch reference output .bin file")
    parser.add_argument("--cpp_output_path", type=str, required=True, help="Path to C++ (DUT) output .bin file")
    parser.add_argument("--charts_dir", type=str, default=os.path.join(os.path.dirname(__file__), 'results', 'charts'), help="Directory to save plots")
    parser.add_argument("--epsilon", type=float, default=1e-5, help="Epsilon for relative error calculation (and for RMSNorm itself if it were passed to C++ side)")
    parser.add_argument("--output_accuracy_json", type=str, help="Path to save the accuracy metrics JSON file.")
    parser.add_argument("--outlier_abs_threshold", type=float, default=1e-3, help="Absolute error threshold for outlier detection")
    parser.add_argument("--outlier_rel_threshold", type=float, default=0.01, help="Relative error threshold for outlier detection")
    parser.add_argument("--enable_outlier_analysis", action="store_true", help="Enable detailed outlier analysis and visualization")

    args = parser.parse_args()

    os.makedirs(args.charts_dir, exist_ok=True)

    if args.d_model % args.oc_group_size != 0:
        parser.error("d_model must be divisible by oc_group_size")
    oc_group_rmsnorm = args.d_model // args.oc_group_size
    
    output_shape = (oc_group_rmsnorm, args.seq_len, args.oc_group_size)
    output_dtype = np.float32 # Both PyTorch and C++ use FP32 for RMSNorm

    print(f"Comparing PyTorch (ref) output: {args.ref_path}")
    print(f"With C++ (DUT) output:         {args.cpp_output_path}")

    # Load the reference tensor (from PyTorch)
    if not os.path.exists(args.ref_path):
        print(f"Error: Reference output file not found: {args.ref_path}")
        sys.exit(1)
    tensor_ref = load_tensor_from_bin(args.ref_path, dtype=output_dtype, shape=output_shape)

    # Load the Device Under Test tensor (from C++ simulation)
    if not os.path.exists(args.cpp_output_path):
        print(f"Error: C++ output file not found: {args.cpp_output_path}")
        sys.exit(1)
    tensor_cpp = load_tensor_from_bin(args.cpp_output_path, dtype=output_dtype, shape=output_shape)

    print(f"Loaded reference tensor shape: {tensor_ref.shape}, dtype: {tensor_ref.dtype}")
    print(f"Loaded C++ tensor shape:     {tensor_cpp.shape}, dtype: {tensor_cpp.dtype}")

    # Calculate numerical metrics (with optional outlier analysis)
    # Enable outlier analysis if requested
    outlier_abs_threshold = args.outlier_abs_threshold if args.enable_outlier_analysis else None
    outlier_rel_threshold = args.outlier_rel_threshold if args.enable_outlier_analysis else None
    outlier_output_dir = args.charts_dir if args.enable_outlier_analysis else None
    
    metrics = calculate_numerical_metrics(
        tensor_ref, tensor_cpp, 
        epsilon_for_relative_error=args.epsilon,
        outlier_absolute_threshold=outlier_abs_threshold,
        outlier_relative_threshold=outlier_rel_threshold,
        output_dir=outlier_output_dir
    )
    print_numerical_metrics_report(metrics)

    if args.output_accuracy_json:
        accuracy_data = {
            "op_type": "rmsnorm",
            "precision_dut": "fp32",
            "precision_ref": "fp32",
            "dimensions": {
                "oc_group": oc_group_rmsnorm,
                "seq_len": args.seq_len,
                "oc_group_size": args.oc_group_size,
                "d_model": args.d_model
            },
            "metrics": {
                "max_absolute_error": metrics["max_absolute_error"],
                "mean_absolute_error": metrics["mae"],
                "max_relative_error": metrics["max_relative_error"],
                "mean_relative_error": metrics["mean_relative_error"],
                "cosine_similarity": metrics["cosine_similarity"],
                "mse": metrics["mse"]
            }
        }
        json_output_dir = os.path.dirname(args.output_accuracy_json)
        if json_output_dir:
            os.makedirs(json_output_dir, exist_ok=True)
        with open(args.output_accuracy_json, 'w') as f:
            json.dump(accuracy_data, f, indent=4)
        print(f"Accuracy JSON saved to: {args.output_accuracy_json}")

    # Plotting
    plot_scatter_comparison(
        tensor_cpp, 
        tensor_ref, 
        title="RMSNorm FP32: C++ Output vs. PyTorch Reference",
        save_path=os.path.join(args.charts_dir, "rmsnorm_fp32_scatter_comparison.png")
    )
    print(f"Scatter comparison plot saved to {os.path.join(args.charts_dir, 'rmsnorm_fp32_scatter_comparison.png')}")

    plot_error_histogram(
        metrics['absolute_error_array'], 
        title="RMSNorm FP32: Absolute Error Distribution",
        save_path=os.path.join(args.charts_dir, "rmsnorm_fp32_abs_error_hist.png")
    )
    print(f"Absolute error histogram saved to {os.path.join(args.charts_dir, 'rmsnorm_fp32_abs_error_hist.png')}")

    plot_error_histogram(
        metrics['relative_error_array'], 
        title=f"RMSNorm FP32: Relative Error Distribution (epsilon={metrics['epsilon_for_relative_error']:.1e})",
        save_path=os.path.join(args.charts_dir, "rmsnorm_fp32_rel_error_hist.png")
    )
    print(f"Relative error histogram saved to {os.path.join(args.charts_dir, 'rmsnorm_fp32_rel_error_hist.png')}")

    print("\nRMSNorm comparison script finished.")

if __name__ == '__main__':
    main() 