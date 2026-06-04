| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [5:0] | 6 | Insn_opcode `5'10000` ~ `5'b10010` for gemm execute instruction. |  | 
| insn_number | [9:6] | 4 | The number of execution times controled by a single synchronize word. |  | 
| insn_kind | [12:10] | 3 | 指令类型, <br> `000 - config` <br> `001 - convolution execute`<br> `010 - gemm execute`<br> `011 - transposed convlution execute` |  | 
| type_a | [15:13] | 3 | 输入A的数据类型, <br>`000 - int4`<br> `001 - int8`<br>  `010 - fp16`<br> `011 - bf16`<br>`100 - int16`. | `000` | 
| type_b | [18:16] | 3 | 输入B的数据类型, <br>`000 - int4`<br> `001 - int8`<br>  `010 - fp16`<br> `011 - bf16`<br>`100 - int16`. | `000` | 
| type_accumulator | [19:19] | 1 | 累加数据类型, <br>`0 - int32`<br> `1 - fp32`. | `0` | 
| type_output | [21:20] | 2 | 输出数据类型, <br>`00 - int32`<br> `01 - fp32`<br> `10 - int16`. | `00` | 
| tile_m | [33:22] | 12 | 矩阵乘法tile m维度 | `0` | 
| n_groups | [41:34] | 8 | n方向分组数 | `0` | 
| k_groups | [49:42] | 8 | k方向分组数 | `0` | 
| ifmap_highaddr | [50:50] | 1 | ifmap SRAM Ping-Pong高位 | `0` | 
| weight_highaddr | [51:51] | 1 | weight SRAM Ping-Pong高位 | `0` | 
| psum_highaddr | [53:52] | 2 | psum SRAM Ping-Pong高位 | `0` | 
| psum_number | [65:54] | 12 | psum SRAM写入次数 | `0` | 
| psum_accumulated | [66:66] | 1 | 是否累加psum,<br> `0 - disable`<br> `1 - enable | `0` | 
