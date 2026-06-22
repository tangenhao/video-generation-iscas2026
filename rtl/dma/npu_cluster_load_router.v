module npu_cluster_load_router(
  clk, rst_n, logic_rst_n,
  axi4_clk, axi4_rst_n,

  load_highaddr, load_highaddr_sel,
  load_0_fifo_wen, load_0_fifo_wdata, load_0_fifo_full, load_0_fifo_empty,
  load_1_fifo_wen, load_1_fifo_wdata, load_1_fifo_full, load_1_fifo_empty,
  load_0_work_en,
  load_1_work_en,
  load_0_local_done, load_1_local_done,
  load_0_global_done, load_1_global_done,
  load_0_execute_time, load_1_execute_time,
  enable_prof_counter,

  ifmap_wvalid, ifmap_waddr, ifmap_wdata,
  qact_wvalid, qact_waddr, qact_wdata,
  vcucode_wvalid, vcucode_waddr, vcucode_wdata,
  vcupara_wvalid, vcupara_waddr, vcupara_wdata,
  vcures_wvalid, vcures_waddr, vcures_wdata,
  regfile_wvalid, regfile_waddr, regfile_wdata,
  weight_0_wvalid, weight_0_wdata, weight_1_wvalid, weight_1_wdata,

  dma_0_M_AXI_ARID, dma_0_M_AXI_ARADDR, dma_0_M_AXI_ARLEN,
  dma_0_M_AXI_ARSIZE, dma_0_M_AXI_ARBURST, dma_0_M_AXI_ARLOCK, dma_0_M_AXI_ARCACHE, dma_0_M_AXI_ARPROT, dma_0_M_AXI_ARQOS, dma_0_M_AXI_ARUSER,
  dma_0_M_AXI_ARVALID, dma_0_M_AXI_ARREADY,
  dma_0_M_AXI_RID, dma_0_M_AXI_RDATA, dma_0_M_AXI_RRESP, dma_0_M_AXI_RLAST, dma_0_M_AXI_RUSER, dma_0_M_AXI_RVALID, dma_0_M_AXI_RREADY,

  dma_1_M_AXI_ARID, dma_1_M_AXI_ARADDR, dma_1_M_AXI_ARLEN,
  dma_1_M_AXI_ARSIZE, dma_1_M_AXI_ARBURST, dma_1_M_AXI_ARLOCK, dma_1_M_AXI_ARCACHE, dma_1_M_AXI_ARPROT, dma_1_M_AXI_ARQOS, dma_1_M_AXI_ARUSER,
  dma_1_M_AXI_ARVALID, dma_1_M_AXI_ARREADY,
  dma_1_M_AXI_RID, dma_1_M_AXI_RDATA, dma_1_M_AXI_RRESP, dma_1_M_AXI_RLAST, dma_1_M_AXI_RUSER, dma_1_M_AXI_RVALID, dma_1_M_AXI_RREADY
);

parameter INSN_BITS              = 128;
parameter INSN_FIFO_DEPTH        = 128;
parameter AXI_M_AXI_BURSTLENGTH  = 128;
parameter AXI_OUTSTANDING_DEPTH  = 8;
parameter AXI_M_AXI_ID_WIDTH     = 20;
parameter AXI_M_AXI_ADDR_WIDTH   = 64;
parameter AXI_M_AXI_USER_WIDTH   = 1;
parameter AXI_M_AXI_DATA_WIDTH   = 256;
parameter AXI_M_AXI_MIN_ID       = 0;

parameter MASTER_PERI_ADDR_WIDTH    = 38;
parameter MASTER_PERI_BUSRSTS_WIDTH = 22;
parameter MASTER_PERI_DATA_WIDTH    = 256;
parameter MASTER_SRAM_ADDR_WIDTH    = 20;

parameter IFMAP_WIDTH       = 576;
parameter QACT_WIDTH        = 288;
parameter VCUCODE_WIDTH     = 64;
parameter VCUPARA_WIDTH     = 576;
parameter VCULUT_WIDTH      = 64;
parameter VCURES_WIDTH      = 576;
parameter WEIGHT_WIDTH      = 288;
parameter IFMAP_ADDR_BITS   = 9;
parameter QACT_ADDR_BITS    = 9;
parameter VCUCODE_ADDR_BITS = 7;
parameter VCUPARA_ADDR_BITS = 9;
parameter VCULUT_ADDR_BITS  = 9;
parameter VCURES_ADDR_BITS  = 9;
parameter WEIGHT_ADDR_BITS  = 14;
parameter HIGHADDR_BITS     = 24;

input                              clk;
input                              rst_n;
input                              logic_rst_n;
input                              axi4_clk;
input                              axi4_rst_n;
input      [HIGHADDR_BITS-1:0]     load_highaddr;
input                              load_highaddr_sel;
input                              load_0_fifo_wen;
input      [INSN_BITS-1:0]         load_0_fifo_wdata;
output wire                        load_0_fifo_full;
output wire                        load_0_fifo_empty;
input                              load_1_fifo_wen;
input      [INSN_BITS-1:0]         load_1_fifo_wdata;
output wire                        load_1_fifo_full;
output wire                        load_1_fifo_empty;
input                              load_0_work_en;
input                              load_1_work_en;
output wire                        load_0_local_done;
output wire                        load_1_local_done;
output wire                        load_0_global_done;
output wire                        load_1_global_done;
output wire [31:0]                 load_0_execute_time;
output wire [31:0]                 load_1_execute_time;
input                              enable_prof_counter;

output wire                        ifmap_wvalid;
output wire [IFMAP_ADDR_BITS-1:0]  ifmap_waddr;
output wire [IFMAP_WIDTH-1:0]      ifmap_wdata;
output wire                        qact_wvalid;
output wire [QACT_ADDR_BITS-1:0]   qact_waddr;
output wire [QACT_WIDTH-1:0]       qact_wdata;
output wire                        vcucode_wvalid;
output wire [VCUCODE_ADDR_BITS:0]  vcucode_waddr;
output wire [VCUCODE_WIDTH-1:0]    vcucode_wdata;
output wire                        vcupara_wvalid;
output wire [VCUPARA_ADDR_BITS:0]  vcupara_waddr;
output wire [VCUPARA_WIDTH-1:0]    vcupara_wdata;
output wire                        vcures_wvalid;
output wire [VCURES_ADDR_BITS-1:0] vcures_waddr;
output wire [VCURES_WIDTH-1:0]     vcures_wdata;
output wire                        regfile_wvalid;
output wire [31:0]                 regfile_waddr;
output wire [31:0]                 regfile_wdata;
output wire                        weight_0_wvalid;
output wire [WEIGHT_WIDTH-1:0]     weight_0_wdata;
output wire                        weight_1_wvalid;
output wire [WEIGHT_WIDTH-1:0]     weight_1_wdata;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   dma_0_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] dma_0_M_AXI_ARADDR;
output wire [7:0]                      dma_0_M_AXI_ARLEN;
output wire [2:0]                      dma_0_M_AXI_ARSIZE;
output wire [1:0]                      dma_0_M_AXI_ARBURST;
output wire                            dma_0_M_AXI_ARLOCK;
output wire [3:0]                      dma_0_M_AXI_ARCACHE;
output wire [2:0]                      dma_0_M_AXI_ARPROT;
output wire [3:0]                      dma_0_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] dma_0_M_AXI_ARUSER;
output wire                            dma_0_M_AXI_ARVALID;
input                                  dma_0_M_AXI_ARREADY;
input      [AXI_M_AXI_ID_WIDTH-1:0]    dma_0_M_AXI_RID;
input      [AXI_M_AXI_DATA_WIDTH-1:0]  dma_0_M_AXI_RDATA;
input      [1:0]                       dma_0_M_AXI_RRESP;
input                                  dma_0_M_AXI_RLAST;
input      [AXI_M_AXI_USER_WIDTH-1:0]  dma_0_M_AXI_RUSER;
input                                  dma_0_M_AXI_RVALID;
output wire                            dma_0_M_AXI_RREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   dma_1_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] dma_1_M_AXI_ARADDR;
output wire [7:0]                      dma_1_M_AXI_ARLEN;
output wire [2:0]                      dma_1_M_AXI_ARSIZE;
output wire [1:0]                      dma_1_M_AXI_ARBURST;
output wire                            dma_1_M_AXI_ARLOCK;
output wire [3:0]                      dma_1_M_AXI_ARCACHE;
output wire [2:0]                      dma_1_M_AXI_ARPROT;
output wire [3:0]                      dma_1_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] dma_1_M_AXI_ARUSER;
output wire                            dma_1_M_AXI_ARVALID;
input                                  dma_1_M_AXI_ARREADY;
input      [AXI_M_AXI_ID_WIDTH-1:0]    dma_1_M_AXI_RID;
input      [AXI_M_AXI_DATA_WIDTH-1:0]  dma_1_M_AXI_RDATA;
input      [1:0]                       dma_1_M_AXI_RRESP;
input                                  dma_1_M_AXI_RLAST;
input      [AXI_M_AXI_USER_WIDTH-1:0]  dma_1_M_AXI_RUSER;
input                                  dma_1_M_AXI_RVALID;
output wire                            dma_1_M_AXI_RREADY;

reg load_0_work_en_reg;
reg load_1_work_en_reg;
wire load_0_insn_read;
wire [INSN_BITS-1:0] load_0_insn;
wire load_1_insn_read;
wire [INSN_BITS-1:0] load_1_insn;
reg load_highaddr_sel_1st;
reg load_highaddr_sel_2nd;
reg load_highaddr_sel_3rd;
reg [HIGHADDR_BITS-1:0] load_highaddr_reg_1st;
reg [HIGHADDR_BITS-1:0] load_highaddr_reg_2nd;
reg [HIGHADDR_BITS-1:0] load_highaddr_reg_3rd;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    load_0_work_en_reg <= 1'b0;
    load_1_work_en_reg <= 1'b0;
  end
  else begin
    load_0_work_en_reg <= load_0_work_en;
    load_1_work_en_reg <= load_1_work_en;
  end
end

insn_fifo #(
  .width ( INSN_BITS       ),
  .depth ( INSN_FIFO_DEPTH )
) u_load_0_insn_fifo(
  .clk      ( clk                ),
  .rst_n    ( rst_n              ),
  .w_en     ( load_0_fifo_wen    ),
  .r_en     ( load_0_insn_read   ),
  .w_data   ( load_0_fifo_wdata  ),
  .full     (                    ),
  .empty    ( load_0_fifo_empty  ),
  .afull    ( load_0_fifo_full   ),
  .aempty   (                    ),
  .hfull    (                    ),
  .hempty   (                    ),
  .r_data   ( load_0_insn        ),
  .capacity (                    )
);

insn_fifo #(
  .width ( INSN_BITS       ),
  .depth ( INSN_FIFO_DEPTH )
) u_load_1_insn_fifo(
  .clk      ( clk                ),
  .rst_n    ( rst_n              ),
  .w_en     ( load_1_fifo_wen    ),
  .r_en     ( load_1_insn_read   ),
  .w_data   ( load_1_fifo_wdata  ),
  .full     (                    ),
  .empty    ( load_1_fifo_empty  ),
  .afull    ( load_1_fifo_full   ),
  .aempty   (                    ),
  .hfull    (                    ),
  .hempty   (                    ),
  .r_data   ( load_1_insn        ),
  .capacity (                    )
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    load_highaddr_sel_1st <= 1'b0;
    load_highaddr_sel_2nd <= 1'b0;
    load_highaddr_sel_3rd <= 1'b0;
    load_highaddr_reg_1st <= 'd0;
    load_highaddr_reg_2nd <= 'd0;
    load_highaddr_reg_3rd <= 'd0;
  end
  else begin
    load_highaddr_sel_1st <= load_highaddr_sel;
    load_highaddr_reg_1st <= load_highaddr_sel ? load_highaddr : 'd0;
    load_highaddr_sel_2nd <= load_highaddr_sel_1st;
    load_highaddr_reg_2nd <= load_highaddr_sel_1st ? load_highaddr_reg_1st : 'd0;
    load_highaddr_sel_3rd <= load_highaddr_sel_2nd;
    load_highaddr_reg_3rd <= load_highaddr_sel_2nd ? load_highaddr_reg_2nd : 'd0;
  end
end

load_master_dma_0 #(
  .LOAD_INSNBITS         ( INSN_BITS                 ),
  .PERI_ADDR_WIDTH       ( MASTER_PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH    ( MASTER_PERI_BUSRSTS_WIDTH ),
  .PERI_DATA_WIDTH       ( MASTER_PERI_DATA_WIDTH    ),
  .AXI_M_AXI_ID_WIDTH    ( AXI_M_AXI_ID_WIDTH        ),
  .AXI_M_AXI_ADDR_WIDTH  ( AXI_M_AXI_ADDR_WIDTH      ),
  .AXI_M_AXI_USER_WIDTH  ( AXI_M_AXI_USER_WIDTH      ),
  .AXI_M_AXI_DATA_WIDTH  ( AXI_M_AXI_DATA_WIDTH      ),
  .AXI_M_AXI_BURSTLENGTH ( AXI_M_AXI_BURSTLENGTH     ),
  .AXI_OUTSTANDING_DEPTH ( AXI_OUTSTANDING_DEPTH     ),
  .SRAM_ADDR_WIDTH       ( MASTER_SRAM_ADDR_WIDTH    ),
  .AXI_M_AXI_MIN_ID      ( AXI_M_AXI_MIN_ID          ),
  .AXI_M_AXI_MAX_ID      ( AXI_M_AXI_MIN_ID + 16     ),
  .IFMAP_WIDTH           ( IFMAP_WIDTH               ),
  .QACT_WIDTH            ( QACT_WIDTH                ),
  .WEIGHT_WIDTH          ( WEIGHT_WIDTH              ),
  .VCUCODE_WIDTH         ( VCUCODE_WIDTH             ),
  .VCUPARA_WIDTH         ( VCUPARA_WIDTH             ),
  .VCULUT_WIDTH          ( VCULUT_WIDTH              ),
  .VCURES_WIDTH          ( VCURES_WIDTH              ),
  .IFMAP_ADDR_BITS       ( IFMAP_ADDR_BITS           ),
  .QACT_ADDR_BITS        ( QACT_ADDR_BITS            ),
  .VCUPARA_ADDR_BITS     ( VCUPARA_ADDR_BITS         ),
  .VCURES_ADDR_BITS      ( VCURES_ADDR_BITS          ),
  .VCUCODE_ADDR_BITS     ( VCUCODE_ADDR_BITS         ),
  .VCULUT_ADDR_BITS      ( VCULUT_ADDR_BITS          )
) u_load_master_0(
  .clk                     ( clk                         ),
  .fifo_rst_n              ( rst_n                       ),
  .logic_rst_n             ( logic_rst_n                 ),
  .axi4_clk                ( axi4_clk                    ),
  .axi4_rst_n              ( axi4_rst_n                  ),
  .work_en                 ( load_0_work_en_reg          ),
  .insn_read               ( load_0_insn_read            ),
  .insn                    ( load_0_insn                 ),
  .global_done             ( load_0_global_done          ),
  .local_done              ( load_0_local_done           ),
  .highaddr                ( load_highaddr_reg_3rd       ),
  .highaddr_sel            ( load_highaddr_sel_3rd       ),
  .ifmap_wvalid            ( ifmap_wvalid                ),
  .ifmap_waddr             ( ifmap_waddr                 ),
  .ifmap_wdata             ( ifmap_wdata                 ),
  .qact_wvalid             ( qact_wvalid                 ),
  .qact_waddr              ( qact_waddr                  ),
  .qact_wdata              ( qact_wdata                  ),
  .weight_wvalid           ( weight_0_wvalid             ),
  .weight_wdata            ( weight_0_wdata              ),
  .vcucode_wvalid          ( vcucode_wvalid              ),
  .vcucode_waddr           ( vcucode_waddr               ),
  .vcucode_wdata           ( vcucode_wdata               ),
  .vcupara_wvalid          ( vcupara_wvalid              ),
  .vcupara_waddr           ( vcupara_waddr               ),
  .vcupara_wdata           ( vcupara_wdata               ),
  .vcures_wvalid           ( vcures_wvalid               ),
  .vcures_waddr            ( vcures_waddr                ),
  .vcures_wdata            ( vcures_wdata                ),
  .regfile_wvalid          ( regfile_wvalid              ),
  .regfile_waddr           ( regfile_waddr               ),
  .regfile_wdata           ( regfile_wdata               ),
  .axi4_full_M_AXI_ARREADY ( dma_0_M_AXI_ARREADY        ),
  .axi4_full_M_AXI_RID     ( dma_0_M_AXI_RID            ),
  .axi4_full_M_AXI_RDATA   ( dma_0_M_AXI_RDATA          ),
  .axi4_full_M_AXI_RRESP   ( dma_0_M_AXI_RRESP          ),
  .axi4_full_M_AXI_RLAST   ( dma_0_M_AXI_RLAST          ),
  .axi4_full_M_AXI_RUSER   ( dma_0_M_AXI_RUSER          ),
  .axi4_full_M_AXI_RVALID  ( dma_0_M_AXI_RVALID         ),
  .axi4_full_M_AXI_ARID    ( dma_0_M_AXI_ARID           ),
  .axi4_full_M_AXI_ARADDR  ( dma_0_M_AXI_ARADDR         ),
  .axi4_full_M_AXI_ARLEN   ( dma_0_M_AXI_ARLEN          ),
  .axi4_full_M_AXI_ARSIZE  ( dma_0_M_AXI_ARSIZE         ),
  .axi4_full_M_AXI_ARBURST ( dma_0_M_AXI_ARBURST        ),
  .axi4_full_M_AXI_ARLOCK  ( dma_0_M_AXI_ARLOCK         ),
  .axi4_full_M_AXI_ARCACHE ( dma_0_M_AXI_ARCACHE        ),
  .axi4_full_M_AXI_ARPROT  ( dma_0_M_AXI_ARPROT         ),
  .axi4_full_M_AXI_ARQOS   ( dma_0_M_AXI_ARQOS          ),
  .axi4_full_M_AXI_ARUSER  ( dma_0_M_AXI_ARUSER         ),
  .axi4_full_M_AXI_ARVALID ( dma_0_M_AXI_ARVALID        ),
  .axi4_full_M_AXI_RREADY  ( dma_0_M_AXI_RREADY         ),
  .enable_prof_counter     ( enable_prof_counter        ),
  .execute_time            ( load_0_execute_time        )
);

load_master_dma_1 #(
  .LOAD_INSNBITS         ( INSN_BITS                 ),
  .PERI_ADDR_WIDTH       ( MASTER_PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH    ( MASTER_PERI_BUSRSTS_WIDTH ),
  .PERI_DATA_WIDTH       ( MASTER_PERI_DATA_WIDTH    ),
  .AXI_M_AXI_ID_WIDTH    ( AXI_M_AXI_ID_WIDTH        ),
  .AXI_M_AXI_ADDR_WIDTH  ( AXI_M_AXI_ADDR_WIDTH      ),
  .AXI_M_AXI_USER_WIDTH  ( AXI_M_AXI_USER_WIDTH      ),
  .AXI_M_AXI_DATA_WIDTH  ( AXI_M_AXI_DATA_WIDTH      ),
  .AXI_M_AXI_BURSTLENGTH ( AXI_M_AXI_BURSTLENGTH     ),
  .AXI_OUTSTANDING_DEPTH ( AXI_OUTSTANDING_DEPTH     ),
  .SRAM_ADDR_WIDTH       ( MASTER_SRAM_ADDR_WIDTH    ),
  .AXI_M_AXI_MIN_ID      ( AXI_M_AXI_MIN_ID + 16     ),
  .AXI_M_AXI_MAX_ID      ( AXI_M_AXI_MIN_ID + 32     ),
  .WEIGHT_WIDTH          ( WEIGHT_WIDTH              ),
  .WEIGHT_ADDR_BITS      ( WEIGHT_ADDR_BITS          )
) u_load_master_1(
  .clk                     ( clk                         ),
  .fifo_rst_n              ( rst_n                       ),
  .logic_rst_n             ( logic_rst_n                 ),
  .axi4_clk                ( axi4_clk                    ),
  .axi4_rst_n              ( axi4_rst_n                  ),
  .work_en                 ( load_1_work_en_reg          ),
  .insn_read               ( load_1_insn_read            ),
  .insn                    ( load_1_insn                 ),
  .global_done             ( load_1_global_done          ),
  .local_done              ( load_1_local_done           ),
  .highaddr                ( 24'd0                       ),
  .highaddr_sel            ( 1'b0                        ),
  .weight_wvalid           ( weight_1_wvalid               ),
  // .weight_waddr            ( weight_waddr                ),
  .weight_wdata            ( weight_1_wdata                ),
  .axi4_full_M_AXI_ARREADY ( dma_1_M_AXI_ARREADY        ),
  .axi4_full_M_AXI_RID     ( dma_1_M_AXI_RID            ),
  .axi4_full_M_AXI_RDATA   ( dma_1_M_AXI_RDATA          ),
  .axi4_full_M_AXI_RRESP   ( dma_1_M_AXI_RRESP          ),
  .axi4_full_M_AXI_RLAST   ( dma_1_M_AXI_RLAST          ),
  .axi4_full_M_AXI_RUSER   ( dma_1_M_AXI_RUSER          ),
  .axi4_full_M_AXI_RVALID  ( dma_1_M_AXI_RVALID         ),
  .axi4_full_M_AXI_ARID    ( dma_1_M_AXI_ARID           ),
  .axi4_full_M_AXI_ARADDR  ( dma_1_M_AXI_ARADDR         ),
  .axi4_full_M_AXI_ARLEN   ( dma_1_M_AXI_ARLEN          ),
  .axi4_full_M_AXI_ARSIZE  ( dma_1_M_AXI_ARSIZE         ),
  .axi4_full_M_AXI_ARBURST ( dma_1_M_AXI_ARBURST        ),
  .axi4_full_M_AXI_ARLOCK  ( dma_1_M_AXI_ARLOCK         ),
  .axi4_full_M_AXI_ARCACHE ( dma_1_M_AXI_ARCACHE        ),
  .axi4_full_M_AXI_ARPROT  ( dma_1_M_AXI_ARPROT         ),
  .axi4_full_M_AXI_ARQOS   ( dma_1_M_AXI_ARQOS          ),
  .axi4_full_M_AXI_ARUSER  ( dma_1_M_AXI_ARUSER         ),
  .axi4_full_M_AXI_ARVALID ( dma_1_M_AXI_ARVALID        ),
  .axi4_full_M_AXI_RREADY  ( dma_1_M_AXI_RREADY         ),
  .enable_prof_counter     ( enable_prof_counter        ),
  .execute_time            ( load_1_execute_time        )
);

endmodule
