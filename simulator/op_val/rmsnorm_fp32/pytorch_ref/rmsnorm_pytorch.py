import torch
import numpy as np
import sys
import os
import time # Import time module
import argparse # Import argparse module
import json # Import json module

# Add common_utils to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../common_utils')))
from data_gen import load_tensor_from_bin, save_tensor_to_bin, generate_random_tensor

def rmsnorm_pytorch_fp32(input_np: np.ndarray, gamma_np: np.ndarray, epsilon: float = 1e-5) -> tuple:
    """
    Performs RMSNorm using PyTorch with FP32 precision.
    input_np shape: (oc_group, seq_len, oc_group_size) as in rmsnorm.h
    gamma_np shape: (d_model) where d_model = oc_group * oc_group_size, or (oc_group, oc_group_size)
    Output shape: Same as input_np
    """
    start_time = time.perf_counter()
    input_torch = torch.from_numpy(input_np.copy()).float()
    gamma_torch = torch.from_numpy(gamma_np.copy()).float()

    oc_group, seq_len, oc_group_size = input_np.shape
    d_model = oc_group * oc_group_size

    # Reshape input to (seq_len, d_model) for easier RMS calculation across d_model
    input_reshaped = input_torch.permute(1, 0, 2).reshape(seq_len, d_model) # (seq_len, oc_group, oc_group_size) -> (seq_len, d_model)

    # Calculate RMS
    # RMS = sqrt(mean(x^2) + epsilon)
    variance = input_reshaped.pow(2).mean(dim=-1, keepdim=True)
    rms = torch.sqrt(variance + epsilon)
    output_normalized = input_reshaped / rms

    # Reshape gamma to be broadcastable with (seq_len, d_model) if it's not already (d_model)
    # The C++ code applies gamma[oc_iter * oc_group_size + oc_inner_iter]
    # This implies gamma is effectively (d_model) or (oc_group, oc_group_size) then flattened/indexed
    if gamma_torch.ndim == 1 and gamma_torch.shape[0] == d_model:
        gamma_reshaped = gamma_torch # Shape (d_model)
    elif gamma_torch.shape == (oc_group, oc_group_size):
        gamma_reshaped = gamma_torch.reshape(d_model) # Shape (d_model)
    else:
        raise ValueError(f"Unsupported gamma_np shape: {gamma_np.shape}. Expected ({d_model},) or ({oc_group}, {oc_group_size})")

    output_scaled = output_normalized * gamma_reshaped

    # Reshape output back to (oc_group, seq_len, oc_group_size)
    output_final = output_scaled.reshape(seq_len, oc_group, oc_group_size).permute(1, 0, 2) # (seq_len, d_model) -> (seq_len, oc_group, oc_group_size) -> (oc_group, seq_len, oc_group_size)
    end_time = time.perf_counter()
    execution_time = end_time - start_time
    print(f"PyTorch FP32 RMSNorm execution time: {execution_time:.6f} seconds")

    return output_final.cpu().numpy(), execution_time

def main():
    parser = argparse.ArgumentParser(description="PyTorch RMSNorm Reference Script (FP32)")
    parser.add_argument("--seq_len", type=int, required=True, help="Sequence length dimension")
    parser.add_argument("--d_model", type=int, required=True, help="Dimension of the model (oc_group * oc_group_size)")
    parser.add_argument("--oc_group_size", type=int, required=True, help="Size of the oc_group (feature dimension per group)")
    parser.add_argument("--epsilon", type=float, default=1e-5, help="Epsilon value for RMSNorm")
    parser.add_argument("--input_path", type=str, required=True, help="Path to the input tensor .bin file")
    parser.add_argument("--gamma_path", type=str, required=True, help="Path to the gamma tensor .bin file")
    parser.add_argument("--output_path", type=str, required=True, help="Path to save the RMSNorm output .bin file")
    parser.add_argument("--output_performance_json", type=str, help="Path to save the performance metrics JSON file.")

    args = parser.parse_args()

    if args.d_model % args.oc_group_size != 0:
        parser.error("d_model must be divisible by oc_group_size")
    
    oc_group_rmsnorm = args.d_model // args.oc_group_size
    seq_len_rmsnorm = args.seq_len
    oc_group_size_rmsnorm = args.oc_group_size
    d_model_rmsnorm = args.d_model

    rmsnorm_input_shape = (oc_group_rmsnorm, seq_len_rmsnorm, oc_group_size_rmsnorm)
    rmsnorm_gamma_shape = (d_model_rmsnorm,)
    rmsnorm_dtype = np.float32

    print(f"Loading RMSNorm input from: {args.input_path}")
    input_data = load_tensor_from_bin(args.input_path, dtype=rmsnorm_dtype, shape=rmsnorm_input_shape)
    print(f"Loading RMSNorm gamma from: {args.gamma_path}")
    gamma_data = load_tensor_from_bin(args.gamma_path, dtype=rmsnorm_dtype, shape=rmsnorm_gamma_shape)

    print(f"Loaded RMSNorm input shape: {input_data.shape}, dtype: {input_data.dtype}")
    print(f"Loaded RMSNorm gamma shape: {gamma_data.shape}, dtype: {gamma_data.dtype}")

    output_pytorch_fp32, exec_time = rmsnorm_pytorch_fp32(input_data, gamma_data, epsilon=args.epsilon)
    print(f"PyTorch FP32 RMSNorm output shape: {output_pytorch_fp32.shape}, dtype: {output_pytorch_fp32.dtype}")
    
    print(f"Saving PyTorch RMSNorm output to: {args.output_path}")
    save_tensor_to_bin(output_pytorch_fp32, args.output_path)

    if args.output_performance_json:
        total_elements = input_data.size
        elements_per_sec = total_elements / exec_time if exec_time > 0 else 0
        performance_data = {
            "op_type": "rmsnorm",
            "precision": "fp32",
            "dimensions": {
                "oc_group": oc_group_rmsnorm,
                "seq_len": seq_len_rmsnorm,
                "oc_group_size": oc_group_size_rmsnorm,
                "d_model": d_model_rmsnorm
            },
            "device": "cpu",
            "latency_ms": exec_time * 1000,
            "throughput": elements_per_sec,
            "throughput_unit": "Elements/sec"
        }
        with open(args.output_performance_json, 'w') as f:
            json.dump(performance_data, f, indent=4)
        print(f"Performance JSON saved to: {args.output_performance_json}")

    print("RMSNorm PyTorch reference script finished. Output saved to .bin file.")

if __name__ == '__main__':
    main() 