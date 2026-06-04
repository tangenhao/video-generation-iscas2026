module mux_16to1_1bit (
  mask,
  data,
  out
);

input [15:0] mask;
input [15:0] data;
output out;

wire mux_0_res;
wire mux_1_res;
wire mux_2_res;
wire mux_3_res;

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

mux_4to1_1bit u_mux_2 (
  .mask(mask[11:8]),
  .data(data[11:8]),
  .out(mux_2_res)
);

mux_4to1_1bit u_mux_3 (
  .mask(mask[15:12]),
  .data(data[15:12]),
  .out(mux_3_res)
);

assign out = |mask[15:12] ? mux_3_res : 
             |mask[15:12] ? mux_2_res : 
             |mask[11:8] ? mux_1_res : 
             |mask[3:0] ? mux_0_res : 0;
endmodule
