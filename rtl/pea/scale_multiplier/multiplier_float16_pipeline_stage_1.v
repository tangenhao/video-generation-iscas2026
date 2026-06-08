module multiplier_float16_pipeline_stage_1(
  clk, rst_n,
  a, b,
  o
);

input clk;
input rst_n;

input [15:0] a;
input [15:0] b;
output [15:0] o;

wire a_sign;
wire [4:0] a_exp;
wire [10:0] a_frac;

wire b_sign;
wire [4:0] b_exp;
wire [10:0] b_frac;

wire a_unnorm;
wire a_zero;
wire a_inf;
wire a_nan;

wire b_unnorm;
wire b_zero;
wire b_inf;
wire b_nan;

wire cal_sign;
wire signed [6:0] cal_exp;
wire [21:0] cal_frac;

wire [4:0] lzd_o_temp;
wire [4:0] lzd_o;
wire [4:0] shift_number;
wire [5:0] norm_exp;
wire [31:0] norm_frac;
wire signed [6:0] exp_shift;
wire [31:0] frac_shift;
wire [21:0] frac_shift_temp;
wire [31:0] frac_right_shift;
wire [11:0] retrain_frac;
wire [20:0] trunction_frac;

wire carry;
wire [11:0] round_frac;

wire [4:0] final_exp;
wire [10:0] final_frac;

wire o_sign;
wire [4:0] o_exp;
wire [9:0] o_frac;

reg cal_sign_reg;
reg signed [6:0] cal_exp_reg;
reg [21:0] cal_frac_reg;
reg [4:0] shift_number_reg;
reg a_nan_reg;
reg a_inf_reg;
reg a_zero_reg;
reg b_nan_reg;
reg b_inf_reg;
reg b_zero_reg;

assign a_unnorm = (~(|a[14:10])) & (|a[9:0]);
assign a_sign = a[15];
assign a_exp = a_unnorm ? 1 : a[14:10];
assign a_frac = a_unnorm ? a[9:0] : {1'b1, a[9:0]};

assign b_unnorm = (~(|b[14:10])) & (|b[9:0]);
assign b_sign = b[15];
assign b_exp = b_unnorm ? 1 : b[14:10];
assign b_frac = b_unnorm ? b[9:0] : {1'b1, b[9:0]};

assign a_zero = (~(|a[14:10])) & (~(|a[9:0]));
assign a_inf = (&a[14:10]) & (~(|a[9:0]));
assign a_nan = (&a[14:10]) & (|a[9:0]);

assign b_zero = (~(|b[14:10])) & (~(|b[9:0]));
assign b_inf = (&b[14:10]) & (~(|b[9:0]));
assign b_nan = (&b[14:10]) & (~(|b[9:0]));

assign cal_sign = a_sign ^ b_sign;
assign cal_exp = a_exp + b_exp - 15;
assign cal_frac = a_frac * b_frac;

assign lzd_o = lzd_o_temp;
assign shift_number = ((lzd_o < 2) || (lzd_o > 11)) ? 0 : lzd_o - 1;

assign exp_shift = cal_exp_reg - shift_number_reg;
assign frac_shift = {frac_shift_temp, 10'd0};

assign norm_exp = exp_shift <= 0 ? 0 : frac_shift[31] ? exp_shift + 1 : exp_shift;
assign norm_frac = exp_shift <= 0 ? frac_right_shift : frac_shift;

assign retrain_frac = exp_shift <= 0 ? {1'b0, norm_frac[31:21]} :
                      frac_shift[31] == 1 ? {1'b0, norm_frac[31:21]} :
                      norm_frac[31:20];
assign trunction_frac = exp_shift <= 0 ? norm_frac[20:0] :
                        frac_shift[31] == 1 ? norm_frac[20:0] :
                        {norm_frac[19:0], 1'b0};

assign carry = ((trunction_frac[20] & (|trunction_frac[19:0]))) | ((trunction_frac[20] & (~(|trunction_frac[19:0]))) & (retrain_frac[0]));
assign round_frac = carry ? retrain_frac + 1 : retrain_frac;

assign final_exp = (round_frac[11] & (|norm_exp)) | ((~(|norm_exp)) & round_frac[10]) ? norm_exp + 1 : norm_exp;
assign final_frac = (round_frac[11]) ? round_frac[11:1] : round_frac[10:0];

wire zero;
wire inf;
wire nan;

assign inf = ((final_exp >= 'h1f) & !nan) || ((a_inf_reg & !b_nan_reg) || (b_inf_reg & !a_nan_reg));
assign nan = a_nan_reg | b_nan_reg | (a_zero_reg & b_inf_reg) | (b_zero_reg & a_inf_reg);
assign zero = (a_zero_reg & !b_inf_reg) | (b_zero_reg & !a_inf_reg) ;

assign o_sign = cal_sign_reg;

assign o_exp = zero ? 0 :
               inf | nan ? 'h1f :
               final_exp;
assign o_frac = nan ? 'h3ff :
                zero | inf ? 0 :
                final_frac[9:0];

assign o = {o_sign, o_exp, o_frac};

// lzd #(.W(32), .N(5)) u_lzd(
//   .data({10'd0, cal_frac}),
//   .zcnt(lzd_o_temp),
//   .full()
// );

lzd32 u_lzd32(
  .data ( {cal_frac, 10'b0} ),
  .zcnt ( lzd_o_temp        ),
  .full (                   )
);

wire [4:0] right_shift_number;
assign right_shift_number = (~exp_shift[4:0]+1);

shifter_right_32_5 u_shifter_right_32_5(
  .data(frac_shift),
  .shift(right_shift_number),
  .o(frac_right_shift)
);

shifter_left_22_5 u_shifter_left_22_5(
  .data(cal_frac_reg),
  .shift(shift_number_reg),
  .o(frac_shift_temp)
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cal_sign_reg     <= 'd0;
    cal_exp_reg      <= 'd0;
    cal_frac_reg     <= 'd0;
    shift_number_reg <= 'd0;
    a_nan_reg        <= 'd0;
    a_inf_reg        <= 'd0;
    a_zero_reg       <= 'd0;
    b_nan_reg        <= 'd0;
    b_inf_reg        <= 'd0;
    b_zero_reg       <= 'd0;
  end
  else begin
    cal_sign_reg     <= cal_sign;
    cal_exp_reg      <= cal_exp;
    cal_frac_reg     <= cal_frac;
    shift_number_reg <= shift_number;
    a_nan_reg        <= a_nan;
    a_inf_reg        <= a_inf;
    a_zero_reg       <= a_zero;
    b_nan_reg        <= b_nan;
    b_inf_reg        <= b_inf;
    b_zero_reg       <= b_zero;
  end
end

endmodule