module adder_float32_pipeline_stage_1(
  clk, rst_n, valid, 
  a, b,
  o, done
);

input              clk;
input              rst_n;
input              valid;
input       [31:0] a;
input       [31:0] b;
output wire [31:0] o;
output wire        done;

wire a_sign;
wire [7:0] a_exp;
wire [23:0] a_frac;

wire b_sign;
wire [7:0] b_exp;
wire [23:0] b_frac;

wire a_unnorm;
wire a_zero;
wire a_inf;
wire a_nan;

wire b_unnorm;
wire b_zero;
wire b_inf;
wire b_nan;

wire [1:0] exp_cmp;
wire [1:0] frac_cmp;
wire cmp;
wire [7:0] exp_larger;
wire [46:0] frac_larger;
wire [7:0] exp_smaller;
wire [46:0] frac_smaller;
wire [7:0] exp_diff;

wire minus_flag;
wire [47:0] frac_larger_align;
wire [47:0] frac_smaller_align;
wire [47:0] frac_smaller_temp;

wire cal_sign;
wire [8:0] cal_exp;
wire [47:0] cal_frac_temp;
wire [47:0] cal_frac;

wire [5:0] lzd_o_temp;
wire [5:0] lzd_o;
wire [5:0] shift_number;
wire [8:0] norm_exp;
wire [46:0] norm_frac;
wire [47:0] frac_left_shift;

wire carry;
wire [24:0] round_frac;

wire [7:0] final_exp;
wire [23:0] final_frac;

wire o_sign;
wire [7:0] o_exp;
wire [22:0] o_frac;

reg cal_sign_reg;
reg [8:0] cal_exp_reg;
reg [47:0] cal_frac_reg;
reg a_sign_reg;
reg a_inf_reg;
reg a_nan_reg;
reg a_zero_reg;
reg b_sign_reg;
reg b_inf_reg;
reg b_nan_reg;
reg b_zero_reg;
reg minus_flag_reg;
reg [1:0] exp_cmp_reg;
reg [1:0] cmp_reg;
reg [1:0] frac_cmp_reg;


reg done_reg;

assign a_unnorm = (~(|a[30:23])) & (|a[22:0]);
assign a_sign = a[31];
assign a_exp = a_unnorm ? 1 : a[30:23];
assign a_frac = a_unnorm | a_zero  ? a[22:0] : {1'b1, a[22:0]};
assign a_zero = (~(|a[30:23])) & (~(|a[22:0]));
assign a_inf = (&a[30:23]) & (~(|a[22:0]));
assign a_nan = (&a[30:23]) & (|a[22:0]);

assign b_unnorm = (~(|b[30:23])) & (|b[22:0]);
assign b_sign = b[31];
assign b_exp = b_unnorm ? 1'b1 : b[30:23];
assign b_frac = b_unnorm | b_zero ? b[22:0] : {1'b1, b[22:0]};
assign b_zero = (~(|b[30:23])) & (~(|b[22:0]));
assign b_inf = (&b[30:23]) & (~(|b[22:0]));
assign b_nan = (&b[30:23]) & (|b[22:0]);

assign exp_cmp = a_exp == b_exp ? 'b11 :
                 a_exp > b_exp ? 'b01 :
                 'b00;
assign frac_cmp = a_frac == b_frac ? 'b11 :
                  a_frac > b_frac ? 'b01 :
                  'b00;
assign cmp = (exp_cmp[0] & !exp_cmp[1]) | (exp_cmp[1] & frac_cmp[0]);
assign exp_larger = exp_cmp[0] ? a_exp : b_exp;
assign exp_smaller = exp_cmp[0] ? b_exp : a_exp;
assign exp_diff = exp_larger - exp_smaller;
assign frac_larger = cmp ? {a_frac, 23'b0} : {b_frac, 23'b0};
assign frac_smaller = cmp ? {b_frac, 23'b0} : {a_frac, 23'b0};

assign minus_flag = a_sign ^ b_sign;
assign frac_larger_align = minus_flag ? {1'b1, ~frac_larger} + 1 : frac_larger;
assign frac_smaller_align = frac_smaller_temp;

assign cal_sign = cmp ? a_sign : b_sign;
assign cal_exp = exp_larger;
assign cal_frac = minus_flag ? (~cal_frac_temp) + 1 : cal_frac_temp;

assign lzd_o = lzd_o_temp;
assign shift_number = cal_exp_reg <= lzd_o ? cal_exp_reg - 1 : lzd_o - 1;
assign norm_exp = (~(|lzd_o)) ? cal_exp_reg + 1 : lzd_o == 1 ? cal_exp_reg : cal_exp_reg - shift_number;
assign norm_frac = (~(|lzd_o)) ? cal_frac_reg[47:1] : lzd_o == 1 ? cal_frac_reg[46:0] : frac_left_shift;

assign carry = (norm_frac[22:0] > 'h40_0000) | ((norm_frac[22:0] == 'h40_0000) && (norm_frac[23]));
assign round_frac = carry ? norm_frac[46:23] + 1 : norm_frac[46:23];

assign final_exp = ((round_frac[24]) & (|norm_exp)) | ((~(|norm_exp)) & round_frac[23]) ? norm_exp + 1 : norm_exp;
assign final_frac = (round_frac[24]) ? round_frac[24:1] : round_frac[23:0];

wire zero;
wire inf;
wire nan;
wire subnormal;

assign inf = ((final_exp >= 'hff) & !nan) || ((a_inf_reg & !b_nan_reg) || (b_inf_reg & !a_nan_reg));
assign nan = a_nan_reg | b_nan_reg | (a_inf_reg & b_inf_reg & minus_flag_reg);
assign zero = (minus_flag_reg & (&exp_cmp_reg) & (&frac_cmp_reg)) | (a_zero_reg & b_zero_reg);
assign subnormal =  (final_exp == 1) & !final_frac[23];

assign o_sign = (inf & a_inf_reg & a_sign_reg) | (inf & b_inf_reg & b_sign_reg) | (!inf & !zero & cal_sign_reg);

assign o_exp = nan | inf ? 'hff :
               zero | subnormal ? 0 :
               final_exp;
assign o_frac = nan ? 'h7fffff :
                zero | inf ? 0 :
                final_frac[22:0];

assign o = {o_sign, o_exp, o_frac};
assign done = done_reg;

// lzd #(.W(64), .N(6)) u_lzd(
//   .data({16'd0, cal_frac_reg}),
//   .zcnt(lzd_o_temp),
//   .full()
// );

lzd64 u_lzd64(
  .data ( {cal_frac_reg, 16'd0} ),
  .zcnt ( lzd_o_temp            ),
  .full (                       )
);

shifter_right_47_8 u_shift_right_47_8(
  .data(frac_smaller),
  .shift(exp_diff),
  .o(frac_smaller_temp[46:0])
);

shifter_left_48_6 u_shifter_left_48_6(
  .data(cal_frac_reg),
  .shift(shift_number),
  .o(frac_left_shift)
);

assign frac_smaller_temp[47] = 1'b0;

adder_48bit u_adder(
  .a(frac_larger_align),
  .b(frac_smaller_align),
  .o(cal_frac_temp)
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cal_sign_reg   <= 'd0;
    cal_exp_reg    <= 'd0;
    cal_frac_reg   <= 'd0;
    a_sign_reg     <= 'd0;
    a_zero_reg     <= 'd1;
    a_inf_reg      <= 'd0;
    a_nan_reg      <= 'd0;
    b_sign_reg     <= 'd0;
    b_zero_reg     <= 'd1;
    b_inf_reg      <= 'd0;
    b_nan_reg      <= 'd0;
    minus_flag_reg <= 'd0;
    exp_cmp_reg    <= 'd0;
    cmp_reg        <= 'd0;
    frac_cmp_reg   <= 'd0;
    done_reg       <= 'd0;
  end
  else begin
    cal_sign_reg   <= cal_sign;
    cal_exp_reg    <= cal_exp;
    cal_frac_reg   <= cal_frac;
    a_sign_reg     <= a_sign;
    a_zero_reg     <= a_zero;
    a_inf_reg      <= a_inf;
    a_nan_reg      <= a_nan;
    b_sign_reg     <= b_sign;
    b_zero_reg     <= b_zero;
    b_inf_reg      <= b_inf;
    b_nan_reg      <= b_nan;
    minus_flag_reg <= minus_flag;
    exp_cmp_reg    <= exp_cmp;
    cmp_reg        <= cmp;
    frac_cmp_reg   <= frac_cmp;
    done_reg       <= valid;
  end
end



endmodule