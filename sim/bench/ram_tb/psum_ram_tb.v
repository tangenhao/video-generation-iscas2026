module psum_ram_tb;

parameter PSUM_WIDTH      = 1024;
parameter PSUM_ADDR_BITS  = 14;
parameter BANK            = 16;

reg                       clk;
reg                       rst_n;
reg                       pea_0_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_0_waddr;
reg  [PSUM_WIDTH-1:0]     pea_0_wdata;
reg                       pea_1_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_1_waddr;
reg  [PSUM_WIDTH-1:0]     pea_1_wdata;
reg                       pea_2_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_2_waddr;
reg  [PSUM_WIDTH-1:0]     pea_2_wdata;
reg                       pea_3_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_3_waddr;
reg  [PSUM_WIDTH-1:0]     pea_3_wdata;
reg                       pea_4_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_4_waddr;
reg  [PSUM_WIDTH-1:0]     pea_4_wdata;
reg                       pea_5_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_5_waddr;
reg  [PSUM_WIDTH-1:0]     pea_5_wdata;
reg                       pea_6_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_6_waddr;
reg  [PSUM_WIDTH-1:0]     pea_6_wdata;
reg                       pea_7_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_7_waddr;
reg  [PSUM_WIDTH-1:0]     pea_7_wdata;
reg                       pea_8_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_8_waddr;
reg  [PSUM_WIDTH-1:0]     pea_8_wdata;
reg                       pea_9_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_9_waddr;
reg  [PSUM_WIDTH-1:0]     pea_9_wdata;
reg                       pea_a_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_a_waddr;
reg  [PSUM_WIDTH-1:0]     pea_a_wdata;
reg                       pea_b_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_b_waddr;
reg  [PSUM_WIDTH-1:0]     pea_b_wdata;
reg                       pea_c_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_c_waddr;
reg  [PSUM_WIDTH-1:0]     pea_c_wdata;
reg                       pea_d_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_d_waddr;
reg  [PSUM_WIDTH-1:0]     pea_d_wdata;
reg                       pea_e_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_e_waddr;
reg  [PSUM_WIDTH-1:0]     pea_e_wdata;
reg                       pea_f_wvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_f_waddr;
reg  [PSUM_WIDTH-1:0]     pea_f_wdata;
reg                       vcu_0_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_0_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_0_wdata;
reg                       vcu_1_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_1_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_1_wdata;
reg                       vcu_2_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_2_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_2_wdata;
reg                       vcu_3_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_3_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_3_wdata;
reg                       vcu_4_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_4_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_4_wdata;
reg                       vcu_5_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_5_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_5_wdata;
reg                       vcu_6_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_6_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_6_wdata;
reg                       vcu_7_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_7_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_7_wdata;
reg                       vcu_8_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_8_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_8_wdata;
reg                       vcu_9_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_9_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_9_wdata;
reg                       vcu_a_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_a_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_a_wdata;
reg                       vcu_b_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_b_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_b_wdata;
reg                       vcu_c_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_c_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_c_wdata;
reg                       vcu_d_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_d_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_d_wdata;
reg                       vcu_e_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_e_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_e_wdata;
reg                       vcu_f_wvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_f_waddr;
reg  [PSUM_WIDTH-1:0]     vcu_f_wdata;
reg                       master_0_wvalid;
reg  [PSUM_ADDR_BITS-1:0] master_0_waddr;
reg  [PSUM_WIDTH-1:0]     master_0_wdata;
reg                       master_1_wvalid;
reg  [PSUM_ADDR_BITS-1:0] master_1_waddr;
reg  [PSUM_WIDTH-1:0]     master_1_wdata;
reg                       slave_wvalid;
reg  [PSUM_ADDR_BITS-1:0] slave_waddr;
reg  [PSUM_WIDTH-1:0]     slave_wdata;
reg                       pea_0_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_0_raddr;
reg                       pea_1_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_1_raddr;
reg                       pea_2_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_2_raddr;
reg                       pea_3_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_3_raddr;
reg                       pea_4_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_4_raddr;
reg                       pea_5_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_5_raddr;
reg                       pea_6_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_6_raddr;
reg                       pea_7_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_7_raddr;
reg                       pea_8_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_8_raddr;
reg                       pea_9_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_9_raddr;
reg                       pea_a_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_a_raddr;
reg                       pea_b_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_b_raddr;
reg                       pea_c_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_c_raddr;
reg                       pea_d_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_d_raddr;
reg                       pea_e_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_e_raddr;
reg                       pea_f_rvalid;
reg  [PSUM_ADDR_BITS-1:0] pea_f_raddr;
reg                       vcu_0_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_0_raddr;
reg                       vcu_1_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_1_raddr;
reg                       vcu_2_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_2_raddr;
reg                       vcu_3_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_3_raddr;
reg                       vcu_4_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_4_raddr;
reg                       vcu_5_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_5_raddr;
reg                       vcu_6_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_6_raddr;
reg                       vcu_7_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_7_raddr;
reg                       vcu_8_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_8_raddr;
reg                       vcu_9_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_9_raddr;
reg                       vcu_a_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_a_raddr;
reg                       vcu_b_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_b_raddr;
reg                       vcu_c_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_c_raddr;
reg                       vcu_d_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_d_raddr;
reg                       vcu_e_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_e_raddr;
reg                       vcu_f_rvalid;
reg  [PSUM_ADDR_BITS-1:0] vcu_f_raddr;
reg                       master_0_rvalid;
reg  [PSUM_ADDR_BITS-1:0] master_0_raddr;
reg                       master_1_rvalid;
reg  [PSUM_ADDR_BITS-1:0] master_1_raddr;
reg                       slave_rvalid;
reg  [PSUM_ADDR_BITS-1:0] slave_raddr;

wire                  pea_0_wready;
wire                  pea_1_wready;
wire                  pea_2_wready;
wire                  pea_3_wready;
wire                  pea_4_wready;
wire                  pea_5_wready;
wire                  pea_6_wready;
wire                  pea_7_wready;
wire                  pea_8_wready;
wire                  pea_9_wready;
wire                  pea_a_wready;
wire                  pea_b_wready;
wire                  pea_c_wready;
wire                  pea_d_wready;
wire                  pea_e_wready;
wire                  pea_f_wready;
wire                  vcu_0_wready;
wire                  vcu_1_wready;
wire                  vcu_2_wready;
wire                  vcu_3_wready;
wire                  vcu_4_wready;
wire                  vcu_5_wready;
wire                  vcu_6_wready;
wire                  vcu_7_wready;
wire                  vcu_8_wready;
wire                  vcu_9_wready;
wire                  vcu_a_wready;
wire                  vcu_b_wready;
wire                  vcu_c_wready;
wire                  vcu_d_wready;
wire                  vcu_e_wready;
wire                  vcu_f_wready;
wire                  master_0_wready;
wire                  master_1_wready;
wire                  slave_wready;
wire [PSUM_WIDTH-1:0] pea_0_rdata;
wire                  pea_0_rready;
wire [PSUM_WIDTH-1:0] pea_1_rdata;
wire                  pea_1_rready;
wire [PSUM_WIDTH-1:0] pea_2_rdata;
wire                  pea_2_rready;
wire [PSUM_WIDTH-1:0] pea_3_rdata;
wire                  pea_3_rready;
wire [PSUM_WIDTH-1:0] pea_4_rdata;
wire                  pea_4_rready;
wire [PSUM_WIDTH-1:0] pea_5_rdata;
wire                  pea_5_rready;
wire [PSUM_WIDTH-1:0] pea_6_rdata;
wire                  pea_6_rready;
wire [PSUM_WIDTH-1:0] pea_7_rdata;
wire                  pea_7_rready;
wire [PSUM_WIDTH-1:0] pea_8_rdata;
wire                  pea_8_rready;
wire [PSUM_WIDTH-1:0] pea_9_rdata;
wire                  pea_9_rready;
wire [PSUM_WIDTH-1:0] pea_a_rdata;
wire                  pea_a_rready;
wire [PSUM_WIDTH-1:0] pea_b_rdata;
wire                  pea_b_rready;
wire [PSUM_WIDTH-1:0] pea_c_rdata;
wire                  pea_c_rready;
wire [PSUM_WIDTH-1:0] pea_d_rdata;
wire                  pea_d_rready;
wire [PSUM_WIDTH-1:0] pea_e_rdata;
wire                  pea_e_rready;
wire [PSUM_WIDTH-1:0] pea_f_rdata;
wire                  pea_f_rready;
wire [PSUM_WIDTH-1:0] vcu_0_rdata;
wire                  vcu_0_rready;
wire [PSUM_WIDTH-1:0] vcu_1_rdata;
wire                  vcu_1_rready;
wire [PSUM_WIDTH-1:0] vcu_2_rdata;
wire                  vcu_2_rready;
wire [PSUM_WIDTH-1:0] vcu_3_rdata;
wire                  vcu_3_rready;
wire [PSUM_WIDTH-1:0] vcu_4_rdata;
wire                  vcu_4_rready;
wire [PSUM_WIDTH-1:0] vcu_5_rdata;
wire                  vcu_5_rready;
wire [PSUM_WIDTH-1:0] vcu_6_rdata;
wire                  vcu_6_rready;
wire [PSUM_WIDTH-1:0] vcu_7_rdata;
wire                  vcu_7_rready;
wire [PSUM_WIDTH-1:0] vcu_8_rdata;
wire                  vcu_8_rready;
wire [PSUM_WIDTH-1:0] vcu_9_rdata;
wire                  vcu_9_rready;
wire [PSUM_WIDTH-1:0] vcu_a_rdata;
wire                  vcu_a_rready;
wire [PSUM_WIDTH-1:0] vcu_b_rdata;
wire                  vcu_b_rready;
wire [PSUM_WIDTH-1:0] vcu_c_rdata;
wire                  vcu_c_rready;
wire [PSUM_WIDTH-1:0] vcu_d_rdata;
wire                  vcu_d_rready;
wire [PSUM_WIDTH-1:0] vcu_e_rdata;
wire                  vcu_e_rready;
wire [PSUM_WIDTH-1:0] vcu_f_rdata;
wire                  vcu_f_rready;
wire [PSUM_WIDTH-1:0] master_0_rdata;
wire                  master_0_rready;
wire [PSUM_WIDTH-1:0] master_1_rdata;
wire                  master_1_rready;
wire [PSUM_WIDTH-1:0] slave_rdata;
wire                  slave_rready;

psum_ram u_psum_ram(
  .clk             ( clk             ),
  .rst_n           ( rst_n           ),
  .pea_0_wvalid    ( pea_0_wvalid    ),
  .pea_0_waddr     ( pea_0_waddr     ),
  .pea_0_wdata     ( pea_0_wdata     ),
  .pea_1_wvalid    ( pea_1_wvalid    ),
  .pea_1_waddr     ( pea_1_waddr     ),
  .pea_1_wdata     ( pea_1_wdata     ),
  .pea_2_wvalid    ( pea_2_wvalid    ),
  .pea_2_waddr     ( pea_2_waddr     ),
  .pea_2_wdata     ( pea_2_wdata     ),
  .pea_3_wvalid    ( pea_3_wvalid    ),
  .pea_3_waddr     ( pea_3_waddr     ),
  .pea_3_wdata     ( pea_3_wdata     ),
  .pea_4_wvalid    ( pea_4_wvalid    ),
  .pea_4_waddr     ( pea_4_waddr     ),
  .pea_4_wdata     ( pea_4_wdata     ),
  .pea_5_wvalid    ( pea_5_wvalid    ),
  .pea_5_waddr     ( pea_5_waddr     ),
  .pea_5_wdata     ( pea_5_wdata     ),
  .pea_6_wvalid    ( pea_6_wvalid    ),
  .pea_6_waddr     ( pea_6_waddr     ),
  .pea_6_wdata     ( pea_6_wdata     ),
  .pea_7_wvalid    ( pea_7_wvalid    ),
  .pea_7_waddr     ( pea_7_waddr     ),
  .pea_7_wdata     ( pea_7_wdata     ),
  .pea_8_wvalid    ( pea_8_wvalid    ),
  .pea_8_waddr     ( pea_8_waddr     ),
  .pea_8_wdata     ( pea_8_wdata     ),
  .pea_9_wvalid    ( pea_9_wvalid    ),
  .pea_9_waddr     ( pea_9_waddr     ),
  .pea_9_wdata     ( pea_9_wdata     ),
  .pea_a_wvalid    ( pea_a_wvalid    ),
  .pea_a_waddr     ( pea_a_waddr     ),
  .pea_a_wdata     ( pea_a_wdata     ),
  .pea_b_wvalid    ( pea_b_wvalid    ),
  .pea_b_waddr     ( pea_b_waddr     ),
  .pea_b_wdata     ( pea_b_wdata     ),
  .pea_c_wvalid    ( pea_c_wvalid    ),
  .pea_c_waddr     ( pea_c_waddr     ),
  .pea_c_wdata     ( pea_c_wdata     ),
  .pea_d_wvalid    ( pea_d_wvalid    ),
  .pea_d_waddr     ( pea_d_waddr     ),
  .pea_d_wdata     ( pea_d_wdata     ),
  .pea_e_wvalid    ( pea_e_wvalid    ),
  .pea_e_waddr     ( pea_e_waddr     ),
  .pea_e_wdata     ( pea_e_wdata     ),
  .pea_f_wvalid    ( pea_f_wvalid    ),
  .pea_f_waddr     ( pea_f_waddr     ),
  .pea_f_wdata     ( pea_f_wdata     ),
  .vcu_0_wvalid    ( vcu_0_wvalid    ),
  .vcu_0_waddr     ( vcu_0_waddr     ),
  .vcu_0_wdata     ( vcu_0_wdata     ),
  .vcu_1_wvalid    ( vcu_1_wvalid    ),
  .vcu_1_waddr     ( vcu_1_waddr     ),
  .vcu_1_wdata     ( vcu_1_wdata     ),
  .vcu_2_wvalid    ( vcu_2_wvalid    ),
  .vcu_2_waddr     ( vcu_2_waddr     ),
  .vcu_2_wdata     ( vcu_2_wdata     ),
  .vcu_3_wvalid    ( vcu_3_wvalid    ),
  .vcu_3_waddr     ( vcu_3_waddr     ),
  .vcu_3_wdata     ( vcu_3_wdata     ),
  .vcu_4_wvalid    ( vcu_4_wvalid    ),
  .vcu_4_waddr     ( vcu_4_waddr     ),
  .vcu_4_wdata     ( vcu_4_wdata     ),
  .vcu_5_wvalid    ( vcu_5_wvalid    ),
  .vcu_5_waddr     ( vcu_5_waddr     ),
  .vcu_5_wdata     ( vcu_5_wdata     ),
  .vcu_6_wvalid    ( vcu_6_wvalid    ),
  .vcu_6_waddr     ( vcu_6_waddr     ),
  .vcu_6_wdata     ( vcu_6_wdata     ),
  .vcu_7_wvalid    ( vcu_7_wvalid    ),
  .vcu_7_waddr     ( vcu_7_waddr     ),
  .vcu_7_wdata     ( vcu_7_wdata     ),
  .vcu_8_wvalid    ( vcu_8_wvalid    ),
  .vcu_8_waddr     ( vcu_8_waddr     ),
  .vcu_8_wdata     ( vcu_8_wdata     ),
  .vcu_9_wvalid    ( vcu_9_wvalid    ),
  .vcu_9_waddr     ( vcu_9_waddr     ),
  .vcu_9_wdata     ( vcu_9_wdata     ),
  .vcu_a_wvalid    ( vcu_a_wvalid    ),
  .vcu_a_waddr     ( vcu_a_waddr     ),
  .vcu_a_wdata     ( vcu_a_wdata     ),
  .vcu_b_wvalid    ( vcu_b_wvalid    ),
  .vcu_b_waddr     ( vcu_b_waddr     ),
  .vcu_b_wdata     ( vcu_b_wdata     ),
  .vcu_c_wvalid    ( vcu_c_wvalid    ),
  .vcu_c_waddr     ( vcu_c_waddr     ),
  .vcu_c_wdata     ( vcu_c_wdata     ),
  .vcu_d_wvalid    ( vcu_d_wvalid    ),
  .vcu_d_waddr     ( vcu_d_waddr     ),
  .vcu_d_wdata     ( vcu_d_wdata     ),
  .vcu_e_wvalid    ( vcu_e_wvalid    ),
  .vcu_e_waddr     ( vcu_e_waddr     ),
  .vcu_e_wdata     ( vcu_e_wdata     ),
  .vcu_f_wvalid    ( vcu_f_wvalid    ),
  .vcu_f_waddr     ( vcu_f_waddr     ),
  .vcu_f_wdata     ( vcu_f_wdata     ),
  .master_0_wvalid ( master_0_wvalid ),
  .master_0_waddr  ( master_0_waddr  ),
  .master_0_wdata  ( master_0_wdata  ),
  .master_1_wvalid ( master_1_wvalid ),
  .master_1_waddr  ( master_1_waddr  ),
  .master_1_wdata  ( master_1_wdata  ),
  .slave_wvalid    ( slave_wvalid    ),
  .slave_waddr     ( slave_waddr     ),
  .slave_wdata     ( slave_wdata     ),
  .pea_0_rvalid    ( pea_0_rvalid    ),
  .pea_0_raddr     ( pea_0_raddr     ),
  .pea_1_rvalid    ( pea_1_rvalid    ),
  .pea_1_raddr     ( pea_1_raddr     ),
  .pea_2_rvalid    ( pea_2_rvalid    ),
  .pea_2_raddr     ( pea_2_raddr     ),
  .pea_3_rvalid    ( pea_3_rvalid    ),
  .pea_3_raddr     ( pea_3_raddr     ),
  .pea_4_rvalid    ( pea_4_rvalid    ),
  .pea_4_raddr     ( pea_4_raddr     ),
  .pea_5_rvalid    ( pea_5_rvalid    ),
  .pea_5_raddr     ( pea_5_raddr     ),
  .pea_6_rvalid    ( pea_6_rvalid    ),
  .pea_6_raddr     ( pea_6_raddr     ),
  .pea_7_rvalid    ( pea_7_rvalid    ),
  .pea_7_raddr     ( pea_7_raddr     ),
  .pea_8_rvalid    ( pea_8_rvalid    ),
  .pea_8_raddr     ( pea_8_raddr     ),
  .pea_9_rvalid    ( pea_9_rvalid    ),
  .pea_9_raddr     ( pea_9_raddr     ),
  .pea_a_rvalid    ( pea_a_rvalid    ),
  .pea_a_raddr     ( pea_a_raddr     ),
  .pea_b_rvalid    ( pea_b_rvalid    ),
  .pea_b_raddr     ( pea_b_raddr     ),
  .pea_c_rvalid    ( pea_c_rvalid    ),
  .pea_c_raddr     ( pea_c_raddr     ),
  .pea_d_rvalid    ( pea_d_rvalid    ),
  .pea_d_raddr     ( pea_d_raddr     ),
  .pea_e_rvalid    ( pea_e_rvalid    ),
  .pea_e_raddr     ( pea_e_raddr     ),
  .pea_f_rvalid    ( pea_f_rvalid    ),
  .pea_f_raddr     ( pea_f_raddr     ),
  .vcu_0_rvalid    ( vcu_0_rvalid    ),
  .vcu_0_raddr     ( vcu_0_raddr     ),
  .vcu_1_rvalid    ( vcu_1_rvalid    ),
  .vcu_1_raddr     ( vcu_1_raddr     ),
  .vcu_2_rvalid    ( vcu_2_rvalid    ),
  .vcu_2_raddr     ( vcu_2_raddr     ),
  .vcu_3_rvalid    ( vcu_3_rvalid    ),
  .vcu_3_raddr     ( vcu_3_raddr     ),
  .vcu_4_rvalid    ( vcu_4_rvalid    ),
  .vcu_4_raddr     ( vcu_4_raddr     ),
  .vcu_5_rvalid    ( vcu_5_rvalid    ),
  .vcu_5_raddr     ( vcu_5_raddr     ),
  .vcu_6_rvalid    ( vcu_6_rvalid    ),
  .vcu_6_raddr     ( vcu_6_raddr     ),
  .vcu_7_rvalid    ( vcu_7_rvalid    ),
  .vcu_7_raddr     ( vcu_7_raddr     ),
  .vcu_8_rvalid    ( vcu_8_rvalid    ),
  .vcu_8_raddr     ( vcu_8_raddr     ),
  .vcu_9_rvalid    ( vcu_9_rvalid    ),
  .vcu_9_raddr     ( vcu_9_raddr     ),
  .vcu_a_rvalid    ( vcu_a_rvalid    ),
  .vcu_a_raddr     ( vcu_a_raddr     ),
  .vcu_b_rvalid    ( vcu_b_rvalid    ),
  .vcu_b_raddr     ( vcu_b_raddr     ),
  .vcu_c_rvalid    ( vcu_c_rvalid    ),
  .vcu_c_raddr     ( vcu_c_raddr     ),
  .vcu_d_rvalid    ( vcu_d_rvalid    ),
  .vcu_d_raddr     ( vcu_d_raddr     ),
  .vcu_e_rvalid    ( vcu_e_rvalid    ),
  .vcu_e_raddr     ( vcu_e_raddr     ),
  .vcu_f_rvalid    ( vcu_f_rvalid    ),
  .vcu_f_raddr     ( vcu_f_raddr     ),
  .master_0_rvalid ( master_0_rvalid ),
  .master_0_raddr  ( master_0_raddr  ),
  .master_1_rvalid ( master_1_rvalid ),
  .master_1_raddr  ( master_1_raddr  ),
  .slave_rvalid    ( slave_rvalid    ),
  .slave_raddr     ( slave_raddr     ),
  .pea_0_wready    ( pea_0_wready    ),
  .pea_1_wready    ( pea_1_wready    ),
  .pea_2_wready    ( pea_2_wready    ),
  .pea_3_wready    ( pea_3_wready    ),
  .pea_4_wready    ( pea_4_wready    ),
  .pea_5_wready    ( pea_5_wready    ),
  .pea_6_wready    ( pea_6_wready    ),
  .pea_7_wready    ( pea_7_wready    ),
  .pea_8_wready    ( pea_8_wready    ),
  .pea_9_wready    ( pea_9_wready    ),
  .pea_a_wready    ( pea_a_wready    ),
  .pea_b_wready    ( pea_b_wready    ),
  .pea_c_wready    ( pea_c_wready    ),
  .pea_d_wready    ( pea_d_wready    ),
  .pea_e_wready    ( pea_e_wready    ),
  .pea_f_wready    ( pea_f_wready    ),
  .vcu_0_wready    ( vcu_0_wready    ),
  .vcu_1_wready    ( vcu_1_wready    ),
  .vcu_2_wready    ( vcu_2_wready    ),
  .vcu_3_wready    ( vcu_3_wready    ),
  .vcu_4_wready    ( vcu_4_wready    ),
  .vcu_5_wready    ( vcu_5_wready    ),
  .vcu_6_wready    ( vcu_6_wready    ),
  .vcu_7_wready    ( vcu_7_wready    ),
  .vcu_8_wready    ( vcu_8_wready    ),
  .vcu_9_wready    ( vcu_9_wready    ),
  .vcu_a_wready    ( vcu_a_wready    ),
  .vcu_b_wready    ( vcu_b_wready    ),
  .vcu_c_wready    ( vcu_c_wready    ),
  .vcu_d_wready    ( vcu_d_wready    ),
  .vcu_e_wready    ( vcu_e_wready    ),
  .vcu_f_wready    ( vcu_f_wready    ),
  .master_0_wready ( master_0_wready ),
  .master_1_wready ( master_1_wready ),
  .slave_wready    ( slave_wready    ),
  .pea_0_rdata     ( pea_0_rdata     ),
  .pea_0_rready    ( pea_0_rready    ),
  .pea_1_rdata     ( pea_1_rdata     ),
  .pea_1_rready    ( pea_1_rready    ),
  .pea_2_rdata     ( pea_2_rdata     ),
  .pea_2_rready    ( pea_2_rready    ),
  .pea_3_rdata     ( pea_3_rdata     ),
  .pea_3_rready    ( pea_3_rready    ),
  .pea_4_rdata     ( pea_4_rdata     ),
  .pea_4_rready    ( pea_4_rready    ),
  .pea_5_rdata     ( pea_5_rdata     ),
  .pea_5_rready    ( pea_5_rready    ),
  .pea_6_rdata     ( pea_6_rdata     ),
  .pea_6_rready    ( pea_6_rready    ),
  .pea_7_rdata     ( pea_7_rdata     ),
  .pea_7_rready    ( pea_7_rready    ),
  .pea_8_rdata     ( pea_8_rdata     ),
  .pea_8_rready    ( pea_8_rready    ),
  .pea_9_rdata     ( pea_9_rdata     ),
  .pea_9_rready    ( pea_9_rready    ),
  .pea_a_rdata     ( pea_a_rdata     ),
  .pea_a_rready    ( pea_a_rready    ),
  .pea_b_rdata     ( pea_b_rdata     ),
  .pea_b_rready    ( pea_b_rready    ),
  .pea_c_rdata     ( pea_c_rdata     ),
  .pea_c_rready    ( pea_c_rready    ),
  .pea_d_rdata     ( pea_d_rdata     ),
  .pea_d_rready    ( pea_d_rready    ),
  .pea_e_rdata     ( pea_e_rdata     ),
  .pea_e_rready    ( pea_e_rready    ),
  .pea_f_rdata     ( pea_f_rdata     ),
  .pea_f_rready    ( pea_f_rready    ),
  .vcu_0_rdata     ( vcu_0_rdata     ),
  .vcu_0_rready    ( vcu_0_rready    ),
  .vcu_1_rdata     ( vcu_1_rdata     ),
  .vcu_1_rready    ( vcu_1_rready    ),
  .vcu_2_rdata     ( vcu_2_rdata     ),
  .vcu_2_rready    ( vcu_2_rready    ),
  .vcu_3_rdata     ( vcu_3_rdata     ),
  .vcu_3_rready    ( vcu_3_rready    ),
  .vcu_4_rdata     ( vcu_4_rdata     ),
  .vcu_4_rready    ( vcu_4_rready    ),
  .vcu_5_rdata     ( vcu_5_rdata     ),
  .vcu_5_rready    ( vcu_5_rready    ),
  .vcu_6_rdata     ( vcu_6_rdata     ),
  .vcu_6_rready    ( vcu_6_rready    ),
  .vcu_7_rdata     ( vcu_7_rdata     ),
  .vcu_7_rready    ( vcu_7_rready    ),
  .vcu_8_rdata     ( vcu_8_rdata     ),
  .vcu_8_rready    ( vcu_8_rready    ),
  .vcu_9_rdata     ( vcu_9_rdata     ),
  .vcu_9_rready    ( vcu_9_rready    ),
  .vcu_a_rdata     ( vcu_a_rdata     ),
  .vcu_a_rready    ( vcu_a_rready    ),
  .vcu_b_rdata     ( vcu_b_rdata     ),
  .vcu_b_rready    ( vcu_b_rready    ),
  .vcu_c_rdata     ( vcu_c_rdata     ),
  .vcu_c_rready    ( vcu_c_rready    ),
  .vcu_d_rdata     ( vcu_d_rdata     ),
  .vcu_d_rready    ( vcu_d_rready    ),
  .vcu_e_rdata     ( vcu_e_rdata     ),
  .vcu_e_rready    ( vcu_e_rready    ),
  .vcu_f_rdata     ( vcu_f_rdata     ),
  .vcu_f_rready    ( vcu_f_rready    ),
  .master_0_rdata  ( master_0_rdata  ),
  .master_0_rready ( master_0_rready ),
  .master_1_rdata  ( master_1_rdata  ),
  .master_1_rready ( master_1_rready ),
  .slave_rdata     ( slave_rdata     ),
  .slave_rready    ( slave_rready    )
);

initial begin
clk = 0;
rst_n = 0;
pea_0_wvalid = 0;
pea_0_waddr = 0;
pea_0_wdata = 0;
pea_1_wvalid = 0;
pea_1_waddr = 0;
pea_1_wdata = 0;
pea_2_wvalid = 0;
pea_2_waddr = 0;
pea_2_wdata = 0;
pea_3_wvalid = 0;
pea_3_waddr = 0;
pea_3_wdata = 0;
pea_4_wvalid = 0;
pea_4_waddr = 0;
pea_4_wdata = 0;
pea_5_wvalid = 0;
pea_5_waddr = 0;
pea_5_wdata = 0;
pea_6_wvalid = 0;
pea_6_waddr = 0;
pea_6_wdata = 0;
pea_7_wvalid = 0;
pea_7_waddr = 0;
pea_7_wdata = 0;
pea_8_wvalid = 0;
pea_8_waddr = 0;
pea_8_wdata = 0;
pea_9_wvalid = 0;
pea_9_waddr = 0;
pea_9_wdata = 0;
pea_a_wvalid = 0;
pea_a_waddr = 0;
pea_a_wdata = 0;
pea_b_wvalid = 0;
pea_b_waddr = 0;
pea_b_wdata = 0;
pea_c_wvalid = 0;
pea_c_waddr = 0;
pea_c_wdata = 0;
pea_d_wvalid = 0;
pea_d_waddr = 0;
pea_d_wdata = 0;
pea_e_wvalid = 0;
pea_e_waddr = 0;
pea_e_wdata = 0;
pea_f_wvalid = 0;
pea_f_waddr = 0;
pea_f_wdata = 0;
vcu_0_wvalid = 0;
vcu_0_waddr = 0;
vcu_0_wdata = 0;
vcu_1_wvalid = 0;
vcu_1_waddr = 0;
vcu_1_wdata = 0;
vcu_2_wvalid = 0;
vcu_2_waddr = 0;
vcu_2_wdata = 0;
vcu_3_wvalid = 0;
vcu_3_waddr = 0;
vcu_3_wdata = 0;
vcu_4_wvalid = 0;
vcu_4_waddr = 0;
vcu_4_wdata = 0;
vcu_5_wvalid = 0;
vcu_5_waddr = 0;
vcu_5_wdata = 0;
vcu_6_wvalid = 0;
vcu_6_waddr = 0;
vcu_6_wdata = 0;
vcu_7_wvalid = 0;
vcu_7_waddr = 0;
vcu_7_wdata = 0;
vcu_8_wvalid = 0;
vcu_8_waddr = 0;
vcu_8_wdata = 0;
vcu_9_wvalid = 0;
vcu_9_waddr = 0;
vcu_9_wdata = 0;
vcu_a_wvalid = 0;
vcu_a_waddr = 0;
vcu_a_wdata = 0;
vcu_b_wvalid = 0;
vcu_b_waddr = 0;
vcu_b_wdata = 0;
vcu_c_wvalid = 0;
vcu_c_waddr = 0;
vcu_c_wdata = 0;
vcu_d_wvalid = 0;
vcu_d_waddr = 0;
vcu_d_wdata = 0;
vcu_e_wvalid = 0;
vcu_e_waddr = 0;
vcu_e_wdata = 0;
vcu_f_wvalid = 0;
vcu_f_waddr = 0;
vcu_f_wdata = 0;
master_0_wvalid = 0;
master_0_waddr = 0;
master_0_wdata = 0;
master_1_wvalid = 0;
master_1_waddr = 0;
master_1_wdata = 0;
slave_wvalid = 0;
slave_waddr = 0;
slave_wdata = 0;
pea_0_rvalid = 0;
pea_0_raddr = 0;
pea_1_rvalid = 0;
pea_1_raddr = 0;
pea_2_rvalid = 0;
pea_2_raddr = 0;
pea_3_rvalid = 0;
pea_3_raddr = 0;
pea_4_rvalid = 0;
pea_4_raddr = 0;
pea_5_rvalid = 0;
pea_5_raddr = 0;
pea_6_rvalid = 0;
pea_6_raddr = 0;
pea_7_rvalid = 0;
pea_7_raddr = 0;
pea_8_rvalid = 0;
pea_8_raddr = 0;
pea_9_rvalid = 0;
pea_9_raddr = 0;
pea_a_rvalid = 0;
pea_a_raddr = 0;
pea_b_rvalid = 0;
pea_b_raddr = 0;
pea_c_rvalid = 0;
pea_c_raddr = 0;
pea_d_rvalid = 0;
pea_d_raddr = 0;
pea_e_rvalid = 0;
pea_e_raddr = 0;
pea_f_rvalid = 0;
pea_f_raddr = 0;
vcu_0_rvalid = 0;
vcu_0_raddr = 0;
vcu_1_rvalid = 0;
vcu_1_raddr = 0;
vcu_2_rvalid = 0;
vcu_2_raddr = 0;
vcu_3_rvalid = 0;
vcu_3_raddr = 0;
vcu_4_rvalid = 0;
vcu_4_raddr = 0;
vcu_5_rvalid = 0;
vcu_5_raddr = 0;
vcu_6_rvalid = 0;
vcu_6_raddr = 0;
vcu_7_rvalid = 0;
vcu_7_raddr = 0;
vcu_8_rvalid = 0;
vcu_8_raddr = 0;
vcu_9_rvalid = 0;
vcu_9_raddr = 0;
vcu_a_rvalid = 0;
vcu_a_raddr = 0;
vcu_b_rvalid = 0;
vcu_b_raddr = 0;
vcu_c_rvalid = 0;
vcu_c_raddr = 0;
vcu_d_rvalid = 0;
vcu_d_raddr = 0;
vcu_e_rvalid = 0;
vcu_e_raddr = 0;
vcu_f_rvalid = 0;
vcu_f_raddr = 0;
master_0_rvalid = 0;
master_0_raddr = 0;
master_1_rvalid = 0;
master_1_raddr = 0;
slave_rvalid = 0;
slave_raddr = 0;

#10 rst_n = 1;
end

initial begin
  $fsdbDumpfile("psum_ram_tb.fsdb");
  $fsdbDumpvars(0, "psum_ram_tb");
  $fsdbDumpMDA();
end

always #5 clk = ~clk;

/* -------------------------------------------------------------------------------------------------------- */
/*                                               master 0 read                                              */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (~rst_n) begin
//     master_0_wvalid <= 0;
//     master_0_waddr <= -1;
//     master_0_wdata <= -1;
//     master_0_rvalid <= 0;
//     master_0_raddr <= -1;
//     write_done_flag <= 0;
//   end 
//   else begin
//     master_0_wvalid <= 1;
//     master_0_waddr <= master_0_waddr + 1;
//     master_0_wdata <= master_0_wdata + 1;

//     if (master_0_waddr == 256 * 4 * 16 - 2) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       master_0_rvalid <= 1;
//       master_0_raddr <= master_0_raddr + 1;

//       if (master_0_raddr == 256 * 4 * 16 - 2) begin
//         $finish;
//       end
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                               master 1 read                                              */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (~rst_n) begin
//     master_0_wvalid <= 0;
//     master_0_waddr <= -1;
//     master_0_wdata <= -1;
//     master_1_rvalid <= 0;
//     master_1_raddr <= -1;
//     write_done_flag <= 0;
//   end 
//   else begin
//     master_0_wvalid <= 1;
//     master_0_waddr <= master_0_waddr + 1;
//     master_0_wdata <= master_0_wdata + 1;

//     if (master_0_waddr == 256 * 4 * 16 - 2) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       master_1_rvalid <= 1;
//       master_1_raddr <= master_1_raddr + 1;

//       if (master_1_raddr == 256 * 4 * 16 - 2) begin
//         $finish;
//       end
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                slave read                                                */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (~rst_n) begin
//     master_1_wvalid <= 0;
//     master_1_waddr <= -1;
//     master_1_wdata <= -1;
//     slave_rvalid <= 0;
//     slave_raddr <= -1;
//     write_done_flag <= 0;
//   end 
//   else begin
//     master_1_wvalid <= 1;
//     master_1_waddr <= master_1_waddr + 1;
//     master_1_wdata <= master_1_wdata + 1;

//     if (master_1_waddr == 256 * 4 * 16 - 2) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       slave_rvalid <= 1;
//       slave_raddr <= slave_raddr + 1;

//       if (slave_raddr == 256 * 4 * 16 - 2) begin
//         $finish;
//       end
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        pea write pea read no cross                                       */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     pea_0_wvalid <= 0;
//     pea_0_waddr <= -1;
//     pea_0_wdata <= -1;
//     pea_1_wvalid <= 0;
//     pea_1_waddr <= -1;
//     pea_1_wdata <= -1;
//     pea_2_wvalid <= 0;
//     pea_2_waddr <= -1;
//     pea_2_wdata <= -1;
//     pea_3_wvalid <= 0;
//     pea_3_waddr <= -1;
//     pea_3_wdata <= -1;
//     pea_4_wvalid <= 0;
//     pea_4_waddr <= -1;
//     pea_4_wdata <= -1;
//     pea_5_wvalid <= 0;
//     pea_5_waddr <= -1;
//     pea_5_wdata <= -1;
//     pea_6_wvalid <= 0;
//     pea_6_waddr <= -1;
//     pea_6_wdata <= -1;
//     pea_7_wvalid <= 0;
//     pea_7_waddr <= -1;
//     pea_7_wdata <= -1;
//     pea_8_wvalid <= 0;
//     pea_8_waddr <= -1;
//     pea_8_wdata <= -1;
//     pea_9_wvalid <= 0;
//     pea_9_waddr <= -1;
//     pea_9_wdata <= -1;
//     pea_a_wvalid <= 0;
//     pea_a_waddr <= -1;
//     pea_a_wdata <= -1;
//     pea_b_wvalid <= 0;
//     pea_b_waddr <= -1;
//     pea_b_wdata <= -1;
//     pea_c_wvalid <= 0;
//     pea_c_waddr <= -1;
//     pea_c_wdata <= -1;
//     pea_d_wvalid <= 0;
//     pea_d_waddr <= -1;
//     pea_d_wdata <= -1;
//     pea_e_wvalid <= 0;
//     pea_e_waddr <= -1;
//     pea_e_wdata <= -1;
//     pea_f_wvalid <= 0;
//     pea_f_waddr <= -1;
//     pea_f_wdata <= -1;
//     vcu_0_rvalid <= 0;
//     vcu_0_raddr <= -1;
//     vcu_1_rvalid <= 0;
//     vcu_1_raddr <= -1;
//     vcu_2_rvalid <= 0;
//     vcu_2_raddr <= -1;
//     vcu_3_rvalid <= 0;
//     vcu_3_raddr <= -1;
//     vcu_4_rvalid <= 0;
//     vcu_4_raddr <= -1;
//     vcu_5_rvalid <= 0;
//     vcu_5_raddr <= -1;
//     vcu_6_rvalid <= 0;
//     vcu_6_raddr <= -1;
//     vcu_7_rvalid <= 0;
//     vcu_7_raddr <= -1;
//     vcu_8_rvalid <= 0;
//     vcu_8_raddr <= -1;
//     vcu_9_rvalid <= 0;
//     vcu_9_raddr <= -1;
//     vcu_a_rvalid <= 0;
//     vcu_a_raddr <= -1;
//     vcu_b_rvalid <= 0;
//     vcu_b_raddr <= -1;
//     vcu_c_rvalid <= 0;
//     vcu_c_raddr <= -1;
//     vcu_d_rvalid <= 0;
//     vcu_d_raddr <= -1;
//     vcu_e_rvalid <= 0;
//     vcu_e_raddr <= -1;
//     vcu_f_rvalid <= 0;
//     vcu_f_raddr <= -1;
//     write_done_flag <= 1'b0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       pea_0_wvalid <= 1;
//       pea_1_wvalid <= 1;
//       pea_2_wvalid <= 1;
//       pea_3_wvalid <= 1;
//       pea_4_wvalid <= 1;
//       pea_5_wvalid <= 1;
//       pea_6_wvalid <= 1;
//       pea_7_wvalid <= 1;
//       pea_8_wvalid <= 1;
//       pea_9_wvalid <= 1;
//       pea_a_wvalid <= 1;
//       pea_b_wvalid <= 1;
//       pea_c_wvalid <= 1;
//       pea_d_wvalid <= 1;
//       pea_e_wvalid <= 1;
//       pea_f_wvalid <= 1;
//       pea_0_wdata <= pea_0_wdata + 1;
//       pea_1_wdata <= pea_1_wdata + 1;
//       pea_2_wdata <= pea_2_wdata + 1;
//       pea_3_wdata <= pea_3_wdata + 1;
//       pea_4_wdata <= pea_4_wdata + 1;
//       pea_5_wdata <= pea_5_wdata + 1;
//       pea_6_wdata <= pea_6_wdata + 1;
//       pea_7_wdata <= pea_7_wdata + 1;
//       pea_8_wdata <= pea_8_wdata + 1;
//       pea_9_wdata <= pea_9_wdata + 1;
//       pea_a_wdata <= pea_a_wdata + 1;
//       pea_b_wdata <= pea_b_wdata + 1;
//       pea_c_wdata <= pea_c_wdata + 1;
//       pea_d_wdata <= pea_d_wdata + 1;
//       pea_e_wdata <= pea_e_wdata + 1;
//       pea_f_wdata <= pea_f_wdata + 1;
//       if (pea_0_waddr == 256 - 1) begin
//         pea_0_waddr <= 256 * 16;
//       end
//       else if (pea_0_waddr == 256 * 16 + 256 - 1) begin
//         pea_0_waddr <= 256 * 32;
//       end
//       else if (pea_0_waddr == 256 * 32 + 256 - 1) begin
//         pea_0_waddr <= 256 * 48;
//       end
//       else if (pea_0_waddr == 256 * 48 + 256 - 1) begin
//         pea_0_waddr <= 0;
//         write_done_flag <= 1;
//         pea_0_wvalid <= 0;
//       end
//       else begin
//         pea_0_waddr <= pea_0_waddr + 1;
//       end

//       if (pea_1_waddr == 256 - 1) begin
//         pea_1_waddr <= 256 * 16;
//       end
//       else if (pea_1_waddr == 256 * 16 + 256 - 1) begin
//         pea_1_waddr <= 256 * 32;
//       end
//       else if (pea_1_waddr == 256 * 32 + 256 - 1) begin
//         pea_1_waddr <= 256 * 48;
//       end
//       else if (pea_1_waddr == 256 * 48 + 256 - 1) begin
//         pea_1_waddr <= 0;
//         write_done_flag <= 1;
//         pea_1_wvalid <= 0;
//       end
//       else begin
//         pea_1_waddr <= pea_1_waddr + 1;
//       end

//       if (pea_2_waddr == 256 - 1) begin
//         pea_2_waddr <= 256 * 16;
//       end
//       else if (pea_2_waddr == 256 * 16 + 256 - 1) begin
//         pea_2_waddr <= 256 * 32;
//       end
//       else if (pea_2_waddr == 256 * 32 + 256 - 1) begin
//         pea_2_waddr <= 256 * 48;
//       end
//       else if (pea_2_waddr == 256 * 48 + 256 - 1) begin
//         pea_2_waddr <= 0;
//         write_done_flag <= 1;
//         pea_2_wvalid <= 0;
//       end
//       else begin
//         pea_2_waddr <= pea_2_waddr + 1;
//       end

//       if (pea_3_waddr == 256 - 1) begin
//         pea_3_waddr <= 256 * 16;
//       end
//       else if (pea_3_waddr == 256 * 16 + 256 - 1) begin
//         pea_3_waddr <= 256 * 32;
//       end
//       else if (pea_3_waddr == 256 * 32 + 256 - 1) begin
//         pea_3_waddr <= 256 * 48;
//       end
//       else if (pea_3_waddr == 256 * 48 + 256 - 1) begin
//         pea_3_waddr <= 0;
//         write_done_flag <= 1;
//         pea_3_wvalid <= 0;
//       end
//       else begin
//         pea_3_waddr <= pea_3_waddr + 1;
//       end

//       if (pea_4_waddr == 256 - 1) begin
//         pea_4_waddr <= 256 * 16;
//       end
//       else if (pea_4_waddr == 256 * 16 + 256 - 1) begin
//         pea_4_waddr <= 256 * 32;
//       end
//       else if (pea_4_waddr == 256 * 32 + 256 - 1) begin
//         pea_4_waddr <= 256 * 48;
//       end
//       else if (pea_4_waddr == 256 * 48 + 256 - 1) begin
//         pea_4_waddr <= 0;
//         write_done_flag <= 1;
//         pea_4_wvalid <= 0;
//       end
//       else begin
//         pea_4_waddr <= pea_4_waddr + 1;
//       end

//       if (pea_5_waddr == 256 - 1) begin
//         pea_5_waddr <= 256 * 16;
//       end
//       else if (pea_5_waddr == 256 * 16 + 256 - 1) begin
//         pea_5_waddr <= 256 * 32;
//       end
//       else if (pea_5_waddr == 256 * 32 + 256 - 1) begin
//         pea_5_waddr <= 256 * 48;
//       end
//       else if (pea_5_waddr == 256 * 48 + 256 - 1) begin
//         pea_5_waddr <= 0;
//         write_done_flag <= 1;
//         pea_5_wvalid <= 0;
//       end
//       else begin
//         pea_5_waddr <= pea_5_waddr + 1;
//       end

//       if (pea_6_waddr == 256 - 1) begin
//         pea_6_waddr <= 256 * 16;
//       end
//       else if (pea_6_waddr == 256 * 16 + 256 - 1) begin
//         pea_6_waddr <= 256 * 32;
//       end
//       else if (pea_6_waddr == 256 * 32 + 256 - 1) begin
//         pea_6_waddr <= 256 * 48;
//       end
//       else if (pea_6_waddr == 256 * 48 + 256 - 1) begin
//         pea_6_waddr <= 0;
//         write_done_flag <= 1;
//         pea_6_wvalid <= 0;
//       end
//       else begin
//         pea_6_waddr <= pea_6_waddr + 1;
//       end

//       if (pea_7_waddr == 256 - 1) begin
//         pea_7_waddr <= 256 * 16;
//       end
//       else if (pea_7_waddr == 256 * 16 + 256 - 1) begin
//         pea_7_waddr <= 256 * 32;
//       end
//       else if (pea_7_waddr == 256 * 32 + 256 - 1) begin
//         pea_7_waddr <= 256 * 48;
//       end
//       else if (pea_7_waddr == 256 * 48 + 256 - 1) begin
//         pea_7_waddr <= 0;
//         write_done_flag <= 1;
//         pea_7_wvalid <= 0;
//       end
//       else begin
//         pea_7_waddr <= pea_7_waddr + 1;
//       end

//       if (pea_8_waddr == 256 - 1) begin
//         pea_8_waddr <= 256 * 16;
//       end
//       else if (pea_8_waddr == 256 * 16 + 256 - 1) begin
//         pea_8_waddr <= 256 * 32;
//       end
//       else if (pea_8_waddr == 256 * 32 + 256 - 1) begin
//         pea_8_waddr <= 256 * 48;
//       end
//       else if (pea_8_waddr == 256 * 48 + 256 - 1) begin
//         pea_8_waddr <= 0;
//         write_done_flag <= 1;
//         pea_8_wvalid <= 0;
//       end
//       else begin
//         pea_8_waddr <= pea_8_waddr + 1;
//       end

//       if (pea_9_waddr == 256 - 1) begin
//         pea_9_waddr <= 256 * 16;
//       end
//       else if (pea_9_waddr == 256 * 16 + 256 - 1) begin
//         pea_9_waddr <= 256 * 32;
//       end
//       else if (pea_9_waddr == 256 * 32 + 256 - 1) begin
//         pea_9_waddr <= 256 * 48;
//       end
//       else if (pea_9_waddr == 256 * 48 + 256 - 1) begin
//         pea_9_waddr <= 0;
//         write_done_flag <= 1;
//         pea_9_wvalid <= 0;
//       end
//       else begin
//         pea_9_waddr <= pea_9_waddr + 1;
//       end

//       if (pea_a_waddr == 256 - 1) begin
//         pea_a_waddr <= 256 * 16;
//       end
//       else if (pea_a_waddr == 256 * 16 + 256 - 1) begin
//         pea_a_waddr <= 256 * 32;
//       end
//       else if (pea_a_waddr == 256 * 32 + 256 - 1) begin
//         pea_a_waddr <= 256 * 48;
//       end
//       else if (pea_a_waddr == 256 * 48 + 256 - 1) begin
//         pea_a_waddr <= 0;
//         write_done_flag <= 1;
//         pea_a_wvalid <= 0;
//       end
//       else begin
//         pea_a_waddr <= pea_a_waddr + 1;
//       end

//       if (pea_b_waddr == 256 - 1) begin
//         pea_b_waddr <= 256 * 16;
//       end
//       else if (pea_b_waddr == 256 * 16 + 256 - 1) begin
//         pea_b_waddr <= 256 * 32;
//       end
//       else if (pea_b_waddr == 256 * 32 + 256 - 1) begin
//         pea_b_waddr <= 256 * 48;
//       end
//       else if (pea_b_waddr == 256 * 48 + 256 - 1) begin
//         pea_b_waddr <= 0;
//         write_done_flag <= 1;
//         pea_b_wvalid <= 0;
//       end
//       else begin
//         pea_b_waddr <= pea_b_waddr + 1;
//       end

//       if (pea_c_waddr == 256 - 1) begin
//         pea_c_waddr <= 256 * 16;
//       end
//       else if (pea_c_waddr == 256 * 16 + 256 - 1) begin
//         pea_c_waddr <= 256 * 32;
//       end
//       else if (pea_c_waddr == 256 * 32 + 256 - 1) begin
//         pea_c_waddr <= 256 * 48;
//       end
//       else if (pea_c_waddr == 256 * 48 + 256 - 1) begin
//         pea_c_waddr <= 0;
//         write_done_flag <= 1;
//         pea_c_wvalid <= 0;
//       end
//       else begin
//         pea_c_waddr <= pea_c_waddr + 1;
//       end

//       if (pea_d_waddr == 256 - 1) begin
//         pea_d_waddr <= 256 * 16;
//       end
//       else if (pea_d_waddr == 256 * 16 + 256 - 1) begin
//         pea_d_waddr <= 256 * 32;
//       end
//       else if (pea_d_waddr == 256 * 32 + 256 - 1) begin
//         pea_d_waddr <= 256 * 48;
//       end
//       else if (pea_d_waddr == 256 * 48 + 256 - 1) begin
//         pea_d_waddr <= 0;
//         write_done_flag <= 1;
//         pea_d_wvalid <= 0;
//       end
//       else begin
//         pea_d_waddr <= pea_d_waddr + 1;
//       end

//       if (pea_e_waddr == 256 - 1) begin
//         pea_e_waddr <= 256 * 16;
//       end
//       else if (pea_e_waddr == 256 * 16 + 256 - 1) begin
//         pea_e_waddr <= 256 * 32;
//       end
//       else if (pea_e_waddr == 256 * 32 + 256 - 1) begin
//         pea_e_waddr <= 256 * 48;
//       end
//       else if (pea_e_waddr == 256 * 48 + 256 - 1) begin
//         pea_e_waddr <= 0;
//         write_done_flag <= 1;
//         pea_e_wvalid <= 0;
//       end
//       else begin
//         pea_e_waddr <= pea_e_waddr + 1;
//       end

//       if (pea_f_waddr == 256 - 1) begin
//         pea_f_waddr <= 256 * 16;
//       end
//       else if (pea_f_waddr == 256 * 16 + 256 - 1) begin
//         pea_f_waddr <= 256 * 32;
//       end
//       else if (pea_f_waddr == 256 * 32 + 256 - 1) begin
//         pea_f_waddr <= 256 * 48;
//       end
//       else if (pea_f_waddr == 256 * 48 + 256 - 1) begin
//         pea_f_waddr <= 0;
//         write_done_flag <= 1;
//         pea_f_wvalid <= 0;
//       end
//       else begin
//         pea_f_waddr <= pea_f_waddr + 1;
//       end
//     end
//     else begin

//       pea_0_wvalid <= 0;
//       pea_1_wvalid <= 0;
//       pea_2_wvalid <= 0;
//       pea_3_wvalid <= 0;
//       pea_4_wvalid <= 0;
//       pea_5_wvalid <= 0;
//       pea_6_wvalid <= 0;
//       pea_7_wvalid <= 0;
//       pea_8_wvalid <= 0;
//       pea_9_wvalid <= 0;
//       pea_a_wvalid <= 0;
//       pea_b_wvalid <= 0;
//       pea_c_wvalid <= 0;
//       pea_d_wvalid <= 0;
//       pea_e_wvalid <= 0;
//       pea_f_wvalid <= 0;

//       vcu_0_rvalid <= 1;
//       vcu_1_rvalid <= 1;
//       vcu_2_rvalid <= 1;
//       vcu_3_rvalid <= 1;
//       vcu_4_rvalid <= 1;
//       vcu_5_rvalid <= 1;
//       vcu_6_rvalid <= 1;
//       vcu_7_rvalid <= 1;
//       vcu_8_rvalid <= 1;
//       vcu_9_rvalid <= 1;
//       vcu_a_rvalid <= 1;
//       vcu_b_rvalid <= 1;
//       vcu_c_rvalid <= 1;
//       vcu_d_rvalid <= 1;
//       vcu_e_rvalid <= 1;
//       vcu_f_rvalid <= 1;
//       if (vcu_0_raddr == 256 - 1) begin
//         vcu_0_raddr <= 256 * 16;
//       end
//       else if (vcu_0_raddr == 256 * 16 + 256 - 1) begin
//         vcu_0_raddr <= 256 * 32;
//       end
//       else if (vcu_0_raddr == 256 * 32 + 256 - 1) begin
//         vcu_0_raddr <= 256 * 48;
//       end
//       else if (vcu_0_raddr == 256 * 48 + 256 - 1) begin
//         vcu_0_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_0_raddr <= vcu_0_raddr + 1;
//       end

//       if (vcu_1_raddr == 256 - 1) begin
//         vcu_1_raddr <= 256 * 16;
//       end
//       else if (vcu_1_raddr == 256 * 16 + 256 - 1) begin
//         vcu_1_raddr <= 256 * 32;
//       end
//       else if (vcu_1_raddr == 256 * 32 + 256 - 1) begin
//         vcu_1_raddr <= 256 * 48;
//       end
//       else if (vcu_1_raddr == 256 * 48 + 256 - 1) begin
//         vcu_1_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_1_raddr <= vcu_1_raddr + 1;
//       end

//       if (vcu_2_raddr == 256 - 1) begin
//         vcu_2_raddr <= 256 * 16;
//       end
//       else if (vcu_2_raddr == 256 * 16 + 256 - 1) begin
//         vcu_2_raddr <= 256 * 32;
//       end
//       else if (vcu_2_raddr == 256 * 32 + 256 - 1) begin
//         vcu_2_raddr <= 256 * 48;
//       end
//       else if (vcu_2_raddr == 256 * 48 + 256 - 1) begin
//         vcu_2_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_2_raddr <= vcu_2_raddr + 1;
//       end

//       if (vcu_3_raddr == 256 - 1) begin
//         vcu_3_raddr <= 256 * 16;
//       end
//       else if (vcu_3_raddr == 256 * 16 + 256 - 1) begin
//         vcu_3_raddr <= 256 * 32;
//       end
//       else if (vcu_3_raddr == 256 * 32 + 256 - 1) begin
//         vcu_3_raddr <= 256 * 48;
//       end
//       else if (vcu_3_raddr == 256 * 48 + 256 - 1) begin
//         vcu_3_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_3_raddr <= vcu_3_raddr + 1;
//       end

//       if (vcu_4_raddr == 256 - 1) begin
//         vcu_4_raddr <= 256 * 16;
//       end
//       else if (vcu_4_raddr == 256 * 16 + 256 - 1) begin
//         vcu_4_raddr <= 256 * 32;
//       end
//       else if (vcu_4_raddr == 256 * 32 + 256 - 1) begin
//         vcu_4_raddr <= 256 * 48;
//       end
//       else if (vcu_4_raddr == 256 * 48 + 256 - 1) begin
//         vcu_4_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_4_raddr <= vcu_4_raddr + 1;
//       end

//       if (vcu_5_raddr == 256 - 1) begin
//         vcu_5_raddr <= 256 * 16;
//       end
//       else if (vcu_5_raddr == 256 * 16 + 256 - 1) begin
//         vcu_5_raddr <= 256 * 32;
//       end
//       else if (vcu_5_raddr == 256 * 32 + 256 - 1) begin
//         vcu_5_raddr <= 256 * 48;
//       end
//       else if (vcu_5_raddr == 256 * 48 + 256 - 1) begin
//         vcu_5_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_5_raddr <= vcu_5_raddr + 1;
//       end

//       if (vcu_6_raddr == 256 - 1) begin
//         vcu_6_raddr <= 256 * 16;
//       end
//       else if (vcu_6_raddr == 256 * 16 + 256 - 1) begin
//         vcu_6_raddr <= 256 * 32;
//       end
//       else if (vcu_6_raddr == 256 * 32 + 256 - 1) begin
//         vcu_6_raddr <= 256 * 48;
//       end
//       else if (vcu_6_raddr == 256 * 48 + 256 - 1) begin
//         vcu_6_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_6_raddr <= vcu_6_raddr + 1;
//       end

//       if (vcu_7_raddr == 256 - 1) begin
//         vcu_7_raddr <= 256 * 16;
//       end
//       else if (vcu_7_raddr == 256 * 16 + 256 - 1) begin
//         vcu_7_raddr <= 256 * 32;
//       end
//       else if (vcu_7_raddr == 256 * 32 + 256 - 1) begin
//         vcu_7_raddr <= 256 * 48;
//       end
//       else if (vcu_7_raddr == 256 * 48 + 256 - 1) begin
//         vcu_7_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_7_raddr <= vcu_7_raddr + 1;
//       end

//       if (vcu_8_raddr == 256 - 1) begin
//         vcu_8_raddr <= 256 * 16;
//       end
//       else if (vcu_8_raddr == 256 * 16 + 256 - 1) begin
//         vcu_8_raddr <= 256 * 32;
//       end
//       else if (vcu_8_raddr == 256 * 32 + 256 - 1) begin
//         vcu_8_raddr <= 256 * 48;
//       end
//       else if (vcu_8_raddr == 256 * 48 + 256 - 1) begin
//         vcu_8_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_8_raddr <= vcu_8_raddr + 1;
//       end

//       if (vcu_9_raddr == 256 - 1) begin
//         vcu_9_raddr <= 256 * 16;
//       end
//       else if (vcu_9_raddr == 256 * 16 + 256 - 1) begin
//         vcu_9_raddr <= 256 * 32;
//       end
//       else if (vcu_9_raddr == 256 * 32 + 256 - 1) begin
//         vcu_9_raddr <= 256 * 48;
//       end
//       else if (vcu_9_raddr == 256 * 48 + 256 - 1) begin
//         vcu_9_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_9_raddr <= vcu_9_raddr + 1;
//       end

//       if (vcu_a_raddr == 256 - 1) begin
//         vcu_a_raddr <= 256 * 16;
//       end
//       else if (vcu_a_raddr == 256 * 16 + 256 - 1) begin
//         vcu_a_raddr <= 256 * 32;
//       end
//       else if (vcu_a_raddr == 256 * 32 + 256 - 1) begin
//         vcu_a_raddr <= 256 * 48;
//       end
//       else if (vcu_a_raddr == 256 * 48 + 256 - 1) begin
//         vcu_a_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_a_raddr <= vcu_a_raddr + 1;
//       end

//       if (vcu_b_raddr == 256 - 1) begin
//         vcu_b_raddr <= 256 * 16;
//       end
//       else if (vcu_b_raddr == 256 * 16 + 256 - 1) begin
//         vcu_b_raddr <= 256 * 32;
//       end
//       else if (vcu_b_raddr == 256 * 32 + 256 - 1) begin
//         vcu_b_raddr <= 256 * 48;
//       end
//       else if (vcu_b_raddr == 256 * 48 + 256 - 1) begin
//         vcu_b_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_b_raddr <= vcu_b_raddr + 1;
//       end

//       if (vcu_c_raddr == 256 - 1) begin
//         vcu_c_raddr <= 256 * 16;
//       end
//       else if (vcu_c_raddr == 256 * 16 + 256 - 1) begin
//         vcu_c_raddr <= 256 * 32;
//       end
//       else if (vcu_c_raddr == 256 * 32 + 256 - 1) begin
//         vcu_c_raddr <= 256 * 48;
//       end
//       else if (vcu_c_raddr == 256 * 48 + 256 - 1) begin
//         vcu_c_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_c_raddr <= vcu_c_raddr + 1;
//       end

//       if (vcu_d_raddr == 256 - 1) begin
//         vcu_d_raddr <= 256 * 16;
//       end
//       else if (vcu_d_raddr == 256 * 16 + 256 - 1) begin
//         vcu_d_raddr <= 256 * 32;
//       end
//       else if (vcu_d_raddr == 256 * 32 + 256 - 1) begin
//         vcu_d_raddr <= 256 * 48;
//       end
//       else if (vcu_d_raddr == 256 * 48 + 256 - 1) begin
//         vcu_d_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_d_raddr <= vcu_d_raddr + 1;
//       end

//       if (vcu_e_raddr == 256 - 1) begin
//         vcu_e_raddr <= 256 * 16;
//       end
//       else if (vcu_e_raddr == 256 * 16 + 256 - 1) begin
//         vcu_e_raddr <= 256 * 32;
//       end
//       else if (vcu_e_raddr == 256 * 32 + 256 - 1) begin
//         vcu_e_raddr <= 256 * 48;
//       end
//       else if (vcu_e_raddr == 256 * 48 + 256 - 1) begin
//         vcu_e_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_e_raddr <= vcu_e_raddr + 1;
//       end

//       if (vcu_f_raddr == 256 - 1) begin
//         vcu_f_raddr <= 256 * 16;
//       end
//       else if (vcu_f_raddr == 256 * 16 + 256 - 1) begin
//         vcu_f_raddr <= 256 * 32;
//       end
//       else if (vcu_f_raddr == 256 * 32 + 256 - 1) begin
//         vcu_f_raddr <= 256 * 48;
//       end
//       else if (vcu_f_raddr == 256 * 48 + 256 - 1) begin
//         vcu_f_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         vcu_f_raddr <= vcu_f_raddr + 1;
//       end
//     end

//     if (vcu_0_raddr == 256 * 48 + 256 - 1) begin
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                            vcu write pea read                                            */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     vcu_0_wvalid <= 0;
//     vcu_0_waddr <= -1;
//     vcu_0_wdata <= -1;
//     vcu_1_wvalid <= 0;
//     vcu_1_waddr <= -1;
//     vcu_1_wdata <= -1;
//     vcu_2_wvalid <= 0;
//     vcu_2_waddr <= -1;
//     vcu_2_wdata <= -1;
//     vcu_3_wvalid <= 0;
//     vcu_3_waddr <= -1;
//     vcu_3_wdata <= -1;
//     vcu_4_wvalid <= 0;
//     vcu_4_waddr <= -1;
//     vcu_4_wdata <= -1;
//     vcu_5_wvalid <= 0;
//     vcu_5_waddr <= -1;
//     vcu_5_wdata <= -1;
//     vcu_6_wvalid <= 0;
//     vcu_6_waddr <= -1;
//     vcu_6_wdata <= -1;
//     vcu_7_wvalid <= 0;
//     vcu_7_waddr <= -1;
//     vcu_7_wdata <= -1;
//     vcu_8_wvalid <= 0;
//     vcu_8_waddr <= -1;
//     vcu_8_wdata <= -1;
//     vcu_9_wvalid <= 0;
//     vcu_9_waddr <= -1;
//     vcu_9_wdata <= -1;
//     vcu_a_wvalid <= 0;
//     vcu_a_waddr <= -1;
//     vcu_a_wdata <= -1;
//     vcu_b_wvalid <= 0;
//     vcu_b_waddr <= -1;
//     vcu_b_wdata <= -1;
//     vcu_c_wvalid <= 0;
//     vcu_c_waddr <= -1;
//     vcu_c_wdata <= -1;
//     vcu_d_wvalid <= 0;
//     vcu_d_waddr <= -1;
//     vcu_d_wdata <= -1;
//     vcu_e_wvalid <= 0;
//     vcu_e_waddr <= -1;
//     vcu_e_wdata <= -1;
//     vcu_f_wvalid <= 0;
//     vcu_f_waddr <= -1;
//     vcu_f_wdata <= -1;
//     pea_0_rvalid <= 0;
//     pea_0_raddr <= -1;
//     pea_1_rvalid <= 0;
//     pea_1_raddr <= -1;
//     pea_2_rvalid <= 0;
//     pea_2_raddr <= -1;
//     pea_3_rvalid <= 0;
//     pea_3_raddr <= -1;
//     pea_4_rvalid <= 0;
//     pea_4_raddr <= -1;
//     pea_5_rvalid <= 0;
//     pea_5_raddr <= -1;
//     pea_6_rvalid <= 0;
//     pea_6_raddr <= -1;
//     pea_7_rvalid <= 0;
//     pea_7_raddr <= -1;
//     pea_8_rvalid <= 0;
//     pea_8_raddr <= -1;
//     pea_9_rvalid <= 0;
//     pea_9_raddr <= -1;
//     pea_a_rvalid <= 0;
//     pea_a_raddr <= -1;
//     pea_b_rvalid <= 0;
//     pea_b_raddr <= -1;
//     pea_c_rvalid <= 0;
//     pea_c_raddr <= -1;
//     pea_d_rvalid <= 0;
//     pea_d_raddr <= -1;
//     pea_e_rvalid <= 0;
//     pea_e_raddr <= -1;
//     pea_f_rvalid <= 0;
//     pea_f_raddr <= -1;
//     write_done_flag <= 1'b0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       vcu_0_wvalid <= 1;
//       vcu_1_wvalid <= 1;
//       vcu_2_wvalid <= 1;
//       vcu_3_wvalid <= 1;
//       vcu_4_wvalid <= 1;
//       vcu_5_wvalid <= 1;
//       vcu_6_wvalid <= 1;
//       vcu_7_wvalid <= 1;
//       vcu_8_wvalid <= 1;
//       vcu_9_wvalid <= 1;
//       vcu_a_wvalid <= 1;
//       vcu_b_wvalid <= 1;
//       vcu_c_wvalid <= 1;
//       vcu_d_wvalid <= 1;
//       vcu_e_wvalid <= 1;
//       vcu_f_wvalid <= 1;
//       vcu_0_wdata <= vcu_0_wdata + 1;
//       vcu_1_wdata <= vcu_1_wdata + 1;
//       vcu_2_wdata <= vcu_2_wdata + 1;
//       vcu_3_wdata <= vcu_3_wdata + 1;
//       vcu_4_wdata <= vcu_4_wdata + 1;
//       vcu_5_wdata <= vcu_5_wdata + 1;
//       vcu_6_wdata <= vcu_6_wdata + 1;
//       vcu_7_wdata <= vcu_7_wdata + 1;
//       vcu_8_wdata <= vcu_8_wdata + 1;
//       vcu_9_wdata <= vcu_9_wdata + 1;
//       vcu_a_wdata <= vcu_a_wdata + 1;
//       vcu_b_wdata <= vcu_b_wdata + 1;
//       vcu_c_wdata <= vcu_c_wdata + 1;
//       vcu_d_wdata <= vcu_d_wdata + 1;
//       vcu_e_wdata <= vcu_e_wdata + 1;
//       vcu_f_wdata <= vcu_f_wdata + 1;
//       if (vcu_0_waddr == 256 - 1) begin
//         vcu_0_waddr <= 256 * 16;
//       end
//       else if (vcu_0_waddr == 256 * 16 + 256 - 1) begin
//         vcu_0_waddr <= 256 * 32;
//       end
//       else if (vcu_0_waddr == 256 * 32 + 256 - 1) begin
//         vcu_0_waddr <= 256 * 48;
//       end
//       else if (vcu_0_waddr == 256 * 48 + 256 - 1) begin
//         vcu_0_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_0_wvalid <= 0;
//       end
//       else begin
//         vcu_0_waddr <= vcu_0_waddr + 1;
//       end

//       if (vcu_1_waddr == 256 - 1) begin
//         vcu_1_waddr <= 256 * 16;
//       end
//       else if (vcu_1_waddr == 256 * 16 + 256 - 1) begin
//         vcu_1_waddr <= 256 * 32;
//       end
//       else if (vcu_1_waddr == 256 * 32 + 256 - 1) begin
//         vcu_1_waddr <= 256 * 48;
//       end
//       else if (vcu_1_waddr == 256 * 48 + 256 - 1) begin
//         vcu_1_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_1_wvalid <= 0;
//       end
//       else begin
//         vcu_1_waddr <= vcu_1_waddr + 1;
//       end

//       if (vcu_2_waddr == 256 - 1) begin
//         vcu_2_waddr <= 256 * 16;
//       end
//       else if (vcu_2_waddr == 256 * 16 + 256 - 1) begin
//         vcu_2_waddr <= 256 * 32;
//       end
//       else if (vcu_2_waddr == 256 * 32 + 256 - 1) begin
//         vcu_2_waddr <= 256 * 48;
//       end
//       else if (vcu_2_waddr == 256 * 48 + 256 - 1) begin
//         vcu_2_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_2_wvalid <= 0;
//       end
//       else begin
//         vcu_2_waddr <= vcu_2_waddr + 1;
//       end

//       if (vcu_3_waddr == 256 - 1) begin
//         vcu_3_waddr <= 256 * 16;
//       end
//       else if (vcu_3_waddr == 256 * 16 + 256 - 1) begin
//         vcu_3_waddr <= 256 * 32;
//       end
//       else if (vcu_3_waddr == 256 * 32 + 256 - 1) begin
//         vcu_3_waddr <= 256 * 48;
//       end
//       else if (vcu_3_waddr == 256 * 48 + 256 - 1) begin
//         vcu_3_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_3_wvalid <= 0;
//       end
//       else begin
//         vcu_3_waddr <= vcu_3_waddr + 1;
//       end

//       if (vcu_4_waddr == 256 - 1) begin
//         vcu_4_waddr <= 256 * 16;
//       end
//       else if (vcu_4_waddr == 256 * 16 + 256 - 1) begin
//         vcu_4_waddr <= 256 * 32;
//       end
//       else if (vcu_4_waddr == 256 * 32 + 256 - 1) begin
//         vcu_4_waddr <= 256 * 48;
//       end
//       else if (vcu_4_waddr == 256 * 48 + 256 - 1) begin
//         vcu_4_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_4_wvalid <= 0;
//       end
//       else begin
//         vcu_4_waddr <= vcu_4_waddr + 1;
//       end

//       if (vcu_5_waddr == 256 - 1) begin
//         vcu_5_waddr <= 256 * 16;
//       end
//       else if (vcu_5_waddr == 256 * 16 + 256 - 1) begin
//         vcu_5_waddr <= 256 * 32;
//       end
//       else if (vcu_5_waddr == 256 * 32 + 256 - 1) begin
//         vcu_5_waddr <= 256 * 48;
//       end
//       else if (vcu_5_waddr == 256 * 48 + 256 - 1) begin
//         vcu_5_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_5_wvalid <= 0;
//       end
//       else begin
//         vcu_5_waddr <= vcu_5_waddr + 1;
//       end

//       if (vcu_6_waddr == 256 - 1) begin
//         vcu_6_waddr <= 256 * 16;
//       end
//       else if (vcu_6_waddr == 256 * 16 + 256 - 1) begin
//         vcu_6_waddr <= 256 * 32;
//       end
//       else if (vcu_6_waddr == 256 * 32 + 256 - 1) begin
//         vcu_6_waddr <= 256 * 48;
//       end
//       else if (vcu_6_waddr == 256 * 48 + 256 - 1) begin
//         vcu_6_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_6_wvalid <= 0;
//       end
//       else begin
//         vcu_6_waddr <= vcu_6_waddr + 1;
//       end

//       if (vcu_7_waddr == 256 - 1) begin
//         vcu_7_waddr <= 256 * 16;
//       end
//       else if (vcu_7_waddr == 256 * 16 + 256 - 1) begin
//         vcu_7_waddr <= 256 * 32;
//       end
//       else if (vcu_7_waddr == 256 * 32 + 256 - 1) begin
//         vcu_7_waddr <= 256 * 48;
//       end
//       else if (vcu_7_waddr == 256 * 48 + 256 - 1) begin
//         vcu_7_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_7_wvalid <= 0;
//       end
//       else begin
//         vcu_7_waddr <= vcu_7_waddr + 1;
//       end

//       if (vcu_8_waddr == 256 - 1) begin
//         vcu_8_waddr <= 256 * 16;
//       end
//       else if (vcu_8_waddr == 256 * 16 + 256 - 1) begin
//         vcu_8_waddr <= 256 * 32;
//       end
//       else if (vcu_8_waddr == 256 * 32 + 256 - 1) begin
//         vcu_8_waddr <= 256 * 48;
//       end
//       else if (vcu_8_waddr == 256 * 48 + 256 - 1) begin
//         vcu_8_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_8_wvalid <= 0;
//       end
//       else begin
//         vcu_8_waddr <= vcu_8_waddr + 1;
//       end

//       if (vcu_9_waddr == 256 - 1) begin
//         vcu_9_waddr <= 256 * 16;
//       end
//       else if (vcu_9_waddr == 256 * 16 + 256 - 1) begin
//         vcu_9_waddr <= 256 * 32;
//       end
//       else if (vcu_9_waddr == 256 * 32 + 256 - 1) begin
//         vcu_9_waddr <= 256 * 48;
//       end
//       else if (vcu_9_waddr == 256 * 48 + 256 - 1) begin
//         vcu_9_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_9_wvalid <= 0;
//       end
//       else begin
//         vcu_9_waddr <= vcu_9_waddr + 1;
//       end

//       if (vcu_a_waddr == 256 - 1) begin
//         vcu_a_waddr <= 256 * 16;
//       end
//       else if (vcu_a_waddr == 256 * 16 + 256 - 1) begin
//         vcu_a_waddr <= 256 * 32;
//       end
//       else if (vcu_a_waddr == 256 * 32 + 256 - 1) begin
//         vcu_a_waddr <= 256 * 48;
//       end
//       else if (vcu_a_waddr == 256 * 48 + 256 - 1) begin
//         vcu_a_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_a_wvalid <= 0;
//       end
//       else begin
//         vcu_a_waddr <= vcu_a_waddr + 1;
//       end

//       if (vcu_b_waddr == 256 - 1) begin
//         vcu_b_waddr <= 256 * 16;
//       end
//       else if (vcu_b_waddr == 256 * 16 + 256 - 1) begin
//         vcu_b_waddr <= 256 * 32;
//       end
//       else if (vcu_b_waddr == 256 * 32 + 256 - 1) begin
//         vcu_b_waddr <= 256 * 48;
//       end
//       else if (vcu_b_waddr == 256 * 48 + 256 - 1) begin
//         vcu_b_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_b_wvalid <= 0;
//       end
//       else begin
//         vcu_b_waddr <= vcu_b_waddr + 1;
//       end

//       if (vcu_c_waddr == 256 - 1) begin
//         vcu_c_waddr <= 256 * 16;
//       end
//       else if (vcu_c_waddr == 256 * 16 + 256 - 1) begin
//         vcu_c_waddr <= 256 * 32;
//       end
//       else if (vcu_c_waddr == 256 * 32 + 256 - 1) begin
//         vcu_c_waddr <= 256 * 48;
//       end
//       else if (vcu_c_waddr == 256 * 48 + 256 - 1) begin
//         vcu_c_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_c_wvalid <= 0;
//       end
//       else begin
//         vcu_c_waddr <= vcu_c_waddr + 1;
//       end

//       if (vcu_d_waddr == 256 - 1) begin
//         vcu_d_waddr <= 256 * 16;
//       end
//       else if (vcu_d_waddr == 256 * 16 + 256 - 1) begin
//         vcu_d_waddr <= 256 * 32;
//       end
//       else if (vcu_d_waddr == 256 * 32 + 256 - 1) begin
//         vcu_d_waddr <= 256 * 48;
//       end
//       else if (vcu_d_waddr == 256 * 48 + 256 - 1) begin
//         vcu_d_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_d_wvalid <= 0;
//       end
//       else begin
//         vcu_d_waddr <= vcu_d_waddr + 1;
//       end

//       if (vcu_e_waddr == 256 - 1) begin
//         vcu_e_waddr <= 256 * 16;
//       end
//       else if (vcu_e_waddr == 256 * 16 + 256 - 1) begin
//         vcu_e_waddr <= 256 * 32;
//       end
//       else if (vcu_e_waddr == 256 * 32 + 256 - 1) begin
//         vcu_e_waddr <= 256 * 48;
//       end
//       else if (vcu_e_waddr == 256 * 48 + 256 - 1) begin
//         vcu_e_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_e_wvalid <= 0;
//       end
//       else begin
//         vcu_e_waddr <= vcu_e_waddr + 1;
//       end

//       if (vcu_f_waddr == 256 - 1) begin
//         vcu_f_waddr <= 256 * 16;
//       end
//       else if (vcu_f_waddr == 256 * 16 + 256 - 1) begin
//         vcu_f_waddr <= 256 * 32;
//       end
//       else if (vcu_f_waddr == 256 * 32 + 256 - 1) begin
//         vcu_f_waddr <= 256 * 48;
//       end
//       else if (vcu_f_waddr == 256 * 48 + 256 - 1) begin
//         vcu_f_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_f_wvalid <= 0;
//       end
//       else begin
//         vcu_f_waddr <= vcu_f_waddr + 1;
//       end
//     end
//     else begin

//       vcu_0_wvalid <= 0;
//       vcu_1_wvalid <= 0;
//       vcu_2_wvalid <= 0;
//       vcu_3_wvalid <= 0;
//       vcu_4_wvalid <= 0;
//       vcu_5_wvalid <= 0;
//       vcu_6_wvalid <= 0;
//       vcu_7_wvalid <= 0;
//       vcu_8_wvalid <= 0;
//       vcu_9_wvalid <= 0;
//       vcu_a_wvalid <= 0;
//       vcu_b_wvalid <= 0;
//       vcu_c_wvalid <= 0;
//       vcu_d_wvalid <= 0;
//       vcu_e_wvalid <= 0;
//       vcu_f_wvalid <= 0;

//       pea_0_rvalid <= 1;
//       pea_1_rvalid <= 1;
//       pea_2_rvalid <= 1;
//       pea_3_rvalid <= 1;
//       pea_4_rvalid <= 1;
//       pea_5_rvalid <= 1;
//       pea_6_rvalid <= 1;
//       pea_7_rvalid <= 1;
//       pea_8_rvalid <= 1;
//       pea_9_rvalid <= 1;
//       pea_a_rvalid <= 1;
//       pea_b_rvalid <= 1;
//       pea_c_rvalid <= 1;
//       pea_d_rvalid <= 1;
//       pea_e_rvalid <= 1;
//       pea_f_rvalid <= 1;
//       if (pea_0_raddr == 256 - 1) begin
//         pea_0_raddr <= 256 * 16;
//       end
//       else if (pea_0_raddr == 256 * 16 + 256 - 1) begin
//         pea_0_raddr <= 256 * 32;
//       end
//       else if (pea_0_raddr == 256 * 32 + 256 - 1) begin
//         pea_0_raddr <= 256 * 48;
//       end
//       else if (pea_0_raddr == 256 * 48 + 256 - 1) begin
//         pea_0_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_0_raddr <= pea_0_raddr + 1;
//       end

//       if (pea_1_raddr == 256 - 1) begin
//         pea_1_raddr <= 256 * 16;
//       end
//       else if (pea_1_raddr == 256 * 16 + 256 - 1) begin
//         pea_1_raddr <= 256 * 32;
//       end
//       else if (pea_1_raddr == 256 * 32 + 256 - 1) begin
//         pea_1_raddr <= 256 * 48;
//       end
//       else if (pea_1_raddr == 256 * 48 + 256 - 1) begin
//         pea_1_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_1_raddr <= pea_1_raddr + 1;
//       end

//       if (pea_2_raddr == 256 - 1) begin
//         pea_2_raddr <= 256 * 16;
//       end
//       else if (pea_2_raddr == 256 * 16 + 256 - 1) begin
//         pea_2_raddr <= 256 * 32;
//       end
//       else if (pea_2_raddr == 256 * 32 + 256 - 1) begin
//         pea_2_raddr <= 256 * 48;
//       end
//       else if (pea_2_raddr == 256 * 48 + 256 - 1) begin
//         pea_2_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_2_raddr <= pea_2_raddr + 1;
//       end

//       if (pea_3_raddr == 256 - 1) begin
//         pea_3_raddr <= 256 * 16;
//       end
//       else if (pea_3_raddr == 256 * 16 + 256 - 1) begin
//         pea_3_raddr <= 256 * 32;
//       end
//       else if (pea_3_raddr == 256 * 32 + 256 - 1) begin
//         pea_3_raddr <= 256 * 48;
//       end
//       else if (pea_3_raddr == 256 * 48 + 256 - 1) begin
//         pea_3_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_3_raddr <= pea_3_raddr + 1;
//       end

//       if (pea_4_raddr == 256 - 1) begin
//         pea_4_raddr <= 256 * 16;
//       end
//       else if (pea_4_raddr == 256 * 16 + 256 - 1) begin
//         pea_4_raddr <= 256 * 32;
//       end
//       else if (pea_4_raddr == 256 * 32 + 256 - 1) begin
//         pea_4_raddr <= 256 * 48;
//       end
//       else if (pea_4_raddr == 256 * 48 + 256 - 1) begin
//         pea_4_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_4_raddr <= pea_4_raddr + 1;
//       end

//       if (pea_5_raddr == 256 - 1) begin
//         pea_5_raddr <= 256 * 16;
//       end
//       else if (pea_5_raddr == 256 * 16 + 256 - 1) begin
//         pea_5_raddr <= 256 * 32;
//       end
//       else if (pea_5_raddr == 256 * 32 + 256 - 1) begin
//         pea_5_raddr <= 256 * 48;
//       end
//       else if (pea_5_raddr == 256 * 48 + 256 - 1) begin
//         pea_5_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_5_raddr <= pea_5_raddr + 1;
//       end

//       if (pea_6_raddr == 256 - 1) begin
//         pea_6_raddr <= 256 * 16;
//       end
//       else if (pea_6_raddr == 256 * 16 + 256 - 1) begin
//         pea_6_raddr <= 256 * 32;
//       end
//       else if (pea_6_raddr == 256 * 32 + 256 - 1) begin
//         pea_6_raddr <= 256 * 48;
//       end
//       else if (pea_6_raddr == 256 * 48 + 256 - 1) begin
//         pea_6_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_6_raddr <= pea_6_raddr + 1;
//       end

//       if (pea_7_raddr == 256 - 1) begin
//         pea_7_raddr <= 256 * 16;
//       end
//       else if (pea_7_raddr == 256 * 16 + 256 - 1) begin
//         pea_7_raddr <= 256 * 32;
//       end
//       else if (pea_7_raddr == 256 * 32 + 256 - 1) begin
//         pea_7_raddr <= 256 * 48;
//       end
//       else if (pea_7_raddr == 256 * 48 + 256 - 1) begin
//         pea_7_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_7_raddr <= pea_7_raddr + 1;
//       end

//       if (pea_8_raddr == 256 - 1) begin
//         pea_8_raddr <= 256 * 16;
//       end
//       else if (pea_8_raddr == 256 * 16 + 256 - 1) begin
//         pea_8_raddr <= 256 * 32;
//       end
//       else if (pea_8_raddr == 256 * 32 + 256 - 1) begin
//         pea_8_raddr <= 256 * 48;
//       end
//       else if (pea_8_raddr == 256 * 48 + 256 - 1) begin
//         pea_8_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_8_raddr <= pea_8_raddr + 1;
//       end

//       if (pea_9_raddr == 256 - 1) begin
//         pea_9_raddr <= 256 * 16;
//       end
//       else if (pea_9_raddr == 256 * 16 + 256 - 1) begin
//         pea_9_raddr <= 256 * 32;
//       end
//       else if (pea_9_raddr == 256 * 32 + 256 - 1) begin
//         pea_9_raddr <= 256 * 48;
//       end
//       else if (pea_9_raddr == 256 * 48 + 256 - 1) begin
//         pea_9_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_9_raddr <= pea_9_raddr + 1;
//       end

//       if (pea_a_raddr == 256 - 1) begin
//         pea_a_raddr <= 256 * 16;
//       end
//       else if (pea_a_raddr == 256 * 16 + 256 - 1) begin
//         pea_a_raddr <= 256 * 32;
//       end
//       else if (pea_a_raddr == 256 * 32 + 256 - 1) begin
//         pea_a_raddr <= 256 * 48;
//       end
//       else if (pea_a_raddr == 256 * 48 + 256 - 1) begin
//         pea_a_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_a_raddr <= pea_a_raddr + 1;
//       end

//       if (pea_b_raddr == 256 - 1) begin
//         pea_b_raddr <= 256 * 16;
//       end
//       else if (pea_b_raddr == 256 * 16 + 256 - 1) begin
//         pea_b_raddr <= 256 * 32;
//       end
//       else if (pea_b_raddr == 256 * 32 + 256 - 1) begin
//         pea_b_raddr <= 256 * 48;
//       end
//       else if (pea_b_raddr == 256 * 48 + 256 - 1) begin
//         pea_b_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_b_raddr <= pea_b_raddr + 1;
//       end

//       if (pea_c_raddr == 256 - 1) begin
//         pea_c_raddr <= 256 * 16;
//       end
//       else if (pea_c_raddr == 256 * 16 + 256 - 1) begin
//         pea_c_raddr <= 256 * 32;
//       end
//       else if (pea_c_raddr == 256 * 32 + 256 - 1) begin
//         pea_c_raddr <= 256 * 48;
//       end
//       else if (pea_c_raddr == 256 * 48 + 256 - 1) begin
//         pea_c_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_c_raddr <= pea_c_raddr + 1;
//       end

//       if (pea_d_raddr == 256 - 1) begin
//         pea_d_raddr <= 256 * 16;
//       end
//       else if (pea_d_raddr == 256 * 16 + 256 - 1) begin
//         pea_d_raddr <= 256 * 32;
//       end
//       else if (pea_d_raddr == 256 * 32 + 256 - 1) begin
//         pea_d_raddr <= 256 * 48;
//       end
//       else if (pea_d_raddr == 256 * 48 + 256 - 1) begin
//         pea_d_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_d_raddr <= pea_d_raddr + 1;
//       end

//       if (pea_e_raddr == 256 - 1) begin
//         pea_e_raddr <= 256 * 16;
//       end
//       else if (pea_e_raddr == 256 * 16 + 256 - 1) begin
//         pea_e_raddr <= 256 * 32;
//       end
//       else if (pea_e_raddr == 256 * 32 + 256 - 1) begin
//         pea_e_raddr <= 256 * 48;
//       end
//       else if (pea_e_raddr == 256 * 48 + 256 - 1) begin
//         pea_e_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_e_raddr <= pea_e_raddr + 1;
//       end

//       if (pea_f_raddr == 256 - 1) begin
//         pea_f_raddr <= 256 * 16;
//       end
//       else if (pea_f_raddr == 256 * 16 + 256 - 1) begin
//         pea_f_raddr <= 256 * 32;
//       end
//       else if (pea_f_raddr == 256 * 32 + 256 - 1) begin
//         pea_f_raddr <= 256 * 48;
//       end
//       else if (pea_f_raddr == 256 * 48 + 256 - 1) begin
//         pea_f_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_f_raddr <= pea_f_raddr + 1;
//       end
//     end

//     if (pea_0_raddr == 256 * 48 + 256 - 1) begin
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                         vcu write pea read cross                                         */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     vcu_0_wvalid <= 0;
//     vcu_0_waddr <= -1;
//     vcu_0_wdata <= -1;
//     vcu_4_wvalid <= 0;
//     vcu_4_waddr <= -1;
//     vcu_4_wdata <= -1;
//     vcu_8_wvalid <= 0;
//     vcu_8_waddr <= -1;
//     vcu_8_wdata <= -1;
//     vcu_c_wvalid <= 0;
//     vcu_c_waddr <= -1;
//     vcu_c_wdata <= -1;
//     vcu_f_wvalid <= 0;
//     vcu_f_waddr <= -1;
//     vcu_f_wdata <= -1;
//     pea_0_rvalid <= 0;
//     pea_0_raddr <= -1;
//     pea_4_rvalid <= 0;
//     pea_4_raddr <= -1;
//     pea_8_rvalid <= 0;
//     pea_8_raddr <= -1;
//     pea_c_rvalid <= 0;
//     pea_c_raddr <= -1;
//     write_done_flag <= 1'b0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       vcu_0_wvalid <= 1;
//       vcu_4_wvalid <= 1;
//       vcu_8_wvalid <= 1;
//       vcu_c_wvalid <= 1;
//       vcu_0_wdata <= vcu_0_wdata + 1;
//       vcu_4_wdata <= vcu_4_wdata + 1;
//       vcu_8_wdata <= vcu_8_wdata + 1;
//       vcu_c_wdata <= vcu_c_wdata + 1;
//       if (vcu_0_waddr == 256 * 4 - 1) begin
//         vcu_0_waddr <= 256 * 16;
//       end
//       else if (vcu_0_waddr == 256 * 16 + 256 * 4 - 1) begin
//         vcu_0_waddr <= 256 * 32;
//       end
//       else if (vcu_0_waddr == 256 * 32 + 256 * 4 - 1) begin
//         vcu_0_waddr <= 256 * 48;
//       end
//       else if (vcu_0_waddr == 256 * 48 + 256 * 4 - 1) begin
//         vcu_0_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_0_wvalid <= 0;
//       end
//       else begin
//         vcu_0_waddr <= vcu_0_waddr + 1;
//       end

//       if (vcu_4_waddr == 256 * 8 - 1) begin
//         vcu_4_waddr <= 256 * 16 + 256 * 4;
//       end
//       else if (vcu_4_waddr == 256 * 16 + 256 * 8 - 1) begin
//         vcu_4_waddr <= 256 * 32 + 256 * 4;
//       end
//       else if (vcu_4_waddr == 256 * 32 + 256 * 8 - 1) begin
//         vcu_4_waddr <= 256 * 48 + 256 * 4;
//       end
//       else if (vcu_4_waddr == 256 * 48 + 256 * 8 - 1) begin
//         vcu_4_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_4_wvalid <= 0;
//       end
//       else begin
//         vcu_4_waddr <= vcu_4_waddr + 1;
//       end

//       if (vcu_8_waddr == 256 * 12 - 1) begin
//         vcu_8_waddr <= 256 * 16 + 256 * 8;
//       end
//       else if (vcu_8_waddr == 256 * 16 + 256 * 12 - 1) begin
//         vcu_8_waddr <= 256 * 32 + 256 * 8;
//       end
//       else if (vcu_8_waddr == 256 * 32 + 256 * 12 - 1) begin
//         vcu_8_waddr <= 256 * 48 + 256 * 8;
//       end
//       else if (vcu_8_waddr == 256 * 48 + 256 * 12 - 1) begin
//         vcu_8_waddr <= 0;
//         write_done_flag <= 1;
//         vcu_8_wvalid <= 0;
//       end
//       else begin
//         vcu_8_waddr <= vcu_8_waddr + 1;
//       end

//       if (vcu_c_waddr == 256 * 16 - 1) begin
//         vcu_c_waddr <= 256 * 16 + 256 * 12;
//       end
//       else if (vcu_c_waddr == 256 * 16 + 256 * 16 - 1) begin
//         vcu_c_waddr <= 256 * 32 + 256 * 12;
//       end
//       else if (vcu_c_waddr == 256 * 32 + 256 * 16 - 1) begin
//         vcu_c_waddr <= 256 * 48 + 256 * 12;
//       end
//       else if (vcu_0_waddr == 256 * 48 + 256 * 4 - 1) begin
//         vcu_c_waddr <= 0;
//         vcu_c_wvalid <= 0;
//       end
//       else begin
//         vcu_c_waddr <= vcu_c_waddr + 1;
//       end
//     end
//     else begin

//       vcu_0_wvalid <= 0;
//       vcu_1_wvalid <= 0;
//       vcu_2_wvalid <= 0;
//       vcu_3_wvalid <= 0;
//       vcu_4_wvalid <= 0;
//       vcu_5_wvalid <= 0;
//       vcu_6_wvalid <= 0;
//       vcu_7_wvalid <= 0;
//       vcu_8_wvalid <= 0;
//       vcu_9_wvalid <= 0;
//       vcu_a_wvalid <= 0;
//       vcu_b_wvalid <= 0;
//       vcu_c_wvalid <= 0;
//       vcu_d_wvalid <= 0;
//       vcu_e_wvalid <= 0;
//       vcu_f_wvalid <= 0;

//       pea_0_rvalid <= 1;
//       pea_4_rvalid <= 1;
//       pea_8_rvalid <= 1;
//       pea_c_rvalid <= 1;
//       if (pea_0_raddr == 256 * 4 - 1) begin
//         pea_0_raddr <= 256 * 16;
//       end
//       else if (pea_0_raddr == 256 * 16 + 256 * 4 - 1) begin
//         pea_0_raddr <= 256 * 32;
//       end
//       else if (pea_0_raddr == 256 * 32 + 256 * 4 - 1) begin
//         pea_0_raddr <= 256 * 48;
//       end
//       else if (pea_0_raddr == 256 * 48 + 256 * 4 - 1) begin
//         pea_0_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_0_raddr <= pea_0_raddr + 1;
//       end

//       if (pea_4_raddr == 256 * 8 - 1) begin
//         pea_4_raddr <= 256 * 16 + 256 * 4;
//       end
//       else if (pea_4_raddr == 256 * 16 + 256 * 8 - 1) begin
//         pea_4_raddr <= 256 * 32 + 256 * 4;
//       end
//       else if (pea_4_raddr == 256 * 32 + 256 * 8 - 1) begin
//         pea_4_raddr <= 256 * 48 + 256 * 4;
//       end
//       else if (pea_4_raddr == 256 * 48 + 256 * 8 - 1) begin
//         pea_4_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_4_raddr <= pea_4_raddr + 1;
//       end

//       if (pea_8_raddr == 256 * 12 - 1) begin
//         pea_8_raddr <= 256 * 16 + 256 * 8;
//       end
//       else if (pea_8_raddr == 256 * 16 + 256 * 12 - 1) begin
//         pea_8_raddr <= 256 * 32 + 256 * 8;
//       end
//       else if (pea_8_raddr == 256 * 32 + 256 * 12 - 1) begin
//         pea_8_raddr <= 256 * 48 + 256 * 8;
//       end
//       else if (pea_8_raddr == 256 * 48 + 256 * 12 - 1) begin
//         pea_8_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_8_raddr <= pea_8_raddr + 1;
//       end

//       if (pea_c_raddr == 256 * 16 - 1) begin
//         pea_c_raddr <= 256 * 16 + 256 * 12;
//       end
//       else if (pea_c_raddr == 256 * 16 + 256 * 16 - 1) begin
//         pea_c_raddr <= 256 * 32 + 256 * 12;
//       end
//       else if (pea_c_raddr == 256 * 32 + 256 * 16 - 1) begin
//         pea_c_raddr <= 256 * 48 + 256 * 12;
//       end
//       else if (pea_c_raddr == 256 * 48 + 256 * 16 - 2) begin
//         pea_c_raddr <= 0;
//         write_done_flag <= 0;
//       end
//       else begin
//         pea_c_raddr <= pea_c_raddr + 1;
//       end
//     end

//     if (pea_0_raddr == 256 * 48 + 256 * 4 - 1) begin
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                         pea write vcu read cross                                         */
/* -------------------------------------------------------------------------------------------------------- */

reg write_done_flag;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pea_0_wvalid <= 0;
    pea_0_waddr <= -1;
    pea_0_wdata <= -1;
    pea_4_wvalid <= 0;
    pea_4_waddr <= -1;
    pea_4_wdata <= -1;
    pea_8_wvalid <= 0;
    pea_8_waddr <= -1;
    pea_8_wdata <= -1;
    pea_c_wvalid <= 0;
    pea_c_waddr <= -1;
    pea_c_wdata <= -1;
    pea_f_wvalid <= 0;
    pea_f_waddr <= -1;
    pea_f_wdata <= -1;
    vcu_0_rvalid <= 0;
    vcu_0_raddr <= -1;
    vcu_4_rvalid <= 0;
    vcu_4_raddr <= -1;
    vcu_8_rvalid <= 0;
    vcu_8_raddr <= -1;
    vcu_c_rvalid <= 0;
    vcu_c_raddr <= -1;
    write_done_flag <= 1'b0;
  end
  else begin
    if (!write_done_flag) begin
      pea_0_wvalid <= 1;
      pea_4_wvalid <= 1;
      pea_8_wvalid <= 1;
      pea_c_wvalid <= 1;
      pea_0_wdata <= pea_0_wdata + 1;
      pea_4_wdata <= pea_4_wdata + 1;
      pea_8_wdata <= pea_8_wdata + 1;
      pea_c_wdata <= pea_c_wdata + 1;
      if (pea_0_waddr == 256 * 4 - 1) begin
        pea_0_waddr <= 256 * 16;
      end
      else if (pea_0_waddr == 256 * 16 + 256 * 4 - 1) begin
        pea_0_waddr <= 256 * 32;
      end
      else if (pea_0_waddr == 256 * 32 + 256 * 4 - 1) begin
        pea_0_waddr <= 256 * 48;
      end
      else if (pea_0_waddr == 256 * 48 + 256 * 4 - 1) begin
        pea_0_waddr <= 0;
        write_done_flag <= 1;
        pea_0_wvalid <= 0;
      end
      else begin
        pea_0_waddr <= pea_0_waddr + 1;
      end

      if (pea_4_waddr == 256 * 4 - 1) begin
        pea_4_waddr <= 256 * 16;
      end
      else if (pea_4_waddr == 256 * 16 + 256 * 4 - 1) begin
        pea_4_waddr <= 256 * 32;
      end
      else if (pea_4_waddr == 256 * 32 + 256 * 4 - 1) begin
        pea_4_waddr <= 256 * 48;
      end
      else if (pea_4_waddr == 256 * 48 + 256 * 4 - 1) begin
        pea_4_waddr <= 0;
        write_done_flag <= 1;
        pea_4_wvalid <= 0;
      end
      else begin
        pea_4_waddr <= pea_4_waddr + 1;
      end

      if (pea_8_waddr == 256 * 4 - 1) begin
        pea_8_waddr <= 256 * 16;
      end
      else if (pea_8_waddr == 256 * 16 + 256 * 4 - 1) begin
        pea_8_waddr <= 256 * 32;
      end
      else if (pea_8_waddr == 256 * 32 + 256 * 4 - 1) begin
        pea_8_waddr <= 256 * 48;
      end
      else if (pea_8_waddr == 256 * 48 + 256 * 4 - 1) begin
        pea_8_waddr <= 0;
        write_done_flag <= 1;
        pea_8_wvalid <= 0;
      end
      else begin
        pea_8_waddr <= pea_8_waddr + 1;
      end

      if (pea_c_waddr == 256 * 4 - 1) begin
        pea_c_waddr <= 256 * 16;
      end
      else if (pea_c_waddr == 256 * 16 + 256 * 4 - 1) begin
        pea_c_waddr <= 256 * 32;
      end
      else if (pea_c_waddr == 256 * 32 + 256 * 4 - 1) begin
        pea_c_waddr <= 256 * 48;
      end
      else if (pea_0_waddr == 256 * 48 + 256 * 4 - 1) begin
        pea_c_waddr <= 0;
        pea_c_wvalid <= 0;
      end
      else begin
        pea_c_waddr <= pea_c_waddr + 1;
      end
    end
    else begin

      pea_0_wvalid <= 0;
      pea_1_wvalid <= 0;
      pea_2_wvalid <= 0;
      pea_3_wvalid <= 0;
      pea_4_wvalid <= 0;
      pea_5_wvalid <= 0;
      pea_6_wvalid <= 0;
      pea_7_wvalid <= 0;
      pea_8_wvalid <= 0;
      pea_9_wvalid <= 0;
      pea_a_wvalid <= 0;
      pea_b_wvalid <= 0;
      pea_c_wvalid <= 0;
      pea_d_wvalid <= 0;
      pea_e_wvalid <= 0;
      pea_f_wvalid <= 0;

      vcu_0_rvalid <= 1;
      vcu_4_rvalid <= 1;
      vcu_8_rvalid <= 1;
      vcu_c_rvalid <= 1;
      if (vcu_0_raddr == 256 * 4 - 1) begin
        vcu_0_raddr <= 256 * 16;
      end
      else if (vcu_0_raddr == 256 * 16 + 256 * 4 - 1) begin
        vcu_0_raddr <= 256 * 32;
      end
      else if (vcu_0_raddr == 256 * 32 + 256 * 4 - 1) begin
        vcu_0_raddr <= 256 * 48;
      end
      else if (vcu_0_raddr == 256 * 48 + 256 * 4 - 1) begin
        vcu_0_raddr <= 0;
        write_done_flag <= 0;
      end
      else begin
        vcu_0_raddr <= vcu_0_raddr + 1;
      end

      if (vcu_4_raddr == 256 * 4 - 1) begin
        vcu_4_raddr <= 256 * 16;
      end
      else if (vcu_4_raddr == 256 * 16 + 256 * 4 - 1) begin
        vcu_4_raddr <= 256 * 32;
      end
      else if (vcu_4_raddr == 256 * 32 + 256 * 4 - 1) begin
        vcu_4_raddr <= 256 * 48;
      end
      else if (vcu_4_raddr == 256 * 48 + 256 * 4 - 1) begin
        vcu_4_raddr <= 0;
        write_done_flag <= 0;
      end
      else begin
        vcu_4_raddr <= vcu_4_raddr + 1;
      end

      if (vcu_8_raddr == 256 * 4 - 1) begin
        vcu_8_raddr <= 256 * 16;
      end
      else if (vcu_8_raddr == 256 * 16 + 256 * 4 - 1) begin
        vcu_8_raddr <= 256 * 32;
      end
      else if (vcu_8_raddr == 256 * 32 + 256 * 4 - 1) begin
        vcu_8_raddr <= 256 * 48;
      end
      else if (vcu_8_raddr == 256 * 48 + 256 * 4 - 1) begin
        vcu_8_raddr <= 0;
        write_done_flag <= 0;
      end
      else begin
        vcu_8_raddr <= vcu_8_raddr + 1;
      end

      if (vcu_c_raddr == 256 * 4 - 1) begin
        vcu_c_raddr <= 256 * 16;
      end
      else if (vcu_c_raddr == 256 * 16 + 256 * 4 - 1) begin
        vcu_c_raddr <= 256 * 32;
      end
      else if (vcu_c_raddr == 256 * 32 + 256 * 4 - 1) begin
        vcu_c_raddr <= 256 * 48;
      end
      else if (vcu_c_raddr == 256 * 48 + 256 * 4 - 2) begin
        vcu_c_raddr <= 0;
        write_done_flag <= 0;
      end
      else begin
        vcu_c_raddr <= vcu_c_raddr + 1;
      end
    end

    if (vcu_0_raddr == 256 * 48 + 256 * 4 - 1) begin
      $finish;
    end
  end
end

endmodule