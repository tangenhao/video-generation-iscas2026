module adder_32_24(
  a, b,
  s
);

input wire [23:0] a;
input wire [23:0] b;
output wire [31:0] s;

assign s = {{8{a[23]}}, a} + {b, 8'b0};

endmodule