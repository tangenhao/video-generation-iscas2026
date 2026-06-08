
module sincos_pre(
  data, opcode, 
  index, data_out, neg_quadrant, quad, in_fraction_zero_sign
);

input       [31:0] data;
input       [5:0]  opcode;
output wire [6:0]  index;
output wire [18:0] data_out;
output wire        neg_quadrant;
output wire [1:0]  quad;
output wire        in_fraction_zero_sign;

// wire   [31:0]  para_16divpi;
wire   [23:0]  frac;
wire   [7:0]   shift_number;
wire   [31:0]  norm_frac;
wire   [25:0]  in_fraction;

localparam SIN = 6'b001000;
localparam COS = 6'b001001;

// assign para_16divpi = 32'h40A2F983;
// assign frac = (data[30:23] == 8'b0) ? {1'b0, data[22:0]} : {1'b1, data[22:0]};
assign frac =  ( {24{~(|data[30:23])}} &  {1'b0, data[22:0]} ) | ( {24{(|data[30:23])}} &  {1'b1, data[22:0]} ) ;

// assign shift_number = (data[30:23] > 8'h7F) ? (data[30:23] - 8'h7F) : (8'h7F - data[30:23]);
assign shift_number = ( {8{data[30]}} &  (data[30:23] - 8'h7F) ) |  ( {8{~data[30]}} &   (8'h7F - data[30:23]) );

// assign norm_frac = (data[30:23] > 8'h7F) ? ( {8'b0,frac} << shift_number) : ({8'b0,frac} >> shift_number);
assign norm_frac = ( {32{data[30]}} &  ( {8'b0,frac} << shift_number) ) |    ( {32{~data[30]}} & ({8'b0,frac} >> shift_number) ) ;

// assign quad = (opcode == 6'b000111) ? norm_frac[27:26] : (norm_frac[27:26] + 1);
assign quad =  ( {2{(opcode == SIN)}} & norm_frac[27:26] )  |  ( {2{~(opcode == SIN)}} & (norm_frac[27:26] + 1) );

// assign in_fraction_zero_sign = (norm_frac[25:0] == 26'b0) ? 1'b1 : 1'b0;
assign in_fraction_zero_sign =  ~(|norm_frac[25:0] ) ;

// assign in_fraction =  quad[0] ? ((~norm_frac[25:0]) + 1) : norm_frac[25:0];
assign in_fraction =  ( {26{quad[0]}} & ((~norm_frac[25:0]) + 1) )  |   ( {26{~quad[0]}} & norm_frac[25:0] );

assign index = in_fraction[25:19];
assign data_out = in_fraction[18:0];
assign neg_quadrant = quad[1];
  
endmodule

