module bf16_to_fp32(
  bf16, fp32
);
    
input       [15:0] bf16;
output wire [31:0] fp32;

assign fp32 =(&bf16[14:7]) ? (|bf16[6:0] ? {bf16[15], 31'h7fffffff} : {bf16[15], 8'hff, 23'h0}) : {bf16, 16'd0};
    
endmodule
