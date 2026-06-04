module shifter_true_form_int4(
  data,
  shift,
  o
);

input wire [3:0] data;
input wire [1:0] shift;
output wire [10:0] o;

wire bit_0;
wire bit_1;
wire bit_2;
wire bit_3;

assign bit_3 = shift == 0 ? data[3] :
               shift == 1 ? data[2] :
               shift == 2 ? data[1] :
               shift == 3 ? data[0] : 1'b0;

assign bit_2 = shift == 0 ? data[2] :
               shift == 1 ? data[1] :
               shift == 2 ? data[0] :
               shift == 3 ? 1'b0 : 1'b0;

assign bit_1 = shift == 0 ? data[1] :
               shift == 1 ? data[0] :
               shift == 2 ? 1'b0 :
               shift == 3 ? 1'b0 : 1'b0;

assign bit_0 = shift == 0 ? data[0] :
               shift == 1 ? 1'b0 :
               shift == 2 ? 1'b0 :
               shift == 3 ? 1'b0 : 1'b0;

assign o = {bit_3, bit_2, bit_1, bit_0, 7'b0};

endmodule