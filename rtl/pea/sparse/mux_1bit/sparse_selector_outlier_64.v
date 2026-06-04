module sparse_selector_outlier_64 (
  mask,
  data,
  out
);

input [63:0] mask;
input [63:0] data;
output [31:0] out;

genvar selector_i;
generate
  for (selector_i = 0; selector_i < 16; selector_i = selector_i + 1) begin: mux_4to2_16bit
    mux_4to2_1bit u_mux_0 (
      .mask(mask[selector_i*4 +: 4]),
      .data(data[selector_i*4 +: 4]),
      .out(out[selector_i*2 +: 2])
    ); 
  end
endgenerate

endmodule
