module multiplier_float32_pipeline_stage_1(
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
output wire done;

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

wire cal_sign;
wire signed [9:0] cal_exp;
wire [47:0] cal_frac;

wire [5:0] lzd_o_temp;
wire [5:0] lzd_o;
wire [5:0] shift_number;
wire [8:0] norm_exp;
wire [70:0] norm_frac;
wire signed [9:0] exp_shift;
wire [70:0] frac_shift;
wire [47:0] frac_shift_temp;
wire [70:0] frac_right_shift;
wire [24:0] retrain_frac;
wire [46:0] trunction_frac;

wire carry;
wire [24:0] round_frac;

wire [7:0] final_exp;
wire [23:0] final_frac;

wire o_sign;
wire [7:0] o_exp;
wire [22:0] o_frac;

reg cal_sign_reg;
reg signed [9:0] cal_exp_reg;
reg [47:0] cal_frac_reg;
reg a_sign_reg;
reg a_inf_reg;
reg a_nan_reg;
reg a_zero_reg;
reg b_sign_reg;
reg b_inf_reg;
reg b_nan_reg;
reg b_zero_reg;

reg done_reg;

assign a_unnorm = (~(|a[30:23])) & (|a[22:0]);
assign a_sign = a[31];
assign a_exp = a_unnorm ? 1 : a[30:23];
assign a_frac = a_unnorm ? a[22:0] : {1'b1, a[22:0]};
assign a_zero = (~(|a[30:23])) & (~(|a[22:0]));
assign a_inf = (&a[30:23]) & (~(|a[22:0]));
assign a_nan = (&a[30:23]) & (|a[22:0]);

assign b_unnorm = (~(|b[30:23])) & (|b[22:0]);
assign b_sign = b[31];
assign b_exp = b_unnorm ? 1 : b[30:23];
assign b_frac = b_unnorm ? b[22:0] : {1'b1, b[22:0]};
assign b_zero = (~(|b[30:23])) & (~(|b[22:0]));
assign b_inf = (&b[30:23]) & (~(|b[22:0]));
assign b_nan = (&b[30:23]) & (|b[22:0]);

assign cal_sign = a_sign ^ b_sign;
assign cal_exp = a_exp + b_exp - 127;
assign cal_frac = a_frac * b_frac;

assign lzd_o = lzd_o_temp;
assign shift_number = ((lzd_o < 2) || (lzd_o > 24)) ? 0 : lzd_o - 1;

assign exp_shift = cal_exp_reg - shift_number;
assign frac_shift = {frac_shift_temp, 23'd0};

assign norm_exp = exp_shift <= 0 ? 0 : frac_shift[70] ? exp_shift + 1 : exp_shift;
assign norm_frac = exp_shift <= 0 ? frac_right_shift : frac_shift;

assign retrain_frac = exp_shift <= 0 ? {1'b0, norm_frac[70:47]} :
                      frac_shift[70] == 1 ? {1'b0, norm_frac[70:47]} :
                      norm_frac[70:46];
assign trunction_frac = exp_shift <= 0 ? norm_frac[46:0] :
                        frac_shift[70] == 1 ? norm_frac[46:0] :
                        {norm_frac[45:0], 1'b0};

assign carry = ((trunction_frac[46] & (|trunction_frac[45:0]))) | ((trunction_frac[46] & (~(|trunction_frac[45:0]))) & (retrain_frac[0]));
assign round_frac = carry ? retrain_frac + 1 : retrain_frac;

assign final_exp = ((round_frac[24]) & (|norm_exp)) | ((~(|norm_exp)) & round_frac[23]) ? norm_exp + 1 : norm_exp;
assign final_frac = (round_frac[24]) ? round_frac[24:1] : round_frac[23:0];

wire zero;
wire inf;
wire nan;

assign inf = ((final_exp >= 'hff) & !nan) || ((a_inf_reg & !b_nan_reg) || (b_inf_reg & !a_nan_reg));
assign nan = a_nan_reg | b_nan_reg | (a_zero_reg & b_inf_reg) | (b_zero_reg & a_inf_reg);
assign zero = (a_zero_reg & !b_inf_reg) | (b_zero_reg & !a_inf_reg) ;

assign o_sign = cal_sign_reg;

assign o_exp = zero ? 0 :
               inf | nan ? 'hff :
               final_exp;
assign o_frac = nan ? 'hfffffff :
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

wire [7:0] right_shift_number;
assign right_shift_number = (~exp_shift[7:0]+1);

shifter_right_71_8 u_shifter_right_71_8(
  .data(frac_shift),
  .shift(right_shift_number),
  .o(frac_right_shift)
);

shifter_left_48_6 u_shifter_left_48_6(
  .data(cal_frac_reg),
  .shift(shift_number),
  .o(frac_shift_temp)
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cal_sign_reg <= 'd0;
    cal_exp_reg  <= 'd0;
    cal_frac_reg <= 'd0;
    a_sign_reg   <= 'd0;
    a_zero_reg   <= 'd1;
    a_inf_reg    <= 'd0;
    a_nan_reg    <= 'd0;
    b_sign_reg   <= 'd0;
    b_zero_reg   <= 'd1;
    b_inf_reg    <= 'd0;
    b_nan_reg    <= 'd0;
    done_reg     <= 'd0;
  end
  else begin
    cal_sign_reg <= cal_sign;
    cal_exp_reg  <= cal_exp;
    cal_frac_reg <= cal_frac;
    a_sign_reg   <= a_sign;
    a_zero_reg   <= a_zero;
    a_inf_reg    <= a_inf;
    a_nan_reg    <= a_nan;
    b_sign_reg   <= b_sign;
    b_zero_reg   <= b_zero;
    b_inf_reg    <= b_inf;
    b_nan_reg    <= b_nan;
    done_reg     <= valid;
  end
end

endmodule