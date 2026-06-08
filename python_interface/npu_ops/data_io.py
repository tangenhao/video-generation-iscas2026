"""
NPU算子文件数据处理模块
按照流程步骤1.1.3的要求实现：
- 支持bin文件的tensor加载和保存(参考cpp_sim风格)
- 自动处理数据类型转换和形状验证
- 提供数据对比和验证工具
"""

import numpy as np
import struct
from pathlib import Path
from typing import Union, Tuple, Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

class TensorIO:
    """Tensor文件I/O处理类，与cpp_sim风格兼容"""
    
    @staticmethod
    def save_tensor_to_bin(tensor: np.ndarray, file_path: Union[str, Path]) -> None:
        """
        将tensor保存为二进制文件
        
        Args:
            tensor: 要保存的numpy数组
            file_path: 输出文件路径
        """
        file_path = Path(file_path)
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        # 保存为连续的C风格数组
        tensor_contiguous = np.ascontiguousarray(tensor)
        
        with open(file_path, 'wb') as f:
            # 写入数据类型信息（可选，用于验证）
            dtype_str = str(tensor.dtype).encode('utf-8')
            f.write(struct.pack('I', len(dtype_str)))
            f.write(dtype_str)
            
            # 写入形状信息
            f.write(struct.pack('I', len(tensor.shape)))
            for dim in tensor.shape:
                f.write(struct.pack('I', dim))
            
            # 写入实际数据
            f.write(tensor_contiguous.tobytes())
        
        logger.info(f"✅ Tensor保存完成: {tensor.shape} {tensor.dtype} -> {file_path}")
    
    @staticmethod
    def load_tensor_from_bin(file_path: Union[str, Path], 
                            expected_shape: Optional[Tuple] = None,
                            expected_dtype: Optional[np.dtype] = None) -> np.ndarray:
        """
        从二进制文件加载tensor
        
        Args:
            file_path: 输入文件路径
            expected_shape: 期望的形状（用于验证）
            expected_dtype: 期望的数据类型（用于验证）
        
        Returns:
            加载的numpy数组
        """
        file_path = Path(file_path)
        if not file_path.exists():
            raise FileNotFoundError(f"文件不存在: {file_path}")
        
        with open(file_path, 'rb') as f:
            # 读取数据类型信息
            dtype_len = struct.unpack('I', f.read(4))[0]
            dtype_str = f.read(dtype_len).decode('utf-8')
            dtype = np.dtype(dtype_str)
            
            # 读取形状信息
            ndim = struct.unpack('I', f.read(4))[0]
            shape = []
            for _ in range(ndim):
                shape.append(struct.unpack('I', f.read(4))[0])
            shape = tuple(shape)
            
            # 读取数据
            data_size = np.prod(shape) * dtype.itemsize
            data_bytes = f.read(data_size)
            
            # 重构tensor
            tensor = np.frombuffer(data_bytes, dtype=dtype).reshape(shape)
        
        # 验证形状和数据类型
        if expected_shape is not None and tensor.shape != expected_shape:
            raise ValueError(f"形状不匹配: 期望 {expected_shape}, 实际 {tensor.shape}")
        
        if expected_dtype is not None and tensor.dtype != expected_dtype:
            logger.warning(f"数据类型不匹配: 期望 {expected_dtype}, 实际 {tensor.dtype}，将进行转换")
            tensor = tensor.astype(expected_dtype)
        
        logger.info(f"✅ Tensor加载完成: {file_path} -> {tensor.shape} {tensor.dtype}")
        return tensor
    
    @staticmethod
    def save_raw_tensor(tensor: np.ndarray, file_path: Union[str, Path]) -> None:
        """
        保存原始tensor数据（无元数据，与cpp_sim兼容）
        
        Args:
            tensor: 要保存的numpy数组
            file_path: 输出文件路径
        """
        file_path = Path(file_path)
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        # 保存为连续的C风格数组
        tensor_contiguous = np.ascontiguousarray(tensor)
        
        with open(file_path, 'wb') as f:
            f.write(tensor_contiguous.tobytes())
        
        logger.info(f"✅ 原始Tensor保存完成: {tensor.shape} {tensor.dtype} -> {file_path}")
    
    @staticmethod
    def load_raw_tensor(file_path: Union[str, Path], 
                       shape: Tuple, dtype: np.dtype) -> np.ndarray:
        """
        加载原始tensor数据（无元数据，与cpp_sim兼容）
        
        Args:
            file_path: 输入文件路径
            shape: tensor形状
            dtype: 数据类型
        
        Returns:
            加载的numpy数组
        """
        file_path = Path(file_path)
        if not file_path.exists():
            raise FileNotFoundError(f"文件不存在: {file_path}")
        
        # 计算期望的文件大小
        expected_size = np.prod(shape) * np.dtype(dtype).itemsize
        file_size = file_path.stat().st_size
        
        if file_size != expected_size:
            logger.warning(
                f"文件大小可能不匹配: 期望 {expected_size} 字节, 实际 {file_size} 字节"
            )
        
        with open(file_path, 'rb') as f:
            data_bytes = f.read()
        
        # 重构tensor
        tensor = np.frombuffer(data_bytes, dtype=dtype).reshape(shape)
        
        logger.info(f"✅ 原始Tensor加载完成: {file_path} -> {tensor.shape} {tensor.dtype}")
        return tensor

class DataValidator:
    """数据验证工具类"""
    
    @staticmethod
    def compare_tensors(tensor1: np.ndarray, tensor2: np.ndarray,
                       rtol: float = 1e-5, atol: float = 1e-8,
                       name1: str = "tensor1", name2: str = "tensor2") -> Dict[str, Any]:
        """
        比较两个tensor的数值差异
        
        Args:
            tensor1, tensor2: 要比较的张量
            rtol: 相对误差容忍度
            atol: 绝对误差容忍度
            name1, name2: 张量名称（用于日志）
        
        Returns:
            包含比较结果的字典
        """
        # 形状检查
        if tensor1.shape != tensor2.shape:
            raise ValueError(f"形状不匹配: {name1} {tensor1.shape} vs {name2} {tensor2.shape}")
        
        # 转换为相同的数据类型进行比较
        if tensor1.dtype != tensor2.dtype:
            logger.info(f"数据类型不同，转换为float32进行比较: {tensor1.dtype} vs {tensor2.dtype}")
            tensor1 = tensor1.astype(np.float32)
            tensor2 = tensor2.astype(np.float32)
        
        # 计算差异
        abs_diff = np.abs(tensor1 - tensor2)
        rel_diff = abs_diff / (np.abs(tensor2) + 1e-10)  # 避免除零
        
        max_abs_diff = np.max(abs_diff)
        max_rel_diff = np.max(rel_diff)
        mean_abs_diff = np.mean(abs_diff)
        mean_rel_diff = np.mean(rel_diff)
        
        # 判断是否通过
        is_close = np.allclose(tensor1, tensor2, rtol=rtol, atol=atol)
        
        result = {
            "is_close": is_close,
            "max_abs_diff": float(max_abs_diff),
            "max_rel_diff": float(max_rel_diff),
            "mean_abs_diff": float(mean_abs_diff),
            "mean_rel_diff": float(mean_rel_diff),
            "rtol": rtol,
            "atol": atol,
            "shape": tensor1.shape,
            "dtype": str(tensor1.dtype)
        }
        
        # 日志输出
        status = "✅ 通过" if is_close else "❌ 失败"
        logger.info(f"{status} 张量比较 {name1} vs {name2}:")
        logger.info(f"  最大绝对误差: {max_abs_diff:.2e}")
        logger.info(f"  最大相对误差: {max_rel_diff:.2e}")
        logger.info(f"  平均绝对误差: {mean_abs_diff:.2e}")
        logger.info(f"  平均相对误差: {mean_rel_diff:.2e}")
        
        return result
    
    @staticmethod
    def validate_tensor_properties(tensor: np.ndarray, 
                                  expected_shape: Optional[Tuple] = None,
                                  expected_dtype: Optional[np.dtype] = None,
                                  expected_range: Optional[Tuple[float, float]] = None,
                                  name: str = "tensor") -> bool:
        """
        验证tensor的属性
        
        Args:
            tensor: 要验证的张量
            expected_shape: 期望形状
            expected_dtype: 期望数据类型
            expected_range: 期望数值范围 (min, max)
            name: 张量名称
        
        Returns:
            是否通过验证
        """
        passed = True
        
        # 形状验证
        if expected_shape is not None:
            if tensor.shape != expected_shape:
                logger.error(f"❌ {name} 形状验证失败: 期望 {expected_shape}, 实际 {tensor.shape}")
                passed = False
            else:
                logger.info(f"✅ {name} 形状验证通过: {tensor.shape}")
        
        # 数据类型验证
        if expected_dtype is not None:
            if tensor.dtype != expected_dtype:
                logger.error(f"❌ {name} 数据类型验证失败: 期望 {expected_dtype}, 实际 {tensor.dtype}")
                passed = False
            else:
                logger.info(f"✅ {name} 数据类型验证通过: {tensor.dtype}")
        
        # 数值范围验证
        if expected_range is not None:
            min_val, max_val = expected_range
            actual_min, actual_max = float(np.min(tensor)), float(np.max(tensor))
            
            if actual_min < min_val or actual_max > max_val:
                logger.error(
                    f"❌ {name} 数值范围验证失败: "
                    f"期望 [{min_val}, {max_val}], 实际 [{actual_min:.6f}, {actual_max:.6f}]"
                )
                passed = False
            else:
                logger.info(
                    f"✅ {name} 数值范围验证通过: [{actual_min:.6f}, {actual_max:.6f}] "
                    f"在 [{min_val}, {max_val}] 范围内"
                )
        
        return passed

class FileManager:
    """文件管理工具类"""
    
    def __init__(self, base_dir: Union[str, Path] = ""):
        if base_dir is not "":
            self.base_dir = Path(base_dir)
            self.base_dir.mkdir(parents=True, exist_ok=True)
            logger.info(f"✅ 文件管理器初始化: {self.base_dir}")
    
    def get_file_path(self, relative_path: str) -> Path:
        """获取相对于base_dir的文件路径"""
        return self.base_dir / relative_path
    
    def save_tensor(self, tensor: np.ndarray, relative_path: str, 
                   raw_format: bool = False) -> Path:
        """
        保存tensor到指定路径
        
        Args:
            tensor: 要保存的张量
            relative_path: 相对路径
            raw_format: 是否使用原始格式（无元数据）
        
        Returns:
            实际保存的文件路径
        """
        file_path = self.get_file_path(relative_path)
        
        if raw_format:
            TensorIO.save_raw_tensor(tensor, file_path)
        else:
            TensorIO.save_tensor_to_bin(tensor, file_path)
        
        return file_path
    
    def load_tensor(self, relative_path: str, 
                   shape: Optional[Tuple] = None,
                   dtype: Optional[np.dtype] = None,
                   raw_format: bool = False) -> np.ndarray:
        """
        从指定路径加载tensor
        
        Args:
            relative_path: 相对路径
            shape: 形状（raw_format时必需）
            dtype: 数据类型（raw_format时必需）
            raw_format: 是否使用原始格式
        
        Returns:
            加载的张量
        """
        file_path = self.get_file_path(relative_path)
        
        if raw_format:
            if shape is None or dtype is None:
                raise ValueError("raw_format模式下必须指定shape和dtype")
            return TensorIO.load_raw_tensor(file_path, shape, dtype)
        else:
            return TensorIO.load_tensor_from_bin(file_path, shape, dtype)
    
    def list_files(self, pattern: str = "*") -> list:
        """列出匹配模式的文件"""
        return list(self.base_dir.glob(pattern))
    
    def cleanup(self) -> None:
        """清理所有文件"""
        import shutil
        if self.base_dir.exists():
            shutil.rmtree(self.base_dir)
            logger.info(f"✅ 清理完成: {self.base_dir}")

# 便捷函数
def save_tensor_bin(tensor: np.ndarray, file_path: Union[str, Path]) -> None:
    """便捷函数：保存tensor为bin文件"""
    TensorIO.save_tensor_to_bin(tensor, file_path)

def load_tensor_bin(file_path: Union[str, Path], 
                   shape: Optional[Tuple] = None,
                   dtype: Optional[np.dtype] = None) -> np.ndarray:
    """便捷函数：从bin文件加载tensor"""
    return TensorIO.load_tensor_from_bin(file_path, shape, dtype)

def compare_tensor_files(file1: Union[str, Path], file2: Union[str, Path],
                        shape: Tuple, dtype: np.dtype,
                        rtol: float = 1e-5, atol: float = 1e-8) -> Dict[str, Any]:
    """便捷函数：比较两个tensor文件"""
    tensor1 = TensorIO.load_raw_tensor(file1, shape, dtype)
    tensor2 = TensorIO.load_raw_tensor(file2, shape, dtype)
    
    return DataValidator.compare_tensors(
        tensor1, tensor2, rtol, atol, 
        name1=str(file1), name2=str(file2)
    )
