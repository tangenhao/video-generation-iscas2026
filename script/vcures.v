assign master_0_rready = read_grant_0[0] | read_grant_1[0] | read_grant_2[0] | read_grant_3[0] | read_grant_4[0] | read_grant_5[0] | read_grant_6[0] | read_grant_7[0] | read_grant_8[0] | read_grant_9[0] | read_grant_10[0] | read_grant_11[0] | read_grant_12[0] | read_grant_13[0] | read_grant_14[0] | read_grant_15[0];
assign master_1_rready = read_grant_0[2] | read_grant_1[3] | read_grant_2[3] | read_grant_3[3] | read_grant_4[2] | read_grant_5[3] | read_grant_6[3] | read_grant_7[3] | read_grant_8[2] | read_grant_9[3] | read_grant_10[3] | read_grant_11[3] | read_grant_12[2] | read_grant_13[3] | read_grant_14[3] | read_grant_15[3];
assign slave_rready = read_grant_0[3] | read_grant_1[4] | read_grant_2[4] | read_grant_3[4] | read_grant_4[3] | read_grant_5[4] | read_grant_6[4] | read_grant_7[4] | read_grant_8[3] | read_grant_9[4] | read_grant_10[4] | read_grant_11[4] | read_grant_12[3] | read_grant_13[4] | read_grant_14[4] | read_grant_15[4];
assign vcures_0_rready = read_grant_0[1] | read_grant_1[1] | read_grant_2[1] | read_grant_3[1];
assign vcures_1_rready = read_grant_1[2];
assign vcures_2_rready = read_grant_2[2];
assign vcures_3_rready = read_grant_3[2];
assign vcures_4_rready = read_grant_4[1] | read_grant_5[1] | read_grant_6[1] | read_grant_7[1];
assign vcures_5_rready = read_grant_5[2];
assign vcures_6_rready = read_grant_6[2];
assign vcures_7_rready = read_grant_7[2];
assign vcures_8_rready = read_grant_8[1] | read_grant_9[1] | read_grant_10[1] | read_grant_11[1];
assign vcures_9_rready = read_grant_9[2];
assign vcures_a_rready = read_grant_10[2];
assign vcures_b_rready = read_grant_11[2];
assign vcures_c_rready = read_grant_12[1] | read_grant_13[1] | read_grant_14[1] | read_grant_15[1];
assign vcures_d_rready = read_grant_13[2];
assign vcures_e_rready = read_grant_14[2];
assign vcures_f_rready = read_grant_15[2];
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
                        read_grant_15_reg[0] ? rdata[15] : 0;

assign master_1_rdata = read_grant_0_reg[2] ? rdata[0] :
                        read_grant_1_reg[3] ? rdata[1] :
                        read_grant_2_reg[3] ? rdata[2] :
                        read_grant_3_reg[3] ? rdata[3] :
                        read_grant_4_reg[2] ? rdata[4] :
                        read_grant_5_reg[3] ? rdata[5] :
                        read_grant_6_reg[3] ? rdata[6] :
                        read_grant_7_reg[3] ? rdata[7] :
                        read_grant_8_reg[2] ? rdata[8] :
                        read_grant_9_reg[3] ? rdata[9] :
                        read_grant_10_reg[3] ? rdata[10] :
                        read_grant_11_reg[3] ? rdata[11] :
                        read_grant_12_reg[2] ? rdata[12] :
                        read_grant_13_reg[3] ? rdata[13] :
                        read_grant_14_reg[3] ? rdata[14] :
                        read_grant_15_reg[3] ? rdata[15] : 0;

assign slave_rdata = read_grant_0_reg[3] ? rdata[0] :
                     read_grant_1_reg[4] ? rdata[1] :
                     read_grant_2_reg[4] ? rdata[2] :
                     read_grant_3_reg[4] ? rdata[3] :
                     read_grant_4_reg[3] ? rdata[4] :
                     read_grant_5_reg[4] ? rdata[5] :
                     read_grant_6_reg[4] ? rdata[6] :
                     read_grant_7_reg[4] ? rdata[7] :
                     read_grant_8_reg[3] ? rdata[8] :
                     read_grant_9_reg[4] ? rdata[9] :
                     read_grant_10_reg[4] ? rdata[10] :
                     read_grant_11_reg[4] ? rdata[11] :
                     read_grant_12_reg[3] ? rdata[12] :
                     read_grant_13_reg[4] ? rdata[13] :
                     read_grant_14_reg[4] ? rdata[14] :
                     read_grant_15_reg[4] ? rdata[15] : 0;

assign vcures_0_rdata = read_grant_0_reg[1] ? rdata[0] :
                        read_grant_1_reg[1] ? rdata[1] :
                        read_grant_2_reg[1] ? rdata[2] :
                        read_grant_3_reg[1] ? rdata[3] : 0;

assign vcures_1_rdata = read_grant_1_reg[2] ? rdata[1] : 0;

assign vcures_2_rdata = read_grant_2_reg[2] ? rdata[2] : 0;

assign vcures_3_rdata = read_grant_3_reg[2] ? rdata[3] : 0;

assign vcures_4_rdata = read_grant_4_reg[1] ? rdata[4] :
                        read_grant_5_reg[1] ? rdata[5] :
                        read_grant_6_reg[1] ? rdata[6] :
                        read_grant_7_reg[1] ? rdata[7] : 0;

assign vcures_5_rdata = read_grant_5_reg[2] ? rdata[5] : 0;

assign vcures_6_rdata = read_grant_6_reg[2] ? rdata[6] : 0;

assign vcures_7_rdata = read_grant_7_reg[2] ? rdata[7] : 0;

assign vcures_8_rdata = read_grant_8_reg[1] ? rdata[8] :
                        read_grant_9_reg[1] ? rdata[9] :
                        read_grant_10_reg[1] ? rdata[10] :
                        read_grant_11_reg[1] ? rdata[11] : 0;

assign vcures_9_rdata = read_grant_9_reg[2] ? rdata[9] : 0;

assign vcures_a_rdata = read_grant_10_reg[2] ? rdata[10] : 0;

assign vcures_b_rdata = read_grant_11_reg[2] ? rdata[11] : 0;

assign vcures_c_rdata = read_grant_12_reg[1] ? rdata[12] :
                        read_grant_13_reg[1] ? rdata[13] :
                        read_grant_14_reg[1] ? rdata[14] :
                        read_grant_15_reg[1] ? rdata[15] : 0;

assign vcures_d_rdata = read_grant_13_reg[2] ? rdata[13] : 0;

assign vcures_e_rdata = read_grant_14_reg[2] ? rdata[14] : 0;

assign vcures_f_rdata = read_grant_15_reg[2] ? rdata[15] : 0;

