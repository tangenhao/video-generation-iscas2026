module mux_16to4_1bit (
  mask,
  data,
  out
);

input [15:0] mask;
input [15:0] data;
output [3:0] out;

wire [15:0] mask_0_sel;
wire [15:0] mask_1_sel;
wire [15:0] mask_2_sel;
wire [15:0] mask_3_sel;

and_minus #(.width(16)) u_and_minus_0 (
  .in(mask),
  .out(mask_0_sel)
);

and_minus #(.width(16)) u_and_minus_1 (
  .in(mask_0_sel ^ mask),
  .out(mask_1_sel)
);

and_minus #(.width(16)) u_and_minus_2 (
  .in(mask_1_sel ^ mask_0_sel),
  .out(mask_2_sel)
);

and_minus #(.width(16)) u_and_minus_3 (
  .in(mask_2_sel ^ mask_1_sel),
  .out(mask_3_sel)
);

mux_16to1_1bit u_mux_0 (
  .mask(mask_0_sel),
  .data(data),
  .out(out[0])
);

mux_16to1_1bit u_mux_1 (
  .mask(mask_1_sel),
  .data(data),
  .out(out[1])
);

mux_16to1_1bit u_mux_2 (
  .mask(mask_2_sel),
  .data(data),
  .out(out[2])
);

mux_16to1_1bit u_mux_3 (
  .mask(mask_3_sel),
  .data(data),
  .out(out[3])
);

endmodule
