module data_move_8_4_ifmap(
  sparse_enable, in, out, identifier
);

parameter IFMAP_WIDTH = 256;

input                      sparse_enable;
input  [IFMAP_WIDTH*2-1:0] in;
output [IFMAP_WIDTH*2-1:0] out;

input identifier;

wire [IFMAP_WIDTH*2-1:0] out;
wire [IFMAP_WIDTH/2-1:0] in_0;
wire [IFMAP_WIDTH/2-1:0] in_1;

assign in_0 = sparse_enable ? identifier ? in[IFMAP_WIDTH+IFMAP_WIDTH/2-1:IFMAP_WIDTH] : in[IFMAP_WIDTH/2-1:0] :
                              identifier ? in[IFMAP_WIDTH-1:IFMAP_WIDTH/2] : in[IFMAP_WIDTH/2-1:0];
assign in_1 = sparse_enable ? identifier ? in[IFMAP_WIDTH*2-1:IFMAP_WIDTH+IFMAP_WIDTH/2] : in[IFMAP_WIDTH-1:IFMAP_WIDTH/2] :
                              identifier ? in[IFMAP_WIDTH*2-1:IFMAP_WIDTH+IFMAP_WIDTH/2] : in[IFMAP_WIDTH+IFMAP_WIDTH/2-1:IFMAP_WIDTH];

data_move_8_4 u_data_move_8_4_lower_0(
  .en  ( 1'b1                 ),
  .in  ( in_0                 ),
  .out ( out[IFMAP_WIDTH-1:0] )
);

data_move_8_4 u_data_move_8_4_lower_1(
  .en  ( 1'b1                             ),
  .in  ( in_1                             ),
  .out ( out[IFMAP_WIDTH*2-1:IFMAP_WIDTH] )
);

endmodule
