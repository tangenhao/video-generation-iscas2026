module data_move_ifmapmask(
  in, out,
  mode,
  type_a, outlier_enable,
  weight_1_ifmap_4_identifier,
  weight_1_ifmap_2_identifier
);

parameter IFMAPMASK_WIDTH = 128;

localparam TYPE_IS_INT4      = 0;
localparam TYPE_IS_INT8      = 1;
localparam WEIGHT_NO_MOVE    = 0;
localparam WEIGHT_MOVE_8TO16 = 1;
localparam WEIGHT_MOVE_4TO16 = 2;
localparam WEIGHT_MOVE_4TO8  = 3;
localparam WEIGHT_MOVE_4NTO8 = 4;

input      [IFMAPMASK_WIDTH-1:0] in;
input      [2:0]                 mode;
input      [1:0]                 type_a;
input                            outlier_enable;
input      [1:0]                 weight_1_ifmap_4_identifier;
input                            weight_1_ifmap_2_identifier;
output reg [IFMAPMASK_WIDTH-1:0] out;

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
        out = {{IFMAPMASK_WIDTH*3/4{1'b0}}, in[IFMAPMASK_WIDTH/2-1:IFMAPMASK_WIDTH/4]};
      end
      else begin
        out = {{IFMAPMASK_WIDTH*3/4{1'b0}}, in[IFMAPMASK_WIDTH/4-1:0]};
      end
    end
    WEIGHT_MOVE_4TO16 : begin
      if (weight_16_4_identifier == 2'b00) begin
        out = {{IFMAPMASK_WIDTH*3/4{1'b0}}, in[IFMAPMASK_WIDTH/4-1:0]};
      end 
      else if (weight_16_4_identifier == 2'b01) begin
        out = {{IFMAPMASK_WIDTH*3/4{1'b0}}, in[IFMAPMASK_WIDTH/2-1:IFMAPMASK_WIDTH/4]};
      end 
      else if (weight_16_4_identifier == 2'b10) begin
        out = {{IFMAPMASK_WIDTH*3/4{1'b0}}, in[IFMAPMASK_WIDTH*3/4-1:IFMAPMASK_WIDTH/2]};
      end 
      else begin
        out = {{IFMAPMASK_WIDTH*3/4{1'b0}}, in[IFMAPMASK_WIDTH-1:IFMAPMASK_WIDTH*3/4]};
      end 
    end
    WEIGHT_MOVE_4TO8 : begin
      if (weight_8_4_identifier) begin
        out = {{IFMAPMASK_WIDTH/2{1'b0}}, in[IFMAPMASK_WIDTH-1:IFMAPMASK_WIDTH/2]};
      end 
      else begin
        out = {{IFMAPMASK_WIDTH/2{1'b0}}, in[IFMAPMASK_WIDTH/2-1:0]};
      end 
    end
    WEIGHT_MOVE_4NTO8 : begin
      if (weight_8_4n_identifier) begin
        out = {{IFMAPMASK_WIDTH/2{1'b0}}, in[IFMAPMASK_WIDTH-1:IFMAPMASK_WIDTH/2]};
      end 
      else begin
        out = {{IFMAPMASK_WIDTH/2{1'b0}}, in[IFMAPMASK_WIDTH/2-1:0]};
      end 
    end
    default : begin
      out = in;
    end
  endcase
end


endmodule