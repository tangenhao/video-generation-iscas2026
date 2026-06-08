module sincos_norm(
  sum, data_initial_sincos, neg_quadrant, opcode, in_fraction_zero_sign, quad, lzd_o, 
  out
);

localparam SIN      = 6'b001000;
localparam COS      = 6'b001001;

input       [63:0] sum;
input       [31:0] data_initial_sincos;
input              neg_quadrant;
input       [5:0]  opcode;
input              in_fraction_zero_sign;
input       [1:0]  quad;
input       [5:0]  lzd_o;
output wire [31:0] out;

wire [31:0]  out_temp;
wire [31:0]  out_temp_temp;
wire [5:0]   shift_number;
wire [63:0]  sum_norm;
wire [22:0]  frac_round_before;
wire [22:0]  frac_round;
wire [7:0]   exp_mid;
wire norm_sign;
wire [31:0]  one_out;

assign norm_sign = (opcode == SIN) ? data_initial_sincos[31] : 1'b0;
assign out_temp_temp[31] = neg_quadrant ^ norm_sign;
assign shift_number = lzd_o - 1;

assign sum_norm = sum << shift_number;

assign exp_mid = 127 - shift_number;
assign frac_round_before = sum_norm[61:39];
assign frac_round = ( sum_norm[38] && (sum_norm[37:0] != 38'b0)) ? (frac_round_before + 1) : frac_round_before;
assign out_temp_temp[30:23] = (( frac_round_before == 23'h7fffff ) && (frac_round == 23'h0)) ? (exp_mid + 1) : exp_mid;
assign out_temp_temp[22:0]  = frac_round;
assign out_temp = (sum == 64'b0) ?  64'b0 : out_temp_temp;
assign one_out = quad[1] ? (norm_sign ? 32'h3f800000 :32'hbf800000) : (norm_sign ? 32'hbf800000 :32'h3f800000 );
assign out = ( data_initial_sincos[30:23] == 8'hff ) ? ( ((data_initial_sincos[22:0] == 23'b0) || data_initial_sincos[31]) ? 32'hffffffff :  32'h7fffffff ) :
              (in_fraction_zero_sign ? ( (quad[0]) ? one_out: 32'b0 ) : out_temp);

// shifter_left_64_6 shifter_left_64_6_sincos(
// .data(sum), 
// .shift(shift_number),
// .o(sum_norm)
// );
endmodule

