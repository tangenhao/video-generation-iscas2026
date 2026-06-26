module weight_ram(
  clk, rst_n,

  rvalid_0, raddr_0, rdata_0,

  dma_wvalid,    dma_wdata,
  dma_wvalid_1,  dma_wdata_1,
  dma_wvalid_2,  dma_wdata_2,
  dma_wvalid_3,  dma_wdata_3,
  dma_wvalid_4,  dma_wdata_4,
  dma_wvalid_5,  dma_wdata_5,
  dma_wvalid_6,  dma_wdata_6,
  dma_wvalid_7,  dma_wdata_7
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

parameter WIDTH     = 288;
parameter ADDR_BITS = 14;
parameter BANK      = 36;
parameter DEPTH     = 128;

input                        clk;
input                        rst_n;
 
input                        rvalid_0;
input       [ADDR_BITS-1:0]  raddr_0;
output wire [WIDTH*BANK-1:0] rdata_0;
 
input                        dma_wvalid;
input       [WIDTH-1:0]      dma_wdata;

input                        dma_wvalid_1;
input       [WIDTH-1:0]      dma_wdata_1;

input                        dma_wvalid_2;
input       [WIDTH-1:0]      dma_wdata_2;

input                        dma_wvalid_3;
input       [WIDTH-1:0]      dma_wdata_3;

input                        dma_wvalid_4;
input       [WIDTH-1:0]      dma_wdata_4;

input                        dma_wvalid_5;
input       [WIDTH-1:0]      dma_wdata_5;

input                        dma_wvalid_6;
input       [WIDTH-1:0]      dma_wdata_6;

input                        dma_wvalid_7;
input       [WIDTH-1:0]      dma_wdata_7;

localparam BANK_DIV_4 = BANK >> 2;

wire [WIDTH*BANK_DIV_4-1:0] rdata_2dma_0;
wire [WIDTH*BANK_DIV_4-1:0] rdata_2dma_1;
wire [WIDTH*BANK_DIV_4-1:0] rdata_2dma_2;
wire [WIDTH*BANK_DIV_4-1:0] rdata_2dma_3;

weight_ram_1dma #(
  .WIDTH     ( WIDTH      ),
  .ADDR_BITS ( ADDR_BITS  ),
  .BANK      ( BANK_DIV_4 ),
  .DEPTH     ( DEPTH      )
) u_weight_ram_1dma_0(
  .clk          ( clk          ),
  .rst_n        ( rst_n        ),

  .rvalid_0     ( rvalid_0     ),
  .raddr_0      ( raddr_0      ),
  .rdata        ( rdata_2dma_0 ),

  .dma_wvalid_0 ( dma_wvalid_1 ),
  .dma_wdata_0  ( dma_wdata_1  )
);

weight_ram_1dma #(
  .WIDTH     ( WIDTH      ),
  .ADDR_BITS ( ADDR_BITS  ),
  .BANK      ( BANK_DIV_4 ),
  .DEPTH     ( DEPTH      )
) u_weight_ram_1dma_1(
  .clk          ( clk          ),
  .rst_n        ( rst_n        ),

  .rvalid_0     ( rvalid_0     ),
  .raddr_0      ( raddr_0      ),
  .rdata        ( rdata_2dma_1 ),

  .dma_wvalid_0 ( dma_wvalid_3 ),
  .dma_wdata_0  ( dma_wdata_3  )
);

weight_ram_1dma #(
  .WIDTH     ( WIDTH      ),
  .ADDR_BITS ( ADDR_BITS  ),
  .BANK      ( BANK_DIV_4 ),
  .DEPTH     ( DEPTH      )
) u_weight_ram_1dma_2(
  .clk          ( clk          ),
  .rst_n        ( rst_n        ),

  .rvalid_0     ( rvalid_0     ),
  .raddr_0      ( raddr_0      ),
  .rdata        ( rdata_2dma_2 ),

  .dma_wvalid_0 ( dma_wvalid_5 ),
  .dma_wdata_0  ( dma_wdata_5  )
);

weight_ram_1dma #(
  .WIDTH     ( WIDTH      ),
  .ADDR_BITS ( ADDR_BITS  ),
  .BANK      ( BANK_DIV_4 ),
  .DEPTH     ( DEPTH      )
) u_weight_ram_1dma_3(
  .clk          ( clk          ),
  .rst_n        ( rst_n        ),

  .rvalid_0     ( rvalid_0     ),
  .raddr_0      ( raddr_0      ),
  .rdata        ( rdata_2dma_3 ),

  .dma_wvalid_0 ( dma_wvalid_7 ),
  .dma_wdata_0  ( dma_wdata_7  )
);

assign rdata_0 = {rdata_2dma_3, rdata_2dma_2, rdata_2dma_1, rdata_2dma_0};

endmodule
