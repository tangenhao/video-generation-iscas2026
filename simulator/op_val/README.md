## Llama2-7B FP16模型关键算子FPGA性能验证实验方案

### 1. 引言

本文档旨在规划Llama2-7B FP16模型中关键计算算子在目标FPGA上的性能和数值正确性验证实验。实验将关注FP16矩阵乘法、FP32 RMSNorm、FP32 Softmax和FP32 Swish这几个核心算子。我们将定义性能评估指标，设计数值正确性验证流程，并规划结果的展示形式及输出目录结构。

### 2. 实验目标

*   评估核心算子在FPGA上实现的性能（吞吐量和延迟）。
*   验证FPGA上FP16算子（目前主要是GEMM）的数值计算正确性，与其他主流框架（如PyTorch）的FP16/FP32计算结果进行对比。
*   验证FPGA上FP32算子（RMSNorm, Softmax, Swish）的数值计算正确性，与PyTorch的FP32计算结果进行对比。
*   为未来Llama2-7B模型在FPGA上的整体部署提供数据支持和性能瓶颈分析依据。

### 3. 核心算子列表及代码提取说明

本次实验将关注以下核心算子：

1.  **FP16矩阵乘 (GEMM)**
    *   **来源**: `c/include/compute_model/gemm/gemm.h`
    *   **提取部分**:
        *   `compute_model::gemm::GemmSim` 结构体。
        *   关注模板参数实例化为 `TYPE_A = compute_model::common::fp16::half`, `TYPE_B = compute_model::common::fp16::half`, `TYPE_ACCUMULATOR = float` (或 `compute_model::common::fp16::half`，取决于实际硬件累加精度策略，通常先用`float`累加后转换)。`TYPE_OUTPUT` 通常也为 `compute_model::common::fp16::half`。
        *   核心计算逻辑位于 `GemmSim::operator()` 函数。
        *   相关的底层计算函数如 `mpt_fpxfp` (FP16 x FP16 -> FP32/FP16) 也需要包含。
        *   数据加载模拟 (如 `LoadIfmap`, `LoadWeight`) 和结果存储模拟 (`StoreOfmap`) 中的 `memcpy` 操作应保留，以模拟数据搬移，但指令生成部分可移除。
        *   需要设置不同的矩阵维度 (M, K, N) 进行测试。

2.  **FP32 RMSNorm**
    *   **来源**: `c/include/compute_model/transformer/rmsnorm.h`
    *   **提取部分**:
        *   `compute_model::transformer::rmsnorm::apply_rmsnorm` 函数。
        *   模板参数 `T` 应为 `float`。
        *   涉及的主要计算包括：平方、求和、除法、加法、开方倒数（rsqrt）、乘法。
        *   输入为 `input` 张量和 `gamma` 张量，输出到 `output` 张量。
        *   需要设置不同的序列长度 (seq_len) 和模型维度 (d_model) 进行测试。

3.  **FP32 Softmax**
    *   **来源**: `c/csrc/test/vcu_test/vector_reduce/softmax.cpp`
    *   **提取部分**:
        *   `main` 函数中关于Softmax计算的核心逻辑。
        *   具体步骤：
            1.  `data_exp = data_in * (std::log2(exp(1.0f)))`
            2.  `data_exp = compute_model::function::exp2(data_exp)`
            3.  `data_sum_temp = compute_model::function::reduce_sum(sub_tensor, 32, true)` (循环内)
            4.  `data_sum = data_sum + data_sum_temp` (循环内)
            5.  `sum_rec = compute_model::function::reciprocal(data_sum)`
            6.  `data_out[...] = data_exp[...] * sum_rec[...]`
        *   数据生成、文件读写及指令生成相关的代码需要移除。`split_exp_fra` 函数如果不是核心计算逻辑的一部分可以不提取。
        *   需要设置不同的序列长度 (seq_len) 和维度 (d_model / oc_group_size) 进行测试。

4.  **FP32 Swish**
    *   **来源**: `c/csrc/test/vcu_test/test_vcu_opcode/test_swish.cpp`
    *   **提取部分**:
        *   `main` 函数中关于Swish计算的核心逻辑。Swish(x) = x * sigmoid(x).
        *   具体步骤：
            1.  `data_out = data_in * (-log2(exp(1.0f)))` (计算 `-x * log2(e)`)
            2.  `data_out = compute_model::function::exp2(data_out)` (计算 `exp2(-x*log2(e))` 即 `exp(-x)`)
            3.  `data_out = data_out + 1.0f` (计算 `1 + exp(-x)`)
            4.  `data_out = compute_model::function::reciprocal(data_out)` (计算 `1 / (1 + exp(-x))` 即 `sigmoid(x)`)
            5.  `data_out = data_out * data_in` (计算 `x * sigmoid(x)`)
        *   数据生成、文件读写及指令生成相关的代码需要移除。
        *   需要针对不同的输入维度进行测试。

5.  **LLaMA Block (综合算子)**
    *   **来源**: 集成实现，结合多个核心算子
    *   **包含算子**:
        *   Multi-Head Self-Attention (包含 QKV Projection, Attention Computation, Output Projection)
        *   Feed-Forward Network (包含 Gate/Up Projection, SwiGLU 激活, Down Projection)
        *   RMSNorm (Input & Post-Attention)
        *   Residual Connections
    *   **验证内容**:
        *   整体 LLaMA Block 的前向传播计算正确性
        *   复合算子间的数据流和精度传播
        *   端到端的数值稳定性分析
        *   支持离群点分析，识别计算过程中的异常值

### 4. 性能评估指标

对于每个算子，我们将评估以下性能指标：

*   **吞吐量 (Throughput)**:
    *   定义：单位时间内处理的数据量或完成的计算操作次数。
    *   单位：
        *   GEMM: GOPS (Giga Operations Per Second) 或 TFLOPS (Tera Floating-point Operations Per Second)。计算公式：`FLOPS = 2 * M * K * N` (对于FP16乘加)。
        *   RMSNorm, Softmax, Swish: Elements/second (处理的元素数量除以时间)。
    *   测量方法：执行算子多次（例如，处理一批数据），记录总时间，然后用总操作数或总元素数除以总时间。

*   **延迟 (Latency)**:
    *   定义：处理单个输入样本或完成一次算子操作所需的时间。
    *   单位：毫秒 (ms) 或微秒 (µs)。
    *   测量方法：精确记录单次算子调用从输入数据准备好到输出结果产生的时间。

### 5. FP16/FP32 数值正确性验证方案

将FPGA模拟计算结果与PyTorch的计算结果进行对比，并支持离群点分析功能。

1.  **输入数据生成**:
    *   在C++模拟或PyTorch中生成一组相同的随机输入数据（例如，使用相同的随机种子和分布）。确保数据类型与算子要求一致（FP16或FP32）。
    *   保存这组输入数据，以便双方加载。

2.  **PyTorch参考计算**:
    *   **FP16 GEMM**: 使用 `torch.matmul()`。输入张量和权重张量需转换为 `torch.float16`。同时，为了更全面的比较，可以保留一份PyTorch FP32的计算结果。
    *   **FP32 RMSNorm, Softmax, Swish**: 使用PyTorch内置函数或通过基本张量运算组合实现这些FP32算子。
    *   **LLaMA Block**: 使用Transformers库或自定义实现完整的LLaMA块计算，包括attention、feed-forward、normalization等。

3.  **FPGA模拟计算**:
    *   使用提取的C++核心计算代码，加载相同的输入数据，执行算子模拟。

4.  **结果比较与误差分析**:
    *   比较FPGA模拟输出和PyTorch参考输出。
    *   **主要指标**:
        *   **最大绝对误差**: `max(abs(output_fpga - output_pytorch))`
        *   **平均绝对误差**: `mean(abs(output_fpga - output_pytorch))`
        *   **最大相对误差**: `max(abs(output_fpga - output_pytorch) / abs(output_pytorch))` (需注意 `output_pytorch` 为零的情况)
        *   **平均相对误差**: `mean(abs(output_fpga - output_pytorch) / abs(output_pytorch))`
        *   **余弦相似度**: 对于向量或矩阵输出，计算两者之间的余弦相似度。
    *   **离群点分析**:
        *   自动识别超过设定阈值的离群点（绝对误差阈值和相对误差阈值）
        *   生成离群点详细报告，包括位置索引、参考值、实际值、误差大小
        *   提供离群点分布可视化图表（误差分布直方图、散点图等）
        *   支持按误差类型分类（绝对误差、相对误差、混合误差）
        *   保存离群点分析结果为JSON格式，便于后续分析
    *   **通过/失败标准**: 根据算子特性和FP16/FP32的精度预期，设定可接受的误差阈值。例如，FP16结果与FP32基准比较时，相对误差在`1e-3`到`1e-2`范围内可能被认为是可接受的。

### 6. 结果展示结构

结果将通过表格和图表形式呈现。

*   **性能结果表格**:

    | 算子         | 输入配置 (例如 M,K,N 或 Seq,Dim) | FPGA吞吐量 (GOPS/TFLOPS/Ele/s) | FPGA延迟 (ms/µs) | PyTorch CPU/GPU 吞吐量 | PyTorch CPU/GPU 延迟 | FPGA加速比 (vs CPU/GPU) |
    | :----------- | :------------------------------ | :--------------------------- | :--------------- | :----------------------- | :------------------- | :---------------------- |
    | FP16 GEMM    | M=..., K=..., N=...             |                              |                  |                          |                      |                         |
    | FP32 RMSNorm | Seq=..., Dim=...                |                              |                  |                          |                      |                         |
    | FP32 Softmax | Seq=..., Dim=...                |                              |                  |                          |                      |                         |
    | FP32 Swish   | Elements=...                    |                              |                  |                          |                      |                         |
    | LLaMA Block  | Batch=..., Seq=..., Dim=...     |                              |                  |                          |                      |                         |

*   **数值正确性结果表格** (以FP16 GEMM为例，其他算子类似调整对比基准):

    | 算子       | 输入配置        | 对比基准       | 最大绝对误差 | 平均绝对误差 | 最大相对误差 | 平均相对误差 | 余弦相似度 | 离群点数量/比例 | 通过/失败 |
    | :--------- | :-------------- | :------------- | :----------- | :----------- | :----------- | :----------- | :--------- | :-------------- | :-------- |
    | FP16 GEMM  | M=..., K=..., N=... | PyTorch FP16   |              |              |              |              |            |                 |           |
    | FP16 GEMM  | M=..., K=..., N=... | PyTorch FP32   |              |              |              |              |            |                 |           |
    | FP32 RMSNorm| Seq=..., Dim=... | PyTorch FP32   |              |              |              |              |            |                 |           |
    | FP32 Softmax| Seq=..., Dim=... | PyTorch FP32   |              |              |              |              |            |                 |           |
    | FP32 Swish  | Elements=...    | PyTorch FP32   |              |              |              |              |            |                 |           |
    | LLaMA Block | Batch=..., Seq=..., Dim=... | PyTorch FP32 |              |              |              |              |            |                 |           |

*   **图表**:
    *   **吞吐量对比图**: 柱状图，X轴为算子/配置，Y轴为吞吐量，对比FPGA与PyTorch (CPU/GPU)。
    *   **延迟对比图**: 柱状图，X轴为算子/配置，Y轴为延迟，对比FPGA与PyTorch。
    *   **误差分布图**: 直方图或箱线图，展示不同算子/配置下的误差分布情况。
    *   **离群点分析图**:
        *   离群点绝对误差分布直方图
        *   离群点相对误差分布直方图  
        *   离群点值散点图（参考值 vs 实际值）
        *   离群点误差类型分布饼图
    *   **(可选) 性能随输入规模变化曲线**: X轴为输入数据的关键维度（如矩阵大小、序列长度），Y轴为吞吐量或延迟。

### 7. 输出目录结构规划

实验相关代码、数据和结果将存放于 `simulator/op_val/` 目录下，具体结构如下：

```
simulator/
└── op_val/
    ├── README.md                     # 本实验方案文档
    ├── Makefile                      # 统一构建和测试脚本，支持离群点分析参数
    ├── run_op_validation.py          # 统一的算子验证脚本，支持多种算子类型和离群点分析
    ├── run_all_validations.sh        # 批量运行所有验证测试的脚本
    ├── common_utils/                 # 通用工具脚本
    │   ├── data_gen.py               # 数据生成和加载工具
    │   └── plot_utils.py             # 绘图和离群点分析工具
    ├── gemm_fp16/
    │   ├── cpp_sim/                  # 提取的C++ GEMM模拟代码和Makefile/build脚本
    │   │   └── gemm_sim_fp16.cpp
    │   ├── pytorch_ref/              # PyTorch FP16/FP32 GEMM参考实现
    │   │   └── gemm_pytorch.py
    │   ├── compare_gemm_outputs.py   # GEMM算子结果比较脚本，支持离群点分析
    │   ├── data/                     # 测试用的输入/输出数据样本
    │   │   ├── input_M...K...N....dat
    │   │   └── ref_output_M...K...N....dat
    │   └── results/                  # 测试结果和分析报告
    │       ├── test_name_*/          # 按测试名称分组的结果目录
    │       │   ├── performance.json
    │       │   ├── accuracy.json
    │       │   ├── outlier_analysis.json  # 离群点分析详细结果
    │       │   ├── charts/           # 可视化图表
    │       │   │   ├── throughput_comparison.png
    │       │   │   ├── error_distribution.png
    │       │   │   ├── outlier_*.png # 离群点分析图表
    │       │   │   └── scatter_comparison.png
    │       │   └── logs/             # 详细日志
    │       │       └── test_name.log
    ├── rmsnorm_fp32/
    │   ├── cpp_sim/
    │   │   └── rmsnorm_sim_fp32.cpp
    │   ├── pytorch_ref/
    │   │   └── rmsnorm_pytorch.py
    │   ├── compare_rmsnorm_outputs.py # RMSNorm算子结果比较脚本，支持离群点分析
    │   ├── data/
    │   └── results/
    │       └── (结构同上)
    ├── softmax_fp32/
    │   ├── cpp_sim/
    │   │   └── softmax_sim_fp32.cpp
    │   ├── pytorch_ref/
    │   │   └── softmax_pytorch.py
    │   ├── compare_softmax_outputs.py # Softmax算子结果比较脚本，支持离群点分析
    │   ├── data/
    │   └── results/
    │       └── (结构同上)
    ├── swish_fp32/
    │   ├── cpp_sim/
    │   │   └── swish_sim_fp32.cpp
    │   ├── pytorch_ref/
    │   │   └── swish_pytorch.py
    │   ├── compare_swish_outputs.py  # Swish算子结果比较脚本，支持离群点分析
    │   ├── data/
    │   └── results/
    │       └── (结构同上)
    └── llama_block/
        ├── cpp_sim/                  # LLaMA Block C++模拟实现
        │   └── llama_block_sim.cpp
        ├── pytorch_ref/              # PyTorch LLaMA Block参考实现
        │   └── llama_block_pytorch.py
        ├── compare_llama_block_outputs.py # LLaMA Block结果比较脚本，支持离群点分析
        ├── capture_outlier.py        # 独立的离群点分析工具
        ├── data/                     # LLaMA Block测试数据
        └── results/
            └── (结构同上，包含离群点分析结果)
```

### 8. 实验步骤概要

1.  **环境准备**: 设置C++编译环境和Python (PyTorch) 环境。
2.  **代码提取与封装**:
    *   根据第3节的说明，从现有代码中提取各个算子的核心计算模拟部分，并封装成可独立运行的C++函数或类。
    *   编写PyTorch参考实现脚本。
    *   实现LLaMA Block完整的前向传播验证。
3.  **数据生成与准备**: 编写脚本生成或转换符合各算子输入要求的测试数据。
4.  **性能测试**:
    *   在FPGA模拟环境中运行C++算子模拟代码，记录执行时间，计算吞吐量和延迟。
    *   在CPU/GPU上运行PyTorch参考代码，记录执行时间，计算吞吐量和延迟。
5.  **正确性验证**:
    *   使用相同的输入数据，分别运行FPGA模拟代码和PyTorch参考代码。
    *   收集双方的输出结果，并进行第5节中描述的误差分析。
    *   执行离群点分析，识别和可视化异常误差点。
6.  **离群点深度分析**:
    *   使用自动化工具识别超过阈值的离群点
    *   生成离群点详细报告和可视化图表
    *   分析离群点产生的原因和模式
7.  **结果汇总与报告**:
    *   将性能数据和正确性数据填入第6节设计的表格中。
    *   生成相应的对比图表和离群点分析图表。
    *   撰写实验报告，总结实验结果，分析性能瓶颈和误差来源，重点关注离群点分析结果。

### 9. 离群点分析功能使用说明

系统集成了完整的离群点分析功能，可通过以下方式使用：

**命令行参数**:
*   `--enable_outlier_analysis`: 启用离群点分析
*   `--outlier_abs_threshold <value>`: 设置绝对误差阈值（默认：1e-3）
*   `--outlier_rel_threshold <value>`: 设置相对误差阈值（默认：0.01）

**使用示例**:
```bash
# 运行GEMM验证并启用离群点分析
make gemm_outlier_test

# 或直接使用run_op_validation.py
python3 run_op_validation.py --op_type gemm --M 64 --K 128 --N 32 \
    --enable_outlier_analysis --outlier_abs_threshold 1e-4 --outlier_rel_threshold 0.005

# 运行LLaMA Block验证并启用离群点分析
python3 run_op_validation.py --op_type llama_block --batch_size 4 --seq_len 64 --hidden_size 32 \
    --enable_outlier_analysis
```

**输出文件**:
*   `outlier_analysis.json`: 离群点详细信息（按相对误差优先、绝对误差次之排序）
*   `outlier_*.png`: 离群点分布可视化图表
*   在主验证日志中包含离群点统计摘要 