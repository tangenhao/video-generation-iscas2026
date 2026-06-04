module sparse_selector_32_16bit (
  mask,
  data,
  out
);

input [31:0] mask;
input [511:0] data;
output [255:0] out;

genvar selector_i;
generate
  for (selector_i = 0; selector_i < 8; selector_i = selector_i + 1) begin: mux_4to2_16bit
    mux_4to2_16bit u_mux_0 (
      .mask(mask[selector_i*4 +: 4]),
      .data(data[selector_i*64 +: 64]),
      .out(out[selector_i*32 +: 32])
    ); 
  end
endgenerate

endmodule
