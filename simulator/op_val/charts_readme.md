# 图表与数值指标说明文档

本文档旨在详细解释在算子验证过程中，由 `common_utils/plot_utils.py` 生成的各类数值准确性指标报告和相关图表的含义、计算方法以及如何解读它们。这些工具用于比较 C++ 仿真（DUT - Device Under Test）结果与 PyTorch 参考实现（Reference）结果之间的差异。

## 1. 数值准确性指标报告 (Numerical Accuracy Metrics Report)

当运行各个算子的 `compare_<op_name>_outputs.py` 脚本时，会打印出一个数值准确性指标报告。该报告由 `plot_utils.print_numerical_metrics_report` 函数生成，其数据来源于 `plot_utils.calculate_numerical_metrics` 函数的计算结果。

以下是报告中各项指标的详细说明：

*   **Number of Elements**:
    *   **含义**: 被比较的张量中的元素总数量。
    *   **计算**: `tensor_ref.size`。

*   **Mean Squared Error (MSE)**:
    *   **含义**: 均方误差，衡量两个张量之间差异的平均平方值。对较大的误差值更敏感。
    *   **计算**: `np.mean((tensor_ref - tensor_dut) ** 2)`。

*   **Mean Absolute Error (MAE)**:
    *   **含义**: 平均绝对误差，衡量两个张量之间差异的平均绝对值。能直观反映误差的平均大小。
    *   **计算**: `np.mean(np.abs(tensor_ref - tensor_dut))`。

*   **Max Absolute Error**:
    *   **含义**: 最大绝对误差，两个张量对应元素之间差异绝对值的最大值。反映了最坏情况下的误差。
    *   **计算**: `np.max(np.abs(tensor_ref - tensor_dut))`。

*   **Max Relative Error**:
    *   **含义**: 最大相对误差。对于每个元素，计算绝对误差除以参考张量中对应元素的绝对值（加上一个小常数 epsilon 以避免除零）。该指标取所有元素相对误差中的最大值。它能更好地反映误差相对于参考值大小的比例，尤其当参考值本身变化范围很大时。
    *   **计算**:
        1.  `abs_diff = np.abs(tensor_ref - tensor_dut)`
        2.  `denominator = np.abs(tensor_ref) + epsilon_for_relative_error`
        3.  `relative_diff = abs_diff / denominator`
        4.  `max_rel_err = np.max(relative_diff)`
    *   **`epsilon_for_relative_error`**: 一个小常数（默认为 `1e-9`，但在比较 FP16 GEMM 输出时可能设置为 `1e-7`），加在相对误差计算的分母中，以防止当参考值为0或接近0时发生除零错误或产生无意义的巨大相对误差。报告中会显示所使用的 `epsilon` 值。

*   **Cosine Similarity**:
    *   **含义**: 余弦相似度，衡量两个张量在方向上的相似性，忽略其幅度。值域为 \[-1, 1\]，1表示方向完全相同，0表示正交（无相关性），-1表示方向完全相反。对于高维数据，它是一个常用的相似性度量。
    *   **计算**: 将两个张量展平 (flatten) 为一维向量后，计算它们的点积，然后除以两个向量模长（L2范数）的乘积。
        *   `flat_ref = tensor_ref.flatten()`
        *   `flat_dut = tensor_dut.flatten()`
        *   `dot_product = np.dot(flat_ref, flat_dut)`
        *   `norm_ref = np.linalg.norm(flat_ref)`
        *   `norm_dut = np.linalg.norm(flat_dut)`
        *   特殊处理：若 `norm_ref` 和 `norm_dut` 都为0，则余弦相似度为1.0；若其中一个为0，则为0.0。
        *   否则为 `dot_product / (norm_ref * norm_dut)`。

*   **Reference Tensor Stats / DUT Tensor Stats**:
    *   **含义**: 分别报告参考张量和DUT张量的一些基本统计特性。
    *   **Mean**: 张量所有元素的平均值 (`np.mean(tensor)`)。
    *   **Std Dev**: 张量所有元素的标准差 (`np.std(tensor)`)。
    *   **NaNs**: 张量中是否存在 NaN (Not a Number) 值 (`np.any(np.isnan(tensor))`)。
    *   **Infs**: 张量中是否存在 Inf (Infinity) 值 (`np.any(np.isinf(tensor))`)。

## 2. 散点对比图 (Scatter Plot: DUT vs. Reference)

此图由 `plot_utils.plot_scatter_comparison` 函数生成，用于可视化 DUT 张量值与参考张量值的对应关系。

*   **文件名格式**: `<op_name>_<precision>_scatter_comparison.png` (例如 `gemm_fp16_scatter_comparison.png`)，保存在对应算子的 `results/charts/` 目录下。

*   **横坐标 (X-axis)**: **Reference Values** (来自 PyTorch 参考实现)。
*   **纵坐标 (Y-axis)**: **DUT Values** (来自 C++ 仿真实现)。

*   **如何解读**:
    *   图中的每个点代表两个张量中相同位置的一对元素值。
    *   一条红色的虚线 `y=x` 表示理想匹配线。如果 DUT 的输出与参考输出完全一致，则所有点都应精确地落在这条线上。
    *   点偏离 `y=x` 线的程度表示了 DUT 输出与参考输出之间的差异。
    *   点的分布模式可以揭示系统性偏差（例如，所有点系统性地高于或低于 `y=x` 线）或随机误差。
    *   **采样**: 对于元素数量非常多（默认大于10000个元素）的张量，为了绘图性能和可读性，会随机抽取一部分样本点（默认10000个）进行绘制。
    *   **坐标轴**: 坐标轴通常设置为等比例 (`axis('equal')`)，以便更直观地比较偏差。

## 3. 误差直方图 (Error Histogram)

此图由 `plot_utils.plot_error_histogram` 函数生成，用于显示绝对误差或相对误差的分布情况。

*   **文件名格式**:
    *   绝对误差: `<op_name>_<precision>_abs_error_hist.png` (例如 `gemm_fp16_abs_error_hist.png`)
    *   相对误差: `<op_name>_<precision>_rel_error_hist.png` (例如 `gemm_fp16_rel_error_hist.png`)
    *   均保存在对应算子的 `results/charts/` 目录下。

*   **输入数据**:
    *   **绝对误差直方图**: `metrics['absolute_error_array']`，即 `np.abs(tensor_ref - tensor_dut)`。
    *   **相对误差直方图**: `metrics['relative_error_array']`，即 `np.abs(tensor_ref - tensor_dut) / (np.abs(tensor_ref) + epsilon)`。

*   **横坐标 (X-axis)**: **Error Value**。
    *   对于绝对误差图，表示 `参考值 - DUT值` 的绝对值。
    *   对于相对误差图，表示上述计算的相对误差值。图的标题会注明计算相对误差时使用的 `epsilon` 值。

*   **纵坐标 (Y-axis)**: **Frequency** (通常采用对数刻度 `plt.yscale('log')`)。
    *   表示具有特定误差大小（或在特定误差区间内）的元素数量。对数刻度有助于观察分布的尾部以及较小频率的误差。

*   **如何解读**:
    *   直方图的形状可以揭示误差的分布特性。例如，如果误差主要集中在0附近，表明大部分元素的差异很小。
    *   分布的宽度可以反映误差的整体幅度。
    *   长尾或离群的条柱可能表示存在一些具有较大误差的特定元素。
    *   通过比较不同算子或不同条件下的误差直方图，可以评估数值稳定性的差异。

通过综合分析这些数值指标报告和图表，可以全面评估 C++ 仿真算子在数值准确性方面与 PyTorch 参考实现的接近程度。 