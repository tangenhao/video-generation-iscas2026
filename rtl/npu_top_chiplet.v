module npu_top_chiplet(
  axi4_clk, axi4_rst_n, 

  // MCU
  mcu_M_AXI_ARID, mcu_M_AXI_ARADDR, mcu_M_AXI_ARLEN, 
  mcu_M_AXI_ARSIZE, mcu_M_AXI_ARBURST, mcu_M_AXI_ARLOCK, mcu_M_AXI_ARCACHE, mcu_M_AXI_ARPROT, mcu_M_AXI_ARQOS, mcu_M_AXI_ARUSER, 
  mcu_M_AXI_ARVALID, mcu_M_AXI_ARREADY,
  mcu_M_AXI_RID, mcu_M_AXI_RDATA, mcu_M_AXI_RRESP, mcu_M_AXI_RLAST, mcu_M_AXI_RUSER, mcu_M_AXI_RVALID, mcu_M_AXI_RREADY,

  mcu_M_AXI_AWID, mcu_M_AXI_AWADDR, mcu_M_AXI_AWLEN,
  mcu_M_AXI_AWSIZE, mcu_M_AXI_AWBURST, mcu_M_AXI_AWLOCK, mcu_M_AXI_AWCACHE, mcu_M_AXI_AWPROT, mcu_M_AXI_AWQOS, mcu_M_AXI_AWUSER,
  mcu_M_AXI_AWVALID, mcu_M_AXI_AWREADY,
  mcu_M_AXI_WDATA, mcu_M_AXI_WSTRB, mcu_M_AXI_WLAST, mcu_M_AXI_WUSER, mcu_M_AXI_WVALID, mcu_M_AXI_WREADY,
  mcu_M_AXI_BID, mcu_M_AXI_BRESP, mcu_M_AXI_BUSER, mcu_M_AXI_BVALID, mcu_M_AXI_BREADY, 

  // Serdes0
  serdes0_M_AXI_ARID, serdes0_M_AXI_ARADDR, serdes0_M_AXI_ARLEN, 
  serdes0_M_AXI_ARSIZE, serdes0_M_AXI_ARBURST, serdes0_M_AXI_ARLOCK, serdes0_M_AXI_ARCACHE, serdes0_M_AXI_ARPROT, serdes0_M_AXI_ARQOS, serdes0_M_AXI_ARUSER, 
  serdes0_M_AXI_ARVALID, serdes0_M_AXI_ARREADY,
  serdes0_M_AXI_RID, serdes0_M_AXI_RDATA, serdes0_M_AXI_RRESP, serdes0_M_AXI_RLAST, serdes0_M_AXI_RUSER, serdes0_M_AXI_RVALID, serdes0_M_AXI_RREADY,

  serdes0_S_AXI_ARID, serdes0_S_AXI_ARADDR, serdes0_S_AXI_ARLEN, 
  serdes0_S_AXI_ARSIZE, serdes0_S_AXI_ARBURST, serdes0_S_AXI_ARLOCK, serdes0_S_AXI_ARCACHE, serdes0_S_AXI_ARPROT, serdes0_S_AXI_ARQOS, serdes0_S_AXI_ARUSER, 
  serdes0_S_AXI_ARVALID, serdes0_S_AXI_ARREADY,
  serdes0_S_AXI_RID, serdes0_S_AXI_RDATA, serdes0_S_AXI_RRESP, serdes0_S_AXI_RLAST, serdes0_S_AXI_RUSER, serdes0_S_AXI_RVALID, serdes0_S_AXI_RREADY,

  serdes0_M_AXI_AWID, serdes0_M_AXI_AWADDR, serdes0_M_AXI_AWLEN,
  serdes0_M_AXI_AWSIZE, serdes0_M_AXI_AWBURST, serdes0_M_AXI_AWLOCK, serdes0_M_AXI_AWCACHE, serdes0_M_AXI_AWPROT, serdes0_M_AXI_AWQOS, serdes0_M_AXI_AWUSER,
  serdes0_M_AXI_AWVALID, serdes0_M_AXI_AWREADY,
  serdes0_M_AXI_WDATA, serdes0_M_AXI_WSTRB, serdes0_M_AXI_WLAST, serdes0_M_AXI_WUSER, serdes0_M_AXI_WVALID, serdes0_M_AXI_WREADY,
  serdes0_M_AXI_BID, serdes0_M_AXI_BRESP, serdes0_M_AXI_BUSER, serdes0_M_AXI_BVALID, serdes0_M_AXI_BREADY, 

  serdes0_S_AXI_AWID, serdes0_S_AXI_AWADDR, serdes0_S_AXI_AWLEN,
  serdes0_S_AXI_AWSIZE, serdes0_S_AXI_AWBURST, serdes0_S_AXI_AWLOCK, serdes0_S_AXI_AWCACHE, serdes0_S_AXI_AWPROT, serdes0_S_AXI_AWQOS, serdes0_S_AXI_AWUSER,
  serdes0_S_AXI_AWVALID, serdes0_S_AXI_AWREADY,
  serdes0_S_AXI_WDATA, serdes0_S_AXI_WSTRB, serdes0_S_AXI_WLAST, serdes0_S_AXI_WUSER, serdes0_S_AXI_WVALID, serdes0_S_AXI_WREADY,
  serdes0_S_AXI_BID, serdes0_S_AXI_BRESP, serdes0_S_AXI_BUSER, serdes0_S_AXI_BVALID, serdes0_S_AXI_BREADY, 

  // Serdes1
  serdes1_M_AXI_ARID, serdes1_M_AXI_ARADDR, serdes1_M_AXI_ARLEN, 
  serdes1_M_AXI_ARSIZE, serdes1_M_AXI_ARBURST, serdes1_M_AXI_ARLOCK, serdes1_M_AXI_ARCACHE, serdes1_M_AXI_ARPROT, serdes1_M_AXI_ARQOS, serdes1_M_AXI_ARUSER, 
  serdes1_M_AXI_ARVALID, serdes1_M_AXI_ARREADY,
  serdes1_M_AXI_RID, serdes1_M_AXI_RDATA, serdes1_M_AXI_RRESP, serdes1_M_AXI_RLAST, serdes1_M_AXI_RUSER, serdes1_M_AXI_RVALID, serdes1_M_AXI_RREADY,

  serdes1_S_AXI_ARID, serdes1_S_AXI_ARADDR, serdes1_S_AXI_ARLEN, 
  serdes1_S_AXI_ARSIZE, serdes1_S_AXI_ARBURST, serdes1_S_AXI_ARLOCK, serdes1_S_AXI_ARCACHE, serdes1_S_AXI_ARPROT, serdes1_S_AXI_ARQOS, serdes1_S_AXI_ARUSER, 
  serdes1_S_AXI_ARVALID, serdes1_S_AXI_ARREADY,
  serdes1_S_AXI_RID, serdes1_S_AXI_RDATA, serdes1_S_AXI_RRESP, serdes1_S_AXI_RLAST, serdes1_S_AXI_RUSER, serdes1_S_AXI_RVALID, serdes1_S_AXI_RREADY,

  serdes1_M_AXI_AWID, serdes1_M_AXI_AWADDR, serdes1_M_AXI_AWLEN,
  serdes1_M_AXI_AWSIZE, serdes1_M_AXI_AWBURST, serdes1_M_AXI_AWLOCK, serdes1_M_AXI_AWCACHE, serdes1_M_AXI_AWPROT, serdes1_M_AXI_AWQOS, serdes1_M_AXI_AWUSER,
  serdes1_M_AXI_AWVALID, serdes1_M_AXI_AWREADY,
  serdes1_M_AXI_WDATA, serdes1_M_AXI_WSTRB, serdes1_M_AXI_WLAST, serdes1_M_AXI_WUSER, serdes1_M_AXI_WVALID, serdes1_M_AXI_WREADY,
  serdes1_M_AXI_BID, serdes1_M_AXI_BRESP, serdes1_M_AXI_BUSER, serdes1_M_AXI_BVALID, serdes1_M_AXI_BREADY, 

  serdes1_S_AXI_AWID, serdes1_S_AXI_AWADDR, serdes1_S_AXI_AWLEN,
  serdes1_S_AXI_AWSIZE, serdes1_S_AXI_AWBURST, serdes1_S_AXI_AWLOCK, serdes1_S_AXI_AWCACHE, serdes1_S_AXI_AWPROT, serdes1_S_AXI_AWQOS, serdes1_S_AXI_AWUSER,
  serdes1_S_AXI_AWVALID, serdes1_S_AXI_AWREADY,
  serdes1_S_AXI_WDATA, serdes1_S_AXI_WSTRB, serdes1_S_AXI_WLAST, serdes1_S_AXI_WUSER, serdes1_S_AXI_WVALID, serdes1_S_AXI_WREADY,
  serdes1_S_AXI_BID, serdes1_S_AXI_BRESP, serdes1_S_AXI_BUSER, serdes1_S_AXI_BVALID, serdes1_S_AXI_BREADY, 

  // DDR 0
  ddr0_M_AXI_ARID, ddr0_M_AXI_ARADDR, ddr0_M_AXI_ARLEN, 
  ddr0_M_AXI_ARSIZE, ddr0_M_AXI_ARBURST, ddr0_M_AXI_ARLOCK, ddr0_M_AXI_ARCACHE, ddr0_M_AXI_ARPROT, ddr0_M_AXI_ARQOS, ddr0_M_AXI_ARUSER, 
  ddr0_M_AXI_ARVALID, ddr0_M_AXI_ARREADY,
  ddr0_M_AXI_RID, ddr0_M_AXI_RDATA, ddr0_M_AXI_RRESP, ddr0_M_AXI_RLAST, ddr0_M_AXI_RUSER, ddr0_M_AXI_RVALID, ddr0_M_AXI_RREADY,

  ddr0_M_AXI_AWID, ddr0_M_AXI_AWADDR, ddr0_M_AXI_AWLEN,
  ddr0_M_AXI_AWSIZE, ddr0_M_AXI_AWBURST, ddr0_M_AXI_AWLOCK, ddr0_M_AXI_AWCACHE, ddr0_M_AXI_AWPROT, ddr0_M_AXI_AWQOS, ddr0_M_AXI_AWUSER,
  ddr0_M_AXI_AWVALID, ddr0_M_AXI_AWREADY,
  ddr0_M_AXI_WDATA, ddr0_M_AXI_WSTRB, ddr0_M_AXI_WLAST, ddr0_M_AXI_WUSER, ddr0_M_AXI_WVALID, ddr0_M_AXI_WREADY,
  ddr0_M_AXI_BID, ddr0_M_AXI_BRESP, ddr0_M_AXI_BUSER, ddr0_M_AXI_BVALID, ddr0_M_AXI_BREADY, 

  // DDR 0
  ddr1_M_AXI_ARID, ddr1_M_AXI_AWADDR, ddr1_M_AXI_ARLEN, 
  ddr1_M_AXI_ARSIZE, ddr1_M_AXI_ARBURST, ddr1_M_AXI_ARLOCK, ddr1_M_AXI_ARCACHE, ddr1_M_AXI_ARPROT, ddr1_M_AXI_ARQOS, ddr1_M_AXI_ARUSER, 
  ddr1_M_AXI_ARVALID, ddr1_M_AXI_ARREADY,
  ddr1_M_AXI_RID, ddr1_M_AXI_RDATA, ddr1_M_AXI_RRESP, ddr1_M_AXI_RLAST, ddr1_M_AXI_RUSER, ddr1_M_AXI_RVALID, ddr1_M_AXI_RREADY,

  ddr1_M_AXI_AWID, ddr1_M_AXI_ARADDR, ddr1_M_AXI_AWLEN,
  ddr1_M_AXI_AWSIZE, ddr1_M_AXI_AWBURST, ddr1_M_AXI_AWLOCK, ddr1_M_AXI_AWCACHE, ddr1_M_AXI_AWPROT, ddr1_M_AXI_AWQOS, ddr1_M_AXI_AWUSER,
  ddr1_M_AXI_AWVALID, ddr1_M_AXI_AWREADY,
  ddr1_M_AXI_WDATA, ddr1_M_AXI_WSTRB, ddr1_M_AXI_WLAST, ddr1_M_AXI_WUSER, ddr1_M_AXI_WVALID, ddr1_M_AXI_WREADY,
  ddr1_M_AXI_BID, ddr1_M_AXI_BRESP, ddr1_M_AXI_BUSER, ddr1_M_AXI_BVALID, ddr1_M_AXI_BREADY, 

  clk, rst_n,

  apb4_pclk, apb4_presetn,
  apb4_paddr, apb4_psel, apb4_penable, apb4_pwrite, 
  apb4_pready, 
  apb4_pwdata, apb4_pstrb, 
  apb4_prdata,
  apb4_pprot, apb4_pslverr,

  pcie_clk, pcie_rst_n,
  pcie_ven_msi_req, pcie_ven_msi_func_num, pcie_ven_msi_tc, pcie_ven_msi_vector,
  pcie_msi_grant, mode_sel,

  mcu_clk, mcu_rst_n
);

parameter MASTER_PERI_ADDR_WIDTH    = 38;
parameter MASTER_PERI_BUSRSTS_WIDTH = 22;
parameter MASTER_PERI_DATA_WIDTH    = 256;
parameter SLAVE_PERI_ADDR_WIDTH     = 38;
parameter SLAVE_PERI_BUSRSTS_WIDTH  = 22;
parameter SLAVE_PERI_DATA_WIDTH     = 256;
parameter MASTER_SRAM_ADDR_WIDTH    = 20;

parameter AXI_S_AXI_BURSTLENGTH  = 64;
parameter AXI_M_AXI_BURSTLENGTH  = 128;
parameter AXI_M_AXI_MAX_4K       = 8;
parameter AXI_S_AXI_MAX_4K       = 8;

parameter AXI_OUTSTANDING_DEPTH  = 8;

parameter AXI_M_AXI_ID_WIDTH   = 20;
parameter AXI_M_AXI_ADDR_WIDTH = 64;
parameter AXI_M_AXI_USER_WIDTH = 1;
parameter AXI_M_AXI_DATA_WIDTH = 256;
parameter DATA_AXI_ID_WIDTH    = 20;
parameter INSN_AXI_ID_WIDTH    = 20;

parameter AXI_S_AXI_ID_WIDTH   = 20;
parameter AXI_S_AXI_ADDR_WIDTH = 64;
parameter AXI_S_AXI_USER_WIDTH = 1;
parameter AXI_S_AXI_DATA_WIDTH = 256;

parameter HIGHADDR_BITS        = 24;
parameter VALIDADDR_BITS       = 40;

localparam integer AXI_M_AXI_DATA_BYTES = AXI_M_AXI_DATA_WIDTH / 8;
localparam integer AXI_S_AXI_DATA_BYTES = AXI_S_AXI_DATA_WIDTH / 8;

parameter serdes_M_AXI_ID_WIDTH = 8;
parameter serdes_S_AXI_ID_WIDTH = 8;
parameter npu_M_AXI_ID_WIDTH    = 20;
parameter npu_S_AXI_ID_WIDTH    = 20;
parameter ddr_M_AXI_ID_WIDTH    = 14;
parameter MCU_M_AXI_ID_WIDTH    = 8;

// 请把这里替换成你的crossbar的参数
parameter DATA_WIDTH        = AXI_M_AXI_DATA_WIDTH;
parameter ADDR_WIDTH        = AXI_M_AXI_ADDR_WIDTH;
parameter STRB_WIDTH        = (DATA_WIDTH/8);
parameter S_ID_WIDTH        = 20;
parameter M_ID_WIDTH        = 23;
parameter AWUSER_ENABLE     = 0;
parameter AWUSER_WIDTH      = AXI_M_AXI_USER_WIDTH;
parameter WUSER_ENABLE      = 0;
parameter WUSER_WIDTH       = AXI_M_AXI_USER_WIDTH;
parameter BUSER_ENABLE      = 0;
parameter BUSER_WIDTH       = AXI_M_AXI_USER_WIDTH;
parameter ARUSER_ENABLE     = 0;
parameter ARUSER_WIDTH      = AXI_M_AXI_USER_WIDTH;
parameter RUSER_ENABLE      = 0;
parameter RUSER_WIDTH       = AXI_M_AXI_USER_WIDTH;
parameter S00_THREADS       = 4;
parameter S00_ACCEPT        = 8;
parameter S01_THREADS       = 4;
parameter S01_ACCEPT        = 8;
parameter S02_THREADS       = 4;
parameter S02_ACCEPT        = 8;
parameter S03_THREADS       = 4;
parameter S03_ACCEPT        = 8;
parameter S04_THREADS       = 4;
parameter S04_ACCEPT        = 8;
parameter M_REGIONS         = 1;
parameter M00_BASE_ADDR     = 'b0000_0000_0000_0000_0000_0000_0000000000000000000000000000000000000000;
parameter M00_ADDR_WIDTH    = {M_REGIONS{64'd60}};
parameter M00_CONNECT_READ  = 6'b111111;
parameter M00_CONNECT_WRITE = 6'b111111;
parameter M00_ISSUE         = 4;
parameter M00_SECURE        = 0;
parameter M01_BASE_ADDR     = 'b0001_0000_0000_0000_0000_0000_0000000000000000000000000000000000000000;
parameter M01_ADDR_WIDTH    = {M_REGIONS{64'd60}};
parameter M01_CONNECT_READ  = 6'b111111;
parameter M01_CONNECT_WRITE = 6'b111111;
parameter M01_ISSUE         = 4;
parameter M01_SECURE        = 0;
parameter M02_BASE_ADDR     = 'b0010_0000_0000_0000_0000_0000_0000000000000000000000000000000000000000;
parameter M02_ADDR_WIDTH    = {M_REGIONS{64'd60}};
parameter M02_CONNECT_READ  = 6'b111111;
parameter M02_CONNECT_WRITE = 6'b111111;
parameter M02_ISSUE         = 4;
parameter M02_SECURE        = 0;
parameter M03_BASE_ADDR     = 'b0100_0000_0000_0000_0000_0000_0000000000000000000000000000000000000000;
parameter M03_ADDR_WIDTH    = {M_REGIONS{64'd60}};
parameter M03_CONNECT_READ  = 6'b111111;
parameter M03_CONNECT_WRITE = 6'b111111;
parameter M03_ISSUE         = 4;
parameter M03_SECURE        = 0;
parameter M04_BASE_ADDR     = 'b0110_0000_0000_0000_0000_0000_0000000000000000000000000000000000000000;
parameter M04_ADDR_WIDTH    = {M_REGIONS{64'd60}};
parameter M04_CONNECT_READ  = 6'b111111;
parameter M04_CONNECT_WRITE = 6'b111111;
parameter M04_ISSUE         = 4;
parameter M04_SECURE        = 0;
parameter S00_AW_REG_TYPE   = 0;
parameter S00_W_REG_TYPE    = 0;
parameter S00_B_REG_TYPE    = 1;
parameter S00_AR_REG_TYPE   = 0;
parameter S00_R_REG_TYPE    = 2;
parameter S01_AW_REG_TYPE   = 0;
parameter S01_W_REG_TYPE    = 0;
parameter S01_B_REG_TYPE    = 1;
parameter S01_AR_REG_TYPE   = 0;
parameter S01_R_REG_TYPE    = 2;
parameter S02_AW_REG_TYPE   = 0;
parameter S02_W_REG_TYPE    = 0;
parameter S02_B_REG_TYPE    = 1;
parameter S02_AR_REG_TYPE   = 0;
parameter S02_R_REG_TYPE    = 2;
parameter S03_AW_REG_TYPE   = 0;
parameter S03_W_REG_TYPE    = 0;
parameter S03_B_REG_TYPE    = 1;
parameter S03_AR_REG_TYPE   = 0;
parameter S03_R_REG_TYPE    = 2;
parameter S04_AW_REG_TYPE   = 0;
parameter S04_W_REG_TYPE    = 0;
parameter S04_B_REG_TYPE    = 1;
parameter S04_AR_REG_TYPE   = 0;
parameter S04_R_REG_TYPE    = 2;
parameter M00_AW_REG_TYPE   = 1;
parameter M00_W_REG_TYPE    = 2;
parameter M00_B_REG_TYPE    = 0;
parameter M00_AR_REG_TYPE   = 1;
parameter M00_R_REG_TYPE    = 0;
parameter M01_AW_REG_TYPE   = 1;
parameter M01_W_REG_TYPE    = 2;
parameter M01_B_REG_TYPE    = 0;
parameter M01_AR_REG_TYPE   = 1;
parameter M01_R_REG_TYPE    = 0;
parameter M02_AW_REG_TYPE   = 1;
parameter M02_W_REG_TYPE    = 2;
parameter M02_B_REG_TYPE    = 0;
parameter M02_AR_REG_TYPE   = 1;
parameter M02_R_REG_TYPE    = 0;
parameter M03_AW_REG_TYPE   = 1;
parameter M03_W_REG_TYPE    = 2;
parameter M03_B_REG_TYPE    = 0;
parameter M03_AR_REG_TYPE   = 1;
parameter M03_R_REG_TYPE    = 0;
parameter M04_AW_REG_TYPE   = 1;
parameter M04_W_REG_TYPE    = 2;
parameter M04_B_REG_TYPE    = 0;
parameter M04_AR_REG_TYPE   = 1;
parameter M04_R_REG_TYPE    = 0;

input                                           axi4_clk;
input                                           axi4_rst_n;
input                                           apb4_pclk;
input                                           apb4_presetn;
input       [31:0]                              apb4_paddr;
input                                           apb4_psel;
input                                           apb4_penable;
input                                           apb4_pwrite;
input       [31:0]                              apb4_pwdata;
input       [3:0]                               apb4_pstrb;
input       [2:0]                               apb4_pprot;
input                                           clk;
input                                           rst_n;

input       [MCU_M_AXI_ID_WIDTH-1:0]    mcu_M_AXI_AWID;
input       [31:0]                      mcu_M_AXI_AWADDR;
input       [7:0]                       mcu_M_AXI_AWLEN;
input       [2:0]                       mcu_M_AXI_AWSIZE;
input       [1:0]                       mcu_M_AXI_AWBURST;
input                                   mcu_M_AXI_AWLOCK;
input       [3:0]                       mcu_M_AXI_AWCACHE;
input       [2:0]                       mcu_M_AXI_AWPROT;
input       [3:0]                       mcu_M_AXI_AWQOS;
input       [AXI_M_AXI_USER_WIDTH-1:0]  mcu_M_AXI_AWUSER;
input                                   mcu_M_AXI_AWVALID;
input       [AXI_M_AXI_DATA_WIDTH-1:0]  mcu_M_AXI_WDATA;
input       [AXI_M_AXI_DATA_BYTES-1:0]  mcu_M_AXI_WSTRB;
input                                   mcu_M_AXI_WLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0]  mcu_M_AXI_WUSER;
input                                   mcu_M_AXI_WVALID;
input                                   mcu_M_AXI_BREADY;
input       [MCU_M_AXI_ID_WIDTH-1:0]    mcu_M_AXI_ARID;
input       [31:0]                      mcu_M_AXI_ARADDR;
input       [7:0]                       mcu_M_AXI_ARLEN;
input       [2:0]                       mcu_M_AXI_ARSIZE;
input       [1:0]                       mcu_M_AXI_ARBURST;
input                                   mcu_M_AXI_ARLOCK;
input       [3:0]                       mcu_M_AXI_ARCACHE;
input       [2:0]                       mcu_M_AXI_ARPROT;
input       [3:0]                       mcu_M_AXI_ARQOS;
input       [AXI_M_AXI_USER_WIDTH-1:0]  mcu_M_AXI_ARUSER;
input                                   mcu_M_AXI_ARVALID;
input                                   mcu_M_AXI_RREADY;

input       [serdes_S_AXI_ID_WIDTH-1:0] serdes0_S_AXI_AWID;
input       [AXI_S_AXI_ADDR_WIDTH-1:0]  serdes0_S_AXI_AWADDR;
input       [7:0]                       serdes0_S_AXI_AWLEN;
input       [2:0]                       serdes0_S_AXI_AWSIZE;
input       [1:0]                       serdes0_S_AXI_AWBURST;
input                                   serdes0_S_AXI_AWLOCK;
input       [3:0]                       serdes0_S_AXI_AWCACHE;
input       [2:0]                       serdes0_S_AXI_AWPROT;
input       [3:0]                       serdes0_S_AXI_AWQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0]  serdes0_S_AXI_AWUSER;
input                                   serdes0_S_AXI_AWVALID;
input       [AXI_S_AXI_DATA_WIDTH-1:0]  serdes0_S_AXI_WDATA;
input       [AXI_S_AXI_DATA_BYTES-1:0]  serdes0_S_AXI_WSTRB;
input                                   serdes0_S_AXI_WLAST;
input       [AXI_S_AXI_USER_WIDTH-1:0]  serdes0_S_AXI_WUSER;
input                                   serdes0_S_AXI_WVALID;
input                                   serdes0_S_AXI_BREADY;
input       [serdes_S_AXI_ID_WIDTH-1:0] serdes0_S_AXI_ARID;
input       [AXI_S_AXI_ADDR_WIDTH-1:0]  serdes0_S_AXI_ARADDR;
input       [7:0]                       serdes0_S_AXI_ARLEN;
input       [2:0]                       serdes0_S_AXI_ARSIZE;
input       [1:0]                       serdes0_S_AXI_ARBURST;
input                                   serdes0_S_AXI_ARLOCK;
input       [3:0]                       serdes0_S_AXI_ARCACHE;
input       [2:0]                       serdes0_S_AXI_ARPROT;
input       [3:0]                       serdes0_S_AXI_ARQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0]  serdes0_S_AXI_ARUSER;
input                                   serdes0_S_AXI_ARVALID;
input                                   serdes0_S_AXI_RREADY;

input       [serdes_S_AXI_ID_WIDTH-1:0] serdes1_S_AXI_AWID;
input       [AXI_S_AXI_ADDR_WIDTH-1:0]  serdes1_S_AXI_AWADDR;
input       [7:0]                       serdes1_S_AXI_AWLEN;
input       [2:0]                       serdes1_S_AXI_AWSIZE;
input       [1:0]                       serdes1_S_AXI_AWBURST;
input                                   serdes1_S_AXI_AWLOCK;
input       [3:0]                       serdes1_S_AXI_AWCACHE;
input       [2:0]                       serdes1_S_AXI_AWPROT;
input       [3:0]                       serdes1_S_AXI_AWQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0]  serdes1_S_AXI_AWUSER;
input                                   serdes1_S_AXI_AWVALID;
input       [AXI_S_AXI_DATA_WIDTH-1:0]  serdes1_S_AXI_WDATA;
input       [AXI_S_AXI_DATA_BYTES-1:0]  serdes1_S_AXI_WSTRB;
input                                   serdes1_S_AXI_WLAST;
input       [AXI_S_AXI_USER_WIDTH-1:0]  serdes1_S_AXI_WUSER;
input                                   serdes1_S_AXI_WVALID;
input                                   serdes1_S_AXI_BREADY;
input       [serdes_S_AXI_ID_WIDTH-1:0] serdes1_S_AXI_ARID;
input       [AXI_S_AXI_ADDR_WIDTH-1:0]  serdes1_S_AXI_ARADDR;
input       [7:0]                       serdes1_S_AXI_ARLEN;
input       [2:0]                       serdes1_S_AXI_ARSIZE;
input       [1:0]                       serdes1_S_AXI_ARBURST;
input                                   serdes1_S_AXI_ARLOCK;
input       [3:0]                       serdes1_S_AXI_ARCACHE;
input       [2:0]                       serdes1_S_AXI_ARPROT;
input       [3:0]                       serdes1_S_AXI_ARQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0]  serdes1_S_AXI_ARUSER;
input                                   serdes1_S_AXI_ARVALID;
input                                   serdes1_S_AXI_RREADY;

input                                   serdes0_M_AXI_AWREADY;
input                                   serdes0_M_AXI_WREADY;
input       [serdes_M_AXI_ID_WIDTH-1:0] serdes0_M_AXI_BID;
input       [1:0]                       serdes0_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0]  serdes0_M_AXI_BUSER;
input                                   serdes0_M_AXI_BVALID;
input                                   serdes0_M_AXI_ARREADY;
input       [serdes_M_AXI_ID_WIDTH-1:0] serdes0_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0]  serdes0_M_AXI_RDATA;
input       [1:0]                       serdes0_M_AXI_RRESP;
input                                   serdes0_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0]  serdes0_M_AXI_RUSER;
input                                   serdes0_M_AXI_RVALID;

input                                   serdes1_M_AXI_AWREADY;
input                                   serdes1_M_AXI_WREADY;
input       [serdes_M_AXI_ID_WIDTH-1:0] serdes1_M_AXI_BID;
input       [1:0]                       serdes1_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0]  serdes1_M_AXI_BUSER;
input                                   serdes1_M_AXI_BVALID;
input                                   serdes1_M_AXI_ARREADY;
input       [serdes_M_AXI_ID_WIDTH-1:0] serdes1_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0]  serdes1_M_AXI_RDATA;
input       [1:0]                       serdes1_M_AXI_RRESP;
input                                   serdes1_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0]  serdes1_M_AXI_RUSER;
input                                   serdes1_M_AXI_RVALID;

input                                   ddr0_M_AXI_AWREADY;
input                                   ddr0_M_AXI_WREADY;
input       [ddr_M_AXI_ID_WIDTH-1:0]    ddr0_M_AXI_BID;
input       [1:0]                       ddr0_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0]  ddr0_M_AXI_BUSER;
input                                   ddr0_M_AXI_BVALID;
input                                   ddr0_M_AXI_ARREADY;
input       [ddr_M_AXI_ID_WIDTH-1:0]    ddr0_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0]  ddr0_M_AXI_RDATA;
input       [1:0]                       ddr0_M_AXI_RRESP;
input                                   ddr0_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0]  ddr0_M_AXI_RUSER;
input                                   ddr0_M_AXI_RVALID;

input                                   ddr1_M_AXI_AWREADY;
input                                   ddr1_M_AXI_WREADY;
input       [ddr_M_AXI_ID_WIDTH-1:0]    ddr1_M_AXI_BID;
input       [1:0]                       ddr1_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0]  ddr1_M_AXI_BUSER;
input                                   ddr1_M_AXI_BVALID;
input                                   ddr1_M_AXI_ARREADY;
input       [ddr_M_AXI_ID_WIDTH-1:0]    ddr1_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0]  ddr1_M_AXI_RDATA;
input       [1:0]                       ddr1_M_AXI_RRESP;
input                                   ddr1_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0]  ddr1_M_AXI_RUSER;
input                                   ddr1_M_AXI_RVALID;

output wire                             mcu_M_AXI_AWREADY;
output wire                             mcu_M_AXI_WREADY;
output wire [MCU_M_AXI_ID_WIDTH-1:0]    mcu_M_AXI_BID;
output wire [1:0]                       mcu_M_AXI_BRESP;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  mcu_M_AXI_BUSER;
output wire                             mcu_M_AXI_BVALID;
output wire                             mcu_M_AXI_ARREADY;
output wire [MCU_M_AXI_ID_WIDTH-1:0]    mcu_M_AXI_RID;
output wire [AXI_M_AXI_DATA_WIDTH-1:0]  mcu_M_AXI_RDATA;
output wire [1:0]                       mcu_M_AXI_RRESP;
output wire                             mcu_M_AXI_RLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  mcu_M_AXI_RUSER;
output wire                             mcu_M_AXI_RVALID;

output wire                             serdes0_S_AXI_AWREADY;
output wire                             serdes0_S_AXI_WREADY;
output wire [serdes_S_AXI_ID_WIDTH-1:0] serdes0_S_AXI_BID;
output wire [1:0]                       serdes0_S_AXI_BRESP;
output wire [AXI_S_AXI_USER_WIDTH-1:0]  serdes0_S_AXI_BUSER;
output wire                             serdes0_S_AXI_BVALID;
output wire                             serdes0_S_AXI_ARREADY;
output wire [serdes_S_AXI_ID_WIDTH-1:0] serdes0_S_AXI_RID;
output wire [AXI_S_AXI_DATA_WIDTH-1:0]  serdes0_S_AXI_RDATA;
output wire [1:0]                       serdes0_S_AXI_RRESP;
output wire                             serdes0_S_AXI_RLAST;
output wire [AXI_S_AXI_USER_WIDTH-1:0]  serdes0_S_AXI_RUSER;
output wire                             serdes0_S_AXI_RVALID;

output wire                             serdes1_S_AXI_AWREADY;
output wire                             serdes1_S_AXI_WREADY;
output wire [serdes_S_AXI_ID_WIDTH-1:0] serdes1_S_AXI_BID;
output wire [1:0]                       serdes1_S_AXI_BRESP;
output wire [AXI_S_AXI_USER_WIDTH-1:0]  serdes1_S_AXI_BUSER;
output wire                             serdes1_S_AXI_BVALID;
output wire                             serdes1_S_AXI_ARREADY;
output wire [serdes_S_AXI_ID_WIDTH-1:0] serdes1_S_AXI_RID;
output wire [AXI_S_AXI_DATA_WIDTH-1:0]  serdes1_S_AXI_RDATA;
output wire [1:0]                       serdes1_S_AXI_RRESP;
output wire                             serdes1_S_AXI_RLAST;
output wire [AXI_S_AXI_USER_WIDTH-1:0]  serdes1_S_AXI_RUSER;
output wire                             serdes1_S_AXI_RVALID;

output wire [serdes_S_AXI_ID_WIDTH-1:0] serdes0_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  serdes0_M_AXI_AWADDR;
output wire [7:0]                       serdes0_M_AXI_AWLEN;
output wire [2:0]                       serdes0_M_AXI_AWSIZE;
output wire [1:0]                       serdes0_M_AXI_AWBURST;
output wire                             serdes0_M_AXI_AWLOCK;
output wire [3:0]                       serdes0_M_AXI_AWCACHE;
output wire [2:0]                       serdes0_M_AXI_AWPROT;
output wire [3:0]                       serdes0_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  serdes0_M_AXI_AWUSER;
output wire                             serdes0_M_AXI_AWVALID;
output wire [AXI_M_AXI_DATA_WIDTH-1:0]  serdes0_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0]  serdes0_M_AXI_WSTRB;
output wire                             serdes0_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  serdes0_M_AXI_WUSER;
output wire                             serdes0_M_AXI_WVALID;
output wire                             serdes0_M_AXI_BREADY;
output wire [serdes_S_AXI_ID_WIDTH-1:0] serdes0_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  serdes0_M_AXI_ARADDR;
output wire [7:0]                       serdes0_M_AXI_ARLEN;
output wire [2:0]                       serdes0_M_AXI_ARSIZE;
output wire [1:0]                       serdes0_M_AXI_ARBURST;
output wire                             serdes0_M_AXI_ARLOCK;
output wire [3:0]                       serdes0_M_AXI_ARCACHE;
output wire [2:0]                       serdes0_M_AXI_ARPROT;
output wire [3:0]                       serdes0_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  serdes0_M_AXI_ARUSER;
output wire                             serdes0_M_AXI_ARVALID;
output wire                             serdes0_M_AXI_RREADY;

output wire [serdes_S_AXI_ID_WIDTH-1:0] serdes1_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  serdes1_M_AXI_AWADDR;
output wire [7:0]                       serdes1_M_AXI_AWLEN;
output wire [2:0]                       serdes1_M_AXI_AWSIZE;
output wire [1:0]                       serdes1_M_AXI_AWBURST;
output wire                             serdes1_M_AXI_AWLOCK;
output wire [3:0]                       serdes1_M_AXI_AWCACHE;
output wire [2:0]                       serdes1_M_AXI_AWPROT;
output wire [3:0]                       serdes1_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  serdes1_M_AXI_AWUSER;
output wire                             serdes1_M_AXI_AWVALID;
output wire [AXI_M_AXI_DATA_WIDTH-1:0]  serdes1_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0]  serdes1_M_AXI_WSTRB;
output wire                             serdes1_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  serdes1_M_AXI_WUSER;
output wire                             serdes1_M_AXI_WVALID;
output wire                             serdes1_M_AXI_BREADY;
output wire [serdes_S_AXI_ID_WIDTH-1:0] serdes1_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  serdes1_M_AXI_ARADDR;
output wire [7:0]                       serdes1_M_AXI_ARLEN;
output wire [2:0]                       serdes1_M_AXI_ARSIZE;
output wire [1:0]                       serdes1_M_AXI_ARBURST;
output wire                             serdes1_M_AXI_ARLOCK;
output wire [3:0]                       serdes1_M_AXI_ARCACHE;
output wire [2:0]                       serdes1_M_AXI_ARPROT;
output wire [3:0]                       serdes1_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  serdes1_M_AXI_ARUSER;
output wire                             serdes1_M_AXI_ARVALID;
output wire                             serdes1_M_AXI_RREADY;

output wire [ddr_M_AXI_ID_WIDTH-1:0]    ddr0_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  ddr0_M_AXI_AWADDR;
output wire [7:0]                       ddr0_M_AXI_AWLEN;
output wire [2:0]                       ddr0_M_AXI_AWSIZE;
output wire [1:0]                       ddr0_M_AXI_AWBURST;
output wire                             ddr0_M_AXI_AWLOCK;
output wire [3:0]                       ddr0_M_AXI_AWCACHE;
output wire [2:0]                       ddr0_M_AXI_AWPROT;
output wire [3:0]                       ddr0_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  ddr0_M_AXI_AWUSER;
output wire                             ddr0_M_AXI_AWVALID;
output wire [AXI_M_AXI_DATA_WIDTH-1:0]  ddr0_M_AXI_WDATA;
output wire [AXI_S_AXI_DATA_BYTES-1:0]  ddr0_M_AXI_WSTRB;
output wire                             ddr0_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  ddr0_M_AXI_WUSER;
output wire                             ddr0_M_AXI_WVALID;
output wire                             ddr0_M_AXI_BREADY;
output wire [ddr_M_AXI_ID_WIDTH-1:0]    ddr0_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  ddr0_M_AXI_ARADDR;
output wire [7:0]                       ddr0_M_AXI_ARLEN;
output wire [2:0]                       ddr0_M_AXI_ARSIZE;
output wire [1:0]                       ddr0_M_AXI_ARBURST;
output wire                             ddr0_M_AXI_ARLOCK;
output wire [3:0]                       ddr0_M_AXI_ARCACHE;
output wire [2:0]                       ddr0_M_AXI_ARPROT;
output wire [3:0]                       ddr0_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  ddr0_M_AXI_ARUSER;
output wire                             ddr0_M_AXI_ARVALID;
output wire                             ddr0_M_AXI_RREADY;

output wire [ddr_M_AXI_ID_WIDTH-1:0]    ddr1_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  ddr1_M_AXI_AWADDR;
output wire [7:0]                       ddr1_M_AXI_AWLEN;
output wire [2:0]                       ddr1_M_AXI_AWSIZE;
output wire [1:0]                       ddr1_M_AXI_AWBURST;
output wire                             ddr1_M_AXI_AWLOCK;
output wire [3:0]                       ddr1_M_AXI_AWCACHE;
output wire [2:0]                       ddr1_M_AXI_AWPROT;
output wire [3:0]                       ddr1_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  ddr1_M_AXI_AWUSER;
output wire                             ddr1_M_AXI_AWVALID;
output wire [AXI_M_AXI_DATA_WIDTH-1:0]  ddr1_M_AXI_WDATA;
output wire [AXI_S_AXI_DATA_BYTES-1:0]  ddr1_M_AXI_WSTRB;
output wire                             ddr1_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  ddr1_M_AXI_WUSER;
output wire                             ddr1_M_AXI_WVALID;
output wire                             ddr1_M_AXI_BREADY;
output wire [ddr_M_AXI_ID_WIDTH-1:0]    ddr1_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  ddr1_M_AXI_ARADDR;
output wire [7:0]                       ddr1_M_AXI_ARLEN;
output wire [2:0]                       ddr1_M_AXI_ARSIZE;
output wire [1:0]                       ddr1_M_AXI_ARBURST;
output wire                             ddr1_M_AXI_ARLOCK;
output wire [3:0]                       ddr1_M_AXI_ARCACHE;
output wire [2:0]                       ddr1_M_AXI_ARPROT;
output wire [3:0]                       ddr1_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  ddr1_M_AXI_ARUSER;
output wire                             ddr1_M_AXI_ARVALID;
output wire                             ddr1_M_AXI_RREADY;

output wire [31:0]                      apb4_prdata;
output wire                             apb4_pslverr;
output wire                             apb4_pready;

input         pcie_clk;
input         pcie_rst_n;
output        pcie_ven_msi_req;
output [2:0]  pcie_ven_msi_func_num;
output [2:0]  pcie_ven_msi_tc;
output [4:0]  pcie_ven_msi_vector;
input         pcie_msi_grant;
input  [2:0]  mode_sel;

input         mcu_clk;
input         mcu_rst_n;

wire [AXI_M_AXI_ADDR_WIDTH-1:0] pcie_routed_axi_araddr;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] pcie_routed_axi_awaddr;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] mcu_routed_axi_araddr;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] mcu_routed_axi_awaddr;

// Crossbar
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_0_dma_0_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_0_dma_0_M_AXI_ARADDR;
wire [7:0]                      cluster_0_dma_0_M_AXI_ARLEN;
wire [2:0]                      cluster_0_dma_0_M_AXI_ARSIZE;
wire [1:0]                      cluster_0_dma_0_M_AXI_ARBURST;
wire                            cluster_0_dma_0_M_AXI_ARLOCK;
wire [3:0]                      cluster_0_dma_0_M_AXI_ARCACHE;
wire [2:0]                      cluster_0_dma_0_M_AXI_ARPROT;
wire [3:0]                      cluster_0_dma_0_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_ARUSER;
wire                            cluster_0_dma_0_M_AXI_ARVALID;
wire                            cluster_0_dma_0_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_0_dma_0_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_0_dma_0_M_AXI_RDATA;
wire [1:0]                      cluster_0_dma_0_M_AXI_RRESP;
wire                            cluster_0_dma_0_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_RUSER;
wire                            cluster_0_dma_0_M_AXI_RVALID;
wire                            cluster_0_dma_0_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_0_dma_1_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_0_dma_1_M_AXI_ARADDR;
wire [7:0]                      cluster_0_dma_1_M_AXI_ARLEN;
wire [2:0]                      cluster_0_dma_1_M_AXI_ARSIZE;
wire [1:0]                      cluster_0_dma_1_M_AXI_ARBURST;
wire                            cluster_0_dma_1_M_AXI_ARLOCK;
wire [3:0]                      cluster_0_dma_1_M_AXI_ARCACHE;
wire [2:0]                      cluster_0_dma_1_M_AXI_ARPROT;
wire [3:0]                      cluster_0_dma_1_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_ARUSER;
wire                            cluster_0_dma_1_M_AXI_ARVALID;
wire                            cluster_0_dma_1_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_0_dma_1_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_0_dma_1_M_AXI_RDATA;
wire [1:0]                      cluster_0_dma_1_M_AXI_RRESP;
wire                            cluster_0_dma_1_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_RUSER;
wire                            cluster_0_dma_1_M_AXI_RVALID;
wire                            cluster_0_dma_1_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_1_dma_0_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_1_dma_0_M_AXI_ARADDR;
wire [7:0]                      cluster_1_dma_0_M_AXI_ARLEN;
wire [2:0]                      cluster_1_dma_0_M_AXI_ARSIZE;
wire [1:0]                      cluster_1_dma_0_M_AXI_ARBURST;
wire                            cluster_1_dma_0_M_AXI_ARLOCK;
wire [3:0]                      cluster_1_dma_0_M_AXI_ARCACHE;
wire [2:0]                      cluster_1_dma_0_M_AXI_ARPROT;
wire [3:0]                      cluster_1_dma_0_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_ARUSER;
wire                            cluster_1_dma_0_M_AXI_ARVALID;
wire                            cluster_1_dma_0_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_1_dma_0_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_1_dma_0_M_AXI_RDATA;
wire [1:0]                      cluster_1_dma_0_M_AXI_RRESP;
wire                            cluster_1_dma_0_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_RUSER;
wire                            cluster_1_dma_0_M_AXI_RVALID;
wire                            cluster_1_dma_0_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_1_dma_1_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_1_dma_1_M_AXI_ARADDR;
wire [7:0]                      cluster_1_dma_1_M_AXI_ARLEN;
wire [2:0]                      cluster_1_dma_1_M_AXI_ARSIZE;
wire [1:0]                      cluster_1_dma_1_M_AXI_ARBURST;
wire                            cluster_1_dma_1_M_AXI_ARLOCK;
wire [3:0]                      cluster_1_dma_1_M_AXI_ARCACHE;
wire [2:0]                      cluster_1_dma_1_M_AXI_ARPROT;
wire [3:0]                      cluster_1_dma_1_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_ARUSER;
wire                            cluster_1_dma_1_M_AXI_ARVALID;
wire                            cluster_1_dma_1_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_1_dma_1_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_1_dma_1_M_AXI_RDATA;
wire [1:0]                      cluster_1_dma_1_M_AXI_RRESP;
wire                            cluster_1_dma_1_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_RUSER;
wire                            cluster_1_dma_1_M_AXI_RVALID;
wire                            cluster_1_dma_1_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_2_dma_0_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_2_dma_0_M_AXI_ARADDR;
wire [7:0]                      cluster_2_dma_0_M_AXI_ARLEN;
wire [2:0]                      cluster_2_dma_0_M_AXI_ARSIZE;
wire [1:0]                      cluster_2_dma_0_M_AXI_ARBURST;
wire                            cluster_2_dma_0_M_AXI_ARLOCK;
wire [3:0]                      cluster_2_dma_0_M_AXI_ARCACHE;
wire [2:0]                      cluster_2_dma_0_M_AXI_ARPROT;
wire [3:0]                      cluster_2_dma_0_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_ARUSER;
wire                            cluster_2_dma_0_M_AXI_ARVALID;
wire                            cluster_2_dma_0_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_2_dma_0_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_2_dma_0_M_AXI_RDATA;
wire [1:0]                      cluster_2_dma_0_M_AXI_RRESP;
wire                            cluster_2_dma_0_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_RUSER;
wire                            cluster_2_dma_0_M_AXI_RVALID;
wire                            cluster_2_dma_0_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_2_dma_1_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_2_dma_1_M_AXI_ARADDR;
wire [7:0]                      cluster_2_dma_1_M_AXI_ARLEN;
wire [2:0]                      cluster_2_dma_1_M_AXI_ARSIZE;
wire [1:0]                      cluster_2_dma_1_M_AXI_ARBURST;
wire                            cluster_2_dma_1_M_AXI_ARLOCK;
wire [3:0]                      cluster_2_dma_1_M_AXI_ARCACHE;
wire [2:0]                      cluster_2_dma_1_M_AXI_ARPROT;
wire [3:0]                      cluster_2_dma_1_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_ARUSER;
wire                            cluster_2_dma_1_M_AXI_ARVALID;
wire                            cluster_2_dma_1_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_2_dma_1_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_2_dma_1_M_AXI_RDATA;
wire [1:0]                      cluster_2_dma_1_M_AXI_RRESP;
wire                            cluster_2_dma_1_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_RUSER;
wire                            cluster_2_dma_1_M_AXI_RVALID;
wire                            cluster_2_dma_1_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_3_dma_0_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_3_dma_0_M_AXI_ARADDR;
wire [7:0]                      cluster_3_dma_0_M_AXI_ARLEN;
wire [2:0]                      cluster_3_dma_0_M_AXI_ARSIZE;
wire [1:0]                      cluster_3_dma_0_M_AXI_ARBURST;
wire                            cluster_3_dma_0_M_AXI_ARLOCK;
wire [3:0]                      cluster_3_dma_0_M_AXI_ARCACHE;
wire [2:0]                      cluster_3_dma_0_M_AXI_ARPROT;
wire [3:0]                      cluster_3_dma_0_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_ARUSER;
wire                            cluster_3_dma_0_M_AXI_ARVALID;
wire                            cluster_3_dma_0_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_3_dma_0_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_3_dma_0_M_AXI_RDATA;
wire [1:0]                      cluster_3_dma_0_M_AXI_RRESP;
wire                            cluster_3_dma_0_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_RUSER;
wire                            cluster_3_dma_0_M_AXI_RVALID;
wire                            cluster_3_dma_0_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_3_dma_1_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_3_dma_1_M_AXI_ARADDR;
wire [7:0]                      cluster_3_dma_1_M_AXI_ARLEN;
wire [2:0]                      cluster_3_dma_1_M_AXI_ARSIZE;
wire [1:0]                      cluster_3_dma_1_M_AXI_ARBURST;
wire                            cluster_3_dma_1_M_AXI_ARLOCK;
wire [3:0]                      cluster_3_dma_1_M_AXI_ARCACHE;
wire [2:0]                      cluster_3_dma_1_M_AXI_ARPROT;
wire [3:0]                      cluster_3_dma_1_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_ARUSER;
wire                            cluster_3_dma_1_M_AXI_ARVALID;
wire                            cluster_3_dma_1_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_3_dma_1_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_3_dma_1_M_AXI_RDATA;
wire [1:0]                      cluster_3_dma_1_M_AXI_RRESP;
wire                            cluster_3_dma_1_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_RUSER;
wire                            cluster_3_dma_1_M_AXI_RVALID;
wire                            cluster_3_dma_1_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    dma_0_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] dma_0_M_AXI_ARADDR;
wire [7:0]                      dma_0_M_AXI_ARLEN;
wire [2:0]                      dma_0_M_AXI_ARSIZE;
wire [1:0]                      dma_0_M_AXI_ARBURST;
wire                            dma_0_M_AXI_ARLOCK;
wire [3:0]                      dma_0_M_AXI_ARCACHE;
wire [2:0]                      dma_0_M_AXI_ARPROT;
wire [3:0]                      dma_0_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_0_M_AXI_ARUSER;
wire                            dma_0_M_AXI_ARVALID;
wire                            dma_0_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    dma_0_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] dma_0_M_AXI_RDATA;
wire [1:0]                      dma_0_M_AXI_RRESP;
wire                            dma_0_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_0_M_AXI_RUSER;
wire                            dma_0_M_AXI_RVALID;
wire                            dma_0_M_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    dma_1_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] dma_1_M_AXI_ARADDR;
wire [7:0]                      dma_1_M_AXI_ARLEN;
wire [2:0]                      dma_1_M_AXI_ARSIZE;
wire [1:0]                      dma_1_M_AXI_ARBURST;
wire                            dma_1_M_AXI_ARLOCK;
wire [3:0]                      dma_1_M_AXI_ARCACHE;
wire [2:0]                      dma_1_M_AXI_ARPROT;
wire [3:0]                      dma_1_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_1_M_AXI_ARUSER;
wire                            dma_1_M_AXI_ARVALID;
wire                            dma_1_M_AXI_ARREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    dma_1_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] dma_1_M_AXI_RDATA;
wire [1:0]                      dma_1_M_AXI_RRESP;
wire                            dma_1_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_1_M_AXI_RUSER;
wire                            dma_1_M_AXI_RVALID;
wire                            dma_1_M_AXI_RREADY;

wire [INSN_AXI_ID_WIDTH-1:0]    insn_M_AXI_ARID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] insn_M_AXI_ARADDR;
wire [7:0]                      insn_M_AXI_ARLEN;
wire [2:0]                      insn_M_AXI_ARSIZE;
wire [1:0]                      insn_M_AXI_ARBURST;
wire                            insn_M_AXI_ARLOCK;
wire [3:0]                      insn_M_AXI_ARCACHE;
wire [2:0]                      insn_M_AXI_ARPROT;
wire [3:0]                      insn_M_AXI_ARQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_ARUSER;
wire                            insn_M_AXI_ARVALID;
wire                            insn_M_AXI_ARREADY;
wire [INSN_AXI_ID_WIDTH-1:0]    insn_M_AXI_RID;
wire [AXI_M_AXI_DATA_WIDTH-1:0] insn_M_AXI_RDATA;
wire [1:0]                      insn_M_AXI_RRESP;
wire                            insn_M_AXI_RLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_RUSER;
wire                            insn_M_AXI_RVALID;
wire                            insn_M_AXI_RREADY;

wire [AXI_S_AXI_ID_WIDTH-1:0]   npu_S_AXI_ARID;
wire [AXI_S_AXI_ADDR_WIDTH-1:0] npu_S_AXI_ARADDR;
wire [7:0]                      npu_S_AXI_ARLEN;
wire [2:0]                      npu_S_AXI_ARSIZE;
wire [1:0]                      npu_S_AXI_ARBURST;
wire                            npu_S_AXI_ARLOCK;
wire [3:0]                      npu_S_AXI_ARCACHE;
wire [2:0]                      npu_S_AXI_ARPROT;
wire [3:0]                      npu_S_AXI_ARQOS;
wire [AXI_S_AXI_USER_WIDTH-1:0] npu_S_AXI_ARUSER;
wire                            npu_S_AXI_ARVALID;
wire                            npu_S_AXI_ARREADY;
wire [AXI_S_AXI_ID_WIDTH-1:0]   npu_S_AXI_RID;
wire [AXI_S_AXI_DATA_WIDTH-1:0] npu_S_AXI_RDATA;
wire [1:0]                      npu_S_AXI_RRESP;
wire                            npu_S_AXI_RLAST;
wire [AXI_S_AXI_USER_WIDTH-1:0] npu_S_AXI_RUSER;
wire                            npu_S_AXI_RVALID;
wire                            npu_S_AXI_RREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_0_dma_0_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_0_dma_0_M_AXI_AWADDR;
wire [7:0]                      cluster_0_dma_0_M_AXI_AWLEN;
wire [2:0]                      cluster_0_dma_0_M_AXI_AWSIZE;
wire [1:0]                      cluster_0_dma_0_M_AXI_AWBURST;
wire                            cluster_0_dma_0_M_AXI_AWLOCK;
wire [3:0]                      cluster_0_dma_0_M_AXI_AWCACHE;
wire [2:0]                      cluster_0_dma_0_M_AXI_AWPROT;
wire [3:0]                      cluster_0_dma_0_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_AWUSER;
wire                            cluster_0_dma_0_M_AXI_AWVALID;
wire                            cluster_0_dma_0_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_0_dma_0_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_0_dma_0_M_AXI_WSTRB;
wire                            cluster_0_dma_0_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_WUSER;
wire                            cluster_0_dma_0_M_AXI_WVALID;
wire                            cluster_0_dma_0_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_0_dma_0_M_AXI_BID;
wire [1:0]                      cluster_0_dma_0_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_BUSER;
wire                            cluster_0_dma_0_M_AXI_BVALID;
wire                            cluster_0_dma_0_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_0_dma_1_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_0_dma_1_M_AXI_AWADDR;
wire [7:0]                      cluster_0_dma_1_M_AXI_AWLEN;
wire [2:0]                      cluster_0_dma_1_M_AXI_AWSIZE;
wire [1:0]                      cluster_0_dma_1_M_AXI_AWBURST;
wire                            cluster_0_dma_1_M_AXI_AWLOCK;
wire [3:0]                      cluster_0_dma_1_M_AXI_AWCACHE;
wire [2:0]                      cluster_0_dma_1_M_AXI_AWPROT;
wire [3:0]                      cluster_0_dma_1_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_AWUSER;
wire                            cluster_0_dma_1_M_AXI_AWVALID;
wire                            cluster_0_dma_1_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_0_dma_1_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_0_dma_1_M_AXI_WSTRB;
wire                            cluster_0_dma_1_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_WUSER;
wire                            cluster_0_dma_1_M_AXI_WVALID;
wire                            cluster_0_dma_1_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_0_dma_1_M_AXI_BID;
wire [1:0]                      cluster_0_dma_1_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_BUSER;
wire                            cluster_0_dma_1_M_AXI_BVALID;
wire                            cluster_0_dma_1_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_1_dma_0_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_1_dma_0_M_AXI_AWADDR;
wire [7:0]                      cluster_1_dma_0_M_AXI_AWLEN;
wire [2:0]                      cluster_1_dma_0_M_AXI_AWSIZE;
wire [1:0]                      cluster_1_dma_0_M_AXI_AWBURST;
wire                            cluster_1_dma_0_M_AXI_AWLOCK;
wire [3:0]                      cluster_1_dma_0_M_AXI_AWCACHE;
wire [2:0]                      cluster_1_dma_0_M_AXI_AWPROT;
wire [3:0]                      cluster_1_dma_0_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_AWUSER;
wire                            cluster_1_dma_0_M_AXI_AWVALID;
wire                            cluster_1_dma_0_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_1_dma_0_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_1_dma_0_M_AXI_WSTRB;
wire                            cluster_1_dma_0_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_WUSER;
wire                            cluster_1_dma_0_M_AXI_WVALID;
wire                            cluster_1_dma_0_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_1_dma_0_M_AXI_BID;
wire [1:0]                      cluster_1_dma_0_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_BUSER;
wire                            cluster_1_dma_0_M_AXI_BVALID;
wire                            cluster_1_dma_0_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_1_dma_1_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_1_dma_1_M_AXI_AWADDR;
wire [7:0]                      cluster_1_dma_1_M_AXI_AWLEN;
wire [2:0]                      cluster_1_dma_1_M_AXI_AWSIZE;
wire [1:0]                      cluster_1_dma_1_M_AXI_AWBURST;
wire                            cluster_1_dma_1_M_AXI_AWLOCK;
wire [3:0]                      cluster_1_dma_1_M_AXI_AWCACHE;
wire [2:0]                      cluster_1_dma_1_M_AXI_AWPROT;
wire [3:0]                      cluster_1_dma_1_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_AWUSER;
wire                            cluster_1_dma_1_M_AXI_AWVALID;
wire                            cluster_1_dma_1_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_1_dma_1_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_1_dma_1_M_AXI_WSTRB;
wire                            cluster_1_dma_1_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_WUSER;
wire                            cluster_1_dma_1_M_AXI_WVALID;
wire                            cluster_1_dma_1_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_1_dma_1_M_AXI_BID;
wire [1:0]                      cluster_1_dma_1_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_BUSER;
wire                            cluster_1_dma_1_M_AXI_BVALID;
wire                            cluster_1_dma_1_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_2_dma_0_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_2_dma_0_M_AXI_AWADDR;
wire [7:0]                      cluster_2_dma_0_M_AXI_AWLEN;
wire [2:0]                      cluster_2_dma_0_M_AXI_AWSIZE;
wire [1:0]                      cluster_2_dma_0_M_AXI_AWBURST;
wire                            cluster_2_dma_0_M_AXI_AWLOCK;
wire [3:0]                      cluster_2_dma_0_M_AXI_AWCACHE;
wire [2:0]                      cluster_2_dma_0_M_AXI_AWPROT;
wire [3:0]                      cluster_2_dma_0_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_AWUSER;
wire                            cluster_2_dma_0_M_AXI_AWVALID;
wire                            cluster_2_dma_0_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_2_dma_0_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_2_dma_0_M_AXI_WSTRB;
wire                            cluster_2_dma_0_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_WUSER;
wire                            cluster_2_dma_0_M_AXI_WVALID;
wire                            cluster_2_dma_0_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_2_dma_0_M_AXI_BID;
wire [1:0]                      cluster_2_dma_0_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_BUSER;
wire                            cluster_2_dma_0_M_AXI_BVALID;
wire                            cluster_2_dma_0_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_2_dma_1_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_2_dma_1_M_AXI_AWADDR;
wire [7:0]                      cluster_2_dma_1_M_AXI_AWLEN;
wire [2:0]                      cluster_2_dma_1_M_AXI_AWSIZE;
wire [1:0]                      cluster_2_dma_1_M_AXI_AWBURST;
wire                            cluster_2_dma_1_M_AXI_AWLOCK;
wire [3:0]                      cluster_2_dma_1_M_AXI_AWCACHE;
wire [2:0]                      cluster_2_dma_1_M_AXI_AWPROT;
wire [3:0]                      cluster_2_dma_1_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_AWUSER;
wire                            cluster_2_dma_1_M_AXI_AWVALID;
wire                            cluster_2_dma_1_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_2_dma_1_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_2_dma_1_M_AXI_WSTRB;
wire                            cluster_2_dma_1_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_WUSER;
wire                            cluster_2_dma_1_M_AXI_WVALID;
wire                            cluster_2_dma_1_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_2_dma_1_M_AXI_BID;
wire [1:0]                      cluster_2_dma_1_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_BUSER;
wire                            cluster_2_dma_1_M_AXI_BVALID;
wire                            cluster_2_dma_1_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_3_dma_0_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_3_dma_0_M_AXI_AWADDR;
wire [7:0]                      cluster_3_dma_0_M_AXI_AWLEN;
wire [2:0]                      cluster_3_dma_0_M_AXI_AWSIZE;
wire [1:0]                      cluster_3_dma_0_M_AXI_AWBURST;
wire                            cluster_3_dma_0_M_AXI_AWLOCK;
wire [3:0]                      cluster_3_dma_0_M_AXI_AWCACHE;
wire [2:0]                      cluster_3_dma_0_M_AXI_AWPROT;
wire [3:0]                      cluster_3_dma_0_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_AWUSER;
wire                            cluster_3_dma_0_M_AXI_AWVALID;
wire                            cluster_3_dma_0_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_3_dma_0_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_3_dma_0_M_AXI_WSTRB;
wire                            cluster_3_dma_0_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_WUSER;
wire                            cluster_3_dma_0_M_AXI_WVALID;
wire                            cluster_3_dma_0_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_3_dma_0_M_AXI_BID;
wire [1:0]                      cluster_3_dma_0_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_BUSER;
wire                            cluster_3_dma_0_M_AXI_BVALID;
wire                            cluster_3_dma_0_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    cluster_3_dma_1_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_3_dma_1_M_AXI_AWADDR;
wire [7:0]                      cluster_3_dma_1_M_AXI_AWLEN;
wire [2:0]                      cluster_3_dma_1_M_AXI_AWSIZE;
wire [1:0]                      cluster_3_dma_1_M_AXI_AWBURST;
wire                            cluster_3_dma_1_M_AXI_AWLOCK;
wire [3:0]                      cluster_3_dma_1_M_AXI_AWCACHE;
wire [2:0]                      cluster_3_dma_1_M_AXI_AWPROT;
wire [3:0]                      cluster_3_dma_1_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_AWUSER;
wire                            cluster_3_dma_1_M_AXI_AWVALID;
wire                            cluster_3_dma_1_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_3_dma_1_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_3_dma_1_M_AXI_WSTRB;
wire                            cluster_3_dma_1_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_WUSER;
wire                            cluster_3_dma_1_M_AXI_WVALID;
wire                            cluster_3_dma_1_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    cluster_3_dma_1_M_AXI_BID;
wire [1:0]                      cluster_3_dma_1_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_BUSER;
wire                            cluster_3_dma_1_M_AXI_BVALID;
wire                            cluster_3_dma_1_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    dma_0_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] dma_0_M_AXI_AWADDR;
wire [7:0]                      dma_0_M_AXI_AWLEN;
wire [2:0]                      dma_0_M_AXI_AWSIZE;
wire [1:0]                      dma_0_M_AXI_AWBURST;
wire                            dma_0_M_AXI_AWLOCK;
wire [3:0]                      dma_0_M_AXI_AWCACHE;
wire [2:0]                      dma_0_M_AXI_AWPROT;
wire [3:0]                      dma_0_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_0_M_AXI_AWUSER;
wire                            dma_0_M_AXI_AWVALID;
wire                            dma_0_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] dma_0_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] dma_0_M_AXI_WSTRB;
wire                            dma_0_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_0_M_AXI_WUSER;
wire                            dma_0_M_AXI_WVALID;
wire                            dma_0_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    dma_0_M_AXI_BID;
wire [1:0]                      dma_0_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_0_M_AXI_BUSER;
wire                            dma_0_M_AXI_BVALID;
wire                            dma_0_M_AXI_BREADY;

wire [DATA_AXI_ID_WIDTH-1:0]    dma_1_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] dma_1_M_AXI_AWADDR;
wire [7:0]                      dma_1_M_AXI_AWLEN;
wire [2:0]                      dma_1_M_AXI_AWSIZE;
wire [1:0]                      dma_1_M_AXI_AWBURST;
wire                            dma_1_M_AXI_AWLOCK;
wire [3:0]                      dma_1_M_AXI_AWCACHE;
wire [2:0]                      dma_1_M_AXI_AWPROT;
wire [3:0]                      dma_1_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_1_M_AXI_AWUSER;
wire                            dma_1_M_AXI_AWVALID;
wire                            dma_1_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] dma_1_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] dma_1_M_AXI_WSTRB;
wire                            dma_1_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_1_M_AXI_WUSER;
wire                            dma_1_M_AXI_WVALID;
wire                            dma_1_M_AXI_WREADY;
wire [DATA_AXI_ID_WIDTH-1:0]    dma_1_M_AXI_BID;
wire [1:0]                      dma_1_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] dma_1_M_AXI_BUSER;
wire                            dma_1_M_AXI_BVALID;
wire                            dma_1_M_AXI_BREADY;

wire [INSN_AXI_ID_WIDTH-1:0]    insn_M_AXI_AWID;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] insn_M_AXI_AWADDR;
wire [7:0]                      insn_M_AXI_AWLEN;
wire [2:0]                      insn_M_AXI_AWSIZE;
wire [1:0]                      insn_M_AXI_AWBURST;
wire                            insn_M_AXI_AWLOCK;
wire [3:0]                      insn_M_AXI_AWCACHE;
wire [2:0]                      insn_M_AXI_AWPROT;
wire [3:0]                      insn_M_AXI_AWQOS;
wire [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_AWUSER;
wire                            insn_M_AXI_AWVALID;
wire                            insn_M_AXI_AWREADY;
wire [AXI_M_AXI_DATA_WIDTH-1:0] insn_M_AXI_WDATA;
wire [AXI_M_AXI_DATA_BYTES-1:0] insn_M_AXI_WSTRB;
wire                            insn_M_AXI_WLAST;
wire [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_WUSER;
wire                            insn_M_AXI_WVALID;
wire                            insn_M_AXI_WREADY;
wire [INSN_AXI_ID_WIDTH-1:0]    insn_M_AXI_BID;
wire [1:0]                      insn_M_AXI_BRESP;
wire [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_BUSER;
wire                            insn_M_AXI_BVALID;
wire                            insn_M_AXI_BREADY;

wire [AXI_S_AXI_ID_WIDTH-1:0]   npu_S_AXI_AWID;
wire [AXI_S_AXI_ADDR_WIDTH-1:0] npu_S_AXI_AWADDR;
wire [7:0]                      npu_S_AXI_AWLEN;
wire [2:0]                      npu_S_AXI_AWSIZE;
wire [1:0]                      npu_S_AXI_AWBURST;
wire                            npu_S_AXI_AWLOCK;
wire [3:0]                      npu_S_AXI_AWCACHE;
wire [2:0]                      npu_S_AXI_AWPROT;
wire [3:0]                      npu_S_AXI_AWQOS;
wire [AXI_S_AXI_USER_WIDTH-1:0] npu_S_AXI_AWUSER;
wire                            npu_S_AXI_AWVALID;
wire                            npu_S_AXI_AWREADY;
wire [AXI_S_AXI_DATA_WIDTH-1:0] npu_S_AXI_WDATA;
wire [AXI_S_AXI_DATA_BYTES-1:0] npu_S_AXI_WSTRB;
wire                            npu_S_AXI_WLAST;
wire [AXI_S_AXI_USER_WIDTH-1:0] npu_S_AXI_WUSER;
wire                            npu_S_AXI_WVALID;
wire                            npu_S_AXI_WREADY;
wire [AXI_S_AXI_ID_WIDTH-1:0]   npu_S_AXI_BID;
wire [1:0]                      npu_S_AXI_BRESP;
wire [AXI_S_AXI_USER_WIDTH-1:0] npu_S_AXI_BUSER;
wire                            npu_S_AXI_BVALID;
wire                            npu_S_AXI_BREADY;

wire [31:0] pcie_highaddr;
wire [31:0] mcu_highaddr;

wire [19:0] mcu_M_AXI_ARID_virt;
wire [19:0] mcu_M_AXI_RID_virt;
wire [19:0] mcu_M_AXI_AWID_virt;
wire [19:0] mcu_M_AXI_BID_virt;

assign mcu_M_AXI_ARID_virt = {12'd0, mcu_M_AXI_ARID};
assign mcu_M_AXI_RID = mcu_M_AXI_RID_virt[MCU_M_AXI_ID_WIDTH-1:0];
assign mcu_M_AXI_AWID_virt = {12'd0, mcu_M_AXI_AWID};
assign mcu_M_AXI_BID = mcu_M_AXI_BID_virt[MCU_M_AXI_ID_WIDTH-1:0];

wire [19:0] serdes0_S_AXI_ARID_virt;
wire [19:0] serdes0_S_AXI_RID_virt;
wire [19:0] serdes0_S_AXI_AWID_virt;
wire [19:0] serdes0_S_AXI_BID_virt;

assign serdes0_S_AXI_ARID_virt = {13'd0, serdes0_S_AXI_ARID};
assign serdes0_S_AXI_RID = serdes0_S_AXI_RID_virt[serdes_S_AXI_ID_WIDTH-1:0];
assign serdes0_S_AXI_AWID_virt = {13'd0, serdes0_S_AXI_AWID};
assign serdes0_S_AXI_BID = serdes0_S_AXI_BID_virt[serdes_S_AXI_ID_WIDTH-1:0];

wire [19:0] serdes1_S_AXI_ARID_virt;
wire [19:0] serdes1_S_AXI_RID_virt;
wire [19:0] serdes1_S_AXI_AWID_virt;
wire [19:0] serdes1_S_AXI_BID_virt;

assign serdes1_S_AXI_ARID_virt = {13'd0, serdes1_S_AXI_ARID};
assign serdes1_S_AXI_RID = serdes1_S_AXI_RID_virt[serdes_S_AXI_ID_WIDTH-1:0];
assign serdes1_S_AXI_AWID_virt = {13'd0, serdes1_S_AXI_AWID};
assign serdes1_S_AXI_BID = serdes1_S_AXI_BID_virt[serdes_S_AXI_ID_WIDTH-1:0];

wire [22:0] serdes0_M_AXI_ARID_virt;
wire [22:0] serdes0_M_AXI_RID_virt;
wire [22:0] serdes0_M_AXI_AWID_virt;
wire [22:0] serdes0_M_AXI_BID_virt;

axi_id_convertor #(
  .IN_ID_WIDTH  ( 23 ),
  .OUT_ID_WIDTH ( 8  )
) u_serdes0_M_id_convertor(
  .clk       ( axi4_clk                ),
  .rst_n     ( axi4_rst_n              ),
  .arvalid   ( serdes0_M_AXI_ARVALID   ),
  .arready   ( serdes0_M_AXI_ARREADY   ),
  .arid      ( serdes0_M_AXI_ARID_virt ),
  .virt_arid ( serdes0_M_AXI_ARID      ),
  .awvalid   ( serdes0_M_AXI_AWVALID   ),
  .awready   ( serdes0_M_AXI_AWREADY   ),
  .awid      ( serdes0_M_AXI_AWID_virt ),
  .virt_awid ( serdes0_M_AXI_AWID      ),
  .rvalid    ( serdes0_M_AXI_RVALID    ),
  .rready    ( serdes0_M_AXI_RREADY    ),
  .rid       ( serdes0_M_AXI_RID_virt  ),
  .virt_rid  ( serdes0_M_AXI_RID       ),
  .bvalid    ( serdes0_M_AXI_BVALID    ),
  .bready    ( serdes0_M_AXI_BREADY    ),
  .bid       ( serdes0_M_AXI_BID_virt  ),
  .virt_bid  ( serdes0_M_AXI_BID       )
);

wire [22:0] serdes1_M_AXI_ARID_virt;
wire [22:0] serdes1_M_AXI_RID_virt;
wire [22:0] serdes1_M_AXI_AWID_virt;
wire [22:0] serdes1_M_AXI_BID_virt;

axi_id_convertor #(
  .IN_ID_WIDTH  ( 23 ),
  .OUT_ID_WIDTH ( 8  )
) u_serdes1_M_id_convertor(
  .clk       ( axi4_clk                ),
  .rst_n     ( axi4_rst_n              ),
  .arvalid   ( serdes1_M_AXI_ARVALID   ),
  .arready   ( serdes1_M_AXI_ARREADY   ),
  .arid      ( serdes1_M_AXI_ARID_virt ),
  .virt_arid ( serdes1_M_AXI_ARID      ),
  .awvalid   ( serdes1_M_AXI_AWVALID   ),
  .awready   ( serdes1_M_AXI_AWREADY   ),
  .awid      ( serdes1_M_AXI_AWID_virt ),
  .virt_awid ( serdes1_M_AXI_AWID      ),
  .rvalid    ( serdes1_M_AXI_RVALID    ),
  .rready    ( serdes1_M_AXI_RREADY    ),
  .rid       ( serdes1_M_AXI_RID_virt  ),
  .virt_rid  ( serdes1_M_AXI_RID       ),
  .bvalid    ( serdes1_M_AXI_BVALID    ),
  .bready    ( serdes1_M_AXI_BREADY    ),
  .bid       ( serdes1_M_AXI_BID_virt  ),
  .virt_bid  ( serdes1_M_AXI_BID       )
);

wire [22:0] ddr0_M_AXI_ARID_virt;
wire [22:0] ddr0_M_AXI_RID_virt;
wire [22:0] ddr0_M_AXI_AWID_virt;
wire [22:0] ddr0_M_AXI_BID_virt;

axi_id_convertor #(
  .IN_ID_WIDTH  ( 23 ),
  .OUT_ID_WIDTH ( 14 )
) u_ddr0_M_id_convertor(
  .clk       ( axi4_clk            ),
  .rst_n     ( axi4_rst_n          ),
  .arvalid   ( ddr0_M_AXI_ARVALID   ),
  .arready   ( ddr0_M_AXI_ARREADY   ),
  .arid      ( ddr0_M_AXI_ARID_virt ),
  .virt_arid ( ddr0_M_AXI_ARID      ),
  .awvalid   ( ddr0_M_AXI_AWVALID   ),
  .awready   ( ddr0_M_AXI_AWREADY   ),
  .awid      ( ddr0_M_AXI_AWID_virt ),
  .virt_awid ( ddr0_M_AXI_AWID      ),
  .rvalid    ( ddr0_M_AXI_RVALID    ),
  .rready    ( ddr0_M_AXI_RREADY    ),
  .rid       ( ddr0_M_AXI_RID_virt  ),
  .virt_rid  ( ddr0_M_AXI_RID       ),
  .bvalid    ( ddr0_M_AXI_BVALID    ),
  .bready    ( ddr0_M_AXI_BREADY    ),
  .bid       ( ddr0_M_AXI_BID_virt  ),
  .virt_bid  ( ddr0_M_AXI_BID       )
);

wire [22:0] ddr1_M_AXI_ARID_virt;
wire [22:0] ddr1_M_AXI_RID_virt;
wire [22:0] ddr1_M_AXI_AWID_virt;
wire [22:0] ddr1_M_AXI_BID_virt;

axi_id_convertor #(
  .IN_ID_WIDTH  ( 23 ),
  .OUT_ID_WIDTH ( 14 )
) u_ddr1_M_id_convertor(
  .clk       ( axi4_clk            ),
  .rst_n     ( axi4_rst_n          ),
  .arvalid   ( ddr1_M_AXI_ARVALID   ),
  .arready   ( ddr1_M_AXI_ARREADY   ),
  .arid      ( ddr1_M_AXI_ARID_virt ),
  .virt_arid ( ddr1_M_AXI_ARID      ),
  .awvalid   ( ddr1_M_AXI_AWVALID   ),
  .awready   ( ddr1_M_AXI_AWREADY   ),
  .awid      ( ddr1_M_AXI_AWID_virt ),
  .virt_awid ( ddr1_M_AXI_AWID      ),
  .rvalid    ( ddr1_M_AXI_RVALID    ),
  .rready    ( ddr1_M_AXI_RREADY    ),
  .rid       ( ddr1_M_AXI_RID_virt  ),
  .virt_rid  ( ddr1_M_AXI_RID       ),
  .bvalid    ( ddr1_M_AXI_BVALID    ),
  .bready    ( ddr1_M_AXI_BREADY    ),
  .bid       ( ddr1_M_AXI_BID_virt  ),
  .virt_bid  ( ddr1_M_AXI_BID       )
);

wire [22:0] npu_S_AXI_ARID_virt;
wire [22:0] npu_S_AXI_RID_virt;
wire [22:0] npu_S_AXI_AWID_virt;
wire [22:0] npu_S_AXI_BID_virt;

axi_id_convertor #(
  .IN_ID_WIDTH  ( 23 ),
  .OUT_ID_WIDTH ( 20 )
) u_npu_S_id_convertor(
  .clk       ( axi4_clk            ),
  .rst_n     ( axi4_rst_n          ),
  .arvalid   ( npu_S_AXI_ARVALID   ),
  .arready   ( npu_S_AXI_ARREADY   ),
  .arid      ( npu_S_AXI_ARID_virt ),
  .virt_arid ( npu_S_AXI_ARID      ),
  .awvalid   ( npu_S_AXI_AWVALID   ),
  .awready   ( npu_S_AXI_AWREADY   ),
  .awid      ( npu_S_AXI_AWID_virt ),
  .virt_awid ( npu_S_AXI_AWID      ),
  .rvalid    ( npu_S_AXI_RVALID    ),
  .rready    ( npu_S_AXI_RREADY    ),
  .rid       ( npu_S_AXI_RID_virt  ),
  .virt_rid  ( npu_S_AXI_RID       ),
  .bvalid    ( npu_S_AXI_BVALID    ),
  .bready    ( npu_S_AXI_BREADY    ),
  .bid       ( npu_S_AXI_BID_virt  ),
  .virt_bid  ( npu_S_AXI_BID       )
);

axi_crossbar_wrap_6x5 #(
  .DATA_WIDTH        ( DATA_WIDTH        ),
  .ADDR_WIDTH        ( ADDR_WIDTH        ),
  .STRB_WIDTH        ( STRB_WIDTH        ),
  .S_ID_WIDTH        ( S_ID_WIDTH        ),
  .M_ID_WIDTH        ( M_ID_WIDTH        ),
  .AWUSER_ENABLE     ( AWUSER_ENABLE     ),
  .AWUSER_WIDTH      ( AWUSER_WIDTH      ),
  .WUSER_ENABLE      ( WUSER_ENABLE      ),
  .WUSER_WIDTH       ( WUSER_WIDTH       ),
  .BUSER_ENABLE      ( BUSER_ENABLE      ),
  .BUSER_WIDTH       ( BUSER_WIDTH       ),
  .ARUSER_ENABLE     ( ARUSER_ENABLE     ),
  .ARUSER_WIDTH      ( ARUSER_WIDTH      ),
  .RUSER_ENABLE      ( RUSER_ENABLE      ),
  .RUSER_WIDTH       ( RUSER_WIDTH       ),
  .S00_THREADS       ( S00_THREADS       ),
  .S00_ACCEPT        ( S00_ACCEPT        ),
  .S01_THREADS       ( S01_THREADS       ),
  .S01_ACCEPT        ( S01_ACCEPT        ),
  .S02_THREADS       ( S02_THREADS       ),
  .S02_ACCEPT        ( S02_ACCEPT        ),
  .S03_THREADS       ( S03_THREADS       ),
  .S03_ACCEPT        ( S03_ACCEPT        ),
  .S04_THREADS       ( S04_THREADS       ),
  .S04_ACCEPT        ( S04_ACCEPT        ),
  .S05_THREADS       ( S04_THREADS       ),
  .S05_ACCEPT        ( S04_ACCEPT        ),
  .M_REGIONS         ( M_REGIONS         ),
  .M00_BASE_ADDR     ( M00_BASE_ADDR     ),
  .M00_ADDR_WIDTH    ( M00_ADDR_WIDTH    ),
  .M00_CONNECT_READ  ( M00_CONNECT_READ  ),
  .M00_CONNECT_WRITE ( M00_CONNECT_WRITE ),
  .M00_ISSUE         ( M00_ISSUE         ),
  .M00_SECURE        ( M00_SECURE        ),
  .M01_BASE_ADDR     ( M01_BASE_ADDR     ),
  .M01_ADDR_WIDTH    ( M01_ADDR_WIDTH    ),
  .M01_CONNECT_READ  ( M01_CONNECT_READ  ),
  .M01_CONNECT_WRITE ( M01_CONNECT_WRITE ),
  .M01_ISSUE         ( M01_ISSUE         ),
  .M01_SECURE        ( M01_SECURE        ),
  .M02_BASE_ADDR     ( M02_BASE_ADDR     ),
  .M02_ADDR_WIDTH    ( M02_ADDR_WIDTH    ),
  .M02_CONNECT_READ  ( M02_CONNECT_READ  ),
  .M02_CONNECT_WRITE ( M02_CONNECT_WRITE ),
  .M02_ISSUE         ( M02_ISSUE         ),
  .M02_SECURE        ( M02_SECURE        ),
  .M03_BASE_ADDR     ( M03_BASE_ADDR     ),
  .M03_ADDR_WIDTH    ( M03_ADDR_WIDTH    ),
  .M03_CONNECT_READ  ( M03_CONNECT_READ  ),
  .M03_CONNECT_WRITE ( M03_CONNECT_WRITE ),
  .M03_ISSUE         ( M03_ISSUE         ),
  .M03_SECURE        ( M03_SECURE        ),
  .M04_BASE_ADDR     ( M04_BASE_ADDR     ),
  .M04_ADDR_WIDTH    ( M04_ADDR_WIDTH    ),
  .M04_CONNECT_READ  ( M04_CONNECT_READ  ),
  .M04_CONNECT_WRITE ( M04_CONNECT_WRITE ),
  .M04_ISSUE         ( M04_ISSUE         ),
  .M04_SECURE        ( M04_SECURE        ),
  .S00_AW_REG_TYPE   ( S00_AW_REG_TYPE   ),
  .S00_W_REG_TYPE    ( S00_W_REG_TYPE    ),
  .S00_B_REG_TYPE    ( S00_B_REG_TYPE    ),
  .S00_AR_REG_TYPE   ( S00_AR_REG_TYPE   ),
  .S00_R_REG_TYPE    ( S00_R_REG_TYPE    ),
  .S01_AW_REG_TYPE   ( S01_AW_REG_TYPE   ),
  .S01_W_REG_TYPE    ( S01_W_REG_TYPE    ),
  .S01_B_REG_TYPE    ( S01_B_REG_TYPE    ),
  .S01_AR_REG_TYPE   ( S01_AR_REG_TYPE   ),
  .S01_R_REG_TYPE    ( S01_R_REG_TYPE    ),
  .S02_AW_REG_TYPE   ( S02_AW_REG_TYPE   ),
  .S02_W_REG_TYPE    ( S02_W_REG_TYPE    ),
  .S02_B_REG_TYPE    ( S02_B_REG_TYPE    ),
  .S02_AR_REG_TYPE   ( S02_AR_REG_TYPE   ),
  .S02_R_REG_TYPE    ( S02_R_REG_TYPE    ),
  .S03_AW_REG_TYPE   ( S03_AW_REG_TYPE   ),
  .S03_W_REG_TYPE    ( S03_W_REG_TYPE    ),
  .S03_B_REG_TYPE    ( S03_B_REG_TYPE    ),
  .S03_AR_REG_TYPE   ( S03_AR_REG_TYPE   ),
  .S03_R_REG_TYPE    ( S03_R_REG_TYPE    ),
  .S04_AW_REG_TYPE   ( S04_AW_REG_TYPE   ),
  .S04_W_REG_TYPE    ( S04_W_REG_TYPE    ),
  .S04_B_REG_TYPE    ( S04_B_REG_TYPE    ),
  .S04_AR_REG_TYPE   ( S04_AR_REG_TYPE   ),
  .S04_R_REG_TYPE    ( S04_R_REG_TYPE    ),
  .S05_AW_REG_TYPE   ( S04_AW_REG_TYPE   ),
  .S05_W_REG_TYPE    ( S04_W_REG_TYPE    ),
  .S05_B_REG_TYPE    ( S04_B_REG_TYPE    ),
  .S05_AR_REG_TYPE   ( S04_AR_REG_TYPE   ),
  .S05_R_REG_TYPE    ( S04_R_REG_TYPE    ),
  .M00_AW_REG_TYPE   ( M00_AW_REG_TYPE   ),
  .M00_W_REG_TYPE    ( M00_W_REG_TYPE    ),
  .M00_B_REG_TYPE    ( M00_B_REG_TYPE    ),
  .M00_AR_REG_TYPE   ( M00_AR_REG_TYPE   ),
  .M00_R_REG_TYPE    ( M00_R_REG_TYPE    ),
  .M01_AW_REG_TYPE   ( M01_AW_REG_TYPE   ),
  .M01_W_REG_TYPE    ( M01_W_REG_TYPE    ),
  .M01_B_REG_TYPE    ( M01_B_REG_TYPE    ),
  .M01_AR_REG_TYPE   ( M01_AR_REG_TYPE   ),
  .M01_R_REG_TYPE    ( M01_R_REG_TYPE    ),
  .M02_AW_REG_TYPE   ( M02_AW_REG_TYPE   ),
  .M02_W_REG_TYPE    ( M02_W_REG_TYPE    ),
  .M02_B_REG_TYPE    ( M02_B_REG_TYPE    ),
  .M02_AR_REG_TYPE   ( M02_AR_REG_TYPE   ),
  .M02_R_REG_TYPE    ( M02_R_REG_TYPE    ),
  .M03_AW_REG_TYPE   ( M03_AW_REG_TYPE   ),
  .M03_W_REG_TYPE    ( M03_W_REG_TYPE    ),
  .M03_B_REG_TYPE    ( M03_B_REG_TYPE    ),
  .M03_AR_REG_TYPE   ( M03_AR_REG_TYPE   ),
  .M03_R_REG_TYPE    ( M03_R_REG_TYPE    ),
  .M04_AW_REG_TYPE   ( M04_AW_REG_TYPE   ),
  .M04_W_REG_TYPE    ( M04_W_REG_TYPE    ),
  .M04_B_REG_TYPE    ( M04_B_REG_TYPE    ),
  .M04_AR_REG_TYPE   ( M04_AR_REG_TYPE   ),
  .M04_R_REG_TYPE    ( M04_R_REG_TYPE    )
) u_axi_crosbar(
  .clk              ( axi4_clk                 ),
  .rst_n            ( axi4_rst_n               ),
  .s00_axi_awid     ( serdes0_S_AXI_AWID_virt  ),
  .s00_axi_awaddr   ( serdes0_S_AXI_AWADDR     ),
  .s00_axi_awlen    ( serdes0_S_AXI_AWLEN      ),
  .s00_axi_awsize   ( serdes0_S_AXI_AWSIZE     ),
  .s00_axi_awburst  ( serdes0_S_AXI_AWBURST    ),
  .s00_axi_awlock   ( serdes0_S_AXI_AWLOCK     ),
  .s00_axi_awcache  ( serdes0_S_AXI_AWCACHE    ),
  .s00_axi_awprot   ( serdes0_S_AXI_AWPROT     ),
  .s00_axi_awqos    ( serdes0_S_AXI_AWQOS      ),
  .s00_axi_awuser   ( serdes0_S_AXI_AWUSER     ),
  .s00_axi_awvalid  ( serdes0_S_AXI_AWVALID    ),
  .s00_axi_wdata    ( serdes0_S_AXI_WDATA      ),
  .s00_axi_wstrb    ( serdes0_S_AXI_WSTRB      ),
  .s00_axi_wlast    ( serdes0_S_AXI_WLAST      ),
  .s00_axi_wuser    ( serdes0_S_AXI_WUSER      ),
  .s00_axi_wvalid   ( serdes0_S_AXI_WVALID     ),
  .s00_axi_bready   ( serdes0_S_AXI_BREADY     ),
  .s00_axi_arid     ( serdes0_S_AXI_ARID_virt  ),
  .s00_axi_araddr   ( serdes0_S_AXI_ARADDR     ),
  .s00_axi_arlen    ( serdes0_S_AXI_ARLEN      ),
  .s00_axi_arsize   ( serdes0_S_AXI_ARSIZE     ),
  .s00_axi_arburst  ( serdes0_S_AXI_ARBURST    ),
  .s00_axi_arlock   ( serdes0_S_AXI_ARLOCK     ),
  .s00_axi_arcache  ( serdes0_S_AXI_ARCACHE    ),
  .s00_axi_arprot   ( serdes0_S_AXI_ARPROT     ),
  .s00_axi_arqos    ( serdes0_S_AXI_ARQOS      ),
  .s00_axi_aruser   ( serdes0_S_AXI_ARUSER     ),
  .s00_axi_arvalid  ( serdes0_S_AXI_ARVALID    ),
  .s00_axi_rready   ( serdes0_S_AXI_RREADY     ),
  .s00_axi_awready  ( serdes0_S_AXI_AWREADY    ),
  .s00_axi_wready   ( serdes0_S_AXI_WREADY     ),
  .s00_axi_bid      ( serdes0_S_AXI_BID_virt   ),
  .s00_axi_bresp    ( serdes0_S_AXI_BRESP      ),
  .s00_axi_buser    ( serdes0_S_AXI_BUSER      ),
  .s00_axi_bvalid   ( serdes0_S_AXI_BVALID     ),
  .s00_axi_arready  ( serdes0_S_AXI_ARREADY    ),
  .s00_axi_rid      ( serdes0_S_AXI_RID_virt   ),
  .s00_axi_rdata    ( serdes0_S_AXI_RDATA      ),
  .s00_axi_rresp    ( serdes0_S_AXI_RRESP      ),
  .s00_axi_rlast    ( serdes0_S_AXI_RLAST      ),
  .s00_axi_ruser    ( serdes0_S_AXI_RUSER      ),
  .s00_axi_rvalid   ( serdes0_S_AXI_RVALID     ),

  .s01_axi_awid     ( serdes1_S_AXI_AWID_virt  ),
  .s01_axi_awaddr   ( serdes1_S_AXI_AWADDR     ),
  .s01_axi_awlen    ( serdes1_S_AXI_AWLEN      ),
  .s01_axi_awsize   ( serdes1_S_AXI_AWSIZE     ),
  .s01_axi_awburst  ( serdes1_S_AXI_AWBURST    ),
  .s01_axi_awlock   ( serdes1_S_AXI_AWLOCK     ),
  .s01_axi_awcache  ( serdes1_S_AXI_AWCACHE    ),
  .s01_axi_awprot   ( serdes1_S_AXI_AWPROT     ),
  .s01_axi_awqos    ( serdes1_S_AXI_AWQOS      ),
  .s01_axi_awuser   ( serdes1_S_AXI_AWUSER     ),
  .s01_axi_awvalid  ( serdes1_S_AXI_AWVALID    ),
  .s01_axi_wdata    ( serdes1_S_AXI_WDATA      ),
  .s01_axi_wstrb    ( serdes1_S_AXI_WSTRB      ),
  .s01_axi_wlast    ( serdes1_S_AXI_WLAST      ),
  .s01_axi_wuser    ( serdes1_S_AXI_WUSER      ),
  .s01_axi_wvalid   ( serdes1_S_AXI_WVALID     ),
  .s01_axi_bready   ( serdes1_S_AXI_BREADY     ),
  .s01_axi_arid     ( serdes1_S_AXI_ARID_virt  ),
  .s01_axi_araddr   ( serdes1_S_AXI_ARADDR     ),
  .s01_axi_arlen    ( serdes1_S_AXI_ARLEN      ),
  .s01_axi_arsize   ( serdes1_S_AXI_ARSIZE     ),
  .s01_axi_arburst  ( serdes1_S_AXI_ARBURST    ),
  .s01_axi_arlock   ( serdes1_S_AXI_ARLOCK     ),
  .s01_axi_arcache  ( serdes1_S_AXI_ARCACHE    ),
  .s01_axi_arprot   ( serdes1_S_AXI_ARPROT     ),
  .s01_axi_arqos    ( serdes1_S_AXI_ARQOS      ),
  .s01_axi_aruser   ( serdes1_S_AXI_ARUSER     ),
  .s01_axi_arvalid  ( serdes1_S_AXI_ARVALID    ),
  .s01_axi_rready   ( serdes1_S_AXI_RREADY     ),
  .s01_axi_awready  ( serdes1_S_AXI_AWREADY    ),
  .s01_axi_wready   ( serdes1_S_AXI_WREADY     ),
  .s01_axi_bid      ( serdes1_S_AXI_BID_virt   ),
  .s01_axi_bresp    ( serdes1_S_AXI_BRESP      ),
  .s01_axi_buser    ( serdes1_S_AXI_BUSER      ),
  .s01_axi_bvalid   ( serdes1_S_AXI_BVALID     ),
  .s01_axi_arready  ( serdes1_S_AXI_ARREADY    ),
  .s01_axi_rid      ( serdes1_S_AXI_RID_virt   ),
  .s01_axi_rdata    ( serdes1_S_AXI_RDATA      ),
  .s01_axi_rresp    ( serdes1_S_AXI_RRESP      ),
  .s01_axi_rlast    ( serdes1_S_AXI_RLAST      ),
  .s01_axi_ruser    ( serdes1_S_AXI_RUSER      ),
  .s01_axi_rvalid   ( serdes1_S_AXI_RVALID     ),

  .s02_axi_awid     ( dma_0_M_AXI_AWID    ),
  .s02_axi_awaddr   ( dma_0_M_AXI_AWADDR  ),
  .s02_axi_awlen    ( dma_0_M_AXI_AWLEN   ),
  .s02_axi_awsize   ( dma_0_M_AXI_AWSIZE  ),
  .s02_axi_awburst  ( dma_0_M_AXI_AWBURST ),
  .s02_axi_awlock   ( dma_0_M_AXI_AWLOCK  ),
  .s02_axi_awcache  ( dma_0_M_AXI_AWCACHE ),
  .s02_axi_awprot   ( dma_0_M_AXI_AWPROT  ),
  .s02_axi_awqos    ( dma_0_M_AXI_AWQOS   ),
  .s02_axi_awuser   ( dma_0_M_AXI_AWUSER  ),
  .s02_axi_awvalid  ( dma_0_M_AXI_AWVALID ),
  .s02_axi_wdata    ( dma_0_M_AXI_WDATA   ),
  .s02_axi_wstrb    ( dma_0_M_AXI_WSTRB   ),
  .s02_axi_wlast    ( dma_0_M_AXI_WLAST   ),
  .s02_axi_wuser    ( dma_0_M_AXI_WUSER   ),
  .s02_axi_wvalid   ( dma_0_M_AXI_WVALID  ),
  .s02_axi_bready   ( dma_0_M_AXI_BREADY  ),
  .s02_axi_arid     ( dma_0_M_AXI_ARID    ),
  .s02_axi_araddr   ( dma_0_M_AXI_ARADDR  ),
  .s02_axi_arlen    ( dma_0_M_AXI_ARLEN   ),
  .s02_axi_arsize   ( dma_0_M_AXI_ARSIZE  ),
  .s02_axi_arburst  ( dma_0_M_AXI_ARBURST ),
  .s02_axi_arlock   ( dma_0_M_AXI_ARLOCK  ),
  .s02_axi_arcache  ( dma_0_M_AXI_ARCACHE ),
  .s02_axi_arprot   ( dma_0_M_AXI_ARPROT  ),
  .s02_axi_arqos    ( dma_0_M_AXI_ARQOS   ),
  .s02_axi_aruser   ( dma_0_M_AXI_ARUSER  ),
  .s02_axi_arvalid  ( dma_0_M_AXI_ARVALID ),
  .s02_axi_rready   ( dma_0_M_AXI_RREADY  ),
  .s02_axi_awready  ( dma_0_M_AXI_AWREADY ),
  .s02_axi_wready   ( dma_0_M_AXI_WREADY  ),
  .s02_axi_bid      ( dma_0_M_AXI_BID     ),
  .s02_axi_bresp    ( dma_0_M_AXI_BRESP   ),
  .s02_axi_buser    ( dma_0_M_AXI_BUSER   ),
  .s02_axi_bvalid   ( dma_0_M_AXI_BVALID  ),
  .s02_axi_arready  ( dma_0_M_AXI_ARREADY ),
  .s02_axi_rid      ( dma_0_M_AXI_RID     ),
  .s02_axi_rdata    ( dma_0_M_AXI_RDATA   ),
  .s02_axi_rresp    ( dma_0_M_AXI_RRESP   ),
  .s02_axi_rlast    ( dma_0_M_AXI_RLAST   ),
  .s02_axi_ruser    ( dma_0_M_AXI_RUSER   ),
  .s02_axi_rvalid   ( dma_0_M_AXI_RVALID  ),
  
  .s03_axi_awid     ( insn_M_AXI_AWID      ),
  .s03_axi_awaddr   ( insn_M_AXI_AWADDR    ),
  .s03_axi_awlen    ( insn_M_AXI_AWLEN     ),
  .s03_axi_awsize   ( insn_M_AXI_AWSIZE    ),
  .s03_axi_awburst  ( insn_M_AXI_AWBURST   ),
  .s03_axi_awlock   ( insn_M_AXI_AWLOCK    ),
  .s03_axi_awcache  ( insn_M_AXI_AWCACHE   ),
  .s03_axi_awprot   ( insn_M_AXI_AWPROT    ),
  .s03_axi_awqos    ( insn_M_AXI_AWQOS     ),
  .s03_axi_awuser   ( insn_M_AXI_AWUSER    ),
  .s03_axi_awvalid  ( insn_M_AXI_AWVALID   ),
  .s03_axi_wdata    ( insn_M_AXI_WDATA     ),
  .s03_axi_wstrb    ( insn_M_AXI_WSTRB     ),
  .s03_axi_wlast    ( insn_M_AXI_WLAST     ),
  .s03_axi_wuser    ( insn_M_AXI_WUSER     ),
  .s03_axi_wvalid   ( insn_M_AXI_WVALID    ),
  .s03_axi_bready   ( insn_M_AXI_BREADY    ),
  .s03_axi_arid     ( insn_M_AXI_ARID      ),
  .s03_axi_araddr   ( insn_M_AXI_ARADDR    ),
  .s03_axi_arlen    ( insn_M_AXI_ARLEN     ),
  .s03_axi_arsize   ( insn_M_AXI_ARSIZE    ),
  .s03_axi_arburst  ( insn_M_AXI_ARBURST   ),
  .s03_axi_arlock   ( insn_M_AXI_ARLOCK    ),
  .s03_axi_arcache  ( insn_M_AXI_ARCACHE   ),
  .s03_axi_arprot   ( insn_M_AXI_ARPROT    ),
  .s03_axi_arqos    ( insn_M_AXI_ARQOS     ),
  .s03_axi_aruser   ( insn_M_AXI_ARUSER    ),
  .s03_axi_arvalid  ( insn_M_AXI_ARVALID   ),
  .s03_axi_rready   ( insn_M_AXI_RREADY    ),
  .s03_axi_awready  ( insn_M_AXI_AWREADY   ),
  .s03_axi_wready   ( insn_M_AXI_WREADY    ),
  .s03_axi_bid      ( insn_M_AXI_BID       ),
  .s03_axi_bresp    ( insn_M_AXI_BRESP     ),
  .s03_axi_buser    ( insn_M_AXI_BUSER     ),
  .s03_axi_bvalid   ( insn_M_AXI_BVALID    ),
  .s03_axi_arready  ( insn_M_AXI_ARREADY   ),
  .s03_axi_rid      ( insn_M_AXI_RID       ),
  .s03_axi_rdata    ( insn_M_AXI_RDATA     ),
  .s03_axi_rresp    ( insn_M_AXI_RRESP     ),
  .s03_axi_rlast    ( insn_M_AXI_RLAST     ),
  .s03_axi_ruser    ( insn_M_AXI_RUSER     ),
  .s03_axi_rvalid   ( insn_M_AXI_RVALID    ),
  
  .s04_axi_awid     ( mcu_M_AXI_AWID_virt      ),
  .s04_axi_awaddr   ( mcu_routed_axi_awaddr    ),
  .s04_axi_awlen    ( mcu_M_AXI_AWLEN          ),
  .s04_axi_awsize   ( mcu_M_AXI_AWSIZE         ),
  .s04_axi_awburst  ( mcu_M_AXI_AWBURST        ),
  .s04_axi_awlock   ( mcu_M_AXI_AWLOCK         ),
  .s04_axi_awcache  ( mcu_M_AXI_AWCACHE        ),
  .s04_axi_awprot   ( mcu_M_AXI_AWPROT         ),
  .s04_axi_awqos    ( mcu_M_AXI_AWQOS          ),
  .s04_axi_awuser   ( mcu_M_AXI_AWUSER         ),
  .s04_axi_awvalid  ( mcu_M_AXI_AWVALID        ),
  .s04_axi_wdata    ( mcu_M_AXI_WDATA          ),
  .s04_axi_wstrb    ( mcu_M_AXI_WSTRB          ),
  .s04_axi_wlast    ( mcu_M_AXI_WLAST          ),
  .s04_axi_wuser    ( mcu_M_AXI_WUSER          ),
  .s04_axi_wvalid   ( mcu_M_AXI_WVALID         ),
  .s04_axi_bready   ( mcu_M_AXI_BREADY         ),
  .s04_axi_arid     ( mcu_M_AXI_ARID_virt      ),
  .s04_axi_araddr   ( mcu_routed_axi_araddr    ),
  .s04_axi_arlen    ( mcu_M_AXI_ARLEN          ),
  .s04_axi_arsize   ( mcu_M_AXI_ARSIZE         ),
  .s04_axi_arburst  ( mcu_M_AXI_ARBURST        ),
  .s04_axi_arlock   ( mcu_M_AXI_ARLOCK         ),
  .s04_axi_arcache  ( mcu_M_AXI_ARCACHE        ),
  .s04_axi_arprot   ( mcu_M_AXI_ARPROT         ),
  .s04_axi_arqos    ( mcu_M_AXI_ARQOS          ),
  .s04_axi_aruser   ( mcu_M_AXI_ARUSER         ),
  .s04_axi_arvalid  ( mcu_M_AXI_ARVALID        ),
  .s04_axi_rready   ( mcu_M_AXI_RREADY         ),
  .s04_axi_awready  ( mcu_M_AXI_AWREADY        ),
  .s04_axi_wready   ( mcu_M_AXI_WREADY         ),
  .s04_axi_bid      ( mcu_M_AXI_BID_virt       ),
  .s04_axi_bresp    ( mcu_M_AXI_BRESP          ),
  .s04_axi_buser    ( mcu_M_AXI_BUSER          ),
  .s04_axi_bvalid   ( mcu_M_AXI_BVALID         ),
  .s04_axi_arready  ( mcu_M_AXI_ARREADY        ),
  .s04_axi_rid      ( mcu_M_AXI_RID_virt       ),
  .s04_axi_rdata    ( mcu_M_AXI_RDATA          ),
  .s04_axi_rresp    ( mcu_M_AXI_RRESP          ),
  .s04_axi_rlast    ( mcu_M_AXI_RLAST          ),
  .s04_axi_ruser    ( mcu_M_AXI_RUSER          ),
  .s04_axi_rvalid   ( mcu_M_AXI_RVALID         ),

  .s05_axi_awid     ( dma_1_M_AXI_AWID    ),
  .s05_axi_awaddr   ( dma_1_M_AXI_AWADDR  ),
  .s05_axi_awlen    ( dma_1_M_AXI_AWLEN   ),
  .s05_axi_awsize   ( dma_1_M_AXI_AWSIZE  ),
  .s05_axi_awburst  ( dma_1_M_AXI_AWBURST ),
  .s05_axi_awlock   ( dma_1_M_AXI_AWLOCK  ),
  .s05_axi_awcache  ( dma_1_M_AXI_AWCACHE ),
  .s05_axi_awprot   ( dma_1_M_AXI_AWPROT  ),
  .s05_axi_awqos    ( dma_1_M_AXI_AWQOS   ),
  .s05_axi_awuser   ( dma_1_M_AXI_AWUSER  ),
  .s05_axi_awvalid  ( dma_1_M_AXI_AWVALID ),
  .s05_axi_wdata    ( dma_1_M_AXI_WDATA   ),
  .s05_axi_wstrb    ( dma_1_M_AXI_WSTRB   ),
  .s05_axi_wlast    ( dma_1_M_AXI_WLAST   ),
  .s05_axi_wuser    ( dma_1_M_AXI_WUSER   ),
  .s05_axi_wvalid   ( dma_1_M_AXI_WVALID  ),
  .s05_axi_bready   ( dma_1_M_AXI_BREADY  ),
  .s05_axi_arid     ( dma_1_M_AXI_ARID    ),
  .s05_axi_araddr   ( dma_1_M_AXI_ARADDR  ),
  .s05_axi_arlen    ( dma_1_M_AXI_ARLEN   ),
  .s05_axi_arsize   ( dma_1_M_AXI_ARSIZE  ),
  .s05_axi_arburst  ( dma_1_M_AXI_ARBURST ),
  .s05_axi_arlock   ( dma_1_M_AXI_ARLOCK  ),
  .s05_axi_arcache  ( dma_1_M_AXI_ARCACHE ),
  .s05_axi_arprot   ( dma_1_M_AXI_ARPROT  ),
  .s05_axi_arqos    ( dma_1_M_AXI_ARQOS   ),
  .s05_axi_aruser   ( dma_1_M_AXI_ARUSER  ),
  .s05_axi_arvalid  ( dma_1_M_AXI_ARVALID ),
  .s05_axi_rready   ( dma_1_M_AXI_RREADY  ),
  .s05_axi_awready  ( dma_1_M_AXI_AWREADY ),
  .s05_axi_wready   ( dma_1_M_AXI_WREADY  ),
  .s05_axi_bid      ( dma_1_M_AXI_BID     ),
  .s05_axi_bresp    ( dma_1_M_AXI_BRESP   ),
  .s05_axi_buser    ( dma_1_M_AXI_BUSER   ),
  .s05_axi_bvalid   ( dma_1_M_AXI_BVALID  ),
  .s05_axi_arready  ( dma_1_M_AXI_ARREADY ),
  .s05_axi_rid      ( dma_1_M_AXI_RID     ),
  .s05_axi_rdata    ( dma_1_M_AXI_RDATA   ),
  .s05_axi_rresp    ( dma_1_M_AXI_RRESP   ),
  .s05_axi_rlast    ( dma_1_M_AXI_RLAST   ),
  .s05_axi_ruser    ( dma_1_M_AXI_RUSER   ),
  .s05_axi_rvalid   ( dma_1_M_AXI_RVALID  ),

  .m00_axi_awready  ( npu_S_AXI_AWREADY      ),
  .m00_axi_wready   ( npu_S_AXI_WREADY       ),
  .m00_axi_bid      ( npu_S_AXI_BID_virt     ),
  .m00_axi_bresp    ( npu_S_AXI_BRESP        ),
  .m00_axi_buser    ( npu_S_AXI_BUSER        ),
  .m00_axi_bvalid   ( npu_S_AXI_BVALID       ),
  .m00_axi_arready  ( npu_S_AXI_ARREADY      ),
  .m00_axi_rid      ( npu_S_AXI_RID_virt     ),
  .m00_axi_rdata    ( npu_S_AXI_RDATA        ),
  .m00_axi_rresp    ( npu_S_AXI_RRESP        ),
  .m00_axi_rlast    ( npu_S_AXI_RLAST        ),
  .m00_axi_ruser    ( npu_S_AXI_RUSER        ),
  .m00_axi_rvalid   ( npu_S_AXI_RVALID       ),
  .m00_axi_awid     ( npu_S_AXI_AWID_virt    ),
  .m00_axi_awaddr   ( npu_S_AXI_AWADDR       ),
  .m00_axi_awlen    ( npu_S_AXI_AWLEN        ),
  .m00_axi_awsize   ( npu_S_AXI_AWSIZE       ),
  .m00_axi_awburst  ( npu_S_AXI_AWBURST      ),
  .m00_axi_awlock   ( npu_S_AXI_AWLOCK       ),
  .m00_axi_awcache  ( npu_S_AXI_AWCACHE      ),
  .m00_axi_awprot   ( npu_S_AXI_AWPROT       ),
  .m00_axi_awqos    ( npu_S_AXI_AWQOS        ),
  .m00_axi_awregion (                        ),
  .m00_axi_awuser   ( npu_S_AXI_AWUSER       ),
  .m00_axi_awvalid  ( npu_S_AXI_AWVALID      ),
  .m00_axi_wdata    ( npu_S_AXI_WDATA        ),
  .m00_axi_wstrb    ( npu_S_AXI_WSTRB        ),
  .m00_axi_wlast    ( npu_S_AXI_WLAST        ),
  .m00_axi_wuser    ( npu_S_AXI_WUSER        ),
  .m00_axi_wvalid   ( npu_S_AXI_WVALID       ),
  .m00_axi_bready   ( npu_S_AXI_BREADY       ),
  .m00_axi_arid     ( npu_S_AXI_ARID_virt    ),
  .m00_axi_araddr   ( npu_S_AXI_ARADDR       ),
  .m00_axi_arlen    ( npu_S_AXI_ARLEN        ),
  .m00_axi_arsize   ( npu_S_AXI_ARSIZE       ),
  .m00_axi_arburst  ( npu_S_AXI_ARBURST      ),
  .m00_axi_arlock   ( npu_S_AXI_ARLOCK       ),
  .m00_axi_arcache  ( npu_S_AXI_ARCACHE      ),
  .m00_axi_arprot   ( npu_S_AXI_ARPROT       ),
  .m00_axi_arqos    ( npu_S_AXI_ARQOS        ),
  .m00_axi_arregion (                        ),
  .m00_axi_aruser   ( npu_S_AXI_ARUSER       ),
  .m00_axi_arvalid  ( npu_S_AXI_ARVALID      ),
  .m00_axi_rready   ( npu_S_AXI_RREADY       ),

  .m01_axi_awready  ( ddr1_M_AXI_AWREADY     ),
  .m01_axi_wready   ( ddr1_M_AXI_WREADY      ),
  .m01_axi_bid      ( ddr1_M_AXI_BID_virt    ),
  .m01_axi_bresp    ( ddr1_M_AXI_BRESP       ),
  .m01_axi_buser    ( ddr1_M_AXI_BUSER       ),
  .m01_axi_bvalid   ( ddr1_M_AXI_BVALID      ),
  .m01_axi_arready  ( ddr1_M_AXI_ARREADY     ),
  .m01_axi_rid      ( ddr1_M_AXI_RID_virt    ),
  .m01_axi_rdata    ( ddr1_M_AXI_RDATA       ),
  .m01_axi_rresp    ( ddr1_M_AXI_RRESP       ),
  .m01_axi_rlast    ( ddr1_M_AXI_RLAST       ),
  .m01_axi_ruser    ( ddr1_M_AXI_RUSER       ),
  .m01_axi_rvalid   ( ddr1_M_AXI_RVALID      ),
  .m01_axi_awid     ( ddr1_M_AXI_AWID_virt   ),
  .m01_axi_awaddr   ( ddr1_M_AXI_AWADDR      ),
  .m01_axi_awlen    ( ddr1_M_AXI_AWLEN       ),
  .m01_axi_awsize   ( ddr1_M_AXI_AWSIZE      ),
  .m01_axi_awburst  ( ddr1_M_AXI_AWBURST     ),
  .m01_axi_awlock   ( ddr1_M_AXI_AWLOCK      ),
  .m01_axi_awcache  ( ddr1_M_AXI_AWCACHE     ),
  .m01_axi_awprot   ( ddr1_M_AXI_AWPROT      ),
  .m01_axi_awqos    ( ddr1_M_AXI_AWQOS       ),
  .m01_axi_awregion (                        ),
  .m01_axi_awuser   ( ddr1_M_AXI_AWUSER      ),
  .m01_axi_awvalid  ( ddr1_M_AXI_AWVALID     ),
  .m01_axi_wdata    ( ddr1_M_AXI_WDATA       ),
  .m01_axi_wstrb    ( ddr1_M_AXI_WSTRB       ),
  .m01_axi_wlast    ( ddr1_M_AXI_WLAST       ),
  .m01_axi_wuser    ( ddr1_M_AXI_WUSER       ),
  .m01_axi_wvalid   ( ddr1_M_AXI_WVALID      ),
  .m01_axi_bready   ( ddr1_M_AXI_BREADY      ),
  .m01_axi_arid     ( ddr1_M_AXI_ARID_virt   ),
  .m01_axi_araddr   ( ddr1_M_AXI_ARADDR      ),
  .m01_axi_arlen    ( ddr1_M_AXI_ARLEN       ),
  .m01_axi_arsize   ( ddr1_M_AXI_ARSIZE      ),
  .m01_axi_arburst  ( ddr1_M_AXI_ARBURST     ),
  .m01_axi_arlock   ( ddr1_M_AXI_ARLOCK      ),
  .m01_axi_arcache  ( ddr1_M_AXI_ARCACHE     ),
  .m01_axi_arprot   ( ddr1_M_AXI_ARPROT      ),
  .m01_axi_arqos    ( ddr1_M_AXI_ARQOS       ),
  .m01_axi_arregion (                        ),
  .m01_axi_aruser   ( ddr1_M_AXI_ARUSER      ),
  .m01_axi_arvalid  ( ddr1_M_AXI_ARVALID     ),
  .m01_axi_rready   ( ddr1_M_AXI_RREADY      ),

  .m02_axi_awready  ( serdes0_M_AXI_AWREADY   ),
  .m02_axi_wready   ( serdes0_M_AXI_WREADY    ),
  .m02_axi_bid      ( serdes0_M_AXI_BID_virt  ),
  .m02_axi_bresp    ( serdes0_M_AXI_BRESP     ),
  .m02_axi_buser    ( serdes0_M_AXI_BUSER     ),
  .m02_axi_bvalid   ( serdes0_M_AXI_BVALID    ),
  .m02_axi_arready  ( serdes0_M_AXI_ARREADY   ),
  .m02_axi_rid      ( serdes0_M_AXI_RID_virt  ),
  .m02_axi_rdata    ( serdes0_M_AXI_RDATA     ),
  .m02_axi_rresp    ( serdes0_M_AXI_RRESP     ),
  .m02_axi_rlast    ( serdes0_M_AXI_RLAST     ),
  .m02_axi_ruser    ( serdes0_M_AXI_RUSER     ),
  .m02_axi_rvalid   ( serdes0_M_AXI_RVALID    ),
  .m02_axi_awid     ( serdes0_M_AXI_AWID_virt ),
  .m02_axi_awaddr   ( pcie_routed_axi_awaddr  ),
  .m02_axi_awlen    ( serdes0_M_AXI_AWLEN     ),
  .m02_axi_awsize   ( serdes0_M_AXI_AWSIZE    ),
  .m02_axi_awburst  ( serdes0_M_AXI_AWBURST   ),
  .m02_axi_awlock   ( serdes0_M_AXI_AWLOCK    ),
  .m02_axi_awcache  ( serdes0_M_AXI_AWCACHE   ),
  .m02_axi_awprot   ( serdes0_M_AXI_AWPROT    ),
  .m02_axi_awqos    ( serdes0_M_AXI_AWQOS     ),
  .m02_axi_awregion (                         ),
  .m02_axi_awuser   ( serdes0_M_AXI_AWUSER    ),
  .m02_axi_awvalid  ( serdes0_M_AXI_AWVALID   ),
  .m02_axi_wdata    ( serdes0_M_AXI_WDATA     ),
  .m02_axi_wstrb    ( serdes0_M_AXI_WSTRB     ),
  .m02_axi_wlast    ( serdes0_M_AXI_WLAST     ),
  .m02_axi_wuser    ( serdes0_M_AXI_WUSER     ),
  .m02_axi_wvalid   ( serdes0_M_AXI_WVALID    ),
  .m02_axi_bready   ( serdes0_M_AXI_BREADY    ),
  .m02_axi_arid     ( serdes0_M_AXI_ARID_virt ),
  .m02_axi_araddr   ( pcie_routed_axi_araddr  ),
  .m02_axi_arlen    ( serdes0_M_AXI_ARLEN     ),
  .m02_axi_arsize   ( serdes0_M_AXI_ARSIZE    ),
  .m02_axi_arburst  ( serdes0_M_AXI_ARBURST   ),
  .m02_axi_arlock   ( serdes0_M_AXI_ARLOCK    ),
  .m02_axi_arcache  ( serdes0_M_AXI_ARCACHE   ),
  .m02_axi_arprot   ( serdes0_M_AXI_ARPROT    ),
  .m02_axi_arqos    ( serdes0_M_AXI_ARQOS     ),
  .m02_axi_arregion (                         ),
  .m02_axi_aruser   ( serdes0_M_AXI_ARUSER    ),
  .m02_axi_arvalid  ( serdes0_M_AXI_ARVALID   ),
  .m02_axi_rready   ( serdes0_M_AXI_RREADY    ),

  .m03_axi_awready  ( serdes1_M_AXI_AWREADY  ),
  .m03_axi_wready   ( serdes1_M_AXI_WREADY   ),
  .m03_axi_bid      ( serdes1_M_AXI_BID_virt ),
  .m03_axi_bresp    ( serdes1_M_AXI_BRESP    ),
  .m03_axi_buser    ( serdes1_M_AXI_BUSER    ),
  .m03_axi_bvalid   ( serdes1_M_AXI_BVALID   ),
  .m03_axi_arready  ( serdes1_M_AXI_ARREADY  ),
  .m03_axi_rid      ( serdes1_M_AXI_RID_virt ),
  .m03_axi_rdata    ( serdes1_M_AXI_RDATA    ),
  .m03_axi_rresp    ( serdes1_M_AXI_RRESP    ),
  .m03_axi_rlast    ( serdes1_M_AXI_RLAST    ),
  .m03_axi_ruser    ( serdes1_M_AXI_RUSER    ),
  .m03_axi_rvalid   ( serdes1_M_AXI_RVALID   ),
  .m03_axi_awid     ( serdes1_M_AXI_AWID_virt ),
  .m03_axi_awaddr   ( serdes1_M_AXI_AWADDR    ),
  .m03_axi_awlen    ( serdes1_M_AXI_AWLEN     ),
  .m03_axi_awsize   ( serdes1_M_AXI_AWSIZE    ),
  .m03_axi_awburst  ( serdes1_M_AXI_AWBURST   ),
  .m03_axi_awlock   ( serdes1_M_AXI_AWLOCK    ),
  .m03_axi_awcache  ( serdes1_M_AXI_AWCACHE   ),
  .m03_axi_awprot   ( serdes1_M_AXI_AWPROT    ),
  .m03_axi_awqos    ( serdes1_M_AXI_AWQOS     ),
  .m03_axi_awregion (                         ),
  .m03_axi_awuser   ( serdes1_M_AXI_AWUSER    ),
  .m03_axi_awvalid  ( serdes1_M_AXI_AWVALID   ),
  .m03_axi_wdata    ( serdes1_M_AXI_WDATA     ),
  .m03_axi_wstrb    ( serdes1_M_AXI_WSTRB     ),
  .m03_axi_wlast    ( serdes1_M_AXI_WLAST     ),
  .m03_axi_wuser    ( serdes1_M_AXI_WUSER     ),
  .m03_axi_wvalid   ( serdes1_M_AXI_WVALID    ),
  .m03_axi_bready   ( serdes1_M_AXI_BREADY    ),
  .m03_axi_arid     ( serdes1_M_AXI_ARID_virt ),
  .m03_axi_araddr   ( serdes1_M_AXI_ARADDR    ),
  .m03_axi_arlen    ( serdes1_M_AXI_ARLEN     ),
  .m03_axi_arsize   ( serdes1_M_AXI_ARSIZE    ),
  .m03_axi_arburst  ( serdes1_M_AXI_ARBURST   ),
  .m03_axi_arlock   ( serdes1_M_AXI_ARLOCK    ),
  .m03_axi_arcache  ( serdes1_M_AXI_ARCACHE   ),
  .m03_axi_arprot   ( serdes1_M_AXI_ARPROT    ),
  .m03_axi_arqos    ( serdes1_M_AXI_ARQOS     ),
  .m03_axi_arregion (                         ),
  .m03_axi_aruser   ( serdes1_M_AXI_ARUSER    ),
  .m03_axi_arvalid  ( serdes1_M_AXI_ARVALID   ),
  .m03_axi_rready   ( serdes1_M_AXI_RREADY    ),

  .m04_axi_awready  ( ddr0_M_AXI_AWREADY     ),
  .m04_axi_wready   ( ddr0_M_AXI_WREADY      ),
  .m04_axi_bid      ( ddr0_M_AXI_BID_virt    ),
  .m04_axi_bresp    ( ddr0_M_AXI_BRESP       ),
  .m04_axi_buser    ( ddr0_M_AXI_BUSER       ),
  .m04_axi_bvalid   ( ddr0_M_AXI_BVALID      ),
  .m04_axi_arready  ( ddr0_M_AXI_ARREADY     ),
  .m04_axi_rid      ( ddr0_M_AXI_RID_virt    ),
  .m04_axi_rdata    ( ddr0_M_AXI_RDATA       ),
  .m04_axi_rresp    ( ddr0_M_AXI_RRESP       ),
  .m04_axi_rlast    ( ddr0_M_AXI_RLAST       ),
  .m04_axi_ruser    ( ddr0_M_AXI_RUSER       ),
  .m04_axi_rvalid   ( ddr0_M_AXI_RVALID      ),
  .m04_axi_awid     ( ddr0_M_AXI_AWID_virt   ),
  .m04_axi_awaddr   ( ddr0_M_AXI_AWADDR      ),
  .m04_axi_awlen    ( ddr0_M_AXI_AWLEN       ),
  .m04_axi_awsize   ( ddr0_M_AXI_AWSIZE      ),
  .m04_axi_awburst  ( ddr0_M_AXI_AWBURST     ),
  .m04_axi_awlock   ( ddr0_M_AXI_AWLOCK      ),
  .m04_axi_awcache  ( ddr0_M_AXI_AWCACHE     ),
  .m04_axi_awprot   ( ddr0_M_AXI_AWPROT      ),
  .m04_axi_awqos    ( ddr0_M_AXI_AWQOS       ),
  .m04_axi_awregion (                        ),
  .m04_axi_awuser   ( ddr0_M_AXI_AWUSER      ),
  .m04_axi_awvalid  ( ddr0_M_AXI_AWVALID     ),
  .m04_axi_wdata    ( ddr0_M_AXI_WDATA       ),
  .m04_axi_wstrb    ( ddr0_M_AXI_WSTRB       ),
  .m04_axi_wlast    ( ddr0_M_AXI_WLAST       ),
  .m04_axi_wuser    ( ddr0_M_AXI_WUSER       ),
  .m04_axi_wvalid   ( ddr0_M_AXI_WVALID      ),
  .m04_axi_bready   ( ddr0_M_AXI_BREADY      ),
  .m04_axi_arid     ( ddr0_M_AXI_ARID_virt   ),
  .m04_axi_araddr   ( ddr0_M_AXI_ARADDR      ),
  .m04_axi_arlen    ( ddr0_M_AXI_ARLEN       ),
  .m04_axi_arsize   ( ddr0_M_AXI_ARSIZE      ),
  .m04_axi_arburst  ( ddr0_M_AXI_ARBURST     ),
  .m04_axi_arlock   ( ddr0_M_AXI_ARLOCK      ),
  .m04_axi_arcache  ( ddr0_M_AXI_ARCACHE     ),
  .m04_axi_arprot   ( ddr0_M_AXI_ARPROT      ),
  .m04_axi_arqos    ( ddr0_M_AXI_ARQOS       ),
  .m04_axi_arregion (                        ),
  .m04_axi_aruser   ( ddr0_M_AXI_ARUSER      ),
  .m04_axi_arvalid  ( ddr0_M_AXI_ARVALID     ),
  .m04_axi_rready   ( ddr0_M_AXI_RREADY      )
);
// 替换结束

npu_top u_npu_top(
  .clk                    ( clk                 ),
  .rst_n                  ( rst_n               ),

  .axi4_clk               ( axi4_clk            ),
  .axi4_rst_n             ( axi4_rst_n          ),

  .apb4_pclk              ( apb4_pclk           ),
  .apb4_presetn           ( apb4_presetn        ),
  .apb4_paddr             ( apb4_paddr          ),
  .apb4_psel              ( apb4_psel           ),
  .apb4_penable           ( apb4_penable        ),
  .apb4_pwrite            ( apb4_pwrite         ),
  .apb4_pwdata            ( apb4_pwdata         ),
  .apb4_pstrb             ( apb4_pstrb          ),
  .apb4_pprot             ( apb4_pprot          ),
  .apb4_pready            ( apb4_pready         ),
  .apb4_prdata            ( apb4_prdata         ),
  .apb4_pslverr           ( apb4_pslverr        ),

  .cluster_0_dma_0_M_AXI_ARREADY    ( cluster_0_dma_0_M_AXI_ARREADY ),
  .cluster_0_dma_0_M_AXI_RID        ( cluster_0_dma_0_M_AXI_RID     ),
  .cluster_0_dma_0_M_AXI_RDATA      ( cluster_0_dma_0_M_AXI_RDATA   ),
  .cluster_0_dma_0_M_AXI_RRESP      ( cluster_0_dma_0_M_AXI_RRESP   ),
  .cluster_0_dma_0_M_AXI_RLAST      ( cluster_0_dma_0_M_AXI_RLAST   ),
  .cluster_0_dma_0_M_AXI_RUSER      ( cluster_0_dma_0_M_AXI_RUSER   ),
  .cluster_0_dma_0_M_AXI_RVALID     ( cluster_0_dma_0_M_AXI_RVALID  ),
  .cluster_0_dma_0_M_AXI_AWREADY    ( cluster_0_dma_0_M_AXI_AWREADY ),
  .cluster_0_dma_0_M_AXI_WREADY     ( cluster_0_dma_0_M_AXI_WREADY  ),
  .cluster_0_dma_0_M_AXI_BID        ( cluster_0_dma_0_M_AXI_BID     ),
  .cluster_0_dma_0_M_AXI_BRESP      ( cluster_0_dma_0_M_AXI_BRESP   ),
  .cluster_0_dma_0_M_AXI_BUSER      ( cluster_0_dma_0_M_AXI_BUSER   ),
  .cluster_0_dma_0_M_AXI_BVALID     ( cluster_0_dma_0_M_AXI_BVALID  ),
  .cluster_0_dma_0_M_AXI_ARID       ( cluster_0_dma_0_M_AXI_ARID    ),
  .cluster_0_dma_0_M_AXI_ARADDR     ( cluster_0_dma_0_M_AXI_ARADDR  ),
  .cluster_0_dma_0_M_AXI_ARLEN      ( cluster_0_dma_0_M_AXI_ARLEN   ),
  .cluster_0_dma_0_M_AXI_ARSIZE     ( cluster_0_dma_0_M_AXI_ARSIZE  ),
  .cluster_0_dma_0_M_AXI_ARBURST    ( cluster_0_dma_0_M_AXI_ARBURST ),
  .cluster_0_dma_0_M_AXI_ARLOCK     ( cluster_0_dma_0_M_AXI_ARLOCK  ),
  .cluster_0_dma_0_M_AXI_ARCACHE    ( cluster_0_dma_0_M_AXI_ARCACHE ),
  .cluster_0_dma_0_M_AXI_ARPROT     ( cluster_0_dma_0_M_AXI_ARPROT  ),
  .cluster_0_dma_0_M_AXI_ARQOS      ( cluster_0_dma_0_M_AXI_ARQOS   ),
  .cluster_0_dma_0_M_AXI_ARUSER     ( cluster_0_dma_0_M_AXI_ARUSER  ),
  .cluster_0_dma_0_M_AXI_ARVALID    ( cluster_0_dma_0_M_AXI_ARVALID ),
  .cluster_0_dma_0_M_AXI_RREADY     ( cluster_0_dma_0_M_AXI_RREADY  ),
  .cluster_0_dma_0_M_AXI_AWID       ( cluster_0_dma_0_M_AXI_AWID    ),
  .cluster_0_dma_0_M_AXI_AWADDR     ( cluster_0_dma_0_M_AXI_AWADDR  ),
  .cluster_0_dma_0_M_AXI_AWLEN      ( cluster_0_dma_0_M_AXI_AWLEN   ),
  .cluster_0_dma_0_M_AXI_AWSIZE     ( cluster_0_dma_0_M_AXI_AWSIZE  ),
  .cluster_0_dma_0_M_AXI_AWBURST    ( cluster_0_dma_0_M_AXI_AWBURST ),
  .cluster_0_dma_0_M_AXI_AWLOCK     ( cluster_0_dma_0_M_AXI_AWLOCK  ),
  .cluster_0_dma_0_M_AXI_AWCACHE    ( cluster_0_dma_0_M_AXI_AWCACHE ),
  .cluster_0_dma_0_M_AXI_AWPROT     ( cluster_0_dma_0_M_AXI_AWPROT  ),
  .cluster_0_dma_0_M_AXI_AWQOS      ( cluster_0_dma_0_M_AXI_AWQOS   ),
  .cluster_0_dma_0_M_AXI_AWUSER     ( cluster_0_dma_0_M_AXI_AWUSER  ),
  .cluster_0_dma_0_M_AXI_AWVALID    ( cluster_0_dma_0_M_AXI_AWVALID ),
  .cluster_0_dma_0_M_AXI_WDATA      ( cluster_0_dma_0_M_AXI_WDATA   ),
  .cluster_0_dma_0_M_AXI_WSTRB      ( cluster_0_dma_0_M_AXI_WSTRB   ),
  .cluster_0_dma_0_M_AXI_WLAST      ( cluster_0_dma_0_M_AXI_WLAST   ),
  .cluster_0_dma_0_M_AXI_WUSER      ( cluster_0_dma_0_M_AXI_WUSER   ),
  .cluster_0_dma_0_M_AXI_WVALID     ( cluster_0_dma_0_M_AXI_WVALID  ),
  .cluster_0_dma_0_M_AXI_BREADY     ( cluster_0_dma_0_M_AXI_BREADY  ),

  .cluster_1_dma_0_M_AXI_ARREADY    ( cluster_1_dma_0_M_AXI_ARREADY ),
  .cluster_1_dma_0_M_AXI_RID        ( cluster_1_dma_0_M_AXI_RID     ),
  .cluster_1_dma_0_M_AXI_RDATA      ( cluster_1_dma_0_M_AXI_RDATA   ),
  .cluster_1_dma_0_M_AXI_RRESP      ( cluster_1_dma_0_M_AXI_RRESP   ),
  .cluster_1_dma_0_M_AXI_RLAST      ( cluster_1_dma_0_M_AXI_RLAST   ),
  .cluster_1_dma_0_M_AXI_RUSER      ( cluster_1_dma_0_M_AXI_RUSER   ),
  .cluster_1_dma_0_M_AXI_RVALID     ( cluster_1_dma_0_M_AXI_RVALID  ),
  .cluster_1_dma_0_M_AXI_AWREADY    ( cluster_1_dma_0_M_AXI_AWREADY ),
  .cluster_1_dma_0_M_AXI_WREADY     ( cluster_1_dma_0_M_AXI_WREADY  ),
  .cluster_1_dma_0_M_AXI_BID        ( cluster_1_dma_0_M_AXI_BID     ),
  .cluster_1_dma_0_M_AXI_BRESP      ( cluster_1_dma_0_M_AXI_BRESP   ),
  .cluster_1_dma_0_M_AXI_BUSER      ( cluster_1_dma_0_M_AXI_BUSER   ),
  .cluster_1_dma_0_M_AXI_BVALID     ( cluster_1_dma_0_M_AXI_BVALID  ),
  .cluster_1_dma_0_M_AXI_ARID       ( cluster_1_dma_0_M_AXI_ARID    ),
  .cluster_1_dma_0_M_AXI_ARADDR     ( cluster_1_dma_0_M_AXI_ARADDR  ),
  .cluster_1_dma_0_M_AXI_ARLEN      ( cluster_1_dma_0_M_AXI_ARLEN   ),
  .cluster_1_dma_0_M_AXI_ARSIZE     ( cluster_1_dma_0_M_AXI_ARSIZE  ),
  .cluster_1_dma_0_M_AXI_ARBURST    ( cluster_1_dma_0_M_AXI_ARBURST ),
  .cluster_1_dma_0_M_AXI_ARLOCK     ( cluster_1_dma_0_M_AXI_ARLOCK  ),
  .cluster_1_dma_0_M_AXI_ARCACHE    ( cluster_1_dma_0_M_AXI_ARCACHE ),
  .cluster_1_dma_0_M_AXI_ARPROT     ( cluster_1_dma_0_M_AXI_ARPROT  ),
  .cluster_1_dma_0_M_AXI_ARQOS      ( cluster_1_dma_0_M_AXI_ARQOS   ),
  .cluster_1_dma_0_M_AXI_ARUSER     ( cluster_1_dma_0_M_AXI_ARUSER  ),
  .cluster_1_dma_0_M_AXI_ARVALID    ( cluster_1_dma_0_M_AXI_ARVALID ),
  .cluster_1_dma_0_M_AXI_RREADY     ( cluster_1_dma_0_M_AXI_RREADY  ),
  .cluster_1_dma_0_M_AXI_AWID       ( cluster_1_dma_0_M_AXI_AWID    ),
  .cluster_1_dma_0_M_AXI_AWADDR     ( cluster_1_dma_0_M_AXI_AWADDR  ),
  .cluster_1_dma_0_M_AXI_AWLEN      ( cluster_1_dma_0_M_AXI_AWLEN   ),
  .cluster_1_dma_0_M_AXI_AWSIZE     ( cluster_1_dma_0_M_AXI_AWSIZE  ),
  .cluster_1_dma_0_M_AXI_AWBURST    ( cluster_1_dma_0_M_AXI_AWBURST ),
  .cluster_1_dma_0_M_AXI_AWLOCK     ( cluster_1_dma_0_M_AXI_AWLOCK  ),
  .cluster_1_dma_0_M_AXI_AWCACHE    ( cluster_1_dma_0_M_AXI_AWCACHE ),
  .cluster_1_dma_0_M_AXI_AWPROT     ( cluster_1_dma_0_M_AXI_AWPROT  ),
  .cluster_1_dma_0_M_AXI_AWQOS      ( cluster_1_dma_0_M_AXI_AWQOS   ),
  .cluster_1_dma_0_M_AXI_AWUSER     ( cluster_1_dma_0_M_AXI_AWUSER  ),
  .cluster_1_dma_0_M_AXI_AWVALID    ( cluster_1_dma_0_M_AXI_AWVALID ),
  .cluster_1_dma_0_M_AXI_WDATA      ( cluster_1_dma_0_M_AXI_WDATA   ),
  .cluster_1_dma_0_M_AXI_WSTRB      ( cluster_1_dma_0_M_AXI_WSTRB   ),
  .cluster_1_dma_0_M_AXI_WLAST      ( cluster_1_dma_0_M_AXI_WLAST   ),
  .cluster_1_dma_0_M_AXI_WUSER      ( cluster_1_dma_0_M_AXI_WUSER   ),
  .cluster_1_dma_0_M_AXI_WVALID     ( cluster_1_dma_0_M_AXI_WVALID  ),
  .cluster_1_dma_0_M_AXI_BREADY     ( cluster_1_dma_0_M_AXI_BREADY  ),

  .cluster_2_dma_0_M_AXI_ARREADY    ( cluster_2_dma_0_M_AXI_ARREADY ),
  .cluster_2_dma_0_M_AXI_RID        ( cluster_2_dma_0_M_AXI_RID     ),
  .cluster_2_dma_0_M_AXI_RDATA      ( cluster_2_dma_0_M_AXI_RDATA   ),
  .cluster_2_dma_0_M_AXI_RRESP      ( cluster_2_dma_0_M_AXI_RRESP   ),
  .cluster_2_dma_0_M_AXI_RLAST      ( cluster_2_dma_0_M_AXI_RLAST   ),
  .cluster_2_dma_0_M_AXI_RUSER      ( cluster_2_dma_0_M_AXI_RUSER   ),
  .cluster_2_dma_0_M_AXI_RVALID     ( cluster_2_dma_0_M_AXI_RVALID  ),
  .cluster_2_dma_0_M_AXI_AWREADY    ( cluster_2_dma_0_M_AXI_AWREADY ),
  .cluster_2_dma_0_M_AXI_WREADY     ( cluster_2_dma_0_M_AXI_WREADY  ),
  .cluster_2_dma_0_M_AXI_BID        ( cluster_2_dma_0_M_AXI_BID     ),
  .cluster_2_dma_0_M_AXI_BRESP      ( cluster_2_dma_0_M_AXI_BRESP   ),
  .cluster_2_dma_0_M_AXI_BUSER      ( cluster_2_dma_0_M_AXI_BUSER   ),
  .cluster_2_dma_0_M_AXI_BVALID     ( cluster_2_dma_0_M_AXI_BVALID  ),
  .cluster_2_dma_0_M_AXI_ARID       ( cluster_2_dma_0_M_AXI_ARID    ),
  .cluster_2_dma_0_M_AXI_ARADDR     ( cluster_2_dma_0_M_AXI_ARADDR  ),
  .cluster_2_dma_0_M_AXI_ARLEN      ( cluster_2_dma_0_M_AXI_ARLEN   ),
  .cluster_2_dma_0_M_AXI_ARSIZE     ( cluster_2_dma_0_M_AXI_ARSIZE  ),
  .cluster_2_dma_0_M_AXI_ARBURST    ( cluster_2_dma_0_M_AXI_ARBURST ),
  .cluster_2_dma_0_M_AXI_ARLOCK     ( cluster_2_dma_0_M_AXI_ARLOCK  ),
  .cluster_2_dma_0_M_AXI_ARCACHE    ( cluster_2_dma_0_M_AXI_ARCACHE ),
  .cluster_2_dma_0_M_AXI_ARPROT     ( cluster_2_dma_0_M_AXI_ARPROT  ),
  .cluster_2_dma_0_M_AXI_ARQOS      ( cluster_2_dma_0_M_AXI_ARQOS   ),
  .cluster_2_dma_0_M_AXI_ARUSER     ( cluster_2_dma_0_M_AXI_ARUSER  ),
  .cluster_2_dma_0_M_AXI_ARVALID    ( cluster_2_dma_0_M_AXI_ARVALID ),
  .cluster_2_dma_0_M_AXI_RREADY     ( cluster_2_dma_0_M_AXI_RREADY  ),
  .cluster_2_dma_0_M_AXI_AWID       ( cluster_2_dma_0_M_AXI_AWID    ),
  .cluster_2_dma_0_M_AXI_AWADDR     ( cluster_2_dma_0_M_AXI_AWADDR  ),
  .cluster_2_dma_0_M_AXI_AWLEN      ( cluster_2_dma_0_M_AXI_AWLEN   ),
  .cluster_2_dma_0_M_AXI_AWSIZE     ( cluster_2_dma_0_M_AXI_AWSIZE  ),
  .cluster_2_dma_0_M_AXI_AWBURST    ( cluster_2_dma_0_M_AXI_AWBURST ),
  .cluster_2_dma_0_M_AXI_AWLOCK     ( cluster_2_dma_0_M_AXI_AWLOCK  ),
  .cluster_2_dma_0_M_AXI_AWCACHE    ( cluster_2_dma_0_M_AXI_AWCACHE ),
  .cluster_2_dma_0_M_AXI_AWPROT     ( cluster_2_dma_0_M_AXI_AWPROT  ),
  .cluster_2_dma_0_M_AXI_AWQOS      ( cluster_2_dma_0_M_AXI_AWQOS   ),
  .cluster_2_dma_0_M_AXI_AWUSER     ( cluster_2_dma_0_M_AXI_AWUSER  ),
  .cluster_2_dma_0_M_AXI_AWVALID    ( cluster_2_dma_0_M_AXI_AWVALID ),
  .cluster_2_dma_0_M_AXI_WDATA      ( cluster_2_dma_0_M_AXI_WDATA   ),
  .cluster_2_dma_0_M_AXI_WSTRB      ( cluster_2_dma_0_M_AXI_WSTRB   ),
  .cluster_2_dma_0_M_AXI_WLAST      ( cluster_2_dma_0_M_AXI_WLAST   ),
  .cluster_2_dma_0_M_AXI_WUSER      ( cluster_2_dma_0_M_AXI_WUSER   ),
  .cluster_2_dma_0_M_AXI_WVALID     ( cluster_2_dma_0_M_AXI_WVALID  ),
  .cluster_2_dma_0_M_AXI_BREADY     ( cluster_2_dma_0_M_AXI_BREADY  ),

  .cluster_3_dma_0_M_AXI_ARREADY    ( cluster_3_dma_0_M_AXI_ARREADY ),
  .cluster_3_dma_0_M_AXI_RID        ( cluster_3_dma_0_M_AXI_RID     ),
  .cluster_3_dma_0_M_AXI_RDATA      ( cluster_3_dma_0_M_AXI_RDATA   ),
  .cluster_3_dma_0_M_AXI_RRESP      ( cluster_3_dma_0_M_AXI_RRESP   ),
  .cluster_3_dma_0_M_AXI_RLAST      ( cluster_3_dma_0_M_AXI_RLAST   ),
  .cluster_3_dma_0_M_AXI_RUSER      ( cluster_3_dma_0_M_AXI_RUSER   ),
  .cluster_3_dma_0_M_AXI_RVALID     ( cluster_3_dma_0_M_AXI_RVALID  ),
  .cluster_3_dma_0_M_AXI_AWREADY    ( cluster_3_dma_0_M_AXI_AWREADY ),
  .cluster_3_dma_0_M_AXI_WREADY     ( cluster_3_dma_0_M_AXI_WREADY  ),
  .cluster_3_dma_0_M_AXI_BID        ( cluster_3_dma_0_M_AXI_BID     ),
  .cluster_3_dma_0_M_AXI_BRESP      ( cluster_3_dma_0_M_AXI_BRESP   ),
  .cluster_3_dma_0_M_AXI_BUSER      ( cluster_3_dma_0_M_AXI_BUSER   ),
  .cluster_3_dma_0_M_AXI_BVALID     ( cluster_3_dma_0_M_AXI_BVALID  ),
  .cluster_3_dma_0_M_AXI_ARID       ( cluster_3_dma_0_M_AXI_ARID    ),
  .cluster_3_dma_0_M_AXI_ARADDR     ( cluster_3_dma_0_M_AXI_ARADDR  ),
  .cluster_3_dma_0_M_AXI_ARLEN      ( cluster_3_dma_0_M_AXI_ARLEN   ),
  .cluster_3_dma_0_M_AXI_ARSIZE     ( cluster_3_dma_0_M_AXI_ARSIZE  ),
  .cluster_3_dma_0_M_AXI_ARBURST    ( cluster_3_dma_0_M_AXI_ARBURST ),
  .cluster_3_dma_0_M_AXI_ARLOCK     ( cluster_3_dma_0_M_AXI_ARLOCK  ),
  .cluster_3_dma_0_M_AXI_ARCACHE    ( cluster_3_dma_0_M_AXI_ARCACHE ),
  .cluster_3_dma_0_M_AXI_ARPROT     ( cluster_3_dma_0_M_AXI_ARPROT  ),
  .cluster_3_dma_0_M_AXI_ARQOS      ( cluster_3_dma_0_M_AXI_ARQOS   ),
  .cluster_3_dma_0_M_AXI_ARUSER     ( cluster_3_dma_0_M_AXI_ARUSER  ),
  .cluster_3_dma_0_M_AXI_ARVALID    ( cluster_3_dma_0_M_AXI_ARVALID ),
  .cluster_3_dma_0_M_AXI_RREADY     ( cluster_3_dma_0_M_AXI_RREADY  ),
  .cluster_3_dma_0_M_AXI_AWID       ( cluster_3_dma_0_M_AXI_AWID    ),
  .cluster_3_dma_0_M_AXI_AWADDR     ( cluster_3_dma_0_M_AXI_AWADDR  ),
  .cluster_3_dma_0_M_AXI_AWLEN      ( cluster_3_dma_0_M_AXI_AWLEN   ),
  .cluster_3_dma_0_M_AXI_AWSIZE     ( cluster_3_dma_0_M_AXI_AWSIZE  ),
  .cluster_3_dma_0_M_AXI_AWBURST    ( cluster_3_dma_0_M_AXI_AWBURST ),
  .cluster_3_dma_0_M_AXI_AWLOCK     ( cluster_3_dma_0_M_AXI_AWLOCK  ),
  .cluster_3_dma_0_M_AXI_AWCACHE    ( cluster_3_dma_0_M_AXI_AWCACHE ),
  .cluster_3_dma_0_M_AXI_AWPROT     ( cluster_3_dma_0_M_AXI_AWPROT  ),
  .cluster_3_dma_0_M_AXI_AWQOS      ( cluster_3_dma_0_M_AXI_AWQOS   ),
  .cluster_3_dma_0_M_AXI_AWUSER     ( cluster_3_dma_0_M_AXI_AWUSER  ),
  .cluster_3_dma_0_M_AXI_AWVALID    ( cluster_3_dma_0_M_AXI_AWVALID ),
  .cluster_3_dma_0_M_AXI_WDATA      ( cluster_3_dma_0_M_AXI_WDATA   ),
  .cluster_3_dma_0_M_AXI_WSTRB      ( cluster_3_dma_0_M_AXI_WSTRB   ),
  .cluster_3_dma_0_M_AXI_WLAST      ( cluster_3_dma_0_M_AXI_WLAST   ),
  .cluster_3_dma_0_M_AXI_WUSER      ( cluster_3_dma_0_M_AXI_WUSER   ),
  .cluster_3_dma_0_M_AXI_WVALID     ( cluster_3_dma_0_M_AXI_WVALID  ),
  .cluster_3_dma_0_M_AXI_BREADY     ( cluster_3_dma_0_M_AXI_BREADY  ),

  .cluster_0_dma_1_M_AXI_ARREADY    ( cluster_0_dma_1_M_AXI_ARREADY ),
  .cluster_0_dma_1_M_AXI_RID        ( cluster_0_dma_1_M_AXI_RID     ),
  .cluster_0_dma_1_M_AXI_RDATA      ( cluster_0_dma_1_M_AXI_RDATA   ),
  .cluster_0_dma_1_M_AXI_RRESP      ( cluster_0_dma_1_M_AXI_RRESP   ),
  .cluster_0_dma_1_M_AXI_RLAST      ( cluster_0_dma_1_M_AXI_RLAST   ),
  .cluster_0_dma_1_M_AXI_RUSER      ( cluster_0_dma_1_M_AXI_RUSER   ),
  .cluster_0_dma_1_M_AXI_RVALID     ( cluster_0_dma_1_M_AXI_RVALID  ),
  .cluster_0_dma_1_M_AXI_AWREADY    ( cluster_0_dma_1_M_AXI_AWREADY ),
  .cluster_0_dma_1_M_AXI_WREADY     ( cluster_0_dma_1_M_AXI_WREADY  ),
  .cluster_0_dma_1_M_AXI_BID        ( cluster_0_dma_1_M_AXI_BID     ),
  .cluster_0_dma_1_M_AXI_BRESP      ( cluster_0_dma_1_M_AXI_BRESP   ),
  .cluster_0_dma_1_M_AXI_BUSER      ( cluster_0_dma_1_M_AXI_BUSER   ),
  .cluster_0_dma_1_M_AXI_BVALID     ( cluster_0_dma_1_M_AXI_BVALID  ),
  .cluster_0_dma_1_M_AXI_ARID       ( cluster_0_dma_1_M_AXI_ARID    ),
  .cluster_0_dma_1_M_AXI_ARADDR     ( cluster_0_dma_1_M_AXI_ARADDR  ),
  .cluster_0_dma_1_M_AXI_ARLEN      ( cluster_0_dma_1_M_AXI_ARLEN   ),
  .cluster_0_dma_1_M_AXI_ARSIZE     ( cluster_0_dma_1_M_AXI_ARSIZE  ),
  .cluster_0_dma_1_M_AXI_ARBURST    ( cluster_0_dma_1_M_AXI_ARBURST ),
  .cluster_0_dma_1_M_AXI_ARLOCK     ( cluster_0_dma_1_M_AXI_ARLOCK  ),
  .cluster_0_dma_1_M_AXI_ARCACHE    ( cluster_0_dma_1_M_AXI_ARCACHE ),
  .cluster_0_dma_1_M_AXI_ARPROT     ( cluster_0_dma_1_M_AXI_ARPROT  ),
  .cluster_0_dma_1_M_AXI_ARQOS      ( cluster_0_dma_1_M_AXI_ARQOS   ),
  .cluster_0_dma_1_M_AXI_ARUSER     ( cluster_0_dma_1_M_AXI_ARUSER  ),
  .cluster_0_dma_1_M_AXI_ARVALID    ( cluster_0_dma_1_M_AXI_ARVALID ),
  .cluster_0_dma_1_M_AXI_RREADY     ( cluster_0_dma_1_M_AXI_RREADY  ),
  .cluster_0_dma_1_M_AXI_AWID       ( cluster_0_dma_1_M_AXI_AWID    ),
  .cluster_0_dma_1_M_AXI_AWADDR     ( cluster_0_dma_1_M_AXI_AWADDR  ),
  .cluster_0_dma_1_M_AXI_AWLEN      ( cluster_0_dma_1_M_AXI_AWLEN   ),
  .cluster_0_dma_1_M_AXI_AWSIZE     ( cluster_0_dma_1_M_AXI_AWSIZE  ),
  .cluster_0_dma_1_M_AXI_AWBURST    ( cluster_0_dma_1_M_AXI_AWBURST ),
  .cluster_0_dma_1_M_AXI_AWLOCK     ( cluster_0_dma_1_M_AXI_AWLOCK  ),
  .cluster_0_dma_1_M_AXI_AWCACHE    ( cluster_0_dma_1_M_AXI_AWCACHE ),
  .cluster_0_dma_1_M_AXI_AWPROT     ( cluster_0_dma_1_M_AXI_AWPROT  ),
  .cluster_0_dma_1_M_AXI_AWQOS      ( cluster_0_dma_1_M_AXI_AWQOS   ),
  .cluster_0_dma_1_M_AXI_AWUSER     ( cluster_0_dma_1_M_AXI_AWUSER  ),
  .cluster_0_dma_1_M_AXI_AWVALID    ( cluster_0_dma_1_M_AXI_AWVALID ),
  .cluster_0_dma_1_M_AXI_WDATA      ( cluster_0_dma_1_M_AXI_WDATA   ),
  .cluster_0_dma_1_M_AXI_WSTRB      ( cluster_0_dma_1_M_AXI_WSTRB   ),
  .cluster_0_dma_1_M_AXI_WLAST      ( cluster_0_dma_1_M_AXI_WLAST   ),
  .cluster_0_dma_1_M_AXI_WUSER      ( cluster_0_dma_1_M_AXI_WUSER   ),
  .cluster_0_dma_1_M_AXI_WVALID     ( cluster_0_dma_1_M_AXI_WVALID  ),
  .cluster_0_dma_1_M_AXI_BREADY     ( cluster_0_dma_1_M_AXI_BREADY  ),

  .cluster_1_dma_1_M_AXI_ARREADY    ( cluster_1_dma_1_M_AXI_ARREADY ),
  .cluster_1_dma_1_M_AXI_RID        ( cluster_1_dma_1_M_AXI_RID     ),
  .cluster_1_dma_1_M_AXI_RDATA      ( cluster_1_dma_1_M_AXI_RDATA   ),
  .cluster_1_dma_1_M_AXI_RRESP      ( cluster_1_dma_1_M_AXI_RRESP   ),
  .cluster_1_dma_1_M_AXI_RLAST      ( cluster_1_dma_1_M_AXI_RLAST   ),
  .cluster_1_dma_1_M_AXI_RUSER      ( cluster_1_dma_1_M_AXI_RUSER   ),
  .cluster_1_dma_1_M_AXI_RVALID     ( cluster_1_dma_1_M_AXI_RVALID  ),
  .cluster_1_dma_1_M_AXI_AWREADY    ( cluster_1_dma_1_M_AXI_AWREADY ),
  .cluster_1_dma_1_M_AXI_WREADY     ( cluster_1_dma_1_M_AXI_WREADY  ),
  .cluster_1_dma_1_M_AXI_BID        ( cluster_1_dma_1_M_AXI_BID     ),
  .cluster_1_dma_1_M_AXI_BRESP      ( cluster_1_dma_1_M_AXI_BRESP   ),
  .cluster_1_dma_1_M_AXI_BUSER      ( cluster_1_dma_1_M_AXI_BUSER   ),
  .cluster_1_dma_1_M_AXI_BVALID     ( cluster_1_dma_1_M_AXI_BVALID  ),
  .cluster_1_dma_1_M_AXI_ARID       ( cluster_1_dma_1_M_AXI_ARID    ),
  .cluster_1_dma_1_M_AXI_ARADDR     ( cluster_1_dma_1_M_AXI_ARADDR  ),
  .cluster_1_dma_1_M_AXI_ARLEN      ( cluster_1_dma_1_M_AXI_ARLEN   ),
  .cluster_1_dma_1_M_AXI_ARSIZE     ( cluster_1_dma_1_M_AXI_ARSIZE  ),
  .cluster_1_dma_1_M_AXI_ARBURST    ( cluster_1_dma_1_M_AXI_ARBURST ),
  .cluster_1_dma_1_M_AXI_ARLOCK     ( cluster_1_dma_1_M_AXI_ARLOCK  ),
  .cluster_1_dma_1_M_AXI_ARCACHE    ( cluster_1_dma_1_M_AXI_ARCACHE ),
  .cluster_1_dma_1_M_AXI_ARPROT     ( cluster_1_dma_1_M_AXI_ARPROT  ),
  .cluster_1_dma_1_M_AXI_ARQOS      ( cluster_1_dma_1_M_AXI_ARQOS   ),
  .cluster_1_dma_1_M_AXI_ARUSER     ( cluster_1_dma_1_M_AXI_ARUSER  ),
  .cluster_1_dma_1_M_AXI_ARVALID    ( cluster_1_dma_1_M_AXI_ARVALID ),
  .cluster_1_dma_1_M_AXI_RREADY     ( cluster_1_dma_1_M_AXI_RREADY  ),
  .cluster_1_dma_1_M_AXI_AWID       ( cluster_1_dma_1_M_AXI_AWID    ),
  .cluster_1_dma_1_M_AXI_AWADDR     ( cluster_1_dma_1_M_AXI_AWADDR  ),
  .cluster_1_dma_1_M_AXI_AWLEN      ( cluster_1_dma_1_M_AXI_AWLEN   ),
  .cluster_1_dma_1_M_AXI_AWSIZE     ( cluster_1_dma_1_M_AXI_AWSIZE  ),
  .cluster_1_dma_1_M_AXI_AWBURST    ( cluster_1_dma_1_M_AXI_AWBURST ),
  .cluster_1_dma_1_M_AXI_AWLOCK     ( cluster_1_dma_1_M_AXI_AWLOCK  ),
  .cluster_1_dma_1_M_AXI_AWCACHE    ( cluster_1_dma_1_M_AXI_AWCACHE ),
  .cluster_1_dma_1_M_AXI_AWPROT     ( cluster_1_dma_1_M_AXI_AWPROT  ),
  .cluster_1_dma_1_M_AXI_AWQOS      ( cluster_1_dma_1_M_AXI_AWQOS   ),
  .cluster_1_dma_1_M_AXI_AWUSER     ( cluster_1_dma_1_M_AXI_AWUSER  ),
  .cluster_1_dma_1_M_AXI_AWVALID    ( cluster_1_dma_1_M_AXI_AWVALID ),
  .cluster_1_dma_1_M_AXI_WDATA      ( cluster_1_dma_1_M_AXI_WDATA   ),
  .cluster_1_dma_1_M_AXI_WSTRB      ( cluster_1_dma_1_M_AXI_WSTRB   ),
  .cluster_1_dma_1_M_AXI_WLAST      ( cluster_1_dma_1_M_AXI_WLAST   ),
  .cluster_1_dma_1_M_AXI_WUSER      ( cluster_1_dma_1_M_AXI_WUSER   ),
  .cluster_1_dma_1_M_AXI_WVALID     ( cluster_1_dma_1_M_AXI_WVALID  ),
  .cluster_1_dma_1_M_AXI_BREADY     ( cluster_1_dma_1_M_AXI_BREADY  ),

  .cluster_2_dma_1_M_AXI_ARREADY    ( cluster_2_dma_1_M_AXI_ARREADY ),
  .cluster_2_dma_1_M_AXI_RID        ( cluster_2_dma_1_M_AXI_RID     ),
  .cluster_2_dma_1_M_AXI_RDATA      ( cluster_2_dma_1_M_AXI_RDATA   ),
  .cluster_2_dma_1_M_AXI_RRESP      ( cluster_2_dma_1_M_AXI_RRESP   ),
  .cluster_2_dma_1_M_AXI_RLAST      ( cluster_2_dma_1_M_AXI_RLAST   ),
  .cluster_2_dma_1_M_AXI_RUSER      ( cluster_2_dma_1_M_AXI_RUSER   ),
  .cluster_2_dma_1_M_AXI_RVALID     ( cluster_2_dma_1_M_AXI_RVALID  ),
  .cluster_2_dma_1_M_AXI_AWREADY    ( cluster_2_dma_1_M_AXI_AWREADY ),
  .cluster_2_dma_1_M_AXI_WREADY     ( cluster_2_dma_1_M_AXI_WREADY  ),
  .cluster_2_dma_1_M_AXI_BID        ( cluster_2_dma_1_M_AXI_BID     ),
  .cluster_2_dma_1_M_AXI_BRESP      ( cluster_2_dma_1_M_AXI_BRESP   ),
  .cluster_2_dma_1_M_AXI_BUSER      ( cluster_2_dma_1_M_AXI_BUSER   ),
  .cluster_2_dma_1_M_AXI_BVALID     ( cluster_2_dma_1_M_AXI_BVALID  ),
  .cluster_2_dma_1_M_AXI_ARID       ( cluster_2_dma_1_M_AXI_ARID    ),
  .cluster_2_dma_1_M_AXI_ARADDR     ( cluster_2_dma_1_M_AXI_ARADDR  ),
  .cluster_2_dma_1_M_AXI_ARLEN      ( cluster_2_dma_1_M_AXI_ARLEN   ),
  .cluster_2_dma_1_M_AXI_ARSIZE     ( cluster_2_dma_1_M_AXI_ARSIZE  ),
  .cluster_2_dma_1_M_AXI_ARBURST    ( cluster_2_dma_1_M_AXI_ARBURST ),
  .cluster_2_dma_1_M_AXI_ARLOCK     ( cluster_2_dma_1_M_AXI_ARLOCK  ),
  .cluster_2_dma_1_M_AXI_ARCACHE    ( cluster_2_dma_1_M_AXI_ARCACHE ),
  .cluster_2_dma_1_M_AXI_ARPROT     ( cluster_2_dma_1_M_AXI_ARPROT  ),
  .cluster_2_dma_1_M_AXI_ARQOS      ( cluster_2_dma_1_M_AXI_ARQOS   ),
  .cluster_2_dma_1_M_AXI_ARUSER     ( cluster_2_dma_1_M_AXI_ARUSER  ),
  .cluster_2_dma_1_M_AXI_ARVALID    ( cluster_2_dma_1_M_AXI_ARVALID ),
  .cluster_2_dma_1_M_AXI_RREADY     ( cluster_2_dma_1_M_AXI_RREADY  ),
  .cluster_2_dma_1_M_AXI_AWID       ( cluster_2_dma_1_M_AXI_AWID    ),
  .cluster_2_dma_1_M_AXI_AWADDR     ( cluster_2_dma_1_M_AXI_AWADDR  ),
  .cluster_2_dma_1_M_AXI_AWLEN      ( cluster_2_dma_1_M_AXI_AWLEN   ),
  .cluster_2_dma_1_M_AXI_AWSIZE     ( cluster_2_dma_1_M_AXI_AWSIZE  ),
  .cluster_2_dma_1_M_AXI_AWBURST    ( cluster_2_dma_1_M_AXI_AWBURST ),
  .cluster_2_dma_1_M_AXI_AWLOCK     ( cluster_2_dma_1_M_AXI_AWLOCK  ),
  .cluster_2_dma_1_M_AXI_AWCACHE    ( cluster_2_dma_1_M_AXI_AWCACHE ),
  .cluster_2_dma_1_M_AXI_AWPROT     ( cluster_2_dma_1_M_AXI_AWPROT  ),
  .cluster_2_dma_1_M_AXI_AWQOS      ( cluster_2_dma_1_M_AXI_AWQOS   ),
  .cluster_2_dma_1_M_AXI_AWUSER     ( cluster_2_dma_1_M_AXI_AWUSER  ),
  .cluster_2_dma_1_M_AXI_AWVALID    ( cluster_2_dma_1_M_AXI_AWVALID ),
  .cluster_2_dma_1_M_AXI_WDATA      ( cluster_2_dma_1_M_AXI_WDATA   ),
  .cluster_2_dma_1_M_AXI_WSTRB      ( cluster_2_dma_1_M_AXI_WSTRB   ),
  .cluster_2_dma_1_M_AXI_WLAST      ( cluster_2_dma_1_M_AXI_WLAST   ),
  .cluster_2_dma_1_M_AXI_WUSER      ( cluster_2_dma_1_M_AXI_WUSER   ),
  .cluster_2_dma_1_M_AXI_WVALID     ( cluster_2_dma_1_M_AXI_WVALID  ),
  .cluster_2_dma_1_M_AXI_BREADY     ( cluster_2_dma_1_M_AXI_BREADY  ),

  .cluster_3_dma_1_M_AXI_ARREADY    ( cluster_3_dma_1_M_AXI_ARREADY ),
  .cluster_3_dma_1_M_AXI_RID        ( cluster_3_dma_1_M_AXI_RID     ),
  .cluster_3_dma_1_M_AXI_RDATA      ( cluster_3_dma_1_M_AXI_RDATA   ),
  .cluster_3_dma_1_M_AXI_RRESP      ( cluster_3_dma_1_M_AXI_RRESP   ),
  .cluster_3_dma_1_M_AXI_RLAST      ( cluster_3_dma_1_M_AXI_RLAST   ),
  .cluster_3_dma_1_M_AXI_RUSER      ( cluster_3_dma_1_M_AXI_RUSER   ),
  .cluster_3_dma_1_M_AXI_RVALID     ( cluster_3_dma_1_M_AXI_RVALID  ),
  .cluster_3_dma_1_M_AXI_AWREADY    ( cluster_3_dma_1_M_AXI_AWREADY ),
  .cluster_3_dma_1_M_AXI_WREADY     ( cluster_3_dma_1_M_AXI_WREADY  ),
  .cluster_3_dma_1_M_AXI_BID        ( cluster_3_dma_1_M_AXI_BID     ),
  .cluster_3_dma_1_M_AXI_BRESP      ( cluster_3_dma_1_M_AXI_BRESP   ),
  .cluster_3_dma_1_M_AXI_BUSER      ( cluster_3_dma_1_M_AXI_BUSER   ),
  .cluster_3_dma_1_M_AXI_BVALID     ( cluster_3_dma_1_M_AXI_BVALID  ),
  .cluster_3_dma_1_M_AXI_ARID       ( cluster_3_dma_1_M_AXI_ARID    ),
  .cluster_3_dma_1_M_AXI_ARADDR     ( cluster_3_dma_1_M_AXI_ARADDR  ),
  .cluster_3_dma_1_M_AXI_ARLEN      ( cluster_3_dma_1_M_AXI_ARLEN   ),
  .cluster_3_dma_1_M_AXI_ARSIZE     ( cluster_3_dma_1_M_AXI_ARSIZE  ),
  .cluster_3_dma_1_M_AXI_ARBURST    ( cluster_3_dma_1_M_AXI_ARBURST ),
  .cluster_3_dma_1_M_AXI_ARLOCK     ( cluster_3_dma_1_M_AXI_ARLOCK  ),
  .cluster_3_dma_1_M_AXI_ARCACHE    ( cluster_3_dma_1_M_AXI_ARCACHE ),
  .cluster_3_dma_1_M_AXI_ARPROT     ( cluster_3_dma_1_M_AXI_ARPROT  ),
  .cluster_3_dma_1_M_AXI_ARQOS      ( cluster_3_dma_1_M_AXI_ARQOS   ),
  .cluster_3_dma_1_M_AXI_ARUSER     ( cluster_3_dma_1_M_AXI_ARUSER  ),
  .cluster_3_dma_1_M_AXI_ARVALID    ( cluster_3_dma_1_M_AXI_ARVALID ),
  .cluster_3_dma_1_M_AXI_RREADY     ( cluster_3_dma_1_M_AXI_RREADY  ),
  .cluster_3_dma_1_M_AXI_AWID       ( cluster_3_dma_1_M_AXI_AWID    ),
  .cluster_3_dma_1_M_AXI_AWADDR     ( cluster_3_dma_1_M_AXI_AWADDR  ),
  .cluster_3_dma_1_M_AXI_AWLEN      ( cluster_3_dma_1_M_AXI_AWLEN   ),
  .cluster_3_dma_1_M_AXI_AWSIZE     ( cluster_3_dma_1_M_AXI_AWSIZE  ),
  .cluster_3_dma_1_M_AXI_AWBURST    ( cluster_3_dma_1_M_AXI_AWBURST ),
  .cluster_3_dma_1_M_AXI_AWLOCK     ( cluster_3_dma_1_M_AXI_AWLOCK  ),
  .cluster_3_dma_1_M_AXI_AWCACHE    ( cluster_3_dma_1_M_AXI_AWCACHE ),
  .cluster_3_dma_1_M_AXI_AWPROT     ( cluster_3_dma_1_M_AXI_AWPROT  ),
  .cluster_3_dma_1_M_AXI_AWQOS      ( cluster_3_dma_1_M_AXI_AWQOS   ),
  .cluster_3_dma_1_M_AXI_AWUSER     ( cluster_3_dma_1_M_AXI_AWUSER  ),
  .cluster_3_dma_1_M_AXI_AWVALID    ( cluster_3_dma_1_M_AXI_AWVALID ),
  .cluster_3_dma_1_M_AXI_WDATA      ( cluster_3_dma_1_M_AXI_WDATA   ),
  .cluster_3_dma_1_M_AXI_WSTRB      ( cluster_3_dma_1_M_AXI_WSTRB   ),
  .cluster_3_dma_1_M_AXI_WLAST      ( cluster_3_dma_1_M_AXI_WLAST   ),
  .cluster_3_dma_1_M_AXI_WUSER      ( cluster_3_dma_1_M_AXI_WUSER   ),
  .cluster_3_dma_1_M_AXI_WVALID     ( cluster_3_dma_1_M_AXI_WVALID  ),
  .cluster_3_dma_1_M_AXI_BREADY     ( cluster_3_dma_1_M_AXI_BREADY  ),

  .insn_M_AXI_ARREADY     ( insn_M_AXI_ARREADY  ),
  .insn_M_AXI_RID         ( insn_M_AXI_RID      ),
  .insn_M_AXI_RDATA       ( insn_M_AXI_RDATA    ),
  .insn_M_AXI_RRESP       ( insn_M_AXI_RRESP    ),
  .insn_M_AXI_RLAST       ( insn_M_AXI_RLAST    ),
  .insn_M_AXI_RUSER       ( insn_M_AXI_RUSER    ),
  .insn_M_AXI_RVALID      ( insn_M_AXI_RVALID   ),
  .insn_M_AXI_AWREADY     ( insn_M_AXI_AWREADY  ),
  .insn_M_AXI_WREADY      ( insn_M_AXI_WREADY   ),
  .insn_M_AXI_BID         ( insn_M_AXI_BID      ),
  .insn_M_AXI_BRESP       ( insn_M_AXI_BRESP    ),
  .insn_M_AXI_BUSER       ( insn_M_AXI_BUSER    ),
  .insn_M_AXI_BVALID      ( insn_M_AXI_BVALID   ),
  .insn_M_AXI_ARID        ( insn_M_AXI_ARID     ),
  .insn_M_AXI_ARADDR      ( insn_M_AXI_ARADDR   ),
  .insn_M_AXI_ARLEN       ( insn_M_AXI_ARLEN    ),
  .insn_M_AXI_ARSIZE      ( insn_M_AXI_ARSIZE   ),
  .insn_M_AXI_ARBURST     ( insn_M_AXI_ARBURST  ),
  .insn_M_AXI_ARLOCK      ( insn_M_AXI_ARLOCK   ),
  .insn_M_AXI_ARCACHE     ( insn_M_AXI_ARCACHE  ),
  .insn_M_AXI_ARPROT      ( insn_M_AXI_ARPROT   ),
  .insn_M_AXI_ARQOS       ( insn_M_AXI_ARQOS    ),
  .insn_M_AXI_ARUSER      ( insn_M_AXI_ARUSER   ),
  .insn_M_AXI_ARVALID     ( insn_M_AXI_ARVALID  ),
  .insn_M_AXI_RREADY      ( insn_M_AXI_RREADY   ),
  .insn_M_AXI_AWID        ( insn_M_AXI_AWID     ),
  .insn_M_AXI_AWADDR      ( insn_M_AXI_AWADDR   ),
  .insn_M_AXI_AWLEN       ( insn_M_AXI_AWLEN    ),
  .insn_M_AXI_AWSIZE      ( insn_M_AXI_AWSIZE   ),
  .insn_M_AXI_AWBURST     ( insn_M_AXI_AWBURST  ),
  .insn_M_AXI_AWLOCK      ( insn_M_AXI_AWLOCK   ),
  .insn_M_AXI_AWCACHE     ( insn_M_AXI_AWCACHE  ),
  .insn_M_AXI_AWPROT      ( insn_M_AXI_AWPROT   ),
  .insn_M_AXI_AWQOS       ( insn_M_AXI_AWQOS    ),
  .insn_M_AXI_AWUSER      ( insn_M_AXI_AWUSER   ),
  .insn_M_AXI_AWVALID     ( insn_M_AXI_AWVALID  ),
  .insn_M_AXI_WDATA       ( insn_M_AXI_WDATA    ),
  .insn_M_AXI_WSTRB       ( insn_M_AXI_WSTRB    ),
  .insn_M_AXI_WLAST       ( insn_M_AXI_WLAST    ),
  .insn_M_AXI_WUSER       ( insn_M_AXI_WUSER    ),
  .insn_M_AXI_WVALID      ( insn_M_AXI_WVALID   ),
  .insn_M_AXI_BREADY      ( insn_M_AXI_BREADY   ),

  .axi_S_AXI_ARID         ( npu_S_AXI_ARID      ),
  .axi_S_AXI_ARADDR       ( npu_S_AXI_ARADDR    ),
  .axi_S_AXI_ARLEN        ( npu_S_AXI_ARLEN     ),
  .axi_S_AXI_ARSIZE       ( npu_S_AXI_ARSIZE    ),
  .axi_S_AXI_ARBURST      ( npu_S_AXI_ARBURST   ),
  .axi_S_AXI_ARLOCK       ( npu_S_AXI_ARLOCK    ),
  .axi_S_AXI_ARCACHE      ( npu_S_AXI_ARCACHE   ),
  .axi_S_AXI_ARPROT       ( npu_S_AXI_ARPROT    ),
  .axi_S_AXI_ARQOS        ( npu_S_AXI_ARQOS     ),
  .axi_S_AXI_ARUSER       ( npu_S_AXI_ARUSER    ),
  .axi_S_AXI_ARVALID      ( npu_S_AXI_ARVALID   ),
  .axi_S_AXI_RREADY       ( npu_S_AXI_RREADY    ),
  .axi_S_AXI_AWID         ( npu_S_AXI_AWID      ),
  .axi_S_AXI_AWADDR       ( npu_S_AXI_AWADDR    ),
  .axi_S_AXI_AWLEN        ( npu_S_AXI_AWLEN     ),
  .axi_S_AXI_AWSIZE       ( npu_S_AXI_AWSIZE    ),
  .axi_S_AXI_AWBURST      ( npu_S_AXI_AWBURST   ),
  .axi_S_AXI_AWLOCK       ( npu_S_AXI_AWLOCK    ),
  .axi_S_AXI_AWCACHE      ( npu_S_AXI_AWCACHE   ),
  .axi_S_AXI_AWPROT       ( npu_S_AXI_AWPROT    ),
  .axi_S_AXI_AWQOS        ( npu_S_AXI_AWQOS     ),
  .axi_S_AXI_AWUSER       ( npu_S_AXI_AWUSER    ),
  .axi_S_AXI_AWVALID      ( npu_S_AXI_AWVALID   ),
  .axi_S_AXI_WDATA        ( npu_S_AXI_WDATA     ),
  .axi_S_AXI_WSTRB        ( npu_S_AXI_WSTRB     ),
  .axi_S_AXI_WLAST        ( npu_S_AXI_WLAST     ),
  .axi_S_AXI_WUSER        ( npu_S_AXI_WUSER     ),
  .axi_S_AXI_WVALID       ( npu_S_AXI_WVALID    ),
  .axi_S_AXI_BREADY       ( npu_S_AXI_BREADY    ),
  .axi_S_AXI_ARREADY      ( npu_S_AXI_ARREADY   ),
  .axi_S_AXI_RID          ( npu_S_AXI_RID       ),
  .axi_S_AXI_RDATA        ( npu_S_AXI_RDATA     ),
  .axi_S_AXI_RRESP        ( npu_S_AXI_RRESP     ),
  .axi_S_AXI_RLAST        ( npu_S_AXI_RLAST     ),
  .axi_S_AXI_RUSER        ( npu_S_AXI_RUSER     ),
  .axi_S_AXI_RVALID       ( npu_S_AXI_RVALID    ),
  .axi_S_AXI_AWREADY      ( npu_S_AXI_AWREADY   ),
  .axi_S_AXI_WREADY       ( npu_S_AXI_WREADY    ),
  .axi_S_AXI_BID          ( npu_S_AXI_BID       ),
  .axi_S_AXI_BRESP        ( npu_S_AXI_BRESP     ),
  .axi_S_AXI_BUSER        ( npu_S_AXI_BUSER     ),
  .axi_S_AXI_BVALID       ( npu_S_AXI_BVALID    ),

  .pcie_clk               ( pcie_clk              ),
  .pcie_rst_n             ( pcie_rst_n            ),
  .pcie_ven_msi_func_num  ( pcie_ven_msi_func_num ),
  .pcie_ven_msi_tc        ( pcie_ven_msi_tc       ),
  .pcie_ven_msi_req       ( pcie_ven_msi_req      ),
  .pcie_ven_msi_vector    ( pcie_ven_msi_vector   ),
  .pcie_msi_grant         ( pcie_msi_grant        ),
  .pcie_highaddr          ( pcie_highaddr         ),
  .mcu_highaddr           ( mcu_highaddr          ),
  .mcu_clk                ( mcu_clk               ),
  .mcu_rst_n              ( mcu_rst_n             )
);

pcie_axi_convertor u_pcie_araddr_cvt(
  .mode_sel    ( mode_sel                      ),
  .highaddr    ( pcie_highaddr                 ),
  .in_address  ( serdes0_M_AXI_ARADDR          ),
  .out_address ( pcie_routed_axi_araddr        )
);

pcie_axi_convertor u_pcie_awaddr_cvt(
  .mode_sel    ( mode_sel                    ),
  .highaddr    ( pcie_highaddr               ),
  .in_address  ( serdes0_M_AXI_AWADDR        ),
  .out_address ( pcie_routed_axi_awaddr      )
);

mcu_axi_convertor u_mcu_araddr_cvt(
  .highaddr    ( mcu_highaddr          ),
  .in_address  ( mcu_M_AXI_ARADDR      ),
  .out_address ( mcu_routed_axi_araddr )
);

mcu_axi_convertor u_mcu_awaddr_cvt(
  .highaddr    ( mcu_highaddr          ),
  .in_address  ( mcu_M_AXI_AWADDR      ),
  .out_address ( mcu_routed_axi_awaddr )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 Crossbar                                                 */
/* -------------------------------------------------------------------------------------------------------- */

parameter CR0_DATA_WIDTH         = AXI_M_AXI_DATA_WIDTH;
parameter CR0_ADDR_WIDTH         = AXI_M_AXI_ADDR_WIDTH;
parameter CR0_STRB_WIDTH         = (DATA_WIDTH/8);
parameter CR0_S_ID_WIDTH         = 20;
parameter CR0_M_ID_WIDTH         = 22;
parameter CR0_AWUSER_ENABLE      = 0;
parameter CR0_AWUSER_WIDTH       = 1;
parameter CR0_WUSER_ENABLE       = 0;
parameter CR0_WUSER_WIDTH        = 1;
parameter CR0_BUSER_ENABLE       = 0;
parameter CR0_BUSER_WIDTH        = 1;
parameter CR0_ARUSER_ENABLE      = 0;
parameter CR0_ARUSER_WIDTH       = 1;
parameter CR0_RUSER_ENABLE       = 0;
parameter CR0_RUSER_WIDTH        = 1;
parameter CR0_S00_THREADS        = 4;
parameter CR0_S00_ACCEPT         = 8;
parameter CR0_S01_THREADS        = 4;
parameter CR0_S01_ACCEPT         = 8;
parameter CR0_S02_THREADS        = 4;
parameter CR0_S02_ACCEPT         = 8;
parameter CR0_S03_THREADS        = 4;
parameter CR0_S03_ACCEPT         = 8;
parameter CR0_S04_THREADS        = 4;
parameter CR0_S04_ACCEPT         = 8;
parameter CR0_M_REGIONS          = 1;
parameter CR0_M00_BASE_ADDR      = 0;
parameter CR0_M00_ADDR_WIDTH     = {M_REGIONS{64'd64}};
parameter CR0_M00_CONNECT_READ   = 4'b1111;
parameter CR0_M00_CONNECT_WRITE  = 4'b1111;
parameter CR0_M00_ISSUE          = 4;
parameter CR0_M00_SECURE         = 0;
parameter CR0_S00_AW_REG_TYPE    = 0;
parameter CR0_S00_W_REG_TYPE     = 0;
parameter CR0_S00_B_REG_TYPE     = 1;
parameter CR0_S00_AR_REG_TYPE    = 0;
parameter CR0_S00_R_REG_TYPE     = 2;
parameter CR0_S01_AW_REG_TYPE    = 0;
parameter CR0_S01_W_REG_TYPE     = 0;
parameter CR0_S01_B_REG_TYPE     = 1;
parameter CR0_S01_AR_REG_TYPE    = 0;
parameter CR0_S01_R_REG_TYPE     = 2;
parameter CR0_S02_AW_REG_TYPE    = 0;
parameter CR0_S02_W_REG_TYPE     = 0;
parameter CR0_S02_B_REG_TYPE     = 1;
parameter CR0_S02_AR_REG_TYPE    = 0;
parameter CR0_S02_R_REG_TYPE     = 2;
parameter CR0_S03_AW_REG_TYPE    = 0;
parameter CR0_S03_W_REG_TYPE     = 0;
parameter CR0_S03_B_REG_TYPE     = 1;
parameter CR0_S03_AR_REG_TYPE    = 0;
parameter CR0_S03_R_REG_TYPE     = 2;
parameter CR0_S04_AW_REG_TYPE    = 0;
parameter CR0_S04_W_REG_TYPE     = 0;
parameter CR0_S04_B_REG_TYPE     = 1;
parameter CR0_S04_AR_REG_TYPE    = 0;
parameter CR0_S04_R_REG_TYPE     = 2;
parameter CR0_M00_AW_REG_TYPE    = 1;
parameter CR0_M00_W_REG_TYPE     = 2;
parameter CR0_M00_B_REG_TYPE     = 0;
parameter CR0_M00_AR_REG_TYPE    = 1;
parameter CR0_M00_R_REG_TYPE     = 0;

wire [21:0] dma_0_M_AXI_ARID_virt;
wire [21:0] dma_0_M_AXI_AWID_virt;
wire [21:0] dma_0_M_AXI_RID_virt;
wire [21:0] dma_0_M_AXI_BID_virt;

wire [21:0] dma_1_M_AXI_ARID_virt;
wire [21:0] dma_1_M_AXI_AWID_virt;
wire [21:0] dma_1_M_AXI_RID_virt;
wire [21:0] dma_1_M_AXI_BID_virt;

axi_id_convertor #(
  .IN_ID_WIDTH  ( 22 ),
  .OUT_ID_WIDTH ( 20 )
) u_dma_0_id_convertor(
  .clk       ( axi4_clk              ),
  .rst_n     ( axi4_rst_n            ),
  .arvalid   ( dma_0_M_AXI_ARVALID   ),
  .arready   ( dma_0_M_AXI_ARREADY   ),
  .arid      ( dma_0_M_AXI_ARID_virt ),
  .virt_arid ( dma_0_M_AXI_ARID      ),
  .awvalid   ( dma_0_M_AXI_AWVALID   ),
  .awready   ( dma_0_M_AXI_AWREADY   ),
  .awid      ( dma_0_M_AXI_AWID_virt ),
  .virt_awid ( dma_0_M_AXI_AWID      ),
  .rvalid    ( dma_0_M_AXI_RVALID    ),
  .rready    ( dma_0_M_AXI_RREADY    ),
  .rid       ( dma_0_M_AXI_RID_virt  ),
  .virt_rid  ( dma_0_M_AXI_RID       ),
  .bvalid    ( dma_0_M_AXI_BVALID    ),
  .bready    ( dma_0_M_AXI_BREADY    ),
  .bid       ( dma_0_M_AXI_BID_virt  ),
  .virt_bid  ( dma_0_M_AXI_BID       )
);

axi_crossbar_wrap_4x1 #(
  .DATA_WIDTH        ( CR0_DATA_WIDTH        ),
  .ADDR_WIDTH        ( CR0_ADDR_WIDTH        ),
  .STRB_WIDTH        ( CR0_STRB_WIDTH        ),
  .S_ID_WIDTH        ( CR0_S_ID_WIDTH        ),
  .M_ID_WIDTH        ( CR0_M_ID_WIDTH        ),
  .AWUSER_ENABLE     ( CR0_AWUSER_ENABLE     ),
  .AWUSER_WIDTH      ( CR0_AWUSER_WIDTH      ),
  .WUSER_ENABLE      ( CR0_WUSER_ENABLE      ),
  .WUSER_WIDTH       ( CR0_WUSER_WIDTH       ),
  .BUSER_ENABLE      ( CR0_BUSER_ENABLE      ),
  .BUSER_WIDTH       ( CR0_BUSER_WIDTH       ),
  .ARUSER_ENABLE     ( CR0_ARUSER_ENABLE     ),
  .ARUSER_WIDTH      ( CR0_ARUSER_WIDTH      ),
  .RUSER_ENABLE      ( CR0_RUSER_ENABLE      ),
  .RUSER_WIDTH       ( CR0_RUSER_WIDTH       ),
  .S00_THREADS       ( CR0_S00_THREADS       ),
  .S00_ACCEPT        ( CR0_S00_ACCEPT        ),
  .S01_THREADS       ( CR0_S01_THREADS       ),
  .S01_ACCEPT        ( CR0_S01_ACCEPT        ),
  .S02_THREADS       ( CR0_S02_THREADS       ),
  .S02_ACCEPT        ( CR0_S02_ACCEPT        ),
  .S03_THREADS       ( CR0_S03_THREADS       ),
  .S03_ACCEPT        ( CR0_S03_ACCEPT        ),
  .M_REGIONS         ( CR0_M_REGIONS         ),
  .M00_BASE_ADDR     ( CR0_M00_BASE_ADDR     ),
  .M00_ADDR_WIDTH    ( CR0_M00_ADDR_WIDTH    ),
  .M00_CONNECT_READ  ( CR0_M00_CONNECT_READ  ),
  .M00_CONNECT_WRITE ( CR0_M00_CONNECT_WRITE ),
  .M00_ISSUE         ( CR0_M00_ISSUE         ),
  .M00_SECURE        ( CR0_M00_SECURE        ),
  .S00_AW_REG_TYPE   ( CR0_S00_AW_REG_TYPE   ),
  .S00_W_REG_TYPE    ( CR0_S00_W_REG_TYPE    ),
  .S00_B_REG_TYPE    ( CR0_S00_B_REG_TYPE    ),
  .S00_AR_REG_TYPE   ( CR0_S00_AR_REG_TYPE   ),
  .S00_R_REG_TYPE    ( CR0_S00_R_REG_TYPE    ),
  .S01_AW_REG_TYPE   ( CR0_S01_AW_REG_TYPE   ),
  .S01_W_REG_TYPE    ( CR0_S01_W_REG_TYPE    ),
  .S01_B_REG_TYPE    ( CR0_S01_B_REG_TYPE    ),
  .S01_AR_REG_TYPE   ( CR0_S01_AR_REG_TYPE   ),
  .S01_R_REG_TYPE    ( CR0_S01_R_REG_TYPE    ),
  .S02_AW_REG_TYPE   ( CR0_S02_AW_REG_TYPE   ),
  .S02_W_REG_TYPE    ( CR0_S02_W_REG_TYPE    ),
  .S02_B_REG_TYPE    ( CR0_S02_B_REG_TYPE    ),
  .S02_AR_REG_TYPE   ( CR0_S02_AR_REG_TYPE   ),
  .S02_R_REG_TYPE    ( CR0_S02_R_REG_TYPE    ),
  .S03_AW_REG_TYPE   ( CR0_S03_AW_REG_TYPE   ),
  .S03_W_REG_TYPE    ( CR0_S03_W_REG_TYPE    ),
  .S03_B_REG_TYPE    ( CR0_S03_B_REG_TYPE    ),
  .S03_AR_REG_TYPE   ( CR0_S03_AR_REG_TYPE   ),
  .S03_R_REG_TYPE    ( CR0_S03_R_REG_TYPE    ),
  .M00_AW_REG_TYPE   ( CR0_M00_AW_REG_TYPE   ),
  .M00_W_REG_TYPE    ( CR0_M00_W_REG_TYPE    ),
  .M00_B_REG_TYPE    ( CR0_M00_B_REG_TYPE    ),
  .M00_AR_REG_TYPE   ( CR0_M00_AR_REG_TYPE   ),
  .M00_R_REG_TYPE    ( CR0_M00_R_REG_TYPE    )
) u_axi_crossbar_wrap_4x1_dma_0(
  .clk              ( clk                            ),
  .rst_n            ( rst_n                          ),

  .s00_axi_awid     ( cluster_0_dma_0_M_AXI_AWID     ),
  .s00_axi_awaddr   ( cluster_0_dma_0_M_AXI_AWADDR   ),
  .s00_axi_awlen    ( cluster_0_dma_0_M_AXI_AWLEN    ),
  .s00_axi_awsize   ( cluster_0_dma_0_M_AXI_AWSIZE   ),
  .s00_axi_awburst  ( cluster_0_dma_0_M_AXI_AWBURST  ),
  .s00_axi_awlock   ( cluster_0_dma_0_M_AXI_AWLOCK   ),
  .s00_axi_awcache  ( cluster_0_dma_0_M_AXI_AWCACHE  ),
  .s00_axi_awprot   ( cluster_0_dma_0_M_AXI_AWPROT   ),
  .s00_axi_awqos    ( cluster_0_dma_0_M_AXI_AWQOS    ),
  .s00_axi_awuser   ( cluster_0_dma_0_M_AXI_AWUSER   ),
  .s00_axi_awvalid  ( cluster_0_dma_0_M_AXI_AWVALID  ),
  .s00_axi_wdata    ( cluster_0_dma_0_M_AXI_WDATA    ),
  .s00_axi_wstrb    ( cluster_0_dma_0_M_AXI_WSTRB    ),
  .s00_axi_wlast    ( cluster_0_dma_0_M_AXI_WLAST    ),
  .s00_axi_wuser    ( cluster_0_dma_0_M_AXI_WUSER    ),
  .s00_axi_wvalid   ( cluster_0_dma_0_M_AXI_WVALID   ),
  .s00_axi_bready   ( cluster_0_dma_0_M_AXI_BREADY   ),
  .s00_axi_arid     ( cluster_0_dma_0_M_AXI_ARID     ),
  .s00_axi_araddr   ( cluster_0_dma_0_M_AXI_ARADDR   ),
  .s00_axi_arlen    ( cluster_0_dma_0_M_AXI_ARLEN    ),
  .s00_axi_arsize   ( cluster_0_dma_0_M_AXI_ARSIZE   ),
  .s00_axi_arburst  ( cluster_0_dma_0_M_AXI_ARBURST  ),
  .s00_axi_arlock   ( cluster_0_dma_0_M_AXI_ARLOCK   ),
  .s00_axi_arcache  ( cluster_0_dma_0_M_AXI_ARCACHE  ),
  .s00_axi_arprot   ( cluster_0_dma_0_M_AXI_ARPROT   ),
  .s00_axi_arqos    ( cluster_0_dma_0_M_AXI_ARQOS    ),
  .s00_axi_aruser   ( cluster_0_dma_0_M_AXI_ARUSER   ),
  .s00_axi_arvalid  ( cluster_0_dma_0_M_AXI_ARVALID  ),
  .s00_axi_rready   ( cluster_0_dma_0_M_AXI_RREADY   ),
  .s00_axi_awready  ( cluster_0_dma_0_M_AXI_AWREADY  ),
  .s00_axi_wready   ( cluster_0_dma_0_M_AXI_WREADY   ),
  .s00_axi_bid      ( cluster_0_dma_0_M_AXI_BID      ),
  .s00_axi_bresp    ( cluster_0_dma_0_M_AXI_BRESP    ),
  .s00_axi_buser    ( cluster_0_dma_0_M_AXI_BUSER    ),
  .s00_axi_bvalid   ( cluster_0_dma_0_M_AXI_BVALID   ),
  .s00_axi_arready  ( cluster_0_dma_0_M_AXI_ARREADY  ),
  .s00_axi_rid      ( cluster_0_dma_0_M_AXI_RID      ),
  .s00_axi_rdata    ( cluster_0_dma_0_M_AXI_RDATA    ),
  .s00_axi_rresp    ( cluster_0_dma_0_M_AXI_RRESP    ),
  .s00_axi_rlast    ( cluster_0_dma_0_M_AXI_RLAST    ),
  .s00_axi_ruser    ( cluster_0_dma_0_M_AXI_RUSER    ),
  .s00_axi_rvalid   ( cluster_0_dma_0_M_AXI_RVALID   ),
  
  .s01_axi_awid     ( cluster_1_dma_0_M_AXI_AWID     ),
  .s01_axi_awaddr   ( cluster_1_dma_0_M_AXI_AWADDR   ),
  .s01_axi_awlen    ( cluster_1_dma_0_M_AXI_AWLEN    ),
  .s01_axi_awsize   ( cluster_1_dma_0_M_AXI_AWSIZE   ),
  .s01_axi_awburst  ( cluster_1_dma_0_M_AXI_AWBURST  ),
  .s01_axi_awlock   ( cluster_1_dma_0_M_AXI_AWLOCK   ),
  .s01_axi_awcache  ( cluster_1_dma_0_M_AXI_AWCACHE  ),
  .s01_axi_awprot   ( cluster_1_dma_0_M_AXI_AWPROT   ),
  .s01_axi_awqos    ( cluster_1_dma_0_M_AXI_AWQOS    ),
  .s01_axi_awuser   ( cluster_1_dma_0_M_AXI_AWUSER   ),
  .s01_axi_awvalid  ( cluster_1_dma_0_M_AXI_AWVALID  ),
  .s01_axi_wdata    ( cluster_1_dma_0_M_AXI_WDATA    ),
  .s01_axi_wstrb    ( cluster_1_dma_0_M_AXI_WSTRB    ),
  .s01_axi_wlast    ( cluster_1_dma_0_M_AXI_WLAST    ),
  .s01_axi_wuser    ( cluster_1_dma_0_M_AXI_WUSER    ),
  .s01_axi_wvalid   ( cluster_1_dma_0_M_AXI_WVALID   ),
  .s01_axi_bready   ( cluster_1_dma_0_M_AXI_BREADY   ),
  .s01_axi_arid     ( cluster_1_dma_0_M_AXI_ARID     ),
  .s01_axi_araddr   ( cluster_1_dma_0_M_AXI_ARADDR   ),
  .s01_axi_arlen    ( cluster_1_dma_0_M_AXI_ARLEN    ),
  .s01_axi_arsize   ( cluster_1_dma_0_M_AXI_ARSIZE   ),
  .s01_axi_arburst  ( cluster_1_dma_0_M_AXI_ARBURST  ),
  .s01_axi_arlock   ( cluster_1_dma_0_M_AXI_ARLOCK   ),
  .s01_axi_arcache  ( cluster_1_dma_0_M_AXI_ARCACHE  ),
  .s01_axi_arprot   ( cluster_1_dma_0_M_AXI_ARPROT   ),
  .s01_axi_arqos    ( cluster_1_dma_0_M_AXI_ARQOS    ),
  .s01_axi_aruser   ( cluster_1_dma_0_M_AXI_ARUSER   ),
  .s01_axi_arvalid  ( cluster_1_dma_0_M_AXI_ARVALID  ),
  .s01_axi_rready   ( cluster_1_dma_0_M_AXI_RREADY   ),
  .s01_axi_awready  ( cluster_1_dma_0_M_AXI_AWREADY  ),
  .s01_axi_wready   ( cluster_1_dma_0_M_AXI_WREADY   ),
  .s01_axi_bid      ( cluster_1_dma_0_M_AXI_BID      ),
  .s01_axi_bresp    ( cluster_1_dma_0_M_AXI_BRESP    ),
  .s01_axi_buser    ( cluster_1_dma_0_M_AXI_BUSER    ),
  .s01_axi_bvalid   ( cluster_1_dma_0_M_AXI_BVALID   ),
  .s01_axi_arready  ( cluster_1_dma_0_M_AXI_ARREADY  ),
  .s01_axi_rid      ( cluster_1_dma_0_M_AXI_RID      ),
  .s01_axi_rdata    ( cluster_1_dma_0_M_AXI_RDATA    ),
  .s01_axi_rresp    ( cluster_1_dma_0_M_AXI_RRESP    ),
  .s01_axi_rlast    ( cluster_1_dma_0_M_AXI_RLAST    ),
  .s01_axi_ruser    ( cluster_1_dma_0_M_AXI_RUSER    ),
  .s01_axi_rvalid   ( cluster_1_dma_0_M_AXI_RVALID   ),

  .s02_axi_awid     ( cluster_2_dma_0_M_AXI_AWID     ),
  .s02_axi_awaddr   ( cluster_2_dma_0_M_AXI_AWADDR   ),
  .s02_axi_awlen    ( cluster_2_dma_0_M_AXI_AWLEN    ),
  .s02_axi_awsize   ( cluster_2_dma_0_M_AXI_AWSIZE   ),
  .s02_axi_awburst  ( cluster_2_dma_0_M_AXI_AWBURST  ),
  .s02_axi_awlock   ( cluster_2_dma_0_M_AXI_AWLOCK   ),
  .s02_axi_awcache  ( cluster_2_dma_0_M_AXI_AWCACHE  ),
  .s02_axi_awprot   ( cluster_2_dma_0_M_AXI_AWPROT   ),
  .s02_axi_awqos    ( cluster_2_dma_0_M_AXI_AWQOS    ),
  .s02_axi_awuser   ( cluster_2_dma_0_M_AXI_AWUSER   ),
  .s02_axi_awvalid  ( cluster_2_dma_0_M_AXI_AWVALID  ),
  .s02_axi_wdata    ( cluster_2_dma_0_M_AXI_WDATA    ),
  .s02_axi_wstrb    ( cluster_2_dma_0_M_AXI_WSTRB    ),
  .s02_axi_wlast    ( cluster_2_dma_0_M_AXI_WLAST    ),
  .s02_axi_wuser    ( cluster_2_dma_0_M_AXI_WUSER    ),
  .s02_axi_wvalid   ( cluster_2_dma_0_M_AXI_WVALID   ),
  .s02_axi_bready   ( cluster_2_dma_0_M_AXI_BREADY   ),
  .s02_axi_arid     ( cluster_2_dma_0_M_AXI_ARID     ),
  .s02_axi_araddr   ( cluster_2_dma_0_M_AXI_ARADDR   ),
  .s02_axi_arlen    ( cluster_2_dma_0_M_AXI_ARLEN    ),
  .s02_axi_arsize   ( cluster_2_dma_0_M_AXI_ARSIZE   ),
  .s02_axi_arburst  ( cluster_2_dma_0_M_AXI_ARBURST  ),
  .s02_axi_arlock   ( cluster_2_dma_0_M_AXI_ARLOCK   ),
  .s02_axi_arcache  ( cluster_2_dma_0_M_AXI_ARCACHE  ),
  .s02_axi_arprot   ( cluster_2_dma_0_M_AXI_ARPROT   ),
  .s02_axi_arqos    ( cluster_2_dma_0_M_AXI_ARQOS    ),
  .s02_axi_aruser   ( cluster_2_dma_0_M_AXI_ARUSER   ),
  .s02_axi_arvalid  ( cluster_2_dma_0_M_AXI_ARVALID  ),
  .s02_axi_rready   ( cluster_2_dma_0_M_AXI_RREADY   ),
  .s02_axi_awready  ( cluster_2_dma_0_M_AXI_AWREADY  ),
  .s02_axi_wready   ( cluster_2_dma_0_M_AXI_WREADY   ),
  .s02_axi_bid      ( cluster_2_dma_0_M_AXI_BID      ),
  .s02_axi_bresp    ( cluster_2_dma_0_M_AXI_BRESP    ),
  .s02_axi_buser    ( cluster_2_dma_0_M_AXI_BUSER    ),
  .s02_axi_bvalid   ( cluster_2_dma_0_M_AXI_BVALID   ),
  .s02_axi_arready  ( cluster_2_dma_0_M_AXI_ARREADY  ),
  .s02_axi_rid      ( cluster_2_dma_0_M_AXI_RID      ),
  .s02_axi_rdata    ( cluster_2_dma_0_M_AXI_RDATA    ),
  .s02_axi_rresp    ( cluster_2_dma_0_M_AXI_RRESP    ),
  .s02_axi_rlast    ( cluster_2_dma_0_M_AXI_RLAST    ),
  .s02_axi_ruser    ( cluster_2_dma_0_M_AXI_RUSER    ),
  .s02_axi_rvalid   ( cluster_2_dma_0_M_AXI_RVALID   ),

  .s03_axi_awid     ( cluster_3_dma_0_M_AXI_AWID     ),
  .s03_axi_awaddr   ( cluster_3_dma_0_M_AXI_AWADDR   ),
  .s03_axi_awlen    ( cluster_3_dma_0_M_AXI_AWLEN    ),
  .s03_axi_awsize   ( cluster_3_dma_0_M_AXI_AWSIZE   ),
  .s03_axi_awburst  ( cluster_3_dma_0_M_AXI_AWBURST  ),
  .s03_axi_awlock   ( cluster_3_dma_0_M_AXI_AWLOCK   ),
  .s03_axi_awcache  ( cluster_3_dma_0_M_AXI_AWCACHE  ),
  .s03_axi_awprot   ( cluster_3_dma_0_M_AXI_AWPROT   ),
  .s03_axi_awqos    ( cluster_3_dma_0_M_AXI_AWQOS    ),
  .s03_axi_awuser   ( cluster_3_dma_0_M_AXI_AWUSER   ),
  .s03_axi_awvalid  ( cluster_3_dma_0_M_AXI_AWVALID  ),
  .s03_axi_wdata    ( cluster_3_dma_0_M_AXI_WDATA    ),
  .s03_axi_wstrb    ( cluster_3_dma_0_M_AXI_WSTRB    ),
  .s03_axi_wlast    ( cluster_3_dma_0_M_AXI_WLAST    ),
  .s03_axi_wuser    ( cluster_3_dma_0_M_AXI_WUSER    ),
  .s03_axi_wvalid   ( cluster_3_dma_0_M_AXI_WVALID   ),
  .s03_axi_bready   ( cluster_3_dma_0_M_AXI_BREADY   ),
  .s03_axi_arid     ( cluster_3_dma_0_M_AXI_ARID     ),
  .s03_axi_araddr   ( cluster_3_dma_0_M_AXI_ARADDR   ),
  .s03_axi_arlen    ( cluster_3_dma_0_M_AXI_ARLEN    ),
  .s03_axi_arsize   ( cluster_3_dma_0_M_AXI_ARSIZE   ),
  .s03_axi_arburst  ( cluster_3_dma_0_M_AXI_ARBURST  ),
  .s03_axi_arlock   ( cluster_3_dma_0_M_AXI_ARLOCK   ),
  .s03_axi_arcache  ( cluster_3_dma_0_M_AXI_ARCACHE  ),
  .s03_axi_arprot   ( cluster_3_dma_0_M_AXI_ARPROT   ),
  .s03_axi_arqos    ( cluster_3_dma_0_M_AXI_ARQOS    ),
  .s03_axi_aruser   ( cluster_3_dma_0_M_AXI_ARUSER   ),
  .s03_axi_arvalid  ( cluster_3_dma_0_M_AXI_ARVALID  ),
  .s03_axi_rready   ( cluster_3_dma_0_M_AXI_RREADY   ),
  .s03_axi_awready  ( cluster_3_dma_0_M_AXI_AWREADY  ),
  .s03_axi_wready   ( cluster_3_dma_0_M_AXI_WREADY   ),
  .s03_axi_bid      ( cluster_3_dma_0_M_AXI_BID      ),
  .s03_axi_bresp    ( cluster_3_dma_0_M_AXI_BRESP    ),
  .s03_axi_buser    ( cluster_3_dma_0_M_AXI_BUSER    ),
  .s03_axi_bvalid   ( cluster_3_dma_0_M_AXI_BVALID   ),
  .s03_axi_arready  ( cluster_3_dma_0_M_AXI_ARREADY  ),
  .s03_axi_rid      ( cluster_3_dma_0_M_AXI_RID      ),
  .s03_axi_rdata    ( cluster_3_dma_0_M_AXI_RDATA    ),
  .s03_axi_rresp    ( cluster_3_dma_0_M_AXI_RRESP    ),
  .s03_axi_rlast    ( cluster_3_dma_0_M_AXI_RLAST    ),
  .s03_axi_ruser    ( cluster_3_dma_0_M_AXI_RUSER    ),
  .s03_axi_rvalid   ( cluster_3_dma_0_M_AXI_RVALID   ),

  .m00_axi_awready  ( dma_0_M_AXI_AWREADY        ),
  .m00_axi_wready   ( dma_0_M_AXI_WREADY         ),
  .m00_axi_bid      ( dma_0_M_AXI_BID_virt       ),
  .m00_axi_bresp    ( dma_0_M_AXI_BRESP          ),
  .m00_axi_buser    ( dma_0_M_AXI_BUSER          ),
  .m00_axi_bvalid   ( dma_0_M_AXI_BVALID         ),
  .m00_axi_arready  ( dma_0_M_AXI_ARREADY        ),
  .m00_axi_rid      ( dma_0_M_AXI_RID_virt       ),
  .m00_axi_rdata    ( dma_0_M_AXI_RDATA          ),
  .m00_axi_rresp    ( dma_0_M_AXI_RRESP          ),
  .m00_axi_rlast    ( dma_0_M_AXI_RLAST          ),
  .m00_axi_ruser    ( dma_0_M_AXI_RUSER          ),
  .m00_axi_rvalid   ( dma_0_M_AXI_RVALID         ),
  .m00_axi_awid     ( dma_0_M_AXI_AWID_virt      ),
  .m00_axi_awaddr   ( dma_0_M_AXI_AWADDR         ),
  .m00_axi_awlen    ( dma_0_M_AXI_AWLEN          ),
  .m00_axi_awsize   ( dma_0_M_AXI_AWSIZE         ),
  .m00_axi_awburst  ( dma_0_M_AXI_AWBURST        ),
  .m00_axi_awlock   ( dma_0_M_AXI_AWLOCK         ),
  .m00_axi_awcache  ( dma_0_M_AXI_AWCACHE        ),
  .m00_axi_awprot   ( dma_0_M_AXI_AWPROT         ),
  .m00_axi_awqos    ( dma_0_M_AXI_AWQOS          ),
  .m00_axi_awregion (                            ),
  .m00_axi_awuser   ( dma_0_M_AXI_AWUSER         ),
  .m00_axi_awvalid  ( dma_0_M_AXI_AWVALID        ),
  .m00_axi_wdata    ( dma_0_M_AXI_WDATA          ),
  .m00_axi_wstrb    ( dma_0_M_AXI_WSTRB          ),
  .m00_axi_wlast    ( dma_0_M_AXI_WLAST          ),
  .m00_axi_wuser    ( dma_0_M_AXI_WUSER          ),
  .m00_axi_wvalid   ( dma_0_M_AXI_WVALID         ),
  .m00_axi_bready   ( dma_0_M_AXI_BREADY         ),
  .m00_axi_arid     ( dma_0_M_AXI_ARID_virt      ),
  .m00_axi_araddr   ( dma_0_M_AXI_ARADDR         ),
  .m00_axi_arlen    ( dma_0_M_AXI_ARLEN          ),
  .m00_axi_arsize   ( dma_0_M_AXI_ARSIZE         ),
  .m00_axi_arburst  ( dma_0_M_AXI_ARBURST        ),
  .m00_axi_arlock   ( dma_0_M_AXI_ARLOCK         ),
  .m00_axi_arcache  ( dma_0_M_AXI_ARCACHE        ),
  .m00_axi_arprot   ( dma_0_M_AXI_ARPROT         ),
  .m00_axi_arqos    ( dma_0_M_AXI_ARQOS          ),
  .m00_axi_arregion (                            ),
  .m00_axi_aruser   ( dma_0_M_AXI_ARUSER         ),
  .m00_axi_arvalid  ( dma_0_M_AXI_ARVALID        ),
  .m00_axi_rready   ( dma_0_M_AXI_RREADY         )
);

axi_id_convertor #(
  .IN_ID_WIDTH  ( 22 ),
  .OUT_ID_WIDTH ( 20 )
) u_dma_1_id_convertor(
  .clk       ( axi4_clk            ),
  .rst_n     ( axi4_rst_n          ),
  .arvalid   ( dma_1_M_AXI_ARVALID   ),
  .arready   ( dma_1_M_AXI_ARREADY   ),
  .arid      ( dma_1_M_AXI_ARID_virt ),
  .virt_arid ( dma_1_M_AXI_ARID      ),
  .awvalid   ( dma_1_M_AXI_AWVALID   ),
  .awready   ( dma_1_M_AXI_AWREADY   ),
  .awid      ( dma_1_M_AXI_AWID_virt ),
  .virt_awid ( dma_1_M_AXI_AWID      ),
  .rvalid    ( dma_1_M_AXI_RVALID    ),
  .rready    ( dma_1_M_AXI_RREADY    ),
  .rid       ( dma_1_M_AXI_RID_virt  ),
  .virt_rid  ( dma_1_M_AXI_RID       ),
  .bvalid    ( dma_1_M_AXI_BVALID    ),
  .bready    ( dma_1_M_AXI_BREADY    ),
  .bid       ( dma_1_M_AXI_BID_virt  ),
  .virt_bid  ( dma_1_M_AXI_BID       )
);

axi_crossbar_wrap_4x1 #(
  .DATA_WIDTH        ( CR0_DATA_WIDTH        ),
  .ADDR_WIDTH        ( CR0_ADDR_WIDTH        ),
  .STRB_WIDTH        ( CR0_STRB_WIDTH        ),
  .S_ID_WIDTH        ( CR0_S_ID_WIDTH        ),
  .M_ID_WIDTH        ( CR0_M_ID_WIDTH        ),
  .AWUSER_ENABLE     ( CR0_AWUSER_ENABLE     ),
  .AWUSER_WIDTH      ( CR0_AWUSER_WIDTH      ),
  .WUSER_ENABLE      ( CR0_WUSER_ENABLE      ),
  .WUSER_WIDTH       ( CR0_WUSER_WIDTH       ),
  .BUSER_ENABLE      ( CR0_BUSER_ENABLE      ),
  .BUSER_WIDTH       ( CR0_BUSER_WIDTH       ),
  .ARUSER_ENABLE     ( CR0_ARUSER_ENABLE     ),
  .ARUSER_WIDTH      ( CR0_ARUSER_WIDTH      ),
  .RUSER_ENABLE      ( CR0_RUSER_ENABLE      ),
  .RUSER_WIDTH       ( CR0_RUSER_WIDTH       ),
  .S00_THREADS       ( CR0_S00_THREADS       ),
  .S00_ACCEPT        ( CR0_S00_ACCEPT        ),
  .S01_THREADS       ( CR0_S01_THREADS       ),
  .S01_ACCEPT        ( CR0_S01_ACCEPT        ),
  .S02_THREADS       ( CR0_S02_THREADS       ),
  .S02_ACCEPT        ( CR0_S02_ACCEPT        ),
  .S03_THREADS       ( CR0_S03_THREADS       ),
  .S03_ACCEPT        ( CR0_S03_ACCEPT        ),
  .M_REGIONS         ( CR0_M_REGIONS         ),
  .M00_BASE_ADDR     ( CR0_M00_BASE_ADDR     ),
  .M00_ADDR_WIDTH    ( CR0_M00_ADDR_WIDTH    ),
  .M00_CONNECT_READ  ( CR0_M00_CONNECT_READ  ),
  .M00_CONNECT_WRITE ( CR0_M00_CONNECT_WRITE ),
  .M00_ISSUE         ( CR0_M00_ISSUE         ),
  .M00_SECURE        ( CR0_M00_SECURE        ),
  .S00_AW_REG_TYPE   ( CR0_S00_AW_REG_TYPE   ),
  .S00_W_REG_TYPE    ( CR0_S00_W_REG_TYPE    ),
  .S00_B_REG_TYPE    ( CR0_S00_B_REG_TYPE    ),
  .S00_AR_REG_TYPE   ( CR0_S00_AR_REG_TYPE   ),
  .S00_R_REG_TYPE    ( CR0_S00_R_REG_TYPE    ),
  .S01_AW_REG_TYPE   ( CR0_S01_AW_REG_TYPE   ),
  .S01_W_REG_TYPE    ( CR0_S01_W_REG_TYPE    ),
  .S01_B_REG_TYPE    ( CR0_S01_B_REG_TYPE    ),
  .S01_AR_REG_TYPE   ( CR0_S01_AR_REG_TYPE   ),
  .S01_R_REG_TYPE    ( CR0_S01_R_REG_TYPE    ),
  .S02_AW_REG_TYPE   ( CR0_S02_AW_REG_TYPE   ),
  .S02_W_REG_TYPE    ( CR0_S02_W_REG_TYPE    ),
  .S02_B_REG_TYPE    ( CR0_S02_B_REG_TYPE    ),
  .S02_AR_REG_TYPE   ( CR0_S02_AR_REG_TYPE   ),
  .S02_R_REG_TYPE    ( CR0_S02_R_REG_TYPE    ),
  .S03_AW_REG_TYPE   ( CR0_S03_AW_REG_TYPE   ),
  .S03_W_REG_TYPE    ( CR0_S03_W_REG_TYPE    ),
  .S03_B_REG_TYPE    ( CR0_S03_B_REG_TYPE    ),
  .S03_AR_REG_TYPE   ( CR0_S03_AR_REG_TYPE   ),
  .S03_R_REG_TYPE    ( CR0_S03_R_REG_TYPE    ),
  .M00_AW_REG_TYPE   ( CR0_M00_AW_REG_TYPE   ),
  .M00_W_REG_TYPE    ( CR0_M00_W_REG_TYPE    ),
  .M00_B_REG_TYPE    ( CR0_M00_B_REG_TYPE    ),
  .M00_AR_REG_TYPE   ( CR0_M00_AR_REG_TYPE   ),
  .M00_R_REG_TYPE    ( CR0_M00_R_REG_TYPE    )
) u_axi_crossbar_wrap_4x1_dma_1(
  .clk              ( clk                            ),
  .rst_n            ( rst_n                          ),

  .s00_axi_awid     ( cluster_0_dma_1_M_AXI_AWID     ),
  .s00_axi_awaddr   ( cluster_0_dma_1_M_AXI_AWADDR   ),
  .s00_axi_awlen    ( cluster_0_dma_1_M_AXI_AWLEN    ),
  .s00_axi_awsize   ( cluster_0_dma_1_M_AXI_AWSIZE   ),
  .s00_axi_awburst  ( cluster_0_dma_1_M_AXI_AWBURST  ),
  .s00_axi_awlock   ( cluster_0_dma_1_M_AXI_AWLOCK   ),
  .s00_axi_awcache  ( cluster_0_dma_1_M_AXI_AWCACHE  ),
  .s00_axi_awprot   ( cluster_0_dma_1_M_AXI_AWPROT   ),
  .s00_axi_awqos    ( cluster_0_dma_1_M_AXI_AWQOS    ),
  .s00_axi_awuser   ( cluster_0_dma_1_M_AXI_AWUSER   ),
  .s00_axi_awvalid  ( cluster_0_dma_1_M_AXI_AWVALID  ),
  .s00_axi_wdata    ( cluster_0_dma_1_M_AXI_WDATA    ),
  .s00_axi_wstrb    ( cluster_0_dma_1_M_AXI_WSTRB    ),
  .s00_axi_wlast    ( cluster_0_dma_1_M_AXI_WLAST    ),
  .s00_axi_wuser    ( cluster_0_dma_1_M_AXI_WUSER    ),
  .s00_axi_wvalid   ( cluster_0_dma_1_M_AXI_WVALID   ),
  .s00_axi_bready   ( cluster_0_dma_1_M_AXI_BREADY   ),
  .s00_axi_arid     ( cluster_0_dma_1_M_AXI_ARID     ),
  .s00_axi_araddr   ( cluster_0_dma_1_M_AXI_ARADDR   ),
  .s00_axi_arlen    ( cluster_0_dma_1_M_AXI_ARLEN    ),
  .s00_axi_arsize   ( cluster_0_dma_1_M_AXI_ARSIZE   ),
  .s00_axi_arburst  ( cluster_0_dma_1_M_AXI_ARBURST  ),
  .s00_axi_arlock   ( cluster_0_dma_1_M_AXI_ARLOCK   ),
  .s00_axi_arcache  ( cluster_0_dma_1_M_AXI_ARCACHE  ),
  .s00_axi_arprot   ( cluster_0_dma_1_M_AXI_ARPROT   ),
  .s00_axi_arqos    ( cluster_0_dma_1_M_AXI_ARQOS    ),
  .s00_axi_aruser   ( cluster_0_dma_1_M_AXI_ARUSER   ),
  .s00_axi_arvalid  ( cluster_0_dma_1_M_AXI_ARVALID  ),
  .s00_axi_rready   ( cluster_0_dma_1_M_AXI_RREADY   ),
  .s00_axi_awready  ( cluster_0_dma_1_M_AXI_AWREADY  ),
  .s00_axi_wready   ( cluster_0_dma_1_M_AXI_WREADY   ),
  .s00_axi_bid      ( cluster_0_dma_1_M_AXI_BID      ),
  .s00_axi_bresp    ( cluster_0_dma_1_M_AXI_BRESP    ),
  .s00_axi_buser    ( cluster_0_dma_1_M_AXI_BUSER    ),
  .s00_axi_bvalid   ( cluster_0_dma_1_M_AXI_BVALID   ),
  .s00_axi_arready  ( cluster_0_dma_1_M_AXI_ARREADY  ),
  .s00_axi_rid      ( cluster_0_dma_1_M_AXI_RID      ),
  .s00_axi_rdata    ( cluster_0_dma_1_M_AXI_RDATA    ),
  .s00_axi_rresp    ( cluster_0_dma_1_M_AXI_RRESP    ),
  .s00_axi_rlast    ( cluster_0_dma_1_M_AXI_RLAST    ),
  .s00_axi_ruser    ( cluster_0_dma_1_M_AXI_RUSER    ),
  .s00_axi_rvalid   ( cluster_0_dma_1_M_AXI_RVALID   ),
  
  .s01_axi_awid     ( cluster_1_dma_1_M_AXI_AWID     ),
  .s01_axi_awaddr   ( cluster_1_dma_1_M_AXI_AWADDR   ),
  .s01_axi_awlen    ( cluster_1_dma_1_M_AXI_AWLEN    ),
  .s01_axi_awsize   ( cluster_1_dma_1_M_AXI_AWSIZE   ),
  .s01_axi_awburst  ( cluster_1_dma_1_M_AXI_AWBURST  ),
  .s01_axi_awlock   ( cluster_1_dma_1_M_AXI_AWLOCK   ),
  .s01_axi_awcache  ( cluster_1_dma_1_M_AXI_AWCACHE  ),
  .s01_axi_awprot   ( cluster_1_dma_1_M_AXI_AWPROT   ),
  .s01_axi_awqos    ( cluster_1_dma_1_M_AXI_AWQOS    ),
  .s01_axi_awuser   ( cluster_1_dma_1_M_AXI_AWUSER   ),
  .s01_axi_awvalid  ( cluster_1_dma_1_M_AXI_AWVALID  ),
  .s01_axi_wdata    ( cluster_1_dma_1_M_AXI_WDATA    ),
  .s01_axi_wstrb    ( cluster_1_dma_1_M_AXI_WSTRB    ),
  .s01_axi_wlast    ( cluster_1_dma_1_M_AXI_WLAST    ),
  .s01_axi_wuser    ( cluster_1_dma_1_M_AXI_WUSER    ),
  .s01_axi_wvalid   ( cluster_1_dma_1_M_AXI_WVALID   ),
  .s01_axi_bready   ( cluster_1_dma_1_M_AXI_BREADY   ),
  .s01_axi_arid     ( cluster_1_dma_1_M_AXI_ARID     ),
  .s01_axi_araddr   ( cluster_1_dma_1_M_AXI_ARADDR   ),
  .s01_axi_arlen    ( cluster_1_dma_1_M_AXI_ARLEN    ),
  .s01_axi_arsize   ( cluster_1_dma_1_M_AXI_ARSIZE   ),
  .s01_axi_arburst  ( cluster_1_dma_1_M_AXI_ARBURST  ),
  .s01_axi_arlock   ( cluster_1_dma_1_M_AXI_ARLOCK   ),
  .s01_axi_arcache  ( cluster_1_dma_1_M_AXI_ARCACHE  ),
  .s01_axi_arprot   ( cluster_1_dma_1_M_AXI_ARPROT   ),
  .s01_axi_arqos    ( cluster_1_dma_1_M_AXI_ARQOS    ),
  .s01_axi_aruser   ( cluster_1_dma_1_M_AXI_ARUSER   ),
  .s01_axi_arvalid  ( cluster_1_dma_1_M_AXI_ARVALID  ),
  .s01_axi_rready   ( cluster_1_dma_1_M_AXI_RREADY   ),
  .s01_axi_awready  ( cluster_1_dma_1_M_AXI_AWREADY  ),
  .s01_axi_wready   ( cluster_1_dma_1_M_AXI_WREADY   ),
  .s01_axi_bid      ( cluster_1_dma_1_M_AXI_BID      ),
  .s01_axi_bresp    ( cluster_1_dma_1_M_AXI_BRESP    ),
  .s01_axi_buser    ( cluster_1_dma_1_M_AXI_BUSER    ),
  .s01_axi_bvalid   ( cluster_1_dma_1_M_AXI_BVALID   ),
  .s01_axi_arready  ( cluster_1_dma_1_M_AXI_ARREADY  ),
  .s01_axi_rid      ( cluster_1_dma_1_M_AXI_RID      ),
  .s01_axi_rdata    ( cluster_1_dma_1_M_AXI_RDATA    ),
  .s01_axi_rresp    ( cluster_1_dma_1_M_AXI_RRESP    ),
  .s01_axi_rlast    ( cluster_1_dma_1_M_AXI_RLAST    ),
  .s01_axi_ruser    ( cluster_1_dma_1_M_AXI_RUSER    ),
  .s01_axi_rvalid   ( cluster_1_dma_1_M_AXI_RVALID   ),

  .s02_axi_awid     ( cluster_2_dma_1_M_AXI_AWID     ),
  .s02_axi_awaddr   ( cluster_2_dma_1_M_AXI_AWADDR   ),
  .s02_axi_awlen    ( cluster_2_dma_1_M_AXI_AWLEN    ),
  .s02_axi_awsize   ( cluster_2_dma_1_M_AXI_AWSIZE   ),
  .s02_axi_awburst  ( cluster_2_dma_1_M_AXI_AWBURST  ),
  .s02_axi_awlock   ( cluster_2_dma_1_M_AXI_AWLOCK   ),
  .s02_axi_awcache  ( cluster_2_dma_1_M_AXI_AWCACHE  ),
  .s02_axi_awprot   ( cluster_2_dma_1_M_AXI_AWPROT   ),
  .s02_axi_awqos    ( cluster_2_dma_1_M_AXI_AWQOS    ),
  .s02_axi_awuser   ( cluster_2_dma_1_M_AXI_AWUSER   ),
  .s02_axi_awvalid  ( cluster_2_dma_1_M_AXI_AWVALID  ),
  .s02_axi_wdata    ( cluster_2_dma_1_M_AXI_WDATA    ),
  .s02_axi_wstrb    ( cluster_2_dma_1_M_AXI_WSTRB    ),
  .s02_axi_wlast    ( cluster_2_dma_1_M_AXI_WLAST    ),
  .s02_axi_wuser    ( cluster_2_dma_1_M_AXI_WUSER    ),
  .s02_axi_wvalid   ( cluster_2_dma_1_M_AXI_WVALID   ),
  .s02_axi_bready   ( cluster_2_dma_1_M_AXI_BREADY   ),
  .s02_axi_arid     ( cluster_2_dma_1_M_AXI_ARID     ),
  .s02_axi_araddr   ( cluster_2_dma_1_M_AXI_ARADDR   ),
  .s02_axi_arlen    ( cluster_2_dma_1_M_AXI_ARLEN    ),
  .s02_axi_arsize   ( cluster_2_dma_1_M_AXI_ARSIZE   ),
  .s02_axi_arburst  ( cluster_2_dma_1_M_AXI_ARBURST  ),
  .s02_axi_arlock   ( cluster_2_dma_1_M_AXI_ARLOCK   ),
  .s02_axi_arcache  ( cluster_2_dma_1_M_AXI_ARCACHE  ),
  .s02_axi_arprot   ( cluster_2_dma_1_M_AXI_ARPROT   ),
  .s02_axi_arqos    ( cluster_2_dma_1_M_AXI_ARQOS    ),
  .s02_axi_aruser   ( cluster_2_dma_1_M_AXI_ARUSER   ),
  .s02_axi_arvalid  ( cluster_2_dma_1_M_AXI_ARVALID  ),
  .s02_axi_rready   ( cluster_2_dma_1_M_AXI_RREADY   ),
  .s02_axi_awready  ( cluster_2_dma_1_M_AXI_AWREADY  ),
  .s02_axi_wready   ( cluster_2_dma_1_M_AXI_WREADY   ),
  .s02_axi_bid      ( cluster_2_dma_1_M_AXI_BID      ),
  .s02_axi_bresp    ( cluster_2_dma_1_M_AXI_BRESP    ),
  .s02_axi_buser    ( cluster_2_dma_1_M_AXI_BUSER    ),
  .s02_axi_bvalid   ( cluster_2_dma_1_M_AXI_BVALID   ),
  .s02_axi_arready  ( cluster_2_dma_1_M_AXI_ARREADY  ),
  .s02_axi_rid      ( cluster_2_dma_1_M_AXI_RID      ),
  .s02_axi_rdata    ( cluster_2_dma_1_M_AXI_RDATA    ),
  .s02_axi_rresp    ( cluster_2_dma_1_M_AXI_RRESP    ),
  .s02_axi_rlast    ( cluster_2_dma_1_M_AXI_RLAST    ),
  .s02_axi_ruser    ( cluster_2_dma_1_M_AXI_RUSER    ),
  .s02_axi_rvalid   ( cluster_2_dma_1_M_AXI_RVALID   ),

  .s03_axi_awid     ( cluster_3_dma_1_M_AXI_AWID     ),
  .s03_axi_awaddr   ( cluster_3_dma_1_M_AXI_AWADDR   ),
  .s03_axi_awlen    ( cluster_3_dma_1_M_AXI_AWLEN    ),
  .s03_axi_awsize   ( cluster_3_dma_1_M_AXI_AWSIZE   ),
  .s03_axi_awburst  ( cluster_3_dma_1_M_AXI_AWBURST  ),
  .s03_axi_awlock   ( cluster_3_dma_1_M_AXI_AWLOCK   ),
  .s03_axi_awcache  ( cluster_3_dma_1_M_AXI_AWCACHE  ),
  .s03_axi_awprot   ( cluster_3_dma_1_M_AXI_AWPROT   ),
  .s03_axi_awqos    ( cluster_3_dma_1_M_AXI_AWQOS    ),
  .s03_axi_awuser   ( cluster_3_dma_1_M_AXI_AWUSER   ),
  .s03_axi_awvalid  ( cluster_3_dma_1_M_AXI_AWVALID  ),
  .s03_axi_wdata    ( cluster_3_dma_1_M_AXI_WDATA    ),
  .s03_axi_wstrb    ( cluster_3_dma_1_M_AXI_WSTRB    ),
  .s03_axi_wlast    ( cluster_3_dma_1_M_AXI_WLAST    ),
  .s03_axi_wuser    ( cluster_3_dma_1_M_AXI_WUSER    ),
  .s03_axi_wvalid   ( cluster_3_dma_1_M_AXI_WVALID   ),
  .s03_axi_bready   ( cluster_3_dma_1_M_AXI_BREADY   ),
  .s03_axi_arid     ( cluster_3_dma_1_M_AXI_ARID     ),
  .s03_axi_araddr   ( cluster_3_dma_1_M_AXI_ARADDR   ),
  .s03_axi_arlen    ( cluster_3_dma_1_M_AXI_ARLEN    ),
  .s03_axi_arsize   ( cluster_3_dma_1_M_AXI_ARSIZE   ),
  .s03_axi_arburst  ( cluster_3_dma_1_M_AXI_ARBURST  ),
  .s03_axi_arlock   ( cluster_3_dma_1_M_AXI_ARLOCK   ),
  .s03_axi_arcache  ( cluster_3_dma_1_M_AXI_ARCACHE  ),
  .s03_axi_arprot   ( cluster_3_dma_1_M_AXI_ARPROT   ),
  .s03_axi_arqos    ( cluster_3_dma_1_M_AXI_ARQOS    ),
  .s03_axi_aruser   ( cluster_3_dma_1_M_AXI_ARUSER   ),
  .s03_axi_arvalid  ( cluster_3_dma_1_M_AXI_ARVALID  ),
  .s03_axi_rready   ( cluster_3_dma_1_M_AXI_RREADY   ),
  .s03_axi_awready  ( cluster_3_dma_1_M_AXI_AWREADY  ),
  .s03_axi_wready   ( cluster_3_dma_1_M_AXI_WREADY   ),
  .s03_axi_bid      ( cluster_3_dma_1_M_AXI_BID      ),
  .s03_axi_bresp    ( cluster_3_dma_1_M_AXI_BRESP    ),
  .s03_axi_buser    ( cluster_3_dma_1_M_AXI_BUSER    ),
  .s03_axi_bvalid   ( cluster_3_dma_1_M_AXI_BVALID   ),
  .s03_axi_arready  ( cluster_3_dma_1_M_AXI_ARREADY  ),
  .s03_axi_rid      ( cluster_3_dma_1_M_AXI_RID      ),
  .s03_axi_rdata    ( cluster_3_dma_1_M_AXI_RDATA    ),
  .s03_axi_rresp    ( cluster_3_dma_1_M_AXI_RRESP    ),
  .s03_axi_rlast    ( cluster_3_dma_1_M_AXI_RLAST    ),
  .s03_axi_ruser    ( cluster_3_dma_1_M_AXI_RUSER    ),
  .s03_axi_rvalid   ( cluster_3_dma_1_M_AXI_RVALID   ),

  .m00_axi_awready  ( dma_1_M_AXI_AWREADY        ),
  .m00_axi_wready   ( dma_1_M_AXI_WREADY         ),
  .m00_axi_bid      ( dma_1_M_AXI_BID_virt       ),
  .m00_axi_bresp    ( dma_1_M_AXI_BRESP          ),
  .m00_axi_buser    ( dma_1_M_AXI_BUSER          ),
  .m00_axi_bvalid   ( dma_1_M_AXI_BVALID         ),
  .m00_axi_arready  ( dma_1_M_AXI_ARREADY        ),
  .m00_axi_rid      ( dma_1_M_AXI_RID_virt       ),
  .m00_axi_rdata    ( dma_1_M_AXI_RDATA          ),
  .m00_axi_rresp    ( dma_1_M_AXI_RRESP          ),
  .m00_axi_rlast    ( dma_1_M_AXI_RLAST          ),
  .m00_axi_ruser    ( dma_1_M_AXI_RUSER          ),
  .m00_axi_rvalid   ( dma_1_M_AXI_RVALID         ),
  .m00_axi_awid     ( dma_1_M_AXI_AWID_virt      ),
  .m00_axi_awaddr   ( dma_1_M_AXI_AWADDR         ),
  .m00_axi_awlen    ( dma_1_M_AXI_AWLEN          ),
  .m00_axi_awsize   ( dma_1_M_AXI_AWSIZE         ),
  .m00_axi_awburst  ( dma_1_M_AXI_AWBURST        ),
  .m00_axi_awlock   ( dma_1_M_AXI_AWLOCK         ),
  .m00_axi_awcache  ( dma_1_M_AXI_AWCACHE        ),
  .m00_axi_awprot   ( dma_1_M_AXI_AWPROT         ),
  .m00_axi_awqos    ( dma_1_M_AXI_AWQOS          ),
  .m00_axi_awregion (                            ),
  .m00_axi_awuser   ( dma_1_M_AXI_AWUSER         ),
  .m00_axi_awvalid  ( dma_1_M_AXI_AWVALID        ),
  .m00_axi_wdata    ( dma_1_M_AXI_WDATA          ),
  .m00_axi_wstrb    ( dma_1_M_AXI_WSTRB          ),
  .m00_axi_wlast    ( dma_1_M_AXI_WLAST          ),
  .m00_axi_wuser    ( dma_1_M_AXI_WUSER          ),
  .m00_axi_wvalid   ( dma_1_M_AXI_WVALID         ),
  .m00_axi_bready   ( dma_1_M_AXI_BREADY         ),
  .m00_axi_arid     ( dma_1_M_AXI_ARID_virt      ),
  .m00_axi_araddr   ( dma_1_M_AXI_ARADDR         ),
  .m00_axi_arlen    ( dma_1_M_AXI_ARLEN          ),
  .m00_axi_arsize   ( dma_1_M_AXI_ARSIZE         ),
  .m00_axi_arburst  ( dma_1_M_AXI_ARBURST        ),
  .m00_axi_arlock   ( dma_1_M_AXI_ARLOCK         ),
  .m00_axi_arcache  ( dma_1_M_AXI_ARCACHE        ),
  .m00_axi_arprot   ( dma_1_M_AXI_ARPROT         ),
  .m00_axi_arqos    ( dma_1_M_AXI_ARQOS          ),
  .m00_axi_arregion (                            ),
  .m00_axi_aruser   ( dma_1_M_AXI_ARUSER         ),
  .m00_axi_arvalid  ( dma_1_M_AXI_ARVALID        ),
  .m00_axi_rready   ( dma_1_M_AXI_RREADY         )
);

endmodule