module dispatch_top(
  clk, fifo_rst_n, logic_rst_n,

  synchronize_fifo_full, synchronize_fifo_wen, synchronize_fifo_wdata,
  load_0_fifo_full, load_0_fifo_wen, load_0_fifo_wdata,
  store_0_fifo_full, store_0_fifo_wen, store_0_fifo_wdata,
  pea_0_fifo_full, pea_0_fifo_wen, pea_0_fifo_wdata,
  vcu_0_fifo_full, vcu_0_fifo_wen, vcu_0_fifo_wdata,

  insn_number, insn_addr, insn_burstlen, config_start, cmd_start,
  dispatch_empty, insn_done,

  npu_done, cib_irq_highaddr, cib_irq_enable, local_highaddr,

  axi4_clk, axi4_rst_n, 
  axi4_full_M_AXI_ARID, axi4_full_M_AXI_ARADDR, axi4_full_M_AXI_ARLEN, 
  axi4_full_M_AXI_ARSIZE, axi4_full_M_AXI_ARBURST, axi4_full_M_AXI_ARLOCK, axi4_full_M_AXI_ARCACHE, axi4_full_M_AXI_ARPROT, axi4_full_M_AXI_ARQOS, axi4_full_M_AXI_ARUSER, 
  axi4_full_M_AXI_ARVALID, axi4_full_M_AXI_ARREADY,
  axi4_full_M_AXI_RID, axi4_full_M_AXI_RDATA, axi4_full_M_AXI_RRESP, axi4_full_M_AXI_RLAST, axi4_full_M_AXI_RUSER, axi4_full_M_AXI_RVALID, axi4_full_M_AXI_RREADY,

  axi4_full_M_AXI_AWID, axi4_full_M_AXI_AWADDR, axi4_full_M_AXI_AWLEN,
  axi4_full_M_AXI_AWSIZE, axi4_full_M_AXI_AWBURST, axi4_full_M_AXI_AWLOCK, axi4_full_M_AXI_AWCACHE, axi4_full_M_AXI_AWPROT, axi4_full_M_AXI_AWQOS, axi4_full_M_AXI_AWUSER,
  axi4_full_M_AXI_AWVALID, axi4_full_M_AXI_AWREADY,
  axi4_full_M_AXI_WDATA, axi4_full_M_AXI_WSTRB, axi4_full_M_AXI_WLAST, axi4_full_M_AXI_WUSER, axi4_full_M_AXI_WVALID, axi4_full_M_AXI_WREADY,
  axi4_full_M_AXI_BID, axi4_full_M_AXI_BRESP, axi4_full_M_AXI_BUSER, axi4_full_M_AXI_BVALID, axi4_full_M_AXI_BREADY
);

parameter AXI_M_AXI_ID_WIDTH     = 20;
parameter AXI_M_AXI_ADDR_WIDTH   = 64;
parameter AXI_M_AXI_USER_WIDTH   = 1;
parameter AXI_M_AXI_DATA_WIDTH   = 256;
parameter AXI_M_AXI_BURSTLENGTH  = 128;
parameter AXI_OUTSTANDING_DEPTH  = 128;
parameter AXI_M_AXI_MIN_ID       = 0;
parameter AXI_M_AXI_MAX_ID       = 15;
localparam integer AXI_M_AXI_DATA_BYTES = AXI_M_AXI_DATA_WIDTH / 8;

parameter integer INSN_R_ADDR_WIDTH    = 64;
parameter integer INSN_R_BUSRSTS_WIDTH = 8;
parameter integer INSN_R_DATA_WIDTH    = 256;
parameter integer INSN_WIDTH           = 128;
parameter integer INSN_FIFO_DEPTH      = 128;
parameter integer HIGHADDR_BITS        = 24;

input                                  clk;
input                                  fifo_rst_n;
input                                  logic_rst_n;
input                                  axi4_clk;
input                                  axi4_rst_n;
output wire [AXI_M_AXI_ID_WIDTH-1:0]   axi4_full_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] axi4_full_M_AXI_ARADDR;
output wire [7:0]                      axi4_full_M_AXI_ARLEN;
output wire [2:0]                      axi4_full_M_AXI_ARSIZE;
output wire [1:0]                      axi4_full_M_AXI_ARBURST;
output wire                            axi4_full_M_AXI_ARLOCK;
output wire [3:0]                      axi4_full_M_AXI_ARCACHE;
output wire [2:0]                      axi4_full_M_AXI_ARPROT;
output wire [3:0]                      axi4_full_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_ARUSER;
output wire                            axi4_full_M_AXI_ARVALID;
input                                  axi4_full_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   axi4_full_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] axi4_full_M_AXI_RDATA;
input       [1:0]                      axi4_full_M_AXI_RRESP;
input                                  axi4_full_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_RUSER;
input                                  axi4_full_M_AXI_RVALID;
output wire                            axi4_full_M_AXI_RREADY;
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
input       [31:0]                     insn_number;
input       [63:0]                     insn_addr;
input       [7:0]                      insn_burstlen;
input       [31:0]                     config_start;
input                                  cmd_start;
output wire                            dispatch_empty;
output wire                            insn_done;
input                                  npu_done;
input       [63:0]                     cib_irq_highaddr;
input                                  cib_irq_enable;
input       [HIGHADDR_BITS-1:0]        local_highaddr;

output wire                  synchronize_fifo_wen;
output wire [INSN_WIDTH-1:0] synchronize_fifo_wdata;
input                        synchronize_fifo_full;

output wire                  load_0_fifo_wen;
output wire [INSN_WIDTH-1:0] load_0_fifo_wdata;
input                        load_0_fifo_full;

output wire                  pea_0_fifo_wen;
output wire [INSN_WIDTH-1:0] pea_0_fifo_wdata;
input                        pea_0_fifo_full;

output wire                  vcu_0_fifo_wen;
output wire [INSN_WIDTH-1:0] vcu_0_fifo_wdata;
input                        vcu_0_fifo_full;

output wire                  store_0_fifo_wen;
output wire [INSN_WIDTH-1:0] store_0_fifo_wdata;
input                        store_0_fifo_full;

wire [INSN_R_ADDR_WIDTH-1:0]    raddr_M_fifo_addr;
wire [INSN_R_BUSRSTS_WIDTH-1:0] raddr_M_fifo_len;
wire                            raddr_M_fifo_ready;
wire                            raddr_M_fifo_valid;
wire                            rdata_M_fifo_ready;
wire [INSN_R_DATA_WIDTH-1:0]    rdata_M_fifo_data;
wire                            rdata_M_fifo_valid;

wire [INSN_R_ADDR_WIDTH-1:0]    peripheral_M_raddr;
wire [INSN_R_BUSRSTS_WIDTH-1:0] peripheral_M_rlen;
wire                            peripheral_M_raddr_valid;
wire                            peripheral_M_raddr_ready;
wire [INSN_R_DATA_WIDTH-1:0]    peripheral_M_rdata;
wire                            peripheral_M_rdata_valid;
wire                            peripheral_M_rdata_ready;

reg  [63:0]  peripheral_M_waddr;
reg  [7:0]   peripheral_M_wlen;
reg          peripheral_M_waddr_valid;
wire         peripheral_M_waddr_ready;
reg  [255:0] peripheral_M_wdata;
reg          peripheral_M_wdata_valid;
wire         peripheral_M_wdata_ready;
wire         peripheral_M_bvalid;
wire         peripheral_M_bready;

wire [63:0]  waddr_M_fifo_addr;
wire [7:0]   waddr_M_fifo_len;
wire         waddr_M_fifo_ready;
wire         waddr_M_fifo_valid;
wire [255:0] wdata_M_fifo_data;
wire         wdata_M_fifo_valid;
wire         wdata_M_fifo_ready;
wire         wdata_M_fifo_bvalid;
wire         wdata_M_fifo_bready;

wire [AXI_M_AXI_ADDR_WIDTH-1:0] local_axi_awaddr;

dispatch #(
  .INSN_R_ADDR_WIDTH    ( INSN_R_ADDR_WIDTH    ),
  .INSN_R_BUSRSTS_WIDTH ( INSN_R_BUSRSTS_WIDTH ),
  .INSN_R_DATA_WIDTH    ( INSN_R_DATA_WIDTH    ),
  .INSN_WIDTH           ( INSN_WIDTH           ),
  .INSN_FIFO_DEPTH      ( INSN_FIFO_DEPTH      )
) u_dispatch(
  .clk                    ( clk                      ),
  .rst_n                  ( logic_rst_n              ),
  .insn_M_raddr           ( peripheral_M_raddr       ),
  .insn_M_rlen            ( peripheral_M_rlen        ),
  .insn_M_raddr_ready     ( peripheral_M_raddr_ready ),
  .insn_M_rdata_ready     ( peripheral_M_rdata_ready ),
  .synchronize_fifo_full  ( synchronize_fifo_full    ),
  .load_0_fifo_full       ( load_0_fifo_full         ),
  .pea_0_fifo_full        ( pea_0_fifo_full          ),
  .vcu_0_fifo_full        ( vcu_0_fifo_full          ),
  .store_0_fifo_full      ( store_0_fifo_full        ),
  .insn_number            ( insn_number              ),
  .insn_addr              ( insn_addr                ),
  .insn_burstlen          ( insn_burstlen            ),
  .config_start           ( config_start             ),
  .cmd_start              ( cmd_start                ),
  .insn_M_raddr_valid     ( peripheral_M_raddr_valid ),
  .insn_M_rdata           ( peripheral_M_rdata       ),
  .insn_M_rdata_valid     ( peripheral_M_rdata_valid ),
  .synchronize_fifo_wen   ( synchronize_fifo_wen     ),
  .synchronize_fifo_wdata ( synchronize_fifo_wdata   ),
  .load_0_fifo_wen        ( load_0_fifo_wen          ),
  .load_0_fifo_wdata      ( load_0_fifo_wdata        ),
  .pea_0_fifo_wen         ( pea_0_fifo_wen           ),
  .pea_0_fifo_wdata       ( pea_0_fifo_wdata         ),
  .vcu_0_fifo_wen         ( vcu_0_fifo_wen           ),
  .vcu_0_fifo_wdata       ( vcu_0_fifo_wdata         ),
  .store_0_fifo_wen       ( store_0_fifo_wen         ),
  .store_0_fifo_wdata     ( store_0_fifo_wdata       ),
  .dispatch_empty         ( dispatch_empty           ),
  .insn_done              ( insn_done                )
);

peripheral_r_addr_clk_bridge #(
  .PERI_ADDR_WIDTH    ( INSN_R_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( INSN_R_BUSRSTS_WIDTH )
) u_peripheral_r_addr_clk_bridge(
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
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
  .PERI_DATA_WIDTH ( INSN_R_DATA_WIDTH )
) u_peripheral_r_data_clk_bridge(
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .rdata_M_fifo_data        ( rdata_M_fifo_data        ),
  .rdata_M_fifo_valid       ( rdata_M_fifo_valid       ),
  .rdata_M_fifo_ready       ( rdata_M_fifo_ready       ),
  .axi4_clk                 ( axi4_clk                 ),
  .axi4_rst_n               ( axi4_rst_n               ),
  .peripheral_M_rdata       ( peripheral_M_rdata       ),
  .peripheral_M_rdata_valid ( peripheral_M_rdata_valid ),
  .peripheral_M_rdata_ready ( peripheral_M_rdata_ready )
);

wire [AXI_M_AXI_ADDR_WIDTH-1:0] local_axi_araddr;

axi4_full_master_read_interface #(
  .PERI_ADDR_WIDTH       ( INSN_R_ADDR_WIDTH     ),
  .PERI_BUSRSTS_WIDTH    ( INSN_R_BUSRSTS_WIDTH  ),
  .PERI_DATA_WIDTH       ( INSN_R_DATA_WIDTH     ),
  .AXI_M_AXI_ID_WIDTH    ( AXI_M_AXI_ID_WIDTH    ),
  .AXI_M_AXI_ADDR_WIDTH  ( AXI_M_AXI_ADDR_WIDTH  ),
  .AXI_M_AXI_USER_WIDTH  ( AXI_M_AXI_USER_WIDTH  ),
  .AXI_M_AXI_DATA_WIDTH  ( AXI_M_AXI_DATA_WIDTH  ),
  .AXI_M_AXI_BURSTLENGTH ( AXI_M_AXI_BURSTLENGTH ),
  .AXI_OUTSTANDING_DEPTH ( AXI_OUTSTANDING_DEPTH ),
  .AXI_M_AXI_MIN_ID      ( AXI_M_AXI_MIN_ID      ),
  .AXI_M_AXI_MAX_ID      ( AXI_M_AXI_MAX_ID      )
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
  .axi4_full_M_AXI_ARADDR  ( local_axi_araddr        ),
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

reg [3:0] irq;

always @(posedge clk or negedge logic_rst_n) begin
  if (!logic_rst_n) begin
    irq <= 4'b0;
  end
  else begin
    if (npu_done) begin
      irq <= 4'b0100;
    end 
    else begin
      irq <= 4'b0000;
    end
  end
end

always @(posedge clk or negedge logic_rst_n) begin
  if (!logic_rst_n) begin
    peripheral_M_waddr <= 64'b0;
    peripheral_M_wlen <= 8'b0;
    peripheral_M_waddr_valid <= 1'b0;
    peripheral_M_wdata <= 256'b0;
    peripheral_M_wdata_valid <= 1'b0;
  end 
  else begin
    peripheral_M_waddr <= cib_irq_highaddr;

    if ((|irq) && cib_irq_enable) begin
      peripheral_M_wlen        <= 8'b0;
      peripheral_M_waddr_valid <= 1'b1;
      peripheral_M_wdata       <= {local_highaddr, irq};
      peripheral_M_wdata_valid <= 1'b1;
    end 
    else begin
      peripheral_M_wlen        <= 8'b0;
      peripheral_M_waddr_valid <= 1'b0;
      peripheral_M_wdata       <= 256'b0;
      peripheral_M_wdata_valid <= 1'b0;
    end

  end
end

peripheral_w_addr_clk_bridge #(
  .PERI_ADDR_WIDTH    ( 64 ),
  .PERI_BUSRSTS_WIDTH ( 8  )
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
  .PERI_DATA_WIDTH ( 256 )
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
  .PERI_ADDR_WIDTH        ( 64                    ),
  .PERI_BUSRSTS_WIDTH     ( 8                     ),
  .PERI_DATA_WIDTH        ( 256                   ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH    ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH  ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH  ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH  ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH ),
  .AXI_M_AXI_MIN_ID       ( AXI_M_AXI_MIN_ID + 16 ),
  .AXI_M_AXI_MAX_ID       ( AXI_M_AXI_MAX_ID + 16 )
) u_axi4_full_master_write_interface(
  .axi4_clk                         ( axi4_clk                ),
  .axi4_rst_n                       ( axi4_rst_n              ),
  .waddr_M_fifo_addr                ( waddr_M_fifo_addr       ),
  .waddr_M_fifo_len                 ( waddr_M_fifo_len        ),
  .waddr_M_fifo_valid               ( waddr_M_fifo_valid      ),
  .waddr_M_fifo_ready               ( waddr_M_fifo_ready      ),
  .wdata_M_fifo_data                ( wdata_M_fifo_data       ),
  .wdata_M_fifo_valid               ( wdata_M_fifo_valid      ),
  .wdata_M_fifo_ready               ( wdata_M_fifo_ready      ),
  .axi4_full_M_AXI_AWREADY          ( axi4_full_M_AXI_AWREADY ),
  .axi4_full_M_AXI_WREADY           ( axi4_full_M_AXI_WREADY  ),
  .axi4_full_M_AXI_BID              ( axi4_full_M_AXI_BID     ),
  .axi4_full_M_AXI_BRESP            ( axi4_full_M_AXI_BRESP   ),
  .axi4_full_M_AXI_BUSER            ( axi4_full_M_AXI_BUSER   ),
  .axi4_full_M_AXI_BVALID           ( axi4_full_M_AXI_BVALID  ),
  .axi4_full_M_AXI_AWID             ( axi4_full_M_AXI_AWID    ),
  .axi4_full_M_AXI_AWADDR           ( local_axi_awaddr        ),
  .axi4_full_M_AXI_AWLEN            ( axi4_full_M_AXI_AWLEN   ),
  .axi4_full_M_AXI_AWSIZE           ( axi4_full_M_AXI_AWSIZE  ),
  .axi4_full_M_AXI_AWBURST          ( axi4_full_M_AXI_AWBURST ),
  .axi4_full_M_AXI_AWLOCK           ( axi4_full_M_AXI_AWLOCK  ),
  .axi4_full_M_AXI_AWCACHE          ( axi4_full_M_AXI_AWCACHE ),
  .axi4_full_M_AXI_AWPROT           ( axi4_full_M_AXI_AWPROT  ),
  .axi4_full_M_AXI_AWQOS            ( axi4_full_M_AXI_AWQOS   ),
  .axi4_full_M_AXI_AWUSER           ( axi4_full_M_AXI_AWUSER  ),
  .axi4_full_M_AXI_AWVALID          ( axi4_full_M_AXI_AWVALID ),
  .axi4_full_M_AXI_WDATA            ( axi4_full_M_AXI_WDATA   ),
  .axi4_full_M_AXI_WSTRB            ( axi4_full_M_AXI_WSTRB   ),
  .axi4_full_M_AXI_WLAST            ( axi4_full_M_AXI_WLAST   ),
  .axi4_full_M_AXI_WUSER            ( axi4_full_M_AXI_WUSER   ),
  .axi4_full_M_AXI_WVALID           ( axi4_full_M_AXI_WVALID  ),
  .axi4_full_M_AXI_BREADY           ( axi4_full_M_AXI_BREADY  ),
  .wdata_M_fifo_bvalid              ( wdata_M_fifo_bvalid     ),
  .wdata_M_fifo_bready              ( wdata_M_fifo_bready     ),
  .axi_transfer_done                (                         )
);

assign wdata_M_fifo_bready = 1'b1;

assign axi4_full_M_AXI_AWADDR = local_axi_awaddr;

ddr_axi_router u_araddr_router(
  .in_addr  ( local_axi_araddr       ),
  .out_addr ( axi4_full_M_AXI_ARADDR )
);

endmodule