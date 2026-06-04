assign master_0_rready = read_grant_0[0] | read_grant_1[0] | read_grant_2[0] | read_grant_3[0] | read_grant_4[0] | read_grant_5[0] | read_grant_6[0] | read_grant_7[0] | read_grant_8[0] | read_grant_9[0] | read_grant_10[0] | read_grant_11[0] | read_grant_12[0] | read_grant_13[0] | read_grant_14[0] | read_grant_15[0] | read_grant_16[0] | read_grant_17[0] | read_grant_18[0] | read_grant_19[0] | read_grant_20[0] | read_grant_21[0] | read_grant_22[0] | read_grant_23[0] | read_grant_24[0] | read_grant_25[0] | read_grant_26[0] | read_grant_27[0] | read_grant_28[0] | read_grant_29[0] | read_grant_30[0] | read_grant_31[0] | read_grant_32[0] | read_grant_33[0] | read_grant_34[0] | read_grant_35[0] | read_grant_36[0] | read_grant_37[0] | read_grant_38[0] | read_grant_39[0] | read_grant_40[0] | read_grant_41[0] | read_grant_42[0] | read_grant_43[0] | read_grant_44[0] | read_grant_45[0] | read_grant_46[0] | read_grant_47[0] | read_grant_48[0] | read_grant_49[0] | read_grant_50[0] | read_grant_51[0] | read_grant_52[0] | read_grant_53[0] | read_grant_54[0] | read_grant_55[0] | read_grant_56[0] | read_grant_57[0] | read_grant_58[0] | read_grant_59[0] | read_grant_60[0] | read_grant_61[0] | read_grant_62[0] | read_grant_63[0];
assign master_1_rready = read_grant_0[3] | read_grant_1[5] | read_grant_2[5] | read_grant_3[5] | read_grant_4[3] | read_grant_5[5] | read_grant_6[5] | read_grant_7[5] | read_grant_8[3] | read_grant_9[5] | read_grant_10[5] | read_grant_11[5] | read_grant_12[3] | read_grant_13[5] | read_grant_14[5] | read_grant_15[5] | read_grant_16[3] | read_grant_17[5] | read_grant_18[5] | read_grant_19[5] | read_grant_20[3] | read_grant_21[5] | read_grant_22[5] | read_grant_23[5] | read_grant_24[3] | read_grant_25[5] | read_grant_26[5] | read_grant_27[5] | read_grant_28[3] | read_grant_29[5] | read_grant_30[5] | read_grant_31[5] | read_grant_32[3] | read_grant_33[5] | read_grant_34[5] | read_grant_35[5] | read_grant_36[3] | read_grant_37[5] | read_grant_38[5] | read_grant_39[5] | read_grant_40[3] | read_grant_41[5] | read_grant_42[5] | read_grant_43[5] | read_grant_44[3] | read_grant_45[5] | read_grant_46[5] | read_grant_47[5] | read_grant_48[3] | read_grant_49[5] | read_grant_50[5] | read_grant_51[5] | read_grant_52[3] | read_grant_53[5] | read_grant_54[5] | read_grant_55[5] | read_grant_56[3] | read_grant_57[5] | read_grant_58[5] | read_grant_59[5] | read_grant_60[3] | read_grant_61[5] | read_grant_62[5] | read_grant_63[5];
assign slave_rready = read_grant_0[4] | read_grant_1[6] | read_grant_2[6] | read_grant_3[6] | read_grant_4[4] | read_grant_5[6] | read_grant_6[6] | read_grant_7[6] | read_grant_8[4] | read_grant_9[6] | read_grant_10[6] | read_grant_11[6] | read_grant_12[4] | read_grant_13[6] | read_grant_14[6] | read_grant_15[6] | read_grant_16[4] | read_grant_17[6] | read_grant_18[6] | read_grant_19[6] | read_grant_20[4] | read_grant_21[6] | read_grant_22[6] | read_grant_23[6] | read_grant_24[4] | read_grant_25[6] | read_grant_26[6] | read_grant_27[6] | read_grant_28[4] | read_grant_29[6] | read_grant_30[6] | read_grant_31[6] | read_grant_32[4] | read_grant_33[6] | read_grant_34[6] | read_grant_35[6] | read_grant_36[4] | read_grant_37[6] | read_grant_38[6] | read_grant_39[6] | read_grant_40[4] | read_grant_41[6] | read_grant_42[6] | read_grant_43[6] | read_grant_44[4] | read_grant_45[6] | read_grant_46[6] | read_grant_47[6] | read_grant_48[4] | read_grant_49[6] | read_grant_50[6] | read_grant_51[6] | read_grant_52[4] | read_grant_53[6] | read_grant_54[6] | read_grant_55[6] | read_grant_56[4] | read_grant_57[6] | read_grant_58[6] | read_grant_59[6] | read_grant_60[4] | read_grant_61[6] | read_grant_62[6] | read_grant_63[6];
assign vcu_0_rready = read_grant_0[2] | read_grant_1[2] | read_grant_2[2] | read_grant_3[2] | read_grant_4[2] | read_grant_5[2] | read_grant_6[2] | read_grant_7[2] | read_grant_8[2] | read_grant_9[2] | read_grant_10[2] | read_grant_11[2] | read_grant_12[2] | read_grant_13[2] | read_grant_14[2] | read_grant_15[2];
assign vcu_1_rready = read_grant_4[4] | read_grant_5[4] | read_grant_6[4] | read_grant_7[4];
assign vcu_2_rready = read_grant_8[4] | read_grant_9[4] | read_grant_10[4] | read_grant_11[4];
assign vcu_3_rready = read_grant_12[4] | read_grant_13[4] | read_grant_14[4] | read_grant_15[4];
assign vcu_4_rready = read_grant_16[2] | read_grant_17[2] | read_grant_18[2] | read_grant_19[2] | read_grant_20[2] | read_grant_21[2] | read_grant_22[2] | read_grant_23[2] | read_grant_24[2] | read_grant_25[2] | read_grant_26[2] | read_grant_27[2] | read_grant_28[2] | read_grant_29[2] | read_grant_30[2] | read_grant_31[2];
assign vcu_5_rready = read_grant_20[4] | read_grant_21[4] | read_grant_22[4] | read_grant_23[4];
assign vcu_6_rready = read_grant_24[4] | read_grant_25[4] | read_grant_26[4] | read_grant_27[4];
assign vcu_7_rready = read_grant_28[4] | read_grant_29[4] | read_grant_30[4] | read_grant_31[4];
assign vcu_8_rready = read_grant_32[2] | read_grant_33[2] | read_grant_34[2] | read_grant_35[2] | read_grant_36[2] | read_grant_37[2] | read_grant_38[2] | read_grant_39[2] | read_grant_40[2] | read_grant_41[2] | read_grant_42[2] | read_grant_43[2] | read_grant_44[2] | read_grant_45[2] | read_grant_46[2] | read_grant_47[2];
assign vcu_9_rready = read_grant_36[4] | read_grant_37[4] | read_grant_38[4] | read_grant_39[4];
assign vcu_a_rready = read_grant_40[4] | read_grant_41[4] | read_grant_42[4] | read_grant_43[4];
assign vcu_b_rready = read_grant_44[4] | read_grant_45[4] | read_grant_46[4] | read_grant_47[4];
assign vcu_c_rready = read_grant_48[2] | read_grant_49[2] | read_grant_50[2] | read_grant_51[2] | read_grant_52[2] | read_grant_53[2] | read_grant_54[2] | read_grant_55[2] | read_grant_56[2] | read_grant_57[2] | read_grant_58[2] | read_grant_59[2] | read_grant_60[2] | read_grant_61[2] | read_grant_62[2] | read_grant_63[2];
assign vcu_d_rready = read_grant_52[4] | read_grant_53[4] | read_grant_54[4] | read_grant_55[4];
assign vcu_e_rready = read_grant_56[4] | read_grant_57[4] | read_grant_58[4] | read_grant_59[4];
assign vcu_f_rready = read_grant_60[4] | read_grant_61[4] | read_grant_62[4] | read_grant_63[4];
assign pea_0_rready = read_grant_0[1] | read_grant_1[1] | read_grant_2[1] | read_grant_3[1] | read_grant_4[1] | read_grant_5[1] | read_grant_6[1] | read_grant_7[1] | read_grant_8[1] | read_grant_9[1] | read_grant_10[1] | read_grant_11[1] | read_grant_12[1] | read_grant_13[1] | read_grant_14[1] | read_grant_15[1];
assign pea_1_rready = read_grant_4[3] | read_grant_5[3] | read_grant_6[3] | read_grant_7[3];
assign pea_2_rready = read_grant_8[3] | read_grant_9[3] | read_grant_10[3] | read_grant_11[3];
assign pea_3_rready = read_grant_12[3] | read_grant_13[3] | read_grant_14[3] | read_grant_15[3];
assign pea_4_rready = read_grant_16[1] | read_grant_17[1] | read_grant_18[1] | read_grant_19[1] | read_grant_20[1] | read_grant_21[1] | read_grant_22[1] | read_grant_23[1] | read_grant_24[1] | read_grant_25[1] | read_grant_26[1] | read_grant_27[1] | read_grant_28[1] | read_grant_29[1] | read_grant_30[1] | read_grant_31[1];
assign pea_5_rready = read_grant_20[3] | read_grant_21[3] | read_grant_22[3] | read_grant_23[3];
assign pea_6_rready = read_grant_24[3] | read_grant_25[3] | read_grant_26[3] | read_grant_27[3];
assign pea_7_rready = read_grant_28[3] | read_grant_29[3] | read_grant_30[3] | read_grant_31[3];
assign pea_8_rready = read_grant_32[1] | read_grant_33[1] | read_grant_34[1] | read_grant_35[1] | read_grant_36[1] | read_grant_37[1] | read_grant_38[1] | read_grant_39[1] | read_grant_40[1] | read_grant_41[1] | read_grant_42[1] | read_grant_43[1] | read_grant_44[1] | read_grant_45[1] | read_grant_46[1] | read_grant_47[1];
assign pea_9_rready = read_grant_36[3] | read_grant_37[3] | read_grant_38[3] | read_grant_39[3];
assign pea_a_rready = read_grant_40[3] | read_grant_41[3] | read_grant_42[3] | read_grant_43[3];
assign pea_b_rready = read_grant_44[3] | read_grant_45[3] | read_grant_46[3] | read_grant_47[3];
assign pea_c_rready = read_grant_48[1] | read_grant_49[1] | read_grant_50[1] | read_grant_51[1] | read_grant_52[1] | read_grant_53[1] | read_grant_54[1] | read_grant_55[1] | read_grant_56[1] | read_grant_57[1] | read_grant_58[1] | read_grant_59[1] | read_grant_60[1] | read_grant_61[1] | read_grant_62[1] | read_grant_63[1];
assign pea_d_rready = read_grant_52[3] | read_grant_53[3] | read_grant_54[3] | read_grant_55[3];
assign pea_e_rready = read_grant_56[3] | read_grant_57[3] | read_grant_58[3] | read_grant_59[3];
assign pea_f_rready = read_grant_60[3] | read_grant_61[3] | read_grant_62[3] | read_grant_63[3];
assign master_0_rdata = read_grant_0_reg[0] ? rdata[0] :
                        read_grant_1_reg[0] ? rdata[1] :
                        read_grant_2_reg[0] ? rdata[2] :
                        read_grant_3_reg[0] ? rdata[3] :
                        read_grant_4_reg[0] ? rdata[4] :
                        read_grant_5_reg[0] ? rdata[5] :
                        read_grant_6_reg[0] ? rdata[6] :
                        read_grant_7_reg[0] ? rdata[7] :
                        read_grant_8_reg[0] ? rdata[8] :
                        read_grant_9_reg[0] ? rdata[9] :
                        read_grant_10_reg[0] ? rdata[10] :
                        read_grant_11_reg[0] ? rdata[11] :
                        read_grant_12_reg[0] ? rdata[12] :
                        read_grant_13_reg[0] ? rdata[13] :
                        read_grant_14_reg[0] ? rdata[14] :
                        read_grant_15_reg[0] ? rdata[15] :
                        read_grant_16_reg[0] ? rdata[16] :
                        read_grant_17_reg[0] ? rdata[17] :
                        read_grant_18_reg[0] ? rdata[18] :
                        read_grant_19_reg[0] ? rdata[19] :
                        read_grant_20_reg[0] ? rdata[20] :
                        read_grant_21_reg[0] ? rdata[21] :
                        read_grant_22_reg[0] ? rdata[22] :
                        read_grant_23_reg[0] ? rdata[23] :
                        read_grant_24_reg[0] ? rdata[24] :
                        read_grant_25_reg[0] ? rdata[25] :
                        read_grant_26_reg[0] ? rdata[26] :
                        read_grant_27_reg[0] ? rdata[27] :
                        read_grant_28_reg[0] ? rdata[28] :
                        read_grant_29_reg[0] ? rdata[29] :
                        read_grant_30_reg[0] ? rdata[30] :
                        read_grant_31_reg[0] ? rdata[31] :
                        read_grant_32_reg[0] ? rdata[32] :
                        read_grant_33_reg[0] ? rdata[33] :
                        read_grant_34_reg[0] ? rdata[34] :
                        read_grant_35_reg[0] ? rdata[35] :
                        read_grant_36_reg[0] ? rdata[36] :
                        read_grant_37_reg[0] ? rdata[37] :
                        read_grant_38_reg[0] ? rdata[38] :
                        read_grant_39_reg[0] ? rdata[39] :
                        read_grant_40_reg[0] ? rdata[40] :
                        read_grant_41_reg[0] ? rdata[41] :
                        read_grant_42_reg[0] ? rdata[42] :
                        read_grant_43_reg[0] ? rdata[43] :
                        read_grant_44_reg[0] ? rdata[44] :
                        read_grant_45_reg[0] ? rdata[45] :
                        read_grant_46_reg[0] ? rdata[46] :
                        read_grant_47_reg[0] ? rdata[47] :
                        read_grant_48_reg[0] ? rdata[48] :
                        read_grant_49_reg[0] ? rdata[49] :
                        read_grant_50_reg[0] ? rdata[50] :
                        read_grant_51_reg[0] ? rdata[51] :
                        read_grant_52_reg[0] ? rdata[52] :
                        read_grant_53_reg[0] ? rdata[53] :
                        read_grant_54_reg[0] ? rdata[54] :
                        read_grant_55_reg[0] ? rdata[55] :
                        read_grant_56_reg[0] ? rdata[56] :
                        read_grant_57_reg[0] ? rdata[57] :
                        read_grant_58_reg[0] ? rdata[58] :
                        read_grant_59_reg[0] ? rdata[59] :
                        read_grant_60_reg[0] ? rdata[60] :
                        read_grant_61_reg[0] ? rdata[61] :
                        read_grant_62_reg[0] ? rdata[62] :
                        read_grant_63_reg[0] ? rdata[63] : 0;

assign master_1_rdata = read_grant_0_reg[3] ? rdata[0] :
                        read_grant_1_reg[5] ? rdata[1] :
                        read_grant_2_reg[5] ? rdata[2] :
                        read_grant_3_reg[5] ? rdata[3] :
                        read_grant_4_reg[3] ? rdata[4] :
                        read_grant_5_reg[5] ? rdata[5] :
                        read_grant_6_reg[5] ? rdata[6] :
                        read_grant_7_reg[5] ? rdata[7] :
                        read_grant_8_reg[3] ? rdata[8] :
                        read_grant_9_reg[5] ? rdata[9] :
                        read_grant_10_reg[5] ? rdata[10] :
                        read_grant_11_reg[5] ? rdata[11] :
                        read_grant_12_reg[3] ? rdata[12] :
                        read_grant_13_reg[5] ? rdata[13] :
                        read_grant_14_reg[5] ? rdata[14] :
                        read_grant_15_reg[5] ? rdata[15] :
                        read_grant_16_reg[3] ? rdata[16] :
                        read_grant_17_reg[5] ? rdata[17] :
                        read_grant_18_reg[5] ? rdata[18] :
                        read_grant_19_reg[5] ? rdata[19] :
                        read_grant_20_reg[3] ? rdata[20] :
                        read_grant_21_reg[5] ? rdata[21] :
                        read_grant_22_reg[5] ? rdata[22] :
                        read_grant_23_reg[5] ? rdata[23] :
                        read_grant_24_reg[3] ? rdata[24] :
                        read_grant_25_reg[5] ? rdata[25] :
                        read_grant_26_reg[5] ? rdata[26] :
                        read_grant_27_reg[5] ? rdata[27] :
                        read_grant_28_reg[3] ? rdata[28] :
                        read_grant_29_reg[5] ? rdata[29] :
                        read_grant_30_reg[5] ? rdata[30] :
                        read_grant_31_reg[5] ? rdata[31] :
                        read_grant_32_reg[3] ? rdata[32] :
                        read_grant_33_reg[5] ? rdata[33] :
                        read_grant_34_reg[5] ? rdata[34] :
                        read_grant_35_reg[5] ? rdata[35] :
                        read_grant_36_reg[3] ? rdata[36] :
                        read_grant_37_reg[5] ? rdata[37] :
                        read_grant_38_reg[5] ? rdata[38] :
                        read_grant_39_reg[5] ? rdata[39] :
                        read_grant_40_reg[3] ? rdata[40] :
                        read_grant_41_reg[5] ? rdata[41] :
                        read_grant_42_reg[5] ? rdata[42] :
                        read_grant_43_reg[5] ? rdata[43] :
                        read_grant_44_reg[3] ? rdata[44] :
                        read_grant_45_reg[5] ? rdata[45] :
                        read_grant_46_reg[5] ? rdata[46] :
                        read_grant_47_reg[5] ? rdata[47] :
                        read_grant_48_reg[3] ? rdata[48] :
                        read_grant_49_reg[5] ? rdata[49] :
                        read_grant_50_reg[5] ? rdata[50] :
                        read_grant_51_reg[5] ? rdata[51] :
                        read_grant_52_reg[3] ? rdata[52] :
                        read_grant_53_reg[5] ? rdata[53] :
                        read_grant_54_reg[5] ? rdata[54] :
                        read_grant_55_reg[5] ? rdata[55] :
                        read_grant_56_reg[3] ? rdata[56] :
                        read_grant_57_reg[5] ? rdata[57] :
                        read_grant_58_reg[5] ? rdata[58] :
                        read_grant_59_reg[5] ? rdata[59] :
                        read_grant_60_reg[3] ? rdata[60] :
                        read_grant_61_reg[5] ? rdata[61] :
                        read_grant_62_reg[5] ? rdata[62] :
                        read_grant_63_reg[5] ? rdata[63] : 0;

assign slave_rdata = read_grant_0_reg[4] ? rdata[0] :
                     read_grant_1_reg[6] ? rdata[1] :
                     read_grant_2_reg[6] ? rdata[2] :
                     read_grant_3_reg[6] ? rdata[3] :
                     read_grant_4_reg[4] ? rdata[4] :
                     read_grant_5_reg[6] ? rdata[5] :
                     read_grant_6_reg[6] ? rdata[6] :
                     read_grant_7_reg[6] ? rdata[7] :
                     read_grant_8_reg[4] ? rdata[8] :
                     read_grant_9_reg[6] ? rdata[9] :
                     read_grant_10_reg[6] ? rdata[10] :
                     read_grant_11_reg[6] ? rdata[11] :
                     read_grant_12_reg[4] ? rdata[12] :
                     read_grant_13_reg[6] ? rdata[13] :
                     read_grant_14_reg[6] ? rdata[14] :
                     read_grant_15_reg[6] ? rdata[15] :
                     read_grant_16_reg[4] ? rdata[16] :
                     read_grant_17_reg[6] ? rdata[17] :
                     read_grant_18_reg[6] ? rdata[18] :
                     read_grant_19_reg[6] ? rdata[19] :
                     read_grant_20_reg[4] ? rdata[20] :
                     read_grant_21_reg[6] ? rdata[21] :
                     read_grant_22_reg[6] ? rdata[22] :
                     read_grant_23_reg[6] ? rdata[23] :
                     read_grant_24_reg[4] ? rdata[24] :
                     read_grant_25_reg[6] ? rdata[25] :
                     read_grant_26_reg[6] ? rdata[26] :
                     read_grant_27_reg[6] ? rdata[27] :
                     read_grant_28_reg[4] ? rdata[28] :
                     read_grant_29_reg[6] ? rdata[29] :
                     read_grant_30_reg[6] ? rdata[30] :
                     read_grant_31_reg[6] ? rdata[31] :
                     read_grant_32_reg[4] ? rdata[32] :
                     read_grant_33_reg[6] ? rdata[33] :
                     read_grant_34_reg[6] ? rdata[34] :
                     read_grant_35_reg[6] ? rdata[35] :
                     read_grant_36_reg[4] ? rdata[36] :
                     read_grant_37_reg[6] ? rdata[37] :
                     read_grant_38_reg[6] ? rdata[38] :
                     read_grant_39_reg[6] ? rdata[39] :
                     read_grant_40_reg[4] ? rdata[40] :
                     read_grant_41_reg[6] ? rdata[41] :
                     read_grant_42_reg[6] ? rdata[42] :
                     read_grant_43_reg[6] ? rdata[43] :
                     read_grant_44_reg[4] ? rdata[44] :
                     read_grant_45_reg[6] ? rdata[45] :
                     read_grant_46_reg[6] ? rdata[46] :
                     read_grant_47_reg[6] ? rdata[47] :
                     read_grant_48_reg[4] ? rdata[48] :
                     read_grant_49_reg[6] ? rdata[49] :
                     read_grant_50_reg[6] ? rdata[50] :
                     read_grant_51_reg[6] ? rdata[51] :
                     read_grant_52_reg[4] ? rdata[52] :
                     read_grant_53_reg[6] ? rdata[53] :
                     read_grant_54_reg[6] ? rdata[54] :
                     read_grant_55_reg[6] ? rdata[55] :
                     read_grant_56_reg[4] ? rdata[56] :
                     read_grant_57_reg[6] ? rdata[57] :
                     read_grant_58_reg[6] ? rdata[58] :
                     read_grant_59_reg[6] ? rdata[59] :
                     read_grant_60_reg[4] ? rdata[60] :
                     read_grant_61_reg[6] ? rdata[61] :
                     read_grant_62_reg[6] ? rdata[62] :
                     read_grant_63_reg[6] ? rdata[63] : 0;

assign pea_0_rdata = read_grant_0_reg[1] ? rdata[0] :
                     read_grant_1_reg[1] ? rdata[1] :
                     read_grant_2_reg[1] ? rdata[2] :
                     read_grant_3_reg[1] ? rdata[3] :
                     read_grant_4_reg[1] ? rdata[4] :
                     read_grant_5_reg[1] ? rdata[5] :
                     read_grant_6_reg[1] ? rdata[6] :
                     read_grant_7_reg[1] ? rdata[7] :
                     read_grant_8_reg[1] ? rdata[8] :
                     read_grant_9_reg[1] ? rdata[9] :
                     read_grant_10_reg[1] ? rdata[10] :
                     read_grant_11_reg[1] ? rdata[11] :
                     read_grant_12_reg[1] ? rdata[12] :
                     read_grant_13_reg[1] ? rdata[13] :
                     read_grant_14_reg[1] ? rdata[14] :
                     read_grant_15_reg[1] ? rdata[15] : 0;

assign pea_1_rdata = read_grant_4_reg[3] ? rdata[4] :
                     read_grant_5_reg[3] ? rdata[5] :
                     read_grant_6_reg[3] ? rdata[6] :
                     read_grant_7_reg[3] ? rdata[7] : 0;

assign pea_2_rdata = read_grant_8_reg[3] ? rdata[8] :
                     read_grant_9_reg[3] ? rdata[9] :
                     read_grant_10_reg[3] ? rdata[10] :
                     read_grant_11_reg[3] ? rdata[11] : 0;

assign pea_3_rdata = read_grant_12_reg[3] ? rdata[12] :
                     read_grant_13_reg[3] ? rdata[13] :
                     read_grant_14_reg[3] ? rdata[14] :
                     read_grant_15_reg[3] ? rdata[15] : 0;

assign pea_4_rdata = read_grant_16_reg[1] ? rdata[16] :
                     read_grant_17_reg[1] ? rdata[17] :
                     read_grant_18_reg[1] ? rdata[18] :
                     read_grant_19_reg[1] ? rdata[19] :
                     read_grant_20_reg[1] ? rdata[20] :
                     read_grant_21_reg[1] ? rdata[21] :
                     read_grant_22_reg[1] ? rdata[22] :
                     read_grant_23_reg[1] ? rdata[23] :
                     read_grant_24_reg[1] ? rdata[24] :
                     read_grant_25_reg[1] ? rdata[25] :
                     read_grant_26_reg[1] ? rdata[26] :
                     read_grant_27_reg[1] ? rdata[27] :
                     read_grant_28_reg[1] ? rdata[28] :
                     read_grant_29_reg[1] ? rdata[29] :
                     read_grant_30_reg[1] ? rdata[30] :
                     read_grant_31_reg[1] ? rdata[31] : 0;

assign pea_5_rdata = read_grant_20_reg[3] ? rdata[20] :
                     read_grant_21_reg[3] ? rdata[21] :
                     read_grant_22_reg[3] ? rdata[22] :
                     read_grant_23_reg[3] ? rdata[23] : 0;

assign pea_6_rdata = read_grant_24_reg[3] ? rdata[24] :
                     read_grant_25_reg[3] ? rdata[25] :
                     read_grant_26_reg[3] ? rdata[26] :
                     read_grant_27_reg[3] ? rdata[27] : 0;

assign pea_7_rdata = read_grant_28_reg[3] ? rdata[28] :
                     read_grant_29_reg[3] ? rdata[29] :
                     read_grant_30_reg[3] ? rdata[30] :
                     read_grant_31_reg[3] ? rdata[31] : 0;

assign pea_8_rdata = read_grant_32_reg[1] ? rdata[32] :
                     read_grant_33_reg[1] ? rdata[33] :
                     read_grant_34_reg[1] ? rdata[34] :
                     read_grant_35_reg[1] ? rdata[35] :
                     read_grant_36_reg[1] ? rdata[36] :
                     read_grant_37_reg[1] ? rdata[37] :
                     read_grant_38_reg[1] ? rdata[38] :
                     read_grant_39_reg[1] ? rdata[39] :
                     read_grant_40_reg[1] ? rdata[40] :
                     read_grant_41_reg[1] ? rdata[41] :
                     read_grant_42_reg[1] ? rdata[42] :
                     read_grant_43_reg[1] ? rdata[43] :
                     read_grant_44_reg[1] ? rdata[44] :
                     read_grant_45_reg[1] ? rdata[45] :
                     read_grant_46_reg[1] ? rdata[46] :
                     read_grant_47_reg[1] ? rdata[47] : 0;

assign pea_9_rdata = read_grant_36_reg[3] ? rdata[36] :
                     read_grant_37_reg[3] ? rdata[37] :
                     read_grant_38_reg[3] ? rdata[38] :
                     read_grant_39_reg[3] ? rdata[39] : 0;

assign pea_a_rdata = read_grant_40_reg[3] ? rdata[40] :
                     read_grant_41_reg[3] ? rdata[41] :
                     read_grant_42_reg[3] ? rdata[42] :
                     read_grant_43_reg[3] ? rdata[43] : 0;

assign pea_b_rdata = read_grant_44_reg[3] ? rdata[44] :
                     read_grant_45_reg[3] ? rdata[45] :
                     read_grant_46_reg[3] ? rdata[46] :
                     read_grant_47_reg[3] ? rdata[47] : 0;

assign pea_c_rdata = read_grant_48_reg[1] ? rdata[48] :
                     read_grant_49_reg[1] ? rdata[49] :
                     read_grant_50_reg[1] ? rdata[50] :
                     read_grant_51_reg[1] ? rdata[51] :
                     read_grant_52_reg[1] ? rdata[52] :
                     read_grant_53_reg[1] ? rdata[53] :
                     read_grant_54_reg[1] ? rdata[54] :
                     read_grant_55_reg[1] ? rdata[55] :
                     read_grant_56_reg[1] ? rdata[56] :
                     read_grant_57_reg[1] ? rdata[57] :
                     read_grant_58_reg[1] ? rdata[58] :
                     read_grant_59_reg[1] ? rdata[59] :
                     read_grant_60_reg[1] ? rdata[60] :
                     read_grant_61_reg[1] ? rdata[61] :
                     read_grant_62_reg[1] ? rdata[62] :
                     read_grant_63_reg[1] ? rdata[63] : 0;

assign pea_d_rdata = read_grant_52_reg[3] ? rdata[52] :
                     read_grant_53_reg[3] ? rdata[53] :
                     read_grant_54_reg[3] ? rdata[54] :
                     read_grant_55_reg[3] ? rdata[55] : 0;

assign pea_e_rdata = read_grant_56_reg[3] ? rdata[56] :
                     read_grant_57_reg[3] ? rdata[57] :
                     read_grant_58_reg[3] ? rdata[58] :
                     read_grant_59_reg[3] ? rdata[59] : 0;

assign pea_f_rdata = read_grant_60_reg[3] ? rdata[60] :
                     read_grant_61_reg[3] ? rdata[61] :
                     read_grant_62_reg[3] ? rdata[62] :
                     read_grant_63_reg[3] ? rdata[63] : 0;

assign vcu_0_rdata = read_grant_0_reg[2] ? rdata[0] :
                     read_grant_1_reg[2] ? rdata[1] :
                     read_grant_2_reg[2] ? rdata[2] :
                     read_grant_3_reg[2] ? rdata[3] :
                     read_grant_4_reg[2] ? rdata[4] :
                     read_grant_5_reg[2] ? rdata[5] :
                     read_grant_6_reg[2] ? rdata[6] :
                     read_grant_7_reg[2] ? rdata[7] :
                     read_grant_8_reg[2] ? rdata[8] :
                     read_grant_9_reg[2] ? rdata[9] :
                     read_grant_10_reg[2] ? rdata[10] :
                     read_grant_11_reg[2] ? rdata[11] :
                     read_grant_12_reg[2] ? rdata[12] :
                     read_grant_13_reg[2] ? rdata[13] :
                     read_grant_14_reg[2] ? rdata[14] :
                     read_grant_15_reg[2] ? rdata[15] : 0;

assign vcu_1_rdata = read_grant_4_reg[4] ? rdata[4] :
                     read_grant_5_reg[4] ? rdata[5] :
                     read_grant_6_reg[4] ? rdata[6] :
                     read_grant_7_reg[4] ? rdata[7] : 0;

assign vcu_2_rdata = read_grant_8_reg[4] ? rdata[8] :
                     read_grant_9_reg[4] ? rdata[9] :
                     read_grant_10_reg[4] ? rdata[10] :
                     read_grant_11_reg[4] ? rdata[11] : 0;

assign vcu_3_rdata = read_grant_12_reg[4] ? rdata[12] :
                     read_grant_13_reg[4] ? rdata[13] :
                     read_grant_14_reg[4] ? rdata[14] :
                     read_grant_15_reg[4] ? rdata[15] : 0;

assign vcu_4_rdata = read_grant_16_reg[2] ? rdata[16] :
                     read_grant_17_reg[2] ? rdata[17] :
                     read_grant_18_reg[2] ? rdata[18] :
                     read_grant_19_reg[2] ? rdata[19] :
                     read_grant_20_reg[2] ? rdata[20] :
                     read_grant_21_reg[2] ? rdata[21] :
                     read_grant_22_reg[2] ? rdata[22] :
                     read_grant_23_reg[2] ? rdata[23] :
                     read_grant_24_reg[2] ? rdata[24] :
                     read_grant_25_reg[2] ? rdata[25] :
                     read_grant_26_reg[2] ? rdata[26] :
                     read_grant_27_reg[2] ? rdata[27] :
                     read_grant_28_reg[2] ? rdata[28] :
                     read_grant_29_reg[2] ? rdata[29] :
                     read_grant_30_reg[2] ? rdata[30] :
                     read_grant_31_reg[2] ? rdata[31] : 0;

assign vcu_5_rdata = read_grant_20_reg[4] ? rdata[20] :
                     read_grant_21_reg[4] ? rdata[21] :
                     read_grant_22_reg[4] ? rdata[22] :
                     read_grant_23_reg[4] ? rdata[23] : 0;

assign vcu_6_rdata = read_grant_24_reg[4] ? rdata[24] :
                     read_grant_25_reg[4] ? rdata[25] :
                     read_grant_26_reg[4] ? rdata[26] :
                     read_grant_27_reg[4] ? rdata[27] : 0;

assign vcu_7_rdata = read_grant_28_reg[4] ? rdata[28] :
                     read_grant_29_reg[4] ? rdata[29] :
                     read_grant_30_reg[4] ? rdata[30] :
                     read_grant_31_reg[4] ? rdata[31] : 0;

assign vcu_8_rdata = read_grant_32_reg[2] ? rdata[32] :
                     read_grant_33_reg[2] ? rdata[33] :
                     read_grant_34_reg[2] ? rdata[34] :
                     read_grant_35_reg[2] ? rdata[35] :
                     read_grant_36_reg[2] ? rdata[36] :
                     read_grant_37_reg[2] ? rdata[37] :
                     read_grant_38_reg[2] ? rdata[38] :
                     read_grant_39_reg[2] ? rdata[39] :
                     read_grant_40_reg[2] ? rdata[40] :
                     read_grant_41_reg[2] ? rdata[41] :
                     read_grant_42_reg[2] ? rdata[42] :
                     read_grant_43_reg[2] ? rdata[43] :
                     read_grant_44_reg[2] ? rdata[44] :
                     read_grant_45_reg[2] ? rdata[45] :
                     read_grant_46_reg[2] ? rdata[46] :
                     read_grant_47_reg[2] ? rdata[47] : 0;

assign vcu_9_rdata = read_grant_36_reg[4] ? rdata[36] :
                     read_grant_37_reg[4] ? rdata[37] :
                     read_grant_38_reg[4] ? rdata[38] :
                     read_grant_39_reg[4] ? rdata[39] : 0;

assign vcu_a_rdata = read_grant_40_reg[4] ? rdata[40] :
                     read_grant_41_reg[4] ? rdata[41] :
                     read_grant_42_reg[4] ? rdata[42] :
                     read_grant_43_reg[4] ? rdata[43] : 0;

assign vcu_b_rdata = read_grant_44_reg[4] ? rdata[44] :
                     read_grant_45_reg[4] ? rdata[45] :
                     read_grant_46_reg[4] ? rdata[46] :
                     read_grant_47_reg[4] ? rdata[47] : 0;

assign vcu_c_rdata = read_grant_48_reg[2] ? rdata[48] :
                     read_grant_49_reg[2] ? rdata[49] :
                     read_grant_50_reg[2] ? rdata[50] :
                     read_grant_51_reg[2] ? rdata[51] :
                     read_grant_52_reg[2] ? rdata[52] :
                     read_grant_53_reg[2] ? rdata[53] :
                     read_grant_54_reg[2] ? rdata[54] :
                     read_grant_55_reg[2] ? rdata[55] :
                     read_grant_56_reg[2] ? rdata[56] :
                     read_grant_57_reg[2] ? rdata[57] :
                     read_grant_58_reg[2] ? rdata[58] :
                     read_grant_59_reg[2] ? rdata[59] :
                     read_grant_60_reg[2] ? rdata[60] :
                     read_grant_61_reg[2] ? rdata[61] :
                     read_grant_62_reg[2] ? rdata[62] :
                     read_grant_63_reg[2] ? rdata[63] : 0;

assign vcu_d_rdata = read_grant_52_reg[4] ? rdata[52] :
                     read_grant_53_reg[4] ? rdata[53] :
                     read_grant_54_reg[4] ? rdata[54] :
                     read_grant_55_reg[4] ? rdata[55] : 0;

assign vcu_e_rdata = read_grant_56_reg[4] ? rdata[56] :
                     read_grant_57_reg[4] ? rdata[57] :
                     read_grant_58_reg[4] ? rdata[58] :
                     read_grant_59_reg[4] ? rdata[59] : 0;

assign vcu_f_rdata = read_grant_60_reg[4] ? rdata[60] :
                     read_grant_61_reg[4] ? rdata[61] :
                     read_grant_62_reg[4] ? rdata[62] :
                     read_grant_63_reg[4] ? rdata[63] : 0;

assign master_0_wready = write_grant_0[0] | write_grant_1[0] | write_grant_2[0] | write_grant_3[0] | write_grant_4[0] | write_grant_5[0] | write_grant_6[0] | write_grant_7[0] | write_grant_8[0] | write_grant_9[0] | write_grant_10[0] | write_grant_11[0] | write_grant_12[0] | write_grant_13[0] | write_grant_14[0] | write_grant_15[0] | write_grant_16[0] | write_grant_17[0] | write_grant_18[0] | write_grant_19[0] | write_grant_20[0] | write_grant_21[0] | write_grant_22[0] | write_grant_23[0] | write_grant_24[0] | write_grant_25[0] | write_grant_26[0] | write_grant_27[0] | write_grant_28[0] | write_grant_29[0] | write_grant_30[0] | write_grant_31[0] | write_grant_32[0] | write_grant_33[0] | write_grant_34[0] | write_grant_35[0] | write_grant_36[0] | write_grant_37[0] | write_grant_38[0] | write_grant_39[0] | write_grant_40[0] | write_grant_41[0] | write_grant_42[0] | write_grant_43[0] | write_grant_44[0] | write_grant_45[0] | write_grant_46[0] | write_grant_47[0] | write_grant_48[0] | write_grant_49[0] | write_grant_50[0] | write_grant_51[0] | write_grant_52[0] | write_grant_53[0] | write_grant_54[0] | write_grant_55[0] | write_grant_56[0] | write_grant_57[0] | write_grant_58[0] | write_grant_59[0] | write_grant_60[0] | write_grant_61[0] | write_grant_62[0] | write_grant_63[0];

assign master_1_wready = write_grant_0[3] | write_grant_1[5] | write_grant_2[5] | write_grant_3[5] | write_grant_4[3] | write_grant_5[5] | write_grant_6[5] | write_grant_7[5] | write_grant_8[3] | write_grant_9[5] | write_grant_10[5] | write_grant_11[5] | write_grant_12[3] | write_grant_13[5] | write_grant_14[5] | write_grant_15[5] | write_grant_16[3] | write_grant_17[5] | write_grant_18[5] | write_grant_19[5] | write_grant_20[3] | write_grant_21[5] | write_grant_22[5] | write_grant_23[5] | write_grant_24[3] | write_grant_25[5] | write_grant_26[5] | write_grant_27[5] | write_grant_28[3] | write_grant_29[5] | write_grant_30[5] | write_grant_31[5] | write_grant_32[3] | write_grant_33[5] | write_grant_34[5] | write_grant_35[5] | write_grant_36[3] | write_grant_37[5] | write_grant_38[5] | write_grant_39[5] | write_grant_40[3] | write_grant_41[5] | write_grant_42[5] | write_grant_43[5] | write_grant_44[3] | write_grant_45[5] | write_grant_46[5] | write_grant_47[5] | write_grant_48[3] | write_grant_49[5] | write_grant_50[5] | write_grant_51[5] | write_grant_52[3] | write_grant_53[5] | write_grant_54[5] | write_grant_55[5] | write_grant_56[3] | write_grant_57[5] | write_grant_58[5] | write_grant_59[5] | write_grant_60[3] | write_grant_61[5] | write_grant_62[5] | write_grant_63[5];

assign slave_wready = write_grant_0[4] | write_grant_1[6] | write_grant_2[6] | write_grant_3[6] | write_grant_4[4] | write_grant_5[6] | write_grant_6[6] | write_grant_7[6] | write_grant_8[4] | write_grant_9[6] | write_grant_10[6] | write_grant_11[6] | write_grant_12[4] | write_grant_13[6] | write_grant_14[6] | write_grant_15[6] | write_grant_16[4] | write_grant_17[6] | write_grant_18[6] | write_grant_19[6] | write_grant_20[4] | write_grant_21[6] | write_grant_22[6] | write_grant_23[6] | write_grant_24[4] | write_grant_25[6] | write_grant_26[6] | write_grant_27[6] | write_grant_28[4] | write_grant_29[6] | write_grant_30[6] | write_grant_31[6] | write_grant_32[4] | write_grant_33[6] | write_grant_34[6] | write_grant_35[6] | write_grant_36[4] | write_grant_37[6] | write_grant_38[6] | write_grant_39[6] | write_grant_40[4] | write_grant_41[6] | write_grant_42[6] | write_grant_43[6] | write_grant_44[4] | write_grant_45[6] | write_grant_46[6] | write_grant_47[6] | write_grant_48[4] | write_grant_49[6] | write_grant_50[6] | write_grant_51[6] | write_grant_52[4] | write_grant_53[6] | write_grant_54[6] | write_grant_55[6] | write_grant_56[4] | write_grant_57[6] | write_grant_58[6] | write_grant_59[6] | write_grant_60[4] | write_grant_61[6] | write_grant_62[6] | write_grant_63[6];

assign pea_0_wready = write_grant_0[1] | write_grant_1[1] | write_grant_2[1] | write_grant_3[1] | write_grant_4[1] | write_grant_5[1] | write_grant_6[1] | write_grant_7[1] | write_grant_8[1] | write_grant_9[1] | write_grant_10[1] | write_grant_11[1] | write_grant_12[1] | write_grant_13[1] | write_grant_14[1] | write_grant_15[1];
assign pea_1_wready = write_grant_4[3] | write_grant_5[3] | write_grant_6[3] | write_grant_7[3];
assign pea_2_wready = write_grant_8[3] | write_grant_9[3] | write_grant_10[3] | write_grant_11[3];
assign pea_3_wready = write_grant_12[3] | write_grant_13[3] | write_grant_14[3] | write_grant_15[3];
assign pea_4_wready = write_grant_16[1] | write_grant_17[1] | write_grant_18[1] | write_grant_19[1] | write_grant_20[1] | write_grant_21[1] | write_grant_22[1] | write_grant_23[1] | write_grant_24[1] | write_grant_25[1] | write_grant_26[1] | write_grant_27[1] | write_grant_28[1] | write_grant_29[1] | write_grant_30[1] | write_grant_31[1];
assign pea_5_wready = write_grant_20[3] | write_grant_21[3] | write_grant_22[3] | write_grant_23[3];
assign pea_6_wready = write_grant_24[3] | write_grant_25[3] | write_grant_26[3] | write_grant_27[3];
assign pea_7_wready = write_grant_28[3] | write_grant_29[3] | write_grant_30[3] | write_grant_31[3];
assign pea_8_wready = write_grant_32[1] | write_grant_33[1] | write_grant_34[1] | write_grant_35[1] | write_grant_36[1] | write_grant_37[1] | write_grant_38[1] | write_grant_39[1] | write_grant_40[1] | write_grant_41[1] | write_grant_42[1] | write_grant_43[1] | write_grant_44[1] | write_grant_45[1] | write_grant_46[1] | write_grant_47[1];
assign pea_9_wready = write_grant_36[3] | write_grant_37[3] | write_grant_38[3] | write_grant_39[3];
assign pea_a_wready = write_grant_40[3] | write_grant_41[3] | write_grant_42[3] | write_grant_43[3];
assign pea_b_wready = write_grant_44[3] | write_grant_45[3] | write_grant_46[3] | write_grant_47[3];
assign pea_c_wready = write_grant_48[1] | write_grant_49[1] | write_grant_50[1] | write_grant_51[1] | write_grant_52[1] | write_grant_53[1] | write_grant_54[1] | write_grant_55[1] | write_grant_56[1] | write_grant_57[1] | write_grant_58[1] | write_grant_59[1] | write_grant_60[1] | write_grant_61[1] | write_grant_62[1] | write_grant_63[1];
assign pea_d_wready = write_grant_52[3] | write_grant_53[3] | write_grant_54[3] | write_grant_55[3];
assign pea_e_wready = write_grant_56[3] | write_grant_57[3] | write_grant_58[3] | write_grant_59[3];
assign pea_f_wready = write_grant_60[3] | write_grant_61[3] | write_grant_62[3] | write_grant_63[3];
assign vcu_0_wready = write_grant_0[2] | write_grant_1[2] | write_grant_2[2] | write_grant_3[2] | write_grant_4[2] | write_grant_5[2] | write_grant_6[2] | write_grant_7[2] | write_grant_8[2] | write_grant_9[2] | write_grant_10[2] | write_grant_11[2] | write_grant_12[2] | write_grant_13[2] | write_grant_14[2] | write_grant_15[2];
assign vcu_1_wready = write_grant_4[4] | write_grant_5[4] | write_grant_6[4] | write_grant_7[4];
assign vcu_2_wready = write_grant_8[4] | write_grant_9[4] | write_grant_10[4] | write_grant_11[4];
assign vcu_3_wready = write_grant_12[4] | write_grant_13[4] | write_grant_14[4] | write_grant_15[4];
assign vcu_4_wready = write_grant_16[2] | write_grant_17[2] | write_grant_18[2] | write_grant_19[2] | write_grant_20[2] | write_grant_21[2] | write_grant_22[2] | write_grant_23[2] | write_grant_24[2] | write_grant_25[2] | write_grant_26[2] | write_grant_27[2] | write_grant_28[2] | write_grant_29[2] | write_grant_30[2] | write_grant_31[2];
assign vcu_5_wready = write_grant_20[4] | write_grant_21[4] | write_grant_22[4] | write_grant_23[4];
assign vcu_6_wready = write_grant_24[4] | write_grant_25[4] | write_grant_26[4] | write_grant_27[4];
assign vcu_7_wready = write_grant_28[4] | write_grant_29[4] | write_grant_30[4] | write_grant_31[4];
assign vcu_8_wready = write_grant_32[2] | write_grant_33[2] | write_grant_34[2] | write_grant_35[2] | write_grant_36[2] | write_grant_37[2] | write_grant_38[2] | write_grant_39[2] | write_grant_40[2] | write_grant_41[2] | write_grant_42[2] | write_grant_43[2] | write_grant_44[2] | write_grant_45[2] | write_grant_46[2] | write_grant_47[2];
assign vcu_9_wready = write_grant_36[4] | write_grant_37[4] | write_grant_38[4] | write_grant_39[4];
assign vcu_a_wready = write_grant_40[4] | write_grant_41[4] | write_grant_42[4] | write_grant_43[4];
assign vcu_b_wready = write_grant_44[4] | write_grant_45[4] | write_grant_46[4] | write_grant_47[4];
assign vcu_c_wready = write_grant_48[2] | write_grant_49[2] | write_grant_50[2] | write_grant_51[2] | write_grant_52[2] | write_grant_53[2] | write_grant_54[2] | write_grant_55[2] | write_grant_56[2] | write_grant_57[2] | write_grant_58[2] | write_grant_59[2] | write_grant_60[2] | write_grant_61[2] | write_grant_62[2] | write_grant_63[2];
assign vcu_d_wready = write_grant_52[4] | write_grant_53[4] | write_grant_54[4] | write_grant_55[4];
assign vcu_e_wready = write_grant_56[4] | write_grant_57[4] | write_grant_58[4] | write_grant_59[4];
assign vcu_f_wready = write_grant_60[4] | write_grant_61[4] | write_grant_62[4] | write_grant_63[4];
