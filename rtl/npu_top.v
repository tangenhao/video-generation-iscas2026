module npu_top(
  axi4_clk, axi4_rst_n, 

  axi_S_AXI_ARID, axi_S_AXI_ARADDR, axi_S_AXI_ARLEN, 
  axi_S_AXI_ARSIZE, axi_S_AXI_ARBURST, axi_S_AXI_ARLOCK, axi_S_AXI_ARCACHE, axi_S_AXI_ARPROT, axi_S_AXI_ARQOS, axi_S_AXI_ARUSER, 
  axi_S_AXI_ARVALID, axi_S_AXI_ARREADY,
  axi_S_AXI_RID, axi_S_AXI_RDATA, axi_S_AXI_RRESP, axi_S_AXI_RLAST, axi_S_AXI_RUSER, axi_S_AXI_RVALID, axi_S_AXI_RREADY,

  axi_S_AXI_AWID, axi_S_AXI_AWADDR, axi_S_AXI_AWLEN,
  axi_S_AXI_AWSIZE, axi_S_AXI_AWBURST, axi_S_AXI_AWLOCK, axi_S_AXI_AWCACHE, axi_S_AXI_AWPROT, axi_S_AXI_AWQOS, axi_S_AXI_AWUSER,
  axi_S_AXI_AWVALID, axi_S_AXI_AWREADY,
  axi_S_AXI_WDATA, axi_S_AXI_WSTRB, axi_S_AXI_WLAST, axi_S_AXI_WUSER, axi_S_AXI_WVALID, axi_S_AXI_WREADY,
  axi_S_AXI_BID, axi_S_AXI_BRESP, axi_S_AXI_BUSER, axi_S_AXI_BVALID, axi_S_AXI_BREADY, 

  cluster_0_dma_0_M_AXI_ARID, cluster_0_dma_0_M_AXI_ARADDR, cluster_0_dma_0_M_AXI_ARLEN, 
  cluster_0_dma_0_M_AXI_ARSIZE, cluster_0_dma_0_M_AXI_ARBURST, cluster_0_dma_0_M_AXI_ARLOCK, cluster_0_dma_0_M_AXI_ARCACHE, cluster_0_dma_0_M_AXI_ARPROT, cluster_0_dma_0_M_AXI_ARQOS, cluster_0_dma_0_M_AXI_ARUSER, 
  cluster_0_dma_0_M_AXI_ARVALID, cluster_0_dma_0_M_AXI_ARREADY,
  cluster_0_dma_0_M_AXI_RID, cluster_0_dma_0_M_AXI_RDATA, cluster_0_dma_0_M_AXI_RRESP, cluster_0_dma_0_M_AXI_RLAST, cluster_0_dma_0_M_AXI_RUSER, cluster_0_dma_0_M_AXI_RVALID, cluster_0_dma_0_M_AXI_RREADY,

  cluster_0_dma_0_M_AXI_AWID, cluster_0_dma_0_M_AXI_AWADDR, cluster_0_dma_0_M_AXI_AWLEN,
  cluster_0_dma_0_M_AXI_AWSIZE, cluster_0_dma_0_M_AXI_AWBURST, cluster_0_dma_0_M_AXI_AWLOCK, cluster_0_dma_0_M_AXI_AWCACHE, cluster_0_dma_0_M_AXI_AWPROT, cluster_0_dma_0_M_AXI_AWQOS, cluster_0_dma_0_M_AXI_AWUSER,
  cluster_0_dma_0_M_AXI_AWVALID, cluster_0_dma_0_M_AXI_AWREADY,
  cluster_0_dma_0_M_AXI_WDATA, cluster_0_dma_0_M_AXI_WSTRB, cluster_0_dma_0_M_AXI_WLAST, cluster_0_dma_0_M_AXI_WUSER, cluster_0_dma_0_M_AXI_WVALID, cluster_0_dma_0_M_AXI_WREADY,
  cluster_0_dma_0_M_AXI_BID, cluster_0_dma_0_M_AXI_BRESP, cluster_0_dma_0_M_AXI_BUSER, cluster_0_dma_0_M_AXI_BVALID, cluster_0_dma_0_M_AXI_BREADY, 

  cluster_1_dma_0_M_AXI_ARID, cluster_1_dma_0_M_AXI_ARADDR, cluster_1_dma_0_M_AXI_ARLEN, 
  cluster_1_dma_0_M_AXI_ARSIZE, cluster_1_dma_0_M_AXI_ARBURST, cluster_1_dma_0_M_AXI_ARLOCK, cluster_1_dma_0_M_AXI_ARCACHE, cluster_1_dma_0_M_AXI_ARPROT, cluster_1_dma_0_M_AXI_ARQOS, cluster_1_dma_0_M_AXI_ARUSER, 
  cluster_1_dma_0_M_AXI_ARVALID, cluster_1_dma_0_M_AXI_ARREADY,
  cluster_1_dma_0_M_AXI_RID, cluster_1_dma_0_M_AXI_RDATA, cluster_1_dma_0_M_AXI_RRESP, cluster_1_dma_0_M_AXI_RLAST, cluster_1_dma_0_M_AXI_RUSER, cluster_1_dma_0_M_AXI_RVALID, cluster_1_dma_0_M_AXI_RREADY,

  cluster_1_dma_0_M_AXI_AWID, cluster_1_dma_0_M_AXI_AWADDR, cluster_1_dma_0_M_AXI_AWLEN,
  cluster_1_dma_0_M_AXI_AWSIZE, cluster_1_dma_0_M_AXI_AWBURST, cluster_1_dma_0_M_AXI_AWLOCK, cluster_1_dma_0_M_AXI_AWCACHE, cluster_1_dma_0_M_AXI_AWPROT, cluster_1_dma_0_M_AXI_AWQOS, cluster_1_dma_0_M_AXI_AWUSER,
  cluster_1_dma_0_M_AXI_AWVALID, cluster_1_dma_0_M_AXI_AWREADY,
  cluster_1_dma_0_M_AXI_WDATA, cluster_1_dma_0_M_AXI_WSTRB, cluster_1_dma_0_M_AXI_WLAST, cluster_1_dma_0_M_AXI_WUSER, cluster_1_dma_0_M_AXI_WVALID, cluster_1_dma_0_M_AXI_WREADY,
  cluster_1_dma_0_M_AXI_BID, cluster_1_dma_0_M_AXI_BRESP, cluster_1_dma_0_M_AXI_BUSER, cluster_1_dma_0_M_AXI_BVALID, cluster_1_dma_0_M_AXI_BREADY, 

  cluster_2_dma_0_M_AXI_ARID, cluster_2_dma_0_M_AXI_ARADDR, cluster_2_dma_0_M_AXI_ARLEN, 
  cluster_2_dma_0_M_AXI_ARSIZE, cluster_2_dma_0_M_AXI_ARBURST, cluster_2_dma_0_M_AXI_ARLOCK, cluster_2_dma_0_M_AXI_ARCACHE, cluster_2_dma_0_M_AXI_ARPROT, cluster_2_dma_0_M_AXI_ARQOS, cluster_2_dma_0_M_AXI_ARUSER, 
  cluster_2_dma_0_M_AXI_ARVALID, cluster_2_dma_0_M_AXI_ARREADY,
  cluster_2_dma_0_M_AXI_RID, cluster_2_dma_0_M_AXI_RDATA, cluster_2_dma_0_M_AXI_RRESP, cluster_2_dma_0_M_AXI_RLAST, cluster_2_dma_0_M_AXI_RUSER, cluster_2_dma_0_M_AXI_RVALID, cluster_2_dma_0_M_AXI_RREADY,

  cluster_2_dma_0_M_AXI_AWID, cluster_2_dma_0_M_AXI_AWADDR, cluster_2_dma_0_M_AXI_AWLEN,
  cluster_2_dma_0_M_AXI_AWSIZE, cluster_2_dma_0_M_AXI_AWBURST, cluster_2_dma_0_M_AXI_AWLOCK, cluster_2_dma_0_M_AXI_AWCACHE, cluster_2_dma_0_M_AXI_AWPROT, cluster_2_dma_0_M_AXI_AWQOS, cluster_2_dma_0_M_AXI_AWUSER,
  cluster_2_dma_0_M_AXI_AWVALID, cluster_2_dma_0_M_AXI_AWREADY,
  cluster_2_dma_0_M_AXI_WDATA, cluster_2_dma_0_M_AXI_WSTRB, cluster_2_dma_0_M_AXI_WLAST, cluster_2_dma_0_M_AXI_WUSER, cluster_2_dma_0_M_AXI_WVALID, cluster_2_dma_0_M_AXI_WREADY,
  cluster_2_dma_0_M_AXI_BID, cluster_2_dma_0_M_AXI_BRESP, cluster_2_dma_0_M_AXI_BUSER, cluster_2_dma_0_M_AXI_BVALID, cluster_2_dma_0_M_AXI_BREADY, 

  cluster_3_dma_0_M_AXI_ARID, cluster_3_dma_0_M_AXI_ARADDR, cluster_3_dma_0_M_AXI_ARLEN, 
  cluster_3_dma_0_M_AXI_ARSIZE, cluster_3_dma_0_M_AXI_ARBURST, cluster_3_dma_0_M_AXI_ARLOCK, cluster_3_dma_0_M_AXI_ARCACHE, cluster_3_dma_0_M_AXI_ARPROT, cluster_3_dma_0_M_AXI_ARQOS, cluster_3_dma_0_M_AXI_ARUSER, 
  cluster_3_dma_0_M_AXI_ARVALID, cluster_3_dma_0_M_AXI_ARREADY,
  cluster_3_dma_0_M_AXI_RID, cluster_3_dma_0_M_AXI_RDATA, cluster_3_dma_0_M_AXI_RRESP, cluster_3_dma_0_M_AXI_RLAST, cluster_3_dma_0_M_AXI_RUSER, cluster_3_dma_0_M_AXI_RVALID, cluster_3_dma_0_M_AXI_RREADY,

  cluster_3_dma_0_M_AXI_AWID, cluster_3_dma_0_M_AXI_AWADDR, cluster_3_dma_0_M_AXI_AWLEN,
  cluster_3_dma_0_M_AXI_AWSIZE, cluster_3_dma_0_M_AXI_AWBURST, cluster_3_dma_0_M_AXI_AWLOCK, cluster_3_dma_0_M_AXI_AWCACHE, cluster_3_dma_0_M_AXI_AWPROT, cluster_3_dma_0_M_AXI_AWQOS, cluster_3_dma_0_M_AXI_AWUSER,
  cluster_3_dma_0_M_AXI_AWVALID, cluster_3_dma_0_M_AXI_AWREADY,
  cluster_3_dma_0_M_AXI_WDATA, cluster_3_dma_0_M_AXI_WSTRB, cluster_3_dma_0_M_AXI_WLAST, cluster_3_dma_0_M_AXI_WUSER, cluster_3_dma_0_M_AXI_WVALID, cluster_3_dma_0_M_AXI_WREADY,
  cluster_3_dma_0_M_AXI_BID, cluster_3_dma_0_M_AXI_BRESP, cluster_3_dma_0_M_AXI_BUSER, cluster_3_dma_0_M_AXI_BVALID, cluster_3_dma_0_M_AXI_BREADY, 

  cluster_0_dma_1_M_AXI_ARID, cluster_0_dma_1_M_AXI_ARADDR, cluster_0_dma_1_M_AXI_ARLEN, 
  cluster_0_dma_1_M_AXI_ARSIZE, cluster_0_dma_1_M_AXI_ARBURST, cluster_0_dma_1_M_AXI_ARLOCK, cluster_0_dma_1_M_AXI_ARCACHE, cluster_0_dma_1_M_AXI_ARPROT, cluster_0_dma_1_M_AXI_ARQOS, cluster_0_dma_1_M_AXI_ARUSER, 
  cluster_0_dma_1_M_AXI_ARVALID, cluster_0_dma_1_M_AXI_ARREADY,
  cluster_0_dma_1_M_AXI_RID, cluster_0_dma_1_M_AXI_RDATA, cluster_0_dma_1_M_AXI_RRESP, cluster_0_dma_1_M_AXI_RLAST, cluster_0_dma_1_M_AXI_RUSER, cluster_0_dma_1_M_AXI_RVALID, cluster_0_dma_1_M_AXI_RREADY,

  cluster_0_dma_1_M_AXI_AWID, cluster_0_dma_1_M_AXI_AWADDR, cluster_0_dma_1_M_AXI_AWLEN,
  cluster_0_dma_1_M_AXI_AWSIZE, cluster_0_dma_1_M_AXI_AWBURST, cluster_0_dma_1_M_AXI_AWLOCK, cluster_0_dma_1_M_AXI_AWCACHE, cluster_0_dma_1_M_AXI_AWPROT, cluster_0_dma_1_M_AXI_AWQOS, cluster_0_dma_1_M_AXI_AWUSER,
  cluster_0_dma_1_M_AXI_AWVALID, cluster_0_dma_1_M_AXI_AWREADY,
  cluster_0_dma_1_M_AXI_WDATA, cluster_0_dma_1_M_AXI_WSTRB, cluster_0_dma_1_M_AXI_WLAST, cluster_0_dma_1_M_AXI_WUSER, cluster_0_dma_1_M_AXI_WVALID, cluster_0_dma_1_M_AXI_WREADY,
  cluster_0_dma_1_M_AXI_BID, cluster_0_dma_1_M_AXI_BRESP, cluster_0_dma_1_M_AXI_BUSER, cluster_0_dma_1_M_AXI_BVALID, cluster_0_dma_1_M_AXI_BREADY, 

  cluster_1_dma_1_M_AXI_ARID, cluster_1_dma_1_M_AXI_ARADDR, cluster_1_dma_1_M_AXI_ARLEN, 
  cluster_1_dma_1_M_AXI_ARSIZE, cluster_1_dma_1_M_AXI_ARBURST, cluster_1_dma_1_M_AXI_ARLOCK, cluster_1_dma_1_M_AXI_ARCACHE, cluster_1_dma_1_M_AXI_ARPROT, cluster_1_dma_1_M_AXI_ARQOS, cluster_1_dma_1_M_AXI_ARUSER, 
  cluster_1_dma_1_M_AXI_ARVALID, cluster_1_dma_1_M_AXI_ARREADY,
  cluster_1_dma_1_M_AXI_RID, cluster_1_dma_1_M_AXI_RDATA, cluster_1_dma_1_M_AXI_RRESP, cluster_1_dma_1_M_AXI_RLAST, cluster_1_dma_1_M_AXI_RUSER, cluster_1_dma_1_M_AXI_RVALID, cluster_1_dma_1_M_AXI_RREADY,

  cluster_1_dma_1_M_AXI_AWID, cluster_1_dma_1_M_AXI_AWADDR, cluster_1_dma_1_M_AXI_AWLEN,
  cluster_1_dma_1_M_AXI_AWSIZE, cluster_1_dma_1_M_AXI_AWBURST, cluster_1_dma_1_M_AXI_AWLOCK, cluster_1_dma_1_M_AXI_AWCACHE, cluster_1_dma_1_M_AXI_AWPROT, cluster_1_dma_1_M_AXI_AWQOS, cluster_1_dma_1_M_AXI_AWUSER,
  cluster_1_dma_1_M_AXI_AWVALID, cluster_1_dma_1_M_AXI_AWREADY,
  cluster_1_dma_1_M_AXI_WDATA, cluster_1_dma_1_M_AXI_WSTRB, cluster_1_dma_1_M_AXI_WLAST, cluster_1_dma_1_M_AXI_WUSER, cluster_1_dma_1_M_AXI_WVALID, cluster_1_dma_1_M_AXI_WREADY,
  cluster_1_dma_1_M_AXI_BID, cluster_1_dma_1_M_AXI_BRESP, cluster_1_dma_1_M_AXI_BUSER, cluster_1_dma_1_M_AXI_BVALID, cluster_1_dma_1_M_AXI_BREADY, 

  cluster_2_dma_1_M_AXI_ARID, cluster_2_dma_1_M_AXI_ARADDR, cluster_2_dma_1_M_AXI_ARLEN, 
  cluster_2_dma_1_M_AXI_ARSIZE, cluster_2_dma_1_M_AXI_ARBURST, cluster_2_dma_1_M_AXI_ARLOCK, cluster_2_dma_1_M_AXI_ARCACHE, cluster_2_dma_1_M_AXI_ARPROT, cluster_2_dma_1_M_AXI_ARQOS, cluster_2_dma_1_M_AXI_ARUSER, 
  cluster_2_dma_1_M_AXI_ARVALID, cluster_2_dma_1_M_AXI_ARREADY,
  cluster_2_dma_1_M_AXI_RID, cluster_2_dma_1_M_AXI_RDATA, cluster_2_dma_1_M_AXI_RRESP, cluster_2_dma_1_M_AXI_RLAST, cluster_2_dma_1_M_AXI_RUSER, cluster_2_dma_1_M_AXI_RVALID, cluster_2_dma_1_M_AXI_RREADY,

  cluster_2_dma_1_M_AXI_AWID, cluster_2_dma_1_M_AXI_AWADDR, cluster_2_dma_1_M_AXI_AWLEN,
  cluster_2_dma_1_M_AXI_AWSIZE, cluster_2_dma_1_M_AXI_AWBURST, cluster_2_dma_1_M_AXI_AWLOCK, cluster_2_dma_1_M_AXI_AWCACHE, cluster_2_dma_1_M_AXI_AWPROT, cluster_2_dma_1_M_AXI_AWQOS, cluster_2_dma_1_M_AXI_AWUSER,
  cluster_2_dma_1_M_AXI_AWVALID, cluster_2_dma_1_M_AXI_AWREADY,
  cluster_2_dma_1_M_AXI_WDATA, cluster_2_dma_1_M_AXI_WSTRB, cluster_2_dma_1_M_AXI_WLAST, cluster_2_dma_1_M_AXI_WUSER, cluster_2_dma_1_M_AXI_WVALID, cluster_2_dma_1_M_AXI_WREADY,
  cluster_2_dma_1_M_AXI_BID, cluster_2_dma_1_M_AXI_BRESP, cluster_2_dma_1_M_AXI_BUSER, cluster_2_dma_1_M_AXI_BVALID, cluster_2_dma_1_M_AXI_BREADY, 

  cluster_3_dma_1_M_AXI_ARID, cluster_3_dma_1_M_AXI_ARADDR, cluster_3_dma_1_M_AXI_ARLEN, 
  cluster_3_dma_1_M_AXI_ARSIZE, cluster_3_dma_1_M_AXI_ARBURST, cluster_3_dma_1_M_AXI_ARLOCK, cluster_3_dma_1_M_AXI_ARCACHE, cluster_3_dma_1_M_AXI_ARPROT, cluster_3_dma_1_M_AXI_ARQOS, cluster_3_dma_1_M_AXI_ARUSER, 
  cluster_3_dma_1_M_AXI_ARVALID, cluster_3_dma_1_M_AXI_ARREADY,
  cluster_3_dma_1_M_AXI_RID, cluster_3_dma_1_M_AXI_RDATA, cluster_3_dma_1_M_AXI_RRESP, cluster_3_dma_1_M_AXI_RLAST, cluster_3_dma_1_M_AXI_RUSER, cluster_3_dma_1_M_AXI_RVALID, cluster_3_dma_1_M_AXI_RREADY,

  cluster_3_dma_1_M_AXI_AWID, cluster_3_dma_1_M_AXI_AWADDR, cluster_3_dma_1_M_AXI_AWLEN,
  cluster_3_dma_1_M_AXI_AWSIZE, cluster_3_dma_1_M_AXI_AWBURST, cluster_3_dma_1_M_AXI_AWLOCK, cluster_3_dma_1_M_AXI_AWCACHE, cluster_3_dma_1_M_AXI_AWPROT, cluster_3_dma_1_M_AXI_AWQOS, cluster_3_dma_1_M_AXI_AWUSER,
  cluster_3_dma_1_M_AXI_AWVALID, cluster_3_dma_1_M_AXI_AWREADY,
  cluster_3_dma_1_M_AXI_WDATA, cluster_3_dma_1_M_AXI_WSTRB, cluster_3_dma_1_M_AXI_WLAST, cluster_3_dma_1_M_AXI_WUSER, cluster_3_dma_1_M_AXI_WVALID, cluster_3_dma_1_M_AXI_WREADY,
  cluster_3_dma_1_M_AXI_BID, cluster_3_dma_1_M_AXI_BRESP, cluster_3_dma_1_M_AXI_BUSER, cluster_3_dma_1_M_AXI_BVALID, cluster_3_dma_1_M_AXI_BREADY, 

  insn_M_AXI_ARID, insn_M_AXI_ARADDR, insn_M_AXI_ARLEN, 
  insn_M_AXI_ARSIZE, insn_M_AXI_ARBURST, insn_M_AXI_ARLOCK, insn_M_AXI_ARCACHE, insn_M_AXI_ARPROT, insn_M_AXI_ARQOS, insn_M_AXI_ARUSER, 
  insn_M_AXI_ARVALID, insn_M_AXI_ARREADY,
  insn_M_AXI_RID, insn_M_AXI_RDATA, insn_M_AXI_RRESP, insn_M_AXI_RLAST, insn_M_AXI_RUSER, insn_M_AXI_RVALID, insn_M_AXI_RREADY,

  insn_M_AXI_AWID, insn_M_AXI_AWADDR, insn_M_AXI_AWLEN,
  insn_M_AXI_AWSIZE, insn_M_AXI_AWBURST, insn_M_AXI_AWLOCK, insn_M_AXI_AWCACHE, insn_M_AXI_AWPROT, insn_M_AXI_AWQOS, insn_M_AXI_AWUSER,
  insn_M_AXI_AWVALID, insn_M_AXI_AWREADY,
  insn_M_AXI_WDATA, insn_M_AXI_WSTRB, insn_M_AXI_WLAST, insn_M_AXI_WUSER, insn_M_AXI_WVALID, insn_M_AXI_WREADY,
  insn_M_AXI_BID, insn_M_AXI_BRESP, insn_M_AXI_BUSER, insn_M_AXI_BVALID, insn_M_AXI_BREADY, 

  clk, rst_n,

  apb4_pclk, apb4_presetn,
  apb4_paddr, apb4_psel, apb4_penable, apb4_pwrite, 
  apb4_pready, 
  apb4_pwdata, apb4_pstrb, 
  apb4_prdata,
  apb4_pprot, apb4_pslverr,

  pcie_clk, pcie_rst_n,
  pcie_ven_msi_req, pcie_ven_msi_func_num, pcie_ven_msi_tc, pcie_ven_msi_vector,
  pcie_msi_grant, pcie_highaddr,
  mcu_clk, mcu_rst_n, mcu_highaddr
);

parameter INSN_BITS             = 128;
parameter AXI_M_AXI_ID_WIDTH    = 20;
parameter AXI_M_AXI_ADDR_WIDTH  = 64;
parameter AXI_M_AXI_USER_WIDTH  = 1;
parameter AXI_M_AXI_DATA_WIDTH  = 256;
parameter AXI_M_AXI_BURSTLENGTH = 128;
parameter AXI_OUTSTANDING_DEPTH = 8;
parameter AXI_M_AXI_DATA_BYTES  = AXI_M_AXI_DATA_WIDTH / 8;

parameter AXI_S_AXI_ID_WIDTH    = 20;
parameter AXI_S_AXI_ADDR_WIDTH  = 64;
parameter AXI_S_AXI_USER_WIDTH  = 1;
parameter AXI_S_AXI_DATA_WIDTH  = 256;
parameter AXI_S_AXI_BURSTLENGTH = 64;
parameter AXI_S_AXI_DATA_BYTES   = AXI_S_AXI_DATA_WIDTH / 8;

parameter MASTER_PERI_ADDR_WIDTH    = 38;
parameter MASTER_PERI_BUSRSTS_WIDTH = 22;
parameter MASTER_PERI_DATA_WIDTH    = 256;
parameter MASTER_SRAM_ADDR_WIDTH    = 20;
parameter SLAVE_PERI_ADDR_WIDTH     = 38;
parameter SLAVE_PERI_BUSRSTS_WIDTH  = 22;
parameter SLAVE_PERI_DATA_WIDTH     = 256;

parameter HIGHADDR_BITS           = 24;

parameter integer INSN_R_ADDR_WIDTH    = 64;
parameter integer INSN_R_BUSRSTS_WIDTH = 8;
parameter integer INSN_R_DATA_WIDTH    = 256;
parameter integer INSN_WIDTH           = 128;
parameter integer INSN_FIFO_DEPTH      = 128;
parameter REG_WIDTH                    = 32;
parameter REG_NUM_BITS                 = 8;

parameter CLUSTER_IFMAP_WIDTH       = 512;
parameter CLUSTER_QACT_WIDTH        = 288;
parameter CLUSTER_VCUCODE_WIDTH     = 64;
parameter CLUSTER_VCUPARA_WIDTH     = 512;
parameter CLUSTER_VCULUT_WIDTH      = 64;
parameter CLUSTER_VCURES_WIDTH      = 512;

parameter CLUSTER_IFMAP_ADDR_BITS   = 9;
parameter CLUSTER_QACT_ADDR_BITS    = 9;
parameter CLUSTER_VCUCODE_ADDR_BITS = 7;
parameter CLUSTER_VCUPARA_ADDR_BITS = 9;
parameter CLUSTER_VCULUT_ADDR_BITS  = 9;
parameter CLUSTER_VCURES_ADDR_BITS  = 9;
parameter WEIGHT_BANK               = 32;
parameter WEIGHT_WIDTH              = 288;
parameter WEIGHT_ADDR_BITS          = 14;
  
parameter OFMAP_ADDR_BITS           = 12;
parameter OFMAP_WIDTH               = 256;


input clk, rst_n;

input axi4_clk, axi4_rst_n;

// apb
input              apb4_pclk;
input              apb4_presetn;
input       [31:0] apb4_paddr;
input              apb4_psel;
input              apb4_penable;
input              apb4_pwrite;
output wire        apb4_pready;
input       [31:0] apb4_pwdata;
input       [3:0]  apb4_pstrb;
output wire [31:0] apb4_prdata;
input       [2:0]  apb4_pprot;
output wire        apb4_pslverr;

input       [AXI_S_AXI_ID_WIDTH-1:0]   axi_S_AXI_ARID;
input       [AXI_S_AXI_ADDR_WIDTH-1:0] axi_S_AXI_ARADDR;
input       [7:0]                      axi_S_AXI_ARLEN;
input       [2:0]                      axi_S_AXI_ARSIZE;
input       [1:0]                      axi_S_AXI_ARBURST;
input                                  axi_S_AXI_ARLOCK;
input       [3:0]                      axi_S_AXI_ARCACHE;
input       [2:0]                      axi_S_AXI_ARPROT;
input       [3:0]                      axi_S_AXI_ARQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0] axi_S_AXI_ARUSER;
input                                  axi_S_AXI_ARVALID;
output wire                            axi_S_AXI_ARREADY;
output wire [AXI_S_AXI_ID_WIDTH-1:0]   axi_S_AXI_RID;
output wire [AXI_S_AXI_DATA_WIDTH-1:0] axi_S_AXI_RDATA;
output wire [1:0]                      axi_S_AXI_RRESP;
output wire                            axi_S_AXI_RLAST;
output wire [AXI_S_AXI_USER_WIDTH-1:0] axi_S_AXI_RUSER;
output wire                            axi_S_AXI_RVALID;
input                                  axi_S_AXI_RREADY;

input       [AXI_S_AXI_ID_WIDTH-1:0]   axi_S_AXI_AWID;
input       [AXI_M_AXI_ADDR_WIDTH-1:0] axi_S_AXI_AWADDR;
input       [7:0]                      axi_S_AXI_AWLEN;
input       [2:0]                      axi_S_AXI_AWSIZE;
input       [1:0]                      axi_S_AXI_AWBURST;
input                                  axi_S_AXI_AWLOCK;
input       [3:0]                      axi_S_AXI_AWCACHE;
input       [2:0]                      axi_S_AXI_AWPROT;
input       [3:0]                      axi_S_AXI_AWQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0] axi_S_AXI_AWUSER;
input                                  axi_S_AXI_AWVALID;
output wire                            axi_S_AXI_AWREADY;
input       [AXI_S_AXI_DATA_WIDTH-1:0] axi_S_AXI_WDATA;
input       [AXI_S_AXI_DATA_BYTES-1:0] axi_S_AXI_WSTRB;
input                                  axi_S_AXI_WLAST;
input       [AXI_S_AXI_USER_WIDTH-1:0] axi_S_AXI_WUSER;
input                                  axi_S_AXI_WVALID;
output wire                            axi_S_AXI_WREADY;
output wire [AXI_S_AXI_ID_WIDTH-1:0]   axi_S_AXI_BID;
output wire [1:0]                      axi_S_AXI_BRESP;
output wire [AXI_S_AXI_USER_WIDTH-1:0] axi_S_AXI_BUSER;
output wire                            axi_S_AXI_BVALID;
input                                  axi_S_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_0_dma_0_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_0_dma_0_M_AXI_AWADDR;
output wire [7:0]                      cluster_0_dma_0_M_AXI_AWLEN;
output wire [2:0]                      cluster_0_dma_0_M_AXI_AWSIZE;
output wire [1:0]                      cluster_0_dma_0_M_AXI_AWBURST;
output wire                            cluster_0_dma_0_M_AXI_AWLOCK;
output wire [3:0]                      cluster_0_dma_0_M_AXI_AWCACHE;
output wire [2:0]                      cluster_0_dma_0_M_AXI_AWPROT;
output wire [3:0]                      cluster_0_dma_0_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_AWUSER;
output wire                            cluster_0_dma_0_M_AXI_AWVALID;
input                                  cluster_0_dma_0_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_0_dma_0_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_0_dma_0_M_AXI_WSTRB;
output wire                            cluster_0_dma_0_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_WUSER;
output wire                            cluster_0_dma_0_M_AXI_WVALID;
input                                  cluster_0_dma_0_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_0_dma_0_M_AXI_BID;
input       [1:0]                      cluster_0_dma_0_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_BUSER;
input                                  cluster_0_dma_0_M_AXI_BVALID;
output wire                            cluster_0_dma_0_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_0_dma_0_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_0_dma_0_M_AXI_ARADDR;
output wire [7:0]                      cluster_0_dma_0_M_AXI_ARLEN;
output wire [2:0]                      cluster_0_dma_0_M_AXI_ARSIZE;
output wire [1:0]                      cluster_0_dma_0_M_AXI_ARBURST;
output wire                            cluster_0_dma_0_M_AXI_ARLOCK;
output wire [3:0]                      cluster_0_dma_0_M_AXI_ARCACHE;
output wire [2:0]                      cluster_0_dma_0_M_AXI_ARPROT;
output wire [3:0]                      cluster_0_dma_0_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_ARUSER;
output wire                            cluster_0_dma_0_M_AXI_ARVALID;
input                                  cluster_0_dma_0_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_0_dma_0_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] cluster_0_dma_0_M_AXI_RDATA;
input       [1:0]                      cluster_0_dma_0_M_AXI_RRESP;
input                                  cluster_0_dma_0_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_0_M_AXI_RUSER;
input                                  cluster_0_dma_0_M_AXI_RVALID;
output wire                            cluster_0_dma_0_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_0_dma_1_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_0_dma_1_M_AXI_AWADDR;
output wire [7:0]                      cluster_0_dma_1_M_AXI_AWLEN;
output wire [2:0]                      cluster_0_dma_1_M_AXI_AWSIZE;
output wire [1:0]                      cluster_0_dma_1_M_AXI_AWBURST;
output wire                            cluster_0_dma_1_M_AXI_AWLOCK;
output wire [3:0]                      cluster_0_dma_1_M_AXI_AWCACHE;
output wire [2:0]                      cluster_0_dma_1_M_AXI_AWPROT;
output wire [3:0]                      cluster_0_dma_1_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_AWUSER;
output wire                            cluster_0_dma_1_M_AXI_AWVALID;
input                                  cluster_0_dma_1_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_0_dma_1_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_0_dma_1_M_AXI_WSTRB;
output wire                            cluster_0_dma_1_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_WUSER;
output wire                            cluster_0_dma_1_M_AXI_WVALID;
input                                  cluster_0_dma_1_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_0_dma_1_M_AXI_BID;
input       [1:0]                      cluster_0_dma_1_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_BUSER;
input                                  cluster_0_dma_1_M_AXI_BVALID;
output wire                            cluster_0_dma_1_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_0_dma_1_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_0_dma_1_M_AXI_ARADDR;
output wire [7:0]                      cluster_0_dma_1_M_AXI_ARLEN;
output wire [2:0]                      cluster_0_dma_1_M_AXI_ARSIZE;
output wire [1:0]                      cluster_0_dma_1_M_AXI_ARBURST;
output wire                            cluster_0_dma_1_M_AXI_ARLOCK;
output wire [3:0]                      cluster_0_dma_1_M_AXI_ARCACHE;
output wire [2:0]                      cluster_0_dma_1_M_AXI_ARPROT;
output wire [3:0]                      cluster_0_dma_1_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_ARUSER;
output wire                            cluster_0_dma_1_M_AXI_ARVALID;
input                                  cluster_0_dma_1_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_0_dma_1_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] cluster_0_dma_1_M_AXI_RDATA;
input       [1:0]                      cluster_0_dma_1_M_AXI_RRESP;
input                                  cluster_0_dma_1_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_0_dma_1_M_AXI_RUSER;
input                                  cluster_0_dma_1_M_AXI_RVALID;
output wire                            cluster_0_dma_1_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_1_dma_0_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_1_dma_0_M_AXI_AWADDR;
output wire [7:0]                      cluster_1_dma_0_M_AXI_AWLEN;
output wire [2:0]                      cluster_1_dma_0_M_AXI_AWSIZE;
output wire [1:0]                      cluster_1_dma_0_M_AXI_AWBURST;
output wire                            cluster_1_dma_0_M_AXI_AWLOCK;
output wire [3:0]                      cluster_1_dma_0_M_AXI_AWCACHE;
output wire [2:0]                      cluster_1_dma_0_M_AXI_AWPROT;
output wire [3:0]                      cluster_1_dma_0_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_AWUSER;
output wire                            cluster_1_dma_0_M_AXI_AWVALID;
input                                  cluster_1_dma_0_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_1_dma_0_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_1_dma_0_M_AXI_WSTRB;
output wire                            cluster_1_dma_0_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_WUSER;
output wire                            cluster_1_dma_0_M_AXI_WVALID;
input                                  cluster_1_dma_0_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_1_dma_0_M_AXI_BID;
input       [1:0]                      cluster_1_dma_0_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_BUSER;
input                                  cluster_1_dma_0_M_AXI_BVALID;
output wire                            cluster_1_dma_0_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_1_dma_0_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_1_dma_0_M_AXI_ARADDR;
output wire [7:0]                      cluster_1_dma_0_M_AXI_ARLEN;
output wire [2:0]                      cluster_1_dma_0_M_AXI_ARSIZE;
output wire [1:0]                      cluster_1_dma_0_M_AXI_ARBURST;
output wire                            cluster_1_dma_0_M_AXI_ARLOCK;
output wire [3:0]                      cluster_1_dma_0_M_AXI_ARCACHE;
output wire [2:0]                      cluster_1_dma_0_M_AXI_ARPROT;
output wire [3:0]                      cluster_1_dma_0_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_ARUSER;
output wire                            cluster_1_dma_0_M_AXI_ARVALID;
input                                  cluster_1_dma_0_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_1_dma_0_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] cluster_1_dma_0_M_AXI_RDATA;
input       [1:0]                      cluster_1_dma_0_M_AXI_RRESP;
input                                  cluster_1_dma_0_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_0_M_AXI_RUSER;
input                                  cluster_1_dma_0_M_AXI_RVALID;
output wire                            cluster_1_dma_0_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_1_dma_1_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_1_dma_1_M_AXI_AWADDR;
output wire [7:0]                      cluster_1_dma_1_M_AXI_AWLEN;
output wire [2:0]                      cluster_1_dma_1_M_AXI_AWSIZE;
output wire [1:0]                      cluster_1_dma_1_M_AXI_AWBURST;
output wire                            cluster_1_dma_1_M_AXI_AWLOCK;
output wire [3:0]                      cluster_1_dma_1_M_AXI_AWCACHE;
output wire [2:0]                      cluster_1_dma_1_M_AXI_AWPROT;
output wire [3:0]                      cluster_1_dma_1_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_AWUSER;
output wire                            cluster_1_dma_1_M_AXI_AWVALID;
input                                  cluster_1_dma_1_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_1_dma_1_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_1_dma_1_M_AXI_WSTRB;
output wire                            cluster_1_dma_1_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_WUSER;
output wire                            cluster_1_dma_1_M_AXI_WVALID;
input                                  cluster_1_dma_1_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_1_dma_1_M_AXI_BID;
input       [1:0]                      cluster_1_dma_1_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_BUSER;
input                                  cluster_1_dma_1_M_AXI_BVALID;
output wire                            cluster_1_dma_1_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_1_dma_1_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_1_dma_1_M_AXI_ARADDR;
output wire [7:0]                      cluster_1_dma_1_M_AXI_ARLEN;
output wire [2:0]                      cluster_1_dma_1_M_AXI_ARSIZE;
output wire [1:0]                      cluster_1_dma_1_M_AXI_ARBURST;
output wire                            cluster_1_dma_1_M_AXI_ARLOCK;
output wire [3:0]                      cluster_1_dma_1_M_AXI_ARCACHE;
output wire [2:0]                      cluster_1_dma_1_M_AXI_ARPROT;
output wire [3:0]                      cluster_1_dma_1_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_ARUSER;
output wire                            cluster_1_dma_1_M_AXI_ARVALID;
input                                  cluster_1_dma_1_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_1_dma_1_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] cluster_1_dma_1_M_AXI_RDATA;
input       [1:0]                      cluster_1_dma_1_M_AXI_RRESP;
input                                  cluster_1_dma_1_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_1_dma_1_M_AXI_RUSER;
input                                  cluster_1_dma_1_M_AXI_RVALID;
output wire                            cluster_1_dma_1_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_2_dma_0_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_2_dma_0_M_AXI_AWADDR;
output wire [7:0]                      cluster_2_dma_0_M_AXI_AWLEN;
output wire [2:0]                      cluster_2_dma_0_M_AXI_AWSIZE;
output wire [1:0]                      cluster_2_dma_0_M_AXI_AWBURST;
output wire                            cluster_2_dma_0_M_AXI_AWLOCK;
output wire [3:0]                      cluster_2_dma_0_M_AXI_AWCACHE;
output wire [2:0]                      cluster_2_dma_0_M_AXI_AWPROT;
output wire [3:0]                      cluster_2_dma_0_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_AWUSER;
output wire                            cluster_2_dma_0_M_AXI_AWVALID;
input                                  cluster_2_dma_0_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_2_dma_0_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_2_dma_0_M_AXI_WSTRB;
output wire                            cluster_2_dma_0_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_WUSER;
output wire                            cluster_2_dma_0_M_AXI_WVALID;
input                                  cluster_2_dma_0_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_2_dma_0_M_AXI_BID;
input       [1:0]                      cluster_2_dma_0_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_BUSER;
input                                  cluster_2_dma_0_M_AXI_BVALID;
output wire                            cluster_2_dma_0_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_2_dma_0_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_2_dma_0_M_AXI_ARADDR;
output wire [7:0]                      cluster_2_dma_0_M_AXI_ARLEN;
output wire [2:0]                      cluster_2_dma_0_M_AXI_ARSIZE;
output wire [1:0]                      cluster_2_dma_0_M_AXI_ARBURST;
output wire                            cluster_2_dma_0_M_AXI_ARLOCK;
output wire [3:0]                      cluster_2_dma_0_M_AXI_ARCACHE;
output wire [2:0]                      cluster_2_dma_0_M_AXI_ARPROT;
output wire [3:0]                      cluster_2_dma_0_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_ARUSER;
output wire                            cluster_2_dma_0_M_AXI_ARVALID;
input                                  cluster_2_dma_0_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_2_dma_0_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] cluster_2_dma_0_M_AXI_RDATA;
input       [1:0]                      cluster_2_dma_0_M_AXI_RRESP;
input                                  cluster_2_dma_0_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_0_M_AXI_RUSER;
input                                  cluster_2_dma_0_M_AXI_RVALID;
output wire                            cluster_2_dma_0_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_2_dma_1_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_2_dma_1_M_AXI_AWADDR;
output wire [7:0]                      cluster_2_dma_1_M_AXI_AWLEN;
output wire [2:0]                      cluster_2_dma_1_M_AXI_AWSIZE;
output wire [1:0]                      cluster_2_dma_1_M_AXI_AWBURST;
output wire                            cluster_2_dma_1_M_AXI_AWLOCK;
output wire [3:0]                      cluster_2_dma_1_M_AXI_AWCACHE;
output wire [2:0]                      cluster_2_dma_1_M_AXI_AWPROT;
output wire [3:0]                      cluster_2_dma_1_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_AWUSER;
output wire                            cluster_2_dma_1_M_AXI_AWVALID;
input                                  cluster_2_dma_1_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_2_dma_1_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_2_dma_1_M_AXI_WSTRB;
output wire                            cluster_2_dma_1_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_WUSER;
output wire                            cluster_2_dma_1_M_AXI_WVALID;
input                                  cluster_2_dma_1_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_2_dma_1_M_AXI_BID;
input       [1:0]                      cluster_2_dma_1_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_BUSER;
input                                  cluster_2_dma_1_M_AXI_BVALID;
output wire                            cluster_2_dma_1_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_2_dma_1_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_2_dma_1_M_AXI_ARADDR;
output wire [7:0]                      cluster_2_dma_1_M_AXI_ARLEN;
output wire [2:0]                      cluster_2_dma_1_M_AXI_ARSIZE;
output wire [1:0]                      cluster_2_dma_1_M_AXI_ARBURST;
output wire                            cluster_2_dma_1_M_AXI_ARLOCK;
output wire [3:0]                      cluster_2_dma_1_M_AXI_ARCACHE;
output wire [2:0]                      cluster_2_dma_1_M_AXI_ARPROT;
output wire [3:0]                      cluster_2_dma_1_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_ARUSER;
output wire                            cluster_2_dma_1_M_AXI_ARVALID;
input                                  cluster_2_dma_1_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_2_dma_1_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] cluster_2_dma_1_M_AXI_RDATA;
input       [1:0]                      cluster_2_dma_1_M_AXI_RRESP;
input                                  cluster_2_dma_1_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_2_dma_1_M_AXI_RUSER;
input                                  cluster_2_dma_1_M_AXI_RVALID;
output wire                            cluster_2_dma_1_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_3_dma_0_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_3_dma_0_M_AXI_AWADDR;
output wire [7:0]                      cluster_3_dma_0_M_AXI_AWLEN;
output wire [2:0]                      cluster_3_dma_0_M_AXI_AWSIZE;
output wire [1:0]                      cluster_3_dma_0_M_AXI_AWBURST;
output wire                            cluster_3_dma_0_M_AXI_AWLOCK;
output wire [3:0]                      cluster_3_dma_0_M_AXI_AWCACHE;
output wire [2:0]                      cluster_3_dma_0_M_AXI_AWPROT;
output wire [3:0]                      cluster_3_dma_0_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_AWUSER;
output wire                            cluster_3_dma_0_M_AXI_AWVALID;
input                                  cluster_3_dma_0_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_3_dma_0_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_3_dma_0_M_AXI_WSTRB;
output wire                            cluster_3_dma_0_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_WUSER;
output wire                            cluster_3_dma_0_M_AXI_WVALID;
input                                  cluster_3_dma_0_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_3_dma_0_M_AXI_BID;
input       [1:0]                      cluster_3_dma_0_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_BUSER;
input                                  cluster_3_dma_0_M_AXI_BVALID;
output wire                            cluster_3_dma_0_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_3_dma_0_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_3_dma_0_M_AXI_ARADDR;
output wire [7:0]                      cluster_3_dma_0_M_AXI_ARLEN;
output wire [2:0]                      cluster_3_dma_0_M_AXI_ARSIZE;
output wire [1:0]                      cluster_3_dma_0_M_AXI_ARBURST;
output wire                            cluster_3_dma_0_M_AXI_ARLOCK;
output wire [3:0]                      cluster_3_dma_0_M_AXI_ARCACHE;
output wire [2:0]                      cluster_3_dma_0_M_AXI_ARPROT;
output wire [3:0]                      cluster_3_dma_0_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_ARUSER;
output wire                            cluster_3_dma_0_M_AXI_ARVALID;
input                                  cluster_3_dma_0_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_3_dma_0_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] cluster_3_dma_0_M_AXI_RDATA;
input       [1:0]                      cluster_3_dma_0_M_AXI_RRESP;
input                                  cluster_3_dma_0_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_0_M_AXI_RUSER;
input                                  cluster_3_dma_0_M_AXI_RVALID;
output wire                            cluster_3_dma_0_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_3_dma_1_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_3_dma_1_M_AXI_AWADDR;
output wire [7:0]                      cluster_3_dma_1_M_AXI_AWLEN;
output wire [2:0]                      cluster_3_dma_1_M_AXI_AWSIZE;
output wire [1:0]                      cluster_3_dma_1_M_AXI_AWBURST;
output wire                            cluster_3_dma_1_M_AXI_AWLOCK;
output wire [3:0]                      cluster_3_dma_1_M_AXI_AWCACHE;
output wire [2:0]                      cluster_3_dma_1_M_AXI_AWPROT;
output wire [3:0]                      cluster_3_dma_1_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_AWUSER;
output wire                            cluster_3_dma_1_M_AXI_AWVALID;
input                                  cluster_3_dma_1_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] cluster_3_dma_1_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] cluster_3_dma_1_M_AXI_WSTRB;
output wire                            cluster_3_dma_1_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_WUSER;
output wire                            cluster_3_dma_1_M_AXI_WVALID;
input                                  cluster_3_dma_1_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_3_dma_1_M_AXI_BID;
input       [1:0]                      cluster_3_dma_1_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_BUSER;
input                                  cluster_3_dma_1_M_AXI_BVALID;
output wire                            cluster_3_dma_1_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   cluster_3_dma_1_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] cluster_3_dma_1_M_AXI_ARADDR;
output wire [7:0]                      cluster_3_dma_1_M_AXI_ARLEN;
output wire [2:0]                      cluster_3_dma_1_M_AXI_ARSIZE;
output wire [1:0]                      cluster_3_dma_1_M_AXI_ARBURST;
output wire                            cluster_3_dma_1_M_AXI_ARLOCK;
output wire [3:0]                      cluster_3_dma_1_M_AXI_ARCACHE;
output wire [2:0]                      cluster_3_dma_1_M_AXI_ARPROT;
output wire [3:0]                      cluster_3_dma_1_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_ARUSER;
output wire                            cluster_3_dma_1_M_AXI_ARVALID;
input                                  cluster_3_dma_1_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   cluster_3_dma_1_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] cluster_3_dma_1_M_AXI_RDATA;
input       [1:0]                      cluster_3_dma_1_M_AXI_RRESP;
input                                  cluster_3_dma_1_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] cluster_3_dma_1_M_AXI_RUSER;
input                                  cluster_3_dma_1_M_AXI_RVALID;
output wire                            cluster_3_dma_1_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   insn_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] insn_M_AXI_AWADDR;
output wire [7:0]                      insn_M_AXI_AWLEN;
output wire [2:0]                      insn_M_AXI_AWSIZE;
output wire [1:0]                      insn_M_AXI_AWBURST;
output wire                            insn_M_AXI_AWLOCK;
output wire [3:0]                      insn_M_AXI_AWCACHE;
output wire [2:0]                      insn_M_AXI_AWPROT;
output wire [3:0]                      insn_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_AWUSER;
output wire                            insn_M_AXI_AWVALID;
input                                  insn_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] insn_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] insn_M_AXI_WSTRB;
output wire                            insn_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_WUSER;
output wire                            insn_M_AXI_WVALID;
input                                  insn_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   insn_M_AXI_BID;
input       [1:0]                      insn_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_BUSER;
input                                  insn_M_AXI_BVALID;
output wire                            insn_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   insn_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] insn_M_AXI_ARADDR;
output wire [7:0]                      insn_M_AXI_ARLEN;
output wire [2:0]                      insn_M_AXI_ARSIZE;
output wire [1:0]                      insn_M_AXI_ARBURST;
output wire                            insn_M_AXI_ARLOCK;
output wire [3:0]                      insn_M_AXI_ARCACHE;
output wire [2:0]                      insn_M_AXI_ARPROT;
output wire [3:0]                      insn_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_ARUSER;
output wire                            insn_M_AXI_ARVALID;
input                                  insn_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]   insn_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0] insn_M_AXI_RDATA;
input       [1:0]                      insn_M_AXI_RRESP;
input                                  insn_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0] insn_M_AXI_RUSER;
input                                  insn_M_AXI_RVALID;
output wire                            insn_M_AXI_RREADY;

input         pcie_clk;
input         pcie_rst_n;
output        pcie_ven_msi_req;
output [2:0]  pcie_ven_msi_func_num;
output [2:0]  pcie_ven_msi_tc;
output [4:0]  pcie_ven_msi_vector;
input         pcie_msi_grant;
output [31:0] pcie_highaddr;
input         mcu_clk;
input         mcu_rst_n;
output [31:0] mcu_highaddr;

/* -------------------------------------------------------------------------------------------------------- */
/*                                              Define Signals                                              */
/* -------------------------------------------------------------------------------------------------------- */

/* -------------------------------------------- Control Signals ------------------------------------------- */

/* Done signal */
wire cluster_0_done;
wire cluster_1_done;
wire cluster_2_done;
wire cluster_3_done;

reg  cluster_0_done_reg;
reg  cluster_1_done_reg;
reg  cluster_2_done_reg;
reg  cluster_3_done_reg;

reg  global_done;

/* -------------------------------------------------- reg ------------------------------------------------- */

wire                             cluster_0_rvalid;
wire                             cluster_0_rready;
wire [31:0]                      cluster_0_raddr;
wire [31:0]                      cluster_0_rdata;

wire                             cluster_0_wvalid;
wire                             cluster_0_wready;
wire [31:0]                      cluster_0_waddr;
wire [31:0]                      cluster_0_wdata;

wire                             weight_0_rvalid;
wire [WEIGHT_ADDR_BITS-1:0]      weight_0_raddr;
wire [WEIGHT_WIDTH*WEIGHT_BANK-1:0] weight_0_rdata;

wire                             weight_1_rvalid;
wire [WEIGHT_ADDR_BITS-1:0]      weight_1_raddr;
wire [WEIGHT_WIDTH*WEIGHT_BANK-1:0] weight_1_rdata;
wire                             weight_2_rvalid;
wire [WEIGHT_ADDR_BITS-1:0]      weight_2_raddr;
wire [WEIGHT_WIDTH*WEIGHT_BANK-1:0] weight_2_rdata;
wire                             weight_3_rvalid;
wire [WEIGHT_ADDR_BITS-1:0]      weight_3_raddr;
wire [WEIGHT_WIDTH*WEIGHT_BANK-1:0] weight_3_rdata;

wire                             weight_dma_0_wvalid;
wire [WEIGHT_ADDR_BITS-1:0]      weight_dma_0_waddr;
wire [WEIGHT_WIDTH-1:0]          weight_dma_0_wdata;

wire                             weight_dma_1_wvalid;
wire [WEIGHT_ADDR_BITS-1:0]      weight_dma_1_waddr;
wire [WEIGHT_WIDTH-1:0]          weight_dma_1_wdata;

wire                             weight_dma_2_wvalid;
wire [WEIGHT_ADDR_BITS-1:0]      weight_dma_2_waddr;
wire [WEIGHT_WIDTH-1:0]          weight_dma_2_wdata;

wire                             weight_dma_3_wvalid;
wire [WEIGHT_ADDR_BITS-1:0]      weight_dma_3_waddr;
wire [WEIGHT_WIDTH-1:0]          weight_dma_3_wdata;

wire                             weight_dma_4_wvalid;
wire [WEIGHT_WIDTH-1:0]          weight_dma_4_wdata;

wire                             weight_dma_5_wvalid;
wire [WEIGHT_WIDTH-1:0]          weight_dma_5_wdata;

wire                             weight_dma_6_wvalid;
wire [WEIGHT_WIDTH-1:0]          weight_dma_6_wdata;

wire                             weight_dma_7_wvalid;
wire [WEIGHT_WIDTH-1:0]          weight_dma_7_wdata;


wire                             cluster_0_load_dma_rst_n;
wire                             cluster_0_enable_prof_counter;
wire                             cluster_0_load_0_local_done_wire;
wire                             cluster_0_load_1_local_done_wire;
wire                             cluster_0_load_0_global_done;
wire                             cluster_0_load_1_global_done;
wire [31:0]                      cluster_0_load_0_execute_time;
wire [31:0]                      cluster_0_load_1_execute_time;

wire                             cluster_0_dma_0_ifmap_wvalid;
wire [CLUSTER_IFMAP_ADDR_BITS-1:0] cluster_0_dma_0_ifmap_waddr;
wire [CLUSTER_IFMAP_WIDTH-1:0]   cluster_0_dma_0_ifmap_wdata;
wire                             cluster_0_dma_0_qact_wvalid;
wire [CLUSTER_QACT_ADDR_BITS-1:0] cluster_0_dma_0_qact_waddr;
wire [CLUSTER_QACT_WIDTH-1:0]    cluster_0_dma_0_qact_wdata;
wire                             cluster_0_dma_0_vcucode_wvalid;
wire [CLUSTER_VCUCODE_ADDR_BITS:0] cluster_0_dma_0_vcucode_waddr;
wire [CLUSTER_VCUCODE_WIDTH-1:0] cluster_0_dma_0_vcucode_wdata;
wire                             cluster_0_dma_0_vcupara_wvalid;
wire [CLUSTER_VCUPARA_ADDR_BITS:0] cluster_0_dma_0_vcupara_waddr;
wire [CLUSTER_VCUPARA_WIDTH-1:0] cluster_0_dma_0_vcupara_wdata;
wire                             cluster_0_dma_0_vcures_wvalid;
wire [CLUSTER_VCURES_ADDR_BITS-1:0] cluster_0_dma_0_vcures_waddr;
wire [CLUSTER_VCURES_WIDTH-1:0]  cluster_0_dma_0_vcures_wdata;
wire                             cluster_0_load_regfile_wvalid;
wire [31:0]                      cluster_0_load_regfile_waddr;
wire [31:0]                      cluster_0_load_regfile_wdata;

wire                             cluster_1_load_dma_rst_n;
wire                             cluster_1_enable_prof_counter;
wire                             cluster_1_load_0_local_done_wire;
wire                             cluster_1_load_1_local_done_wire;
wire                             cluster_1_load_0_global_done;
wire                             cluster_1_load_1_global_done;
wire [31:0]                      cluster_1_load_0_execute_time;
wire [31:0]                      cluster_1_load_1_execute_time;
wire                             cluster_1_dma_0_ifmap_wvalid;
wire [CLUSTER_IFMAP_ADDR_BITS-1:0] cluster_1_dma_0_ifmap_waddr;
wire [CLUSTER_IFMAP_WIDTH-1:0]   cluster_1_dma_0_ifmap_wdata;
wire                             cluster_1_dma_0_qact_wvalid;
wire [CLUSTER_QACT_ADDR_BITS-1:0] cluster_1_dma_0_qact_waddr;
wire [CLUSTER_QACT_WIDTH-1:0]    cluster_1_dma_0_qact_wdata;
wire                             cluster_1_dma_0_vcucode_wvalid;
wire [CLUSTER_VCUCODE_ADDR_BITS:0] cluster_1_dma_0_vcucode_waddr;
wire [CLUSTER_VCUCODE_WIDTH-1:0] cluster_1_dma_0_vcucode_wdata;
wire                             cluster_1_dma_0_vcupara_wvalid;
wire [CLUSTER_VCUPARA_ADDR_BITS:0] cluster_1_dma_0_vcupara_waddr;
wire [CLUSTER_VCUPARA_WIDTH-1:0] cluster_1_dma_0_vcupara_wdata;
wire                             cluster_1_dma_0_vcures_wvalid;
wire [CLUSTER_VCURES_ADDR_BITS-1:0] cluster_1_dma_0_vcures_waddr;
wire [CLUSTER_VCURES_WIDTH-1:0]  cluster_1_dma_0_vcures_wdata;
wire                             cluster_1_load_regfile_wvalid;
wire [31:0]                      cluster_1_load_regfile_waddr;
wire [31:0]                      cluster_1_load_regfile_wdata;

wire                             cluster_2_load_dma_rst_n;
wire                             cluster_2_enable_prof_counter;
wire                             cluster_2_load_0_local_done_wire;
wire                             cluster_2_load_1_local_done_wire;
wire                             cluster_2_load_0_global_done;
wire                             cluster_2_load_1_global_done;
wire [31:0]                      cluster_2_load_0_execute_time;
wire [31:0]                      cluster_2_load_1_execute_time;
wire                             cluster_2_dma_0_ifmap_wvalid;
wire [CLUSTER_IFMAP_ADDR_BITS-1:0] cluster_2_dma_0_ifmap_waddr;
wire [CLUSTER_IFMAP_WIDTH-1:0]   cluster_2_dma_0_ifmap_wdata;
wire                             cluster_2_dma_0_qact_wvalid;
wire [CLUSTER_QACT_ADDR_BITS-1:0] cluster_2_dma_0_qact_waddr;
wire [CLUSTER_QACT_WIDTH-1:0]    cluster_2_dma_0_qact_wdata;
wire                             cluster_2_dma_0_vcucode_wvalid;
wire [CLUSTER_VCUCODE_ADDR_BITS:0] cluster_2_dma_0_vcucode_waddr;
wire [CLUSTER_VCUCODE_WIDTH-1:0] cluster_2_dma_0_vcucode_wdata;
wire                             cluster_2_dma_0_vcupara_wvalid;
wire [CLUSTER_VCUPARA_ADDR_BITS:0] cluster_2_dma_0_vcupara_waddr;
wire [CLUSTER_VCUPARA_WIDTH-1:0] cluster_2_dma_0_vcupara_wdata;
wire                             cluster_2_dma_0_vcures_wvalid;
wire [CLUSTER_VCURES_ADDR_BITS-1:0] cluster_2_dma_0_vcures_waddr;
wire [CLUSTER_VCURES_WIDTH-1:0]  cluster_2_dma_0_vcures_wdata;
wire                             cluster_2_load_regfile_wvalid;
wire [31:0]                      cluster_2_load_regfile_waddr;
wire [31:0]                      cluster_2_load_regfile_wdata;

wire                             cluster_3_load_dma_rst_n;
wire                             cluster_3_enable_prof_counter;
wire                             cluster_3_load_0_local_done_wire;
wire                             cluster_3_load_1_local_done_wire;
wire                             cluster_3_load_0_global_done;
wire                             cluster_3_load_1_global_done;
wire [31:0]                      cluster_3_load_0_execute_time;
wire [31:0]                      cluster_3_load_1_execute_time;
wire                             cluster_3_dma_0_ifmap_wvalid;
wire [CLUSTER_IFMAP_ADDR_BITS-1:0] cluster_3_dma_0_ifmap_waddr;
wire [CLUSTER_IFMAP_WIDTH-1:0]   cluster_3_dma_0_ifmap_wdata;
wire                             cluster_3_dma_0_qact_wvalid;
wire [CLUSTER_QACT_ADDR_BITS-1:0] cluster_3_dma_0_qact_waddr;
wire [CLUSTER_QACT_WIDTH-1:0]    cluster_3_dma_0_qact_wdata;
wire                             cluster_3_dma_0_vcucode_wvalid;
wire [CLUSTER_VCUCODE_ADDR_BITS:0] cluster_3_dma_0_vcucode_waddr;
wire [CLUSTER_VCUCODE_WIDTH-1:0] cluster_3_dma_0_vcucode_wdata;
wire                             cluster_3_dma_0_vcupara_wvalid;
wire [CLUSTER_VCUPARA_ADDR_BITS:0] cluster_3_dma_0_vcupara_waddr;
wire [CLUSTER_VCUPARA_WIDTH-1:0] cluster_3_dma_0_vcupara_wdata;
wire                             cluster_3_dma_0_vcures_wvalid;
wire [CLUSTER_VCURES_ADDR_BITS-1:0] cluster_3_dma_0_vcures_waddr;
wire [CLUSTER_VCURES_WIDTH-1:0]  cluster_3_dma_0_vcures_wdata;
wire                             cluster_3_load_regfile_wvalid;
wire [31:0]                      cluster_3_load_regfile_waddr;
wire [31:0]                      cluster_3_load_regfile_wdata;


wire                             cluster_1_rvalid;
wire                             cluster_1_rready;
wire [31:0]                      cluster_1_raddr;
wire [31:0]                      cluster_1_rdata;

wire                             cluster_1_wvalid;
wire                             cluster_1_wready;
wire [31:0]                      cluster_1_waddr;
wire [31:0]                      cluster_1_wdata;

wire                             cluster_2_rvalid;
wire                             cluster_2_rready;
wire [31:0]                      cluster_2_raddr;
wire [31:0]                      cluster_2_rdata;

wire                             cluster_2_wvalid;
wire                             cluster_2_wready;
wire [31:0]                      cluster_2_waddr;
wire [31:0]                      cluster_2_wdata;

wire                             cluster_3_rvalid;
wire                             cluster_3_rready;
wire [31:0]                      cluster_3_raddr;
wire [31:0]                      cluster_3_rdata;

wire                             cluster_3_wvalid;
wire                             cluster_3_wready;
wire [31:0]                      cluster_3_waddr;
wire [31:0]                      cluster_3_wdata;

wire                             slv_regfile_rvalid;
wire                             slv_regfile_rready;
wire [31:0]                      slv_regfile_raddr;
wire [31:0]                      slv_regfile_rdata;

wire                             slv_regfile_wvalid;
wire                             slv_regfile_wready;
wire [31:0]                      slv_regfile_waddr;
wire [31:0]                      slv_regfile_wdata;

wire                             apb_regfile_rvalid;
wire                             apb_regfile_rready;
wire [31:0]                      apb_regfile_raddr;
wire [31:0]                      apb_regfile_rdata;

wire                             apb_regfile_wvalid;
wire                             apb_regfile_wready;
wire [31:0]                      apb_regfile_waddr;
wire [31:0]                      apb_regfile_wdata;

/* --------------------------------------------- highaddr sel --------------------------------------------- */

wire [HIGHADDR_BITS-1:0] local_highaddr;
wire [HIGHADDR_BITS-1:0] load_highaddr;
wire [HIGHADDR_BITS-1:0] store_highaddr;
wire                     load_highaddr_sel;
wire                     store_highaddr_sel;

/* -------------------------------------------- insn fifo write ------------------------------------------- */

wire                 load_0_fifo_wen;
wire [INSN_BITS-1:0] load_0_fifo_wdata;
wire                 load_0_fifo_ren;
wire [INSN_BITS-1:0] load_0_fifo_rdata;
wire                 load_0_fifo_empty;
wire                 load_0_fifo_full;

wire                 load_1_fifo_wen;
wire [INSN_BITS-1:0] load_1_fifo_wdata;
wire                 load_1_fifo_ren;
wire [INSN_BITS-1:0] load_1_fifo_rdata;
wire                 load_1_fifo_empty;
wire                 load_1_fifo_full;

wire                 load_2_fifo_wen;
wire [INSN_BITS-1:0] load_2_fifo_wdata;
wire                 load_2_fifo_ren;
wire [INSN_BITS-1:0] load_2_fifo_rdata;
wire                 load_2_fifo_empty;
wire                 load_2_fifo_full;

wire                 load_3_fifo_wen;
wire [INSN_BITS-1:0] load_3_fifo_wdata;
wire                 load_3_fifo_ren;
wire [INSN_BITS-1:0] load_3_fifo_rdata;
wire                 load_3_fifo_empty;
wire                 load_3_fifo_full;

wire                 load_4_fifo_wen;
wire [INSN_BITS-1:0] load_4_fifo_wdata;
wire                 load_4_fifo_ren;
wire [INSN_BITS-1:0] load_4_fifo_rdata;
wire                 load_4_fifo_empty;
wire                 load_4_fifo_full;

wire                 load_5_fifo_wen;
wire [INSN_BITS-1:0] load_5_fifo_wdata;
wire                 load_5_fifo_ren;
wire [INSN_BITS-1:0] load_5_fifo_rdata;
wire                 load_5_fifo_empty;
wire                 load_5_fifo_full;

wire                 load_6_fifo_wen;
wire [INSN_BITS-1:0] load_6_fifo_wdata;
wire                 load_6_fifo_ren;
wire [INSN_BITS-1:0] load_6_fifo_rdata;
wire                 load_6_fifo_empty;
wire                 load_6_fifo_full;

wire                 load_7_fifo_wen;
wire [INSN_BITS-1:0] load_7_fifo_wdata;
wire                 load_7_fifo_ren;
wire [INSN_BITS-1:0] load_7_fifo_rdata;
wire                 load_7_fifo_empty;
wire                 load_7_fifo_full;

wire                 store_0_fifo_wen;
wire [INSN_BITS-1:0] store_0_fifo_wdata;
wire                 store_0_fifo_ren;
wire [INSN_BITS-1:0] store_0_fifo_rdata;
wire                 store_0_fifo_empty;
wire                 store_0_fifo_full;

wire                 store_1_fifo_wen;
wire [INSN_BITS-1:0] store_1_fifo_wdata;
wire                 store_1_fifo_ren;
wire [INSN_BITS-1:0] store_1_fifo_rdata;
wire                 store_1_fifo_empty;
wire                 store_1_fifo_full;

wire                 store_2_fifo_wen;
wire [INSN_BITS-1:0] store_2_fifo_wdata;
wire                 store_2_fifo_ren;
wire [INSN_BITS-1:0] store_2_fifo_rdata;
wire                 store_2_fifo_empty;
wire                 store_2_fifo_full;

wire                 store_3_fifo_wen;
wire [INSN_BITS-1:0] store_3_fifo_wdata;
wire                 store_3_fifo_ren;
wire [INSN_BITS-1:0] store_3_fifo_rdata;
wire                 store_3_fifo_empty;
wire                 store_3_fifo_full;

wire                 store_4_fifo_wen;
wire [INSN_BITS-1:0] store_4_fifo_wdata;
wire                 store_4_fifo_ren;
wire [INSN_BITS-1:0] store_4_fifo_rdata;
wire                 store_4_fifo_empty;
wire                 store_4_fifo_full;

wire                 store_5_fifo_wen;
wire [INSN_BITS-1:0] store_5_fifo_wdata;
wire                 store_5_fifo_ren;
wire [INSN_BITS-1:0] store_5_fifo_rdata;
wire                 store_5_fifo_empty;
wire                 store_5_fifo_full;

wire                 store_6_fifo_wen;
wire [INSN_BITS-1:0] store_6_fifo_wdata;
wire                 store_6_fifo_ren;
wire [INSN_BITS-1:0] store_6_fifo_rdata;
wire                 store_6_fifo_empty;
wire                 store_6_fifo_full;

wire                 store_7_fifo_wen;
wire [INSN_BITS-1:0] store_7_fifo_wdata;
wire                 store_7_fifo_ren;
wire [INSN_BITS-1:0] store_7_fifo_rdata;
wire                 store_7_fifo_empty;
wire                 store_7_fifo_full;

wire                 pea_0_fifo_wen;
wire [INSN_BITS-1:0] pea_0_fifo_wdata;
wire                 pea_0_fifo_ren;
wire [INSN_BITS-1:0] pea_0_fifo_rdata;
wire                 pea_0_fifo_empty;
wire                 pea_0_fifo_full;

wire                 pea_1_fifo_wen;
wire [INSN_BITS-1:0] pea_1_fifo_wdata;
wire                 pea_1_fifo_ren;
wire [INSN_BITS-1:0] pea_1_fifo_rdata;
wire                 pea_1_fifo_empty;
wire                 pea_1_fifo_full;

wire                 pea_2_fifo_wen;
wire [INSN_BITS-1:0] pea_2_fifo_wdata;
wire                 pea_2_fifo_ren;
wire [INSN_BITS-1:0] pea_2_fifo_rdata;
wire                 pea_2_fifo_empty;
wire                 pea_2_fifo_full;

wire                 pea_3_fifo_wen;
wire [INSN_BITS-1:0] pea_3_fifo_wdata;
wire                 pea_3_fifo_ren;
wire [INSN_BITS-1:0] pea_3_fifo_rdata;
wire                 pea_3_fifo_empty;
wire                 pea_3_fifo_full;

wire                 pea_4_fifo_wen;
wire [INSN_BITS-1:0] pea_4_fifo_wdata;
wire                 pea_4_fifo_ren;
wire [INSN_BITS-1:0] pea_4_fifo_rdata;
wire                 pea_4_fifo_empty;
wire                 pea_4_fifo_full;

wire                 pea_5_fifo_wen;
wire [INSN_BITS-1:0] pea_5_fifo_wdata;
wire                 pea_5_fifo_ren;
wire [INSN_BITS-1:0] pea_5_fifo_rdata;
wire                 pea_5_fifo_empty;
wire                 pea_5_fifo_full;

wire                 pea_6_fifo_wen;
wire [INSN_BITS-1:0] pea_6_fifo_wdata;
wire                 pea_6_fifo_ren;
wire [INSN_BITS-1:0] pea_6_fifo_rdata;
wire                 pea_6_fifo_empty;
wire                 pea_6_fifo_full;

wire                 pea_7_fifo_wen;
wire [INSN_BITS-1:0] pea_7_fifo_wdata;
wire                 pea_7_fifo_ren;
wire [INSN_BITS-1:0] pea_7_fifo_rdata;
wire                 pea_7_fifo_empty;
wire                 pea_7_fifo_full;

wire                 vcu_0_fifo_wen;
wire [INSN_BITS-1:0] vcu_0_fifo_wdata;
wire                 vcu_0_fifo_ren;
wire [INSN_BITS-1:0] vcu_0_fifo_rdata;
wire                 vcu_0_fifo_empty;
wire                 vcu_0_fifo_full;

wire                 vcu_1_fifo_wen;
wire [INSN_BITS-1:0] vcu_1_fifo_wdata;
wire                 vcu_1_fifo_ren;
wire [INSN_BITS-1:0] vcu_1_fifo_rdata;
wire                 vcu_1_fifo_empty;
wire                 vcu_1_fifo_full;

wire                 vcu_2_fifo_wen;
wire [INSN_BITS-1:0] vcu_2_fifo_wdata;
wire                 vcu_2_fifo_ren;
wire [INSN_BITS-1:0] vcu_2_fifo_rdata;
wire                 vcu_2_fifo_empty;
wire                 vcu_2_fifo_full;

wire                 vcu_3_fifo_wen;
wire [INSN_BITS-1:0] vcu_3_fifo_wdata;
wire                 vcu_3_fifo_ren;
wire [INSN_BITS-1:0] vcu_3_fifo_rdata;
wire                 vcu_3_fifo_empty;
wire                 vcu_3_fifo_full;

wire                 vcu_4_fifo_wen;
wire [INSN_BITS-1:0] vcu_4_fifo_wdata;
wire                 vcu_4_fifo_ren;
wire [INSN_BITS-1:0] vcu_4_fifo_rdata;
wire                 vcu_4_fifo_empty;
wire                 vcu_4_fifo_full;

wire                 vcu_5_fifo_wen;
wire [INSN_BITS-1:0] vcu_5_fifo_wdata;
wire                 vcu_5_fifo_ren;
wire [INSN_BITS-1:0] vcu_5_fifo_rdata;
wire                 vcu_5_fifo_empty;
wire                 vcu_5_fifo_full;

wire                 vcu_6_fifo_wen;
wire [INSN_BITS-1:0] vcu_6_fifo_wdata;
wire                 vcu_6_fifo_ren;
wire [INSN_BITS-1:0] vcu_6_fifo_rdata;
wire                 vcu_6_fifo_empty;
wire                 vcu_6_fifo_full;

wire                 vcu_7_fifo_wen;
wire [INSN_BITS-1:0] vcu_7_fifo_wdata;
wire                 vcu_7_fifo_ren;
wire [INSN_BITS-1:0] vcu_7_fifo_rdata;
wire                 vcu_7_fifo_empty;
wire                 vcu_7_fifo_full;

wire                 synchronize_fifo_wen;
wire [INSN_BITS-1:0] synchronize_fifo_wdata;
wire                 synchronize_fifo_ren;
wire [INSN_BITS-1:0] synchronize_fifo_rdata;
wire                 synchronize_fifo_empty;
wire                 synchronize_fifo_full;

/* -------------------------------------------- work_en & done -------------------------------------------- */

wire load_0_work_en;
wire load_1_work_en;
wire load_2_work_en;
wire load_3_work_en;
wire load_4_work_en;
wire load_5_work_en;
wire load_6_work_en;
wire load_7_work_en;

wire store_0_work_en;
wire store_1_work_en;
wire store_2_work_en;
wire store_3_work_en;
wire store_4_work_en;
wire store_5_work_en;
wire store_6_work_en;
wire store_7_work_en;

wire pea_0_work_en;
wire pea_1_work_en;
wire pea_2_work_en;
wire pea_3_work_en;
wire pea_4_work_en;
wire pea_5_work_en;
wire pea_6_work_en;
wire pea_7_work_en;

wire vcu_0_work_en;
wire vcu_1_work_en;
wire vcu_2_work_en;
wire vcu_3_work_en;
wire vcu_4_work_en;
wire vcu_5_work_en;
wire vcu_6_work_en;
wire vcu_7_work_en;

wire load_0_local_done;
wire load_1_local_done;
wire load_2_local_done;
wire load_3_local_done;
wire load_4_local_done;
wire load_5_local_done;
wire load_6_local_done;
wire load_7_local_done;

wire store_1_local_done;
wire store_2_local_done;
wire store_3_local_done;
wire store_4_local_done;
wire store_5_local_done;
wire store_6_local_done;
wire store_7_local_done;

wire pea_0_done;
wire pea_1_done;
wire pea_2_done;
wire pea_3_done;
wire pea_4_done;
wire pea_5_done;
wire pea_6_done;
wire pea_7_done;

wire vcu_0_done;
wire vcu_1_done;
wire vcu_2_done;
wire vcu_3_done;
wire vcu_4_done;
wire vcu_5_done;
wire vcu_6_done;
wire vcu_7_done;

/* --------------------------------------------- debug signal --------------------------------------------- */

wire        dispatch_empty;
wire        dispatch_insn_done;
wire [63:0] cib_irq_highaddr;
wire [31:0] pcie_highaddr;
wire        pcie_irq_enable;
wire        cib_irq_enable;
wire        pcie_highaddr_config_done;

wire [31:0] insn_fifo_empty_debug;
reg  [31:0] insn_fifo_empty_debug_reg;
wire [31:0] insn_fifo_full_debug;
reg  [31:0] insn_fifo_full_debug_reg;
wire [31:0] collect_done;
reg  [31:0] collect_done_reg;
wire [31:0] word_cnt_debug;
wire [31:0] word_reg_debug;
wire [31:0] done_reg_debug;

/* -------------------------------------------- control signal -------------------------------------------- */

wire [31:0] insn_number;
wire [63:0] insn_addr;
wire [31:0] insn_burst_length;
wire [31:0] control;
wire        cmd_start;
wire        cmd_rst;

/* ------------------------------------------------- reset ------------------------------------------------ */

wire        cmd_rst_0;
wire        cmd_rst_1;
wire        cmd_rst_2;
wire        cmd_rst_3;

wire        apb_rst_n;
wire        dispatch_rst_n;
wire        sync_rst_n;

/* -------------------------------------------------------------------------------------------------------- */
/*                                                    apb                                                   */
/* -------------------------------------------------------------------------------------------------------- */

apb4_slave u_apb4_slave(
  .pclk             ( apb4_pclk             ),
  .presetn          ( apb4_presetn          ),
  .paddr            ( apb4_paddr            ),
  .psel             ( apb4_psel             ),
  .penable          ( apb4_penable          ),
  .pwrite           ( apb4_pwrite           ),
  .pwdata           ( apb4_pwdata           ),
  .pstrb            ( apb4_pstrb            ),
  .pprot            ( apb4_pprot            ),
  .clk              ( clk                   ),
  .logic_rst_n      ( apb_rst_n             ),
  .fifo_rst_n       ( rst_n                 ),
  .sram_rready      ( apb_regfile_rready    ),
  .sram_rdata       ( apb_regfile_rdata     ),
  .sram_wready      ( apb_regfile_wready    ),
  .pready           ( apb4_pready           ),
  .prdata           ( apb4_prdata           ),
  .pslverr          ( apb4_pslverr          ),
  .sram_raddr       ( apb_regfile_raddr     ),
  .sram_rvalid      ( apb_regfile_rvalid    ),
  .sram_waddr       ( apb_regfile_waddr     ),
  .sram_wvalid      ( apb_regfile_wvalid    ),
  .sram_wdata       ( apb_regfile_wdata     )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                   reset                                                  */
/* -------------------------------------------------------------------------------------------------------- */

rst_top u_rst_top (
  .clk             ( clk             ),
  .rst_n           ( rst_n           ),
  .rst_soft        ( cmd_rst         ),
  .cmd_rst_0       ( cmd_rst_0       ),
  .cmd_rst_1       ( cmd_rst_1       ),
  .cmd_rst_2       ( cmd_rst_2       ),
  .cmd_rst_3       ( cmd_rst_3       ),
  .dispatch_rst_n  ( dispatch_rst_n  ),
  .apb_rst_n       ( apb_rst_n       ),
  .sync_rst_n      ( sync_rst_n      )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 Dispatch                                                 */
/* -------------------------------------------------------------------------------------------------------- */
dispatch_top #(
  .AXI_M_AXI_MIN_ID ( 0  ),
  .AXI_M_AXI_MAX_ID ( 64 )
) u_dispatch_top(
  .clk                     ( clk                    ),
  .logic_rst_n             ( dispatch_rst_n         ),
  .fifo_rst_n              ( rst_n                  ),
  .axi4_clk                ( axi4_clk               ),
  .axi4_rst_n              ( axi4_rst_n             ),
  .axi4_full_M_AXI_ARREADY ( insn_M_AXI_ARREADY     ),
  .axi4_full_M_AXI_RID     ( insn_M_AXI_RID         ),
  .axi4_full_M_AXI_RDATA   ( insn_M_AXI_RDATA       ),
  .axi4_full_M_AXI_RRESP   ( insn_M_AXI_RRESP       ),
  .axi4_full_M_AXI_RLAST   ( insn_M_AXI_RLAST       ),
  .axi4_full_M_AXI_RUSER   ( insn_M_AXI_RUSER       ),
  .axi4_full_M_AXI_RVALID  ( insn_M_AXI_RVALID      ),
  .axi4_full_M_AXI_AWREADY ( insn_M_AXI_AWREADY     ),
  .axi4_full_M_AXI_WREADY  ( insn_M_AXI_WREADY      ),
  .axi4_full_M_AXI_BID     ( insn_M_AXI_BID         ),
  .axi4_full_M_AXI_BRESP   ( insn_M_AXI_BRESP       ),
  .axi4_full_M_AXI_BUSER   ( insn_M_AXI_BUSER       ),
  .axi4_full_M_AXI_BVALID  ( insn_M_AXI_BVALID      ),
  .insn_number             ( insn_number            ),
  .insn_addr               ( insn_addr              ),
  .insn_burstlen           ( insn_burst_length[7:0] ),
  .config_start            ( control                ),
  .cmd_start               ( cmd_start              ),
  .synchronize_fifo_full   ( synchronize_fifo_full  ),
  .load_0_fifo_full        ( load_0_fifo_full       ),
  .load_1_fifo_full        ( load_1_fifo_full       ),
  .load_2_fifo_full        ( load_2_fifo_full       ),
  .load_3_fifo_full        ( load_3_fifo_full       ),
  .load_4_fifo_full        ( load_4_fifo_full       ),
  .load_5_fifo_full        ( load_5_fifo_full       ),
  .load_6_fifo_full        ( load_6_fifo_full       ),
  .load_7_fifo_full        ( load_7_fifo_full       ),
  .pea_0_fifo_full         ( pea_0_fifo_full        ),
  .pea_1_fifo_full         ( pea_1_fifo_full        ),
  .pea_2_fifo_full         ( pea_2_fifo_full        ),
  .pea_3_fifo_full         ( pea_3_fifo_full        ),
  .pea_4_fifo_full         ( pea_4_fifo_full        ),
  .pea_5_fifo_full         ( pea_5_fifo_full        ),
  .pea_6_fifo_full         ( pea_6_fifo_full        ),
  .pea_7_fifo_full         ( pea_7_fifo_full        ),
  .vcu_0_fifo_full         ( vcu_0_fifo_full        ),
  .vcu_1_fifo_full         ( vcu_1_fifo_full        ),
  .vcu_2_fifo_full         ( vcu_2_fifo_full        ),
  .vcu_3_fifo_full         ( vcu_3_fifo_full        ),
  .vcu_4_fifo_full         ( vcu_4_fifo_full        ),
  .vcu_5_fifo_full         ( vcu_5_fifo_full        ),
  .vcu_6_fifo_full         ( vcu_6_fifo_full        ),
  .vcu_7_fifo_full         ( vcu_7_fifo_full        ),
  .store_0_fifo_full       ( store_0_fifo_full      ),
  .store_1_fifo_full       ( store_1_fifo_full      ),
  .store_2_fifo_full       ( store_2_fifo_full      ),
  .store_3_fifo_full       ( store_3_fifo_full      ),
  .store_4_fifo_full       ( store_4_fifo_full      ),
  .store_5_fifo_full       ( store_5_fifo_full      ),
  .store_6_fifo_full       ( store_6_fifo_full      ),
  .store_7_fifo_full       ( store_7_fifo_full      ),
  .axi4_full_M_AXI_ARID    ( insn_M_AXI_ARID        ),
  .axi4_full_M_AXI_ARADDR  ( insn_M_AXI_ARADDR      ),
  .axi4_full_M_AXI_ARLEN   ( insn_M_AXI_ARLEN       ),
  .axi4_full_M_AXI_ARSIZE  ( insn_M_AXI_ARSIZE      ),
  .axi4_full_M_AXI_ARBURST ( insn_M_AXI_ARBURST     ),
  .axi4_full_M_AXI_ARLOCK  ( insn_M_AXI_ARLOCK      ),
  .axi4_full_M_AXI_ARCACHE ( insn_M_AXI_ARCACHE     ),
  .axi4_full_M_AXI_ARPROT  ( insn_M_AXI_ARPROT      ),
  .axi4_full_M_AXI_ARQOS   ( insn_M_AXI_ARQOS       ),
  .axi4_full_M_AXI_ARUSER  ( insn_M_AXI_ARUSER      ),
  .axi4_full_M_AXI_ARVALID ( insn_M_AXI_ARVALID     ),
  .axi4_full_M_AXI_RREADY  ( insn_M_AXI_RREADY      ),
  .axi4_full_M_AXI_AWID    ( insn_M_AXI_AWID        ),
  .axi4_full_M_AXI_AWADDR  ( insn_M_AXI_AWADDR      ),
  .axi4_full_M_AXI_AWLEN   ( insn_M_AXI_AWLEN       ),
  .axi4_full_M_AXI_AWSIZE  ( insn_M_AXI_AWSIZE      ),
  .axi4_full_M_AXI_AWBURST ( insn_M_AXI_AWBURST     ),
  .axi4_full_M_AXI_AWLOCK  ( insn_M_AXI_AWLOCK      ),
  .axi4_full_M_AXI_AWCACHE ( insn_M_AXI_AWCACHE     ),
  .axi4_full_M_AXI_AWPROT  ( insn_M_AXI_AWPROT      ),
  .axi4_full_M_AXI_AWQOS   ( insn_M_AXI_AWQOS       ),
  .axi4_full_M_AXI_AWUSER  ( insn_M_AXI_AWUSER      ),
  .axi4_full_M_AXI_AWVALID ( insn_M_AXI_AWVALID     ),
  .axi4_full_M_AXI_WDATA   ( insn_M_AXI_WDATA       ),
  .axi4_full_M_AXI_WSTRB   ( insn_M_AXI_WSTRB       ),
  .axi4_full_M_AXI_WLAST   ( insn_M_AXI_WLAST       ),
  .axi4_full_M_AXI_WUSER   ( insn_M_AXI_WUSER       ),
  .axi4_full_M_AXI_WVALID  ( insn_M_AXI_WVALID      ),
  .axi4_full_M_AXI_BREADY  ( insn_M_AXI_BREADY      ),
  .dispatch_empty          ( dispatch_empty         ),
  .insn_done               ( dispatch_insn_done     ),
  .synchronize_fifo_wen    ( synchronize_fifo_wen   ),
  .synchronize_fifo_wdata  ( synchronize_fifo_wdata ),
  .load_0_fifo_wen         ( load_0_fifo_wen        ),
  .load_0_fifo_wdata       ( load_0_fifo_wdata      ),
  .load_1_fifo_wen         ( load_1_fifo_wen        ),
  .load_1_fifo_wdata       ( load_1_fifo_wdata      ),
  .load_2_fifo_wen         ( load_2_fifo_wen        ),
  .load_2_fifo_wdata       ( load_2_fifo_wdata      ),
  .load_3_fifo_wen         ( load_3_fifo_wen        ),
  .load_3_fifo_wdata       ( load_3_fifo_wdata      ),
  .load_4_fifo_wen         ( load_4_fifo_wen        ),
  .load_4_fifo_wdata       ( load_4_fifo_wdata      ),
  .load_5_fifo_wen         ( load_5_fifo_wen        ),
  .load_5_fifo_wdata       ( load_5_fifo_wdata      ),
  .load_6_fifo_wen         ( load_6_fifo_wen        ),
  .load_6_fifo_wdata       ( load_6_fifo_wdata      ),
  .load_7_fifo_wen         ( load_7_fifo_wen        ),
  .load_7_fifo_wdata       ( load_7_fifo_wdata      ),
  .pea_0_fifo_wen          ( pea_0_fifo_wen         ),
  .pea_1_fifo_wen          ( pea_1_fifo_wen         ),
  .pea_2_fifo_wen          ( pea_2_fifo_wen         ),
  .pea_3_fifo_wen          ( pea_3_fifo_wen         ),
  .pea_4_fifo_wen          ( pea_4_fifo_wen         ),
  .pea_5_fifo_wen          ( pea_5_fifo_wen         ),
  .pea_6_fifo_wen          ( pea_6_fifo_wen         ),
  .pea_7_fifo_wen          ( pea_7_fifo_wen         ),
  .pea_0_fifo_wdata        ( pea_0_fifo_wdata       ),
  .pea_1_fifo_wdata        ( pea_1_fifo_wdata       ),
  .pea_2_fifo_wdata        ( pea_2_fifo_wdata       ),
  .pea_3_fifo_wdata        ( pea_3_fifo_wdata       ),
  .pea_4_fifo_wdata        ( pea_4_fifo_wdata       ),
  .pea_5_fifo_wdata        ( pea_5_fifo_wdata       ),
  .pea_6_fifo_wdata        ( pea_6_fifo_wdata       ),
  .pea_7_fifo_wdata        ( pea_7_fifo_wdata       ),
  .vcu_0_fifo_wen          ( vcu_0_fifo_wen         ),
  .vcu_1_fifo_wen          ( vcu_1_fifo_wen         ),
  .vcu_2_fifo_wen          ( vcu_2_fifo_wen         ),
  .vcu_3_fifo_wen          ( vcu_3_fifo_wen         ),
  .vcu_4_fifo_wen          ( vcu_4_fifo_wen         ),
  .vcu_5_fifo_wen          ( vcu_5_fifo_wen         ),
  .vcu_6_fifo_wen          ( vcu_6_fifo_wen         ),
  .vcu_7_fifo_wen          ( vcu_7_fifo_wen         ),
  .vcu_0_fifo_wdata        ( vcu_0_fifo_wdata       ),
  .vcu_1_fifo_wdata        ( vcu_1_fifo_wdata       ),
  .vcu_2_fifo_wdata        ( vcu_2_fifo_wdata       ),
  .vcu_3_fifo_wdata        ( vcu_3_fifo_wdata       ),
  .vcu_4_fifo_wdata        ( vcu_4_fifo_wdata       ),
  .vcu_5_fifo_wdata        ( vcu_5_fifo_wdata       ),
  .vcu_6_fifo_wdata        ( vcu_6_fifo_wdata       ),
  .vcu_7_fifo_wdata        ( vcu_7_fifo_wdata       ),
  .store_0_fifo_wen        ( store_0_fifo_wen       ),
  .store_0_fifo_wdata      ( store_0_fifo_wdata     ),
  .store_1_fifo_wen        ( store_1_fifo_wen       ),
  .store_1_fifo_wdata      ( store_1_fifo_wdata     ),
  .store_2_fifo_wen        ( store_2_fifo_wen       ),
  .store_2_fifo_wdata      ( store_2_fifo_wdata     ),
  .store_3_fifo_wen        ( store_3_fifo_wen       ),
  .store_3_fifo_wdata      ( store_3_fifo_wdata     ),
  .store_4_fifo_wen        ( store_4_fifo_wen       ),
  .store_4_fifo_wdata      ( store_4_fifo_wdata     ),
  .store_5_fifo_wen        ( store_5_fifo_wen       ),
  .store_5_fifo_wdata      ( store_5_fifo_wdata     ),
  .store_6_fifo_wen        ( store_6_fifo_wen       ),
  .store_6_fifo_wdata      ( store_6_fifo_wdata     ),
  .store_7_fifo_wen        ( store_7_fifo_wen       ),
  .store_7_fifo_wdata      ( store_7_fifo_wdata     ),
  .cib_irq_enable          ( cib_irq_enable         ),
  .cib_irq_highaddr        ( cib_irq_highaddr       ),
  .local_highaddr          ( local_highaddr         ),
  .npu_done                ( global_done            )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Synchronize                                               */
/* -------------------------------------------------------------------------------------------------------- */

insn_fifo #(
  .width ( INSN_WIDTH      ),
  .depth ( INSN_FIFO_DEPTH )
) u_synchoronize_insn_fifo(
  .clk      ( clk                    ),
  .rst_n    ( rst_n                  ),
  .w_en     ( synchronize_fifo_wen   ),
  .r_en     ( synchronize_fifo_ren   ),
  .w_data   ( synchronize_fifo_wdata ),
  .full     (                        ),
  .empty    ( synchronize_fifo_empty ),
  .afull    ( synchronize_fifo_full  ),
  .aempty   (                        ),
  .hfull    (                        ),
  .hempty   (                        ),
  .r_data   ( synchronize_fifo_rdata ),
  .capacity (                        )
);

synchronize u_synchronize(
  .clk                        ( clk                        ),
  .rst_n                      ( sync_rst_n                 ),
  .cmd_start                  ( cmd_start                  ),
  .sync_insn_ready            ( !synchronize_fifo_empty    ),
  .sync_insn                  ( synchronize_fifo_rdata     ),
  .collect_insn_ready         ( ~insn_fifo_empty_debug_reg ),
  .collect_done               ( collect_done_reg           ),
  .sync_insn_read             ( synchronize_fifo_ren       ),
  .collect_worken             ( {vcu_7_work_en,
                                 vcu_6_work_en,
                                 vcu_5_work_en,
                                 vcu_4_work_en,
                                 vcu_3_work_en,
                                 vcu_2_work_en,
                                 vcu_1_work_en,
                                 vcu_0_work_en,
                                 pea_7_work_en, 
                                 pea_6_work_en, 
                                 pea_5_work_en, 
                                 pea_4_work_en, 
                                 pea_3_work_en, 
                                 pea_2_work_en, 
                                 pea_1_work_en, 
                                 pea_0_work_en,
                                 store_7_work_en,
                                 store_6_work_en,
                                 store_5_work_en,
                                 store_4_work_en,
                                 store_3_work_en,
                                 store_2_work_en,
                                 store_1_work_en,
                                 store_0_work_en,
                                 load_7_work_en,
                                 load_6_work_en,
                                 load_5_work_en,
                                 load_4_work_en,
                                 load_3_work_en,
                                 load_2_work_en,
                                 load_1_work_en,
                                 load_0_work_en}           ),
  .load_highaddr_sync         ( load_highaddr              ),
  .load_highaddr_sel          ( load_highaddr_sel          ),
  .store_highaddr_sync        ( store_highaddr             ),
  .store_highaddr_sel         ( store_highaddr_sel         ),
  .word_cnt_debug             ( word_cnt_debug             ),
  .done_reg_debug             ( done_reg_debug             ),
  .word_reg_debug             ( word_reg_debug             )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 Clusters                                                 */
/* -------------------------------------------------------------------------------------------------------- */

npu_cluster #(
  .AXI_M_AXI_MIN_ID ( 64               ),
  .WEIGHT_BANK      ( WEIGHT_BANK      ),
  .WEIGHT_WIDTH     ( WEIGHT_WIDTH     ),
  .WEIGHT_ADDR_BITS ( WEIGHT_ADDR_BITS ),
  .IFMAP_WIDTH      ( CLUSTER_IFMAP_WIDTH       ),
  .QACT_WIDTH       ( CLUSTER_QACT_WIDTH        ),
  .VCUCODE_WIDTH    ( CLUSTER_VCUCODE_WIDTH     ),
  .VCUPARA_WIDTH    ( CLUSTER_VCUPARA_WIDTH     ),
  .VCULUT_WIDTH     ( CLUSTER_VCULUT_WIDTH      ),
  .VCURES_WIDTH     ( CLUSTER_VCURES_WIDTH      ),
  .IFMAP_ADDR_BITS  ( CLUSTER_IFMAP_ADDR_BITS   ),
  .QACT_ADDR_BITS   ( CLUSTER_QACT_ADDR_BITS    ),
  .VCUCODE_ADDR_BITS( CLUSTER_VCUCODE_ADDR_BITS ),
  .VCUPARA_ADDR_BITS( CLUSTER_VCUPARA_ADDR_BITS ),
  .VCULUT_ADDR_BITS ( CLUSTER_VCULUT_ADDR_BITS  ),
  .VCURES_ADDR_BITS ( CLUSTER_VCURES_ADDR_BITS  )
) u_npu_cluster_0(
  .dma_0_M_AXI_AWREADY  ( cluster_0_dma_0_M_AXI_AWREADY ),
  .dma_0_M_AXI_WREADY   ( cluster_0_dma_0_M_AXI_WREADY  ),
  .dma_0_M_AXI_BID      ( cluster_0_dma_0_M_AXI_BID     ),
  .dma_0_M_AXI_BRESP    ( cluster_0_dma_0_M_AXI_BRESP   ),
  .dma_0_M_AXI_BUSER    ( cluster_0_dma_0_M_AXI_BUSER   ),
  .dma_0_M_AXI_BVALID   ( cluster_0_dma_0_M_AXI_BVALID  ),
  .dma_0_M_AXI_AWID     ( cluster_0_dma_0_M_AXI_AWID    ),
  .dma_0_M_AXI_AWADDR   ( cluster_0_dma_0_M_AXI_AWADDR  ),
  .dma_0_M_AXI_AWLEN    ( cluster_0_dma_0_M_AXI_AWLEN   ),
  .dma_0_M_AXI_AWSIZE   ( cluster_0_dma_0_M_AXI_AWSIZE  ),
  .dma_0_M_AXI_AWBURST  ( cluster_0_dma_0_M_AXI_AWBURST ),
  .dma_0_M_AXI_AWLOCK   ( cluster_0_dma_0_M_AXI_AWLOCK  ),
  .dma_0_M_AXI_AWCACHE  ( cluster_0_dma_0_M_AXI_AWCACHE ),
  .dma_0_M_AXI_AWPROT   ( cluster_0_dma_0_M_AXI_AWPROT  ),
  .dma_0_M_AXI_AWQOS    ( cluster_0_dma_0_M_AXI_AWQOS   ),
  .dma_0_M_AXI_AWUSER   ( cluster_0_dma_0_M_AXI_AWUSER  ),
  .dma_0_M_AXI_AWVALID  ( cluster_0_dma_0_M_AXI_AWVALID ),
  .dma_0_M_AXI_WDATA    ( cluster_0_dma_0_M_AXI_WDATA   ),
  .dma_0_M_AXI_WSTRB    ( cluster_0_dma_0_M_AXI_WSTRB   ),
  .dma_0_M_AXI_WLAST    ( cluster_0_dma_0_M_AXI_WLAST   ),
  .dma_0_M_AXI_WUSER    ( cluster_0_dma_0_M_AXI_WUSER   ),
  .dma_0_M_AXI_WVALID   ( cluster_0_dma_0_M_AXI_WVALID  ),
  .dma_0_M_AXI_BREADY   ( cluster_0_dma_0_M_AXI_BREADY  ),

  .dma_1_M_AXI_AWREADY  ( cluster_0_dma_1_M_AXI_AWREADY ),
  .dma_1_M_AXI_WREADY   ( cluster_0_dma_1_M_AXI_WREADY  ),
  .dma_1_M_AXI_BID      ( cluster_0_dma_1_M_AXI_BID     ),
  .dma_1_M_AXI_BRESP    ( cluster_0_dma_1_M_AXI_BRESP   ),
  .dma_1_M_AXI_BUSER    ( cluster_0_dma_1_M_AXI_BUSER   ),
  .dma_1_M_AXI_BVALID   ( cluster_0_dma_1_M_AXI_BVALID  ),
  .dma_1_M_AXI_AWID     ( cluster_0_dma_1_M_AXI_AWID    ),
  .dma_1_M_AXI_AWADDR   ( cluster_0_dma_1_M_AXI_AWADDR  ),
  .dma_1_M_AXI_AWLEN    ( cluster_0_dma_1_M_AXI_AWLEN   ),
  .dma_1_M_AXI_AWSIZE   ( cluster_0_dma_1_M_AXI_AWSIZE  ),
  .dma_1_M_AXI_AWBURST  ( cluster_0_dma_1_M_AXI_AWBURST ),
  .dma_1_M_AXI_AWLOCK   ( cluster_0_dma_1_M_AXI_AWLOCK  ),
  .dma_1_M_AXI_AWCACHE  ( cluster_0_dma_1_M_AXI_AWCACHE ),
  .dma_1_M_AXI_AWPROT   ( cluster_0_dma_1_M_AXI_AWPROT  ),
  .dma_1_M_AXI_AWQOS    ( cluster_0_dma_1_M_AXI_AWQOS   ),
  .dma_1_M_AXI_AWUSER   ( cluster_0_dma_1_M_AXI_AWUSER  ),
  .dma_1_M_AXI_AWVALID  ( cluster_0_dma_1_M_AXI_AWVALID ),
  .dma_1_M_AXI_WDATA    ( cluster_0_dma_1_M_AXI_WDATA   ),
  .dma_1_M_AXI_WSTRB    ( cluster_0_dma_1_M_AXI_WSTRB   ),
  .dma_1_M_AXI_WLAST    ( cluster_0_dma_1_M_AXI_WLAST   ),
  .dma_1_M_AXI_WUSER    ( cluster_0_dma_1_M_AXI_WUSER   ),
  .dma_1_M_AXI_WVALID   ( cluster_0_dma_1_M_AXI_WVALID  ),
  .dma_1_M_AXI_BREADY   ( cluster_0_dma_1_M_AXI_BREADY  ),

  .slv_regfile_wvalid   ( cluster_0_wvalid              ),
  .slv_regfile_wready   (               ),
  .slv_regfile_waddr    ( cluster_0_waddr               ),
  .slv_regfile_wdata    ( cluster_0_wdata               ),
  .slv_regfile_rvalid   ( cluster_0_rvalid              ),
  .slv_regfile_rready   ( cluster_0_rready              ),
  .slv_regfile_raddr    ( cluster_0_raddr               ),
  .slv_regfile_rdata    ( cluster_0_rdata               ),

  .store_0_fifo_wen     ( store_0_fifo_wen              ),
  .store_0_fifo_wdata   ( store_0_fifo_wdata            ),
  .store_0_fifo_full    ( store_0_fifo_full             ),
  .store_0_fifo_empty   ( store_0_fifo_empty            ),
  .store_1_fifo_wen     ( store_1_fifo_wen              ),
  .store_1_fifo_wdata   ( store_1_fifo_wdata            ),
  .store_1_fifo_full    ( store_1_fifo_full             ),
  .store_1_fifo_empty   ( store_1_fifo_empty            ),
  .pea_0_fifo_wen       ( pea_0_fifo_wen                ),
  .pea_0_fifo_wdata     ( pea_0_fifo_wdata              ),
  .pea_0_fifo_full      ( pea_0_fifo_full               ),
  .pea_0_fifo_empty     ( pea_0_fifo_empty              ),
  .pea_1_fifo_wen       ( pea_1_fifo_wen                ),
  .pea_1_fifo_wdata     ( pea_1_fifo_wdata              ),
  .pea_1_fifo_full      ( pea_1_fifo_full               ),
  .pea_1_fifo_empty     ( pea_1_fifo_empty              ),
  .vcu_0_fifo_wen       ( vcu_0_fifo_wen                ),
  .vcu_0_fifo_wdata     ( vcu_0_fifo_wdata              ),
  .vcu_0_fifo_full      ( vcu_0_fifo_full               ),
  .vcu_0_fifo_empty     ( vcu_0_fifo_empty              ),
  .vcu_1_fifo_wen       ( vcu_1_fifo_wen                ),
  .vcu_1_fifo_wdata     ( vcu_1_fifo_wdata              ),
  .vcu_1_fifo_full      ( vcu_1_fifo_full               ),
  .vcu_1_fifo_empty     ( vcu_1_fifo_empty              ),

  .load_0_work_en       ( load_0_work_en                ),
  .load_1_work_en       ( load_1_work_en                ),
  .store_0_work_en      ( store_0_work_en               ),
  .store_1_work_en      ( store_1_work_en               ),
  .pea_0_work_en        ( pea_0_work_en                 ),
  .pea_1_work_en        ( pea_1_work_en                 ),
  .vcu_0_work_en        ( vcu_0_work_en                 ),
  .vcu_1_work_en        ( vcu_1_work_en                 ),

  .load_0_local_done    ( load_0_local_done             ),
  .load_1_local_done    ( load_1_local_done             ),
  .store_0_local_done   ( store_0_local_done            ),
  .store_1_local_done   ( store_1_local_done            ),
  .pea_0_done           ( pea_0_done                    ),
  .pea_1_done           ( pea_1_done                    ),
  .vcu_0_done           ( vcu_0_done                    ),
  .vcu_1_done           ( vcu_1_done                    ),

  .global_done          ( cluster_0_done                ),

  .weight_sram_rvalid   ( weight_0_rvalid               ),
  .weight_sram_raddr    ( weight_0_raddr                ),
  .weight_sram_rdata    ( weight_0_rdata                ),

  .load_0_local_done_wire ( cluster_0_load_0_local_done_wire ),
  .load_1_local_done_wire ( cluster_0_load_1_local_done_wire ),
  .load_0_global_done   ( cluster_0_load_0_global_done  ),
  .load_1_global_done   ( cluster_0_load_1_global_done  ),
  .load_0_execute_time  ( cluster_0_load_0_execute_time ),
  .load_1_execute_time  ( cluster_0_load_1_execute_time ),
  .load_dma_rst_n       ( cluster_0_load_dma_rst_n      ),
  .enable_prof_counter  ( cluster_0_enable_prof_counter ),
  .dma_0_ifmap_sram_wvalid ( cluster_0_dma_0_ifmap_wvalid ),
  .dma_0_ifmap_sram_waddr  ( cluster_0_dma_0_ifmap_waddr  ),
  .dma_0_ifmap_sram_wdata  ( cluster_0_dma_0_ifmap_wdata  ),
  .dma_0_qact_wvalid       ( cluster_0_dma_0_qact_wvalid  ),
  .dma_0_qact_waddr        ( cluster_0_dma_0_qact_waddr   ),
  .dma_0_qact_wdata        ( cluster_0_dma_0_qact_wdata   ),
  .dma_0_vcucode_sram_wvalid ( cluster_0_dma_0_vcucode_wvalid ),
  .dma_0_vcucode_sram_waddr  ( cluster_0_dma_0_vcucode_waddr  ),
  .dma_0_vcucode_sram_wdata  ( cluster_0_dma_0_vcucode_wdata  ),
  .dma_0_vcupara_sram_wvalid ( cluster_0_dma_0_vcupara_wvalid ),
  .dma_0_vcupara_sram_waddr  ( cluster_0_dma_0_vcupara_waddr  ),
  .dma_0_vcupara_sram_wdata  ( cluster_0_dma_0_vcupara_wdata  ),
  .dma_0_vcures_sram_wvalid  ( cluster_0_dma_0_vcures_wvalid  ),
  .dma_0_vcures_sram_waddr   ( cluster_0_dma_0_vcures_waddr   ),
  .dma_0_vcures_sram_wdata   ( cluster_0_dma_0_vcures_wdata   ),
  .mst_regfile_wvalid     ( cluster_0_load_regfile_wvalid ),
  .mst_regfile_waddr      ( cluster_0_load_regfile_waddr  ),
  .mst_regfile_wdata      ( cluster_0_load_regfile_wdata  ),

  .clk                  ( clk                           ),
  .rst_n                ( rst_n                         ),
  .cmd_rst              ( cmd_rst_0                     ),
  .axi4_clk             ( axi4_clk                      ),
  .axi4_rst_n           ( axi4_rst_n                    ),
  .load_highaddr        ( load_highaddr                 ),
  .store_highaddr       ( store_highaddr                ),
  .load_highaddr_sel    ( load_highaddr_sel             ),
  .store_highaddr_sel   ( store_highaddr_sel            )
);


/* -------------------------------------------------------------------------------------------------------- */
/*                                             Load DMA Router                                              */
/* -------------------------------------------------------------------------------------------------------- */

npu_cluster_load_router #(
  .INSN_BITS              ( INSN_BITS                 ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH     ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH     ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH        ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH      ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH      ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH      ),
  .AXI_M_AXI_MIN_ID       ( 64                        ),
  .MASTER_PERI_ADDR_WIDTH ( MASTER_PERI_ADDR_WIDTH    ),
  .MASTER_PERI_BUSRSTS_WIDTH ( MASTER_PERI_BUSRSTS_WIDTH ),
  .MASTER_PERI_DATA_WIDTH ( MASTER_PERI_DATA_WIDTH    ),
  .MASTER_SRAM_ADDR_WIDTH ( MASTER_SRAM_ADDR_WIDTH    ),
  .IFMAP_WIDTH            ( CLUSTER_IFMAP_WIDTH       ),
  .QACT_WIDTH             ( CLUSTER_QACT_WIDTH        ),
  .VCUCODE_WIDTH          ( CLUSTER_VCUCODE_WIDTH     ),
  .VCUPARA_WIDTH          ( CLUSTER_VCUPARA_WIDTH     ),
  .VCULUT_WIDTH           ( CLUSTER_VCULUT_WIDTH      ),
  .VCURES_WIDTH           ( CLUSTER_VCURES_WIDTH      ),
  .WEIGHT_WIDTH           ( WEIGHT_WIDTH              ),
  .IFMAP_ADDR_BITS        ( CLUSTER_IFMAP_ADDR_BITS   ),
  .QACT_ADDR_BITS         ( CLUSTER_QACT_ADDR_BITS    ),
  .VCUCODE_ADDR_BITS      ( CLUSTER_VCUCODE_ADDR_BITS ),
  .VCUPARA_ADDR_BITS      ( CLUSTER_VCUPARA_ADDR_BITS ),
  .VCULUT_ADDR_BITS       ( CLUSTER_VCULUT_ADDR_BITS  ),
  .VCURES_ADDR_BITS       ( CLUSTER_VCURES_ADDR_BITS  ),
  .WEIGHT_ADDR_BITS       ( WEIGHT_ADDR_BITS          ),
  .HIGHADDR_BITS          ( HIGHADDR_BITS             )
) u_cluster_0_load_router(
  .clk                 ( clk                            ),
  .rst_n               ( rst_n                          ),
  .logic_rst_n         ( cluster_0_load_dma_rst_n       ),
  .axi4_clk            ( axi4_clk                       ),
  .axi4_rst_n          ( axi4_rst_n                     ),
  .load_highaddr       ( load_highaddr                  ),
  .load_highaddr_sel   ( load_highaddr_sel              ),
  .load_0_fifo_wen     ( load_0_fifo_wen               ),
  .load_0_fifo_wdata   ( load_0_fifo_wdata             ),
  .load_0_fifo_full    ( load_0_fifo_full              ),
  .load_0_fifo_empty   ( load_0_fifo_empty             ),
  .load_1_fifo_wen     ( load_1_fifo_wen               ),
  .load_1_fifo_wdata   ( load_1_fifo_wdata             ),
  .load_1_fifo_full    ( load_1_fifo_full              ),
  .load_1_fifo_empty   ( load_1_fifo_empty             ),
  .load_0_work_en      ( load_0_work_en                 ),
  .load_1_work_en      ( load_1_work_en                 ),
  .load_0_local_done   ( cluster_0_load_0_local_done_wire ),
  .load_1_local_done   ( cluster_0_load_1_local_done_wire ),
  .load_0_global_done  ( cluster_0_load_0_global_done   ),
  .load_1_global_done  ( cluster_0_load_1_global_done   ),
  .load_0_execute_time ( cluster_0_load_0_execute_time  ),
  .load_1_execute_time ( cluster_0_load_1_execute_time  ),
  .enable_prof_counter ( cluster_0_enable_prof_counter  ),
  .ifmap_wvalid        ( cluster_0_dma_0_ifmap_wvalid   ),
  .ifmap_waddr         ( cluster_0_dma_0_ifmap_waddr    ),
  .ifmap_wdata         ( cluster_0_dma_0_ifmap_wdata    ),
  .qact_wvalid         ( cluster_0_dma_0_qact_wvalid    ),
  .qact_waddr          ( cluster_0_dma_0_qact_waddr     ),
  .qact_wdata          ( cluster_0_dma_0_qact_wdata     ),
  .vcucode_wvalid      ( cluster_0_dma_0_vcucode_wvalid ),
  .vcucode_waddr       ( cluster_0_dma_0_vcucode_waddr  ),
  .vcucode_wdata       ( cluster_0_dma_0_vcucode_wdata  ),
  .vcupara_wvalid      ( cluster_0_dma_0_vcupara_wvalid ),
  .vcupara_waddr       ( cluster_0_dma_0_vcupara_waddr  ),
  .vcupara_wdata       ( cluster_0_dma_0_vcupara_wdata  ),
  .vcures_wvalid       ( cluster_0_dma_0_vcures_wvalid  ),
  .vcures_waddr        ( cluster_0_dma_0_vcures_waddr   ),
  .vcures_wdata        ( cluster_0_dma_0_vcures_wdata   ),
  .regfile_wvalid      ( cluster_0_load_regfile_wvalid  ),
  .regfile_waddr       ( cluster_0_load_regfile_waddr   ),
  .regfile_wdata       ( cluster_0_load_regfile_wdata   ),
  .weight_0_wvalid     ( weight_dma_0_wvalid            ),
  .weight_0_wdata      ( weight_dma_0_wdata             ),
  .weight_1_wvalid     ( weight_dma_1_wvalid            ),
  .weight_1_wdata      ( weight_dma_1_wdata             ),
  .dma_0_M_AXI_ARID    ( cluster_0_dma_0_M_AXI_ARID     ),
  .dma_0_M_AXI_ARADDR  ( cluster_0_dma_0_M_AXI_ARADDR   ),
  .dma_0_M_AXI_ARLEN   ( cluster_0_dma_0_M_AXI_ARLEN    ),
  .dma_0_M_AXI_ARSIZE  ( cluster_0_dma_0_M_AXI_ARSIZE   ),
  .dma_0_M_AXI_ARBURST ( cluster_0_dma_0_M_AXI_ARBURST  ),
  .dma_0_M_AXI_ARLOCK  ( cluster_0_dma_0_M_AXI_ARLOCK   ),
  .dma_0_M_AXI_ARCACHE ( cluster_0_dma_0_M_AXI_ARCACHE  ),
  .dma_0_M_AXI_ARPROT  ( cluster_0_dma_0_M_AXI_ARPROT   ),
  .dma_0_M_AXI_ARQOS   ( cluster_0_dma_0_M_AXI_ARQOS    ),
  .dma_0_M_AXI_ARUSER  ( cluster_0_dma_0_M_AXI_ARUSER   ),
  .dma_0_M_AXI_ARVALID ( cluster_0_dma_0_M_AXI_ARVALID  ),
  .dma_0_M_AXI_ARREADY ( cluster_0_dma_0_M_AXI_ARREADY  ),
  .dma_0_M_AXI_RID     ( cluster_0_dma_0_M_AXI_RID      ),
  .dma_0_M_AXI_RDATA   ( cluster_0_dma_0_M_AXI_RDATA    ),
  .dma_0_M_AXI_RRESP   ( cluster_0_dma_0_M_AXI_RRESP    ),
  .dma_0_M_AXI_RLAST   ( cluster_0_dma_0_M_AXI_RLAST    ),
  .dma_0_M_AXI_RUSER   ( cluster_0_dma_0_M_AXI_RUSER    ),
  .dma_0_M_AXI_RVALID  ( cluster_0_dma_0_M_AXI_RVALID   ),
  .dma_0_M_AXI_RREADY  ( cluster_0_dma_0_M_AXI_RREADY   ),
  .dma_1_M_AXI_ARID    ( cluster_0_dma_1_M_AXI_ARID     ),
  .dma_1_M_AXI_ARADDR  ( cluster_0_dma_1_M_AXI_ARADDR   ),
  .dma_1_M_AXI_ARLEN   ( cluster_0_dma_1_M_AXI_ARLEN    ),
  .dma_1_M_AXI_ARSIZE  ( cluster_0_dma_1_M_AXI_ARSIZE   ),
  .dma_1_M_AXI_ARBURST ( cluster_0_dma_1_M_AXI_ARBURST  ),
  .dma_1_M_AXI_ARLOCK  ( cluster_0_dma_1_M_AXI_ARLOCK   ),
  .dma_1_M_AXI_ARCACHE ( cluster_0_dma_1_M_AXI_ARCACHE  ),
  .dma_1_M_AXI_ARPROT  ( cluster_0_dma_1_M_AXI_ARPROT   ),
  .dma_1_M_AXI_ARQOS   ( cluster_0_dma_1_M_AXI_ARQOS    ),
  .dma_1_M_AXI_ARUSER  ( cluster_0_dma_1_M_AXI_ARUSER   ),
  .dma_1_M_AXI_ARVALID ( cluster_0_dma_1_M_AXI_ARVALID  ),
  .dma_1_M_AXI_ARREADY ( cluster_0_dma_1_M_AXI_ARREADY  ),
  .dma_1_M_AXI_RID     ( cluster_0_dma_1_M_AXI_RID      ),
  .dma_1_M_AXI_RDATA   ( cluster_0_dma_1_M_AXI_RDATA    ),
  .dma_1_M_AXI_RRESP   ( cluster_0_dma_1_M_AXI_RRESP    ),
  .dma_1_M_AXI_RLAST   ( cluster_0_dma_1_M_AXI_RLAST    ),
  .dma_1_M_AXI_RUSER   ( cluster_0_dma_1_M_AXI_RUSER    ),
  .dma_1_M_AXI_RVALID  ( cluster_0_dma_1_M_AXI_RVALID   ),
  .dma_1_M_AXI_RREADY  ( cluster_0_dma_1_M_AXI_RREADY   )
);

npu_cluster_load_router #(
  .INSN_BITS              ( INSN_BITS                 ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH     ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH     ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH        ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH      ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH      ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH      ),
  .AXI_M_AXI_MIN_ID       ( 128                        ),
  .MASTER_PERI_ADDR_WIDTH ( MASTER_PERI_ADDR_WIDTH    ),
  .MASTER_PERI_BUSRSTS_WIDTH ( MASTER_PERI_BUSRSTS_WIDTH ),
  .MASTER_PERI_DATA_WIDTH ( MASTER_PERI_DATA_WIDTH    ),
  .MASTER_SRAM_ADDR_WIDTH ( MASTER_SRAM_ADDR_WIDTH    ),
  .IFMAP_WIDTH            ( CLUSTER_IFMAP_WIDTH       ),
  .QACT_WIDTH             ( CLUSTER_QACT_WIDTH        ),
  .VCUCODE_WIDTH          ( CLUSTER_VCUCODE_WIDTH     ),
  .VCUPARA_WIDTH          ( CLUSTER_VCUPARA_WIDTH     ),
  .VCULUT_WIDTH           ( CLUSTER_VCULUT_WIDTH      ),
  .VCURES_WIDTH           ( CLUSTER_VCURES_WIDTH      ),
  .WEIGHT_WIDTH           ( WEIGHT_WIDTH              ),
  .IFMAP_ADDR_BITS        ( CLUSTER_IFMAP_ADDR_BITS   ),
  .QACT_ADDR_BITS         ( CLUSTER_QACT_ADDR_BITS    ),
  .VCUCODE_ADDR_BITS      ( CLUSTER_VCUCODE_ADDR_BITS ),
  .VCUPARA_ADDR_BITS      ( CLUSTER_VCUPARA_ADDR_BITS ),
  .VCULUT_ADDR_BITS       ( CLUSTER_VCULUT_ADDR_BITS  ),
  .VCURES_ADDR_BITS       ( CLUSTER_VCURES_ADDR_BITS  ),
  .WEIGHT_ADDR_BITS       ( WEIGHT_ADDR_BITS          ),
  .HIGHADDR_BITS          ( HIGHADDR_BITS             )
) u_cluster_1_load_router(
  .clk                 ( clk                            ),
  .rst_n               ( rst_n                          ),
  .logic_rst_n         ( cluster_1_load_dma_rst_n       ),
  .axi4_clk            ( axi4_clk                       ),
  .axi4_rst_n          ( axi4_rst_n                     ),
  .load_highaddr       ( load_highaddr                  ),
  .load_highaddr_sel   ( load_highaddr_sel              ),
  .load_0_fifo_wen     ( load_2_fifo_wen               ),
  .load_0_fifo_wdata   ( load_2_fifo_wdata             ),
  .load_0_fifo_full    ( load_2_fifo_full              ),
  .load_0_fifo_empty   ( load_2_fifo_empty             ),
  .load_1_fifo_wen     ( load_3_fifo_wen               ),
  .load_1_fifo_wdata   ( load_3_fifo_wdata             ),
  .load_1_fifo_full    ( load_3_fifo_full              ),
  .load_1_fifo_empty   ( load_3_fifo_empty             ),
  .load_0_work_en      ( load_2_work_en                 ),
  .load_1_work_en      ( load_3_work_en                 ),
  .load_0_local_done   ( cluster_1_load_0_local_done_wire ),
  .load_1_local_done   ( cluster_1_load_1_local_done_wire ),
  .load_0_global_done  ( cluster_1_load_0_global_done   ),
  .load_1_global_done  ( cluster_1_load_1_global_done   ),
  .load_0_execute_time ( cluster_1_load_0_execute_time  ),
  .load_1_execute_time ( cluster_1_load_1_execute_time  ),
  .enable_prof_counter ( cluster_1_enable_prof_counter  ),
  .ifmap_wvalid        ( cluster_1_dma_0_ifmap_wvalid   ),
  .ifmap_waddr         ( cluster_1_dma_0_ifmap_waddr    ),
  .ifmap_wdata         ( cluster_1_dma_0_ifmap_wdata    ),
  .qact_wvalid         ( cluster_1_dma_0_qact_wvalid    ),
  .qact_waddr          ( cluster_1_dma_0_qact_waddr     ),
  .qact_wdata          ( cluster_1_dma_0_qact_wdata     ),
  .vcucode_wvalid      ( cluster_1_dma_0_vcucode_wvalid ),
  .vcucode_waddr       ( cluster_1_dma_0_vcucode_waddr  ),
  .vcucode_wdata       ( cluster_1_dma_0_vcucode_wdata  ),
  .vcupara_wvalid      ( cluster_1_dma_0_vcupara_wvalid ),
  .vcupara_waddr       ( cluster_1_dma_0_vcupara_waddr  ),
  .vcupara_wdata       ( cluster_1_dma_0_vcupara_wdata  ),
  .vcures_wvalid       ( cluster_1_dma_0_vcures_wvalid  ),
  .vcures_waddr        ( cluster_1_dma_0_vcures_waddr   ),
  .vcures_wdata        ( cluster_1_dma_0_vcures_wdata   ),
  .regfile_wvalid      ( cluster_1_load_regfile_wvalid  ),
  .regfile_waddr       ( cluster_1_load_regfile_waddr   ),
  .regfile_wdata       ( cluster_1_load_regfile_wdata   ),
  .weight_0_wvalid     ( weight_dma_2_wvalid            ),
  .weight_0_wdata      ( weight_dma_2_wdata             ),
  .weight_1_wvalid     ( weight_dma_3_wvalid            ),
  .weight_1_wdata      ( weight_dma_3_wdata             ),
  .dma_0_M_AXI_ARID    ( cluster_1_dma_0_M_AXI_ARID     ),
  .dma_0_M_AXI_ARADDR  ( cluster_1_dma_0_M_AXI_ARADDR   ),
  .dma_0_M_AXI_ARLEN   ( cluster_1_dma_0_M_AXI_ARLEN    ),
  .dma_0_M_AXI_ARSIZE  ( cluster_1_dma_0_M_AXI_ARSIZE   ),
  .dma_0_M_AXI_ARBURST ( cluster_1_dma_0_M_AXI_ARBURST  ),
  .dma_0_M_AXI_ARLOCK  ( cluster_1_dma_0_M_AXI_ARLOCK   ),
  .dma_0_M_AXI_ARCACHE ( cluster_1_dma_0_M_AXI_ARCACHE  ),
  .dma_0_M_AXI_ARPROT  ( cluster_1_dma_0_M_AXI_ARPROT   ),
  .dma_0_M_AXI_ARQOS   ( cluster_1_dma_0_M_AXI_ARQOS    ),
  .dma_0_M_AXI_ARUSER  ( cluster_1_dma_0_M_AXI_ARUSER   ),
  .dma_0_M_AXI_ARVALID ( cluster_1_dma_0_M_AXI_ARVALID  ),
  .dma_0_M_AXI_ARREADY ( cluster_1_dma_0_M_AXI_ARREADY  ),
  .dma_0_M_AXI_RID     ( cluster_1_dma_0_M_AXI_RID      ),
  .dma_0_M_AXI_RDATA   ( cluster_1_dma_0_M_AXI_RDATA    ),
  .dma_0_M_AXI_RRESP   ( cluster_1_dma_0_M_AXI_RRESP    ),
  .dma_0_M_AXI_RLAST   ( cluster_1_dma_0_M_AXI_RLAST    ),
  .dma_0_M_AXI_RUSER   ( cluster_1_dma_0_M_AXI_RUSER    ),
  .dma_0_M_AXI_RVALID  ( cluster_1_dma_0_M_AXI_RVALID   ),
  .dma_0_M_AXI_RREADY  ( cluster_1_dma_0_M_AXI_RREADY   ),
  .dma_1_M_AXI_ARID    ( cluster_1_dma_1_M_AXI_ARID     ),
  .dma_1_M_AXI_ARADDR  ( cluster_1_dma_1_M_AXI_ARADDR   ),
  .dma_1_M_AXI_ARLEN   ( cluster_1_dma_1_M_AXI_ARLEN    ),
  .dma_1_M_AXI_ARSIZE  ( cluster_1_dma_1_M_AXI_ARSIZE   ),
  .dma_1_M_AXI_ARBURST ( cluster_1_dma_1_M_AXI_ARBURST  ),
  .dma_1_M_AXI_ARLOCK  ( cluster_1_dma_1_M_AXI_ARLOCK   ),
  .dma_1_M_AXI_ARCACHE ( cluster_1_dma_1_M_AXI_ARCACHE  ),
  .dma_1_M_AXI_ARPROT  ( cluster_1_dma_1_M_AXI_ARPROT   ),
  .dma_1_M_AXI_ARQOS   ( cluster_1_dma_1_M_AXI_ARQOS    ),
  .dma_1_M_AXI_ARUSER  ( cluster_1_dma_1_M_AXI_ARUSER   ),
  .dma_1_M_AXI_ARVALID ( cluster_1_dma_1_M_AXI_ARVALID  ),
  .dma_1_M_AXI_ARREADY ( cluster_1_dma_1_M_AXI_ARREADY  ),
  .dma_1_M_AXI_RID     ( cluster_1_dma_1_M_AXI_RID      ),
  .dma_1_M_AXI_RDATA   ( cluster_1_dma_1_M_AXI_RDATA    ),
  .dma_1_M_AXI_RRESP   ( cluster_1_dma_1_M_AXI_RRESP    ),
  .dma_1_M_AXI_RLAST   ( cluster_1_dma_1_M_AXI_RLAST    ),
  .dma_1_M_AXI_RUSER   ( cluster_1_dma_1_M_AXI_RUSER    ),
  .dma_1_M_AXI_RVALID  ( cluster_1_dma_1_M_AXI_RVALID   ),
  .dma_1_M_AXI_RREADY  ( cluster_1_dma_1_M_AXI_RREADY   )
);

npu_cluster_load_router #(
  .INSN_BITS              ( INSN_BITS                 ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH     ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH     ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH        ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH      ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH      ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH      ),
  .AXI_M_AXI_MIN_ID       ( 192                        ),
  .MASTER_PERI_ADDR_WIDTH ( MASTER_PERI_ADDR_WIDTH    ),
  .MASTER_PERI_BUSRSTS_WIDTH ( MASTER_PERI_BUSRSTS_WIDTH ),
  .MASTER_PERI_DATA_WIDTH ( MASTER_PERI_DATA_WIDTH    ),
  .MASTER_SRAM_ADDR_WIDTH ( MASTER_SRAM_ADDR_WIDTH    ),
  .IFMAP_WIDTH            ( CLUSTER_IFMAP_WIDTH       ),
  .QACT_WIDTH             ( CLUSTER_QACT_WIDTH        ),
  .VCUCODE_WIDTH          ( CLUSTER_VCUCODE_WIDTH     ),
  .VCUPARA_WIDTH          ( CLUSTER_VCUPARA_WIDTH     ),
  .VCULUT_WIDTH           ( CLUSTER_VCULUT_WIDTH      ),
  .VCURES_WIDTH           ( CLUSTER_VCURES_WIDTH      ),
  .WEIGHT_WIDTH           ( WEIGHT_WIDTH              ),
  .IFMAP_ADDR_BITS        ( CLUSTER_IFMAP_ADDR_BITS   ),
  .QACT_ADDR_BITS         ( CLUSTER_QACT_ADDR_BITS    ),
  .VCUCODE_ADDR_BITS      ( CLUSTER_VCUCODE_ADDR_BITS ),
  .VCUPARA_ADDR_BITS      ( CLUSTER_VCUPARA_ADDR_BITS ),
  .VCULUT_ADDR_BITS       ( CLUSTER_VCULUT_ADDR_BITS  ),
  .VCURES_ADDR_BITS       ( CLUSTER_VCURES_ADDR_BITS  ),
  .WEIGHT_ADDR_BITS       ( WEIGHT_ADDR_BITS          ),
  .HIGHADDR_BITS          ( HIGHADDR_BITS             )
) u_cluster_2_load_router(
  .clk                 ( clk                            ),
  .rst_n               ( rst_n                          ),
  .logic_rst_n         ( cluster_2_load_dma_rst_n       ),
  .axi4_clk            ( axi4_clk                       ),
  .axi4_rst_n          ( axi4_rst_n                     ),
  .load_highaddr       ( load_highaddr                  ),
  .load_highaddr_sel   ( load_highaddr_sel              ),
  .load_0_fifo_wen     ( load_4_fifo_wen               ),
  .load_0_fifo_wdata   ( load_4_fifo_wdata             ),
  .load_0_fifo_full    ( load_4_fifo_full              ),
  .load_0_fifo_empty   ( load_4_fifo_empty             ),
  .load_1_fifo_wen     ( load_5_fifo_wen               ),
  .load_1_fifo_wdata   ( load_5_fifo_wdata             ),
  .load_1_fifo_full    ( load_5_fifo_full              ),
  .load_1_fifo_empty   ( load_5_fifo_empty             ),
  .load_0_work_en      ( load_4_work_en                 ),
  .load_1_work_en      ( load_5_work_en                 ),
  .load_0_local_done   ( cluster_2_load_0_local_done_wire ),
  .load_1_local_done   ( cluster_2_load_1_local_done_wire ),
  .load_0_global_done  ( cluster_2_load_0_global_done   ),
  .load_1_global_done  ( cluster_2_load_1_global_done   ),
  .load_0_execute_time ( cluster_2_load_0_execute_time  ),
  .load_1_execute_time ( cluster_2_load_1_execute_time  ),
  .enable_prof_counter ( cluster_2_enable_prof_counter  ),
  .ifmap_wvalid        ( cluster_2_dma_0_ifmap_wvalid   ),
  .ifmap_waddr         ( cluster_2_dma_0_ifmap_waddr    ),
  .ifmap_wdata         ( cluster_2_dma_0_ifmap_wdata    ),
  .qact_wvalid         ( cluster_2_dma_0_qact_wvalid    ),
  .qact_waddr          ( cluster_2_dma_0_qact_waddr     ),
  .qact_wdata          ( cluster_2_dma_0_qact_wdata     ),
  .vcucode_wvalid      ( cluster_2_dma_0_vcucode_wvalid ),
  .vcucode_waddr       ( cluster_2_dma_0_vcucode_waddr  ),
  .vcucode_wdata       ( cluster_2_dma_0_vcucode_wdata  ),
  .vcupara_wvalid      ( cluster_2_dma_0_vcupara_wvalid ),
  .vcupara_waddr       ( cluster_2_dma_0_vcupara_waddr  ),
  .vcupara_wdata       ( cluster_2_dma_0_vcupara_wdata  ),
  .vcures_wvalid       ( cluster_2_dma_0_vcures_wvalid  ),
  .vcures_waddr        ( cluster_2_dma_0_vcures_waddr   ),
  .vcures_wdata        ( cluster_2_dma_0_vcures_wdata   ),
  .regfile_wvalid      ( cluster_2_load_regfile_wvalid  ),
  .regfile_waddr       ( cluster_2_load_regfile_waddr   ),
  .regfile_wdata       ( cluster_2_load_regfile_wdata   ),
  .weight_0_wvalid     ( weight_dma_4_wvalid            ),
  .weight_0_wdata      ( weight_dma_4_wdata             ),
  .weight_1_wvalid     ( weight_dma_5_wvalid            ),
  .weight_1_wdata      ( weight_dma_5_wdata             ),
  .dma_0_M_AXI_ARID    ( cluster_2_dma_0_M_AXI_ARID     ),
  .dma_0_M_AXI_ARADDR  ( cluster_2_dma_0_M_AXI_ARADDR   ),
  .dma_0_M_AXI_ARLEN   ( cluster_2_dma_0_M_AXI_ARLEN    ),
  .dma_0_M_AXI_ARSIZE  ( cluster_2_dma_0_M_AXI_ARSIZE   ),
  .dma_0_M_AXI_ARBURST ( cluster_2_dma_0_M_AXI_ARBURST  ),
  .dma_0_M_AXI_ARLOCK  ( cluster_2_dma_0_M_AXI_ARLOCK   ),
  .dma_0_M_AXI_ARCACHE ( cluster_2_dma_0_M_AXI_ARCACHE  ),
  .dma_0_M_AXI_ARPROT  ( cluster_2_dma_0_M_AXI_ARPROT   ),
  .dma_0_M_AXI_ARQOS   ( cluster_2_dma_0_M_AXI_ARQOS    ),
  .dma_0_M_AXI_ARUSER  ( cluster_2_dma_0_M_AXI_ARUSER   ),
  .dma_0_M_AXI_ARVALID ( cluster_2_dma_0_M_AXI_ARVALID  ),
  .dma_0_M_AXI_ARREADY ( cluster_2_dma_0_M_AXI_ARREADY  ),
  .dma_0_M_AXI_RID     ( cluster_2_dma_0_M_AXI_RID      ),
  .dma_0_M_AXI_RDATA   ( cluster_2_dma_0_M_AXI_RDATA    ),
  .dma_0_M_AXI_RRESP   ( cluster_2_dma_0_M_AXI_RRESP    ),
  .dma_0_M_AXI_RLAST   ( cluster_2_dma_0_M_AXI_RLAST    ),
  .dma_0_M_AXI_RUSER   ( cluster_2_dma_0_M_AXI_RUSER    ),
  .dma_0_M_AXI_RVALID  ( cluster_2_dma_0_M_AXI_RVALID   ),
  .dma_0_M_AXI_RREADY  ( cluster_2_dma_0_M_AXI_RREADY   ),
  .dma_1_M_AXI_ARID    ( cluster_2_dma_1_M_AXI_ARID     ),
  .dma_1_M_AXI_ARADDR  ( cluster_2_dma_1_M_AXI_ARADDR   ),
  .dma_1_M_AXI_ARLEN   ( cluster_2_dma_1_M_AXI_ARLEN    ),
  .dma_1_M_AXI_ARSIZE  ( cluster_2_dma_1_M_AXI_ARSIZE   ),
  .dma_1_M_AXI_ARBURST ( cluster_2_dma_1_M_AXI_ARBURST  ),
  .dma_1_M_AXI_ARLOCK  ( cluster_2_dma_1_M_AXI_ARLOCK   ),
  .dma_1_M_AXI_ARCACHE ( cluster_2_dma_1_M_AXI_ARCACHE  ),
  .dma_1_M_AXI_ARPROT  ( cluster_2_dma_1_M_AXI_ARPROT   ),
  .dma_1_M_AXI_ARQOS   ( cluster_2_dma_1_M_AXI_ARQOS    ),
  .dma_1_M_AXI_ARUSER  ( cluster_2_dma_1_M_AXI_ARUSER   ),
  .dma_1_M_AXI_ARVALID ( cluster_2_dma_1_M_AXI_ARVALID  ),
  .dma_1_M_AXI_ARREADY ( cluster_2_dma_1_M_AXI_ARREADY  ),
  .dma_1_M_AXI_RID     ( cluster_2_dma_1_M_AXI_RID      ),
  .dma_1_M_AXI_RDATA   ( cluster_2_dma_1_M_AXI_RDATA    ),
  .dma_1_M_AXI_RRESP   ( cluster_2_dma_1_M_AXI_RRESP    ),
  .dma_1_M_AXI_RLAST   ( cluster_2_dma_1_M_AXI_RLAST    ),
  .dma_1_M_AXI_RUSER   ( cluster_2_dma_1_M_AXI_RUSER    ),
  .dma_1_M_AXI_RVALID  ( cluster_2_dma_1_M_AXI_RVALID   ),
  .dma_1_M_AXI_RREADY  ( cluster_2_dma_1_M_AXI_RREADY   )
);

npu_cluster_load_router #(
  .INSN_BITS              ( INSN_BITS                 ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH     ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH     ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH        ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH      ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH      ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH      ),
  .AXI_M_AXI_MIN_ID       ( 256                        ),
  .MASTER_PERI_ADDR_WIDTH ( MASTER_PERI_ADDR_WIDTH    ),
  .MASTER_PERI_BUSRSTS_WIDTH ( MASTER_PERI_BUSRSTS_WIDTH ),
  .MASTER_PERI_DATA_WIDTH ( MASTER_PERI_DATA_WIDTH    ),
  .MASTER_SRAM_ADDR_WIDTH ( MASTER_SRAM_ADDR_WIDTH    ),
  .IFMAP_WIDTH            ( CLUSTER_IFMAP_WIDTH       ),
  .QACT_WIDTH             ( CLUSTER_QACT_WIDTH        ),
  .VCUCODE_WIDTH          ( CLUSTER_VCUCODE_WIDTH     ),
  .VCUPARA_WIDTH          ( CLUSTER_VCUPARA_WIDTH     ),
  .VCULUT_WIDTH           ( CLUSTER_VCULUT_WIDTH      ),
  .VCURES_WIDTH           ( CLUSTER_VCURES_WIDTH      ),
  .WEIGHT_WIDTH           ( WEIGHT_WIDTH              ),
  .IFMAP_ADDR_BITS        ( CLUSTER_IFMAP_ADDR_BITS   ),
  .QACT_ADDR_BITS         ( CLUSTER_QACT_ADDR_BITS    ),
  .VCUCODE_ADDR_BITS      ( CLUSTER_VCUCODE_ADDR_BITS ),
  .VCUPARA_ADDR_BITS      ( CLUSTER_VCUPARA_ADDR_BITS ),
  .VCULUT_ADDR_BITS       ( CLUSTER_VCULUT_ADDR_BITS  ),
  .VCURES_ADDR_BITS       ( CLUSTER_VCURES_ADDR_BITS  ),
  .WEIGHT_ADDR_BITS       ( WEIGHT_ADDR_BITS          ),
  .HIGHADDR_BITS          ( HIGHADDR_BITS             )
) u_cluster_3_load_router(
  .clk                 ( clk                            ),
  .rst_n               ( rst_n                          ),
  .logic_rst_n         ( cluster_3_load_dma_rst_n       ),
  .axi4_clk            ( axi4_clk                       ),
  .axi4_rst_n          ( axi4_rst_n                     ),
  .load_highaddr       ( load_highaddr                  ),
  .load_highaddr_sel   ( load_highaddr_sel              ),
  .load_0_fifo_wen     ( load_6_fifo_wen               ),
  .load_0_fifo_wdata   ( load_6_fifo_wdata             ),
  .load_0_fifo_full    ( load_6_fifo_full              ),
  .load_0_fifo_empty   ( load_6_fifo_empty             ),
  .load_1_fifo_wen     ( load_7_fifo_wen               ),
  .load_1_fifo_wdata   ( load_7_fifo_wdata             ),
  .load_1_fifo_full    ( load_7_fifo_full              ),
  .load_1_fifo_empty   ( load_7_fifo_empty             ),
  .load_0_work_en      ( load_6_work_en                 ),
  .load_1_work_en      ( load_7_work_en                 ),
  .load_0_local_done   ( cluster_3_load_0_local_done_wire ),
  .load_1_local_done   ( cluster_3_load_1_local_done_wire ),
  .load_0_global_done  ( cluster_3_load_0_global_done   ),
  .load_1_global_done  ( cluster_3_load_1_global_done   ),
  .load_0_execute_time ( cluster_3_load_0_execute_time  ),
  .load_1_execute_time ( cluster_3_load_1_execute_time  ),
  .enable_prof_counter ( cluster_3_enable_prof_counter  ),
  .ifmap_wvalid        ( cluster_3_dma_0_ifmap_wvalid   ),
  .ifmap_waddr         ( cluster_3_dma_0_ifmap_waddr    ),
  .ifmap_wdata         ( cluster_3_dma_0_ifmap_wdata    ),
  .qact_wvalid         ( cluster_3_dma_0_qact_wvalid    ),
  .qact_waddr          ( cluster_3_dma_0_qact_waddr     ),
  .qact_wdata          ( cluster_3_dma_0_qact_wdata     ),
  .vcucode_wvalid      ( cluster_3_dma_0_vcucode_wvalid ),
  .vcucode_waddr       ( cluster_3_dma_0_vcucode_waddr  ),
  .vcucode_wdata       ( cluster_3_dma_0_vcucode_wdata  ),
  .vcupara_wvalid      ( cluster_3_dma_0_vcupara_wvalid ),
  .vcupara_waddr       ( cluster_3_dma_0_vcupara_waddr  ),
  .vcupara_wdata       ( cluster_3_dma_0_vcupara_wdata  ),
  .vcures_wvalid       ( cluster_3_dma_0_vcures_wvalid  ),
  .vcures_waddr        ( cluster_3_dma_0_vcures_waddr   ),
  .vcures_wdata        ( cluster_3_dma_0_vcures_wdata   ),
  .regfile_wvalid      ( cluster_3_load_regfile_wvalid  ),
  .regfile_waddr       ( cluster_3_load_regfile_waddr   ),
  .regfile_wdata       ( cluster_3_load_regfile_wdata   ),
  .weight_0_wvalid     ( weight_dma_6_wvalid            ),
  .weight_0_wdata      ( weight_dma_6_wdata             ),
  .weight_1_wvalid     ( weight_dma_7_wvalid            ),
  .weight_1_wdata      ( weight_dma_7_wdata             ),
  .dma_0_M_AXI_ARID    ( cluster_3_dma_0_M_AXI_ARID     ),
  .dma_0_M_AXI_ARADDR  ( cluster_3_dma_0_M_AXI_ARADDR   ),
  .dma_0_M_AXI_ARLEN   ( cluster_3_dma_0_M_AXI_ARLEN    ),
  .dma_0_M_AXI_ARSIZE  ( cluster_3_dma_0_M_AXI_ARSIZE   ),
  .dma_0_M_AXI_ARBURST ( cluster_3_dma_0_M_AXI_ARBURST  ),
  .dma_0_M_AXI_ARLOCK  ( cluster_3_dma_0_M_AXI_ARLOCK   ),
  .dma_0_M_AXI_ARCACHE ( cluster_3_dma_0_M_AXI_ARCACHE  ),
  .dma_0_M_AXI_ARPROT  ( cluster_3_dma_0_M_AXI_ARPROT   ),
  .dma_0_M_AXI_ARQOS   ( cluster_3_dma_0_M_AXI_ARQOS    ),
  .dma_0_M_AXI_ARUSER  ( cluster_3_dma_0_M_AXI_ARUSER   ),
  .dma_0_M_AXI_ARVALID ( cluster_3_dma_0_M_AXI_ARVALID  ),
  .dma_0_M_AXI_ARREADY ( cluster_3_dma_0_M_AXI_ARREADY  ),
  .dma_0_M_AXI_RID     ( cluster_3_dma_0_M_AXI_RID      ),
  .dma_0_M_AXI_RDATA   ( cluster_3_dma_0_M_AXI_RDATA    ),
  .dma_0_M_AXI_RRESP   ( cluster_3_dma_0_M_AXI_RRESP    ),
  .dma_0_M_AXI_RLAST   ( cluster_3_dma_0_M_AXI_RLAST    ),
  .dma_0_M_AXI_RUSER   ( cluster_3_dma_0_M_AXI_RUSER    ),
  .dma_0_M_AXI_RVALID  ( cluster_3_dma_0_M_AXI_RVALID   ),
  .dma_0_M_AXI_RREADY  ( cluster_3_dma_0_M_AXI_RREADY   ),
  .dma_1_M_AXI_ARID    ( cluster_3_dma_1_M_AXI_ARID     ),
  .dma_1_M_AXI_ARADDR  ( cluster_3_dma_1_M_AXI_ARADDR   ),
  .dma_1_M_AXI_ARLEN   ( cluster_3_dma_1_M_AXI_ARLEN    ),
  .dma_1_M_AXI_ARSIZE  ( cluster_3_dma_1_M_AXI_ARSIZE   ),
  .dma_1_M_AXI_ARBURST ( cluster_3_dma_1_M_AXI_ARBURST  ),
  .dma_1_M_AXI_ARLOCK  ( cluster_3_dma_1_M_AXI_ARLOCK   ),
  .dma_1_M_AXI_ARCACHE ( cluster_3_dma_1_M_AXI_ARCACHE  ),
  .dma_1_M_AXI_ARPROT  ( cluster_3_dma_1_M_AXI_ARPROT   ),
  .dma_1_M_AXI_ARQOS   ( cluster_3_dma_1_M_AXI_ARQOS    ),
  .dma_1_M_AXI_ARUSER  ( cluster_3_dma_1_M_AXI_ARUSER   ),
  .dma_1_M_AXI_ARVALID ( cluster_3_dma_1_M_AXI_ARVALID  ),
  .dma_1_M_AXI_ARREADY ( cluster_3_dma_1_M_AXI_ARREADY  ),
  .dma_1_M_AXI_RID     ( cluster_3_dma_1_M_AXI_RID      ),
  .dma_1_M_AXI_RDATA   ( cluster_3_dma_1_M_AXI_RDATA    ),
  .dma_1_M_AXI_RRESP   ( cluster_3_dma_1_M_AXI_RRESP    ),
  .dma_1_M_AXI_RLAST   ( cluster_3_dma_1_M_AXI_RLAST    ),
  .dma_1_M_AXI_RUSER   ( cluster_3_dma_1_M_AXI_RUSER    ),
  .dma_1_M_AXI_RVALID  ( cluster_3_dma_1_M_AXI_RVALID   ),
  .dma_1_M_AXI_RREADY  ( cluster_3_dma_1_M_AXI_RREADY   )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                             Shared Weight SRAM                                           */
/* -------------------------------------------------------------------------------------------------------- */

weight_ram #(
  .WIDTH     ( WEIGHT_WIDTH      ),
  .ADDR_BITS ( WEIGHT_ADDR_BITS  ),
  .BANK      ( WEIGHT_BANK       )
) u_weight_ram_0(
  .clk          ( clk                  ),
  .rst_n        ( rst_n                ),

  .rvalid_0     ( weight_0_rvalid      ),
  .raddr_0      ( weight_0_raddr       ),
  .rdata_0      ( weight_0_rdata       ),

  .dma_wvalid   ( weight_dma_0_wvalid  ),
  .dma_wdata    ( weight_dma_0_wdata   ),
  .dma_wvalid_1 ( weight_dma_1_wvalid  ),
  .dma_wdata_1  ( weight_dma_1_wdata   ),
  .dma_wvalid_2 ( weight_dma_2_wvalid ),
  .dma_wdata_2  ( weight_dma_2_wdata  ),
  .dma_wvalid_3 ( weight_dma_3_wvalid ),
  .dma_wdata_3  ( weight_dma_3_wdata  ),
  .dma_wvalid_4 ( weight_dma_4_wvalid ),
  .dma_wdata_4  ( weight_dma_4_wdata  ),
  .dma_wvalid_5 ( weight_dma_5_wvalid ),
  .dma_wdata_5  ( weight_dma_5_wdata  ),
  .dma_wvalid_6 ( weight_dma_6_wvalid ),
  .dma_wdata_6  ( weight_dma_6_wdata  ),
  .dma_wvalid_7 ( weight_dma_7_wvalid ),
  .dma_wdata_7  ( weight_dma_7_wdata  )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 AXI Slave                                                */
/* -------------------------------------------------------------------------------------------------------- */

load_slave u_load_slave(
  .axi4_clk                ( axi4_clk                ),
  .axi4_rst_n              ( axi4_rst_n              ),
  .axi4_full_S_AXI_ARID    ( axi_S_AXI_ARID          ),
  .axi4_full_S_AXI_ARADDR  ( axi_S_AXI_ARADDR        ),
  .axi4_full_S_AXI_ARLEN   ( axi_S_AXI_ARLEN         ),
  .axi4_full_S_AXI_ARSIZE  ( axi_S_AXI_ARSIZE        ),
  .axi4_full_S_AXI_ARBURST ( axi_S_AXI_ARBURST       ),
  .axi4_full_S_AXI_ARLOCK  ( axi_S_AXI_ARLOCK        ),
  .axi4_full_S_AXI_ARCACHE ( axi_S_AXI_ARCACHE       ),
  .axi4_full_S_AXI_ARPROT  ( axi_S_AXI_ARPROT        ),
  .axi4_full_S_AXI_ARQOS   ( axi_S_AXI_ARQOS         ),
  .axi4_full_S_AXI_ARUSER  ( axi_S_AXI_ARUSER        ),
  .axi4_full_S_AXI_ARVALID ( axi_S_AXI_ARVALID       ),
  .axi4_full_S_AXI_RREADY  ( axi_S_AXI_RREADY        ),
  .clk                     ( clk                     ),
  .logic_rst_n             ( rst_n                   ),
  .fifo_rst_n              ( rst_n                   ),
  .sram_rready             ( slv_regfile_rready      ),
  .sram_rdata              ( slv_regfile_rdata       ),
  .axi4_full_S_AXI_ARREADY ( axi_S_AXI_ARREADY       ),
  .axi4_full_S_AXI_RID     ( axi_S_AXI_RID           ),
  .axi4_full_S_AXI_RDATA   ( axi_S_AXI_RDATA         ),
  .axi4_full_S_AXI_RRESP   ( axi_S_AXI_RRESP         ),
  .axi4_full_S_AXI_RLAST   ( axi_S_AXI_RLAST         ),
  .axi4_full_S_AXI_RUSER   ( axi_S_AXI_RUSER         ),
  .axi4_full_S_AXI_RVALID  ( axi_S_AXI_RVALID        ),
  .sram_raddr              ( slv_regfile_raddr       ),
  .sram_rvalid             ( slv_regfile_rvalid      )
);

store_slave u_store_slave(
  .axi4_clk                ( axi4_clk            ),
  .axi4_rst_n              ( axi4_rst_n          ),
  .axi4_full_S_AXI_AWID    ( axi_S_AXI_AWID      ),
  .axi4_full_S_AXI_AWADDR  ( axi_S_AXI_AWADDR    ),
  .axi4_full_S_AXI_AWLEN   ( axi_S_AXI_AWLEN     ),
  .axi4_full_S_AXI_AWSIZE  ( axi_S_AXI_AWSIZE    ),
  .axi4_full_S_AXI_AWBURST ( axi_S_AXI_AWBURST   ),
  .axi4_full_S_AXI_AWLOCK  ( axi_S_AXI_AWLOCK    ),
  .axi4_full_S_AXI_AWCACHE ( axi_S_AXI_AWCACHE   ),
  .axi4_full_S_AXI_AWPROT  ( axi_S_AXI_AWPROT    ),
  .axi4_full_S_AXI_AWQOS   ( axi_S_AXI_AWQOS     ),
  .axi4_full_S_AXI_AWUSER  ( axi_S_AXI_AWUSER    ),
  .axi4_full_S_AXI_AWVALID ( axi_S_AXI_AWVALID   ),
  .axi4_full_S_AXI_WDATA   ( axi_S_AXI_WDATA     ),
  .axi4_full_S_AXI_WSTRB   ( axi_S_AXI_WSTRB     ),
  .axi4_full_S_AXI_WLAST   ( axi_S_AXI_WLAST     ),
  .axi4_full_S_AXI_WUSER   ( axi_S_AXI_WUSER     ),
  .axi4_full_S_AXI_WVALID  ( axi_S_AXI_WVALID    ),
  .axi4_full_S_AXI_BREADY  ( axi_S_AXI_BREADY    ),
  .clk                     ( clk                 ),
  .fifo_rst_n              ( rst_n               ),
  .logic_rst_n             ( rst_n               ),
  .sram_wready             ( slv_regfile_wready  ),
  .axi4_full_S_AXI_AWREADY ( axi_S_AXI_AWREADY   ),
  .axi4_full_S_AXI_WREADY  ( axi_S_AXI_WREADY    ),
  .axi4_full_S_AXI_BID     ( axi_S_AXI_BID       ),
  .axi4_full_S_AXI_BRESP   ( axi_S_AXI_BRESP     ),
  .axi4_full_S_AXI_BUSER   ( axi_S_AXI_BUSER     ),
  .axi4_full_S_AXI_BVALID  ( axi_S_AXI_BVALID    ),
  .sram_waddr              ( slv_regfile_waddr   ),
  .sram_wvalid             ( slv_regfile_wvalid  ),
  .sram_wdata              ( slv_regfile_wdata   )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                    irq                                                   */
/* -------------------------------------------------------------------------------------------------------- */

pcie_irq u_pcie_irq(
  .npu_clk                   ( clk                       ),
  .npu_rst_n                 ( rst_n                     ),
  .pcie_clk                  ( pcie_clk                  ),
  .pcie_rst_n                ( pcie_rst_n                ),
  .pcie_ven_msi_req          ( pcie_ven_msi_req          ),
  .pcie_ven_msi_func_num     ( pcie_ven_msi_func_num     ),
  .pcie_ven_msi_tc           ( pcie_ven_msi_tc           ),
  .pcie_ven_msi_vector       ( pcie_ven_msi_vector       ),
  .pcie_msi_grant            ( pcie_msi_grant            ),
  .npu_done                  ( global_done               ),
  .pcie_irq_enable           ( pcie_irq_enable           ),
  .pcie_highaddr_config_done ( pcie_highaddr_config_done )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                                  regfile                                                 */
/* -------------------------------------------------------------------------------------------------------- */

assign cluster_0_wready = 1'b1;
assign cluster_1_wready = 1'b1;
assign cluster_2_wready = 1'b1;
assign cluster_3_wready = 1'b1;

regfile_top u_regfile_top(
  .clk                       ( clk                       ),
  .rst_n                     ( rst_n                     ),

  .pcie_clk                  ( pcie_clk                  ),
  .pcie_rst_n                ( pcie_rst_n                ),

  .mcu_clk                   ( mcu_clk                   ),
  .mcu_rst_n                 ( mcu_rst_n                 ),

  .control                   ( control                   ),
  .cmd_start                 ( cmd_start                 ),
  .cmd_rst                   ( cmd_rst                   ),
  .insn_addr                 ( insn_addr                 ),
  .insn_number               ( insn_number               ),
  .insn_burst_length         ( insn_burst_length         ),
  .local_highaddr            ( local_highaddr            ),

  .word_cnt_debug            ( word_cnt_debug            ),
  .word_reg_debug            ( word_reg_debug            ),
  .done_reg_debug            ( done_reg_debug            ),
  .insn_fifo_empty_debug     ( insn_fifo_empty_debug_reg ),
  .insn_fifo_full_debug      ( insn_fifo_full_debug_reg  ),
  .dispatch_empty            ( dispatch_empty            ),
  .dispatch_insn_done        ( dispatch_insn_done        ),

  .slv_rvalid                ( slv_regfile_rvalid        ),
  .slv_rready                ( slv_regfile_rready        ),
  .slv_raddr                 ( slv_regfile_raddr         ),
  .slv_rdata                 ( slv_regfile_rdata         ),

  .slv_wvalid                ( slv_regfile_wvalid        ),
  .slv_waddr                 ( slv_regfile_waddr         ),
  .slv_wdata                 ( slv_regfile_wdata         ),
  .slv_wready                ( slv_regfile_wready        ),

  .apb_rvalid                ( apb_regfile_rvalid        ),
  .apb_rready                ( apb_regfile_rready        ),
  .apb_raddr                 ( apb_regfile_raddr         ),
  .apb_rdata                 ( apb_regfile_rdata         ),

  .apb_wvalid                ( apb_regfile_wvalid        ),
  .apb_waddr                 ( apb_regfile_waddr         ),
  .apb_wdata                 ( apb_regfile_wdata         ),
  .apb_wready                ( apb_regfile_wready        ),

  .cluster_0_rvalid          ( cluster_0_rvalid          ),
  .cluster_0_rready          ( cluster_0_rready          ),
  .cluster_0_raddr           ( cluster_0_raddr           ),
  .cluster_0_rdata           ( cluster_0_rdata           ),

  .cluster_0_wvalid          ( cluster_0_wvalid          ),
  .cluster_0_waddr           ( cluster_0_waddr           ),
  .cluster_0_wdata           ( cluster_0_wdata           ),
  .cluster_0_wready          ( cluster_0_wready          ),

  .cluster_1_rvalid          ( cluster_1_rvalid          ),
  .cluster_1_raddr           ( cluster_1_raddr           ),
  .cluster_1_rdata           ( cluster_1_rdata           ),
  .cluster_1_rready          ( cluster_1_rready          ),

  .cluster_1_wvalid          ( cluster_1_wvalid          ),
  .cluster_1_waddr           ( cluster_1_waddr           ),
  .cluster_1_wdata           ( cluster_1_wdata           ),
  .cluster_1_wready          ( cluster_1_wready          ),

  .cluster_2_rvalid          ( cluster_2_rvalid          ),
  .cluster_2_raddr           ( cluster_2_raddr           ),
  .cluster_2_rdata           ( cluster_2_rdata           ),
  .cluster_2_rready          ( cluster_2_rready          ),

  .cluster_2_wvalid          ( cluster_2_wvalid          ),
  .cluster_2_waddr           ( cluster_2_waddr           ),
  .cluster_2_wdata           ( cluster_2_wdata           ),
  .cluster_2_wready          ( cluster_2_wready          ),

  .cluster_3_rvalid          ( cluster_3_rvalid          ),
  .cluster_3_raddr           ( cluster_3_raddr           ),
  .cluster_3_rdata           ( cluster_3_rdata           ),
  .cluster_3_rready          ( cluster_3_rready          ),

  .cluster_3_wvalid          ( cluster_3_wvalid          ),
  .cluster_3_waddr           ( cluster_3_waddr           ),
  .cluster_3_wdata           ( cluster_3_wdata           ),
  .cluster_3_wready          ( cluster_3_wready          ),

  .cib_irq_highaddr          ( cib_irq_highaddr          ),
  .pcie_highaddr             ( pcie_highaddr             ),
  .pcie_irq_enable           ( pcie_irq_enable           ),
  .cib_irq_enable            ( cib_irq_enable            ),
  .pcie_highaddr_config_done ( pcie_highaddr_config_done ),
  .mcu_highaddr              ( mcu_highaddr              )
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                               Debug Signal                                               */
/* -------------------------------------------------------------------------------------------------------- */

assign insn_fifo_empty_debug = {vcu_7_fifo_empty,   vcu_6_fifo_empty,   vcu_5_fifo_empty,   vcu_4_fifo_empty,
                                vcu_3_fifo_empty,   vcu_2_fifo_empty,   vcu_1_fifo_empty,   vcu_0_fifo_empty,
                                pea_7_fifo_empty,   pea_6_fifo_empty,   pea_5_fifo_empty,   pea_4_fifo_empty,
                                pea_3_fifo_empty,   pea_2_fifo_empty,   pea_1_fifo_empty,   pea_0_fifo_empty,
                                store_7_fifo_empty, store_6_fifo_empty, store_5_fifo_empty, store_4_fifo_empty,
                                store_3_fifo_empty, store_2_fifo_empty, store_1_fifo_empty, store_0_fifo_empty,
                                load_7_fifo_empty,  load_6_fifo_empty,  load_5_fifo_empty,  load_4_fifo_empty,
                                load_3_fifo_empty,  load_2_fifo_empty,  load_1_fifo_empty,  load_0_fifo_empty};

assign insn_fifo_full_debug = {vcu_7_fifo_full,   vcu_6_fifo_full,   vcu_5_fifo_full,   vcu_4_fifo_full,
                               vcu_3_fifo_full,   vcu_2_fifo_full,   vcu_1_fifo_full,   vcu_0_fifo_full,
                               pea_7_fifo_full,   pea_6_fifo_full,   pea_5_fifo_full,   pea_4_fifo_full,
                               pea_3_fifo_full,   pea_2_fifo_full,   pea_1_fifo_full,   pea_0_fifo_full,
                               store_7_fifo_full, store_6_fifo_full, store_5_fifo_full, store_4_fifo_full,
                               store_3_fifo_full, store_2_fifo_full, store_1_fifo_full, store_0_fifo_full,
                               load_7_fifo_full,  load_6_fifo_full,  load_5_fifo_full,  load_4_fifo_full,
                               load_3_fifo_full,  load_2_fifo_full,  load_1_fifo_full,  load_0_fifo_full};

assign collect_done = {vcu_7_done,         vcu_6_done,         vcu_5_done,         vcu_4_done,
                       vcu_3_done,         vcu_2_done,         vcu_1_done,         vcu_0_done,
                       pea_7_done,         pea_6_done,         pea_5_done,         pea_4_done,
                       pea_3_done,         pea_2_done,         pea_1_done,         pea_0_done,
                       store_7_local_done, store_6_local_done, store_5_local_done, store_4_local_done,
                       store_3_local_done, store_2_local_done, store_1_local_done, store_0_local_done,
                       load_7_local_done,  load_6_local_done,  load_5_local_done,  load_4_local_done,
                       load_3_local_done,  load_2_local_done,  load_1_local_done,  load_0_local_done};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    collect_done_reg          <= 1'b0;
    insn_fifo_full_debug_reg  <= 1'b0;
    insn_fifo_empty_debug_reg <= 1'b0;
  end
  else begin
    collect_done_reg          <= collect_done;
    insn_fifo_full_debug_reg  <= insn_fifo_full_debug;
    insn_fifo_empty_debug_reg <= insn_fifo_empty_debug;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Done Logic                                                */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    global_done <= 1'b0;
    cluster_0_done_reg <= 1'b0;
    cluster_1_done_reg <= 1'b0;
    cluster_2_done_reg <= 1'b0;
    cluster_3_done_reg <= 1'b0;
  end
  else begin
    if (cluster_0_done) begin
      cluster_0_done_reg <= 1'b1;
    end
    else begin
      cluster_0_done_reg <= 1'b0;
    end

    if (cluster_1_done) begin
      cluster_1_done_reg <= 1'b1;
    end
    else begin
      cluster_1_done_reg <= 1'b0;
    end

    if (cluster_2_done) begin
      cluster_2_done_reg <= 1'b1;
    end
    else begin
      cluster_2_done_reg <= 1'b0;
    end

    if (cluster_3_done) begin
      cluster_3_done_reg <= 1'b1;
    end
    else begin
      cluster_3_done_reg <= 1'b0;
    end

    if (cluster_0_done_reg || cluster_1_done_reg || cluster_2_done_reg || cluster_3_done_reg) begin
      global_done <= 1'b1;
    end
    else begin
      global_done <= 1'b0;
    end
  end
end

reg start_level;

always @(posedge clk or negedge sync_rst_n) begin
  if (!sync_rst_n) begin
    start_level <= 1'b0;
  end
  else begin
    if (global_done) begin
      start_level <= 1'b0;
    end
    else if (cmd_start) begin
      start_level <= 1'b1;
    end
  end
end

endmodule
