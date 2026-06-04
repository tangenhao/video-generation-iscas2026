module shifter_right_32_5(
  data, shift,
  o
);

input wire [31:0] data;
input wire [4:0] shift;
output wire [31:0] o;

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
wire layer_0_bit_24;
wire layer_0_bit_25;
wire layer_0_bit_26;
wire layer_0_bit_27;
wire layer_0_bit_28;
wire layer_0_bit_29;
wire layer_0_bit_30;
wire layer_0_bit_31;

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
wire layer_1_bit_24;
wire layer_1_bit_25;
wire layer_1_bit_26;
wire layer_1_bit_27;
wire layer_1_bit_28;
wire layer_1_bit_29;
wire layer_1_bit_30;
wire layer_1_bit_31;

wire layer_2_bit_0;
wire layer_2_bit_1;
wire layer_2_bit_2;
wire layer_2_bit_3;
wire layer_2_bit_4;
wire layer_2_bit_5;
wire layer_2_bit_6;
wire layer_2_bit_7;
wire layer_2_bit_8;
wire layer_2_bit_9;
wire layer_2_bit_10;
wire layer_2_bit_11;
wire layer_2_bit_12;
wire layer_2_bit_13;
wire layer_2_bit_14;
wire layer_2_bit_15;
wire layer_2_bit_16;
wire layer_2_bit_17;
wire layer_2_bit_18;
wire layer_2_bit_19;
wire layer_2_bit_20;
wire layer_2_bit_21;
wire layer_2_bit_22;
wire layer_2_bit_23;
wire layer_2_bit_24;
wire layer_2_bit_25;
wire layer_2_bit_26;
wire layer_2_bit_27;
wire layer_2_bit_28;
wire layer_2_bit_29;
wire layer_2_bit_30;
wire layer_2_bit_31;
wire layer_2_bit_32;

assign layer_0_bit_31 = shift[1:0] == 2'd0 ? data[31] : 1'b0;

assign layer_0_bit_30 = shift[1:0] == 2'd0 ? data[30] :
                        shift[1:0] == 2'd1 ? data[31] : 1'b0;

assign layer_0_bit_29 = shift[1:0] == 2'd0 ? data[29] :
                        shift[1:0] == 2'd1 ? data[30] :
                        shift[1:0] == 2'd2 ? data[31] : 1'b0;

assign layer_0_bit_28 = shift[1:0] == 2'd0 ? data[28] :
                        shift[1:0] == 2'd1 ? data[29] :
                        shift[1:0] == 2'd2 ? data[30] :
                        shift[1:0] == 2'd3 ? data[31] : 1'b0;

assign layer_0_bit_27 = shift[1:0] == 2'd0 ? data[27] :
                        shift[1:0] == 2'd1 ? data[28] :
                        shift[1:0] == 2'd2 ? data[29] :
                        shift[1:0] == 2'd3 ? data[30] : 1'b0;

assign layer_0_bit_26 = shift[1:0] == 2'd0 ? data[26] :
                        shift[1:0] == 2'd1 ? data[27] :
                        shift[1:0] == 2'd2 ? data[28] :
                        shift[1:0] == 2'd3 ? data[29] : 1'b0;

assign layer_0_bit_25 = shift[1:0] == 2'd0 ? data[25] :
                        shift[1:0] == 2'd1 ? data[26] :
                        shift[1:0] == 2'd2 ? data[27] :
                        shift[1:0] == 2'd3 ? data[28] : 1'b0;

assign layer_0_bit_24 = shift[1:0] == 2'd0 ? data[24] :
                        shift[1:0] == 2'd1 ? data[25] :
                        shift[1:0] == 2'd2 ? data[26] :
                        shift[1:0] == 2'd3 ? data[27] : 1'b0;

assign layer_0_bit_23 = shift[1:0] == 2'd0 ? data[23] :
                        shift[1:0] == 2'd1 ? data[24] :
                        shift[1:0] == 2'd2 ? data[25] :
                        shift[1:0] == 2'd3 ? data[26] : 1'b0;

assign layer_0_bit_22 = shift[1:0] == 2'd0 ? data[22] :
                        shift[1:0] == 2'd1 ? data[23] :
                        shift[1:0] == 2'd2 ? data[24] :
                        shift[1:0] == 2'd3 ? data[25] : 1'b0;

assign layer_0_bit_21 = shift[1:0] == 2'd0 ? data[21] :
                        shift[1:0] == 2'd1 ? data[22] :
                        shift[1:0] == 2'd2 ? data[23] :
                        shift[1:0] == 2'd3 ? data[24] : 1'b0;

assign layer_0_bit_20 = shift[1:0] == 2'd0 ? data[20] :
                        shift[1:0] == 2'd1 ? data[21] :
                        shift[1:0] == 2'd2 ? data[22] :
                        shift[1:0] == 2'd3 ? data[23] : 1'b0;

assign layer_0_bit_19 = shift[1:0] == 2'd0 ? data[19] :
                        shift[1:0] == 2'd1 ? data[20] :
                        shift[1:0] == 2'd2 ? data[21] :
                        shift[1:0] == 2'd3 ? data[22] : 1'b0;

assign layer_0_bit_18 = shift[1:0] == 2'd0 ? data[18] :
                        shift[1:0] == 2'd1 ? data[19] :
                        shift[1:0] == 2'd2 ? data[20] :
                        shift[1:0] == 2'd3 ? data[21] : 1'b0;

assign layer_0_bit_17 = shift[1:0] == 2'd0 ? data[17] :
                        shift[1:0] == 2'd1 ? data[18] :
                        shift[1:0] == 2'd2 ? data[19] :
                        shift[1:0] == 2'd3 ? data[20] : 1'b0;

assign layer_0_bit_16 = shift[1:0] == 2'd0 ? data[16] :
                        shift[1:0] == 2'd1 ? data[17] :
                        shift[1:0] == 2'd2 ? data[18] :
                        shift[1:0] == 2'd3 ? data[19] : 1'b0;

assign layer_0_bit_15 = shift[1:0] == 2'd0 ? data[15] :
                        shift[1:0] == 2'd1 ? data[16] :
                        shift[1:0] == 2'd2 ? data[17] :
                        shift[1:0] == 2'd3 ? data[18] : 1'b0;

assign layer_0_bit_14 = shift[1:0] == 2'd0 ? data[14] :
                        shift[1:0] == 2'd1 ? data[15] :
                        shift[1:0] == 2'd2 ? data[16] :
                        shift[1:0] == 2'd3 ? data[17] : 1'b0;

assign layer_0_bit_13 = shift[1:0] == 2'd0 ? data[13] :
                        shift[1:0] == 2'd1 ? data[14] :
                        shift[1:0] == 2'd2 ? data[15] :
                        shift[1:0] == 2'd3 ? data[16] : 1'b0;

assign layer_0_bit_12 = shift[1:0] == 2'd0 ? data[12] :
                        shift[1:0] == 2'd1 ? data[13] :
                        shift[1:0] == 2'd2 ? data[14] :
                        shift[1:0] == 2'd3 ? data[15] : 1'b0;

assign layer_0_bit_11 = shift[1:0] == 2'd0 ? data[11] :
                        shift[1:0] == 2'd1 ? data[12] :
                        shift[1:0] == 2'd2 ? data[13] :
                        shift[1:0] == 2'd3 ? data[14] : 1'b0;

assign layer_0_bit_10 = shift[1:0] == 2'd0 ? data[10] :
                        shift[1:0] == 2'd1 ? data[11] :
                        shift[1:0] == 2'd2 ? data[12] :
                        shift[1:0] == 2'd3 ? data[13] : 1'b0;

assign layer_0_bit_9 = shift[1:0] == 2'd0 ? data[9] :
                       shift[1:0] == 2'd1 ? data[10] :
                       shift[1:0] == 2'd2 ? data[11] :
                       shift[1:0] == 2'd3 ? data[12] : 1'b0;

assign layer_0_bit_8 = shift[1:0] == 2'd0 ? data[8] :
                       shift[1:0] == 2'd1 ? data[9] :
                       shift[1:0] == 2'd2 ? data[10] :
                       shift[1:0] == 2'd3 ? data[11] : 1'b0;

assign layer_0_bit_7 = shift[1:0] == 2'd0 ? data[7] :
                       shift[1:0] == 2'd1 ? data[8] :
                       shift[1:0] == 2'd2 ? data[9] :
                       shift[1:0] == 2'd3 ? data[10] : 1'b0;

assign layer_0_bit_6 = shift[1:0] == 2'd0 ? data[6] :
                       shift[1:0] == 2'd1 ? data[7] :
                       shift[1:0] == 2'd2 ? data[8] :
                       shift[1:0] == 2'd3 ? data[9] : 1'b0;

assign layer_0_bit_5 = shift[1:0] == 2'd0 ? data[5] :
                       shift[1:0] == 2'd1 ? data[6] :
                       shift[1:0] == 2'd2 ? data[7] :
                       shift[1:0] == 2'd3 ? data[8] : 1'b0;

assign layer_0_bit_4 = shift[1:0] == 2'd0 ? data[4] :
                       shift[1:0] == 2'd1 ? data[5] :
                       shift[1:0] == 2'd2 ? data[6] :
                       shift[1:0] == 2'd3 ? data[7] : 1'b0;

assign layer_0_bit_3 = shift[1:0] == 2'd0 ? data[3] :
                       shift[1:0] == 2'd1 ? data[4] :
                       shift[1:0] == 2'd2 ? data[5] :
                       shift[1:0] == 2'd3 ? data[6] : 1'b0;

assign layer_0_bit_2 = shift[1:0] == 2'd0 ? data[2] :
                       shift[1:0] == 2'd1 ? data[3] :
                       shift[1:0] == 2'd2 ? data[4] :
                       shift[1:0] == 2'd3 ? data[5] : 1'b0;

assign layer_0_bit_1 = shift[1:0] == 2'd0 ? data[1] :
                       shift[1:0] == 2'd1 ? data[2] :
                       shift[1:0] == 2'd2 ? data[3] :
                       shift[1:0] == 2'd3 ? data[4] : 1'b0;

assign layer_0_bit_0 = shift[1:0] == 2'd0 ? data[0] :
                       shift[1:0] == 2'd1 ? data[1] :
                       shift[1:0] == 2'd2 ? data[2] :
                       shift[1:0] == 2'd3 ? data[3] : 1'b0;

assign layer_1_bit_31 = shift[3:2] == 2'd0 ? layer_0_bit_31 :1'b0;

assign layer_1_bit_30 = shift[3:2] == 2'd0 ? layer_0_bit_30 : 1'b0;

assign layer_1_bit_29 = shift[3:2] == 2'd0 ? layer_0_bit_29 : 1'b0;

assign layer_1_bit_28 = shift[3:2] == 2'd0 ? layer_0_bit_28 : 1'b0;

assign layer_1_bit_27 = shift[3:2] == 2'd0 ? layer_0_bit_27 :
                        shift[3:2] == 2'd1 ? layer_0_bit_31 : 1'b0;

assign layer_1_bit_26 = shift[3:2] == 2'd0 ? layer_0_bit_26 :
                        shift[3:2] == 2'd1 ? layer_0_bit_30 : 1'b0;

assign layer_1_bit_25 = shift[3:2] == 2'd0 ? layer_0_bit_25 :
                        shift[3:2] == 2'd1 ? layer_0_bit_29 : 1'b0;

assign layer_1_bit_24 = shift[3:2] == 2'd0 ? layer_0_bit_24 :
                        shift[3:2] == 2'd1 ? layer_0_bit_28 : 1'b0;

assign layer_1_bit_23 = shift[3:2] == 2'd0 ? layer_0_bit_23 :
                        shift[3:2] == 2'd1 ? layer_0_bit_27 :
                        shift[3:2] == 2'd2 ? layer_0_bit_31 : 1'b0;

assign layer_1_bit_22 = shift[3:2] == 2'd0 ? layer_0_bit_22 :
                        shift[3:2] == 2'd1 ? layer_0_bit_26 :
                        shift[3:2] == 2'd2 ? layer_0_bit_30 : 1'b0;

assign layer_1_bit_21 = shift[3:2] == 2'd0 ? layer_0_bit_21 :
                        shift[3:2] == 2'd1 ? layer_0_bit_25 :
                        shift[3:2] == 2'd2 ? layer_0_bit_29 : 1'b0;

assign layer_1_bit_20 = shift[3:2] == 2'd0 ? layer_0_bit_20 :
                        shift[3:2] == 2'd1 ? layer_0_bit_24 :
                        shift[3:2] == 2'd2 ? layer_0_bit_28 : 1'b0;

assign layer_1_bit_19 = shift[3:2] == 2'd0 ? layer_0_bit_19 :
                        shift[3:2] == 2'd1 ? layer_0_bit_23 :
                        shift[3:2] == 2'd2 ? layer_0_bit_27 :
                        shift[3:2] == 2'd3 ? layer_0_bit_31 : 1'b0;

assign layer_1_bit_18 = shift[3:2] == 2'd0 ? layer_0_bit_18 :
                        shift[3:2] == 2'd1 ? layer_0_bit_22 :
                        shift[3:2] == 2'd2 ? layer_0_bit_26 :
                        shift[3:2] == 2'd3 ? layer_0_bit_30 : 1'b0;

assign layer_1_bit_17 = shift[3:2] == 2'd0 ? layer_0_bit_17 :
                        shift[3:2] == 2'd1 ? layer_0_bit_21 :
                        shift[3:2] == 2'd2 ? layer_0_bit_25 :
                        shift[3:2] == 2'd3 ? layer_0_bit_29 : 1'b0;

assign layer_1_bit_16 = shift[3:2] == 2'd0 ? layer_0_bit_16 :
                        shift[3:2] == 2'd1 ? layer_0_bit_20 :
                        shift[3:2] == 2'd2 ? layer_0_bit_24 :
                        shift[3:2] == 2'd3 ? layer_0_bit_28 : 1'b0;

assign layer_1_bit_15 = shift[3:2] == 2'd0 ? layer_0_bit_15 :
                        shift[3:2] == 2'd1 ? layer_0_bit_19 :
                        shift[3:2] == 2'd2 ? layer_0_bit_23 :
                        shift[3:2] == 2'd3 ? layer_0_bit_27 : 1'b0;

assign layer_1_bit_14 = shift[3:2] == 2'd0 ? layer_0_bit_14 :
                        shift[3:2] == 2'd1 ? layer_0_bit_18 :
                        shift[3:2] == 2'd2 ? layer_0_bit_22 :
                        shift[3:2] == 2'd3 ? layer_0_bit_26 : 1'b0;

assign layer_1_bit_13 = shift[3:2] == 2'd0 ? layer_0_bit_13 :
                        shift[3:2] == 2'd1 ? layer_0_bit_17 :
                        shift[3:2] == 2'd2 ? layer_0_bit_21 :
                        shift[3:2] == 2'd3 ? layer_0_bit_25 : 1'b0;

assign layer_1_bit_12 = shift[3:2] == 2'd0 ? layer_0_bit_12 :
                        shift[3:2] == 2'd1 ? layer_0_bit_16 :
                        shift[3:2] == 2'd2 ? layer_0_bit_20 :
                        shift[3:2] == 2'd3 ? layer_0_bit_24 : 1'b0;

assign layer_1_bit_11 = shift[3:2] == 2'd0 ? layer_0_bit_11 :
                        shift[3:2] == 2'd1 ? layer_0_bit_15 :
                        shift[3:2] == 2'd2 ? layer_0_bit_19 :
                        shift[3:2] == 2'd3 ? layer_0_bit_23 : 1'b0;

assign layer_1_bit_10 = shift[3:2] == 2'd0 ? layer_0_bit_10 :
                        shift[3:2] == 2'd1 ? layer_0_bit_14 :
                        shift[3:2] == 2'd2 ? layer_0_bit_18 :
                        shift[3:2] == 2'd3 ? layer_0_bit_22 : 1'b0;

assign layer_1_bit_9 = shift[3:2] == 2'd0 ? layer_0_bit_9 :
                       shift[3:2] == 2'd1 ? layer_0_bit_13 :
                       shift[3:2] == 2'd2 ? layer_0_bit_17 :
                       shift[3:2] == 2'd3 ? layer_0_bit_21 : 1'b0;

assign layer_1_bit_8 = shift[3:2] == 2'd0 ? layer_0_bit_8 :
                       shift[3:2] == 2'd1 ? layer_0_bit_12 :
                       shift[3:2] == 2'd2 ? layer_0_bit_16 :
                       shift[3:2] == 2'd3 ? layer_0_bit_20 : 1'b0;

assign layer_1_bit_7 = shift[3:2] == 2'd0 ? layer_0_bit_7 :
                       shift[3:2] == 2'd1 ? layer_0_bit_11 :
                       shift[3:2] == 2'd2 ? layer_0_bit_15 :
                       shift[3:2] == 2'd3 ? layer_0_bit_19 : 1'b0;

assign layer_1_bit_6 = shift[3:2] == 2'd0 ? layer_0_bit_6 :
                       shift[3:2] == 2'd1 ? layer_0_bit_10 :
                       shift[3:2] == 2'd2 ? layer_0_bit_14 :
                       shift[3:2] == 2'd3 ? layer_0_bit_18 : 1'b0;

assign layer_1_bit_5 = shift[3:2] == 2'd0 ? layer_0_bit_5 :
                       shift[3:2] == 2'd1 ? layer_0_bit_9 :
                       shift[3:2] == 2'd2 ? layer_0_bit_13 :
                       shift[3:2] == 2'd3 ? layer_0_bit_17 : 1'b0;

assign layer_1_bit_4 = shift[3:2] == 2'd0 ? layer_0_bit_4 :
                       shift[3:2] == 2'd1 ? layer_0_bit_8 :
                       shift[3:2] == 2'd2 ? layer_0_bit_12 :
                       shift[3:2] == 2'd3 ? layer_0_bit_16 : 1'b0;

assign layer_1_bit_3 = shift[3:2] == 2'd0 ? layer_0_bit_3 :
                       shift[3:2] == 2'd1 ? layer_0_bit_7 :
                       shift[3:2] == 2'd2 ? layer_0_bit_11 :
                       shift[3:2] == 2'd3 ? layer_0_bit_15 : 1'b0;

assign layer_1_bit_2 = shift[3:2] == 2'd0 ? layer_0_bit_2 :
                       shift[3:2] == 2'd1 ? layer_0_bit_6 :
                       shift[3:2] == 2'd2 ? layer_0_bit_10 :
                       shift[3:2] == 2'd3 ? layer_0_bit_14 : 1'b0;

assign layer_1_bit_1 = shift[3:2] == 2'd0 ? layer_0_bit_1 :
                       shift[3:2] == 2'd1 ? layer_0_bit_5 :
                       shift[3:2] == 2'd2 ? layer_0_bit_9 :
                       shift[3:2] == 2'd3 ? layer_0_bit_13 : 1'b0;

assign layer_1_bit_0 = shift[3:2] == 2'd0 ? layer_0_bit_0 :
                       shift[3:2] == 2'd1 ? layer_0_bit_4 :
                       shift[3:2] == 2'd2 ? layer_0_bit_8 :
                       shift[3:2] == 2'd3 ? layer_0_bit_12 : 1'b0;

assign layer_2_bit_31 = !shift[4] ? layer_1_bit_31 : 1'b0;

assign layer_2_bit_30 = !shift[4] ? layer_1_bit_30 : 1'b0;

assign layer_2_bit_29 = !shift[4] ? layer_1_bit_29 : 1'b0;

assign layer_2_bit_28 = !shift[4] ? layer_1_bit_28 : 1'b0;

assign layer_2_bit_27 = !shift[4] ? layer_1_bit_27 : 1'b0;

assign layer_2_bit_26 = !shift[4] ? layer_1_bit_26 : 1'b0;

assign layer_2_bit_25 = !shift[4] ? layer_1_bit_25 : 1'b0;

assign layer_2_bit_24 = !shift[4] ? layer_1_bit_24 : 1'b0;

assign layer_2_bit_23 = !shift[4] ? layer_1_bit_23 : 1'b0;

assign layer_2_bit_22 = !shift[4] ? layer_1_bit_22 : 1'b0;

assign layer_2_bit_21 = !shift[4] ? layer_1_bit_21 : 1'b0;

assign layer_2_bit_20 = !shift[4] ? layer_1_bit_20 : 1'b0;

assign layer_2_bit_19 = !shift[4] ? layer_1_bit_19 : 1'b0;

assign layer_2_bit_18 = !shift[4] ? layer_1_bit_18 : 1'b0;

assign layer_2_bit_17 = !shift[4] ? layer_1_bit_17 : 1'b0;

assign layer_2_bit_16 = !shift[4] ? layer_1_bit_16 : 1'b0;

assign layer_2_bit_15 = !shift[4] ? layer_1_bit_15 : layer_1_bit_31;

assign layer_2_bit_14 = !shift[4] ? layer_1_bit_14 : layer_1_bit_30;

assign layer_2_bit_13 = !shift[4] ? layer_1_bit_13 : layer_1_bit_29;

assign layer_2_bit_12 = !shift[4] ? layer_1_bit_12 : layer_1_bit_28;

assign layer_2_bit_11 = !shift[4] ? layer_1_bit_11 : layer_1_bit_27;

assign layer_2_bit_10 = !shift[4] ? layer_1_bit_10 : layer_1_bit_26;

assign layer_2_bit_9 = !shift[4] ? layer_1_bit_9 : layer_1_bit_25;

assign layer_2_bit_8 = !shift[4] ? layer_1_bit_8 : layer_1_bit_24;

assign layer_2_bit_7 = !shift[4] ? layer_1_bit_7 : layer_1_bit_23;

assign layer_2_bit_6 = !shift[4] ? layer_1_bit_6 : layer_1_bit_22;

assign layer_2_bit_5 = !shift[4] ? layer_1_bit_5 : layer_1_bit_21;

assign layer_2_bit_4 = !shift[4] ? layer_1_bit_4 : layer_1_bit_20;

assign layer_2_bit_3 = !shift[4] ? layer_1_bit_3 : layer_1_bit_19;

assign layer_2_bit_2 = !shift[4] ? layer_1_bit_2 : layer_1_bit_18;

assign layer_2_bit_1 = !shift[4] ? layer_1_bit_1 : layer_1_bit_17;

assign layer_2_bit_0 = !shift[4] ? layer_1_bit_0 : layer_1_bit_16;

assign o = {layer_2_bit_31, layer_2_bit_30, layer_2_bit_29, layer_2_bit_28, layer_2_bit_27, layer_2_bit_26, layer_2_bit_25, layer_2_bit_24, layer_2_bit_23, layer_2_bit_22, layer_2_bit_21, layer_2_bit_20, layer_2_bit_19, layer_2_bit_18, layer_2_bit_17, layer_2_bit_16, layer_2_bit_15, layer_2_bit_14, layer_2_bit_13, layer_2_bit_12, layer_2_bit_11, layer_2_bit_10, layer_2_bit_9, layer_2_bit_8, layer_2_bit_7, layer_2_bit_6, layer_2_bit_5, layer_2_bit_4, layer_2_bit_3, layer_2_bit_2, layer_2_bit_1, layer_2_bit_0};

endmodule
