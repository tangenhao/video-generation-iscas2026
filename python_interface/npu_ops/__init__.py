"""
NPU算子Python接口 - 便捷接口模块
按照流程步骤1.2.2的要求，提供类似cpp_sim的简洁调用方式
"""

import numpy as np
from pathlib import Path
from typing import Union, Dict, Optional, Tuple, Any
import logging

from .core import get_npu_core, DType
from .operators import get_operator
from .data_io import TensorIO, DataValidator

logger = logging.getLogger(__name__)

# ========================== 便捷仿真接口 ==========================

def gemm_sim_from_files(ifmap_file: Union[str, Path], 
                       weight_file: Union[str, Path],
                       output_file: Union[str, Path],
                       m: int, n: int, k: int,
                       tile_m: int = 64, 
                       block_n_group: int = 4, 
                       block_k_group: int = 16) -> np.ndarray:
    """
    一行代码运行GEMM仿真
    
    Args:
        ifmap_file: 输入特征图文件 [k_group, m, k_group_size]
        weight_file: 权重文件 [n_group, k_group, n_group_size, k_group_size]
        output_file: 输出文件 [n_group, m, n_group_size]
        m, n, k: 矩阵维度
        tile_m, block_n_group, block_k_group: 分块参数
    
    Returns:
        输出张量
    
    Example:
        >>> output = gemm_sim_from_files("input.bin", "weight.bin", "output.bin", 
        ...                             m=128, n=4096, k=4096)
    """
    logger.info(f"🚀 GEMM仿真: {ifmap_file} × {weight_file} -> {output_file}")
    
    gemm_op = get_operator("gemm")
    
    input_files = {
        "ifmap": str(ifmap_file),
        "weight": str(weight_file)
    }
    
    output_files = {
        "output": str(output_file)
    }
    
    params = {
        "m": m, "n": n, "k": k,
        "tile_m": tile_m,
        "block_n_group": block_n_group,
        "block_k_group": block_k_group
    }
    
    results = gemm_op.simulate_from_files(input_files, output_files, params)
    return results["output"]

def rmsnorm_sim_from_files(input_file: Union[str, Path],
                          gamma_file: Union[str, Path], 
                          output_file: Union[str, Path],
                          seq_len: int, d_model: int,
                          epsilon: float = 1e-6) -> np.ndarray:
    """
    一行代码运行RMSNorm仿真
    
    Args:
        input_file: 输入文件 [oc_group, seq_len, oc_group_size]
        gamma_file: Gamma参数文件 [oc_group, oc_group_size]
        output_file: 输出文件 [oc_group, seq_len, oc_group_size]
        seq_len: 序列长度
        d_model: 模型维度
        epsilon: 数值稳定性参数
    
    Returns:
        归一化后的输出张量
    """
    logger.info(f"🚀 RMSNorm仿真: {input_file} -> {output_file}")
    
    rmsnorm_op = get_operator("rmsnorm")
    
    input_files = {
        "input": str(input_file),
        "gamma": str(gamma_file)
    }
    
    output_files = {
        "output": str(output_file)
    }
    
    params = {
        "seq_len": seq_len,
        "d_model": d_model,
        "epsilon": epsilon,
        "dtype": DType.kFloat32
    }
    
    results = rmsnorm_op.simulate_from_files(input_files, output_files, params)
    return results["output"]

def softmax_sim_from_files(input_file: Union[str, Path],
                          output_file: Union[str, Path],
                          seq_len: int, d_model: int,
                          dtype: DType = DType.kFloat32) -> np.ndarray:
    """
    一行代码运行Softmax仿真
    
    Args:
        input_file: 输入文件 [oc_group, seq_len, oc_group_size]
        output_file: 输出文件 [oc_group, seq_len, oc_group_size]
        seq_len: 序列长度
        d_model: 模型维度
        dtype: 数据类型
    
    Returns:
        Softmax输出张量
    
    Example:
        >>> output = softmax_sim_from_files("input.bin", "output.bin", 
        ...                                seq_len=64, d_model=4096)
    """
    logger.info(f"🚀 Softmax仿真: {input_file} -> {output_file}")
    
    softmax_op = get_operator("softmax")
    
    input_files = {
        "input": str(input_file)
    }
    
    output_files = {
        "output": str(output_file)
    }
    
    params = {
        "seq_len": seq_len,
        "d_model": d_model,
        "dtype": dtype
    }
    
    results = softmax_op.simulate_from_files(input_files, output_files, params)
    return results["output"]

def llama_block_sim_from_files(input_file: Union[str, Path],
                              weight_dir: Union[str, Path],
                              output_file: Union[str, Path],
                              seq_len: int = 64,
                              hidden_size: int = 4096,
                              intermediate_size: int = 11008,
                              num_attention_heads: int = 32,
                              rmsnorm_epsilon: float = 1e-6,
                              weight_file_mapping: Optional[Dict[str, str]] = None) -> np.ndarray:
    """
    一行代码运行Llama Block仿真 - 支持分离的输入文件和权重目录
    
    Args:
        input_file: 输入隐藏状态文件 [n_group, seq_len, n_group_size]
        weight_dir: 权重文件目录，包含所有权重文件
        output_file: 输出文件, [n_group, seq_len, n_group_size] 或标准格式
        seq_len: 序列长度
        hidden_size: 模型维度
        intermediate_size: 中间层维度
        num_attention_heads: 注意力头数
        rmsnorm_epsilon: 1e-6
        weight_file_mapping: 自定义权重文件映射字典，如果为None则使用默认映射
    
    Returns:
        Block输出隐藏状态
    
    Example:
        # 基础使用 - 分离输入和权重
        >>> output = llama_block_sim_from_files(
        ...     "input_hidden_state.bin", "weights/", "result.bin",
        ...     seq_len=64, hidden_size=4096
        ... )
        
        # 自定义映射模式（适配NPU格式）
        >>> custom_mapping = {
        ...     "attn_norm_gamma": "layer_00_input_layernorm_weight.bin",
        ...     "query_weight": "layer_00_self_attn_q_proj_weight_d4096_i4096_h32.bin",
        ...     "key_weight": "layer_00_self_attn_k_proj_weight_d4096_i4096_h32.bin",
        ...     # ... 其他映射
        ... }
        >>> output = llama_block_sim_from_files(
        ...     "input_data.bin", "../para/bin", "result.bin", 
        ...     weight_file_mapping=custom_mapping
        ... )
    """
    logger.info(f"🚀 Llama Block仿真: {input_file} + {weight_dir} -> {output_file}")
    
    input_file = Path(input_file)
    weight_dir = Path(weight_dir)
    
    # 验证输入文件存在
    if not input_file.exists():
        raise FileNotFoundError(f"输入文件不存在: {input_file}")
    
    # 验证权重目录存在
    if not weight_dir.exists():
        raise FileNotFoundError(f"权重目录不存在: {weight_dir}")

    # 使用自定义映射或默认映射
    if weight_file_mapping is not None:
        weight_files = weight_file_mapping
        logger.info("📋 使用自定义权重文件映射")
    else:
        # 默认映射（保持向后兼容）
        weight_files = {
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
        logger.info("📋 使用默认权重文件映射")
    
    # 构建输入文件字典
    input_files = {
        "input_hidden_state": str(input_file)
    }
    
    # 添加权重文件
    missing_files = []
    
    for key, filename in weight_files.items():
        file_path = weight_dir / filename
        if file_path.exists():
            input_files[key] = str(file_path) # 并入input_files
            logger.debug(f"  ✅ {key}: {filename}")
        else:
            missing_files.append((key, filename))
            logger.warning(f"  ❌ {key}: {filename} (文件不存在)")
    
    if missing_files:
        logger.error(f"发现 {len(missing_files)} 个缺失的权重文件:")
        for key, filename in missing_files:
            logger.error(f"  - {key}: {filename}")
        raise FileNotFoundError(f"发现 {len(missing_files)} 个缺失的权重文件")
    
    output_files = {
        "output_hidden_state": str(output_file)
    }
    
    params = {
        "seq_len": seq_len,
        "hidden_size": hidden_size,
        "intermediate_size": intermediate_size,
        "num_attention_heads": num_attention_heads,
        "rmsnorm_epsilon": rmsnorm_epsilon,
    }
    
    llama_block_op = get_operator("llama_block")
    results = llama_block_op.simulate_from_files(input_files, output_files, params)
    return results["output_hidden_state"]

# ========================== 便捷指令生成接口 ==========================

def gemm_generate_instructions(insn_file: Union[str, Path],
                              m: int, n: int, k: int,
                              ifmap_addr: int, weight_addr: int, output_addr: int,
                              tile_m: int = 64, 
                              block_n_group: int = 4, 
                              block_k_group: int = 16,
                              all_done: int = 1) -> int:
    """
    生成GEMM指令
    
    Args:
        insn_file: 指令文件名
        m, n, k: 矩阵维度
        ifmap_addr, weight_addr, output_addr: DDR地址
        tile_m, block_n_group, block_k_group: 分块参数
        all_done: 完成标志
    
    Returns:
        生成的指令数量
    """
    logger.info(f"🔧 生成GEMM指令: {insn_file}")
    
    gemm_op = get_operator("gemm")
    
    params = {
        "m": m, "n": n, "k": k,
        "tile_m": tile_m,
        "block_n_group": block_n_group,
        "block_k_group": block_k_group,
        "all_done": all_done
    }
    
    addresses = {
        "ifmap_addr": ifmap_addr,
        "weight_addr": weight_addr,
        "output_addr": output_addr
    }
    
    output_files = {
        "insn": str(insn_file)
    }
    
    return gemm_op.generate_instructions(params, addresses, output_files)

def rmsnorm_generate_instructions(insn_file: Union[str, Path],
                                 vcucode_file: Union[str, Path],
                                 seq_len: int, d_model: int,
                                 input_addr: int, gamma_addr: int, output_addr: int,
                                 **kwargs) -> int:
    """
    生成RMSNorm指令
    
    Args:
        insn_file: 指令文件名
        vcucode_file: VCU代码文件名
        seq_len: 序列长度
        d_model: 模型维度
        input_addr, gamma_addr, output_addr: DDR地址
        **kwargs: 其他参数
    
    Returns:
        生成的指令数量
    """
    logger.info(f"🔧 生成RMSNorm指令: {insn_file}")
    
    rmsnorm_op = get_operator("rmsnorm")
    
    params = {
        "seq_len": seq_len,
        "d_model": d_model,
        "tile_m": kwargs.get("tile_m", 32),
        "block_oc_group": kwargs.get("block_oc_group", 4),
        "epsilon": kwargs.get("epsilon", 1e-6),
        "dtype": kwargs.get("dtype", DType.kFloat32),
        "all_done": kwargs.get("all_done", 1)
    }
    
    addresses = {
        "input_addr": input_addr,
        "gamma_addr": gamma_addr,
        "output_addr": output_addr,
        "vcucode_addr": kwargs.get("vcucode_addr", 0),
        "rec_lut_addr": kwargs.get("rec_lut_addr", 0),
        "log_lut_addr": kwargs.get("log_lut_addr", 0),
        "exp_lut_addr": kwargs.get("exp_lut_addr", 0),
        "rsqrt_lut_addr": kwargs.get("rsqrt_lut_addr", 0)
    }
    
    output_files = {
        "insn": str(insn_file),
        "vcucode": str(vcucode_file)
    }
    
    return rmsnorm_op.generate_instructions(params, addresses, output_files)

def softmax_generate_instructions(insn_file: Union[str, Path],
                                 vcucode_file: Union[str, Path],
                                 seq_len: int, d_model: int,
                                 input_addr: int, output_addr: int,
                                 vcu_code_addr: int,
                                 exp_lut_addr: int, rec_lut_addr: int,
                                 tile_m: int = None, block_oc_group: int = None,
                                 all_done: int = 1) -> int:
    """
    生成Softmax指令
    
    Args:
        insn_file: 指令文件名
        vcucode_file: VCU代码文件名
        seq_len: 序列长度
        d_model: 模型维度
        input_addr, output_addr: DDR地址
        vcu_code_addr: VCU代码地址
        exp_lut_addr, rec_lut_addr: LUT地址
        tile_m, block_oc_group: 分块参数（可选）
        all_done: 完成标志
    
    Returns:
        生成的指令数量
    """
    logger.info(f"🔧 生成Softmax指令: {insn_file}")
    
    softmax_op = get_operator("softmax")
    
    return softmax_op.generate_instructions(
        str(insn_file), str(vcucode_file),
        seq_len, d_model,
        input_addr, output_addr, vcu_code_addr,
        exp_lut_addr, rec_lut_addr,
        all_done, tile_m, block_oc_group
    )

def llama_block_generate_instructions(insn_file: Union[str, Path],
                                     vcucode_file: Union[str, Path],
                                     seq_len: int, hidden_size: int, intermediate_size: int,
                                     num_attention_heads: int, rmsnorm_epsilon: float,
                                     hidden_dtype: int, weight_dtype: int,
                                     addresses: Dict[str, int],
                                     all_done: int = 1) -> int:
    """
    生成LlamaBlock指令
    
    Args:
        insn_file: 指令文件名
        vcucode_file: VCU代码文件名
        seq_len: 序列长度
        hidden_size: 隐藏层维度
        intermediate_size: 中间层维度
        num_attention_heads: 注意力头数
        rmsnorm_epsilon: RMSNorm epsilon参数
        hidden_dtype, weight_dtype: 数据类型
        addresses: 包含所有地址的字典
        all_done: 完成标志
    
    Returns:
        生成的指令数量
    """
    logger.info(f"🔧 生成LlamaBlock指令: {insn_file}")
    
    llama_block_op = get_operator("llama_block")
    
    return llama_block_op.generate_instructions(
        str(insn_file), str(vcucode_file),
        seq_len, hidden_size, intermediate_size, num_attention_heads,
        rmsnorm_epsilon, hidden_dtype, weight_dtype,
        addresses["input_hidden_state_addr"],
        addresses["final_output_hidden_state_addr"],
        addresses["freq_cls_base_addr"],
        addresses["mask_base_addr"],
        addresses["attn_norm_gamma_addr"],
        addresses["attn_query_weight_addr"],
        addresses["attn_key_weight_addr"],
        addresses["attn_value_weight_addr"],
        addresses["attn_output_weight_addr"],
        addresses["ffn_norm_gamma_addr"],
        addresses["mlp_gate_weight_addr"],
        addresses["mlp_up_weight_addr"],
        addresses["mlp_down_weight_addr"],
        addresses["attn_norm_output_addr"],
        addresses["attn_query_temp_addr"],
        addresses["attn_key_temp_addr"],
        addresses["attn_value_temp_addr"],
        addresses["attn_score_temp_addr"],
        addresses["attn_probe_temp_addr"],
        addresses["attn_output_temp_addr"],
        addresses["attn_output_proj_addr"],
        addresses["residual_after_attn_addr"],
        addresses["ffn_norm_output_addr"],
        addresses["mlp_gate_output_addr"],
        addresses["mlp_up_output_addr"],
        addresses["mlp_mul_output_addr"],
        addresses["mlp_final_proj_output_addr"],
        addresses["vcu_code_llama_block_addr"],
        addresses["rec_lut_addr"],
        addresses["log_lut_addr"],
        addresses["exp_lut_addr"],
        addresses["rsqrt_lut_addr"],
        addresses["swish_lut_addr"],
        all_done
    )

# ========================== 便捷数据生成接口 ==========================

def generate_random_tensor(shape: Tuple[int, ...], 
                          dtype: str = "float32",
                          seed: int = 42,
                          save_to: Optional[Union[str, Path]] = None) -> np.ndarray:
    """
    生成随机测试数据
    
    Args:
        shape: 张量形状
        dtype: 数据类型 ("float32", "float16")
        seed: 随机种子
        save_to: 保存文件路径（可选）
    
    Returns:
        生成的随机张量
    """
    np.random.seed(seed)
    
    if dtype == "float32":
        tensor = np.random.randn(*shape).astype(np.float32)
    elif dtype == "float16":
        tensor = np.random.randn(*shape).astype(np.float16)
    else:
        raise ValueError(f"不支持的数据类型: {dtype}")
    
    if save_to is not None:
        TensorIO.save_raw_tensor(tensor, save_to)
        logger.info(f"✅ 随机张量已保存: {shape} {dtype} -> {save_to}")
    
    return tensor

def generate_gemm_test_data(m: int, n: int, k: int, 
                           output_dir: Union[str, Path],
                           seed: int = 42) -> Dict[str, str]:
    """
    生成GEMM测试数据
    
    Args:
        m, n, k: 矩阵维度
        output_dir: 输出目录
        seed: 随机种子
    
    Returns:
        生成的文件路径字典
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # 计算分组维度
    n_group_size = 32
    k_group_size = 16
    n_group = n // n_group_size
    k_group = k // k_group_size
    
    # 生成测试数据
    ifmap_shape = (k_group, m, k_group_size)
    weight_shape = (n_group, k_group, n_group_size, k_group_size)
    
    files = {}
    
    # 生成ifmap
    ifmap_file = output_dir / "ifmap.bin"
    ifmap = generate_random_tensor(ifmap_shape, "float16", seed, ifmap_file)
    files["ifmap"] = str(ifmap_file)
    
    # 生成weight
    weight_file = output_dir / "weight.bin"
    weight = generate_random_tensor(weight_shape, "float16", seed + 1, weight_file)
    files["weight"] = str(weight_file)
    
    # 预留output文件路径
    files["output"] = str(output_dir / "output.bin")
    
    logger.info(f"✅ GEMM测试数据生成完成: {output_dir}")
    logger.info(f"  ifmap: {ifmap_shape} -> {files['ifmap']}")
    logger.info(f"  weight: {weight_shape} -> {files['weight']}")
    
    return files

# ========================== 便捷验证接口 ==========================

def compare_with_reference(test_output_file: Union[str, Path],
                          reference_file: Union[str, Path],
                          shape: Tuple[int, ...],
                          dtype: str = "float32",
                          rtol: float = 1e-5,
                          atol: float = 1e-8) -> bool:
    """
    将测试输出与参考结果进行比较
    
    Args:
        test_output_file: 测试输出文件
        reference_file: 参考结果文件
        shape: 张量形状
        dtype: 数据类型
        rtol: 相对误差容忍度
        atol: 绝对误差容忍度
    
    Returns:
        是否通过验证
    """
    logger.info(f"🔍 比较结果: {test_output_file} vs {reference_file}")
    
    # 转换数据类型
    np_dtype = np.float32 if dtype == "float32" else np.float16
    
    # 加载张量
    test_tensor = TensorIO.load_raw_tensor(test_output_file, shape, np_dtype)
    ref_tensor = TensorIO.load_raw_tensor(reference_file, shape, np_dtype)
    
    # 执行比较
    result = DataValidator.compare_tensors(
        test_tensor, ref_tensor, rtol, atol,
        name1="test_output", name2="reference"
    )
    
    return result["is_close"]

