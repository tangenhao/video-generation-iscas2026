module full_adder(
  a, b, c_i,
  s, c_o
);

input wire a;
input wire b;
input wire c_i;
output wire s;
output wire c_o;

assign s = a ^ b ^ c_i;
assign c_o = (a ^ b) & c_i | a & b;

endmodule