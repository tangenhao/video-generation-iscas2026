module vcucode_ram(
  clk, rst_n,

  vcucode_rvalid, vcucode_raddr, vcucode_rdata,
  vcucode_wvalid, vcucode_waddr, vcucode_wdata
);

input clk;
input rst_n;

input         vcucode_rvalid;
input  [6:0]  vcucode_raddr;
output [63:0] vcucode_rdata;

input        vcucode_wvalid;
input [6:0]  vcucode_waddr;
input [63:0] vcucode_wdata;

sram_64x128 u_sram_64x128 (
  .w_clk  ( clk            ),
  .w_en   ( vcucode_wvalid ),
  .w_addr ( vcucode_waddr  ),
  .w_data ( vcucode_wdata  ),
  .r_clk  ( clk            ),
  .r_en   ( vcucode_rvalid ),
  .r_addr ( vcucode_raddr  ),
  .r_data ( vcucode_rdata  )
);

endmodule