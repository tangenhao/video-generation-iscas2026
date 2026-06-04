| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [5:0] | 6 | Insn_opcode `5'10011` ~ `5'b10100` for vcu execute instruction. |  | 
| insn_number | [9:6] | 4 | The number of execution times controled by a single synchronize word. |  | 
| insn_kind | [13:10] | 4 | 指令类型, <br> `01 - execute` |  | 
| psum_data_type | [16:14] | 3 | psum输入数据类型标识, 判断来自psum的数据进行何种数据转换 <br>`000` - fp16<br> `001` - bf16 <br>`010` - int16<br>`011` - int32<br>`100` - fp32 |  | 
| resadd_para_type | [19:17] | 3 | resadd输入数据类型标识, 判断来自resadd的数据进行何种数据转换, <br>`000` - int4<br>`001` - int8<br>`010` - int16<br>`011` - fp32<br>`100` - fp16<br>`101` - bf16<br> |  | 
| data_out_type | [22:20] | 3 | 输出数据类型，判断对结果进行何种类型转换, <br>`000` - int4<br>`001` - int8<br>`010` - int16<br>`011` - fp32<br>`100` - fp16<br>`101` - bf16<br>`111` - fp32 |  | 
| data_out_ram | [24:23] | 2 | 判断结果存入哪个寄存器, <br>`0` - psum<br>`1` - ofmap |  | 
| opcode_number | [31:25] | 7 | opcode的数量 |  | 
| opcode_addr | [38:32] | 7 | opcode SRAM的起始地址 |  | 
| psum_in_addr | [52:39] | 14 |  |  | 
| para_in_addr | [58:53] | 6 | psum_ram输入数据地址 |  | 
| resadd_in_addr | [71:59] | 13 | resadd_ram输入数据地址 |  | 
| ram_out_addr | [85:72] | 14 | 输出数据的ram地址 |  | 
| num_data_cnt | [99:86] | 14 | H × W |  | 
| oc_group_cnt | [107:100] | 8 | oc_group |  | 
| para_func_cnt | [109:108] | 2 | para_ram里存储的数据类型个数 |  | 
| psum_sram_valid | [110:110] | 1 |  |  | 
| para_sram_valid | [111:111] | 1 |  |  | 
| res_sram_valid | [112:112] | 1 |  |  | 
