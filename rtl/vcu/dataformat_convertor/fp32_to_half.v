module fp32_to_half(
  in_data, 
  out_data
);

input       [31:0] in_data;
output wire [15:0] out_data;

wire        f_sign;
wire [7:0]  f_exp;
wire [22:0] f_frac;

wire        h_sign;
wire [4:0]  h_exp;
wire [9:0]  h_frac;

assign f_sign = in_data[31];
assign f_exp = in_data[30:23];
assign f_frac = in_data[22:0];

wire inf;
wire nan;
wire zero;
wire unnorm;

assign inf = (f_exp >= 8'h8f) || (&f_exp && (!(|f_frac)));
assign nan = (&f_exp && (|f_frac));
assign zero = ((!(|f_exp)) && (!(|f_frac))) || (f_exp < 8'h66);

assign unnorm = (f_exp <= 8'h70);

wire [7:0]  unnorm_shift;
wire [23:0] unnorm_frac;

assign unnorm_shift = 113 - f_exp;

shifter_24_8 shifter_24_8_inst(
  .data  ( {1'b1, f_frac} ),
  .shift ( unnorm_shift   ),
  .o     ( unnorm_frac    )
);

wire [4:0] norm_exp;
wire [27:0] bits_before_round;
wire [15:0] bits_rounded;

assign norm_exp = f_exp - 112;
assign bits_before_round = unnorm ? {5'b0, unnorm_frac[22:0]} : {norm_exp, f_frac};

wire carry;
assign carry = !(!bits_before_round[13] && bits_before_round[12] && (!(|bits_before_round[11:0])));

assign bits_rounded = (carry & (!unnorm)) | ((carry | (|f_frac[10:0])) & unnorm) ? bits_before_round[27:12] + 1 : bits_before_round[27:12];

assign h_sign = f_sign;
assign h_exp = inf ? 5'h1f : nan ? 5'h1f : zero ? 5'h00 : bits_rounded[15:11];
assign h_frac = nan ? 10'h3ff : inf ? 10'h0 : zero ? 10'h0 : bits_rounded[10:1];

assign out_data = {h_sign, h_exp, h_frac};

endmodule