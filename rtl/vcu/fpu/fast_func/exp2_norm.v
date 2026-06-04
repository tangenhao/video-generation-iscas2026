module exp2_norm(
  sum, data, norm_exp, lzd_o, 
  out
);

input       [63:0] sum;
input       [31:0] data;
input       [8:0]  norm_exp;
input       [5:0]  lzd_o;
output wire [31:0] out;

wire [31:0]  out_temp;
wire [31:0]  out_temp_temp;
wire [22:0]  frac_round_before;
wire [22:0]  frac_round;
wire [5:0]   shift_number;
wire [63:0]  sum_norm_mid;
wire [63:0]  sum_norm;
wire [7:0]   exp_mid;
wire [7:0]   norm_exp_neg_abs;

wire [22:0]  frac_exp2_carry;

wire [7:0]   shifter_1;
wire [7:0]   shifter_2;

assign out_temp_temp[31] = 1'b0;
assign shift_number = lzd_o - 1;

assign sum_norm_mid =  sum << shift_number;

assign norm_exp_neg_abs = (~norm_exp[7:0]) +1 ;


// assign sum_norm =  norm_exp[8] ?  (sum_norm_mid >> (shift_number + 1 + norm_exp_neg_abs) ) :
//                   (( norm_exp < (shift_number + 1) ) ? (sum_norm_mid >> (shift_number + 1 - norm_exp)) : sum_norm_mid );
assign shifter_1 = {2'b0, lzd_o} + norm_exp_neg_abs;
assign shifter_2 = {2'b0, lzd_o} - norm_exp[7:0];
assign sum_norm =  norm_exp[8] ?  (sum_norm_mid >> shifter_1 ) :
                  (( norm_exp < {3'b0, lzd_o} ) ? (sum_norm_mid >> shifter_2 ) : sum_norm_mid );



assign exp_mid = (norm_exp[8] || ( norm_exp < (shift_number + 1) )) ?   8'b0 :  (norm_exp - shift_number);
assign frac_round_before = sum_norm[61:39];
// assign frac_round = ( sum_norm[38] && (sum_norm[37:0] != 38'b0)) ? (frac_round_before + 1) : frac_round_before;
assign frac_exp2_carry = frac_round_before + 1;
assign frac_round = ( sum_norm[38] && (|sum_norm[37:0])) ? frac_exp2_carry : frac_round_before;
// assign frac_round = ( sum_norm[38] && (sum_norm[37:0] != 38'b0)) ? frac_exp2_carry : frac_round_before;

assign out_temp_temp[30:23] = (( &frac_round_before) && (!(|frac_round))) ? (exp_mid + 1) : exp_mid;
// assign out_temp_temp[30:23] = (( frac_round_before == 23'h7fffff ) && (frac_round == 23'h0)) ? (exp_mid + 1) : exp_mid;
assign out_temp_temp[22:0]  = frac_round;

assign out_temp = ({32{&out_temp_temp[30:23]}} & 32'h7f800000) | ( {32{!(&out_temp_temp[30:23])}} & out_temp_temp);
// assign out_temp = (&out_temp_temp[30:23]) ? 32'h7f800000 : out_temp_temp;
// assign out_temp = (out_temp_temp[30:23] == 8'hff) ? 32'h7f800000 : out_temp_temp;

assign out = (&data[30:23]) ?  ( (data[22:0] == 23'b0) ? (data[31] ? 32'h0 : 32'h7f800000) : (data[31] ? 32'hffffffff : 32'h7fffffff)) : 
                                        ( ((data[30:23] > 8'h85) && (data[31] == 1'b0)) ? 32'h7f800000 : 
                                          (((data[30:23] > 8'h86) && (data[31] == 1'b1)) ? 32'h0 : ( (data[30:23] < 8'h67) ? 32'h3F800000 : out_temp ) ) );

// assign out = (data[30:23] == 8'hff) ?  ( (data[22:0] == 23'b0) ? (data[31] ? 32'h0 : 32'h7f800000) : (data[31] ? 32'hffffffff : 32'h7fffffff)) : 
//                                        ( ((data[30:23] > 8'h85) && (data[31] == 1'b0)) ? 32'h7f800000 : 
//                                          (((data[30:23] > 8'h86) && (data[31] == 1'b1)) ? 32'h0 : ( (data[30:23] < 8'h67) ? 32'h3F800000 : out_temp ) ) );

// wire out_condition_0;
// wire out_condition_1;
// wire out_condition_2;
// wire out_condition_3;
// wire out_condition_4;

// wire out_type_1;
// wire out_type_2;
// wire out_type_3;
// wire out_type_4;
// wire out_type_7;
// wire out_type_8;

// assign out_condition_0 = ( data[30:23] == 8'hff );
// assign out_condition_1 = (data[22:0] == 23'b0);
// assign out_condition_2 = ((data[30:23] > 8'h85) & (data[31] == 1'b0));
// assign out_condition_3 = ((data[30:23] > 8'h86) & (data[31] == 1'b1)) ;
// assign out_condition_4 = (data[30:23] < 8'h67) ;

// assign out_type_1 = (out_condition_0 & out_condition_1 & data[31])  |  ((~out_condition_0) &  (~out_condition_2) & out_condition_3 );
// assign out_type_2 = (out_condition_0 & out_condition_1 & (~ data[31])) | ( (~out_condition_0) &  out_condition_2 );
// assign out_type_3 = out_condition_0 & (~out_condition_1) & data[31];
// assign out_type_4 = out_condition_0 & (~out_condition_1) & (~ data[31]);

// assign out_type_7 = (~out_condition_0) &  (~out_condition_2) & (~out_condition_3) & out_condition_4;
// assign out_type_8 = (~out_condition_0) &  (~out_condition_2) & (~out_condition_3) & (~out_condition_4);


// assign out = ({ 32{out_type_1}} & 32'h0) | ({ 32{out_type_2}} & 32'h7f800000) | ({32{out_type_3}}  & 32'hffffffff) | ({ 32{out_type_4}} & 32'h7fffffff) 
//               | ({32{out_type_7}} & 32'h3f800000) | ({32{out_type_8}} & out_temp) ; 


// shifter_left_64_6 shifter_left_64_6_exp2(
// .data(sum), 
// .shift(shift_number),
// .o(sum_norm_mid)
// );

endmodule