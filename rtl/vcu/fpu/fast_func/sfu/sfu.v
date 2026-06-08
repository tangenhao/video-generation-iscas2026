module sfu(
    input clk,
    input rst_n,
    input valid,
    input [10:0] func, 
    input [31:0] din, output [31:0] dout, output reg done
);

wire w_sign;
wire [7:0]  w_exp;
wire [22:0] w_frac;
wire [23:0] w_mantissa;

wire zero_sig;
wire nan_sig;
wire inf_sig;

wire o_pinf;
wire o_ninf;
wire o_nan_p;
wire o_nan_n;
wire o_zero_p;
wire o_zero_n;
wire o_one_p;
wire o_one_n;
wire odd_quad;
wire neg_quad;

wire [7 :0]  shift_num;
wire [30:0]  shifter;
wire [30:0]  shifted_mantissa;
wire [8 :0]  norm_exp_exp2;
wire [8 :0]  norm_exp;
wire [6 :0]  minus_const;
wire [22:0]  norm_frac;
wire [6 :0]  index;
wire [16:0]  x_int;
reg  [32:0]  c0;
reg  [14:0]  c1;
reg  [9: 0]  c2;
wire signed [32:0]  poly1;
wire signed [44:0]  poly2;
wire [45:0] para_exp2;
wire [46:0] para_sincos;
wire [45:0] para_log2;
wire [46:0] para_rec;
wire [48:0] para_rsqrt;
// wire [26:0] mul_out;
wire        out_sign;
wire [7 :0] out_exp;
wire [22:0] out_frac;
wire [31:0] special_out;
wire        special_sig;
wire [5:0]  lzd_o;
reg  [30:0] mul_out_detect;
wire [30:0] mul_out_left_shifted;
wire [23:0] mul_out_right_shifted;
wire [4 :0] norm_l_shift;
wire [7 :0] norm_r_shift;
reg  inv_sig;
wire sh_mant_nzero;
wire sh_mant_zero;
wire [8:0] log2_rec_add1;
wire [8:0] log2_rec_add2;
wire act_func;
reg  [31:0] act_special_o;
reg  [31:0] special_large;
wire special_large_sig;
reg  [2:0] act_high_index;
wire       act_minor_sig;
wire [6:0] act_index;
wire [6:0] norm_index;
wire [22:0] act_frac_sh;
wire [21:0] poly1_trunc;

always@(*) begin
    case (w_exp)
        8'd130: act_high_index = 3'b111;
        8'd129: act_high_index = 3'b110;
        8'd128: act_high_index = 3'b101;
        8'd127: act_high_index = 3'b100;
        8'd126: act_high_index = 3'b011;
        8'd125: act_high_index = 3'b010;
        8'd124: act_high_index = 3'b001;
        default: act_high_index = 3'b000;
    endcase
end
assign special_large_sig = act_func && (w_exp > 130) && (~ (nan_sig || inf_sig));
assign act_minor_sig = din[30:0] < 31'h3D900000; 

always@(*) begin
    case (func[7:6])
        2'b01: begin //tanh
            special_large = w_sign ? 32'hBF800000 : 32'h3F800000;
        end
        6'b10: begin //sigmoid
            special_large = w_sign ? 32'h00000000 : 32'h3F800000;
        end
        default: begin
            special_large = w_sign ? 32'h80000000 : din;
        end
    endcase
end

assign act_func = |func[10:6];
assign act_frac_sh = act_minor_sig ? shifted_mantissa[22:0] : w_frac;
assign act_index = act_minor_sig ? {w_sign, 6'b0} : {w_sign, act_high_index, act_frac_sh[22:20]};

assign sh_mant_nzero = |shifted_mantissa[22:0];
assign sh_mant_zero = ~(|shifted_mantissa[22:0]);

assign o_zero_p = (func[4] && (w_exp > 8'd134) && w_sign) || (|func[1:0] &&  (~odd_quad) &&sh_mant_zero && (~zero_sig)) 
                || (func[5] && inf_sig && (~w_sign)) || (func[2] && inf_sig && (~w_sign)) || (func[0] && zero_sig && (~w_sign))
                || ((func[7]) && inf_sig && w_sign);
assign o_zero_n = (func[2] && inf_sig && w_sign) || (func[0] && zero_sig && w_sign);
assign o_pinf = func[4] && (w_exp > 8'd133) && (~w_sign) || (func[3] && inf_sig && (~w_sign)) || (func[5] && zero_sig && (~w_sign)) ||
               (func[2] && (~w_sign) && (~(|w_exp)) && ( (w_frac[22:21] == 2'b0) || (w_frac[22:0] == 23'h200000)   )) 
               ||((|func[10:8]) && inf_sig && (~w_sign));
assign o_one_p = (func[4] && (w_exp < 8'd103)) || (func[0] && odd_quad && (~(w_sign ^ neg_quad)) &&sh_mant_zero) || 
                 (func[1] && odd_quad && (~( neg_quad)) &&sh_mant_zero) || ((|func[7:6]) && inf_sig && (~w_sign));
assign o_one_n = (func[0] && odd_quad && (w_sign ^ neg_quad) &&sh_mant_zero) || (func[1] && odd_quad && (neg_quad) &&sh_mant_zero)
                 ||((func[6]) && inf_sig && w_sign);
assign o_nan_p  = (nan_sig &&(~w_sign)) || (func[3] && w_sign && (~zero_sig)) || (act_func && nan_sig) || ((|func[10:8]) && inf_sig && w_sign) ;
assign o_nan_n  = (nan_sig && w_sign && (~act_func) ) || ((|func[1:0]) && inf_sig) || (func[5] && w_sign && (~zero_sig));
assign o_ninf = (func[3] && zero_sig) ||
                (func[2] && (w_sign) && (~(|w_exp)) && ( (w_frac[22:21] == 2'b0) || (w_frac[22:0] == 23'h200000)   )) || (func[5] && zero_sig && w_sign);

assign w_sign     = din[31];
assign w_exp      = din[30:23];
assign w_frac     = din[22:0];
assign w_mantissa = {(|w_exp), w_frac};

assign zero_sig   = ~((|w_exp) || (|w_frac));
assign nan_sig    = (&w_exp) && (|w_frac);
assign inf_sig   = (&w_exp) && (~(|w_frac));





//exp2 exp最大134 最小103 相差31 5bit



assign shift_num = 8'd134 - w_exp; //max 31 for exp
assign shifter = {w_mantissa, 7'b0};
assign shifted_mantissa = |shift_num[7:5] ? 31'b0: shifter >> shift_num[4:0];
assign minus_const = sh_mant_nzero ? 7'd126 : 7'd127;
assign norm_exp_exp2 = w_sign ? minus_const - shifted_mantissa[30:23] : shifted_mantissa[30:23] + 127; //TODO:
assign norm_frac = inv_sig ? (~shifted_mantissa[22:0]) : shifted_mantissa[22:0];
assign norm_exp = func[4] ? norm_exp_exp2 :9'd127; //exp2 log2 sin

assign odd_quad = func[1] ? ~shifted_mantissa[23] : shifted_mantissa[23];
assign neg_quad = (func[1] && shifted_mantissa[23]) ? ~shifted_mantissa[24] :shifted_mantissa[24];
always@(*) begin
    case (func)
        6'b000001, 6'b000010: begin //sin
            inv_sig = odd_quad && sh_mant_nzero;
        end
        6'b010000: begin //exp2
            inv_sig = w_sign && sh_mant_nzero;
        end
    default: begin
            inv_sig = 1'b0;
        end
    endcase
end

wire [5:0] log2_shift;
wire [23:0] log2_rec_mantissa;
wire [8:0] log2_rec_int;
wire log2_sign;

DW_lzd #(.a_width(24)) u_lzd24(
    .a(w_mantissa),
    .enc(log2_shift),
    .dec()
);
wire [7:0] exp_mid;
wire [4:0] act_exp_bias;
assign exp_mid = func[5] ? {1'b0,w_exp[7:1]} : w_exp;
assign log2_rec_mantissa = w_mantissa << log2_shift[4:0];
assign log2_rec_add1 = (~(|w_exp)) ? (func[5] ? {5'b0, log2_shift[4:1]} : {4'b0, log2_shift[4:0]}) : 
                        (log2_sign | func[2] | func[5]) ? ~{1'b0, exp_mid} : {1'b0, exp_mid};
assign log2_rec_add2 = func[5] ? 9'd189 : (~(|w_exp)) ? ( func[3]? 9'd125 : 9'd252) : (func[3]? (log2_sign ? 9'd127 : 9'd129) : 9'd254);
assign log2_rec_int = log2_rec_add1 + log2_rec_add2
                     + {7'b0,(func[3] && log2_sign && (~(|log2_rec_mantissa[22:0]))) || (func[5] && (((log2_shift[0]) || (|w_exp)))) } + {7'b0, (|w_exp) && func[5] && (~w_exp[0])};
assign log2_sign = w_exp < 8'd127;

//---------------------
wire [54:0] para_act;
assign norm_index = func[5] ? {((~(|w_exp))&&log2_shift[0]) || ((|w_exp) && (~w_exp[0])) , log2_rec_mantissa[22:17]}  
                        : ( (|func[3:2]) ? log2_rec_mantissa[22:16] : norm_frac[22:16]);
assign index = act_func ? act_index : norm_index;
assign x_int = func[5] ? log2_rec_mantissa[16:0]
                : ((|func[3:2]) ? {1'b0, log2_rec_mantissa[15:0]} 
                : ( act_func ? act_frac_sh[19:3] : {1'b0, norm_frac[15:0]}));

assign act_exp_bias = para_act[54:50];

always@(*) begin
    case (func[5:0])
        // 6'b000001, 6'b000010: begin //sin
        //     c0 = {4'b0, para_sincos[46:23], 5'b0};
        //     c1 = {1'b0, para_sincos[22:9]};
        //     c2 = {1'b1, para_sincos[8:0]};
        // end
        // 6'b000100: begin //cos
        //     c0 = {4'b01, para_rec[46:23], 5'b0};
        //     c1 = {1'b1, para_rec[22:9]};
        //     c2 = {1'b0, para_rec[8:0]};
        // end
        // 6'b001000: begin //log2
        //     c0 = {4'b0,  para_log2[45:22], 5'b0};
        //     c1 = {1'b0,  para_log2[21:8]};
        //     c2 = {2'b11, para_log2[7:0]};
        // end
        6'b010000: begin //exp2
            c0 = {4'b01, para_exp2[45:22], 1'b0, {2{w_sign}}, 1'b0, w_sign};
            c1 = {1'b0, para_exp2[21:8]};
            c2 = {2'b0, para_exp2[7:0]};
        end
        6'b100000: begin //rsqrt
            c0 = {1'b0, para_rsqrt[48:23], 6'b0};
            c1 = {1'b1, para_rsqrt[22:9]};
            c2 = {1'b0, para_rsqrt[8:0]};
        end  
    default: begin // act_func
            c0 = {1'b0, para_act[49:25], 7'b0}; //1+25+7=33
            c1 = para_act[24:10];
            c2 = para_act[9:0];
        end
    endcase
end


table_exp2 u_table_exp2 (
    .index(index),
    .para_exp2(para_exp2)
);

// table_sincos u_table_sincos (
//     .index(index),
//     .para_sincos(para_sincos)
// );

// table_log2 u_table_log2 (
//     .index(index),
//     .para_log2(para_log2)
// );

table_rec u_table_rec (
    .index(index),
    .para_rec(para_rec)
);

table_rsqrt u_table_rsqrt (
    .index(index),
    .para_rsqrt(para_rsqrt)
);

table_act u_table_act (
    .func(func[10:6]),
    .index(index),
    .para_act(para_act)
);

wire [8:0] exp_shift;
wire out_sign_s0;
assign exp_shift = (func[2]|func[5]|func[3]) ? log2_rec_int : (act_func? 8'd133 - act_exp_bias :norm_exp);

assign out_sign_s0 = (func[0] && (neg_quad ^ w_sign)) || (func[1] && neg_quad) || (func[3] && log2_sign) || (func[2] && w_sign) || (act_func && w_sign &&(~func[7]));

// reg signed [32:0]  r_poly1_s1;
reg [14:0] r_c1_s1;
reg [9:0]  r_c2_s1;
reg [16:0] r_x_int_s1;
reg [32:0] r_c_0_s1;
reg [8:0]  r_exp_shift_s1;
reg [5:0]  r_func_s1;
reg [7:0]  r_special_state_s1;
reg        r_out_sign_s1;
reg        r_log2_sign_s1;
reg        r_done_s1;
reg        r_act_func_s1;
reg        r_special_large_sig_s1;


reg [26:0] r_mul_out_s2;
reg [8:0]  r_exp_shift_s2;
reg [5:0]  r_func_s2;
reg [7:0]  r_special_state_s2;
reg        r_out_sign_s2;
reg        r_log2_sign_s2;
reg        r_act_func_s2;
reg        r_special_large_sig_s2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // r_poly1_s1         <= 'd0 ; 
        r_c1_s1            <= 'd0 ;
        r_c2_s1            <= 'd0 ;
        r_x_int_s1         <= 'd0 ; 
        r_c_0_s1           <= 'd0 ; 
        r_exp_shift_s1     <= 'd0 ; 
        r_func_s1          <= 'd0 ; 
        r_special_state_s1 <= 'd0 ; 
        r_out_sign_s1      <= 'd0 ;
        r_log2_sign_s1     <= 'd0 ;
        r_done_s1          <= 'd0 ;
        r_act_func_s1        <= 'd0 ;
        r_special_large_sig_s1 <= 'd0 ;

        r_mul_out_s2      <= 'd0 ;
        r_exp_shift_s2    <= 'd0 ;
        r_func_s2         <= 'd0 ;
        r_special_state_s2<= 'd0 ;
        r_out_sign_s2     <= 'd0 ;
        r_log2_sign_s2    <= 'd0 ;
        done              <= 'd0 ;
        r_act_func_s2       <= 'd0 ;
        r_special_large_sig_s2 <= 'd0 ;
    end 
    else begin
        if (valid) begin
            // r_poly1_s1         <= poly1     ;
            r_c1_s1            <= c1       ;
            r_c2_s1            <= c2       ;
            r_x_int_s1         <= x_int     ;
            r_c_0_s1           <= (act_func&& special_large_sig) ? {1'b0,special_large}:  c0;
            r_exp_shift_s1     <= exp_shift ;
            r_func_s1          <= func      ;
            r_special_state_s1 <= {o_pinf, o_ninf, o_nan_n, o_nan_p, o_zero_n, o_zero_p, o_one_p, o_one_n};
            r_out_sign_s1      <= out_sign_s0 ;
            r_log2_sign_s1     <= log2_sign  ;
            r_act_func_s1        <= act_func   ;
            r_special_large_sig_s1 <= special_large_sig ;
        end
        r_done_s1          <= valid      ;

        r_mul_out_s2      <= (r_act_func_s1 && r_special_large_sig_s1) ? r_c_0_s1[26:0] : poly2[43:17];
        r_exp_shift_s2    <= (r_act_func_s1 && r_special_large_sig_s1) ? {4'b0, r_c_0_s1[31:27]} :r_exp_shift_s1 ;
        r_func_s2         <= r_func_s1  ;
        r_special_state_s2<= r_special_state_s1 ;
        r_out_sign_s2     <= r_out_sign_s1 ;
        r_log2_sign_s2    <= r_log2_sign_s1 ;
        done               <= r_done_s1 ;
        r_act_func_s2       <= r_act_func_s1 ;
        r_special_large_sig_s2 <= r_special_large_sig_s1 ;
    end
end
//------------------------------------------------------
// assign poly1 = $signed({1'b0, x_int}) * $signed(c2) + $signed({c1, 18'b0});
// assign poly2 = $signed(r_poly1_s1[32:13]) * $signed({1'b0, r_x_int_s1}) + $signed({r_c_0_s1, 12'b0});
assign poly1 = $signed({1'b0, r_x_int_s1}) * $signed(r_c2_s1) + $signed({r_c1_s1, 18'b0});
assign poly1_trunc = r_act_func_s1? poly1[32:11] : {{2{poly1[32]}}, poly1[32:13]}; //TODO:
assign poly2 = $signed(poly1_trunc) * $signed({1'b0, r_x_int_s1}) + $signed({r_c_0_s1, 12'b0});
//------------------------------------------------------

wire [23:0] log2_o_mantssa;
wire log2_zero;
wire [7:0]  exp2_sel_bias;

wire compute_zero;
assign compute_zero = ~(|r_mul_out_s2);

assign log2_zero = ~((|r_exp_shift_s2[7:0]) || (|log2_o_mantssa[22:0]));
// assign mul_out = poly2[43:17]; 

assign norm_r_shift = ~r_exp_shift_s2[7:0];
assign exp2_sel_bias = r_func_s2[3] ? 8'd133 : r_exp_shift_s2[7:0];
assign norm_l_shift = ((lzd_o[4:0] > r_exp_shift_s2[7:0])&&(~r_func_s2[3])&&(~r_act_func_s2)) ? r_exp_shift_s2[4:0] : lzd_o[4:0];
assign out_exp  = (r_exp_shift_s2[8] && (r_func_s2[4] || r_func_s2[2])&&(~r_act_func_s2)) ?  8'd0: (((lzd_o[4:0] > r_exp_shift_s2[7:0])&&(~r_func_s2[3])&&(~r_act_func_s2)) ? {7'b0, mul_out_left_shifted[30]} : (exp2_sel_bias - norm_l_shift + 1));
assign out_frac = (r_exp_shift_s2[8] && (r_func_s2[4] || r_func_s2[2])&&(~r_act_func_s2)) ?  mul_out_right_shifted[22:0] :  mul_out_left_shifted[29:7]; //TODO:位宽会不会宽
assign out_sign = r_out_sign_s2;


assign mul_out_left_shifted = mul_out_detect << norm_l_shift;
assign mul_out_right_shifted = ((&norm_r_shift[4:3]) | norm_r_shift[7:5]) ? 24'd0 : {1'b0, mul_out_detect[30:8]}  >> norm_r_shift[4:0]; //TODO:

assign log2_o_mantssa =r_log2_sign_s2 ? {1'b1,23'b0} - r_mul_out_s2[23:1]: r_mul_out_s2[23:1];
always@(*) begin
    case (r_func_s2)
        6'b000001, 6'b000010, 6'b000100, 6'b010000: begin //sin cos rec exp2
            mul_out_detect = {1'b0,r_mul_out_s2[24:0],5'b0};
        end
        6'b001000: begin //log2
            mul_out_detect = {r_exp_shift_s2, log2_o_mantssa[22:0]}; //TODO: 
        end
        6'b100000: begin //rsqrt
            mul_out_detect = {r_mul_out_s2[26:0],4'b0};
        end
    default: begin
            mul_out_detect = {r_mul_out_s2[26:0],4'b0};
        end
    endcase
end
DW_lzd #(.a_width(31)) u_lzd31(
    .a(mul_out_detect),
    .enc(lzd_o),
    .dec()
);
assign dout = special_sig ? special_out: {out_sign, out_exp, out_frac};
assign special_out = r_special_state_s2[5] ? 32'hFFFFFFFF:
                     r_special_state_s2[4] ? 32'h7FFFFFFF :
                     r_special_state_s2[7] ? 32'h7F800000 :
                     r_special_state_s2[6] ? 32'hFF800000 :
                     r_special_state_s2[1] ? 32'h3F800000 : 
                     r_special_state_s2[0] ? 32'hbf800000 :
                     (r_special_state_s2[3] || (compute_zero && r_act_func_s2 && r_out_sign_s2)) ? 32'h80000000 : 
                     (r_act_func_s2 && r_special_large_sig_s2) ? {r_exp_shift_s2[4:0], r_mul_out_s2[26:0]} : 32'h00000000; //TODO:优先级
assign special_sig = (|r_special_state_s2) |  (log2_zero && r_func_s2[3]) | compute_zero | (r_act_func_s2 && r_special_large_sig_s2);
endmodule
