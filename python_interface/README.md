# NPU算子Python接口
> 由于`libfunc.so`需要额外配置环境变量，故提供了config_lib_path.sh脚本用于配置环境变量，只需要运行即可自动获取正确路径并添加到环境变量。使用libnpu_interface.so之前请先运行该脚本。

```bash
source /path/to/npu-gen-3-verification/python_interface/config_lib_path.sh
```
> 该脚本会将`libfunc.so`所在路径添加到`LD_LIBRARY_PATH`环境变量中，确保`libnpu_interface.so`能够正确加载该依赖。

---
NPU算子的Python封装接口，提供仿真验证、指令生成和端到端测试功能。

## 🎯 核心特性

- ✅ **C++接口封装**: 直接封装 `c/csrc/interface/interface.cpp` 的C函数
- ✅ **仿真验证**: 支持NPU算子仿真与PyTorch参考对比
- ✅ **指令生成**: 生成NPU硬件指令文件和VCU代码
- ✅ **文件导向**: 兼容cpp_sim的bin文件格式
- ✅ **端到端测试**: 完整的测试框架和精度分析

## 📁 目录结构

```
python_interface/
├── npu_ops/                    # 核心模块
│   ├── __init__.py            # 便捷接口 (gemm_sim_from_files等)
│   ├── core.py                # C接口封装 (动态库加载、基础算子)
│   ├── data_io.py             # 文件I/O处理 (bin文件读写、数据验证)
│   └── operators.py           # 算子封装类 (高级接口、批量操作)
├── utils/                     # 实用工具
│   ├── txt_bin_convert.py     # 文件格式转换工具
│   ├── bin_file_compare.py    # 二进制文件对比工具  
│   └── README.md              # 工具使用说明
├── lib/                       # 动态库目录
│   └── libnpu_interface.so    # 编译生成的NPU接口库
├── test/                      # 测试文件目录
│   ├── e2e_compare/          # 端到端对比测试
│   │   ├── configs/          # 测试配置
│   │   ├── data/             # 测试数据
│   │   └── output/           # 测试结果
│   └── insn_gen/             # 指令生成测试数据
├── test_insn_gen.py          # 指令生成测试框架
├── test_e2e_compare.py       # NPU vs PyTorch对比测试
└── setup.py                  # 包安装配置
```

## 🚀 快速开始

### 1. 编译动态库
```bash
cd /path/to/npu-gen-3-verification
./script/build_npu_interface.sh
```

### 2. 基础使用

```python
from npu_ops import gemm_sim_from_files, rmsnorm_sim_from_files

# GEMM矩阵乘法仿真
output = gemm_sim_from_files(
    "ifmap.bin", "weight.bin", "output.bin",
    m=128, n=64, k=256
)

# RMSNorm层归一化仿真  
output = rmsnorm_sim_from_files(
    "input.bin", "gamma.bin", "output.bin",
    seq_len=64, d_model=256
)
```

### 3. 指令生成

```python
from npu_ops import gemm_generate_instructions

# 生成GEMM指令
insn_count = gemm_generate_instructions(
    "gemm.insn", 
    m=128, n=64, k=256,
    ifmap_addr=0x10000000,
    weight_addr=0x20000000, 
    output_addr=0x30000000
)
```

## 🧪 测试框架

### 指令生成测试
```bash
python test_insn_gen.py  # JSON配置驱动的指令生成测试
```

### 端到端精度测试  
```bash
python test_e2e_compare.py  # NPU vs PyTorch精度对比
```

## 📊 支持的算子

| 算子 | 仿真接口 | 指令生成 |
|------|----------|----------|
| **GEMM** | ✅ `gemm_sim_from_files` | ✅ `gemm_generate_instructions` |
| **RMSNorm** | ✅ `rmsnorm_sim_from_files` | ✅ `rmsnorm_generate_instructions` |
| **Softmax** | ✅ `softmax_sim_from_files` | ✅ `softmax_generate_instructions` |
| **LlamaBlock** | ✅ `llama_block_sim_from_files` | ✅ `llama_block_generate_instructions` |

## �️ 实用工具

### 文件格式转换
```bash
# 二进制转文本
python utils/txt_bin_convert.py bin2txt input.bin output.txt --data-type fp32

# 文本转二进制
python utils/txt_bin_convert.py txt2bin input.txt output.bin --data-type fp32
```

### 文件对比分析
```bash
# 对比两个bin文件
python utils/bin_file_compare.py npu_output.bin pytorch_output.bin \
    --shape 64 256 --dtype fp32 --case-name test
```

## 🔧 编译配置

### 编译动态库

```bash
# 进入脚本所在目录
cd /path/to/script

# 基础编译 (默认: 仿真配置+非调试+二进制输出)
./script/build_npu_interface.sh

# 常用编译模式
./script/build_npu_interface.sh -f off -d on -s on    # 开发调试
./script/build_npu_interface.sh -f off -d off -s on   # 仿真测试  
./script/build_npu_interface.sh -f on -d off -s off   # FPGA部署

# 清理重新编译
./script/build_npu_interface.sh --clean
```

### 编译选项说明

| 选项 | 参数 | 说明 |
|------|------|------|
| `-f, --fpga` | on/off | FPGA配置: on=FPGA SRAM深度, off=仿真SRAM深度 |
| `-d, --debug` | on/off | 调试模式: on=启用_DEBUG, off=关闭调试信息 |
| `-s, --sim` | on/off | 输出格式: on=文本(.txt), off=二进制(.bin) |
| `-c, --clean` | - | 清理后重新编译 |
| `-v, --verbose` | - | 显示详细编译信息 |
| `-h, --help` | - | 显示帮助信息 |

### 编译模式预设

```bash
# 🔬 开发调试模式 (推荐开发时使用)
./script/build_npu_interface.sh -f off -d on -s on
# → 仿真SRAM + 调试信息 + 文本输出

# 🧪 仿真测试模式 (推荐测试时使用)  
./script/build_npu_interface.sh -f off -d off -s on
# → 仿真SRAM + 发布版本 + 文本输出

# 🚀 FPGA部署模式 (推荐部署时使用)
./script/build_npu_interface.sh -f on -d off -s off
# → FPGA SRAM + 发布版本 + 二进制输出
```

编译成功后，动态库将自动复制到 `python_interface/lib/` 目录。