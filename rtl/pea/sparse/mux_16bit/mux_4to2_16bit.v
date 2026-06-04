module mux_4to2_16bit (
  mask,
  data,
  out
);

input [3:0] mask;
input [63:0] data;
output [31:0] out;

wire [3:0] mask_0_sel;
wire [3:0] mask_1_sel;

and_minus #(.width(4)) u_and_minus_0 (
  .in(mask),
  .out(mask_0_sel)
);

and_minus #(.width(4)) u_and_minus_1 (
  .in(mask_0_sel ^ mask),
  .out(mask_1_sel)
);

mux_4to1_16bit u_mux_0 (
  .mask(mask_0_sel),
  .data(data),
  .out(out[15:0])
);

mux_4to1_16bit u_mux_1 (
  .mask(mask_1_sel),
  .data(data),
  .out(out[31:16])
);

endmodule
