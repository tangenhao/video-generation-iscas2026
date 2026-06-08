# 工具集说明文档

本目录包含用于NPU项目的实用工具。

## txt_bin_convert.py - 文件格式转换工具

### 功能

支持二进制文件与文本文件之间的相互转换，兼容C++版本的 `saveCharArrayToFormattedTextFile` 逻辑。

### 使用示例

#### Python API

```python
from utils.txt_bin_convert import *

# 二进制文件转格式化文本
convert_bin_to_formatted_txt("input.bin", "output.txt", "fp32", 32, True, False)

# 格式化文本转二进制文件
convert_formatted_txt_to_bin("input.txt", "output.bin", "fp32", 32, True, False)
```

#### 命令行

```bash
# 二进制文件转格式化文本
python utils/txt_bin_convert.py bin2txt input.bin output.txt --data-type fp32 --bytes-per-line 32

# 格式化文本转二进制文件  
python utils/txt_bin_convert.py txt2bin input.txt output.bin --data-type fp16 --bytes-per-line 32

# 批量转换
python utils/txt_bin_convert.py batch_bin2txt ./data/ ./output/ --pattern "*.bin" --data-type fp32
python utils/txt_bin_convert.py batch_txt2bin ./data/ ./output/ --pattern "*.txt" --data-type fp32

# 显示文件信息
python utils/txt_bin_convert.py info data.bin
```

### 支持的数据类型

- `fp16`, `fp32`: 浮点数
- `int8`, `int16`, `int32`: 整数

## bin_file_compare.py - 二进制文件对比工具

### 功能

对比两个bin文件的tensor数据，生成精度分析报告和可视化图表。

### 使用示例

#### Python API

```python
from utils.bin_file_compare import compare_bin_files_api

# 对比两个文件
result = compare_bin_files_api(
    file_a="npu_output.bin",
    file_b="pytorch_output.bin", 
    shape=(64, 256),
    dtype="fp32",
    case_name="gemm_test"
)
```

#### 命令行

```bash
# 对比两个文件
python utils/bin_file_compare.py pytorch_output.bin npu_output.bin\
    --shape 64 256 --dtype fp32 --case-name gemm_test

# 指定容差
python utils/bin_file_compare.py file1.bin file2.bin \
    --shape 100 --dtype fp32 --rtol 1e-3 --atol 1e-5
```

### 输出

- 数值精度指标报告
- 散点图对比 (`scatter_plot.png`)
- 误差分布直方图 (`error_histogram.png`)
- 精度报告 (`accuracy.json`)
