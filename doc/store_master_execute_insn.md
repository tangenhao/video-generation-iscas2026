| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [4:0] | 5 | Insn_opcode `5'00010` for store_master instruction. |  | 
| insn_number | [9:5] | 5 | The number of execution times controled by a single synchronize word. |  | 
| store_insns | [11:10] | 2 | Store_insns `2'b00` for store_master_execute instruction. |  | 
| ddr_addr | [49:12] | 38 | 35-bits ddr address, 32GB |  | 
| sequ_burst_0 | [57:50] | 8 | The number of bursts for store sequence iteration 0. <br> <b> true value is `seq_burst_0`+1 <br> |  | 
| hop_offset_1_exp | [60:58] | 3 | The exponent of the hop offset for store sequence iteration 1. |  | 
| hop_offset_1_fra | [68:61] | 8 | The fraction of the hop offset for store sequence iteration 1. |  | 
| sequ_burst_1 | [73:69] | 5 | The number of bursts for store sequence iteration 1. <br> <b> true value is `seq_burst_1`+1 <br> |  | 
| hop_offset_2_exp | [77:74] | 4 | The exponent of the hop offset for store sequence iteration 2. |  | 
| hop_offset_2_fra | [85:78] | 8 | The fraction of the hop offset for store sequence iteration 2. |  | 
| sequ_burst_2 | [89:86] | 4 | The number of bursts for store sequence iteration 2. <br> <b> true value is `seq_burst_2`+1 <br> |  | 
| hop_offset_3_exp | [94:90] | 5 | The exponent of the hop offset for store sequence iteration 3. |  | 
| hop_offset_3_fra | [102:95] | 8 | The fraction of the hop offset for store sequence iteration 3. |  | 
| sequ_burst_3 | [106:103] | 4 | The number of bursts for store sequence iteration 3. <br> <b> true value is `seq_burst_3`+1 <br> |  | 
| sram_addr | [126:107] | 20 | Source SRAM address |  | 
| all_done | [127:127] | 1 | All done flag |  | 
