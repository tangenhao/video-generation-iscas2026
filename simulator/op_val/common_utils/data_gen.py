import numpy as np
import os
import argparse # For command-line arguments

def save_tensor_to_bin(tensor: np.ndarray, file_path: str):
    """
    Saves a NumPy tensor to a .bin file (raw binary).
    Creates the directory if it doesn't exist.
    """
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    tensor.tofile(file_path)
    print(f"Tensor saved to {file_path} (shape: {tensor.shape}, dtype: {tensor.dtype})")

def load_tensor_from_bin(file_path: str, dtype: np.dtype, shape: tuple) -> np.ndarray:
    """
    Loads a NumPy tensor from a .bin file (raw binary).
    Requires dtype and shape to correctly reconstruct the tensor.
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")
    tensor = np.fromfile(file_path, dtype=dtype)
    try:
        tensor = tensor.reshape(shape)
    except ValueError as e:
        raise ValueError(f"Error reshaping tensor from file {file_path}. Expected shape {shape} (total elements {np.prod(shape)}), but got {tensor.size} elements. Error: {e}")
    print(f"Tensor loaded from {file_path} (shape: {tensor.shape}, dtype: {tensor.dtype})")
    return tensor

def generate_random_tensor(shape: tuple, dtype: np.dtype = np.float32, low: float = -1.0, high: float = 1.0, seed: int = None) -> np.ndarray:
    """
    Generates a random NumPy tensor with a uniform distribution.
    """
    if seed is not None:
        np.random.seed(seed)
    if np.issubdtype(dtype, np.integer):
        return np.random.randint(low, high + 1, size=shape, dtype=dtype)
    else:
        return np.random.uniform(low, high, size=shape).astype(dtype)


def generate_gemm_data(base_op_val_dir: str, M: int, K: int, N: int, precision: str = 'fp16', seed_ifmap: int = 0, seed_weight: int = 1):
    if precision == 'fp16':
        dtype = np.float16
    else:
        raise ValueError(f"Unsupported precision for GEMM: {precision}")

    ifmap_shape = (M, K)
    weight_shape = (K, N)
    
    ifmap_data = generate_random_tensor(ifmap_shape, dtype=dtype, seed=seed_ifmap)
    weight_data = generate_random_tensor(weight_shape, dtype=dtype, seed=seed_weight)
    
    data_dir = os.path.join(base_op_val_dir, f'gemm_{precision}', 'data')
    save_tensor_to_bin(ifmap_data, os.path.join(data_dir, f'ifmap_m{M}_k{K}.bin'))
    save_tensor_to_bin(weight_data, os.path.join(data_dir, f'weight_k{K}_n{N}.bin'))
    print(f"GEMM {precision} data generated for M={M}, K={K}, N={N} in {data_dir}")

def generate_rmsnorm_data(base_op_val_dir: str, oc_group: int, seq_len: int, oc_group_size: int, precision: str = 'fp32', seed_input: int = 2, seed_gamma: int = 3):
    if precision != 'fp32':
        raise ValueError(f"RMSNorm currently only supports fp32, got {precision}")
    dtype = np.float32
    d_model = oc_group * oc_group_size

    input_shape = (oc_group, seq_len, oc_group_size)
    gamma_shape = (d_model,)

    input_data = generate_random_tensor(input_shape, dtype=dtype, seed=seed_input)
    gamma_data = generate_random_tensor(gamma_shape, dtype=dtype, seed=seed_gamma)

    data_dir = os.path.join(base_op_val_dir, f'rmsnorm_{precision}', 'data')
    save_tensor_to_bin(input_data, os.path.join(data_dir, f'input_g{oc_group}_s{seq_len}_ogs{oc_group_size}.bin'))
    save_tensor_to_bin(gamma_data, os.path.join(data_dir, f'gamma_d{d_model}.bin'))
    print(f"RMSNorm {precision} data generated for G={oc_group}, S={seq_len}, OGS={oc_group_size} in {data_dir}")

def generate_softmax_data(base_op_val_dir: str, oc_group: int, seq_len: int, oc_group_size: int, precision: str = 'fp32', seed_input: int = 4):
    if precision != 'fp32':
        raise ValueError(f"Softmax currently only supports fp32, got {precision}")
    dtype = np.float32
    input_shape = (oc_group, seq_len, oc_group_size)
    input_data = generate_random_tensor(input_shape, dtype=dtype, seed=seed_input)
    
    dims_suffix = f"_g{oc_group}_s{seq_len}_ogs{oc_group_size}"
    input_filename = f"input{dims_suffix}.bin"
    data_dir = os.path.join(base_op_val_dir, f'softmax_{precision}', 'data')
    save_tensor_to_bin(input_data, os.path.join(data_dir, input_filename))
    print(f"Softmax {precision} data generated for G={oc_group}, S={seq_len}, OGS={oc_group_size} in {data_dir}")

def generate_swish_data(base_op_val_dir: str, oc_group: int, num_data: int, oc_group_size: int, precision: str = 'fp32', seed_input: int = 5):
    if precision != 'fp32':
        raise ValueError(f"Swish currently only supports fp32, got {precision}")
    dtype = np.float32
    input_shape = (oc_group, num_data, oc_group_size)
    input_data = generate_random_tensor(input_shape, dtype=dtype, seed=seed_input)
    
    data_dir = os.path.join(base_op_val_dir, f'swish_{precision}', 'data')
    save_tensor_to_bin(input_data, os.path.join(data_dir, f'input_g{oc_group}_n{num_data}_ogs{oc_group_size}.bin'))
    print(f"Swish {precision} data generated for G={oc_group}, N={num_data}, OGS={oc_group_size} in {data_dir}")

def generate_llama_block_data(
    base_op_val_dir: str, 
    seq_len: int, 
    d_model: int, 
    intermediate_size: int, 
    head_num: int, 
    n_group_size: int = 32,  # FP32 parallelism
    k_group_size: int = 16,  # FP16 parallelism
    seed_input: int = 1,
    seed_attn_norm: int = 100,
    seed_ffn_norm: int = 200,
    seed_query: int = 300,
    seed_key: int = 400,
    seed_value: int = 500,
    seed_output_proj: int = 600,
    seed_gate: int = 700,
    seed_up: int = 800,
    seed_down: int = 900
):
    """
    Generate test data for Llama Block validation.
    """
    print(f"Generating Llama Block data:")
    print(f"  seq_len: {seq_len}, d_model: {d_model}, intermediate_size: {intermediate_size}, head_num: {head_num}")
    print(f"  n_group_size: {n_group_size}, k_group_size: {k_group_size}")
    
    # Validate dimensions
    if d_model % n_group_size != 0:
        raise ValueError(f"d_model ({d_model}) must be divisible by n_group_size ({n_group_size})")
    if d_model % k_group_size != 0:
        raise ValueError(f"d_model ({d_model}) must be divisible by k_group_size ({k_group_size})")
    if intermediate_size % n_group_size != 0:
        raise ValueError(f"intermediate_size ({intermediate_size}) must be divisible by n_group_size ({n_group_size})")
    if intermediate_size % k_group_size != 0:
        raise ValueError(f"intermediate_size ({intermediate_size}) must be divisible by k_group_size ({k_group_size})")
    
    # Calculate group dimensions
    oc_group = d_model // n_group_size
    ic_group_attn = d_model // k_group_size
    oc_group_mlp = intermediate_size // n_group_size
    ic_group_mlp = intermediate_size // k_group_size
    
    # Data types
    hidden_dtype = np.float32  # Hidden states are FP32
    weight_dtype = np.float16  # Weights are FP16
    
    # Shape definitions
    input_shape = (oc_group, seq_len, n_group_size)
    gamma_shape = (oc_group, n_group_size)
    attn_weight_shape = (oc_group, ic_group_attn, n_group_size, k_group_size)
    gate_up_weight_shape = (oc_group_mlp, ic_group_attn, n_group_size, k_group_size)
    down_weight_shape = (oc_group, ic_group_mlp, n_group_size, k_group_size)
    
    print(f"  Calculated shapes:")
    print(f"    input: {input_shape}")
    print(f"    gamma: {gamma_shape}")
    print(f"    attention weights: {attn_weight_shape}")
    print(f"    gate/up weights: {gate_up_weight_shape}")
    print(f"    down weight: {down_weight_shape}")
    
    # Generate data
    input_data = generate_random_tensor(input_shape, dtype=hidden_dtype, low=-0.1, high=0.1, seed=seed_input)
    attn_norm_gamma = generate_random_tensor(gamma_shape, dtype=hidden_dtype, low=0.8, high=1.2, seed=seed_attn_norm)
    ffn_norm_gamma = generate_random_tensor(gamma_shape, dtype=hidden_dtype, low=0.8, high=1.2, seed=seed_ffn_norm)
    
    query_weight = generate_random_tensor(attn_weight_shape, dtype=weight_dtype, low=-0.1, high=0.1, seed=seed_query)
    key_weight = generate_random_tensor(attn_weight_shape, dtype=weight_dtype, low=-0.1, high=0.1, seed=seed_key)
    value_weight = generate_random_tensor(attn_weight_shape, dtype=weight_dtype, low=-0.1, high=0.1, seed=seed_value)
    output_proj_weight = generate_random_tensor(attn_weight_shape, dtype=weight_dtype, low=-0.1, high=0.1, seed=seed_output_proj)
    
    gate_weight = generate_random_tensor(gate_up_weight_shape, dtype=weight_dtype, low=-0.1, high=0.1, seed=seed_gate)
    up_weight = generate_random_tensor(gate_up_weight_shape, dtype=weight_dtype, low=-0.1, high=0.1, seed=seed_up)
    down_weight = generate_random_tensor(down_weight_shape, dtype=weight_dtype, low=-0.1, high=0.1, seed=seed_down)
    
    # Save data
    data_dir = os.path.join(base_op_val_dir, 'llama_block', 'data')
    
    # Create filename suffix for this configuration
    config_suffix = f"s{seq_len}_d{d_model}_i{intermediate_size}_h{head_num}"
    
    save_tensor_to_bin(input_data, os.path.join(data_dir, f'input_{config_suffix}.bin'))
    save_tensor_to_bin(attn_norm_gamma, os.path.join(data_dir, f'attn_norm_gamma_{config_suffix}.bin'))
    save_tensor_to_bin(ffn_norm_gamma, os.path.join(data_dir, f'ffn_norm_gamma_{config_suffix}.bin'))
    save_tensor_to_bin(query_weight, os.path.join(data_dir, f'query_weight_{config_suffix}.bin'))
    save_tensor_to_bin(key_weight, os.path.join(data_dir, f'key_weight_{config_suffix}.bin'))
    save_tensor_to_bin(value_weight, os.path.join(data_dir, f'value_weight_{config_suffix}.bin'))
    save_tensor_to_bin(output_proj_weight, os.path.join(data_dir, f'output_proj_weight_{config_suffix}.bin'))
    save_tensor_to_bin(gate_weight, os.path.join(data_dir, f'gate_weight_{config_suffix}.bin'))
    save_tensor_to_bin(up_weight, os.path.join(data_dir, f'up_weight_{config_suffix}.bin'))
    save_tensor_to_bin(down_weight, os.path.join(data_dir, f'down_weight_{config_suffix}.bin'))
    
    print(f"Llama Block data generated in {data_dir}")
    print(f"Configuration: {config_suffix}")
    
    return config_suffix


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Generate data for specified operators.")
    parser.add_argument("--base_op_val_dir", type=str, default="../", help="Base directory for op_val, e.g., 'simulator/op_val' or '../' if script is in common_utils.")
    parser.add_argument("--op_type", type=str, required=True, choices=['gemm', 'rmsnorm', 'softmax', 'swish', 'llama_block', 'all'], help="Operator type to generate data for, or 'all'.")
    
    # GEMM args
    parser.add_argument("--gemm_m", type=int, default=128, help="M dimension for GEMM")
    parser.add_argument("--gemm_k", type=int, default=256, help="K dimension for GEMM")
    parser.add_argument("--gemm_n", type=int, default=512, help="N dimension for GEMM")
    parser.add_argument("--gemm_precision", type=str, default='fp16', choices=['fp16', 'fp32'], help="Precision for GEMM data")

    # RMSNorm args (oc_group, seq_len, oc_group_size)
    # d_model will be oc_group * oc_group_size
    parser.add_argument("--rmsnorm_oc_group", type=int, default=32, help="oc_group for RMSNorm (d_model = oc_group * oc_group_size)") # Default from 1024/32
    parser.add_argument("--rmsnorm_seq_len", type=int, default=64, help="seq_len for RMSNorm")
    parser.add_argument("--rmsnorm_ogs", type=int, default=32, help="oc_group_size for RMSNorm")
    # RMSNorm precision is fp32 by default, not adding an arg for it unless needed.

    # Softmax args (oc_group, seq_len, oc_group_size)
    parser.add_argument("--softmax_oc_group", type=int, default=1, help="oc_group for Softmax")
    parser.add_argument("--softmax_seq_len", type=int, default=10, help="seq_len for Softmax")
    parser.add_argument("--softmax_ogs", type=int, default=32, help="oc_group_size for Softmax")

    # Swish args (oc_group, num_data, oc_group_size)
    parser.add_argument("--swish_oc_group", type=int, default=2, help="oc_group for Swish")
    parser.add_argument("--swish_num_data", type=int, default=196, help="num_data for Swish (e.g., H*W)") # 14*14 = 196
    parser.add_argument("--swish_ogs", type=int, default=32, help="oc_group_size for Swish")

    # Llama Block args
    parser.add_argument("--llama_seq_len", type=int, default=32, help="Sequence length for Llama Block")
    parser.add_argument("--llama_d_model", type=int, default=128, help="Model dimension for Llama Block")
    parser.add_argument("--llama_intermediate_size", type=int, default=128, help="MLP intermediate size for Llama Block")
    parser.add_argument("--llama_head_num", type=int, default=2, help="Number of attention heads for Llama Block")

    args = parser.parse_args()

    # Resolve base_op_val_dir properly. If this script is in common_utils,
    # and default is "../", it points to simulator/op_val.
    # If a more explicit path like "simulator/op_val" is given, use that.
    abs_base_op_val_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), args.base_op_val_dir))
    print(f"Using base_op_val_dir: {abs_base_op_val_dir}")

    if args.op_type == 'gemm' or args.op_type == 'all':
        print("\nGenerating GEMM data...")
        generate_gemm_data(abs_base_op_val_dir, args.gemm_m, args.gemm_k, args.gemm_n, args.gemm_precision)
    
    if args.op_type == 'rmsnorm' or args.op_type == 'all':
        print("\nGenerating RMSNorm data...")
        d_model_val = args.rmsnorm_oc_group * args.rmsnorm_ogs
        if d_model_val == 0: # Avoid d_model = 0 if defaults are not sensible
            print("Warning: RMSNorm d_model (oc_group * ogs) is 0. Using default example: 1024/32 -> oc_group=32, ogs=32")
            default_rmsnorm_oc_group = 32
            default_rmsnorm_ogs = 32
            generate_rmsnorm_data(abs_base_op_val_dir, default_rmsnorm_oc_group, args.rmsnorm_seq_len, default_rmsnorm_ogs)
        else: 
            generate_rmsnorm_data(abs_base_op_val_dir, args.rmsnorm_oc_group, args.rmsnorm_seq_len, args.rmsnorm_ogs)

    if args.op_type == 'softmax' or args.op_type == 'all':
        print("\nGenerating Softmax data...")
        generate_softmax_data(abs_base_op_val_dir, args.softmax_oc_group, args.softmax_seq_len, args.softmax_ogs)

    if args.op_type == 'swish' or args.op_type == 'all':
        print("\nGenerating Swish data...")
        generate_swish_data(abs_base_op_val_dir, args.swish_oc_group, args.swish_num_data, args.swish_ogs)

    if args.op_type == 'llama_block' or args.op_type == 'all':
        print("\nGenerating Llama Block data...")
        generate_llama_block_data(
            abs_base_op_val_dir,
            args.llama_seq_len,
            args.llama_d_model,
            args.llama_intermediate_size,
            args.llama_head_num
        )

    print("\nData generation script finished.")
