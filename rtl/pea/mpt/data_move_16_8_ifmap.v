module data_move_16_8_ifmap(
  in, out, identifier
);

parameter IFMAP_WIDTH = 256;

input  [IFMAP_WIDTH*2-1:0] in;
output [IFMAP_WIDTH*2-1:0] out;

input identifier;

wire [IFMAP_WIDTH*2-1:0] out;
wire [IFMAP_WIDTH/2-1:0] in_0;
wire [IFMAP_WIDTH/2-1:0] in_1;

assign in_0 = identifier ? in[IFMAP_WIDTH-1:IFMAP_WIDTH/2] : in[IFMAP_WIDTH/2-1:0];
assign in_1 = identifier ? in[IFMAP_WIDTH*2-1:IFMAP_WIDTH+IFMAP_WIDTH/2] : in[IFMAP_WIDTH+IFMAP_WIDTH/2-1:IFMAP_WIDTH];

data_move_16_8 u_data_move_16_8_0(
  .en  ( 1'b1                 ),
  .in  ( in_0                 ),
  .out ( out[IFMAP_WIDTH-1:0] )
);

data_move_16_8 u_data_move_16_8_1(
  .en  ( 1'b1                             ),
  .in  ( in_1                             ),
  .out ( out[IFMAP_WIDTH*2-1:IFMAP_WIDTH] )
);

endmodule
