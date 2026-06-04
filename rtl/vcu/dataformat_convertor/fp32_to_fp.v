module fp32_to_fp(
  in_data, dtype_sel, 
  out_data
);

input [31:0]  in_data;
input         dtype_sel;
output [15:0] out_data;

wire [15:0] fp16;
wire [15:0] bf16;

fp32_to_bfloat u_fp32_to_bfloat(
  .in_data  ( in_data ),
  .out_data ( bf16    )
);

fp32_to_half u_fp32_to_half(
  .in_data  ( in_data ),
  .out_data ( fp16    )
);

assign out_data = dtype_sel ? bf16 : fp16;

    // reg[4:0] exp_16;
    // reg[9:0] frac_16;

    // wire[7:0] exp_bf16;
    // wire[6:0] frac_bf16;
    // wire NAN_f;
    
    // wire[15:0]  fp16;
    // wire[15:0]  bf16;
    
    // wire            sign;
    // wire    [7:0]   exponent;
    // wire    [23:0]  fraction;
    // wire    [7:0]   expo_nonbias;
    // wire exp_non_s;
    // wire    [7:0]   expo_nonbias_abs;
    // wire sel_0,sel_1,sel_2,sel_3;

    // wire G;
    // wire R;
    // wire S;
    // wire h_carry;
    // wire h_exp_carry_p;
    // wire outlier_sign;
    
    // assign sign = in_data[31];
    // assign exponent = in_data[30:23];
    // assign fraction = {1'b1, in_data[22:0]};
    // assign expo_nonbias = exponent - 'd127;
    
    // assign exp_non_s = exponent <'d127;
    // assign expo_nonbias_abs = exp_non_s ? 8'd127 - exponent : exponent - 'd127;
    
    // assign sel_0 = exp_non_s ? (expo_nonbias_abs<='d14) : (expo_nonbias_abs<='d15);
    // assign sel_1 = exp_non_s ? 0 : (expo_nonbias_abs > 'd15);
    // assign sel_2 = exp_non_s ? ((expo_nonbias_abs > 'd14)&&(expo_nonbias_abs <= 'd25)) : 0;
    // assign sel_3 = exp_non_s ? (expo_nonbias_abs > 'd25) : 0;
    
    // assign NAN_f = (&in_data[30:23]) & (|in_data[22:0]);
    // assign fp16 = NAN_f ? {1'b0,exp_16,frac_16}: {sign,exp_16,frac_16};
    // // assign bf16 = NAN_f ? {1'b0,exp_bf16,frac_bf16} : {sign,exp_bf16,frac_bf16};
    // assign out_data = dtype_sel ? bf16 : fp16;

    //bf16--------------------------------------------------------
    // always @(*) begin
    //     casez({fraction[15],(fraction[14:0]=='d0),fraction[16],(fraction[22:16]==7'd127),(exponent==8'd255)})
    //             5'b11111:begin  //That will not happen
    //                         frac_bf16 = 'd0;
    //                         exp_bf16 = exponent;
    //                     end
	// 	        5'b11110:begin
    //                         frac_bf16 = 'd0;
    //                         exp_bf16 = exponent + 'd1;
    //                     end
    //             5'b1110?:begin
    //                         frac_bf16 = fraction[22:16]+'d1;
    //                         exp_bf16 =  exponent;
    //                     end
    //             5'b110??:begin
    //                         frac_bf16 = fraction[22:16];
    //                         exp_bf16 = exponent;
    //                     end
    //             5'b10?11:begin
    //                         frac_bf16 = 'd0;
    //                         exp_bf16 = exponent;
    //                     end
	//             5'b10?10:begin
    //                         frac_bf16 = 'd0;
    //                         exp_bf16 = exponent+'d1;
    //                     end
    //             5'b10?0?:begin
    //                         frac_bf16 = fraction[22:16]+'d1;
    //                         exp_bf16 =  exponent;
    //                     end
    //             5'b0????:begin
    //                         frac_bf16 = fraction[22:16];
    //                         exp_bf16 = exponent;
    //                     end
    //             default:begin
    //                         frac_bf16 = 'd0;
    //                         exp_bf16 = 'd0;
    //                     end
    //     endcase

	//     if(exponent==8'd255) begin
	// 	    if(fraction[22:0]=='d0) begin
    //             frac_bf16 = 'd0;
    //         end
    //         else begin//nan
	// 			frac_bf16 = 'd64;
	//         end
	//     end
    //     else begin
    //         frac_bf16 = 'd0;
    //     end
    // end


    // assign G = in_data[16];
    // assign R = in_data[15];
    // assign S = |in_data[14:0];

    // assign h_carry = R & (G | S);
    // assign h_exp_carry_p = (in_data[22:16] == 7'h7f);

    // assign frac_bf16 = (h_carry & h_exp_carry_p) ? 7'b0 : (h_carry ? in_data[22:16] + 1 : in_data[22:16]);
    // assign exp_bf16 = (h_carry & h_exp_carry_p) ?  in_data[30:23] + 1 : in_data[30:23];

    // assign outlier_sign = &in_data[30:23];
    // assign bf16 = outlier_sign ? in_data[31:16] : {sign,exp_bf16,frac_bf16};

endmodule