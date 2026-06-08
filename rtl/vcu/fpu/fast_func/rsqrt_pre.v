module rsqrt_pre(
  data, 
  index, data_out, norm_exp
);
input       [31:0] data;
output wire [6:0]  index;
output wire [18:0] data_out;
output wire [7:0]  norm_exp;  


wire [4:0]  lzd_o_temp;
wire [4:0]  shift_number;
wire [23:0] norm_frac; 
wire [8:0]  real_exp;
wire [8:0]  even_exp;
wire [7:0]  even_exp_neg_abs;

assign shift_number = lzd_o_temp - 8;
assign norm_frac = (data[30:23] == 8'h0) ? (data[22:0] << shift_number ) : {1'b1, data[22:0]};
assign real_exp = (data[30:23] == 8'h0) ? ( - 9'd126 - {4'b0, shift_number} ) : (({1'b0, data[30:23]}) - 127);
assign even_exp = real_exp[0] ? (real_exp - 1) : real_exp;
assign index =  real_exp[0] ? {1'b1, norm_frac[22:17]} : {1'b0, norm_frac[22:17]};
assign even_exp_neg_abs = (~even_exp[7:0] ) + 1;

assign norm_exp = even_exp[8] ? (127 + even_exp_neg_abs[7:1]) : (127 - even_exp[7:1]);
assign data_out = {norm_frac[16:0], 2'b0};

// lzd #(.W(32), .N(5)) lzd_0(
//   .data({9'b0, data[22:0]}),
//   .zcnt(lzd_o_temp),
//   .full()
// );

lzd32 u_lzd32(
  .data ( {9'b0, data[22:0]} ),
  .zcnt ( lzd_o_temp         ),
  .full (                    )
);

endmodule

