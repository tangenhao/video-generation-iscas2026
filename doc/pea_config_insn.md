| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [5:0] | 6 | Insn_opcode `5'00011` ~ `5'b01100` for pea instruction. |  | 
| insn_number | [9:6] | 4 | The number of execution times controled by a single synchronize word. |  | 
| insn_kind | [12:10] | 3 | 指令类型, <br> `000 - config` <br> `001 - convolution execute`<br> `010 - gemm execute`<br> `011 - transposed convlution execute` |  | 
| sparse_enable | [13:13] | 1 |  |  | 
| ifmap_non_uniform_quantization | [14:14] | 1 |  |  | 
| weight_non_uniform_quantization | [15:15] | 1 |  |  | 
| outlier_enable | [16:16] | 1 | 异常值检测, <br>`0 - disable`<br> `1 - enable`. | `0` | 
| stride_width | [21:17] | 5 | 卷积宽度方向步长 | `1` | 
| stride_height | [26:22] | 5 | 卷积高度方向步长 | `1` | 
| dilation_width | [31:27] | 5 | 卷积宽度方向膨胀率 | `0` | 
| dilation_height | [36:32] | 5 | 卷积高度方向膨胀率 | `0` | 
