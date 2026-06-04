module shifter_right_71_8(
  data, shift,
  o
);

input       [70:0] data;
input       [7:0]  shift;
output wire [70:0] o;

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
wire layer_0_bit_47;
wire layer_0_bit_48;
wire layer_0_bit_49;
wire layer_0_bit_50;
wire layer_0_bit_51;
wire layer_0_bit_52;
wire layer_0_bit_53;
wire layer_0_bit_54;
wire layer_0_bit_55;
wire layer_0_bit_56;
wire layer_0_bit_57;
wire layer_0_bit_58;
wire layer_0_bit_59;
wire layer_0_bit_60;
wire layer_0_bit_61;
wire layer_0_bit_62;
wire layer_0_bit_63;
wire layer_0_bit_64;
wire layer_0_bit_65;
wire layer_0_bit_66;
wire layer_0_bit_67;
wire layer_0_bit_68;
wire layer_0_bit_69;
wire layer_0_bit_70;

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
wire layer_1_bit_47;
wire layer_1_bit_48;
wire layer_1_bit_49;
wire layer_1_bit_50;
wire layer_1_bit_51;
wire layer_1_bit_52;
wire layer_1_bit_53;
wire layer_1_bit_54;
wire layer_1_bit_55;
wire layer_1_bit_56;
wire layer_1_bit_57;
wire layer_1_bit_58;
wire layer_1_bit_59;
wire layer_1_bit_60;
wire layer_1_bit_61;
wire layer_1_bit_62;
wire layer_1_bit_63;
wire layer_1_bit_64;
wire layer_1_bit_65;
wire layer_1_bit_66;
wire layer_1_bit_67;
wire layer_1_bit_68;
wire layer_1_bit_69;
wire layer_1_bit_70;

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
wire layer_2_bit_47;
wire layer_2_bit_48;
wire layer_2_bit_49;
wire layer_2_bit_50;
wire layer_2_bit_51;
wire layer_2_bit_52;
wire layer_2_bit_53;
wire layer_2_bit_54;
wire layer_2_bit_55;
wire layer_2_bit_56;
wire layer_2_bit_57;
wire layer_2_bit_58;
wire layer_2_bit_59;
wire layer_2_bit_60;
wire layer_2_bit_61;
wire layer_2_bit_62;
wire layer_2_bit_63;
wire layer_2_bit_64;
wire layer_2_bit_65;
wire layer_2_bit_66;
wire layer_2_bit_67;
wire layer_2_bit_68;
wire layer_2_bit_69;
wire layer_2_bit_70;

wire layer_3_bit_0;
wire layer_3_bit_1;
wire layer_3_bit_2;
wire layer_3_bit_3;
wire layer_3_bit_4;
wire layer_3_bit_5;
wire layer_3_bit_6;
wire layer_3_bit_7;
wire layer_3_bit_8;
wire layer_3_bit_9;
wire layer_3_bit_10;
wire layer_3_bit_11;
wire layer_3_bit_12;
wire layer_3_bit_13;
wire layer_3_bit_14;
wire layer_3_bit_15;
wire layer_3_bit_16;
wire layer_3_bit_17;
wire layer_3_bit_18;
wire layer_3_bit_19;
wire layer_3_bit_20;
wire layer_3_bit_21;
wire layer_3_bit_22;
wire layer_3_bit_23;
wire layer_3_bit_24;
wire layer_3_bit_25;
wire layer_3_bit_26;
wire layer_3_bit_27;
wire layer_3_bit_28;
wire layer_3_bit_29;
wire layer_3_bit_30;
wire layer_3_bit_31;
wire layer_3_bit_32;
wire layer_3_bit_33;
wire layer_3_bit_34;
wire layer_3_bit_35;
wire layer_3_bit_36;
wire layer_3_bit_37;
wire layer_3_bit_38;
wire layer_3_bit_39;
wire layer_3_bit_40;
wire layer_3_bit_41;
wire layer_3_bit_42;
wire layer_3_bit_43;
wire layer_3_bit_44;
wire layer_3_bit_45;
wire layer_3_bit_46;
wire layer_3_bit_47;
wire layer_3_bit_48;
wire layer_3_bit_49;
wire layer_3_bit_50;
wire layer_3_bit_51;
wire layer_3_bit_52;
wire layer_3_bit_53;
wire layer_3_bit_54;
wire layer_3_bit_55;
wire layer_3_bit_56;
wire layer_3_bit_57;
wire layer_3_bit_58;
wire layer_3_bit_59;
wire layer_3_bit_60;
wire layer_3_bit_61;
wire layer_3_bit_62;
wire layer_3_bit_63;
wire layer_3_bit_64;
wire layer_3_bit_65;
wire layer_3_bit_66;
wire layer_3_bit_67;
wire layer_3_bit_68;
wire layer_3_bit_69;
wire layer_3_bit_70;

assign layer_0_bit_70 = shift[1:0] == 2'd0 ? data[70] : 1'b0;

assign layer_0_bit_69 = shift[1:0] == 2'd0 ? data[69] :
                        shift[1:0] == 2'd1 ? data[70] : 1'b0;

assign layer_0_bit_68 = shift[1:0] == 2'd0 ? data[68] :
                        shift[1:0] == 2'd1 ? data[69] :
                        shift[1:0] == 2'd2 ? data[70] : 1'b0;

assign layer_0_bit_67 = shift[1:0] == 2'd0 ? data[67] :
                        shift[1:0] == 2'd1 ? data[68] :
                        shift[1:0] == 2'd2 ? data[69] :
                        shift[1:0] == 2'd3 ? data[70] : 1'b0;

assign layer_0_bit_66 = shift[1:0] == 2'd0 ? data[66] :
                        shift[1:0] == 2'd1 ? data[67] :
                        shift[1:0] == 2'd2 ? data[68] :
                        shift[1:0] == 2'd3 ? data[69] : 1'b0;

assign layer_0_bit_65 = shift[1:0] == 2'd0 ? data[65] :
                        shift[1:0] == 2'd1 ? data[66] :
                        shift[1:0] == 2'd2 ? data[67] :
                        shift[1:0] == 2'd3 ? data[68] : 1'b0;

assign layer_0_bit_64 = shift[1:0] == 2'd0 ? data[64] :
                        shift[1:0] == 2'd1 ? data[65] :
                        shift[1:0] == 2'd2 ? data[66] :
                        shift[1:0] == 2'd3 ? data[67] : 1'b0;

assign layer_0_bit_63 = shift[1:0] == 2'd0 ? data[63] :
                        shift[1:0] == 2'd1 ? data[64] :
                        shift[1:0] == 2'd2 ? data[65] :
                        shift[1:0] == 2'd3 ? data[66] : 1'b0;

assign layer_0_bit_62 = shift[1:0] == 2'd0 ? data[62] :
                        shift[1:0] == 2'd1 ? data[63] :
                        shift[1:0] == 2'd2 ? data[64] :
                        shift[1:0] == 2'd3 ? data[65] : 1'b0;

assign layer_0_bit_61 = shift[1:0] == 2'd0 ? data[61] :
                        shift[1:0] == 2'd1 ? data[62] :
                        shift[1:0] == 2'd2 ? data[63] :
                        shift[1:0] == 2'd3 ? data[64] : 1'b0;

assign layer_0_bit_60 = shift[1:0] == 2'd0 ? data[60] :
                        shift[1:0] == 2'd1 ? data[61] :
                        shift[1:0] == 2'd2 ? data[62] :
                        shift[1:0] == 2'd3 ? data[63] : 1'b0;

assign layer_0_bit_59 = shift[1:0] == 2'd0 ? data[59] :
                        shift[1:0] == 2'd1 ? data[60] :
                        shift[1:0] == 2'd2 ? data[61] :
                        shift[1:0] == 2'd3 ? data[62] : 1'b0;

assign layer_0_bit_58 = shift[1:0] == 2'd0 ? data[58] :
                        shift[1:0] == 2'd1 ? data[59] :
                        shift[1:0] == 2'd2 ? data[60] :
                        shift[1:0] == 2'd3 ? data[61] : 1'b0;

assign layer_0_bit_57 = shift[1:0] == 2'd0 ? data[57] :
                        shift[1:0] == 2'd1 ? data[58] :
                        shift[1:0] == 2'd2 ? data[59] :
                        shift[1:0] == 2'd3 ? data[60] : 1'b0;

assign layer_0_bit_56 = shift[1:0] == 2'd0 ? data[56] :
                        shift[1:0] == 2'd1 ? data[57] :
                        shift[1:0] == 2'd2 ? data[58] :
                        shift[1:0] == 2'd3 ? data[59] : 1'b0;

assign layer_0_bit_55 = shift[1:0] == 2'd0 ? data[55] :
                        shift[1:0] == 2'd1 ? data[56] :
                        shift[1:0] == 2'd2 ? data[57] :
                        shift[1:0] == 2'd3 ? data[58] : 1'b0;

assign layer_0_bit_54 = shift[1:0] == 2'd0 ? data[54] :
                        shift[1:0] == 2'd1 ? data[55] :
                        shift[1:0] == 2'd2 ? data[56] :
                        shift[1:0] == 2'd3 ? data[57] : 1'b0;

assign layer_0_bit_53 = shift[1:0] == 2'd0 ? data[53] :
                        shift[1:0] == 2'd1 ? data[54] :
                        shift[1:0] == 2'd2 ? data[55] :
                        shift[1:0] == 2'd3 ? data[56] : 1'b0;

assign layer_0_bit_52 = shift[1:0] == 2'd0 ? data[52] :
                        shift[1:0] == 2'd1 ? data[53] :
                        shift[1:0] == 2'd2 ? data[54] :
                        shift[1:0] == 2'd3 ? data[55] : 1'b0;

assign layer_0_bit_51 = shift[1:0] == 2'd0 ? data[51] :
                        shift[1:0] == 2'd1 ? data[52] :
                        shift[1:0] == 2'd2 ? data[53] :
                        shift[1:0] == 2'd3 ? data[54] : 1'b0;

assign layer_0_bit_50 = shift[1:0] == 2'd0 ? data[50] :
                        shift[1:0] == 2'd1 ? data[51] :
                        shift[1:0] == 2'd2 ? data[52] :
                        shift[1:0] == 2'd3 ? data[53] : 1'b0;

assign layer_0_bit_49 = shift[1:0] == 2'd0 ? data[49] :
                        shift[1:0] == 2'd1 ? data[50] :
                        shift[1:0] == 2'd2 ? data[51] :
                        shift[1:0] == 2'd3 ? data[52] : 1'b0;

assign layer_0_bit_48 = shift[1:0] == 2'd0 ? data[48] :
                        shift[1:0] == 2'd1 ? data[49] :
                        shift[1:0] == 2'd2 ? data[50] :
                        shift[1:0] == 2'd3 ? data[51] : 1'b0;

assign layer_0_bit_47 = shift[1:0] == 2'd0 ? data[47] :
                        shift[1:0] == 2'd1 ? data[48] :
                        shift[1:0] == 2'd2 ? data[49] :
                        shift[1:0] == 2'd3 ? data[50] : 1'b0;

assign layer_0_bit_46 = shift[1:0] == 2'd0 ? data[46] :
                        shift[1:0] == 2'd1 ? data[47] :
                        shift[1:0] == 2'd2 ? data[48] :
                        shift[1:0] == 2'd3 ? data[49] : 1'b0;

assign layer_0_bit_45 = shift[1:0] == 2'd0 ? data[45] :
                        shift[1:0] == 2'd1 ? data[46] :
                        shift[1:0] == 2'd2 ? data[47] :
                        shift[1:0] == 2'd3 ? data[48] : 1'b0;

assign layer_0_bit_44 = shift[1:0] == 2'd0 ? data[44] :
                        shift[1:0] == 2'd1 ? data[45] :
                        shift[1:0] == 2'd2 ? data[46] :
                        shift[1:0] == 2'd3 ? data[47] : 1'b0;

assign layer_0_bit_43 = shift[1:0] == 2'd0 ? data[43] :
                        shift[1:0] == 2'd1 ? data[44] :
                        shift[1:0] == 2'd2 ? data[45] :
                        shift[1:0] == 2'd3 ? data[46] : 1'b0;

assign layer_0_bit_42 = shift[1:0] == 2'd0 ? data[42] :
                        shift[1:0] == 2'd1 ? data[43] :
                        shift[1:0] == 2'd2 ? data[44] :
                        shift[1:0] == 2'd3 ? data[45] : 1'b0;

assign layer_0_bit_41 = shift[1:0] == 2'd0 ? data[41] :
                        shift[1:0] == 2'd1 ? data[42] :
                        shift[1:0] == 2'd2 ? data[43] :
                        shift[1:0] == 2'd3 ? data[44] : 1'b0;

assign layer_0_bit_40 = shift[1:0] == 2'd0 ? data[40] :
                        shift[1:0] == 2'd1 ? data[41] :
                        shift[1:0] == 2'd2 ? data[42] :
                        shift[1:0] == 2'd3 ? data[43] : 1'b0;

assign layer_0_bit_39 = shift[1:0] == 2'd0 ? data[39] :
                        shift[1:0] == 2'd1 ? data[40] :
                        shift[1:0] == 2'd2 ? data[41] :
                        shift[1:0] == 2'd3 ? data[42] : 1'b0;

assign layer_0_bit_38 = shift[1:0] == 2'd0 ? data[38] :
                        shift[1:0] == 2'd1 ? data[39] :
                        shift[1:0] == 2'd2 ? data[40] :
                        shift[1:0] == 2'd3 ? data[41] : 1'b0;

assign layer_0_bit_37 = shift[1:0] == 2'd0 ? data[37] :
                        shift[1:0] == 2'd1 ? data[38] :
                        shift[1:0] == 2'd2 ? data[39] :
                        shift[1:0] == 2'd3 ? data[40] : 1'b0;

assign layer_0_bit_36 = shift[1:0] == 2'd0 ? data[36] :
                        shift[1:0] == 2'd1 ? data[37] :
                        shift[1:0] == 2'd2 ? data[38] :
                        shift[1:0] == 2'd3 ? data[39] : 1'b0;

assign layer_0_bit_35 = shift[1:0] == 2'd0 ? data[35] :
                        shift[1:0] == 2'd1 ? data[36] :
                        shift[1:0] == 2'd2 ? data[37] :
                        shift[1:0] == 2'd3 ? data[38] : 1'b0;

assign layer_0_bit_34 = shift[1:0] == 2'd0 ? data[34] :
                        shift[1:0] == 2'd1 ? data[35] :
                        shift[1:0] == 2'd2 ? data[36] :
                        shift[1:0] == 2'd3 ? data[37] : 1'b0;

assign layer_0_bit_33 = shift[1:0] == 2'd0 ? data[33] :
                        shift[1:0] == 2'd1 ? data[34] :
                        shift[1:0] == 2'd2 ? data[35] :
                        shift[1:0] == 2'd3 ? data[36] : 1'b0;

assign layer_0_bit_32 = shift[1:0] == 2'd0 ? data[32] :
                        shift[1:0] == 2'd1 ? data[33] :
                        shift[1:0] == 2'd2 ? data[34] :
                        shift[1:0] == 2'd3 ? data[35] : 1'b0;

assign layer_0_bit_31 = shift[1:0] == 2'd0 ? data[31] :
                        shift[1:0] == 2'd1 ? data[32] :
                        shift[1:0] == 2'd2 ? data[33] :
                        shift[1:0] == 2'd3 ? data[34] : 1'b0;

assign layer_0_bit_30 = shift[1:0] == 2'd0 ? data[30] :
                        shift[1:0] == 2'd1 ? data[31] :
                        shift[1:0] == 2'd2 ? data[32] :
                        shift[1:0] == 2'd3 ? data[33] : 1'b0;

assign layer_0_bit_29 = shift[1:0] == 2'd0 ? data[29] :
                        shift[1:0] == 2'd1 ? data[30] :
                        shift[1:0] == 2'd2 ? data[31] :
                        shift[1:0] == 2'd3 ? data[32] : 1'b0;

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

assign layer_1_bit_70 = shift[3:2] == 2'd0 ? layer_0_bit_70 : 1'b0;

assign layer_1_bit_69 = shift[3:2] == 2'd0 ? layer_0_bit_69 : 1'b0;

assign layer_1_bit_68 = shift[3:2] == 2'd0 ? layer_0_bit_68 : 1'b0;

assign layer_1_bit_67 = shift[3:2] == 2'd0 ? layer_0_bit_67 : 1'b0;

assign layer_1_bit_66 = shift[3:2] == 2'd0 ? layer_0_bit_66 : 
                        shift[3:2] == 2'd1 ? layer_0_bit_70 : 1'b0;

assign layer_1_bit_65 = shift[3:2] == 2'd0 ? layer_0_bit_65 : 
                        shift[3:2] == 2'd1 ? layer_0_bit_69 : 1'b0;

assign layer_1_bit_64 = shift[3:2] == 2'd0 ? layer_0_bit_64 : 
                        shift[3:2] == 2'd1 ? layer_0_bit_68 : 1'b0;

assign layer_1_bit_63 = shift[3:2] == 2'd0 ? layer_0_bit_63 : 
                        shift[3:2] == 2'd1 ? layer_0_bit_67 : 1'b0;

assign layer_1_bit_62 = shift[3:2] == 2'd0 ? layer_0_bit_62 : 
                        shift[3:2] == 2'd1 ? layer_0_bit_66 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_70 : 1'b0;

assign layer_1_bit_61 = shift[3:2] == 2'd0 ? layer_0_bit_61 : 
                        shift[3:2] == 2'd1 ? layer_0_bit_65 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_69 : 1'b0;

assign layer_1_bit_60 = shift[3:2] == 2'd0 ? layer_0_bit_60 : 
                        shift[3:2] == 2'd1 ? layer_0_bit_64 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_68 : 1'b0;

assign layer_1_bit_59 = shift[3:2] == 2'd0 ? layer_0_bit_59 : 
                        shift[3:2] == 2'd1 ? layer_0_bit_63 : 
                        shift[3:2] == 2'd2 ? layer_0_bit_67 : 1'b0;

assign layer_1_bit_58 = shift[3:2] == 2'd0 ? layer_0_bit_58 :
                        shift[3:2] == 2'd1 ? layer_0_bit_62 :
                        shift[3:2] == 2'd2 ? layer_0_bit_66 :
                        shift[3:2] == 2'd3 ? layer_0_bit_70 : 1'b0;

assign layer_1_bit_57 = shift[3:2] == 2'd0 ? layer_0_bit_57 :
                        shift[3:2] == 2'd1 ? layer_0_bit_61 :
                        shift[3:2] == 2'd2 ? layer_0_bit_65 :
                        shift[3:2] == 2'd3 ? layer_0_bit_69 : 1'b0;

assign layer_1_bit_56 = shift[3:2] == 2'd0 ? layer_0_bit_56 :
                        shift[3:2] == 2'd1 ? layer_0_bit_60 :
                        shift[3:2] == 2'd2 ? layer_0_bit_64 :
                        shift[3:2] == 2'd3 ? layer_0_bit_68 : 1'b0;

assign layer_1_bit_55 = shift[3:2] == 2'd0 ? layer_0_bit_55 :
                        shift[3:2] == 2'd1 ? layer_0_bit_59 :
                        shift[3:2] == 2'd2 ? layer_0_bit_63 :
                        shift[3:2] == 2'd3 ? layer_0_bit_67 : 1'b0;

assign layer_1_bit_54 = shift[3:2] == 2'd0 ? layer_0_bit_54 :
                        shift[3:2] == 2'd1 ? layer_0_bit_58 :
                        shift[3:2] == 2'd2 ? layer_0_bit_62 :
                        shift[3:2] == 2'd3 ? layer_0_bit_66 : 1'b0;

assign layer_1_bit_53 = shift[3:2] == 2'd0 ? layer_0_bit_53 :
                        shift[3:2] == 2'd1 ? layer_0_bit_57 :
                        shift[3:2] == 2'd2 ? layer_0_bit_61 :
                        shift[3:2] == 2'd3 ? layer_0_bit_65 : 1'b0;

assign layer_1_bit_52 = shift[3:2] == 2'd0 ? layer_0_bit_52 :
                        shift[3:2] == 2'd1 ? layer_0_bit_56 :
                        shift[3:2] == 2'd2 ? layer_0_bit_60 :
                        shift[3:2] == 2'd3 ? layer_0_bit_64 : 1'b0;

assign layer_1_bit_51 = shift[3:2] == 2'd0 ? layer_0_bit_51 :
                        shift[3:2] == 2'd1 ? layer_0_bit_55 :
                        shift[3:2] == 2'd2 ? layer_0_bit_59 :
                        shift[3:2] == 2'd3 ? layer_0_bit_63 : 1'b0;

assign layer_1_bit_50 = shift[3:2] == 2'd0 ? layer_0_bit_50 :
                        shift[3:2] == 2'd1 ? layer_0_bit_54 :
                        shift[3:2] == 2'd2 ? layer_0_bit_58 :
                        shift[3:2] == 2'd3 ? layer_0_bit_62 : 1'b0;

assign layer_1_bit_49 = shift[3:2] == 2'd0 ? layer_0_bit_49 :
                        shift[3:2] == 2'd1 ? layer_0_bit_53 :
                        shift[3:2] == 2'd2 ? layer_0_bit_57 :
                        shift[3:2] == 2'd3 ? layer_0_bit_61 : 1'b0;

assign layer_1_bit_48 = shift[3:2] == 2'd0 ? layer_0_bit_48 :
                        shift[3:2] == 2'd1 ? layer_0_bit_52 :
                        shift[3:2] == 2'd2 ? layer_0_bit_56 :
                        shift[3:2] == 2'd3 ? layer_0_bit_60 : 1'b0;

assign layer_1_bit_47 = shift[3:2] == 2'd0 ? layer_0_bit_47 :
                        shift[3:2] == 2'd1 ? layer_0_bit_51 :
                        shift[3:2] == 2'd2 ? layer_0_bit_55 :
                        shift[3:2] == 2'd3 ? layer_0_bit_59 : 1'b0;

assign layer_1_bit_46 = shift[3:2] == 2'd0 ? layer_0_bit_46 :
                        shift[3:2] == 2'd1 ? layer_0_bit_50 :
                        shift[3:2] == 2'd2 ? layer_0_bit_54 :
                        shift[3:2] == 2'd3 ? layer_0_bit_58 : 1'b0;

assign layer_1_bit_45 = shift[3:2] == 2'd0 ? layer_0_bit_45 :
                        shift[3:2] == 2'd1 ? layer_0_bit_49 :
                        shift[3:2] == 2'd2 ? layer_0_bit_53 :
                        shift[3:2] == 2'd3 ? layer_0_bit_57 : 1'b0;

assign layer_1_bit_44 = shift[3:2] == 2'd0 ? layer_0_bit_44 :
                        shift[3:2] == 2'd1 ? layer_0_bit_48 :
                        shift[3:2] == 2'd2 ? layer_0_bit_52 :
                        shift[3:2] == 2'd3 ? layer_0_bit_56 : 1'b0;

assign layer_1_bit_43 = shift[3:2] == 2'd0 ? layer_0_bit_43 :
                        shift[3:2] == 2'd1 ? layer_0_bit_47 :
                        shift[3:2] == 2'd2 ? layer_0_bit_51 :
                        shift[3:2] == 2'd3 ? layer_0_bit_55 : 1'b0;

assign layer_1_bit_42 = shift[3:2] == 2'd0 ? layer_0_bit_42 :
                        shift[3:2] == 2'd1 ? layer_0_bit_46 :
                        shift[3:2] == 2'd2 ? layer_0_bit_50 :
                        shift[3:2] == 2'd3 ? layer_0_bit_54 : 1'b0;

assign layer_1_bit_41 = shift[3:2] == 2'd0 ? layer_0_bit_41 :
                        shift[3:2] == 2'd1 ? layer_0_bit_45 :
                        shift[3:2] == 2'd2 ? layer_0_bit_49 :
                        shift[3:2] == 2'd3 ? layer_0_bit_53 : 1'b0;

assign layer_1_bit_40 = shift[3:2] == 2'd0 ? layer_0_bit_40 :
                        shift[3:2] == 2'd1 ? layer_0_bit_44 :
                        shift[3:2] == 2'd2 ? layer_0_bit_48 :
                        shift[3:2] == 2'd3 ? layer_0_bit_52 : 1'b0;

assign layer_1_bit_39 = shift[3:2] == 2'd0 ? layer_0_bit_39 :
                        shift[3:2] == 2'd1 ? layer_0_bit_43 :
                        shift[3:2] == 2'd2 ? layer_0_bit_47 :
                        shift[3:2] == 2'd3 ? layer_0_bit_51 : 1'b0;

assign layer_1_bit_38 = shift[3:2] == 2'd0 ? layer_0_bit_38 :
                        shift[3:2] == 2'd1 ? layer_0_bit_42 :
                        shift[3:2] == 2'd2 ? layer_0_bit_46 :
                        shift[3:2] == 2'd3 ? layer_0_bit_50 : 1'b0;

assign layer_1_bit_37 = shift[3:2] == 2'd0 ? layer_0_bit_37 :
                        shift[3:2] == 2'd1 ? layer_0_bit_41 :
                        shift[3:2] == 2'd2 ? layer_0_bit_45 :
                        shift[3:2] == 2'd3 ? layer_0_bit_49 : 1'b0;

assign layer_1_bit_36 = shift[3:2] == 2'd0 ? layer_0_bit_36 :
                        shift[3:2] == 2'd1 ? layer_0_bit_40 :
                        shift[3:2] == 2'd2 ? layer_0_bit_44 :
                        shift[3:2] == 2'd3 ? layer_0_bit_48 : 1'b0;

assign layer_1_bit_35 = shift[3:2] == 2'd0 ? layer_0_bit_35 :
                        shift[3:2] == 2'd1 ? layer_0_bit_39 :
                        shift[3:2] == 2'd2 ? layer_0_bit_43 :
                        shift[3:2] == 2'd3 ? layer_0_bit_47 : 1'b0;

assign layer_1_bit_34 = shift[3:2] == 2'd0 ? layer_0_bit_34 :
                        shift[3:2] == 2'd1 ? layer_0_bit_38 :
                        shift[3:2] == 2'd2 ? layer_0_bit_42 :
                        shift[3:2] == 2'd3 ? layer_0_bit_46 : 1'b0;

assign layer_1_bit_33 = shift[3:2] == 2'd0 ? layer_0_bit_33 :
                        shift[3:2] == 2'd1 ? layer_0_bit_37 :
                        shift[3:2] == 2'd2 ? layer_0_bit_41 :
                        shift[3:2] == 2'd3 ? layer_0_bit_45 : 1'b0;

assign layer_1_bit_32 = shift[3:2] == 2'd0 ? layer_0_bit_32 :
                        shift[3:2] == 2'd1 ? layer_0_bit_36 :
                        shift[3:2] == 2'd2 ? layer_0_bit_40 :
                        shift[3:2] == 2'd3 ? layer_0_bit_44 : 1'b0;

assign layer_1_bit_31 = shift[3:2] == 2'd0 ? layer_0_bit_31 :
                        shift[3:2] == 2'd1 ? layer_0_bit_35 :
                        shift[3:2] == 2'd2 ? layer_0_bit_39 :
                        shift[3:2] == 2'd3 ? layer_0_bit_43 : 1'b0;

assign layer_1_bit_30 = shift[3:2] == 2'd0 ? layer_0_bit_30 :
                        shift[3:2] == 2'd1 ? layer_0_bit_34 :
                        shift[3:2] == 2'd2 ? layer_0_bit_38 :
                        shift[3:2] == 2'd3 ? layer_0_bit_42 : 1'b0;

assign layer_1_bit_29 = shift[3:2] == 2'd0 ? layer_0_bit_29 :
                        shift[3:2] == 2'd1 ? layer_0_bit_33 :
                        shift[3:2] == 2'd2 ? layer_0_bit_37 :
                        shift[3:2] == 2'd3 ? layer_0_bit_41 : 1'b0;

assign layer_1_bit_28 = shift[3:2] == 2'd0 ? layer_0_bit_28 :
                        shift[3:2] == 2'd1 ? layer_0_bit_32 :
                        shift[3:2] == 2'd2 ? layer_0_bit_36 :
                        shift[3:2] == 2'd3 ? layer_0_bit_40 : 1'b0;

assign layer_1_bit_27 = shift[3:2] == 2'd0 ? layer_0_bit_27 :
                        shift[3:2] == 2'd1 ? layer_0_bit_31 :
                        shift[3:2] == 2'd2 ? layer_0_bit_35 :
                        shift[3:2] == 2'd3 ? layer_0_bit_39 : 1'b0;

assign layer_1_bit_26 = shift[3:2] == 2'd0 ? layer_0_bit_26 :
                        shift[3:2] == 2'd1 ? layer_0_bit_30 :
                        shift[3:2] == 2'd2 ? layer_0_bit_34 :
                        shift[3:2] == 2'd3 ? layer_0_bit_38 : 1'b0;

assign layer_1_bit_25 = shift[3:2] == 2'd0 ? layer_0_bit_25 :
                        shift[3:2] == 2'd1 ? layer_0_bit_29 :
                        shift[3:2] == 2'd2 ? layer_0_bit_33 :
                        shift[3:2] == 2'd3 ? layer_0_bit_37 : 1'b0;

assign layer_1_bit_24 = shift[3:2] == 2'd0 ? layer_0_bit_24 :
                        shift[3:2] == 2'd1 ? layer_0_bit_28 :
                        shift[3:2] == 2'd2 ? layer_0_bit_32 :
                        shift[3:2] == 2'd3 ? layer_0_bit_36 : 1'b0;

assign layer_1_bit_23 = shift[3:2] == 2'd0 ? layer_0_bit_23 :
                        shift[3:2] == 2'd1 ? layer_0_bit_27 :
                        shift[3:2] == 2'd2 ? layer_0_bit_31 :
                        shift[3:2] == 2'd3 ? layer_0_bit_35 : 1'b0;

assign layer_1_bit_22 = shift[3:2] == 2'd0 ? layer_0_bit_22 :
                        shift[3:2] == 2'd1 ? layer_0_bit_26 :
                        shift[3:2] == 2'd2 ? layer_0_bit_30 :
                        shift[3:2] == 2'd3 ? layer_0_bit_34 : 1'b0;

assign layer_1_bit_21 = shift[3:2] == 2'd0 ? layer_0_bit_21 :
                        shift[3:2] == 2'd1 ? layer_0_bit_25 :
                        shift[3:2] == 2'd2 ? layer_0_bit_29 :
                        shift[3:2] == 2'd3 ? layer_0_bit_33 : 1'b0;

assign layer_1_bit_20 = shift[3:2] == 2'd0 ? layer_0_bit_20 :
                        shift[3:2] == 2'd1 ? layer_0_bit_24 :
                        shift[3:2] == 2'd2 ? layer_0_bit_28 :
                        shift[3:2] == 2'd3 ? layer_0_bit_32 : 1'b0;

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

assign layer_2_bit_70 = shift[5:4] == 2'd0 ? layer_1_bit_70 : 1'b0;

assign layer_2_bit_69 = shift[5:4] == 2'd0 ? layer_1_bit_69 : 1'b0;

assign layer_2_bit_68 = shift[5:4] == 2'd0 ? layer_1_bit_68 : 1'b0;

assign layer_2_bit_67 = shift[5:4] == 2'd0 ? layer_1_bit_67 : 1'b0;

assign layer_2_bit_66 = shift[5:4] == 2'd0 ? layer_1_bit_66 : 1'b0;

assign layer_2_bit_65 = shift[5:4] == 2'd0 ? layer_1_bit_65 : 1'b0;

assign layer_2_bit_64 = shift[5:4] == 2'd0 ? layer_1_bit_64 : 1'b0;

assign layer_2_bit_63 = shift[5:4] == 2'd0 ? layer_1_bit_63 : 1'b0;

assign layer_2_bit_62 = shift[5:4] == 2'd0 ? layer_1_bit_62 : 1'b0;

assign layer_2_bit_61 = shift[5:4] == 2'd0 ? layer_1_bit_61 : 1'b0;

assign layer_2_bit_60 = shift[5:4] == 2'd0 ? layer_1_bit_60 : 1'b0;

assign layer_2_bit_59 = shift[5:4] == 2'd0 ? layer_1_bit_59 : 1'b0;

assign layer_2_bit_58 = shift[5:4] == 2'd0 ? layer_1_bit_58 : 1'b0;

assign layer_2_bit_57 = shift[5:4] == 2'd0 ? layer_1_bit_57 : 1'b0;

assign layer_2_bit_56 = shift[5:4] == 2'd0 ? layer_1_bit_56 : 1'b0;

assign layer_2_bit_55 = shift[5:4] == 2'd0 ? layer_1_bit_55 : 1'b0;

assign layer_2_bit_54 = shift[5:4] == 2'd0 ? layer_1_bit_54 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_70 : 1'b0;

assign layer_2_bit_53 = shift[5:4] == 2'd0 ? layer_1_bit_53 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_69 : 1'b0;

assign layer_2_bit_52 = shift[5:4] == 2'd0 ? layer_1_bit_52 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_68 : 1'b0;

assign layer_2_bit_51 = shift[5:4] == 2'd0 ? layer_1_bit_51 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_67 : 1'b0;

assign layer_2_bit_50 = shift[5:4] == 2'd0 ? layer_1_bit_50 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_66 : 1'b0;

assign layer_2_bit_49 = shift[5:4] == 2'd0 ? layer_1_bit_49 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_65 : 1'b0;

assign layer_2_bit_48 = shift[5:4] == 2'd0 ? layer_1_bit_48 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_64 : 1'b0;

assign layer_2_bit_47 = shift[5:4] == 2'd0 ? layer_1_bit_47 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_63 : 1'b0;

assign layer_2_bit_46 = shift[5:4] == 2'd0 ? layer_1_bit_46 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_62 : 1'b0;

assign layer_2_bit_45 = shift[5:4] == 2'd0 ? layer_1_bit_45 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_61 : 1'b0;

assign layer_2_bit_44 = shift[5:4] == 2'd0 ? layer_1_bit_44 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_60 : 1'b0;

assign layer_2_bit_43 = shift[5:4] == 2'd0 ? layer_1_bit_43 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_59 : 1'b0;

assign layer_2_bit_42 = shift[5:4] == 2'd0 ? layer_1_bit_42 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_58 : 1'b0;

assign layer_2_bit_41 = shift[5:4] == 2'd0 ? layer_1_bit_41 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_57 : 1'b0;

assign layer_2_bit_40 = shift[5:4] == 2'd0 ? layer_1_bit_40 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_56 : 1'b0;

assign layer_2_bit_39 = shift[5:4] == 2'd0 ? layer_1_bit_39 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_55 : 1'b0;

assign layer_2_bit_38 = shift[5:4] == 2'd0 ? layer_1_bit_38 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_54 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_70 : 1'b0;

assign layer_2_bit_37 = shift[5:4] == 2'd0 ? layer_1_bit_37 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_53 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_69 : 1'b0;

assign layer_2_bit_36 = shift[5:4] == 2'd0 ? layer_1_bit_36 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_52 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_68 : 1'b0;

assign layer_2_bit_35 = shift[5:4] == 2'd0 ? layer_1_bit_35 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_51 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_67 : 1'b0;

assign layer_2_bit_34 = shift[5:4] == 2'd0 ? layer_1_bit_34 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_50 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_66 : 1'b0;

assign layer_2_bit_33 = shift[5:4] == 2'd0 ? layer_1_bit_33 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_49 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_65 : 1'b0;

assign layer_2_bit_32 = shift[5:4] == 2'd0 ? layer_1_bit_32 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_48 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_64 : 1'b0;

assign layer_2_bit_31 = shift[5:4] == 2'd0 ? layer_1_bit_31 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_47 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_63 : 1'b0;

assign layer_2_bit_30 = shift[5:4] == 2'd0 ? layer_1_bit_30 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_46 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_62 : 1'b0;

assign layer_2_bit_29 = shift[5:4] == 2'd0 ? layer_1_bit_29 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_45 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_61 : 1'b0;

assign layer_2_bit_28 = shift[5:4] == 2'd0 ? layer_1_bit_28 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_44 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_60 : 1'b0;

assign layer_2_bit_27 = shift[5:4] == 2'd0 ? layer_1_bit_27 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_43 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_59 : 1'b0;

assign layer_2_bit_26 = shift[5:4] == 2'd0 ? layer_1_bit_26 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_42 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_58 : 1'b0;

assign layer_2_bit_25 = shift[5:4] == 2'd0 ? layer_1_bit_25 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_41 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_57 : 1'b0;

assign layer_2_bit_24 = shift[5:4] == 2'd0 ? layer_1_bit_24 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_40 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_56 : 1'b0;

assign layer_2_bit_23 = shift[5:4] == 2'd0 ? layer_1_bit_23 : 
                        shift[5:4] == 2'd1 ? layer_1_bit_39 : 
                        shift[5:4] == 2'd2 ? layer_1_bit_55 : 1'b0;

assign layer_2_bit_22 = shift[5:4] == 2'd0 ? layer_1_bit_22 :
                        shift[5:4] == 2'd1 ? layer_1_bit_38 :
                        shift[5:4] == 2'd2 ? layer_1_bit_54 :
                        shift[5:4] == 2'd3 ? layer_1_bit_70 : 1'b0;

assign layer_2_bit_21 = shift[5:4] == 2'd0 ? layer_1_bit_21 :
                        shift[5:4] == 2'd1 ? layer_1_bit_37 :
                        shift[5:4] == 2'd2 ? layer_1_bit_53 :
                        shift[5:4] == 2'd3 ? layer_1_bit_69 : 1'b0;

assign layer_2_bit_20 = shift[5:4] == 2'd0 ? layer_1_bit_20 :
                        shift[5:4] == 2'd1 ? layer_1_bit_36 :
                        shift[5:4] == 2'd2 ? layer_1_bit_52 :
                        shift[5:4] == 2'd3 ? layer_1_bit_68 : 1'b0;

assign layer_2_bit_19 = shift[5:4] == 2'd0 ? layer_1_bit_19 :
                        shift[5:4] == 2'd1 ? layer_1_bit_35 :
                        shift[5:4] == 2'd2 ? layer_1_bit_51 :
                        shift[5:4] == 2'd3 ? layer_1_bit_67 : 1'b0;

assign layer_2_bit_18 = shift[5:4] == 2'd0 ? layer_1_bit_18 :
                        shift[5:4] == 2'd1 ? layer_1_bit_34 :
                        shift[5:4] == 2'd2 ? layer_1_bit_50 :
                        shift[5:4] == 2'd3 ? layer_1_bit_66 : 1'b0;

assign layer_2_bit_17 = shift[5:4] == 2'd0 ? layer_1_bit_17 :
                        shift[5:4] == 2'd1 ? layer_1_bit_33 :
                        shift[5:4] == 2'd2 ? layer_1_bit_49 :
                        shift[5:4] == 2'd3 ? layer_1_bit_65 : 1'b0;

assign layer_2_bit_16 = shift[5:4] == 2'd0 ? layer_1_bit_16 :
                        shift[5:4] == 2'd1 ? layer_1_bit_32 :
                        shift[5:4] == 2'd2 ? layer_1_bit_48 :
                        shift[5:4] == 2'd3 ? layer_1_bit_64 : 1'b0;

assign layer_2_bit_15 = shift[5:4] == 2'd0 ? layer_1_bit_15 :
                        shift[5:4] == 2'd1 ? layer_1_bit_31 :
                        shift[5:4] == 2'd2 ? layer_1_bit_47 :
                        shift[5:4] == 2'd3 ? layer_1_bit_63 : 1'b0;

assign layer_2_bit_14 = shift[5:4] == 2'd0 ? layer_1_bit_14 :
                        shift[5:4] == 2'd1 ? layer_1_bit_30 :
                        shift[5:4] == 2'd2 ? layer_1_bit_46 :
                        shift[5:4] == 2'd3 ? layer_1_bit_62 : 1'b0;

assign layer_2_bit_13 = shift[5:4] == 2'd0 ? layer_1_bit_13 :
                        shift[5:4] == 2'd1 ? layer_1_bit_29 :
                        shift[5:4] == 2'd2 ? layer_1_bit_45 :
                        shift[5:4] == 2'd3 ? layer_1_bit_61 : 1'b0;

assign layer_2_bit_12 = shift[5:4] == 2'd0 ? layer_1_bit_12 :
                        shift[5:4] == 2'd1 ? layer_1_bit_28 :
                        shift[5:4] == 2'd2 ? layer_1_bit_44 :
                        shift[5:4] == 2'd3 ? layer_1_bit_60 : 1'b0;

assign layer_2_bit_11 = shift[5:4] == 2'd0 ? layer_1_bit_11 :
                        shift[5:4] == 2'd1 ? layer_1_bit_27 :
                        shift[5:4] == 2'd2 ? layer_1_bit_43 :
                        shift[5:4] == 2'd3 ? layer_1_bit_59 : 1'b0;

assign layer_2_bit_10 = shift[5:4] == 2'd0 ? layer_1_bit_10 :
                        shift[5:4] == 2'd1 ? layer_1_bit_26 :
                        shift[5:4] == 2'd2 ? layer_1_bit_42 :
                        shift[5:4] == 2'd3 ? layer_1_bit_58 : 1'b0;

assign layer_2_bit_9 = shift[5:4] == 2'd0 ? layer_1_bit_9 :
                       shift[5:4] == 2'd1 ? layer_1_bit_25 :
                       shift[5:4] == 2'd2 ? layer_1_bit_41 :
                       shift[5:4] == 2'd3 ? layer_1_bit_57 : 1'b0;

assign layer_2_bit_8 = shift[5:4] == 2'd0 ? layer_1_bit_8 :
                       shift[5:4] == 2'd1 ? layer_1_bit_24 :
                       shift[5:4] == 2'd2 ? layer_1_bit_40 :
                       shift[5:4] == 2'd3 ? layer_1_bit_56 : 1'b0;

assign layer_2_bit_7 = shift[5:4] == 2'd0 ? layer_1_bit_7 :
                       shift[5:4] == 2'd1 ? layer_1_bit_23 :
                       shift[5:4] == 2'd2 ? layer_1_bit_39 :
                       shift[5:4] == 2'd3 ? layer_1_bit_55 : 1'b0;

assign layer_2_bit_6 = shift[5:4] == 2'd0 ? layer_1_bit_6 :
                       shift[5:4] == 2'd1 ? layer_1_bit_22 :
                       shift[5:4] == 2'd2 ? layer_1_bit_38 :
                       shift[5:4] == 2'd3 ? layer_1_bit_54 : 1'b0;

assign layer_2_bit_5 = shift[5:4] == 2'd0 ? layer_1_bit_5 :
                       shift[5:4] == 2'd1 ? layer_1_bit_21 :
                       shift[5:4] == 2'd2 ? layer_1_bit_37 :
                       shift[5:4] == 2'd3 ? layer_1_bit_53 : 1'b0;

assign layer_2_bit_4 = shift[5:4] == 2'd0 ? layer_1_bit_4 :
                       shift[5:4] == 2'd1 ? layer_1_bit_20 :
                       shift[5:4] == 2'd2 ? layer_1_bit_36 :
                       shift[5:4] == 2'd3 ? layer_1_bit_52 : 1'b0;

assign layer_2_bit_3 = shift[5:4] == 2'd0 ? layer_1_bit_3 :
                       shift[5:4] == 2'd1 ? layer_1_bit_19 :
                       shift[5:4] == 2'd2 ? layer_1_bit_35 :
                       shift[5:4] == 2'd3 ? layer_1_bit_51 : 1'b0;

assign layer_2_bit_2 = shift[5:4] == 2'd0 ? layer_1_bit_2 :
                       shift[5:4] == 2'd1 ? layer_1_bit_18 :
                       shift[5:4] == 2'd2 ? layer_1_bit_34 :
                       shift[5:4] == 2'd3 ? layer_1_bit_50 : 1'b0;

assign layer_2_bit_1 = shift[5:4] == 2'd0 ? layer_1_bit_1 :
                       shift[5:4] == 2'd1 ? layer_1_bit_17 :
                       shift[5:4] == 2'd2 ? layer_1_bit_33 :
                       shift[5:4] == 2'd3 ? layer_1_bit_49 : 1'b0;

assign layer_2_bit_0 = shift[5:4] == 2'd0 ? layer_1_bit_0 :
                       shift[5:4] == 2'd1 ? layer_1_bit_16 :
                       shift[5:4] == 2'd2 ? layer_1_bit_32 :
                       shift[5:4] == 2'd3 ? layer_1_bit_48 : 1'b0;

assign layer_3_bit_70 = !shift[6] ? layer_2_bit_70 : 1'b0;

assign layer_3_bit_69 = !shift[6] ? layer_2_bit_69 : 1'b0;

assign layer_3_bit_68 = !shift[6] ? layer_2_bit_68 : 1'b0;

assign layer_3_bit_67 = !shift[6] ? layer_2_bit_67 : 1'b0;

assign layer_3_bit_66 = !shift[6] ? layer_2_bit_66 : 1'b0;

assign layer_3_bit_65 = !shift[6] ? layer_2_bit_65 : 1'b0;

assign layer_3_bit_64 = !shift[6] ? layer_2_bit_64 : 1'b0;

assign layer_3_bit_63 = !shift[6] ? layer_2_bit_63 : 1'b0;

assign layer_3_bit_62 = !shift[6] ? layer_2_bit_62 : 1'b0;

assign layer_3_bit_61 = !shift[6] ? layer_2_bit_61 : 1'b0;

assign layer_3_bit_60 = !shift[6] ? layer_2_bit_60 : 1'b0;

assign layer_3_bit_59 = !shift[6] ? layer_2_bit_59 : 1'b0;

assign layer_3_bit_58 = !shift[6] ? layer_2_bit_58 : 1'b0;

assign layer_3_bit_57 = !shift[6] ? layer_2_bit_57 : 1'b0;

assign layer_3_bit_56 = !shift[6] ? layer_2_bit_56 : 1'b0;

assign layer_3_bit_55 = !shift[6] ? layer_2_bit_55 : 1'b0;

assign layer_3_bit_54 = !shift[6] ? layer_2_bit_54 : 1'b0;

assign layer_3_bit_53 = !shift[6] ? layer_2_bit_53 : 1'b0;

assign layer_3_bit_52 = !shift[6] ? layer_2_bit_52 : 1'b0;

assign layer_3_bit_51 = !shift[6] ? layer_2_bit_51 : 1'b0;

assign layer_3_bit_50 = !shift[6] ? layer_2_bit_50 : 1'b0;

assign layer_3_bit_49 = !shift[6] ? layer_2_bit_49 : 1'b0;

assign layer_3_bit_48 = !shift[6] ? layer_2_bit_48 : 1'b0;

assign layer_3_bit_47 = !shift[6] ? layer_2_bit_47 : 1'b0;

assign layer_3_bit_46 = !shift[6] ? layer_2_bit_46 : 1'b0;

assign layer_3_bit_45 = !shift[6] ? layer_2_bit_45 : 1'b0;

assign layer_3_bit_44 = !shift[6] ? layer_2_bit_44 : 1'b0;

assign layer_3_bit_43 = !shift[6] ? layer_2_bit_43 : 1'b0;

assign layer_3_bit_42 = !shift[6] ? layer_2_bit_42 : 1'b0;

assign layer_3_bit_41 = !shift[6] ? layer_2_bit_41 : 1'b0;

assign layer_3_bit_40 = !shift[6] ? layer_2_bit_40 : 1'b0;

assign layer_3_bit_39 = !shift[6] ? layer_2_bit_39 : 1'b0;

assign layer_3_bit_38 = !shift[6] ? layer_2_bit_38 : 1'b0;

assign layer_3_bit_37 = !shift[6] ? layer_2_bit_37 : 1'b0;

assign layer_3_bit_36 = !shift[6] ? layer_2_bit_36 : 1'b0;

assign layer_3_bit_35 = !shift[6] ? layer_2_bit_35 : 1'b0;

assign layer_3_bit_34 = !shift[6] ? layer_2_bit_34 : 1'b0;

assign layer_3_bit_33 = !shift[6] ? layer_2_bit_33 : 1'b0;

assign layer_3_bit_32 = !shift[6] ? layer_2_bit_32 : 1'b0;

assign layer_3_bit_31 = !shift[6] ? layer_2_bit_31 : 1'b0;

assign layer_3_bit_30 = !shift[6] ? layer_2_bit_30 : 1'b0;

assign layer_3_bit_29 = !shift[6] ? layer_2_bit_29 : 1'b0;

assign layer_3_bit_28 = !shift[6] ? layer_2_bit_28 : 1'b0;

assign layer_3_bit_27 = !shift[6] ? layer_2_bit_27 : 1'b0;

assign layer_3_bit_26 = !shift[6] ? layer_2_bit_26 : 1'b0;

assign layer_3_bit_25 = !shift[6] ? layer_2_bit_25 : 1'b0;

assign layer_3_bit_24 = !shift[6] ? layer_2_bit_24 : 1'b0;

assign layer_3_bit_23 = !shift[6] ? layer_2_bit_23 : 1'b0;

assign layer_3_bit_22 = !shift[6] ? layer_2_bit_22 : 1'b0;

assign layer_3_bit_21 = !shift[6] ? layer_2_bit_21 : 1'b0;

assign layer_3_bit_20 = !shift[6] ? layer_2_bit_20 : 1'b0;

assign layer_3_bit_19 = !shift[6] ? layer_2_bit_19 : 1'b0;

assign layer_3_bit_18 = !shift[6] ? layer_2_bit_18 : 1'b0;

assign layer_3_bit_17 = !shift[6] ? layer_2_bit_17 : 1'b0;

assign layer_3_bit_16 = !shift[6] ? layer_2_bit_16 : 1'b0;

assign layer_3_bit_15 = !shift[6] ? layer_2_bit_15 : 1'b0;

assign layer_3_bit_14 = !shift[6] ? layer_2_bit_14 : 1'b0;

assign layer_3_bit_13 = !shift[6] ? layer_2_bit_13 : 1'b0;

assign layer_3_bit_12 = !shift[6] ? layer_2_bit_12 : 1'b0;

assign layer_3_bit_11 = !shift[6] ? layer_2_bit_11 : 1'b0;

assign layer_3_bit_10 = !shift[6] ? layer_2_bit_10 : 1'b0;

assign layer_3_bit_9 = !shift[6] ? layer_2_bit_9 : 1'b0;

assign layer_3_bit_8 = !shift[6] ? layer_2_bit_8 : 1'b0;

assign layer_3_bit_7 = !shift[6] ? layer_2_bit_7 : 1'b0;

assign layer_3_bit_6 = !shift[6] ? layer_2_bit_6 : layer_2_bit_70;

assign layer_3_bit_5 = !shift[6] ? layer_2_bit_5 : layer_2_bit_69;

assign layer_3_bit_4 = !shift[6] ? layer_2_bit_4 : layer_2_bit_68;

assign layer_3_bit_3 = !shift[6] ? layer_2_bit_3 : layer_2_bit_67;

assign layer_3_bit_2 = !shift[6] ? layer_2_bit_2 : layer_2_bit_66;

assign layer_3_bit_1 = !shift[6] ? layer_2_bit_1 : layer_2_bit_65;

assign layer_3_bit_0 = !shift[6] ? layer_2_bit_0 : layer_2_bit_64;

assign o = shift > 'd70 ? 'd0 : {layer_3_bit_70, layer_3_bit_69, layer_3_bit_68, layer_3_bit_67, layer_3_bit_66, layer_3_bit_65, layer_3_bit_64, layer_3_bit_63, layer_3_bit_62, layer_3_bit_61, layer_3_bit_60, layer_3_bit_59, layer_3_bit_58, layer_3_bit_57, layer_3_bit_56, layer_3_bit_55, layer_3_bit_54, layer_3_bit_53, layer_3_bit_52, layer_3_bit_51, layer_3_bit_50, layer_3_bit_49, layer_3_bit_48, layer_3_bit_47, layer_3_bit_46, layer_3_bit_45, layer_3_bit_44, layer_3_bit_43, layer_3_bit_42, layer_3_bit_41, layer_3_bit_40, layer_3_bit_39, layer_3_bit_38, layer_3_bit_37, layer_3_bit_36, layer_3_bit_35, layer_3_bit_34, layer_3_bit_33, layer_3_bit_32, layer_3_bit_31, layer_3_bit_30, layer_3_bit_29, layer_3_bit_28, layer_3_bit_27, layer_3_bit_26, layer_3_bit_25, layer_3_bit_24, layer_3_bit_23, layer_3_bit_22, layer_3_bit_21, layer_3_bit_20, layer_3_bit_19, layer_3_bit_18, layer_3_bit_17, layer_3_bit_16, layer_3_bit_15, layer_3_bit_14, layer_3_bit_13, layer_3_bit_12, layer_3_bit_11, layer_3_bit_10, layer_3_bit_9, layer_3_bit_8, layer_3_bit_7, layer_3_bit_6, layer_3_bit_5, layer_3_bit_4, layer_3_bit_3, layer_3_bit_2, layer_3_bit_1, layer_3_bit_0};

endmodule
