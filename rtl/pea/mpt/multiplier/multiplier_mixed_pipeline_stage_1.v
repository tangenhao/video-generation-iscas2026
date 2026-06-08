module multiplier_mixed_pipeline_stage_1(
  clk, rst_n,
  a, b,
  type_a, type_b,
  o, zero, inf, nan
);

input clk;
input rst_n;

input       [15:0] a;
input       [15:0] b;
input       [1:0]  type_a;
input       [1:0]  type_b;
output wire [31:0] o;
output wire zero;
output wire inf;
output wire nan;

wire        compute_float;
wire [1:0]  int_compute_mode;
wire        compute_int16;
wire        a_sign;
wire        b_sign;
wire [7:0]  a_exp;
wire [7:0]  b_exp;
wire [10:0] a_frac;
wire [10:0] b_frac;
wire        a_zero;
wire        b_zero;
wire        a_inf;
wire        b_inf;
wire        a_nan;
wire        b_nan;

reg       compute_float_reg;
reg       a_sign_reg;
reg       b_sign_reg;
reg [7:0] a_exp_reg;
reg [7:0] b_exp_reg;
reg [1:0] type_a_reg;
reg [1:0] type_b_reg;
reg       a_zero_reg;
reg       b_zero_reg;
reg       a_inf_reg;
reg       b_inf_reg;
reg       a_nan_reg;
reg       b_nan_reg;

wire [4:0] a_0;
wire [4:0] a_1;
wire [4:0] a_2;
wire [4:0] a_3;
wire [4:0] b_0;
wire [4:0] b_1;
wire [4:0] b_2;
wire [4:0] b_3;

wire signed [7:0] mul_0;
wire signed [7:0] mul_1;
wire signed [7:0] mul_2;
wire signed [7:0] mul_4;
wire signed [7:0] mul_5;
wire signed [7:0] mul_6;
wire signed [7:0] mul_8;
wire signed [7:0] mul_9;
wire signed [7:0] mul_10;

wire        o_sign;
wire [7:0]  o_exp;
wire [20:0] o_frac;

wire [1:0] sel_mode;
wire [8:0] cal_exp_tmp;
wire [1:0] exp_adj_mode;
wire [9:0] exp_adj;
wire [9:0] cal_exp;
wire [8:0] cal_exp_neg;

wire [21:0] cal_frac;
wire [21:0] cal_frac_shift;
wire        unnorm_cal;
wire [4:0]  lzd_o_temp;
wire [4:0]  lzd_o;
wire [4:0]  shift_number;
wire [8:0]  norm_exp;
wire [21:0] norm_frac;

assign compute_float = type_a[1] | type_b[1];

assign o_sign = a_sign_reg ^ b_sign_reg;

assign sel_mode = {type_a_reg[0] & type_a_reg[1], type_b_reg[0] & type_b_reg[1]};
assign exp_adj = sel_mode == 3 ? -127 :
                 sel_mode == 0 ? 97 :
                 -15;
assign cal_exp_tmp = a_exp_reg + b_exp_reg;
assign cal_exp = cal_exp_tmp + exp_adj;
assign cal_exp_neg = exp_adj - cal_exp_tmp + 1;

assign int_compute_mode = {type_a[0], type_b[0]};

assign a_0[4] = (~(|int_compute_mode)) & !compute_float & a[3];
assign a_0[3:0] = ({4{!compute_float}} & a[3:0]) | ({4{compute_float}} & a_frac[3:0]);

assign a_1[4] = (((int_compute_mode[1] | (!int_compute_mode[0])) & a[7]) | (((!int_compute_mode[1]) & int_compute_mode[0]) & a[3])) & (!compute_float);
assign a_1[3:0] = ({4{((!int_compute_mode[1]) & int_compute_mode[0]) & (!compute_float)}} & {4{a[3]}})
                | ({4{(int_compute_mode[1] | (!int_compute_mode[0])) & !compute_float}} & a[7:4])
                | ({4{compute_float}} & a_frac[7:4]);

assign a_2[4] = (int_compute_mode == 0) & !compute_float & a[11];
assign a_2[3:0] = ({4{compute_float}} & {1'b0, a_frac[10:8]}) | ({4{!compute_float}} & a[11:8]);

assign a_3[4] = ((((!int_compute_mode[1]) & int_compute_mode[0])) & (!compute_float) & a[11]) | ((!compute_float) & (int_compute_mode[1] | (!int_compute_mode[0])) & a[15]);
assign a_3[3:0] = ({4{!compute_float}}) & (({4{((!int_compute_mode[1]) & int_compute_mode[0])}} & {4{a[11]}}) | ({4{int_compute_mode[1] | (!int_compute_mode[0])}} & a[15:12]));

assign b_0[4] = (~(|int_compute_mode)) & !compute_float & b[3];
assign b_0[3:0] = ({4{!compute_float}} & b[3:0]) | ({4{compute_float}} & b_frac[3:0]);

assign b_1[4] = (((int_compute_mode[0] | (!int_compute_mode[1])) & b[7]) | (((!int_compute_mode[0]) & int_compute_mode[1]) & b[3])) & (!compute_float);
assign b_1[3:0] = ({4{((!int_compute_mode[0]) & int_compute_mode[1]) & !compute_float}} & {4{b[3]}})
                | ({4{((int_compute_mode[0] | (!int_compute_mode[1]))) & !compute_float}} & b[7:4])
                | ({4{compute_float}} & b_frac[7:4]);

assign b_2[4] = (int_compute_mode == 0) & !compute_float & b[11];
assign b_2[3:0] = ({4{compute_float}} & {1'b0, b_frac[10:8]}) | ({4{!compute_float}} & b[11:8]);

assign b_3[4] = ((((!int_compute_mode[0]) & int_compute_mode[1])) & (!compute_float) & b[11]) | ((!compute_float) & (int_compute_mode[0] | (!int_compute_mode[1])) & b[15]);
assign b_3[3:0] = ({4{!compute_float}}) & (({4{((!int_compute_mode[0]) & int_compute_mode[1])}} & {4{b[11]}}) | ({4{int_compute_mode[0] | (!int_compute_mode[1])}} & b[15:12]));

wire [11:0] add_0_0;
wire [11:0] add_0_1;
wire [11:0] add_0_2;
wire [11:0] add_0_3;
wire [11:0] add_0_4;
wire [11:0] add_0_5;
wire [11:0] add_0_6;
wire [11:0] add_0_7;

wire carry_0_0;
wire carry_0_1;
wire carry_0_2;
wire carry_0_3;
wire carry_0_4;
wire carry_0_5;
wire carry_0_6;

wire [15:0] add_1_0;
wire [15:0] add_1_1;
wire [15:0] add_1_2;
wire [15:0] add_1_3;

reg [15:0] add_1_0_reg;
reg [15:0] add_1_1_reg;
reg [15:0] add_1_2_reg;
reg [15:0] add_1_3_reg;

reg [7:0] mul_0_reg;
reg [7:0] mul_5_reg;
reg [7:0] mul_10_reg;
reg [7:0] mul_6_reg;

reg [1:0] int_compute_mode_reg;

wire carry_1_0;
wire carry_1_1;
wire carry_1_2;

wire [23:0] add_2_0;
wire [23:0] add_2_1;

wire carry_2;

wire [31:0] add_3;

wire [15:0] int8_res_0;
wire [15:0] int8_res_1;

assign int8_res_0 = add_1_0_reg;
assign int8_res_1 = add_1_3_reg;

assign cal_frac = add_3[21:0];

assign lzd_o = lzd_o_temp;
assign unnorm_cal = cal_exp[9] || (~(|cal_exp[8:0]));
assign shift_number = cal_exp <= lzd_o ? cal_exp - 1 : lzd_o - 1;
assign norm_exp = unnorm_cal ? 1 : lzd_o == 0 ? cal_exp + 1 :
                                   lzd_o == 1 ? cal_exp :
                                   cal_exp - shift_number;
assign norm_frac = unnorm_cal ? cal_frac_shift : lzd_o == 0 ? cal_frac[21:1] :
                                                 lzd_o == 1 ? cal_frac[20:0] :
                                                 cal_frac << shift_number;

wire overflow;

assign overflow = norm_exp[8] || (&norm_exp[7:0]);
assign zero = a_zero_reg || b_zero_reg;
assign inf = (a_inf_reg & !b_nan_reg) | (b_inf_reg & !a_nan_reg) | overflow;
assign nan = a_nan_reg | b_nan_reg;

assign o_exp = zero ? 0 : (inf | nan | overflow) ? 'hff : norm_exp;
assign o_frac = zero ? 0 : (inf | overflow) ? 0 : norm_frac[20:0];

assign o = compute_float_reg ? {o_sign, o_exp, o_frac} : 
           int_compute_mode_reg == 0 ? {mul_6_reg , mul_10_reg , mul_5_reg , mul_0_reg} : {int8_res_1, int8_res_0};

unpack_mul u_unpack_a(
  .data ( a & {16{compute_float}} ),
  .mode ( type_a[1:0] ),
  .sign ( a_sign      ),
  .exp  ( a_exp       ),
  .frac ( a_frac      ),
  .zero ( a_zero      ),
  .inf  ( a_inf       ),
  .nan  ( a_nan       )
);

unpack_mul u_unpack_b(
  .data ( b & {16{compute_float}} ),
  .mode ( type_b[1:0] ),
  .sign ( b_sign      ),
  .exp  ( b_exp       ),
  .frac ( b_frac      ),
  .zero ( b_zero      ),
  .inf  ( b_inf       ),
  .nan  ( b_nan       )
);

multiplier_int4 u_mul_0(
  .a ( a_0   ),
  .b ( b_0   ),
  .o ( mul_0 )
);

multiplier_int4 u_mul_1(
  .a ( a_1   ),
  .b ( b_0   ),
  .o ( mul_1 )
);

wire signed [4:0] real_a_2;
wire signed [4:0] real_b_2;

assign real_a_2 = compute_float ? a_2 : a_3;
assign real_b_2 = compute_float ? b_0 : b_2;

multiplier_int4 u_mul_2(
  .a ( real_a_2 ),
  .b ( real_b_2 ),
  .o ( mul_2    )
);

multiplier_int4 u_mul_4(
  .a ( a_0   ),
  .b ( b_1   ),
  .o ( mul_4 )
);

multiplier_int4 u_mul_5(
  .a ( a_1   ),
  .b ( b_1   ),
  .o ( mul_5 )
);

wire signed [4:0] real_a_6;
wire signed [4:0] real_b_6;

assign real_a_6 = compute_float ? a_2 : a_3;
assign real_b_6 = compute_float ? b_1 : b_3;

multiplier_int4 u_mul_6(
  .a ( real_a_6 ),
  .b ( real_b_6 ),
  .o ( mul_6    )
);

multiplier_int4 u_mul_8(
  .a ( a_0   ),
  .b ( b_2   ),
  .o ( mul_8 )
);

wire signed [4:0] real_a_9;
wire signed [4:0] real_b_9;

assign real_a_9 = compute_float ? a_1 : a_2;
assign real_b_9 = compute_float ? b_2 : b_3;

multiplier_int4 u_mul_9(
  .a ( real_a_9 ),
  .b ( real_b_9 ),
  .o ( mul_9    )
);

multiplier_int4 u_mul_10(
  .a ( a_2    ),
  .b ( b_2    ),
  .o ( mul_10 )
);

adder_12_8 u_adder_layer_0_0(
  .signed_ ( 1'b0    ),
  .a       ( mul_0   ),
  .b       ( mul_1   ),
  .s       ( add_0_0 )
);

assign add_0_1 = mul_2;

adder_12_8 u_adder_layer_0_2(
  .signed_ ( (type_a == 1 || type_b == 1) && (!compute_float) ),
  .a       ( mul_4                                            ),
  .b       ( mul_5                                            ),
  .s       ( add_0_2                                          )
);

assign add_0_3 = mul_6;

adder_12_8 u_adder_layer_0_4(
  .signed_ ( (type_a == 1 || type_b == 1) && (!compute_float) ),
  .a       ( mul_8                                            ),
  .b       ( mul_9                                            ),
  .s       ( add_0_4                                          )
);

wire [7:0] adder_a_0_5;

assign adder_a_0_5 = compute_float ? 8'd0 : mul_2;

adder_12_8 u_adder_layer_0_5(
  .signed_ ( 1'b0        ),
  .a       ( mul_10      ),
  .b       ( adder_a_0_5 ),
  .s       ( add_0_5     )
);

wire signed [7:0] adder_a_0_7;
wire signed [7:0] adder_b_0_7;

assign adder_a_0_7 = compute_float ? 8'd0 : mul_9;
assign adder_b_0_7 = compute_float ? 8'd0 : mul_6;

adder_12_8 u_adder_layer_0_7(
  .signed_ ( !compute_float ),
  .a       ( adder_a_0_7    ),
  .b       ( adder_b_0_7    ),
  .s       ( add_0_7        )
);

adder_16_12 u_adder_layer_1_0(
  .signed_ ( !compute_float ),
  .a       ( add_0_0        ),
  .b       ( add_0_2        ),
  .s       ( add_1_0        )
);

adder_16_12 u_adder_layer_1_1(
  .signed_ ( !compute_float ),
  .a       ( add_0_1        ),
  .b       ( add_0_3        ),
  .s       ( add_1_1        )
);

assign add_1_2 = {{4{add_0_4[11] & (!compute_float)}}, add_0_4};

adder_16_12 u_adder_layer_1_3(
  .signed_ ( !compute_float ),
  .a       ( add_0_5        ),
  .b       ( add_0_7        ),
  .s       ( add_1_3        )
);

adder_24_16 u_adder_layer_2_0(
  .signed_ ( !compute_float ),
  .a       ( add_1_0_reg    ),
  .b       ( add_1_2_reg    ),
  .s       ( add_2_0        )
);

adder_24_16 u_adder_layer_2_1(
  .signed_ ( !compute_float ),
  .a       ( add_1_1_reg    ),
  .b       ( add_1_3_reg    ),
  .s       ( add_2_1        )
);

adder_32_24 u_adder_layer_3(
  .a ( add_2_0 ),
  .b ( add_2_1 ),
  .s ( add_3   )
);

lzd32 u_lzd(
  .data ( {cal_frac, 10'b0} ),
  .zcnt ( lzd_o_temp        ),
  .full (                   )
);

shifter_frac u_shifter_frac(
  .data  ( cal_frac       ),
  .shift ( cal_exp_neg    ),
  .o     ( cal_frac_shift )
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    compute_float_reg    <= 1'b0;
    a_sign_reg           <= 1'b0;
    b_sign_reg           <= 1'b0;
    a_exp_reg            <= 8'b0;
    b_exp_reg            <= 8'b0;
    type_a_reg           <= 2'b0;
    type_b_reg           <= 2'b0;
    a_zero_reg           <= 1'b1;
    b_zero_reg           <= 1'b1;
    a_inf_reg            <= 1'b0;
    b_inf_reg            <= 1'b0;
    a_nan_reg            <= 1'b0;
    b_nan_reg            <= 1'b0;
    add_1_0_reg          <= 16'b0;
    add_1_1_reg          <= 16'b0;
    add_1_2_reg          <= 16'b0;
    add_1_3_reg          <= 16'b0;
    mul_0_reg            <= 8'b0;
    mul_5_reg            <= 8'b0;
    mul_10_reg           <= 8'b0;
    mul_6_reg            <= 8'b0;
    int_compute_mode_reg <= 2'b0;
  end 
  else begin
    if (compute_float) begin
      compute_float_reg    <= compute_float;
      a_sign_reg           <= a_sign;
      b_sign_reg           <= b_sign;
      a_exp_reg            <= a_exp;
      b_exp_reg            <= b_exp;
      type_a_reg           <= type_a;
      type_b_reg           <= type_b;
      a_zero_reg           <= a_zero;
      b_zero_reg           <= b_zero;
      a_inf_reg            <= a_inf;
      b_inf_reg            <= b_inf;
      a_nan_reg            <= a_nan;
      b_nan_reg            <= b_nan;
      int_compute_mode_reg <= 'd0;
    end
    else begin
      compute_float_reg    <= 0;
      a_sign_reg           <= 0;
      b_sign_reg           <= 0;
      a_exp_reg            <= 0;
      b_exp_reg            <= 0;
      type_a_reg           <= 0;
      type_b_reg           <= 0;
      a_zero_reg           <= 0;
      b_zero_reg           <= 0;
      a_inf_reg            <= 0;
      b_inf_reg            <= 0;
      a_nan_reg            <= 0;
      b_nan_reg            <= 0;
      int_compute_mode_reg <= 0;
    end
    add_1_0_reg          <= add_1_0;
    add_1_1_reg          <= add_1_1;
    add_1_2_reg          <= add_1_2;
    add_1_3_reg          <= add_1_3;
    mul_0_reg            <= mul_0;
    mul_5_reg            <= mul_5;
    mul_10_reg           <= mul_10;
    mul_6_reg            <= mul_6;
    int_compute_mode_reg <= int_compute_mode;
  end
end

endmodule