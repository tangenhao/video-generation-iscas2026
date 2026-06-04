module mux_8to1_1bit (
  mask,
  data,
  out
);

input [7:0] mask;
input [7:0] data;
output out;

wire mux_0_res;
wire mux_1_res;

mux_4to1_1bit u_mux_0 (
  .mask(mask[3:0]),
  .data(data[3:0]),
  .out(mux_0_res)
);

mux_4to1_1bit u_mux_1 (
  .mask(mask[7:4]),
  .data(data[7:4]),
  .out(mux_1_res)
);

assign out = |mask[7:4] ? mux_1_res : 
             |mask[3:0] ? mux_0_res : 0;
endmodule
