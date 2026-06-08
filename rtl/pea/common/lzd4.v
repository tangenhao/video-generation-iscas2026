module lzd4(
  data, zcnt, full
);

input  [3:0] data;
output [1:0] zcnt;
output       full;

assign zcnt = data[3] ? 2'b00 : data[2] ? 2'b01 : data[1] ? 2'b10 : data[0] ? 2'b11 : 2'b00;

assign full = ~(|data);

endmodule