module exp2_pre(
  data, 
  index, data_out, norm_exp
);
input       [31:0] data;
output wire [6:0]  index;
output wire [18:0] data_out;
output wire [8:0]  norm_exp;  // |-149 | =149  1+ 8 bit

wire [30:0]  norm_frac_mid; // 23 + 8(int) = 31
wire [30:0]  norm_frac;
wire [4:0]   shift_number;
wire [8:0]   norm_exp_mid;  // 1bit sign
wire [8:0]   norm_exp_mid_minus_1;  // 1bit sign
wire [22:0]  frac_in;

// assign norm_frac_mid = (data[30:23] == 0) ? {8'd0, data[22:0]} : {8'd1, data[22:0]};
assign norm_frac_mid = ({31{~(|data[30:23])}} &  {8'd0, data[22:0]}) | ({31{|data[30:23]}} &  {8'd1, data[22:0]});

// assign shift_number = (data[30:23] > 8'd127) ? (data[30:23] - 127) : (127 - data[30:23]);
assign shift_number = ( {5{data[30]}} & (data[30:23] - 127) ) |  ( {5{~data[30]}}  &  (127 - data[30:23]) );

// assign norm_frac = (data[30:23] > 8'd127) ? ( norm_frac_mid << shift_number ) : ( norm_frac_mid >> shift_number );
assign norm_frac = ( {31{data[30]}}  &  ( norm_frac_mid << shift_number ) )  | ( {31{~data[30]}}  &  ( norm_frac_mid >> shift_number ) );

assign norm_exp_mid = 9'd127 - {1'b0, norm_frac[30:23]};

// assign norm_exp = data[31] ? ((norm_frac[22:0] == 23'b0) ? norm_exp_mid  : (norm_exp_mid -1)) : (norm_frac[29:23] + 127);
assign norm_exp_mid_minus_1 = 9'd126 - {1'b0, norm_frac[30:23]} ;

assign norm_exp = ( {9{data[31] & (~(|norm_frac[22:0]))}} & norm_exp_mid ) | ( {9{data[31] & (|norm_frac[22:0]) }} &  norm_exp_mid_minus_1) | ( {9{~data[31]}} & (norm_frac[29:23] + 127) );


assign frac_in = data[31] ? ((~norm_frac[22:0]) + 1) : norm_frac[22:0];
assign index = frac_in[22:16];
assign data_out = {frac_in[15:0], 3'b0};

endmodule

  
