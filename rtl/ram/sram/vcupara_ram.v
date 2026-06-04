module vcupara_ram(
  clk, rst_n,
  
  rvalid_0, raddr_0, rdata_0,
  rvalid_1, raddr_1, rdata_1,

  dma_wvalid, dma_waddr, dma_wdata
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

parameter WIDTH     = 1024;
parameter ADDR_BITS = 6;
parameter BANK      = 2;

input                       clk;
input                       rst_n;

input                       rvalid_0;
input       [ADDR_BITS-1:0] raddr_0;
output wire [WIDTH-1:0]     rdata_0;

input                       rvalid_1;
input       [ADDR_BITS-1:0] raddr_1;
output wire [WIDTH-1:0]     rdata_1;

localparam BANK_BITS = clogb2(BANK)-1;

input                       dma_wvalid;
input       [ADDR_BITS:0]   dma_waddr;
input       [WIDTH-1:0]     dma_wdata;

wire                 wen[0:BANK-1];
wire [ADDR_BITS-1:0] waddr[0:BANK-1];
wire [WIDTH-1:0]     wdata[0:BANK-1];

genvar sram_i;
generate
  for (sram_i = 0; sram_i < 2; sram_i = sram_i + 1) begin : vcupara_sram_i
    assign wen[sram_i]   = dma_wvalid && (dma_waddr[ADDR_BITS] == sram_i);
    assign waddr[sram_i] = dma_waddr[ADDR_BITS-1:0];
    assign wdata[sram_i] = dma_wdata;
  end
endgenerate

sram_1024x64 u_ram_bank_0(
  .w_clk  ( clk      ),
  .w_en   ( wen[0]   ),
  .w_addr ( waddr[0] ),
  .w_data ( wdata[0] ),  
  .r_clk  ( clk      ),
  .r_en   ( rvalid_0 ),
  .r_addr ( raddr_0  ),
  .r_data ( rdata_0  )
);

sram_1024x64 u_ram_bank_1(
  .w_clk  ( clk      ),
  .w_en   ( wen[1]   ),
  .w_addr ( waddr[1] ),
  .w_data ( wdata[1] ),  
  .r_clk  ( clk      ),
  .r_en   ( rvalid_1 ),
  .r_addr ( raddr_1  ),
  .r_data ( rdata_1  )
);

endmodule
