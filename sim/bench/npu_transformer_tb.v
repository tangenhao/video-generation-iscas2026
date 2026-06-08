module npu_transformer_tb;

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
wire [31:0]                              mcu_M_AXI_ARADDR;
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
  .AXI_M_AXI_BURSTLENGTH  ( PCIE_AXI4_FULL_M_AXI_BURSTLENGTH  ),
  .AXI_OUTSTANDING_DEPTH  ( PCIE_AXI4_FULL_OUTSTANDING_DEPTH  ),
  .AXI_M_AXI_ID_WIDTH     ( PCIE_AXI4_FULL_M_AXI_ID_WIDTH     ),
  .AXI_M_AXI_ADDR_WIDTH ( PCIE_AXI4_FULL_M_AXI_ARADDR_WIDTH ),
  .AXI_M_AXI_USER_WIDTH ( PCIE_AXI4_FULL_M_AXI_ARUSER_WIDTH ),
  .AXI_M_AXI_DATA_WIDTH  ( PCIE_AXI4_FULL_M_AXI_RDATA_WIDTH  ),
  .PERI_ADDR_WIDTH      ( PCIE_PERIPHERAL_R_ADDR_WIDTH      ),
  .PERI_BUSRSTS_WIDTH   ( PCIE_PERIPHERAL_R_BUSRSTS_WIDTH   ),
  .PERI_DATA_WIDTH      ( PCIE_PERIPHERAL_R_DATA_WIDTH      )
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

  /* cmd_rst */
  #100 cmd_in_wr(cmd, 0, 1);
  
  @(posedge axi4_clk) cmd_vld = 1;
  /* insn_addr_low */
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h20, config_regs[0]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* insn_addr_high */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h40, config_regs[1]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* insn_number */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h60, config_regs[2]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* insn_burst_length */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h80, config_regs[3]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* cib_irq_enables */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'ha0, 1);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  /* cib_irq_addr_low */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'hc0, 'h200);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  /* cib_irq_addr_high */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'he0, 'h200);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  /* pcie_irq_enable */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h100, 1);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* local_highaddr */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h120, config_regs[5]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  /* pcie_highaddr */
  @(posedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h140, 'h5000);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  /* mcu_highaddr */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h160, 'h6000);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  /* psum load valid bits */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h800, config_regs[14]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1000, config_regs[14]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1800, config_regs[14]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2000, config_regs[14]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;  
  
  /* psum store valid bits */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h820, config_regs[15]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1020, config_regs[15]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1820, config_regs[15]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2020, config_regs[15]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* vcures load valid bits */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h840, config_regs[16]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1040, config_regs[16]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1840, config_regs[16]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2040, config_regs[16]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* ifmapmask load valid bits */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h860, config_regs[17]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1060, config_regs[17]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1860, config_regs[17]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2060, config_regs[17]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  
  /* enable prof counters */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h880, config_regs[18]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1080, config_regs[18]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h1880, config_regs[18]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h2080, config_regs[18]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* broadcast enable */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h8a0, config_regs[5]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h10a0, config_regs[5]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h18a0, config_regs[5]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 'h20a0, config_regs[5]);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

  /* cmd_start */
  @(negedge u_axi_master.axi4_full_M_AXI_BVALID) #10cmd_in_wr(cmd, 0, 2);
  cmd_vld = 1;
  @(negedge axi4_clk) cmd_vld = 0;

end

always #1 axi4_clk = ~axi4_clk;
always #1 logic_clk = ~logic_clk;
always #2 apb4_pclk = ~apb4_pclk;
always #4 pcie_clk = ~pcie_clk;

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
  #90000000 $finish;
end

always @(posedge pcie_clk or negedge pcie_rst_n) begin
  if (!pcie_rst_n) begin
    pcie_msi_grant <= 0;
  end
  else begin
    if (pcie_ven_msi_req) begin
      #1000 pcie_msi_grant <= 1;
    end
    else begin
      pcie_msi_grant <= 0;
    end
  end
end

npu_top_chiplet u_npu_top_chiplet(
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
  $fsdbDumpfile("npu_transformer_tb.fsdb");
  $fsdbDumpvars(0);
  // $fsdbDumpMDA();
end

parameter ddr_depth                   = 4000000;

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


parameter INSN_ADDR             = 'h00000000;
parameter INPUT_ADDR            = 'h10000;
parameter QUERY_WEIGHT_ADDR     = 'h20000;
parameter KEY_WEIGHT_ADDR       = 'h30000;
parameter VALUE_WEIGHT_ADDR     = 'h40000;
parameter OUTPUT_WEIGHT_ADDR    = 'h50000;
parameter QUERY_TEMP_ADDR       = 'h60000;
parameter KEY_TEMP_ADDR         = 'h70000;
parameter VALUE_TEMP_ADDR       = 'h80000;
parameter SCORE_TEMP_ADDR       = 'h90000;
parameter PROBE_TEMP_ADDR       = 'ha0000;
parameter OUTPUT_TEMP_ADDR      = 'hb0000;
parameter REC_LUT_ADDR          = 'hc0000;
parameter LOG_LUT_ADDR          = 'hc0800;
parameter EXP_LUT_ADDR          = 'hc1000;
parameter RSQRT_LUT_ADDR        = 'hc1800;
parameter TANH_LUT_ADDR         = 'hc2000;
parameter SIGMOID_LUT_ADDR      = 'hc2800;
parameter MISH_LUT_ADDR         = 'hc3000;
parameter SWISH_LUT_ADDR        = 'hc3800;
parameter GELU_LUT_ADDR         = 'hc4000;
parameter SINCOS_LUT_ADDR       = 'hc4800;
parameter BROADCAST_CFG_ADDR    = 'hc5000;
parameter NO_BROADCAST_CFG_ADDR = 'hc5800;
parameter OUTPUT_ADDR           = 'hd0000;
parameter VCUCODE_ADDR          = 'he0000;
parameter FREQ_CLS_ADDR         = 'he8000;
parameter MASK_ADDR             = 'hf0000;

initial begin
  $readmemh("../memory_transformer/insn.txt", u_full_slave_ddr0.data_mem, INSN_ADDR);
  $readmemh("../memory_transformer/input.txt", u_full_slave_ddr0.data_mem, INPUT_ADDR);
  $readmemh("../memory_transformer/weight_query.txt", u_full_slave_ddr0.data_mem, QUERY_WEIGHT_ADDR);
  $readmemh("../memory_transformer/weight_key.txt", u_full_slave_ddr0.data_mem, KEY_WEIGHT_ADDR);
  $readmemh("../memory_transformer/weight_value.txt", u_full_slave_ddr0.data_mem, VALUE_WEIGHT_ADDR);
  $readmemh("../memory_transformer/weight_output.txt", u_full_slave_ddr0.data_mem, OUTPUT_WEIGHT_ADDR);
  $readmemh("../memory/reciprocal.txt", u_full_slave_ddr0.data_mem, REC_LUT_ADDR);
  $readmemh("../memory/log.txt", u_full_slave_ddr0.data_mem, LOG_LUT_ADDR);
  $readmemh("../memory/exp.txt", u_full_slave_ddr0.data_mem, EXP_LUT_ADDR);
  $readmemh("../memory/rsqrt.txt", u_full_slave_ddr0.data_mem, RSQRT_LUT_ADDR);
  $readmemh("../memory/tanh.txt", u_full_slave_ddr0.data_mem, TANH_LUT_ADDR);
  $readmemh("../memory/sigmoid.txt", u_full_slave_ddr0.data_mem, SIGMOID_LUT_ADDR);
  $readmemh("../memory/mish.txt", u_full_slave_ddr0.data_mem, MISH_LUT_ADDR);
  $readmemh("../memory/swish.txt", u_full_slave_ddr0.data_mem, SWISH_LUT_ADDR);
  $readmemh("../memory/gelu.txt", u_full_slave_ddr0.data_mem, GELU_LUT_ADDR);
  $readmemh("../memory/sincos.txt", u_full_slave_ddr0.data_mem, SINCOS_LUT_ADDR);
  $readmemh("../memory_transformer/broadcast_cfg.txt", u_full_slave_ddr0.data_mem, BROADCAST_CFG_ADDR);
  $readmemh("../memory_transformer/no_broadcast_cfg.txt", u_full_slave_ddr0.data_mem, NO_BROADCAST_CFG_ADDR);
  $readmemh("../memory_transformer/vcucode.txt", u_full_slave_ddr0.data_mem, VCUCODE_ADDR);
  $readmemh("../memory_transformer/freq_cls_concat.txt", u_full_slave_ddr0.data_mem, FREQ_CLS_ADDR);
  $readmemh("../memory_transformer/mask_concat.txt", u_full_slave_ddr0.data_mem, MASK_ADDR);

  // $readmemh("../memory_transformer/query_temp_hf.txt", u_full_slave_ddr0.data_mem, QUERY_TEMP_ADDR);
  // $readmemh("../memory_transformer/key_temp_hf_transform.txt", u_full_slave_ddr0.data_mem, KEY_TEMP_ADDR);
  // $readmemh("../memory_transformer/score_temp.txt", u_full_slave_ddr0.data_mem, SCORE_TEMP_ADDR);
  // $readmemh("../memory_transformer/softmax_ref.txt", u_full_slave_ddr0.data_mem, PROBE_TEMP_ADDR);
  // $readmemh("../memory_transformer/value_temp_hf_transform.txt", u_full_slave_ddr0.data_mem, VALUE_TEMP_ADDR);
  // $readmemh("../memory_transformer/output_temp.txt", u_full_slave_ddr0.data_mem, OUTPUT_TEMP_ADDR);
end

parameter psum_bits = 16;
parameter conv_len  = 8192;

reg [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0] gt_reg [0:conv_len];
initial begin
  $readmemh("../memory_transformer/output.txt", gt_reg);
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

task check(integer address);
  begin
    // 打开结果输出文件
    integer result_file;
    result_file = $fopen("../memory_transformer/result.txt", "w");
    if(result_file==0) begin
      $display("can not write to result.txt!");
      $stop;
    end

    for (i=0;i<=(conv_len);i=i+1) begin
      // 输出到re.dat
      $fdisplay(re_file, "%h", u_full_slave_ddr0.data_mem[address+i]);
      // 输出到result.txt
      $fdisplay(result_file, "%h", u_full_slave_ddr0.data_mem[address+i]);        
      
      if (gt_reg[i]!=u_full_slave_ddr0.data_mem[address+i]) begin
        err_cnt = err_cnt + 1;
        $display("index is %d, mem addr is %h", i, address+i);
        $display("gt is %h", gt_reg[i]);
        $display("re is %h", u_full_slave_ddr0.data_mem[address+i]);    
        $display("mismatch number is %d\n", err_cnt);
      end
    end
    $fclose(result_file);
    $display("mismatch number is %d", err_cnt);
    #10000 $finish;
  end
endtask

always @(posedge logic_clk) begin
  if (u_npu_top_chiplet.u_npu_top.global_done) begin
    check(OUTPUT_ADDR);
  end
end
endmodule
