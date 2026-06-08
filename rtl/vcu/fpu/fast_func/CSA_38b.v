module CSA_38b(
  a, b, c, sum, cry
);

input       [37:0] a;
input       [37:0] b;
input       [37:0] c;
output wire [37:0] sum;
output wire [37:0] cry;

assign sum = a ^ b ^ c;
assign cry = (a & b) | ((a | b)& c);


endmodule