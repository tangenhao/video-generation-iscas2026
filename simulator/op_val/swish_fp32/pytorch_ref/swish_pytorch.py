import torch
import torch.nn.functional as F
import numpy as np
import sys
import os
import time # Import time module
import argparse # Import argparse
import json # Import json

# Add common_utils to Python path
current_file_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(os.path.abspath(os.path.join(current_file_dir, '../../common_utils')))
from data_gen import load_tensor_from_bin, save_tensor_to_bin

def swish_pytorch_fp32(input_np: np.ndarray) -> tuple:
    """
    Performs Swish (SiLU) activation using PyTorch with FP32 precision.
    input_np shape: (oc_group, num_data, oc_group_size).
    Swish is an element-wise operation: output = x * sigmoid(x).
    torch.nn.functional.silu is equivalent to Swish.
    """
    start_time = time.perf_counter()
    input_torch = torch.from_numpy(input_np.copy()).float()
    output_torch = F.silu(input_torch)
    end_time = time.perf_counter()
    execution_time = end_time - start_time
    print(f"PyTorch FP32 Swish (SiLU) execution time: {execution_time:.6f} seconds")
    return output_torch.cpu().numpy(), execution_time

def main():
    parser = argparse.ArgumentParser(description="PyTorch Swish (SiLU) Reference Script (FP32)")
    parser.add_argument("--oc_group", type=int, required=True, help="oc_group (batch-like) dimension")
    parser.add_argument("--num_data", type=int, required=True, help="Number of data points (e.g., seq_len or H*W)")
    parser.add_argument("--oc_group_size", type=int, required=True, help="Size of the oc_group (feature dimension per group)")
    parser.add_argument("--input_path", type=str, required=True, help="Path to the input tensor .bin file")
    parser.add_argument("--output_path", type=str, required=True, help="Path to save the Swish output .bin file")
    parser.add_argument("--output_performance_json", type=str, help="Path to save the performance metrics JSON file.")
    
    args = parser.parse_args()

    swish_input_shape = (args.oc_group, args.num_data, args.oc_group_size)
    swish_dtype = np.float32

    print(f"Loading Swish input from: {args.input_path}")
    input_data = load_tensor_from_bin(args.input_path, dtype=swish_dtype, shape=swish_input_shape)
    print(f"Loaded Swish input shape: {input_data.shape}, dtype: {input_data.dtype}")

    output_pytorch_fp32, exec_time = swish_pytorch_fp32(input_data)
    print(f"PyTorch FP32 Swish output shape: {output_pytorch_fp32.shape}, dtype: {output_pytorch_fp32.dtype}")
    
    print(f"Saving PyTorch Swish output to: {args.output_path}")
    save_tensor_to_bin(output_pytorch_fp32, args.output_path)

    if args.output_performance_json:
        total_elements = input_data.size
        elements_per_sec = total_elements / exec_time if exec_time > 0 else 0
        performance_data = {
            "op_type": "swish",
            "precision": "fp32",
            "dimensions": {
                "oc_group": args.oc_group,
                "num_data": args.num_data,
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

    print(f"Swish PyTorch reference script finished. Output saved to {args.output_path}")

if __name__ == '__main__':
    main() 