module int8_to_fp32(
  int8, fp32
);
    
input       [7:0]  int8;
output wire [31:0] fp32;

wire [7 : 0] abs_int8;
wire sign;
wire [2 : 0] zero_num;
wire zero_full;

wire [7 : 0] shifted_int;
wire [22 : 0] frac;

wire [7:0] exp;

assign sign = int8[7];
assign abs_int8 = int8[7] ? ({1'b0,~int8[6 : 0]} + 1) : int8;


// lzd #(.W(8), .N(3)) u0(
//   .data(abs_int8),
//   .zcnt(zero_num),
//   .full(zero_full)
// );

lzd8 u_lzd8(
  .data ( abs_int8  ),
  .zcnt ( zero_num  ),
  .full ( zero_full )
);

assign shifted_int = zero_full ? 0 : (abs_int8 << zero_num);
assign frac = {shifted_int[6:0], 16'h0};
assign exp = zero_full ? 0 : (7 - zero_num + 127);

assign fp32 = {sign, exp, frac};
    
endmodule
