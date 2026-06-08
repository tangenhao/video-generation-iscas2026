module lzd128(
  data, zcnt, full
);

input  [127:0] data;
output [6:0]  zcnt;
output        full;

wire [5:0] zcnt_l0[0:1];
wire [1:0] full_l0;

lzd64 u_lzd64_l0_0(
  .data(data[63:0]),
  .zcnt(zcnt_l0[0]),
  .full(full_l0[0])
);

lzd64 u_lzd64_l0_1(
  .data(data[127:64]),
  .zcnt(zcnt_l0[1]),
  .full(full_l0[1])
);

wire zcnt_l1;
wire full_l1;

lzd2 u_lzd2_l1(
  .data(~full_l0[1:0]),
  .zcnt(zcnt_l1),
  .full(full_l1)
);

assign zcnt[6] = zcnt_l1;

assign zcnt[5:0] = full_l0[1] ? zcnt_l0[0] : zcnt_l0[1];

assign full = full_l1;

endmodule