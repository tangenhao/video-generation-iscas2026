module sparse_selector_outlier_128 (
  mask,
  data,
  out
);

input [127:0] mask;
input [127:0] data;
output [63:0] out;

genvar selector_i;
generate
  for (selector_i = 0; selector_i < 32; selector_i = selector_i + 1) begin: mux_4to2_1bit
    mux_4to2_1bit u_mux_0 (
      .mask(mask[selector_i*4 +: 4]),
      .data(data[selector_i*4 +: 4]),
      .out(out[selector_i*2 +: 2])
    ); 
  end
endgenerate

endmodule
