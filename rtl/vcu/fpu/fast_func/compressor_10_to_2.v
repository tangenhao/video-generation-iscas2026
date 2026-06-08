module compressor_10_to_2(
  a, b, c, d, e, f, g, h, i, j, sum, cry
);

input       [37:0] a;
input       [37:0] b;
input       [37:0] c;
input       [37:0] d;
input       [37:0] e;
input       [37:0] f;
input       [37:0] g;
input       [37:0] h;
input       [37:0] i;
input       [37:0] j;
output wire [37:0] sum;
output wire [37:0] cry;

wire[37:0] sum1;
wire[37:0] cry1;
wire[37:0] sum2;
wire[37:0] cry2;
wire[37:0] sum3;
wire[37:0] cry3;
wire[37:0] sum4;
wire[37:0] cry4;
wire[37:0] sum5;
wire[37:0] cry5;
wire[37:0] sum6;
wire[37:0] cry6;
wire[37:0] sum7;
wire[37:0] cry7;

wire[37:0] cry1_mul2;
wire[37:0] cry2_mul2;
wire[37:0] cry3_mul2;
wire[37:0] cry4_mul2;
wire[37:0] cry5_mul2;
wire[37:0] cry6_mul2;
wire[37:0] cry7_mul2;
  
assign  cry1_mul2 = 2*cry1;
assign  cry2_mul2 = 2*cry2;
assign  cry3_mul2 = 2*cry3;
assign  cry4_mul2 = 2*cry4;
assign  cry5_mul2 = 2*cry5;
assign  cry6_mul2 = 2*cry6;
assign  cry7_mul2 = 2*cry7;

CSA_38b csa1(
  .a(a),
  .b(b),
  .c(c),
  .sum(sum1),
  .cry(cry1)
);

CSA_38b csa2(
  .a(d),
  .b(e),
  .c(f),
  .sum(sum2),
  .cry(cry2)
);

CSA_38b csa3(
  .a(g),
  .b(h),
  .c(i),
  .sum(sum3),
  .cry(cry3)
);

//--------------------------------
CSA_38b csa4(
  .a(sum1),
  .b(cry1_mul2),
  .c(j),
  .sum(sum4),
  .cry(cry4)
);
      
CSA_38b csa5(.a(sum2),
	.b(cry2_mul2),
	.c(sum3),
	.sum(sum5),
	.cry(cry5)
);  

//--------------------------------
CSA_38b csa6(
  .a(sum4),
  .b(cry4_mul2),
  .c(sum5),
  .sum(sum6),
  .cry(cry6)
);

//--------------------------------
CSA_38b csa7(
  .a(sum6),
  .b(cry6_mul2),
  .c(cry5_mul2),
  .sum(sum7),
  .cry(cry7)
);  

//--------------------------------
CSA_38b csa8(
  .a(sum7),
  .b(cry7_mul2),
  .c(cry3_mul2),
  .sum(sum),
  .cry(cry)
);

endmodule
