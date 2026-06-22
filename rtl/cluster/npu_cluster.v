module npu_cluster(
  clk, rst_n, cmd_rst,
  axi4_clk, axi4_rst_n,

  /* AXI-Master */
  dma_0_M_AXI_AWID, dma_0_M_AXI_AWADDR, dma_0_M_AXI_AWLEN,
  dma_0_M_AXI_AWSIZE, dma_0_M_AXI_AWBURST, dma_0_M_AXI_AWLOCK, dma_0_M_AXI_AWCACHE, dma_0_M_AXI_AWPROT, dma_0_M_AXI_AWQOS, dma_0_M_AXI_AWUSER,
  dma_0_M_AXI_AWVALID, dma_0_M_AXI_AWREADY,
  dma_0_M_AXI_WDATA, dma_0_M_AXI_WSTRB, dma_0_M_AXI_WLAST, dma_0_M_AXI_WUSER, dma_0_M_AXI_WVALID, dma_0_M_AXI_WREADY,
  dma_0_M_AXI_BID, dma_0_M_AXI_BRESP, dma_0_M_AXI_BUSER, dma_0_M_AXI_BVALID, dma_0_M_AXI_BREADY,
  
  dma_1_M_AXI_AWID, dma_1_M_AXI_AWADDR, dma_1_M_AXI_AWLEN,
  dma_1_M_AXI_AWSIZE, dma_1_M_AXI_AWBURST, dma_1_M_AXI_AWLOCK, dma_1_M_AXI_AWCACHE, dma_1_M_AXI_AWPROT, dma_1_M_AXI_AWQOS, dma_1_M_AXI_AWUSER,
  dma_1_M_AXI_AWVALID, dma_1_M_AXI_AWREADY,
  dma_1_M_AXI_WDATA, dma_1_M_AXI_WSTRB, dma_1_M_AXI_WLAST, dma_1_M_AXI_WUSER, dma_1_M_AXI_WVALID, dma_1_M_AXI_WREADY,
  dma_1_M_AXI_BID, dma_1_M_AXI_BRESP, dma_1_M_AXI_BUSER, dma_1_M_AXI_BVALID, dma_1_M_AXI_BREADY,

  /* Regfile read and write */
  slv_regfile_wvalid, slv_regfile_waddr, slv_regfile_wdata, slv_regfile_wready,
  slv_regfile_rvalid, slv_regfile_raddr, slv_regfile_rdata, slv_regfile_rready,

  /* insn_fifo */
  store_0_fifo_wen, store_0_fifo_wdata, store_0_fifo_full, store_0_fifo_empty,
  store_1_fifo_wen, store_1_fifo_wdata, store_1_fifo_full, store_1_fifo_empty,
  pea_0_fifo_wen, pea_0_fifo_wdata, pea_0_fifo_full, pea_0_fifo_empty,
  pea_1_fifo_wen, pea_1_fifo_wdata, pea_1_fifo_full, pea_1_fifo_empty,
  vcu_0_fifo_wen, vcu_0_fifo_wdata, vcu_0_fifo_full, vcu_0_fifo_empty,
  vcu_1_fifo_wen, vcu_1_fifo_wdata, vcu_1_fifo_full, vcu_1_fifo_empty,

  /* work_en */
  load_0_work_en, load_1_work_en, store_0_work_en, store_1_work_en, pea_0_work_en, pea_1_work_en, vcu_0_work_en, vcu_1_work_en,

  /* done */
  load_0_local_done, load_1_local_done, store_0_local_done, store_1_local_done, pea_0_done, pea_1_done, vcu_0_done, vcu_1_done,
  global_done,

  /* shared weight sram */
  weight_sram_rvalid, weight_sram_raddr, weight_sram_rdata,

  /* external load dma */
  load_0_local_done_wire, load_1_local_done_wire,
  load_0_global_done, load_1_global_done,
  load_0_execute_time, load_1_execute_time,
  load_dma_rst_n, enable_prof_counter,
  dma_0_ifmap_sram_wvalid, dma_0_ifmap_sram_waddr, dma_0_ifmap_sram_wdata,
  dma_0_qact_wvalid, dma_0_qact_waddr, dma_0_qact_wdata,
  dma_0_vcucode_sram_wvalid, dma_0_vcucode_sram_waddr, dma_0_vcucode_sram_wdata,
  dma_0_vcupara_sram_wvalid, dma_0_vcupara_sram_waddr, dma_0_vcupara_sram_wdata,
  dma_0_vcures_sram_wvalid, dma_0_vcures_sram_waddr, dma_0_vcures_sram_wdata,
  mst_regfile_wvalid, mst_regfile_waddr, mst_regfile_wdata,

  /* highaddr */
  load_highaddr, load_highaddr_sel,
  store_highaddr, store_highaddr_sel
);

/* -------------------------------------------------------------------------------------------------------- */
/*                                             Define Parameters                                            */
/* -------------------------------------------------------------------------------------------------------- */

parameter INSN_BITS              = 128;

parameter AXI_M_AXI_BURSTLENGTH  = 128;
parameter AXI_OUTSTANDING_DEPTH  = 8;
parameter AXI_M_AXI_ID_WIDTH     = 20;
parameter AXI_M_AXI_ADDR_WIDTH   = 64;
parameter AXI_M_AXI_USER_WIDTH   = 1;
parameter AXI_M_AXI_DATA_WIDTH   = 256;
parameter AXI_M_AXI_MIN_ID       = 0;
localparam AXI_M_AXI_DATA_BYTES  = AXI_M_AXI_DATA_WIDTH / 8;

parameter MASTER_PERI_ADDR_WIDTH    = 38;
parameter MASTER_PERI_BUSRSTS_WIDTH = 22;
parameter MASTER_PERI_DATA_WIDTH    = 256;
parameter MASTER_SRAM_ADDR_WIDTH    = 20;
parameter SLAVE_PERI_DATA_WIDTH     = 256;
parameter SLAVE_PERI_ADDR_WIDTH     = 38;
parameter SLAVE_PERI_BUSRSTS_WIDTH  = 22;

parameter WEIGHT_BANK             = 32;

parameter IFMAP_WIDTH             = 512;  //2*288, double buffer for vcu
parameter WEIGHT_WIDTH            = 288;
parameter VCUCODE_WIDTH           = 64;
parameter VCUPARA_WIDTH           = 512;
parameter VCULUT_WIDTH            = 64;
parameter VCURES_WIDTH            = 512;
parameter OFMAP_WIDTH             = 256;
parameter PSUM_WIDTH              = 512;
parameter QACT_WIDTH              = 288;
parameter SCALE_WIDTH             = 512;
parameter PEA_OFMAP_WIDTH         = 1024;

parameter IFMAP_ADDR_BITS         = 9;   //bank:1,0bits; addr:8bits, 144 depth, highaddr:1bits
parameter WEIGHT_ADDR_BITS        = 14;  //bank:32,5bits; addr:8bits, 144 depth, highaddr:1bits
parameter VCUCODE_ADDR_BITS       = 7;
parameter VCUPARA_ADDR_BITS       = 9;
parameter VCULUT_ADDR_BITS        = 9;
parameter VCURES_ADDR_BITS        = 9;
parameter OFMAP_ADDR_BITS         = 8;  //bank:1,0bits; addr:7bits, 72 depth, highaddr:1bits
parameter PSUM_ADDR_BITS          = 9;  //bank:1,0bits; addr:8bits, 144 depth, highaddr:1bits
parameter QACT_ADDR_BITS          = 9;
parameter SCALE_ADDR_BITS         = 9;
parameter PEA_OFMAP_ADDR_BITS     = 9;

parameter SYNCHRONIZE_FIFO_DEPTH = 128;
parameter HIGHADDR_BITS          = 24;

parameter integer INSN_R_ADDR_WIDTH    = 64;
parameter integer INSN_R_BUSRSTS_WIDTH = 8;
parameter integer INSN_R_DATA_WIDTH    = 256;
parameter integer INSN_FIFO_DEPTH      = 128;
parameter REG_WIDTH                    = 32;
parameter REG_NUM_BITS                 = 8;

parameter SYNCHRONIZE_INSNBITS    = 128;

/* -------------------------------------------------------------------------------------------------------- */
/*                                               Define Ports                                               */
/* -------------------------------------------------------------------------------------------------------- */

output wire [AXI_M_AXI_ID_WIDTH-1:0]     dma_0_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]   dma_0_M_AXI_AWADDR;
output wire [7:0]                        dma_0_M_AXI_AWLEN;
output wire [2:0]                        dma_0_M_AXI_AWSIZE;
output wire [1:0]                        dma_0_M_AXI_AWBURST;
output wire                              dma_0_M_AXI_AWLOCK;
output wire [3:0]                        dma_0_M_AXI_AWCACHE;
output wire [2:0]                        dma_0_M_AXI_AWPROT;
output wire [3:0]                        dma_0_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]   dma_0_M_AXI_AWUSER;
output wire                              dma_0_M_AXI_AWVALID;
input                                    dma_0_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0]   dma_0_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0]   dma_0_M_AXI_WSTRB;
output wire                              dma_0_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0]   dma_0_M_AXI_WUSER;
output wire                              dma_0_M_AXI_WVALID;
input                                    dma_0_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]      dma_0_M_AXI_BID;
input       [1:0]                        dma_0_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0]   dma_0_M_AXI_BUSER;
input                                    dma_0_M_AXI_BVALID;
output wire                              dma_0_M_AXI_BREADY;

output wire [AXI_M_AXI_ID_WIDTH-1:0]     dma_1_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]   dma_1_M_AXI_AWADDR;
output wire [7:0]                        dma_1_M_AXI_AWLEN;
output wire [2:0]                        dma_1_M_AXI_AWSIZE;
output wire [1:0]                        dma_1_M_AXI_AWBURST;
output wire                              dma_1_M_AXI_AWLOCK;
output wire [3:0]                        dma_1_M_AXI_AWCACHE;
output wire [2:0]                        dma_1_M_AXI_AWPROT;
output wire [3:0]                        dma_1_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]   dma_1_M_AXI_AWUSER;
output wire                              dma_1_M_AXI_AWVALID;
input                                    dma_1_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0]   dma_1_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0]   dma_1_M_AXI_WSTRB;
output wire                              dma_1_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0]   dma_1_M_AXI_WUSER;
output wire                              dma_1_M_AXI_WVALID;
input                                    dma_1_M_AXI_WREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]     dma_1_M_AXI_BID;
input       [1:0]                        dma_1_M_AXI_BRESP;
input       [AXI_M_AXI_USER_WIDTH-1:0]   dma_1_M_AXI_BUSER;
input                                    dma_1_M_AXI_BVALID;
output wire                              dma_1_M_AXI_BREADY;

input                                    cmd_rst;
output reg                               global_done;

input       [31:0]                       slv_regfile_waddr;
input       [31:0]                       slv_regfile_wdata;
input                                    slv_regfile_wvalid;
output wire                              slv_regfile_wready;

input       [31:0]                       slv_regfile_raddr;
input                                    slv_regfile_rvalid;
output wire [31:0]                       slv_regfile_rdata;
output wire                              slv_regfile_rready;

input                                    clk;
input                                    rst_n;

input                                    axi4_clk;
input                                    axi4_rst_n;

input                                    store_0_fifo_wen;
input       [INSN_BITS-1:0]              store_0_fifo_wdata;
output wire                              store_0_fifo_full;
output wire                              store_0_fifo_empty;

input                                    store_1_fifo_wen;
input       [INSN_BITS-1:0]              store_1_fifo_wdata;
output wire                              store_1_fifo_full;
output wire                              store_1_fifo_empty;

input                                    pea_0_fifo_wen;
input       [INSN_BITS-1:0]              pea_0_fifo_wdata;
output wire                              pea_0_fifo_full;
output wire                              pea_0_fifo_empty;

input                                    pea_1_fifo_wen;
input       [INSN_BITS-1:0]              pea_1_fifo_wdata;
output wire                              pea_1_fifo_full;
output wire                              pea_1_fifo_empty;

input                                    vcu_0_fifo_wen;
input       [INSN_BITS-1:0]              vcu_0_fifo_wdata;
output wire                              vcu_0_fifo_full;
output wire                              vcu_0_fifo_empty;

input                                    vcu_1_fifo_wen;
input       [INSN_BITS-1:0]              vcu_1_fifo_wdata;
output wire                              vcu_1_fifo_full;
output wire                              vcu_1_fifo_empty;

input                                    load_0_work_en;
input                                    load_1_work_en;
input                                    store_0_work_en;
input                                    store_1_work_en;
input                                    pea_0_work_en;
input                                    pea_1_work_en;
input                                    vcu_0_work_en;
input                                    vcu_1_work_en;

output reg                               load_0_local_done;
output reg                               load_1_local_done;
output reg                               store_0_local_done;
output reg                               store_1_local_done;
output reg                               pea_0_done;
output reg                               pea_1_done;
output reg                               vcu_0_done;
output reg                               vcu_1_done;

input      [HIGHADDR_BITS-1:0]           load_highaddr;
input                                    load_highaddr_sel;
input      [HIGHADDR_BITS-1:0]           store_highaddr;
input                                    store_highaddr_sel;

output wire                              weight_sram_rvalid;
output wire [WEIGHT_ADDR_BITS-1:0]       weight_sram_raddr;
input       [WEIGHT_WIDTH*WEIGHT_BANK-1:0] weight_sram_rdata;

input                                    load_0_local_done_wire;
input                                    load_1_local_done_wire;
input                                    load_0_global_done;
input                                    load_1_global_done;
input       [31:0]                       load_0_execute_time;
input       [31:0]                       load_1_execute_time;
output wire                              load_dma_rst_n;
output wire                              enable_prof_counter;

input                                    dma_0_ifmap_sram_wvalid;
input       [IFMAP_ADDR_BITS-1:0]        dma_0_ifmap_sram_waddr;
input       [IFMAP_WIDTH-1:0]            dma_0_ifmap_sram_wdata;

input                                    dma_0_qact_wvalid;
input       [QACT_ADDR_BITS-1:0]         dma_0_qact_waddr;
input       [QACT_WIDTH-1:0]             dma_0_qact_wdata;

input                                    dma_0_vcucode_sram_wvalid;
input       [VCUCODE_ADDR_BITS:0]        dma_0_vcucode_sram_waddr;
input       [VCUCODE_WIDTH-1:0]          dma_0_vcucode_sram_wdata;

input                                    dma_0_vcupara_sram_wvalid;
input       [VCUPARA_ADDR_BITS:0]        dma_0_vcupara_sram_waddr;
input       [VCUPARA_WIDTH-1:0]          dma_0_vcupara_sram_wdata;

input                                    dma_0_vcures_sram_wvalid;
input       [VCURES_ADDR_BITS-1:0]       dma_0_vcures_sram_waddr;
input       [VCURES_WIDTH-1:0]           dma_0_vcures_sram_wdata;

input                                    mst_regfile_wvalid;
input       [31:0]                       mst_regfile_waddr;
input       [31:0]                       mst_regfile_wdata;
 
/* -------------------------------------------------------------------------------------------------------- */
/*                                              Define Signals                                              */
/* -------------------------------------------------------------------------------------------------------- */

/* -------------------------------------------- work_en & done -------------------------------------------- */

reg  load_0_work_en_reg;
reg  load_1_work_en_reg;
reg  store_0_work_en_reg;
reg  store_1_work_en_reg;
reg  pea_0_work_en_reg;
reg  pea_1_work_en_reg;
reg  vcu_0_work_en_reg;
reg  vcu_1_work_en_reg;

wire store_0_local_done_wire;
wire store_1_local_done_wire;
wire pea_0_done_wire;
wire pea_1_done_wire;
wire vcu_0_done_wire;
wire vcu_1_done_wire;

wire store_0_global_done;
wire store_1_global_done;

reg load_0_global_done_reg;
reg load_1_global_done_reg;
reg store_0_global_done_reg;
reg store_1_global_done_reg;

/* ----------------------------------------------- sram wire ---------------------------------------------- */

wire                               dma_0_ofmap_sram_rvalid;
wire [OFMAP_ADDR_BITS-1:0]         dma_0_ofmap_sram_raddr;
wire [OFMAP_WIDTH-1:0]             dma_0_ofmap_sram_rdata;

wire                               dma_1_ofmap_sram_rvalid;
wire [OFMAP_ADDR_BITS-1:0]         dma_1_ofmap_sram_raddr;
wire [OFMAP_WIDTH-1:0]             dma_1_ofmap_sram_rdata;

wire                               pea_qact_rvalid;
wire [QACT_ADDR_BITS-1:0]          pea_qact_raddr;
wire [QACT_WIDTH-1:0]              pea_qact_rdata;

wire                               vcu_dequant_rvalid;
wire [PEA_OFMAP_ADDR_BITS-1:0]     vcu_dequant_raddr;
wire [PEA_OFMAP_WIDTH-1:0]         vcu_dequant_rdata;

wire                               pea_ofmap_sram_wvalid;
wire [PEA_OFMAP_ADDR_BITS-1:0]     pea_ofmap_sram_waddr;
wire [PEA_OFMAP_WIDTH-1:0]         pea_ofmap_sram_wdata;

/* vcu0 to sram */
wire                               ifmap_0_rvalid;
wire [IFMAP_ADDR_BITS-1:0]         ifmap_0_raddr;
wire [IFMAP_WIDTH-1:0]             ifmap_0_rdata;

wire                               psum_vcu_0_rvalid;
wire [PSUM_ADDR_BITS-1:0]          psum_vcu_0_raddr;
wire [PSUM_WIDTH-1:0]              psum_vcu_0_rdata;

wire                               psum_vcu_1_rvalid;
wire [PSUM_ADDR_BITS-1:0]          psum_vcu_1_raddr;
wire [PSUM_WIDTH-1:0]              psum_vcu_1_rdata;

wire                               vcupara_0_rvalid;
wire [VCUPARA_ADDR_BITS-1:0]       vcupara_0_raddr;
wire [VCUPARA_WIDTH-1:0]           vcupara_0_rdata;

wire                               vcures_0_rvalid;
wire [VCURES_ADDR_BITS-1:0]        vcures_0_raddr;
wire [VCURES_WIDTH-1:0]            vcures_0_rdata;

wire                               vcures_0_wvalid;
wire [VCURES_ADDR_BITS-1:0]        vcures_0_waddr;
wire [VCURES_WIDTH-1:0]            vcures_0_wdata;

wire                               vcucode_0_wvalid;
wire [6:0]                         vcucode_0_waddr;
wire [63:0]                        vcucode_0_wdata;

wire                               vcu_qact_wvalid;
wire [QACT_ADDR_BITS-1:0]          vcu_qact_waddr;
wire [QACT_WIDTH-1:0]              vcu_qact_wdata;
 
wire                               vcu_scale_wvalid;
wire [SCALE_ADDR_BITS-1:0]         vcu_scale_waddr;
wire [SCALE_WIDTH-1:0]             vcu_scale_wdata;

wire                               ofmap_0_wvalid;
wire [OFMAP_ADDR_BITS-1:0]         ofmap_0_waddr;
wire [OFMAP_WIDTH-1:0]             ofmap_0_wdata;

wire                               psum_vcu_0_wvalid;
wire [PSUM_ADDR_BITS-1:0]          psum_vcu_0_waddr;
wire [PSUM_WIDTH-1:0]              psum_vcu_0_wdata;

wire                               psum_vcu_1_wvalid;
wire [PSUM_ADDR_BITS-1:0]          psum_vcu_1_waddr;
wire [PSUM_WIDTH-1:0]              psum_vcu_1_wdata;
wire [PSUM_WIDTH-1:0]              psum_vcu_1_dma_rdata_unused;

/* regfile wvalid */
wire                               mst_regfile_rvalid;
wire                               mst_regfile_rready;
wire [31:0]                        mst_regfile_raddr;
wire [31:0]                        mst_regfile_rdata;

wire                               mst_regfile_wready;

/* ---------------------------------------- control & debug signals --------------------------------------- */

/* execute time signals */
wire [31:0] store_0_execute_time;
wire [31:0] store_1_execute_time;
wire [31:0] pea_0_execute_time;
wire [31:0] pea_1_execute_time;
wire [31:0] vcu_0_execute_time;
wire [31:0] vcu_1_execute_time;
wire [31:0] total_execute_time;

/* control signals */
wire [1:0] psum_load_valid_bits;
wire [1:0] psum_store_valid_bits;
wire [1:0] vcures_load_valid_bits;
wire [1:0] ifmap_mask_load_valid_bits;

/* --------------------------------------- Instruction fifo signals --------------------------------------- */

/* store 0 fifo signals */
wire                 store_0_insn_read;
wire [INSN_BITS-1:0] store_0_insn;

/* store 1 fifo signals */
wire                 store_1_insn_read;
wire [INSN_BITS-1:0] store_1_insn;

/* pea 0 fifo signals */
wire                 pea_0_insn_read;
wire [INSN_BITS-1:0] pea_0_insn;

/* pea 1 fifo signals */
wire                 pea_1_insn_read;
wire [INSN_BITS-1:0] pea_1_insn;

/* vcu 0 fifo signals */
wire                 vcu_0_insn_read;
wire [INSN_BITS-1:0] vcu_0_insn;

/* vcu 1 fifo signals */
wire                 vcu_1_insn_read;
wire [INSN_BITS-1:0] vcu_1_insn;

/* ------------------------------------------- highaddr control ------------------------------------------- */

reg                      load_highaddr_sel_1st;
reg                      load_highaddr_sel_2nd;
reg                      load_highaddr_sel_3rd;

reg                      store_highaddr_sel_1st;
reg                      store_highaddr_sel_2nd;
reg                      store_highaddr_sel_3rd;

reg  [HIGHADDR_BITS-1:0] load_highaddr_reg_1st;
reg  [HIGHADDR_BITS-1:0] load_highaddr_reg_2nd;
reg  [HIGHADDR_BITS-1:0] load_highaddr_reg_3rd;

reg  [HIGHADDR_BITS-1:0] store_highaddr_reg_1st;
reg  [HIGHADDR_BITS-1:0] store_highaddr_reg_2nd;
reg  [HIGHADDR_BITS-1:0] store_highaddr_reg_3rd;

/* -------------------------------------------------------------------------------------------------------- */
/*                                                  modules                                                 */
/* -------------------------------------------------------------------------------------------------------- */

/* reset generate */
rst_cluster  u_rst_cluster(
  .clk                ( clk                   ),
  .rst_n              ( rst_n                 ),
  .rst_soft           ( cmd_rst               ),
  .pea_0_rst_n        ( pea_0_rst_n           ),
  .pea_1_rst_n        ( pea_1_rst_n           ),
  .vcu_0_rst_n        ( vcu_0_rst_n           ),
  .vcu_1_rst_n        ( vcu_1_rst_n           ),
  .dma_rst_n          ( dma_rst_n             ),
  .fifo_rst_n         ( fifo_rst_n            ),
  .sram_rst_n         ( sram_rst_n            )
);

assign load_dma_rst_n = dma_rst_n;

/* store 0 */
store_master_dma_0 #(
  .STORE_INSNBITS         ( INSN_BITS                 ),
  .PERI_ADDR_WIDTH        ( MASTER_PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH     ( MASTER_PERI_BUSRSTS_WIDTH ),
  .PERI_DATA_WIDTH        ( MASTER_PERI_DATA_WIDTH    ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH        ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH      ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH      ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH      ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH     ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH     ),
  .SRAM_ADDR_WIDTH        ( MASTER_SRAM_ADDR_WIDTH    ),
  .AXI_M_AXI_MIN_ID       ( AXI_M_AXI_MIN_ID + 32     ),
  .AXI_M_AXI_MAX_ID       ( AXI_M_AXI_MIN_ID + 48     )
) u_store_master_0(
  /* clk & reset */
  .axi4_clk                ( axi4_clk                ),
  .axi4_rst_n              ( axi4_rst_n              ),
  .clk                     ( clk                     ),
  .fifo_rst_n              ( rst_n                   ),
  .logic_rst_n             ( dma_rst_n               ),
  
  /* control signals */
  .work_en                 ( store_0_work_en_reg     ),
  .insn_read               ( store_0_insn_read       ),
  .insn                    ( store_0_insn            ),
  .local_done              ( store_0_local_done_wire ),
  .global_done             ( store_0_global_done     ),
  .highaddr                ( store_highaddr_reg_3rd  ),
  .highaddr_sel            ( store_highaddr_sel_3rd  ),
  
  /* sram signals */
  .psum_rvalid             ( dma_0_psum_sram_rvalid  ),
  .psum_raddr              ( dma_0_psum_sram_raddr   ),
  .psum_rdata              ( dma_0_psum_sram_rdata   ),

  .ofmap_rvalid            ( dma_0_ofmap_sram_rvalid ),
  .ofmap_raddr             ( dma_0_ofmap_sram_raddr  ),
  .ofmap_rdata             ( dma_0_ofmap_sram_rdata  ),

  .psum_store_valid_bits   ( psum_store_valid_bits   ),
  
  /* axi signals */
  .axi4_full_M_AXI_AWREADY ( dma_0_M_AXI_AWREADY     ),
  .axi4_full_M_AXI_WREADY  ( dma_0_M_AXI_WREADY      ),
  .axi4_full_M_AXI_BID     ( dma_0_M_AXI_BID         ),
  .axi4_full_M_AXI_BRESP   ( dma_0_M_AXI_BRESP       ),
  .axi4_full_M_AXI_BUSER   ( dma_0_M_AXI_BUSER       ),
  .axi4_full_M_AXI_BVALID  ( dma_0_M_AXI_BVALID      ),
  .axi4_full_M_AXI_AWID    ( dma_0_M_AXI_AWID        ),
  .axi4_full_M_AXI_AWADDR  ( dma_0_M_AXI_AWADDR      ),
  .axi4_full_M_AXI_AWLEN   ( dma_0_M_AXI_AWLEN       ),
  .axi4_full_M_AXI_AWSIZE  ( dma_0_M_AXI_AWSIZE      ),
  .axi4_full_M_AXI_AWBURST ( dma_0_M_AXI_AWBURST     ),
  .axi4_full_M_AXI_AWLOCK  ( dma_0_M_AXI_AWLOCK      ),
  .axi4_full_M_AXI_AWCACHE ( dma_0_M_AXI_AWCACHE     ),
  .axi4_full_M_AXI_AWPROT  ( dma_0_M_AXI_AWPROT      ),
  .axi4_full_M_AXI_AWQOS   ( dma_0_M_AXI_AWQOS       ),
  .axi4_full_M_AXI_AWUSER  ( dma_0_M_AXI_AWUSER      ),
  .axi4_full_M_AXI_AWVALID ( dma_0_M_AXI_AWVALID     ),
  .axi4_full_M_AXI_WDATA   ( dma_0_M_AXI_WDATA       ),
  .axi4_full_M_AXI_WSTRB   ( dma_0_M_AXI_WSTRB       ),
  .axi4_full_M_AXI_WLAST   ( dma_0_M_AXI_WLAST       ),
  .axi4_full_M_AXI_WUSER   ( dma_0_M_AXI_WUSER       ),
  .axi4_full_M_AXI_WVALID  ( dma_0_M_AXI_WVALID      ),
  .axi4_full_M_AXI_BREADY  ( dma_0_M_AXI_BREADY      ),
  
  /* prof counter */
  .enable_prof_counter     ( enable_prof_counter     ),
  .execute_time            ( store_0_execute_time    )
);

/* store 1 */
store_master_dma_1 #(
  .STORE_INSNBITS         ( INSN_BITS                 ),
  .PERI_ADDR_WIDTH        ( MASTER_PERI_ADDR_WIDTH    ),
  .PERI_BUSRSTS_WIDTH     ( MASTER_PERI_BUSRSTS_WIDTH ),
  .PERI_DATA_WIDTH        ( MASTER_PERI_DATA_WIDTH    ),
  .AXI_M_AXI_ID_WIDTH     ( AXI_M_AXI_ID_WIDTH        ),
  .AXI_M_AXI_ADDR_WIDTH   ( AXI_M_AXI_ADDR_WIDTH      ),
  .AXI_M_AXI_USER_WIDTH   ( AXI_M_AXI_USER_WIDTH      ),
  .AXI_M_AXI_DATA_WIDTH   ( AXI_M_AXI_DATA_WIDTH      ),
  .AXI_M_AXI_BURSTLENGTH  ( AXI_M_AXI_BURSTLENGTH     ),
  .AXI_OUTSTANDING_DEPTH  ( AXI_OUTSTANDING_DEPTH     ),
  .SRAM_ADDR_WIDTH        ( MASTER_SRAM_ADDR_WIDTH    ),
  .AXI_M_AXI_MIN_ID       ( AXI_M_AXI_MIN_ID + 48     ),
  .AXI_M_AXI_MAX_ID       ( AXI_M_AXI_MIN_ID + 64     )
) u_store_master_1(
  /* clk & reset */
  .axi4_clk                ( axi4_clk                ),
  .axi4_rst_n              ( axi4_rst_n              ),
  .clk                     ( clk                     ),
  .fifo_rst_n              ( rst_n                   ),
  .logic_rst_n             ( dma_rst_n               ),
  
  /* control signals */
  .work_en                 ( store_1_work_en_reg     ),
  .insn_read               ( store_1_insn_read       ),
  .insn                    ( store_1_insn            ),
  .local_done              ( store_1_local_done_wire ),
  .global_done             ( store_1_global_done     ),
  .highaddr                ( 24'd0                   ),
  .highaddr_sel            ( 1'b0                    ),
  
  /* sram signals */
  .ofmap_rvalid            ( dma_1_ofmap_sram_rvalid ),
  .ofmap_raddr             ( dma_1_ofmap_sram_raddr  ),
  .ofmap_rdata             ( dma_1_ofmap_sram_rdata  ),
  
  /* axi signals */
  .axi4_full_M_AXI_AWREADY ( dma_1_M_AXI_AWREADY     ),
  .axi4_full_M_AXI_WREADY  ( dma_1_M_AXI_WREADY      ),
  .axi4_full_M_AXI_BID     ( dma_1_M_AXI_BID         ),
  .axi4_full_M_AXI_BRESP   ( dma_1_M_AXI_BRESP       ),
  .axi4_full_M_AXI_BUSER   ( dma_1_M_AXI_BUSER       ),
  .axi4_full_M_AXI_BVALID  ( dma_1_M_AXI_BVALID      ),
  .axi4_full_M_AXI_AWID    ( dma_1_M_AXI_AWID        ),
  .axi4_full_M_AXI_AWADDR  ( dma_1_M_AXI_AWADDR      ),
  .axi4_full_M_AXI_AWLEN   ( dma_1_M_AXI_AWLEN       ),
  .axi4_full_M_AXI_AWSIZE  ( dma_1_M_AXI_AWSIZE      ),
  .axi4_full_M_AXI_AWBURST ( dma_1_M_AXI_AWBURST     ),
  .axi4_full_M_AXI_AWLOCK  ( dma_1_M_AXI_AWLOCK      ),
  .axi4_full_M_AXI_AWCACHE ( dma_1_M_AXI_AWCACHE     ),
  .axi4_full_M_AXI_AWPROT  ( dma_1_M_AXI_AWPROT      ),
  .axi4_full_M_AXI_AWQOS   ( dma_1_M_AXI_AWQOS       ),
  .axi4_full_M_AXI_AWUSER  ( dma_1_M_AXI_AWUSER      ),
  .axi4_full_M_AXI_AWVALID ( dma_1_M_AXI_AWVALID     ),
  .axi4_full_M_AXI_WDATA   ( dma_1_M_AXI_WDATA       ),
  .axi4_full_M_AXI_WSTRB   ( dma_1_M_AXI_WSTRB       ),
  .axi4_full_M_AXI_WLAST   ( dma_1_M_AXI_WLAST       ),
  .axi4_full_M_AXI_WUSER   ( dma_1_M_AXI_WUSER       ),
  .axi4_full_M_AXI_WVALID  ( dma_1_M_AXI_WVALID      ),
  .axi4_full_M_AXI_BREADY  ( dma_1_M_AXI_BREADY      ),
  
  /* prof counter */
  .enable_prof_counter     ( enable_prof_counter     ),
  .execute_time            ( store_1_execute_time    )
);

insn_fifo_wrapper #(
  .INSN_WIDTH      ( INSN_BITS       ),
  .INSN_FIFO_DEPTH ( INSN_FIFO_DEPTH ),
  .HAS_LOAD_FIFO   ( 0               )
) u_insn_fifo_wrapper(
  /* clk & reset */
  .clk                    ( clk                    ),
  .rst_n                  ( fifo_rst_n             ),
  
  .store_0_fifo_wen       ( store_0_fifo_wen       ),
  .store_0_fifo_wdata     ( store_0_fifo_wdata     ),
  .store_0_fifo_ren       ( store_0_insn_read      ),
  .store_0_fifo_rdata     ( store_0_insn           ),
  .store_0_fifo_full      ( store_0_fifo_full      ),
  .store_0_fifo_empty     ( store_0_fifo_empty     ),
  
  .store_1_fifo_wen       ( store_1_fifo_wen       ),
  .store_1_fifo_wdata     ( store_1_fifo_wdata     ),
  .store_1_fifo_ren       ( store_1_insn_read      ),
  .store_1_fifo_rdata     ( store_1_insn           ),
  .store_1_fifo_full      ( store_1_fifo_full      ),
  .store_1_fifo_empty     ( store_1_fifo_empty     ),
  
  .pea_0_fifo_wen         ( pea_0_fifo_wen         ),
  .pea_0_fifo_wdata       ( pea_0_fifo_wdata       ),
  .pea_0_fifo_ren         ( pea_0_fifo_ren         ),
  .pea_0_fifo_rdata       ( pea_0_insn             ),
  .pea_0_fifo_full        ( pea_0_fifo_full        ),
  .pea_0_fifo_empty       ( pea_0_fifo_empty       ),
  
  .pea_1_fifo_wen         ( pea_1_fifo_wen         ),
  .pea_1_fifo_wdata       ( pea_1_fifo_wdata       ),
  .pea_1_fifo_ren         ( pea_1_fifo_ren         ),
  .pea_1_fifo_rdata       ( pea_1_insn             ),
  .pea_1_fifo_full        ( pea_1_fifo_full        ),
  .pea_1_fifo_empty       ( pea_1_fifo_empty       ),

  .vcu_0_fifo_wen         ( vcu_0_fifo_wen         ),
  .vcu_0_fifo_wdata       ( vcu_0_fifo_wdata       ),
  .vcu_0_fifo_ren         ( vcu_0_fifo_ren         ),
  .vcu_0_fifo_rdata       ( vcu_0_insn             ),
  .vcu_0_fifo_full        ( vcu_0_fifo_full        ),
  .vcu_0_fifo_empty       ( vcu_0_fifo_empty       ),

  .vcu_1_fifo_wen         ( vcu_1_fifo_wen         ),
  .vcu_1_fifo_wdata       ( vcu_1_fifo_wdata       ),
  .vcu_1_fifo_ren         ( vcu_1_fifo_ren         ),
  .vcu_1_fifo_rdata       ( vcu_1_insn             ),
  .vcu_1_fifo_full        ( vcu_1_fifo_full        ),
  .vcu_1_fifo_empty       ( vcu_1_fifo_empty       )
);

/* -------------------------------------------- Compute Modules ------------------------------------------- */
pea u_pea_0(
  .clk                        ( clk                       ),
  .rst_n                      ( pea_0_rst_n               ),
  .work_en                    ( pea_0_work_en_reg          ),
  .insn                       ( pea_0_insn                ),
  .insn_read                  ( pea_0_fifo_ren            ),
  .done                       ( pea_0_done_wire           ),

  .ifmap_sram_rvalid          ( pea_qact_rvalid           ),
  .ifmap_sram_raddr           ( pea_qact_raddr            ),
  .ifmap_sram_rdata           ( pea_qact_rdata            ),

  .weight_sram_rvalid         ( weight_sram_rvalid        ),
  .weight_sram_raddr          ( weight_sram_raddr         ),
  .weight_sram_rdata          ( weight_sram_rdata         ),

  .ofmap_sram_wvalid          ( pea_ofmap_sram_wvalid     ),
  .ofmap_sram_waddr           ( pea_ofmap_sram_waddr      ),
  .ofmap_sram_wdata           ( pea_ofmap_sram_wdata      ),

  .enable_prof_counter        ( enable_prof_counter       ),
  .execute_time               ( pea_0_execute_time        )
);

vcu u_vcu_0(
  .clk                 ( clk                 ),
  .rst_n               ( vcu_0_rst_n         ),
  .work_en             ( vcu_0_work_en_reg   ),
  .insn                ( vcu_0_insn          ),
  .done                ( vcu_0_done_wire     ),
  .insn_read           ( vcu_0_fifo_ren      ),

  .psum_rvalid         ( psum_vcu_0_rvalid   ),
  .psum_raddr          ( psum_vcu_0_raddr    ),
  .psum_rdata          ( psum_vcu_0_rdata    ),

  .psum_1_rvalid       ( psum_vcu_1_rvalid   ),
  .psum_1_raddr        ( psum_vcu_1_raddr    ),
  .psum_1_rdata        ( psum_vcu_1_rdata    ),

  .ifmap_rvalid        ( ifmap_0_rvalid      ),
  .ifmap_raddr         ( ifmap_0_raddr       ),
  .ifmap_rdata         ( ifmap_0_rdata       ),

  .dequant_rvalid      ( vcu_dequant_rvalid  ),
  .dequant_raddr       ( vcu_dequant_raddr   ),
  .dequant_rdata       ( vcu_dequant_rdata   ),
  
  .vcupara_rvalid      ( vcupara_0_rvalid    ),
  .vcupara_raddr       ( vcupara_0_raddr     ),
  .vcupara_rdata       ( vcupara_0_rdata     ),

  .vcucode_wvalid      ( vcucode_0_wvalid    ),
  .vcucode_waddr       ( vcucode_0_waddr     ),
  .vcucode_wdata       ( vcucode_0_wdata     ),

  .ofmap_wvalid        ( ofmap_0_wvalid      ),
  .ofmap_waddr         ( ofmap_0_waddr       ),
  .ofmap_wdata         ( ofmap_0_wdata       ),
  
  .vcures_rvalid       ( vcures_0_rvalid     ),
  .vcures_raddr        ( vcures_0_raddr      ),
  .vcures_rdata        ( vcures_0_rdata      ),
  
  .psum_wvalid         ( psum_vcu_0_wvalid   ),
  .psum_waddr          ( psum_vcu_0_waddr    ),
  .psum_wdata          ( psum_vcu_0_wdata    ),

  .psum_1_wvalid       ( psum_vcu_1_wvalid   ),
  .psum_1_waddr        ( psum_vcu_1_waddr    ),
  .psum_1_wdata        ( psum_vcu_1_wdata    ),

  .vcures_wvalid       ( vcures_0_wvalid     ),
  .vcures_waddr        ( vcures_0_waddr      ),
  .vcures_wdata        ( vcures_0_wdata      ),

  //To Pea
  .qact_wvalid         ( vcu_qact_wvalid     ),
  .qact_waddr          ( vcu_qact_waddr      ),
  .qact_wdata          ( vcu_qact_wdata      ),

  .scale_wvalid        ( vcu_scale_wvalid    ),
  .scale_waddr         ( vcu_scale_waddr     ),
  .scale_wdata         ( vcu_scale_wdata     ),

  .enable_prof_counter ( enable_prof_counter ),
  .execute_time        ( vcu_0_execute_time  )
);

/* ------------------------------------------------ regfile ----------------------------------------------- */

regfile_cluster u_regfile_cluster(
  .clk                        ( clk                        ),
  .rst_n                      ( rst_n                      ),

  .mst_wvalid                 ( mst_regfile_wvalid         ),
  .mst_waddr                  ( mst_regfile_waddr          ),
  .mst_wdata                  ( mst_regfile_wdata          ),
  .mst_wready                 ( mst_regfile_wready         ),
  .mst_rvalid                 ( 1'b0                       ),
  .mst_raddr                  ( 32'd0                      ),
  .mst_rdata                  ( mst_regfile_rdata          ),
  .mst_rready                 ( mst_regfile_rready         ),

  .slv_wvalid                 ( slv_regfile_wvalid         ),
  .slv_waddr                  ( slv_regfile_waddr          ),
  .slv_wdata                  ( slv_regfile_wdata          ),
  .slv_rvalid                 ( slv_regfile_rvalid         ),
  .slv_raddr                  ( slv_regfile_raddr          ),
  .slv_wready                 ( slv_regfile_wready         ),
  .slv_rready                 ( slv_regfile_rready         ),
  .slv_rdata                  ( slv_regfile_rdata          ),

  .load_0_execute_time        ( load_0_execute_time        ),
  .load_1_execute_time        ( load_1_execute_time        ),
  .store_0_execute_time       ( store_0_execute_time       ),
  .store_1_execute_time       ( store_1_execute_time       ),
  .pea_0_execute_time         ( pea_0_execute_time         ),
  .pea_1_execute_time         ( pea_1_execute_time         ),
  .vcu_0_execute_time         ( vcu_0_execute_time         ),
  .vcu_1_execute_time         ( vcu_1_execute_time         ),

  .psum_load_valid_bits       ( psum_load_valid_bits       ),
  .psum_store_valid_bits      ( psum_store_valid_bits      ),
  .vcures_load_valid_bits     ( vcures_load_valid_bits     ),
  .ifmap_mask_load_valid_bits ( ifmap_mask_load_valid_bits ),
  .enable_prof_counter        ( enable_prof_counter        ),

  .broadcast                  ( broadcast                  )
);

/* ------------------------------------------------- srams ------------------------------------------------ */

//pea: int8
qact_ram #(
  .WIDTH      ( QACT_WIDTH               ),     
  .ADDR_BITS  ( QACT_ADDR_BITS           )
) u_qact_ram(
  .clk        ( clk                     ),
  .rst_n      ( rst_n                   ),

  .rvalid_0   ( pea_qact_rvalid         ),
  .raddr_0    ( pea_qact_raddr          ),
  .rdata_0    ( pea_qact_rdata          ),

  .dma_wvalid ( dma_0_qact_wvalid       ),
  .dma_waddr  ( dma_0_qact_waddr        ),
  .dma_wdata  ( dma_0_qact_wdata        ),

  .wvalid     ( vcu_qact_wvalid         ),
  .waddr      ( vcu_qact_waddr          ),
  .wdata      ( vcu_qact_wdata          )
);

//pea: fp16
pea_ofmap_ram #(
  .WIDTH      ( PEA_OFMAP_WIDTH         ),
  .ADDR_BITS  ( PEA_OFMAP_ADDR_BITS     )
) u_pea_ofmap_ram(
  .clk        ( clk                     ),
  .rst_n      ( rst_n                   ),

  .rvalid_0   ( vcu_dequant_rvalid      ),
  .raddr_0    ( vcu_dequant_raddr       ),
  .rdata_0    ( vcu_dequant_rdata       ),

  .wvalid     ( pea_ofmap_sram_wvalid   ),
  .waddr      ( pea_ofmap_sram_waddr    ),
  .wdata      ( pea_ofmap_sram_wdata    )
);

ofmap_ram u_ofmap_ram(
  .clk          ( clk                     ),
  .rst_n        ( rst_n                   ),
  .wvalid_0     ( ofmap_0_wvalid          ),
  .waddr_0      ( ofmap_0_waddr           ),
  .wdata_0      ( ofmap_0_wdata           ),
  .wvalid_1     ( ofmap_1_wvalid          ),
  .waddr_1      ( ofmap_1_waddr           ),
  .wdata_1      ( ofmap_1_wdata           ),
  .dma_0_rvalid ( dma_0_ofmap_sram_rvalid ),
  .dma_0_raddr  ( dma_0_ofmap_sram_raddr  ),
  .dma_0_rdata  ( dma_0_ofmap_sram_rdata  ),

  .dma_1_rvalid ( dma_1_ofmap_sram_rvalid ),
  .dma_1_raddr  ( dma_1_ofmap_sram_raddr  ),
  .dma_1_rdata  ( dma_1_ofmap_sram_rdata  )
);

//vcu: fp16
ifmap_ram #(
  .WIDTH      ( IFMAP_WIDTH             ),     
  .ADDR_BITS  ( IFMAP_ADDR_BITS         )
) u_ifmap_vcu_ram(
  .clk        ( clk                     ),
  .rst_n      ( rst_n                   ),

  .rvalid_0   ( ifmap_0_rvalid          ),
  .raddr_0    ( ifmap_0_raddr           ),
  .rdata_0    ( ifmap_0_rdata           ),

  .dma_wvalid ( dma_0_ifmap_sram_wvalid ),
  .dma_waddr  ( dma_0_ifmap_sram_waddr  ),
  .dma_wdata  ( dma_0_ifmap_sram_wdata  )
);

vcumul_ram #(
  .WIDTH      ( VCUPARA_WIDTH             ),     
  .ADDR_BITS  ( VCUPARA_ADDR_BITS         )
) u_vcumul_ram(
  .clk        ( clk                       ),
  .rst_n      ( rst_n                     ),
  .rvalid_0   ( vcupara_0_rvalid          ),
  .raddr_0    ( vcupara_0_raddr           ),
  .rdata_0    ( vcupara_0_rdata           ),
  .dma_wvalid ( dma_0_vcupara_sram_wvalid ),
  .dma_waddr  ( dma_0_vcupara_sram_waddr  ),
  .dma_wdata  ( dma_0_vcupara_sram_wdata  )
);

vcuadd_ram #(
  .WIDTH      ( VCURES_WIDTH             ),     
  .ADDR_BITS  ( VCURES_ADDR_BITS         )
) u_vcuresadd_ram(
  .clk        ( clk                      ),
  .rst_n      ( rst_n                    ),
  
  .rvalid_0   ( vcures_0_rvalid          ),
  .raddr_0    ( vcures_0_raddr           ),
  .rdata_0    ( vcures_0_rdata           ),

  .dma_wvalid ( dma_0_vcures_sram_wvalid ),
  .dma_waddr  ( dma_0_vcures_sram_waddr  ),
  .dma_wdata  ( dma_0_vcures_sram_wdata  )
);

psum_vcu_0_ram #(
  .WIDTH      ( PSUM_WIDTH               ),     
  .ADDR_BITS  ( PSUM_ADDR_BITS           )
) u_psum_vcu_0_ram(
  .clk          ( clk                     ),
  .rst_n        ( rst_n                   ),

  .vcu_0_wvalid ( psum_vcu_0_wvalid       ),
  .vcu_0_waddr  ( psum_vcu_0_waddr        ),
  .vcu_0_wdata  ( psum_vcu_0_wdata        ),

  .vcu_0_rvalid ( psum_vcu_0_rvalid       ),
  .vcu_0_raddr  ( psum_vcu_0_raddr        ),
  .vcu_0_rdata  ( psum_vcu_0_rdata        ),

  .dma_rvalid   ( dma_0_psum_sram_rvalid  ),
  .dma_raddr    ( dma_0_psum_sram_raddr   ),
  .dma_rdata    ( dma_0_psum_sram_rdata   )
);

psum_vcu_1_ram #(
  .WIDTH      ( PSUM_WIDTH               ),     
  .ADDR_BITS  ( PSUM_ADDR_BITS           )
) u_psum_vcu_1_ram(
  .clk          ( clk                     ),
  .rst_n        ( rst_n                   ),

  .vcu_0_wvalid ( psum_vcu_1_wvalid       ),
  .vcu_0_waddr  ( psum_vcu_1_waddr        ),
  .vcu_0_wdata  ( psum_vcu_1_wdata        ),

  .vcu_0_rvalid ( psum_vcu_1_rvalid       ),
  .vcu_0_raddr  ( psum_vcu_1_raddr        ),
  .vcu_0_rdata  ( psum_vcu_1_rdata        ),

  .dma_rvalid   ( dma_0_psum_sram_rvalid  ),
  .dma_raddr    ( dma_0_psum_sram_raddr   ),
  .dma_rdata    ( dma_0_psum_sram_rdata   )
);

vcucode_ram_dispatch  u_vcucode_ram_dispatch(
  .clk         ( clk                       ),
  .rst_n       ( rst_n                     ),
  .dma_wvalid  ( dma_0_vcucode_sram_wvalid ),
  .dma_waddr   ( dma_0_vcucode_sram_waddr  ),
  .dma_wdata   ( dma_0_vcucode_sram_wdata  ),
  .wvalid_0    ( vcucode_0_wvalid          ),
  .waddr_0     ( vcucode_0_waddr           ),
  .wdata_0     ( vcucode_0_wdata           ),
  .wvalid_1    ( vcucode_1_wvalid          ),
  .waddr_1     ( vcucode_1_waddr           ),
  .wdata_1     ( vcucode_1_wdata           )
);



/* -------------------------------------------------------------------------------------------------------- */
/*                                             Highaddr Pipeline                                            */
/* -------------------------------------------------------------------------------------------------------- */

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
    if (load_highaddr_sel) begin
      load_highaddr_sel_1st <= 1'b1;
      load_highaddr_reg_1st <= load_highaddr;
    end
    else begin
      load_highaddr_sel_1st <= 1'b0;
      load_highaddr_reg_1st <= 'd0;
    end

    if (load_highaddr_sel_1st) begin
      load_highaddr_sel_2nd <= 1'b1;
      load_highaddr_reg_2nd <= load_highaddr_reg_1st;
    end
    else begin
      load_highaddr_sel_2nd <= 1'b0;
      load_highaddr_reg_2nd <= 'd0;
    end

    if (load_highaddr_sel_2nd) begin
      load_highaddr_sel_3rd <= 1'b1;
      load_highaddr_reg_3rd <= load_highaddr_reg_2nd;
    end
    else begin
      load_highaddr_sel_3rd <= 1'b0;
      load_highaddr_reg_3rd <= 'd0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    store_highaddr_sel_1st <= 1'b0;
    store_highaddr_sel_2nd <= 1'b0;
    store_highaddr_sel_3rd <= 1'b0;
    store_highaddr_reg_1st <= 'd0;
    store_highaddr_reg_2nd <= 'd0;
    store_highaddr_reg_3rd <= 'd0;
  end
  else begin
    if (store_highaddr_sel) begin
      store_highaddr_sel_1st <= 1'b1;
      store_highaddr_reg_1st <= store_highaddr;
    end
    else begin
      store_highaddr_sel_1st <= 1'b0;
      store_highaddr_reg_1st <= 'd0;
    end

    if (store_highaddr_sel_1st) begin
      store_highaddr_sel_2nd <= 1'b1;
      store_highaddr_reg_2nd <= store_highaddr_reg_1st;
    end
    else begin
      store_highaddr_sel_2nd <= 1'b0;
      store_highaddr_reg_2nd <= 'd0;
    end

    if (store_highaddr_sel_2nd) begin
      store_highaddr_sel_3rd <= 1'b1;
      store_highaddr_reg_3rd <= store_highaddr_reg_2nd;
    end
    else begin
      store_highaddr_sel_3rd <= 1'b0;
      store_highaddr_reg_3rd <= 'd0;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Done logic                                                */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    load_0_local_done  <= 1'b0;
    load_1_local_done  <= 1'b0;
    store_0_local_done <= 1'b0;
    store_1_local_done <= 1'b0;
    pea_0_done         <= 1'b0;
    pea_1_done         <= 1'b0;
    vcu_0_done         <= 1'b0;
    vcu_1_done         <= 1'b0;
  end
  else begin
    if (load_0_local_done_wire) begin
      load_0_local_done <= 1'b1;
    end
    else begin
      load_0_local_done <= 1'b0;
    end

    if (load_1_local_done_wire) begin
      load_1_local_done <= 1'b1;
    end
    else begin
      load_1_local_done <= 1'b0;
    end

    if (store_0_local_done_wire) begin
      store_0_local_done <= 1'b1;
    end
    else begin
      store_0_local_done <= 1'b0;
    end

    if (store_1_local_done_wire) begin
      store_1_local_done <= 1'b1;
    end
    else begin
      store_1_local_done <= 1'b0;
    end

    if (pea_0_done_wire) begin
      pea_0_done <= 1'b1;
    end
    else begin
      pea_0_done <= 1'b0;
    end

    if (pea_1_done_wire) begin
      pea_1_done <= 1'b1;
    end
    else begin
      pea_1_done <= 1'b0;
    end

    if (vcu_0_done_wire) begin
      vcu_0_done <= 1'b1;
    end
    else begin
      vcu_0_done <= 1'b0;
    end

    if (vcu_1_done_wire) begin
      vcu_1_done <= 1'b1;
    end
    else begin
      vcu_1_done <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    global_done <= 1'b0;
    load_0_global_done_reg <= 1'b0;
    load_1_global_done_reg <= 1'b0;
    store_0_global_done_reg <= 1'b0;
    store_1_global_done_reg <= 1'b0;
  end
  else begin
    if (load_0_global_done) begin
      load_0_global_done_reg <= 1'b1;
    end
    else begin
      load_0_global_done_reg <= 1'b0;
    end

    if (load_1_global_done) begin
      load_1_global_done_reg <= 1'b1;
    end
    else begin
      load_1_global_done_reg <= 1'b0;
    end

    if (store_0_global_done) begin
      store_0_global_done_reg <= 1'b1;
    end
    else begin
      store_0_global_done_reg <= 1'b0;
    end

    if (store_1_global_done) begin
      store_1_global_done_reg <= 1'b1;
    end
    else begin
      store_1_global_done_reg <= 1'b0;
    end

    if (load_0_global_done_reg || load_1_global_done_reg || store_0_global_done_reg || store_1_global_done_reg) begin
      global_done <= 1'b1;
    end
    else begin
      global_done <= 1'b0;
    end
  end
end

/* ------------------------------------------------ work_en ----------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    load_0_work_en_reg  <= 1'b0;
    load_1_work_en_reg  <= 1'b0;
    store_0_work_en_reg <= 1'b0;
    store_1_work_en_reg <= 1'b0;
    pea_0_work_en_reg   <= 1'b0;
    pea_1_work_en_reg   <= 1'b0;
    vcu_0_work_en_reg   <= 1'b0;
    vcu_1_work_en_reg   <= 1'b0;
  end
  else begin
    if (load_0_work_en) begin
      load_0_work_en_reg <= 1'b1;
    end
    else begin
      load_0_work_en_reg <= 1'b0;
    end

    if (load_1_work_en) begin
      load_1_work_en_reg <= 1'b1;
    end
    else begin
      load_1_work_en_reg <= 1'b0;
    end

    if (store_0_work_en) begin
      store_0_work_en_reg <= 1'b1;
    end
    else begin
      store_0_work_en_reg <= 1'b0;
    end

    if (store_1_work_en) begin
      store_1_work_en_reg <= 1'b1;
    end
    else begin
      store_1_work_en_reg <= 1'b0;
    end

    if (pea_0_work_en) begin
      pea_0_work_en_reg <= 1'b1;
    end
    else begin
      pea_0_work_en_reg <= 1'b0;
    end

    if (pea_1_work_en) begin
      pea_1_work_en_reg <= 1'b1;
    end
    else begin
      pea_1_work_en_reg <= 1'b0;
    end

    if (vcu_0_work_en) begin
      vcu_0_work_en_reg <= 1'b1;
    end
    else begin
      vcu_0_work_en_reg <= 1'b0;
    end

    if (vcu_1_work_en) begin
      vcu_1_work_en_reg <= 1'b1;
    end
    else begin
      vcu_1_work_en_reg <= 1'b0;
    end
  end
end

endmodule
