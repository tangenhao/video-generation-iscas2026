module vculut_ram_dispatch(
  clk, rst_n,
  
  dma_wvalid, dma_waddr, dma_wdata,

  wvalid_0, waddr_0, wdata_0,
  wvalid_1, waddr_1, wdata_1
);

input         clk;
input         rst_n;

input         dma_wvalid;
input  [9:0]  dma_waddr;
input  [63:0] dma_wdata;

output        wvalid_0;
output [8:0]  waddr_0;
output [63:0] wdata_0;

output        wvalid_1;
output [8:0]  waddr_1;
output [63:0] wdata_1;

assign wvalid_0 = dma_wvalid & (dma_waddr[9] == 1'b0);
assign waddr_0  = dma_waddr[8:0];
assign wdata_0  = dma_wdata;

assign wvalid_1 = dma_wvalid & (dma_waddr[9] == 1'b1);
assign waddr_1  = dma_waddr[8:0];
assign wdata_1  = dma_wdata;

endmodule