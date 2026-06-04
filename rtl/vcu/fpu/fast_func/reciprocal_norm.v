module reciprocal_norm(
  sum, data, norm_exp, lzd_o,
  out
);

input       [63:0] sum;
input       [31:0] data;
input       [7:0]  norm_exp;
input       [5:0]  lzd_o;
output wire [31:0] out;

wire [31:0]  out_temp;
wire [22:0]  frac_round_before;
wire [22:0]  frac_round;
wire [5:0]   shift_number;
wire [7:0]   exp_mid;
wire [63:0]  sum_norm_mid;
wire [63:0]  sum_norm;

assign out_temp[31] = data[31];
assign shift_number = lzd_o - 1;

assign sum_norm_mid =  sum << shift_number;

assign sum_norm = ( norm_exp < (shift_number + 1) ) ?  (sum_norm_mid >> (shift_number + 1 - norm_exp))  :  sum_norm_mid;
assign exp_mid = ( norm_exp < (shift_number + 1) ) ?   8'b0 :  (norm_exp - shift_number);
assign frac_round_before = sum_norm[61:39];
assign frac_round = ( sum_norm[38] && (sum_norm[37:0] != 38'b0)) ? (frac_round_before + 1) : frac_round_before;
assign out_temp[30:23] = (( frac_round_before == 23'h7fffff ) && (frac_round == 23'h0)) ? (exp_mid + 1) : exp_mid;
assign out_temp[22:0]  = frac_round;

assign out = ( data[30:23] == 8'hff ) ? ((data[22:0] == 23'b0) ? {data[31], 31'b0} : {data[31], 31'h7fffffff}): 
              ( ((data[30:21] == 10'b0) || (data[30:0] == 31'h200000)) ? {data[31], 31'h7f800000} : out_temp);

// shifter_left_64_6 shifter_left_64_6_rec(
// .data(sum), 
// .shift(shift_number),
// .o(sum_norm_mid)
// );

endmodule