# 实用小工具

## 1. 自动生成指令例化

- Requirement
  - python3
  - 在`cfg/insn_bits.cfg`中定义指令的位宽

- Usage:

```bash
cd script
python insn_decode.py
```

- Output:

```verilog
====  vcu_execute_insn ====

reg [5:0]insn_opcode        insn[4:0]
reg [5:0]insn_number        insn[9:5]
reg [2:0]insn_kind          insn[11:10]
reg [3:0]psum_data_type     insn[14:12]
reg [3:0]resadd_para_type   insn[17:15]
reg [3:0]data_out_type      insn[20:18]
reg [1:0]data_out_ram       insn[21:21]
reg [10:0]opcode_number     insn[31:22]
reg [7:0]opcode_addr        insn[38:32]
reg [6:0]para_in_addr       insn[44:39]
reg [12:0]resadd_in_addr    insn[56:45]
reg [13:0]ram_out_addr      insn[69:57]
reg [10:0]num_data_cnt      insn[79:70]
reg [4:0]oc_group_cnt       insn[83:80]
reg [2:0]para_func_cnt      insn[85:84]
```

## 2. 自动生成指令文档

- Requirement
  - python3
  - 在`cfg/insn_bits.cfg`中定义指令的位宽
  - 在`cfg/insn_decscription.cfg`中定义指令的文档
  - 在`cfg/insn_default.cfg`中定义指令的默认值

- Usage:

```bash
cd script
python gen_doc.py
```

- Output:
  - 在`doc`文件夹中生成`${insn_name}.md`文件, 文件内容只有一个markdown表格

## 3. markdown表格与excel、csv互转

- Requirement
  - python3
    - pandas
    - openpyxl
    - shutil
    - zipfile

```bash
pip install pandas openpyxl shutil zipfile
```

- Usage:

```bash
cd script
python md2excel.py --input doc/convolution_execute_insn.md --output doc/convolution_execute_insn.xlsx
python excel2md.py --input doc/convolution_execute_insn.xlsx --output doc/convolution_execute_insn.md
```

- Output:
  - `md2excel.py`将markdown表格转为excel表格
  - `excel2md.py`将excel表格转为markdown表格
  - 两个脚本的`--input`参数为输入文件路径，`--output`参数为输出文件路径
  - `md2excel.py`输出的excel表格中，第一行为表头，第二行为数据类型，第三行为数据默认值
  - `excel2md.py`输出的markdown表格中，第一行为表头，第二行为数据类型，第三行为数据默认值
  - `csv`文件与`excel`文件的转换方法类似，只需要将`--input`和`--output`的文件后缀改为`.csv`即可


## 4. 自动生成指令图

- Requirement
  - python3
  - 在`cfg/insn_bits.cfg`中定义指令的位宽

- Usage:

```bash
cd script
python gen_figs.py
```

- Output:
  - 在`../doc/Figs`文件夹中生成`${insn_name}.svg`文件, 文件内容为指令的位宽图

## 5. 自动例化verilog模块

- Requirement
  - python3

- Usage:

```bash
python script/instantiate.py --input rtl/npu_top.v -p -t
```

- Output:
  - 在命令行中打印例化的模块
  - `-p`参数表示例化模块中的参数
  - `-t`参数表示像testbench一样, 用`reg`定义输入信号, 用`wire`定义输出信号

- **不喜欢这种例化风格怎么改**
  - line 99: `formatPort_tb`函数, 调整line 104`l1`变量定义, 调整line 110, line 111.ljust()的参数, 可以调整端口信号的对齐方式, 仅对添加`-t`参数的例化有效
  - line 168: `formatPara_tb`函数, 调整line 176`l1`变量定义, 调整line 180, line 183.ljust()的参数, 可以调整参数定义的对齐方式, 仅对添加`-t`参数的例化有效
  - line 129: `formatDeclare_tb`函数, 调整line 131`width_length`变量定义, 调整line 141, line 143.ljust()的参数, 可以调整信号声明的对齐方式, 仅对添加`-t`参数的例化有效


## 6. txt_to_num 数据转换

- Requirement
  - python3

- Usage:

```bash
python txt_to_num.py --input data.txt --output data_converted.txt --format [int4|int8|fp16|fp32] --verify --verify_count 5
```
还可对目录中的所有文件进行转换，只需要将`--input` `--output`参数改为目录路径即可

- Output:
  - 在命令行中打印转换后的数据
  - 在`data_converted.txt`文件中保存转换后的数据
  - 支持`int4`, `int8`, `fp16`, `fp32`四种数据格式
  - 支持验证转换后的数据是否正确
  - 支持验证时显示的样本数量
