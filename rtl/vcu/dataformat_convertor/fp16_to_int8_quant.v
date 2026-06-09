module fp16_to_int8_quant(
  in_data,
  out_data
);

input       [15:0] in_data;
output wire [7:0]  out_data;

wire        f_sign;
wire [4:0]  f_exp;
wire [9:0]  f_frac;

assign f_sign = in_data[15];
assign f_exp  = in_data[14:10];
assign f_frac = in_data[9:0];

wire zero;
wire nan;
wire normal;

assign zero   = (!(|f_exp)) && (!(|f_frac));
assign nan    = (&f_exp) && (|f_frac);
assign normal = |f_exp;

wire [10:0] significand;
assign significand = {1'b1, f_frac};

wire signed [9:0] f_exp_ext;
assign f_exp_ext = {5'b0, f_exp} - 10'd15;

wire in_round_range;
wire overflow_range;

assign in_round_range = normal && (f_exp_ext >= -10'sd1) && (f_exp_ext <= 10'sd6);
assign overflow_range = normal && (f_exp_ext >= 10'sd7);

wire signed [9:0] right_shift_ext;
wire [4:0]        right_shift;
wire [11:0]       significand_ext;
wire [8:0]        int_part;
wire [11:0]       frac_mask;
wire [11:0]       frac_part;
wire [11:0]       half_part;
wire              round_inc;
wire [8:0]        rounded_mag;

assign right_shift_ext = 10'sd10 - f_exp_ext;
assign right_shift     = right_shift_ext[4:0];
assign significand_ext = {1'b0, significand};
assign int_part        = significand_ext >> right_shift;
assign frac_mask       = (12'd1 << right_shift) - 1'b1;
assign frac_part       = significand_ext & frac_mask;
assign half_part       = 12'd1 << (right_shift - 1'b1);
// Round to nearest, ties to even.
assign round_inc       = (frac_part > half_part) || ((frac_part == half_part) && int_part[0]);
assign rounded_mag     = int_part + round_inc;

wire [8:0] magnitude_pre_clamp;
wire [8:0] magnitude_clamped;

assign magnitude_pre_clamp = (nan || zero)      ? 9'd0 :
                              overflow_range    ? (f_sign ? 9'd128 : 9'd127) :
                              in_round_range    ? rounded_mag :
                                                  9'd0;

assign magnitude_clamped = f_sign ? ((magnitude_pre_clamp > 9'd128) ? 9'd128 : magnitude_pre_clamp) :
                                    ((magnitude_pre_clamp > 9'd127) ? 9'd127 : magnitude_pre_clamp);

assign out_data = f_sign ? (~magnitude_clamped[7:0] + 1'b1) : magnitude_clamped[7:0];

endmodule