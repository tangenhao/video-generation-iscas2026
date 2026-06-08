"""
NPU算子高级封装接口
按照流程步骤1.2的设计思路实现：
- 提供算子封装类，支持文件导向的接口
- 实现GEMM、RMSNorm、Softmax、LlamaBlock算子的高级封装
- 支持仿真和指令生成两种模式
"""

import numpy as np
from pathlib import Path
from typing import Dict, Union, Optional, Tuple, Any
import logging

from .core import get_npu_core, DType
from .data_io import TensorIO, DataValidator, FileManager

logger = logging.getLogger(__name__)

class NPUOperator:
    """NPU算子基类，提供文件导向的接口"""
    
    def __init__(self, name: str, base_dir: Union[str, Path] = ""):
        self.name = name
        self.npu_core = get_npu_core()
        self.file_manager = FileManager(f"{base_dir}/{name}" if base_dir != "" else "")
        logger.info(f"✅ {name} 算子初始化完成")
    
    def simulate_from_files(self, input_files: Dict[str, str], 
                           output_files: Dict[str, str], 
                           params: Dict[str, Any]) -> Dict[str, np.ndarray]:
        """
        从文件加载数据，运行仿真，保存结果到文件
        
        Args:
            input_files: 输入文件映射 {"input_name": "file_path"}
            output_files: 输出文件映射 {"output_name": "file_path"}
            params: 算子参数
        
        Returns:
            输出张量字典
        """
        raise NotImplementedError("子类必须实现此方法")
    
    def generate_instructions(self, params: Dict[str, Any], 
                            addresses: Dict[str, int], 
                            output_files: Dict[str, str]) -> int:
        """
        生成NPU指令并保存到文件
        
        Args:
            params: 算子参数
            addresses: DDR地址映射
            output_files: 输出文件映射
        
        Returns:
            生成的指令数量
        """
        raise NotImplementedError("子类必须实现此方法")

class GemmOperator(NPUOperator):
    """GEMM算子封装"""
    
    def __init__(self):
        super().__init__("Gemm")
    
    def simulate_from_files(self, input_files: Dict[str, str], 
                           output_files: Dict[str, str], 
                           params: Dict[str, Any]) -> Dict[str, np.ndarray]:
        """
        GEMM仿真接口
        
        Args:
            input_files: {"ifmap": "ifmap_file.bin", "weight": "weight_file.bin"}
            output_files: {"output": "output_file.bin"}
            params: {"m": 64, "n": 4096, "k": 4096, "tile_m": 64, "block_n_group": 4, "block_k_group": 16}
        
        Returns:
            {"output": output_tensor}
        """
        logger.info(f"🚀 开始GEMM仿真: {params}")
        
        # 解析参数
        m = params["m"]
        n = params["n"] 
        k = params["k"]
        tile_m = params.get("tile_m", 64)
        block_n_group = params.get("block_n_group", 4)
        block_k_group = params.get("block_k_group", 16)
        
        # 计算预期形状
        n_group_size = 32
        k_group_size = 16
        n_group = n // n_group_size
        k_group = k // k_group_size
        
        ifmap_shape = (k_group, m, k_group_size)
        weight_shape = (n_group, k_group, n_group_size, k_group_size)
        output_shape = (n_group, m, n_group_size)
        
        # 加载输入数据
        logger.info("📥 加载输入数据...")
        ifmap = TensorIO.load_raw_tensor(
            input_files["ifmap"], ifmap_shape, np.float16
        )
        weight = TensorIO.load_raw_tensor(
            input_files["weight"], weight_shape, np.float16
        )
        
        # 验证输入
        DataValidator.validate_tensor_properties(
            ifmap, ifmap_shape, np.float16, name="ifmap"
        )
        DataValidator.validate_tensor_properties(
            weight, weight_shape, np.float16, name="weight"
        )
        
        # 执行仿真
        logger.info("⚡ 执行GEMM仿真...")
        output = self.npu_core.GemmSim(
            ifmap, weight, m, n, k, tile_m, block_n_group, block_k_group
        )
        
        # 保存输出
        logger.info("💾 保存输出数据...")
        TensorIO.save_raw_tensor(output, output_files["output"])
        
        # 验证输出
        DataValidator.validate_tensor_properties(
            output, output_shape, np.float32, name="output"
        )
        
        logger.info(f"✅ GEMM仿真完成: {output.shape} -> {output_files['output']}")
        
        return {"output": output}
    
    def generate_instructions(self, params: Dict[str, Any], 
                            addresses: Dict[str, int], 
                            output_files: Dict[str, str]) -> int:
        """
        生成GEMM指令
        
        Args:
            params: {"m": 64, "n": 4096, "k": 4096, ...}
            addresses: {"ifmap_addr": 0x1000, "weight_addr": 0x2000, "output_addr": 0x3000}
            output_files: {"insn": "gemm_insn.bin"}
        
        Returns:
            生成的指令数量
        """
        logger.info(f"🔧 生成GEMM指令: {params}")
        
        insn_count = self.npu_core.Gemm(
            output_files["insn"],
            params["m"], params["n"], params["k"],
            params.get("tile_m", 64),
            params.get("block_n_group", 4),
            params.get("block_k_group", 16),
            addresses["ifmap_addr"],
            addresses["weight_addr"],
            addresses["output_addr"],
            params.get("all_done", 1)
        )
        
        return insn_count

class RMSNormOperator(NPUOperator):
    """RMSNorm算子封装"""
    
    def __init__(self):
        super().__init__("RMSNorm")
    
    def simulate_from_files(self, input_files: Dict[str, str], 
                           output_files: Dict[str, str], 
                           params: Dict[str, Any]) -> Dict[str, np.ndarray]:
        """
        RMSNorm仿真接口
        
        Args:
            input_files: {"input": "input_file.bin", "gamma": "gamma_file.bin"}
            output_files: {"output": "output_file.bin"}
            params: {"seq_len": 64, "d_model": 4096, "epsilon": 1e-6, "dtype": DType.kFloat32}
        """
        logger.info(f"🚀 开始RMSNorm仿真: {params}")
        
        # 解析参数
        seq_len = params["seq_len"]
        d_model = params["d_model"]
        epsilon = params.get("epsilon", 1e-6)
        dtype = params.get("dtype", DType.kFloat32)
        
        # 计算预期形状
        oc_group_size = 32
        oc_group = d_model // oc_group_size
        
        input_shape = (oc_group, seq_len, oc_group_size)
        gamma_shape = (oc_group, oc_group_size)
        
        # 加载输入数据
        logger.info("📥 加载输入数据...")
        input_data = TensorIO.load_raw_tensor(
            input_files["input"], input_shape, np.float32
        )
        gamma = TensorIO.load_raw_tensor(
            input_files["gamma"], gamma_shape, np.float32
        )
        
        # 执行仿真
        logger.info("⚡ 执行RMSNorm仿真...")
        output = self.npu_core.RMSNormSim(
            input_data, gamma, seq_len, d_model, epsilon, dtype
        )
        
        # 保存输出
        logger.info("💾 保存输出数据...")
        TensorIO.save_raw_tensor(output, output_files["output"])
        
        logger.info(f"✅ RMSNorm仿真完成: {output.shape} -> {output_files['output']}")
        
        return {"output": output}
    
    def generate_instructions(self, params: Dict[str, Any], 
                            addresses: Dict[str, int], 
                            output_files: Dict[str, str]) -> int:
        """生成RMSNorm指令"""
        logger.info(f"🔧 生成RMSNorm指令: {params}")
        
        insn_count = self.npu_core.RMSNorm(
            output_files["insn"],
            output_files.get("vcucode", "rmsnorm_vcucode.bin"),
            params["seq_len"], params["d_model"],
            params.get("tile_m", 64),
            params.get("block_oc_group", 4),
            params.get("epsilon", 1e-6),
            params.get("dtype", DType.kFloat32),
            addresses["input_addr"],
            addresses["gamma_addr"],
            addresses["output_addr"],
            addresses.get("vcucode_addr", 0),
            addresses.get("rec_lut_addr", 0),
            addresses.get("log_lut_addr", 0),
            addresses.get("exp_lut_addr", 0),
            addresses.get("rsqrt_lut_addr", 0),
            params.get("all_done", 1)
        )
        
        return insn_count

class SoftmaxOperator(NPUOperator):
    """Softmax算子封装"""
    
    def __init__(self):
        super().__init__("Softmax")
    
    def simulate_from_files(self, input_files: Dict[str, str], 
                           output_files: Dict[str, str], 
                           params: Dict[str, Any]) -> Dict[str, np.ndarray]:
        """Softmax仿真接口"""
        logger.info(f"🚀 开始Softmax仿真: {params}")
        
        # 解析参数
        seq_len = params["seq_len"]
        d_model = params["d_model"]
        dtype = params.get("dtype", DType.kFloat32)

        n_group_size = 32
        n_group = d_model // n_group_size
        input_shape = (n_group, seq_len, n_group_size)
        
        # 加载输入数据
        logger.info("📥 加载输入数据...")
        input_data = TensorIO.load_raw_tensor(
            input_files["input"], input_shape, 
            np.float32 
        )
        
        # 执行仿真
        logger.info("⚡ 执行Softmax仿真...")
        output = self.npu_core.SoftmaxSim(input_data, seq_len, d_model)
        
        # 保存输出
        logger.info("💾 保存输出数据...")
        TensorIO.save_raw_tensor(output, output_files["output"])
        
        logger.info(f"✅ Softmax仿真完成: {output.shape} -> {output_files['output']}")
        
        return {"output": output}
    
    def generate_instructions(self, insn_file_name: str, vcucode_file_name: str,
                            seq_len: int, d_model: int,
                            input_addr: int, output_addr: int, vcu_code_addr: int,
                            exp_lut_addr: int, rec_lut_addr: int, 
                            all_done: int = 1,
                            tile_m: int = None, block_oc_group: int = None) -> int:
        """
        生成Softmax指令
        
        Args:
            insn_file_name: 指令文件名
            vcucode_file_name: VCU代码文件名
            seq_len: 序列长度
            d_model: 模型维度
            input_addr: 输入地址
            output_addr: 输出地址
            vcu_code_addr: VCU代码地址
            exp_lut_addr, rec_lut_addr: LUT地址
            all_done: 完成标志
            tile_m: tile参数（可选）
            block_oc_group: block参数（可选）
            
        Returns:
            生成的指令数量
        """
        if tile_m is None:
            tile_m = seq_len
        if block_oc_group is None:
            block_oc_group = 1
            
        return self.npu_core.Softmax(
            insn_file_name, vcucode_file_name,
            seq_len, d_model, tile_m, block_oc_group,
            input_addr, output_addr, vcu_code_addr,
            exp_lut_addr, rec_lut_addr,
            all_done
        )

class LlamaBlockOperator(NPUOperator):
    """Llama Block算子封装"""
    
    def __init__(self):
        super().__init__("LlamaBlock")
    
    def simulate_from_files(self, input_files: Dict[str, str], 
                           output_files: Dict[str, str], 
                           params: Dict[str, Any]) -> Dict[str, np.ndarray]:
        """
        Llama Block仿真接口
        
        Args:
            input_files: {
                "input_hidden_state": "input_hidden_state.bin",
                "attn_norm_gamma": "attn_norm_gamma.bin",
                "ffn_norm_gamma": "ffn_norm_gamma.bin",
                "query_weight": "query_weight.bin",
                "key_weight": "key_weight.bin", 
                "value_weight": "value_weight.bin",
                "output_weight": "output_weight.bin",
                "gate_weight": "gate_weight.bin",
                "up_weight": "up_weight.bin",
                "down_weight": "down_weight.bin"
            }
            output_files: {"output_hidden_state": "output_hidden_state.bin"}
            params: {
                "seq_len": 64, "hidden_size": 4096, "intermediate_size": 11008, 
                "num_attention_heads": 32, "rmsnorm_epsilon": 1e-6,
            }
        """
        logger.info(f"🚀 开始Llama Block仿真: {params}")
        
        # 解析参数
        seq_len = params["seq_len"]
        hidden_size = params["hidden_size"]
        intermediate_size = params["intermediate_size"]
        num_attention_heads = params["num_attention_heads"]
        rmsnorm_epsilon = params.get("rmsnorm_epsilon", 1e-6)
                
        # 计算预期形状
        oc_group_size = 32
        k_group_size = 16
        n_group_size = 32
        
        oc_group = hidden_size // oc_group_size
        ic_group_attn = hidden_size // k_group_size
        oc_group_mlp = intermediate_size // n_group_size
        ic_group_mlp = intermediate_size // k_group_size
        
        # 定义固定顺序的张量形状和数据类型
        tensor_specs = [
            ("input_hidden_state", (oc_group, seq_len, oc_group_size), np.float32),
            ("attn_norm_gamma", (oc_group, oc_group_size), np.float32),
            ("ffn_norm_gamma", (oc_group, oc_group_size), np.float32),
            ("query_weight", (oc_group, ic_group_attn, n_group_size, k_group_size), np.float16),
            ("key_weight", (oc_group, ic_group_attn, n_group_size, k_group_size), np.float16),
            ("value_weight", (oc_group, ic_group_attn, n_group_size, k_group_size), np.float16),
            ("output_weight", (oc_group, ic_group_attn, n_group_size, k_group_size), np.float16),
            ("gate_weight", (oc_group_mlp, ic_group_attn, n_group_size, k_group_size), np.float16),
            ("up_weight", (oc_group_mlp, ic_group_attn, n_group_size, k_group_size), np.float16),
            ("down_weight", (oc_group, ic_group_mlp, n_group_size, k_group_size), np.float16)
        ]        
        
        # 加载所有输入数据
        logger.info("📥 加载输入数据...")
        tensors = []
        # 加载输入隐藏状态
        input_spec = tensor_specs[0]
        first_key = next(iter(input_files))
        file_path = input_files[first_key]    
        logger.info(f"  加载 {input_spec[0]}: {input_spec[1]} {input_spec[2]}")
        input_tensor = TensorIO.load_raw_tensor(file_path, input_spec[1], input_spec[2])
        tensors.append(input_tensor)

        # 按固定顺序加载权重文件
        weight_keys = [
            "attn_norm_gamma", "ffn_norm_gamma", "query_weight", "key_weight",
            "value_weight", "output_weight", "gate_weight", "up_weight", "down_weight"
        ]
        
        for i, weight_key in enumerate(weight_keys):
            spec = tensor_specs[i + 1]  # 第0个是input_hidden_state
            
            if weight_key in input_files:
                file_path = input_files[weight_key]
                logger.info(f"  加载 {spec[0]}: {spec[1]} {spec[2]} <- {file_path}")
                tensor = TensorIO.load_raw_tensor(file_path, spec[1], spec[2])
                tensors.append(tensor)
            else:
                raise ValueError(f"缺少必需的权重文件: {weight_key}")
            
        # 执行仿真
        logger.info("⚡ 执行Llama Block仿真...")
        output_hidden_state = self.npu_core.LlamaBlockSim(
            tensors[0],  # input_hidden_state
            tensors[1],  # attn_norm_gamma
            tensors[2],  # ffn_norm_gamma
            tensors[3],  # query_weight
            tensors[4],  # key_weight
            tensors[5],  # value_weight
            tensors[6],  # output_weight
            tensors[7],  # gate_weight
            tensors[8],  # up_weight
            tensors[9],  # down_weight
            seq_len, hidden_size, intermediate_size, num_attention_heads,
            rmsnorm_epsilon
        )
        
        # 保存输出
        logger.info("💾 保存输出数据...")
        TensorIO.save_raw_tensor(output_hidden_state, output_files["output_hidden_state"])
        
        logger.info(f"✅ Llama Block仿真完成: {output_hidden_state.shape} -> {output_files['output_hidden_state']}")
        
        return {"output_hidden_state": output_hidden_state}
    
    def generate_instructions(self, insn_file_name: str, vcucode_file_name: str,
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
            [其他参数...]: 各种权重地址和临时地址
            all_done: 完成标志
        
        Returns:
            生成的指令数量
        """
        return self.npu_core.LlamaBlock(
            insn_file_name, vcucode_file_name,
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

# 工厂函数
def get_operator(op_type: str) -> NPUOperator:
    """获取指定类型的算子实例"""
    operators = {
        "gemm": GemmOperator,
        "rmsnorm": RMSNormOperator, 
        "softmax": SoftmaxOperator,
        "llama_block": LlamaBlockOperator
    }
    
    if op_type.lower() not in operators:
        raise ValueError(f"不支持的算子类型: {op_type}. 支持的类型: {list(operators.keys())}")
    
    return operators[op_type.lower()]()
