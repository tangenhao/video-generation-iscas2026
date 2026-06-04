module adder_12_8(
  signed_,
  a, b,
  s
);

input         signed_;
input [7:0]   a;
input [7:0]   b;
output [11:0] s;

wire [11:0] real_a;
wire [11:0] real_b;

assign real_a = {{4{a[7] & signed_}}, a};
assign real_b = {b, 4'b0};

assign s = real_a + real_b;

endmodule
