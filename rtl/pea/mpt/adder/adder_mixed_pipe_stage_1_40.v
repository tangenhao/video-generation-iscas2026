module adder_mixed_pipe_stage_1_40(
  clk, rst_n,
  a, b,
  a_zero, a_inf, a_nan,
  b_zero, b_inf, b_nan,
  mode,
  o,
  zero, inf, nan
);

parameter WIDTH = 40;

input wire clk, rst_n;

input       [39:0] a;
input       [39:0] b;
input              a_zero;
input              a_inf;
input              a_nan;
input              b_zero;
input              b_inf;
input              b_nan;
input       [1:0]  mode;
output wire [43:0] o;
output wire        zero;
output wire        inf;
output wire        nan;

wire compute_float;
wire compute_int4;
wire compute_int8;

reg compute_float_reg;

wire signed [10:0] a_0;
wire signed [10:0] a_1;
wire signed [10:0] a_2;
wire signed [10:0] a_3;

wire signed [10:0] b_0;
wire signed [10:0] b_1;
wire signed [10:0] b_2;
wire signed [10:0] b_3;

wire c_i_0;
wire c_i_1;
wire c_i_2;
wire c_i_3;

wire c_o_0;
wire c_o_1;
wire c_o_2;
wire c_o_3;

wire signed [10:0] sum_0;
wire signed [10:0] sum_1;
wire signed [10:0] sum_2;
wire signed [10:0] sum_3;

reg signed [10:0] sum_0_reg;
reg signed [10:0] sum_1_reg;
reg signed [10:0] sum_2_reg;
reg signed [10:0] sum_3_reg;

wire        sign_a;
wire        sign_b;
wire [7:0]  exp_a;
wire [7:0]  exp_b;
wire [20:0] frac_a;
wire [20:0] frac_b;

reg sign_a_reg;
reg sign_b_reg;

wire        minus_flag;
wire [1:0]  exp_cmp;
wire [1:0]  frac_cmp;
wire        cmp;
wire [7:0]  exp_larger;
wire [7:0]  exp_smaller;
wire [7:0]  exp_diff;
wire [20:0] frac_larger;
wire [20:0] frac_smaller;

wire [21:0] frac_larger_align;
wire [21:0] frac_smaller_align;

reg       minus_flag_reg;
reg [1:0] exp_cmp_reg;
reg [1:0] frac_cmp_reg;
reg [1:0] cmp_reg;
reg [7:0] exp_larger_reg;

reg a_zero_reg;
reg a_inf_reg;
reg a_nan_reg;
reg b_zero_reg;
reg b_inf_reg;
reg b_nan_reg;

wire        cal_sign;
wire [8:0]  cal_exp;
wire [21:0] cal_frac;

wire [4:0]  lzd;
wire [4:0]  lzd_temp;
wire        full;
wire [4:0]  shift_number;
wire [8:0]  norm_exp;
wire [21:0] norm_frac;

wire        overflow;
wire        o_sign;
wire [7:0]  o_exp;
wire [20:0] o_frac;

wire [21:0] int8_res_0;
wire [21:0] int8_res_1;

// unpack
assign compute_float = mode[1] & !mode[0];
assign compute_int4 = !mode[1] & !mode[0];
assign compute_int8 = !mode[1] & mode[0];

assign sign_a = compute_float ? a[29] : 1'b0;
assign sign_b = compute_float ? b[29] : 0;
assign exp_a  = compute_float ? a[28:21] : 0;
assign exp_b  = compute_float ? b[28:21] : 0;
assign frac_a = compute_float ? a[20:0] : 0;
assign frac_b = compute_float ? b[20:0] : 0;

// sel
assign exp_cmp = exp_a == exp_b ? 'b11 :
                 exp_a > exp_b ? 'b01 :
                 'b00;
assign frac_cmp = frac_a == frac_b ? 'b11 :
                  frac_a > frac_b ? 'b01 :
                  'b00;
assign cmp = (exp_cmp[0] & !exp_cmp[1]) | (exp_cmp[1] & frac_cmp[0]);

assign exp_larger = exp_cmp[0] ? exp_a : exp_b;
assign exp_smaller = exp_cmp[0] ? exp_b : exp_a;
assign exp_diff = exp_larger - exp_smaller;

assign frac_larger = cmp ? frac_a : frac_b;
assign frac_smaller = cmp ? frac_b : frac_a;

// align and complement
assign frac_larger_align = minus_flag ? {1'b1, ~frac_larger} + 1 : frac_larger;

// add
assign minus_flag = sign_a ^ sign_b;

assign a_0 = ({11{compute_float}} & {1'b0, frac_larger_align[9:0]})
           | ({11{compute_int4}} & {a[9], a[9:0]})
           | ({11{!compute_float & !compute_int4}} & {1'b0, a[9:0]});

assign a_1 = ({11{compute_float}} & {1'b0, frac_larger_align[19:10]})
           | ({11{!compute_float}} & {a[19], a[19:10]});

assign a_2 = ({11{compute_float}} & {{9{frac_larger_align[21]}}, frac_larger_align[21:20]})
           | ({11{compute_int4}} & {a[29], a[29:20]})
           | ({11{!compute_float & !compute_int4}} & {1'b0, a[29:20]});

assign a_3 = ({11{!compute_float}} & {a[39], a[39:30]});

assign b_0 = ({11{compute_float}} & {1'b0, frac_smaller_align[9:0]})
           | ({11{compute_int4}} & {b[9], b[9:0]})
           | ({11{!compute_float & !compute_int4}} & {1'b0, b[9:0]});

assign b_1 = ({11{compute_float}} & {1'b0, frac_smaller_align[19:10]})
           | ({11{!compute_float}} & {b[19], b[19:10]});

assign b_2 = ({11{compute_float}} & {{9{frac_smaller_align[21]}}, frac_smaller_align[21:20]})
           | ({11{compute_int4}} & {b[29], b[29:20]})
           | ({11{!compute_float & !compute_int4}} & {1'b0, b[29:20]});

assign b_3 = ({11{!compute_float}} & {b[39], b[39:30]});

assign c_i_0 = 'd0;
assign c_i_1 = compute_float | compute_int8 ? c_o_0 : 'd0;
assign c_i_2 = compute_float ? c_o_1 : 'd0;
assign c_i_3 = compute_int8 ? c_o_2 : 'd0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sum_0_reg         <= 0;
    sum_1_reg         <= 0;
    sum_2_reg         <= 0;
    sum_3_reg         <= 0;
    sign_a_reg        <= 0;
    sign_b_reg        <= 0;
    minus_flag_reg    <= 0;
    cmp_reg           <= 0;
    exp_larger_reg    <= 0;
    a_zero_reg        <= 1;
    a_inf_reg         <= 0;
    a_nan_reg         <= 0;
    b_zero_reg        <= 1;
    b_inf_reg         <= 0;
    b_nan_reg         <= 0;
    compute_float_reg <= 0;
    exp_cmp_reg       <= 0;
    frac_cmp_reg      <= 0;
  end
  else begin
    sum_0_reg         <= sum_0;
    sum_1_reg         <= sum_1;
    sum_2_reg         <= sum_2;
    sum_3_reg         <= sum_3;
    sign_a_reg        <= sign_a;
    sign_b_reg        <= sign_b;
    minus_flag_reg    <= minus_flag;
    cmp_reg           <= cmp;
    exp_larger_reg    <= exp_larger;
    a_zero_reg        <= a_zero;
    a_inf_reg         <= a_inf;
    a_nan_reg         <= a_nan;
    b_zero_reg        <= b_zero;
    b_inf_reg         <= b_inf;
    b_nan_reg         <= b_nan;
    compute_float_reg <= compute_float;
    exp_cmp_reg       <= exp_cmp;
    frac_cmp_reg      <= frac_cmp;
  end
end

assign cal_sign = (|cmp_reg) ? sign_a_reg : sign_b_reg;
assign cal_exp = exp_larger_reg;
wire [21:0] cal_frac_temp;
assign cal_frac_temp = {sum_2_reg[1:0], sum_1_reg[9:0], sum_0_reg[9:0]};
assign cal_frac = minus_flag_reg ? ~cal_frac_temp + 1 : cal_frac_temp;

assign lzd = lzd_temp;
assign shift_number = full ? 5'b0 : cal_exp <= lzd ? cal_exp - 1 : lzd - 1;
assign norm_exp = lzd == 0 ? cal_exp + 1 :
                  lzd == 1 ? cal_exp :
                  cal_exp - shift_number;
assign norm_frac = lzd == 0 ? cal_frac[21:1] :
                   lzd == 1 ? cal_frac[20:0] :
                   cal_frac << shift_number;

assign overflow = norm_exp[8] || (&norm_exp[7:0]);
assign zero = minus_flag_reg & (&exp_cmp_reg) & (&frac_cmp_reg) | (a_zero_reg & b_zero_reg);
assign inf = (a_inf_reg & !b_nan_reg) | (b_inf_reg & !a_nan_reg) | (overflow & !(nan));
assign nan = a_nan_reg | b_nan_reg | (minus_flag_reg & a_inf_reg & b_inf_reg);

assign o_sign = (inf & a_inf_reg & sign_a_reg) | (inf & b_inf_reg & sign_b_reg) | (!inf & cal_sign);
assign o_exp =  zero ? 0 : (inf | nan) ? 8'hff : norm_exp;
assign o_frac = zero ? 0 : (inf | overflow) ? 21'h0 : norm_frac[20:0];

assign int8_res_0 = {sum_1_reg[10], sum_1_reg, sum_0_reg[9:0]};
assign int8_res_1 = {sum_3_reg[10], sum_3_reg, sum_2_reg[9:0]};

assign o = compute_float ? {12'd0, o_sign, o_exp, o_frac} :
           compute_int4 ? {sum_3_reg, sum_2_reg, sum_1_reg, sum_0_reg} :
            {int8_res_1, int8_res_0};

adder_11bit u_adder_int_0(
  .a   ( a_0   ),
  .b   ( b_0   ),
  .c_i ( c_i_0 ),
  .o   ( sum_0 ),
  .c_o ( c_o_0 )
);

adder_11bit u_adder_int_1(
  .a   ( a_1   ),
  .b   ( b_1   ),
  .c_i ( c_i_1 ),
  .o   ( sum_1 ),
  .c_o ( c_o_1 )
);

adder_11bit u_adder_int_2(
  .a   ( a_2   ),
  .b   ( b_2   ),
  .c_i ( c_i_2 ),
  .o   ( sum_2 ),
  .c_o ( c_o_2 )
);

adder_11bit u_adder_int_3(
  .a   ( a_3   ),
  .b   ( b_3   ),
  .c_i ( c_i_3 ),
  .o   ( sum_3 ),
  .c_o ( c_o_3 )
);

lzd32 u_lzd(
  .data ( {cal_frac, 10'b0} ),
  .zcnt ( lzd_temp          ),
  .full ( full              )
);

shifter_frac u_shifter_frac(
  .data  ( {1'b0, frac_smaller} ),
  .shift ( {1'b0, exp_diff}     ),
  .o     ( frac_smaller_align   )
);
endmodule