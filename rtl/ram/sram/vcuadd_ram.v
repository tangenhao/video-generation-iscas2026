module vcuadd_ram(
  clk, rst_n,

  rvalid_0, raddr_0, rdata_0,

  dma_wvalid, dma_waddr, dma_wdata
);

function integer clogb2 (input integer bit_depth);              
begin     
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end     
endfunction 

parameter WIDTH     = 512;
parameter ADDR_BITS = 9;

input                       clk;
input                       rst_n;

input                       rvalid_0;
input       [ADDR_BITS-1:0] raddr_0;
output reg  [WIDTH-1:0]     rdata_0;

input                       dma_wvalid;
input       [ADDR_BITS-1:0] dma_waddr;
input       [WIDTH-1:0]     dma_wdata;

wire                           ren;
wire [ADDR_BITS-1:0]           raddr;
wire [WIDTH-1:0]               rdata;
reg                            wen;
reg  [ADDR_BITS-1:0]           waddr;
reg  [WIDTH-1:0]               wdata;

reg                            ren_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wen     <= 'd0;
    waddr   <= 'd0;
    wdata   <= 'd0;
  end
  else begin
    wen     <= dma_wvalid;
    waddr   <= dma_waddr;
    wdata   <= dma_wdata;
  end
end

sram_512x144 u_ram_bank(
  .w_clk  ( clk           ),
  .w_en   ( wen           ),
  .w_addr ( waddr         ),
  .w_data ( wdata         ),
  .r_clk  ( clk           ),
  .r_en   ( ren           ),
  .r_addr ( raddr         ),
  .r_data ( rdata         )
);

assign ren   = rvalid_0;
assign raddr = raddr_0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ren_reg <= 1'b0;
  end
  else begin
    ren_reg <= ren;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rdata_0 <= 'd0;
  end
  else if (ren_reg) begin
    rdata_0 <= rdata;
  end
  else begin
    rdata_0 <= rdata_0;
  end
end

endmodule
