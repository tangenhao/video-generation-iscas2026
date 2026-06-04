import numpy as np
import os
import subprocess
import sys
import argparse # Import argparse
import json # Import json

# Add common_utils to Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
common_utils_path = os.path.join(current_dir, '..', 'common_utils')
sys.path.append(common_utils_path)

try:
    import data_gen
    from plot_utils import (
        calculate_numerical_metrics,
        print_numerical_metrics_report,
        plot_scatter_comparison,
        plot_error_histogram,
        generate_outlier_analysis_and_plots
    )
except ImportError as e:
    print(f"Failed to import from common_utils ({common_utils_path}): {e}. Ensure it exists and is a valid Python module.")
    sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Compare Swish FP32 outputs (PyTorch vs C++)")
    parser.add_argument("--oc_group", type=int, required=True, help="oc_group (batch-like) dimension")
    parser.add_argument("--num_data", type=int, required=True, help="Number of data elements (e.g., seq_len or H*W)")
    parser.add_argument("--oc_group_size", type=int, required=True, help="Size of oc_group (feature dimension)")
    parser.add_argument("--ref_path", type=str, required=True, help="Path to PyTorch reference output .bin file")
    parser.add_argument("--cpp_output_path", type=str, required=True, help="Path where C++ simulator has saved its output, and this script will load from")
    parser.add_argument("--charts_dir", type=str, default=os.path.join(os.path.dirname(__file__), 'results', 'charts'), help="Directory to save plots")
    parser.add_argument("--epsilon", type=float, default=1e-5, help="Epsilon for relative error calculation")
    parser.add_argument("--output_accuracy_json", type=str, help="Path to save the accuracy metrics JSON file.")
    parser.add_argument("--outlier_abs_threshold", type=float, default=1e-3, help="Absolute error threshold for outlier detection")
    parser.add_argument("--outlier_rel_threshold", type=float, default=0.01, help="Relative error threshold for outlier detection")
    parser.add_argument("--enable_outlier_analysis", action="store_true", help="Enable detailed outlier analysis and visualization")

    args = parser.parse_args()
    
    shape = (args.oc_group, args.num_data, args.oc_group_size)
    dtype = np.float32

    os.makedirs(args.charts_dir, exist_ok=True)
    # os.makedirs(os.path.dirname(args.cpp_output_path), exist_ok=True) # Commenting out, should be handled by main runner

    print(f"--- Swish (FP32) Output Comparison ---")
    print(f"Shape: {shape}, Dtype: {dtype}")
    print(f"Using dimensions: oc_group={args.oc_group}, num_data={args.num_data}, oc_group_size={args.oc_group_size}")
    print(f"PyTorch reference output: {args.ref_path}")
    # print(f"C++ executable: {args.cpp_exe_path}") # No longer needed
    # print(f"C++ input file: {args.cpp_input_path}") # No longer needed
    print(f"C++ output file to load: {args.cpp_output_path}") # Clarified print

    # --- Step 1: Ensure Python reference output exists ---
    if not os.path.exists(args.ref_path):
        print(f"\\nError: Python reference output file not found: {args.ref_path}")
        sys.exit(1)
    
    try:
        ref_output_tensor = data_gen.load_tensor_from_bin(args.ref_path, dtype, shape)
        print(f"\\nSuccessfully loaded Python reference output from: {args.ref_path}")
    except Exception as e:
        print(f"Error loading Python reference output: {e}")
        sys.exit(1)

    # --- Step 3: Load C++ simulation output ---
    # Renaming this to Step 2 as the original Step 2 is removed.
    print("\n--- Loading Pre-computed C++ Simulation Output ---")
    if not os.path.exists(args.cpp_output_path):
        print(f"\\nError: C++ output file not found (expected to be pre-generated): {args.cpp_output_path}") # Clarified error message
        sys.exit(1)
    
    try:
        cpp_output_tensor = data_gen.load_tensor_from_bin(args.cpp_output_path, dtype, shape)
        print(f"\\nSuccessfully loaded C++ output from: {args.cpp_output_path}")
    except Exception as e:
        print(f"Error loading C++ output: {e}")
        sys.exit(1)

    # --- Step 4: Compare outputs ---
    print("\\n--- Numerical Comparison Metrics ---")
    metrics = calculate_numerical_metrics(
        ref_output_tensor, cpp_output_tensor, 
        epsilon_for_relative_error=args.epsilon,
        enable_outlier_analysis=args.enable_outlier_analysis,
        outlier_abs_threshold=args.outlier_abs_threshold,
        outlier_rel_threshold=args.outlier_rel_threshold,
        charts_dir=args.charts_dir
    )
    print_numerical_metrics_report(metrics)

    if args.output_accuracy_json:
        accuracy_data = {
            "op_type": "swish",
            "precision_dut": "fp32",
            "precision_ref": "fp32",
            "dimensions": {
                "oc_group": args.oc_group,
                "num_data": args.num_data,
                "oc_group_size": args.oc_group_size
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
        cpp_output_tensor, 
        ref_output_tensor, 
        title="Swish FP32: C++ Output vs. PyTorch Reference",
        save_path=os.path.join(args.charts_dir, "swish_fp32_scatter_comparison.png")
    )
    print(f"Scatter comparison plot saved to {os.path.join(args.charts_dir, 'swish_fp32_scatter_comparison.png')}")

    plot_error_histogram(
        metrics['absolute_error_array'], 
        title="Swish FP32: Absolute Error Distribution",
        save_path=os.path.join(args.charts_dir, "swish_fp32_abs_error_hist.png")
    )
    print(f"Absolute error histogram saved to {os.path.join(args.charts_dir, 'swish_fp32_abs_error_hist.png')}")

    plot_error_histogram(
        metrics['relative_error_array'], 
        title=f"Swish FP32: Relative Error Distribution (epsilon={metrics['epsilon_for_relative_error']:.1e})",
        save_path=os.path.join(args.charts_dir, "swish_fp32_rel_error_hist.png")
    )
    print(f"Relative error histogram saved to {os.path.join(args.charts_dir, 'swish_fp32_rel_error_hist.png')}")

    if metrics['any_nan_dut'] or metrics['any_inf_dut'] or metrics['any_nan_ref'] or metrics['any_inf_ref']:
        print("\\nWarnings regarding NaNs/Infs (see full report above).")

    print("\\nSwish comparison script finished.")

if __name__ == "__main__":
    main() 