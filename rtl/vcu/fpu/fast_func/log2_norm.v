module log2_norm(
  sum, data, result_int, neg, 
  out
);
input       [63:0] sum;
input       [31:0] data;
input       [7:0]  result_int;
input              neg;
output wire [31:0] out;


wire [31:0]  out_temp;
wire [31:0]  out_temp_temp;
wire [53:0]  frac_round_before;
// wire [53:0]  frac_round;
wire [5:0]   shift_number;
wire [61:0]  result_mid;
wire [61:0]  result;
wire [5:0]   lzd_o_temp;
wire [63:0]  shift_out;

// assign out_temp_temp[31] = neg;
// assign frac_round_before = sum[61:8];
// assign frac_round = (sum[7] && (sum[6:0] != 7'b0)) ? (frac_round_before + 1) : frac_round_before;
// assign result_mid[53:0] = neg ? ((~frac_round) + 1) : frac_round;
// assign result_mid[61:54] = result_int;
// assign shift_number = lzd_o_temp - 6'd2;
// assign result = result_mid << shift_number;
// assign out_temp_temp[30:23] = 134 - shift_number;
// assign out_temp_temp[22:0]  = result[60:38];
// assign out_temp = (result_mid == 62'b0 ) ? 62'b0 : out_temp_temp;

// assign out = data[31] ? 32'hffffffff :  (((data[30:0] == 31'b0) ?  32'hff800000 :  
//             ( ( data[30:23] == 8'hff ) ? ((data[22:0] == 23'b0) ? 32'h7f800000 : 32'h7fffffff) :out_temp )  ));

wire carry;
wire [53:0] frac_carry;
wire [53:0] frac_carry_neg;
wire [53:0] frac_neg;
wire norm_sig_1;
wire norm_sig_2;
wire norm_sig_3;
wire norm_sig_4;

//assign carry = sum[7] & (sum[6:0] != 7'b0);
assign carry = sum[7] & (|sum[6:0]);

assign out_temp_temp[31] = neg;
assign frac_round_before = sum[61:8];
assign frac_carry = frac_round_before + 1;
assign frac_carry_neg = ~frac_round_before;
assign frac_neg = (~frac_round_before) + 1;
assign norm_sig_1 = (~carry) & (~neg);
assign norm_sig_2 = (~carry) & neg;
assign norm_sig_3 = carry & (~neg);
assign norm_sig_4 = carry & neg;
assign result_mid[53:0] = ({54{norm_sig_1}} & frac_round_before) | ({54{norm_sig_2}} & frac_neg) | ({54{norm_sig_3}} & frac_carry) | ({54{norm_sig_4}} & frac_carry_neg) ;
assign result_mid[61:54] = result_int;



assign shift_number = lzd_o_temp - 2;

assign result = result_mid << shift_number;
// assign result = shift_out[61:0];
// assign out_temp_temp[30:23] = 134 - shift_number;
assign out_temp_temp[30:23] = 8'd136 - {2'b0, lzd_o_temp};
assign out_temp_temp[22:0]  = result[60:38];

//assign out_temp = (result_mid == 62'b0 ) ? 62'b0 : out_temp_temp;
assign out_temp = {32{(|result_mid)}}  & out_temp_temp;

// assign out = data[31] ? 32'hffffffff :  (((data[30:0] == 31'b0) ?  32'hff800000 :  
//             ( ( data[30:23] == 8'hff ) ? ((data[22:0] == 23'b0) ? 32'h7f800000 : 32'h7fffffff) :out_temp )  ));

assign out = data[31] ? 32'hffffffff :  ( (~(|data[30:0])) ?  32'hff800000 :  
            ( (&data[30:23]) ? ((~ (|data[22:0] )) ? 32'h7f800000 : 32'h7fffffff) :out_temp )  );

// lzd #(.W(64), .N(6)) lzd_2(
//   .data({2'b0, result_mid}),
//   .zcnt(lzd_o_temp),
//   .full()
// );

lzd64 u_lzd64(
  .data ( {2'b0, result_mid} ),
  .zcnt ( lzd_o_temp         ),
  .full (                    )
);

// shifter_left_64_6 shifter_left_64_6_log2(
// .data({2'b0, result_mid}), 
// .shift(shift_number),
// .o(shift_out)
// );

endmodule