| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [5:0] | 6 | Insn_opcode `5'00000` for synchronize instruction. |  | 
| sync_insns | [7:6] | 2 | Sync_insns `2'b01` for synchronize_iteration instruction. |  | 
| next_word | [14:8] | 7 | The number of words to be iterated. |  | 
| iteration_times | [22:15] | 8 | The number of iteration times. |  | 
| valid_insn_number | [24:23] | 2 | The number of valid instruction synchronize words in this instruction. |  | 
| sync_word_0 | [56:25] | 32 | Sync word 0 |  | 
| sync_word_1 | [88:57] | 32 | Sync word 1 |  | 
| load_highaddr_config | [89:89] | 1 |  |  | 
| store_highaddr_config | [90:90] | 1 |  |  | 
