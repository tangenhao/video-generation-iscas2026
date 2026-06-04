module adder_16_12(
  signed_,
  a, b,
  s
);

input              signed_;
input       [11:0] a;
input       [11:0] b;
output wire [15:0] s;

wire [15:0] real_a;
wire [15:0] real_b;

assign real_a = {{4{a[11] & signed_}}, a};
assign real_b = {b, 4'b0};

assign s = real_a + real_b;

endmodule