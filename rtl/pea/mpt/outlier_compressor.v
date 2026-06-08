module outlier_compressor(
  dtype_sel, outlier_second_pass,
  ifmap, outlier_index,
  out
);

parameter IFMAP_WIDTH         = 256;
parameter OUTLIER_INDEX_WIDTH = 64;

input                                 dtype_sel;
input                                 outlier_second_pass;
input       [IFMAP_WIDTH-1:0]         ifmap;
input       [OUTLIER_INDEX_WIDTH-1:0] outlier_index;
output wire [IFMAP_WIDTH-1:0]         out;

wire [IFMAP_WIDTH-1:0] ifmap_int8;
wire [IFMAP_WIDTH-1:0] ifmap_int4;

genvar int8_outlier_i;
generate
  for (int8_outlier_i = 0; int8_outlier_i < 32; int8_outlier_i = int8_outlier_i + 1) begin : int8_outlier
    assign ifmap_int8[int8_outlier_i*8 +: 8] = outlier_second_pass ? outlier_index[int8_outlier_i] ? ifmap[int8_outlier_i*8 +: 8] : 8'h00 : 
                                                                     outlier_index[int8_outlier_i] ? 8'h00 : ifmap[int8_outlier_i*8 +: 8];
  end
endgenerate

genvar int4_outlier_i;
generate
  for (int4_outlier_i = 0; int4_outlier_i < 64; int4_outlier_i = int4_outlier_i + 1) begin : int4_outlier
    assign ifmap_int4[int4_outlier_i*4 +: 4] = outlier_second_pass ? outlier_index[int4_outlier_i] ? ifmap[int4_outlier_i*4 +: 4] : 4'h0 : 
                                                                     outlier_index[int4_outlier_i] ? 4'h0 : ifmap[int4_outlier_i*4 +: 4];
  end
endgenerate

assign out = dtype_sel ? ifmap_int8 : ifmap_int4;

endmodule