module mux_32to16_4bit (
  mask,
  data,
  out
);

input [31:0] mask;
input [127:0] data;
output [63:0] out;

wire [31:0] mask_0_sel;
wire [31:0] mask_1_sel;
wire [31:0] mask_2_sel;
wire [31:0] mask_3_sel;
wire [31:0] mask_4_sel;
wire [31:0] mask_5_sel;
wire [31:0] mask_6_sel;
wire [31:0] mask_7_sel;
wire [31:0] mask_8_sel;
wire [31:0] mask_9_sel;
wire [31:0] mask_10_sel;
wire [31:0] mask_11_sel;
wire [31:0] mask_12_sel;
wire [31:0] mask_13_sel;
wire [31:0] mask_14_sel;
wire [31:0] mask_15_sel;

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

and_minus #(.width(32)) u_and_minus_4 (
  .in(mask_3_sel ^ mask_2_sel),
  .out(mask_4_sel)
);

and_minus #(.width(32)) u_and_minus_5 (
  .in(mask_4_sel ^ mask_3_sel),
  .out(mask_5_sel)
);

and_minus #(.width(32)) u_and_minus_6 (
  .in(mask_5_sel ^ mask_4_sel),
  .out(mask_6_sel)
);

and_minus #(.width(32)) u_and_minus_7 (
  .in(mask_6_sel ^ mask_5_sel),
  .out(mask_7_sel)
);

and_minus #(.width(32)) u_and_minus_8 (
  .in(mask_7_sel ^ mask_6_sel),
  .out(mask_8_sel)
);

and_minus #(.width(32)) u_and_minus_9 (
  .in(mask_8_sel ^ mask_7_sel),
  .out(mask_9_sel)
);

and_minus #(.width(32)) u_and_minus_10 (
  .in(mask_9_sel ^ mask_8_sel),
  .out(mask_10_sel)
);

and_minus #(.width(32)) u_and_minus_11 (
  .in(mask_10_sel ^ mask_9_sel),
  .out(mask_11_sel)
);

and_minus #(.width(32)) u_and_minus_12 (
  .in(mask_11_sel ^ mask_10_sel),
  .out(mask_12_sel)
);

and_minus #(.width(32)) u_and_minus_13 (
  .in(mask_12_sel ^ mask_11_sel),
  .out(mask_13_sel)
);

and_minus #(.width(32)) u_and_minus_14 (
  .in(mask_13_sel ^ mask_12_sel),
  .out(mask_14_sel)
);

and_minus #(.width(32)) u_and_minus_15 (
  .in(mask_14_sel ^ mask_13_sel),
  .out(mask_15_sel)
);

mux_32to1_4bit u_mux_0 (
  .mask(mask_0_sel),
  .data(data),
  .out(out[3:0])
);

mux_32to1_4bit u_mux_1 (
  .mask(mask_1_sel),
  .data(data),
  .out(out[7:4])
);

mux_32to1_4bit u_mux_2 (
  .mask(mask_2_sel),
  .data(data),
  .out(out[11:8])
);

mux_32to1_4bit u_mux_3 (
  .mask(mask_3_sel),
  .data(data),
  .out(out[15:12])
);

mux_32to1_4bit u_mux_4 (
  .mask(mask_4_sel),
  .data(data),
  .out(out[19:16])
);

mux_32to1_4bit u_mux_5 (
  .mask(mask_5_sel),
  .data(data),
  .out(out[23:20])
);

mux_32to1_4bit u_mux_6 (
  .mask(mask_6_sel),
  .data(data),
  .out(out[27:24])
);

mux_32to1_4bit u_mux_7 (
  .mask(mask_7_sel),
  .data(data),
  .out(out[31:28])
);

mux_32to1_4bit u_mux_8 (
  .mask(mask_8_sel),
  .data(data),
  .out(out[35:32])
);

mux_32to1_4bit u_mux_9 (
  .mask(mask_9_sel),
  .data(data),
  .out(out[39:36])
);

mux_32to1_4bit u_mux_10 (
  .mask(mask_10_sel),
  .data(data),
  .out(out[43:40])
);

mux_32to1_4bit u_mux_11 (
  .mask(mask_11_sel),
  .data(data),
  .out(out[47:44])
);

mux_32to1_4bit u_mux_12 (
  .mask(mask_12_sel),
  .data(data),
  .out(out[51:48])
);

mux_32to1_4bit u_mux_13 (
  .mask(mask_13_sel),
  .data(data),
  .out(out[55:52])
);

mux_32to1_4bit u_mux_14 (
  .mask(mask_14_sel),
  .data(data),
  .out(out[59:56])
);

mux_32to1_4bit u_mux_15 (
  .mask(mask_15_sel),
  .data(data),
  .out(out[63:60])
);

endmodule
