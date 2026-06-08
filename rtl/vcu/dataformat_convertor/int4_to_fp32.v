module int4_to_fp32(
  int4, fp32
);
    
input       [3:0]  int4;
output wire [31:0] fp32;


wire [3 : 0] abs_int4;
wire sign;
wire [1 : 0] zero_num;
wire zero_full;

wire [3 : 0] shifted_int;
wire [22 : 0] frac;

wire [7:0] exp;

assign sign = int4[3];
assign abs_int4 = int4[3] ? ({1'b0,~int4[2 : 0]} + 1) : int4;

// lzd #(.W(4), .N(2)) u0(
//   .data(abs_int4),
//   .zcnt(zero_num),
//   .full(zero_full)
// );

lzd4 u_lzd4(
  .data(abs_int4),
  .zcnt(zero_num),
  .full(zero_full)
);

assign shifted_int = zero_full ? 0 : (abs_int4 << zero_num);
assign frac = {shifted_int[2:0], 20'h0};
assign exp = zero_full ? 0 : (3 - zero_num + 127);

assign fp32 = {sign, exp, frac};
    
endmodule
