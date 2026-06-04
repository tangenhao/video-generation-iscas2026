# tb使用说明

## 1. 工程目录结构

```bash
.
├── c # 计算模型与指令编译c代码
├── cfg # 配置文件
├── cocotb # cocotb,没啥用
├── doc # 文档
├── README.md # 说明文档
├── rtl # rtl代码
├── script # 脚本
└── sim # 仿真目录
```

## 2. 仿真流程

- 编译c

```bash
cd c/build
cmake ..
make -j128 # 16线程编译, 数越大编译越快
```

- 生成指令与数据

```bash
cd c/exe
./test_conv_1x1_int8
```

- 仿真

```bash
cd sim
make sim TOP=npu_tb
```

## 3. workflow简单分析

- c代码
  - 生成随机激励与golden数据
  - 生成指令
  - 将上面的所有东西存成一个txt, 供tb读取
- tb
  - 读取c代码生成的txt, 放入ddr, `sim/bench/npu_tb.v`的line 987
  - apb配置寄存器, 启动npu计算, apb配置在`sim/bench/npu_tb.v`的line 436 ~ 484, 可能目前只需要改line 440, 配置指令条数, 如果条数比较多改大一点
  - **后续的操作就与tb无关了, NPU的计算流程为**
    - dispatch模块根据apb配置的指令数量, 指令基地址从ddr中取指令, 分发到各个模块的指令fifo
    - synchronize模块根据**取到的sync指令**, 控制各个模块执行指令fifo中的指令队列
    - load模块从ddr加载数据
    - pea, vcu执行计算
    - store模块将计算结果存入ddr

- 需要关注的c code
  - `c/csrc/test/test_pea.cpp`, 生成仿真数据与指令
  - `c/include/compute_model/tensor.h`, tensor结构体定义
    - 具体用法参照`test_vcu.cpp`的line 59 ~ line 88
    - 重载了一堆运算符, 用于方便的操作tensor
    - 目前支持的操作:
      - 输入输出流运算符, 可以直接cout, 或fstream操作
      - randn随机生成tensor数据
      - vector的容器操作
      - 快速算法的tensor实现, 本质上是遍历tensor内元素, 但用起来十分方便
  - `c/include/pea/pea_insn.h`, 用于生成pea指令, 用法参考`test_pea.cpp`的line 23 ~ 40
  - `c/include/compute_model/conv2d.h`, 用于生成测试激励, 用法参考`test_pea.cpp`的line 42 ~ 66
- 需要注意的地方
  - **所有要写入SRAM的数据会被预先存入DDR, 通过load store指令加载**
  - **DDR被拆分成了2个256bit, 拆分函数为`common::file_utils::saveCharArrayToFormattedTextFileSplitTwoDDR`**
  - SRAM基地址参考[这里](./doc/sram_address_dispatch.md)