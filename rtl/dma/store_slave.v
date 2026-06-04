module store_slave(
  axi4_clk, axi4_rst_n,
  axi4_full_S_AXI_AWID, axi4_full_S_AXI_AWADDR, axi4_full_S_AXI_AWLEN,
  axi4_full_S_AXI_AWSIZE, axi4_full_S_AXI_AWBURST, axi4_full_S_AXI_AWLOCK, axi4_full_S_AXI_AWCACHE, axi4_full_S_AXI_AWPROT, axi4_full_S_AXI_AWQOS, axi4_full_S_AXI_AWUSER,
  axi4_full_S_AXI_AWVALID, axi4_full_S_AXI_AWREADY,
  axi4_full_S_AXI_WDATA, axi4_full_S_AXI_WSTRB, axi4_full_S_AXI_WLAST, axi4_full_S_AXI_WUSER, axi4_full_S_AXI_WVALID, axi4_full_S_AXI_WREADY,
  axi4_full_S_AXI_BID, axi4_full_S_AXI_BRESP, axi4_full_S_AXI_BUSER, axi4_full_S_AXI_BVALID, axi4_full_S_AXI_BREADY, 

  clk, fifo_rst_n, logic_rst_n,
  sram_waddr, sram_wvalid, sram_wready, sram_wdata
);


parameter PERI_ADDR_WIDTH    = 32;
parameter PERI_BUSRSTS_WIDTH = 8;
parameter PERI_DATA_WIDTH    = 256;

parameter AXI_S_AXI_ID_WIDTH    = 20;
parameter AXI_S_AXI_ADDR_WIDTH  = 64;
parameter AXI_S_AXI_USER_WIDTH  = 1;
parameter AXI_S_AXI_DATA_WIDTH  = 256;
parameter AXI_S_AXI_BURSTLENGTH = 32;
parameter AXI_OUTSTANDING_DEPTH = 128;
localparam integer AXI_S_AXI_DATA_BYTES = AXI_S_AXI_DATA_WIDTH / 8;

input                                  axi4_clk;
input                                  axi4_rst_n;
input       [AXI_S_AXI_ID_WIDTH-1:0]   axi4_full_S_AXI_AWID;
input       [AXI_S_AXI_ADDR_WIDTH-1:0] axi4_full_S_AXI_AWADDR;
input       [7:0]                      axi4_full_S_AXI_AWLEN;
input       [2:0]                      axi4_full_S_AXI_AWSIZE;
input       [1:0]                      axi4_full_S_AXI_AWBURST;
input                                  axi4_full_S_AXI_AWLOCK;
input       [3:0]                      axi4_full_S_AXI_AWCACHE;
input       [2:0]                      axi4_full_S_AXI_AWPROT;
input       [3:0]                      axi4_full_S_AXI_AWQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0] axi4_full_S_AXI_AWUSER;
input                                  axi4_full_S_AXI_AWVALID;
output wire                            axi4_full_S_AXI_AWREADY;
input       [AXI_S_AXI_DATA_WIDTH-1:0] axi4_full_S_AXI_WDATA;
input       [AXI_S_AXI_DATA_BYTES-1:0] axi4_full_S_AXI_WSTRB;
input                                  axi4_full_S_AXI_WLAST;
input       [AXI_S_AXI_USER_WIDTH-1:0] axi4_full_S_AXI_WUSER;
input                                  axi4_full_S_AXI_WVALID;
output wire                            axi4_full_S_AXI_WREADY;
output wire [AXI_S_AXI_ID_WIDTH-1:0]   axi4_full_S_AXI_BID;
output wire [1:0]                      axi4_full_S_AXI_BRESP;
output wire [AXI_S_AXI_USER_WIDTH-1:0] axi4_full_S_AXI_BUSER;
output wire                            axi4_full_S_AXI_BVALID;
input                                  axi4_full_S_AXI_BREADY;

input                             clk;
input                             fifo_rst_n;
input                             logic_rst_n;
output wire [31:0]                sram_waddr;
output wire                       sram_wvalid;
input                             sram_wready;
output wire [31:0]                sram_wdata;


wire [PERI_ADDR_WIDTH-1:0]    waddr_S_fifo_addr;
wire [PERI_BUSRSTS_WIDTH-1:0] waddr_S_fifo_len;
wire                          waddr_S_fifo_ready;
wire                          waddr_S_fifo_valid;
wire [PERI_DATA_WIDTH-1:0]    wdata_S_fifo_data;
wire                          wdata_S_fifo_valid;
wire                          wdata_S_fifo_ready;

wire [PERI_ADDR_WIDTH-1:0]    peripheral_S_waddr;
wire [PERI_BUSRSTS_WIDTH-1:0] peripheral_S_wlen;
wire                          peripheral_S_waddr_valid;
wire                          peripheral_S_waddr_ready;
wire [PERI_DATA_WIDTH-1:0]    peripheral_S_wdata;
wire                          peripheral_S_wdata_valid;
wire                          peripheral_S_wdata_ready;


axi4_full_slave_write_interface #(
  .PERI_ADDR_WIDTH        ( PERI_ADDR_WIDTH        ),
  .PERI_BUSRSTS_WIDTH     ( PERI_BUSRSTS_WIDTH     ),
  .PERI_DATA_WIDTH        ( PERI_DATA_WIDTH        ), 
  .AXI_S_AXI_ID_WIDTH     ( AXI_S_AXI_ID_WIDTH     ),
  .AXI_S_AXI_ADDR_WIDTH   ( AXI_S_AXI_ADDR_WIDTH   ),
  .AXI_S_AXI_USER_WIDTH   ( AXI_S_AXI_USER_WIDTH   ),
  .AXI_S_AXI_DATA_WIDTH   ( AXI_S_AXI_DATA_WIDTH   ),
  .AXI_S_AXI_BURSTLENGTH  ( AXI_S_AXI_BURSTLENGTH  ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH  )
) u_axi4_full_slave_write_interface(
  .axi4_clk                ( axi4_clk                ),
  .axi4_rst_n              ( axi4_rst_n              ),
  .axi4_full_S_AXI_AWID    ( axi4_full_S_AXI_AWID    ),
  .axi4_full_S_AXI_AWADDR  ( axi4_full_S_AXI_AWADDR  ),
  .axi4_full_S_AXI_AWLEN   ( axi4_full_S_AXI_AWLEN   ),
  .axi4_full_S_AXI_AWSIZE  ( axi4_full_S_AXI_AWSIZE  ),
  .axi4_full_S_AXI_AWBURST ( axi4_full_S_AXI_AWBURST ),
  .axi4_full_S_AXI_AWLOCK  ( axi4_full_S_AXI_AWLOCK  ),
  .axi4_full_S_AXI_AWCACHE ( axi4_full_S_AXI_AWCACHE ),
  .axi4_full_S_AXI_AWPROT  ( axi4_full_S_AXI_AWPROT  ),
  .axi4_full_S_AXI_AWQOS   ( axi4_full_S_AXI_AWQOS   ),
  .axi4_full_S_AXI_AWUSER  ( axi4_full_S_AXI_AWUSER  ),
  .axi4_full_S_AXI_AWVALID ( axi4_full_S_AXI_AWVALID ),
  .axi4_full_S_AXI_WDATA   ( axi4_full_S_AXI_WDATA   ),
  .axi4_full_S_AXI_WSTRB   ( axi4_full_S_AXI_WSTRB   ),
  .axi4_full_S_AXI_WLAST   ( axi4_full_S_AXI_WLAST   ),
  .axi4_full_S_AXI_WUSER   ( axi4_full_S_AXI_WUSER   ),
  .axi4_full_S_AXI_WVALID  ( axi4_full_S_AXI_WVALID  ),
  .axi4_full_S_AXI_BREADY  ( axi4_full_S_AXI_BREADY  ),
  .waddr_S_fifo_addr       ( waddr_S_fifo_addr       ),
  .waddr_S_fifo_len        ( waddr_S_fifo_len        ),
  .waddr_S_fifo_valid      ( waddr_S_fifo_valid      ),
  .waddr_S_fifo_ready      ( waddr_S_fifo_ready      ),
  .wdata_S_fifo_data       ( wdata_S_fifo_data       ),
  .wdata_S_fifo_valid      ( wdata_S_fifo_valid      ),
  .wdata_S_fifo_ready      ( wdata_S_fifo_ready      ),
  .axi4_full_S_AXI_AWREADY ( axi4_full_S_AXI_AWREADY ),
  .axi4_full_S_AXI_WREADY  ( axi4_full_S_AXI_WREADY  ),
  .axi4_full_S_AXI_BID     ( axi4_full_S_AXI_BID     ),
  .axi4_full_S_AXI_BRESP   ( axi4_full_S_AXI_BRESP   ),
  .axi4_full_S_AXI_BUSER   ( axi4_full_S_AXI_BUSER   ),
  .axi4_full_S_AXI_BVALID  ( axi4_full_S_AXI_BVALID  )
);

axi4_w_addr_clk_bridge #(
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH )
) u_axi4_w_addr_clk_bridge(
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .waddr_S_fifo_addr        ( waddr_S_fifo_addr        ),
  .waddr_S_fifo_len         ( waddr_S_fifo_len         ),
  .waddr_S_fifo_valid       ( waddr_S_fifo_valid       ),
  .waddr_S_fifo_ready       ( waddr_S_fifo_ready       ),
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .peripheral_S_waddr       ( peripheral_S_waddr       ),
  .peripheral_S_wlen        ( peripheral_S_wlen        ),
  .peripheral_S_waddr_valid ( peripheral_S_waddr_valid ),
  .peripheral_S_waddr_ready ( peripheral_S_waddr_ready )
);


axi4_w_data_clk_bridge #(
  .PERI_DATA_WIDTH ( PERI_DATA_WIDTH )
) u_axi4_w_data_clk_bridge(
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .wdata_S_fifo_data        ( wdata_S_fifo_data        ),
  .wdata_S_fifo_valid       ( wdata_S_fifo_valid       ),
  .wdata_S_fifo_ready       ( wdata_S_fifo_ready       ), 
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .peripheral_S_wdata       ( peripheral_S_wdata       ),
  .peripheral_S_wdata_valid ( peripheral_S_wdata_valid ),
  .peripheral_S_wdata_ready ( peripheral_S_wdata_ready )
);


store_ed #(
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH ),
  .PERI_DATA_WIDTH    ( PERI_DATA_WIDTH    )
) u_store_ed(
  .clk                      ( clk                      ),
  .rst_n                    ( logic_rst_n              ),
  .peripheral_S_waddr       ( peripheral_S_waddr       ),
  .peripheral_S_wlen        ( peripheral_S_wlen        ),
  .peripheral_S_waddr_valid ( peripheral_S_waddr_valid ),
  .peripheral_S_wdata       ( peripheral_S_wdata       ),
  .peripheral_S_wdata_valid ( peripheral_S_wdata_valid ),
  .peripheral_S_waddr_ready ( peripheral_S_waddr_ready ),
  .peripheral_S_wdata_ready ( peripheral_S_wdata_ready ),
  .sram_write_addr          ( sram_waddr               ),
  .sram_write_valid         ( sram_wvalid              ),
  .sram_write_ready         ( sram_wready              ),
  .sram_write_data          ( sram_wdata               )
);

endmodule
