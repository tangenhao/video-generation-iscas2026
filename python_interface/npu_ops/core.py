"""
NPU算子Python接口核心模块
按照流程步骤1.1.2的设计原则实现：
- 完全兼容interface.cpp：严格按照实际C函数签名设计接口
- 文件导向设计：支持从bin文件加载数据，结果保存到文件
- 二次封装友好：为高级封装预留清晰的接口
"""

import ctypes
import numpy as np
import os
from pathlib import Path
from typing import Union, Tuple, Optional
import logging

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 数据类型定义，与C++保持一致
class DType:
    kInt4     = 0
    kInt8     = 1
    kHalf     = 2
    kBfloat16 = 3
    kInt16    = 4
    kInt32    = 5
    kFloat32  = 6
    kBool     = 7

class NPUCore:
    """NPU算子核心接口类"""
    
    def __init__(self, lib_path: Optional[str] = None):
        """
        初始化NPU核心接口
        
        Args:
            lib_path: 动态库路径，如果为None则自动查找
        """
        self._lib = None
        self._lib_path = lib_path
        self._load_library()
        self._setup_function_signatures()
        
        logger.info("✅ NPU核心接口初始化成功")
    
    def _load_library(self):
        """加载NPU动态库"""
        if self._lib_path is None:
            # 自动查找动态库
            current_dir = Path(__file__).parent
            lib_dir = current_dir.parent / "lib"
            
            # 支持多种库文件名
            possible_names = [
                "libnpu_interface.so"
            ]
            
            for name in possible_names:
                lib_path = lib_dir / name
                if lib_path.exists():
                    self._lib_path = str(lib_path)
                    break
            
            if self._lib_path is None:
                raise FileNotFoundError(
                    f"未找到NPU动态库。请先运行 script/build_npu_interface.sh 编译动态库，"
                    f"或在以下位置之一放置库文件: {[str(lib_dir / name) for name in possible_names]}"
                )
        
        try:
            self._lib = ctypes.CDLL(self._lib_path)
            logger.info(f"✅ 成功加载动态库: {self._lib_path}")
        except OSError as e:
            raise RuntimeError(f"无法加载动态库 {self._lib_path}: {e}")
    
    def _setup_function_signatures(self):
        """设置C函数签名，严格按照interface.cpp中的定义"""
        
        # 工具函数
        self._lib.gen_random_data.argtypes = [
            ctypes.c_void_p,  # data
            ctypes.c_int,     # size
            ctypes.c_int32,   # dtype
            ctypes.c_int,     # seed
            ctypes.c_int,     # min
            ctypes.c_int      # max
        ]
        self._lib.gen_random_data.restype = None
        
        self._lib.float_to_half.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
        self._lib.float_to_half.restype = None
        
        self._lib.half_to_float.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
        self._lib.half_to_float.restype = None
        
        # 仿真算子 (xxxSim)
        self._lib.GemmSim.argtypes = [
            ctypes.c_void_p,  # output [n_group, m, n_group_size]
            ctypes.c_void_p,  # ifmap [k_group, m, k_group_size]
            ctypes.c_void_p,  # weight [n_group, k_group, n_group_size, k_group_size]
            ctypes.c_int,     # m
            ctypes.c_int,     # n
            ctypes.c_int,     # k
            ctypes.c_int,     # tile_m
            ctypes.c_int,     # block_n_group
            ctypes.c_int      # block_k_group
        ]
        self._lib.GemmSim.restype = None
        
        self._lib.RMSNormSim.argtypes = [
            ctypes.c_void_p,  # output
            ctypes.c_void_p,  # input
            ctypes.c_void_p,  # gamma
            ctypes.c_int,     # seq_len
            ctypes.c_int,     # d_model
            ctypes.c_float,   # epsilon
            ctypes.c_int32    # dtype
        ]
        self._lib.RMSNormSim.restype = None
        
        self._lib.SoftmaxSim.argtypes = [
            ctypes.c_void_p,  # output
            ctypes.c_void_p,  # input
            ctypes.c_int,     # seq_len
            ctypes.c_int,     # d_model
            ctypes.c_int32    # dtype
        ]
        self._lib.SoftmaxSim.restype = None
                
        self._lib.LlamaBlockSim.argtypes = [
            ctypes.c_void_p,  # output_hidden_state
            ctypes.c_void_p,  # input_hidden_state
            ctypes.c_void_p,  # attn_norm_gamma
            ctypes.c_void_p,  # ffn_norm_gamma
            ctypes.c_void_p,  # query_weight
            ctypes.c_void_p,  # key_weight
            ctypes.c_void_p,  # value_weight
            ctypes.c_void_p,  # output_weight
            ctypes.c_void_p,  # gate_weight
            ctypes.c_void_p,  # up_weight
            ctypes.c_void_p,  # down_weight
            ctypes.c_int,     # seq_len
            ctypes.c_int,     # d_model
            ctypes.c_int,     # intermediate_size
            ctypes.c_int,     # num_attention_heads
            ctypes.c_float    # rmsnorm_epsilon
        ]
        self._lib.LlamaBlockSim.restype = None
        
        # 指令生成函数
        self._lib.Gemm.argtypes = [
            ctypes.c_char_p,   # insn_file_name
            ctypes.c_int,      # m
            ctypes.c_int,      # n
            ctypes.c_int,      # k
            ctypes.c_int,      # tile_m
            ctypes.c_int,      # block_n_group
            ctypes.c_int,      # block_k_group
            ctypes.c_uint64,   # ifmap_addr
            ctypes.c_uint64,   # weight_addr
            ctypes.c_uint64,   # output_addr
            ctypes.c_int       # all_done
        ]
        self._lib.Gemm.restype = ctypes.c_uint64
        
        self._lib.RMSNorm.argtypes = [
            ctypes.c_char_p,   # insn_file_name
            ctypes.c_char_p,   # vcucode_file_name
            ctypes.c_int,      # seq_len
            ctypes.c_int,      # d_model
            ctypes.c_int,      # tile_m
            ctypes.c_int,      # block_oc_group
            ctypes.c_float,    # epsilon
            ctypes.c_int32,    # dtype
            ctypes.c_uint64,   # input_ddr_base_address
            ctypes.c_uint64,   # gamma_ddr_base_address
            ctypes.c_uint64,   # output_ddr_base_address
            ctypes.c_uint64,   # vcucode_ddr_base_address
            ctypes.c_uint64,   # rec_lut_ddr_base_address
            ctypes.c_uint64,   # log_lut_ddr_base_address
            ctypes.c_uint64,   # exp_lut_ddr_base_address
            ctypes.c_uint64,   # rsqrt_lut_ddr_base_address
            ctypes.c_int       # all_done
        ]
        self._lib.RMSNorm.restype = ctypes.c_uint64
        
        self._lib.Softmax.argtypes = [
            ctypes.c_char_p,   # insn_file_name
            ctypes.c_char_p,   # vcucode_file_name
            ctypes.c_int,      # seq_len
            ctypes.c_int,      # d_model
            ctypes.c_int,      # tile_m
            ctypes.c_int,      # block_oc_group
            ctypes.c_uint64,   # input_addr
            ctypes.c_uint64,   # output_addr
            ctypes.c_uint64,   # vcu_code_addr
            ctypes.c_uint64,   # exp_lut_addr
            ctypes.c_uint64,   # rec_lut_addr
            ctypes.c_int       # all_done
        ]
        self._lib.Softmax.restype = ctypes.c_int

        self._lib.LlamaBlock.argtypes = [
            ctypes.c_char_p,   # insn_file_name
            ctypes.c_char_p,   # vcucode_file_name
            ctypes.c_int,      # seq_len
            ctypes.c_int,      # hidden_size
            ctypes.c_int,      # intermediate_size
            ctypes.c_int,      # num_attention_heads
            ctypes.c_float,    # rmsnorm_epsilon
            ctypes.c_int32,    # hidden_dtype
            ctypes.c_int32,    # weight_dtype
            ctypes.c_uint64,   # input_hidden_state_addr
            ctypes.c_uint64,   # final_output_hidden_state_addr
            # RoPE and Mask Parameters
            ctypes.c_uint64,   # freq_cls_base_addr
            ctypes.c_uint64,   # mask_base_addr
            # Weight Address
            ctypes.c_uint64,   # attn_norm_gamma_addr
            ctypes.c_uint64,   # attn_query_weight_addr
            ctypes.c_uint64,   # attn_key_weight_addr
            ctypes.c_uint64,   # attn_value_weight_addr
            ctypes.c_uint64,   # attn_output_weight_addr
            ctypes.c_uint64,   # ffn_norm_gamma_addr
            ctypes.c_uint64,   # mlp_gate_weight_addr
            ctypes.c_uint64,   # mlp_up_weight_addr
            ctypes.c_uint64,   # mlp_down_weight_addr
            # Temporary Storage Addresses
            ctypes.c_uint64,   # attn_norm_output_addr
            ctypes.c_uint64,   # attn_query_temp_addr
            ctypes.c_uint64,   # attn_key_temp_addr
            ctypes.c_uint64,   # attn_value_temp_addr
            ctypes.c_uint64,   # attn_score_temp_addr
            ctypes.c_uint64,   # attn_probe_temp_addr
            ctypes.c_uint64,   # attn_output_temp_addr
            ctypes.c_uint64,   # attn_output_proj_addr
            ctypes.c_uint64,   # residual_after_attn_addr
            ctypes.c_uint64,   # ffn_norm_output_addr
            ctypes.c_uint64,   # mlp_gate_output_addr
            ctypes.c_uint64,   # mlp_up_output_addr
            ctypes.c_uint64,   # mlp_mul_output_addr
            ctypes.c_uint64,   # mlp_final_proj_output_addr
            # VCU code Addresses
            ctypes.c_uint64,   # vcu_code_llama_block_addr
            ctypes.c_uint64,   # rec_lut_addr
            ctypes.c_uint64,   # log_lut_addr
            ctypes.c_uint64,   # exp_lut_addr
            ctypes.c_uint64,   # rsqrt_lut_addr
            ctypes.c_uint64,   # swish_lut_addr
            ctypes.c_int       # all_done
        ]
        self._lib.LlamaBlock.restype = ctypes.c_uint64
        
        logger.info("✅ C函数签名设置完成")

    # ========================== 工具函数 ==========================
    
    def gen_random_data(self, size: int, dtype: int = DType.kFloat32, 
                       seed: int = 42, min_val: int = -1, max_val: int = 1) -> np.ndarray:
        """
        生成随机测试数据
        
        Args:
            size: 数据元素个数
            dtype: 数据类型 (DType.kFloat32 或 DType.kHalf)
            seed: 随机种子
            min_val: 最小值
            max_val: 最大值
        
        Returns:
            生成的随机数据数组
        """
        if dtype == DType.kFloat32:
            data = np.zeros(size, dtype=np.float32)
        elif dtype == DType.kHalf:
            data = np.zeros(size, dtype=np.float16)
        else:
            raise ValueError(f"不支持的数据类型: {dtype}")
        
        self._lib.gen_random_data(
            data.ctypes.data_as(ctypes.c_void_p),
            size, dtype, seed, min_val, max_val
        )
        
        return data
    
    def float_to_half(self, float_data: np.ndarray) -> np.ndarray:
        """将float32数据转换为half (fp16)"""
        if float_data.dtype != np.float32:
            float_data = float_data.astype(np.float32)
        
        half_data = np.zeros_like(float_data, dtype=np.float16)
        
        self._lib.float_to_half(
            half_data.ctypes.data_as(ctypes.c_void_p),
            float_data.ctypes.data_as(ctypes.c_void_p),
            float_data.size
        )
        
        return half_data
    
    def half_to_float(self, half_data: np.ndarray) -> np.ndarray:
        """将half (fp16)数据转换为float32"""
        if half_data.dtype != np.float16:
            half_data = half_data.astype(np.float16)
        
        float_data = np.zeros_like(half_data, dtype=np.float32)
        
        self._lib.half_to_float(
            float_data.ctypes.data_as(ctypes.c_void_p),
            half_data.ctypes.data_as(ctypes.c_void_p),
            half_data.size
        )
        
        return float_data

    # ========================== 仿真算子 (xxxSim系列) ==========================
    
    def GemmSim(self, ifmap: np.ndarray, weight: np.ndarray, 
                m: int, n: int, k: int,
                tile_m: int = 64, block_n_group: int = 4, block_k_group: int = 16) -> np.ndarray:
        """
        GEMM矩阵乘法仿真
        
        Args:
            ifmap: 输入特征图 [k_group, m, k_group_size]，k_group_size=16
            weight: 权重矩阵 [n_group, k_group, n_group_size, k_group_size]，n_group_size=32
            m, n, k: 矩阵维度
            tile_m, block_n_group, block_k_group: 分块参数
        
        Returns:
            输出张量 [n_group, m, n_group_size]
        """
        # 计算分组维度
        n_group_size = 32
        k_group_size = 16
        n_group = n // n_group_size
        k_group = k // k_group_size
        
        # 验证输入形状
        expected_ifmap_shape = (k_group, m, k_group_size)
        expected_weight_shape = (n_group, k_group, n_group_size, k_group_size)
        
        if ifmap.shape != expected_ifmap_shape:
            raise ValueError(f"ifmap形状错误: 期望 {expected_ifmap_shape}, 实际 {ifmap.shape}")
        if weight.shape != expected_weight_shape:
            raise ValueError(f"weight形状错误: 期望 {expected_weight_shape}, 实际 {weight.shape}")
        
        # 确保数据类型正确
        ifmap = ifmap.astype(np.float16)
        weight = weight.astype(np.float16)
        
        # 创建输出张量
        output = np.zeros((n_group, m, n_group_size), dtype=np.float32)
        
        # 调用C函数
        self._lib.GemmSim(
            output.ctypes.data_as(ctypes.c_void_p),
            ifmap.ctypes.data_as(ctypes.c_void_p),
            weight.ctypes.data_as(ctypes.c_void_p),
            m, n, k, tile_m, block_n_group, block_k_group
        )
        
        return output
    
    def RMSNormSim(self, input_data: np.ndarray, gamma: np.ndarray,
                   seq_len: int, d_model: int, epsilon: float = 1e-6,
                   dtype: int = DType.kFloat32) -> np.ndarray:
        """
        RMSNorm层归一化仿真
        
        Args:
            input_data: 输入数据 [oc_group, seq_len, oc_group_size]，oc_group_size=32
            gamma: 缩放参数 [oc_group, oc_group_size]
            seq_len: 序列长度
            d_model: 模型维度
            epsilon: 数值稳定性参数
            dtype: 数据类型
        
        Returns:
            归一化后的输出张量
        """
        oc_group_size = 32
        oc_group = d_model // oc_group_size
        
        # 验证输入形状
        expected_input_shape = (oc_group, seq_len, oc_group_size)
        expected_gamma_shape = (oc_group, oc_group_size)
        
        if input_data.shape != expected_input_shape:
            raise ValueError(f"input形状错误: 期望 {expected_input_shape}, 实际 {input_data.shape}")
        if gamma.shape != expected_gamma_shape:
            raise ValueError(f"gamma形状错误: 期望 {expected_gamma_shape}, 实际 {gamma.shape}")
        
        # 确保数据类型正确
        if dtype == DType.kFloat32:
            input_data = input_data.astype(np.float32)
            gamma = gamma.astype(np.float32)
            output = np.zeros_like(input_data, dtype=np.float32)
        else:
            raise ValueError(f"暂不支持的数据类型: {dtype}")
        
        # 调用C函数
        self._lib.RMSNormSim(
            output.ctypes.data_as(ctypes.c_void_p),
            input_data.ctypes.data_as(ctypes.c_void_p),
            gamma.ctypes.data_as(ctypes.c_void_p),
            seq_len, d_model, epsilon, dtype
        )
        
        return output
    
    def SoftmaxSim(self, input_data: np.ndarray, seq_len: int, d_model: int) -> np.ndarray:
        """
        Softmax激活函数仿真
        
        Args:
            input_data: 输入数据
            seq_len: 序列长度
            d_model: 模型维度
        
        Returns:
            Softmax输出张量
        """
        # 创建输出张量
        output = np.zeros_like(input_data)
        oc_group_size = 32
        oc_group = d_model // oc_group_size

        # 调用C函数
        self._lib.SoftmaxSim(
            output.ctypes.data_as(ctypes.c_void_p),
            input_data.ctypes.data_as(ctypes.c_void_p),
            oc_group, seq_len, oc_group_size
        )

        return output
    
    def LlamaBlockSim(self, input_hidden_state: np.ndarray,
                      attn_norm_gamma: np.ndarray,
                      ffn_norm_gamma: np.ndarray,
                      query_weight: np.ndarray, key_weight: np.ndarray, 
                      value_weight: np.ndarray, output_weight: np.ndarray,
                      gate_weight: np.ndarray, up_weight: np.ndarray, down_weight: np.ndarray,
                      seq_len: int, hidden_size: int, intermediate_size: int, num_attention_heads: int,
                      rmsnorm_epsilon: float) -> np.ndarray:
        """
        Llama完整Block仿真
        
        Args:
            input_hidden_state: 输入隐藏状态
            attn_norm_gamma, ffn_norm_gamma: 归一化参数
            query_weight, key_weight, value_weight, output_weight: 注意力权重
            gate_weight, up_weight, down_weight: MLP权重
            seq_len: 序列长度
            hidden_size: 模型维度
            intermediate_size: 中间层维度
            num_attention_heads: 注意力头数
            rmsnorm_epsilon: 1e-6f        
        Returns:
            Block输出隐藏状态
        """
        # 创建输出张量
        output_hidden_state = np.zeros_like(input_hidden_state)
        
        # 调用C函数
        self._lib.LlamaBlockSim(
            output_hidden_state.ctypes.data_as(ctypes.c_void_p),
            input_hidden_state.ctypes.data_as(ctypes.c_void_p),
            attn_norm_gamma.ctypes.data_as(ctypes.c_void_p),
            ffn_norm_gamma.ctypes.data_as(ctypes.c_void_p),
            query_weight.ctypes.data_as(ctypes.c_void_p),
            key_weight.ctypes.data_as(ctypes.c_void_p),
            value_weight.ctypes.data_as(ctypes.c_void_p),
            output_weight.ctypes.data_as(ctypes.c_void_p),
            gate_weight.ctypes.data_as(ctypes.c_void_p),
            up_weight.ctypes.data_as(ctypes.c_void_p),
            down_weight.ctypes.data_as(ctypes.c_void_p),
            seq_len, hidden_size, intermediate_size, num_attention_heads,
            rmsnorm_epsilon
        )
        
        return output_hidden_state

    # ========================== 指令生成函数 (返回uint64_t系列) ==========================
    
    def Gemm(self, insn_file_name: str, m: int, n: int, k: int,
             tile_m: int, block_n_group: int, block_k_group: int,
             ifmap_addr: int, weight_addr: int, output_addr: int,
             all_done: int = 1) -> int:
        """
        生成GEMM指令
        
        Args:
            insn_file_name: 指令文件名
            m, n, k: 矩阵维度
            tile_m, block_n_group, block_k_group: 分块参数
            ifmap_addr, weight_addr, output_addr: DDR地址
            all_done: 完成标志
        
        Returns:
            生成的指令数量
        """
        result = self._lib.Gemm(
            insn_file_name.encode('utf-8'),
            m, n, k, tile_m, block_n_group, block_k_group,
            ifmap_addr, weight_addr, output_addr, all_done
        )
        
        logger.info(f"✅ GEMM指令生成完成: {result} 条指令 -> {insn_file_name}")
        return result
    
    def RMSNorm(self, insn_file_name: str, vcucode_file_name: str,
                seq_len: int, d_model: int, tile_m: int, block_oc_group: int,
                epsilon: float, dtype: int,
                input_ddr_base_address: int, gamma_ddr_base_address: int,
                output_ddr_base_address: int, vcucode_ddr_base_address: int,
                rec_lut_ddr_base_address: int, log_lut_ddr_base_address: int,
                exp_lut_ddr_base_address: int, rsqrt_lut_ddr_base_address: int,
                all_done: int = 1) -> int:
        """
        生成RMSNorm指令
        
        Returns:
            生成的指令数量
        """
        result = self._lib.RMSNorm(
            insn_file_name.encode('utf-8'),
            vcucode_file_name.encode('utf-8'),
            seq_len, d_model, tile_m, block_oc_group,
            epsilon, dtype,
            input_ddr_base_address, gamma_ddr_base_address,
            output_ddr_base_address, vcucode_ddr_base_address,
            rec_lut_ddr_base_address, log_lut_ddr_base_address,
            exp_lut_ddr_base_address, rsqrt_lut_ddr_base_address,
            all_done
        )
        
        logger.info(f"✅ RMSNorm指令生成完成: {result} 条指令 -> {insn_file_name}")
        return result
    
    def Softmax(self, insn_file_name: str, vcucode_file_name: str,
                seq_len: int, d_model: int, tile_m: int, block_oc_group: int,
                input_addr: int, output_addr: int, vcu_code_addr: int,
                exp_lut_addr: int, rec_lut_addr: int,
                all_done: int = 1) -> int:
        """
        生成Softmax指令
        
        Args:
            insn_file_name: 指令文件名
            vcucode_file_name: VCU代码文件名
            seq_len: 序列长度
            d_model: 模型维度
            tile_m: tile参数
            block_oc_group: block参数
            input_addr: 输入地址
            output_addr: 输出地址
            vcu_code_addr: VCU代码地址
            exp_lut_addr, rec_lut_addr: LUT地址
            all_done: 完成标志
        
        Returns:
            生成的指令数量
        """
        result = self._lib.Softmax(
            insn_file_name.encode('utf-8'),
            vcucode_file_name.encode('utf-8'),
            seq_len, d_model, tile_m, block_oc_group,
            input_addr, output_addr, vcu_code_addr,
            exp_lut_addr, rec_lut_addr,
            all_done
        )
        
        logger.info(f"✅ Softmax指令生成完成: {result} 条指令 -> {insn_file_name}")
        return result
    
    def LlamaBlock(self, insn_file_name: str, vcucode_file_name: str,
                   seq_len: int, hidden_size: int, intermediate_size: int,
                   num_attention_heads: int, rmsnorm_epsilon: float,
                   hidden_dtype: int, weight_dtype: int,
                   input_hidden_state_addr: int, final_output_hidden_state_addr: int,
                   freq_cls_base_addr: int, mask_base_addr: int,
                   attn_norm_gamma_addr: int, attn_query_weight_addr: int,
                   attn_key_weight_addr: int, attn_value_weight_addr: int,
                   attn_output_weight_addr: int, ffn_norm_gamma_addr: int,
                   mlp_gate_weight_addr: int, mlp_up_weight_addr: int, mlp_down_weight_addr: int,
                   attn_norm_output_addr: int, attn_query_temp_addr: int,
                   attn_key_temp_addr: int, attn_value_temp_addr: int,
                   attn_score_temp_addr: int, attn_probe_temp_addr: int,
                   attn_output_temp_addr: int, attn_output_proj_addr: int,
                   residual_after_attn_addr: int, ffn_norm_output_addr: int,
                   mlp_gate_output_addr: int, mlp_up_output_addr: int,
                   mlp_mul_output_addr: int, mlp_final_proj_output_addr: int,
                   vcu_code_llama_block_addr: int, rec_lut_addr: int,
                   log_lut_addr: int, exp_lut_addr: int, rsqrt_lut_addr: int,
                   swish_lut_addr: int, all_done: int = 1) -> int:
        """
        生成LlamaBlock指令
        
        Args:
            insn_file_name: 指令文件名
            vcucode_file_name: VCU代码文件名
            seq_len: 序列长度
            hidden_size: 隐藏层维度 (d_model)
            intermediate_size: 中间层维度
            num_attention_heads: 注意力头数
            rmsnorm_epsilon: RMSNorm epsilon参数
            hidden_dtype: 隐藏状态数据类型
            weight_dtype: 权重数据类型
            input_hidden_state_addr: 输入隐藏状态地址
            final_output_hidden_state_addr: 最终输出隐藏状态地址
            freq_cls_base_addr: RoPE频率类基地址
            mask_base_addr: Mask基地址
            attn_norm_gamma_addr: 注意力RMSNorm gamma地址
            attn_query_weight_addr: Query权重地址
            attn_key_weight_addr: Key权重地址
            attn_value_weight_addr: Value权重地址
            attn_output_weight_addr: 注意力输出权重地址
            ffn_norm_gamma_addr: FFN RMSNorm gamma地址
            mlp_gate_weight_addr: MLP Gate权重地址
            mlp_up_weight_addr: MLP Up权重地址
            mlp_down_weight_addr: MLP Down权重地址
            attn_norm_output_addr: 注意力RMSNorm输出地址
            attn_query_temp_addr: Query临时地址
            attn_key_temp_addr: Key临时地址
            attn_value_temp_addr: Value临时地址
            attn_score_temp_addr: 注意力分数临时地址
            attn_probe_temp_addr: Softmax输出临时地址
            attn_output_temp_addr: 注意力输出临时地址
            attn_output_proj_addr: 注意力投影输出地址
            residual_after_attn_addr: 注意力后残差地址
            ffn_norm_output_addr: FFN RMSNorm输出地址
            mlp_gate_output_addr: MLP Gate输出地址
            mlp_up_output_addr: MLP Up输出地址
            mlp_mul_output_addr: MLP乘法输出地址
            mlp_final_proj_output_addr: MLP最终投影输出地址
            vcu_code_llama_block_addr: VCU代码地址
            rec_lut_addr: REC LUT地址
            log_lut_addr: LOG LUT地址
            exp_lut_addr: EXP LUT地址
            rsqrt_lut_addr: RSQRT LUT地址
            swish_lut_addr: Swish LUT地址
            all_done: 完成标志
        
        Returns:
            生成的指令数量
        """
        result = self._lib.LlamaBlock(
            insn_file_name.encode('utf-8'),
            vcucode_file_name.encode('utf-8'),
            seq_len, hidden_size, intermediate_size, num_attention_heads,
            rmsnorm_epsilon, hidden_dtype, weight_dtype,
            input_hidden_state_addr, final_output_hidden_state_addr,
            freq_cls_base_addr, mask_base_addr,
            attn_norm_gamma_addr, attn_query_weight_addr,
            attn_key_weight_addr, attn_value_weight_addr,
            attn_output_weight_addr, ffn_norm_gamma_addr,
            mlp_gate_weight_addr, mlp_up_weight_addr, mlp_down_weight_addr,
            attn_norm_output_addr, attn_query_temp_addr,
            attn_key_temp_addr, attn_value_temp_addr,
            attn_score_temp_addr, attn_probe_temp_addr,
            attn_output_temp_addr, attn_output_proj_addr,
            residual_after_attn_addr, ffn_norm_output_addr,
            mlp_gate_output_addr, mlp_up_output_addr,
            mlp_mul_output_addr, mlp_final_proj_output_addr,
            vcu_code_llama_block_addr, rec_lut_addr,
            log_lut_addr, exp_lut_addr, rsqrt_lut_addr,
            swish_lut_addr, all_done
        )
        
        logger.info(f"✅ LlamaBlock指令生成完成: {result} 条指令 -> {insn_file_name}")
        return result

# 全局实例，方便导入使用
_npu_core = None

def get_npu_core() -> NPUCore:
    """获取NPU核心接口的全局实例"""
    global _npu_core
    if _npu_core is None:
        _npu_core = NPUCore()
    return _npu_core
