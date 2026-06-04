module multiplier_int4(
  a, b, o
);

input       signed [4:0] a;
input       signed [4:0] b;
output wire signed [7:0] o;

assign o = a * b;

endmodule