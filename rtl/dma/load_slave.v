module load_slave(
  axi4_clk, axi4_rst_n,
  axi4_full_S_AXI_ARID, axi4_full_S_AXI_ARADDR, axi4_full_S_AXI_ARLEN, 
  axi4_full_S_AXI_ARSIZE, axi4_full_S_AXI_ARBURST, axi4_full_S_AXI_ARLOCK, axi4_full_S_AXI_ARCACHE, axi4_full_S_AXI_ARPROT, axi4_full_S_AXI_ARQOS, axi4_full_S_AXI_ARUSER, 
  axi4_full_S_AXI_ARVALID, axi4_full_S_AXI_ARREADY,
  axi4_full_S_AXI_RID, axi4_full_S_AXI_RDATA, axi4_full_S_AXI_RRESP, axi4_full_S_AXI_RLAST, axi4_full_S_AXI_RUSER, axi4_full_S_AXI_RVALID, axi4_full_S_AXI_RREADY,

  clk, fifo_rst_n, logic_rst_n, 
  sram_raddr, sram_rvalid, sram_rready, sram_rdata
);

//Define parameters:
parameter PERI_ADDR_WIDTH      = 33;
parameter PERI_BUSRSTS_WIDTH   = 8;
parameter PERI_DATA_WIDTH      = 256;

parameter AXI_S_AXI_ID_WIDTH    = 20;
parameter AXI_S_AXI_ADDR_WIDTH  = 64;
parameter AXI_S_AXI_USER_WIDTH  = 1;
parameter AXI_S_AXI_DATA_WIDTH  = 256;
parameter AXI_S_AXI_BURSTLENGTH = 32;
parameter AXI_OUTSTANDING_DEPTH = 8;


input                                  axi4_clk;
input                                  axi4_rst_n;
input [AXI_S_AXI_ID_WIDTH-1:0]         axi4_full_S_AXI_ARID;
input [AXI_S_AXI_ADDR_WIDTH-1:0]       axi4_full_S_AXI_ARADDR;
input [7:0]                            axi4_full_S_AXI_ARLEN;
input [2:0]                            axi4_full_S_AXI_ARSIZE;
input [1:0]                            axi4_full_S_AXI_ARBURST;
input                                  axi4_full_S_AXI_ARLOCK;
input [3:0]                            axi4_full_S_AXI_ARCACHE;
input [2:0]                            axi4_full_S_AXI_ARPROT;
input [3:0]                            axi4_full_S_AXI_ARQOS;
input [AXI_S_AXI_USER_WIDTH-1:0]       axi4_full_S_AXI_ARUSER;
input                                  axi4_full_S_AXI_ARVALID;
output wire                            axi4_full_S_AXI_ARREADY;
output wire [AXI_S_AXI_ID_WIDTH-1:0]   axi4_full_S_AXI_RID;
output wire [AXI_S_AXI_DATA_WIDTH-1:0] axi4_full_S_AXI_RDATA;
output wire [1:0]                      axi4_full_S_AXI_RRESP;
output wire                            axi4_full_S_AXI_RLAST;
output wire [AXI_S_AXI_USER_WIDTH-1:0] axi4_full_S_AXI_RUSER;
output wire                            axi4_full_S_AXI_RVALID;
input                                  axi4_full_S_AXI_RREADY;

input              clk;
input              fifo_rst_n;
input              logic_rst_n;
output wire [31:0] sram_raddr;
output wire        sram_rvalid;
input              sram_rready;
input       [31:0] sram_rdata;


wire [PERI_ADDR_WIDTH-1:0]    raddr_S_fifo_addr;
wire [PERI_BUSRSTS_WIDTH-1:0] raddr_S_fifo_len;
wire                          raddr_S_fifo_ready;
wire                          raddr_S_fifo_valid;
wire [PERI_DATA_WIDTH-1:0]    rdata_S_fifo_data;
wire                          rdata_S_fifo_valid;
wire                          rdata_S_fifo_ready;

wire [PERI_ADDR_WIDTH-1:0]    peripheral_S_raddr;
wire [PERI_BUSRSTS_WIDTH-1:0] peripheral_S_rlen;
wire                          peripheral_S_raddr_valid;
wire                          peripheral_S_raddr_ready;
wire [PERI_DATA_WIDTH-1:0]    peripheral_S_rdata;
wire                          peripheral_S_rdata_valid;
wire                          peripheral_S_rdata_ready;


axi4_full_slave_read_interface #(
  .PERI_ADDR_WIDTH       ( PERI_ADDR_WIDTH       ),
  .PERI_BUSRSTS_WIDTH    ( PERI_BUSRSTS_WIDTH    ),
  .PERI_DATA_WIDTH       ( PERI_DATA_WIDTH       ),
  .AXI_S_AXI_ID_WIDTH    ( AXI_S_AXI_ID_WIDTH    ),
  .AXI_S_AXI_ADDR_WIDTH  ( AXI_S_AXI_ADDR_WIDTH  ),
  .AXI_S_AXI_USER_WIDTH  ( AXI_S_AXI_USER_WIDTH  ),
  .AXI_S_AXI_DATA_WIDTH  ( AXI_S_AXI_DATA_WIDTH  ),
  .AXI_S_AXI_BURSTLENGTH ( AXI_S_AXI_BURSTLENGTH ),
  .AXI_OUTSTANDING_DEPTH ( AXI_OUTSTANDING_DEPTH )
) u_axi4_full_slave_read_interface(
  .axi4_clk                ( axi4_clk                ),
  .axi4_rst_n              ( axi4_rst_n              ),

  .axi4_full_S_AXI_ARID    ( axi4_full_S_AXI_ARID    ),
  .axi4_full_S_AXI_ARADDR  ( axi4_full_S_AXI_ARADDR  ),
  .axi4_full_S_AXI_ARLEN   ( axi4_full_S_AXI_ARLEN   ),
  .axi4_full_S_AXI_ARSIZE  ( axi4_full_S_AXI_ARSIZE  ),
  .axi4_full_S_AXI_ARBURST ( axi4_full_S_AXI_ARBURST ),
  .axi4_full_S_AXI_ARLOCK  ( axi4_full_S_AXI_ARLOCK  ),
  .axi4_full_S_AXI_ARCACHE ( axi4_full_S_AXI_ARCACHE ),
  .axi4_full_S_AXI_ARPROT  ( axi4_full_S_AXI_ARPROT  ),
  .axi4_full_S_AXI_ARQOS   ( axi4_full_S_AXI_ARQOS   ),
  .axi4_full_S_AXI_ARUSER  ( axi4_full_S_AXI_ARUSER  ),
  .axi4_full_S_AXI_ARVALID ( axi4_full_S_AXI_ARVALID ),
  .axi4_full_S_AXI_RREADY  ( axi4_full_S_AXI_RREADY  ),
  .axi4_full_S_AXI_ARREADY ( axi4_full_S_AXI_ARREADY ),
  .axi4_full_S_AXI_RID     ( axi4_full_S_AXI_RID     ),
  .axi4_full_S_AXI_RDATA   ( axi4_full_S_AXI_RDATA   ),
  .axi4_full_S_AXI_RRESP   ( axi4_full_S_AXI_RRESP   ),
  .axi4_full_S_AXI_RLAST   ( axi4_full_S_AXI_RLAST   ),
  .axi4_full_S_AXI_RUSER   ( axi4_full_S_AXI_RUSER   ),
  .axi4_full_S_AXI_RVALID  ( axi4_full_S_AXI_RVALID  ),

  .raddr_S_fifo_addr       ( raddr_S_fifo_addr       ),
  .raddr_S_fifo_len        ( raddr_S_fifo_len        ),
  .raddr_S_fifo_ready      ( raddr_S_fifo_ready      ),
  .raddr_S_fifo_valid      ( raddr_S_fifo_valid      ),
  .rdata_S_fifo_data       ( rdata_S_fifo_data       ),
  .rdata_S_fifo_valid      ( rdata_S_fifo_valid      ),
  .rdata_S_fifo_ready      ( rdata_S_fifo_ready      )
);

axi4_r_addr_clk_bridge #(
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH )
) u_axi4_r_addr_clk_bridge(
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .raddr_S_fifo_addr        ( raddr_S_fifo_addr        ),
  .raddr_S_fifo_len         ( raddr_S_fifo_len         ),
  .raddr_S_fifo_ready       ( raddr_S_fifo_ready       ),
  .raddr_S_fifo_valid       ( raddr_S_fifo_valid       ),
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .peripheral_S_raddr_ready ( peripheral_S_raddr_ready ),
  .peripheral_S_raddr       ( peripheral_S_raddr       ),
  .peripheral_S_rlen        ( peripheral_S_rlen        ),
  .peripheral_S_raddr_valid ( peripheral_S_raddr_valid )
);

axi4_r_data_clk_bridge #(
  .PERI_DATA_WIDTH ( PERI_DATA_WIDTH )
) u_axi4_r_data_clk_bridge(
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .peripheral_S_rdata       ( peripheral_S_rdata       ),
  .peripheral_S_rdata_valid ( peripheral_S_rdata_valid ),
  .peripheral_S_rdata_ready ( peripheral_S_rdata_ready ),
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .rdata_S_fifo_ready       ( rdata_S_fifo_ready       ),
  .rdata_S_fifo_data        ( rdata_S_fifo_data        ),
  .rdata_S_fifo_valid       ( rdata_S_fifo_valid       )
);

load_ed #(
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH ),
  .PERI_DATA_WIDTH    ( PERI_DATA_WIDTH    )
) u_load_ed(
  .clk                      ( clk                      ),
  .rst_n                    ( logic_rst_n              ),
  .peripheral_S_raddr       ( peripheral_S_raddr       ),
  .peripheral_S_rlen        ( peripheral_S_rlen        ),
  .peripheral_S_raddr_valid ( peripheral_S_raddr_valid ),
  .peripheral_S_rdata_ready ( peripheral_S_rdata_ready ),
  .peripheral_S_raddr_ready ( peripheral_S_raddr_ready ),
  .peripheral_S_rdata       ( peripheral_S_rdata       ),
  .peripheral_S_rdata_valid ( peripheral_S_rdata_valid ),
  .sram_read_addr           ( sram_raddr               ),
  .sram_read_valid          ( sram_rvalid              ),
  .sram_read_ready          ( sram_rready              ),
  .sram_read_data           ( sram_rdata               )
);

endmodule

