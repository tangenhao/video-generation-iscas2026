module data_move_16_8(
  en, in, out
);

input en;
input [127:0] in;
output [255:0] out;

genvar i;
generate
  for (i = 0; i < 16; i = i + 1) begin: gen
    assign out[16*i +: 16] = en ? {8'b0, in[8*i +: 8]} : 16'b0;
  end 
endgenerate

endmodule