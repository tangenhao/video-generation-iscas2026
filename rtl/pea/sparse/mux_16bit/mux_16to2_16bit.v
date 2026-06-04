module mux_16to2_16bit (
  mask,
  data,
  out
);

input [15:0] mask;
input [255:0] data;
output [31:0] out;

wire [15:0] mask_0_sel;
wire [15:0] mask_1_sel;

and_minus #(.width(16)) u_and_minus_0 (
  .in(mask),
  .out(mask_0_sel)
);

and_minus #(.width(16)) u_and_minus_1 (
  .in(mask_0_sel ^ mask),
  .out(mask_1_sel)
);

mux_16to1_16bit u_mux_0 (
  .mask(mask_0_sel),
  .data(data),
  .out(out[15:0])
);

mux_16to1_16bit u_mux_1 (
  .mask(mask_1_sel),
  .data(data),
  .out(out[31:16])
);

endmodule
