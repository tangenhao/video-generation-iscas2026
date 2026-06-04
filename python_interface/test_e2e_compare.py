"""
NPU算子端到端测试 - 重构版
真正有意义的验证：NPU仿真 vs PyTorch参考实现

按照重构思路：
1. 生成标准测试数据
2. 运行PyTorch参考实现 (Golden Reference)  
3. 运行NPU仿真实现
4. 精度对比与详细分析
5. 生成可视化报告
"""

import sys
import os
import json
import time
import logging
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any
import numpy as np
import torch

# 添加路径
current_dir = Path(__file__).parent
sys.path.append(str(current_dir.parent))
sys.path.append(str(current_dir.parent / "simulator" / "op_val" / "common_utils"))
sys.path.append(str(current_dir.parent / "simulator" / "op_val" / "gemm_fp16" / "pytorch_ref"))
sys.path.append(str(current_dir.parent / "simulator" / "op_val" / "rmsnorm_fp32" / "pytorch_ref"))
sys.path.append(str(current_dir.parent / "simulator" / "op_val" / "softmax_fp32" / "pytorch_ref"))
sys.path.append(str(current_dir.parent / "simulator" / "op_val" / "llama_block" / "pytorch_ref"))

# 导入NPU接口
from npu_ops import (
    gemm_sim_from_files,
    rmsnorm_sim_from_files, 
    softmax_sim_from_files,
    llama_block_sim_from_files,
)
from npu_ops.data_io import TensorIO, DataValidator

# 导入common_utils工具集
from data_gen import generate_random_tensor, save_tensor_to_bin, load_tensor_from_bin
from plot_utils import (
    calculate_numerical_metrics,
    print_numerical_metrics_report,
    plot_scatter_comparison,
    plot_error_histogram,
    generate_outlier_analysis_and_plots,
    OutlierAnalysis
)

# 导入PyTorch参考实现
from gemm_pytorch import gemm_pytorch_fp16
from rmsnorm_pytorch import rmsnorm_pytorch_fp32
from softmax_pytorch import softmax_pytorch_fp32
from llama_block_pytorch import llama_block_pytorch

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def generate_freq_cls(seq_len: int, d_head: int) -> np.ndarray:
    """
    生成RoPE频率系数张量 (参考C++实现的generate_freq_cls)
    
    Args:
        seq_len: 序列长度
        d_head: 注意力头维度
        
    Returns:
        频率系数张量 [d_head/n_group_size, seq_len, n_group_size]，其中 n_group_size=32
    """
    n_group_size = 32
    d_group = d_head // n_group_size
    
    # 创建基础频率系数 
    inv_freq = 1.0 / (10000.0 ** (np.arange(0, d_head, 2).astype(np.float32) / d_head))
    
    # 生成位置索引
    position = np.arange(seq_len, dtype=np.float32)
    
    # 计算频率矩阵 [seq_len, d_head//2]
    freqs = np.outer(position, inv_freq)
    
    # 生成cos和sin值 [seq_len, d_head//2]
    cos_freqs = np.cos(freqs).astype(np.float32)
    sin_freqs = np.sin(freqs).astype(np.float32)
    
    # 交替排列cos和sin，生成完整的频率张量 [seq_len, d_head]
    freq_cls_original = np.zeros((seq_len, d_head), dtype=np.float32)
    freq_cls_original[:, 0::2] = cos_freqs  # 偶数位置放cos
    freq_cls_original[:, 1::2] = sin_freqs  # 奇数位置放sin
    
    # 转换为NPU期望的分组格式 [d_head/n_group_size, seq_len, n_group_size]
    freq_cls_transformed = np.zeros((d_group, seq_len, n_group_size), dtype=np.float32)
    
    for d_iter in range(d_group):
        for seq in range(seq_len):
            for n in range(n_group_size):
                out_idx = d_iter * seq_len * n_group_size + seq * n_group_size + n
                in_idx = seq * d_head + d_iter * n_group_size + n
                freq_cls_transformed.flat[out_idx] = freq_cls_original.flat[in_idx]
    
    return freq_cls_transformed

def generate_causal_mask(seq_len: int, num_head: int) -> np.ndarray:
    """
    生成因果掩码张量 (参考C++实现的CausalMask)
    
    Args:
        seq_len: 序列长度
        num_head: 注意力头数
        
    Returns:
        因果掩码张量 [num_head, seq_len/n_group_size, seq_len, n_group_size]，其中 n_group_size=32
    """
    n_group_size = 32
    seq_group = seq_len // n_group_size
    
    # 1. 创建原始因果掩码 [seq_len, seq_len]
    mask_head_original = np.zeros((seq_len, seq_len), dtype=np.float32)
    for i in range(seq_len):
        for j in range(seq_len):
            if i < j:
                mask_head_original[i, j] = -1e9  # 上三角设为负无穷
            else:
                mask_head_original[i, j] = 0.0   # 下三角（包括对角线）设为0
    
    # 2. 转换为分组格式 [seq_len/n_group_size, seq_len, n_group_size]
    mask_head_transformed = np.zeros((seq_group, seq_len, n_group_size), dtype=np.float32)
    for n_iter in range(seq_group):
        for seq in range(seq_len):
            for n in range(n_group_size):
                out_idx = n_iter * seq_len * n_group_size + seq * n_group_size + n;
                in_idx  = n_iter * n_group_size + seq * seq_len + n;
                mask_head_transformed.flat[out_idx] = mask_head_original.flat[in_idx]
    
    # 3. 复制到所有注意力头 [num_head, seq_len/n_group_size, seq_len, n_group_size]
    mask_concat = np.zeros((num_head, seq_group, seq_len, n_group_size), dtype=np.float32)
    for head in range(num_head):
        for n_iter in range(seq_group):
            for seq in range(seq_len):
                for n in range(n_group_size):
                    out_idx = head * seq_len * seq_len + n_iter * seq_len * n_group_size + seq * n_group_size + n
                    in_idx = n_iter * seq_len * n_group_size + seq * n_group_size + n
                    mask_concat.flat[out_idx] = mask_head_transformed.flat[in_idx]
    
    # print(f"生成因果掩码: shape={mask_concat.shape}, dtype={mask_concat.dtype}")
    # print(f"部分数据预览:\n{mask_concat[0, :2, :8, :8]}")
    return mask_concat

def generate_llama_block_additional_tensors(seq_len: int, hidden_size: int, num_attention_heads: int, 
                                           case_dir: Path) -> Dict[str, np.ndarray]:
    """
    为LlamaBlock生成额外所需的张量：freq_cls和causal_mask
    
    Args:
        seq_len: 序列长度
        hidden_size: 模型维度  
        num_attention_heads: 注意力头数
        case_dir: 测试用例目录
        
    Returns:
        生成的张量字典，包含freq_cls和causal_mask的numpy数组
    """
    d_head = hidden_size // num_attention_heads  # 每个注意力头的维度
    n_group_size = 32
    
    logger.info(f"🔧 生成LlamaBlock额外张量: seq_len={seq_len}, d_head={d_head}, num_head={num_attention_heads}")
    
    # 1. 生成单个头的freq_cls
    freq_cls_head = generate_freq_cls(seq_len, d_head)
    logger.info(f"   freq_cls_head shape: {freq_cls_head.shape}")
    
    # 2. 拼接所有头的freq_cls
    d_model_group = hidden_size // n_group_size
    freq_cls_concat = np.zeros((d_model_group, seq_len, n_group_size), dtype=np.float32)
    
    d_head_group = d_head // n_group_size
    for head in range(num_attention_heads):
        for n_iter in range(d_head_group):
            for seq_len_iter in range(seq_len):
                for n_group_iter in range(n_group_size):
                    out_idx = head * d_head * seq_len + n_iter * seq_len * n_group_size + seq_len_iter * n_group_size + n_group_iter
                    in_idx = n_iter * seq_len * n_group_size + seq_len_iter * n_group_size + n_group_iter
                    freq_cls_concat.flat[out_idx] = freq_cls_head.flat[in_idx]
    
    # 3. 生成因果掩码
    causal_mask = generate_causal_mask(seq_len, num_attention_heads)
    logger.info(f"   causal_mask shape: {causal_mask.shape}")
    
    # 4. 保存为.bin文件
    freq_cls_file = case_dir / "freq_cls_concat.bin"
    causal_mask_file = case_dir / "causal_mask_concat.bin"
    
    save_tensor_to_bin(freq_cls_concat, str(freq_cls_file))
    save_tensor_to_bin(causal_mask, str(causal_mask_file))
    
    logger.info(f"✅ 额外张量生成完成:")
    logger.info(f"   freq_cls_concat: {freq_cls_concat.shape} -> {freq_cls_file}")
    logger.info(f"   causal_mask: {causal_mask.shape} -> {causal_mask_file}")
    
    return {
        "freq_cls_concat": freq_cls_concat,
        "causal_mask": causal_mask
    }

class E2EValidator:
    """端到端验证器 - NPU vs PyTorch精度对比"""
    
    def __init__(self, config_path: Optional[str] = None):
        self.test_dir = Path("test/e2e_compare")
        self.output_dir = self.test_dir / "output"
        self.data_dir = self.test_dir / "data"
        
        # 创建目录
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.data_dir.mkdir(parents=True, exist_ok=True)
        
        # 加载配置
        if config_path is None:
            config_path = self.test_dir / "configs" / "e2e_test_config.json"
        
        with open(config_path, 'r') as f:
            self.config = json.load(f)
        
        self.test_results = {}
        
        logger.info(f"🚀 E2E验证器初始化完成")
        logger.info(f"   输出目录: {self.output_dir}")
        logger.info(f"   数据目录: {self.data_dir}")
    
    def validate_operator(self, op_name: str, npu_result: np.ndarray, 
                         pytorch_result: np.ndarray, test_case_name: str) -> bool:
        """统一的算子验证逻辑 - 完全参考op_val格式"""
        
        op_output_dir = self.output_dir / op_name / test_case_name
        op_output_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"🔍 {op_name}精度验证: {test_case_name}")
        logger.info(f"   NPU结果: {npu_result.shape}, dtype={npu_result.dtype}")
        logger.info(f"   PyTorch结果: {pytorch_result.shape}, dtype={pytorch_result.dtype}")
        
        try:
            # 获取配置参数
            op_config = self.config[op_name]
            tolerance = op_config["tolerance"]
            
            # 一次性完成所有数值分析（包含离群点分析）
            outlier_abs_threshold = tolerance.get("outlier_absolute_threshold", 1e-4)
            outlier_rel_threshold = tolerance.get("outlier_relative_threshold", 0.01)
            
            metrics = calculate_numerical_metrics(
                pytorch_result,  # reference (PyTorch)
                npu_result,      # dut (NPU)
                epsilon_for_relative_error=1e-9,
                outlier_absolute_threshold=outlier_abs_threshold,
                outlier_relative_threshold=outlier_rel_threshold,
                output_dir=str(op_output_dir)  # 自动生成所有离群点分析图表
            )
            
            # 打印详细报告
            print_numerical_metrics_report(metrics)
            
            # 生成基础对比图表
            plot_scatter_comparison(
                npu_result, pytorch_result,
                title=f"{op_name}: NPU vs PyTorch ({test_case_name})",
                save_path=str(op_output_dir / f"{op_name}_scatter_comparison.png")
            )
            # Absolute error histogram
            plot_error_histogram(
                metrics['absolute_error_array'], 
                title=f"{op_name}: Absolute Error Distribution",
                save_path=os.path.join(op_output_dir, f"{op_name}_abs_error_hist.png")
            )
            print(f"Absolute error histogram saved to {os.path.join(op_output_dir, f'{op_name}_abs_error_hist.png')}")

            # Relative error histogram
            plot_error_histogram(
                metrics['relative_error_array'], 
                title=f"{op_name}: Relative Error Distribution",
                save_path=os.path.join(op_output_dir, f"{op_name}_rel_error_hist.png")
            )
            print(f"Relative error histogram saved to {os.path.join(op_output_dir, f'{op_name}_rel_error_hist.png')}")

            # 判断是否通过
            passed = self._check_pass_criteria(metrics, tolerance)
            
            # 保存accuracy.json（完全参考op_val格式）
            self.save_accuracy_report(op_name, test_case_name, metrics, passed, op_output_dir)
            
            # 记录结果
            if op_name not in self.test_results:
                self.test_results[op_name] = {}
            self.test_results[op_name][test_case_name] = {
                "passed": passed,
                "metrics": metrics,
                "output_dir": str(op_output_dir)
            }
            
            if passed:
                logger.info(f"✅ {op_name} ({test_case_name}) 验证通过")
            else:
                logger.error(f"❌ {op_name} ({test_case_name}) 验证失败")
                self._log_failure_details(metrics, tolerance)
            
            return passed
            
        except Exception as e:
            logger.error(f"❌ {op_name} ({test_case_name}) 验证异常: {e}")
            import traceback
            logger.error(traceback.format_exc())
            return False
    
    def _check_pass_criteria(self, metrics: Dict, tolerance: Dict) -> bool:
        """检查是否通过所有标准"""
        checks = []
        
        # 基础精度检查
        checks.append(metrics["max_absolute_error"] <= tolerance["max_absolute_error"])
        checks.append(metrics["cosine_similarity"] >= tolerance["min_cosine_similarity"])
        
        # 可选的额外检查
        if "mean_absolute_error" in tolerance:
            checks.append(metrics["mae"] <= tolerance["mean_absolute_error"])
        if "max_relative_error" in tolerance:
            checks.append(metrics["max_relative_error"] <= tolerance["max_relative_error"])
        if "max_outlier_percentage" in tolerance and "outlier_percentage" in metrics:
            checks.append(metrics["outlier_percentage"] <= tolerance["max_outlier_percentage"])
        
        return all(checks)
    
    def save_accuracy_report(self, op_name: str, test_case_name: str, 
                            metrics: Dict, passed: bool, output_dir: Path):
        """保存与op_val格式一致的accuracy.json"""
        
        tolerance = self.config[op_name]["tolerance"]
        
        # 构建individual_checks
        individual_checks = {}
        individual_checks["max_absolute_error"] = metrics["max_absolute_error"] <= tolerance["max_absolute_error"]
        individual_checks["cosine_similarity"] = metrics["cosine_similarity"] >= tolerance["min_cosine_similarity"]
        
        if "mean_absolute_error" in tolerance:
            individual_checks["mean_absolute_error"] = metrics["mae"] <= tolerance["mean_absolute_error"]
        if "max_relative_error" in tolerance:
            individual_checks["max_relative_error"] = metrics["max_relative_error"] <= tolerance["max_relative_error"]
        
        # 处理离群点检查
        if "outlier_percentage" in metrics:
            max_outlier_pct = tolerance.get("max_outlier_percentage", 0.1)
            individual_checks["outlier_percentage"] = metrics["outlier_percentage"] <= max_outlier_pct

        accuracy_report = {
            "op_type": op_name,
            "test_case": test_case_name,
            "precision_dut": "mixed_fp32_fp16",  # NPU实现精度
            "precision_ref": "fp32",             # PyTorch参考精度
            "metrics": {
                "max_absolute_error": float(metrics["max_absolute_error"]),
                "mean_absolute_error": float(metrics["mae"]),
                "max_relative_error": float(metrics["max_relative_error"]),
                "mean_relative_error": float(metrics["mean_relative_error"]),
                "cosine_similarity": float(metrics["cosine_similarity"]),
                "mse": float(metrics["mse"])
            },
            "pass_fail_assessment": {
                "overall_status": "PASS" if passed else "FAIL",
                "individual_checks": individual_checks,
                "thresholds": tolerance
            },
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }
        
        # 添加离群点信息（如果有）
        if "outlier_count" in metrics:
            accuracy_report["metrics"]["outlier_count"] = int(metrics["outlier_count"])
            accuracy_report["metrics"]["outlier_percentage"] = float(metrics["outlier_percentage"])
        
        # 保存accuracy.json
        with open(output_dir / "accuracy.json", 'w') as f:
            json.dump(accuracy_report, f, indent=2)
        
        logger.info(f"📄 Accuracy报告已保存: {output_dir / 'accuracy.json'}")
    
    def _log_failure_details(self, metrics: Dict, tolerance: Dict):
        """记录失败详情"""
        logger.error("   详细失败信息:")
        
        if metrics["max_absolute_error"] > tolerance["max_absolute_error"]:
            logger.error(f"     Max Abs Error: {metrics['max_absolute_error']:.6e} > {tolerance['max_absolute_error']:.6e}")
        
        if metrics["cosine_similarity"] < tolerance["min_cosine_similarity"]:
            logger.error(f"     Cosine Similarity: {metrics['cosine_similarity']:.6f} < {tolerance['min_cosine_similarity']:.6f}")
        
        if "mean_absolute_error" in tolerance and metrics["mae"] > tolerance["mean_absolute_error"]:
            logger.error(f"     Mean Abs Error: {metrics['mae']:.6e} > {tolerance['mean_absolute_error']:.6e}")
        
        if "max_relative_error" in tolerance and metrics["max_relative_error"] > tolerance["max_relative_error"]:
            logger.error(f"     Max Rel Error: {metrics['max_relative_error']:.6e} > {tolerance['max_relative_error']:.6e}")
        
        if "outlier_percentage" in metrics and "max_outlier_percentage" in tolerance:
            if metrics["outlier_percentage"] > tolerance["max_outlier_percentage"]:
                logger.error(f"     Outlier Percentage: {metrics['outlier_percentage']:.2%} > {tolerance['max_outlier_percentage']:.2%}")
    
def test_gemm_npu_vs_pytorch():
    """GEMM: NPU仿真 vs PyTorch参考"""
    logger.info("🧪 GEMM端到端验证: NPU vs PyTorch")
    
    validator = E2EValidator()
    test_cases = validator.config["gemm"]["test_cases"]
    
    all_passed = True
    
    for test_case in test_cases:
        case_name = test_case["name"]
        M, K, N = test_case["M"], test_case["K"], test_case["N"]
        
        logger.info(f"📋 测试用例: {case_name} (M={M}, K={K}, N={N})")
        
        try:
            # 数据目录
            case_dir = validator.data_dir / "gemm" / case_name
            case_dir.mkdir(parents=True, exist_ok=True)

            ifmap_data = generate_random_tensor((M, K), dtype=np.float16, low=-0.5, high=0.5, seed=42)
            weight_data = generate_random_tensor((K, N), dtype=np.float16, low=-0.5, high=0.5, seed=43)

            ifmap_file = case_dir / "ifmap.bin"
            weight_file = case_dir / "weight.bin"
            
            save_tensor_to_bin(ifmap_data, str(ifmap_file))
            save_tensor_to_bin(weight_data, str(weight_file))
            
            # 2. PyTorch参考实现 (Golden Reference)
            logger.info("🔥 运行PyTorch参考实现...")
            pytorch_result, pytorch_time = gemm_pytorch_fp16(ifmap_data, weight_data)
            save_tensor_to_bin(pytorch_result, case_dir / "output_pytorch.bin") 
            logger.info(f"   PyTorch耗时: {pytorch_time:.6f}s")
            
            # 3. NPU仿真实现
            logger.info("⚡ 运行NPU仿真实现...")
            
            # 转换为NPU格式 - 需要重新调整数据格式
            # GEMM NPU格式: ifmap [k_group, m, k_group_size], weight [n_group, k_group, n_group_size, k_group_size]
            k_group_size = 16  # 从config获取或设置默认值
            n_group_size = 32
            
            k_group = K // k_group_size
            n_group = N // n_group_size
            
            # 重新排列数据为NPU格式
            ifmap_npu = ifmap_data.reshape(M, k_group, k_group_size).transpose(1, 0, 2)  # [k_group, m, k_group_size]
            weight_npu = weight_data.reshape(k_group, k_group_size, n_group, n_group_size).transpose(2, 0, 3, 1)  # [n_group, k_group, n_group_size, k_group_size]
            
            # 保存NPU格式数据
            ifmap_npu_file = case_dir / "ifmap_npu.bin"
            weight_npu_file = case_dir / "weight_npu.bin"
            output_npu_file = case_dir / "output_npu.bin"
            
            save_tensor_to_bin(ifmap_npu, str(ifmap_npu_file))
            save_tensor_to_bin(weight_npu, str(weight_npu_file))
            
            npu_result = gemm_sim_from_files(
                ifmap_npu_file, weight_npu_file, output_npu_file,
                m=M, n=N, k=K,
                tile_m=test_case.get("tile_m", 64),
                block_n_group=test_case.get("block_n_group", 4),
                block_k_group=test_case.get("block_k_group", 8)
            )
            
            # 转换NPU输出格式回标准格式
            npu_result_std = npu_result.transpose(1, 0, 2).reshape(M, N)
            
            # 4. 精度对比
            case_passed = validator.validate_operator(
                "gemm", npu_result_std, pytorch_result, case_name
            )
            
            if not case_passed:
                all_passed = False
                
        except Exception as e:
            logger.error(f"❌ GEMM测试用例 {case_name} 失败: {e}")
            all_passed = False
    
    return all_passed

def test_rmsnorm_npu_vs_pytorch():
    """RMSNorm: NPU仿真 vs PyTorch参考"""
    logger.info("🧪 RMSNorm端到端验证: NPU vs PyTorch")
    
    validator = E2EValidator()
    test_cases = validator.config["rmsnorm"]["test_cases"]
    
    all_passed = True
    
    for test_case in test_cases:
        case_name = test_case["name"]
        seq_len = test_case["seq_len"]
        d_model = test_case["d_model"]
        epsilon = test_case["epsilon"]
        oc_group_size = test_case["oc_group_size"]
        
        logger.info(f"📋 测试用例: {case_name} (seq_len={seq_len}, d_model={d_model})")
        
        try:
            # 数据目录
            case_dir = validator.data_dir / "rmsnorm" / case_name
            case_dir.mkdir(parents=True, exist_ok=True)
            
            # 1. 生成测试数据
            oc_group = d_model // oc_group_size
            
            input_shape = (oc_group, seq_len, oc_group_size)
            gamma_shape = (d_model,)  # PyTorch格式

            input_data = generate_random_tensor(input_shape, dtype=np.float32, low=-0.5, high=0.5, seed=100)
            gamma_data = generate_random_tensor(gamma_shape, dtype=np.float32, low=-0.5, high=0.5, seed=101)

            input_file = case_dir / "input.bin"
            gamma_file = case_dir / "gamma.bin"
            
            save_tensor_to_bin(input_data, str(input_file))
            save_tensor_to_bin(gamma_data, str(gamma_file))
            
            # 2. PyTorch参考实现 (Golden Reference)
            logger.info("🔥 运行PyTorch参考实现...")
            pytorch_result, pytorch_time = rmsnorm_pytorch_fp32(input_data, gamma_data, epsilon)
            save_tensor_to_bin(pytorch_result, case_dir / "output_pytorch.bin") 
            logger.info(f"   PyTorch耗时: {pytorch_time:.6f}s")
            
            # 3. NPU仿真实现
            logger.info("⚡ 运行NPU仿真实现...")
            output_file = case_dir / "output_npu.bin"
            
            npu_result = rmsnorm_sim_from_files(
                input_file, gamma_file, output_file,
                seq_len, d_model, epsilon=epsilon
            )
            
            # 4. 精度对比
            case_passed = validator.validate_operator(
                "rmsnorm", npu_result, pytorch_result, case_name
            )
            
            if not case_passed:
                all_passed = False
                
        except Exception as e:
            logger.error(f"❌ RMSNorm测试用例 {case_name} 失败: {e}")
            all_passed = False
    
    return all_passed

def test_softmax_npu_vs_pytorch():
    """Softmax: NPU仿真 vs PyTorch参考"""
    logger.info("🧪 Softmax端到端验证: NPU vs PyTorch")
    
    validator = E2EValidator()
    test_cases = validator.config["softmax"]["test_cases"]
    
    all_passed = True
    
    for test_case in test_cases:
        case_name = test_case["name"]
        seq_len = test_case["seq_len"]
        d_model = test_case["d_model"]
        oc_group_size = test_case["oc_group_size"]
        
        logger.info(f"📋 测试用例: {case_name} (seq_len={seq_len}, d_model={d_model})")
        
        try:
            # 数据目录
            case_dir = validator.data_dir / "softmax" / case_name
            case_dir.mkdir(parents=True, exist_ok=True)
            
            # 1. 生成测试数据
            oc_group = d_model // oc_group_size
            input_shape = (oc_group, seq_len, oc_group_size)

            input_data = generate_random_tensor(input_shape, dtype=np.float32, low=-0.5, high=0.5, seed=200)

            input_file = case_dir / "input.bin"
            save_tensor_to_bin(input_data, str(input_file))
            
            # 2. PyTorch参考实现 (Golden Reference)
            logger.info("🔥 运行PyTorch参考实现...")
            pytorch_result, pytorch_time = softmax_pytorch_fp32(input_data)
            save_tensor_to_bin(pytorch_result, case_dir / "output_pytorch.bin") 
            logger.info(f"   PyTorch耗时: {pytorch_time:.6f}s")
            
            # 3. NPU仿真实现
            logger.info("⚡ 运行NPU仿真实现...")
            output_file = case_dir / "output_npu.bin"
            
            npu_result = softmax_sim_from_files(
                input_file, output_file,
                seq_len, d_model
            )
            
            # 4. 精度对比
            case_passed = validator.validate_operator(
                "softmax", npu_result, pytorch_result, case_name
            )
            
            if not case_passed:
                all_passed = False
                
        except Exception as e:
            logger.error(f"❌ Softmax测试用例 {case_name} 失败: {e}")
            all_passed = False
    
    return all_passed

def test_llama_block_npu_vs_pytorch():
    """LlamaBlock: NPU仿真 vs PyTorch参考"""
    logger.info("🧪 LlamaBlock端到端验证: NPU vs PyTorch")
    
    validator = E2EValidator()
    test_cases = validator.config["llama_block"]["test_cases"]
    
    all_passed = True
    
    for test_case in test_cases:
        case_name = test_case["name"]
        seq_len = test_case["seq_len"]
        hidden_size = test_case["hidden_size"]
        intermediate_size = test_case["intermediate_size"]
        num_attention_heads = test_case["num_attention_heads"]
        rmsnorm_epsilon = test_case["rmsnorm_epsilon"]
        
        logger.info(f"📋 测试用例: {case_name} (seq_len={seq_len}, hidden_size={hidden_size})")
        
        try:
            # 数据目录
            case_dir = validator.data_dir / "llama_block" / case_name
            case_dir.mkdir(parents=True, exist_ok=True)
            
            # 计算预期形状
            oc_group_size = 32
            k_group_size = 16
            n_group_size = 32
            
            oc_group = hidden_size // oc_group_size
            ic_group_attn = hidden_size // k_group_size
            oc_group_mlp = intermediate_size // n_group_size
            ic_group_mlp = intermediate_size // k_group_size
            
            # 定义所有张量的预期形状
            tensor_shapes = {
                "input_hidden_state": (oc_group, seq_len, oc_group_size),
                "attn_norm_gamma": (oc_group, oc_group_size),
                "query_weight": (oc_group, ic_group_attn, n_group_size, k_group_size),
                "key_weight": (oc_group, ic_group_attn, n_group_size, k_group_size),
                "value_weight": (oc_group, ic_group_attn, n_group_size, k_group_size),
                "output_weight": (oc_group, ic_group_attn, n_group_size, k_group_size),
                "ffn_norm_gamma": (oc_group, oc_group_size),
                "gate_weight": (oc_group_mlp, ic_group_attn, n_group_size, k_group_size),
                "up_weight": (oc_group_mlp, ic_group_attn, n_group_size, k_group_size),
                "down_weight": (oc_group, ic_group_mlp, n_group_size, k_group_size)
            }
            tensor_data = {}
            # 生成所有输入张量
            for tensor_name, tensor_shape in tensor_shapes.items():
                # if "input" in tensor_name or "norm" in tensor_name:
                #     generated_tensor = generate_random_tensor(tensor_shape, dtype=np.float32, low=-0.05, high=0.05, seed=1)
                #     tensor_file = case_dir / f"{tensor_name}.bin"
                #     save_tensor_to_bin(generated_tensor, str(tensor_file))
                #     tensor_data[tensor_name] = generated_tensor 
                # else:
                #     generated_tensor = generate_random_tensor(tensor_shape, dtype=np.float16, low=-0.2, high=0.2, seed=300 + hash(tensor_name) % 1000)
                #     tensor_file = case_dir / f"{tensor_name}.bin"
                #     save_tensor_to_bin(generated_tensor, str(tensor_file))
                #     tensor_data[tensor_name] = generated_tensor
                
                tensor_data['input_hidden_state'] = load_tensor_from_bin()

            # 生成LlamaBlock所需的额外张量 (freq_cls 和 causal_mask)
            logger.info("🔧 生成LlamaBlock额外参数(for RoPE and Causal Mask)...")
            additional_tensors = generate_llama_block_additional_tensors(
                seq_len=seq_len,
                hidden_size=hidden_size, 
                num_attention_heads=num_attention_heads,
                case_dir=case_dir
            )

            # 2. PyTorch参考实现 (Golden Reference)
            logger.info("🔥 运行PyTorch参考实现...")
            pytorch_result, pytorch_time = llama_block_pytorch(
                tensor_data['input_hidden_state'],
                tensor_data['attn_norm_gamma'], tensor_data['ffn_norm_gamma'],
                tensor_data['query_weight'], tensor_data['key_weight'], tensor_data['value_weight'], tensor_data['output_weight'],
                tensor_data['gate_weight'], tensor_data['up_weight'], tensor_data['down_weight'],
                num_attention_heads=num_attention_heads,
                rmsnorm_epsilon=rmsnorm_epsilon
            )
            save_tensor_to_bin(pytorch_result, case_dir / "output_pytorch.bin") 
            logger.info(f"   PyTorch耗时: {pytorch_time:.6f}s")
            
            # # 3. NPU仿真实现
            # logger.info("⚡ 运行NPU仿真实现...")
            # output_file = case_dir / "output_npu.bin"

            # npu_sim_start_time = time.perf_counter()
            # npu_result = llama_block_sim_from_files(
            #     input_file=case_dir / "input_hidden_state.bin",
            #     weight_dir=case_dir,
            #     output_file=output_file,
            #     seq_len=seq_len,
            #     hidden_size=hidden_size,
            #     intermediate_size=intermediate_size,
            #     num_attention_heads=num_attention_heads,
            # )
            # npu_sim_end_time = time.perf_counter()
            # npu_sim_time = npu_sim_end_time - npu_sim_start_time
            # logger.info(f"   NPU仿真耗时: {npu_sim_time:.6f}s")
            
            # # 4. 精度对比
            # case_passed = validator.validate_operator(
            #     "llama_block", npu_result, pytorch_result, case_name
            # )
            
            # if not case_passed:
            #     all_passed = False
                
        except Exception as e:
            logger.error(f"❌ LlamaBlock测试用例 {case_name} 失败: {e}")
            import traceback
            logger.error(traceback.format_exc())
            all_passed = False
    
    return all_passed

def run_all_e2e_tests():
    """运行所有端到端测试 - NPU vs PyTorch验证"""
    logger.info("🚀 开始NPU vs PyTorch端到端验证")
    
    tests = [
        ("GEMM NPU vs PyTorch", test_gemm_npu_vs_pytorch),
        ("RMSNorm NPU vs PyTorch", test_rmsnorm_npu_vs_pytorch),
        ("Softmax NPU vs PyTorch", test_softmax_npu_vs_pytorch),
        ("LlamaBlock NPU vs PyTorch", test_llama_block_npu_vs_pytorch),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        logger.info(f"\n{'='*60}")
        logger.info(f"🧪 {test_name}")
        logger.info(f"{'='*60}")
        
        try:
            if test_func():
                passed += 1
                logger.info(f"✅ {test_name} 通过")
            else:
                logger.error(f"❌ {test_name} 失败")
        except Exception as e:
            logger.error(f"❌ {test_name} 异常: {e}")
            import traceback
            logger.error(traceback.format_exc())
    
    # 生成综合报告
    try:
        validator = E2EValidator()
        generate_final_report(validator.test_results, validator.output_dir)
    except Exception as e:
        logger.warning(f"⚠️ 生成综合报告失败: {e}")
    
    logger.info(f"\n🎯 端到端测试完成: {passed}/{total} 项通过")
    
    return passed == total

def generate_final_report(test_results: Dict, output_dir: Path):
    """生成最终的综合测试报告"""
    report_dir = output_dir / "reports"
    report_dir.mkdir(parents=True, exist_ok=True)
    
    # 综合报告
    summary = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "total_operators": len(test_results),
        "test_results": test_results,
        "summary": {}
    }
    
    for op_name, op_results in test_results.items():
        passed_cases = sum(1 for result in op_results.values() if result["passed"])
        total_cases = len(op_results)
        summary["summary"][op_name] = {
            "passed": passed_cases,
            "total": total_cases,
            "pass_rate": passed_cases / total_cases if total_cases > 0 else 0
        }
    
    # 保存JSON报告
    with open(report_dir / "e2e_test_summary.json", 'w') as f:
        json.dump(summary, f, indent=2, default=str)
    
    logger.info(f"📊 综合报告已保存到: {report_dir / 'e2e_test_summary.json'}")

if __name__ == "__main__":
    success = test_llama_block_npu_vs_pytorch()
    
    if success:
        print("🎉 所有NPU vs PyTorch端到端测试通过！")
        exit(0)
    else:
        print("❌ 部分NPU vs PyTorch端到端测试失败！")
        exit(1)
