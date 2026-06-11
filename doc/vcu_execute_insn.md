| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [5:0] | 6 | Insn_opcode `5'10011` ~ `5'b10100` for vcu execute instruction. |  |
| insn_number | [9:6] | 4 | The number of execution times controled by a single synchronize word. |  |
| insn_kind | [13:10] | 4 | 指令类型, <br> `01 - execute` |  |
| psum_data_type | [16:14] | 3 | psum输入数据类型标识, 判断来自psum的数据进行何种数据转换 <br>`000` - fp16<br> `001` - bf16 <br>`010` - int16<br>`011` - int32<br>`100` - fp32 |  |
| resadd_para_type | [19:17] | 3 | resadd输入数据类型标识, 判断来自resadd的数据进行何种数据转换, <br>`000` - int4<br>`001` - int8<br>`010` - int16<br>`011` - fp32<br>`100` - fp16<br>`101` - bf16<br> |  |
| data_out_type | [22:20] | 3 | 输出数据类型，判断对结果进行何种类型转换, <br>`000` - int4<br>`001` - int8<br>`010` - int16<br>`011` - fp32<br>`100` - fp16<br>`101` - bf16<br>`111` - fp32 |  |
| data_out_ram | [24:23] | 2 | 判断结果存入哪个寄存器, <br>`0` - psum<br>`1` - ofmap<br>`2` - psum_1<br>`3` - qact/scale |  |
| opcode_number | [31:25] | 7 | opcode的数量 |  |
| opcode_addr | [38:32] | 7 | opcode SRAM的起始地址 |  |
| psum_in_addr | [47:39] | 9 |  |  |
| para_in_addr | [56:48] | 9 | psum_ram输入数据地址 |  |
| resadd_in_addr | [65:57] | 9 | resadd_ram输入数据地址 |  |
| ram_out_addr | [73:66] | 8 | 输出数据的ram地址 |  |
| num_data_cnt | [87:74] | 14 | H × W |  |
| oc_group_cnt | [95:88] | 8 | oc_group |  |
| para_func_cnt | [97:96] | 2 | para_ram里存储的数据类型个数 |  |
| psum_sram_valid | [98:98] | 1 |  |  |
| resadd_sram_valid | [99:99] | 1 |  |  |
| para_sram_valid | [100:100] | 1 |  |  |
| psum_addr_hop | [101:101] | 1 |  |  |
| acc_clear | [102:102] | 1 |  |  |
| stream_en | [103:103] | 1 |  |  |
| ifmap_sram_valid | [104:104] | 1 |  |  |
| ifmap_in_addr | [113:105] | 9 |  |  |
| s2p_32_en | [114:114] | 1 |  |  |
| psum_1_sram_valid | [115:115] | 1 |  |  |
| psum_1_in_addr | [124:116] | 9 |  |  |
| reversed | [127:125] | 3 |  |  |
