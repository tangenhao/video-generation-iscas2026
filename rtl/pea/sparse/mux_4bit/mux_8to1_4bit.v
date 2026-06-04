module mux_8to1_4bit (
  mask,
  data,
  out
);

input [7:0] mask;
input [31:0] data;
output [3:0] out;

wire [3:0] mux_0_res;
wire [3:0] mux_1_res;

mux_4to1_4bit u_mux_0 (
  .mask(mask[3:0]),
  .data(data[15:0]),
  .out(mux_0_res)
);

mux_4to1_4bit u_mux_1 (
  .mask(mask[7:4]),
  .data(data[31:16]),
  .out(mux_1_res)
);

assign out = |mask[7:4] ? mux_1_res : 
             |mask[3:0] ? mux_0_res : 0;
endmodule
