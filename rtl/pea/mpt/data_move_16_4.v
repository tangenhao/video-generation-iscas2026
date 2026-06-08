module data_move_16_4(
  en, in, out
);

input          en;
input  [63:0]  in;
output [255:0] out;

genvar i;
generate
  for (i = 0; i < 16; i = i + 1) begin: gen
    assign out[16*i +: 16] = en ? {12'b0, in[4*i +: 4]} : 16'b0;
  end 
endgenerate

endmodule