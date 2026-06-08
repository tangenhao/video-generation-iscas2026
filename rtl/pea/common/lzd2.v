module lzd2(
  data, zcnt, full
);

input  [1:0] data;
output       zcnt;
output       full;

assign zcnt = data[1] ? 1'b0 : data[0] ? 1'b1 : 1'b0;
assign full = ~(|data);

endmodule