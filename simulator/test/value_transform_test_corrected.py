#!/usr/bin/env python3
"""
Value Transform 函数验证脚本
对比手工实现的三步变换与使用 reshape/permute 的直接实现
"""

import numpy as np
import torch

def value_transform_manual(value, num_head, d_model):
    """
    手工实现的三步变换，模拟 C++ 中的逻辑
    输入形状: [d_model/n_group_size, seq_len, n_group_size]
    输出形状: [head_num, d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size]
    """
    d_h = d_model // num_head
    seq_len = value.shape[1]
    k_group_size = 16
    n_group_size = 32
    
    print(f"Input shape: {value.shape}")
    print(f"d_h: {d_h}, seq_len: {seq_len}")
    
    # Step 1: [d_model/n_group_size, seq_len, n_group_size] -> [seq_len/n_group_size, d_model, n_group_size]
    value_step1 = np.zeros((seq_len // n_group_size, d_model, n_group_size), dtype=np.float32)
    
    for seq_iter in range(seq_len // n_group_size):
        for d_iter in range(d_model // n_group_size):
            for n in range(n_group_size):
                for seq_in_group in range(n_group_size):
                    out_idx = seq_iter * d_model * n_group_size + d_iter * n_group_size * n_group_size + n * n_group_size + seq_in_group
                    in_idx = d_iter * seq_len * n_group_size + (seq_iter * n_group_size + seq_in_group) * n_group_size + n
                    value_step1.flat[out_idx] = value.flat[in_idx]
    
    print(f"Step 1 shape: {value_step1.shape}")
    
    # Step 2: [seq_len/n_group_size, d_model, n_group_size] -> [seq_len/k_group_size, d_model, k_group_size]
    value_step2 = np.zeros((seq_len // k_group_size, d_model, k_group_size), dtype=np.float16)
    
    for seq_iter in range(seq_len // n_group_size):
        for d_iter in range(d_model):
            for n in range(n_group_size):
                in_idx = seq_iter * d_model * n_group_size + d_iter * n_group_size + n
                
                out_seq_iter = seq_iter * 2 + (1 if n >= k_group_size else 0)
                out_k = n - k_group_size if n >= k_group_size else n
                out_idx = out_seq_iter * d_model * k_group_size + d_iter * k_group_size + out_k
                
                value_step2.flat[out_idx] = np.float16(value_step1.flat[in_idx])
    
    print(f"Step 2 shape: {value_step2.shape}")
    
    # Step 3: [seq_len/k_group_size, d_model, k_group_size] -> [head_num, d_h/n_group_size, seq_len/k_group_size, n_group_size, k_group_size]
    output_hf = np.zeros((num_head, d_h // n_group_size, seq_len // k_group_size, n_group_size, k_group_size), dtype=np.float16)
    
    for head in range(num_head):
        for d_iter in range(d_h // n_group_size):
            for seq_iter in range(seq_len // k_group_size):
                for n in range(n_group_size):
                    for k in range(k_group_size):
                        out_idx = (head * (d_h // n_group_size) * (seq_len // k_group_size) * n_group_size * k_group_size
                                 + d_iter * (seq_len // k_group_size) * n_group_size * k_group_size
                                 + seq_iter * n_group_size * k_group_size
                                 + n * k_group_size + k)
                        
                        # 计算在原始 d_model 维度中的全局位置
                        d_global = head * d_h + d_iter * n_group_size + n
                        in_idx = seq_iter * d_model * k_group_size + d_global * k_group_size + k
                        
                        if in_idx < value_step2.size:
                            output_hf.flat[out_idx] = value_step2.flat[in_idx]
    
    print(f"Final output shape: {output_hf.shape}")
    return output_hf

def value_transform_pytorch(value, num_head, d_model):
    """
    使用 PyTorch 的 reshape 和 permute 实现相同的变换
    这个版本更严格地遵循 C++ 的逻辑
    """
    value = torch.from_numpy(value)
    
    d_h = d_model // num_head
    seq_len = value.shape[1]
    k_group_size = 16
    n_group_size = 32
    
    print(f"\nPyTorch version:")
    print(f"Input shape: {value.shape}")
    
    # [d_model/n_group_size, seq_len, n_group_size],fp32 -> [seq_len/k_group_size, d_model, k_group_size],fp16
    value_step1 = torch.zeros((seq_len // n_group_size, d_model, n_group_size), dtype=value.dtype)
    value_step1 = value.permute(1, 0, 2).reshape(seq_len, d_model).reshape(seq_len // k_group_size, k_group_size, d_model).permute(0, 2, 1)
    print(f"Step 1 shape: {value_step1.shape}")

    value_step2 = value_step1.to(torch.float16)
    print(f"Step 2 shape: {value_step2.shape}")

    value_transform = value_step2.reshape(seq_len // k_group_size, d_model // n_group_size, n_group_size, k_group_size).permute(1, 0, 2, 3)
    output_hf = value_transform.reshape(num_head, d_h // n_group_size, seq_len // k_group_size, n_group_size, k_group_size)
    print(f"Final output shape: {output_hf.shape}")
    return output_hf.numpy()

def compare_results(result1, result2, tolerance=1e-5):
    """比较两个结果的差异"""
    print(f"\n=== 结果比较 ===")
    print(f"Manual result shape: {result1.shape}")
    print(f"PyTorch result shape: {result2.shape}")
    
    if result1.shape != result2.shape:
        print("❌ 形状不匹配!")
        return False
    
    diff = np.abs(result1 - result2)
    max_diff = np.max(diff)
    mean_diff = np.mean(diff)
    
    print(f"最大差异: {max_diff}")
    print(f"平均差异: {mean_diff}")
    print(f"相对误差: {max_diff / (np.max(np.abs(result1)) + 1e-8)}")
    
    if max_diff < tolerance:
        print("✅ 结果匹配!")
        return True
    else:
        print("❌ 结果不匹配!")
        # 显示前几个不匹配的元素
        mismatch_indices = np.where(diff > tolerance)
        if len(mismatch_indices[0]) > 0:
            print("不匹配的元素:")
            for i in range(min(5, len(mismatch_indices[0]))):
                idx = tuple(m[i] for m in mismatch_indices)
                print(f"  位置 {idx}: manual={result1[idx]}, pytorch={result2[idx]}, diff={diff[idx]}")
        return False

def main():
    # 测试参数
    num_head = 4
    seq_len = 64
    d_model = 256
    k_group_size = 16
    n_group_size = 32
    
    print(f"测试参数:")
    print(f"num_head: {num_head}")
    print(f"seq_len: {seq_len}")
    print(f"d_model: {d_model}")
    print(f"k_group_size: {k_group_size}")
    print(f"n_group_size: {n_group_size}")
    print()
    
    # 创建测试数据
    np.random.seed(42)
    input_shape = (d_model // n_group_size, seq_len, n_group_size)
    value_input = np.random.randn(*input_shape).astype(np.float32)
    
    print("=" * 50)
    print("手工实现 (模拟 C++ 逻辑)")
    print("=" * 50)
    result_manual = value_transform_manual(value_input.copy(), num_head, d_model)
    
    print("\n" + "=" * 50)
    print("PyTorch 实现 (reshape + permute)")
    print("=" * 50)
    result_pytorch = value_transform_pytorch(value_input.copy(), num_head, d_model)
    
    # 比较结果
    compare_results(result_manual, result_pytorch)
    
    # 额外的形状验证
    d_h = d_model // num_head
    expected_shape = (num_head, d_h // n_group_size, seq_len // k_group_size, n_group_size, k_group_size)
    print(f"\n期望的输出形状: {expected_shape}")
    print(f"手工实现形状: {result_manual.shape}")
    print(f"PyTorch 实现形状: {result_pytorch.shape}")
    
    if result_manual.shape == expected_shape and result_pytorch.shape == expected_shape:
        print("✅ 输出形状正确!")
    else:
        print("❌ 输出形状不正确!")

if __name__ == "__main__":
    main()
