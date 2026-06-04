module mux_16to1_4bit (
  mask,
  data,
  out
);

input [15:0] mask;
input [63:0] data;
output [3:0] out;

wire [3:0] mux_0_res;
wire [3:0] mux_1_res;
wire [3:0] mux_2_res;
wire [3:0] mux_3_res;

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

mux_4to1_4bit u_mux_2 (
  .mask(mask[11:8]),
  .data(data[47:32]),
  .out(mux_2_res)
);

mux_4to1_4bit u_mux_3 (
  .mask(mask[15:12]),
  .data(data[63:48]),
  .out(mux_3_res)
);

assign out = |mask[15:12] ? mux_3_res : 
             |mask[15:12] ? mux_2_res : 
             |mask[11:8] ? mux_1_res : 
             |mask[3:0] ? mux_0_res : 0;
endmodule
