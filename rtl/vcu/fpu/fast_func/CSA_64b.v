module CSA_64b(
  a, b, c, sum, cry
);

input       [63:0] a;
input       [63:0] b;
input       [63:0] c;
output wire [63:0] sum;
output wire [63:0] cry;

assign sum = a ^ b ^ c;
assign cry = (a & b) | ((a | b)& c);

endmodule