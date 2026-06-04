module shifter_true_form_int8(
  data,
  shift,
  o
);

input wire [7:0] data;
input wire [2:0] shift;
output wire [10:0] o;

wire bit_0;
wire bit_1;
wire bit_2;
wire bit_3;
wire bit_4;
wire bit_5;
wire bit_6;
wire bit_7;

assign bit_7 = shift == 0 ? data[7] :
               shift == 1 ? data[6] :
               shift == 2 ? data[5] :
               shift == 3 ? data[4] :
               shift == 4 ? data[3] :
               shift == 5 ? data[2] :
               shift == 6 ? data[1] :
               shift == 7 ? data[0] : 1'b0;

assign bit_6 = shift == 0 ? data[6] :
               shift == 1 ? data[5] :
               shift == 2 ? data[4] :
               shift == 3 ? data[3] :
               shift == 4 ? data[2] :
               shift == 5 ? data[1] :
               shift == 6 ? data[0] :
               shift == 7 ? 1'b0 : 1'b0;

assign bit_5 = shift == 0 ? data[5] :
               shift == 1 ? data[4] :
               shift == 2 ? data[3] :
               shift == 3 ? data[2] :
               shift == 4 ? data[1] :
               shift == 5 ? data[0] :
               shift == 6 ? 1'b0 :
               shift == 7 ? 1'b0 : 1'b0;

assign bit_4 = shift == 0 ? data[4] :
               shift == 1 ? data[3] :
               shift == 2 ? data[2] :
               shift == 3 ? data[1] :
               shift == 4 ? data[0] :
               shift == 5 ? 1'b0 :
               shift == 6 ? 1'b0 :
               shift == 7 ? 1'b0 : 1'b0;

assign bit_3 = shift == 0 ? data[3] :
               shift == 1 ? data[2] :
               shift == 2 ? data[1] :
               shift == 3 ? data[0] :
               shift == 4 ? 1'b0 :
               shift == 5 ? 1'b0 :
               shift == 6 ? 1'b0 :
               shift == 7 ? 1'b0 : 1'b0; 

assign bit_2 = shift == 0 ? data[2] :
               shift == 1 ? data[1] :
               shift == 2 ? data[0] :
               shift == 3 ? 1'b0 :
               shift == 4 ? 1'b0 :
               shift == 5 ? 1'b0 :
               shift == 6 ? 1'b0 :
               shift == 7 ? 1'b0 : 1'b0;

assign bit_1 = shift == 0 ? data[1] :
               shift == 1 ? data[0] :
               shift == 2 ? 1'b0 :
               shift == 3 ? 1'b0 :
               shift == 4 ? 1'b0 :
               shift == 5 ? 1'b0 :
               shift == 6 ? 1'b0 :
               shift == 7 ? 1'b0 : 1'b0;

assign bit_0 = shift == 0 ? data[0] :
               shift == 1 ? 1'b0 :
               shift == 2 ? 1'b0 :
               shift == 3 ? 1'b0 :
               shift == 4 ? 1'b0 :
               shift == 5 ? 1'b0 :
               shift == 6 ? 1'b0 :
               shift == 7 ? 1'b0 : 1'b0;

assign o = {bit_7, bit_6, bit_5, bit_4, bit_3, bit_2, bit_1, bit_0, 3'b0};

endmodule