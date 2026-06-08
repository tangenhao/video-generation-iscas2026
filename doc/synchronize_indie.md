| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [5:0] | 6 | Insn_opcode `5'00000` for synchronize instruction. |  | 
| sync_insns | [7:6] | 2 | Sync_insns `2'b00` for synchronize_indie instruction. |  | 
| valid_insn_number | [9:8] | 2 | The number of valid instruction synchronize words in this instruction. |  | 
| sync_word_0 | [41:10] | 32 | Sync word 0 |  | 
| sync_word_1 | [73:42] | 32 | Sync word 1 |  | 
| sync_word_2 | [105:74] | 32 | Sync word 2 |  | 
| load_highaddr_config | [106:106] | 1 | Load high address configuration, `1` - Use last synchronze_cross instruction configed high address, `0` - Use local high address configuration. |  | 
| store_highaddr_config | [107:107] | 1 | Store high address configuration, `1` - Use last synchronze_cross instruction configed high address, `0` - Use local high address configuration. |  | 
