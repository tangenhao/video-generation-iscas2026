module data_move_8_4(
  en,
  in, out
);

input en;
input [127:0] in;
output [255:0] out;

genvar i;
generate
  for (i = 0; i < 32; i = i + 1) begin: gen
    assign out[8*i +: 8] = en ? {4'b0, in[4*i +: 4]} : 8'b0;
  end 
endgenerate

endmodule