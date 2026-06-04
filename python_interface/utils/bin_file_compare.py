"""
二进制文件对比工具
支持加载两个bin文件并进行精度对比分析

功能:
1. 加载指定的bin文件为tensor
2. 比较两个tensor的差异
3. 生成详细的误差分析报告
4. 生成可视化图表
5. 保存accuracy.json报告

使用方法:
1. Python API调用
2. 命令行调用
"""

import sys
import os
import json
import time
import logging
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Any, Union
import numpy as np

# 添加路径 - 适配utils目录位置
current_dir = Path(__file__).parent
print(f"{__file__}当前目录: {current_dir}")
sys.path.append(str(current_dir.parent.parent))  # 回到project根目录
sys.path.append(str(current_dir.parent.parent / "simulator" / "op_val" / "common_utils"))

# 导入common_utils工具集
from data_gen import load_tensor_from_bin
from plot_utils import (
    calculate_numerical_metrics,
    print_numerical_metrics_report,
    plot_scatter_comparison,
    plot_error_histogram,
    generate_outlier_analysis_and_plots,
    OutlierAnalysis
)

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class BinFileComparator:
    """二进制文件对比器"""
    
    def __init__(self, output_base_dir: Optional[str] = None):
        """
        初始化对比器
        
        Args:
            output_base_dir: 输出基础目录，默认为 python_interface/test/utils
        """
        if output_base_dir is None:
            self.output_base_dir = current_dir.parent / "test" / "utils"
        else:
            self.output_base_dir = Path(output_base_dir)
        
        self.output_base_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"🔧 BinFileComparator初始化")
        logger.info(f"   输出基础目录: {self.output_base_dir}")
    
    def load_bin_file(self, file_path: str, shape: Tuple[int, ...], dtype: str) -> np.ndarray:
        """
        加载二进制文件为numpy数组
        
        Args:
            file_path: bin文件路径
            shape: 张量形状
            dtype: 数据类型 ('fp32', 'fp16', 'int32', 'int8'等)
            
        Returns:
            加载的numpy数组
        """
        logger.info(f"📥 加载bin文件: {file_path}")
        logger.info(f"   目标形状: {shape}, 数据类型: {dtype}")
        
        # 映射字符串dtype到numpy dtype
        dtype_map = {
            'fp32': np.float32,
            'fp16': np.float16,
            'int32': np.int32,
            'int16': np.int16,
            'int8': np.int8,
            'uint8': np.uint8
        }
        
        if dtype not in dtype_map:
            raise ValueError(f"不支持的数据类型: {dtype}. 支持的类型: {list(dtype_map.keys())}")
        
        np_dtype = dtype_map[dtype]
        
        try:
            tensor = load_tensor_from_bin(file_path, np_dtype, shape)
            logger.info(f"✅ 成功加载: {tensor.shape}, {tensor.dtype}")
            return tensor
        except Exception as e:
            logger.error(f"❌ 加载失败: {e}")
            raise
    
    def compare_tensors(self, 
                       tensor_a: np.ndarray,
                       tensor_b: np.ndarray,
                       case_name: str,
                       labels: Tuple[str, str] = ("Reference", "DUT"),
                       tolerance: Optional[Dict] = None,
                       output_dir: Optional[str] = None) -> Dict:
        """
        比较两个tensor并生成分析报告
        
        Args:
            tensor_a: 参考张量
            tensor_b: 待测张量
            case_name: 测试用例名称
            labels: 张量标签 (参考名称, 待测名称)
            tolerance: 容差配置
            output_dir: 输出目录，如果为None则使用默认目录
            
        Returns:
            包含所有指标的字典
        """
        if output_dir is None:
            output_dir = self.output_base_dir / case_name
        else:
            output_dir = Path(output_dir)
        
        output_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info(f"🔍 张量对比分析: {case_name}")
        logger.info(f"   {labels[0]}: {tensor_a.shape}, {tensor_a.dtype}")
        logger.info(f"   {labels[1]}: {tensor_b.shape}, {tensor_b.dtype}")
        logger.info(f"   输出目录: {output_dir}")
        
        # 验证张量形状匹配
        if tensor_a.shape != tensor_b.shape:
            raise ValueError(f"张量形状不匹配: {tensor_a.shape} vs {tensor_b.shape}")
        
        # 设置默认容差
        if tolerance is None:
            tolerance = {
                "max_absolute_error": 1e-3,
                "min_cosine_similarity": 0.999,
                "outlier_absolute_threshold": 1e-4,
                "outlier_relative_threshold": 0.01,
                "max_outlier_percentage": 0.1
            }
        
        try:
            # 一次性完成所有数值分析（包含离群点分析）
            outlier_abs_threshold = tolerance.get("outlier_absolute_threshold", 1e-4)
            outlier_rel_threshold = tolerance.get("outlier_relative_threshold", 0.01)
            
            metrics = calculate_numerical_metrics(
                tensor_a,        # reference
                tensor_b,        # dut
                epsilon_for_relative_error=1e-9,
                outlier_absolute_threshold=outlier_abs_threshold,
                outlier_relative_threshold=outlier_rel_threshold,
                output_dir=str(output_dir)  # 自动生成所有离群点分析图表
            )
            
            # 打印详细报告
            print(f"\n{'='*60}")
            print(f"📊 {case_name} 对比分析报告")
            print(f"{'='*60}")
            print_numerical_metrics_report(metrics)
            
            # 生成基础对比图表
            plot_scatter_comparison(
                tensor_b, tensor_a,
                title=f"{case_name}: {labels[1]} vs {labels[0]}",
                save_path=str(output_dir / f"{case_name}_scatter_comparison.png")
            )
            
            # 绝对误差直方图
            plot_error_histogram(
                metrics['absolute_error_array'], 
                title=f"{case_name}: Absolute Error Distribution",
                save_path=str(output_dir / f"{case_name}_abs_error_hist.png")
            )
            logger.info(f"✅ 绝对误差直方图已保存: {output_dir / f'{case_name}_abs_error_hist.png'}")

            # 相对误差直方图
            plot_error_histogram(
                metrics['relative_error_array'], 
                title=f"{case_name}: Relative Error Distribution",
                save_path=str(output_dir / f"{case_name}_rel_error_hist.png")
            )
            logger.info(f"✅ 相对误差直方图已保存: {output_dir / f'{case_name}_rel_error_hist.png'}")

            # 判断是否通过
            passed = self._check_pass_criteria(metrics, tolerance)
            
            # 保存accuracy.json报告
            self._save_accuracy_report(case_name, metrics, passed, tolerance, labels, output_dir)
            
            # 添加元数据
            metrics["case_name"] = case_name
            metrics["labels"] = labels
            metrics["passed"] = passed
            metrics["output_dir"] = str(output_dir)
            
            if passed:
                logger.info(f"✅ {case_name} 对比验证通过")
            else:
                logger.error(f"❌ {case_name} 对比验证失败")
                self._log_failure_details(metrics, tolerance)
            
            return metrics
            
        except Exception as e:
            logger.error(f"❌ {case_name} 对比分析异常: {e}")
            import traceback
            logger.error(traceback.format_exc())
            raise
    
    def compare_bin_files(self,
                         file_a: str,
                         file_b: str, 
                         shape: Tuple[int, ...],
                         dtype: str,
                         case_name: str,
                         labels: Tuple[str, str] = ("Reference", "DUT"),
                         tolerance: Optional[Dict] = None,
                         output_dir: Optional[str] = None) -> Dict:
        """
        直接比较两个bin文件
        
        Args:
            file_a: 参考bin文件路径
            file_b: 待测bin文件路径
            shape: 张量形状
            dtype: 数据类型
            case_name: 测试用例名称
            labels: 文件标签
            tolerance: 容差配置
            output_dir: 输出目录
            
        Returns:
            对比分析结果
        """
        logger.info(f"🚀 开始bin文件对比: {case_name}")
        logger.info(f"   参考文件: {file_a}")
        logger.info(f"   待测文件: {file_b}")
        
        # 加载两个文件
        tensor_a = self.load_bin_file(file_a, shape, dtype)
        tensor_b = self.load_bin_file(file_b, shape, dtype)
        
        # 执行对比
        return self.compare_tensors(
            tensor_a, tensor_b, case_name, labels, tolerance, output_dir
        )
    
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
    
    def _save_accuracy_report(self, case_name: str, metrics: Dict, passed: bool, 
                             tolerance: Dict, labels: Tuple[str, str], output_dir: Path):
        """保存accuracy.json报告"""
        
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
            "case_name": case_name,
            "comparison_type": "bin_file_comparison",
            "reference_label": labels[0],
            "dut_label": labels[1],
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


def compare_bin_files_api(file_a: str,
                         file_b: str,
                         shape: Union[Tuple[int, ...], List[int]],
                         dtype: str,
                         case_name: str = "comparison",
                         labels: Tuple[str, str] = ("Reference", "DUT"),
                         tolerance: Optional[Dict] = None,
                         output_dir: Optional[str] = None) -> Dict:
    """
    便捷API：直接比较两个bin文件
    
    Args:
        file_a: 参考bin文件路径
        file_b: 待测bin文件路径
        shape: 张量形状
        dtype: 数据类型 ('fp32', 'fp16', 'int32', 'int8'等)
        case_name: 测试用例名称
        labels: 文件标签
        tolerance: 容差配置
        output_dir: 输出目录
        
    Returns:
        对比分析结果字典
    """
    comparator = BinFileComparator(output_dir)
    return comparator.compare_bin_files(
        file_a, file_b, tuple(shape), dtype, case_name, labels, tolerance, output_dir
    )


def main():
    """命令行接口"""
    parser = argparse.ArgumentParser(description="二进制文件对比工具")
    
    parser.add_argument("file_a", help="参考bin文件路径")
    parser.add_argument("file_b", help="待测bin文件路径") 
    parser.add_argument("--shape", nargs="+", type=int, required=True, help="张量形状，如: --shape 64 128 256")
    parser.add_argument("--dtype", required=True, choices=["fp32", "fp16", "int32", "int8", "uint8"], help="数据类型")
    parser.add_argument("--case-name", default="comparison", help="测试用例名称")
    parser.add_argument("--label-a", default="Reference", help="文件A标签")
    parser.add_argument("--label-b", default="DUT", help="文件B标签")
    parser.add_argument("--output-dir", help="输出目录")
    parser.add_argument("--max-abs-error", type=float, default=1e-3, help="最大绝对误差阈值")
    parser.add_argument("--min-cosine-sim", type=float, default=0.999, help="最小余弦相似度")
    parser.add_argument("--outlier-abs-threshold", type=float, default=1e-4, help="离群点绝对阈值")
    parser.add_argument("--outlier-rel-threshold", type=float, default=0.01, help="离群点相对阈值")
    parser.add_argument("--max-outlier-percentage", type=float, default=0.1, help="最大离群点百分比")
    
    args = parser.parse_args()
    
    # 构建容差配置
    tolerance = {
        "max_absolute_error": args.max_abs_error,
        "min_cosine_similarity": args.min_cosine_sim,
        "outlier_absolute_threshold": args.outlier_abs_threshold,
        "outlier_relative_threshold": args.outlier_rel_threshold,
        "max_outlier_percentage": args.max_outlier_percentage
    }
    
    # 执行对比
    try:
        result = compare_bin_files_api(
            file_a=args.file_a,
            file_b=args.file_b,
            shape=tuple(args.shape),
            dtype=args.dtype,
            case_name=args.case_name,
            labels=(args.label_a, args.label_b),
            tolerance=tolerance,
            output_dir=args.output_dir
        )
        
        # 输出结果
        if result["passed"]:
            print(f"\n✅ 对比验证通过: {args.case_name}")
            exit(0)
        else:
            print(f"\n❌ 对比验证失败: {args.case_name}")
            exit(1)
            
    except Exception as e:
        print(f"\n❌ 对比过程异常: {e}")
        import traceback
        traceback.print_exc()
        exit(1)


if __name__ == "__main__":
    main()
