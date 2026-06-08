# 算子验证测试报告

## 引言

本报告总结了Llama2-7B FP16/FP32模型关键算子的性能和精度验证结果。测试将C++仿真输出（DUT - 被测设备）与PyTorch参考实现进行了比较。目前所有PyTorch的性能指标均基于CPU。FPGA性能数据尚未集成。

---

## GEMM (FP16)

### 测试运行: `gemm_fp16_mk_test1`

**PyTorch (CPU) 性能:**

| 指标            | 值                                      |
|-----------------|-----------------------------------------|
| 精度            | fp16                                    |
| 维度            | M=64, K=128, N=32                       |
| 延迟 (ms)       | 13.78                                   |
| 吞吐量 (GOPS)   | 0.038                                   |

**精度 (C++ DUT vs. PyTorch FP16 参考):**

| 指标                | 值                     |
|-----------------------|------------------------|
| 最大绝对误差          | 0.00390625             |
| 平均绝对误差          | 3.8743e-06             |
| 最大相对误差          | 0.00095224             |
| 平均相对误差          | 2.7418e-06             |
| 余弦相似度            | 0.99951                |
| MSE (均方误差)        | 0.0                    |

**图表:**

*   [绝对误差直方图](./gemm_fp16/results/gemm_fp16_mk_test1/charts/gemm_fp16_abs_error_hist.png)
*   [相对误差直方图](./gemm_fp16/results/gemm_fp16_mk_test1/charts/gemm_fp16_rel_error_hist.png)
*   [散点比较图](./gemm_fp16/results/gemm_fp16_mk_test1/charts/gemm_fp16_scatter_comparison.png)

**分析:**
对于此配置，C++ DUT与PyTorch FP16参考实现表现出良好的一致性。误差极小。

---

### 测试运行: `gemm_fp16_mk_test2`

**PyTorch (CPU) 性能:**

| 指标            | 值                                      |
|-----------------|-----------------------------------------|
| 精度            | fp16                                    |
| 维度            | M=128, K=256, N=64                      |
| 延迟 (ms)       | 15.11                                   |
| 吞吐量 (GOPS)   | 0.278                                   |

**精度 (C++ DUT vs. PyTorch FP16 参考):**

| 指标                | 值                     |
|-----------------------|------------------------|
| 最大绝对误差          | 0.00390625             |
| 平均绝对误差          | 2.2650e-06             |
| 最大相对误差          | 0.00605774             |
| 平均相对误差          | 3.9935e-06             |
| 余弦相似度            | NaN                    |
| MSE (均方误差)        | 0.0                    |

**余弦相似度说明:** 余弦相似度为NaN值可能表示在此特定测试用例中，参考张量和DUT张量均为零或非常接近零。

**图表:**

*   [绝对误差直方图](./gemm_fp16/results/gemm_fp16_mk_test2/charts/gemm_fp16_abs_error_hist.png)
*   [相对误差直方图](./gemm_fp16/results/gemm_fp16_mk_test2/charts/gemm_fp16_rel_error_hist.png)
*   [散点比较图](./gemm_fp16/results/gemm_fp16_mk_test2/charts/gemm_fp16_scatter_comparison.png)

**分析:**
对于此较大配置，C++ DUT与PyTorch FP16参考实现总体表现出良好的一致性，但余弦相似度为NaN，如果期望得到非零张量，则需要进一步调查。

---

## RMSNorm (FP32)

### 测试运行: `rmsnorm_fp32_mk_test1`

**PyTorch (CPU) 性能:**

| 指标                   | 值                                           |
|--------------------------|----------------------------------------------|
| 精度                     | fp32                                         |
| 维度                     | oc_group=8, seq_len=128, ogs=32, d_model=256 |
| 延迟 (ms)                | 5.75                                         |
| 吞吐量 (Elements/sec)    | 5,696,214                                    |

**精度 (C++ DUT vs. PyTorch FP32 参考):**

| 指标                | 值                     |
|-----------------------|------------------------|
| 最大绝对误差          | 3.5763e-07             |
| 平均绝对误差          | 2.1496e-08             |
| 最大相对误差          | 3.1555e-07             |
| 平均相对误差          | 5.0915e-08             |
| 余弦相似度            | 1.0                    |
| MSE (均方误差)        | 1.8521e-15             |

**图表:**

*   [绝对误差直方图](./rmsnorm_fp32/results/rmsnorm_fp32_mk_test1/charts/rmsnorm_fp32_abs_error_hist.png)
*   [相对误差直方图](./rmsnorm_fp32/results/rmsnorm_fp32_mk_test1/charts/rmsnorm_fp32_rel_error_hist.png)
*   [散点比较图](./rmsnorm_fp32/results/rmsnorm_fp32_mk_test1/charts/rmsnorm_fp32_scatter_comparison.png)

**分析:**
C++ DUT与PyTorch FP32参考实现之间的一致性极好。误差处于机器精度水平。

---

### 测试运行: `rmsnorm_fp32_mk_test2`

**PyTorch (CPU) 性能:**

| 指标                   | 值                                           |
|--------------------------|----------------------------------------------|
| 精度                     | fp32                                         |
| 维度                     | oc_group=8, seq_len=512, ogs=32, d_model=256 |
| 延迟 (ms)                | 17.22                                        |
| 吞吐量 (Elements/sec)    | 7,611,513                                    |

**精度 (C++ DUT vs. PyTorch FP32 参考):**

| 指标                | 值                     |
|-----------------------|------------------------|
| 最大绝对误差          | 3.5763e-07             |
| 平均绝对误差          | 2.2404e-08             |
| 最大相对误差          | 3.3213e-07             |
| 平均相对误差          | 5.2912e-08             |
| 余弦相似度            | 1.0                    |
| MSE (均方误差)        | 2.0054e-15             |

**图表:**

*   [绝对误差直方图](./rmsnorm_fp32/results/rmsnorm_fp32_mk_test2/charts/rmsnorm_fp32_abs_error_hist.png)
*   [相对误差直方图](./rmsnorm_fp32/results/rmsnorm_fp32_mk_test2/charts/rmsnorm_fp32_rel_error_hist.png)
*   [散点比较图](./rmsnorm_fp32/results/rmsnorm_fp32_mk_test2/charts/rmsnorm_fp32_scatter_comparison.png)

**分析:**
对于较大的序列长度，同样表现出极好的一致性。

---

## Softmax (FP32)

### 测试运行: `softmax_fp32_mk_test1`

**PyTorch (CPU) 性能:**

| 指标                   | 值                                     |
|--------------------------|----------------------------------------|
| 精度                     | fp32                                   |
| 维度                     | oc_group=1, seq_len=128, ogs=32        |
| 延迟 (ms)                | 15.92                                  |
| 吞吐量 (Elements/sec)    | 257,330                                |

**精度 (C++ DUT vs. PyTorch FP32 参考):**

| 指标                | 值                     |
|-----------------------|------------------------|
| 最大绝对误差          | 1.4901e-08             |
| 平均绝对误差          | 2.1585e-09             |
| 最大相对误差          | 4.2862e-07             |
| 平均相对误差          | 7.3149e-08             |
| 余弦相似度            | 1.0                    |
| MSE (均方误差)        | 1.0485e-17             |

**图表:**

*   [绝对误差直方图](./softmax_fp32/results/softmax_fp32_mk_test1/charts/softmax_fp32_abs_error_hist.png)
*   [相对误差直方图](./softmax_fp32/results/softmax_fp32_mk_test1/charts/softmax_fp32_rel_error_hist.png)
*   [散点比较图](./softmax_fp32/results/softmax_fp32_mk_test1/charts/softmax_fp32_scatter_comparison.png)

**分析:**
Softmax算子表现出极好的一致性。

---

### 测试运行: `softmax_fp32_mk_test2`

**PyTorch (CPU) 性能:**

| 指标                   | 值                                     |
|--------------------------|----------------------------------------|
| 精度                     | fp32                                   |
| 维度                     | oc_group=1, seq_len=256, ogs=32        |
| 延迟 (ms)                | 15.11                                  |
| 吞吐量 (Elements/sec)    | 542,003                                |

**精度 (C++ DUT vs. PyTorch FP32 参考):**

| 指标                | 值                     |
|-----------------------|------------------------|
| 最大绝对误差          | 1.4901e-08             |
| 平均绝对误差          | 2.2793e-09             |
| 最大相对误差          | 4.2862e-07             |
| 平均相对误差          | 7.6071e-08             |
| 余弦相似度            | 1.0                    |
| MSE (均方误差)        | 1.1399e-17             |

**图表:**
*   [绝对误差直方图](./softmax_fp32/results/softmax_fp32_mk_test2/charts/softmax_fp32_abs_error_hist.png)
*   [相对误差直方图](./softmax_fp32/results/softmax_fp32_mk_test2/charts/softmax_fp32_rel_error_hist.png)
*   [散点比较图](./softmax_fp32/results/softmax_fp32_mk_test2/charts/softmax_fp32_scatter_comparison.png)

**分析:**
在增加序列长度后，仍然保持了极好的一致性。

---

## Swish (FP32)

### 测试运行: `swish_fp32_mk_test1`

**PyTorch (CPU) 性能:**

| 指标                   | 值                                        |
|--------------------------|-------------------------------------------|
| 精度                     | fp32                                      |
| 维度                     | oc_group=2, num_data=1024, ogs=32         |
| 延迟 (ms)                | 14.89                                     |
| 吞吐量 (Elements/sec)    | 4,401,224                                 |

**精度 (C++ DUT vs. PyTorch FP32 参考):**

| 指标                | 值                     |
|-----------------------|------------------------|
| 最大绝对误差          | 1.7881e-07             |
| 平均绝对误差          | 1.0978e-08             |
| 最大相对误差          | 2.7538e-07             |
| 平均相对误差          | 4.6073e-08             |
| 余弦相似度            | 1.0                    |
| MSE (均方误差)        | 4.0176e-16             |

**图表:**

*   [绝对误差直方图](./swish_fp32/results/swish_fp32_mk_test1/charts/swish_fp32_abs_error_hist.png)
*   [相对误差直方图](./swish_fp32/results/swish_fp32_mk_test1/charts/swish_fp32_rel_error_hist.png)
*   [散点比较图](./swish_fp32/results/swish_fp32_mk_test1/charts/swish_fp32_scatter_comparison.png)

**分析:**
Swish算子表现出极好的一致性。

---

### 测试运行: `swish_fp32_mk_test2`

**PyTorch (CPU) 性能:**

| 指标                   | 值                                        |
|--------------------------|-------------------------------------------|
| 精度                     | fp32                                      |
| 维度                     | oc_group=4, num_data=1024, ogs=32         |
| 延迟 (ms)                | 16.01                                     |
| 吞吐量 (Elements/sec)    | 8,188,594                                 |

**精度 (C++ DUT vs. PyTorch FP32 参考):**

| 指标                | 值                     |
|-----------------------|------------------------|
| 最大绝对误差          | 1.7881e-07             |
| 平均绝对误差          | 1.0939e-08             |
| 最大相对误差          | 2.7538e-07             |
| 平均相对误差          | 4.5902e-08             |
| 余弦相似度            | 1.0                    |
| MSE (均方误差)        | 4.0037e-16             |

**图表:**

*   [绝对误差直方图](./swish_fp32/results/swish_fp32_mk_test2/charts/swish_fp32_abs_error_hist.png)
*   [相对误差直方图](./swish_fp32/results/swish_fp32_mk_test2/charts/swish_fp32_rel_error_hist.png)
*   [散点比较图](./swish_fp32/results/swish_fp32_mk_test2/charts/swish_fp32_scatter_comparison.png)

**分析:**
Swish算子表现出极好的一致性。

---
