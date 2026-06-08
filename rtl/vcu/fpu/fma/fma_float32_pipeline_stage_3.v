module fma_float32_pipeline_stage_3(
  clk, rst_n, valid,
  a, b, c,
  o, done
);

input              clk;
input              rst_n;
input              valid;
input       [31:0] a;
input       [31:0] b;
input       [31:0] c;
output wire [31:0] o;
output wire        done;

wire a_sign;
wire [7:0] a_exp;
wire [23:0] a_frac;

wire b_sign;
wire [7:0] b_exp;
wire [23:0] b_frac;

wire c_sign;
wire [7:0] c_exp;
wire [23:0] c_frac;

wire a_unnorm;
wire a_zero;
wire a_inf;
wire a_nan;

wire b_unnorm;
wire b_zero;
wire b_inf;
wire b_nan;

wire c_unnorm;
wire c_zero;
wire c_inf;
wire c_nan;

wire mul_cal_sign;
wire signed [9:0] mul_cal_exp;
wire [47:0] mul_cal_frac;

wire [5:0] mul_lzd_temp;
wire [5:0] mul_lzd;
wire [5:0] mul_shift_number;
wire [8:0] mul_norm_exp;
wire [70:0] mul_norm_frac;
wire signed [9:0] mul_exp_shift;
wire [70:0] mul_frac_shift;
wire [47:0] mul_frac_shift_temp;
wire [70:0] mul_frac_right_shift;
wire [7:0] mul_right_shift_number;

wire mul_zero;
wire mul_nan;
wire mul_inf;
wire mul_cal_inf;
wire [7:0] mul_exp_new;
wire [70:0] mul_frac_new;

wire [1:0] add_exp_cmp;
wire [1:0] add_frac_cmp;
wire add_cmp;
wire [7:0] add_exp_larger;
wire [69:0] add_frac_larger;
wire [7:0] add_exp_smaller;
wire [69:0] add_frac_smaller;
wire [7:0] add_exp_diff;

wire add_minus_flag;
wire [70:0] add_frac_larger_align;
wire [70:0] add_frac_smaller_align;
wire [70:0] add_frac_smaller_temp;

wire add_cal_sign;
wire [8:0] add_cal_exp;
wire [70:0] add_cal_frac_temp;
wire [70:0] add_cal_frac;

wire [6:0] add_lzd_temp;
wire [6:0] add_lzd;
wire [6:0] add_shift_number;
wire signed [8:0] add_exp_shift;
wire [70:0] add_frac_shift;
wire [70:0] add_frac_shift_temp;
wire [70:0] add_frac_right_shift;
wire [7:0] add_right_shift_number;

wire [8:0] add_norm_exp;
wire [70:0] add_norm_frac;
wire [24:0] add_retrain_frac;
wire [46:0] add_truncation_frac;

wire add_carry;
wire [24:0] add_round_frac;

wire [8:0] final_exp;
wire [23:0] final_frac;

wire o_zero;
wire o_inf;
wire o_nan;
wire o_subnormal;

wire o_sign;
wire [7:0] o_exp;
wire [22:0] o_frac;

assign a_unnorm = (~(|a[30:23])) & (|a[22:0]);
assign a_zero = (~(|a[30:23])) & (~(|a[22:0]));
assign a_inf = (&a[30:23]) & (~(|a[22:0]));
assign a_nan = (&a[30:23]) & (|a[22:0]);
assign a_sign = a[31];
assign a_exp = a_unnorm ? 1 : a[30:23];
assign a_frac = a_unnorm | a_zero ? a[22:0] : {1'b1, a[22:0]};

assign b_unnorm = (~(|b[30:23])) & (|b[22:0]);
assign b_zero = (~(|b[30:23])) & (~(|b[22:0]));
assign b_inf = (&b[30:23]) & (~(|b[22:0]));
assign b_nan = (&b[30:23]) & (|b[22:0]);
assign b_sign = b[31];
assign b_exp = b_unnorm ? 1 : b[30:23];
assign b_frac = b_unnorm | b_zero ? b[22:0] : {1'b1, b[22:0]};

assign c_unnorm = (~(|c[30:23])) & (|c[22:0]);
assign c_sign = c[31];
assign c_zero = (~(|c[30:23])) & (~(|c[22:0]));
assign c_inf = (&c[30:23]) & (~(|c[22:0]));
assign c_nan = (&c[30:23]) & (|c[22:0]);
assign c_exp = c_unnorm ? 1 : c[30:23];
assign c_frac = c_unnorm | c_zero ? c[22:0] : {1'b1, c[22:0]};

assign mul_cal_sign = a_sign ^ b_sign;
assign mul_cal_exp = a_exp + b_exp - 127;
assign mul_cal_frac = a_frac * b_frac;

assign mul_lzd = mul_lzd_temp;
assign mul_shift_number = ((mul_lzd < 2) || (mul_lzd > 24)) ? 0 : mul_lzd - 1;

reg [6:0] mul_shift_number_stage_1;
reg [47:0] mul_cal_frac_stage_1;
reg signed [9:0] mul_cal_exp_stage_1;
reg a_nan_stage_1;
reg a_inf_stage_1;
reg a_zero_stage_1;
reg b_nan_stage_1;
reg b_inf_stage_1;
reg b_zero_stage_1;
reg c_sign_stage_1;
reg [7:0] c_exp_stage_1;
reg [23:0] c_frac_stage_1;
reg c_nan_stage_1;
reg c_inf_stage_1;
reg c_zero_stage_1;
reg mul_cal_sign_stage_1;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    mul_shift_number_stage_1 <= 7'b0;
    mul_cal_sign_stage_1     <= 1'b0;
    mul_cal_frac_stage_1     <= 48'b0;
    mul_cal_exp_stage_1      <= 10'b0;
    a_nan_stage_1            <= 1'b0;
    a_inf_stage_1            <= 1'b0;
    a_zero_stage_1           <= 1'b0;
    b_nan_stage_1            <= 1'b0;
    b_inf_stage_1            <= 1'b0;
    b_zero_stage_1           <= 1'b0;
    c_sign_stage_1           <= 1'b0;
    c_exp_stage_1            <= 8'b0;
    c_frac_stage_1           <= 24'b0;
    c_nan_stage_1            <= 1'b0;
    c_inf_stage_1            <= 1'b0;
    c_zero_stage_1           <= 1'b0;
  end
  else begin
    mul_shift_number_stage_1 <= mul_shift_number;
    mul_cal_sign_stage_1     <= mul_cal_sign;
    mul_cal_frac_stage_1     <= mul_cal_frac;
    mul_cal_exp_stage_1      <= mul_cal_exp;
    a_nan_stage_1            <= a_nan;
    a_inf_stage_1            <= a_inf;
    a_zero_stage_1           <= a_zero;
    b_nan_stage_1            <= b_nan;
    b_inf_stage_1            <= b_inf;
    b_zero_stage_1           <= b_zero;
    c_sign_stage_1           <= c_sign;
    c_exp_stage_1            <= c_exp;
    c_frac_stage_1           <= c_frac;
    c_nan_stage_1            <= c_nan;
    c_inf_stage_1            <= c_inf;
    c_zero_stage_1           <= c_zero;
  end
end

assign mul_exp_shift = mul_cal_exp_stage_1 - mul_shift_number_stage_1;
assign mul_frac_shift = {mul_frac_shift_temp, 23'd0};

assign mul_right_shift_number = (~mul_exp_shift[7:0] + 1);
assign mul_norm_exp = mul_exp_shift <= 0 ? 0 : mul_frac_shift[70] ? mul_exp_shift + 1 : mul_exp_shift;
assign mul_norm_frac = mul_exp_shift <= 0 ? mul_frac_right_shift : 
                       mul_frac_shift[70] ? {1'b0, mul_frac_shift[70:1]} : mul_frac_shift;

assign mul_cal_inf = ((mul_norm_exp > 'hff) & !mul_nan);
assign mul_inf = ((a_inf_stage_1 & !b_nan_stage_1) || (b_inf_stage_1 & !a_nan_stage_1));
assign mul_nan = a_nan_stage_1 | b_nan_stage_1 | (a_zero_stage_1 & b_inf_stage_1) | (b_zero_stage_1 & a_inf_stage_1);
assign mul_zero = (a_zero_stage_1 & !b_inf_stage_1) | (b_zero_stage_1 & !a_inf_stage_1) | (~(|mul_norm_exp) && ~(|mul_norm_frac));

assign mul_exp_new = ~(|mul_norm_exp) ? 1 : mul_norm_exp[7:0];
assign mul_frac_new = ~(|mul_norm_exp) ? {1'b0, mul_norm_frac[70:1]} : mul_norm_frac[70:0];

assign add_exp_cmp = mul_exp_new == c_exp_stage_1 ? 'b11 :
                     mul_exp_new > c_exp_stage_1 ? 'b01 :
                     'b00;
assign add_frac_cmp = (mul_frac_new[69:46] == c_frac_stage_1) && (~(|mul_frac_new[45:0])) ? 'b11 :
                      (mul_frac_new[69:46] > c_frac_stage_1) || ((mul_frac_new[69:46] == c_frac_stage_1) && (|mul_frac_new[45:0])) ? 'b01 :
                      'b00;
assign add_cmp = (add_exp_cmp[0] & !add_exp_cmp[1]) | (add_exp_cmp[1] & add_frac_cmp[0]);

assign add_exp_larger = add_exp_cmp[0] ? mul_exp_new : c_exp_stage_1;
assign add_exp_smaller = add_exp_cmp[0] ? c_exp_stage_1 : mul_exp_new;
assign add_exp_diff = add_exp_larger - add_exp_smaller;
assign add_frac_larger = add_cmp ? mul_frac_new[69:0] : {c_frac_stage_1, 46'b0};
assign add_frac_smaller = add_cmp ? {c_frac_stage_1, 46'b0} : mul_frac_new[69:0];

assign add_minus_flag = mul_cal_sign_stage_1 ^ c_sign_stage_1;
assign add_frac_larger_align = add_minus_flag ? {1'b1, ~add_frac_larger} + 1 : {1'b0, add_frac_larger};
assign add_frac_smaller_align = add_frac_smaller_temp;

assign add_cal_sign = add_cmp ? mul_cal_sign_stage_1 : c_sign_stage_1;
assign add_cal_exp = add_exp_larger;

reg        add_cal_sign_stage_2;
reg [70:0] add_frac_larger_align_stage_2;
reg [70:0] add_frac_smaller_align_stage_2;
reg        add_minus_flag_stage_2;
reg [8:0]  add_cal_exp_stage_2;
reg        c_sign_stage_2;
reg        c_nan_stage_2;
reg        c_inf_stage_2;
reg        c_zero_stage_2;
reg        mul_zero_stage_2;
reg        mul_inf_stage_2;
reg        mul_nan_stage_2;
reg        mul_cal_inf_stage_2;
reg        mul_cal_sign_stage_2;
reg [1:0]  add_exp_cmp_stage_2;
reg [1:0]  add_frac_cmp_stage_2;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    add_cal_sign_stage_2           <= 1'd0;
    add_frac_larger_align_stage_2  <= 71'd0;
    add_frac_smaller_align_stage_2 <= 71'd0;
    add_minus_flag_stage_2         <= 1'd0;
    add_cal_exp_stage_2            <= 9'd0;
    c_sign_stage_2                 <= 1'd0;
    c_nan_stage_2                  <= 1'd0;
    c_inf_stage_2                  <= 1'd0;
    c_zero_stage_2                 <= 1'd0;
    mul_zero_stage_2               <= 1'd0;
    mul_inf_stage_2                <= 1'd0;
    mul_nan_stage_2                <= 1'd0;
    mul_cal_inf_stage_2            <= 1'd0;
    mul_cal_sign_stage_2           <= 1'd0;
    add_exp_cmp_stage_2            <= 2'd0;
    add_frac_cmp_stage_2           <= 2'd0;
  end
  else begin
    add_cal_sign_stage_2           <= add_cal_sign;
    add_frac_larger_align_stage_2  <= add_frac_larger_align;
    add_frac_smaller_align_stage_2 <= add_frac_smaller_align;
    add_minus_flag_stage_2         <= add_minus_flag;
    add_cal_exp_stage_2            <= add_cal_exp;
    c_sign_stage_2                 <= c_sign_stage_1;
    c_nan_stage_2                  <= c_nan_stage_1;
    c_inf_stage_2                  <= c_inf_stage_1;
    c_zero_stage_2                 <= c_zero_stage_1;
    mul_zero_stage_2               <= mul_zero;
    mul_inf_stage_2                <= mul_inf;
    mul_nan_stage_2                <= mul_nan;
    mul_cal_inf_stage_2            <= mul_cal_inf;
    mul_cal_sign_stage_2           <= mul_cal_sign_stage_1;
    add_exp_cmp_stage_2            <= add_exp_cmp;
    add_frac_cmp_stage_2           <= add_frac_cmp;
  end
end


assign add_cal_frac = add_minus_flag_stage_2 ? (~add_cal_frac_temp) + 1 : add_cal_frac_temp;

assign add_lzd = add_lzd_temp == 0 ? 0 : add_lzd_temp;
assign add_shift_number = (add_lzd < 2) || (add_lzd > 47) ? 0 : add_lzd - 1;

reg        add_cal_sign_stage_3;
reg [70:0] add_cal_frac_stage_3;
reg [8:0]  add_cal_exp_stage_3;
reg [6:0]  add_shift_number_stage_3;
reg        c_sign_stage_3;
reg        c_nan_stage_3;
reg        c_inf_stage_3;
reg        c_zero_stage_3;
reg        mul_zero_stage_3;
reg        mul_inf_stage_3;
reg        mul_nan_stage_3;
reg        mul_cal_sign_stage_3;
reg        mul_cal_inf_stage_3;
reg [1:0]  add_exp_cmp_stage_3;
reg [1:0]  add_frac_cmp_stage_3;

reg done_reg;
reg done_reg_reg;
reg done_reg_reg_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    add_cal_sign_stage_3     <= 1'b0;
    add_cal_frac_stage_3     <= 71'd0;
    add_cal_exp_stage_3      <= 9'd0;
    add_shift_number_stage_3 <= 7'd0;
    c_sign_stage_3           <= 1'd0;
    c_nan_stage_3            <= 1'd0;
    c_inf_stage_3            <= 1'd0;
    c_zero_stage_3           <= 1'd0;
    mul_zero_stage_3         <= 1'd0;
    mul_inf_stage_3          <= 1'd0;
    mul_nan_stage_3          <= 1'd0;
    mul_cal_sign_stage_3     <= 1'd0;
    mul_cal_inf_stage_3      <= 1'd0;
    add_exp_cmp_stage_3      <= 2'd0;
    add_frac_cmp_stage_3     <= 2'd0;
  end
  else begin
    add_cal_sign_stage_3     <= add_cal_sign_stage_2;
    add_cal_frac_stage_3     <= add_cal_frac;
    add_cal_exp_stage_3      <= add_cal_exp_stage_2;
    add_shift_number_stage_3 <= add_shift_number;
    c_sign_stage_3           <= c_sign_stage_2;
    c_nan_stage_3            <= c_nan_stage_2;
    c_inf_stage_3            <= c_inf_stage_2;
    c_zero_stage_3           <= c_zero_stage_2;
    mul_zero_stage_3         <= mul_zero_stage_2;
    mul_inf_stage_3          <= mul_inf_stage_2;
    mul_nan_stage_3          <= mul_nan_stage_2;
    mul_cal_sign_stage_3     <= mul_cal_sign_stage_2;
    mul_cal_inf_stage_3      <= mul_cal_inf_stage_2;
    add_exp_cmp_stage_3      <= add_exp_cmp_stage_2;
    add_frac_cmp_stage_3     <= add_frac_cmp_stage_2;
  end
end

assign add_exp_shift = add_cal_exp_stage_3 - add_shift_number_stage_3;
assign add_frac_shift = add_frac_shift_temp;

assign add_right_shift_number = (~add_exp_shift[7:0]+1);
assign add_norm_exp = add_exp_shift <= 0 ? 0 : add_cal_frac_stage_3[70] ? add_exp_shift + 1 : add_exp_shift;
assign add_norm_frac = add_exp_shift <= 0 ? add_frac_right_shift : add_frac_shift;

assign add_retrain_frac = add_exp_shift <= 0 ? {1'b0, add_norm_frac[70:47]} :
                         add_frac_shift[70] == 1 ? {1'b0, add_norm_frac[70:47]} :
                         add_norm_frac[70:46];
assign add_truncation_frac = add_exp_shift <= 0 ? add_norm_frac[46:0] :
                            add_frac_shift[70] == 1 ? add_norm_frac[46:0] :
                            {add_norm_frac[45:0], 1'b0};

assign add_carry = ((add_truncation_frac[46] & (|add_truncation_frac[45:0]))) | ((add_truncation_frac[46] & (~(|add_truncation_frac[45:0]))) & (add_retrain_frac[0]));
assign add_round_frac = add_carry ? add_retrain_frac + 1 : add_retrain_frac;

assign final_exp = ((add_round_frac[24]) & (|add_norm_exp)) | ((~(|add_norm_exp)) & add_round_frac[23]) ? add_norm_exp + 1 : add_norm_exp;
assign final_frac = (add_round_frac[24]) ? add_round_frac[24:1] : add_round_frac[23:0];

assign o_inf = ((final_exp >= 'hff) & !o_nan) | ((mul_inf_stage_3 & !c_nan_stage_3) | (c_inf_stage_3 & !mul_nan_stage_3) | (mul_cal_inf_stage_3 & !c_nan_stage_3));
assign o_nan = mul_nan_stage_3 | c_nan_stage_3 | (mul_inf_stage_3 & c_inf_stage_3 & (mul_cal_sign_stage_3 ^ c_sign_stage_3));
assign o_zero = ((mul_cal_sign_stage_3 ^ c_sign_stage_3) & (&add_exp_cmp_stage_3) & (&add_frac_cmp_stage_3)) | (mul_zero_stage_3 & c_zero_stage_3);
assign o_subnormal =  (final_exp == 1) & !final_frac[23];

assign o_sign = (o_inf & c_inf_stage_3 & c_sign_stage_3) | (o_inf & (!c_inf_stage_3) & (mul_inf_stage_3 | mul_cal_inf_stage_3) & mul_cal_sign_stage_3) | (!c_inf_stage_3 & !(mul_inf_stage_3 | mul_cal_inf_stage_3) & add_cal_sign_stage_3);
assign o_exp = (o_inf | o_nan) ? 'hff : (o_zero | o_subnormal) ? 0 : final_exp[7:0];
assign o_frac = o_nan ? 'h7fffff : (o_zero | o_inf) ? 0 : final_frac;

assign o = {o_sign, o_exp, o_frac};
assign done = done_reg_reg_reg;
// lzd #(.W(64), .N(6)) u_lzd_mul(
//   .data({mul_cal_frac, 16'd0}),
//   .zcnt(mul_lzd_temp),
//   .full()
// );

lzd64 u_lzd_mul(
  .data ( {mul_cal_frac, 16'd0} ),
  .zcnt ( mul_lzd_temp          ),
  .full (                       )
);

// lzd #(.W(128), .N(7)) u_lzd_add(
//   .data({add_cal_frac, 57'd0}),
//   .zcnt(add_lzd_temp),
//   .full()
// );

lzd128 u_lzd_add(
  .data ( {add_cal_frac, 57'd0} ),
  .zcnt ( add_lzd_temp          ),
  .full (                       )
);

shifter_left_48_6 u_shifter_left_mul(
  .data(mul_cal_frac_stage_1),
  .shift(mul_shift_number_stage_1[5:0]),
  .o(mul_frac_shift_temp)
);

shifter_right_71_8 u_shifter_right_mul(
  .data(mul_frac_shift),
  .shift(mul_right_shift_number),
  .o(mul_frac_right_shift)
);

shifter_left_71_7 u_shifter_left_add(
  .data(add_cal_frac_stage_3),
  .shift(add_shift_number_stage_3),
  .o(add_frac_shift_temp)
);

shifter_right_71_8 u_shift_right_frac_smaller(
  .data({1'b0, add_frac_smaller}),
  .shift(add_exp_diff),
  .o(add_frac_smaller_temp)
);

shifter_right_71_8 u_shifter_right_add(
  .data(add_frac_shift),
  .shift(add_right_shift_number),
  .o(add_frac_right_shift)
);

adder_71bit u_adder_71bit(
  .a(add_frac_larger_align_stage_2),
  .b(add_frac_smaller_align_stage_2),
  .o(add_cal_frac_temp)
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    done_reg <= 'd0;
    done_reg_reg <= 'd0;
    done_reg_reg_reg <= 'd0;
  end
  else begin
    done_reg <= valid;
    done_reg_reg <= done_reg;
    done_reg_reg_reg <= done_reg_reg;
  end
end
endmodule