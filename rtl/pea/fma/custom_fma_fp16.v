module custom_fma_fp16(
  clk, rst_n,
  psum, scale,
  o
);

input                     clk;
input                     rst_n;
input       signed [31:0] psum;
input              [15:0] scale;
output wire        [15:0] o;

wire sign_psum;
wire [31:0] true_form_psum;
wire [4:0] lz_psum;
wire [5:0] exp_psum;
wire [31:0] frac_psum;

assign sign_psum = psum[31];
assign true_form_psum = (sign_psum) ? (~psum + 1) : psum;
assign exp_psum = 31 - lz_psum;
assign frac_psum = true_form_psum << lz_psum;

// lzd#(32, 5) u_lzd_psum(
//   .data(true_form_psum),
//   .zcnt(lz_psum),
//   .full()
// );

lzd32 u_lzd_psum(
  .data ( true_form_psum ),
  .zcnt ( lz_psum        ),
  .full (                )
);

wire sign_scale;
wire [4:0] exp_scale;
wire [10:0] frac_scale;

assign sign_scale = scale[15];
assign exp_scale = scale[14:10];
assign frac_scale = {1'b1, scale[9:0]};

wire cal_sign;
wire [7:0] cal_exp;
wire [42:0] cal_frac;

wire cal_zero = (scale[14:0] == 'b0) || (psum == 'b0);

assign cal_sign = sign_scale ^ sign_psum;
// assign cal_exp = cal_zero ? 'd0 : exp_scale + exp_psum + 112;
assign cal_exp = cal_zero ? 'd0 : exp_scale + exp_psum + 111;
assign cal_frac = cal_zero ? 'd0 : frac_scale * frac_psum;

reg cal_sign_reg;
reg [7:0] cal_exp_reg;
reg [42:0] cal_frac_reg;

always @(posedge clk or negedge rst_n)
begin
  if (!rst_n) begin
    cal_sign_reg <= 1'b0;
    cal_exp_reg <= 8'b0;
    cal_frac_reg <= 43'b0;
  end
  else begin
    cal_sign_reg <= cal_sign;
    cal_exp_reg <= cal_exp;
    cal_frac_reg <= cal_frac;
  end
end

wire [4:0] shift_number;
wire signed [8:0] exp_postshift;
wire [7:0] exp_norm;
wire [42:0] frac_postshift;
wire [22:0] frac_norm_fp32;
wire [9:0] frac_norm;

assign shift_number = cal_frac_reg[42:40] == 'd1 ? 'd1 :
                      cal_frac_reg[42:39] == 'd1 ? 'd2 :
                      cal_frac_reg[42:38] == 'd1 ? 'd3 :
                      cal_frac_reg[42:37] == 'd1 ? 'd4 :
                      cal_frac_reg[42:36] == 'd1 ? 'd5 :
                      cal_frac_reg[42:35] == 'd1 ? 'd6 :
                      cal_frac_reg[42:34] == 'd1 ? 'd7 :
                      cal_frac_reg[42:33] == 'd1 ? 'd8 :
                      cal_frac_reg[42:32] == 'd1 ? 'd9 :
                      cal_frac_reg[42:31] == 'd1 ? 'd10 :
                      cal_frac_reg[42:30] == 'd1 ? 'd11 :
                      cal_frac_reg[42:29] == 'd1 ? 'd12 :
                      cal_frac_reg[42:28] == 'd1 ? 'd13 :
                      cal_frac_reg[42:27] == 'd1 ? 'd14 :
                      cal_frac_reg[42:26] == 'd1 ? 'd15 :
                      cal_frac_reg[42:25] == 'd1 ? 'd16 :
                      cal_frac_reg[42:24] == 'd1 ? 'd17 :
                      cal_frac_reg[42:23] == 'd1 ? 'd18 :
                      cal_frac_reg[42:22] == 'd1 ? 'd19 :
                      cal_frac_reg[42:21] == 'd1 ? 'd20 :
                      cal_frac_reg[42:20] == 'd1 ? 'd21 :
                      cal_frac_reg[42:19] == 'd1 ? 'd22 :
                      cal_frac_reg[42:18] == 'd1 ? 'd23 :
                      cal_frac_reg[42:17] == 'd1 ? 'd24 :
                      'd0;
assign exp_postshift = cal_exp_reg - shift_number;
assign frac_postshift = cal_frac_reg << shift_number;
assign frac_norm_fp32 = exp_postshift > 0 ? frac_postshift[42:41] >= 2 ? frac_postshift[41:19] :
                                             frac_postshift[42:41] == 1 ? frac_postshift[40:18] :
                                             frac_postshift[39:17] :
                        frac_postshift >> (-exp_postshift);
assign frac_norm = frac_norm_fp32[22:13];
assign exp_norm = exp_postshift > 0 ? frac_postshift[42:41] >= 2 ? exp_postshift + 2 :
                                       frac_postshift[41:41] == 1 ? exp_postshift + 1 :
                                       exp_postshift : 'd0;

wire [4:0] exp_o;
wire [9:0] frac_o;

// FP16格式：指数范围0-31，偏置为15
// 从FP32指数（偏置127）转换到FP16指数（偏置15）
wire signed [8:0] exp_fp16 = exp_norm - 112;  // 127 - 15 = 112

assign exp_o = exp_fp16 <= 0 ? 5'd0 :           // 下溢
               exp_fp16 >= 31 ? 5'd31 :         // 上溢（无穷大）
               exp_fp16[4:0];
assign frac_o = exp_fp16 >= 31 ? 10'd0 : frac_norm;

assign o = {cal_sign_reg, exp_o, frac_o};
endmodule