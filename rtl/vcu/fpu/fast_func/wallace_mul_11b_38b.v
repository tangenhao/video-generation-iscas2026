module wallace_mul_11b_38b(
  a, b,
  o

);
input       [37:0] a;
input       [10:0] b;
output wire [48:0] o;

wire [48:0] c[10:0];

assign c[0] = ({38{b[0]}} & a) << 0; 
assign c[1] = ({38{b[1]}} & a) << 1; 
assign c[2] = ({38{b[2]}} & a) << 2; 
assign c[3] = ({38{b[3]}} & a) << 3; 
assign c[4] = ({38{b[4]}} & a) << 4; 
assign c[5] = ({38{b[5]}} & a) << 5; 
assign c[6] = ({38{b[6]}} & a) << 6; 
assign c[7] = ({38{b[7]}} & a) << 7; 
assign c[8] = ({38{b[8]}} & a) << 8; 
assign c[9] = ({38{b[9]}} & a) << 9; 
assign c[10] = ({38{b[10]}} & a) << 10; 

wire [48:0] sum0;
wire [48:0] sum1;
wire [48:0] sum2;
wire [48:0] sum3;
wire [48:0] sum4;
wire [48:0] sum5;
wire [48:0] sum6;
wire [48:0] sum7;
wire [48:0] sum8;

wire [48:0] carry0;
wire [48:0] carry1;
wire [48:0] carry2;
wire [48:0] carry3;
wire [48:0] carry4;
wire [48:0] carry5;
wire [48:0] carry6;
wire [48:0] carry7;
wire [48:0] carry8;

//--------------------------------------
CSA_49b CSA_49b_0(
  .a(c[0]),
  .b(c[1]),
  .c(c[2]),
  .sum(sum0),
  .cry(carry0)
);

CSA_49b CSA_49b_1(
  .a(c[3]),
  .b(c[4]),
  .c(c[5]),
  .sum(sum1),
  .cry(carry1)
);

CSA_49b CSA_49b_2(
  .a(c[6]),
  .b(c[7]),
  .c(c[8]),
  .sum(sum2),
  .cry(carry2)
);

//-----------------------------------

CSA_49b CSA_49b_3(
  .a(sum0),
  .b(sum1),
  .c(sum2),
  .sum(sum3),
  .cry(carry3)
);

CSA_49b CSA_49b_4(
  .a(carry0 << 1),
  .b(carry1 << 1),
  .c(carry2 << 1),
  .sum(sum4),
  .cry(carry4)
);

//-------------------------------------
CSA_49b CSA_49b_5(
  .a(sum3),
  .b(carry3 << 1),
  .c(sum4),
  .sum(sum5),
  .cry(carry5)
);


CSA_49b CSA_49b_6(
  .a(carry4 << 1),
  .b(c[9]),
  .c(c[10]),
  .sum(sum6),
  .cry(carry6)
);

//-------------------------------------

CSA_49b CSA_49b_7(
  .a(sum5),
  .b(carry5 << 1),
  .c(sum6),
  .sum(sum7),
  .cry(carry7)
);

//-------------------------------------
CSA_49b CSA_49b_8(
  .a(sum7),
  .b(carry7 << 1),
  .c(carry6 << 1),
  .sum(sum8),
  .cry(carry8)
);

//----------------------
// adder_49bit adder_49bit_0(
//   .a(sum8), 
//   .b(carry8<<1),
//   .o(o)
// );

assign o = sum8 + (carry8<<1);
endmodule