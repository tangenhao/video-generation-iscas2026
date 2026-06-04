module npu_pcie_irq_tb;

parameter PERIPHERAL_R_ADDR_WIDTH       = 33;
parameter PERIPHERAL_R_BUSRSTS_WIDTH    = 8;
parameter PERIPHERAL_R_DATA_WIDTH       = 256;
parameter PERIPHERAL_W_ADDR_WIDTH       = 33;
parameter PERIPHERAL_W_BUSRSTS_WIDTH    = 8;
parameter PERIPHERAL_W_DATA_WIDTH       = 256;
parameter AXI4_FULL_S_AXI_BURSTLENGTH   = 32;
parameter AXI4_FULL_M_AXI_BURSTLENGTH   = 32;
parameter AXI4_FULL_M_AXI_MAX_4K        = 8;
parameter AXI4_FULL_S_AXI_MAX_4K        = 8;
parameter ASYN_RADDR_FIFO_DEPTH         = 64;
parameter AXI4_FULL_OUTSTANDING_DEPTH   = 128;
parameter AXI4_FULL_M_AXI_ID_WIDTH      = 26;
parameter AXI4_FULL_M_AXI_ARADDR_WIDTH  = 64;
parameter AXI4_FULL_M_AXI_ARUSER_WIDTH  = 1;
parameter AXI4_FULL_M_AXI_RDATA_WIDTH   = 256;
parameter AXI4_FULL_M_AXI_RUSER_WIDTH   = 1;
parameter AXI4_FULL_S_AXI_ID_WIDTH      = 20;
parameter AXI4_FULL_S_AXI_ARADDR_WIDTH  = 64;
parameter AXI4_FULL_S_AXI_ARUSER_WIDTH  = 1;
parameter AXI4_FULL_S_AXI_RDATA_WIDTH   = 256;
parameter AXI4_FULL_S_AXI_RUSER_WIDTH   = 1;
parameter AXI4_FULL_R_ID                = 0;
parameter AXI4_FULL_M_AXI_AWADDR_WIDTH  = 64;
parameter AXI4_FULL_M_AXI_AWUSER_WIDTH  = 1;
parameter AXI4_FULL_M_AXI_WDATA_WIDTH   = 256;
parameter AXI4_FULL_M_AXI_WUSER_WIDTH   = 1;
parameter AXI4_FULL_M_AXI_BUSER_WIDTH   = 1;
parameter AXI4_FULL_AW_ID               = 0;
parameter AXI4_FULL_S_AXI_AWADDR_WIDTH  = 64;
parameter AXI4_FULL_S_AXI_AWUSER_WIDTH  = 1;
parameter AXI4_FULL_S_AXI_WDATA_WIDTH   = 256;
parameter AXI4_FULL_S_AXI_WUSER_WIDTH   = 1;
parameter AXI4_FULL_S_AXI_BUSER_WIDTH   = 1;
parameter AXI4_FULL_B_ID                = 0;
parameter LOAD_INSNBITS                 = 128;
parameter STORE_INSNBITS                = 128;
parameter PEA_INSNBITS                  = 128;
parameter VCU_INSNBITS                  = 128;
localparam integer AXI4_FULL_M_AXI_DATA_BYTES = AXI4_FULL_M_AXI_WDATA_WIDTH / 8;
localparam integer AXI4_FULL_S_AXI_DATA_BYTES = AXI4_FULL_S_AXI_WDATA_WIDTH / 8;

parameter PCIE_AXI4_FULL_M_AXI_BURSTLENGTH   = 32;
parameter PCIE_AXI4_FULL_OUTSTANDING_DEPTH   = 8;
parameter PCIE_AXI4_FULL_M_AXI_ID_WIDTH      = 8;
parameter PCIE_AXI4_FULL_M_AXI_ARADDR_WIDTH  = 32;
parameter PCIE_AXI4_FULL_M_AXI_ARUSER_WIDTH  = 1;
parameter PCIE_AXI4_FULL_M_AXI_RDATA_WIDTH   = 256;
parameter PCIE_AXI4_FULL_M_AXI_RUSER_WIDTH   = 1;
parameter PCIE_AXI4_FULL_M_AXI_AWADDR_WIDTH  = 32;
parameter PCIE_AXI4_FULL_M_AXI_AWUSER_WIDTH  = 1;
parameter PCIE_AXI4_FULL_M_AXI_WDATA_WIDTH   = 256;
parameter PCIE_AXI4_FULL_M_AXI_WUSER_WIDTH   = 1;
parameter PCIE_AXI4_FULL_M_AXI_BUSER_WIDTH   = 1;
parameter PCIE_PERIPHERAL_R_ADDR_WIDTH       = 32;
parameter PCIE_PERIPHERAL_R_BUSRSTS_WIDTH    = 22;
parameter PCIE_PERIPHERAL_R_DATA_WIDTH       = 256;
parameter PCIE_PERIPHERAL_W_ADDR_WIDTH       = 32;
parameter PCIE_PERIPHERAL_W_BUSRSTS_WIDTH    = 22;
parameter PCIE_PERIPHERAL_W_DATA_WIDTH       = 256;
parameter PCIE_AXI4_FULL_M_AXI_MAX_4K        = 8;
parameter PCIE_AXI4_FULL_AR_ID               = 3;
parameter PCIE_AXI4_FULL_AW_ID               = 3;
localparam integer PCIE_AXI4_FULL_M_AXI_DATA_BYTES = AXI4_FULL_M_AXI_WDATA_WIDTH / 8;
localparam integer PCIE_AXI4_FULL_S_AXI_DATA_BYTES = AXI4_FULL_S_AXI_WDATA_WIDTH / 8;

parameter ddr_ID_WIDTH = 14;

reg         apb4_pclk;
reg         apb4_presetn;

reg         pcie_clk;
reg         pcie_rst_n;

reg         mcu_clk;
reg         mcu_rst_n;

wire        pcie_ven_msi_req;
wire [2:0]  pcie_ven_msi_func_num;
wire [2:0]  pcie_ven_msi_tc;
wire [4:0]  pcie_ven_msi_vector;
reg         pcie_msi_grant;
wire [31:0] pcie_highaddr;

localparam integer CMD_BITS = PCIE_PERIPHERAL_R_ADDR_WIDTH + PCIE_PERIPHERAL_R_BUSRSTS_WIDTH + 1 + PCIE_PERIPHERAL_R_DATA_WIDTH;

reg  [CMD_BITS-1:0] cmd;
reg         cmd_vld;
wire [31:0] cmd_rd_data;
                        
wire [31:0] apb4_paddr;
wire        apb4_pwrite;
wire        apb4_psel;
wire        apb4_penable;
wire [31:0] apb4_pwdata;
wire [31:0] apb4_prdata;
wire        apb4_pready;
wire        apb4_pslverr;
wire [3:0]  apb4_pstrb;
wire [2:0]  apb4_pprot;

assign apb4_paddr = 0;
assign apb4_pwrite = 0;
assign apb4_psel = 0;
assign apb4_penable = 0;
assign apb4_pwdata = 0;
assign apb4_pstrb = 0;
assign apb4_pprot = 0;

reg         axi4_clk;
reg         axi4_rst_n;
reg         logic_clk;
reg         logic_rst_n;

wire [7:0]                               mcu_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  mcu_M_AXI_ARADDR;
wire [7:0]                               mcu_M_AXI_ARLEN;
wire [2:0]                               mcu_M_AXI_ARSIZE;
wire [1:0]                               mcu_M_AXI_ARBURST;
wire                                     mcu_M_AXI_ARLOCK;
wire [3:0]                               mcu_M_AXI_ARCACHE;
wire [2:0]                               mcu_M_AXI_ARPROT;
wire [3:0]                               mcu_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  mcu_M_AXI_ARUSER;
wire                                     mcu_M_AXI_ARVALID;
wire                                     mcu_M_AXI_RREADY;
wire [7:0]                               mcu_M_AXI_AWID;
wire [AXI4_FULL_M_AXI_AWADDR_WIDTH-1:0]  mcu_M_AXI_AWADDR;
wire [7:0]                               mcu_M_AXI_AWLEN;
wire [2:0]                               mcu_M_AXI_AWSIZE;
wire [1:0]                               mcu_M_AXI_AWBURST;
wire                                     mcu_M_AXI_AWLOCK;
wire [3:0]                               mcu_M_AXI_AWCACHE;
wire [2:0]                               mcu_M_AXI_AWPROT;
wire [3:0]                               mcu_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  mcu_M_AXI_AWUSER;
wire                                     mcu_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   mcu_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    mcu_M_AXI_WSTRB;
wire                                     mcu_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   mcu_M_AXI_WUSER;
wire                                     mcu_M_AXI_WVALID;
wire                                     mcu_M_AXI_BREADY;
wire                                     mcu_M_AXI_ARREADY;
wire [7:0]                               mcu_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   mcu_M_AXI_RDATA;
wire [1:0]                               mcu_M_AXI_RRESP;
wire                                     mcu_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   mcu_M_AXI_RUSER;
wire                                     mcu_M_AXI_RVALID;
wire                                     mcu_M_AXI_AWREADY;
wire                                     mcu_M_AXI_WREADY;
wire [7:0]                               mcu_M_AXI_BID;
wire [1:0]                               mcu_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   mcu_M_AXI_BUSER;
wire                                     mcu_M_AXI_BVALID;

wire                                     serdes0_M_AXI_ARREADY;
wire [7:0]                               serdes0_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   serdes0_M_AXI_RDATA;
wire [1:0]                               serdes0_M_AXI_RRESP;
wire                                     serdes0_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   serdes0_M_AXI_RUSER;
wire                                     serdes0_M_AXI_RVALID;
wire                                     serdes0_M_AXI_AWREADY;
wire                                     serdes0_M_AXI_WREADY;
wire [7:0]                               serdes0_M_AXI_BID;
wire [1:0]                               serdes0_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   serdes0_M_AXI_BUSER;
wire                                     serdes0_M_AXI_BVALID;

wire [7:0]                               serdes0_S_AXI_ARID;
wire [AXI4_FULL_S_AXI_ARADDR_WIDTH-1:0]  serdes0_S_AXI_ARADDR;
wire [7:0]                               serdes0_S_AXI_ARLEN;
wire [2:0]                               serdes0_S_AXI_ARSIZE;
wire [1:0]                               serdes0_S_AXI_ARBURST;
wire                                     serdes0_S_AXI_ARLOCK;
wire [3:0]                               serdes0_S_AXI_ARCACHE;
wire [2:0]                               serdes0_S_AXI_ARPROT;
wire [3:0]                               serdes0_S_AXI_ARQOS;
wire [AXI4_FULL_S_AXI_ARUSER_WIDTH-1:0]  serdes0_S_AXI_ARUSER;
wire                                     serdes0_S_AXI_ARVALID;
wire                                     serdes0_S_AXI_RREADY;
wire [7:0]                               serdes0_S_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  serdes0_S_AXI_AWADDR;
wire [7:0]                               serdes0_S_AXI_AWLEN;
wire [2:0]                               serdes0_S_AXI_AWSIZE;
wire [1:0]                               serdes0_S_AXI_AWBURST;
wire                                     serdes0_S_AXI_AWLOCK;
wire [3:0]                               serdes0_S_AXI_AWCACHE;
wire [2:0]                               serdes0_S_AXI_AWPROT;
wire [3:0]                               serdes0_S_AXI_AWQOS;
wire [AXI4_FULL_S_AXI_AWUSER_WIDTH-1:0]  serdes0_S_AXI_AWUSER;
wire                                     serdes0_S_AXI_AWVALID;
wire [AXI4_FULL_S_AXI_WDATA_WIDTH-1:0]   serdes0_S_AXI_WDATA;
wire [AXI4_FULL_S_AXI_DATA_BYTES-1:0]    serdes0_S_AXI_WSTRB;
wire                                     serdes0_S_AXI_WLAST;
wire [AXI4_FULL_S_AXI_WUSER_WIDTH-1:0]   serdes0_S_AXI_WUSER;
wire                                     serdes0_S_AXI_WVALID;
wire                                     serdes0_S_AXI_BREADY;

wire                                     serdes1_M_AXI_ARREADY;
wire [7:0]                               serdes1_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   serdes1_M_AXI_RDATA;
wire [1:0]                               serdes1_M_AXI_RRESP;
wire                                     serdes1_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   serdes1_M_AXI_RUSER;
wire                                     serdes1_M_AXI_RVALID;
wire                                     serdes1_M_AXI_AWREADY;
wire                                     serdes1_M_AXI_WREADY;
wire [7:0]                               serdes1_M_AXI_BID;
wire [1:0]                               serdes1_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   serdes1_M_AXI_BUSER;
wire                                     serdes1_M_AXI_BVALID;

wire [7:0]                               serdes1_S_AXI_ARID;
wire [AXI4_FULL_S_AXI_ARADDR_WIDTH-1:0]  serdes1_S_AXI_ARADDR;
wire [7:0]                               serdes1_S_AXI_ARLEN;
wire [2:0]                               serdes1_S_AXI_ARSIZE;
wire [1:0]                               serdes1_S_AXI_ARBURST;
wire                                     serdes1_S_AXI_ARLOCK;
wire [3:0]                               serdes1_S_AXI_ARCACHE;
wire [2:0]                               serdes1_S_AXI_ARPROT;
wire [3:0]                               serdes1_S_AXI_ARQOS;
wire [AXI4_FULL_S_AXI_ARUSER_WIDTH-1:0]  serdes1_S_AXI_ARUSER;
wire                                     serdes1_S_AXI_ARVALID;
wire                                     serdes1_S_AXI_RREADY;

wire [7:0]                               serdes1_S_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  serdes1_S_AXI_AWADDR;
wire [7:0]                               serdes1_S_AXI_AWLEN;
wire [2:0]                               serdes1_S_AXI_AWSIZE;
wire [1:0]                               serdes1_S_AXI_AWBURST;
wire                                     serdes1_S_AXI_AWLOCK;
wire [3:0]                               serdes1_S_AXI_AWCACHE;
wire [2:0]                               serdes1_S_AXI_AWPROT;
wire [3:0]                               serdes1_S_AXI_AWQOS;
wire [AXI4_FULL_S_AXI_AWUSER_WIDTH-1:0]  serdes1_S_AXI_AWUSER;
wire                                     serdes1_S_AXI_AWVALID;
wire [AXI4_FULL_S_AXI_WDATA_WIDTH-1:0]   serdes1_S_AXI_WDATA;
wire [AXI4_FULL_S_AXI_DATA_BYTES-1:0]    serdes1_S_AXI_WSTRB;
wire                                     serdes1_S_AXI_WLAST;
wire [AXI4_FULL_S_AXI_WUSER_WIDTH-1:0]   serdes1_S_AXI_WUSER;
wire                                     serdes1_S_AXI_WVALID;
wire                                     serdes1_S_AXI_BREADY;

wire                                     ddr0_M_AXI_ARREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr0_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   ddr0_M_AXI_RDATA;
wire [1:0]                               ddr0_M_AXI_RRESP;
wire                                     ddr0_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   ddr0_M_AXI_RUSER;
wire                                     ddr0_M_AXI_RVALID;
wire                                     ddr0_M_AXI_AWREADY;
wire                                     ddr0_M_AXI_WREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr0_M_AXI_BID;
wire [1:0]                               ddr0_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   ddr0_M_AXI_BUSER;
wire                                     ddr0_M_AXI_BVALID;

wire                                     ddr1_M_AXI_ARREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr1_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   ddr1_M_AXI_RDATA;
wire [1:0]                               ddr1_M_AXI_RRESP;
wire                                     ddr1_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   ddr1_M_AXI_RUSER;
wire                                     ddr1_M_AXI_RVALID;
wire                                     ddr1_M_AXI_AWREADY;
wire                                     ddr1_M_AXI_WREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr1_M_AXI_BID;
wire [1:0]                               ddr1_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   ddr1_M_AXI_BUSER;
wire                                     ddr1_M_AXI_BVALID;

reg                                      clk;
reg                                      rst_n;

assign mcu_M_AXI_AWID    = 2;
assign mcu_M_AXI_AWADDR  = 0;
assign mcu_M_AXI_AWLEN   = 0;
assign mcu_M_AXI_AWSIZE  = 0;
assign mcu_M_AXI_AWBURST = 0;
assign mcu_M_AXI_AWLOCK  = 0;
assign mcu_M_AXI_AWCACHE = 0;
assign mcu_M_AXI_AWPROT  = 0;
assign mcu_M_AXI_AWQOS   = 0;
assign mcu_M_AXI_AWUSER  = 0;
assign mcu_M_AXI_AWVALID = 0;
assign mcu_M_AXI_WDATA   = 0;
assign mcu_M_AXI_WSTRB   = 0;
assign mcu_M_AXI_WLAST   = 0;
assign mcu_M_AXI_WUSER   = 0;
assign mcu_M_AXI_WVALID  = 0;
assign mcu_M_AXI_BREADY  = 0;
assign mcu_M_AXI_ARID    = 2;
assign mcu_M_AXI_ARADDR  = 0;
assign mcu_M_AXI_ARLEN   = 0;
assign mcu_M_AXI_ARSIZE  = 0;
assign mcu_M_AXI_ARBURST = 0;
assign mcu_M_AXI_ARLOCK  = 0;
assign mcu_M_AXI_ARCACHE = 0;
assign mcu_M_AXI_ARPROT  = 0;
assign mcu_M_AXI_ARQOS   = 0;
assign mcu_M_AXI_ARUSER  = 0;
assign mcu_M_AXI_ARVALID = 0;
assign mcu_M_AXI_RREADY  = 0;

assign serdes1_S_AXI_AWID    = 2;
assign serdes1_S_AXI_AWADDR  = 0;
assign serdes1_S_AXI_AWLEN   = 0;
assign serdes1_S_AXI_AWSIZE  = 0;
assign serdes1_S_AXI_AWBURST = 0;
assign serdes1_S_AXI_AWLOCK  = 0;
assign serdes1_S_AXI_AWCACHE = 0;
assign serdes1_S_AXI_AWPROT  = 0;
assign serdes1_S_AXI_AWQOS   = 0;
assign serdes1_S_AXI_AWUSER  = 0;
assign serdes1_S_AXI_AWVALID = 0;
assign serdes1_S_AXI_WDATA   = 0;
assign serdes1_S_AXI_WSTRB   = 0;
assign serdes1_S_AXI_WLAST   = 0;
assign serdes1_S_AXI_WUSER   = 0;
assign serdes1_S_AXI_WVALID  = 0;
assign serdes1_S_AXI_BREADY  = 0;
assign serdes1_S_AXI_ARID    = 2;
assign serdes1_S_AXI_ARADDR  = 0;
assign serdes1_S_AXI_ARLEN   = 0;
assign serdes1_S_AXI_ARSIZE  = 0;
assign serdes1_S_AXI_ARBURST = 0;
assign serdes1_S_AXI_ARLOCK  = 0;
assign serdes1_S_AXI_ARCACHE = 0;
assign serdes1_S_AXI_ARPROT  = 0;
assign serdes1_S_AXI_ARQOS   = 0;
assign serdes1_S_AXI_ARUSER  = 0;
assign serdes1_S_AXI_ARVALID = 0;
assign serdes1_S_AXI_RREADY  = 0;

assign serdes0_M_AXI_AWREADY = 0;
assign serdes0_M_AXI_WREADY  = 0;
assign serdes0_M_AXI_BID     = 0;
assign serdes0_M_AXI_BRESP   = 0;
assign serdes0_M_AXI_BUSER   = 0;
assign serdes0_M_AXI_BVALID  = 0;
assign serdes0_M_AXI_ARREADY = 0;
assign serdes0_M_AXI_RID     = 0;
assign serdes0_M_AXI_RDATA   = 0;
assign serdes0_M_AXI_RRESP   = 0;
assign serdes0_M_AXI_RLAST   = 0;
assign serdes0_M_AXI_RUSER   = 0;
assign serdes0_M_AXI_RVALID  = 0;

assign serdes1_M_AXI_AWREADY = 0;
assign serdes1_M_AXI_WREADY  = 0;
assign serdes1_M_AXI_BID     = 0;
assign serdes1_M_AXI_BRESP   = 0;
assign serdes1_M_AXI_BUSER   = 0;
assign serdes1_M_AXI_BVALID  = 0;
assign serdes1_M_AXI_ARREADY = 0;
assign serdes1_M_AXI_RID     = 0;
assign serdes1_M_AXI_RDATA   = 0;
assign serdes1_M_AXI_RRESP   = 0;
assign serdes1_M_AXI_RLAST   = 0;
assign serdes1_M_AXI_RUSER   = 0;
assign serdes1_M_AXI_RVALID  = 0;

wire [7:0]                               serdes0_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  serdes0_M_AXI_ARADDR;
wire [7:0]                               serdes0_M_AXI_ARLEN;
wire [2:0]                               serdes0_M_AXI_ARSIZE;
wire [1:0]                               serdes0_M_AXI_ARBURST;
wire                                     serdes0_M_AXI_ARLOCK;
wire [3:0]                               serdes0_M_AXI_ARCACHE;
wire [2:0]                               serdes0_M_AXI_ARPROT;
wire [3:0]                               serdes0_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  serdes0_M_AXI_ARUSER;
wire                                     serdes0_M_AXI_ARVALID;
wire                                     serdes0_M_AXI_RREADY;
wire [7:0]                               serdes0_M_AXI_AWID;
wire [AXI4_FULL_M_AXI_AWADDR_WIDTH-1:0]  serdes0_M_AXI_AWADDR;
wire [7:0]                               serdes0_M_AXI_AWLEN;
wire [2:0]                               serdes0_M_AXI_AWSIZE;
wire [1:0]                               serdes0_M_AXI_AWBURST;
wire                                     serdes0_M_AXI_AWLOCK;
wire [3:0]                               serdes0_M_AXI_AWCACHE;
wire [2:0]                               serdes0_M_AXI_AWPROT;
wire [3:0]                               serdes0_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  serdes0_M_AXI_AWUSER;
wire                                     serdes0_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   serdes0_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    serdes0_M_AXI_WSTRB;
wire                                     serdes0_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   serdes0_M_AXI_WUSER;
wire                                     serdes0_M_AXI_WVALID;
wire                                     serdes0_M_AXI_BREADY;

wire [7:0]                               serdes1_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  serdes1_M_AXI_ARADDR;
wire [7:0]                               serdes1_M_AXI_ARLEN;
wire [2:0]                               serdes1_M_AXI_ARSIZE;
wire [1:0]                               serdes1_M_AXI_ARBURST;
wire                                     serdes1_M_AXI_ARLOCK;
wire [3:0]                               serdes1_M_AXI_ARCACHE;
wire [2:0]                               serdes1_M_AXI_ARPROT;
wire [3:0]                               serdes1_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  serdes1_M_AXI_ARUSER;
wire                                     serdes1_M_AXI_ARVALID;
wire                                     serdes1_M_AXI_RREADY;

wire                                     serdes1_S_AXI_ARREADY;
wire [7:0]                               serdes1_S_AXI_RID;
wire [AXI4_FULL_S_AXI_RDATA_WIDTH-1:0]   serdes1_S_AXI_RDATA;
wire [1:0]                               serdes1_S_AXI_RRESP;
wire                                     serdes1_S_AXI_RLAST;
wire [AXI4_FULL_S_AXI_RUSER_WIDTH-1:0]   serdes1_S_AXI_RUSER;
wire                                     serdes1_S_AXI_RVALID;

wire [7:0]                               serdes1_M_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  serdes1_M_AXI_AWADDR;
wire [7:0]                               serdes1_M_AXI_AWLEN;
wire [2:0]                               serdes1_M_AXI_AWSIZE;
wire [1:0]                               serdes1_M_AXI_AWBURST;
wire                                     serdes1_M_AXI_AWLOCK;
wire [3:0]                               serdes1_M_AXI_AWCACHE;
wire [2:0]                               serdes1_M_AXI_AWPROT;
wire [3:0]                               serdes1_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  serdes1_M_AXI_AWUSER;
wire                                     serdes1_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   serdes1_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    serdes1_M_AXI_WSTRB;
wire                                     serdes1_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   serdes1_M_AXI_WUSER;
wire                                     serdes1_M_AXI_WVALID;
wire                                     serdes1_M_AXI_BREADY;

wire                                     serdes1_S_AXI_AWREADY;
wire                                     serdes1_S_AXI_WREADY;
wire [7:0]                               serdes1_S_AXI_BID;
wire [1:0]                               serdes1_S_AXI_BRESP;
wire [AXI4_FULL_S_AXI_BUSER_WIDTH-1:0]   serdes1_S_AXI_BUSER;
wire                                     serdes1_S_AXI_BVALID;

wire [ddr_ID_WIDTH-1:0]                  ddr0_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  ddr0_M_AXI_ARADDR;
wire [7:0]                               ddr0_M_AXI_ARLEN;
wire [2:0]                               ddr0_M_AXI_ARSIZE;
wire [1:0]                               ddr0_M_AXI_ARBURST;
wire                                     ddr0_M_AXI_ARLOCK;
wire [3:0]                               ddr0_M_AXI_ARCACHE;
wire [2:0]                               ddr0_M_AXI_ARPROT;
wire [3:0]                               ddr0_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  ddr0_M_AXI_ARUSER;
wire                                     ddr0_M_AXI_ARVALID;
wire                                     ddr0_M_AXI_RREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr0_M_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  ddr0_M_AXI_AWADDR;
wire [7:0]                               ddr0_M_AXI_AWLEN;
wire [2:0]                               ddr0_M_AXI_AWSIZE;
wire [1:0]                               ddr0_M_AXI_AWBURST;
wire                                     ddr0_M_AXI_AWLOCK;
wire [3:0]                               ddr0_M_AXI_AWCACHE;
wire [2:0]                               ddr0_M_AXI_AWPROT;
wire [3:0]                               ddr0_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  ddr0_M_AXI_AWUSER;
wire                                     ddr0_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   ddr0_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    ddr0_M_AXI_WSTRB;
wire                                     ddr0_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   ddr0_M_AXI_WUSER;
wire                                     ddr0_M_AXI_WVALID;
wire                                     ddr0_M_AXI_BREADY;

wire [ddr_ID_WIDTH-1:0]                  ddr1_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  ddr1_M_AXI_ARADDR;
wire [7:0]                               ddr1_M_AXI_ARLEN;
wire [2:0]                               ddr1_M_AXI_ARSIZE;
wire [1:0]                               ddr1_M_AXI_ARBURST;
wire                                     ddr1_M_AXI_ARLOCK;
wire [3:0]                               ddr1_M_AXI_ARCACHE;
wire [2:0]                               ddr1_M_AXI_ARPROT;
wire [3:0]                               ddr1_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  ddr1_M_AXI_ARUSER;
wire                                     ddr1_M_AXI_ARVALID;
wire                                     ddr1_M_AXI_RREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr1_M_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  ddr1_M_AXI_AWADDR;
wire [7:0]                               ddr1_M_AXI_AWLEN;
wire [2:0]                               ddr1_M_AXI_AWSIZE;
wire [1:0]                               ddr1_M_AXI_AWBURST;
wire                                     ddr1_M_AXI_AWLOCK;
wire [3:0]                               ddr1_M_AXI_AWCACHE;
wire [2:0]                               ddr1_M_AXI_AWPROT;
wire [3:0]                               ddr1_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  ddr1_M_AXI_AWUSER;
wire                                     ddr1_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   ddr1_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    ddr1_M_AXI_WSTRB;
wire                                     ddr1_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   ddr1_M_AXI_WUSER;
wire                                     ddr1_M_AXI_WVALID;
wire                                     ddr1_M_AXI_BREADY;


wire                                         pcie_axi4_full_M_AXI_AWREADY;
wire                                         pcie_axi4_full_M_AXI_WREADY;
wire [PCIE_AXI4_FULL_M_AXI_ID_WIDTH-1:0]     pcie_axi4_full_M_AXI_BID;
wire [1:0]                                   pcie_axi4_full_M_AXI_BRESP;
wire [PCIE_AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]  pcie_axi4_full_M_AXI_BUSER;
wire                                         pcie_axi4_full_M_AXI_BVALID;
wire                                         pcie_axi4_full_M_AXI_ARREADY;
wire [PCIE_AXI4_FULL_M_AXI_ID_WIDTH-1:0]     pcie_axi4_full_M_AXI_RID;
wire [PCIE_AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]  pcie_axi4_full_M_AXI_RDATA;
wire [1:0]                                   pcie_axi4_full_M_AXI_RRESP;
wire                                         pcie_axi4_full_M_AXI_RLAST;
wire [PCIE_AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]  pcie_axi4_full_M_AXI_RUSER;
wire                                         pcie_axi4_full_M_AXI_RVALID;
wire [PCIE_AXI4_FULL_M_AXI_ID_WIDTH-1:0]     pcie_axi4_full_M_AXI_AWID;
wire [PCIE_AXI4_FULL_M_AXI_AWADDR_WIDTH-1:0] pcie_axi4_full_M_AXI_AWADDR;
wire [7:0]                                   pcie_axi4_full_M_AXI_AWLEN;
wire [2:0]                                   pcie_axi4_full_M_AXI_AWSIZE;
wire [1:0]                                   pcie_axi4_full_M_AXI_AWBURST;
wire                                         pcie_axi4_full_M_AXI_AWLOCK;
wire [3:0]                                   pcie_axi4_full_M_AXI_AWCACHE;
wire [2:0]                                   pcie_axi4_full_M_AXI_AWPROT;
wire [3:0]                                   pcie_axi4_full_M_AXI_AWQOS;
wire [PCIE_AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0] pcie_axi4_full_M_AXI_AWUSER;
wire                                         pcie_axi4_full_M_AXI_AWVALID;
wire [PCIE_AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]  pcie_axi4_full_M_AXI_WDATA;
wire [PCIE_AXI4_FULL_M_AXI_DATA_BYTES-1:0]   pcie_axi4_full_M_AXI_WSTRB;
wire                                         pcie_axi4_full_M_AXI_WLAST;
wire [PCIE_AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]  pcie_axi4_full_M_AXI_WUSER;
wire                                         pcie_axi4_full_M_AXI_WVALID;
wire                                         pcie_axi4_full_M_AXI_BREADY;
wire [PCIE_AXI4_FULL_M_AXI_ID_WIDTH-1:0]     pcie_axi4_full_M_AXI_ARID;
wire [PCIE_AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0] pcie_axi4_full_M_AXI_ARADDR;
wire [7:0]                                   pcie_axi4_full_M_AXI_ARLEN;
wire [2:0]                                   pcie_axi4_full_M_AXI_ARSIZE;
wire [1:0]                                   pcie_axi4_full_M_AXI_ARBURST;
wire                                         pcie_axi4_full_M_AXI_ARLOCK;
wire [3:0]                                   pcie_axi4_full_M_AXI_ARCACHE;
wire [2:0]                                   pcie_axi4_full_M_AXI_ARPROT;
wire [3:0]                                   pcie_axi4_full_M_AXI_ARQOS;
wire [PCIE_AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0] pcie_axi4_full_M_AXI_ARUSER;
wire                                         pcie_axi4_full_M_AXI_ARVALID;
wire                                         pcie_axi4_full_M_AXI_RREADY;
wire [63:0]                                  pcie_routed_axi_araddr;
wire [63:0]                                  pcie_routed_axi_awaddr;

axi_master #(
  .AXI4_FULL_M_AXI_BURSTLENGTH  ( PCIE_AXI4_FULL_M_AXI_BURSTLENGTH  ),
  .AXI4_FULL_OUTSTANDING_DEPTH  ( PCIE_AXI4_FULL_OUTSTANDING_DEPTH  ),
  .AXI4_FULL_M_AXI_ID_WIDTH     ( PCIE_AXI4_FULL_M_AXI_ID_WIDTH     ),
  .AXI4_FULL_M_AXI_ARADDR_WIDTH ( PCIE_AXI4_FULL_M_AXI_ARADDR_WIDTH ),
  .AXI4_FULL_M_AXI_ARUSER_WIDTH ( PCIE_AXI4_FULL_M_AXI_ARUSER_WIDTH ),
  .AXI4_FULL_M_AXI_RDATA_WIDTH  ( PCIE_AXI4_FULL_M_AXI_RDATA_WIDTH  ),
  .AXI4_FULL_M_AXI_RUSER_WIDTH  ( PCIE_AXI4_FULL_M_AXI_RUSER_WIDTH  ),
  .AXI4_FULL_M_AXI_AWADDR_WIDTH ( PCIE_AXI4_FULL_M_AXI_AWADDR_WIDTH ),
  .AXI4_FULL_M_AXI_AWUSER_WIDTH ( PCIE_AXI4_FULL_M_AXI_AWUSER_WIDTH ),
  .AXI4_FULL_M_AXI_WDATA_WIDTH  ( PCIE_AXI4_FULL_M_AXI_WDATA_WIDTH  ),
  .AXI4_FULL_M_AXI_WUSER_WIDTH  ( PCIE_AXI4_FULL_M_AXI_WUSER_WIDTH  ),
  .AXI4_FULL_M_AXI_BUSER_WIDTH  ( PCIE_AXI4_FULL_M_AXI_BUSER_WIDTH  ),
  .PERIPHERAL_R_ADDR_WIDTH      ( PCIE_PERIPHERAL_R_ADDR_WIDTH      ),
  .PERIPHERAL_R_BUSRSTS_WIDTH   ( PCIE_PERIPHERAL_R_BUSRSTS_WIDTH   ),
  .PERIPHERAL_R_DATA_WIDTH      ( PCIE_PERIPHERAL_R_DATA_WIDTH      ),
  .PERIPHERAL_W_ADDR_WIDTH      ( PCIE_PERIPHERAL_W_ADDR_WIDTH      ),
  .PERIPHERAL_W_BUSRSTS_WIDTH   ( PCIE_PERIPHERAL_W_BUSRSTS_WIDTH   ),
  .PERIPHERAL_W_DATA_WIDTH      ( PCIE_PERIPHERAL_W_DATA_WIDTH      ),
  .AXI4_FULL_M_AXI_MAX_4K       ( PCIE_AXI4_FULL_M_AXI_MAX_4K       )
) u_axi_master(
  .axi4_clk                ( axi4_clk                     ),
  .axi4_rst_n              ( axi4_rst_n                   ),
  .axi4_full_M_AXI_AWREADY ( pcie_axi4_full_M_AXI_AWREADY ),
  .axi4_full_M_AXI_WREADY  ( pcie_axi4_full_M_AXI_WREADY  ),
  .axi4_full_M_AXI_BID     ( pcie_axi4_full_M_AXI_BID     ),
  .axi4_full_M_AXI_BRESP   ( pcie_axi4_full_M_AXI_BRESP   ),
  .axi4_full_M_AXI_BUSER   ( pcie_axi4_full_M_AXI_BUSER   ),
  .axi4_full_M_AXI_BVALID  ( pcie_axi4_full_M_AXI_BVALID  ),
  .axi4_full_M_AXI_ARREADY ( pcie_axi4_full_M_AXI_ARREADY ),
  .axi4_full_M_AXI_RID     ( pcie_axi4_full_M_AXI_RID     ),
  .axi4_full_M_AXI_RDATA   ( pcie_axi4_full_M_AXI_RDATA   ),
  .axi4_full_M_AXI_RRESP   ( pcie_axi4_full_M_AXI_RRESP   ),
  .axi4_full_M_AXI_RLAST   ( pcie_axi4_full_M_AXI_RLAST   ),
  .axi4_full_M_AXI_RUSER   ( pcie_axi4_full_M_AXI_RUSER   ),
  .axi4_full_M_AXI_RVALID  ( pcie_axi4_full_M_AXI_RVALID  ),
  .cmd                     ( cmd                          ),
  .cmd_vld                 ( cmd_vld                      ),
  .axi4_full_M_AXI_AWID    ( pcie_axi4_full_M_AXI_AWID    ),
  .axi4_full_M_AXI_AWADDR  ( pcie_axi4_full_M_AXI_AWADDR  ),
  .axi4_full_M_AXI_AWLEN   ( pcie_axi4_full_M_AXI_AWLEN   ),
  .axi4_full_M_AXI_AWSIZE  ( pcie_axi4_full_M_AXI_AWSIZE  ),
  .axi4_full_M_AXI_AWBURST ( pcie_axi4_full_M_AXI_AWBURST ),
  .axi4_full_M_AXI_AWLOCK  ( pcie_axi4_full_M_AXI_AWLOCK  ),
  .axi4_full_M_AXI_AWCACHE ( pcie_axi4_full_M_AXI_AWCACHE ),
  .axi4_full_M_AXI_AWPROT  ( pcie_axi4_full_M_AXI_AWPROT  ),
  .axi4_full_M_AXI_AWQOS   ( pcie_axi4_full_M_AXI_AWQOS   ),
  .axi4_full_M_AXI_AWUSER  ( pcie_axi4_full_M_AXI_AWUSER  ),
  .axi4_full_M_AXI_AWVALID ( pcie_axi4_full_M_AXI_AWVALID ),
  .axi4_full_M_AXI_WDATA   ( pcie_axi4_full_M_AXI_WDATA   ),
  .axi4_full_M_AXI_WSTRB   ( pcie_axi4_full_M_AXI_WSTRB   ),
  .axi4_full_M_AXI_WLAST   ( pcie_axi4_full_M_AXI_WLAST   ),
  .axi4_full_M_AXI_WUSER   ( pcie_axi4_full_M_AXI_WUSER   ),
  .axi4_full_M_AXI_WVALID  ( pcie_axi4_full_M_AXI_WVALID  ),
  .axi4_full_M_AXI_BREADY  ( pcie_axi4_full_M_AXI_BREADY  ),
  .axi4_full_M_AXI_ARID    ( pcie_axi4_full_M_AXI_ARID    ),
  .axi4_full_M_AXI_ARADDR  ( pcie_axi4_full_M_AXI_ARADDR  ),
  .axi4_full_M_AXI_ARLEN   ( pcie_axi4_full_M_AXI_ARLEN   ),
  .axi4_full_M_AXI_ARSIZE  ( pcie_axi4_full_M_AXI_ARSIZE  ),
  .axi4_full_M_AXI_ARBURST ( pcie_axi4_full_M_AXI_ARBURST ),
  .axi4_full_M_AXI_ARLOCK  ( pcie_axi4_full_M_AXI_ARLOCK  ),
  .axi4_full_M_AXI_ARCACHE ( pcie_axi4_full_M_AXI_ARCACHE ),
  .axi4_full_M_AXI_ARPROT  ( pcie_axi4_full_M_AXI_ARPROT  ),
  .axi4_full_M_AXI_ARQOS   ( pcie_axi4_full_M_AXI_ARQOS   ),
  .axi4_full_M_AXI_ARUSER  ( pcie_axi4_full_M_AXI_ARUSER  ),
  .axi4_full_M_AXI_ARVALID ( pcie_axi4_full_M_AXI_ARVALID ),
  .axi4_full_M_AXI_RREADY  ( pcie_axi4_full_M_AXI_RREADY  )
);

parameter time_step = 1;

reg cmd_vld_i_reg;

reg [31:0] config_regs[0:32];

initial begin
  $readmemh("../bench/reg_data.txt", config_regs);
end

initial begin
 // rst; 
  pcie_msi_grant = 0;

  axi4_clk   = 0;
  pcie_clk  = 0;
  logic_clk = 0;
  mcu_clk = 0;
  apb4_pclk = 0;
  mcu_rst_n = 1;
  apb4_presetn = 1;
  logic_rst_n = 1;
  axi4_rst_n = 1;
  pcie_rst_n = 1;
  cmd = 65'b0;
  cmd_vld = 0;
  #10 apb4_presetn = 0;
  logic_rst_n = 0;
  axi4_rst_n = 0;
  pcie_rst_n = 0;
  mcu_rst_n = 0;
  #10 apb4_presetn = 1;
  logic_rst_n = 1;
  axi4_rst_n = 1;
  pcie_rst_n = 1;
  mcu_rst_n = 1;

  #100 cmd_in_wr(cmd, 0, 1);
  
  @(posedge axi4_clk) cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h20, config_regs[0]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h40, config_regs[1]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h60, config_regs[2]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h80, config_regs[3]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'ha0, config_regs[4]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'hc0, config_regs[5]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'he0, config_regs[6]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h100, config_regs[7]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h120, config_regs[8]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(posedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h140, config_regs[9]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h160, config_regs[10]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h180, config_regs[11]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1a0, config_regs[12]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1c0, config_regs[13]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1e0, config_regs[14]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h200, config_regs[15]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h220, config_regs[16]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h240, config_regs[17]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h260, config_regs[18]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h280, config_regs[19]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2a0, config_regs[20]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2c0, config_regs[21]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2e0, config_regs[22]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h300, config_regs[23]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h320, config_regs[24]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h340, config_regs[25]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h360, config_regs[26]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h380, config_regs[27]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h3a0, config_regs[28]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h3c0, config_regs[29]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h3e0, config_regs[30]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h440, 1);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h860, 1);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'ha00, 2);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 0, 2);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  wait(pcie_ven_msi_req == 1 && pcie_ven_msi_vector == 1)
  pcie_msi_grant = 1;
  #15000 pcie_msi_grant = 0;
  wait(pcie_ven_msi_req == 1 && pcie_ven_msi_vector == 4)
  pcie_msi_grant = 1;
  #995.5 pcie_msi_grant = 0;

  cmd_in_wr(cmd, 0, 1);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h20, 'h60);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h40, config_regs[1]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h60, config_regs[2]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h80, config_regs[3]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'ha0, config_regs[4]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'hc0, config_regs[5]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'he0, config_regs[6]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h100, config_regs[7]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h120, config_regs[8]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(posedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h140, config_regs[9]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h160, config_regs[10]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h180, config_regs[11]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1a0, config_regs[12]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1c0, config_regs[13]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1e0, config_regs[14]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h200, config_regs[15]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h220, config_regs[16]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h240, config_regs[17]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h260, config_regs[18]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h280, config_regs[19]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2a0, config_regs[20]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2c0, config_regs[21]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2e0, config_regs[22]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h300, config_regs[23]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h320, config_regs[24]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h340, config_regs[25]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h360, config_regs[26]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h380, config_regs[27]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h3a0, config_regs[28]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h3c0, 'h0);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h3e0, 'h0);
  @(negedge axi4_clk) cmd_vld = 0;

  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 0, 2);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
end

always #1 axi4_clk = ~axi4_clk;
always #1 logic_clk = ~logic_clk;
always #2 apb4_pclk = ~apb4_pclk;
always #2.5 pcie_clk = ~pcie_clk;

//-- RST
task rst;
  begin
    apb4_pclk    = 1;
    apb4_presetn  = 1;
    cmd     = 56'b0;
    cmd_vld = 0;
    #20 apb4_presetn = 0;
    #10 apb4_presetn = 1;
  end
endtask

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  cmd_vld_i_reg <= cmd_vld;
end

//-- write
task cmd_in_wr;
  output [CMD_BITS-1:0] cmd;
  input  [PCIE_AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0] addr;
  input  [PCIE_AXI4_FULL_M_AXI_RDATA_WIDTH-1:0] data;

  begin
    cmd_vld = 1;
    cmd     = {1'b1, 8'd0, data, addr};
  end
endtask

// //-- read
// task cmd_in_rd;
//   output [55:0] cmd;
//   input  [55:0] data ;
//   output [31:0] prdata;
//   input  [31:0] rd_data;

//   begin
//     cmd = data;
//     cmd_vld = 1;
//     #20 cmd_vld = 0;
//   end
// endtask
initial begin
  #150000 $finish;
end

// always @(posedge pcie_clk or negedge pcie_rst_n) begin
//   if (!pcie_rst_n) begin
//     pcie_msi_grant <= 0;
//   end
//   else begin
//     if (pcie_ven_msi_req) begin
//       #1000 pcie_msi_grant <= 1;
//     end
//     else begin
//       pcie_msi_grant <= 0;
//     end
//   end
// end

npu_top_chiplet #(
  .AXI4_FULL_S_AXI_BURSTLENGTH  ( AXI4_FULL_S_AXI_BURSTLENGTH  ),
  .AXI4_FULL_M_AXI_BURSTLENGTH  ( AXI4_FULL_M_AXI_BURSTLENGTH  ),
  .AXI4_FULL_M_AXI_MAX_4K       ( AXI4_FULL_M_AXI_MAX_4K       ),
  .AXI4_FULL_S_AXI_MAX_4K       ( AXI4_FULL_S_AXI_MAX_4K       ),
  .AXI4_FULL_OUTSTANDING_DEPTH  ( AXI4_FULL_OUTSTANDING_DEPTH  ),
  .AXI4_FULL_M_AXI_ID_WIDTH     ( AXI4_FULL_M_AXI_ID_WIDTH   ),
  .AXI4_FULL_M_AXI_ARADDR_WIDTH ( AXI4_FULL_M_AXI_ARADDR_WIDTH ),
  .AXI4_FULL_M_AXI_ARUSER_WIDTH ( AXI4_FULL_M_AXI_ARUSER_WIDTH ),
  .AXI4_FULL_M_AXI_RDATA_WIDTH  ( AXI4_FULL_M_AXI_RDATA_WIDTH  ),
  .AXI4_FULL_M_AXI_RUSER_WIDTH  ( AXI4_FULL_M_AXI_RUSER_WIDTH  ),
  .AXI4_FULL_S_AXI_ARADDR_WIDTH ( AXI4_FULL_S_AXI_ARADDR_WIDTH ),
  .AXI4_FULL_S_AXI_ARUSER_WIDTH ( AXI4_FULL_S_AXI_ARUSER_WIDTH ),
  .AXI4_FULL_S_AXI_ID_WIDTH     ( AXI4_FULL_S_AXI_ID_WIDTH     ),
  .AXI4_FULL_S_AXI_RDATA_WIDTH  ( AXI4_FULL_S_AXI_RDATA_WIDTH  ),
  .AXI4_FULL_S_AXI_RUSER_WIDTH  ( AXI4_FULL_S_AXI_RUSER_WIDTH  ),
  .AXI4_FULL_M_AXI_AWADDR_WIDTH ( AXI4_FULL_M_AXI_AWADDR_WIDTH ),
  .AXI4_FULL_M_AXI_AWUSER_WIDTH ( AXI4_FULL_M_AXI_AWUSER_WIDTH ),
  .AXI4_FULL_M_AXI_WDATA_WIDTH  ( AXI4_FULL_M_AXI_WDATA_WIDTH  ),
  .AXI4_FULL_M_AXI_WUSER_WIDTH  ( AXI4_FULL_M_AXI_WUSER_WIDTH  ),
  .AXI4_FULL_M_AXI_BUSER_WIDTH  ( AXI4_FULL_M_AXI_BUSER_WIDTH  ),
  .AXI4_FULL_S_AXI_AWADDR_WIDTH ( AXI4_FULL_S_AXI_AWADDR_WIDTH ),
  .AXI4_FULL_S_AXI_AWUSER_WIDTH ( AXI4_FULL_S_AXI_AWUSER_WIDTH ),
  .AXI4_FULL_S_AXI_WDATA_WIDTH  ( AXI4_FULL_S_AXI_WDATA_WIDTH  ),
  .AXI4_FULL_S_AXI_WUSER_WIDTH  ( AXI4_FULL_S_AXI_WUSER_WIDTH  ),
  .AXI4_FULL_S_AXI_BUSER_WIDTH  ( AXI4_FULL_S_AXI_BUSER_WIDTH  ),
  .LOAD_INSNBITS                ( LOAD_INSNBITS                ),
  .STORE_INSNBITS               ( STORE_INSNBITS               ),
  .PEA_INSNBITS                 ( PEA_INSNBITS                 ),
  .VCU_INSNBITS                 ( VCU_INSNBITS                 )
) u_npu_top_chiplet(
  .mode_sel              ( 3'b001                               ),
  .mcu_clk               ( mcu_clk                              ),
  .mcu_rst_n             ( mcu_rst_n                            ),
  .axi4_clk              ( axi4_clk                             ),
  .axi4_rst_n            ( axi4_rst_n                           ),
  .apb4_pclk             ( apb4_pclk                            ),
  .apb4_presetn          ( apb4_presetn                         ),
  .apb4_paddr            ( apb4_paddr                           ),
  .apb4_psel             ( apb4_psel                            ),
  .apb4_penable          ( apb4_penable                         ),
  .apb4_pwrite           ( apb4_pwrite                          ),
  .apb4_pwdata           ( apb4_pwdata                          ),
  .apb4_pstrb            ( apb4_pstrb                           ),
  .apb4_pprot            ( apb4_pprot                           ),

  .serdes0_M_AXI_ARREADY ( serdes0_M_AXI_ARREADY                ),
  .serdes0_M_AXI_RID     ( serdes0_M_AXI_RID                    ),
  .serdes0_M_AXI_RDATA   ( serdes0_M_AXI_RDATA                  ),
  .serdes0_M_AXI_RRESP   ( serdes0_M_AXI_RRESP                  ),
  .serdes0_M_AXI_RLAST   ( serdes0_M_AXI_RLAST                  ),
  .serdes0_M_AXI_RUSER   ( serdes0_M_AXI_RUSER                  ),
  .serdes0_M_AXI_RVALID  ( serdes0_M_AXI_RVALID                 ),
  .serdes0_M_AXI_AWREADY ( serdes0_M_AXI_AWREADY                ),
  .serdes0_M_AXI_WREADY  ( serdes0_M_AXI_WREADY                 ),
  .serdes0_M_AXI_BID     ( serdes0_M_AXI_BID                    ),
  .serdes0_M_AXI_BRESP   ( serdes0_M_AXI_BRESP                  ),
  .serdes0_M_AXI_BUSER   ( serdes0_M_AXI_BUSER                  ),
  .serdes0_M_AXI_BVALID  ( serdes0_M_AXI_BVALID                 ),
  .serdes0_M_AXI_ARID    ( serdes0_M_AXI_ARID                   ),
  .serdes0_M_AXI_ARADDR  ( serdes0_M_AXI_ARADDR                 ),
  .serdes0_M_AXI_ARLEN   ( serdes0_M_AXI_ARLEN                  ),
  .serdes0_M_AXI_ARSIZE  ( serdes0_M_AXI_ARSIZE                 ),
  .serdes0_M_AXI_ARBURST ( serdes0_M_AXI_ARBURST                ),
  .serdes0_M_AXI_ARLOCK  ( serdes0_M_AXI_ARLOCK                 ),
  .serdes0_M_AXI_ARCACHE ( serdes0_M_AXI_ARCACHE                ),
  .serdes0_M_AXI_ARPROT  ( serdes0_M_AXI_ARPROT                 ),
  .serdes0_M_AXI_ARQOS   ( serdes0_M_AXI_ARQOS                  ),
  .serdes0_M_AXI_ARUSER  ( serdes0_M_AXI_ARUSER                 ),
  .serdes0_M_AXI_ARVALID ( serdes0_M_AXI_ARVALID                ),
  .serdes0_M_AXI_RREADY  ( serdes0_M_AXI_RREADY                 ),
  .serdes0_M_AXI_AWID    ( serdes0_M_AXI_AWID                   ),
  .serdes0_M_AXI_AWADDR  ( serdes0_M_AXI_AWADDR                 ),
  .serdes0_M_AXI_AWLEN   ( serdes0_M_AXI_AWLEN                  ),
  .serdes0_M_AXI_AWSIZE  ( serdes0_M_AXI_AWSIZE                 ),
  .serdes0_M_AXI_AWBURST ( serdes0_M_AXI_AWBURST                ),
  .serdes0_M_AXI_AWLOCK  ( serdes0_M_AXI_AWLOCK                 ),
  .serdes0_M_AXI_AWCACHE ( serdes0_M_AXI_AWCACHE                ),
  .serdes0_M_AXI_AWPROT  ( serdes0_M_AXI_AWPROT                 ),
  .serdes0_M_AXI_AWQOS   ( serdes0_M_AXI_AWQOS                  ),
  .serdes0_M_AXI_AWUSER  ( serdes0_M_AXI_AWUSER                 ),
  .serdes0_M_AXI_AWVALID ( serdes0_M_AXI_AWVALID                ),
  .serdes0_M_AXI_WDATA   ( serdes0_M_AXI_WDATA                  ),
  .serdes0_M_AXI_WSTRB   ( serdes0_M_AXI_WSTRB                  ),
  .serdes0_M_AXI_WLAST   ( serdes0_M_AXI_WLAST                  ),
  .serdes0_M_AXI_WUSER   ( serdes0_M_AXI_WUSER                  ),
  .serdes0_M_AXI_WVALID  ( serdes0_M_AXI_WVALID                 ),
  .serdes0_M_AXI_BREADY  ( serdes0_M_AXI_BREADY                 ),
  
  .serdes0_S_AXI_ARID    ( pcie_axi4_full_M_AXI_ARID            ),
  .serdes0_S_AXI_ARADDR  ( {32'b0, pcie_axi4_full_M_AXI_ARADDR} ),
  .serdes0_S_AXI_ARLEN   ( pcie_axi4_full_M_AXI_ARLEN           ),
  .serdes0_S_AXI_ARSIZE  ( pcie_axi4_full_M_AXI_ARSIZE          ),
  .serdes0_S_AXI_ARBURST ( pcie_axi4_full_M_AXI_ARBURST         ),
  .serdes0_S_AXI_ARLOCK  ( pcie_axi4_full_M_AXI_ARLOCK          ),
  .serdes0_S_AXI_ARCACHE ( pcie_axi4_full_M_AXI_ARCACHE         ),
  .serdes0_S_AXI_ARPROT  ( pcie_axi4_full_M_AXI_ARPROT          ),
  .serdes0_S_AXI_ARQOS   ( pcie_axi4_full_M_AXI_ARQOS           ),
  .serdes0_S_AXI_ARUSER  ( pcie_axi4_full_M_AXI_ARUSER          ),
  .serdes0_S_AXI_ARVALID ( pcie_axi4_full_M_AXI_ARVALID         ),
  .serdes0_S_AXI_RREADY  ( pcie_axi4_full_M_AXI_RREADY          ),
  .serdes0_S_AXI_AWID    ( pcie_axi4_full_M_AXI_AWID            ),
  .serdes0_S_AXI_AWADDR  ( {32'b0, pcie_axi4_full_M_AXI_AWADDR} ),
  .serdes0_S_AXI_AWLEN   ( pcie_axi4_full_M_AXI_AWLEN           ),
  .serdes0_S_AXI_AWSIZE  ( pcie_axi4_full_M_AXI_AWSIZE          ),
  .serdes0_S_AXI_AWBURST ( pcie_axi4_full_M_AXI_AWBURST         ),
  .serdes0_S_AXI_AWLOCK  ( pcie_axi4_full_M_AXI_AWLOCK          ),
  .serdes0_S_AXI_AWCACHE ( pcie_axi4_full_M_AXI_AWCACHE         ),
  .serdes0_S_AXI_AWPROT  ( pcie_axi4_full_M_AXI_AWPROT          ),
  .serdes0_S_AXI_AWQOS   ( pcie_axi4_full_M_AXI_AWQOS           ),
  .serdes0_S_AXI_AWUSER  ( pcie_axi4_full_M_AXI_AWUSER          ),
  .serdes0_S_AXI_AWVALID ( pcie_axi4_full_M_AXI_AWVALID         ),
  .serdes0_S_AXI_WDATA   ( pcie_axi4_full_M_AXI_WDATA           ),
  .serdes0_S_AXI_WSTRB   ( pcie_axi4_full_M_AXI_WSTRB           ),
  .serdes0_S_AXI_WLAST   ( pcie_axi4_full_M_AXI_WLAST           ),
  .serdes0_S_AXI_WUSER   ( pcie_axi4_full_M_AXI_WUSER           ),
  .serdes0_S_AXI_WVALID  ( pcie_axi4_full_M_AXI_WVALID          ),
  .serdes0_S_AXI_BREADY  ( pcie_axi4_full_M_AXI_BREADY          ),
  .serdes0_S_AXI_ARREADY ( pcie_axi4_full_M_AXI_ARREADY         ),
  .serdes0_S_AXI_RID     ( pcie_axi4_full_M_AXI_RID             ),
  .serdes0_S_AXI_RDATA   ( pcie_axi4_full_M_AXI_RDATA           ),
  .serdes0_S_AXI_RRESP   ( pcie_axi4_full_M_AXI_RRESP           ),
  .serdes0_S_AXI_RLAST   ( pcie_axi4_full_M_AXI_RLAST           ),
  .serdes0_S_AXI_RUSER   ( pcie_axi4_full_M_AXI_RUSER           ),
  .serdes0_S_AXI_RVALID  ( pcie_axi4_full_M_AXI_RVALID          ),
  .serdes0_S_AXI_AWREADY ( pcie_axi4_full_M_AXI_AWREADY         ),
  .serdes0_S_AXI_WREADY  ( pcie_axi4_full_M_AXI_WREADY          ),
  .serdes0_S_AXI_BID     ( pcie_axi4_full_M_AXI_BID             ),
  .serdes0_S_AXI_BRESP   ( pcie_axi4_full_M_AXI_BRESP           ),
  .serdes0_S_AXI_BUSER   ( pcie_axi4_full_M_AXI_BUSER           ),
  .serdes0_S_AXI_BVALID  ( pcie_axi4_full_M_AXI_BVALID          ),

  .serdes1_M_AXI_ARREADY ( serdes1_M_AXI_ARREADY                ),
  .serdes1_M_AXI_RID     ( serdes1_M_AXI_RID                    ),
  .serdes1_M_AXI_RDATA   ( serdes1_M_AXI_RDATA                  ),
  .serdes1_M_AXI_RRESP   ( serdes1_M_AXI_RRESP                  ),
  .serdes1_M_AXI_RLAST   ( serdes1_M_AXI_RLAST                  ),
  .serdes1_M_AXI_RUSER   ( serdes1_M_AXI_RUSER                  ),
  .serdes1_M_AXI_RVALID  ( serdes1_M_AXI_RVALID                 ),
  .serdes1_M_AXI_AWREADY ( serdes1_M_AXI_AWREADY                ),
  .serdes1_M_AXI_WREADY  ( serdes1_M_AXI_WREADY                 ),
  .serdes1_M_AXI_BID     ( serdes1_M_AXI_BID                    ),
  .serdes1_M_AXI_BRESP   ( serdes1_M_AXI_BRESP                  ),
  .serdes1_M_AXI_BUSER   ( serdes1_M_AXI_BUSER                  ),
  .serdes1_M_AXI_BVALID  ( serdes1_M_AXI_BVALID                 ),
  .serdes1_M_AXI_ARID    ( serdes1_M_AXI_ARID                   ),
  .serdes1_M_AXI_ARADDR  ( serdes1_M_AXI_ARADDR                 ),
  .serdes1_M_AXI_ARLEN   ( serdes1_M_AXI_ARLEN                  ),
  .serdes1_M_AXI_ARSIZE  ( serdes1_M_AXI_ARSIZE                 ),
  .serdes1_M_AXI_ARBURST ( serdes1_M_AXI_ARBURST                ),
  .serdes1_M_AXI_ARLOCK  ( serdes1_M_AXI_ARLOCK                 ),
  .serdes1_M_AXI_ARCACHE ( serdes1_M_AXI_ARCACHE                ),
  .serdes1_M_AXI_ARPROT  ( serdes1_M_AXI_ARPROT                 ),
  .serdes1_M_AXI_ARQOS   ( serdes1_M_AXI_ARQOS                  ),
  .serdes1_M_AXI_ARUSER  ( serdes1_M_AXI_ARUSER                 ),
  .serdes1_M_AXI_ARVALID ( serdes1_M_AXI_ARVALID                ),
  .serdes1_M_AXI_RREADY  ( serdes1_M_AXI_RREADY                 ),
  .serdes1_M_AXI_AWID    ( serdes1_M_AXI_AWID                   ),
  .serdes1_M_AXI_AWADDR  ( serdes1_M_AXI_AWADDR                 ),
  .serdes1_M_AXI_AWLEN   ( serdes1_M_AXI_AWLEN                  ),
  .serdes1_M_AXI_AWSIZE  ( serdes1_M_AXI_AWSIZE                 ),
  .serdes1_M_AXI_AWBURST ( serdes1_M_AXI_AWBURST                ),
  .serdes1_M_AXI_AWLOCK  ( serdes1_M_AXI_AWLOCK                 ),
  .serdes1_M_AXI_AWCACHE ( serdes1_M_AXI_AWCACHE                ),
  .serdes1_M_AXI_AWPROT  ( serdes1_M_AXI_AWPROT                 ),
  .serdes1_M_AXI_AWQOS   ( serdes1_M_AXI_AWQOS                  ),
  .serdes1_M_AXI_AWUSER  ( serdes1_M_AXI_AWUSER                 ),
  .serdes1_M_AXI_AWVALID ( serdes1_M_AXI_AWVALID                ),
  .serdes1_M_AXI_WDATA   ( serdes1_M_AXI_WDATA                  ),
  .serdes1_M_AXI_WSTRB   ( serdes1_M_AXI_WSTRB                  ),
  .serdes1_M_AXI_WLAST   ( serdes1_M_AXI_WLAST                  ),
  .serdes1_M_AXI_WUSER   ( serdes1_M_AXI_WUSER                  ),
  .serdes1_M_AXI_WVALID  ( serdes1_M_AXI_WVALID                 ),
  .serdes1_M_AXI_BREADY  ( serdes1_M_AXI_BREADY                 ),


  .serdes1_S_AXI_ARID    ( serdes1_S_AXI_ARID                   ),
  .serdes1_S_AXI_ARADDR  ( serdes1_S_AXI_ARADDR                 ),
  .serdes1_S_AXI_ARLEN   ( serdes1_S_AXI_ARLEN                  ),
  .serdes1_S_AXI_ARSIZE  ( serdes1_S_AXI_ARSIZE                 ),
  .serdes1_S_AXI_ARBURST ( serdes1_S_AXI_ARBURST                ),
  .serdes1_S_AXI_ARLOCK  ( serdes1_S_AXI_ARLOCK                 ),
  .serdes1_S_AXI_ARCACHE ( serdes1_S_AXI_ARCACHE                ),
  .serdes1_S_AXI_ARPROT  ( serdes1_S_AXI_ARPROT                 ),
  .serdes1_S_AXI_ARQOS   ( serdes1_S_AXI_ARQOS                  ),
  .serdes1_S_AXI_ARUSER  ( serdes1_S_AXI_ARUSER                 ),
  .serdes1_S_AXI_ARVALID ( serdes1_S_AXI_ARVALID                ),
  .serdes1_S_AXI_RREADY  ( serdes1_S_AXI_RREADY                 ),
  .serdes1_S_AXI_AWID    ( serdes1_S_AXI_AWID                   ),
  .serdes1_S_AXI_AWADDR  ( serdes1_S_AXI_AWADDR                 ),
  .serdes1_S_AXI_AWLEN   ( serdes1_S_AXI_AWLEN                  ),
  .serdes1_S_AXI_AWSIZE  ( serdes1_S_AXI_AWSIZE                 ),
  .serdes1_S_AXI_AWBURST ( serdes1_S_AXI_AWBURST                ),
  .serdes1_S_AXI_AWLOCK  ( serdes1_S_AXI_AWLOCK                 ),
  .serdes1_S_AXI_AWCACHE ( serdes1_S_AXI_AWCACHE                ),
  .serdes1_S_AXI_AWPROT  ( serdes1_S_AXI_AWPROT                 ),
  .serdes1_S_AXI_AWQOS   ( serdes1_S_AXI_AWQOS                  ),
  .serdes1_S_AXI_AWUSER  ( serdes1_S_AXI_AWUSER                 ),
  .serdes1_S_AXI_AWVALID ( serdes1_S_AXI_AWVALID                ),
  .serdes1_S_AXI_WDATA   ( serdes1_S_AXI_WDATA                  ),
  .serdes1_S_AXI_WSTRB   ( serdes1_S_AXI_WSTRB                  ),
  .serdes1_S_AXI_WLAST   ( serdes1_S_AXI_WLAST                  ),
  .serdes1_S_AXI_WUSER   ( serdes1_S_AXI_WUSER                  ),
  .serdes1_S_AXI_WVALID  ( serdes1_S_AXI_WVALID                 ),
  .serdes1_S_AXI_BREADY  ( serdes1_S_AXI_BREADY                 ),
  .serdes1_S_AXI_ARREADY ( serdes1_S_AXI_ARREADY                ),
  .serdes1_S_AXI_RID     ( serdes1_S_AXI_RID                    ),
  .serdes1_S_AXI_RDATA   ( serdes1_S_AXI_RDATA                  ),
  .serdes1_S_AXI_RRESP   ( serdes1_S_AXI_RRESP                  ),
  .serdes1_S_AXI_RLAST   ( serdes1_S_AXI_RLAST                  ),
  .serdes1_S_AXI_RUSER   ( serdes1_S_AXI_RUSER                  ),
  .serdes1_S_AXI_RVALID  ( serdes1_S_AXI_RVALID                 ),
  .serdes1_S_AXI_AWREADY ( serdes1_S_AXI_AWREADY                ),
  .serdes1_S_AXI_WREADY  ( serdes1_S_AXI_WREADY                 ),
  .serdes1_S_AXI_BID     ( serdes1_S_AXI_BID                    ),
  .serdes1_S_AXI_BRESP   ( serdes1_S_AXI_BRESP                  ),
  .serdes1_S_AXI_BUSER   ( serdes1_S_AXI_BUSER                  ),
  .serdes1_S_AXI_BVALID  ( serdes1_S_AXI_BVALID                 ),

  .ddr0_M_AXI_ARREADY    ( ddr0_M_AXI_ARREADY                   ),
  .ddr0_M_AXI_RID        ( ddr0_M_AXI_RID                       ),
  .ddr0_M_AXI_RDATA      ( ddr0_M_AXI_RDATA                     ),
  .ddr0_M_AXI_RRESP      ( ddr0_M_AXI_RRESP                     ),
  .ddr0_M_AXI_RLAST      ( ddr0_M_AXI_RLAST                     ),
  .ddr0_M_AXI_RUSER      ( ddr0_M_AXI_RUSER                     ),
  .ddr0_M_AXI_RVALID     ( ddr0_M_AXI_RVALID                    ),
  .ddr0_M_AXI_AWREADY    ( ddr0_M_AXI_AWREADY                   ),
  .ddr0_M_AXI_WREADY     ( ddr0_M_AXI_WREADY                    ),
  .ddr0_M_AXI_BID        ( ddr0_M_AXI_BID                       ),
  .ddr0_M_AXI_BRESP      ( ddr0_M_AXI_BRESP                     ),
  .ddr0_M_AXI_BUSER      ( ddr0_M_AXI_BUSER                     ),
  .ddr0_M_AXI_BVALID     ( ddr0_M_AXI_BVALID                    ),
  .ddr0_M_AXI_ARID       ( ddr0_M_AXI_ARID                      ),
  .ddr0_M_AXI_ARADDR     ( ddr0_M_AXI_ARADDR                    ),
  .ddr0_M_AXI_ARLEN      ( ddr0_M_AXI_ARLEN                     ),
  .ddr0_M_AXI_ARSIZE     ( ddr0_M_AXI_ARSIZE                    ),
  .ddr0_M_AXI_ARBURST    ( ddr0_M_AXI_ARBURST                   ),
  .ddr0_M_AXI_ARLOCK     ( ddr0_M_AXI_ARLOCK                    ),
  .ddr0_M_AXI_ARCACHE    ( ddr0_M_AXI_ARCACHE                   ),
  .ddr0_M_AXI_ARPROT     ( ddr0_M_AXI_ARPROT                    ),
  .ddr0_M_AXI_ARQOS      ( ddr0_M_AXI_ARQOS                     ),
  .ddr0_M_AXI_ARUSER     ( ddr0_M_AXI_ARUSER                    ),
  .ddr0_M_AXI_ARVALID    ( ddr0_M_AXI_ARVALID                   ),
  .ddr0_M_AXI_RREADY     ( ddr0_M_AXI_RREADY                    ),
  .ddr0_M_AXI_AWID       ( ddr0_M_AXI_AWID                      ),
  .ddr0_M_AXI_AWADDR     ( ddr0_M_AXI_AWADDR                    ),
  .ddr0_M_AXI_AWLEN      ( ddr0_M_AXI_AWLEN                     ),
  .ddr0_M_AXI_AWSIZE     ( ddr0_M_AXI_AWSIZE                    ),
  .ddr0_M_AXI_AWBURST    ( ddr0_M_AXI_AWBURST                   ),
  .ddr0_M_AXI_AWLOCK     ( ddr0_M_AXI_AWLOCK                    ),
  .ddr0_M_AXI_AWCACHE    ( ddr0_M_AXI_AWCACHE                   ),
  .ddr0_M_AXI_AWPROT     ( ddr0_M_AXI_AWPROT                    ),
  .ddr0_M_AXI_AWQOS      ( ddr0_M_AXI_AWQOS                     ),
  .ddr0_M_AXI_AWUSER     ( ddr0_M_AXI_AWUSER                    ),
  .ddr0_M_AXI_AWVALID    ( ddr0_M_AXI_AWVALID                   ),
  .ddr0_M_AXI_WDATA      ( ddr0_M_AXI_WDATA                     ),
  .ddr0_M_AXI_WSTRB      ( ddr0_M_AXI_WSTRB                     ),
  .ddr0_M_AXI_WLAST      ( ddr0_M_AXI_WLAST                     ),
  .ddr0_M_AXI_WUSER      ( ddr0_M_AXI_WUSER                     ),
  .ddr0_M_AXI_WVALID     ( ddr0_M_AXI_WVALID                    ),
  .ddr0_M_AXI_BREADY     ( ddr0_M_AXI_BREADY                    ),

  .ddr1_M_AXI_ARREADY    ( ddr1_M_AXI_ARREADY                   ),
  .ddr1_M_AXI_RID        ( ddr1_M_AXI_RID                       ),
  .ddr1_M_AXI_RDATA      ( ddr1_M_AXI_RDATA                     ),
  .ddr1_M_AXI_RRESP      ( ddr1_M_AXI_RRESP                     ),
  .ddr1_M_AXI_RLAST      ( ddr1_M_AXI_RLAST                     ),
  .ddr1_M_AXI_RUSER      ( ddr1_M_AXI_RUSER                     ),
  .ddr1_M_AXI_RVALID     ( ddr1_M_AXI_RVALID                    ),
  .ddr1_M_AXI_AWREADY    ( ddr1_M_AXI_AWREADY                   ),
  .ddr1_M_AXI_WREADY     ( ddr1_M_AXI_WREADY                    ),
  .ddr1_M_AXI_BID        ( ddr1_M_AXI_BID                       ),
  .ddr1_M_AXI_BRESP      ( ddr1_M_AXI_BRESP                     ),
  .ddr1_M_AXI_BUSER      ( ddr1_M_AXI_BUSER                     ),
  .ddr1_M_AXI_BVALID     ( ddr1_M_AXI_BVALID                    ),
  .ddr1_M_AXI_ARID       ( ddr1_M_AXI_ARID                      ),
  .ddr1_M_AXI_ARADDR     ( ddr1_M_AXI_ARADDR                    ),
  .ddr1_M_AXI_ARLEN      ( ddr1_M_AXI_ARLEN                     ),
  .ddr1_M_AXI_ARSIZE     ( ddr1_M_AXI_ARSIZE                    ),
  .ddr1_M_AXI_ARBURST    ( ddr1_M_AXI_ARBURST                   ),
  .ddr1_M_AXI_ARLOCK     ( ddr1_M_AXI_ARLOCK                    ),
  .ddr1_M_AXI_ARCACHE    ( ddr1_M_AXI_ARCACHE                   ),
  .ddr1_M_AXI_ARPROT     ( ddr1_M_AXI_ARPROT                    ),
  .ddr1_M_AXI_ARQOS      ( ddr1_M_AXI_ARQOS                     ),
  .ddr1_M_AXI_ARUSER     ( ddr1_M_AXI_ARUSER                    ),
  .ddr1_M_AXI_ARVALID    ( ddr1_M_AXI_ARVALID                   ),
  .ddr1_M_AXI_RREADY     ( ddr1_M_AXI_RREADY                    ),
  .ddr1_M_AXI_AWID       ( ddr1_M_AXI_AWID                      ),
  .ddr1_M_AXI_AWADDR     ( ddr1_M_AXI_AWADDR                    ),
  .ddr1_M_AXI_AWLEN      ( ddr1_M_AXI_AWLEN                     ),
  .ddr1_M_AXI_AWSIZE     ( ddr1_M_AXI_AWSIZE                    ),
  .ddr1_M_AXI_AWBURST    ( ddr1_M_AXI_AWBURST                   ),
  .ddr1_M_AXI_AWLOCK     ( ddr1_M_AXI_AWLOCK                    ),
  .ddr1_M_AXI_AWCACHE    ( ddr1_M_AXI_AWCACHE                   ),
  .ddr1_M_AXI_AWPROT     ( ddr1_M_AXI_AWPROT                    ),
  .ddr1_M_AXI_AWQOS      ( ddr1_M_AXI_AWQOS                     ),
  .ddr1_M_AXI_AWUSER     ( ddr1_M_AXI_AWUSER                    ),
  .ddr1_M_AXI_AWVALID    ( ddr1_M_AXI_AWVALID                   ),
  .ddr1_M_AXI_WDATA      ( ddr1_M_AXI_WDATA                     ),
  .ddr1_M_AXI_WSTRB      ( ddr1_M_AXI_WSTRB                     ),
  .ddr1_M_AXI_WLAST      ( ddr1_M_AXI_WLAST                     ),
  .ddr1_M_AXI_WUSER      ( ddr1_M_AXI_WUSER                     ),
  .ddr1_M_AXI_WVALID     ( ddr1_M_AXI_WVALID                    ),
  .ddr1_M_AXI_BREADY     ( ddr1_M_AXI_BREADY                    ),

  .mcu_M_AXI_ARREADY     ( mcu_M_AXI_ARREADY                    ),
  .mcu_M_AXI_RID         ( mcu_M_AXI_RID                        ),
  .mcu_M_AXI_RDATA       ( mcu_M_AXI_RDATA                      ),
  .mcu_M_AXI_RRESP       ( mcu_M_AXI_RRESP                      ),
  .mcu_M_AXI_RLAST       ( mcu_M_AXI_RLAST                      ),
  .mcu_M_AXI_RUSER       ( mcu_M_AXI_RUSER                      ),
  .mcu_M_AXI_RVALID      ( mcu_M_AXI_RVALID                     ),
  .mcu_M_AXI_AWREADY     ( mcu_M_AXI_AWREADY                    ),
  .mcu_M_AXI_WREADY      ( mcu_M_AXI_WREADY                     ),
  .mcu_M_AXI_BID         ( mcu_M_AXI_BID                        ),
  .mcu_M_AXI_BRESP       ( mcu_M_AXI_BRESP                      ),
  .mcu_M_AXI_BUSER       ( mcu_M_AXI_BUSER                      ),
  .mcu_M_AXI_BVALID      ( mcu_M_AXI_BVALID                     ),
  .mcu_M_AXI_ARID        ( mcu_M_AXI_ARID                       ),
  .mcu_M_AXI_ARADDR      ( mcu_M_AXI_ARADDR                     ),
  .mcu_M_AXI_ARLEN       ( mcu_M_AXI_ARLEN                      ),
  .mcu_M_AXI_ARSIZE      ( mcu_M_AXI_ARSIZE                     ),
  .mcu_M_AXI_ARBURST     ( mcu_M_AXI_ARBURST                    ),
  .mcu_M_AXI_ARLOCK      ( mcu_M_AXI_ARLOCK                     ),
  .mcu_M_AXI_ARCACHE     ( mcu_M_AXI_ARCACHE                    ),
  .mcu_M_AXI_ARPROT      ( mcu_M_AXI_ARPROT                     ),
  .mcu_M_AXI_ARQOS       ( mcu_M_AXI_ARQOS                      ),
  .mcu_M_AXI_ARUSER      ( mcu_M_AXI_ARUSER                     ),
  .mcu_M_AXI_ARVALID     ( mcu_M_AXI_ARVALID                    ),
  .mcu_M_AXI_RREADY      ( mcu_M_AXI_RREADY                     ),
  .mcu_M_AXI_AWID        ( mcu_M_AXI_AWID                       ),
  .mcu_M_AXI_AWADDR      ( mcu_M_AXI_AWADDR                     ),
  .mcu_M_AXI_AWLEN       ( mcu_M_AXI_AWLEN                      ),
  .mcu_M_AXI_AWSIZE      ( mcu_M_AXI_AWSIZE                     ),
  .mcu_M_AXI_AWBURST     ( mcu_M_AXI_AWBURST                    ),
  .mcu_M_AXI_AWLOCK      ( mcu_M_AXI_AWLOCK                     ),
  .mcu_M_AXI_AWCACHE     ( mcu_M_AXI_AWCACHE                    ),
  .mcu_M_AXI_AWPROT      ( mcu_M_AXI_AWPROT                     ),
  .mcu_M_AXI_AWQOS       ( mcu_M_AXI_AWQOS                      ),
  .mcu_M_AXI_AWUSER      ( mcu_M_AXI_AWUSER                     ),
  .mcu_M_AXI_AWVALID     ( mcu_M_AXI_AWVALID                    ),
  .mcu_M_AXI_WDATA       ( mcu_M_AXI_WDATA                      ),
  .mcu_M_AXI_WSTRB       ( mcu_M_AXI_WSTRB                      ),
  .mcu_M_AXI_WLAST       ( mcu_M_AXI_WLAST                      ),
  .mcu_M_AXI_WUSER       ( mcu_M_AXI_WUSER                      ),
  .mcu_M_AXI_WVALID      ( mcu_M_AXI_WVALID                     ),
  .mcu_M_AXI_BREADY      ( mcu_M_AXI_BREADY                     ),

  .clk                   ( logic_clk                            ),      
  .rst_n                 ( logic_rst_n                          ),      
  
  .apb4_prdata           ( apb4_prdata                          ),
  .apb4_pslverr          ( apb4_pslverr                         ),
  .apb4_pready           ( apb4_pready                          ),
  .pcie_clk              ( pcie_clk                             ),
  .pcie_rst_n            ( pcie_rst_n                           ),
  .pcie_ven_msi_req      ( pcie_ven_msi_req                     ),
  .pcie_msi_grant        ( pcie_msi_grant                       ),
  .pcie_ven_msi_func_num ( pcie_ven_msi_func_num                ),
  .pcie_ven_msi_tc       ( pcie_ven_msi_tc                      ),
  .pcie_ven_msi_vector   ( pcie_ven_msi_vector                  )
);


initial begin
  $fsdbDumpfile("npu_tb.fsdb");
  $fsdbDumpvars(0);
  $fsdbDumpMDA             ;
end

parameter ddr_depth                   = 1000000;

full_slave_ddr #(
  .C_S_AXI_ID_WIDTH           ( ddr_ID_WIDTH                  ),
  .C_S_AXI_DATA_WIDTH         ( AXI4_FULL_M_AXI_RDATA_WIDTH   ),
  .C_S_AXI_ADDR_WIDTH         ( AXI4_FULL_S_AXI_AWADDR_WIDTH  ),
  .C_S_AXI_AWUSER_WIDTH       ( AXI4_FULL_M_AXI_AWUSER_WIDTH  ),
  .C_S_AXI_ARUSER_WIDTH       ( AXI4_FULL_M_AXI_ARUSER_WIDTH  ),
  .C_S_AXI_WUSER_WIDTH        ( AXI4_FULL_M_AXI_WUSER_WIDTH   ),
  .C_S_AXI_RUSER_WIDTH        ( AXI4_FULL_S_AXI_RUSER_WIDTH   ),
  .C_S_AXI_BUSER_WIDTH        ( AXI4_FULL_S_AXI_BUSER_WIDTH   ),
  .C_S_TARGET_SLAVE_BASE_ADDR ( 'h00000000                    ),
  .ddr_depth                  ( ddr_depth                     )
) u_full_slave_ddr1(
  .S_AXI_ACLK     ( axi4_clk       ),
  .S_AXI_ARESETN  ( axi4_rst_n     ),
  .S_AXI_AWID     ( ddr1_M_AXI_AWID     ),
  .S_AXI_AWADDR   ( ddr1_M_AXI_AWADDR   ),
  .S_AXI_AWLEN    ( ddr1_M_AXI_AWLEN    ),
  .S_AXI_AWSIZE   ( ddr1_M_AXI_AWSIZE   ),
  .S_AXI_AWBURST  ( ddr1_M_AXI_AWBURST  ),
  .S_AXI_AWLOCK   ( ddr1_M_AXI_AWLOCK   ),
  .S_AXI_AWCACHE  ( ddr1_M_AXI_AWCACHE  ),
  .S_AXI_AWPROT   ( ddr1_M_AXI_AWPROT   ),
  .S_AXI_AWQOS    ( ddr1_M_AXI_AWQOS    ),
  .S_AXI_AWREGION (                    ),
  .S_AXI_AWUSER   ( ddr1_M_AXI_AWUSER   ),
  .S_AXI_AWVALID  ( ddr1_M_AXI_AWVALID  ),
  .S_AXI_WDATA    ( ddr1_M_AXI_WDATA    ),
  .S_AXI_WSTRB    ( ddr1_M_AXI_WSTRB    ),
  .S_AXI_WLAST    ( ddr1_M_AXI_WLAST    ),
  .S_AXI_WUSER    ( ddr1_M_AXI_WUSER    ),
  .S_AXI_WVALID   ( ddr1_M_AXI_WVALID   ),
  .S_AXI_BREADY   ( ddr1_M_AXI_BREADY   ),
  .S_AXI_ARID     ( ddr1_M_AXI_ARID     ),
  .S_AXI_ARADDR   ( ddr1_M_AXI_ARADDR   ),
  .S_AXI_ARLEN    ( ddr1_M_AXI_ARLEN    ),
  .S_AXI_ARSIZE   ( ddr1_M_AXI_ARSIZE   ),
  .S_AXI_ARBURST  ( ddr1_M_AXI_ARBURST  ),
  .S_AXI_ARLOCK   ( ddr1_M_AXI_ARLOCK   ),
  .S_AXI_ARCACHE  ( ddr1_M_AXI_ARCACHE  ),
  .S_AXI_ARPROT   ( ddr1_M_AXI_ARPROT   ),
  .S_AXI_ARQOS    ( ddr1_M_AXI_ARQOS    ),
  .S_AXI_ARREGION (                    ),
  .S_AXI_ARUSER   ( ddr1_M_AXI_ARUSER   ),
  .S_AXI_ARVALID  ( ddr1_M_AXI_ARVALID  ),
  .S_AXI_RREADY   ( ddr1_M_AXI_RREADY   ),
  .S_AXI_AWREADY  ( ddr1_M_AXI_AWREADY  ),
  .S_AXI_WREADY   ( ddr1_M_AXI_WREADY   ),
  .S_AXI_BID      ( ddr1_M_AXI_BID      ),
  .S_AXI_BRESP    ( ddr1_M_AXI_BRESP    ),
  .S_AXI_BUSER    ( ddr1_M_AXI_BUSER    ),
  .S_AXI_BVALID   ( ddr1_M_AXI_BVALID   ),
  .S_AXI_ARREADY  ( ddr1_M_AXI_ARREADY  ),
  .S_AXI_RID      ( ddr1_M_AXI_RID      ),
  .S_AXI_RDATA    ( ddr1_M_AXI_RDATA    ),
  .S_AXI_RRESP    ( ddr1_M_AXI_RRESP    ),
  .S_AXI_RLAST    ( ddr1_M_AXI_RLAST    ),
  .S_AXI_RUSER    ( ddr1_M_AXI_RUSER    ),
  .S_AXI_RVALID   ( ddr1_M_AXI_RVALID   )
);

full_slave_ddr #(
  .C_S_AXI_ID_WIDTH           ( ddr_ID_WIDTH                  ),
  .C_S_AXI_DATA_WIDTH         ( AXI4_FULL_M_AXI_RDATA_WIDTH   ),
  .C_S_AXI_ADDR_WIDTH         ( AXI4_FULL_S_AXI_AWADDR_WIDTH  ),
  .C_S_AXI_AWUSER_WIDTH       ( AXI4_FULL_M_AXI_AWUSER_WIDTH  ),
  .C_S_AXI_ARUSER_WIDTH       ( AXI4_FULL_M_AXI_ARUSER_WIDTH  ),
  .C_S_AXI_WUSER_WIDTH        ( AXI4_FULL_M_AXI_WUSER_WIDTH   ),
  .C_S_AXI_RUSER_WIDTH        ( AXI4_FULL_S_AXI_RUSER_WIDTH   ),
  .C_S_AXI_BUSER_WIDTH        ( AXI4_FULL_S_AXI_BUSER_WIDTH   ),
  .C_S_TARGET_SLAVE_BASE_ADDR ( 'h00000000                    ),
  .ddr_depth                  ( ddr_depth                     )
) u_full_slave_ddr0(
  .S_AXI_ACLK     ( axi4_clk       ),
  .S_AXI_ARESETN  ( axi4_rst_n     ),
  .S_AXI_AWID     ( ddr0_M_AXI_AWID     ),
  .S_AXI_AWADDR   ( ddr0_M_AXI_AWADDR   ),
  .S_AXI_AWLEN    ( ddr0_M_AXI_AWLEN    ),
  .S_AXI_AWSIZE   ( ddr0_M_AXI_AWSIZE   ),
  .S_AXI_AWBURST  ( ddr0_M_AXI_AWBURST  ),
  .S_AXI_AWLOCK   ( ddr0_M_AXI_AWLOCK   ),
  .S_AXI_AWCACHE  ( ddr0_M_AXI_AWCACHE  ),
  .S_AXI_AWPROT   ( ddr0_M_AXI_AWPROT   ),
  .S_AXI_AWQOS    ( ddr0_M_AXI_AWQOS    ),
  .S_AXI_AWREGION (                    ),
  .S_AXI_AWUSER   ( ddr0_M_AXI_AWUSER   ),
  .S_AXI_AWVALID  ( ddr0_M_AXI_AWVALID  ),
  .S_AXI_WDATA    ( ddr0_M_AXI_WDATA    ),
  .S_AXI_WSTRB    ( ddr0_M_AXI_WSTRB    ),
  .S_AXI_WLAST    ( ddr0_M_AXI_WLAST    ),
  .S_AXI_WUSER    ( ddr0_M_AXI_WUSER    ),
  .S_AXI_WVALID   ( ddr0_M_AXI_WVALID   ),
  .S_AXI_BREADY   ( ddr0_M_AXI_BREADY   ),
  .S_AXI_ARID     ( ddr0_M_AXI_ARID     ),
  .S_AXI_ARADDR   ( ddr0_M_AXI_ARADDR   ),
  .S_AXI_ARLEN    ( ddr0_M_AXI_ARLEN    ),
  .S_AXI_ARSIZE   ( ddr0_M_AXI_ARSIZE   ),
  .S_AXI_ARBURST  ( ddr0_M_AXI_ARBURST  ),
  .S_AXI_ARLOCK   ( ddr0_M_AXI_ARLOCK   ),
  .S_AXI_ARCACHE  ( ddr0_M_AXI_ARCACHE  ),
  .S_AXI_ARPROT   ( ddr0_M_AXI_ARPROT   ),
  .S_AXI_ARQOS    ( ddr0_M_AXI_ARQOS    ),
  .S_AXI_ARREGION (                    ),
  .S_AXI_ARUSER   ( ddr0_M_AXI_ARUSER   ),
  .S_AXI_ARVALID  ( ddr0_M_AXI_ARVALID  ),
  .S_AXI_RREADY   ( ddr0_M_AXI_RREADY   ),
  .S_AXI_AWREADY  ( ddr0_M_AXI_AWREADY  ),
  .S_AXI_WREADY   ( ddr0_M_AXI_WREADY   ),
  .S_AXI_BID      ( ddr0_M_AXI_BID      ),
  .S_AXI_BRESP    ( ddr0_M_AXI_BRESP    ),
  .S_AXI_BUSER    ( ddr0_M_AXI_BUSER    ),
  .S_AXI_BVALID   ( ddr0_M_AXI_BVALID   ),
  .S_AXI_ARREADY  ( ddr0_M_AXI_ARREADY  ),
  .S_AXI_RID      ( ddr0_M_AXI_RID      ),
  .S_AXI_RDATA    ( ddr0_M_AXI_RDATA    ),
  .S_AXI_RRESP    ( ddr0_M_AXI_RRESP    ),
  .S_AXI_RLAST    ( ddr0_M_AXI_RLAST    ),
  .S_AXI_RUSER    ( ddr0_M_AXI_RUSER    ),
  .S_AXI_RVALID   ( ddr0_M_AXI_RVALID   )
);

initial begin
  $readmemh("../memory/insn.txt", u_full_slave_ddr0.data_mem);
  $readmemh("../memory/ifmap.txt", u_full_slave_ddr0.data_mem, 'h10000);
  $readmemh("../memory/weight.txt", u_full_slave_ddr0.data_mem, 'h20000);
  $readmemh("../memory/ifmap_scale.txt", u_full_slave_ddr0.data_mem, 'h40000);
  $readmemh("../memory/weight_scale.txt", u_full_slave_ddr0.data_mem, 'h50000);
  $readmemh("../memory/outlier_index.txt", u_full_slave_ddr0.data_mem, 'h60000);
  $readmemh("../memory/psum.txt", u_full_slave_ddr0.data_mem, 'h70000);
  $readmemh("../memory/ifmap_mask.txt", u_full_slave_ddr0.data_mem, 'h80000);
  $readmemh("../memory/vcucode.txt", u_full_slave_ddr0.data_mem, 'h90000);
  $readmemh("../memory/vcupara.txt", u_full_slave_ddr0.data_mem, 'ha0000);
  $readmemh("../memory/vcures.txt", u_full_slave_ddr0.data_mem, 'hb0000);
  $readmemh("../memory/reciprocal.txt", u_full_slave_ddr0.data_mem, 'hc0000);
  $readmemh("../memory/log.txt", u_full_slave_ddr0.data_mem, 'hc0800);
  $readmemh("../memory/exp.txt", u_full_slave_ddr0.data_mem, 'hc1000);
  $readmemh("../memory/rsqrt.txt", u_full_slave_ddr0.data_mem, 'hc1800);
  $readmemh("../memory/tanh.txt", u_full_slave_ddr0.data_mem, 'hc2000);
  $readmemh("../memory/sigmoid.txt", u_full_slave_ddr0.data_mem, 'hc2800);
  $readmemh("../memory/mish.txt", u_full_slave_ddr0.data_mem, 'hc3000);
  $readmemh("../memory/swish.txt", u_full_slave_ddr0.data_mem, 'hc3800);
  $readmemh("../memory/gelu.txt", u_full_slave_ddr0.data_mem, 'hc4000);
  $readmemh("../memory/sincos.txt", u_full_slave_ddr0.data_mem, 'hc4800);
  $readmemh("../memory/config.txt", u_full_slave_ddr0.data_mem, 'hd0000);
end

parameter psum_bits = 16;
parameter conv_len  = 1024;

reg [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0] gt_reg [0:conv_len];
initial begin
  $readmemh("../memory/ofmap.txt", gt_reg);
end

integer i;
reg [15:0] err_cnt='d0;
reg [15:0] cor_cnt='d0;

integer re_file;
initial begin
  re_file = $fopen("re.dat", "w");
  if(re_file==0) begin
    $display("can not write the file!");
    $stop;
  end
end

always @(posedge logic_clk) begin
  if (u_npu_top_chiplet.u_npu_top.global_done) begin
    for (i=0;i<=(conv_len);i=i+1) begin
      $fdisplay(re_file, "%h", u_full_slave_ddr0.data_mem['h30000+i]);
        if (gt_reg[i]==u_full_slave_ddr0.data_mem['h30000+i]) begin
          cor_cnt =  cor_cnt + 1;
          // $display("mismatch number is %d\n", cor_cnt);
        end
        else begin
          err_cnt = err_cnt + 1;
          $display("index is %d, mem addr is %h", i, 'h30000+i);
          $display("gt is %h", gt_reg[i]);
          $display("re is %h", u_full_slave_ddr0.data_mem['h30000+i]);    
          $display("mismatch number is %d\n", err_cnt);
        end
      end
      $display("mismatch number is %d", err_cnt);
      #10000 $finish;
  end
end
endmodule