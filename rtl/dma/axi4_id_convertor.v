module axi_id_convertor(
  clk, rst_n,

  arvalid, arready, arid, virt_arid,
  awvalid, awready, awid, virt_awid,

  rvalid, rready, virt_rid, rid,
  bvalid, bready, virt_bid, bid
);

parameter IN_ID_WIDTH       = 10;
parameter OUT_ID_WIDTH      = 8;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction

input clk;
input rst_n;

input arvalid;
input arready;
input awvalid;
input awready;
input rvalid;
input rready;
input bvalid;
input bready;

input [IN_ID_WIDTH-1:0] arid;
input [IN_ID_WIDTH-1:0] awid;
input [OUT_ID_WIDTH-1:0] virt_rid;
input [OUT_ID_WIDTH-1:0] virt_bid;

output wire [OUT_ID_WIDTH-1:0] virt_arid;
output wire [OUT_ID_WIDTH-1:0] virt_awid;
output reg  [IN_ID_WIDTH-1:0] rid;
output reg  [IN_ID_WIDTH-1:0] bid;

reg [IN_ID_WIDTH-1:0] arid_reg[0:15];
reg [IN_ID_WIDTH-1:0] awid_reg[0:15];

reg [OUT_ID_WIDTH-1:0] rid_reg[0:15];
reg [OUT_ID_WIDTH-1:0] bid_reg[0:15];

reg [3:0] read_channel_ptr;
reg [3:0] write_channel_ptr;
wire [4:0] read_channel_offset;
wire [4:0] write_channel_offset;

assign read_channel_offset = read_channel_ptr + 1'b1;
assign write_channel_offset = write_channel_ptr + 1'b1;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    read_channel_ptr <= 0;
  end
  else begin
    if (arvalid && arready) begin
      read_channel_ptr <= read_channel_ptr + 1'b1;
    end
    else begin
      read_channel_ptr <= read_channel_ptr;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    write_channel_ptr <= 0;
  end
  else begin
    if (awvalid && awready) begin
      write_channel_ptr <= write_channel_ptr + 1'b1;
    end
    else begin
      write_channel_ptr <= write_channel_ptr;
    end
  end
end

integer r_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (r_i=0; r_i<16; r_i=r_i+1) begin
      arid_reg[r_i] <= 0;
      rid_reg[r_i] <= 0;
    end
  end
  else begin
    if (arvalid && arready) begin
      arid_reg[read_channel_ptr] <= arid;
      rid_reg[read_channel_ptr] <= {arid[OUT_ID_WIDTH-1:5], read_channel_offset};
    end
    else begin
      for (r_i=0; r_i<16; r_i=r_i+1) begin
        arid_reg[r_i] <= arid_reg[r_i];
        rid_reg[r_i] <= rid_reg[r_i];
      end
    end
  end
end

integer w_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (w_i=0; w_i<16; w_i=w_i+1) begin
      awid_reg[w_i] <= 0;
      bid_reg[w_i] <= 0;
    end
  end
  else begin
    if (awvalid && awready) begin
      awid_reg[write_channel_ptr] <= awid;
      bid_reg[write_channel_ptr] <= {awid[OUT_ID_WIDTH-1:5], write_channel_offset};
    end
    else begin
      for (w_i=0; w_i<16; w_i=w_i+1) begin
        awid_reg[w_i] <= awid_reg[w_i];
        bid_reg[w_i] <= bid_reg[w_i];
      end
    end
  end
end

assign virt_arid = {arid[OUT_ID_WIDTH-1:5], read_channel_offset};
assign virt_awid = {awid[OUT_ID_WIDTH-1:5], write_channel_offset};

wire [15:0] rid_hit;
wire [15:0] bid_hit;

genvar rid_compare_i;
generate
for (rid_compare_i=0; rid_compare_i<16; rid_compare_i=rid_compare_i+1) begin
  assign rid_hit[rid_compare_i] = (virt_rid == rid_reg[rid_compare_i]);
end
endgenerate

genvar bid_compare_i;
generate
for (bid_compare_i=0; bid_compare_i<16; bid_compare_i=bid_compare_i+1) begin
  assign bid_hit[bid_compare_i] = (virt_bid == bid_reg[bid_compare_i]);
end
endgenerate

always @(*) begin
  case(rid_hit)
    16'b1: rid = arid_reg[0];
    16'b10: rid = arid_reg[1];
    16'b100: rid = arid_reg[2];
    16'b1000: rid = arid_reg[3];
    16'b10000: rid = arid_reg[4];
    16'b100000: rid = arid_reg[5];
    16'b1000000: rid = arid_reg[6];
    16'b10000000: rid = arid_reg[7];
    16'b100000000: rid = arid_reg[8];
    16'b1000000000: rid = arid_reg[9];
    16'b10000000000: rid = arid_reg[10];
    16'b100000000000: rid = arid_reg[11];
    16'b1000000000000: rid = arid_reg[12];
    16'b10000000000000: rid = arid_reg[13];
    16'b100000000000000: rid = arid_reg[14];
    16'b1000000000000000: rid = arid_reg[15];
    default: rid = 0;
  endcase
end

always @(*) begin
  case(bid_hit)
    16'b1: bid = awid_reg[0];
    16'b10: bid = awid_reg[1];
    16'b100: bid = awid_reg[2];
    16'b1000: bid = awid_reg[3];
    16'b10000: bid = awid_reg[4];
    16'b100000: bid = awid_reg[5];
    16'b1000000: bid = awid_reg[6];
    16'b10000000: bid = awid_reg[7];
    16'b100000000: bid = awid_reg[8];
    16'b1000000000: bid = awid_reg[9];
    16'b10000000000: bid = awid_reg[10];
    16'b100000000000: bid = awid_reg[11];
    16'b1000000000000: bid = awid_reg[12];
    16'b10000000000000: bid = awid_reg[13];
    16'b100000000000000: bid = awid_reg[14];
    16'b1000000000000000: bid = awid_reg[15];
    default: bid = 0;
  endcase
end

endmodule