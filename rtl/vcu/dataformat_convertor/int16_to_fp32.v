module int16_to_fp32(
  int16, fp32
);
    
input       [15:0] int16;
output wire [31:0] fp32;

wire [15 : 0] abs_int16;
wire sign;
wire [3 : 0] zero_num;
wire zero_full;

wire [15 : 0] shifted_int;
wire [22 : 0] frac;

wire [7:0] exp;

assign sign = int16[15];
assign abs_int16 = int16[15] ? ((~int16) + 1) : int16;


// lzd #(.W(16), .N(4)) u0(
//   .data(abs_int16),
//   .zcnt(zero_num),
//   .full(zero_full)
// );

lzd16 u_lzd16(
  .data(abs_int16),
  .zcnt(zero_num),
  .full(zero_full)
);

assign shifted_int = zero_full ? 0 : (abs_int16 << zero_num);
assign frac = {shifted_int[14:0], 8'h0};
assign exp = zero_full ? 0 : (15 - zero_num + 127);

assign fp32 = {sign, exp, frac};
endmodule