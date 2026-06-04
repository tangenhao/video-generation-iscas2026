module unpack_mul(
  data,
  mode,
  sign, exp, frac, 
  zero, inf, nan
);

input       [15:0] data;
input       [1:0]  mode;
output wire        sign;
output wire [7:0]  exp;
output wire [10:0] frac;
output wire        zero;
output wire        inf;
output wire        nan;

wire unpack_float;
wire unpack_int4;
wire unpack_int8;
wire unnorm;

wire       sign_float;
wire [7:0] exp_float;
wire [9:0] frac_float;

wire        sign_int4;
wire [7:0]  exp_int4;
wire [10:0] frac_int4;
wire [3:0]  true_form_int4;
wire [10:0] true_form_int4_shifted;
wire [1:0]  lzd_int4;

wire        sign_int8;
wire [7:0]  exp_int8;
wire [10:0] frac_int8;
wire [7:0]  true_form_int8;
wire [10:0] true_form_int8_shifted;
wire [2:0]  lzd_int8;

assign unpack_float = mode[1];
assign sign_float = data[15];
assign exp_float = mode[0] ? {data[14:7]} : {3'b000, data[14:10]};
assign frac_float = mode[0] ? {data[6:0], 3'b000} : data[9:0];
assign unnorm = mode[0] ? (~(|data[14:7])) : (~(|data[14:10]));
assign zero = unpack_float ? (~(|data[14:0])) : (~(|data));
assign inf = unpack_float ? mode[0] ? (&data[14:7]) & (~(|data[6:0])) : (&data[14:10]) & (~(|data[9:0])) : 'd0;
assign nan = unpack_float ? mode[0] ? (&data[14:7]) & (|data[6:0]) : (&data[14:10]) & (|data[9:0]) : 'd0;

assign unpack_int4 = (!mode[1]) & (!mode[0]);
assign sign_int4 = data[3];
assign true_form_int4 = sign_int4 ? 8 - data[2:0] : data[2:0];
assign exp_int4 = (~(|data)) ? 8'h00 : (data[3] & (~(|data[2:0]))) ? 8'h12 : 18 - lzd_int4;
assign frac_int4 = (~(|data)) ? 11'h0 : (data[3] & (~(|data[2:0]))) ? 11'h400 : true_form_int4_shifted;

assign unpack_int8 = (!mode[1]) & mode[0];
assign sign_int8 = data[7];
assign true_form_int8 = sign_int8 ? 128 - data[6:0] : data[6:0];
assign exp_int8 = (~(|data)) ? 8'h00 : (data[7] & (~(|data[6:0]))) ? 8'h16 : 22 - lzd_int8;
assign frac_int8 = (~(|data)) ? 11'h0 : (data[7] & (~(|data[6:0]))) ? 11'h400 : true_form_int8_shifted;

assign sign = unpack_float ? sign_float : unpack_int4 ? sign_int4 : sign_int8;
assign exp = unpack_float ? unnorm ? 1'b1 : (inf | nan) ? 8'hff : exp_float : unpack_int4 ? exp_int4 : exp_int8;
assign frac = unpack_float ? unnorm ? frac_float : inf ? 11'b0 : {1'b1, frac_float} : unpack_int4 ? frac_int4 : frac_int8;

lzd4 u_lzd_int4(
  .data ( true_form_int4 ),
  .zcnt ( lzd_int4       ),
  .full (                )
);

lzd8 u_lzd_int8(
  .data ( true_form_int8 ),
  .zcnt ( lzd_int8       ),
  .full (                )
);

shifter_true_form_int4 u_shifter_true_from_int4(
  .data(true_form_int4),
  .shift(lzd_int4),
  .o(true_form_int4_shifted)
);

shifter_true_form_int8 u_shifter_true_from_int8(
  .data  ( true_form_int8         ),
  .shift ( lzd_int8               ),
  .o     ( true_form_int8_shifted )
);

endmodule