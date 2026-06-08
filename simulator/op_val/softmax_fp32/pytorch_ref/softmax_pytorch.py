import torch
import numpy as np
import sys
import os
import time # Import time module
import argparse # Import argparse
import json # Import json

# Add common_utils to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../common_utils')))
from data_gen import load_tensor_from_bin, save_tensor_to_bin, generate_random_tensor

def softmax_pytorch_fp32(input_np: np.ndarray) -> tuple:
    """
    Performs Softmax using PyTorch with FP32 precision.
    input_np shape: (oc_group, seq_len, oc_group_size) as in softmax.cpp example.
    The PyTorch reference assumes softmax over the concatenated features (d_model = oc_group * oc_group_size)
    for each seq_len item.
    """
    start_time = time.perf_counter()
    input_torch = torch.from_numpy(input_np.copy()).float()
    
    oc_group, seq_len, oc_group_size = input_np.shape
    d_model = oc_group * oc_group_size

    # If oc_group > 1, the C++ simulation applies softmax to each of the [seq_len, oc_group_size] slices independently within each group.
    # If oc_group == 1, it's effectively softmax over the last dimension [oc_group_size] for each seq_len.
    # The current C++ `compute_softmax` takes (oc_group, seq_len, oc_group_size) and applies softmax on the innermost `oc_group_size` dimension.
    # So, dim=-1 for torch.softmax is correct if applied to the original input_torch shape.
    
    input_reshaped = input_torch.permute(1, 0, 2).reshape(seq_len, d_model) # This was for d_model wide softmax
    output_torch = torch.softmax(input_reshaped, dim=-1)
    output_final = output_torch.reshape(seq_len, oc_group, oc_group_size).permute(1, 0, 2)

    end_time = time.perf_counter()
    execution_time = end_time - start_time
    print(f"PyTorch FP32 Softmax execution time: {execution_time:.6f} seconds")

    return output_final.cpu().numpy(), execution_time

def main():
    parser = argparse.ArgumentParser(description="PyTorch Softmax Reference Script (FP32)")
    parser.add_argument("--oc_group", type=int, required=True, help="oc_group (batch-like) dimension")
    parser.add_argument("--seq_len", type=int, required=True, help="Sequence length dimension")
    parser.add_argument("--oc_group_size", type=int, required=True, help="Size of the oc_group (feature dimension per group, softmax is applied over this dim)")
    parser.add_argument("--input_path", type=str, required=True, help="Path to the input tensor .bin file")
    parser.add_argument("--output_path", type=str, required=True, help="Path to save the Softmax output .bin file")
    parser.add_argument("--output_performance_json", type=str, help="Path to save the performance metrics JSON file.")
    
    args = parser.parse_args()

    softmax_input_shape = (args.oc_group, args.seq_len, args.oc_group_size)
    softmax_dtype = np.float32

    print(f"Loading Softmax input from: {args.input_path}")
    input_data = load_tensor_from_bin(args.input_path, dtype=softmax_dtype, shape=softmax_input_shape)
    
    print(f"Loaded Softmax input shape: {input_data.shape}, dtype: {input_data.dtype}")

    output_pytorch_fp32, exec_time = softmax_pytorch_fp32(input_data)
    print(f"PyTorch FP32 Softmax output shape: {output_pytorch_fp32.shape}, dtype: {output_pytorch_fp32.dtype}")
    
    print(f"Saving PyTorch Softmax output to: {args.output_path}")
    save_tensor_to_bin(output_pytorch_fp32, args.output_path)

    if args.output_performance_json:
        total_elements = input_data.size
        elements_per_sec = total_elements / exec_time if exec_time > 0 else 0
        performance_data = {
            "op_type": "softmax",
            "precision": "fp32",
            "dimensions": {
                "oc_group": args.oc_group,
                "seq_len": args.seq_len,
                "oc_group_size": args.oc_group_size
            },
            "device": "cpu",
            "latency_ms": exec_time * 1000,
            "throughput": elements_per_sec,
            "throughput_unit": "Elements/sec"
        }
        with open(args.output_performance_json, 'w') as f:
            json.dump(performance_data, f, indent=4)
        print(f"Performance JSON saved to: {args.output_performance_json}")

    print("Softmax PyTorch reference script finished. Output saved to .bin file.")

if __name__ == '__main__':
    main() 