module dispatch_local_fifo
# (
  parameter width = 256,
  parameter depth = 128,
  parameter addr_bit = 7
)
(
  clk, rst_n,
  w_en, w_data,
  r_en, r_data,
  hfull, hempty,
  afull, aempty,
  full, empty,
  capacity
);

input clk, rst_n;
input w_en, r_en;
input [width-1:0] w_data;
output wire full, empty;
output wire afull, aempty;
output wire hfull, hempty;
output wire [width-1:0] r_data;
output wire [addr_bit:0] capacity;

wire wenc;
wire renc;
reg [addr_bit-1:0] waddr;
reg [addr_bit-1:0] raddr;
reg [addr_bit:0] avail_cout;

wire almost_full, almost_empty;

assign hfull = (avail_cout <= (depth>>1))? 1'b1: 1'b0;
assign almost_full = (avail_cout <= 'd2)? 1'b1: 1'b0;
assign full = (avail_cout == 'd0)? 1'b1: 1'b0;
assign afull = almost_full | full;
assign hempty = (| avail_cout[addr_bit:addr_bit-1])? 1'b1: 1'b0;
assign almost_empty = (avail_cout >= (depth - 'd2))? 1'b1: 1'b0;
assign empty = (avail_cout == depth)? 1'b1: 1'b0;
assign aempty = almost_empty | empty;
assign capacity = avail_cout;

assign wenc = w_en && !full;
assign renc = r_en && !empty;

sram_256x128 u_sram_256x128 (
  .w_clk  ( clk    ),
  .w_en   ( wenc   ),
  .w_data ( w_data ),
  .w_addr ( waddr  ),
  .r_clk  ( clk    ),
  .r_en   ( renc   ),
  .r_data ( r_data ),
  .r_addr ( raddr  )
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    waddr <= 'd0;
  end
  else begin
    if (wenc) begin
      waddr <= waddr + 1'b1;
    end
    else begin
      waddr <= waddr;
    end
  end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    raddr <= 'd0;
  end
  else begin
    if (renc) begin
      raddr <= raddr + 1'b1;
    end
    else begin
      raddr <= raddr;
    end
  end
end

always@(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    avail_cout <= depth;
  end
  else begin
    case({wenc, renc})
      2'b11: begin
        avail_cout <= avail_cout;
      end
      2'b10: begin
        avail_cout <= avail_cout - 1;
      end
      2'b01: begin
        avail_cout <= avail_cout + 1;
      end
      default: begin
        avail_cout <= avail_cout;
      end
    endcase
  end
end

endmodule
