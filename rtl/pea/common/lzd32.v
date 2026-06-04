module lzd32(
  data, zcnt, full
);

input  [31:0] data;
output [4:0]  zcnt;
output        full;

wire [2:0] zcnt_l0[0:3];
wire [3:0] full_l0;

lzd8 u_lzd8_l0_0(
  .data(data[7:0]),
  .zcnt(zcnt_l0[0]),
  .full(full_l0[0])
);

lzd8 u_lzd8_l0_1(
  .data(data[15:8]),
  .zcnt(zcnt_l0[1]),
  .full(full_l0[1])
);

lzd8 u_lzd8_l0_2(
  .data(data[23:16]),
  .zcnt(zcnt_l0[2]),
  .full(full_l0[2])
);

lzd8 u_lzd8_l0_3(
  .data(data[31:24]),
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

assign zcnt[4:3] = zcnt_l1;

assign zcnt[2:0] = full_l0[3] ? full_l0[2] ? full_l0[1] ? zcnt_l0[0] : zcnt_l0[1] : zcnt_l0[2] : zcnt_l0[3];

assign full = full_l1;

endmodule