module fp16_to_fp32(
  fp16, fp32
);
    
input       [15:0] fp16;
output wire [31:0] fp32;
    
wire fp16_sign;
wire fp32_sign;

wire [4:0] fp16_exp;
wire [7:0] fp32_exp;

wire [9:0] fp16_frac;
wire [22:0] fp32_frac;

wire [3:0] lzd_o_temp;
wire [3:0] shift_number;
wire denormal_sign;
wire nan_sign;
wire inf_sign;
wire zero_sign;
wire [23:0] fp16_frac_shift;

wire [31:0] fp32_temp;

assign fp16_sign = fp16[15];
assign fp16_exp = fp16[14:10];
assign fp16_frac = fp16[9:0];

assign denormal_sign =  (~(|fp16_exp)) & (|fp16_frac);
assign nan_sign = (&fp16_exp) & (|fp16_frac);
assign inf_sign = (&fp16_exp) & (~(|fp16_frac));
assign zero_sign = (~(|fp16_exp)) & (~(|fp16_frac));


assign fp32_sign = fp16_sign;

assign shift_number = lzd_o_temp;
assign fp16_frac_shift = {(fp16_frac << shift_number), 14'b0};

assign fp32_exp = denormal_sign ?  ( 8'd112 - {4'b0, shift_number} ) : ( {3'b0, fp16_exp} + 112 );

assign fp32_frac = denormal_sign ? fp16_frac_shift[22:0] : {fp16_frac, 13'b0};

assign fp32_temp = {fp32_sign, fp32_exp, fp32_frac};

assign fp32 = zero_sign ? {fp32_sign, 31'h0} : (nan_sign ? {fp32_sign, 31'h7fffffff} : (inf_sign ? {fp32_sign, 31'h7F800000} : fp32_temp));

// lzd #(.W(16), .N(4)) lzd_data_tran(
// .data({6'b0, fp16_frac}),
// .zcnt(lzd_o_temp),
// .full()
// );

lzd16 u_lzd16(
  .data({fp16_frac, 6'd0}),
  .zcnt(lzd_o_temp),
  .full()
);
    
endmodule
