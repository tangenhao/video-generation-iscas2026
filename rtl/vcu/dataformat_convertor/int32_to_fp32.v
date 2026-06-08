module int32_to_fp32(
  int32, fp32
);
input       [31:0] int32;
output wire [31:0] fp32;

wire [31 : 0] abs_int;
wire sign;
wire [4 : 0] zero_num;
wire zero_full;

wire [31 : 0] shifted_int;
wire [22 : 0] unrounded_frac;
wire [7 : 0] bits_after_frac;
wire [1 : 0] plus_1_conditions;
wire [22 : 0] frac;

wire [7:0] exp;
wire [30:0] exp_frac;

assign sign = int32[31];
assign abs_int = int32[31] ? ({1'b0,~int32[30 : 0]} + 1) : int32;

// lzd #(.W(32), .N(5)) u0(
//   .data(abs_int),
//   .zcnt(zero_num),
//   .full(zero_full)
// );

lzd32 u_lzd32(
  .data ( abs_int   ),
  .zcnt ( zero_num  ),
  .full ( zero_full )
);

assign shifted_int = zero_full ? 0 : (abs_int << zero_num);
assign unrounded_frac = shifted_int[30 : 8];
assign bits_after_frac = shifted_int[7 : 0];
assign plus_1_conditions[0] = ((|bits_after_frac[6 : 0]) && bits_after_frac[7]) ? 1'b1 : 1'b0;
assign plus_1_conditions[1] = ((bits_after_frac == 8'b10000000) && unrounded_frac[0]) ? 1'b1 : 1'b0;
assign exp = zero_full ? 0 : (31 - zero_num + 127);

assign exp_frac = {exp, unrounded_frac} + (|plus_1_conditions);

assign fp32 = {sign, exp_frac};
endmodule
