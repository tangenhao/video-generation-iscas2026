module CSA_35b(
  a, b, c, sum, cry
);

input      [34:0] a;
input      [34:0] b;
input      [34:0] c;
output wire[34:0] sum;
output wire[34:0] cry;
  
assign sum = a ^ b ^ c;
assign   cry  = (a & b) | ((a | b)& c);
  
endmodule