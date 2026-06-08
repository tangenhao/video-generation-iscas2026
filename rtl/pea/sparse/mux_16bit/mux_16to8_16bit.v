module mux_16to8_16bit (
  mask,
  data,
  out
);

input [15:0] mask;
input [255:0] data;
output [127:0] out;

wire [15:0] mask_0_sel;
wire [15:0] mask_1_sel;
wire [15:0] mask_2_sel;
wire [15:0] mask_3_sel;
wire [15:0] mask_4_sel;
wire [15:0] mask_5_sel;
wire [15:0] mask_6_sel;
wire [15:0] mask_7_sel;

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

and_minus #(.width(16)) u_and_minus_4 (
  .in(mask_3_sel ^ mask_2_sel),
  .out(mask_4_sel)
);

and_minus #(.width(16)) u_and_minus_5 (
  .in(mask_4_sel ^ mask_3_sel),
  .out(mask_5_sel)
);

and_minus #(.width(16)) u_and_minus_6 (
  .in(mask_5_sel ^ mask_4_sel),
  .out(mask_6_sel)
);

and_minus #(.width(16)) u_and_minus_7 (
  .in(mask_6_sel ^ mask_5_sel),
  .out(mask_7_sel)
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

mux_16to1_16bit u_mux_2 (
  .mask(mask_2_sel),
  .data(data),
  .out(out[47:32])
);

mux_16to1_16bit u_mux_3 (
  .mask(mask_3_sel),
  .data(data),
  .out(out[63:48])
);

mux_16to1_16bit u_mux_4 (
  .mask(mask_4_sel),
  .data(data),
  .out(out[79:64])
);

mux_16to1_16bit u_mux_5 (
  .mask(mask_5_sel),
  .data(data),
  .out(out[95:80])
);

mux_16to1_16bit u_mux_6 (
  .mask(mask_6_sel),
  .data(data),
  .out(out[111:96])
);

mux_16to1_16bit u_mux_7 (
  .mask(mask_7_sel),
  .data(data),
  .out(out[127:112])
);

endmodule
