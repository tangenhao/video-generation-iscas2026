module int2fp32(
  in_data, dtype_sel, out_data
);

input       [31:0] in_data;
input       [1:0]  dtype_sel;
output wire [31:0] out_data;

reg [31:0] data_origin;

always@(*)
begin
  case(dtype_sel)
    2'b00: data_origin = {{28{in_data[3]}}, in_data[3:0]};
    2'b01: data_origin = {{24{in_data[7]}}, in_data[7:0]};
    2'b10: data_origin = {{16{in_data[15]}}, in_data[15:0]};
    2'b11: data_origin = in_data;
    default: data_origin = 0;
  endcase
end

wire        sign;
wire [31:0] true_from_int;
wire [4:0]  zcnt;
wire        full;

assign sign = data_origin[31];
assign true_from_int = sign ? ((~data_origin) + 1) : data_origin;

lzd32 u_lzd32(
  .data ( true_from_int ),
  .zcnt ( zcnt          ),
  .full ( full          )
);

wire [31:0] shifted_int;
wire [22:0] unrounded_frac;
wire [7:0]  bits_after_frac;
wire [1:0]  plus_1_conditions;
wire [22:0] frac;
wire [7:0]  exp;
wire [30:0] exp_frac;

assign shifted_int = full ? 0 : (true_from_int << zcnt);
assign unrounded_frac = shifted_int[30 : 8];
assign bits_after_frac = shifted_int[7 : 0];
assign plus_1_conditions[0] = ((|bits_after_frac[6 : 0]) && bits_after_frac[7]) ? 1'b1 : 1'b0;
assign plus_1_conditions[1] = ((bits_after_frac == 8'b10000000) && unrounded_frac[0]) ? 1'b1 : 1'b0;
assign exp = full ? 0 : (31 - zcnt + 127);

assign exp_frac = {exp, unrounded_frac} + (|plus_1_conditions);

assign out_data = {sign, exp_frac};

endmodule