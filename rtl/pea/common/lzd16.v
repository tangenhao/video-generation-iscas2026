module lzd16(
  data, zcnt, full
);

input  [15:0] data;
output [3:0] zcnt;
output       full;

wire [1:0] zcnt_l0[0:3];
wire [3:0] full_l0;

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

lzd4 u_lzd4_l0_2(
  .data(data[11:8]),
  .zcnt(zcnt_l0[2]),
  .full(full_l0[2])
);

lzd4 u_lzd4_l0_3(
  .data(data[15:12]),
  .zcnt(zcnt_l0[3]),
  .full(full_l0[3])
);

wire [1:0] zcnt_l1;
wire full_l1;

lzd4 u_lzd4_l1(
  .data(~full_l0),
  .zcnt(zcnt_l1),
  .full(full_l1)
);

assign zcnt[3:2] = zcnt_l1;

assign zcnt[1:0] = full_l0[3] ? full_l0[2] ? (full_l0[1] ? zcnt_l0[0] : zcnt_l0[1]) : 
                                              zcnt_l0[2] : 
                                zcnt_l0[3];

assign full = full_l1;

endmodule