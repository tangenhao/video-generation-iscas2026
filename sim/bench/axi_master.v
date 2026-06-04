module axi_master(
  axi4_clk, axi4_rst_n,

  axi4_full_M_AXI_ARID, axi4_full_M_AXI_ARADDR, axi4_full_M_AXI_ARLEN, 
  axi4_full_M_AXI_ARSIZE, axi4_full_M_AXI_ARBURST, axi4_full_M_AXI_ARLOCK, axi4_full_M_AXI_ARCACHE, axi4_full_M_AXI_ARPROT, axi4_full_M_AXI_ARQOS, axi4_full_M_AXI_ARUSER, 
  axi4_full_M_AXI_ARVALID, axi4_full_M_AXI_ARREADY,
  axi4_full_M_AXI_RID, axi4_full_M_AXI_RDATA, axi4_full_M_AXI_RRESP, axi4_full_M_AXI_RLAST, axi4_full_M_AXI_RUSER, axi4_full_M_AXI_RVALID, axi4_full_M_AXI_RREADY,

  axi4_full_M_AXI_AWID, axi4_full_M_AXI_AWADDR, axi4_full_M_AXI_AWLEN,
  axi4_full_M_AXI_AWSIZE, axi4_full_M_AXI_AWBURST, axi4_full_M_AXI_AWLOCK, axi4_full_M_AXI_AWCACHE, axi4_full_M_AXI_AWPROT, axi4_full_M_AXI_AWQOS, axi4_full_M_AXI_AWUSER,
  axi4_full_M_AXI_AWVALID, axi4_full_M_AXI_AWREADY,
  axi4_full_M_AXI_WDATA, axi4_full_M_AXI_WSTRB, axi4_full_M_AXI_WLAST, axi4_full_M_AXI_WUSER, axi4_full_M_AXI_WVALID, axi4_full_M_AXI_WREADY,
  axi4_full_M_AXI_BID, axi4_full_M_AXI_BRESP, axi4_full_M_AXI_BUSER, axi4_full_M_AXI_BVALID, axi4_full_M_AXI_BREADY,

  cmd, cmd_vld
);

parameter AXI_M_AXI_BURSTLENGTH  = 64;
parameter AXI_OUTSTANDING_DEPTH  = 8;

parameter AXI_M_AXI_ID_WIDTH   = 26;
parameter AXI_M_AXI_ADDR_WIDTH = 64;
parameter AXI_M_AXI_USER_WIDTH = 1;
parameter AXI_M_AXI_DATA_WIDTH = 256;

parameter PERI_ADDR_WIDTH    = 38;
parameter PERI_BUSRSTS_WIDTH = 22;
parameter PERI_DATA_WIDTH    = 256;
parameter AXI_M_AXI_MAX_4K     = 8;
localparam integer AXI_M_AXI_DATA_BYTES = AXI_M_AXI_DATA_WIDTH / 8;

localparam integer CMD_BITS = AXI_M_AXI_ADDR_WIDTH + 8 + 1 + AXI_M_AXI_DATA_WIDTH;

parameter AXI_AR_ID = 0;
parameter AXI_AW_ID = 0;

input                                          axi4_clk; 
input                                          axi4_rst_n;
output wire [AXI_M_AXI_ID_WIDTH-1:0]     axi4_full_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] axi4_full_M_AXI_AWADDR;
output wire [7:0]                              axi4_full_M_AXI_AWLEN;
output wire [2:0]                              axi4_full_M_AXI_AWSIZE;
output wire [1:0]                              axi4_full_M_AXI_AWBURST;
output wire                                    axi4_full_M_AXI_AWLOCK;
output wire [3:0]                              axi4_full_M_AXI_AWCACHE;
output wire [2:0]                              axi4_full_M_AXI_AWPROT;
output wire [3:0]                              axi4_full_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_AWUSER;
output wire                                    axi4_full_M_AXI_AWVALID;
input                                          axi4_full_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0]  axi4_full_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0]   axi4_full_M_AXI_WSTRB;
output wire                                    axi4_full_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  axi4_full_M_AXI_WUSER;
output wire                                    axi4_full_M_AXI_WVALID;
input                                          axi4_full_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]     axi4_full_M_AXI_BID;
input       [1:0]                              axi4_full_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0]  axi4_full_M_AXI_BUSER;
input                                          axi4_full_M_AXI_BVALID;
output wire                                    axi4_full_M_AXI_BREADY;
output wire [AXI_M_AXI_ID_WIDTH-1:0]     axi4_full_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] axi4_full_M_AXI_ARADDR;
output wire [7:0]                              axi4_full_M_AXI_ARLEN;
output wire [2:0]                              axi4_full_M_AXI_ARSIZE;
output wire [1:0]                              axi4_full_M_AXI_ARBURST;
output wire                                    axi4_full_M_AXI_ARLOCK;
output wire [3:0]                              axi4_full_M_AXI_ARCACHE;
output wire [2:0]                              axi4_full_M_AXI_ARPROT;
output wire [3:0]                              axi4_full_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_ARUSER;
output wire                                    axi4_full_M_AXI_ARVALID;
input                                          axi4_full_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]     axi4_full_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0]  axi4_full_M_AXI_RDATA;
input       [1:0]                              axi4_full_M_AXI_RRESP;
input                                          axi4_full_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0]  axi4_full_M_AXI_RUSER;
input                                          axi4_full_M_AXI_RVALID;
output wire                                    axi4_full_M_AXI_RREADY;
input       [CMD_BITS-1:0]                     cmd;
input                                          cmd_vld;

reg  [PERI_ADDR_WIDTH-1:0]    peripheral_M_raddr;
reg  [PERI_BUSRSTS_WIDTH-1:0] peripheral_M_rlen;
reg                                   peripheral_M_raddr_valid;
wire                                  peripheral_M_raddr_ready;
wire [PERI_DATA_WIDTH-1:0]    peripheral_M_rdata;
reg                                   peripheral_M_rdata_valid;
wire                                  peripheral_M_rdata_ready;

wire [PERI_ADDR_WIDTH-1:0]    raddr_M_fifo_addr;
wire [PERI_BUSRSTS_WIDTH-1:0] raddr_M_fifo_len;
wire                                  raddr_M_fifo_ready;
wire                                  raddr_M_fifo_valid;
wire [PERI_DATA_WIDTH-1:0]    rdata_M_fifo_data;
wire                                  rdata_M_fifo_valid;
wire                                  rdata_M_fifo_ready;

peripheral_r_addr_clk_bridge #(
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH ) 
) u_peripheral_r_addr_clk_bridge(
  .peripheral_clk           ( axi4_clk                 ),
  .peripheral_rst_n         ( axi4_rst_n               ),
  .peripheral_M_raddr       ( peripheral_M_raddr       ),
  .peripheral_M_rlen        ( peripheral_M_rlen        ),
  .peripheral_M_raddr_valid ( peripheral_M_raddr_valid ),
  .peripheral_M_raddr_ready ( peripheral_M_raddr_ready ),
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .raddr_M_fifo_valid       ( raddr_M_fifo_valid       ),
  .raddr_M_fifo_addr        ( raddr_M_fifo_addr        ),
  .raddr_M_fifo_len         ( raddr_M_fifo_len         ),
  .raddr_M_fifo_ready       ( raddr_M_fifo_ready       )
);


peripheral_r_data_clk_bridge #(
  .PERI_DATA_WIDTH(PERI_DATA_WIDTH)
) u_peripheral_r_data_clk_bridge(
  .peripheral_clk           ( axi4_clk                 ),
  .peripheral_rst_n         ( axi4_rst_n               ),
  .rdata_M_fifo_data        ( rdata_M_fifo_data        ),
  .rdata_M_fifo_valid       ( rdata_M_fifo_valid       ),
  .rdata_M_fifo_ready       ( rdata_M_fifo_ready       ),
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .peripheral_M_rdata       ( peripheral_M_rdata       ),
  .peripheral_M_rdata_valid ( peripheral_M_rdata_valid ),
  .peripheral_M_rdata_ready ( peripheral_M_rdata_ready )
);


axi4_full_master_read_interface #(
  .PERI_ADDR_WIDTH        ( PERI_ADDR_WIDTH        ),
  .PERI_BUSRSTS_WIDTH     ( PERI_BUSRSTS_WIDTH     ),
  .PERI_DATA_WIDTH        ( PERI_DATA_WIDTH        ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH     ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH   ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH   ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH   ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH  ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH  )
) u_axi4_full_master_read_interface(
  .axi4_clk                ( axi4_clk                ),
  .axi4_rst_n              ( axi4_rst_n              ),
  .axi4_full_M_AXI_ARREADY ( axi4_full_M_AXI_ARREADY ),
  .axi4_full_M_AXI_RID     ( axi4_full_M_AXI_RID     ),
  .axi4_full_M_AXI_RDATA   ( axi4_full_M_AXI_RDATA   ),
  .axi4_full_M_AXI_RRESP   ( axi4_full_M_AXI_RRESP   ),
  .axi4_full_M_AXI_RLAST   ( axi4_full_M_AXI_RLAST   ),
  .axi4_full_M_AXI_RUSER   ( axi4_full_M_AXI_RUSER   ),
  .axi4_full_M_AXI_RVALID  ( axi4_full_M_AXI_RVALID  ),
  .axi4_full_M_AXI_ARID    ( axi4_full_M_AXI_ARID    ),
  .axi4_full_M_AXI_ARADDR  ( axi4_full_M_AXI_ARADDR  ),
  .axi4_full_M_AXI_ARLEN   ( axi4_full_M_AXI_ARLEN   ),
  .axi4_full_M_AXI_ARSIZE  ( axi4_full_M_AXI_ARSIZE  ),
  .axi4_full_M_AXI_ARBURST ( axi4_full_M_AXI_ARBURST ),
  .axi4_full_M_AXI_ARLOCK  ( axi4_full_M_AXI_ARLOCK  ),
  .axi4_full_M_AXI_ARCACHE ( axi4_full_M_AXI_ARCACHE ),
  .axi4_full_M_AXI_ARPROT  ( axi4_full_M_AXI_ARPROT  ),
  .axi4_full_M_AXI_ARQOS   ( axi4_full_M_AXI_ARQOS   ),
  .axi4_full_M_AXI_ARUSER  ( axi4_full_M_AXI_ARUSER  ),
  .axi4_full_M_AXI_ARVALID ( axi4_full_M_AXI_ARVALID ),
  .axi4_full_M_AXI_RREADY  ( axi4_full_M_AXI_RREADY  ),

  .raddr_M_fifo_addr       ( raddr_M_fifo_addr       ),
  .raddr_M_fifo_len        ( raddr_M_fifo_len        ),
  .raddr_M_fifo_ready      ( raddr_M_fifo_ready      ),
  .raddr_M_fifo_valid      ( raddr_M_fifo_valid      ),
  .rdata_M_fifo_ready      ( rdata_M_fifo_ready      ),
  .rdata_M_fifo_valid      ( rdata_M_fifo_valid      ),
  .rdata_M_fifo_data       ( rdata_M_fifo_data       )
);

reg  [PERI_ADDR_WIDTH-1:0]    peripheral_M_waddr;
reg  [PERI_BUSRSTS_WIDTH-1:0] peripheral_M_wlen;
reg                                   peripheral_M_waddr_valid;
wire                                  peripheral_M_waddr_ready;
reg  [PERI_DATA_WIDTH-1:0]    peripheral_M_wdata;
reg                                   peripheral_M_wdata_valid;
wire                                  peripheral_M_wdata_ready;
wire                                  peripheral_M_bvalid;
wire                                  peripheral_M_bready;

wire [PERI_ADDR_WIDTH-1:0]    waddr_M_fifo_addr;
wire [PERI_BUSRSTS_WIDTH-1:0] waddr_M_fifo_len;
wire                                  waddr_M_fifo_ready;
wire                                  waddr_M_fifo_valid;
wire [PERI_DATA_WIDTH-1:0]    wdata_M_fifo_data;
wire                                  wdata_M_fifo_valid;
wire                                  wdata_M_fifo_ready;
wire                                  wdata_M_fifo_bvalid;
wire                                  wdata_M_fifo_bready;

peripheral_w_addr_clk_bridge #(
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH )
) u_peripheral_w_addr_clk_bridge(
  .peripheral_clk           ( axi4_clk                 ),
  .peripheral_rst_n         ( axi4_rst_n               ),
  .peripheral_M_waddr       ( peripheral_M_waddr       ),
  .peripheral_M_wlen        ( peripheral_M_wlen        ),
  .peripheral_M_waddr_valid ( peripheral_M_waddr_valid ),
  .peripheral_M_waddr_ready ( peripheral_M_waddr_ready ),
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .waddr_M_fifo_valid       ( waddr_M_fifo_valid       ),
  .waddr_M_fifo_addr        ( waddr_M_fifo_addr        ),
  .waddr_M_fifo_len         ( waddr_M_fifo_len         ),
  .waddr_M_fifo_ready       ( waddr_M_fifo_ready       )
);

peripheral_w_data_clk_bridge #(
  .PERI_DATA_WIDTH(PERI_DATA_WIDTH)
) u_peripheral_w_data_clk_bridge(
  .peripheral_clk           ( axi4_clk                 ),
  .peripheral_rst_n         ( axi4_rst_n               ),
  .peripheral_M_wdata       ( peripheral_M_wdata       ),
  .peripheral_M_wdata_valid ( peripheral_M_wdata_valid ),
  .peripheral_M_wdata_ready ( peripheral_M_wdata_ready ),
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .wdata_M_fifo_data        ( wdata_M_fifo_data        ),
  .wdata_M_fifo_valid       ( wdata_M_fifo_valid       ),
  .wdata_M_fifo_ready       ( wdata_M_fifo_ready       )
);

axi4_full_master_write_interface #(
  .PERI_ADDR_WIDTH        ( PERI_ADDR_WIDTH        ),
  .PERI_BUSRSTS_WIDTH     ( PERI_BUSRSTS_WIDTH     ),
  .PERI_DATA_WIDTH        ( PERI_DATA_WIDTH        ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH     ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH   ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH   ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH   ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH  ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH  )
) u_axi4_full_master_write_interface(
  .axi4_clk                ( axi4_clk                ),
  .axi4_rst_n              ( axi4_rst_n              ),
 
  .waddr_M_fifo_addr       ( waddr_M_fifo_addr       ),
  .waddr_M_fifo_len        ( waddr_M_fifo_len        ),
  .waddr_M_fifo_valid      ( waddr_M_fifo_valid      ),

  .waddr_M_fifo_ready      ( waddr_M_fifo_ready      ),
  .wdata_M_fifo_data       ( wdata_M_fifo_data       ),
  .wdata_M_fifo_valid      ( wdata_M_fifo_valid      ),
  .wdata_M_fifo_ready      ( wdata_M_fifo_ready      ),
  
  .axi4_full_M_AXI_AWREADY ( axi4_full_M_AXI_AWREADY ),
  .axi4_full_M_AXI_WREADY  ( axi4_full_M_AXI_WREADY  ),
  .axi4_full_M_AXI_BID     ( axi4_full_M_AXI_BID     ),
  .axi4_full_M_AXI_BRESP   ( axi4_full_M_AXI_BRESP   ),
  .axi4_full_M_AXI_BUSER   ( axi4_full_M_AXI_BUSER   ),
  .axi4_full_M_AXI_BVALID  ( axi4_full_M_AXI_BVALID  ),
  .axi4_full_M_AXI_AWID    ( axi4_full_M_AXI_AWID    ),
  .axi4_full_M_AXI_AWADDR  ( axi4_full_M_AXI_AWADDR  ),
  .axi4_full_M_AXI_AWLEN   ( axi4_full_M_AXI_AWLEN   ),
  .axi4_full_M_AXI_AWSIZE  ( axi4_full_M_AXI_AWSIZE  ),
  .axi4_full_M_AXI_AWBURST ( axi4_full_M_AXI_AWBURST ),
  .axi4_full_M_AXI_AWLOCK  ( axi4_full_M_AXI_AWLOCK  ),
  .axi4_full_M_AXI_AWCACHE ( axi4_full_M_AXI_AWCACHE ),
  .axi4_full_M_AXI_AWPROT  ( axi4_full_M_AXI_AWPROT  ),
  .axi4_full_M_AXI_AWQOS   ( axi4_full_M_AXI_AWQOS   ),
  .axi4_full_M_AXI_AWUSER  ( axi4_full_M_AXI_AWUSER  ),
  .axi4_full_M_AXI_AWVALID ( axi4_full_M_AXI_AWVALID ),
  .axi4_full_M_AXI_WDATA   ( axi4_full_M_AXI_WDATA   ),
  .axi4_full_M_AXI_WSTRB   ( axi4_full_M_AXI_WSTRB   ),
  .axi4_full_M_AXI_WLAST   ( axi4_full_M_AXI_WLAST   ),
  .axi4_full_M_AXI_WUSER   ( axi4_full_M_AXI_WUSER   ),
  .axi4_full_M_AXI_WVALID  ( axi4_full_M_AXI_WVALID  ),
  .axi4_full_M_AXI_BREADY  ( axi4_full_M_AXI_BREADY  ),
  .wdata_M_fifo_bvalid     ( wdata_M_fifo_bvalid     ),
  .wdata_M_fifo_bready     ( wdata_M_fifo_bready     ),
  .axi_transfer_done       (                         )
);

assign wdata_M_fifo_bready = 1'b1;

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    peripheral_M_waddr       <= 0;
    peripheral_M_wlen        <= 0;
    peripheral_M_waddr_valid <= 0;
    peripheral_M_wdata       <= 0;
    peripheral_M_wdata_valid <= 0;

    peripheral_M_raddr       <= 0;
    peripheral_M_rlen        <= 0;
    peripheral_M_raddr_valid <= 0;
    peripheral_M_rdata_valid <= 0;
  end
  else begin
    if (cmd_vld) begin
      if (cmd[CMD_BITS-1]) begin
        peripheral_M_waddr <= cmd[0+:AXI_M_AXI_ADDR_WIDTH];
        peripheral_M_wdata  <= cmd[AXI_M_AXI_ADDR_WIDTH+:AXI_M_AXI_DATA_WIDTH];
        peripheral_M_waddr_valid <= 1;
        peripheral_M_wlen <= cmd[(AXI_M_AXI_ADDR_WIDTH+AXI_M_AXI_DATA_WIDTH)+:8];
        peripheral_M_wdata_valid <= 1;
      end
      else begin
        peripheral_M_raddr <= cmd[0+:AXI_M_AXI_ADDR_WIDTH];
        peripheral_M_rlen  <= cmd[AXI_M_AXI_ADDR_WIDTH+:8];
        peripheral_M_raddr_valid <= 1;
      end
    end
    else begin
      if (peripheral_M_waddr_ready) begin
        peripheral_M_waddr_valid <= 0;
      end
      if (peripheral_M_wdata_ready) begin
        peripheral_M_wdata_valid <= 0;
      end
      if (peripheral_M_raddr_ready) begin
        peripheral_M_raddr_valid <= 0;
      end
    end
  end
end

endmodule