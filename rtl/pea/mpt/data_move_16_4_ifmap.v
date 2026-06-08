module data_move_16_4_ifmap(
  in, out, identifier
);

parameter IFMAP_WIDTH = 256;

input  [IFMAP_WIDTH*2-1:0] in;
output [IFMAP_WIDTH*2-1:0] out;

input [1:0] identifier;

wire [IFMAP_WIDTH*2-1:0] out;
reg  [IFMAP_WIDTH/4-1:0] in_0;
reg  [IFMAP_WIDTH/4-1:0] in_1;

always @(*) begin
  case(identifier)
    2'b00 : begin
      in_0 = in[IFMAP_WIDTH/4-1:0];
      in_1 = in[IFMAP_WIDTH*5/4-1:IFMAP_WIDTH];
    end
    2'b01 : begin
      in_0 = in[IFMAP_WIDTH/2-1:IFMAP_WIDTH/4];
      in_1 = in[IFMAP_WIDTH*3/2-1:IFMAP_WIDTH*5/4];
    end
    2'b10 : begin
      in_0 = in[IFMAP_WIDTH*3/4-1:IFMAP_WIDTH/2];
      in_1 = in[IFMAP_WIDTH*7/4-1:IFMAP_WIDTH*3/2];
    end
    2'b11 : begin
      in_0 = in[IFMAP_WIDTH-1:IFMAP_WIDTH*3/4];
      in_1 = in[IFMAP_WIDTH*2-1:IFMAP_WIDTH*7/4];
    end
  endcase
end

data_move_16_4 u_data_move_16_4_0(
  .en  ( 1'b1                 ),
  .in  ( in_0                 ),
  .out ( out[IFMAP_WIDTH-1:0] )
);

data_move_16_4 u_data_move_16_4_1(
  .en  ( 1'b1                             ),
  .in  ( in_1                             ),
  .out ( out[IFMAP_WIDTH*2-1:IFMAP_WIDTH] )
);

endmodule