module shifter_24_8(
  data, shift,
  o
);

input wire [23:0] data;
input wire [7:0] shift;
output wire [23:0] o;

wire layer_0_bit_0;
wire layer_0_bit_1;
wire layer_0_bit_2;
wire layer_0_bit_3;
wire layer_0_bit_4;
wire layer_0_bit_5;
wire layer_0_bit_6;
wire layer_0_bit_7;
wire layer_0_bit_8;
wire layer_0_bit_9;
wire layer_0_bit_10;
wire layer_0_bit_11;
wire layer_0_bit_12;
wire layer_0_bit_13;
wire layer_0_bit_14;
wire layer_0_bit_15;
wire layer_0_bit_16;
wire layer_0_bit_17;
wire layer_0_bit_18;
wire layer_0_bit_19;
wire layer_0_bit_20;
wire layer_0_bit_21;
wire layer_0_bit_22;
wire layer_0_bit_23;

wire layer_1_bit_0;
wire layer_1_bit_1;
wire layer_1_bit_2;
wire layer_1_bit_3;
wire layer_1_bit_4;
wire layer_1_bit_5;
wire layer_1_bit_6;
wire layer_1_bit_7;
wire layer_1_bit_8;
wire layer_1_bit_9;
wire layer_1_bit_10;
wire layer_1_bit_11;
wire layer_1_bit_12;
wire layer_1_bit_13;
wire layer_1_bit_14;
wire layer_1_bit_15;
wire layer_1_bit_16;
wire layer_1_bit_17;
wire layer_1_bit_18;
wire layer_1_bit_19;
wire layer_1_bit_20;
wire layer_1_bit_21;
wire layer_1_bit_22;
wire layer_1_bit_23;

assign layer_0_bit_23 = shift[1:0] == 2'd0 ? data[23] : 'd0;

assign layer_0_bit_22 = shift[1:0] == 2'd0 ? data[22] :
                        shift[1:0] == 2'd1 ? data[23] : 'd0;

assign layer_0_bit_21 = shift[1:0] == 2'd0 ? data[21] :
                        shift[1:0] == 2'd1 ? data[22] :
                        shift[1:0] == 2'd2 ? data[23] : 'd0;

assign layer_0_bit_20 = shift[1:0] == 2'd0 ? data[20] : 
                        shift[1:0] == 2'd1 ? data[21] :
                        shift[1:0] == 2'd2 ? data[22] :
                        shift[1:0] == 2'd3 ? data[23] : 'd0;

assign layer_0_bit_19 = shift[1:0] == 2'd0 ? data[19] :
                        shift[1:0] == 2'd1 ? data[20] :
                        shift[1:0] == 2'd2 ? data[21] :
                        shift[1:0] == 2'd3 ? data[22] : 'd0;

assign layer_0_bit_18 = shift[1:0] == 2'd0 ? data[18] :
                        shift[1:0] == 2'd1 ? data[19] :
                        shift[1:0] == 2'd2 ? data[20] :
                        shift[1:0] == 2'd3 ? data[21] : 'd0;

assign layer_0_bit_17 = shift[1:0] == 2'd0 ? data[17] :
                        shift[1:0] == 2'd1 ? data[18] :
                        shift[1:0] == 2'd2 ? data[19] :
                        shift[1:0] == 2'd3 ? data[20] : 'd0;

assign layer_0_bit_16 = shift[1:0] == 2'd0 ? data[16] :
                        shift[1:0] == 2'd1 ? data[17] :
                        shift[1:0] == 2'd2 ? data[18] :
                        shift[1:0] == 2'd3 ? data[19] : 'd0;

assign layer_0_bit_15 = shift[1:0] == 2'd0 ? data[15] :
                        shift[1:0] == 2'd1 ? data[16] :
                        shift[1:0] == 2'd2 ? data[17] :
                        shift[1:0] == 2'd3 ? data[18] : 'd0;

assign layer_0_bit_14 = shift[1:0] == 2'd0 ? data[14] :
                        shift[1:0] == 2'd1 ? data[15] :
                        shift[1:0] == 2'd2 ? data[16] :
                        shift[1:0] == 2'd3 ? data[17] : 'd0;

assign layer_0_bit_13 = shift[1:0] == 2'd0 ? data[13] :
                        shift[1:0] == 2'd1 ? data[14] :
                        shift[1:0] == 2'd2 ? data[15] :
                        shift[1:0] == 2'd3 ? data[16] : 'd0;

assign layer_0_bit_12 = shift[1:0] == 2'd0 ? data[12] :
                        shift[1:0] == 2'd1 ? data[13] :
                        shift[1:0] == 2'd2 ? data[14] :
                        shift[1:0] == 2'd3 ? data[15] : 'd0;

assign layer_0_bit_11 = shift[1:0] == 2'd0 ? data[11] :
                        shift[1:0] == 2'd1 ? data[12] :
                        shift[1:0] == 2'd2 ? data[13] :
                        shift[1:0] == 2'd3 ? data[14] : 'd0;

assign layer_0_bit_10 = shift[1:0] == 2'd0 ? data[10] :
                        shift[1:0] == 2'd1 ? data[11] :
                        shift[1:0] == 2'd2 ? data[12] :
                        shift[1:0] == 2'd3 ? data[13] : 'd0;

assign layer_0_bit_9 = shift[1:0] == 2'd0 ? data[9] :
                       shift[1:0] == 2'd1 ? data[10] :
                       shift[1:0] == 2'd2 ? data[11] :
                       shift[1:0] == 2'd3 ? data[12] : 'd0;

assign layer_0_bit_8 = shift[1:0] == 2'd0 ? data[8] :
                       shift[1:0] == 2'd1 ? data[9] :
                       shift[1:0] == 2'd2 ? data[10] :
                       shift[1:0] == 2'd3 ? data[11] : 'd0;  

assign layer_0_bit_7 = shift[1:0] == 2'd0 ? data[7] :
                       shift[1:0] == 2'd1 ? data[8] :
                       shift[1:0] == 2'd2 ? data[9] :
                       shift[1:0] == 2'd3 ? data[10] : 'd0;

assign layer_0_bit_6 = shift[1:0] == 2'd0 ? data[6] :
                       shift[1:0] == 2'd1 ? data[7] :
                       shift[1:0] == 2'd2 ? data[8] :
                       shift[1:0] == 2'd3 ? data[9] : 'd0;

assign layer_0_bit_5 = shift[1:0] == 2'd0 ? data[5] :
                       shift[1:0] == 2'd1 ? data[6] :
                       shift[1:0] == 2'd2 ? data[7] :
                       shift[1:0] == 2'd3 ? data[8] : 'd0;

assign layer_0_bit_4 = shift[1:0] == 2'd0 ? data[4] :
                       shift[1:0] == 2'd1 ? data[5] :
                       shift[1:0] == 2'd2 ? data[6] :
                       shift[1:0] == 2'd3 ? data[7] : 'd0;

assign layer_0_bit_3 = shift[1:0] == 2'd0 ? data[3] :
                       shift[1:0] == 2'd1 ? data[4] :
                       shift[1:0] == 2'd2 ? data[5] :
                       shift[1:0] == 2'd3 ? data[6] : 'd0;

assign layer_0_bit_2 = shift[1:0] == 2'd0 ? data[2] :
                       shift[1:0] == 2'd1 ? data[3] :
                       shift[1:0] == 2'd2 ? data[4] :
                       shift[1:0] == 2'd3 ? data[5] : 'd0;

assign layer_0_bit_1 = shift[1:0] == 2'd0 ? data[1] :
                       shift[1:0] == 2'd1 ? data[2] :
                       shift[1:0] == 2'd2 ? data[3] :
                       shift[1:0] == 2'd3 ? data[4] : 'd0;

assign layer_0_bit_0 = shift[1:0] == 2'd0 ? data[0] :
                       shift[1:0] == 2'd1 ? data[1] :
                       shift[1:0] == 2'd2 ? data[2] :
                       shift[1:0] == 2'd3 ? data[3] : 'd0;

wire [23:0] layer_0;

assign layer_0 = {layer_0_bit_23, layer_0_bit_22, layer_0_bit_21, layer_0_bit_20, layer_0_bit_19, layer_0_bit_18, layer_0_bit_17, layer_0_bit_16, layer_0_bit_15, layer_0_bit_14, layer_0_bit_13, layer_0_bit_12, layer_0_bit_11, layer_0_bit_10, layer_0_bit_9, layer_0_bit_8, layer_0_bit_7, layer_0_bit_6, layer_0_bit_5, layer_0_bit_4, layer_0_bit_3, layer_0_bit_2, layer_0_bit_1, layer_0_bit_0};

assign layer_1_bit_23 = shift[4:2] == 3'd0 ? layer_0_bit_23 : 'd0;

assign layer_1_bit_22 = shift[4:2] == 3'd0 ? layer_0_bit_22 : 'd0;

assign layer_1_bit_21 = shift[4:2] == 3'd0 ? layer_0_bit_21 : 'd0;

assign layer_1_bit_20 = shift[4:2] == 3'd0 ? layer_0_bit_20 : 'd0;

assign layer_1_bit_19 = shift[4:2] == 3'd0 ? layer_0_bit_19 :
                        shift[4:2] == 3'd1 ? layer_0_bit_23 : 'd0;

assign layer_1_bit_18 = shift[4:2] == 3'd0 ? layer_0_bit_18 :
                        shift[4:2] == 3'd1 ? layer_0_bit_22 : 'd0;

assign layer_1_bit_17 = shift[4:2] == 3'd0 ? layer_0_bit_17 : 
                        shift[4:2] == 3'd1 ? layer_0_bit_21 : 'd0;

assign layer_1_bit_16 = shift[4:2] == 3'd0 ? layer_0_bit_16 :
                        shift[4:2] == 3'd1 ? layer_0_bit_20 : 'd0;

assign layer_1_bit_15 = shift[4:2] == 3'd0 ? layer_0_bit_15 :
                        shift[4:2] == 3'd1 ? layer_0_bit_19 :
                        shift[4:2] == 3'd2 ? layer_0_bit_23 : 'd0;

assign layer_1_bit_14 = shift[4:2] == 3'd0 ? layer_0_bit_14 :
                        shift[4:2] == 3'd1 ? layer_0_bit_18 :
                        shift[4:2] == 3'd2 ? layer_0_bit_22 : 'd0;

assign layer_1_bit_13 = shift[4:2] == 3'd0 ? layer_0_bit_13 :
                        shift[4:2] == 3'd1 ? layer_0_bit_17 :
                        shift[4:2] == 3'd2 ? layer_0_bit_21 : 'd0;

assign layer_1_bit_12 = shift[4:2] == 3'd0 ? layer_0_bit_12 :
                        shift[4:2] == 3'd1 ? layer_0_bit_16 :
                        shift[4:2] == 3'd2 ? layer_0_bit_20 : 'd0;

assign layer_1_bit_11 = shift[4:2] == 3'd0 ? layer_0_bit_11 :
                        shift[4:2] == 3'd1 ? layer_0_bit_15 :
                        shift[4:2] == 3'd2 ? layer_0_bit_19 :
                        shift[4:2] == 3'd3 ? layer_0_bit_23 : 'd0;

assign layer_1_bit_10 = shift[4:2] == 3'd0 ? layer_0_bit_10 :
                        shift[4:2] == 3'd1 ? layer_0_bit_14 :
                        shift[4:2] == 3'd2 ? layer_0_bit_18 :
                        shift[4:2] == 3'd3 ? layer_0_bit_22 : 'd0;

assign layer_1_bit_9 = shift[4:2] == 3'd0 ? layer_0_bit_9 :
                       shift[4:2] == 3'd1 ? layer_0_bit_13 :
                       shift[4:2] == 3'd2 ? layer_0_bit_17 :
                       shift[4:2] == 3'd3 ? layer_0_bit_21 : 'd0;
                         
assign layer_1_bit_8 = shift[4:2] == 3'd0 ? layer_0_bit_8 :
                       shift[4:2] == 3'd1 ? layer_0_bit_12 :
                       shift[4:2] == 3'd2 ? layer_0_bit_16 :
                       shift[4:2] == 3'd3 ? layer_0_bit_20 : 'd0;

assign layer_1_bit_7 = shift[4:2] == 3'd0 ? layer_0_bit_7 :
                       shift[4:2] == 3'd1 ? layer_0_bit_11 :
                       shift[4:2] == 3'd2 ? layer_0_bit_15 :
                       shift[4:2] == 3'd3 ? layer_0_bit_19 : 'd0;

assign layer_1_bit_6 = shift[4:2] == 3'd0 ? layer_0_bit_6 :
                       shift[4:2] == 3'd1 ? layer_0_bit_10 :
                       shift[4:2] == 3'd2 ? layer_0_bit_14 :
                       shift[4:2] == 3'd3 ? layer_0_bit_18 : 'd0;

assign layer_1_bit_5 = shift[4:2] == 3'd0 ? layer_0_bit_5 :
                       shift[4:2] == 3'd1 ? layer_0_bit_9 :
                       shift[4:2] == 3'd2 ? layer_0_bit_13 :
                       shift[4:2] == 3'd3 ? layer_0_bit_17 :
                       shift[4:2] == 3'd4 ? layer_0_bit_21 : 'd0;

assign layer_1_bit_4 = shift[4:2] == 3'd0 ? layer_0_bit_4 :
                       shift[4:2] == 3'd1 ? layer_0_bit_8 :
                       shift[4:2] == 3'd2 ? layer_0_bit_12 :
                       shift[4:2] == 3'd3 ? layer_0_bit_16 :
                       shift[4:2] == 3'd4 ? layer_0_bit_20 : 'd0;

assign layer_1_bit_3 = shift[4:2] == 3'd0 ? layer_0_bit_3 :
                       shift[4:2] == 3'd1 ? layer_0_bit_7 :
                       shift[4:2] == 3'd2 ? layer_0_bit_11 :
                       shift[4:2] == 3'd3 ? layer_0_bit_15 :
                       shift[4:2] == 3'd4 ? layer_0_bit_19 : 'd0;

assign layer_1_bit_2 = shift[4:2] == 3'd0 ? layer_0_bit_2 :
                       shift[4:2] == 3'd1 ? layer_0_bit_6 :
                       shift[4:2] == 3'd2 ? layer_0_bit_10 :
                       shift[4:2] == 3'd3 ? layer_0_bit_14 :
                       shift[4:2] == 3'd4 ? layer_0_bit_18 : 'd0;

assign layer_1_bit_1 = shift[4:2] == 3'd0 ? layer_0_bit_1 :
                       shift[4:2] == 3'd1 ? layer_0_bit_5 :
                       shift[4:2] == 3'd2 ? layer_0_bit_9 :
                       shift[4:2] == 3'd3 ? layer_0_bit_13 :
                       shift[4:2] == 3'd4 ? layer_0_bit_17 :
                       shift[4:2] == 3'd5 ? layer_0_bit_21 : 'd0;

assign layer_1_bit_0 = shift[4:2] == 3'd0 ? layer_0_bit_0 :
                       shift[4:2] == 3'd1 ? layer_0_bit_4 :
                       shift[4:2] == 3'd2 ? layer_0_bit_8 :
                       shift[4:2] == 3'd3 ? layer_0_bit_12 :
                       shift[4:2] == 3'd4 ? layer_0_bit_16 :
                       shift[4:2] == 3'd5 ? layer_0_bit_20 : 'd0;

assign o = shift < 'd24 ? {layer_1_bit_23, layer_1_bit_22, layer_1_bit_21, layer_1_bit_20, layer_1_bit_19, layer_1_bit_18, layer_1_bit_17, layer_1_bit_16, layer_1_bit_15, layer_1_bit_14, layer_1_bit_13, layer_1_bit_12, layer_1_bit_11, layer_1_bit_10, layer_1_bit_9, layer_1_bit_8, layer_1_bit_7, layer_1_bit_6, layer_1_bit_5, layer_1_bit_4, layer_1_bit_3, layer_1_bit_2, layer_1_bit_1, layer_1_bit_0} : 'd0;

endmodule