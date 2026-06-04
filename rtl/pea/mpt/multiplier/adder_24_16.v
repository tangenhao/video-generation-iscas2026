module adder_24_16(
  signed_,
  a, b,
  s
);

input              signed_;
input       [15:0] a;
input       [15:0] b;
output wire [23:0] s;

wire [23:0] real_a;
wire [23:0] real_b;

assign real_a = {{8{a[15] & signed_}}, a};
assign real_b = {b, 8'b0};

assign s = real_a + real_b;

endmodule
