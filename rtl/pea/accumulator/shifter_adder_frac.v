module shifter_adder_frac(
  data, shift,
  o
);

input wire [46:0] data;
input wire [7:0] shift;
output wire [46:0] o;

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
wire layer_0_bit_32;
wire layer_0_bit_33;
wire layer_0_bit_34;
wire layer_0_bit_35;
wire layer_0_bit_36;
wire layer_0_bit_37;
wire layer_0_bit_38;
wire layer_0_bit_39;
wire layer_0_bit_40;
wire layer_0_bit_41;
wire layer_0_bit_42;
wire layer_0_bit_43;
wire layer_0_bit_44;
wire layer_0_bit_45;
wire layer_0_bit_46;

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
wire layer_1_bit_32;
wire layer_1_bit_33;
wire layer_1_bit_34;
wire layer_1_bit_35;
wire layer_1_bit_36;
wire layer_1_bit_37;
wire layer_1_bit_38;
wire layer_1_bit_39;
wire layer_1_bit_40;
wire layer_1_bit_41;
wire layer_1_bit_42;
wire layer_1_bit_43;
wire layer_1_bit_44;
wire layer_1_bit_45;
wire layer_1_bit_46;

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
wire layer_2_bit_33;
wire layer_2_bit_34;
wire layer_2_bit_35;
wire layer_2_bit_36;
wire layer_2_bit_37;
wire layer_2_bit_38;
wire layer_2_bit_39;
wire layer_2_bit_40;
wire layer_2_bit_41;
wire layer_2_bit_42;
wire layer_2_bit_43;
wire layer_2_bit_44;
wire layer_2_bit_45;
wire layer_2_bit_46;

assign layer_0_bit_46 = shift[1:0] == 2'd0 ? data[46] : 'd0;

assign layer_0_bit_45 = shift[1:0] == 2'd0 ? data[45] :
                        shift[1:0] == 2'd1 ? data[46] : 'd0;

assign layer_0_bit_44 = shift[1:0] == 2'd0 ? data[44] :
                        shift[1:0] == 2'd1 ? data[45] :
                        shift[1:0] == 2'd2 ? data[46] : 'd0;

assign layer_0_bit_43 = shift[1:0] == 2'd0 ? data[43] :
                        shift[1:0] == 2'd1 ? data[44] :
                        shift[1:0] == 2'd2 ? data[45] :
                        shift[1:0] == 2'd3 ? data[46] : 'd0;

assign layer_0_bit_42 = shift[1:0] == 2'd0 ? data[42] :
                        shift[1:0] == 2'd1 ? data[43] :
                        shift[1:0] == 2'd2 ? data[44] :
                        shift[1:0] == 2'd3 ? data[45] : 'd0;

assign layer_0_bit_41 = shift[1:0] == 2'd0 ? data[41] :
                        shift[1:0] == 2'd1 ? data[42] :
                        shift[1:0] == 2'd2 ? data[43] :
                        shift[1:0] == 2'd3 ? data[44] : 'd0;

assign layer_0_bit_40 = shift[1:0] == 2'd0 ? data[40] :
                        shift[1:0] == 2'd1 ? data[41] :
                        shift[1:0] == 2'd2 ? data[42] :
                        shift[1:0] == 2'd3 ? data[43] : 'd0;

assign layer_0_bit_39 = shift[1:0] == 2'd0 ? data[39] :
                        shift[1:0] == 2'd1 ? data[40] :
                        shift[1:0] == 2'd2 ? data[41] :
                        shift[1:0] == 2'd3 ? data[42] : 'd0;

assign layer_0_bit_38 = shift[1:0] == 2'd0 ? data[38] :
                        shift[1:0] == 2'd1 ? data[39] :
                        shift[1:0] == 2'd2 ? data[40] :
                        shift[1:0] == 2'd3 ? data[41] : 'd0;

assign layer_0_bit_37 = shift[1:0] == 2'd0 ? data[37] :
                        shift[1:0] == 2'd1 ? data[38] :
                        shift[1:0] == 2'd2 ? data[39] :
                        shift[1:0] == 2'd3 ? data[40] : 'd0;

assign layer_0_bit_36 = shift[1:0] == 2'd0 ? data[36] :
                        shift[1:0] == 2'd1 ? data[37] :
                        shift[1:0] == 2'd2 ? data[38] :
                        shift[1:0] == 2'd3 ? data[39] : 'd0;

assign layer_0_bit_35 = shift[1:0] == 2'd0 ? data[35] :
                        shift[1:0] == 2'd1 ? data[36] :
                        shift[1:0] == 2'd2 ? data[37] :
                        shift[1:0] == 2'd3 ? data[38] : 'd0;

assign layer_0_bit_34 = shift[1:0] == 2'd0 ? data[34] :
                        shift[1:0] == 2'd1 ? data[35] :
                        shift[1:0] == 2'd2 ? data[36] :
                        shift[1:0] == 2'd3 ? data[37] : 'd0;          

assign layer_0_bit_33 = shift[1:0] == 2'd0 ? data[33] :
                        shift[1:0] == 2'd1 ? data[34] :
                        shift[1:0] == 2'd2 ? data[35] :
                        shift[1:0] == 2'd3 ? data[36] : 'd0;

assign layer_0_bit_32 = shift[1:0] == 2'd0 ? data[32] :
                        shift[1:0] == 2'd1 ? data[33] :
                        shift[1:0] == 2'd2 ? data[34] :
                        shift[1:0] == 2'd3 ? data[35] : 'd0;

assign layer_0_bit_31 = shift[1:0] == 2'd0 ? data[31] :
                        shift[1:0] == 2'd1 ? data[32] :
                        shift[1:0] == 2'd2 ? data[33] :
                        shift[1:0] == 2'd3 ? data[34] : 'd0;

assign layer_0_bit_30 = shift[1:0] == 2'd0 ? data[30] :
                        shift[1:0] == 2'd1 ? data[31] :
                        shift[1:0] == 2'd2 ? data[32] :
                        shift[1:0] == 2'd3 ? data[33] : 'd0;

assign layer_0_bit_29 = shift[1:0] == 2'd0 ? data[29] :
                        shift[1:0] == 2'd1 ? data[30] :
                        shift[1:0] == 2'd2 ? data[31] :
                        shift[1:0] == 2'd3 ? data[32] : 'd0;

assign layer_0_bit_28 = shift[1:0] == 2'd0 ? data[28] :
                        shift[1:0] == 2'd1 ? data[29] :
                        shift[1:0] == 2'd2 ? data[30] :
                        shift[1:0] == 2'd3 ? data[31] : 'd0;

assign layer_0_bit_27 = shift[1:0] == 2'd0 ? data[27] :
                        shift[1:0] == 2'd1 ? data[28] :
                        shift[1:0] == 2'd2 ? data[29] :
                        shift[1:0] == 2'd3 ? data[30] : 'd0;

assign layer_0_bit_26 = shift[1:0] == 2'd0 ? data[26] :
                        shift[1:0] == 2'd1 ? data[27] :
                        shift[1:0] == 2'd2 ? data[28] :
                        shift[1:0] == 2'd3 ? data[29] : 'd0;
                        
assign layer_0_bit_25 = shift[1:0] == 2'd0 ? data[25] :
                        shift[1:0] == 2'd1 ? data[26] :
                        shift[1:0] == 2'd2 ? data[27] :
                        shift[1:0] == 2'd3 ? data[28] : 'd0;

assign layer_0_bit_24 = shift[1:0] == 2'd0 ? data[24] :
                        shift[1:0] == 2'd1 ? data[25] :
                        shift[1:0] == 2'd2 ? data[26] :
                        shift[1:0] == 2'd3 ? data[27] : 'd0;

assign layer_0_bit_23 = shift[1:0] == 2'd0 ? data[23] :
                        shift[1:0] == 2'd1 ? data[24] :
                        shift[1:0] == 2'd2 ? data[25] :
                        shift[1:0] == 2'd3 ? data[26] : 'd0;

assign layer_0_bit_22 = shift[1:0] == 2'd0 ? data[22] :
                        shift[1:0] == 2'd1 ? data[23] :
                        shift[1:0] == 2'd2 ? data[24] :
                        shift[1:0] == 2'd3 ? data[25] : 'd0;

assign layer_0_bit_21 = shift[1:0] == 2'd0 ? data[21] :
                        shift[1:0] == 2'd1 ? data[22] :
                        shift[1:0] == 2'd2 ? data[23] :
                        shift[1:0] == 2'd3 ? data[24] : 'd0;

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

assign layer_1_bit_46 = shift[3:2] == 2'd0 ? layer_0_bit_46 : 'd0;

assign layer_1_bit_45 = shift[3:2] == 2'd0 ? layer_0_bit_45 : 'd0;

assign layer_1_bit_44 = shift[3:2] == 2'd0 ? layer_0_bit_44 : 'd0;

assign layer_1_bit_43 = shift[3:2] == 2'd0 ? layer_0_bit_43 : 'd0;

assign layer_1_bit_42 = shift[3:2] == 2'd0 ? layer_0_bit_42 :
                        shift[3:2] == 2'd1 ? layer_0_bit_46 : 'd0;

assign layer_1_bit_41 = shift[3:2] == 2'd0 ? layer_0_bit_41 :
                        shift[3:2] == 2'd1 ? layer_0_bit_45 : 'd0;

assign layer_1_bit_40 = shift[3:2] == 2'd0 ? layer_0_bit_40 :
                        shift[3:2] == 2'd1 ? layer_0_bit_44 : 'd0;

assign layer_1_bit_39 = shift[3:2] == 2'd0 ? layer_0_bit_39 :
                        shift[3:2] == 2'd1 ? layer_0_bit_43 : 'd0;

assign layer_1_bit_38 = shift[3:2] == 2'd0 ? layer_0_bit_38 :
                        shift[3:2] == 2'd1 ? layer_0_bit_42 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_46 : 'd0;

assign layer_1_bit_37 = shift[3:2] == 2'd0 ? layer_0_bit_37 :
                        shift[3:2] == 2'd1 ? layer_0_bit_41 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_45 : 'd0;

assign layer_1_bit_36 = shift[3:2] == 2'd0 ? layer_0_bit_36 :
                        shift[3:2] == 2'd1 ? layer_0_bit_40 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_44 : 'd0;

assign layer_1_bit_35 = shift[3:2] == 2'd0 ? layer_0_bit_35 :
                        shift[3:2] == 2'd1 ? layer_0_bit_39 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_43 : 'd0;

assign layer_1_bit_34 = shift[3:2] == 2'd0 ? layer_0_bit_34 :
                        shift[3:2] == 2'd1 ? layer_0_bit_38 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_42 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_46 : 'd0;

assign layer_1_bit_33 = shift[3:2] == 2'd0 ? layer_0_bit_33 :
                        shift[3:2] == 2'd1 ? layer_0_bit_37 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_41 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_45 : 'd0;

assign layer_1_bit_32 = shift[3:2] == 2'd0 ? layer_0_bit_32 :
                        shift[3:2] == 2'd1 ? layer_0_bit_36 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_40 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_44 : 'd0;

assign layer_1_bit_31 = shift[3:2] == 2'd0 ? layer_0_bit_31 :
                        shift[3:2] == 2'd1 ? layer_0_bit_35 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_39 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_43 : 'd0;

assign layer_1_bit_30 = shift[3:2] == 2'd0 ? layer_0_bit_30 :
                        shift[3:2] == 2'd1 ? layer_0_bit_34 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_38 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_42 : 
                        'd0;

assign layer_1_bit_29 = shift[3:2] == 2'd0 ? layer_0_bit_29 :
                        shift[3:2] == 2'd1 ? layer_0_bit_33 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_37 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_41 : 
                        'd0;

assign layer_1_bit_28 = shift[3:2] == 2'd0 ? layer_0_bit_28 :
                        shift[3:2] == 2'd1 ? layer_0_bit_32 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_36 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_40 : 
                        'd0;

assign layer_1_bit_27 = shift[3:2] == 2'd0 ? layer_0_bit_27 :
                        shift[3:2] == 2'd1 ? layer_0_bit_31 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_35 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_39 : 
                        'd0;

assign layer_1_bit_26 = shift[3:2] == 2'd0 ? layer_0_bit_26 :
                        shift[3:2] == 2'd1 ? layer_0_bit_30 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_34 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_38 : 
                        'd0;

assign layer_1_bit_25 = shift[3:2] == 2'd0 ? layer_0_bit_25 :
                        shift[3:2] == 2'd1 ? layer_0_bit_29 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_33 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_37 : 
                        'd0;

assign layer_1_bit_24 = shift[3:2] == 2'd0 ? layer_0_bit_24 :
                        shift[3:2] == 2'd1 ? layer_0_bit_28 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_32 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_36 : 
                        'd0;

assign layer_1_bit_23 = shift[3:2] == 2'd0 ? layer_0_bit_23 :
                        shift[3:2] == 2'd1 ? layer_0_bit_27 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_31 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_35 : 
                        'd0;

assign layer_1_bit_22 = shift[3:2] == 2'd0 ? layer_0_bit_22 :
                        shift[3:2] == 2'd1 ? layer_0_bit_26 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_30 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_34 : 
                        'd0;

assign layer_1_bit_21 = shift[3:2] == 2'd0 ? layer_0_bit_21 :
                        shift[3:2] == 2'd1 ? layer_0_bit_25 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_29 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_33 : 
                        'd0;

assign layer_1_bit_20 = shift[3:2] == 2'd0 ? layer_0_bit_20 :
                        shift[3:2] == 2'd1 ? layer_0_bit_24 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_28 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_32 : 
                        'd0;

assign layer_1_bit_19 = shift[3:2] == 2'd0 ? layer_0_bit_19 :
                        shift[3:2] == 2'd1 ? layer_0_bit_23 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_27 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_31 : 
                        'd0;

assign layer_1_bit_18 = shift[3:2] == 2'd0 ? layer_0_bit_18 :
                        shift[3:2] == 2'd1 ? layer_0_bit_22 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_26 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_30 : 
                        'd0;

assign layer_1_bit_17 = shift[3:2] == 2'd0 ? layer_0_bit_17 :
                        shift[3:2] == 2'd1 ? layer_0_bit_21 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_25 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_29 : 
                        'd0;

assign layer_1_bit_16 = shift[3:2] == 2'd0 ? layer_0_bit_16 :
                        shift[3:2] == 2'd1 ? layer_0_bit_20 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_24 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_28 : 
                        'd0;

assign layer_1_bit_15 = shift[3:2] == 2'd0 ? layer_0_bit_15 :
                        shift[3:2] == 2'd1 ? layer_0_bit_19 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_23 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_27 : 
                        'd0;

assign layer_1_bit_14 = shift[3:2] == 2'd0 ? layer_0_bit_14 :
                        shift[3:2] == 2'd1 ? layer_0_bit_18 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_22 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_26 : 
                        'd0;

assign layer_1_bit_13 = shift[3:2] == 2'd0 ? layer_0_bit_13 :
                        shift[3:2] == 2'd1 ? layer_0_bit_17 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_21 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_25 : 
                        'd0;

assign layer_1_bit_12 = shift[3:2] == 2'd0 ? layer_0_bit_12 :
                        shift[3:2] == 2'd1 ? layer_0_bit_16 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_20 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_24 : 
                        'd0;

assign layer_1_bit_11 = shift[3:2] == 2'd0 ? layer_0_bit_11 :
                        shift[3:2] == 2'd1 ? layer_0_bit_15 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_19 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_23 : 
                        'd0;

assign layer_1_bit_10 = shift[3:2] == 2'd0 ? layer_0_bit_10 :
                        shift[3:2] == 2'd1 ? layer_0_bit_14 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_18 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_22 : 
                        'd0;

assign layer_1_bit_9 = shift[3:2] == 2'd0 ? layer_0_bit_9 :
                        shift[3:2] == 2'd1 ? layer_0_bit_13 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_17 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_21 : 
                        'd0;

assign layer_1_bit_8 = shift[3:2] == 2'd0 ? layer_0_bit_8 :
                        shift[3:2] == 2'd1 ? layer_0_bit_12 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_16 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_20 : 
                        'd0;

assign layer_1_bit_7 = shift[3:2] == 2'd0 ? layer_0_bit_7 :
                        shift[3:2] == 2'd1 ? layer_0_bit_11 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_15 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_19 : 
                        'd0;

assign layer_1_bit_6 = shift[3:2] == 2'd0 ? layer_0_bit_6 :
                        shift[3:2] == 2'd1 ? layer_0_bit_10 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_14 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_18 : 
                        'd0;

assign layer_1_bit_5 = shift[3:2] == 2'd0 ? layer_0_bit_5 :
                        shift[3:2] == 2'd1 ? layer_0_bit_9 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_13 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_17 : 
                        'd0;

assign layer_1_bit_4 = shift[3:2] == 2'd0 ? layer_0_bit_4 :
                        shift[3:2] == 2'd1 ? layer_0_bit_8 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_12 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_16 : 
                        'd0;

assign layer_1_bit_3 = shift[3:2] == 2'd0 ? layer_0_bit_3 :
                        shift[3:2] == 2'd1 ? layer_0_bit_7 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_11 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_15 : 
                        'd0;

assign layer_1_bit_2 = shift[3:2] == 2'd0 ? layer_0_bit_2 :
                        shift[3:2] == 2'd1 ? layer_0_bit_6 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_10 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_14 : 
                        'd0;

assign layer_1_bit_1 = shift[3:2] == 2'd0 ? layer_0_bit_1 :
                        shift[3:2] == 2'd1 ? layer_0_bit_5 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_9 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_13 : 
                        'd0;

assign layer_1_bit_0 = shift[3:2] == 2'd0 ? layer_0_bit_0 :
                        shift[3:2] == 2'd1 ? layer_0_bit_4 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_8 : 
                        shift[3:2] == 2'd3 ? layer_0_bit_12 : 
                        'd0;

assign layer_2_bit_46 = shift[5:4] == 2'd0 ? layer_1_bit_46 : 'd0;

assign layer_2_bit_45 = shift[5:4] == 2'd0 ? layer_1_bit_45 : 'd0;

assign layer_2_bit_44 = shift[5:4] == 2'd0 ? layer_1_bit_44 : 'd0;

assign layer_2_bit_43 = shift[5:4] == 2'd0 ? layer_1_bit_43 : 'd0;

assign layer_2_bit_42 = shift[5:4] == 2'd0 ? layer_1_bit_42 : 'd0;

assign layer_2_bit_41 = shift[5:4] == 2'd0 ? layer_1_bit_41 : 'd0;

assign layer_2_bit_40 = shift[5:4] == 2'd0 ? layer_1_bit_40 : 'd0;

assign layer_2_bit_39 = shift[5:4] == 2'd0 ? layer_1_bit_39 : 'd0;

assign layer_2_bit_38 = shift[5:4] == 2'd0 ? layer_1_bit_38 : 'd0;

assign layer_2_bit_37 = shift[5:4] == 2'd0 ? layer_1_bit_37 : 'd0;

assign layer_2_bit_36 = shift[5:4] == 2'd0 ? layer_1_bit_36 : 'd0;

assign layer_2_bit_35 = shift[5:4] == 2'd0 ? layer_1_bit_35 : 'd0;

assign layer_2_bit_34 = shift[5:4] == 2'd0 ? layer_1_bit_34 : 'd0;

assign layer_2_bit_33 = shift[5:4] == 2'd0 ? layer_1_bit_33 : 'd0;

assign layer_2_bit_32 = shift[5:4] == 2'd0 ? layer_1_bit_32 : 'd0;

assign layer_2_bit_31 = shift[5:4] == 2'd0 ? layer_1_bit_31 : 'd0;

assign layer_2_bit_30 = shift[5:4] == 2'd0 ? layer_1_bit_30 :
                        shift[5:4] == 2'd1 ? layer_1_bit_46 : 'd0;

assign layer_2_bit_29 = shift[5:4] == 2'd0 ? layer_1_bit_29 :
                        shift[5:4] == 2'd1 ? layer_1_bit_45 : 'd0;

assign layer_2_bit_28 = shift[5:4] == 2'd0 ? layer_1_bit_28 :
                        shift[5:4] == 2'd1 ? layer_1_bit_44 : 'd0;

assign layer_2_bit_27 = shift[5:4] == 2'd0 ? layer_1_bit_27 :
                        shift[5:4] == 2'd1 ? layer_1_bit_43 : 'd0;

assign layer_2_bit_26 = shift[5:4] == 2'd0 ? layer_1_bit_26 :
                        shift[5:4] == 2'd1 ? layer_1_bit_42 : 'd0;

assign layer_2_bit_25 = shift[5:4] == 2'd0 ? layer_1_bit_25 :
                        shift[5:4] == 2'd1 ? layer_1_bit_41 : 'd0;

assign layer_2_bit_24 = shift[5:4] == 2'd0 ? layer_1_bit_24 :
                        shift[5:4] == 2'd1 ? layer_1_bit_40 : 'd0;

assign layer_2_bit_23 = shift[5:4] == 2'd0 ? layer_1_bit_23 :
                        shift[5:4] == 2'd1 ? layer_1_bit_39 : 'd0;

assign layer_2_bit_22 = shift[5:4] == 2'd0 ? layer_1_bit_22 :
                        shift[5:4] == 2'd1 ? layer_1_bit_38 : 'd0;

assign layer_2_bit_21 = shift[5:4] == 2'd0 ? layer_1_bit_21 :
                        shift[5:4] == 2'd1 ? layer_1_bit_37 : 'd0;

assign layer_2_bit_20 = shift[5:4] == 2'd0 ? layer_1_bit_20 :
                        shift[5:4] == 2'd1 ? layer_1_bit_36 : 'd0;

assign layer_2_bit_19 = shift[5:4] == 2'd0 ? layer_1_bit_19 :
                        shift[5:4] == 2'd1 ? layer_1_bit_35 : 'd0;

assign layer_2_bit_18 = shift[5:4] == 2'd0 ? layer_1_bit_18 :
                        shift[5:4] == 2'd1 ? layer_1_bit_34 : 'd0;

assign layer_2_bit_17 = shift[5:4] == 2'd0 ? layer_1_bit_17 :
                        shift[5:4] == 2'd1 ? layer_1_bit_33 : 'd0;

assign layer_2_bit_16 = shift[5:4] == 2'd0 ? layer_1_bit_16 :
                        shift[5:4] == 2'd1 ? layer_1_bit_32 : 'd0;

assign layer_2_bit_15 = shift[5:4] == 2'd0 ? layer_1_bit_15 :
                        shift[5:4] == 2'd1 ? layer_1_bit_31 : 'd0;

assign layer_2_bit_14 = shift[5:4] == 2'd0 ? layer_1_bit_14 :
                        shift[5:4] == 2'd1 ? layer_1_bit_30 :
                        shift[5:4] == 2'd2 ? layer_1_bit_46 : 'd0;

assign layer_2_bit_13 = shift[5:4] == 2'd0 ? layer_1_bit_13 :
                        shift[5:4] == 2'd1 ? layer_1_bit_29 :
                        shift[5:4] == 2'd2 ? layer_1_bit_45 : 'd0;

assign layer_2_bit_12 = shift[5:4] == 2'd0 ? layer_1_bit_12 :
                        shift[5:4] == 2'd1 ? layer_1_bit_28 :
                        shift[5:4] == 2'd2 ? layer_1_bit_44 : 'd0;

assign layer_2_bit_11 = shift[5:4] == 2'd0 ? layer_1_bit_11 :
                        shift[5:4] == 2'd1 ? layer_1_bit_27 :
                        shift[5:4] == 2'd2 ? layer_1_bit_43 : 'd0;

assign layer_2_bit_10 = shift[5:4] == 2'd0 ? layer_1_bit_10 :
                        shift[5:4] == 2'd1 ? layer_1_bit_26 :
                        shift[5:4] == 2'd2 ? layer_1_bit_42 :
                        shift[5:4] == 2'd3 ? layer_1_bit_46 : 'd0;

assign layer_2_bit_9 = shift[5:4] == 2'd0 ? layer_1_bit_9 :
                        shift[5:4] == 2'd1 ? layer_1_bit_25 :
                        shift[5:4] == 2'd2 ? layer_1_bit_41 : 'd0;

assign layer_2_bit_8 = shift[5:4] == 2'd0 ? layer_1_bit_8 :
                        shift[5:4] == 2'd1 ? layer_1_bit_24 :
                        shift[5:4] == 2'd2 ? layer_1_bit_40 : 'd0;

assign layer_2_bit_7 = shift[5:4] == 2'd0 ? layer_1_bit_7 :
                        shift[5:4] == 2'd1 ? layer_1_bit_23 :
                        shift[5:4] == 2'd2 ? layer_1_bit_39 : 'd0;

assign layer_2_bit_6 = shift[5:4] == 2'd0 ? layer_1_bit_6 :
                        shift[5:4] == 2'd1 ? layer_1_bit_22 :
                        shift[5:4] == 2'd2 ? layer_1_bit_38 : 'd0;

assign layer_2_bit_5 = shift[5:4] == 2'd0 ? layer_1_bit_5 :
                        shift[5:4] == 2'd1 ? layer_1_bit_21 :
                        shift[5:4] == 2'd2 ? layer_1_bit_37 : 'd0;

assign layer_2_bit_4 = shift[5:4] == 2'd0 ? layer_1_bit_4 :
                        shift[5:4] == 2'd1 ? layer_1_bit_20 :
                        shift[5:4] == 2'd2 ? layer_1_bit_36 : 'd0;

assign layer_2_bit_3 = shift[5:4] == 2'd0 ? layer_1_bit_3 :
                        shift[5:4] == 2'd1 ? layer_1_bit_19 :
                        shift[5:4] == 2'd2 ? layer_1_bit_35 : 'd0;

assign layer_2_bit_2 = shift[5:4] == 2'd0 ? layer_1_bit_2 :
                        shift[5:4] == 2'd1 ? layer_1_bit_18 :
                        shift[5:4] == 2'd2 ? layer_1_bit_34 : 'd0;

assign layer_2_bit_1 = shift[5:4] == 2'd0 ? layer_1_bit_1 :
                        shift[5:4] == 2'd1 ? layer_1_bit_17 :
                        shift[5:4] == 2'd2 ? layer_1_bit_33 : 'd0;

assign layer_2_bit_0 = shift[5:4] == 2'd0 ? layer_1_bit_0 :
                        shift[5:4] == 2'd1 ? layer_1_bit_16 :
                        shift[5:4] == 2'd2 ? layer_1_bit_32 : 'd0;

assign o = shift > 'd46 ? 'd0 : {layer_2_bit_46, layer_2_bit_45, layer_2_bit_44, layer_2_bit_43, layer_2_bit_42, layer_2_bit_41, layer_2_bit_40, layer_2_bit_39, layer_2_bit_38, layer_2_bit_37, layer_2_bit_36, layer_2_bit_35, layer_2_bit_34, layer_2_bit_33, layer_2_bit_32, layer_2_bit_31, layer_2_bit_30, layer_2_bit_29, layer_2_bit_28, layer_2_bit_27, layer_2_bit_26, layer_2_bit_25, layer_2_bit_24, layer_2_bit_23, layer_2_bit_22, layer_2_bit_21, layer_2_bit_20, layer_2_bit_19, layer_2_bit_18, layer_2_bit_17, layer_2_bit_16, layer_2_bit_15, layer_2_bit_14, layer_2_bit_13, layer_2_bit_12, layer_2_bit_11, layer_2_bit_10, layer_2_bit_9, layer_2_bit_8, layer_2_bit_7, layer_2_bit_6, layer_2_bit_5, layer_2_bit_4, layer_2_bit_3, layer_2_bit_2, layer_2_bit_1, layer_2_bit_0};

endmodule