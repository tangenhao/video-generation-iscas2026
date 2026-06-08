module squarer(
	a, square_out
);

input       [18:0] a;
output wire [37:0] square_out;

wire [37:0] add1;
wire [37:0] add2;
wire [37:0] add3;
wire [37:0] add4;
wire [37:0] add5;
wire [37:0] add6;
wire [37:0] add7;
wire [37:0] add8;
wire [37:0] add9;
wire [37:0] add10;

wire [37:0] sum;

wire [37:0] carry;
wire [37:0] carry_multiply_2;

assign add1 = { a[18]&a[17], a[18]&(~a[17]), a[17]&a[16], a[17]&(~a[16]), a[16]&a[15], a[16]&(~a[15]), 
                a[15]&a[14], a[15]&(~a[14]), a[14]&a[13], a[14]&(~a[13]), a[13]&a[12], a[13]&(~a[12]), 
                a[12]&a[11], a[12]&(~a[11]), a[11]&a[10], a[11]&(~a[10]), a[10]&a[9],  a[10]&(~a[9]), 
                a[9]&a[8], a[9]&(~a[8]), a[8]&a[7], a[8]&(~a[7]), a[7]&a[6], a[7]&(~a[6]), 
                a[6]&a[5], a[6]&(~a[5]), a[5]&a[4], a[5]&(~a[4]), a[4]&a[3], a[4]&(~a[3]), 
                a[3]&a[2], a[3]&(~a[2]), a[2]&a[1], a[2]&(~a[1]), a[1]&a[0], a[1]&(~a[0]), 1'b0, a[0]};


assign add2 = { 2'b0, { 17{a[18]} } & a[16:0], { 16{a[0]} } & a[17:2] , 3'b0 };
assign add3 = { 4'b0, { 15{a[17]} } & a[15:1], { 14{a[1]} } & a[16:3] , 5'b0 };
assign add4 = { 6'b0, { 13{a[16]} } & a[14:2], { 12{a[2]} } & a[15:4] , 7'b0 };
assign add5 = { 8'b0, { 11{a[15]} } & a[13:3], { 10{a[3]} } & a[14:5] , 9'b0 };
assign add6 = { 10'b0, { 9{a[14]} } & a[12:4], { 8{a[4]} } & a[13:6] , 11'b0 };
assign add7 = { 12'b0, { 7{a[13]} } & a[11:5], { 6{a[5]} } & a[12:7] , 13'b0 };
assign add8 = { 14'b0, { 5{a[12]} } & a[10:6], { 4{a[6]} } & a[11:8] , 15'b0 };
assign add9 = { 16'b0, { 3{a[11]} } & a[9:7],  { 2{a[7]} } & a[10:9] , 17'b0 };
assign add10 = { 18'b0, a[10] & a[8],  19'b0 };

compressor_10_to_2 compressor_10_to_2_0(
	.a( add1 ),
	.b( add2 ),
	.c( add3 ),
	.d( add4 ),
	.e( add5 ),
	.f( add6 ),
	.g( add7 ),
	.h( add8 ),
	.i( add9 ),
	.j( add10 ),
	.sum( sum ),
	.cry( carry )
);

assign carry_multiply_2 = {carry[36:0],1'b0};
assign square_out = sum + carry_multiply_2 ;

// adder_38bit adder_38bit_0(
//   .a(sum), 
//   .b(carry_multiply_2),
//   .o(square_out)
// );

endmodule