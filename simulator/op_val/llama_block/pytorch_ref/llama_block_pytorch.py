import torch
import torch.nn.functional as F
import numpy as np
import sys
import os
import time
import argparse
import json
import math

# Add common_utils to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../common_utils')))
from data_gen import load_tensor_from_bin, save_tensor_to_bin, generate_random_tensor

def rmsnorm_pytorch(input_tensor, gamma_tensor, epsilon=1e-6):
    """
    RMSNorm implementation in PyTorch (FP32) \\
    `input_tensor`: [oc_group, seq_len, oc_group_size] -> [seq_len, d_model] for calculation \\
    `gamma_tensor`: [oc_group, oc_group_size] -> [d_model] \\
    `output`: [oc_group, seq_len, oc_group_size]
    """
    print("=========rmsnorm_pytorch=========")
    oc_group, seq_len, oc_group_size = input_tensor.shape
    d_model = oc_group * oc_group_size
    
    # Reshape for calculation: [oc_group, seq_len, oc_group_size] -> [seq_len, d_model]
    input_reshaped = input_tensor.permute(1, 0, 2).reshape(seq_len, d_model)
    gamma_reshaped = gamma_tensor.reshape(d_model)
    
    # RMSNorm calculation
    variance = input_reshaped.pow(2).mean(dim=-1, keepdim=True)
    rms = torch.sqrt(variance + epsilon)
    normalized = input_reshaped / rms
    output = normalized * gamma_reshaped
    
    # Reshape back: [seq_len, d_model] -> [oc_group, seq_len, oc_group_size]
    output_final = output.reshape(seq_len, oc_group, oc_group_size).permute(1, 0, 2)
    return output_final

def apply_rotary_emb(xq, xk, seq_len, head_dim, base=10000):
    """
    Apply RoPE (Rotary Position Embedding) to query and key tensors \\
    `xq`: query tensor [seq_len, head_num, head_dim] \\
    `xk`: key tensor [seq_len, head_num, head_dim] \\
    `seq_len`: sequence length \\
    `head_dim`: head dimension \\
    `base`: base for RoPE calculation
    """
    # Create position indices
    position_indices = torch.arange(seq_len, dtype=torch.float32).unsqueeze(1)  # [seq_len, 1]
    
    # Create frequency indices
    freq_indices = torch.arange(head_dim // 2, dtype=torch.float32) / (head_dim // 2)  # [head_dim//2]
    
    # Calculate frequencies
    freqs = base ** (-freq_indices)  # [head_dim//2]
    
    # Calculate angles
    angles = position_indices * freqs  # [seq_len, head_dim//2]
    
    # Create complex frequencies
    freqs_cis = torch.polar(torch.ones_like(angles), angles)  # [seq_len, head_dim//2]
    
    def reshape_for_broadcast(freqs_cis, x):
        ndim = x.ndim
        assert 0 <= 0 < ndim  # seq_len dimension is at index 0
        assert freqs_cis.shape == (x.shape[0], x.shape[-1])  # [seq_len, head_dim//2]
        shape = [d if i == 0 or i == ndim - 1 else 1 for i, d in enumerate(x.shape)]
        return freqs_cis.view(*shape)
    
    # Convert query and key to complex representation
    # [seq_len, head_num, head_dim] -> [seq_len, head_num, head_dim//2, 2] -> [seq_len, head_num, head_dim//2]
    xq_ = torch.view_as_complex(xq.float().reshape(*xq.shape[:-1], -1, 2))
    xk_ = torch.view_as_complex(xk.float().reshape(*xk.shape[:-1], -1, 2))
    
    print("RoPE xq_ shape:", xq_.shape)
    print("RoPE xk_ shape:", xk_.shape)
    print("RoPE freqs_cis shape:", freqs_cis.shape)
    # Reshape freqs_cis for broadcasting: [seq_len, head_dim//2] -> [seq_len, 1, head_dim//2]
    freqs_cis = reshape_for_broadcast(freqs_cis, xq_)
    
    # Apply rotation through complex multiplication
    # view_as_real: [seq_len, head_num, head_dim//2, 2] -> flatten(2): [seq_len, head_num, head_dim]
    xq_out = torch.view_as_real(xq_ * freqs_cis).flatten(2) 
    xk_out = torch.view_as_real(xk_ * freqs_cis).flatten(2)
    print("RoPE xq_out shape:", xq_out.shape)
    print("RoPE xk_out shape:", xk_out.shape)

    return xq_out.type_as(xq), xk_out.type_as(xk)

def multihead_attention_pytorch(input_tensor, q_weight, k_weight, v_weight, o_weight, head_num, epsilon=1e-8):
    """
    Multi-Head Self-Attention implementation (FP16) \\
    `input_tensor`: [oc_group, seq_len, oc_group_size] in FP16 \\
    `weights`: [oc_group, ic_group, oc_group_size, ic_group_size] in FP16 \\
    `output`: [oc_group, seq_len, oc_group_size] in fp16
    """
    print("=========multihead_attention_pytorch=========")
    oc_group, seq_len, oc_group_size = input_tensor.shape
    d_model = oc_group * oc_group_size
    head_dim = d_model // head_num
    
    # Reshape input: [oc_group, seq_len, oc_group_size] -> [seq_len, d_model]
    input_reshaped = input_tensor.permute(1, 0, 2).reshape(seq_len, d_model)
    print("input_reshaped shape:", input_reshaped.shape)

    # Reshape weights: [oc_group, ic_group, oc_group_size, ic_group_size] -> [d_model, d_model]
    q_weight_2d = q_weight.permute(0, 2, 1, 3).reshape(d_model, d_model)
    k_weight_2d = k_weight.permute(0, 2, 1, 3).reshape(d_model, d_model)
    v_weight_2d = v_weight.permute(0, 2, 1, 3).reshape(d_model, d_model)
    o_weight_2d = o_weight.permute(0, 2, 1, 3).reshape(d_model, d_model)
    print("q_weight_2d shape:", q_weight_2d.shape)

    # Linear projections
    Q = torch.matmul(input_reshaped, q_weight_2d.transpose(0, 1))  # [seq_len, d_model]
    K = torch.matmul(input_reshaped, k_weight_2d.transpose(0, 1))  # [seq_len, d_model]
    V = torch.matmul(input_reshaped, v_weight_2d.transpose(0, 1))  # [seq_len, d_model]
    print("Q shape:", Q.shape)

    # Reshape for multi-head: [seq_len, d_model] -> [seq_len, head_num, head_dim]
    Q = Q.reshape(seq_len, head_num, head_dim)
    K = K.reshape(seq_len, head_num, head_dim)
    V = V.reshape(seq_len, head_num, head_dim)
    
    # Apply RoPE to Q and K
    Q, K = apply_rotary_emb(Q, K, seq_len, head_dim)  # [seq_len, head_num, head_dim]
    print("After RoPE Q shape:", Q.shape)

    # Transpose: [seq_len, head_num, head_dim] -> [head_num, seq_len, head_dim]
    Q = Q.transpose(0, 1)   # [head_num, seq_len, head_dim]
    K = K.transpose(0, 1)   # [head_num, seq_len, head_dim]
    V = V.transpose(0, 1)   # [head_num, seq_len, head_dim]
    print("After Transpose Q shape:", Q.shape)

    # Attention computation
    scale = 1.0 / math.sqrt(head_dim)
    scores = torch.matmul(Q, K.transpose(-2, -1)) * scale  # [head_num, seq_len, seq_len]
    print("scores shape:", scores.shape)

    # Apply causal mask
    mask = torch.triu(torch.ones(seq_len, seq_len), diagonal=1).bool()
    print("mask:", mask)
    scores.masked_fill_(mask.unsqueeze(0), float('-inf'))  # Set future positions to -inf

    # Softmax
    attn_weights = F.softmax(scores, dim=-1)
    
    # Apply attention to values
    attn_output = torch.matmul(attn_weights, V)  # [head_num, seq_len, head_dim]
    
    # Transpose back: [head_num, seq_len, head_dim] -> [seq_len, head_num, head_dim]
    attn_output = attn_output.transpose(0, 1)
    
    # Concatenate heads: [seq_len, head_num, head_dim] -> [seq_len, d_model]
    attn_output = attn_output.reshape(seq_len, d_model)
    
    # Output projection
    output = torch.matmul(attn_output, o_weight_2d.transpose(0, 1))  # [seq_len, d_model]
    
    # Reshape back: [seq_len, d_model] -> [oc_group, seq_len, oc_group_size]
    output_final = output.reshape(seq_len, oc_group, oc_group_size).permute(1, 0, 2)
    print("output_final shape:", output_final.shape)
    print("output_final dtype:", output_final.dtype)

    return output_final

def llama_mlp_pytorch(input_tensor, gate_weight, up_weight, down_weight):
    """
    Llama MLP implementation (FP16) \\
    `input_tensor`: [oc_group, seq_len, oc_group_size] in FP16 \\
    Gate and Up project to intermediate_size, Down projects back to d_model
    `output`: [oc_group, seq_len, oc_group_size] in FP16
    """
    print("=========llama_mlp_pytorch=========")
    oc_group, seq_len, oc_group_size = input_tensor.shape
    d_model = oc_group * oc_group_size
    
    # Get intermediate size from gate weight shape
    intermediate_oc_group = gate_weight.shape[0]
    intermediate_size = intermediate_oc_group * oc_group_size
    
    # Reshape input: [oc_group, seq_len, oc_group_size] -> [seq_len, d_model]
    input_reshaped = input_tensor.permute(1, 0, 2).reshape(seq_len, d_model)
    
    # Reshape weights: [oc_group, ic_group, oc_group_size, ic_group_size] -> [intermediate_size, d_model] 
    gate_weight_2d = gate_weight.permute(0, 2, 1, 3).reshape(intermediate_size, d_model)
    up_weight_2d = up_weight.permute(0, 2, 1, 3).reshape(intermediate_size, d_model)
    down_weight_2d = down_weight.permute(0, 2, 1, 3).reshape(d_model, intermediate_size)
    
    # Gate and Up projections
    gate_out = torch.matmul(input_reshaped, gate_weight_2d.transpose(0, 1))  # [seq_len, intermediate_size]
    up_out = torch.matmul(input_reshaped, up_weight_2d.transpose(0, 1))     # [seq_len, intermediate_size]
    
    # Swish activation on gate output
    gate_swish = F.silu(gate_out)  # [seq_len, intermediate_size]
    
    # Element-wise multiplication
    intermediate_out = gate_swish * up_out  # [seq_len, intermediate_size]
    print("intermediate_out shape:", intermediate_out.shape)
    print("intermediate_out dtype:", intermediate_out.dtype)

    # Down projection
    output = torch.matmul(intermediate_out, down_weight_2d.transpose(0, 1))  # [seq_len, d_model]
    
    # Reshape back: [seq_len, d_model] -> [oc_group, seq_len, oc_group_size]
    output_final = output.reshape(seq_len, oc_group, oc_group_size).permute(1, 0, 2)
    return output_final

def llama_block_pytorch( # numpy input, we need to convert to torch tensor
    input_hidden_state,      # torch.float32 [oc_group, seq_len, oc_group_size]
    attn_norm_gamma,         # torch.float32 [oc_group, oc_group_size]
    ffn_norm_gamma,          # torch.float32 [oc_group, oc_group_size]
    query_weight,            # torch.float16 [oc_group, ic_group, oc_group_size, ic_group_size]
    key_weight,              # torch.float16
    value_weight,            # torch.float16
    output_proj_weight,      # torch.float16
    gate_weight,             # torch.float16 [intermediate_oc_group, ic_group, oc_group_size, ic_group_size]
    up_weight,               # torch.float16
    down_weight,             # torch.float16 [oc_group, intermediate_ic_group, oc_group_size, ic_group_size]
    num_attention_heads,
    rmsnorm_epsilon=1e-5
):
    """
    input numpy, ouput numpy \\
    Complete Llama Block implementation matching C++ structure \\
    n_group_size = 32  # FP32 parallelism \\
    k_group_size = 16  # FP16 parallelism 
    """

    # Convert numpy to torch tensors (permute need it)
    input_hidden_state = torch.from_numpy(input_hidden_state.copy()).float()
    attn_norm_gamma = torch.from_numpy(attn_norm_gamma.copy()).float()
    ffn_norm_gamma = torch.from_numpy(ffn_norm_gamma.copy()).float()
    
    query_weight = torch.from_numpy(query_weight.copy()).half()
    key_weight = torch.from_numpy(key_weight.copy()).half()
    value_weight = torch.from_numpy(value_weight.copy()).half()
    output_proj_weight = torch.from_numpy(output_proj_weight.copy()).half()
    
    gate_weight = torch.from_numpy(gate_weight.copy()).half()
    up_weight = torch.from_numpy(up_weight.copy()).half()
    down_weight = torch.from_numpy(down_weight.copy()).half()
    
    n_group_size = 32  # FP32 parallelism 
    k_group_size = 16  # FP16 parallelism

    start_time = time.perf_counter()

    # 1. Pre-attention RMSNorm (FP32)
    attn_norm_out = rmsnorm_pytorch(input_hidden_state, attn_norm_gamma, rmsnorm_epsilon) # [n_group, seq_len, n_group_size]
    
    # 2. FP32→FP16 and Parallesim conversion for attention
    attn_norm_out_fp16 = attn_norm_out.half()

    # 3. Multi-head self-attention (FP16)
    attn_out = multihead_attention_pytorch(
        attn_norm_out_fp16, query_weight, key_weight, value_weight, 
        output_proj_weight, num_attention_heads
    )
    
    # 4. FP16→FP32 + first residual connection
    attn_out_fp32 = attn_out.float()
    residual_1 = input_hidden_state + attn_out_fp32
    
    # 5. Pre-FFN RMSNorm (FP32)
    ffn_norm_out = rmsnorm_pytorch(residual_1, ffn_norm_gamma, rmsnorm_epsilon)
    
    # 6. FP32→FP16 + MLP (FP16)
    ffn_norm_out_fp16 = ffn_norm_out.half()
    mlp_out = llama_mlp_pytorch(ffn_norm_out_fp16, gate_weight, up_weight, down_weight)
    
    # 7. FP16→FP32 + second residual connection
    mlp_out_fp32 = mlp_out.float()
    output = residual_1 + mlp_out_fp32
    
    end_time = time.perf_counter()
    execution_time = end_time - start_time
    print("==============Llama Block execution completed.==============")
    print(f"PyTorch Llama Block execution time: {execution_time:.6f} seconds")
    return output.cpu().numpy(), execution_time


def main():
    parser = argparse.ArgumentParser(description="PyTorch Llama Block Reference Script")
    parser.add_argument("--seq_len", type=int, required=True, help="Sequence length")
    parser.add_argument("--d_model", type=int, required=True, help="Model dimension")
    parser.add_argument("--intermediate_size", type=int, required=True, help="MLP intermediate size")
    parser.add_argument("--head_num", type=int, required=True, help="Number of attention heads")
    parser.add_argument("--rmsnorm_epsilon", type=float, default=1e-5, help="RMSNorm epsilon")
    
    # Input file paths
    parser.add_argument("--input_path", type=str, required=True, help="Input hidden state path")
    parser.add_argument("--attn_norm_gamma_path", type=str, required=True, help="Attention norm gamma path")
    parser.add_argument("--ffn_norm_gamma_path", type=str, required=True, help="FFN norm gamma path")
    parser.add_argument("--query_weight_path", type=str, required=True, help="Query weight path")
    parser.add_argument("--key_weight_path", type=str, required=True, help="Key weight path")
    parser.add_argument("--value_weight_path", type=str, required=True, help="Value weight path")
    parser.add_argument("--output_proj_weight_path", type=str, required=True, help="Output projection weight path")
    parser.add_argument("--gate_weight_path", type=str, required=True, help="Gate weight path")
    parser.add_argument("--up_weight_path", type=str, required=True, help="Up weight path")
    parser.add_argument("--down_weight_path", type=str, required=True, help="Down weight path")
    
    # Output file paths
    parser.add_argument("--output_path", type=str, required=True, help="Output path")
    parser.add_argument("--output_performance_json", type=str, help="Performance JSON output path")
    
    args = parser.parse_args()
    
    # Calculate dimensions
    n_group_size = 32  # FP32 parallelism
    k_group_size = 16  # FP16 parallelism
    
    oc_group = args.d_model // n_group_size
    ic_group_attn = args.d_model // k_group_size
    oc_group_mlp = args.intermediate_size // n_group_size
    ic_group_mlp = args.intermediate_size // k_group_size
    
    # Define shapes
    input_shape = (oc_group, args.seq_len, n_group_size)
    gamma_shape = (oc_group, n_group_size)
    attn_weight_shape = (oc_group, ic_group_attn, n_group_size, k_group_size)
    gate_up_weight_shape = (oc_group_mlp, ic_group_attn, n_group_size, k_group_size)
    down_weight_shape = (oc_group, ic_group_mlp, n_group_size, k_group_size)
    
    print(f"Loading Llama Block inputs...")
    print(f"Input shape: {input_shape}")
    print(f"Gamma shape: {gamma_shape}")
    print(f"Attention weight shape: {attn_weight_shape}")
    print(f"Gate/Up weight shape: {gate_up_weight_shape}")
    print(f"Down weight shape: {down_weight_shape}")
    
    # Load all input data
    input_tensor = load_tensor_from_bin(args.input_path, dtype=np.float32, shape=input_shape)
    attn_norm_gamma_tensor = load_tensor_from_bin(args.attn_norm_gamma_path, dtype=np.float32, shape=gamma_shape)
    ffn_norm_gamma_tensor = load_tensor_from_bin(args.ffn_norm_gamma_path, dtype=np.float32, shape=gamma_shape)
    
    query_weight_tensor = load_tensor_from_bin(args.query_weight_path, dtype=np.float16, shape=attn_weight_shape)
    key_weight_tensor = load_tensor_from_bin(args.key_weight_path, dtype=np.float16, shape=attn_weight_shape)
    value_weight_tensor = load_tensor_from_bin(args.value_weight_path, dtype=np.float16, shape=attn_weight_shape)
    output_proj_weight_tensor = load_tensor_from_bin(args.output_proj_weight_path, dtype=np.float16, shape=attn_weight_shape)
    
    gate_weight_tensor = load_tensor_from_bin(args.gate_weight_path, dtype=np.float16, shape=gate_up_weight_shape)
    up_weight_tensor = load_tensor_from_bin(args.up_weight_path, dtype=np.float16, shape=gate_up_weight_shape)
    down_weight_tensor = load_tensor_from_bin(args.down_weight_path, dtype=np.float16, shape=down_weight_shape)
        
    print("Data loaded successfully. Running Llama Block computation...")
        
    output_tensor, execution_time = llama_block_pytorch(
        input_tensor,
        attn_norm_gamma_tensor,
        ffn_norm_gamma_tensor,
        query_weight_tensor,
        key_weight_tensor,
        value_weight_tensor,
        output_proj_weight_tensor,
        gate_weight_tensor,
        up_weight_tensor,
        down_weight_tensor,
        args.head_num,
        args.rmsnorm_epsilon
    )
    
    tokens_per_sec = args.seq_len / execution_time if execution_time > 0 else 0
    
    print(f"Throughput: {tokens_per_sec:.2f} tokens/sec")
    
    # Save output
    output_data = output_tensor.cpu().numpy()
    print(f"Saving output to: {args.output_path}")
    save_tensor_to_bin(output_data, args.output_path)
    
    # Save performance metrics
    if args.output_performance_json:
        performance_data = {
            "op_type": "llama_block",
            "precision": "mixed_fp32_fp16",
            "dimensions": {
                "seq_len": args.seq_len,
                "d_model": args.d_model,
                "intermediate_size": args.intermediate_size,
                "head_num": args.head_num
            },
            "device": "cpu",
            "latency_ms": execution_time * 1000,
            "throughput": tokens_per_sec,
            "throughput_unit": "tokens/sec"
        }
        with open(args.output_performance_json, 'w') as f:
            json.dump(performance_data, f, indent=4)
        print(f"Performance JSON saved to: {args.output_performance_json}")
    
    print("Llama Block PyTorch reference completed successfully.")
    print(f"Output shape: {output_tensor.shape}")

if __name__ == '__main__':
    main()
