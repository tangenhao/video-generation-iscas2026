module interpolor(
  clk, rst_n, 
  opcode, para_data,
  data_in, out
);

localparam SIN      = 6'b001000;
localparam COS      = 6'b001001;
localparam REC      = 6'b001010;
localparam LOG      = 6'b001011;
localparam EXP      = 6'b001100;
localparam RSQRT    = 6'b001101;
localparam FTANH    = 6'b100010;
localparam FSIGMOID = 6'b100011;
localparam FSIWSH   = 6'b100100;
localparam FMISH    = 6'b100101;
localparam FGELU    = 6'b100110;

input          clk;
input          rst_n;
input  [5:0]   opcode;
input  [18:0]  data_in;
output [63:0]  out;
input  [63:0]  para_data;

// wire [51:0] para;
wire [24:0] c0;
wire [15:0] c1;
wire [10:0] c2;

wire [37:0] x2;
wire [34:0] c1_x;   // 16 + 19 = 35  
wire [48:0] c2_x2;  // 11 + 38 = 49  
wire [2:0]  neg_basic;
wire [2:0]  neg_activation;
wire [2:0]  neg;

wire [63:0] c0_shift;
wire [63:0] c1_x_shift;
wire [63:0] c2_x2_shift;

wire [63:0] c0_shift_sign;
wire [63:0] c1_x_shift_sign;
wire [63:0] c2_x2_shift_sign;

wire [63:0] sum;
wire [63:0] carry;
wire [63:0] carry_mul_2;

reg [5:0] opcode_reg;
reg [18:0] x_reg;
reg [37:0] x2_reg;
reg [24:0] c0_reg;
reg [15:0] c1_reg;
reg [10:0] c2_reg;
// reg [63:0] sum_reg ;
// reg [63:0] carry_mul_2_reg;
reg [2:0] neg_reg;
reg [2:0] neg_reg_reg;

reg [63:0] c0_shift_reg;
reg [63:0] c1_x_shift_reg;
reg [63:0] c2_x2_shift_reg;


assign c0 = para_data[51:27];
assign c1 = para_data[26:11];
assign c2 = para_data[10:0];

assign neg_basic = ( {3{(opcode == SIN) | (opcode == COS) |(opcode == LOG) }} & 3'b001) | ( {3{(opcode == REC) | (opcode == RSQRT)}} & 3'b010 ) | ( {3{(opcode == EXP)}} & 3'b000) ;
assign neg_activation = para_data[54:52];
assign neg = ( {3{~opcode[5]}} & neg_basic) | ( {3{opcode[5]}} & neg_activation);

wallace_mul_16b_19b wallace_mul_16b_19b_0(
  .a(c1_reg),
  .b(x_reg),
  .o(c1_x)
);

wallace_mul_11b_38b wallace_mul_11b_38b_0(
  .a(x2_reg),
  .b(c2_reg),
  .o(c2_x2)
);


// assign c1_x = (c1_reg[7:0] * x_reg[9:0]) + ( (c1_reg[15:8] * x_reg[9:0]) << 8) + ((c1_reg[7:0] * x_reg[18:10]) << 10) + ( (c1_reg[15:8] * x_reg[18:10]) << 18) ;
// assign c2_x2 = (c2_reg[4:0] * x2_reg[18:0]) + ((c2_reg[10:5] * x2_reg[18:0]) << 5) + ((c2_reg[4:0] * x2_reg[37:19]) << 19) + ((c2_reg[10:5] * x2_reg[37:19]) << 24);

// assign c0_shift = c0_reg << 38;
// assign c1_x_shift = (opcode_reg == RSQRT) ? (c1_x << 22) : (c1_x << 21);
// assign c2_x2_shift = (opcode_reg == RSQRT) ? (c2_x2 << 2) : c2_x2;

assign c0_shift = ({64{opcode_reg[5]}} & ({6'd0, c0_reg, 33'd0})) |  ({64{~opcode_reg[5]}} & ({1'd0, c0_reg, 38'd0}));
assign c1_x_shift = ({64{(opcode_reg == RSQRT) & (~opcode_reg[5])}} &  ({7'd0, c1_x, 22'd0}) )| 
                    ( {64{(~(opcode_reg == RSQRT)) & (~opcode_reg[5])}} & ({8'd0, c1_x, 21'd0})) |
                    ( {64{opcode_reg[5]}} & ({9'd0, c1_x, 20'd0}));
assign c2_x2_shift = ({64{(opcode_reg == RSQRT)}} & ({13'd0, c2_x2, 2'd0}) )| ( {64{~(opcode_reg == RSQRT)}} & {15'd0, c2_x2});

//assign c0_shift_sign = neg_reg[2] ? ( (~c0_shift) + 1 ) : c0_shift ; 

// assign c0_shift_sign = c0_shift ; 
// assign c1_x_shift_sign = neg_reg[1] ? ( (~c1_x_shift) + 1 ) : c1_x_shift ; 
// assign c2_x2_shift_sign = neg_reg[0] ? ( (~c2_x2_shift) + 1 ) : c2_x2_shift ; 

// assign c0_shift_sign = c0_shift_reg ; 
// assign c1_x_shift_sign = neg_reg[1] ? ( (~c1_x_shift_reg) + 1 ) : c1_x_shift_reg ; 
// assign c2_x2_shift_sign = neg_reg[0] ? ( (~c2_x2_shift_reg) + 1 ) : c2_x2_shift_reg ; 

assign c0_shift_sign =    ( {64{neg_reg_reg[2]}} & ( (~c0_shift_reg) + 1 ) ) | ( {64{~neg_reg_reg[2]}} &  c0_shift_reg ) ;  //c0 +
assign c1_x_shift_sign =  ( {64{neg_reg_reg[1]}} & ( (~c1_x_shift_reg) + 1 ) ) | ( {64{~neg_reg_reg[1]}} & c1_x_shift_reg) ; 
assign c2_x2_shift_sign = ( {64{neg_reg_reg[0]}} & ( (~c2_x2_shift_reg) + 1 ) ) | ( {64{~neg_reg_reg[0]}} & c2_x2_shift_reg); 

// wire [63:0] c1_x_shift_comp;
// wire [63:0] c2_x2_shift_comp;

// assign c0_shift_sign = c0_shift ;  //c0 +
// assign c1_x_shift_sign =   ( {64{neg_reg[1]}} & c1_x_shift_comp) | ( {64{~neg_reg[1]}} & c1_x_shift) ; 
// assign c2_x2_shift_sign = ( {64{neg_reg[0]}} & c2_x2_shift_comp) | ( {64{~neg_reg[0]}} & c2_x2_shift); 


// accu_adder_64bit accu_adder_64bit_0(
//     .a(c1_x_shift), 
//     .o(c1_x_shift_comp)
// );

// accu_adder_64bit accu_adder_64bit_1(
//     .a(c2_x2_shift), 
//     .o(c2_x2_shift_comp)
// );

// adder_64bit adder_64bit_0(
//   .a(~c1_x_shift), 
//   .b({63'b0,1'b1}),
//   .o(c1_x_shift_comp)
// );

// adder_64bit adder_64bit_1(
//   .a(~c2_x2_shift), 
//   .b({63'b0,1'b1}),
//   .o(c2_x2_shift_comp)
// );

assign carry_mul_2 = carry << 1;

// para_lut para_lut_0(
//     .index(index),
//     .opcode(opcode),
//     .para(para)
// );

squarer squarer_0(
  .a(data_in), 
  .square_out(x2)
);

CSA_64b CSA_64b_0(
	.a(c0_shift_sign),
	.b(c1_x_shift_sign),
	.c(c2_x2_shift_sign),
	.sum(sum),
	.cry(carry)
);


// adder_64bit adder_64bit_2(
//   .a(sum_reg), 
//   .b(carry_mul_2_reg),
//   .o(out)
// );

assign out = sum + carry_mul_2;
// assign out = sum_reg + carry_mul_2_reg;

// always@(posedge clk or negedge rst_n) begin
//     if(!rst_n) begin
//         x_reg  <= 'd0;
//         x2_reg <= 'd0;
//         c0_reg <= 'd0;
//         c1_reg <= 'd0;
//         c2_reg <= 'd0;
//         neg_reg <= 'd0;
//         opcode_reg <= 'd0;
//         sum_reg <= 'd0;
//         carry_mul_2_reg <= 'd0;
//     end
//     else begin
//         x_reg  <= data_in;
//         x2_reg <= x2;
//         c0_reg <= c0;
//         c1_reg <= c1;
//         c2_reg <= c2;
//         neg_reg <= neg;
//         opcode_reg <= opcode;
//         sum_reg <= sum;
//         carry_mul_2_reg <= carry_mul_2;
//     end
// end

always@(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    x_reg  <= 'd0;
    x2_reg <= 'd0;
    c0_reg <= 'd0;
    c1_reg <= 'd0;
    c2_reg <= 'd0;
    neg_reg <= 'd0;
    opcode_reg <= 'd0;
    c0_shift_reg <= 'd0;
    c1_x_shift_reg <= 'd0;
    c2_x2_shift_reg <= 'd0;
    neg_reg_reg <= 'd0;
  end
  else begin
    x_reg  <= data_in;
    x2_reg <= x2;
    c0_reg <= c0;
    c1_reg <= c1;
    c2_reg <= c2;
    neg_reg <= neg;
    opcode_reg <= opcode;
    c0_shift_reg <= c0_shift;
    c1_x_shift_reg <= c1_x_shift;
    c2_x2_shift_reg <= c2_x2_shift;
    neg_reg_reg <= neg_reg;
  end
end



endmodule