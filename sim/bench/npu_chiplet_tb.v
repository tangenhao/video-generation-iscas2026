module npu_chiplet_tb;

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
parameter ASYN_RDATA_FIFO_DEPTH         = 8;
parameter ASYN_WADDR_FIFO_DEPTH         = 8;
parameter ASYN_WDATA_FIFO_DEPTH         = 8;
parameter AXI4_FULL_OUTSTANDING_DEPTH   = 8;
parameter AXI4_FULL_M_AXI_ID_WIDTH      = 26;
parameter AXI4_FULL_M_AXI_ARADDR_WIDTH  = 64;
parameter AXI4_FULL_M_AXI_ARUSER_WIDTH  = 1;
parameter AXI4_FULL_M_AXI_RDATA_WIDTH   = 256;
parameter AXI4_FULL_M_AXI_RUSER_WIDTH   = 1;
parameter AXI4_FULL_AR_ID               = 0;
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

parameter ddr_ID_WIDTH = 21;

reg         apb4_pclk;
reg         apb4_presetn;
                        
reg  [64:0] chip0_cmd;
reg         chip0_cmd_vld;
wire [31:0] chip0_cmd_rd_data;

reg  [64:0] chip1_cmd;
reg         chip1_cmd_vld;
wire [31:0] chip1_cmd_rd_data;
                        
wire [15:0] chip0_apb4_paddr;
wire        chip0_apb4_pwrite;
wire        chip0_apb4_psel;
wire        chip0_apb4_penable;
wire [31:0] chip0_apb4_pwdata;
wire [31:0] chip0_apb4_prdata;
wire        chip0_apb4_pready;
wire        chip0_apb4_pslverr;

wire [15:0] chip1_apb4_paddr;
wire        chip1_apb4_pwrite;
wire        chip1_apb4_psel;
wire        chip1_apb4_penable;
wire [31:0] chip1_apb4_pwdata;
wire [31:0] chip1_apb4_prdata;
wire        chip1_apb4_pready;
wire        chip1_apb4_pslverr;

reg         axi4_clk;
reg         axi4_rst_n;
reg         logic_clk;
reg         logic_rst_n;

wire                                     chip0_serdes0_M_AXI_ARREADY;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      chip0_serdes0_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   chip0_serdes0_M_AXI_RDATA;
wire [1:0]                               chip0_serdes0_M_AXI_RRESP;
wire                                     chip0_serdes0_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   chip0_serdes0_M_AXI_RUSER;
wire                                     chip0_serdes0_M_AXI_RVALID;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip0_serdes0_S_AXI_ARID;
wire [AXI4_FULL_S_AXI_ARADDR_WIDTH-1:0]  chip0_serdes0_S_AXI_ARADDR;
wire [7:0]                               chip0_serdes0_S_AXI_ARLEN;
wire [2:0]                               chip0_serdes0_S_AXI_ARSIZE;
wire [1:0]                               chip0_serdes0_S_AXI_ARBURST;
wire                                     chip0_serdes0_S_AXI_ARLOCK;
wire [3:0]                               chip0_serdes0_S_AXI_ARCACHE;
wire [2:0]                               chip0_serdes0_S_AXI_ARPROT;
wire [3:0]                               chip0_serdes0_S_AXI_ARQOS;
wire [AXI4_FULL_S_AXI_ARUSER_WIDTH-1:0]  chip0_serdes0_S_AXI_ARUSER;
wire                                     chip0_serdes0_S_AXI_ARVALID;
wire                                     chip0_serdes0_S_AXI_RREADY;
wire                                     chip0_serdes0_M_AXI_AWREADY;
wire                                     chip0_serdes0_M_AXI_WREADY;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      chip0_serdes0_M_AXI_BID;
wire [1:0]                               chip0_serdes0_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   chip0_serdes0_M_AXI_BUSER;
wire                                     chip0_serdes0_M_AXI_BVALID;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip0_serdes0_S_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  chip0_serdes0_S_AXI_AWADDR;
wire [7:0]                               chip0_serdes0_S_AXI_AWLEN;
wire [2:0]                               chip0_serdes0_S_AXI_AWSIZE;
wire [1:0]                               chip0_serdes0_S_AXI_AWBURST;
wire                                     chip0_serdes0_S_AXI_AWLOCK;
wire [3:0]                               chip0_serdes0_S_AXI_AWCACHE;
wire [2:0]                               chip0_serdes0_S_AXI_AWPROT;
wire [3:0]                               chip0_serdes0_S_AXI_AWQOS;
wire [AXI4_FULL_S_AXI_AWUSER_WIDTH-1:0]  chip0_serdes0_S_AXI_AWUSER;
wire                                     chip0_serdes0_S_AXI_AWVALID;
wire [AXI4_FULL_S_AXI_WDATA_WIDTH-1:0]   chip0_serdes0_S_AXI_WDATA;
wire [AXI4_FULL_S_AXI_DATA_BYTES-1:0]    chip0_serdes0_S_AXI_WSTRB;
wire                                     chip0_serdes0_S_AXI_WLAST;
wire [AXI4_FULL_S_AXI_WUSER_WIDTH-1:0]   chip0_serdes0_S_AXI_WUSER;
wire                                     chip0_serdes0_S_AXI_WVALID;
wire                                     chip0_serdes0_S_AXI_BREADY;

wire                                     connected_serdes_M_AXI_ARREADY;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      connected_serdes_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   connected_serdes_M_AXI_RDATA;
wire [1:0]                               connected_serdes_M_AXI_RRESP;
wire                                     connected_serdes_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   connected_serdes_M_AXI_RUSER;
wire                                     connected_serdes_M_AXI_RVALID;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      connected_serdes_S_AXI_ARID;
wire [AXI4_FULL_S_AXI_ARADDR_WIDTH-1:0]  connected_serdes_S_AXI_ARADDR;
wire [7:0]                               connected_serdes_S_AXI_ARLEN;
wire [2:0]                               connected_serdes_S_AXI_ARSIZE;
wire [1:0]                               connected_serdes_S_AXI_ARBURST;
wire                                     connected_serdes_S_AXI_ARLOCK;
wire [3:0]                               connected_serdes_S_AXI_ARCACHE;
wire [2:0]                               connected_serdes_S_AXI_ARPROT;
wire [3:0]                               connected_serdes_S_AXI_ARQOS;
wire [AXI4_FULL_S_AXI_ARUSER_WIDTH-1:0]  connected_serdes_S_AXI_ARUSER;
wire                                     connected_serdes_S_AXI_ARVALID;
wire                                     connected_serdes_S_AXI_RREADY;
wire                                     connected_serdes_M_AXI_AWREADY;
wire                                     connected_serdes_M_AXI_WREADY;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      connected_serdes_M_AXI_BID;
wire [1:0]                               connected_serdes_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   connected_serdes_M_AXI_BUSER;
wire                                     connected_serdes_M_AXI_BVALID;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      connected_serdes_S_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  connected_serdes_S_AXI_AWADDR;
wire [7:0]                               connected_serdes_S_AXI_AWLEN;
wire [2:0]                               connected_serdes_S_AXI_AWSIZE;
wire [1:0]                               connected_serdes_S_AXI_AWBURST;
wire                                     connected_serdes_S_AXI_AWLOCK;
wire [3:0]                               connected_serdes_S_AXI_AWCACHE;
wire [2:0]                               connected_serdes_S_AXI_AWPROT;
wire [3:0]                               connected_serdes_S_AXI_AWQOS;
wire [AXI4_FULL_S_AXI_AWUSER_WIDTH-1:0]  connected_serdes_S_AXI_AWUSER;
wire                                     connected_serdes_S_AXI_AWVALID;
wire [AXI4_FULL_S_AXI_WDATA_WIDTH-1:0]   connected_serdes_S_AXI_WDATA;
wire [AXI4_FULL_S_AXI_DATA_BYTES-1:0]    connected_serdes_S_AXI_WSTRB;
wire                                     connected_serdes_S_AXI_WLAST;
wire [AXI4_FULL_S_AXI_WUSER_WIDTH-1:0]   connected_serdes_S_AXI_WUSER;
wire                                     connected_serdes_S_AXI_WVALID;
wire                                     connected_serdes_S_AXI_BREADY;

wire                                     chip1_M_AXI_ARREADY;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      chip1_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   chip1_M_AXI_RDATA;
wire [1:0]                               chip1_M_AXI_RRESP;
wire                                     chip1_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   chip1_M_AXI_RUSER;
wire                                     chip1_M_AXI_RVALID;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip1_S_AXI_ARID;
wire [AXI4_FULL_S_AXI_ARADDR_WIDTH-1:0]  chip1_S_AXI_ARADDR;
wire [7:0]                               chip1_S_AXI_ARLEN;
wire [2:0]                               chip1_S_AXI_ARSIZE;
wire [1:0]                               chip1_S_AXI_ARBURST;
wire                                     chip1_S_AXI_ARLOCK;
wire [3:0]                               chip1_S_AXI_ARCACHE;
wire [2:0]                               chip1_S_AXI_ARPROT;
wire [3:0]                               chip1_S_AXI_ARQOS;
wire [AXI4_FULL_S_AXI_ARUSER_WIDTH-1:0]  chip1_S_AXI_ARUSER;
wire                                     chip1_S_AXI_ARVALID;
wire                                     chip1_S_AXI_RREADY;
wire                                     chip1_M_AXI_AWREADY;
wire                                     chip1_M_AXI_WREADY;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      chip1_M_AXI_BID;
wire [1:0]                               chip1_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   chip1_M_AXI_BUSER;
wire                                     chip1_M_AXI_BVALID;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip1_S_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  chip1_S_AXI_AWADDR;
wire [7:0]                               chip1_S_AXI_AWLEN;
wire [2:0]                               chip1_S_AXI_AWSIZE;
wire [1:0]                               chip1_S_AXI_AWBURST;
wire                                     chip1_S_AXI_AWLOCK;
wire [3:0]                               chip1_S_AXI_AWCACHE;
wire [2:0]                               chip1_S_AXI_AWPROT;
wire [3:0]                               chip1_S_AXI_AWQOS;
wire [AXI4_FULL_S_AXI_AWUSER_WIDTH-1:0]  chip1_S_AXI_AWUSER;
wire                                     chip1_S_AXI_AWVALID;
wire [AXI4_FULL_S_AXI_WDATA_WIDTH-1:0]   chip1_S_AXI_WDATA;
wire [AXI4_FULL_S_AXI_DATA_BYTES-1:0]    chip1_S_AXI_WSTRB;
wire                                     chip1_S_AXI_WLAST;
wire [AXI4_FULL_S_AXI_WUSER_WIDTH-1:0]   chip1_S_AXI_WUSER;
wire                                     chip1_S_AXI_WVALID;
wire                                     chip1_S_AXI_BREADY;

wire                                     chip0_ddr_M_AXI_ARREADY;
wire [ddr_ID_WIDTH-1:0]                  chip0_ddr_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   chip0_ddr_M_AXI_RDATA;
wire [1:0]                               chip0_ddr_M_AXI_RRESP;
wire                                     chip0_ddr_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   chip0_ddr_M_AXI_RUSER;
wire                                     chip0_ddr_M_AXI_RVALID;
wire                                     chip0_ddr_M_AXI_AWREADY;
wire                                     chip0_ddr_M_AXI_WREADY;
wire [ddr_ID_WIDTH-1:0]                  chip0_ddr_M_AXI_BID;
wire [1:0]                               chip0_ddr_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   chip0_ddr_M_AXI_BUSER;
wire                                     chip0_ddr_M_AXI_BVALID;

wire                                     chip1_ddr_M_AXI_ARREADY;
wire [ddr_ID_WIDTH-1:0]                  chip1_ddr_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   chip1_ddr_M_AXI_RDATA;
wire [1:0]                               chip1_ddr_M_AXI_RRESP;
wire                                     chip1_ddr_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   chip1_ddr_M_AXI_RUSER;
wire                                     chip1_ddr_M_AXI_RVALID;
wire                                     chip1_ddr_M_AXI_AWREADY;
wire                                     chip1_ddr_M_AXI_WREADY;
wire [ddr_ID_WIDTH-1:0]                  chip1_ddr_M_AXI_BID;
wire [1:0]                               chip1_ddr_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   chip1_ddr_M_AXI_BUSER;
wire                                     chip1_ddr_M_AXI_BVALID;

reg                                      clk;
reg                                      rst_n;

assign chip0_serdes0_S_AXI_AWID = 1;
assign chip0_serdes0_S_AXI_AWADDR = 0;
assign chip0_serdes0_S_AXI_AWLEN = 0;
assign chip0_serdes0_S_AXI_AWSIZE = 0;
assign chip0_serdes0_S_AXI_AWBURST = 0;
assign chip0_serdes0_S_AXI_AWLOCK = 0;
assign chip0_serdes0_S_AXI_AWCACHE = 0;
assign chip0_serdes0_S_AXI_AWPROT = 0;
assign chip0_serdes0_S_AXI_AWQOS = 0;
assign chip0_serdes0_S_AXI_AWUSER = 0;
assign chip0_serdes0_S_AXI_AWVALID = 0;
assign chip0_serdes0_S_AXI_WDATA = 0;
assign chip0_serdes0_S_AXI_WSTRB = 0;
assign chip0_serdes0_S_AXI_WLAST = 0;
assign chip0_serdes0_S_AXI_WUSER = 0;
assign chip0_serdes0_S_AXI_WVALID = 0;
assign chip0_serdes0_S_AXI_BREADY = 0;
assign chip0_serdes0_S_AXI_ARID = 1;
assign chip0_serdes0_S_AXI_ARADDR = 0;
assign chip0_serdes0_S_AXI_ARLEN = 0;
assign chip0_serdes0_S_AXI_ARSIZE = 0;
assign chip0_serdes0_S_AXI_ARBURST = 0;
assign chip0_serdes0_S_AXI_ARLOCK = 0;
assign chip0_serdes0_S_AXI_ARCACHE = 0;
assign chip0_serdes0_S_AXI_ARPROT = 0;
assign chip0_serdes0_S_AXI_ARQOS = 0;
assign chip0_serdes0_S_AXI_ARUSER = 0;
assign chip0_serdes0_S_AXI_ARVALID = 0;
assign chip0_serdes0_S_AXI_RREADY = 0;
assign chip1_serdes1_S_AXI_AWID = 2;
assign chip1_serdes1_S_AXI_AWADDR = 0;
assign chip1_serdes1_S_AXI_AWLEN = 0;
assign chip1_serdes1_S_AXI_AWSIZE = 0;
assign chip1_serdes1_S_AXI_AWBURST = 0;
assign chip1_serdes1_S_AXI_AWLOCK = 0;
assign chip1_serdes1_S_AXI_AWCACHE = 0;
assign chip1_serdes1_S_AXI_AWPROT = 0;
assign chip1_serdes1_S_AXI_AWQOS = 0;
assign chip1_serdes1_S_AXI_AWUSER = 0;
assign chip1_serdes1_S_AXI_AWVALID = 0;
assign chip1_serdes1_S_AXI_WDATA = 0;
assign chip1_serdes1_S_AXI_WSTRB = 0;
assign chip1_serdes1_S_AXI_WLAST = 0;
assign chip1_serdes1_S_AXI_WUSER = 0;
assign chip1_serdes1_S_AXI_WVALID = 0;
assign chip1_serdes1_S_AXI_BREADY = 0;
assign chip1_serdes1_S_AXI_ARID = 2;
assign chip1_serdes1_S_AXI_ARADDR = 0;
assign chip1_serdes1_S_AXI_ARLEN = 0;
assign chip1_serdes1_S_AXI_ARSIZE = 0;
assign chip1_serdes1_S_AXI_ARBURST = 0;
assign chip1_serdes1_S_AXI_ARLOCK = 0;
assign chip1_serdes1_S_AXI_ARCACHE = 0;
assign chip1_serdes1_S_AXI_ARPROT = 0;
assign chip1_serdes1_S_AXI_ARQOS = 0;
assign chip1_serdes1_S_AXI_ARUSER = 0;
assign chip1_serdes1_S_AXI_ARVALID = 0;
assign chip1_serdes1_S_AXI_RREADY = 0;
assign chip0_serdes0_M_AXI_AWREADY = 0;
assign chip0_serdes0_M_AXI_WREADY = 0;
assign chip0_serdes0_M_AXI_BID = 0;
assign chip0_serdes0_M_AXI_BRESP = 0;
assign chip0_serdes0_M_AXI_BUSER = 0;
assign chip0_serdes0_M_AXI_BVALID = 0;
assign chip0_serdes0_M_AXI_ARREADY = 0;
assign chip0_serdes0_M_AXI_RID = 0;
assign chip0_serdes0_M_AXI_RDATA = 0;
assign chip0_serdes0_M_AXI_RRESP = 0;
assign chip0_serdes0_M_AXI_RLAST = 0;
assign chip0_serdes0_M_AXI_RUSER = 0;
assign chip0_serdes0_M_AXI_RVALID = 0;
assign chip1_serdes1_M_AXI_AWREADY = 0;
assign chip1_serdes1_M_AXI_WREADY = 0;
assign chip1_serdes1_M_AXI_BID = 0;
assign chip1_serdes1_M_AXI_BRESP = 0;
assign chip1_serdes1_M_AXI_BUSER = 0;
assign chip1_serdes1_M_AXI_BVALID = 0;
assign chip1_serdes1_M_AXI_ARREADY = 0;
assign chip1_serdes1_M_AXI_RID = 0;
assign chip1_serdes1_M_AXI_RDATA = 0;
assign chip1_serdes1_M_AXI_RRESP = 0;
assign chip1_serdes1_M_AXI_RLAST = 0;
assign chip1_serdes1_M_AXI_RUSER = 0;
assign chip1_serdes1_M_AXI_RVALID = 0;

wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      chip0_serdes0_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  chip0_serdes0_M_AXI_ARADDR;
wire [7:0]                               chip0_serdes0_M_AXI_ARLEN;
wire [2:0]                               chip0_serdes0_M_AXI_ARSIZE;
wire [1:0]                               chip0_serdes0_M_AXI_ARBURST;
wire                                     chip0_serdes0_M_AXI_ARLOCK;
wire [3:0]                               chip0_serdes0_M_AXI_ARCACHE;
wire [2:0]                               chip0_serdes0_M_AXI_ARPROT;
wire [3:0]                               chip0_serdes0_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  chip0_serdes0_M_AXI_ARUSER;
wire                                     chip0_serdes0_M_AXI_ARVALID;
wire                                     chip0_serdes0_M_AXI_RREADY;
wire                                     chip0_serdes0_S_AXI_ARREADY;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip0_serdes0_S_AXI_RID;
wire [AXI4_FULL_S_AXI_RDATA_WIDTH-1:0]   chip0_serdes0_S_AXI_RDATA;
wire [1:0]                               chip0_serdes0_S_AXI_RRESP;
wire                                     chip0_serdes0_S_AXI_RLAST;
wire [AXI4_FULL_S_AXI_RUSER_WIDTH-1:0]   chip0_serdes0_S_AXI_RUSER;
wire                                     chip0_serdes0_S_AXI_RVALID;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      chip0_serdes0_M_AXI_AWID;
wire [AXI4_FULL_M_AXI_AWADDR_WIDTH-1:0]  chip0_serdes0_M_AXI_AWADDR;
wire [7:0]                               chip0_serdes0_M_AXI_AWLEN;
wire [2:0]                               chip0_serdes0_M_AXI_AWSIZE;
wire [1:0]                               chip0_serdes0_M_AXI_AWBURST;
wire                                     chip0_serdes0_M_AXI_AWLOCK;
wire [3:0]                               chip0_serdes0_M_AXI_AWCACHE;
wire [2:0]                               chip0_serdes0_M_AXI_AWPROT;
wire [3:0]                               chip0_serdes0_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  chip0_serdes0_M_AXI_AWUSER;
wire                                     chip0_serdes0_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   chip0_serdes0_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    chip0_serdes0_M_AXI_WSTRB;
wire                                     chip0_serdes0_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   chip0_serdes0_M_AXI_WUSER;
wire                                     chip0_serdes0_M_AXI_WVALID;
wire                                     chip0_serdes0_M_AXI_BREADY;
wire                                     chip0_serdes0_S_AXI_AWREADY;
wire                                     chip0_serdes0_S_AXI_WREADY;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip0_serdes0_S_AXI_BID;
wire [1:0]                               chip0_serdes0_S_AXI_BRESP;
wire [AXI4_FULL_S_AXI_BUSER_WIDTH-1:0]   chip0_serdes0_S_AXI_BUSER;
wire                                     chip0_serdes0_S_AXI_BVALID;

wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      connected_serdes_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  connected_serdes_M_AXI_ARADDR;
wire [7:0]                               connected_serdes_M_AXI_ARLEN;
wire [2:0]                               connected_serdes_M_AXI_ARSIZE;
wire [1:0]                               connected_serdes_M_AXI_ARBURST;
wire                                     connected_serdes_M_AXI_ARLOCK;
wire [3:0]                               connected_serdes_M_AXI_ARCACHE;
wire [2:0]                               connected_serdes_M_AXI_ARPROT;
wire [3:0]                               connected_serdes_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  connected_serdes_M_AXI_ARUSER;
wire                                     connected_serdes_M_AXI_ARVALID;
wire                                     connected_serdes_M_AXI_RREADY;
wire                                     connected_serdes_S_AXI_ARREADY;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      connected_serdes_S_AXI_RID;
wire [AXI4_FULL_S_AXI_RDATA_WIDTH-1:0]   connected_serdes_S_AXI_RDATA;
wire [1:0]                               connected_serdes_S_AXI_RRESP;
wire                                     connected_serdes_S_AXI_RLAST;
wire [AXI4_FULL_S_AXI_RUSER_WIDTH-1:0]   connected_serdes_S_AXI_RUSER;
wire                                     connected_serdes_S_AXI_RVALID;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      connected_serdes_M_AXI_AWID;
wire [AXI4_FULL_M_AXI_AWADDR_WIDTH-1:0]  connected_serdes_M_AXI_AWADDR;
wire [7:0]                               connected_serdes_M_AXI_AWLEN;
wire [2:0]                               connected_serdes_M_AXI_AWSIZE;
wire [1:0]                               connected_serdes_M_AXI_AWBURST;
wire                                     connected_serdes_M_AXI_AWLOCK;
wire [3:0]                               connected_serdes_M_AXI_AWCACHE;
wire [2:0]                               connected_serdes_M_AXI_AWPROT;
wire [3:0]                               connected_serdes_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  connected_serdes_M_AXI_AWUSER;
wire                                     connected_serdes_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   connected_serdes_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    connected_serdes_M_AXI_WSTRB;
wire                                     connected_serdes_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   connected_serdes_M_AXI_WUSER;
wire                                     connected_serdes_M_AXI_WVALID;
wire                                     connected_serdes_M_AXI_BREADY;
wire                                     connected_serdes_S_AXI_AWREADY;
wire                                     connected_serdes_S_AXI_WREADY;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      connected_serdes_S_AXI_BID;
wire [1:0]                               connected_serdes_S_AXI_BRESP;
wire [AXI4_FULL_S_AXI_BUSER_WIDTH-1:0]   connected_serdes_S_AXI_BUSER;
wire                                     connected_serdes_S_AXI_BVALID;

wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip1_serdes1_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  chip1_serdes1_M_AXI_ARADDR;
wire [7:0]                               chip1_serdes1_M_AXI_ARLEN;
wire [2:0]                               chip1_serdes1_M_AXI_ARSIZE;
wire [1:0]                               chip1_serdes1_M_AXI_ARBURST;
wire                                     chip1_serdes1_M_AXI_ARLOCK;
wire [3:0]                               chip1_serdes1_M_AXI_ARCACHE;
wire [2:0]                               chip1_serdes1_M_AXI_ARPROT;
wire [3:0]                               chip1_serdes1_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  chip1_serdes1_M_AXI_ARUSER;
wire                                     chip1_serdes1_M_AXI_ARVALID;
wire                                     chip1_serdes1_M_AXI_RREADY;
wire                                     chip1_serdes1_S_AXI_ARREADY;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip1_serdes1_S_AXI_RID;
wire [AXI4_FULL_S_AXI_RDATA_WIDTH-1:0]   chip1_serdes1_S_AXI_RDATA;
wire [1:0]                               chip1_serdes1_S_AXI_RRESP;
wire                                     chip1_serdes1_S_AXI_RLAST;
wire [AXI4_FULL_S_AXI_RUSER_WIDTH-1:0]   chip1_serdes1_S_AXI_RUSER;
wire                                     chip1_serdes1_S_AXI_RVALID;
wire [AXI4_FULL_M_AXI_ID_WIDTH-1:0]      chip1_serdes1_M_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  chip1_serdes1_M_AXI_AWADDR;
wire [7:0]                               chip1_serdes1_M_AXI_AWLEN;
wire [2:0]                               chip1_serdes1_M_AXI_AWSIZE;
wire [1:0]                               chip1_serdes1_M_AXI_AWBURST;
wire                                     chip1_serdes1_M_AXI_AWLOCK;
wire [3:0]                               chip1_serdes1_M_AXI_AWCACHE;
wire [2:0]                               chip1_serdes1_M_AXI_AWPROT;
wire [3:0]                               chip1_serdes1_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  chip1_serdes1_M_AXI_AWUSER;
wire                                     chip1_serdes1_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   chip1_serdes1_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    chip1_serdes1_M_AXI_WSTRB;
wire                                     chip1_serdes1_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   chip1_serdes1_M_AXI_WUSER;
wire                                     chip1_serdes1_M_AXI_WVALID;
wire                                     chip1_serdes1_M_AXI_BREADY;
wire                                     chip1_serdes1_S_AXI_AWREADY;
wire                                     chip1_serdes1_S_AXI_WREADY;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      chip1_serdes1_S_AXI_BID;
wire [1:0]                               chip1_serdes1_S_AXI_BRESP;
wire [AXI4_FULL_S_AXI_BUSER_WIDTH-1:0]   chip1_serdes1_S_AXI_BUSER;
wire                                     chip1_serdes1_S_AXI_BVALID;

wire [ddr_ID_WIDTH-1:0]                  chip0_ddr_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  chip0_ddr_M_AXI_ARADDR;
wire [7:0]                               chip0_ddr_M_AXI_ARLEN;
wire [2:0]                               chip0_ddr_M_AXI_ARSIZE;
wire [1:0]                               chip0_ddr_M_AXI_ARBURST;
wire                                     chip0_ddr_M_AXI_ARLOCK;
wire [3:0]                               chip0_ddr_M_AXI_ARCACHE;
wire [2:0]                               chip0_ddr_M_AXI_ARPROT;
wire [3:0]                               chip0_ddr_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  chip0_ddr_M_AXI_ARUSER;
wire                                     chip0_ddr_M_AXI_ARVALID;
wire                                     chip0_ddr_M_AXI_RREADY;
wire [ddr_ID_WIDTH-1:0]                  chip0_ddr_M_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  chip0_ddr_M_AXI_AWADDR;
wire [7:0]                               chip0_ddr_M_AXI_AWLEN;
wire [2:0]                               chip0_ddr_M_AXI_AWSIZE;
wire [1:0]                               chip0_ddr_M_AXI_AWBURST;
wire                                     chip0_ddr_M_AXI_AWLOCK;
wire [3:0]                               chip0_ddr_M_AXI_AWCACHE;
wire [2:0]                               chip0_ddr_M_AXI_AWPROT;
wire [3:0]                               chip0_ddr_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  chip0_ddr_M_AXI_AWUSER;
wire                                     chip0_ddr_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   chip0_ddr_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    chip0_ddr_M_AXI_WSTRB;
wire                                     chip0_ddr_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   chip0_ddr_M_AXI_WUSER;
wire                                     chip0_ddr_M_AXI_WVALID;
wire                                     chip0_ddr_M_AXI_BREADY;

wire [ddr_ID_WIDTH-1:0]                  chip1_ddr_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  chip1_ddr_M_AXI_ARADDR;
wire [7:0]                               chip1_ddr_M_AXI_ARLEN;
wire [2:0]                               chip1_ddr_M_AXI_ARSIZE;
wire [1:0]                               chip1_ddr_M_AXI_ARBURST;
wire                                     chip1_ddr_M_AXI_ARLOCK;
wire [3:0]                               chip1_ddr_M_AXI_ARCACHE;
wire [2:0]                               chip1_ddr_M_AXI_ARPROT;
wire [3:0]                               chip1_ddr_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  chip1_ddr_M_AXI_ARUSER;
wire                                     chip1_ddr_M_AXI_ARVALID;
wire                                     chip1_ddr_M_AXI_RREADY;
wire [ddr_ID_WIDTH-1:0]                  chip1_ddr_M_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  chip1_ddr_M_AXI_AWADDR;
wire [7:0]                               chip1_ddr_M_AXI_AWLEN;
wire [2:0]                               chip1_ddr_M_AXI_AWSIZE;
wire [1:0]                               chip1_ddr_M_AXI_AWBURST;
wire                                     chip1_ddr_M_AXI_AWLOCK;
wire [3:0]                               chip1_ddr_M_AXI_AWCACHE;
wire [2:0]                               chip1_ddr_M_AXI_AWPROT;
wire [3:0]                               chip1_ddr_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  chip1_ddr_M_AXI_AWUSER;
wire                                     chip1_ddr_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   chip1_ddr_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    chip1_ddr_M_AXI_WSTRB;
wire                                     chip1_ddr_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   chip1_ddr_M_AXI_WUSER;
wire                                     chip1_ddr_M_AXI_WVALID;
wire                                     chip1_ddr_M_AXI_BREADY;

wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  routed_serdes_M_AXI_ARADDR;
wire [AXI4_FULL_M_AXI_AWADDR_WIDTH-1:0]  routed_serdes_M_AXI_AWADDR;

parameter time_step = 1;

reg chip0_cmd_vld_i_reg;
reg chip1_cmd_vld_i_reg;

initial begin
 // rst; 
  apb4_pclk   = 0;
  logic_clk = 0;
  axi4_clk = 0;
  apb4_presetn = 1;
  logic_rst_n = 1;
  axi4_rst_n = 1;
  chip0_cmd = 65'b0;
  chip0_cmd_vld = 0;
  chip1_cmd = 65'b0;
  chip1_cmd_vld = 0;
  #10 apb4_presetn = 0;
  logic_rst_n = 0;
  axi4_rst_n = 0;
  #10 apb4_presetn = 1;
  logic_rst_n = 1;
  axi4_rst_n = 1;

  // Config cmd_rst
  #10 cmd_in_wr(chip0_cmd, chip0_cmd_vld, 0, 1);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 0, 1);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config insn_baseaddr
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 4, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 4, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config insn_number
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 8, 100);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 8, 2);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config insn_axi_burt_length
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 12, 31);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 12, 31);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config chip local highaddr
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 16, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 16, 'h10);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config chip local dependency reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 20, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 20, 1);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config expand weight sram reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 24, 1);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 24, 1);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config ifmap broadcast reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 28, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 28, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config ifmap scale broadcast reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 32, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 32, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config weight broadcast reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 36, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 36, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config weight scale broadcast reg
  @(posedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 40, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 40, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config outlier index broadcast reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 44, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 44, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config vcupara broadcast reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 48, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 48, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config vcures broadcast reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 52, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 52, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config vcucode broadcast reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 56, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 56, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config vculut broadcast reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 60, 0);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 60, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 308, 'h400016);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 60, 0);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

  // Config cmd_start reg
  @(negedge u_apb_master_chip0.pready) #10cmd_in_wr(chip0_cmd, chip0_cmd_vld, 0, 2);
  cmd_in_wr(chip1_cmd, chip1_cmd_vld, 0, 2);
  @(negedge apb4_pclk) chip0_cmd_vld = 0;
  chip1_cmd_vld = 0;

end

always #10 apb4_pclk = ~apb4_pclk;
always #1 logic_clk = ~logic_clk;
always #2 axi4_clk = ~axi4_clk;

//-- RST
task rst;
  begin
    apb4_pclk     = 1;
    apb4_presetn  = 1;
    chip0_cmd     = 56'b0;
    chip0_cmd_vld = 0;
    chip1_cmd     = 56'b0;
    chip1_cmd_vld = 0;
    #20 apb4_presetn = 0;
    #10 apb4_presetn = 1;
  end
endtask

always @(posedge apb4_pclk or negedge apb4_presetn) begin
  chip0_cmd_vld_i_reg <= chip0_cmd_vld;
  chip1_cmd_vld_i_reg <= chip1_cmd_vld;
end

//-- write
task cmd_in_wr;
  output [64:0] cmd;
  output        cmd_vld;
  input  [31:0] addr;
  input  [31:0] data;

  begin
    cmd_vld = 1;
    cmd     = {1'b1, addr, data};
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
  #1000000 $finish;
end

apb u_apb_master_chip0
(
  .pclk          (apb4_pclk    ),
  .prst_n        (apb4_presetn ),
  .cmd           (chip0_cmd          ),
  .cmd_vld       (chip0_cmd_vld      ),
  .cmd_rd_data   (chip0_cmd_rd_data  ),
  .paddr         (chip0_apb4_paddr   ),
  .pwrite        (chip0_apb4_pwrite  ),
  .psel          (chip0_apb4_psel    ),
  .penable       (chip0_apb4_penable ),
  .pwdata        (chip0_apb4_pwdata  ),
  .prdata        (chip0_apb4_prdata  ),
  .pready        (chip0_apb4_pready  ),
  .pslverr       (chip0_apb4_pslverr )
);

apb u_apb_master_chip1
(
  .pclk          (apb4_pclk    ),
  .prst_n        (apb4_presetn ),
  .cmd           (chip1_cmd          ),
  .cmd_vld       (chip1_cmd_vld      ),
  .cmd_rd_data   (chip1_cmd_rd_data  ),
  .paddr         (chip1_apb4_paddr   ),
  .pwrite        (chip1_apb4_pwrite  ),
  .psel          (chip1_apb4_psel    ),
  .penable       (chip1_apb4_penable ),
  .pwdata        (chip1_apb4_pwdata  ),
  .prdata        (chip1_apb4_prdata  ),
  .pready        (chip1_apb4_pready  ),
  .pslverr       (chip1_apb4_pslverr )
);

npu_top_chiplet #(
  .AXI4_FULL_S_AXI_BURSTLENGTH  ( AXI4_FULL_S_AXI_BURSTLENGTH  ),
  .AXI4_FULL_M_AXI_BURSTLENGTH  ( AXI4_FULL_M_AXI_BURSTLENGTH  ),
  .AXI4_FULL_M_AXI_MAX_4K       ( AXI4_FULL_M_AXI_MAX_4K       ),
  .AXI4_FULL_S_AXI_MAX_4K       ( AXI4_FULL_S_AXI_MAX_4K       ),
  .AXI4_FULL_OUTSTANDING_DEPTH  ( AXI4_FULL_OUTSTANDING_DEPTH  ),
  .AXI4_FULL_M_AXI_ID_WIDTH     ( AXI4_FULL_M_AXI_ID_WIDTH     ),
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
) u_npu_top_chiplet_0(
  .mode_sel              ( 3'b010                      ),
  .axi4_clk              ( axi4_clk                    ),
  .axi4_rst_n            ( axi4_rst_n                  ),
  .apb4_pclk             ( apb4_pclk                   ),
  .apb4_presetn          ( apb4_presetn                ),
  .apb4_paddr            ( chip0_apb4_paddr            ),
  .apb4_psel             ( chip0_apb4_psel             ),
  .apb4_penable          ( chip0_apb4_penable          ),
  .apb4_pwrite           ( chip0_apb4_pwrite           ),
  .apb4_pwdata           ( chip0_apb4_pwdata           ),
  .apb4_pstrb            ( chip0_apb4_pstrb            ),
  .apb4_pprot            ( chip0_apb4_pprot            ),
  .serdes0_M_AXI_ARREADY ( chip0_serdes0_M_AXI_ARREADY ),
  .serdes0_M_AXI_RID     ( chip0_serdes0_M_AXI_RID     ),
  .serdes0_M_AXI_RDATA   ( chip0_serdes0_M_AXI_RDATA   ),
  .serdes0_M_AXI_RRESP   ( chip0_serdes0_M_AXI_RRESP   ),
  .serdes0_M_AXI_RLAST   ( chip0_serdes0_M_AXI_RLAST   ),
  .serdes0_M_AXI_RUSER   ( chip0_serdes0_M_AXI_RUSER   ),
  .serdes0_M_AXI_RVALID  ( chip0_serdes0_M_AXI_RVALID  ),
  .serdes0_S_AXI_ARID    ( chip0_serdes0_S_AXI_ARID    ),
  .serdes0_S_AXI_ARADDR  ( chip0_serdes0_S_AXI_ARADDR  ),
  .serdes0_S_AXI_ARLEN   ( chip0_serdes0_S_AXI_ARLEN   ),
  .serdes0_S_AXI_ARSIZE  ( chip0_serdes0_S_AXI_ARSIZE  ),
  .serdes0_S_AXI_ARBURST ( chip0_serdes0_S_AXI_ARBURST ),
  .serdes0_S_AXI_ARLOCK  ( chip0_serdes0_S_AXI_ARLOCK  ),
  .serdes0_S_AXI_ARCACHE ( chip0_serdes0_S_AXI_ARCACHE ),
  .serdes0_S_AXI_ARPROT  ( chip0_serdes0_S_AXI_ARPROT  ),
  .serdes0_S_AXI_ARQOS   ( chip0_serdes0_S_AXI_ARQOS   ),
  .serdes0_S_AXI_ARUSER  ( chip0_serdes0_S_AXI_ARUSER  ),
  .serdes0_S_AXI_ARVALID ( chip0_serdes0_S_AXI_ARVALID ),
  .serdes0_S_AXI_RREADY  ( chip0_serdes0_S_AXI_RREADY  ),
  .serdes0_M_AXI_AWREADY ( chip0_serdes0_M_AXI_AWREADY ),
  .serdes0_M_AXI_WREADY  ( chip0_serdes0_M_AXI_WREADY  ),
  .serdes0_M_AXI_BID     ( chip0_serdes0_M_AXI_BID     ),
  .serdes0_M_AXI_BRESP   ( chip0_serdes0_M_AXI_BRESP   ),
  .serdes0_M_AXI_BUSER   ( chip0_serdes0_M_AXI_BUSER   ),
  .serdes0_M_AXI_BVALID  ( chip0_serdes0_M_AXI_BVALID  ),
  .serdes0_S_AXI_AWID    ( chip0_serdes0_S_AXI_AWID    ),
  .serdes0_S_AXI_AWADDR  ( chip0_serdes0_S_AXI_AWADDR  ),
  .serdes0_S_AXI_AWLEN   ( chip0_serdes0_S_AXI_AWLEN   ),
  .serdes0_S_AXI_AWSIZE  ( chip0_serdes0_S_AXI_AWSIZE  ),
  .serdes0_S_AXI_AWBURST ( chip0_serdes0_S_AXI_AWBURST ),
  .serdes0_S_AXI_AWLOCK  ( chip0_serdes0_S_AXI_AWLOCK  ),
  .serdes0_S_AXI_AWCACHE ( chip0_serdes0_S_AXI_AWCACHE ),
  .serdes0_S_AXI_AWPROT  ( chip0_serdes0_S_AXI_AWPROT  ),
  .serdes0_S_AXI_AWQOS   ( chip0_serdes0_S_AXI_AWQOS   ),
  .serdes0_S_AXI_AWUSER  ( chip0_serdes0_S_AXI_AWUSER  ),
  .serdes0_S_AXI_AWVALID ( chip0_serdes0_S_AXI_AWVALID ),
  .serdes0_S_AXI_WDATA   ( chip0_serdes0_S_AXI_WDATA   ),
  .serdes0_S_AXI_WSTRB   ( chip0_serdes0_S_AXI_WSTRB   ),
  .serdes0_S_AXI_WLAST   ( chip0_serdes0_S_AXI_WLAST   ),
  .serdes0_S_AXI_WUSER   ( chip0_serdes0_S_AXI_WUSER   ),
  .serdes0_S_AXI_WVALID  ( chip0_serdes0_S_AXI_WVALID  ),
  .serdes0_S_AXI_BREADY  ( chip0_serdes0_S_AXI_BREADY  ),
  .serdes1_M_AXI_ARREADY ( connected_serdes_M_AXI_ARREADY ),
  .serdes1_M_AXI_RID     ( connected_serdes_M_AXI_RID     ),
  .serdes1_M_AXI_RDATA   ( connected_serdes_M_AXI_RDATA   ),
  .serdes1_M_AXI_RRESP   ( connected_serdes_M_AXI_RRESP   ),
  .serdes1_M_AXI_RLAST   ( connected_serdes_M_AXI_RLAST   ),
  .serdes1_M_AXI_RUSER   ( connected_serdes_M_AXI_RUSER   ),
  .serdes1_M_AXI_RVALID  ( connected_serdes_M_AXI_RVALID  ),
  .serdes1_S_AXI_ARID    ( connected_serdes_S_AXI_ARID    ),
  .serdes1_S_AXI_ARADDR  ( connected_serdes_S_AXI_ARADDR  ),
  .serdes1_S_AXI_ARLEN   ( connected_serdes_S_AXI_ARLEN   ),
  .serdes1_S_AXI_ARSIZE  ( connected_serdes_S_AXI_ARSIZE  ),
  .serdes1_S_AXI_ARBURST ( connected_serdes_S_AXI_ARBURST ),
  .serdes1_S_AXI_ARLOCK  ( connected_serdes_S_AXI_ARLOCK  ),
  .serdes1_S_AXI_ARCACHE ( connected_serdes_S_AXI_ARCACHE ),
  .serdes1_S_AXI_ARPROT  ( connected_serdes_S_AXI_ARPROT  ),
  .serdes1_S_AXI_ARQOS   ( connected_serdes_S_AXI_ARQOS   ),
  .serdes1_S_AXI_ARUSER  ( connected_serdes_S_AXI_ARUSER  ),
  .serdes1_S_AXI_ARVALID ( connected_serdes_S_AXI_ARVALID ),
  .serdes1_S_AXI_RREADY  ( connected_serdes_S_AXI_RREADY  ),
  .serdes1_M_AXI_AWREADY ( connected_serdes_M_AXI_AWREADY ),
  .serdes1_M_AXI_WREADY  ( connected_serdes_M_AXI_WREADY  ),
  .serdes1_M_AXI_BID     ( connected_serdes_M_AXI_BID     ),
  .serdes1_M_AXI_BRESP   ( connected_serdes_M_AXI_BRESP   ),
  .serdes1_M_AXI_BUSER   ( connected_serdes_M_AXI_BUSER   ),
  .serdes1_M_AXI_BVALID  ( connected_serdes_M_AXI_BVALID  ),
  .serdes1_S_AXI_AWID    ( connected_serdes_S_AXI_AWID    ),
  .serdes1_S_AXI_AWADDR  ( connected_serdes_S_AXI_AWADDR  ),
  .serdes1_S_AXI_AWLEN   ( connected_serdes_S_AXI_AWLEN   ),
  .serdes1_S_AXI_AWSIZE  ( connected_serdes_S_AXI_AWSIZE  ),
  .serdes1_S_AXI_AWBURST ( connected_serdes_S_AXI_AWBURST ),
  .serdes1_S_AXI_AWLOCK  ( connected_serdes_S_AXI_AWLOCK  ),
  .serdes1_S_AXI_AWCACHE ( connected_serdes_S_AXI_AWCACHE ),
  .serdes1_S_AXI_AWPROT  ( connected_serdes_S_AXI_AWPROT  ),
  .serdes1_S_AXI_AWQOS   ( connected_serdes_S_AXI_AWQOS   ),
  .serdes1_S_AXI_AWUSER  ( connected_serdes_S_AXI_AWUSER  ),
  .serdes1_S_AXI_AWVALID ( connected_serdes_S_AXI_AWVALID ),
  .serdes1_S_AXI_WDATA   ( connected_serdes_S_AXI_WDATA   ),
  .serdes1_S_AXI_WSTRB   ( connected_serdes_S_AXI_WSTRB   ),
  .serdes1_S_AXI_WLAST   ( connected_serdes_S_AXI_WLAST   ),
  .serdes1_S_AXI_WUSER   ( connected_serdes_S_AXI_WUSER   ),
  .serdes1_S_AXI_WVALID  ( connected_serdes_S_AXI_WVALID  ),
  .serdes1_S_AXI_BREADY  ( connected_serdes_S_AXI_BREADY  ),
  .ddr_M_AXI_ARREADY     ( chip0_ddr_M_AXI_ARREADY     ),
  .ddr_M_AXI_RID         ( chip0_ddr_M_AXI_RID         ),
  .ddr_M_AXI_RDATA       ( chip0_ddr_M_AXI_RDATA       ),
  .ddr_M_AXI_RRESP       ( chip0_ddr_M_AXI_RRESP       ),
  .ddr_M_AXI_RLAST       ( chip0_ddr_M_AXI_RLAST       ),
  .ddr_M_AXI_RUSER       ( chip0_ddr_M_AXI_RUSER       ),
  .ddr_M_AXI_RVALID      ( chip0_ddr_M_AXI_RVALID      ),
  .ddr_M_AXI_AWREADY     ( chip0_ddr_M_AXI_AWREADY     ),
  .ddr_M_AXI_WREADY      ( chip0_ddr_M_AXI_WREADY      ),
  .ddr_M_AXI_BID         ( chip0_ddr_M_AXI_BID         ),
  .ddr_M_AXI_BRESP       ( chip0_ddr_M_AXI_BRESP       ),
  .ddr_M_AXI_BUSER       ( chip0_ddr_M_AXI_BUSER       ),
  .ddr_M_AXI_BVALID      ( chip0_ddr_M_AXI_BVALID      ),
  .clk                   ( logic_clk             ),
  .rst_n                 ( logic_rst_n           ),
  .serdes0_M_AXI_ARID    ( chip0_serdes0_M_AXI_ARID    ),
  .serdes0_M_AXI_ARADDR  ( chip0_serdes0_M_AXI_ARADDR  ),
  .serdes0_M_AXI_ARLEN   ( chip0_serdes0_M_AXI_ARLEN   ),
  .serdes0_M_AXI_ARSIZE  ( chip0_serdes0_M_AXI_ARSIZE  ),
  .serdes0_M_AXI_ARBURST ( chip0_serdes0_M_AXI_ARBURST ),
  .serdes0_M_AXI_ARLOCK  ( chip0_serdes0_M_AXI_ARLOCK  ),
  .serdes0_M_AXI_ARCACHE ( chip0_serdes0_M_AXI_ARCACHE ),
  .serdes0_M_AXI_ARPROT  ( chip0_serdes0_M_AXI_ARPROT  ),
  .serdes0_M_AXI_ARQOS   ( chip0_serdes0_M_AXI_ARQOS   ),
  .serdes0_M_AXI_ARUSER  ( chip0_serdes0_M_AXI_ARUSER  ),
  .serdes0_M_AXI_ARVALID ( chip0_serdes0_M_AXI_ARVALID ),
  .serdes0_M_AXI_RREADY  ( chip0_serdes0_M_AXI_RREADY  ),
  .serdes0_S_AXI_ARREADY ( chip0_serdes0_S_AXI_ARREADY ),
  .serdes0_S_AXI_RID     ( chip0_serdes0_S_AXI_RID     ),
  .serdes0_S_AXI_RDATA   ( chip0_serdes0_S_AXI_RDATA   ),
  .serdes0_S_AXI_RRESP   ( chip0_serdes0_S_AXI_RRESP   ),
  .serdes0_S_AXI_RLAST   ( chip0_serdes0_S_AXI_RLAST   ),
  .serdes0_S_AXI_RUSER   ( chip0_serdes0_S_AXI_RUSER   ),
  .serdes0_S_AXI_RVALID  ( chip0_serdes0_S_AXI_RVALID  ),
  .serdes0_M_AXI_AWID    ( chip0_serdes0_M_AXI_AWID    ),
  .serdes0_M_AXI_AWADDR  ( chip0_serdes0_M_AXI_AWADDR  ),
  .serdes0_M_AXI_AWLEN   ( chip0_serdes0_M_AXI_AWLEN   ),
  .serdes0_M_AXI_AWSIZE  ( chip0_serdes0_M_AXI_AWSIZE  ),
  .serdes0_M_AXI_AWBURST ( chip0_serdes0_M_AXI_AWBURST ),
  .serdes0_M_AXI_AWLOCK  ( chip0_serdes0_M_AXI_AWLOCK  ),
  .serdes0_M_AXI_AWCACHE ( chip0_serdes0_M_AXI_AWCACHE ),
  .serdes0_M_AXI_AWPROT  ( chip0_serdes0_M_AXI_AWPROT  ),
  .serdes0_M_AXI_AWQOS   ( chip0_serdes0_M_AXI_AWQOS   ),
  .serdes0_M_AXI_AWUSER  ( chip0_serdes0_M_AXI_AWUSER  ),
  .serdes0_M_AXI_AWVALID ( chip0_serdes0_M_AXI_AWVALID ),
  .serdes0_M_AXI_WDATA   ( chip0_serdes0_M_AXI_WDATA   ),
  .serdes0_M_AXI_WSTRB   ( chip0_serdes0_M_AXI_WSTRB   ),
  .serdes0_M_AXI_WLAST   ( chip0_serdes0_M_AXI_WLAST   ),
  .serdes0_M_AXI_WUSER   ( chip0_serdes0_M_AXI_WUSER   ),
  .serdes0_M_AXI_WVALID  ( chip0_serdes0_M_AXI_WVALID  ),
  .serdes0_M_AXI_BREADY  ( chip0_serdes0_M_AXI_BREADY  ),
  .serdes0_S_AXI_AWREADY ( chip0_serdes0_S_AXI_AWREADY ),
  .serdes0_S_AXI_WREADY  ( chip0_serdes0_S_AXI_WREADY  ),
  .serdes0_S_AXI_BID     ( chip0_serdes0_S_AXI_BID     ),
  .serdes0_S_AXI_BRESP   ( chip0_serdes0_S_AXI_BRESP   ),
  .serdes0_S_AXI_BUSER   ( chip0_serdes0_S_AXI_BUSER   ),
  .serdes0_S_AXI_BVALID  ( chip0_serdes0_S_AXI_BVALID  ),
  .serdes1_M_AXI_ARID    ( connected_serdes_M_AXI_ARID    ),
  .serdes1_M_AXI_ARADDR  ( connected_serdes_M_AXI_ARADDR  ),
  .serdes1_M_AXI_ARLEN   ( connected_serdes_M_AXI_ARLEN   ),
  .serdes1_M_AXI_ARSIZE  ( connected_serdes_M_AXI_ARSIZE  ),
  .serdes1_M_AXI_ARBURST ( connected_serdes_M_AXI_ARBURST ),
  .serdes1_M_AXI_ARLOCK  ( connected_serdes_M_AXI_ARLOCK  ),
  .serdes1_M_AXI_ARCACHE ( connected_serdes_M_AXI_ARCACHE ),
  .serdes1_M_AXI_ARPROT  ( connected_serdes_M_AXI_ARPROT  ),
  .serdes1_M_AXI_ARQOS   ( connected_serdes_M_AXI_ARQOS   ),
  .serdes1_M_AXI_ARUSER  ( connected_serdes_M_AXI_ARUSER  ),
  .serdes1_M_AXI_ARVALID ( connected_serdes_M_AXI_ARVALID ),
  .serdes1_M_AXI_RREADY  ( connected_serdes_M_AXI_RREADY  ),
  .serdes1_S_AXI_ARREADY ( connected_serdes_S_AXI_ARREADY ),
  .serdes1_S_AXI_RID     ( connected_serdes_S_AXI_RID     ),
  .serdes1_S_AXI_RDATA   ( connected_serdes_S_AXI_RDATA   ),
  .serdes1_S_AXI_RRESP   ( connected_serdes_S_AXI_RRESP   ),
  .serdes1_S_AXI_RLAST   ( connected_serdes_S_AXI_RLAST   ),
  .serdes1_S_AXI_RUSER   ( connected_serdes_S_AXI_RUSER   ),
  .serdes1_S_AXI_RVALID  ( connected_serdes_S_AXI_RVALID  ),
  .serdes1_M_AXI_AWID    ( connected_serdes_M_AXI_AWID    ),
  .serdes1_M_AXI_AWADDR  ( connected_serdes_M_AXI_AWADDR  ),
  .serdes1_M_AXI_AWLEN   ( connected_serdes_M_AXI_AWLEN   ),
  .serdes1_M_AXI_AWSIZE  ( connected_serdes_M_AXI_AWSIZE  ),
  .serdes1_M_AXI_AWBURST ( connected_serdes_M_AXI_AWBURST ),
  .serdes1_M_AXI_AWLOCK  ( connected_serdes_M_AXI_AWLOCK  ),
  .serdes1_M_AXI_AWCACHE ( connected_serdes_M_AXI_AWCACHE ),
  .serdes1_M_AXI_AWPROT  ( connected_serdes_M_AXI_AWPROT  ),
  .serdes1_M_AXI_AWQOS   ( connected_serdes_M_AXI_AWQOS   ),
  .serdes1_M_AXI_AWUSER  ( connected_serdes_M_AXI_AWUSER  ),
  .serdes1_M_AXI_AWVALID ( connected_serdes_M_AXI_AWVALID ),
  .serdes1_M_AXI_WDATA   ( connected_serdes_M_AXI_WDATA   ),
  .serdes1_M_AXI_WSTRB   ( connected_serdes_M_AXI_WSTRB   ),
  .serdes1_M_AXI_WLAST   ( connected_serdes_M_AXI_WLAST   ),
  .serdes1_M_AXI_WUSER   ( connected_serdes_M_AXI_WUSER   ),
  .serdes1_M_AXI_WVALID  ( connected_serdes_M_AXI_WVALID  ),
  .serdes1_M_AXI_BREADY  ( connected_serdes_M_AXI_BREADY  ),
  .serdes1_S_AXI_AWREADY ( connected_serdes_S_AXI_AWREADY ),
  .serdes1_S_AXI_WREADY  ( connected_serdes_S_AXI_WREADY  ),
  .serdes1_S_AXI_BID     ( connected_serdes_S_AXI_BID     ),
  .serdes1_S_AXI_BRESP   ( connected_serdes_S_AXI_BRESP   ),
  .serdes1_S_AXI_BUSER   ( connected_serdes_S_AXI_BUSER   ),
  .serdes1_S_AXI_BVALID  ( connected_serdes_S_AXI_BVALID  ),
  .ddr_M_AXI_ARID        ( chip0_ddr_M_AXI_ARID           ),
  .ddr_M_AXI_ARADDR      ( chip0_ddr_M_AXI_ARADDR         ),
  .ddr_M_AXI_ARLEN       ( chip0_ddr_M_AXI_ARLEN          ),
  .ddr_M_AXI_ARSIZE      ( chip0_ddr_M_AXI_ARSIZE         ),
  .ddr_M_AXI_ARBURST     ( chip0_ddr_M_AXI_ARBURST        ),
  .ddr_M_AXI_ARLOCK      ( chip0_ddr_M_AXI_ARLOCK         ),
  .ddr_M_AXI_ARCACHE     ( chip0_ddr_M_AXI_ARCACHE        ),
  .ddr_M_AXI_ARPROT      ( chip0_ddr_M_AXI_ARPROT         ),
  .ddr_M_AXI_ARQOS       ( chip0_ddr_M_AXI_ARQOS          ),
  .ddr_M_AXI_ARUSER      ( chip0_ddr_M_AXI_ARUSER         ),
  .ddr_M_AXI_ARVALID     ( chip0_ddr_M_AXI_ARVALID        ),
  .ddr_M_AXI_RREADY      ( chip0_ddr_M_AXI_RREADY         ),
  .ddr_M_AXI_AWID        ( chip0_ddr_M_AXI_AWID           ),
  .ddr_M_AXI_AWADDR      ( chip0_ddr_M_AXI_AWADDR         ),
  .ddr_M_AXI_AWLEN       ( chip0_ddr_M_AXI_AWLEN          ),
  .ddr_M_AXI_AWSIZE      ( chip0_ddr_M_AXI_AWSIZE         ),
  .ddr_M_AXI_AWBURST     ( chip0_ddr_M_AXI_AWBURST        ),
  .ddr_M_AXI_AWLOCK      ( chip0_ddr_M_AXI_AWLOCK         ),
  .ddr_M_AXI_AWCACHE     ( chip0_ddr_M_AXI_AWCACHE        ),
  .ddr_M_AXI_AWPROT      ( chip0_ddr_M_AXI_AWPROT         ),
  .ddr_M_AXI_AWQOS       ( chip0_ddr_M_AXI_AWQOS          ),
  .ddr_M_AXI_AWUSER      ( chip0_ddr_M_AXI_AWUSER         ),
  .ddr_M_AXI_AWVALID     ( chip0_ddr_M_AXI_AWVALID        ),
  .ddr_M_AXI_WDATA       ( chip0_ddr_M_AXI_WDATA          ),
  .ddr_M_AXI_WSTRB       ( chip0_ddr_M_AXI_WSTRB          ),
  .ddr_M_AXI_WLAST       ( chip0_ddr_M_AXI_WLAST          ),
  .ddr_M_AXI_WUSER       ( chip0_ddr_M_AXI_WUSER          ),
  .ddr_M_AXI_WVALID      ( chip0_ddr_M_AXI_WVALID         ),
  .ddr_M_AXI_BREADY      ( chip0_ddr_M_AXI_BREADY         ),
  .apb4_prdata           ( chip0_apb4_prdata           ),
  .apb4_pslverr          ( chip0_apb4_pslverr          ),
  .apb4_pready           ( chip0_apb4_pready           )
);


npu_top_chiplet #(
  .AXI4_FULL_S_AXI_BURSTLENGTH  ( AXI4_FULL_S_AXI_BURSTLENGTH  ),
  .AXI4_FULL_M_AXI_BURSTLENGTH  ( AXI4_FULL_M_AXI_BURSTLENGTH  ),
  .AXI4_FULL_M_AXI_MAX_4K       ( AXI4_FULL_M_AXI_MAX_4K       ),
  .AXI4_FULL_S_AXI_MAX_4K       ( AXI4_FULL_S_AXI_MAX_4K       ),
  .ASYN_RADDR_FIFO_DEPTH        ( ASYN_RADDR_FIFO_DEPTH        ),
  .ASYN_RDATA_FIFO_DEPTH        ( ASYN_RDATA_FIFO_DEPTH        ),
  .ASYN_WADDR_FIFO_DEPTH        ( ASYN_WADDR_FIFO_DEPTH        ),
  .ASYN_WDATA_FIFO_DEPTH        ( ASYN_WDATA_FIFO_DEPTH        ),
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
) u_npu_top_chiplet_1(
  .axi4_clk              ( axi4_clk              ),
  .axi4_rst_n            ( axi4_rst_n            ),
  .apb4_pclk             ( apb4_pclk             ),
  .apb4_presetn          ( apb4_presetn          ),
  .apb4_paddr            ( chip1_apb4_paddr            ),
  .apb4_psel             ( chip1_apb4_psel             ),
  .apb4_penable          ( chip1_apb4_penable          ),
  .apb4_pwrite           ( chip1_apb4_pwrite           ),
  .apb4_pwdata           ( chip1_apb4_pwdata           ),
  .apb4_pstrb            ( chip1_apb4_pstrb            ),
  .apb4_pprot            ( chip1_apb4_pprot            ),
  .serdes0_M_AXI_ARREADY ( connected_serdes_S_AXI_ARREADY ),
  .serdes0_M_AXI_RID     ( connected_serdes_S_AXI_RID     ),
  .serdes0_M_AXI_RDATA   ( connected_serdes_S_AXI_RDATA   ),
  .serdes0_M_AXI_RRESP   ( connected_serdes_S_AXI_RRESP   ),
  .serdes0_M_AXI_RLAST   ( connected_serdes_S_AXI_RLAST   ),
  .serdes0_M_AXI_RUSER   ( connected_serdes_S_AXI_RUSER   ),
  .serdes0_M_AXI_RVALID  ( connected_serdes_S_AXI_RVALID  ),
  .serdes0_S_AXI_ARID    ( connected_serdes_M_AXI_ARID    ),
  .serdes0_S_AXI_ARADDR  ( routed_serdes_M_AXI_ARADDR     ),
  .serdes0_S_AXI_ARLEN   ( connected_serdes_M_AXI_ARLEN   ),
  .serdes0_S_AXI_ARSIZE  ( connected_serdes_M_AXI_ARSIZE  ),
  .serdes0_S_AXI_ARBURST ( connected_serdes_M_AXI_ARBURST ),
  .serdes0_S_AXI_ARLOCK  ( connected_serdes_M_AXI_ARLOCK  ),
  .serdes0_S_AXI_ARCACHE ( connected_serdes_M_AXI_ARCACHE ),
  .serdes0_S_AXI_ARPROT  ( connected_serdes_M_AXI_ARPROT  ),
  .serdes0_S_AXI_ARQOS   ( connected_serdes_M_AXI_ARQOS   ),
  .serdes0_S_AXI_ARUSER  ( connected_serdes_M_AXI_ARUSER  ),
  .serdes0_S_AXI_ARVALID ( connected_serdes_M_AXI_ARVALID ),
  .serdes0_S_AXI_RREADY  ( connected_serdes_M_AXI_RREADY  ),
  .serdes0_M_AXI_AWREADY ( connected_serdes_S_AXI_AWREADY ),
  .serdes0_M_AXI_WREADY  ( connected_serdes_S_AXI_WREADY  ),
  .serdes0_M_AXI_BID     ( connected_serdes_S_AXI_BID     ),
  .serdes0_M_AXI_BRESP   ( connected_serdes_S_AXI_BRESP   ),
  .serdes0_M_AXI_BUSER   ( connected_serdes_S_AXI_BUSER   ),
  .serdes0_M_AXI_BVALID  ( connected_serdes_S_AXI_BVALID  ),
  .serdes0_S_AXI_AWID    ( connected_serdes_M_AXI_AWID    ),
  .serdes0_S_AXI_AWADDR  ( routed_serdes_M_AXI_AWADDR     ),
  .serdes0_S_AXI_AWLEN   ( connected_serdes_M_AXI_AWLEN   ),
  .serdes0_S_AXI_AWSIZE  ( connected_serdes_M_AXI_AWSIZE  ),
  .serdes0_S_AXI_AWBURST ( connected_serdes_M_AXI_AWBURST ),
  .serdes0_S_AXI_AWLOCK  ( connected_serdes_M_AXI_AWLOCK  ),
  .serdes0_S_AXI_AWCACHE ( connected_serdes_M_AXI_AWCACHE ),
  .serdes0_S_AXI_AWPROT  ( connected_serdes_M_AXI_AWPROT  ),
  .serdes0_S_AXI_AWQOS   ( connected_serdes_M_AXI_AWQOS   ),
  .serdes0_S_AXI_AWUSER  ( connected_serdes_M_AXI_AWUSER  ),
  .serdes0_S_AXI_AWVALID ( connected_serdes_M_AXI_AWVALID ),
  .serdes0_S_AXI_WDATA   ( connected_serdes_M_AXI_WDATA   ),
  .serdes0_S_AXI_WSTRB   ( connected_serdes_M_AXI_WSTRB   ),
  .serdes0_S_AXI_WLAST   ( connected_serdes_M_AXI_WLAST   ),
  .serdes0_S_AXI_WUSER   ( connected_serdes_M_AXI_WUSER   ),
  .serdes0_S_AXI_WVALID  ( connected_serdes_M_AXI_WVALID  ),
  .serdes0_S_AXI_BREADY  ( connected_serdes_M_AXI_BREADY  ),
  .serdes1_M_AXI_ARREADY ( chip1_serdes1_M_AXI_ARREADY ),
  .serdes1_M_AXI_RID     ( chip1_serdes1_M_AXI_RID     ),
  .serdes1_M_AXI_RDATA   ( chip1_serdes1_M_AXI_RDATA   ),
  .serdes1_M_AXI_RRESP   ( chip1_serdes1_M_AXI_RRESP   ),
  .serdes1_M_AXI_RLAST   ( chip1_serdes1_M_AXI_RLAST   ),
  .serdes1_M_AXI_RUSER   ( chip1_serdes1_M_AXI_RUSER   ),
  .serdes1_M_AXI_RVALID  ( chip1_serdes1_M_AXI_RVALID  ),
  .serdes1_S_AXI_ARID    ( chip1_serdes1_S_AXI_ARID    ),
  .serdes1_S_AXI_ARADDR  ( chip1_serdes1_S_AXI_ARADDR  ),
  .serdes1_S_AXI_ARLEN   ( chip1_serdes1_S_AXI_ARLEN   ),
  .serdes1_S_AXI_ARSIZE  ( chip1_serdes1_S_AXI_ARSIZE  ),
  .serdes1_S_AXI_ARBURST ( chip1_serdes1_S_AXI_ARBURST ),
  .serdes1_S_AXI_ARLOCK  ( chip1_serdes1_S_AXI_ARLOCK  ),
  .serdes1_S_AXI_ARCACHE ( chip1_serdes1_S_AXI_ARCACHE ),
  .serdes1_S_AXI_ARPROT  ( chip1_serdes1_S_AXI_ARPROT  ),
  .serdes1_S_AXI_ARQOS   ( chip1_serdes1_S_AXI_ARQOS   ),
  .serdes1_S_AXI_ARUSER  ( chip1_serdes1_S_AXI_ARUSER  ),
  .serdes1_S_AXI_ARVALID ( chip1_serdes1_S_AXI_ARVALID ),
  .serdes1_S_AXI_RREADY  ( chip1_serdes1_S_AXI_RREADY  ),
  .serdes1_M_AXI_AWREADY ( chip1_serdes1_M_AXI_AWREADY ),
  .serdes1_M_AXI_WREADY  ( chip1_serdes1_M_AXI_WREADY  ),
  .serdes1_M_AXI_BID     ( chip1_serdes1_M_AXI_BID     ),
  .serdes1_M_AXI_BRESP   ( chip1_serdes1_M_AXI_BRESP   ),
  .serdes1_M_AXI_BUSER   ( chip1_serdes1_M_AXI_BUSER   ),
  .serdes1_M_AXI_BVALID  ( chip1_serdes1_M_AXI_BVALID  ),
  .serdes1_S_AXI_AWID    ( chip1_serdes1_S_AXI_AWID    ),
  .serdes1_S_AXI_AWADDR  ( chip1_serdes1_S_AXI_AWADDR  ),
  .serdes1_S_AXI_AWLEN   ( chip1_serdes1_S_AXI_AWLEN   ),
  .serdes1_S_AXI_AWSIZE  ( chip1_serdes1_S_AXI_AWSIZE  ),
  .serdes1_S_AXI_AWBURST ( chip1_serdes1_S_AXI_AWBURST ),
  .serdes1_S_AXI_AWLOCK  ( chip1_serdes1_S_AXI_AWLOCK  ),
  .serdes1_S_AXI_AWCACHE ( chip1_serdes1_S_AXI_AWCACHE ),
  .serdes1_S_AXI_AWPROT  ( chip1_serdes1_S_AXI_AWPROT  ),
  .serdes1_S_AXI_AWQOS   ( chip1_serdes1_S_AXI_AWQOS   ),
  .serdes1_S_AXI_AWUSER  ( chip1_serdes1_S_AXI_AWUSER  ),
  .serdes1_S_AXI_AWVALID ( chip1_serdes1_S_AXI_AWVALID ),
  .serdes1_S_AXI_WDATA   ( chip1_serdes1_S_AXI_WDATA   ),
  .serdes1_S_AXI_WSTRB   ( chip1_serdes1_S_AXI_WSTRB   ),
  .serdes1_S_AXI_WLAST   ( chip1_serdes1_S_AXI_WLAST   ),
  .serdes1_S_AXI_WUSER   ( chip1_serdes1_S_AXI_WUSER   ),
  .serdes1_S_AXI_WVALID  ( chip1_serdes1_S_AXI_WVALID  ),
  .serdes1_S_AXI_BREADY  ( chip1_serdes1_S_AXI_BREADY  ),
  .ddr_M_AXI_ARREADY     ( chip1_ddr_M_AXI_ARREADY     ),
  .ddr_M_AXI_RID         ( chip1_ddr_M_AXI_RID         ),
  .ddr_M_AXI_RDATA       ( chip1_ddr_M_AXI_RDATA       ),
  .ddr_M_AXI_RRESP       ( chip1_ddr_M_AXI_RRESP       ),
  .ddr_M_AXI_RLAST       ( chip1_ddr_M_AXI_RLAST       ),
  .ddr_M_AXI_RUSER       ( chip1_ddr_M_AXI_RUSER       ),
  .ddr_M_AXI_RVALID      ( chip1_ddr_M_AXI_RVALID      ),
  .ddr_M_AXI_AWREADY     ( chip1_ddr_M_AXI_AWREADY     ),
  .ddr_M_AXI_WREADY      ( chip1_ddr_M_AXI_WREADY      ),
  .ddr_M_AXI_BID         ( chip1_ddr_M_AXI_BID         ),
  .ddr_M_AXI_BRESP       ( chip1_ddr_M_AXI_BRESP       ),
  .ddr_M_AXI_BUSER       ( chip1_ddr_M_AXI_BUSER       ),
  .ddr_M_AXI_BVALID      ( chip1_ddr_M_AXI_BVALID      ),
  .clk                   ( logic_clk             ),
  .rst_n                 ( logic_rst_n           ),
  .serdes0_M_AXI_ARID    ( connected_serdes_S_AXI_ARID    ),
  .serdes0_M_AXI_ARADDR  ( connected_serdes_S_AXI_ARADDR  ),
  .serdes0_M_AXI_ARLEN   ( connected_serdes_S_AXI_ARLEN   ),
  .serdes0_M_AXI_ARSIZE  ( connected_serdes_S_AXI_ARSIZE  ),
  .serdes0_M_AXI_ARBURST ( connected_serdes_S_AXI_ARBURST ),
  .serdes0_M_AXI_ARLOCK  ( connected_serdes_S_AXI_ARLOCK  ),
  .serdes0_M_AXI_ARCACHE ( connected_serdes_S_AXI_ARCACHE ),
  .serdes0_M_AXI_ARPROT  ( connected_serdes_S_AXI_ARPROT  ),
  .serdes0_M_AXI_ARQOS   ( connected_serdes_S_AXI_ARQOS   ),
  .serdes0_M_AXI_ARUSER  ( connected_serdes_S_AXI_ARUSER  ),
  .serdes0_M_AXI_ARVALID ( connected_serdes_S_AXI_ARVALID ),
  .serdes0_M_AXI_RREADY  ( connected_serdes_S_AXI_RREADY  ),
  .serdes0_S_AXI_ARREADY ( connected_serdes_M_AXI_ARREADY ),
  .serdes0_S_AXI_RID     ( connected_serdes_M_AXI_RID     ),
  .serdes0_S_AXI_RDATA   ( connected_serdes_M_AXI_RDATA   ),
  .serdes0_S_AXI_RRESP   ( connected_serdes_M_AXI_RRESP   ),
  .serdes0_S_AXI_RLAST   ( connected_serdes_M_AXI_RLAST   ),
  .serdes0_S_AXI_RUSER   ( connected_serdes_M_AXI_RUSER   ),
  .serdes0_S_AXI_RVALID  ( connected_serdes_M_AXI_RVALID  ),
  .serdes0_M_AXI_AWID    ( connected_serdes_S_AXI_AWID    ),
  .serdes0_M_AXI_AWADDR  ( connected_serdes_S_AXI_AWADDR  ),
  .serdes0_M_AXI_AWLEN   ( connected_serdes_S_AXI_AWLEN   ),
  .serdes0_M_AXI_AWSIZE  ( connected_serdes_S_AXI_AWSIZE  ),
  .serdes0_M_AXI_AWBURST ( connected_serdes_S_AXI_AWBURST ),
  .serdes0_M_AXI_AWLOCK  ( connected_serdes_S_AXI_AWLOCK  ),
  .serdes0_M_AXI_AWCACHE ( connected_serdes_S_AXI_AWCACHE ),
  .serdes0_M_AXI_AWPROT  ( connected_serdes_S_AXI_AWPROT  ),
  .serdes0_M_AXI_AWQOS   ( connected_serdes_S_AXI_AWQOS   ),
  .serdes0_M_AXI_AWUSER  ( connected_serdes_S_AXI_AWUSER  ),
  .serdes0_M_AXI_AWVALID ( connected_serdes_S_AXI_AWVALID ),
  .serdes0_M_AXI_WDATA   ( connected_serdes_S_AXI_WDATA   ),
  .serdes0_M_AXI_WSTRB   ( connected_serdes_S_AXI_WSTRB   ),
  .serdes0_M_AXI_WLAST   ( connected_serdes_S_AXI_WLAST   ),
  .serdes0_M_AXI_WUSER   ( connected_serdes_S_AXI_WUSER   ),
  .serdes0_M_AXI_WVALID  ( connected_serdes_S_AXI_WVALID  ),
  .serdes0_M_AXI_BREADY  ( connected_serdes_S_AXI_BREADY  ),
  .serdes0_S_AXI_AWREADY ( connected_serdes_M_AXI_AWREADY ),
  .serdes0_S_AXI_WREADY  ( connected_serdes_M_AXI_WREADY  ),
  .serdes0_S_AXI_BID     ( connected_serdes_M_AXI_BID     ),
  .serdes0_S_AXI_BRESP   ( connected_serdes_M_AXI_BRESP   ),
  .serdes0_S_AXI_BUSER   ( connected_serdes_M_AXI_BUSER   ),
  .serdes0_S_AXI_BVALID  ( connected_serdes_M_AXI_BVALID  ),
  .serdes1_M_AXI_ARID    ( chip1_serdes1_M_AXI_ARID    ),
  .serdes1_M_AXI_ARADDR  ( chip1_serdes1_M_AXI_ARADDR  ),
  .serdes1_M_AXI_ARLEN   ( chip1_serdes1_M_AXI_ARLEN   ),
  .serdes1_M_AXI_ARSIZE  ( chip1_serdes1_M_AXI_ARSIZE  ),
  .serdes1_M_AXI_ARBURST ( chip1_serdes1_M_AXI_ARBURST ),
  .serdes1_M_AXI_ARLOCK  ( chip1_serdes1_M_AXI_ARLOCK  ),
  .serdes1_M_AXI_ARCACHE ( chip1_serdes1_M_AXI_ARCACHE ),
  .serdes1_M_AXI_ARPROT  ( chip1_serdes1_M_AXI_ARPROT  ),
  .serdes1_M_AXI_ARQOS   ( chip1_serdes1_M_AXI_ARQOS   ),
  .serdes1_M_AXI_ARUSER  ( chip1_serdes1_M_AXI_ARUSER  ),
  .serdes1_M_AXI_ARVALID ( chip1_serdes1_M_AXI_ARVALID ),
  .serdes1_M_AXI_RREADY  ( chip1_serdes1_M_AXI_RREADY  ),
  .serdes1_S_AXI_ARREADY ( chip1_serdes1_S_AXI_ARREADY ),
  .serdes1_S_AXI_RID     ( chip1_serdes1_S_AXI_RID     ),
  .serdes1_S_AXI_RDATA   ( chip1_serdes1_S_AXI_RDATA   ),
  .serdes1_S_AXI_RRESP   ( chip1_serdes1_S_AXI_RRESP   ),
  .serdes1_S_AXI_RLAST   ( chip1_serdes1_S_AXI_RLAST   ),
  .serdes1_S_AXI_RUSER   ( chip1_serdes1_S_AXI_RUSER   ),
  .serdes1_S_AXI_RVALID  ( chip1_serdes1_S_AXI_RVALID  ),
  .serdes1_M_AXI_AWID    ( chip1_serdes1_M_AXI_AWID    ),
  .serdes1_M_AXI_AWADDR  ( chip1_serdes1_M_AXI_AWADDR  ),
  .serdes1_M_AXI_AWLEN   ( chip1_serdes1_M_AXI_AWLEN   ),
  .serdes1_M_AXI_AWSIZE  ( chip1_serdes1_M_AXI_AWSIZE  ),
  .serdes1_M_AXI_AWBURST ( chip1_serdes1_M_AXI_AWBURST ),
  .serdes1_M_AXI_AWLOCK  ( chip1_serdes1_M_AXI_AWLOCK  ),
  .serdes1_M_AXI_AWCACHE ( chip1_serdes1_M_AXI_AWCACHE ),
  .serdes1_M_AXI_AWPROT  ( chip1_serdes1_M_AXI_AWPROT  ),
  .serdes1_M_AXI_AWQOS   ( chip1_serdes1_M_AXI_AWQOS   ),
  .serdes1_M_AXI_AWUSER  ( chip1_serdes1_M_AXI_AWUSER  ),
  .serdes1_M_AXI_AWVALID ( chip1_serdes1_M_AXI_AWVALID ),
  .serdes1_M_AXI_WDATA   ( chip1_serdes1_M_AXI_WDATA   ),
  .serdes1_M_AXI_WSTRB   ( chip1_serdes1_M_AXI_WSTRB   ),
  .serdes1_M_AXI_WLAST   ( chip1_serdes1_M_AXI_WLAST   ),
  .serdes1_M_AXI_WUSER   ( chip1_serdes1_M_AXI_WUSER   ),
  .serdes1_M_AXI_WVALID  ( chip1_serdes1_M_AXI_WVALID  ),
  .serdes1_M_AXI_BREADY  ( chip1_serdes1_M_AXI_BREADY  ),
  .serdes1_S_AXI_AWREADY ( chip1_serdes1_S_AXI_AWREADY ),
  .serdes1_S_AXI_WREADY  ( chip1_serdes1_S_AXI_WREADY  ),
  .serdes1_S_AXI_BID     ( chip1_serdes1_S_AXI_BID     ),
  .serdes1_S_AXI_BRESP   ( chip1_serdes1_S_AXI_BRESP   ),
  .serdes1_S_AXI_BUSER   ( chip1_serdes1_S_AXI_BUSER   ),
  .serdes1_S_AXI_BVALID  ( chip1_serdes1_S_AXI_BVALID  ),
  .ddr_M_AXI_ARID        ( chip1_ddr_M_AXI_ARID        ),
  .ddr_M_AXI_ARADDR      ( chip1_ddr_M_AXI_ARADDR      ),
  .ddr_M_AXI_ARLEN       ( chip1_ddr_M_AXI_ARLEN       ),
  .ddr_M_AXI_ARSIZE      ( chip1_ddr_M_AXI_ARSIZE      ),
  .ddr_M_AXI_ARBURST     ( chip1_ddr_M_AXI_ARBURST     ),
  .ddr_M_AXI_ARLOCK      ( chip1_ddr_M_AXI_ARLOCK      ),
  .ddr_M_AXI_ARCACHE     ( chip1_ddr_M_AXI_ARCACHE     ),
  .ddr_M_AXI_ARPROT      ( chip1_ddr_M_AXI_ARPROT      ),
  .ddr_M_AXI_ARQOS       ( chip1_ddr_M_AXI_ARQOS       ),
  .ddr_M_AXI_ARUSER      ( chip1_ddr_M_AXI_ARUSER      ),
  .ddr_M_AXI_ARVALID     ( chip1_ddr_M_AXI_ARVALID     ),
  .ddr_M_AXI_RREADY      ( chip1_ddr_M_AXI_RREADY      ),
  .ddr_M_AXI_AWID        ( chip1_ddr_M_AXI_AWID        ),
  .ddr_M_AXI_AWADDR      ( chip1_ddr_M_AXI_AWADDR      ),
  .ddr_M_AXI_AWLEN       ( chip1_ddr_M_AXI_AWLEN       ),
  .ddr_M_AXI_AWSIZE      ( chip1_ddr_M_AXI_AWSIZE      ),
  .ddr_M_AXI_AWBURST     ( chip1_ddr_M_AXI_AWBURST     ),
  .ddr_M_AXI_AWLOCK      ( chip1_ddr_M_AXI_AWLOCK      ),
  .ddr_M_AXI_AWCACHE     ( chip1_ddr_M_AXI_AWCACHE     ),
  .ddr_M_AXI_AWPROT      ( chip1_ddr_M_AXI_AWPROT      ),
  .ddr_M_AXI_AWQOS       ( chip1_ddr_M_AXI_AWQOS       ),
  .ddr_M_AXI_AWUSER      ( chip1_ddr_M_AXI_AWUSER      ),
  .ddr_M_AXI_AWVALID     ( chip1_ddr_M_AXI_AWVALID     ),
  .ddr_M_AXI_WDATA       ( chip1_ddr_M_AXI_WDATA       ),
  .ddr_M_AXI_WSTRB       ( chip1_ddr_M_AXI_WSTRB       ),
  .ddr_M_AXI_WLAST       ( chip1_ddr_M_AXI_WLAST       ),
  .ddr_M_AXI_WUSER       ( chip1_ddr_M_AXI_WUSER       ),
  .ddr_M_AXI_WVALID      ( chip1_ddr_M_AXI_WVALID      ),
  .ddr_M_AXI_BREADY      ( chip1_ddr_M_AXI_BREADY      ),
  .apb4_prdata           ( chip1_apb4_prdata           ),
  .apb4_pslverr          ( chip1_apb4_pslverr          ),
  .apb4_pready           ( chip1_apb4_pready           )
);


initial begin
  $fsdbDumpfile("npu_chiplet_tb.fsdb");
  $fsdbDumpvars            ;
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
) u_full_slave_ddr_chip0(
  .S_AXI_ACLK     ( axi4_clk       ),
  .S_AXI_ARESETN  ( axi4_rst_n     ),
  .S_AXI_AWID     ( chip0_ddr_M_AXI_AWID     ),
  .S_AXI_AWADDR   ( chip0_ddr_M_AXI_AWADDR   ),
  .S_AXI_AWLEN    ( chip0_ddr_M_AXI_AWLEN    ),
  .S_AXI_AWSIZE   ( chip0_ddr_M_AXI_AWSIZE   ),
  .S_AXI_AWBURST  ( chip0_ddr_M_AXI_AWBURST  ),
  .S_AXI_AWLOCK   ( chip0_ddr_M_AXI_AWLOCK   ),
  .S_AXI_AWCACHE  ( chip0_ddr_M_AXI_AWCACHE  ),
  .S_AXI_AWPROT   ( chip0_ddr_M_AXI_AWPROT   ),
  .S_AXI_AWQOS    ( chip0_ddr_M_AXI_AWQOS    ),
  .S_AXI_AWREGION ( chip0_ddr_M_AXI_AWREGION ),
  .S_AXI_AWUSER   ( chip0_ddr_M_AXI_AWUSER   ),
  .S_AXI_AWVALID  ( chip0_ddr_M_AXI_AWVALID  ),
  .S_AXI_WDATA    ( chip0_ddr_M_AXI_WDATA    ),
  .S_AXI_WSTRB    ( chip0_ddr_M_AXI_WSTRB    ),
  .S_AXI_WLAST    ( chip0_ddr_M_AXI_WLAST    ),
  .S_AXI_WUSER    ( chip0_ddr_M_AXI_WUSER    ),
  .S_AXI_WVALID   ( chip0_ddr_M_AXI_WVALID   ),
  .S_AXI_BREADY   ( chip0_ddr_M_AXI_BREADY   ),
  .S_AXI_ARID     ( chip0_ddr_M_AXI_ARID     ),
  .S_AXI_ARADDR   ( chip0_ddr_M_AXI_ARADDR   ),
  .S_AXI_ARLEN    ( chip0_ddr_M_AXI_ARLEN    ),
  .S_AXI_ARSIZE   ( chip0_ddr_M_AXI_ARSIZE   ),
  .S_AXI_ARBURST  ( chip0_ddr_M_AXI_ARBURST  ),
  .S_AXI_ARLOCK   ( chip0_ddr_M_AXI_ARLOCK   ),
  .S_AXI_ARCACHE  ( chip0_ddr_M_AXI_ARCACHE  ),
  .S_AXI_ARPROT   ( chip0_ddr_M_AXI_ARPROT   ),
  .S_AXI_ARQOS    ( chip0_ddr_M_AXI_ARQOS    ),
  .S_AXI_ARREGION ( chip0_ddr_M_AXI_ARREGION ),
  .S_AXI_ARUSER   ( chip0_ddr_M_AXI_ARUSER   ),
  .S_AXI_ARVALID  ( chip0_ddr_M_AXI_ARVALID  ),
  .S_AXI_RREADY   ( chip0_ddr_M_AXI_RREADY   ),
  .S_AXI_AWREADY  ( chip0_ddr_M_AXI_AWREADY  ),
  .S_AXI_WREADY   ( chip0_ddr_M_AXI_WREADY   ),
  .S_AXI_BID      ( chip0_ddr_M_AXI_BID      ),
  .S_AXI_BRESP    ( chip0_ddr_M_AXI_BRESP    ),
  .S_AXI_BUSER    ( chip0_ddr_M_AXI_BUSER    ),
  .S_AXI_BVALID   ( chip0_ddr_M_AXI_BVALID   ),
  .S_AXI_ARREADY  ( chip0_ddr_M_AXI_ARREADY  ),
  .S_AXI_RID      ( chip0_ddr_M_AXI_RID      ),
  .S_AXI_RDATA    ( chip0_ddr_M_AXI_RDATA    ),
  .S_AXI_RRESP    ( chip0_ddr_M_AXI_RRESP    ),
  .S_AXI_RLAST    ( chip0_ddr_M_AXI_RLAST    ),
  .S_AXI_RUSER    ( chip0_ddr_M_AXI_RUSER    ),
  .S_AXI_RVALID   ( chip0_ddr_M_AXI_RVALID   )
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
) u_full_slave_ddr_chip1(
  .S_AXI_ACLK     ( axi4_clk       ),
  .S_AXI_ARESETN  ( axi4_rst_n     ),
  .S_AXI_AWID     ( chip1_ddr_M_AXI_AWID     ),
  .S_AXI_AWADDR   ( chip1_ddr_M_AXI_AWADDR   ),
  .S_AXI_AWLEN    ( chip1_ddr_M_AXI_AWLEN    ),
  .S_AXI_AWSIZE   ( chip1_ddr_M_AXI_AWSIZE   ),
  .S_AXI_AWBURST  ( chip1_ddr_M_AXI_AWBURST  ),
  .S_AXI_AWLOCK   ( chip1_ddr_M_AXI_AWLOCK   ),
  .S_AXI_AWCACHE  ( chip1_ddr_M_AXI_AWCACHE  ),
  .S_AXI_AWPROT   ( chip1_ddr_M_AXI_AWPROT   ),
  .S_AXI_AWQOS    ( chip1_ddr_M_AXI_AWQOS    ),
  .S_AXI_AWREGION ( chip1_ddr_M_AXI_AWREGION ),
  .S_AXI_AWUSER   ( chip1_ddr_M_AXI_AWUSER   ),
  .S_AXI_AWVALID  ( chip1_ddr_M_AXI_AWVALID  ),
  .S_AXI_WDATA    ( chip1_ddr_M_AXI_WDATA    ),
  .S_AXI_WSTRB    ( chip1_ddr_M_AXI_WSTRB    ),
  .S_AXI_WLAST    ( chip1_ddr_M_AXI_WLAST    ),
  .S_AXI_WUSER    ( chip1_ddr_M_AXI_WUSER    ),
  .S_AXI_WVALID   ( chip1_ddr_M_AXI_WVALID   ),
  .S_AXI_BREADY   ( chip1_ddr_M_AXI_BREADY   ),
  .S_AXI_ARID     ( chip1_ddr_M_AXI_ARID     ),
  .S_AXI_ARADDR   ( chip1_ddr_M_AXI_ARADDR   ),
  .S_AXI_ARLEN    ( chip1_ddr_M_AXI_ARLEN    ),
  .S_AXI_ARSIZE   ( chip1_ddr_M_AXI_ARSIZE   ),
  .S_AXI_ARBURST  ( chip1_ddr_M_AXI_ARBURST  ),
  .S_AXI_ARLOCK   ( chip1_ddr_M_AXI_ARLOCK   ),
  .S_AXI_ARCACHE  ( chip1_ddr_M_AXI_ARCACHE  ),
  .S_AXI_ARPROT   ( chip1_ddr_M_AXI_ARPROT   ),
  .S_AXI_ARQOS    ( chip1_ddr_M_AXI_ARQOS    ),
  .S_AXI_ARREGION ( chip1_ddr_M_AXI_ARREGION ),
  .S_AXI_ARUSER   ( chip1_ddr_M_AXI_ARUSER   ),
  .S_AXI_ARVALID  ( chip1_ddr_M_AXI_ARVALID  ),
  .S_AXI_RREADY   ( chip1_ddr_M_AXI_RREADY   ),
  .S_AXI_AWREADY  ( chip1_ddr_M_AXI_AWREADY  ),
  .S_AXI_WREADY   ( chip1_ddr_M_AXI_WREADY   ),
  .S_AXI_BID      ( chip1_ddr_M_AXI_BID      ),
  .S_AXI_BRESP    ( chip1_ddr_M_AXI_BRESP    ),
  .S_AXI_BUSER    ( chip1_ddr_M_AXI_BUSER    ),
  .S_AXI_BVALID   ( chip1_ddr_M_AXI_BVALID   ),
  .S_AXI_ARREADY  ( chip1_ddr_M_AXI_ARREADY  ),
  .S_AXI_RID      ( chip1_ddr_M_AXI_RID      ),
  .S_AXI_RDATA    ( chip1_ddr_M_AXI_RDATA    ),
  .S_AXI_RRESP    ( chip1_ddr_M_AXI_RRESP    ),
  .S_AXI_RLAST    ( chip1_ddr_M_AXI_RLAST    ),
  .S_AXI_RUSER    ( chip1_ddr_M_AXI_RUSER    ),
  .S_AXI_RVALID   ( chip1_ddr_M_AXI_RVALID   )
);

address_router u_serdes_0_araddr_router(
  .in_address     ( connected_serdes_M_AXI_ARADDR            ),
  .out_address    ( routed_serdes_M_AXI_ARADDR               ),
  .local_highaddr ( u_npu_top_chiplet_1.local_highaddr[19:4] )
);

address_router u_serdes_0_awaddr_router(
  .in_address    ( connected_serdes_M_AXI_AWADDR            ),
  .out_address   ( routed_serdes_M_AXI_AWADDR               ),
  .local_highaddr( u_npu_top_chiplet_1.local_highaddr[19:4] )
);


initial begin
  $readmemh("../memory/ddr0.txt", u_full_slave_ddr_chip0.data_mem);
  $readmemh("../memory/ddr1.txt", u_full_slave_ddr_chip1.data_mem);
end
endmodule