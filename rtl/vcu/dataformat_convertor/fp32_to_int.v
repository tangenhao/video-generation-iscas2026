module fp32_to_int(
  in_data, 
  out_data
);

input       [31:0] in_data;
output wire [31:0] out_data;

wire        f_sign;
wire [7:0]  f_exp;
wire [22:0] f_frac;

assign f_sign = in_data[31];
assign f_exp  = in_data[30:23];
assign f_frac = in_data[22:0];

wire unnorm;
wire inf;
wire nan;
wire zero;

assign unnorm = (!(|f_exp)) && (!(|f_frac));
assign inf    = ((&f_exp) && (!(|f_frac))) || (f_exp >= 8'h9e);
assign nan    = (&f_exp) && (|f_frac);
assign zero   = (!(|f_exp)) && (!(|f_frac));

wire [54:0] f_frac_ext;
wire signed [8:0] f_exp_ext;
wire [54:0] shift_result;

assign f_frac_ext = {31'h0, !unnorm, f_frac};
assign f_exp_ext = f_exp - 127;

wire [30:0] true_form;

assign true_form = f_exp_ext[8] ? 'd0 : shift_result[53:23];

assign out_data = (nan | inf) ? 'h80000000 : (f_sign & (!zero) & (!f_exp_ext[8])) ? {1'b1, ~true_form[30:0] + 1'b1} : {1'b0, true_form[30:0]};

shifter_55_8 u_shifter(
  .data   ( f_frac_ext     ),
  .shift  ( f_exp_ext[7:0] ),
  .o      ( shift_result   )
);

endmodule