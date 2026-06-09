module load_master_dma_0(
  clk, fifo_rst_n, logic_rst_n,
  work_en, insn, insn_read,
  local_done, global_done, 

  ifmap_wvalid, ifmap_waddr, ifmap_wdata,
  vcucode_wvalid, vcucode_waddr, vcucode_wdata,
  vcupara_wvalid, vcupara_waddr, vcupara_wdata,
  vcures_wvalid, vcures_waddr, vcures_wdata,

  regfile_wvalid, regfile_waddr, regfile_wdata,

  highaddr, highaddr_sel,

  enable_prof_counter, execute_time,

  axi4_clk, axi4_rst_n, 
  axi4_full_M_AXI_ARID, axi4_full_M_AXI_ARADDR, axi4_full_M_AXI_ARLEN, 
  axi4_full_M_AXI_ARSIZE, axi4_full_M_AXI_ARBURST, axi4_full_M_AXI_ARLOCK, axi4_full_M_AXI_ARCACHE, axi4_full_M_AXI_ARPROT, axi4_full_M_AXI_ARQOS, axi4_full_M_AXI_ARUSER, 
  axi4_full_M_AXI_ARVALID, axi4_full_M_AXI_ARREADY,
  axi4_full_M_AXI_RID, axi4_full_M_AXI_RDATA, axi4_full_M_AXI_RRESP, axi4_full_M_AXI_RLAST, axi4_full_M_AXI_RUSER, axi4_full_M_AXI_RVALID, axi4_full_M_AXI_RREADY
);

parameter LOAD_INSNBITS        = 128;

parameter PERI_ADDR_WIDTH      = 35;
parameter PERI_BUSRSTS_WIDTH   = 22;
parameter PERI_DATA_WIDTH      = 128;
parameter SRAM_ADDR_WIDTH      = 20;

parameter AXI_M_AXI_ID_WIDTH     = 4;
parameter AXI_M_AXI_ADDR_WIDTH   = 64;
parameter AXI_M_AXI_USER_WIDTH   = 1;
parameter AXI_M_AXI_DATA_WIDTH   = 128;
parameter AXI_M_AXI_BURSTLENGTH  = 128;
parameter AXI_OUTSTANDING_DEPTH  = 128;
parameter AXI_M_AXI_MIN_ID       = 0;
parameter AXI_M_AXI_MAX_ID       = 15;

parameter IFMAP_WIDTH             = 512;
parameter VCUCODE_WIDTH           = 64;
parameter VCUPARA_WIDTH           = 512;
parameter VCULUT_WIDTH            = 64;
parameter VCURES_WIDTH            = 512;

parameter IFMAP_ADDR_BITS         = 9;  //bank:4,2bits; addr:6bits, 36 depth, highaddr:1bits
parameter VCUPARA_ADDR_BITS       = 9;  //vector_mul, fp16
parameter VCURES_ADDR_BITS        = 9;  //vector_add, fp16
parameter VCUCODE_ADDR_BITS       = 7;
parameter VCULUT_ADDR_BITS        = 9;

input                                  clk; 
input                                  logic_rst_n;
input                                  fifo_rst_n;
input                                  work_en;
output                                 insn_read;
input       [LOAD_INSNBITS-1:0]        insn;
output wire                            local_done;
output wire                            global_done;

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

output wire [IFMAP_ADDR_BITS-1:0]         ifmap_waddr;
output wire [IFMAP_WIDTH-1:0]             ifmap_wdata;
output wire                               ifmap_wvalid;

output wire [VCUCODE_ADDR_BITS:0]         vcucode_waddr;
output wire [VCUCODE_WIDTH-1:0]           vcucode_wdata;
output wire                               vcucode_wvalid;

output wire [VCUPARA_ADDR_BITS:0]         vcupara_waddr;
output wire [VCUPARA_WIDTH-1:0]           vcupara_wdata;
output wire                               vcupara_wvalid;

output wire [VCURES_ADDR_BITS-1:0]        vcures_waddr;
output wire [VCURES_WIDTH-1:0]            vcures_wdata;
output wire                               vcures_wvalid;

output wire [31:0]                        regfile_waddr;
output wire [31:0]                        regfile_wdata;
output wire                               regfile_wvalid;

input       [23:0] highaddr;
input              highaddr_sel;

input              enable_prof_counter;
output reg  [31:0] execute_time;

wire [PERI_ADDR_WIDTH-1:0]    peripheral_M_raddr;
wire [PERI_BUSRSTS_WIDTH-1:0] peripheral_M_rlen;
wire                          peripheral_M_raddr_valid;
wire                          peripheral_M_raddr_ready;
wire [PERI_DATA_WIDTH-1:0]    peripheral_M_rdata;
wire                          peripheral_M_rdata_valid;
wire                          peripheral_M_rdata_ready;

wire [PERI_ADDR_WIDTH-1:0]    raddr_M_fifo_addr;
wire [PERI_BUSRSTS_WIDTH-1:0] raddr_M_fifo_len;
wire                          raddr_M_fifo_ready;
wire                          raddr_M_fifo_valid;
wire [PERI_DATA_WIDTH-1:0]    rdata_M_fifo_data;
wire                          rdata_M_fifo_valid;
wire                          rdata_M_fifo_ready;

wire [AXI_M_AXI_ADDR_WIDTH-1:0] local_axi_araddr;

load_insn_dma_0 #(
  .LOAD_INSNBITS      ( LOAD_INSNBITS      ),
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH ),
  .PERI_DATA_WIDTH    ( PERI_DATA_WIDTH    ),
  .SRAM_ADDR_WIDTH    ( SRAM_ADDR_WIDTH    )
) u_load_insn(
  .clk                      ( clk                      ),
  .rst_n                    ( logic_rst_n              ),
  .insn_read                ( insn_read                ),
  .work_en                  ( work_en                  ),
  .insn                     ( insn                     ),
  .peripheral_M_rdata_ready ( peripheral_M_rdata_ready ),
  .peripheral_M_rdata       ( peripheral_M_rdata       ),
  .peripheral_M_rdata_valid ( peripheral_M_rdata_valid ),
  .local_done               ( local_done               ),
  .global_done              ( global_done              ),
  .peripheral_M_raddr       ( peripheral_M_raddr       ),
  .peripheral_M_rlen        ( peripheral_M_rlen        ),
  .peripheral_M_raddr_valid ( peripheral_M_raddr_valid ),
  .peripheral_M_raddr_ready ( peripheral_M_raddr_ready ),

  .ifmap_waddr              ( ifmap_waddr              ),
  .ifmap_wdata              ( ifmap_wdata              ),
  .ifmap_wvalid             ( ifmap_wvalid             ),
  .vcucode_waddr            ( vcucode_waddr            ),
  .vcucode_wdata            ( vcucode_wdata            ),
  .vcucode_wvalid           ( vcucode_wvalid           ),
  .vcupara_waddr            ( vcupara_waddr            ),
  .vcupara_wdata            ( vcupara_wdata            ),
  .vcupara_wvalid           ( vcupara_wvalid           ),
  .vcures_waddr             ( vcures_waddr             ),
  .vcures_wdata             ( vcures_wdata             ),
  .vcures_wvalid            ( vcures_wvalid            ),
  .regfile_waddr            ( regfile_waddr            ),
  .regfile_wdata            ( regfile_wdata            ),
  .regfile_wvalid           ( regfile_wvalid           )
);

peripheral_r_addr_clk_bridge #(
  .PERI_ADDR_WIDTH    ( PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH ( PERI_BUSRSTS_WIDTH ) 
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
  .PERI_DATA_WIDTH ( PERI_DATA_WIDTH )
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


axi4_full_master_read_interface #(
  .PERI_ADDR_WIDTH        ( PERI_ADDR_WIDTH        ),
  .PERI_BUSRSTS_WIDTH     ( PERI_BUSRSTS_WIDTH     ),
  .PERI_DATA_WIDTH        ( PERI_DATA_WIDTH        ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH     ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH   ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH   ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH   ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH  ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH  ),
  .AXI_M_AXI_MAX_ID       ( AXI_M_AXI_MAX_ID       ),
  .AXI_M_AXI_MIN_ID       ( AXI_M_AXI_MIN_ID       )
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

wire [AXI_M_AXI_ADDR_WIDTH-1:0] router_ddr_axi_araddr;

ddr_axi_router u_araddr_router(
  .in_addr  ( local_axi_araddr      ),
  .out_addr ( router_ddr_axi_araddr )
);

assign axi4_full_M_AXI_ARADDR = highaddr_sel ? ({highaddr, 40'd0} | local_axi_araddr) : router_ddr_axi_araddr;

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

endmodule

