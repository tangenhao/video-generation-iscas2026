module data_move_ifmap(
  in, mode,
  type_b, outlier_enable, sparse_enable,
  weight_1_ifmap_2_identifier,
  weight_1_ifmap_4_identifier,
  weight_2_ifmap_2_identifier,
  weight_2_ifmap_4_cross_ic,
  weight_4_ifmap_4_identifier,
  out
);

parameter IFMAP_WIDTH         = 256;
parameter OUTLIER_INDEX_WIDTH = 64;

localparam TYPE_IS_INT4     = 0;
localparam TYPE_IS_INT8     = 1;
localparam IFMAP_NO_MOVE    = 0;
localparam IFMAP_MOVE_8TO16 = 1;
localparam IFMAP_MOVE_4TO16 = 2;
localparam IFMAP_MOVE_4TO8  = 3;
localparam IFMAP_MOVE_4NTO8 = 4;

input      [IFMAP_WIDTH*2-1:0] in;
input      [2:0]               mode;
input      [2:0]               type_b;
input                          outlier_enable;
input                          sparse_enable;
input                          weight_1_ifmap_2_identifier;
input      [1:0]               weight_1_ifmap_4_identifier;
input                          weight_2_ifmap_2_identifier;
input                          weight_2_ifmap_4_cross_ic;
input      [1:0]               weight_4_ifmap_4_identifier;
output reg [IFMAP_WIDTH*2-1:0] out;

reg [IFMAP_WIDTH*2-1:0] in_16_8;
reg [IFMAP_WIDTH*2-1:0] in_16_4;
reg [IFMAP_WIDTH*2-1:0] in_8_4;
reg [IFMAP_WIDTH*2-1:0] in_8_4n;

wire [IFMAP_WIDTH*2-1:0] ifmap_local_rdata_16_8;
wire [IFMAP_WIDTH*2-1:0] ifmap_local_rdata_16_4;
wire [IFMAP_WIDTH*2-1:0] ifmap_local_rdata_8_4;
wire [IFMAP_WIDTH*2-1:0] ifmap_local_rdata_8_4n;

always @(*) begin
  case(mode)
    IFMAP_MOVE_8TO16 : begin
      in_16_8 = in;
      in_16_4 = 0;
      in_8_4  = 0;
      in_8_4n = 0;
    end
    IFMAP_MOVE_4TO16 : begin
      in_16_4 = in;
      in_16_8 = 0;
      in_8_4  = 0;
      in_8_4n = 0;
    end
    IFMAP_MOVE_4TO8 : begin
      in_8_4  = in;
      in_16_8 = 0;
      in_16_4 = 0;
      in_8_4n = 0;
    end
    IFMAP_MOVE_4NTO8 : begin
      in_8_4n = in;
      in_16_8 = 0;
      in_16_4 = 0;
      in_8_4  = 0;
    end
    default : begin
      in_16_8 = 0;
      in_16_4 = 0;
      in_8_4  = 0;
      in_8_4n = 0;
    end
  endcase
end

reg       ifmap_16_8_identifier;
reg [1:0] ifmap_16_4_identifier;
reg       ifmap_8_4_identifier;
reg       ifmap_8_4n_identifier;

always @(*) begin
  case(mode)
    IFMAP_MOVE_8TO16 : begin
      ifmap_16_8_identifier = weight_2_ifmap_2_identifier;
      ifmap_16_4_identifier = 0;
      ifmap_8_4_identifier  = 0;
      ifmap_8_4n_identifier = 0;
    end
    IFMAP_MOVE_4TO16 : begin
      ifmap_16_8_identifier = 0;
      ifmap_16_4_identifier = weight_4_ifmap_4_identifier;
      ifmap_8_4_identifier  = 0;
      ifmap_8_4n_identifier = 0;
    end
    IFMAP_MOVE_4TO8 : begin
      if (type_b == TYPE_IS_INT8 && outlier_enable) begin
        ifmap_8_4_identifier = weight_2_ifmap_4_cross_ic;
      end
      else if (type_b == TYPE_IS_INT8 && (!outlier_enable)) begin
        ifmap_8_4_identifier = weight_2_ifmap_2_identifier;
      end
      else if (type_b == TYPE_IS_INT4 && outlier_enable) begin
        ifmap_8_4_identifier = weight_1_ifmap_4_identifier[0];
      end
      else if (type_b == TYPE_IS_INT4 && (!outlier_enable)) begin
        ifmap_8_4_identifier = weight_1_ifmap_2_identifier;
      end
      else begin
        ifmap_8_4_identifier = 0;
      end
      ifmap_16_8_identifier = 0;
      ifmap_16_4_identifier = 0;
      ifmap_8_4n_identifier = 0;
    end
    IFMAP_MOVE_4NTO8 : begin
      if (type_b == TYPE_IS_INT8 && outlier_enable) begin
        ifmap_8_4n_identifier = weight_2_ifmap_4_cross_ic;
      end
      else if (type_b == TYPE_IS_INT8 && (!outlier_enable)) begin
        ifmap_8_4n_identifier = weight_2_ifmap_2_identifier;
      end
      else if (type_b == TYPE_IS_INT4 && outlier_enable) begin
        ifmap_8_4n_identifier = weight_1_ifmap_4_identifier[0];
      end
      else if (type_b == TYPE_IS_INT4 && (!outlier_enable)) begin
        ifmap_8_4n_identifier = weight_1_ifmap_2_identifier;
      end
      else begin
        ifmap_8_4n_identifier = 0;
      end
      ifmap_16_8_identifier = 0;
      ifmap_16_4_identifier = 0;
      ifmap_8_4_identifier  = 0;
    end
    default : begin
      ifmap_16_8_identifier = 0;
      ifmap_16_4_identifier = 0;
      ifmap_8_4_identifier  = 0;
      ifmap_8_4n_identifier = 0;
    end
  endcase
end

data_move_16_8_ifmap u_data_move_16_8_ifmap(
  .in         ( in_16_8                ),
  .out        ( ifmap_local_rdata_16_8 ),
  .identifier ( ifmap_16_8_identifier  )
);

data_move_16_4_ifmap u_data_move_16_4_ifmap(
  .in         ( in_16_4                ),
  .out        ( ifmap_local_rdata_16_4 ),
  .identifier ( ifmap_16_4_identifier  )
);

data_move_8_4_ifmap u_data_move_8_4_ifmap(
  .sparse_enable ( sparse_enable && type_b == TYPE_IS_INT4 ),
  .in            ( in_8_4                ),
  .out           ( ifmap_local_rdata_8_4 ),
  .identifier    ( ifmap_8_4_identifier  )
);

data_move_8_4n_ifmap u_data_move_8_4n_ifmap(
  .sparse_enable ( sparse_enable && type_b == TYPE_IS_INT4 ),
  .in            ( in_8_4n                ),
  .out           ( ifmap_local_rdata_8_4n ),
  .identifier    ( ifmap_8_4n_identifier  )
);

always @(*) begin
  case(mode)
    IFMAP_MOVE_8TO16 : out = ifmap_local_rdata_16_8;
    IFMAP_MOVE_4TO16 : out = ifmap_local_rdata_16_4;
    IFMAP_MOVE_4TO8  : out = ifmap_local_rdata_8_4;
    IFMAP_MOVE_4NTO8 : out = ifmap_local_rdata_8_4n;
    default : out = in;
  endcase
end

endmodule