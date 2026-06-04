module vcu_tb;

import "DPI-C" function void log2_c(
  input bit [1023:0] in,
  output bit [10:0] out
);

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

parameter ddr_ID_WIDTH = 14;

reg         apb4_pclk;
reg         apb4_presetn;
                        
reg  [64:0] cmd;
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

reg         axi4_clk;
reg         axi4_rst_n;
reg         logic_clk;
reg         logic_rst_n;

wire                                     serdes0_M_AXI_ARREADY;
wire [6:0]                               serdes0_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   serdes0_M_AXI_RDATA;
wire [1:0]                               serdes0_M_AXI_RRESP;
wire                                     serdes0_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   serdes0_M_AXI_RUSER;
wire                                     serdes0_M_AXI_RVALID;
wire [6:0]                               serdes0_S_AXI_ARID;
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
wire                                     serdes0_M_AXI_AWREADY;
wire                                     serdes0_M_AXI_WREADY;
wire [6:0]                               serdes0_M_AXI_BID;
wire [1:0]                               serdes0_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   serdes0_M_AXI_BUSER;
wire                                     serdes0_M_AXI_BVALID;
wire [6:0]                               serdes0_S_AXI_AWID;
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
wire [6:0]                               serdes1_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   serdes1_M_AXI_RDATA;
wire [1:0]                               serdes1_M_AXI_RRESP;
wire                                     serdes1_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   serdes1_M_AXI_RUSER;
wire                                     serdes1_M_AXI_RVALID;
wire [6:0]                               serdes1_S_AXI_ARID;
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
wire                                     serdes1_M_AXI_AWREADY;
wire                                     serdes1_M_AXI_WREADY;
wire [6:0]                               serdes1_M_AXI_BID;
wire [1:0]                               serdes1_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   serdes1_M_AXI_BUSER;
wire                                     serdes1_M_AXI_BVALID;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      serdes1_S_AXI_AWID;
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
wire                                     ddr_M_AXI_ARREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr_M_AXI_RID;
wire [AXI4_FULL_M_AXI_RDATA_WIDTH-1:0]   ddr_M_AXI_RDATA;
wire [1:0]                               ddr_M_AXI_RRESP;
wire                                     ddr_M_AXI_RLAST;
wire [AXI4_FULL_M_AXI_RUSER_WIDTH-1:0]   ddr_M_AXI_RUSER;
wire                                     ddr_M_AXI_RVALID;
wire                                     ddr_M_AXI_AWREADY;
wire                                     ddr_M_AXI_WREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr_M_AXI_BID;
wire [1:0]                               ddr_M_AXI_BRESP;
wire [AXI4_FULL_M_AXI_BUSER_WIDTH-1:0]   ddr_M_AXI_BUSER;
wire                                     ddr_M_AXI_BVALID;
reg                                      clk;
reg                                      rst_n;

assign serdes0_S_AXI_AWID = 1;
assign serdes0_S_AXI_AWADDR = 0;
assign serdes0_S_AXI_AWLEN = 0;
assign serdes0_S_AXI_AWSIZE = 0;
assign serdes0_S_AXI_AWBURST = 0;
assign serdes0_S_AXI_AWLOCK = 0;
assign serdes0_S_AXI_AWCACHE = 0;
assign serdes0_S_AXI_AWPROT = 0;
assign serdes0_S_AXI_AWQOS = 0;
assign serdes0_S_AXI_AWUSER = 0;
assign serdes0_S_AXI_AWVALID = 0;
assign serdes0_S_AXI_WDATA = 0;
assign serdes0_S_AXI_WSTRB = 0;
assign serdes0_S_AXI_WLAST = 0;
assign serdes0_S_AXI_WUSER = 0;
assign serdes0_S_AXI_WVALID = 0;
assign serdes0_S_AXI_BREADY = 0;
assign serdes0_S_AXI_ARID = 1;
assign serdes0_S_AXI_ARADDR = 0;
assign serdes0_S_AXI_ARLEN = 0;
assign serdes0_S_AXI_ARSIZE = 0;
assign serdes0_S_AXI_ARBURST = 0;
assign serdes0_S_AXI_ARLOCK = 0;
assign serdes0_S_AXI_ARCACHE = 0;
assign serdes0_S_AXI_ARPROT = 0;
assign serdes0_S_AXI_ARQOS = 0;
assign serdes0_S_AXI_ARUSER = 0;
assign serdes0_S_AXI_ARVALID = 0;
assign serdes0_S_AXI_RREADY = 0;
assign serdes1_S_AXI_AWID = 2;
assign serdes1_S_AXI_AWADDR = 0;
assign serdes1_S_AXI_AWLEN = 0;
assign serdes1_S_AXI_AWSIZE = 0;
assign serdes1_S_AXI_AWBURST = 0;
assign serdes1_S_AXI_AWLOCK = 0;
assign serdes1_S_AXI_AWCACHE = 0;
assign serdes1_S_AXI_AWPROT = 0;
assign serdes1_S_AXI_AWQOS = 0;
assign serdes1_S_AXI_AWUSER = 0;
assign serdes1_S_AXI_AWVALID = 0;
assign serdes1_S_AXI_WDATA = 0;
assign serdes1_S_AXI_WSTRB = 0;
assign serdes1_S_AXI_WLAST = 0;
assign serdes1_S_AXI_WUSER = 0;
assign serdes1_S_AXI_WVALID = 0;
assign serdes1_S_AXI_BREADY = 0;
assign serdes1_S_AXI_ARID = 2;
assign serdes1_S_AXI_ARADDR = 0;
assign serdes1_S_AXI_ARLEN = 0;
assign serdes1_S_AXI_ARSIZE = 0;
assign serdes1_S_AXI_ARBURST = 0;
assign serdes1_S_AXI_ARLOCK = 0;
assign serdes1_S_AXI_ARCACHE = 0;
assign serdes1_S_AXI_ARPROT = 0;
assign serdes1_S_AXI_ARQOS = 0;
assign serdes1_S_AXI_ARUSER = 0;
assign serdes1_S_AXI_ARVALID = 0;
assign serdes1_S_AXI_RREADY = 0;
assign serdes0_M_AXI_AWREADY = 0;
assign serdes0_M_AXI_WREADY = 0;
assign serdes0_M_AXI_BID = 0;
assign serdes0_M_AXI_BRESP = 0;
assign serdes0_M_AXI_BUSER = 0;
assign serdes0_M_AXI_BVALID = 0;
assign serdes0_M_AXI_ARREADY = 0;
assign serdes0_M_AXI_RID = 0;
assign serdes0_M_AXI_RDATA = 0;
assign serdes0_M_AXI_RRESP = 0;
assign serdes0_M_AXI_RLAST = 0;
assign serdes0_M_AXI_RUSER = 0;
assign serdes0_M_AXI_RVALID = 0;
assign serdes1_M_AXI_AWREADY = 0;
assign serdes1_M_AXI_WREADY = 0;
assign serdes1_M_AXI_BID = 0;
assign serdes1_M_AXI_BRESP = 0;
assign serdes1_M_AXI_BUSER = 0;
assign serdes1_M_AXI_BVALID = 0;
assign serdes1_M_AXI_ARREADY = 0;
assign serdes1_M_AXI_RID = 0;
assign serdes1_M_AXI_RDATA = 0;
assign serdes1_M_AXI_RRESP = 0;
assign serdes1_M_AXI_RLAST = 0;
assign serdes1_M_AXI_RUSER = 0;
assign serdes1_M_AXI_RVALID = 0;

wire [6:0]                               serdes0_M_AXI_ARID;
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
wire                                     serdes0_S_AXI_ARREADY;
wire [AXI4_FULL_S_AXI_ID_WIDTH-1:0]      serdes0_S_AXI_RID;
wire [AXI4_FULL_S_AXI_RDATA_WIDTH-1:0]   serdes0_S_AXI_RDATA;
wire [1:0]                               serdes0_S_AXI_RRESP;
wire                                     serdes0_S_AXI_RLAST;
wire [AXI4_FULL_S_AXI_RUSER_WIDTH-1:0]   serdes0_S_AXI_RUSER;
wire                                     serdes0_S_AXI_RVALID;
wire [6:0]                               serdes0_M_AXI_AWID;
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
wire                                     serdes0_S_AXI_AWREADY;
wire                                     serdes0_S_AXI_WREADY;
wire [6:0]                               serdes0_S_AXI_BID;
wire [1:0]                               serdes0_S_AXI_BRESP;
wire [AXI4_FULL_S_AXI_BUSER_WIDTH-1:0]   serdes0_S_AXI_BUSER;
wire                                     serdes0_S_AXI_BVALID;
wire [6:0]                               serdes1_M_AXI_ARID;
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
wire [6:0]                               serdes1_S_AXI_RID;
wire [AXI4_FULL_S_AXI_RDATA_WIDTH-1:0]   serdes1_S_AXI_RDATA;
wire [1:0]                               serdes1_S_AXI_RRESP;
wire                                     serdes1_S_AXI_RLAST;
wire [AXI4_FULL_S_AXI_RUSER_WIDTH-1:0]   serdes1_S_AXI_RUSER;
wire                                     serdes1_S_AXI_RVALID;
wire [6:0]                               serdes1_M_AXI_AWID;
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
wire [6:0]                               serdes1_S_AXI_BID;
wire [1:0]                               serdes1_S_AXI_BRESP;
wire [AXI4_FULL_S_AXI_BUSER_WIDTH-1:0]   serdes1_S_AXI_BUSER;
wire                                     serdes1_S_AXI_BVALID;
wire [ddr_ID_WIDTH-1:0]                  ddr_M_AXI_ARID;
wire [AXI4_FULL_M_AXI_ARADDR_WIDTH-1:0]  ddr_M_AXI_ARADDR;
wire [7:0]                               ddr_M_AXI_ARLEN;
wire [2:0]                               ddr_M_AXI_ARSIZE;
wire [1:0]                               ddr_M_AXI_ARBURST;
wire                                     ddr_M_AXI_ARLOCK;
wire [3:0]                               ddr_M_AXI_ARCACHE;
wire [2:0]                               ddr_M_AXI_ARPROT;
wire [3:0]                               ddr_M_AXI_ARQOS;
wire [AXI4_FULL_M_AXI_ARUSER_WIDTH-1:0]  ddr_M_AXI_ARUSER;
wire                                     ddr_M_AXI_ARVALID;
wire                                     ddr_M_AXI_RREADY;
wire [ddr_ID_WIDTH-1:0]                  ddr_M_AXI_AWID;
wire [AXI4_FULL_S_AXI_AWADDR_WIDTH-1:0]  ddr_M_AXI_AWADDR;
wire [7:0]                               ddr_M_AXI_AWLEN;
wire [2:0]                               ddr_M_AXI_AWSIZE;
wire [1:0]                               ddr_M_AXI_AWBURST;
wire                                     ddr_M_AXI_AWLOCK;
wire [3:0]                               ddr_M_AXI_AWCACHE;
wire [2:0]                               ddr_M_AXI_AWPROT;
wire [3:0]                               ddr_M_AXI_AWQOS;
wire [AXI4_FULL_M_AXI_AWUSER_WIDTH-1:0]  ddr_M_AXI_AWUSER;
wire                                     ddr_M_AXI_AWVALID;
wire [AXI4_FULL_M_AXI_WDATA_WIDTH-1:0]   ddr_M_AXI_WDATA;
wire [AXI4_FULL_M_AXI_DATA_BYTES-1:0]    ddr_M_AXI_WSTRB;
wire                                     ddr_M_AXI_WLAST;
wire [AXI4_FULL_M_AXI_WUSER_WIDTH-1:0]   ddr_M_AXI_WUSER;
wire                                     ddr_M_AXI_WVALID;
wire                                     ddr_M_AXI_BREADY;

parameter time_step = 1;

reg cmd_vld_i_reg;

reg [31:0] config_regs[0:20];

initial begin
  $readmemh("../bench/reg_data.txt", config_regs);
end

initial begin
 // rst; 
  apb4_pclk   = 0;
  logic_clk = 0;
  axi4_clk = 0;
  apb4_presetn = 1;
  logic_rst_n = 1;
  axi4_rst_n = 1;
  cmd = 65'b0;
  cmd_vld = 0;
  #10 apb4_presetn = 0;
  logic_rst_n = 0;
  axi4_rst_n = 0;
  #10 apb4_presetn = 1;
  logic_rst_n = 1;
  axi4_rst_n = 1;

  #10 cmd_in_wr(cmd, 0, 1);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 4, config_regs[0]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 8, config_regs[1]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 12, config_regs[2]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 16, config_regs[3]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 20, config_regs[4]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 24, config_regs[5]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 28, config_regs[6]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 32, config_regs[7]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 36, config_regs[8]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(posedge u_apb_master.pready) #10cmd_in_wr(cmd, 40, config_regs[9]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 44, config_regs[10]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 48, config_regs[11]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 52, config_regs[12]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 56, config_regs[13]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 60, config_regs[14]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 64, config_regs[15]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 68, config_regs[16]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 72, config_regs[17]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 76, config_regs[18]);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 268, 1);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;
  @(negedge u_apb_master.pready) #10cmd_in_wr(cmd, 0, 2);
  cmd_vld = 1;
  @(negedge apb4_pclk) cmd_vld = 0;

end

always #10 apb4_pclk = ~apb4_pclk;
always #1 logic_clk = ~logic_clk;
always #2 axi4_clk = ~axi4_clk;

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

always @(posedge apb4_pclk or negedge apb4_presetn) begin
  cmd_vld_i_reg <= cmd_vld;
end

//-- write
task cmd_in_wr;
  output [64:0] cmd;
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
  #150000 $finish;
end
apb u_apb_master
(
  .pclk          (apb4_pclk    ),
  .prst_n        (apb4_presetn ),
  .cmd           (cmd          ),
  .cmd_vld       (cmd_vld      ),
  .cmd_rd_data   (cmd_rd_data  ),
  .paddr         (apb4_paddr   ),
  .pwrite        (apb4_pwrite  ),
  .psel          (apb4_psel    ),
  .penable       (apb4_penable ),
  .pwdata        (apb4_pwdata  ),
  .prdata        (apb4_prdata  ),
  .pready        (apb4_pready  ),
  .pslverr       (apb4_pslverr )
);

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
  .axi4_clk              ( axi4_clk              ),
  .axi4_rst_n            ( axi4_rst_n            ),
  .apb4_pclk             ( apb4_pclk             ),
  .apb4_presetn          ( apb4_presetn          ),
  .apb4_paddr            ( apb4_paddr            ),
  .apb4_psel             ( apb4_psel             ),
  .apb4_penable          ( apb4_penable          ),
  .apb4_pwrite           ( apb4_pwrite           ),
  .apb4_pwdata           ( apb4_pwdata           ),
  .apb4_pstrb            ( apb4_pstrb            ),
  .apb4_pprot            ( apb4_pprot            ),
  .serdes0_M_AXI_ARREADY ( serdes0_M_AXI_ARREADY ),
  .serdes0_M_AXI_RID     ( serdes0_M_AXI_RID     ),
  .serdes0_M_AXI_RDATA   ( serdes0_M_AXI_RDATA   ),
  .serdes0_M_AXI_RRESP   ( serdes0_M_AXI_RRESP   ),
  .serdes0_M_AXI_RLAST   ( serdes0_M_AXI_RLAST   ),
  .serdes0_M_AXI_RUSER   ( serdes0_M_AXI_RUSER   ),
  .serdes0_M_AXI_RVALID  ( serdes0_M_AXI_RVALID  ),
  .serdes0_S_AXI_ARID    ( serdes0_S_AXI_ARID    ),
  .serdes0_S_AXI_ARADDR  ( serdes0_S_AXI_ARADDR  ),
  .serdes0_S_AXI_ARLEN   ( serdes0_S_AXI_ARLEN   ),
  .serdes0_S_AXI_ARSIZE  ( serdes0_S_AXI_ARSIZE  ),
  .serdes0_S_AXI_ARBURST ( serdes0_S_AXI_ARBURST ),
  .serdes0_S_AXI_ARLOCK  ( serdes0_S_AXI_ARLOCK  ),
  .serdes0_S_AXI_ARCACHE ( serdes0_S_AXI_ARCACHE ),
  .serdes0_S_AXI_ARPROT  ( serdes0_S_AXI_ARPROT  ),
  .serdes0_S_AXI_ARQOS   ( serdes0_S_AXI_ARQOS   ),
  .serdes0_S_AXI_ARUSER  ( serdes0_S_AXI_ARUSER  ),
  .serdes0_S_AXI_ARVALID ( serdes0_S_AXI_ARVALID ),
  .serdes0_S_AXI_RREADY  ( serdes0_S_AXI_RREADY  ),
  .serdes0_M_AXI_AWREADY ( serdes0_M_AXI_AWREADY ),
  .serdes0_M_AXI_WREADY  ( serdes0_M_AXI_WREADY  ),
  .serdes0_M_AXI_BID     ( serdes0_M_AXI_BID     ),
  .serdes0_M_AXI_BRESP   ( serdes0_M_AXI_BRESP   ),
  .serdes0_M_AXI_BUSER   ( serdes0_M_AXI_BUSER   ),
  .serdes0_M_AXI_BVALID  ( serdes0_M_AXI_BVALID  ),
  .serdes0_S_AXI_AWID    ( serdes0_S_AXI_AWID    ),
  .serdes0_S_AXI_AWADDR  ( serdes0_S_AXI_AWADDR  ),
  .serdes0_S_AXI_AWLEN   ( serdes0_S_AXI_AWLEN   ),
  .serdes0_S_AXI_AWSIZE  ( serdes0_S_AXI_AWSIZE  ),
  .serdes0_S_AXI_AWBURST ( serdes0_S_AXI_AWBURST ),
  .serdes0_S_AXI_AWLOCK  ( serdes0_S_AXI_AWLOCK  ),
  .serdes0_S_AXI_AWCACHE ( serdes0_S_AXI_AWCACHE ),
  .serdes0_S_AXI_AWPROT  ( serdes0_S_AXI_AWPROT  ),
  .serdes0_S_AXI_AWQOS   ( serdes0_S_AXI_AWQOS   ),
  .serdes0_S_AXI_AWUSER  ( serdes0_S_AXI_AWUSER  ),
  .serdes0_S_AXI_AWVALID ( serdes0_S_AXI_AWVALID ),
  .serdes0_S_AXI_WDATA   ( serdes0_S_AXI_WDATA   ),
  .serdes0_S_AXI_WSTRB   ( serdes0_S_AXI_WSTRB   ),
  .serdes0_S_AXI_WLAST   ( serdes0_S_AXI_WLAST   ),
  .serdes0_S_AXI_WUSER   ( serdes0_S_AXI_WUSER   ),
  .serdes0_S_AXI_WVALID  ( serdes0_S_AXI_WVALID  ),
  .serdes0_S_AXI_BREADY  ( serdes0_S_AXI_BREADY  ),
  .serdes1_M_AXI_ARREADY ( serdes1_M_AXI_ARREADY ),
  .serdes1_M_AXI_RID     ( serdes1_M_AXI_RID     ),
  .serdes1_M_AXI_RDATA   ( serdes1_M_AXI_RDATA   ),
  .serdes1_M_AXI_RRESP   ( serdes1_M_AXI_RRESP   ),
  .serdes1_M_AXI_RLAST   ( serdes1_M_AXI_RLAST   ),
  .serdes1_M_AXI_RUSER   ( serdes1_M_AXI_RUSER   ),
  .serdes1_M_AXI_RVALID  ( serdes1_M_AXI_RVALID  ),
  .serdes1_S_AXI_ARID    ( serdes1_S_AXI_ARID    ),
  .serdes1_S_AXI_ARADDR  ( serdes1_S_AXI_ARADDR  ),
  .serdes1_S_AXI_ARLEN   ( serdes1_S_AXI_ARLEN   ),
  .serdes1_S_AXI_ARSIZE  ( serdes1_S_AXI_ARSIZE  ),
  .serdes1_S_AXI_ARBURST ( serdes1_S_AXI_ARBURST ),
  .serdes1_S_AXI_ARLOCK  ( serdes1_S_AXI_ARLOCK  ),
  .serdes1_S_AXI_ARCACHE ( serdes1_S_AXI_ARCACHE ),
  .serdes1_S_AXI_ARPROT  ( serdes1_S_AXI_ARPROT  ),
  .serdes1_S_AXI_ARQOS   ( serdes1_S_AXI_ARQOS   ),
  .serdes1_S_AXI_ARUSER  ( serdes1_S_AXI_ARUSER  ),
  .serdes1_S_AXI_ARVALID ( serdes1_S_AXI_ARVALID ),
  .serdes1_S_AXI_RREADY  ( serdes1_S_AXI_RREADY  ),
  .serdes1_M_AXI_AWREADY ( serdes1_M_AXI_AWREADY ),
  .serdes1_M_AXI_WREADY  ( serdes1_M_AXI_WREADY  ),
  .serdes1_M_AXI_BID     ( serdes1_M_AXI_BID     ),
  .serdes1_M_AXI_BRESP   ( serdes1_M_AXI_BRESP   ),
  .serdes1_M_AXI_BUSER   ( serdes1_M_AXI_BUSER   ),
  .serdes1_M_AXI_BVALID  ( serdes1_M_AXI_BVALID  ),
  .serdes1_S_AXI_AWID    ( serdes1_S_AXI_AWID    ),
  .serdes1_S_AXI_AWADDR  ( serdes1_S_AXI_AWADDR  ),
  .serdes1_S_AXI_AWLEN   ( serdes1_S_AXI_AWLEN   ),
  .serdes1_S_AXI_AWSIZE  ( serdes1_S_AXI_AWSIZE  ),
  .serdes1_S_AXI_AWBURST ( serdes1_S_AXI_AWBURST ),
  .serdes1_S_AXI_AWLOCK  ( serdes1_S_AXI_AWLOCK  ),
  .serdes1_S_AXI_AWCACHE ( serdes1_S_AXI_AWCACHE ),
  .serdes1_S_AXI_AWPROT  ( serdes1_S_AXI_AWPROT  ),
  .serdes1_S_AXI_AWQOS   ( serdes1_S_AXI_AWQOS   ),
  .serdes1_S_AXI_AWUSER  ( serdes1_S_AXI_AWUSER  ),
  .serdes1_S_AXI_AWVALID ( serdes1_S_AXI_AWVALID ),
  .serdes1_S_AXI_WDATA   ( serdes1_S_AXI_WDATA   ),
  .serdes1_S_AXI_WSTRB   ( serdes1_S_AXI_WSTRB   ),
  .serdes1_S_AXI_WLAST   ( serdes1_S_AXI_WLAST   ),
  .serdes1_S_AXI_WUSER   ( serdes1_S_AXI_WUSER   ),
  .serdes1_S_AXI_WVALID  ( serdes1_S_AXI_WVALID  ),
  .serdes1_S_AXI_BREADY  ( serdes1_S_AXI_BREADY  ),
  .ddr_M_AXI_ARREADY    ( ddr_M_AXI_ARREADY    ),
  .ddr_M_AXI_RID        ( ddr_M_AXI_RID        ),
  .ddr_M_AXI_RDATA      ( ddr_M_AXI_RDATA      ),
  .ddr_M_AXI_RRESP      ( ddr_M_AXI_RRESP      ),
  .ddr_M_AXI_RLAST      ( ddr_M_AXI_RLAST      ),
  .ddr_M_AXI_RUSER      ( ddr_M_AXI_RUSER      ),
  .ddr_M_AXI_RVALID     ( ddr_M_AXI_RVALID     ),
  .ddr_M_AXI_AWREADY    ( ddr_M_AXI_AWREADY    ),
  .ddr_M_AXI_WREADY     ( ddr_M_AXI_WREADY     ),
  .ddr_M_AXI_BID        ( ddr_M_AXI_BID        ),
  .ddr_M_AXI_BRESP      ( ddr_M_AXI_BRESP      ),
  .ddr_M_AXI_BUSER      ( ddr_M_AXI_BUSER      ),
  .ddr_M_AXI_BVALID     ( ddr_M_AXI_BVALID     ),
  .clk                   ( logic_clk             ),
  .rst_n                 ( logic_rst_n           ),
  .serdes0_M_AXI_ARID    ( serdes0_M_AXI_ARID    ),
  .serdes0_M_AXI_ARADDR  ( serdes0_M_AXI_ARADDR  ),
  .serdes0_M_AXI_ARLEN   ( serdes0_M_AXI_ARLEN   ),
  .serdes0_M_AXI_ARSIZE  ( serdes0_M_AXI_ARSIZE  ),
  .serdes0_M_AXI_ARBURST ( serdes0_M_AXI_ARBURST ),
  .serdes0_M_AXI_ARLOCK  ( serdes0_M_AXI_ARLOCK  ),
  .serdes0_M_AXI_ARCACHE ( serdes0_M_AXI_ARCACHE ),
  .serdes0_M_AXI_ARPROT  ( serdes0_M_AXI_ARPROT  ),
  .serdes0_M_AXI_ARQOS   ( serdes0_M_AXI_ARQOS   ),
  .serdes0_M_AXI_ARUSER  ( serdes0_M_AXI_ARUSER  ),
  .serdes0_M_AXI_ARVALID ( serdes0_M_AXI_ARVALID ),
  .serdes0_M_AXI_RREADY  ( serdes0_M_AXI_RREADY  ),
  .serdes0_S_AXI_ARREADY ( serdes0_S_AXI_ARREADY ),
  .serdes0_S_AXI_RID     ( serdes0_S_AXI_RID     ),
  .serdes0_S_AXI_RDATA   ( serdes0_S_AXI_RDATA   ),
  .serdes0_S_AXI_RRESP   ( serdes0_S_AXI_RRESP   ),
  .serdes0_S_AXI_RLAST   ( serdes0_S_AXI_RLAST   ),
  .serdes0_S_AXI_RUSER   ( serdes0_S_AXI_RUSER   ),
  .serdes0_S_AXI_RVALID  ( serdes0_S_AXI_RVALID  ),
  .serdes0_M_AXI_AWID    ( serdes0_M_AXI_AWID    ),
  .serdes0_M_AXI_AWADDR  ( serdes0_M_AXI_AWADDR  ),
  .serdes0_M_AXI_AWLEN   ( serdes0_M_AXI_AWLEN   ),
  .serdes0_M_AXI_AWSIZE  ( serdes0_M_AXI_AWSIZE  ),
  .serdes0_M_AXI_AWBURST ( serdes0_M_AXI_AWBURST ),
  .serdes0_M_AXI_AWLOCK  ( serdes0_M_AXI_AWLOCK  ),
  .serdes0_M_AXI_AWCACHE ( serdes0_M_AXI_AWCACHE ),
  .serdes0_M_AXI_AWPROT  ( serdes0_M_AXI_AWPROT  ),
  .serdes0_M_AXI_AWQOS   ( serdes0_M_AXI_AWQOS   ),
  .serdes0_M_AXI_AWUSER  ( serdes0_M_AXI_AWUSER  ),
  .serdes0_M_AXI_AWVALID ( serdes0_M_AXI_AWVALID ),
  .serdes0_M_AXI_WDATA   ( serdes0_M_AXI_WDATA   ),
  .serdes0_M_AXI_WSTRB   ( serdes0_M_AXI_WSTRB   ),
  .serdes0_M_AXI_WLAST   ( serdes0_M_AXI_WLAST   ),
  .serdes0_M_AXI_WUSER   ( serdes0_M_AXI_WUSER   ),
  .serdes0_M_AXI_WVALID  ( serdes0_M_AXI_WVALID  ),
  .serdes0_M_AXI_BREADY  ( serdes0_M_AXI_BREADY  ),
  .serdes0_S_AXI_AWREADY ( serdes0_S_AXI_AWREADY ),
  .serdes0_S_AXI_WREADY  ( serdes0_S_AXI_WREADY  ),
  .serdes0_S_AXI_BID     ( serdes0_S_AXI_BID     ),
  .serdes0_S_AXI_BRESP   ( serdes0_S_AXI_BRESP   ),
  .serdes0_S_AXI_BUSER   ( serdes0_S_AXI_BUSER   ),
  .serdes0_S_AXI_BVALID  ( serdes0_S_AXI_BVALID  ),
  .serdes1_M_AXI_ARID    ( serdes1_M_AXI_ARID    ),
  .serdes1_M_AXI_ARADDR  ( serdes1_M_AXI_ARADDR  ),
  .serdes1_M_AXI_ARLEN   ( serdes1_M_AXI_ARLEN   ),
  .serdes1_M_AXI_ARSIZE  ( serdes1_M_AXI_ARSIZE  ),
  .serdes1_M_AXI_ARBURST ( serdes1_M_AXI_ARBURST ),
  .serdes1_M_AXI_ARLOCK  ( serdes1_M_AXI_ARLOCK  ),
  .serdes1_M_AXI_ARCACHE ( serdes1_M_AXI_ARCACHE ),
  .serdes1_M_AXI_ARPROT  ( serdes1_M_AXI_ARPROT  ),
  .serdes1_M_AXI_ARQOS   ( serdes1_M_AXI_ARQOS   ),
  .serdes1_M_AXI_ARUSER  ( serdes1_M_AXI_ARUSER  ),
  .serdes1_M_AXI_ARVALID ( serdes1_M_AXI_ARVALID ),
  .serdes1_M_AXI_RREADY  ( serdes1_M_AXI_RREADY  ),
  .serdes1_S_AXI_ARREADY ( serdes1_S_AXI_ARREADY ),
  .serdes1_S_AXI_RID     ( serdes1_S_AXI_RID     ),
  .serdes1_S_AXI_RDATA   ( serdes1_S_AXI_RDATA   ),
  .serdes1_S_AXI_RRESP   ( serdes1_S_AXI_RRESP   ),
  .serdes1_S_AXI_RLAST   ( serdes1_S_AXI_RLAST   ),
  .serdes1_S_AXI_RUSER   ( serdes1_S_AXI_RUSER   ),
  .serdes1_S_AXI_RVALID  ( serdes1_S_AXI_RVALID  ),
  .serdes1_M_AXI_AWID    ( serdes1_M_AXI_AWID    ),
  .serdes1_M_AXI_AWADDR  ( serdes1_M_AXI_AWADDR  ),
  .serdes1_M_AXI_AWLEN   ( serdes1_M_AXI_AWLEN   ),
  .serdes1_M_AXI_AWSIZE  ( serdes1_M_AXI_AWSIZE  ),
  .serdes1_M_AXI_AWBURST ( serdes1_M_AXI_AWBURST ),
  .serdes1_M_AXI_AWLOCK  ( serdes1_M_AXI_AWLOCK  ),
  .serdes1_M_AXI_AWCACHE ( serdes1_M_AXI_AWCACHE ),
  .serdes1_M_AXI_AWPROT  ( serdes1_M_AXI_AWPROT  ),
  .serdes1_M_AXI_AWQOS   ( serdes1_M_AXI_AWQOS   ),
  .serdes1_M_AXI_AWUSER  ( serdes1_M_AXI_AWUSER  ),
  .serdes1_M_AXI_AWVALID ( serdes1_M_AXI_AWVALID ),
  .serdes1_M_AXI_WDATA   ( serdes1_M_AXI_WDATA   ),
  .serdes1_M_AXI_WSTRB   ( serdes1_M_AXI_WSTRB   ),
  .serdes1_M_AXI_WLAST   ( serdes1_M_AXI_WLAST   ),
  .serdes1_M_AXI_WUSER   ( serdes1_M_AXI_WUSER   ),
  .serdes1_M_AXI_WVALID  ( serdes1_M_AXI_WVALID  ),
  .serdes1_M_AXI_BREADY  ( serdes1_M_AXI_BREADY  ),
  .serdes1_S_AXI_AWREADY ( serdes1_S_AXI_AWREADY ),
  .serdes1_S_AXI_WREADY  ( serdes1_S_AXI_WREADY  ),
  .serdes1_S_AXI_BID     ( serdes1_S_AXI_BID     ),
  .serdes1_S_AXI_BRESP   ( serdes1_S_AXI_BRESP   ),
  .serdes1_S_AXI_BUSER   ( serdes1_S_AXI_BUSER   ),
  .serdes1_S_AXI_BVALID  ( serdes1_S_AXI_BVALID  ),
  .ddr_M_AXI_ARID        ( ddr_M_AXI_ARID       ),
  .ddr_M_AXI_ARADDR      ( ddr_M_AXI_ARADDR     ),
  .ddr_M_AXI_ARLEN       ( ddr_M_AXI_ARLEN      ),
  .ddr_M_AXI_ARSIZE      ( ddr_M_AXI_ARSIZE     ),
  .ddr_M_AXI_ARBURST     ( ddr_M_AXI_ARBURST    ),
  .ddr_M_AXI_ARLOCK      ( ddr_M_AXI_ARLOCK     ),
  .ddr_M_AXI_ARCACHE     ( ddr_M_AXI_ARCACHE    ),
  .ddr_M_AXI_ARPROT      ( ddr_M_AXI_ARPROT     ),
  .ddr_M_AXI_ARQOS       ( ddr_M_AXI_ARQOS      ),
  .ddr_M_AXI_ARUSER      ( ddr_M_AXI_ARUSER     ),
  .ddr_M_AXI_ARVALID     ( ddr_M_AXI_ARVALID    ),
  .ddr_M_AXI_RREADY      ( ddr_M_AXI_RREADY     ),
  .ddr_M_AXI_AWID        ( ddr_M_AXI_AWID       ),
  .ddr_M_AXI_AWADDR      ( ddr_M_AXI_AWADDR     ),
  .ddr_M_AXI_AWLEN       ( ddr_M_AXI_AWLEN      ),
  .ddr_M_AXI_AWSIZE      ( ddr_M_AXI_AWSIZE     ),
  .ddr_M_AXI_AWBURST     ( ddr_M_AXI_AWBURST    ),
  .ddr_M_AXI_AWLOCK      ( ddr_M_AXI_AWLOCK     ),
  .ddr_M_AXI_AWCACHE     ( ddr_M_AXI_AWCACHE    ),
  .ddr_M_AXI_AWPROT      ( ddr_M_AXI_AWPROT     ),
  .ddr_M_AXI_AWQOS       ( ddr_M_AXI_AWQOS      ),
  .ddr_M_AXI_AWUSER      ( ddr_M_AXI_AWUSER     ),
  .ddr_M_AXI_AWVALID     ( ddr_M_AXI_AWVALID    ),
  .ddr_M_AXI_WDATA       ( ddr_M_AXI_WDATA      ),
  .ddr_M_AXI_WSTRB       ( ddr_M_AXI_WSTRB      ),
  .ddr_M_AXI_WLAST       ( ddr_M_AXI_WLAST      ),
  .ddr_M_AXI_WUSER       ( ddr_M_AXI_WUSER      ),
  .ddr_M_AXI_WVALID      ( ddr_M_AXI_WVALID     ),
  .ddr_M_AXI_BREADY      ( ddr_M_AXI_BREADY     ),
  .apb4_prdata           ( apb4_prdata           ),
  .apb4_pslverr          ( apb4_pslverr          ),
  .apb4_pready           ( apb4_pready           )
);


initial begin
  $fsdbDumpfile("vcu_tb.fsdb");
  // $fsdbDumpvars(0, npu_tb.u_npu_top_chiplet.u_npu_top.u_pea);
  $fsdbDumpvars(0);
  // $fsdbDumpvars(0, npu_tb.u_npu_top_chiplet.u_npu_top.u_vcu);
  // $fsdbDumpMDA             ;
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
) u_full_slave_ddr(
  .S_AXI_ACLK     ( axi4_clk       ),
  .S_AXI_ARESETN  ( axi4_rst_n     ),
  .S_AXI_AWID     ( ddr_M_AXI_AWID     ),
  .S_AXI_AWADDR   ( ddr_M_AXI_AWADDR   ),
  .S_AXI_AWLEN    ( ddr_M_AXI_AWLEN    ),
  .S_AXI_AWSIZE   ( ddr_M_AXI_AWSIZE   ),
  .S_AXI_AWBURST  ( ddr_M_AXI_AWBURST  ),
  .S_AXI_AWLOCK   ( ddr_M_AXI_AWLOCK   ),
  .S_AXI_AWCACHE  ( ddr_M_AXI_AWCACHE  ),
  .S_AXI_AWPROT   ( ddr_M_AXI_AWPROT   ),
  .S_AXI_AWQOS    ( ddr_M_AXI_AWQOS    ),
  .S_AXI_AWREGION ( ddr_M_AXI_AWREGION ),
  .S_AXI_AWUSER   ( ddr_M_AXI_AWUSER   ),
  .S_AXI_AWVALID  ( ddr_M_AXI_AWVALID  ),
  .S_AXI_WDATA    ( ddr_M_AXI_WDATA    ),
  .S_AXI_WSTRB    ( ddr_M_AXI_WSTRB    ),
  .S_AXI_WLAST    ( ddr_M_AXI_WLAST    ),
  .S_AXI_WUSER    ( ddr_M_AXI_WUSER    ),
  .S_AXI_WVALID   ( ddr_M_AXI_WVALID   ),
  .S_AXI_BREADY   ( ddr_M_AXI_BREADY   ),
  .S_AXI_ARID     ( ddr_M_AXI_ARID     ),
  .S_AXI_ARADDR   ( ddr_M_AXI_ARADDR   ),
  .S_AXI_ARLEN    ( ddr_M_AXI_ARLEN    ),
  .S_AXI_ARSIZE   ( ddr_M_AXI_ARSIZE   ),
  .S_AXI_ARBURST  ( ddr_M_AXI_ARBURST  ),
  .S_AXI_ARLOCK   ( ddr_M_AXI_ARLOCK   ),
  .S_AXI_ARCACHE  ( ddr_M_AXI_ARCACHE  ),
  .S_AXI_ARPROT   ( ddr_M_AXI_ARPROT   ),
  .S_AXI_ARQOS    ( ddr_M_AXI_ARQOS    ),
  .S_AXI_ARREGION ( ddr_M_AXI_ARREGION ),
  .S_AXI_ARUSER   ( ddr_M_AXI_ARUSER   ),
  .S_AXI_ARVALID  ( ddr_M_AXI_ARVALID  ),
  .S_AXI_RREADY   ( ddr_M_AXI_RREADY   ),
  .S_AXI_AWREADY  ( ddr_M_AXI_AWREADY  ),
  .S_AXI_WREADY   ( ddr_M_AXI_WREADY   ),
  .S_AXI_BID      ( ddr_M_AXI_BID      ),
  .S_AXI_BRESP    ( ddr_M_AXI_BRESP    ),
  .S_AXI_BUSER    ( ddr_M_AXI_BUSER    ),
  .S_AXI_BVALID   ( ddr_M_AXI_BVALID   ),
  .S_AXI_ARREADY  ( ddr_M_AXI_ARREADY  ),
  .S_AXI_RID      ( ddr_M_AXI_RID      ),
  .S_AXI_RDATA    ( ddr_M_AXI_RDATA    ),
  .S_AXI_RRESP    ( ddr_M_AXI_RRESP    ),
  .S_AXI_RLAST    ( ddr_M_AXI_RLAST    ),
  .S_AXI_RUSER    ( ddr_M_AXI_RUSER    ),
  .S_AXI_RVALID   ( ddr_M_AXI_RVALID   )
);

initial begin
  $readmemh("../memory/insn.txt", u_full_slave_ddr.data_mem);
  $readmemh("../memory/ifmap.txt", u_full_slave_ddr.data_mem, 'h10000);
  $readmemh("../memory/weight.txt", u_full_slave_ddr.data_mem, 'h20000);
  $readmemh("../memory/ifmap_scale.txt", u_full_slave_ddr.data_mem, 'h40000);
  $readmemh("../memory/weight_scale.txt", u_full_slave_ddr.data_mem, 'h50000);
  $readmemh("../memory/outlier_index.txt", u_full_slave_ddr.data_mem, 'h60000);
  $readmemh("../memory/psum.txt", u_full_slave_ddr.data_mem, 'h70000);
  $readmemh("../memory/ifmap_mask.txt", u_full_slave_ddr.data_mem, 'h80000);
  $readmemh("../memory/vcucode.txt", u_full_slave_ddr.data_mem, 'h90000);
  $readmemh("../memory/vcupara.txt", u_full_slave_ddr.data_mem, 'ha0000);
  $readmemh("../memory/vcures.txt", u_full_slave_ddr.data_mem, 'hb0000);
  $readmemh("../memory/reciprocal.txt", u_full_slave_ddr.data_mem, 'hc0000);
  $readmemh("../memory/log.txt", u_full_slave_ddr.data_mem, 'hc0800);
  $readmemh("../memory/exp.txt", u_full_slave_ddr.data_mem, 'hc1000);
  $readmemh("../memory/rsqrt.txt", u_full_slave_ddr.data_mem, 'hc1800);
  $readmemh("../memory/tanh.txt", u_full_slave_ddr.data_mem, 'hc2000);
  $readmemh("../memory/sigmoid.txt", u_full_slave_ddr.data_mem, 'hc2800);
  $readmemh("../memory/mish.txt", u_full_slave_ddr.data_mem, 'hc3000);
  $readmemh("../memory/swish.txt", u_full_slave_ddr.data_mem, 'hc3800);
  $readmemh("../memory/gelu.txt", u_full_slave_ddr.data_mem, 'hc4000);
  $readmemh("../memory/sincos.txt", u_full_slave_ddr.data_mem, 'hc4800);
end

parameter psum_bits = 16;
parameter conv_len  = 256;

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
  if (u_npu_top_chiplet.u_npu_top.u_vcu_0.psum_wvalid) begin
    $display("psum_waddr: %h, psum_wdata = %h", u_npu_top_chiplet.u_npu_top.u_vcu_0.psum_waddr, u_npu_top_chiplet.u_npu_top.u_vcu_0.psum_wdata);
  end
  if (u_npu_top_chiplet.u_npu_top.u_vcu_0.done) begin
    $display("done = %h", u_npu_top_chiplet.u_npu_top.u_vcu_0.done);
    u_npu_top_chiplet.u_npu_top.u_vcu_0.insn_valid <= 1;
  end
  else begin
    // $display("insn_valid = %h", u_npu_top_chiplet.u_npu_top.u_vcu_0.insn_valid);
    u_npu_top_chiplet.u_npu_top.u_vcu_0.insn_valid <= 0;
  end

  if (u_npu_top_chiplet.u_npu_top.u_vcu_0.insn_valid == 1) begin
    $display("insn_valid = %h", u_npu_top_chiplet.u_npu_top.u_vcu_0.insn_valid);
  end
end
endmodule