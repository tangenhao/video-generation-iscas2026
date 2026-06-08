import numpy as np
import os
import sys
import torch # For cosine similarity
import argparse
import json

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

def main():
    parser = argparse.ArgumentParser(description="Compare Llama Block outputs (PyTorch vs C++)")
    parser.add_argument("--seq_len", type=int, required=True, help="Sequence length")
    parser.add_argument("--d_model", type=int, required=True, help="Model dimension")
    parser.add_argument("--intermediate_size", type=int, required=True, help="MLP intermediate size")
    parser.add_argument("--head_num", type=int, required=True, help="Number of attention heads")
    parser.add_argument("--ref_path", type=str, required=True, help="Path to PyTorch reference output .bin file")
    parser.add_argument("--cpp_output_path", type=str, required=True, help="Path to C++ (DUT) output .bin file")
    parser.add_argument("--charts_dir", type=str, default=os.path.join(os.path.dirname(__file__), 'results', 'charts'), help="Directory to save plots")
    parser.add_argument("--epsilon", type=float, default=1e-6, help="Epsilon for relative error calculation")
    parser.add_argument("--output_accuracy_json", type=str, help="Path to save the accuracy metrics JSON file.")
    parser.add_argument("--outlier_abs_threshold", type=float, default=1e-3, help="Absolute error threshold for outlier detection")
    parser.add_argument("--outlier_rel_threshold", type=float, default=0.01, help="Relative error threshold for outlier detection")
    parser.add_argument("--enable_outlier_analysis", action="store_true", help="Enable detailed outlier analysis and visualization")

    args = parser.parse_args()

    os.makedirs(args.charts_dir, exist_ok=True)

    # Calculate dimensions
    n_group_size = 32  # FP32 parallelism
    oc_group = args.d_model // n_group_size
    
    if args.d_model % n_group_size != 0:
        parser.error("d_model must be divisible by n_group_size (32)")
    
    output_shape = (oc_group, args.seq_len, n_group_size)
    output_dtype = np.float32  # Both PyTorch and C++ output FP32

    print(f"Comparing Llama Block outputs:")
    print(f"PyTorch (ref) output: {args.ref_path}")
    print(f"C++ (DUT) output:     {args.cpp_output_path}")
    print(f"Expected output shape: {output_shape}")

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
    print(f"Loaded C++ tensor shape:       {tensor_cpp.shape}, dtype: {tensor_cpp.dtype}")

    # Calculate numerical metrics (with optional outlier analysis)
    print("\n" + "="*50)
    print("NUMERICAL ACCURACY ANALYSIS")
    print("="*50)
    
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

    # Additional analysis for Llama Block (complex composite operator)
    print("\n" + "-"*50)
    print("LLAMA BLOCK SPECIFIC ANALYSIS")
    print("-"*50)
    
    # Per-token analysis (average across feature dimensions)
    token_ref_means = np.mean(tensor_ref, axis=(0, 2))  # [seq_len]
    token_cpp_means = np.mean(tensor_cpp, axis=(0, 2))  # [seq_len]
    token_abs_errors = np.abs(token_ref_means - token_cpp_means)
    
    print(f"Per-token mean absolute error: {np.mean(token_abs_errors):.6e}")
    print(f"Max per-token absolute error:  {np.max(token_abs_errors):.6e}")
    print(f"Min per-token absolute error:  {np.min(token_abs_errors):.6e}")
    
    # Per-feature analysis (average across sequence and batch dimensions)
    feature_ref_means = np.mean(tensor_ref, axis=1)  # [oc_group, n_group_size]
    feature_cpp_means = np.mean(tensor_cpp, axis=1)  # [oc_group, n_group_size]
    feature_abs_errors = np.abs(feature_ref_means - feature_cpp_means)
    
    print(f"Per-feature mean absolute error: {np.mean(feature_abs_errors):.6e}")
    print(f"Max per-feature absolute error:  {np.max(feature_abs_errors):.6e}")
    
    # Error distribution analysis
    abs_errors = np.abs(tensor_ref - tensor_cpp)
    error_percentiles = np.percentile(abs_errors, [50, 90, 95, 99])
    print(f"Absolute error percentiles:")
    print(f"  50th percentile (median): {error_percentiles[0]:.6e}")
    print(f"  90th percentile:          {error_percentiles[1]:.6e}")
    print(f"  95th percentile:          {error_percentiles[2]:.6e}")
    print(f"  99th percentile:          {error_percentiles[3]:.6e}")

    # Determine pass/fail status
    print("\n" + "-"*50)
    print("PASS/FAIL ASSESSMENT")
    print("-"*50)
    
    # Define thresholds for Llama Block (mixed precision, composite operator)
    max_abs_error_threshold = 1e-3
    mean_abs_error_threshold = 1e-4
    cosine_similarity_threshold = 0.999
    max_rel_error_threshold = 1e-2
    
    checks = {
        "Max absolute error": (metrics["max_absolute_error"] < max_abs_error_threshold, 
                              f"{metrics['max_absolute_error']:.6e} < {max_abs_error_threshold}"),
        "Mean absolute error": (metrics["mae"] < mean_abs_error_threshold,
                               f"{metrics['mae']:.6e} < {mean_abs_error_threshold}"),
        "Cosine similarity": (metrics["cosine_similarity"] > cosine_similarity_threshold,
                             f"{metrics['cosine_similarity']:.6f} > {cosine_similarity_threshold}"),
        "Max relative error": (metrics["max_relative_error"] < max_rel_error_threshold,
                              f"{metrics['max_relative_error']:.6e} < {max_rel_error_threshold}")
    }
    
    all_passed = True
    for check_name, (passed, condition) in checks.items():
        status = "PASS" if passed else "FAIL"
        print(f"{check_name:20}: {status} ({condition})")
        if not passed:
            all_passed = False
    
    overall_status = "PASS" if all_passed else "FAIL"
    print(f"\nOverall result: {overall_status}")

    # Save accuracy metrics
    if args.output_accuracy_json:
        accuracy_data = {
            "op_type": "llama_block",
            "precision_dut": "mixed_fp32_fp16",
            "precision_ref": "mixed_fp32_fp16",
            "dimensions": {
                "seq_len": args.seq_len,
                "d_model": args.d_model,
                "intermediate_size": args.intermediate_size,
                "head_num": args.head_num,
                "oc_group": oc_group,
                "n_group_size": n_group_size
            },
            "metrics": {
                "max_absolute_error": float(metrics["max_absolute_error"]),
                "mean_absolute_error": float(metrics["mae"]),
                "max_relative_error": float(metrics["max_relative_error"]),
                "mean_relative_error": float(metrics["mean_relative_error"]),
                "cosine_similarity": float(metrics["cosine_similarity"]),
                "mse": float(metrics["mse"])
            },
            "extended_metrics": {
                "per_token_mean_abs_error": float(np.mean(token_abs_errors)),
                "per_token_max_abs_error": float(np.max(token_abs_errors)),
                "per_feature_mean_abs_error": float(np.mean(feature_abs_errors)),
                "per_feature_max_abs_error": float(np.max(feature_abs_errors)),
                "error_percentiles": {
                    "50th": float(error_percentiles[0]),
                    "90th": float(error_percentiles[1]),
                    "95th": float(error_percentiles[2]),
                    "99th": float(error_percentiles[3])
                }
            },
            "pass_fail_assessment": {
                "overall_status": overall_status,
                "individual_checks": {name: passed for name, (passed, _) in checks.items()},
                "thresholds": {
                    "max_absolute_error": max_abs_error_threshold,
                    "mean_absolute_error": mean_abs_error_threshold,
                    "cosine_similarity": cosine_similarity_threshold,
                    "max_relative_error": max_rel_error_threshold
                }
            }
        }
        
        json_output_dir = os.path.dirname(args.output_accuracy_json)
        if json_output_dir:
            os.makedirs(json_output_dir, exist_ok=True)
        with open(args.output_accuracy_json, 'w') as f:
            json.dump(accuracy_data, f, indent=4)
        print(f"\nAccuracy JSON saved to: {args.output_accuracy_json}")

    # Generate plots
    print(f"\nGenerating comparison plots...")
    
    # Scatter plot
    plot_scatter_comparison(
        tensor_cpp, 
        tensor_ref, 
        title="Llama Block: C++ Output vs. PyTorch Reference",
        save_path=os.path.join(args.charts_dir, "llama_block_scatter_comparison.png")
    )
    print(f"Scatter comparison plot saved to {os.path.join(args.charts_dir, 'llama_block_scatter_comparison.png')}")

    # Absolute error histogram
    plot_error_histogram(
        metrics['absolute_error_array'], 
        title="Llama Block: Absolute Error Distribution",
        save_path=os.path.join(args.charts_dir, "llama_block_abs_error_hist.png")
    )
    print(f"Absolute error histogram saved to {os.path.join(args.charts_dir, 'llama_block_abs_error_hist.png')}")

    # Relative error histogram
    plot_error_histogram(
        metrics['relative_error_array'], 
        title="Llama Block: Relative Error Distribution",
        save_path=os.path.join(args.charts_dir, "llama_block_rel_error_hist.png")
    )
    print(f"Relative error histogram saved to {os.path.join(args.charts_dir, 'llama_block_rel_error_hist.png')}")

    print(f"\nComparison completed. Overall result: {overall_status}")

if __name__ == "__main__":
    main()
