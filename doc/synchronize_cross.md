| Name | Field | Bits | Description | Default |
|:-----|:-----:|:----:|:------------|:-------:|
| insn_opcode | [4:0] | 5 | Insn_opcode `5'00000` for synchronize instruction. |  | 
| sync_insns | [6:5] | 2 | Sync_insns `2'b10` for synchronize_cross instruction. |  | 
| sync_word | [24:7] | 18 | Sync word |  | 
| load_highaddr | [43:25] | 19 | Load high address |  | 
| check_reg_value | [75:44] | 32 | Dependency register check value |  | 
| store_highaddr | [94:76] | 19 | Store high address |  | 
| set_reg_value | [126:95] | 32 | Dependency register set value |  | 
