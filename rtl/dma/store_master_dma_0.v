module store_master_dma_0(
  clk, fifo_rst_n, logic_rst_n,
  work_en, insn, insn_read,
  local_done, global_done, 

  highaddr, highaddr_sel,

  enable_prof_counter, execute_time,

  psum_store_valid_bits,

  psum_rvalid, psum_raddr, psum_rdata,
  ofmap_rvalid, ofmap_raddr, ofmap_rdata,

  axi4_clk, axi4_rst_n,
  axi4_full_M_AXI_AWID, axi4_full_M_AXI_AWADDR, axi4_full_M_AXI_AWLEN,
  axi4_full_M_AXI_AWSIZE, axi4_full_M_AXI_AWBURST, axi4_full_M_AXI_AWLOCK, axi4_full_M_AXI_AWCACHE, axi4_full_M_AXI_AWPROT, axi4_full_M_AXI_AWQOS, axi4_full_M_AXI_AWUSER,
  axi4_full_M_AXI_AWVALID, axi4_full_M_AXI_AWREADY,
  axi4_full_M_AXI_WDATA, axi4_full_M_AXI_WSTRB, axi4_full_M_AXI_WLAST, axi4_full_M_AXI_WUSER, axi4_full_M_AXI_WVALID, axi4_full_M_AXI_WREADY,
  axi4_full_M_AXI_BID, axi4_full_M_AXI_BRESP, axi4_full_M_AXI_BUSER, axi4_full_M_AXI_BVALID, axi4_full_M_AXI_BREADY
);

parameter STORE_INSNBITS = 128;

parameter PERI_ADDR_WIDTH               = 38;
parameter PERI_BUSRSTS_WIDTH            = 8;
parameter PERI_DATA_WIDTH               = 256;

parameter AXI_M_AXI_ID_WIDTH     = 20;
parameter AXI_M_AXI_ADDR_WIDTH   = 64;
parameter AXI_M_AXI_USER_WIDTH   = 1;
parameter AXI_M_AXI_DATA_WIDTH   = 256;
parameter AXI_M_AXI_BURSTLENGTH  = 128;
parameter AXI_OUTSTANDING_DEPTH  = 128;
parameter SRAM_ADDR_WIDTH        = 20;
parameter AXI_M_AXI_MIN_ID       = 0;
parameter AXI_M_AXI_MAX_ID       = 15;

localparam integer AXI_M_AXI_DATA_BYTES = AXI_M_AXI_DATA_WIDTH / 8;

parameter PSUM_WIDTH      = 1024;
parameter OFMAP_WIDTH     = 256;

parameter PSUM_ADDR_BITS  = 12;
parameter OFMAP_ADDR_BITS = 12;

input                                  clk;
input                                  fifo_rst_n;
input                                  logic_rst_n;
input                                  work_en;
output                                 insn_read;
input       [STORE_INSNBITS-1:0]       insn;
output wire                            local_done;
output wire                            global_done;

input                                  axi4_clk; 
input                                  axi4_rst_n;
output wire [AXI_M_AXI_ID_WIDTH-1:0]   axi4_full_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] axi4_full_M_AXI_AWADDR;
output wire [7:0]                      axi4_full_M_AXI_AWLEN;
output wire [2:0]                      axi4_full_M_AXI_AWSIZE;
output wire [1:0]                      axi4_full_M_AXI_AWBURST;
output wire                            axi4_full_M_AXI_AWLOCK;
output wire [3:0]                      axi4_full_M_AXI_AWCACHE;
output wire [2:0]                      axi4_full_M_AXI_AWPROT;
output wire [3:0]                      axi4_full_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_AWUSER;
output wire                            axi4_full_M_AXI_AWVALID;
input                                  axi4_full_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] axi4_full_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] axi4_full_M_AXI_WSTRB;
output wire                            axi4_full_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_WUSER;
output wire                            axi4_full_M_AXI_WVALID;
input                                  axi4_full_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   axi4_full_M_AXI_BID;
input       [1:0]                      axi4_full_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_BUSER;
input                                  axi4_full_M_AXI_BVALID;
output wire                            axi4_full_M_AXI_BREADY;

input       [1:0]                      psum_store_valid_bits;

output wire                            psum_rvalid;
output wire [PSUM_ADDR_BITS-1:0]       psum_raddr;
input       [PSUM_WIDTH-1:0]           psum_rdata;

output wire                            ofmap_rvalid;
output wire [OFMAP_ADDR_BITS-1:0]      ofmap_raddr;
input       [OFMAP_WIDTH-1:0]          ofmap_rdata;

input       [23:0] highaddr;
input              highaddr_sel;

input              enable_prof_counter;
output reg  [31:0] execute_time;

wire [PERI_ADDR_WIDTH-1:0]    peripheral_M_waddr;
wire [PERI_BUSRSTS_WIDTH-1:0] peripheral_M_wlen;
wire                          peripheral_M_waddr_valid;
wire                          peripheral_M_waddr_ready;
wire [PERI_DATA_WIDTH-1:0]    peripheral_M_wdata;
wire                          peripheral_M_wdata_valid;
wire                          peripheral_M_wdata_ready;
wire                          peripheral_M_bvalid;
wire                          peripheral_M_bready;

wire [PERI_ADDR_WIDTH-1:0]    waddr_M_fifo_addr;
wire [PERI_BUSRSTS_WIDTH-1:0] waddr_M_fifo_len;
wire                          waddr_M_fifo_ready;
wire                          waddr_M_fifo_valid;
wire [PERI_DATA_WIDTH-1:0]    wdata_M_fifo_data;
wire                          wdata_M_fifo_valid;
wire                          wdata_M_fifo_ready;
wire                          wdata_M_fifo_bvalid;
wire                          wdata_M_fifo_bready;

wire axi_aw_handshake;

wire logic_local_done, logic_global_done;

wire [PERI_ADDR_WIDTH-1:0]        store_insn_peripheral_M_waddr;
wire [PERI_BUSRSTS_WIDTH-1:0]     store_insn_peripheral_M_wlen;
wire                              store_insn_peripheral_M_waddr_valid;
wire                              store_insn_peripheral_M_waddr_ready;
wire [PERI_DATA_WIDTH-1:0]        store_insn_peripheral_M_wdata;
wire                              store_insn_peripheral_M_wdata_valid;
wire                              store_insn_peripheral_M_wdata_ready;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] local_axi_awaddr;

wire axi_transfer_done;
reg axi_transfer_done_1st;
reg axi_transfer_done_2rd;
reg axi_transfer_done_3th;

store_insn_dma_0 #(
  .STORE_INSNBITS     ( STORE_INSNBITS     ),
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH ),
  .PERI_DATA_WIDTH    ( PERI_DATA_WIDTH    ),
  .SRAM_ADDR_WIDTH    ( SRAM_ADDR_WIDTH    )
) u_store_insn(
  .clk                      ( clk                       ),
  .rst_n                    ( logic_rst_n               ),
  .insn_read                ( insn_read                 ),
  .work_en                  ( work_en                   ),
  .insn                     ( insn                      ),
  .peripheral_M_waddr_ready ( peripheral_M_waddr_ready  ),
  .peripheral_M_wdata_ready ( peripheral_M_wdata_ready  ),
  .local_done               ( local_done                ),
  .global_done              ( global_done               ),
  .peripheral_M_waddr       ( peripheral_M_waddr        ),
  .peripheral_M_wlen        ( peripheral_M_wlen         ),
  .peripheral_M_waddr_valid ( peripheral_M_waddr_valid  ),
  .peripheral_M_wdata       ( peripheral_M_wdata        ),
  .peripheral_M_wdata_valid ( peripheral_M_wdata_valid  ),
  .peripheral_M_bready      ( peripheral_M_bready       ),
  .axi_aw_handshake         ( axi_aw_handshake          ),
  .axi_transfer_done        ( axi_transfer_done_3th     ),
  .psum_store_valid_bits    ( psum_store_valid_bits     ),
  .psum_rvalid              ( psum_rvalid               ),
  .psum_raddr               ( psum_raddr                ),
  .psum_rdata               ( psum_rdata                ),
  .ofmap_rvalid             ( ofmap_rvalid              ),
  .ofmap_raddr              ( ofmap_raddr               ),
  .ofmap_rdata              ( ofmap_rdata               )
);

peripheral_w_addr_clk_bridge #(
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH )
) u_peripheral_w_addr_clk_bridge(
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
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
  .PERI_DATA_WIDTH ( PERI_DATA_WIDTH )
) u_peripheral_w_data_clk_bridge(
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
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
  .PERI_ADDR_WIDTH        ( PERI_ADDR_WIDTH       ),
  .PERI_BUSRSTS_WIDTH     ( PERI_BUSRSTS_WIDTH    ),
  .PERI_DATA_WIDTH        ( PERI_DATA_WIDTH       ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH    ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH  ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH  ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH  ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH ),
  .AXI_M_AXI_MAX_ID       ( AXI_M_AXI_MAX_ID       ),
  .AXI_M_AXI_MIN_ID       ( AXI_M_AXI_MIN_ID       )
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
  .axi4_full_M_AXI_AWADDR  ( local_axi_awaddr        ),
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
  .axi_transfer_done       ( axi_transfer_done       )
);

AsyncAxiFifo8 #(.DATAWIDTH(1)) u_b_fifo (
  .CLKU        ( axi4_clk                 ), 
  .RESETUn     ( axi4_rst_n               ), 
  .READYU      ( wdata_M_fifo_bready      ),
  .VALIDU      ( wdata_M_fifo_bvalid      ),
  .DATAU       ( 1'b1                     ),
  .SYNCMODEREQ ( 1'b0                     ),
  .CLKD        ( clk                      ),
  .RESETDn     ( fifo_rst_n               ),
  .READYD      ( peripheral_M_bvalid      ),
  .VALIDD      ( peripheral_M_bready      ),
  .DATAD       (                          ), 
  .SYNCMODEACK (                          )
);

AsyncAxiFifo8 #(.DATAWIDTH(1)) u_aw_fifo (
  .CLKU        ( axi4_clk                                           ), 
  .RESETUn     ( axi4_rst_n                                         ), 
  .READYU      (                                                    ),
  .VALIDU      ( axi4_full_M_AXI_AWVALID && axi4_full_M_AXI_AWREADY ),
  .DATAU       ( 1'b1                                               ),
  .SYNCMODEREQ ( 1'b0                                               ),
  .CLKD        ( clk                                                ),
  .RESETDn     ( fifo_rst_n                                         ),
  .READYD      ( 1'b1                                               ),
  .VALIDD      ( axi_aw_handshake                                   ),
  .DATAD       (                                                    ), 
  .SYNCMODEACK ()
);

wire [AXI_M_AXI_ADDR_WIDTH-1:0] router_ddr_axi_awaddr;

ddr_axi_router u_awaddr_router(
  .in_addr  ( local_axi_awaddr      ),
  .out_addr ( router_ddr_axi_awaddr )
);

assign peripheral_M_bvalid = 1'b1;
assign axi4_full_M_AXI_AWADDR = highaddr_sel ? ({highaddr, 40'd0} | local_axi_awaddr) : router_ddr_axi_awaddr;

reg start_level;

always @(posedge clk or negedge logic_rst_n) begin
  if (!logic_rst_n) begin
    start_level <= 1'b0;
  end
  else begin
    if (work_en) begin
      start_level <= 1'b1;
    end
    else if (local_done) begin
      start_level <= 1'b0;
    end
    else begin
      start_level <= start_level;
    end
  end
end

always @(posedge clk or negedge logic_rst_n) begin
  if (!logic_rst_n) begin
    execute_time <= 32'd0;
  end
  else begin
    if (start_level && enable_prof_counter) begin
      execute_time <= execute_time + 1;
    end
  end
end

always @(posedge clk or negedge logic_rst_n) begin
  if (!logic_rst_n) begin
    axi_transfer_done_1st <= 1'b0;
    axi_transfer_done_2rd <= 1'b0;
    axi_transfer_done_3th <= 1'b0;
  end
  else begin
    axi_transfer_done_1st <= axi_transfer_done;
    axi_transfer_done_2rd <= axi_transfer_done_1st;
    axi_transfer_done_3th <= axi_transfer_done_2rd;
  end
end

endmodule

