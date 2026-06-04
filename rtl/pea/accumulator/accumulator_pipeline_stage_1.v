module accumulator_pipeline_stage_1(
  clk, rst_n,
  mode,
  a, b,
  o
);

input        clk;
input        rst_n;
input        mode;
input [31:0] a;
input [31:0] b;

output wire [31:0] o;

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

wire subnormal;
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
reg [31:0] a_reg;
reg [31:0] b_reg;
reg [1:0] exp_cmp_reg;
reg [1:0] cmp_reg;
reg [1:0] frac_cmp_reg;

assign a_unnorm = (~(|a[30:23])) & (|a[22:0]);
assign a_sign = a[31];
assign a_exp = a_unnorm ? 1 : a[30:23];
assign a_frac = a_unnorm ? a[22:0] : {1'b1, a[22:0]};

assign b_unnorm = (~(|b[30:23])) & (|b[22:0]);
assign b_sign = b[31];
assign b_exp = b_unnorm ? 1'b1 : b[30:23];
assign b_frac = b_unnorm ? b[22:0] : {1'b1, b[22:0]};

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
assign frac_larger_align = mode ? minus_flag ? {1'b1, ~frac_larger} + 1 : frac_larger : a;
assign frac_smaller_align = mode ? frac_smaller_temp : b;

assign cal_sign = cmp ? a_sign : b_sign;
assign cal_exp = exp_larger;
// assign cal_frac_temp = frac_larger_align + frac_smaller_align;
assign cal_frac = minus_flag ? (~cal_frac_temp) + 1 : cal_frac_temp;

assign lzd_o = lzd_o_temp;
assign shift_number = cal_exp_reg <= lzd_o ? cal_exp_reg - 1 : lzd_o - 1;
assign norm_exp = (~(|lzd_o)) ? cal_exp_reg + 1 : lzd_o == 1 ? cal_exp_reg : cal_exp_reg - shift_number;
assign norm_frac = (~(|lzd_o)) ? cal_frac_reg[47:1] : lzd_o == 1 ? cal_frac_reg[46:0] : cal_frac_reg << shift_number;

assign carry = (norm_frac[22:0] > 'h40_0000) | ((norm_frac[22:0] == 'h40_0000) && (norm_frac[23]));
assign round_frac = carry ? norm_frac[46:23] + 1 : norm_frac[46:23];

assign final_exp = (round_frac[24]) ? norm_exp + 1 : norm_exp;
assign final_frac = (round_frac[24]) ? round_frac[24:1] : round_frac[23:0];

wire zero;
wire inf;
wire a_bypass;
wire b_bypass;

assign a_zero = (~(|a_reg[30:23])) & (~(|a_reg[22:0]));
assign a_inf = (&a_reg[30:23]) & (~(|a_reg[22:0]));
assign a_nan = (&a_reg[30:23]) & (|a_reg[22:0]);

assign b_zero = (~(|b_reg[30:23])) & (~(|b_reg[22:0]));
assign b_inf = (&b_reg[30:23]) & (~(|b_reg[22:0]));
assign b_nan = (&b_reg[30:23]) & (~(|b_reg[22:0]));

assign inf = norm_exp == 'hff | (a_inf & !b_nan) | (b_inf & !a_nan);
assign zero = ((a_reg[31] ^ b_reg[31]) & (&exp_cmp_reg) & (&frac_cmp_reg)) | (a_zero & b_zero);
assign subnormal =  (norm_exp == 1) & !final_frac[23];
assign a_bypass = b_zero & !a_zero;
assign b_bypass = a_zero & !b_zero;

assign o_sign = ((a_reg[31] ^ b_reg[31]) & (&exp_cmp_reg) & (&frac_cmp_reg)) ? 0 :
                a_bypass ? a_reg[31] :
                b_bypass ? b_reg[31] :
                cal_sign_reg;

assign o_exp = a_bypass ? a_reg[30:23] :
               b_bypass ? b_reg[30:23] :
               zero | subnormal ? 0 :
               inf ? 'hff :
               final_exp;
assign o_frac = a_bypass ? a_reg[22:0] :
                b_bypass ? b_reg[22:0] :
                zero | inf ? 0 :
                final_frac[22:0];

assign o = mode ? {o_sign, o_exp, o_frac} : cal_frac_temp[31:0];

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

shifter_adder_frac u_shifter_adder_frac(
  .data(frac_smaller),
  .shift(exp_diff),
  .o(frac_smaller_temp[46:0])
);

assign frac_smaller_temp[47] = 1'b0;

adder_48bit u_adder(
  .a(frac_larger_align),
  .b(frac_smaller_align),
  .o(cal_frac_temp)
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cal_sign_reg <= 'd0;
    cal_exp_reg  <= 'd0;
    cal_frac_reg <= 'd0;
    a_reg        <= 'd0;
    b_reg        <= 'd0;
    exp_cmp_reg  <= 'd0;
    cmp_reg      <= 'd0;
    frac_cmp_reg <= 'd0;
  end
  else begin
    cal_sign_reg <= cal_sign;
    cal_exp_reg  <= cal_exp;
    cal_frac_reg <= cal_frac;
    a_reg        <= a;
    b_reg        <= b;
    exp_cmp_reg  <= exp_cmp;
    cmp_reg      <= cmp;
    frac_cmp_reg <= frac_cmp;
  end
end

endmodule