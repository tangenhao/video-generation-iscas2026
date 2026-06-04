module ifmap_ram_tb();

parameter IFMAP_WIDTH      = 256;
parameter IFMAP_ADDR_BITS  = 13;
parameter BANK             = 16;

reg                        clk;
reg                        rst_n;
reg  [1:0]                 broadcast;
reg  [BANK-1:0]            broadcast_mask;
reg                        ifmap_0_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_0_raddr;
reg  [1:0]                 ifmap_0_rsparse;
reg                        ifmap_1_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_1_raddr;
reg  [1:0]                 ifmap_1_rsparse;
reg                        ifmap_2_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_2_raddr;
reg  [1:0]                 ifmap_2_rsparse;
reg                        ifmap_3_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_3_raddr;
reg  [1:0]                 ifmap_3_rsparse;
reg                        ifmap_4_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_4_raddr;
reg  [1:0]                 ifmap_4_rsparse;
reg                        ifmap_5_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_5_raddr;
reg  [1:0]                 ifmap_5_rsparse;
reg                        ifmap_6_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_6_raddr;
reg  [1:0]                 ifmap_6_rsparse;
reg                        ifmap_7_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_7_raddr;
reg  [1:0]                 ifmap_7_rsparse;
reg                        ifmap_8_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_8_raddr;
reg  [1:0]                 ifmap_8_rsparse;
reg                        ifmap_9_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_9_raddr;
reg  [1:0]                 ifmap_9_rsparse;
reg                        ifmap_a_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_a_raddr;
reg  [1:0]                 ifmap_a_rsparse;
reg                        ifmap_b_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_b_raddr;
reg  [1:0]                 ifmap_b_rsparse;
reg                        ifmap_c_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_c_raddr;
reg  [1:0]                 ifmap_c_rsparse;
reg                        ifmap_d_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_d_raddr;
reg  [1:0]                 ifmap_d_rsparse;
reg                        ifmap_e_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_e_raddr;
reg  [1:0]                 ifmap_e_rsparse;
reg                        ifmap_f_rvalid;
reg  [IFMAP_ADDR_BITS-1:0] ifmap_f_raddr;
reg  [1:0]                 ifmap_f_rsparse;
reg                        master_0_wvalid;
reg  [IFMAP_ADDR_BITS-1:0] master_0_waddr;
reg  [IFMAP_WIDTH-1:0]     master_0_wdata;
reg                        master_1_wvalid;
reg  [IFMAP_ADDR_BITS-1:0] master_1_waddr;
reg  [IFMAP_WIDTH-1:0]     master_1_wdata;
reg                        slave_wvalid;
reg  [IFMAP_ADDR_BITS-1:0] slave_waddr;
reg  [IFMAP_WIDTH-1:0]     slave_wdata;

wire [IFMAP_WIDTH*2-1:0] ifmap_0_rdata;
wire                     ifmap_0_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_1_rdata;
wire                     ifmap_1_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_2_rdata;
wire                     ifmap_2_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_3_rdata;
wire                     ifmap_3_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_4_rdata;
wire                     ifmap_4_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_5_rdata;
wire                     ifmap_5_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_6_rdata;
wire                     ifmap_6_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_7_rdata;
wire                     ifmap_7_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_8_rdata;
wire                     ifmap_8_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_9_rdata;
wire                     ifmap_9_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_a_rdata;
wire                     ifmap_a_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_b_rdata;
wire                     ifmap_b_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_c_rdata;
wire                     ifmap_c_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_d_rdata;
wire                     ifmap_d_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_e_rdata;
wire                     ifmap_e_rready;
wire [IFMAP_WIDTH*2-1:0] ifmap_f_rdata;
wire                     ifmap_f_rready;
wire                     master_0_wready;
wire                     master_1_wready;
wire                     slave_wready;


ifmap_ram u_ifmap_ram(
  .clk             ( clk             ),
  .rst_n           ( rst_n           ),
  .broadcast       ( broadcast       ),
  .broadcast_mask  ( broadcast_mask  ),
  .ifmap_0_rvalid  ( ifmap_0_rvalid  ),
  .ifmap_0_raddr   ( ifmap_0_raddr   ),
  .ifmap_0_rsparse ( ifmap_0_rsparse ),
  .ifmap_1_rvalid  ( ifmap_1_rvalid  ),
  .ifmap_1_raddr   ( ifmap_1_raddr   ),
  .ifmap_1_rsparse ( ifmap_1_rsparse ),
  .ifmap_2_rvalid  ( ifmap_2_rvalid  ),
  .ifmap_2_raddr   ( ifmap_2_raddr   ),
  .ifmap_2_rsparse ( ifmap_2_rsparse ),
  .ifmap_3_rvalid  ( ifmap_3_rvalid  ),
  .ifmap_3_raddr   ( ifmap_3_raddr   ),
  .ifmap_3_rsparse ( ifmap_3_rsparse ),
  .ifmap_4_rvalid  ( ifmap_4_rvalid  ),
  .ifmap_4_raddr   ( ifmap_4_raddr   ),
  .ifmap_4_rsparse ( ifmap_4_rsparse ),
  .ifmap_5_rvalid  ( ifmap_5_rvalid  ),
  .ifmap_5_raddr   ( ifmap_5_raddr   ),
  .ifmap_5_rsparse ( ifmap_5_rsparse ),
  .ifmap_6_rvalid  ( ifmap_6_rvalid  ),
  .ifmap_6_raddr   ( ifmap_6_raddr   ),
  .ifmap_6_rsparse ( ifmap_6_rsparse ),
  .ifmap_7_rvalid  ( ifmap_7_rvalid  ),
  .ifmap_7_raddr   ( ifmap_7_raddr   ),
  .ifmap_7_rsparse ( ifmap_7_rsparse ),
  .ifmap_8_rvalid  ( ifmap_8_rvalid  ),
  .ifmap_8_raddr   ( ifmap_8_raddr   ),
  .ifmap_8_rsparse ( ifmap_8_rsparse ),
  .ifmap_9_rvalid  ( ifmap_9_rvalid  ),
  .ifmap_9_raddr   ( ifmap_9_raddr   ),
  .ifmap_9_rsparse ( ifmap_9_rsparse ),
  .ifmap_a_rvalid  ( ifmap_a_rvalid  ),
  .ifmap_a_raddr   ( ifmap_a_raddr   ),
  .ifmap_a_rsparse ( ifmap_a_rsparse ),
  .ifmap_b_rvalid  ( ifmap_b_rvalid  ),
  .ifmap_b_raddr   ( ifmap_b_raddr   ),
  .ifmap_b_rsparse ( ifmap_b_rsparse ),
  .ifmap_c_rvalid  ( ifmap_c_rvalid  ),
  .ifmap_c_raddr   ( ifmap_c_raddr   ),
  .ifmap_c_rsparse ( ifmap_c_rsparse ),
  .ifmap_d_rvalid  ( ifmap_d_rvalid  ),
  .ifmap_d_raddr   ( ifmap_d_raddr   ),
  .ifmap_d_rsparse ( ifmap_d_rsparse ),
  .ifmap_e_rvalid  ( ifmap_e_rvalid  ),
  .ifmap_e_raddr   ( ifmap_e_raddr   ),
  .ifmap_e_rsparse ( ifmap_e_rsparse ),
  .ifmap_f_rvalid  ( ifmap_f_rvalid  ),
  .ifmap_f_raddr   ( ifmap_f_raddr   ),
  .ifmap_f_rsparse ( ifmap_f_rsparse ),
  .master_0_wvalid ( master_0_wvalid ),
  .master_0_waddr  ( master_0_waddr  ),
  .master_0_wdata  ( master_0_wdata  ),
  .master_1_wvalid ( master_1_wvalid ),
  .master_1_waddr  ( master_1_waddr  ),
  .master_1_wdata  ( master_1_wdata  ),
  .slave_wvalid    ( slave_wvalid    ),
  .slave_waddr     ( slave_waddr     ),
  .slave_wdata     ( slave_wdata     ),
  .ifmap_0_rdata   ( ifmap_0_rdata   ),
  .ifmap_0_rready  ( ifmap_0_rready  ),
  .ifmap_1_rdata   ( ifmap_1_rdata   ),
  .ifmap_1_rready  ( ifmap_1_rready  ),
  .ifmap_2_rdata   ( ifmap_2_rdata   ),
  .ifmap_2_rready  ( ifmap_2_rready  ),
  .ifmap_3_rdata   ( ifmap_3_rdata   ),
  .ifmap_3_rready  ( ifmap_3_rready  ),
  .ifmap_4_rdata   ( ifmap_4_rdata   ),
  .ifmap_4_rready  ( ifmap_4_rready  ),
  .ifmap_5_rdata   ( ifmap_5_rdata   ),
  .ifmap_5_rready  ( ifmap_5_rready  ),
  .ifmap_6_rdata   ( ifmap_6_rdata   ),
  .ifmap_6_rready  ( ifmap_6_rready  ),
  .ifmap_7_rdata   ( ifmap_7_rdata   ),
  .ifmap_7_rready  ( ifmap_7_rready  ),
  .ifmap_8_rdata   ( ifmap_8_rdata   ),
  .ifmap_8_rready  ( ifmap_8_rready  ),
  .ifmap_9_rdata   ( ifmap_9_rdata   ),
  .ifmap_9_rready  ( ifmap_9_rready  ),
  .ifmap_a_rdata   ( ifmap_a_rdata   ),
  .ifmap_a_rready  ( ifmap_a_rready  ),
  .ifmap_b_rdata   ( ifmap_b_rdata   ),
  .ifmap_b_rready  ( ifmap_b_rready  ),
  .ifmap_c_rdata   ( ifmap_c_rdata   ),
  .ifmap_c_rready  ( ifmap_c_rready  ),
  .ifmap_d_rdata   ( ifmap_d_rdata   ),
  .ifmap_d_rready  ( ifmap_d_rready  ),
  .ifmap_e_rdata   ( ifmap_e_rdata   ),
  .ifmap_e_rready  ( ifmap_e_rready  ),
  .ifmap_f_rdata   ( ifmap_f_rdata   ),
  .ifmap_f_rready  ( ifmap_f_rready  ),
  .master_0_wready ( master_0_wready ),
  .master_1_wready ( master_1_wready ),
  .slave_wready    ( slave_wready    )
);

initial begin
  $fsdbDumpfile("ifmap_ram_tb.fsdb");
  $fsdbDumpvars(0, "ifmap_ram_tb");
  $fsdbDumpMDA();
end

initial begin
  clk = 0;
  rst_n = 0;
  broadcast = 0;
  broadcast_mask = 0;
  ifmap_0_rvalid = 0;
  ifmap_0_raddr = 0;
  ifmap_0_rsparse = 0;
  ifmap_1_rvalid = 0;
  ifmap_1_raddr = 0;
  ifmap_1_rsparse = 0;
  ifmap_2_rvalid = 0;
  ifmap_2_raddr = 0;
  ifmap_2_rsparse = 0;
  ifmap_3_rvalid = 0;
  ifmap_3_raddr = 0;
  ifmap_3_rsparse = 0;
  ifmap_4_rvalid = 0;
  ifmap_4_raddr = 0;
  ifmap_4_rsparse = 0;
  ifmap_5_rvalid = 0;
  ifmap_5_raddr = 0;
  ifmap_5_rsparse = 0;
  ifmap_6_rvalid = 0;
  ifmap_6_raddr = 0;
  ifmap_6_rsparse = 0;
  ifmap_7_rvalid = 0;
  ifmap_7_raddr = 0;
  ifmap_7_rsparse = 0;
  ifmap_8_rvalid = 0;
  ifmap_8_raddr = 0;
  ifmap_8_rsparse = 0;
  ifmap_9_rvalid = 0;
  ifmap_9_raddr = 0;
  ifmap_9_rsparse = 0;
  ifmap_a_rvalid = 0;
  ifmap_a_raddr = 0;
  ifmap_a_rsparse = 0;
  ifmap_b_rvalid = 0;
  ifmap_b_raddr = 0;
  ifmap_b_rsparse = 0;
  ifmap_c_rvalid = 0;
  ifmap_c_raddr = 0;
  ifmap_c_rsparse = 0;
  ifmap_d_rvalid = 0;
  ifmap_d_raddr = 0;
  ifmap_d_rsparse = 0;
  ifmap_e_rvalid = 0;
  ifmap_e_raddr = 0;
  ifmap_e_rsparse = 0;
  ifmap_f_rvalid = 0;
  ifmap_f_raddr = 0;
  ifmap_f_rsparse = 0;
  master_0_wvalid = 0;
  master_0_waddr = 0;
  master_0_wdata = 0;
  master_1_wvalid = 0;
  master_1_waddr = 0;
  master_1_wdata = 0;
  slave_wvalid = 0;
  slave_waddr = 0;
  slave_wdata = 0;

  #10 rst_n = 1;
end

always #5 clk = ~clk;

/* -------------------------------------------------------------------------------------------------------- */
/*                                              master 0 write                                              */
/* -------------------------------------------------------------------------------------------------------- */

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_0_wvalid = 0;
//     master_0_waddr = 0;
//     master_0_wdata = 0;
//   end 
//   else begin
//     master_0_wvalid = 1;
//     master_0_waddr = master_0_waddr + 1;
//     master_0_wdata = master_0_wdata + 1;

//     if (master_0_waddr == 256 * 2 * 16 - 1) begin
//       $display("master 0 write done");
//       master_0_wvalid = 0;

//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                              master 1 write                                              */
/* -------------------------------------------------------------------------------------------------------- */

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_1_wvalid = 0;
//     master_1_waddr = 0;
//     master_1_wdata = 0;
//   end 
//   else begin
//     master_1_wvalid = 1;
//     master_1_waddr = master_1_waddr + 1;
//     master_1_wdata = master_1_wdata + 1;

//     if (master_1_waddr == 256 * 2 * 16 - 1) begin
//       $display("master 1 write done");
//       master_1_wvalid = 0;

//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                             master 0 1 write                                             */
/* -------------------------------------------------------------------------------------------------------- */

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_1_wvalid = 0;
//     master_1_waddr = 256 * 8;
//     master_1_wdata = 0;
//     master_0_wvalid = 0;
//     master_0_waddr = 0;
//     master_0_wdata = 0;
//   end 
//   else begin
//     master_1_wvalid = 1;
//     master_1_waddr = master_1_waddr + 1;
//     master_1_wdata = master_1_wdata + 1;
//     master_0_wvalid = 1;
//     master_0_waddr = master_0_waddr + 1;
//     master_0_wdata = master_0_wdata + 1;

//     if (master_0_waddr == 256 * 8 - 1) begin
//       master_0_wvalid = 0;
//       master_1_wvalid = 0;
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        master 0 write core 0 read                                        */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_0_wvalid = 0;
//     master_0_waddr = 0;
//     master_0_wdata = 0;
//     ifmap_0_rvalid = 0;
//     ifmap_0_raddr = 0;
//     ifmap_0_rsparse = 0;
//     write_done_flag = 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_0_wvalid = 1;
//       if (master_0_waddr == 256 * 4 - 1) begin
//         master_0_waddr = 256 * 16;
//       end
//       else begin
//         master_0_waddr = master_0_waddr + 1;
//       end
//       master_0_wdata = master_0_wdata + 1;
//     end
//     else begin
//       master_0_wvalid = 0;
//       master_0_waddr = 0;
//       master_0_wdata = 0;
//     end

//     if (master_0_waddr == 256 * 16 + 256 * 4 - 1) begin
//       write_done_flag = 1;
//     end

//     if (write_done_flag) begin
//       ifmap_0_rvalid = 1;
//       if (ifmap_0_raddr == 256 * 4 - 1) begin
//         ifmap_0_raddr = 256 * 16;
//       end
//       else begin
//         ifmap_0_raddr = ifmap_0_raddr + 1;
//       end
//       ifmap_0_rsparse = 0;
//     end

//     if (ifmap_0_raddr == 256 * 16 + 256 * 4 - 1) begin
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        master 0 write core 4 read                                        */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_0_wvalid <= 0;
//     master_0_waddr <= 256 * 4 - 1;
//     master_0_wdata <= -1;
//     ifmap_4_rvalid <= 0;
//     ifmap_4_raddr <= 256 * 4 - 1;
//     ifmap_4_rsparse <= 0;
//     write_done_flag <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_0_wvalid = 1;
//       if (master_0_waddr == 256 * 8 - 1) begin
//         master_0_waddr <= 256 * 16 + 256 * 4;
//       end
//       else begin
//         master_0_waddr <= master_0_waddr + 1;
//       end
//       master_0_wdata <= master_0_wdata + 1;
//     end
//     else begin
//       master_0_wvalid <= 0;
//       master_0_waddr <= 0;
//       master_0_wdata <= 0;
//     end

//     if (master_0_waddr == 256 * 16 + 256 * 8 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       ifmap_4_rvalid <= 1;
//       if (ifmap_4_raddr == 256 * 8 - 1) begin
//         ifmap_4_raddr <= 256 * 16 + 256 * 4;
//       end
//       else begin
//         ifmap_4_raddr <= ifmap_4_raddr + 1;
//       end
//       ifmap_4_rsparse <= 0;
//     end

//     if (ifmap_4_raddr == 256 * 16 + 256 * 8 - 1) begin
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        master 0 write core 8 read                                        */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_0_wvalid <= 0;
//     master_0_waddr <= 256 * 8 - 1;
//     master_0_wdata <= -1;
//     ifmap_8_rvalid <= 0;
//     ifmap_8_raddr <= 256 * 8 - 1;
//     ifmap_8_rsparse <= 0;
//     write_done_flag <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_0_wvalid = 1;
//       if (master_0_waddr == 256 * 12 - 1) begin
//         master_0_waddr <= 256 * 16 + 256 * 8;
//       end
//       else begin
//         master_0_waddr <= master_0_waddr + 1;
//       end
//       master_0_wdata <= master_0_wdata + 1;
//     end
//     else begin
//       master_0_wvalid <= 0;
//       master_0_waddr <= 0;
//       master_0_wdata <= 0;
//     end

//     if (master_0_waddr == 256 * 16 + 256 * 12 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       ifmap_8_rvalid <= 1;
//       if (ifmap_8_raddr == 256 * 12 - 1) begin
//         ifmap_8_raddr <= 256 * 16 + 256 * 8;
//       end
//       else begin
//         ifmap_8_raddr <= ifmap_8_raddr + 1;
//       end
//       ifmap_8_rsparse <= 0;
//     end

//     if (ifmap_8_raddr == 256 * 16 + 256 * 12 - 1) begin
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        master 0 write core 12 read                                       */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_0_wvalid <= 0;
//     master_0_waddr <= 256 * 12 - 1;
//     master_0_wdata <= -1;
//     ifmap_c_rvalid <= 0;
//     ifmap_c_raddr <= 256 * 12 - 1;
//     ifmap_c_rsparse <= 0;
//     write_done_flag <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_0_wvalid = 1;
//       if (master_0_waddr == 256 * 16 - 1) begin
//         master_0_waddr <= 256 * 16 + 256 * 12;
//       end
//       else begin
//         master_0_waddr <= master_0_waddr + 1;
//       end
//       master_0_wdata <= master_0_wdata + 1;
//     end
//     else begin
//       master_0_wvalid <= 0;
//       master_0_waddr <= 0;
//       master_0_wdata <= 0;
//     end

//     if (master_0_waddr == 256 * 16 + 256 * 16 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       ifmap_c_rvalid <= 1;
//       if (ifmap_c_raddr == 256 * 16 - 1) begin
//         ifmap_c_raddr <= 256 * 16 + 256 * 12;
//       end
//       else begin
//         ifmap_c_raddr <= ifmap_c_raddr + 1;
//       end
//       ifmap_c_rsparse <= 0;
//     end

//     if (ifmap_c_raddr == 256 * 16 + 256 * 16 - 1) begin
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                   master 1 write simple multi core read                                  */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_1_wvalid <= 0;
//     master_1_waddr <= -1;
//     master_1_wdata <= -1;
//     write_done_flag <= 0;
//     ifmap_0_rvalid  <= 0;
//     ifmap_0_raddr   <= -1;
//     ifmap_0_rsparse <= 0;
//     ifmap_1_rvalid  <= 0;
//     ifmap_1_raddr   <= 256 - 1;
//     ifmap_1_rsparse <= 0;
//     ifmap_2_rvalid  <= 0;
//     ifmap_2_raddr   <= 256 * 2 - 1;
//     ifmap_2_rsparse <= 0;
//     ifmap_3_rvalid  <= 0;
//     ifmap_3_raddr   <= 256 * 3 - 1;
//     ifmap_3_rsparse <= 0;
//     ifmap_4_rvalid  <= 0;
//     ifmap_4_raddr   <= 256 * 4 - 1;
//     ifmap_4_rsparse <= 0;
//     ifmap_5_rvalid  <= 0;
//     ifmap_5_raddr   <= 256 * 5 - 1;
//     ifmap_5_rsparse <= 0;
//     ifmap_6_rvalid  <= 0;
//     ifmap_6_raddr   <= 256 * 6 - 1;
//     ifmap_6_rsparse <= 0;
//     ifmap_7_rvalid  <= 0;
//     ifmap_7_raddr   <= 256 * 7 - 1;
//     ifmap_7_rsparse <= 0;
//     ifmap_8_rvalid  <= 0;
//     ifmap_8_raddr   <= 256 * 8 - 1;
//     ifmap_8_rsparse <= 0;
//     ifmap_9_rvalid  <= 0;
//     ifmap_9_raddr   <= 256 * 9 - 1;
//     ifmap_9_rsparse <= 0;
//     ifmap_a_rvalid  <= 0;
//     ifmap_a_raddr   <= 256 * 10 - 1;
//     ifmap_a_rsparse <= 0;
//     ifmap_b_rvalid  <= 0;
//     ifmap_b_raddr   <= 256 * 11 - 1;
//     ifmap_b_rsparse <= 0;
//     ifmap_c_rvalid  <= 0;
//     ifmap_c_raddr   <= 256 * 12 - 1;
//     ifmap_c_rsparse <= 0;
//     ifmap_d_rvalid  <= 0;
//     ifmap_d_raddr   <= 256 * 13 - 1;
//     ifmap_d_rsparse <= 0;
//     ifmap_e_rvalid  <= 0;
//     ifmap_e_raddr   <= 256 * 14 - 1;
//     ifmap_e_rsparse <= 0;
//     ifmap_f_rvalid  <= 0;
//     ifmap_f_raddr   <= 256 * 15 - 1;
//     ifmap_f_rsparse <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_1_wvalid = 1;
//       master_1_waddr <= master_1_waddr + 1;
//       master_1_wdata <= master_1_wdata + 1;
//     end
//     else begin
//       master_1_wvalid <= 0;
//       master_1_waddr <= 0;
//       master_1_wdata <= 0;
//     end

//     if (master_1_waddr == 256 * 16 * 2 - 2) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       ifmap_0_rvalid <= 1;
//       if (ifmap_0_raddr == 256 - 1) begin
//         ifmap_0_raddr <= 256 * 16;
//       end
//       else begin
//         ifmap_0_raddr <= ifmap_0_raddr + 1;
//       end
//       ifmap_0_rsparse <= 0;

//       ifmap_1_rvalid <= 1;
//       if (ifmap_1_raddr == 256 * 2 - 1) begin
//         ifmap_1_raddr <= 256 * 16 + 256;
//       end
//       else begin
//         ifmap_1_raddr <= ifmap_1_raddr + 1;
//       end
//       ifmap_1_rsparse <= 0;

//       ifmap_2_rvalid <= 1;
//       if (ifmap_2_raddr == 256 * 3 - 1) begin
//         ifmap_2_raddr <= 256 * 16 + 256 * 2;
//       end
//       else begin
//         ifmap_2_raddr <= ifmap_2_raddr + 1;
//       end
//       ifmap_2_rsparse <= 0;

//       ifmap_3_rvalid <= 1;
//       if (ifmap_3_raddr == 256 * 4 - 1) begin
//         ifmap_3_raddr <= 256 * 16 + 256 * 3;
//       end
//       else begin
//         ifmap_3_raddr <= ifmap_3_raddr + 1;
//       end
//       ifmap_3_rsparse <= 0;

//       ifmap_4_rvalid <= 1;
//       if (ifmap_4_raddr == 256 * 5 - 1) begin
//         ifmap_4_raddr <= 256 * 16 + 256 * 4;
//       end
//       else begin
//         ifmap_4_raddr <= ifmap_4_raddr + 1;
//       end
//       ifmap_4_rsparse <= 0;

//       ifmap_5_rvalid <= 1;
//       if (ifmap_5_raddr == 256 * 6 - 1) begin
//         ifmap_5_raddr <= 256 * 16 + 256 * 5;
//       end
//       else begin
//         ifmap_5_raddr <= ifmap_5_raddr + 1;
//       end
//       ifmap_5_rsparse <= 0;

//       ifmap_6_rvalid <= 1;
//       if (ifmap_6_raddr == 256 * 7 - 1) begin
//         ifmap_6_raddr <= 256 * 16 + 256 * 6;
//       end
//       else begin
//         ifmap_6_raddr <= ifmap_6_raddr + 1;
//       end
//       ifmap_6_rsparse <= 0;

//       ifmap_7_rvalid <= 1;
//       if (ifmap_7_raddr == 256 * 8 - 1) begin
//         ifmap_7_raddr <= 256 * 16 + 256 * 7;
//       end
//       else begin
//         ifmap_7_raddr <= ifmap_7_raddr + 1;
//       end
//       ifmap_7_rsparse <= 0;

//       ifmap_8_rvalid <= 1;
//       if (ifmap_8_raddr == 256 * 9 - 1) begin
//         ifmap_8_raddr <= 256 * 16 + 256 * 8;
//       end
//       else begin
//         ifmap_8_raddr <= ifmap_8_raddr + 1;
//       end
//       ifmap_8_rsparse <= 0;

//       ifmap_9_rvalid <= 1;
//       if (ifmap_9_raddr == 256 * 10 - 1) begin
//         ifmap_9_raddr <= 256 * 16 + 256 * 9;
//       end
//       else begin
//         ifmap_9_raddr <= ifmap_9_raddr + 1;
//       end
//       ifmap_9_rsparse <= 0;

//       ifmap_a_rvalid <= 1;
//       if (ifmap_a_raddr == 256 * 11 - 1) begin
//         ifmap_a_raddr <= 256 * 16 + 256 * 10;
//       end
//       else begin
//         ifmap_a_raddr <= ifmap_a_raddr + 1;
//       end
//       ifmap_a_rsparse <= 0;

//       ifmap_b_rvalid <= 1;
//       if (ifmap_b_raddr == 256 * 12 - 1) begin
//         ifmap_b_raddr <= 256 * 16 + 256 * 11;
//       end
//       else begin
//         ifmap_b_raddr <= ifmap_b_raddr + 1;
//       end
//       ifmap_b_rsparse <= 0;

//       ifmap_c_rvalid <= 1;
//       if (ifmap_c_raddr == 256 * 13 - 1) begin
//         ifmap_c_raddr <= 256 * 16 + 256 * 12;
//       end
//       else begin
//         ifmap_c_raddr <= ifmap_c_raddr + 1;
//       end
//       ifmap_c_rsparse <= 0;

//       ifmap_d_rvalid <= 1;
//       if (ifmap_d_raddr == 256 * 14 - 1) begin
//         ifmap_d_raddr <= 256 * 16 + 256 * 13;
//       end
//       else begin
//         ifmap_d_raddr <= ifmap_d_raddr + 1;
//       end
//       ifmap_d_rsparse <= 0;

//       ifmap_e_rvalid <= 1;
//       if (ifmap_e_raddr == 256 * 15 - 1) begin
//         ifmap_e_raddr <= 256 * 16 + 256 * 14;
//       end
//       else begin
//         ifmap_e_raddr <= ifmap_e_raddr + 1;
//       end
//       ifmap_e_rsparse <= 0;

//       ifmap_f_rvalid <= 1;
//       if (ifmap_f_raddr == 256 * 16 - 1) begin
//         ifmap_f_raddr <= 256 * 16 + 256 * 15;
//       end
//       else begin
//         ifmap_f_raddr <= ifmap_f_raddr + 1;
//       end

//       if (ifmap_f_raddr == 256 * 16 + 256 * 16 - 1) begin
//         $finish;
//       end

//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                 master 1 write broadcast multi-core read                                 */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_1_wvalid <= 0;
//     master_1_waddr <= -1;
//     master_1_wdata <= -1;
//     broadcast <= 1;
//     broadcast_mask <= 'h0ff0;
//     write_done_flag <= 0;
//     ifmap_0_rvalid  <= 0;
//     ifmap_0_raddr   <= -1;
//     ifmap_0_rsparse <= 0;
//     ifmap_1_rvalid  <= 0;
//     ifmap_1_raddr   <= 256 - 1;
//     ifmap_1_rsparse <= 0;
//     ifmap_2_rvalid  <= 0;
//     ifmap_2_raddr   <= 256 * 2 - 1;
//     ifmap_2_rsparse <= 0;
//     ifmap_3_rvalid  <= 0;
//     ifmap_3_raddr   <= 256 * 3 - 1;
//     ifmap_3_rsparse <= 0;
//     ifmap_4_rvalid  <= 0;
//     ifmap_4_raddr   <= 256 * 4 - 1;
//     ifmap_4_rsparse <= 0;
//     ifmap_5_rvalid  <= 0;
//     ifmap_5_raddr   <= 256 * 5 - 1;
//     ifmap_5_rsparse <= 0;
//     ifmap_6_rvalid  <= 0;
//     ifmap_6_raddr   <= 256 * 6 - 1;
//     ifmap_6_rsparse <= 0;
//     ifmap_7_rvalid  <= 0;
//     ifmap_7_raddr   <= 256 * 7 - 1;
//     ifmap_7_rsparse <= 0;
//     ifmap_8_rvalid  <= 0;
//     ifmap_8_raddr   <= 256 * 8 - 1;
//     ifmap_8_rsparse <= 0;
//     ifmap_9_rvalid  <= 0;
//     ifmap_9_raddr   <= 256 * 9 - 1;
//     ifmap_9_rsparse <= 0;
//     ifmap_a_rvalid  <= 0;
//     ifmap_a_raddr   <= 256 * 10 - 1;
//     ifmap_a_rsparse <= 0;
//     ifmap_b_rvalid  <= 0;
//     ifmap_b_raddr   <= 256 * 11 - 1;
//     ifmap_b_rsparse <= 0;
//     ifmap_c_rvalid  <= 0;
//     ifmap_c_raddr   <= 256 * 12 - 1;
//     ifmap_c_rsparse <= 0;
//     ifmap_d_rvalid  <= 0;
//     ifmap_d_raddr   <= 256 * 13 - 1;
//     ifmap_d_rsparse <= 0;
//     ifmap_e_rvalid  <= 0;
//     ifmap_e_raddr   <= 256 * 14 - 1;
//     ifmap_e_rsparse <= 0;
//     ifmap_f_rvalid  <= 0;
//     ifmap_f_raddr   <= 256 * 15 - 1;
//     ifmap_f_rsparse <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_1_wvalid = 1;
//       if (master_1_waddr == 256 - 1) begin
//         master_1_waddr <= 256 * 16;
//       end
//       else begin
//         master_1_waddr <= master_1_waddr + 1;
//       end
//       master_1_wdata <= master_1_wdata + 1;
//     end
//     else begin
//       master_1_wvalid <= 0;
//       master_1_waddr <= 0;
//       master_1_wdata <= 0;
//     end

//     if (master_1_waddr == 256 * 16 + 256 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       ifmap_0_rvalid <= 1;
//       if (ifmap_0_raddr == 256 - 1) begin
//         ifmap_0_raddr <= 256 * 16;
//       end
//       else begin
//         ifmap_0_raddr <= ifmap_0_raddr + 1;
//       end
//       ifmap_0_rsparse <= 0;

//       ifmap_1_rvalid <= 1;
//       if (ifmap_1_raddr == 256 * 2 - 1) begin
//         ifmap_1_raddr <= 256 * 16 + 256;
//       end
//       else begin
//         ifmap_1_raddr <= ifmap_1_raddr + 1;
//       end
//       ifmap_1_rsparse <= 0;

//       ifmap_2_rvalid <= 1;
//       if (ifmap_2_raddr == 256 * 3 - 1) begin
//         ifmap_2_raddr <= 256 * 16 + 256 * 2;
//       end
//       else begin
//         ifmap_2_raddr <= ifmap_2_raddr + 1;
//       end
//       ifmap_2_rsparse <= 0;

//       ifmap_3_rvalid <= 1;
//       if (ifmap_3_raddr == 256 * 4 - 1) begin
//         ifmap_3_raddr <= 256 * 16 + 256 * 3;
//       end
//       else begin
//         ifmap_3_raddr <= ifmap_3_raddr + 1;
//       end
//       ifmap_3_rsparse <= 0;

//       ifmap_4_rvalid <= 1;
//       if (ifmap_4_raddr == 256 * 5 - 1) begin
//         ifmap_4_raddr <= 256 * 16 + 256 * 4;
//       end
//       else begin
//         ifmap_4_raddr <= ifmap_4_raddr + 1;
//       end
//       ifmap_4_rsparse <= 0;

//       ifmap_5_rvalid <= 1;
//       if (ifmap_5_raddr == 256 * 6 - 1) begin
//         ifmap_5_raddr <= 256 * 16 + 256 * 5;
//       end
//       else begin
//         ifmap_5_raddr <= ifmap_5_raddr + 1;
//       end
//       ifmap_5_rsparse <= 0;

//       ifmap_6_rvalid <= 1;
//       if (ifmap_6_raddr == 256 * 7 - 1) begin
//         ifmap_6_raddr <= 256 * 16 + 256 * 6;
//       end
//       else begin
//         ifmap_6_raddr <= ifmap_6_raddr + 1;
//       end
//       ifmap_6_rsparse <= 0;

//       ifmap_7_rvalid <= 1;
//       if (ifmap_7_raddr == 256 * 8 - 1) begin
//         ifmap_7_raddr <= 256 * 16 + 256 * 7;
//       end
//       else begin
//         ifmap_7_raddr <= ifmap_7_raddr + 1;
//       end
//       ifmap_7_rsparse <= 0;

//       ifmap_8_rvalid <= 1;
//       if (ifmap_8_raddr == 256 * 9 - 1) begin
//         ifmap_8_raddr <= 256 * 16 + 256 * 8;
//       end
//       else begin
//         ifmap_8_raddr <= ifmap_8_raddr + 1;
//       end
//       ifmap_8_rsparse <= 0;

//       ifmap_9_rvalid <= 1;
//       if (ifmap_9_raddr == 256 * 10 - 1) begin
//         ifmap_9_raddr <= 256 * 16 + 256 * 9;
//       end
//       else begin
//         ifmap_9_raddr <= ifmap_9_raddr + 1;
//       end
//       ifmap_9_rsparse <= 0;

//       ifmap_a_rvalid <= 1;
//       if (ifmap_a_raddr == 256 * 11 - 1) begin
//         ifmap_a_raddr <= 256 * 16 + 256 * 10;
//       end
//       else begin
//         ifmap_a_raddr <= ifmap_a_raddr + 1;
//       end
//       ifmap_a_rsparse <= 0;

//       ifmap_b_rvalid <= 1;
//       if (ifmap_b_raddr == 256 * 12 - 1) begin
//         ifmap_b_raddr <= 256 * 16 + 256 * 11;
//       end
//       else begin
//         ifmap_b_raddr <= ifmap_b_raddr + 1;
//       end
//       ifmap_b_rsparse <= 0;

//       ifmap_c_rvalid <= 1;
//       if (ifmap_c_raddr == 256 * 13 - 1) begin
//         ifmap_c_raddr <= 256 * 16 + 256 * 12;
//       end
//       else begin
//         ifmap_c_raddr <= ifmap_c_raddr + 1;
//       end
//       ifmap_c_rsparse <= 0;

//       ifmap_d_rvalid <= 1;
//       if (ifmap_d_raddr == 256 * 14 - 1) begin
//         ifmap_d_raddr <= 256 * 16 + 256 * 13;
//       end
//       else begin
//         ifmap_d_raddr <= ifmap_d_raddr + 1;
//       end
//       ifmap_d_rsparse <= 0;

//       ifmap_e_rvalid <= 1;
//       if (ifmap_e_raddr == 256 * 15 - 1) begin
//         ifmap_e_raddr <= 256 * 16 + 256 * 14;
//       end
//       else begin
//         ifmap_e_raddr <= ifmap_e_raddr + 1;
//       end
//       ifmap_e_rsparse <= 0;

//       ifmap_f_rvalid <= 1;
//       if (ifmap_f_raddr == 256 * 16 - 1) begin
//         ifmap_f_raddr <= 256 * 16 + 256 * 15;
//       end
//       else begin
//         ifmap_f_raddr <= ifmap_f_raddr + 1;
//       end

//       if (ifmap_f_raddr == 256 * 16 + 256 * 16 - 1) begin
//         $finish;
//       end

//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                 slave cross broadcast multi-core read                                 */
/* -------------------------------------------------------------------------------------------------------- */

// reg write_done_flag;

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     slave_wvalid <= 0;
//     slave_waddr <= -1;
//     slave_wdata <= -1;
//     broadcast <= 2;
//     broadcast_mask <= 'h6;
//     write_done_flag <= 0;
//     ifmap_0_rvalid  <= 0;
//     ifmap_0_raddr   <= -1;
//     ifmap_0_rsparse <= 0;
//     ifmap_4_rvalid  <= 0;
//     ifmap_4_raddr   <= 256 * 4 - 1;
//     ifmap_4_rsparse <= 0;
//     ifmap_8_rvalid  <= 0;
//     ifmap_8_raddr   <= 256 * 8 - 1;
//     ifmap_8_rsparse <= 0;
//     ifmap_c_rvalid  <= 0;
//     ifmap_c_raddr   <= 256 * 12 - 1;
//     ifmap_c_rsparse <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       slave_wvalid = 1;
//       if (slave_waddr == 256 * 4 - 1) begin
//         slave_waddr <= 256 * 16;
//       end
//       else begin
//         slave_waddr <= slave_waddr + 1;
//       end
//       slave_wdata <= slave_wdata + 1;
//     end
//     else begin
//       slave_wvalid <= 0;
//       slave_waddr <= 0;
//       slave_wdata <= 0;
//     end

//     if (slave_waddr == 256 * 16 + 256 * 4 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       ifmap_0_rvalid <= 1;
//       if (ifmap_0_raddr == 256 * 4 - 1) begin
//         ifmap_0_raddr <= 256 * 16;
//       end
//       else begin
//         ifmap_0_raddr <= ifmap_0_raddr + 1;
//       end
//       ifmap_0_rsparse <= 0;

//       ifmap_4_rvalid <= 1;
//       if (ifmap_4_raddr == 256 * 8 - 1) begin
//         ifmap_4_raddr <= 256 * 16 + 256 * 4;
//       end
//       else begin
//         ifmap_4_raddr <= ifmap_4_raddr + 1;
//       end
//       ifmap_4_rsparse <= 0;

//       ifmap_8_rvalid <= 1;
//       if (ifmap_8_raddr == 256 * 12 - 1) begin
//         ifmap_8_raddr <= 256 * 16 + 256 * 8;
//       end
//       else begin
//         ifmap_8_raddr <= ifmap_8_raddr + 1;
//       end
//       ifmap_8_rsparse <= 0;

//       ifmap_c_rvalid <= 1;
//       if (ifmap_c_raddr == 256 * 16 - 1) begin
//         ifmap_c_raddr <= 256 * 16 + 256 * 12;
//       end
//       else begin
//         ifmap_c_raddr <= ifmap_c_raddr + 1;
//       end
//       ifmap_c_rsparse <= 0;

//       if (ifmap_c_raddr == 256 * 16 + 256 * 16 - 1) begin
//         $finish;
//       end

//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                     master 0 write core 0 read sparse                                    */
/* -------------------------------------------------------------------------------------------------------- */

reg write_done_flag;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    master_0_wvalid <= 0;
    master_0_waddr <= -1;
    master_0_wdata <= -1;
    write_done_flag <= 0;
    ifmap_0_rvalid  <= 0;
    ifmap_0_raddr   <= -1;
    ifmap_0_rsparse <= 1;
  end
  else begin
    if (!write_done_flag) begin
      master_0_wvalid = 1;
      if (master_0_waddr == 256 * 4 - 1) begin
        master_0_waddr <= 256 * 16;
      end
      else begin
        master_0_waddr <= master_0_waddr + 1;
      end
      master_0_wdata <= master_0_wdata + 1;
    end
    else begin
      master_0_wvalid <= 0;
      master_0_waddr <= 0;
      master_0_wdata <= 0;
    end

    if (master_0_waddr == 256 * 16 + 256 * 4 - 1) begin
      write_done_flag <= 1;
    end

    if (write_done_flag) begin
      ifmap_0_rvalid <= 1;
      if (ifmap_0_raddr == 256 * 2 - 1) begin
        ifmap_0_raddr <= 256 * 16;
      end
      else begin
        ifmap_0_raddr <= ifmap_0_raddr + 1;
      end
      ifmap_0_rsparse <= 1;

      if (ifmap_0_raddr == 256 * 16 + 256 * 2 - 1) begin
        $finish;
      end

    end
  end
end

endmodule