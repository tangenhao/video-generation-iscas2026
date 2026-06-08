module data_move_weight(
  in, out,
  mode,
  type_a, outlier_enable,
  weight_1_ifmap_4_identifier,
  weight_1_ifmap_2_identifier
);

parameter WEIGHT_WIDTH = 256;

localparam TYPE_IS_INT4      = 0;
localparam TYPE_IS_INT8      = 1;
localparam WEIGHT_NO_MOVE    = 0;
localparam WEIGHT_MOVE_8TO16 = 1;
localparam WEIGHT_MOVE_4TO16 = 2;
localparam WEIGHT_MOVE_4TO8  = 3;
localparam WEIGHT_MOVE_4NTO8 = 4;

input      [WEIGHT_WIDTH-1:0] in;
input      [2:0]              mode;
input      [2:0]              type_a;
input                         outlier_enable;
input      [1:0]              weight_1_ifmap_4_identifier;
input                         weight_1_ifmap_2_identifier;
output reg [WEIGHT_WIDTH-1:0] out;

reg [WEIGHT_WIDTH/2-1:0] in_16_8;
reg [WEIGHT_WIDTH/2-1:0] in_8_4;
reg [WEIGHT_WIDTH/4-1:0] in_16_4;
reg [WEIGHT_WIDTH/2-1:0] in_8_4n;

wire [WEIGHT_WIDTH-1:0] out_16_8;
wire [WEIGHT_WIDTH-1:0] out_8_4;
wire [WEIGHT_WIDTH-1:0] out_16_4;
wire [WEIGHT_WIDTH-1:0] out_16_4n;
wire [WEIGHT_WIDTH-1:0] out_8_4n;

reg       weight_16_8_identifier;
reg [1:0] weight_16_4_identifier; 
reg       weight_8_4_identifier;
reg       weight_8_4n_identifier;

always @(*) begin
  case(mode)
    WEIGHT_MOVE_8TO16 : begin
      weight_16_8_identifier = weight_1_ifmap_2_identifier;
      weight_16_4_identifier = 0;
      weight_8_4_identifier  = 0;
      weight_8_4n_identifier = 0;
    end
    WEIGHT_MOVE_4TO16 : begin
      weight_16_4_identifier = weight_1_ifmap_4_identifier;
      weight_16_8_identifier = 0;
      weight_8_4_identifier  = 0;
      weight_8_4n_identifier = 0;
    end
    WEIGHT_MOVE_4TO8 : begin
      if (type_a == TYPE_IS_INT4 && outlier_enable) begin
        weight_8_4_identifier = weight_1_ifmap_4_identifier[0];
      end
      else if (type_a == TYPE_IS_INT8 && outlier_enable) begin
        weight_8_4_identifier = weight_1_ifmap_4_identifier[1];
      end
      else begin
        weight_8_4_identifier = weight_1_ifmap_2_identifier;
      end
      weight_16_8_identifier = 0;
      weight_16_4_identifier = 0;
      weight_8_4n_identifier = 0;
    end
    WEIGHT_MOVE_4NTO8 : begin
      if (type_a == TYPE_IS_INT4 && outlier_enable) begin
        weight_8_4n_identifier = weight_1_ifmap_4_identifier[0];
      end
      else if (type_a == TYPE_IS_INT8 && outlier_enable) begin
        weight_8_4n_identifier = weight_1_ifmap_4_identifier[1];
      end
      else begin
        weight_8_4n_identifier = weight_1_ifmap_2_identifier;
      end
      weight_16_8_identifier = 0;
      weight_16_4_identifier = 0;
      weight_8_4_identifier  = 0;
    end
    default : begin
      weight_16_8_identifier = 0;
      weight_16_4_identifier = 0;
      weight_8_4_identifier  = 0;
      weight_8_4n_identifier = 0;
    end
  endcase
end

always @(*) begin
  case(mode)
    WEIGHT_MOVE_8TO16 : begin
      if (weight_16_8_identifier) begin
        in_16_8 = in[WEIGHT_WIDTH-1:WEIGHT_WIDTH/2];
      end 
      else begin
        in_16_8 = in[WEIGHT_WIDTH/2-1:0];
      end
      in_16_4 = 0;
      in_8_4  = 0;
      in_8_4n = 0;
    end
    WEIGHT_MOVE_4TO16 : begin
      if (weight_16_4_identifier == 2'b00) begin
        in_16_4 = in[WEIGHT_WIDTH/4-1:0];
      end 
      else if (weight_16_4_identifier == 2'b01) begin
        in_16_4 = in[WEIGHT_WIDTH/2-1:WEIGHT_WIDTH/4];
      end 
      else if (weight_16_4_identifier == 2'b10) begin
        in_16_4 = in[WEIGHT_WIDTH*3/4-1:WEIGHT_WIDTH/2];
      end 
      else begin
        in_16_4 = in[WEIGHT_WIDTH-1:WEIGHT_WIDTH*3/4];
      end
      in_16_8 = 0;
      in_8_4  = 0;
      in_8_4n = 0;
    end
    WEIGHT_MOVE_4TO8 : begin
      if (weight_8_4_identifier) begin
        in_8_4 = in[WEIGHT_WIDTH-1:WEIGHT_WIDTH/2];
      end 
      else begin
        in_8_4 = in[WEIGHT_WIDTH/2-1:0];
      end
      in_16_8 = 0;
      in_16_4 = 0;
      in_8_4n = 0;
    end
    WEIGHT_MOVE_4NTO8 : begin
      if (weight_8_4n_identifier) begin
        in_8_4n = in[WEIGHT_WIDTH-1:WEIGHT_WIDTH/2];
      end 
      else begin
        in_8_4n = in[WEIGHT_WIDTH/2-1:0];
      end
      in_16_8 = 0;
      in_16_4 = 0;
      in_8_4  = 0;
    end
    default : begin
      in_16_8 = 0;
      in_8_4  = 0;
      in_16_4 = 0;
      in_8_4n = 0;
    end
  endcase
end

data_move_16_8 u_data_move_16_8(
  .en  ( mode == WEIGHT_MOVE_8TO16 ),
  .in  ( in_16_8                   ),
  .out ( out_16_8                  )
);

data_move_16_4 u_data_move_16_4(
  .en  ( mode == WEIGHT_MOVE_4TO16 ),
  .in  ( in_16_4                   ),
  .out ( out_16_4                  )
);

data_move_8_4 u_data_move_8_4(
  .en  ( mode == WEIGHT_MOVE_4TO8 ),
  .in  ( in_8_4                   ),
  .out ( out_8_4                  )
);

data_move_8_4n u_data_move_8_4n(
  .en  ( mode == WEIGHT_MOVE_4NTO8 ),
  .in  ( in_8_4n        ),
  .out ( out_8_4n       )
);

always @(*) begin
  case(mode)
    WEIGHT_MOVE_8TO16 : out = out_16_8;
    WEIGHT_MOVE_4TO16 : out = out_16_4;
    WEIGHT_MOVE_4TO8  : out = out_8_4;
    WEIGHT_MOVE_4NTO8 : out = out_8_4n;
    default : out = in;
  endcase
end

endmodule