module lzd64(
  data, zcnt, full
);

input  [63:0] data;
output [5:0]  zcnt;
output        full;

wire [3:0] zcnt_l0[0:3];
wire [3:0] full_l0;

lzd16 u_lzd16_l0_0(
  .data(data[15:0]),
  .zcnt(zcnt_l0[0]),
  .full(full_l0[0])
);

lzd16 u_lzd16_l0_1(
  .data(data[31:16]),
  .zcnt(zcnt_l0[1]),
  .full(full_l0[1])
);

lzd16 u_lzd16_l0_2(
  .data(data[47:32]),
  .zcnt(zcnt_l0[2]),
  .full(full_l0[2])
);

lzd16 u_lzd16_l0_3(
  .data(data[63:48]),
  .zcnt(zcnt_l0[3]),
  .full(full_l0[3])
);

wire [1:0] zcnt_l1;
wire full_l1;

lzd4 u_lzd4_l1(
  .data(~full_l0[3:0]),
  .zcnt(zcnt_l1),
  .full(full_l1)
);

assign zcnt[5:4] = zcnt_l1;

assign zcnt[3:0] = full_l0[3] ? full_l0[2] ? full_l0[1] ? zcnt_l0[0] : zcnt_l0[1] : zcnt_l0[2] : zcnt_l0[3];

assign full = full_l1;

endmodule