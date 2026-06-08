module mux_16to1_8bit (
  mask,
  data,
  out
);

input [15:0] mask;
input [127:0] data;
output [7:0] out;

wire [7:0] mux_0_res;
wire [7:0] mux_1_res;
wire [7:0] mux_2_res;
wire [7:0] mux_3_res;

mux_4to1_8bit u_mux_0 (
  .mask(mask[3:0]),
  .data(data[31:0]),
  .out(mux_0_res)
);

mux_4to1_8bit u_mux_1 (
  .mask(mask[7:4]),
  .data(data[63:32]),
  .out(mux_1_res)
);

mux_4to1_8bit u_mux_2 (
  .mask(mask[11:8]),
  .data(data[95:64]),
  .out(mux_2_res)
);

mux_4to1_8bit u_mux_3 (
  .mask(mask[15:12]),
  .data(data[127:96]),
  .out(mux_3_res)
);

assign out = |mask[15:12] ? mux_3_res : 
             |mask[15:12] ? mux_2_res : 
             |mask[11:8] ? mux_1_res : 
             |mask[3:0] ? mux_0_res : 0;
endmodule
