module fp32_to_bfloat(
  in_data, 
  out_data
);

input       [31:0] in_data;
output wire [15:0] out_data;

wire        f_sign;
wire [7:0]  f_exp;
wire [22:0] f_frac;

wire        h_sign;
wire [7:0]  h_exp;
wire [6:0]  h_frac;

assign f_sign = in_data[31];
assign f_exp = in_data[30:23];
assign f_frac = in_data[22:0];

wire inf;
wire nan;
wire zero;

assign inf = (&f_exp && (!(|f_frac)));
assign nan = (&f_exp && (|f_frac));
assign zero = ((!(|f_exp)) && (!(|f_frac)));

wire g;
wire r;
wire s;

assign g = f_frac[16];
assign r = f_frac[15];
assign s = |f_frac[14:0];

wire carry;
wire carry_p;

assign carry = r & (g | s);
assign carry_p = &f_frac[22:16];

assign h_sign = f_sign;
assign h_exp = (inf | nan) ? 8'hff : zero ? 8'h00 : (carry & carry_p) ? f_exp + 1 : f_exp;
assign h_frac = nan ? 7'h3f : inf ? 7'h00 : (zero | (carry & carry_p)) ? 7'h00 : carry ? f_frac[22:16] + 1 : f_frac[22:16];

assign out_data = {h_sign, h_exp, h_frac};

endmodule