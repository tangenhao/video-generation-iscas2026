module CSA_49b(
  a, b, c, sum, cry
);

input       [48:0] a;
input       [48:0] b;
input       [48:0] c;
output wire [48:0] sum;
output wire [48:0] cry;

assign sum = a ^ b ^ c;
assign 	cry	= (a & b) | ((a | b)& c);


endmodule