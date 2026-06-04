module log2_pre(
  data, 
  index, data_out, result_int, neg
);

input       [31:0] data;
output wire [6:0]  index;
output wire [18:0] data_out;
output wire [7:0]  result_int;  // |-149 | =149
output wire        neg;

wire [4:0]  lzd_o_temp;
wire [4:0]  shift_number;
wire [23:0] norm_frac;
wire [8:0]  norm_exp;  //1bit sign
wire [7:0]  norm_neg_abs;


assign shift_number = lzd_o_temp - 8;
// assign norm_frac = (data[30:23] == 8'h0) ? (data[22:0] << shift_number ) : {1'b1, data[22:0]};
assign norm_frac = (~(|data[30:23]))  ? (data[22:0] << shift_number ) : {1'b1, data[22:0]};

// assign norm_exp = (data[30:23] == 8'h0) ? ( -126 - shift_number ) : ({1'b0,data[30:23]} -127);
assign norm_exp = (~(|data[30:23]))  ? ( - 9'd118 - {4'b0, lzd_o_temp} ) : ({1'b0, data[30:23]} -127);

assign neg = norm_exp[8];  
assign norm_neg_abs = (~norm_exp[7:0]);
// assign result_int = norm_exp[8] ? ( (norm_frac[22:0] == 23'b0) ? (norm_neg_abs  + 1) : norm_neg_abs ) : norm_exp[7:0];
assign result_int = norm_exp[8] ? ( (~(|norm_frac[22:0])) ? (norm_neg_abs  + 1) : norm_neg_abs ) : norm_exp[7:0];

assign index = norm_frac[22:16];
assign data_out =  {norm_frac[15:0], 3'b0};


// lzd #(.W(32), .N(5)) lzd_1(
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

    
