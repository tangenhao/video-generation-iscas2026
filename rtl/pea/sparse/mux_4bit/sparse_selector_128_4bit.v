module sparse_selector_128_4bit (
  mask,
  data,
  out
);

input [127:0] mask;
input [511:0] data;
output [255:0] out;

genvar selector_i;
generate
  for (selector_i = 0; selector_i < 32; selector_i = selector_i + 1) begin: mux_4to2_16bit
    mux_4to2_4bit u_mux_0 (
      .mask(mask[selector_i*4 +: 4]),
      .data(data[selector_i*16 +: 16]),
      .out(out[selector_i*8 +: 8])
    ); 
  end
endgenerate

endmodule
