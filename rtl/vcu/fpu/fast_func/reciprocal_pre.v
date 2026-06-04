module reciprocal_pre(
  data, 
  index, data_out, norm_exp
);

input       [31:0] data;
output wire [6:0]  index;
output wire [18:0] data_out;
output wire [7:0]  norm_exp;

wire [1:0]  shift_number;
wire [7:0]  norm_exp_mid;
wire [23:0] norm_frac;

assign shift_number = (data[30:23] != 8'h0) ? 0 : (data[22] ?  2'd1  : 2'd2);

assign norm_exp_mid = (8'd254) - data[30:23];
assign norm_exp = (data[30:23] == 8'h0) ? (norm_exp_mid + shift_number -1) : norm_exp_mid;
assign norm_frac = (data[30:23] == 8'h0) ? (data[22:0] << shift_number) : {1'b1, data[22:0]};

assign index = norm_frac[22:16];
assign data_out =  {norm_frac[15:0], 3'b0};

endmodule

