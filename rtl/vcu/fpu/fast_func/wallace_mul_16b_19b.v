module wallace_mul_16b_19b(
  a, b,
  o
);

input       [15:0] a;
input       [18:0] b;
output wire [34:0] o;

wire [34:0] c[18:0];

assign c[0] = ({16{b[0]}} & a) << 0; 
assign c[1] = ({16{b[1]}} & a) << 1; 
assign c[2] = ({16{b[2]}} & a) << 2; 
assign c[3] = ({16{b[3]}} & a) << 3; 
assign c[4] = ({16{b[4]}} & a) << 4; 
assign c[5] = ({16{b[5]}} & a) << 5; 
assign c[6] = ({16{b[6]}} & a) << 6; 
assign c[7] = ({16{b[7]}} & a) << 7; 
assign c[8] = ({16{b[8]}} & a) << 8; 
assign c[9] = ({16{b[9]}} & a) << 9; 
assign c[10] = ({16{b[10]}} & a) << 10; 
assign c[11] = ({16{b[11]}} & a) << 11; 
assign c[12] = ({16{b[12]}} & a) << 12; 
assign c[13] = ({16{b[13]}} & a) << 13; 
assign c[14] = ({16{b[14]}} & a) << 14; 
assign c[15] = ({16{b[15]}} & a) << 15; 
assign c[16] = ({16{b[16]}} & a) << 16; 
assign c[17] = ({16{b[17]}} & a) << 17; 
assign c[18] = ({16{b[18]}} & a) << 18; 

wire [34:0] sum0;
wire [34:0] sum1;
wire [34:0] sum2;
wire [34:0] sum3;
wire [34:0] sum4;
wire [34:0] sum5;
wire [34:0] sum6;
wire [34:0] sum7;
wire [34:0] sum8;
wire [34:0] sum9;
wire [34:0] sum10;
wire [34:0] sum11;
wire [34:0] sum12;
wire [34:0] sum13;
wire [34:0] sum14;
wire [34:0] sum15;
wire [34:0] sum16;

wire [34:0] carry0;
wire [34:0] carry1;
wire [34:0] carry2;
wire [34:0] carry3;
wire [34:0] carry4;
wire [34:0] carry5;
wire [34:0] carry6;
wire [34:0] carry7;
wire [34:0] carry8;
wire [34:0] carry9;
wire [34:0] carry10;
wire [34:0] carry11;
wire [34:0] carry12;
wire [34:0] carry13;
wire [34:0] carry14;
wire [34:0] carry15;
wire [34:0] carry16;

//--------------------------------------
CSA_35b CSA_35b_0(
  .a(c[0]),
  .b(c[1]),
  .c(c[2]),
  .sum(sum0),
  .cry(carry0)
);

CSA_35b CSA_35b_1(
  .a(c[3]),
  .b(c[4]),
  .c(c[5]),
  .sum(sum1),
  .cry(carry1)
);

CSA_35b CSA_35b_2(
  .a(c[6]),
  .b(c[7]),
  .c(c[8]),
  .sum(sum2),
  .cry(carry2)
);

CSA_35b CSA_35b_3(
  .a(c[9]),
  .b(c[10]),
  .c(c[11]),
  .sum(sum3),
  .cry(carry3)
);

CSA_35b CSA_35b_4(
  .a(c[12]),
  .b(c[13]),
  .c(c[14]),
  .sum(sum4),
  .cry(carry4)
);

CSA_35b CSA_35b_5(
  .a(c[15]),
  .b(c[16]),
  .c(c[17]),
  .sum(sum5),
  .cry(carry5)
);


//-------------------------------

CSA_35b CSA_35b_6(
  .a(sum0),
  .b(sum1),
  .c(sum2),
  .sum(sum6),
  .cry(carry6)
);

CSA_35b CSA_35b_7(
  .a(sum3),
  .b(sum4),
  .c(sum5),
  .sum(sum7),
  .cry(carry7)
);


CSA_35b CSA_35b_8(
  .a(carry0 << 1),
  .b(carry1 << 1),
  .c(carry2 << 1),
  .sum(sum8),
  .cry(carry8)
);

CSA_35b CSA_35b_9(
  .a(carry3 << 1),
  .b(carry4 << 1),
  .c(carry5 << 1),
  .sum(sum9),
  .cry(carry9)
);

//----------------------------------
CSA_35b CSA_35b_10(
  .a(sum6),
  .b(sum7),
  .c(sum8),
  .sum(sum10),
  .cry(carry10)
);

CSA_35b CSA_35b_11(
  .a(carry6 << 1),
  .b(carry7 << 1),
  .c(carry8 << 1),
  .sum(sum11),
  .cry(carry11)
);

CSA_35b CSA_35b_12(
  .a(sum9),
  .b(carry9 << 1),
  .c(c[18]),
  .sum(sum12),
  .cry(carry12)
);

//-------------------------------

CSA_35b CSA_35b_13(
  .a(sum10),
  .b(carry10 << 1),
  .c(sum11),
  .sum(sum13),
  .cry(carry13)
);

CSA_35b CSA_35b_14(
  .a(carry11 << 1),
  .b(sum12 ),
  .c(carry12 << 1),
  .sum(sum14),
  .cry(carry14)
);

//--------------------
CSA_35b CSA_35b_15(
  .a(sum13),
  .b(carry13 << 1),
  .c(sum14),
  .sum(sum15),
  .cry(carry15)
);

//---------------------
CSA_35b CSA_35b_16(
  .a(sum15),
  .b(carry15 << 1),
  .c(carry14 << 1),
  .sum(sum16),
  .cry(carry16)
);

//----------------------

// adder_35bit adder_35bit_0(
//   .a(sum16), 
//   .b(carry16<<1),
//   .o(o)
// );

assign o = sum16 + (carry16<<1);

endmodule