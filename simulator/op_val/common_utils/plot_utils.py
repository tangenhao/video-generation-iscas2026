import matplotlib.pyplot as plt
import pandas as pd
import os
import numpy as np
import sys
import json
from typing import Dict, List, Tuple, Optional, Union
from dataclasses import dataclass, asdict

# Ensure data_gen can be imported from common_utils
# This script itself is in common_utils, so direct import should work if data_gen.py is also there.
# If run from elsewhere, the path might need adjustment, but compare_*.py scripts add common_utils to sys.path.
try:
    from .data_gen import load_tensor_from_bin 
except ImportError:
    # Fallback if run as a script directly from common_utils for testing, or if . is not recognized.
    try:
        from data_gen import load_tensor_from_bin
    except ImportError:
        print("Error: Failed to import load_tensor_from_bin from data_gen. Ensure data_gen.py is in the same directory or accessible via sys.path.")
        sys.exit(1)

@dataclass
class OutlierPoint:
    """单个离群点的数据结构"""
    index: Tuple[int, ...]  # 多维索引
    flat_index: int         # 扁平化索引
    ref_value: float        # 参考值
    dut_value: float        # 实际值 (Device Under Test)
    absolute_error: float   # 绝对误差
    relative_error: float   # 相对误差
    error_type: str         # 误差类型: "absolute", "relative", "both"

@dataclass
class OutlierAnalysis:
    """离群点分析结果"""
    total_elements: int
    outlier_count: int
    outlier_percentage: float
    absolute_threshold: float
    relative_threshold: float
    epsilon_for_relative: float
    outliers: List[OutlierPoint]
    statistics: Dict[str, float]

def plot_performance_comparison(csv_file_path: str, output_dir: str):
    """
    Plots performance (throughput, latency) comparison from a CSV file.
    Assumes CSV has columns like 'Operator', 'InputConfig', 'FPGATput', 'PytorchTput', 'FPGALatency', 'PytorchLatency'.
    Adjust column names as per your actual CSV.
    """
    # TODO: Implement actual plotting logic based on CSV structure
    print(f"Placeholder: Plotting performance from {csv_file_path} to {output_dir}")
    # Example:
    # df = pd.read_csv(csv_file_path)
    # fig, ax = plt.subplots(1, 2, figsize=(15, 5))
    # df.plot(x='InputConfig', y=['FPGATput', 'PytorchTput'], kind='bar', ax=ax[0], title='Throughput Comparison')
    # df.plot(x='InputConfig', y=['FPGALatency', 'PytorchLatency'], kind='bar', ax=ax[1], title='Latency Comparison')
    # plt.tight_layout()
    # os.makedirs(output_dir, exist_ok=True)
    # plt.savefig(os.path.join(output_dir, 'performance_comparison.png'))
    # plt.close()

def plot_accuracy_metrics(csv_file_path: str, output_dir: str):
    """
    Plots accuracy metrics (errors, cosine similarity) from a CSV file.
    Assumes CSV has columns like 'Operator', 'InputConfig', 'MaxAbsError', 'MeanAbsError', 'CosineSimilarity'.
    Adjust column names as per your actual CSV.
    """
    # TODO: Implement actual plotting logic based on CSV structure
    print(f"Placeholder: Plotting accuracy from {csv_file_path} to {output_dir}")

def calculate_numerical_metrics(tensor_ref: np.ndarray, tensor_dut: np.ndarray, 
                               epsilon_for_relative_error=1e-9,
                               outlier_absolute_threshold: float = None,
                               outlier_relative_threshold: float = None,
                               output_dir: str = None):
    """
    Calculates various numerical difference metrics between a reference tensor and a 
    Device Under Test (DUT) tensor. Optionally performs outlier analysis.
    """
    if tensor_ref.shape != tensor_dut.shape:
        raise ValueError(f"Tensor shapes do not match: Ref {tensor_ref.shape}, DUT {tensor_dut.shape}")

    diff = tensor_ref - tensor_dut
    abs_diff = np.abs(diff)

    mse = np.mean(diff**2)
    mae = np.mean(abs_diff)
    max_abs_err = np.max(abs_diff)

    denominator = np.abs(tensor_ref) + epsilon_for_relative_error
    relative_diff = abs_diff / denominator
    max_rel_err = np.max(relative_diff) 
    mean_rel_err = np.mean(relative_diff)
    
    flat_ref = tensor_ref.flatten()
    flat_dut = tensor_dut.flatten()
    dot_product = np.dot(flat_ref, flat_dut)
    norm_ref = np.linalg.norm(flat_ref)
    norm_dut = np.linalg.norm(flat_dut)
    
    cosine_similarity_val = 0.0
    if norm_ref == 0 and norm_dut == 0: 
        cosine_similarity_val = 1.0
    elif norm_ref == 0 or norm_dut == 0: 
        cosine_similarity_val = 0.0 
    else:
        cosine_similarity_val = dot_product / (norm_ref * norm_dut)

    # Check for NaNs/Infs
    any_nan_ref = np.any(np.isnan(tensor_ref))
    any_inf_ref = np.any(np.isinf(tensor_ref))
    any_nan_dut = np.any(np.isnan(tensor_dut))
    any_inf_dut = np.any(np.isinf(tensor_dut))

    metrics = {
        "mse": float(mse),
        "mae": float(mae),
        "max_absolute_error": float(max_abs_err),
        "absolute_error_array": abs_diff,             # Store full absolute error array
        "max_relative_error": float(max_rel_err),
        "mean_relative_error": float(mean_rel_err),         # Add to metrics
        "relative_error_array": relative_diff,         # Store full relative error array
        "cosine_similarity": float(cosine_similarity_val),
        "num_elements": int(tensor_ref.size),
        "ref_mean": float(np.mean(tensor_ref)),
        "dut_mean": float(np.mean(tensor_dut)),
        "ref_std": float(np.std(tensor_ref)),
        "dut_std": float(np.std(tensor_dut)),
        "epsilon_for_relative_error": float(epsilon_for_relative_error), # Store epsilon
        "any_nan_ref": bool(any_nan_ref),
        "any_inf_ref": bool(any_inf_ref),
        "any_nan_dut": bool(any_nan_dut),
        "any_inf_dut": bool(any_inf_dut),
    }
    
    # 如果指定了离群点阈值并且提供了输出目录，进行离群点分析
    if (outlier_absolute_threshold is not None or outlier_relative_threshold is not None) and output_dir:
        # 设置默认阈值
        abs_thresh = outlier_absolute_threshold if outlier_absolute_threshold is not None else max_abs_err * 0.1
        rel_thresh = outlier_relative_threshold if outlier_relative_threshold is not None else max_rel_err * 0.1
        
        # 进行离群点分析
        outlier_analysis = generate_outlier_analysis_and_plots(
            tensor_ref, tensor_dut, output_dir,
            absolute_threshold=abs_thresh,
            relative_threshold=rel_thresh,
            epsilon_for_relative_error=epsilon_for_relative_error
        )
        
        # 将离群点信息添加到metrics中
        metrics["outlier_analysis"] = {
            "outlier_count": outlier_analysis.outlier_count,
            "outlier_percentage": outlier_analysis.outlier_percentage,
            "absolute_threshold": outlier_analysis.absolute_threshold,
            "relative_threshold": outlier_analysis.relative_threshold,
            "outlier_statistics": outlier_analysis.statistics
        }
    
    return metrics

def find_outliers(tensor_ref: np.ndarray, 
                  tensor_dut: np.ndarray,
                  absolute_threshold: float = 1e-3,
                  relative_threshold: float = 0.1,
                  epsilon_for_relative_error: float = 1e-9,
                  max_outliers: int = 1000) -> OutlierAnalysis:
    """
    识别超过阈值的离群点
    
    Args:
        tensor_ref: 参考张量
        tensor_dut: 待测张量 
        absolute_threshold: 绝对误差阈值
        relative_threshold: 相对误差阈值
        epsilon_for_relative_error: 计算相对误差时的小数值保护
        max_outliers: 最大记录的离群点数量
        
    Returns:
        OutlierAnalysis: 离群点分析结果
    """
    if tensor_ref.shape != tensor_dut.shape:
        raise ValueError(f"Tensor shapes do not match: Ref {tensor_ref.shape}, DUT {tensor_dut.shape}")
    
    # 计算误差
    diff = tensor_ref - tensor_dut
    abs_diff = np.abs(diff)
    denominator = np.abs(tensor_ref) + epsilon_for_relative_error
    rel_diff = abs_diff / denominator
    
    # 找到超过阈值的点
    abs_outliers = abs_diff > absolute_threshold
    rel_outliers = rel_diff > relative_threshold
    all_outliers = abs_outliers | rel_outliers
    
    # 获取离群点的索引
    outlier_indices = np.where(all_outliers)
    outlier_flat_indices = np.ravel_multi_index(outlier_indices, tensor_ref.shape)
    
    outliers = []
    outlier_count = len(outlier_flat_indices)
    
    # 构建所有离群点的信息用于排序
    temp_outliers = []
    for i, flat_idx in enumerate(outlier_flat_indices):
        multi_idx = tuple(idx[i] for idx in outlier_indices)
        
        ref_val = tensor_ref[multi_idx]
        dut_val = tensor_dut[multi_idx]
        abs_err = abs_diff[multi_idx]
        rel_err = rel_diff[multi_idx]
        
        temp_outliers.append({
            'flat_index': int(flat_idx),
            'multi_index': tuple(int(x) for x in multi_idx),
            'ref_value': float(ref_val),
            'dut_value': float(dut_val),
            'absolute_error': float(abs_err),
            'relative_error': float(rel_err)
        })
    
    # 按照相对误差优先、绝对误差次之的顺序排序（从高到低）
    temp_outliers.sort(key=lambda x: (-x['relative_error'], -x['absolute_error']))
    
    # 如果离群点太多，只保留前N个
    if outlier_count > max_outliers:
        temp_outliers = temp_outliers[:max_outliers]
    
    # 构建离群点列表
    outliers = []
    for temp_outlier in temp_outliers:
        # 确定误差类型
        abs_err = temp_outlier['absolute_error']
        rel_err = temp_outlier['relative_error']
        
        is_abs_outlier = abs_err > absolute_threshold
        is_rel_outlier = rel_err > relative_threshold
        
        if is_abs_outlier and is_rel_outlier:
            error_type = "both"
        elif is_abs_outlier:
            error_type = "absolute"
        else:
            error_type = "relative"
        
        outlier = OutlierPoint(
            index=temp_outlier['multi_index'],
            flat_index=temp_outlier['flat_index'],
            ref_value=temp_outlier['ref_value'],
            dut_value=temp_outlier['dut_value'],
            absolute_error=temp_outlier['absolute_error'],
            relative_error=temp_outlier['relative_error'],
            error_type=error_type
        )
        outliers.append(outlier)
    
    # 计算统计信息
    if outliers:
        abs_errors = [o.absolute_error for o in outliers]
        rel_errors = [o.relative_error for o in outliers]
        
        statistics = {
            "max_absolute_error": float(np.max(abs_errors)),
            "min_absolute_error": float(np.min(abs_errors)),
            "mean_absolute_error": float(np.mean(abs_errors)),
            "max_relative_error": float(np.max(rel_errors)),
            "min_relative_error": float(np.min(rel_errors)),
            "mean_relative_error": float(np.mean(rel_errors)),
            "std_absolute_error": float(np.std(abs_errors)),
            "std_relative_error": float(np.std(rel_errors))
        }
    else:
        statistics = {
            "max_absolute_error": 0.0,
            "min_absolute_error": 0.0,
            "mean_absolute_error": 0.0,
            "max_relative_error": 0.0,
            "min_relative_error": 0.0,
            "mean_relative_error": 0.0,
            "std_absolute_error": 0.0,
            "std_relative_error": 0.0
        }
    
    return OutlierAnalysis(
        total_elements=tensor_ref.size,
        outlier_count=outlier_count,
        outlier_percentage=float(outlier_count / tensor_ref.size * 100),
        absolute_threshold=absolute_threshold,
        relative_threshold=relative_threshold,
        epsilon_for_relative=epsilon_for_relative_error,
        outliers=outliers,
        statistics=statistics
    )

def save_outlier_analysis_json(analysis: OutlierAnalysis, 
                              output_path: str,
                              include_detailed_outliers: bool = True) -> None:
    """
    保存离群点分析结果到JSON文件
    
    Args:
        analysis: 离群点分析结果
        output_path: 输出文件路径
        include_detailed_outliers: 是否包含详细的离群点列表
    """
    # 确保输出目录存在
    output_dir = os.path.dirname(output_path)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
    
    # 转换为字典
    data = asdict(analysis)
    
    if not include_detailed_outliers:
        # 如果不需要详细列表，只保留统计信息
        data["outliers"] = f"共 {len(data['outliers'])} 个离群点 (详细信息已省略)"
    
    # 添加元数据
    data["metadata"] = {
        "analysis_type": "outlier_detection",
        "version": "1.0",
        "description": "离群点分析结果",
        "total_outliers_found": analysis.outlier_count,
        "outliers_shown": len(analysis.outliers),
        "truncated": analysis.outlier_count > len(analysis.outliers)
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"Outlier analysis saved to: {output_path}")

def plot_outlier_distribution(analysis: OutlierAnalysis, 
                             output_dir: str,
                             tensor_ref: Optional[np.ndarray] = None,
                             tensor_dut: Optional[np.ndarray] = None):
    """
    生成离群点分布图表
    
    Args:
        analysis: 离群点分析结果
        output_dir: 输出目录
        tensor_ref: 参考张量（可选，用于生成更详细的图表）
        tensor_dut: 待测张量（可选，用于生成更详细的图表）
    """
    os.makedirs(output_dir, exist_ok=True)
    
    if not analysis.outliers:
        print("No outliers found, skipping outlier distribution plots.")
        return
    
    # 1. 离群点绝对误差分布
    abs_errors = [o.absolute_error for o in analysis.outliers]
    plt.figure(figsize=(10, 6))
    plt.hist(abs_errors, bins=50, edgecolor='black', alpha=0.7, color='red')
    plt.title(f'Outlier Absolute Error Distribution\n({len(abs_errors)} outliers, {analysis.outlier_percentage:.3f}% of total)')
    plt.xlabel('Absolute Error')
    plt.ylabel('Frequency')
    plt.yscale('log')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'outlier_absolute_error_distribution.png'), dpi=150)
    plt.close()
    
    # 2. 离群点相对误差分布
    rel_errors = [o.relative_error for o in analysis.outliers]
    plt.figure(figsize=(10, 6))
    plt.hist(rel_errors, bins=50, edgecolor='black', alpha=0.7, color='orange')
    plt.title(f'Outlier Relative Error Distribution\n({len(rel_errors)} outliers, {analysis.outlier_percentage:.3f}% of total)')
    plt.xlabel('Relative Error')
    plt.ylabel('Frequency')
    plt.yscale('log')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'outlier_relative_error_distribution.png'), dpi=150)
    plt.close()
    
    # 3. 离群点散点图（参考值 vs 实际值）
    ref_values = [o.ref_value for o in analysis.outliers]
    dut_values = [o.dut_value for o in analysis.outliers]
    
    plt.figure(figsize=(10, 10))
    plt.scatter(ref_values, dut_values, alpha=0.6, s=20, c='red', edgecolors='black', linewidth=0.5)
    
    # 添加理想线 y=x
    min_val = min(min(ref_values), min(dut_values))
    max_val = max(max(ref_values), max(dut_values))
    plt.plot([min_val, max_val], [min_val, max_val], 'k--', lw=2, label='y=x (Ideal)')
    
    plt.title(f'Outlier Values: DUT vs Reference\n({len(ref_values)} outliers)')
    plt.xlabel('Reference Values')
    plt.ylabel('DUT Values')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.axis('equal')
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'outlier_scatter_plot.png'), dpi=150)
    plt.close()
    
    # 4. 误差类型分布饼图
    error_types = [o.error_type for o in analysis.outliers]
    type_counts = {}
    for et in error_types:
        type_counts[et] = type_counts.get(et, 0) + 1
    
    if type_counts:
        plt.figure(figsize=(8, 8))
        colors = {'absolute': 'lightcoral', 'relative': 'lightskyblue', 'both': 'lightgreen'}
        plot_colors = [colors.get(t, 'gray') for t in type_counts.keys()]
        
        plt.pie(type_counts.values(), labels=type_counts.keys(), autopct='%1.1f%%', 
                colors=plot_colors, startangle=90)
        plt.title(f'Outlier Error Type Distribution\n(Total: {len(analysis.outliers)} outliers)')
        plt.tight_layout()
        plt.savefig(os.path.join(output_dir, 'outlier_error_type_distribution.png'), dpi=150)
        plt.close()
    
    print(f"Outlier distribution plots saved to: {output_dir}")

def generate_outlier_analysis_and_plots(tensor_ref: np.ndarray,
                                       tensor_dut: np.ndarray,
                                       output_dir: str,
                                       absolute_threshold: float = 1e-3,
                                       relative_threshold: float = 0.1,
                                       epsilon_for_relative_error: float = 1e-9,
                                       max_outliers: int = 1000,
                                       include_detailed_outliers: bool = True) -> OutlierAnalysis:
    """
    完整的离群点分析和可视化流程
    
    Args:
        tensor_ref: 参考张量
        tensor_dut: 待测张量
        output_dir: 输出目录
        absolute_threshold: 绝对误差阈值
        relative_threshold: 相对误差阈值
        epsilon_for_relative_error: 相对误差计算的epsilon
        max_outliers: 最大记录的离群点数量
        include_detailed_outliers: JSON中是否包含详细的离群点列表
        
    Returns:
        OutlierAnalysis: 离群点分析结果
    """
    # 进行离群点分析
    analysis = find_outliers(tensor_ref, tensor_dut, 
                           absolute_threshold, relative_threshold, 
                           epsilon_for_relative_error, max_outliers)
    
    # 保存JSON结果
    json_path = os.path.join(output_dir, "outlier_analysis.json")
    save_outlier_analysis_json(analysis, json_path, include_detailed_outliers)
    
    # 生成可视化图表
    plot_outlier_distribution(analysis, output_dir, tensor_ref, tensor_dut)
    
    # 打印简要报告
    print(f"\n--- Outlier Analysis Summary ---")
    print(f"Total elements: {analysis.total_elements:,}")
    print(f"Outliers found: {analysis.outlier_count:,} ({analysis.outlier_percentage:.4f}%)")
    print(f"Absolute threshold: {analysis.absolute_threshold:.2e}")
    print(f"Relative threshold: {analysis.relative_threshold:.2e}")
    
    if analysis.outliers:
        stats = analysis.statistics
        print(f"Max absolute error: {stats['max_absolute_error']:.6e}")
        print(f"Max relative error: {stats['max_relative_error']:.6e}")
    
    return analysis

def print_numerical_metrics_report(metrics: dict):
    """Prints a formatted report of the numerical metrics."""
    print("\n--- Numerical Accuracy Metrics ---")
    print(f"  Number of Elements:     {metrics['num_elements']}")
    print(f"  Mean Squared Error (MSE): {metrics['mse']:.6e}")
    print(f"  Mean Absolute Error (MAE):{metrics['mae']:.6e}")
    print(f"  Max Absolute Error:       {metrics['max_absolute_error']:.6e}")
    print(f"  Max Relative Error:       {metrics['max_relative_error']:.6e} (epsilon={metrics.get('epsilon_for_relative_error', 'N/A'):.1e})")
    print(f"  Mean Relative Error:      {metrics['mean_relative_error']:.6e} (epsilon={metrics.get('epsilon_for_relative_error', 'N/A'):.1e})")
    print(f"  Cosine Similarity:        {metrics['cosine_similarity']:.8f}")
    print("\n  Reference Tensor Stats:")
    print(f"    Mean:                   {metrics['ref_mean']:.6e}")
    print(f"    Std Dev:                {metrics['ref_std']:.6e}")
    print(f"    NaNs:                   {metrics['any_nan_ref']}")
    print(f"    Infs:                   {metrics['any_inf_ref']}")
    print("  DUT Tensor Stats:")
    print(f"    Mean:                   {metrics['dut_mean']:.6e}")
    print(f"    Std Dev:                {metrics['dut_std']:.6e}")
    print(f"    NaNs:                   {metrics['any_nan_dut']}")
    print(f"    Infs:                   {metrics['any_inf_dut']}")
    print("----------------------------------")

def plot_scatter_comparison(tensor_dut: np.ndarray, tensor_ref: np.ndarray, # Swapped order to DUT, REF
                            title: str = "Scatter Plot: DUT vs. Reference", 
                            save_path: str = "scatter_comparison.png"):
    """
    Generates and saves a scatter plot comparing DUT tensor against reference tensor.
    Note: Order of arguments is DUT then Reference.
    """
    # Ensure the directory for save_path exists
    output_dir = os.path.dirname(save_path)
    if output_dir: # Check if output_dir is not empty (i.e., not saving in current dir)
        os.makedirs(output_dir, exist_ok=True)

    plt.figure(figsize=(8, 8))
    ref_flat = tensor_ref.flatten()
    dut_flat = tensor_dut.flatten()
    
    sample_size = 10000
    if ref_flat.size > sample_size:
        indices = np.random.choice(ref_flat.size, sample_size, replace=False)
        ref_flat_sample = ref_flat[indices]
        dut_flat_sample = dut_flat[indices]
    else:
        ref_flat_sample = ref_flat
        dut_flat_sample = dut_flat

    # Scatter plot: DUT (y-axis) vs Reference (x-axis)
    plt.scatter(ref_flat_sample, dut_flat_sample, alpha=0.5, s=10, edgecolors='k', linewidths=0.5)
    
    min_val = min(np.min(ref_flat_sample), np.min(dut_flat_sample))
    max_val = max(np.max(ref_flat_sample), np.max(dut_flat_sample))
    plt.plot([min_val, max_val], [min_val, max_val], 'r--', lw=2, label='y=x (Ideal Match)')
    
    plt.title(title)
    plt.xlabel("Reference Values")
    plt.ylabel("DUT Values") # Changed from "DUT (C++) Values" for generality
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.legend()
    plt.axis('equal') 
    plt.tight_layout()
    plt.savefig(save_path)
    plt.close()
    print(f"Scatter plot saved to: {save_path}")

def plot_error_histogram(errors: np.ndarray, 
                         title: str = "Error Distribution", 
                         save_path: str = "error_histogram.png",
                         bins: int = 50):
    """
    Generates and saves a histogram of the provided error array.
    """
    output_dir = os.path.dirname(save_path)
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)

    plt.figure(figsize=(10, 6))
    plt.hist(errors.flatten(), bins=bins, edgecolor='black', alpha=0.7)
    plt.title(title)
    plt.xlabel("Error Value") # Generic xlabel, title should specify if absolute/relative
    plt.ylabel("Frequency")
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.yscale('log') 
    plt.tight_layout()
    plt.savefig(save_path)
    plt.close()
    print(f"Error histogram saved to: {save_path}")

if __name__ == '__main__':
    print("Plotting utilities for operator verification.")
    
    dummy_shape = (2, 3, 4)
    dummy_dtype = np.float32
    
    test_data_dir = os.path.join(os.path.dirname(__file__), "test_data_plot_utils")
    os.makedirs(test_data_dir, exist_ok=True)
    
    ref_file = os.path.join(test_data_dir, "dummy_ref.bin")
    dut_file = os.path.join(test_data_dir, "dummy_dut.bin")
    
    current_epsilon = 1e-6 # Example epsilon

    if not os.path.exists(ref_file) or not os.path.exists(dut_file):
        print(f"Generating dummy data in {test_data_dir} for plot_utils.py example...")
        dummy_ref_data = np.random.rand(*dummy_shape).astype(dummy_dtype)
        dummy_dut_data = dummy_ref_data + np.random.normal(0, 0.01, size=dummy_shape).astype(dummy_dtype) 
        dummy_dut_data[0,0,0] += 0.1
        dummy_dut_data[1,1,1] -= 0.05

        dummy_ref_data.tofile(ref_file)
        dummy_dut_data.tofile(dut_file)
        print("Dummy .bin files created.")

    try:
        print(f"\nLoading dummy reference tensor from: {ref_file}")
        ref_tensor = load_tensor_from_bin(ref_file, shape=dummy_shape, dtype=dummy_dtype)
        print(f"Loading dummy DUT tensor from: {dut_file}")
        dut_tensor = load_tensor_from_bin(dut_file, shape=dummy_shape, dtype=dummy_dtype)

        print("\nCalculating metrics...")
        # Pass epsilon here
        metrics = calculate_numerical_metrics(ref_tensor, dut_tensor, epsilon_for_relative_error=current_epsilon)
        # metrics dictionary now contains 'epsilon_for_relative_error'
        print_numerical_metrics_report(metrics)

        charts_output_dir = os.path.join(test_data_dir, "charts")
        # No need to create charts_output_dir here, plot functions will do it via os.path.dirname(save_path)

        print("\nGenerating plots...")
        # For scatter plot, the typical convention is (DUT, Ref) or (x,y) -> (Ref, DUT)
        # My previous compare scripts used (DUT, Ref) for the call.
        # The plot_scatter_comparison here has (tensor_ref, tensor_dut, ...)
        # I'll adjust the call in the example to match its current signature (ref, dut)
        # And in compare_*.py I pass (cpp_tensor, ref_tensor), so plot_scatter_comparison should be (dut, ref)
        # I've updated plot_scatter_comparison signature to (tensor_dut, tensor_ref, ...)
        plot_scatter_comparison(dut_tensor, ref_tensor,  # DUT first, then Ref
                                title="Example: DUT vs. Reference", 
                                save_path=os.path.join(charts_output_dir, "example_scatter.png"))
        
        plot_error_histogram(metrics['absolute_error_array'], 
                             title="Example: Absolute Error Distribution", 
                             save_path=os.path.join(charts_output_dir, "example_hist_absolute_error.png"))
                             
        plot_error_histogram(metrics['relative_error_array'], 
                             title=f"Example: Relative Error Distribution (epsilon={metrics['epsilon_for_relative_error']:.1e})",
                             save_path=os.path.join(charts_output_dir, "example_hist_relative_error.png"))
        print("\nplot_utils.py example finished.")

    except FileNotFoundError as e:
        print(f"Error: {e}. Could not run example as dummy data is missing and generation failed or was skipped.")
    except Exception as e:
        print(f"An unexpected error occurred during the example: {e}") 