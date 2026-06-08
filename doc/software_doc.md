# 软件说明

## 1. pea::Conv2dOp

### 1.1. 介绍

用于生成NPU卷积指令序列

### 1.2. 模板

```c++
template<int  SPARSE_BASE_              = 0,      // 稀疏基数
         int  SPARSE_RATIO_             = 0,      // 稀疏比率
         bool NON_UNIFORM_QUANTIZATION_ = false,  // 是否支持非均匀量化, 仅int4的weight支持
         bool OUTLIER_ENABLE_           = false,  // 是否支持异常值处理, 仅int卷积/矩阵乘支持
         int  TYPE_A_                   = kInt4,  // ifmap的输入数据类型, 定义在c/include/common/type_utils.h
         int  TYPE_B_                   = kInt4,  // weight的输入数据类型, 定义在c/include/common/type_utils.h
         int  TYPE_ACCUMULATOR_         = kInt32,  // 累加器的数据类型, 定义在c/include/common/type_utils.h
         int  TYPE_OUTPUT_              = kInt32,  // 输出的数据类型, 定义在c/include/common/type_utils.h
         int  PE_SERIAL_                = 0,       // PE序列号,
         bool DEBUG_                    = false    // 是否打印调试信息
         >
struct Conv2dOp
```

### 1.2 参数

```c++
struct Arguments {
  int      ifmap_h;          // 输入特征图高度
  int      ifmap_w;          // 输入特征图宽度 
  int      weight_h;         // 卷积核高度
  int      weight_w;         // 卷积核宽度
  int      in_channels;      // 输入通道数
  int      out_channels;     // 输出通道数
  int      stride_h;         // 滑动步长
  int      stride_w;         // 滑动步长
  int      pad_h;            // 上下padding
  int      pad_w;            // 左右padding
  int      dilation_h;       // 膨胀系数
  int      dilation_w;       // 膨胀系数
  int      ifmap_block_h;    // 分块卷积, 输入特征图块高度
  int      ifmap_block_w;    // 分块卷积, 输入特征图块宽度
  int      weight_block_h;   // 分块卷积, 卷积核块高度
  int      weight_block_w;   // 分块卷积, 卷积核块宽度
  int      block_ic_group;   // 分组卷积, 输入通道组数
  int      block_oc_group;   // 分组卷积, 输出通道组数
  uint64_t ifmap_base_addr;  // 输入特征图基地址
  uint64_t weight_base_addr; // 卷积核基地址
  uint64_t ofmap_base_addr;  // 输出特征图基地址
  uint64_t ifmap_scale_base_addr   = 0; // 输入特征图量化因子基地址
  uint64_t weight_scale_base_addr  = 0; // 卷积核量化因子基地址
  uint64_t outlier_index_base_addr = 0; // 异常值索引基地址
  uint64_t ifmap_mask_base_addr    = 0; // 输入特征图掩码基地址
  };
```

- 备注
  - `ifmap_scale_base_addr`, `weight_scale_base_addr`, `outlier_index_base_addr`, `ifmap_mask_base_addr` 为可选参数, 需要根据template配置信息来决定是否使用
  - `ifmap_scale_base_addr`, `weight_scale_base_addr` 为量化因子基地址, 用于per vector scale quantization
  - `outlier_index_base_addr` 为异常值索引基地址, 用于异常值处理
  - `ifmap_mask_base_addr` 为输入特征图掩码基地址, 用于稀疏卷积