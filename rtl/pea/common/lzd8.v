module lzd8(
  data, zcnt, full
);

input  [7:0] data;
output [2:0] zcnt;
output       full;

wire [1:0] zcnt_l0[0:1];
wire [1:0] full_l0;

lzd4 u_lzd4_l0_0(
  .data(data[3:0]),
  .zcnt(zcnt_l0[0]),
  .full(full_l0[0])
);

lzd4 u_lzd4_l0_1(
  .data(data[7:4]),
  .zcnt(zcnt_l0[1]),
  .full(full_l0[1])
);

lzd2 u_lzd2_l1(
  .data(~full_l0),
  .zcnt(zcnt[2]),
  .full(full)
);

assign zcnt[1:0] = full_l0[1] ? zcnt_l0[0] : zcnt_l0[1];

endmodule
