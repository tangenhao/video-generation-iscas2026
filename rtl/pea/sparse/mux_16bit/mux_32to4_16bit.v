module mux_32to4_16bit (
  mask,
  data,
  out
);

input [31:0] mask;
input [511:0] data;
output [63:0] out;

wire [31:0] mask_0_sel;
wire [31:0] mask_1_sel;
wire [31:0] mask_2_sel;
wire [31:0] mask_3_sel;

and_minus #(.width(32)) u_and_minus_0 (
  .in(mask),
  .out(mask_0_sel)
);

and_minus #(.width(32)) u_and_minus_1 (
  .in(mask_0_sel ^ mask),
  .out(mask_1_sel)
);

and_minus #(.width(32)) u_and_minus_2 (
  .in(mask_1_sel ^ mask_0_sel),
  .out(mask_2_sel)
);

and_minus #(.width(32)) u_and_minus_3 (
  .in(mask_2_sel ^ mask_1_sel),
  .out(mask_3_sel)
);

mux_32to1_16bit u_mux_0 (
  .mask(mask_0_sel),
  .data(data),
  .out(out[15:0])
);

mux_32to1_16bit u_mux_1 (
  .mask(mask_1_sel),
  .data(data),
  .out(out[31:16])
);

mux_32to1_16bit u_mux_2 (
  .mask(mask_2_sel),
  .data(data),
  .out(out[47:32])
);

mux_32to1_16bit u_mux_3 (
  .mask(mask_3_sel),
  .data(data),
  .out(out[63:48])
);

endmodule
