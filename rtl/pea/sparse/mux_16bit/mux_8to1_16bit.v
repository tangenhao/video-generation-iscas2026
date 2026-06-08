module mux_8to1_16bit (
  mask,
  data,
  out
);

input [7:0] mask;
input [127:0] data;
output [15:0] out;

wire [15:0] mux_0_res;
wire [15:0] mux_1_res;

mux_4to1_16bit u_mux_0 (
  .mask(mask[3:0]),
  .data(data[63:0]),
  .out(mux_0_res)
);

mux_4to1_16bit u_mux_1 (
  .mask(mask[7:4]),
  .data(data[127:64]),
  .out(mux_1_res)
);

assign out = |mask[7:4] ? mux_1_res : 
             |mask[3:0] ? mux_0_res : 0;
endmodule
