| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [5:0] | 6 | Insn_opcode `5'01101` ~ `5'b01111` for convolution execute instruction. |  | 
| insn_number | [9:6] | 4 | The number of execution times controled by a single synchronize word. |  | 
| insn_kind | [12:10] | 3 | 指令类型, <br> `000 - config` <br> `001 - convolution execute`<br> `010 - gemm execute`<br> `011 - transposed convlution execute` |  | 
| type_a | [15:13] | 3 | 输入A的数据类型, <br>`000 - int4`<br> `001 - int8`<br>  `010 - fp16`<br> `011 - bf16`<br>`100 - int16`. | `000` | 
| type_b | [18:16] | 3 | 输入B的数据类型, <br>`000 - int4`<br> `001 - int8`<br>  `010 - fp16`<br> `011 - bf16`<br>`100 - int16`. | `000` | 
| type_accumulator | [19:19] | 1 | 累加数据类型, <br>`0 - int32`<br> `1 - fp32`. | `0` | 
| type_output | [21:20] | 2 | 输出数据类型, <br>`00 - int32`<br> `01 - fp32`<br> `10 - int16`. | `00` | 
| ifmap_width | [33:22] | 12 | 输入特征图宽度<br><b>为真实值` -1` | `0` | 
| ifmap_height | [45:34] | 12 | 输入特征图高度<br><b>为真实值` -1` | `0` | 
| weight_width | [53:46] | 8 | 输入卷积核宽度<br><b>为真实值` -1` | `0` | 
| weight_height | [61:54] | 8 | 输入卷积核高度<br><b>为真实值` -1` | `0` | 
| psum_width | [73:62] | 12 | 部分和宽度<br><b>为真实值` -1` | `0` | 
| psum_height | [85:74] | 12 | 部分和高度<br><b>为真实值` -1` | `0` | 
| ic_group | [93:86] | 8 | 输入通道组数<br><b>为真实值` -1` | `0` | 
| oc_group | [101:94] | 8 | 输出通道组数<br><b>为真实值` -1` | `0` | 
| ifmap_highaddr | [102:102] | 1 | ifmap SRAM Ping-Pong高位 | `0` | 
| weight_highaddr | [103:103] | 1 | weight SRAM Ping-Pong高位 | `0` | 
| psum_highaddr | [105:104] | 2 | psum SRAM Ping-Pong高位 | `0` | 
| pad_left | [112:106] | 7 | 左侧填充<br><b>为真实值 | `0` | 
| pad_top | [119:113] | 7 | 上侧填充<br><b>为真实值 | `0` | 
| psum_number | [126:120] | 7 | psum SRAM写入次数 | `0` | 
| psum_accumulated | [127:127] | 1 | 是否累加psum,<br> `0 - disable`<br> `1 - enable | `0` | 
