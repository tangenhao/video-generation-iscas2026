module vcures_ram_tb();

parameter VCURES_WIDTH      = 1024;
parameter VCURES_ADDR_BITS  = 13;
parameter BANK              = 16;

reg                         clk;
reg                         rst_n;
reg                         broadcast;
reg  [BANK-1:0]             broadcast_mask;
reg                         vcures_0_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_0_raddr;
reg                         vcures_1_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_1_raddr;
reg                         vcures_2_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_2_raddr;
reg                         vcures_3_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_3_raddr;
reg                         vcures_4_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_4_raddr;
reg                         vcures_5_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_5_raddr;
reg                         vcures_6_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_6_raddr;
reg                         vcures_7_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_7_raddr;
reg                         vcures_8_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_8_raddr;
reg                         vcures_9_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_9_raddr;
reg                         vcures_a_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_a_raddr;
reg                         vcures_b_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_b_raddr;
reg                         vcures_c_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_c_raddr;
reg                         vcures_d_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_d_raddr;
reg                         vcures_e_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_e_raddr;
reg                         vcures_f_rvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_f_raddr;
reg                         vcures_0_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_0_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_0_wdata;
reg                         vcures_1_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_1_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_1_wdata;
reg                         vcures_2_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_2_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_2_wdata;
reg                         vcures_3_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_3_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_3_wdata;
reg                         vcures_4_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_4_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_4_wdata;
reg                         vcures_5_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_5_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_5_wdata;
reg                         vcures_6_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_6_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_6_wdata;
reg                         vcures_7_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_7_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_7_wdata;
reg                         vcures_8_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_8_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_8_wdata;
reg                         vcures_9_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_9_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_9_wdata;
reg                         vcures_a_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_a_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_a_wdata;
reg                         vcures_b_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_b_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_b_wdata;
reg                         vcures_c_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_c_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_c_wdata;
reg                         vcures_d_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_d_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_d_wdata;
reg                         vcures_e_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_e_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_e_wdata;
reg                         vcures_f_wvalid;
reg  [VCURES_ADDR_BITS-1:0] vcures_f_waddr;
reg  [VCURES_WIDTH-1:0]     vcures_f_wdata;
reg                         master_0_wvalid;
reg  [VCURES_ADDR_BITS-1:0] master_0_waddr;
reg  [VCURES_WIDTH-1:0]     master_0_wdata;
reg                         master_1_wvalid;
reg  [VCURES_ADDR_BITS-1:0] master_1_waddr;
reg  [VCURES_WIDTH-1:0]     master_1_wdata;
reg                         slave_wvalid;
reg  [VCURES_ADDR_BITS-1:0] slave_waddr;
reg  [VCURES_WIDTH-1:0]     slave_wdata;

wire [VCURES_WIDTH-1:0] vcures_0_rdata;
wire                    vcures_0_rready;
wire [VCURES_WIDTH-1:0] vcures_1_rdata;
wire                    vcures_1_rready;
wire [VCURES_WIDTH-1:0] vcures_2_rdata;
wire                    vcures_2_rready;
wire [VCURES_WIDTH-1:0] vcures_3_rdata;
wire                    vcures_3_rready;
wire [VCURES_WIDTH-1:0] vcures_4_rdata;
wire                    vcures_4_rready;
wire [VCURES_WIDTH-1:0] vcures_5_rdata;
wire                    vcures_5_rready;
wire [VCURES_WIDTH-1:0] vcures_6_rdata;
wire                    vcures_6_rready;
wire [VCURES_WIDTH-1:0] vcures_7_rdata;
wire                    vcures_7_rready;
wire [VCURES_WIDTH-1:0] vcures_8_rdata;
wire                    vcures_8_rready;
wire [VCURES_WIDTH-1:0] vcures_9_rdata;
wire                    vcures_9_rready;
wire [VCURES_WIDTH-1:0] vcures_a_rdata;
wire                    vcures_a_rready;
wire [VCURES_WIDTH-1:0] vcures_b_rdata;
wire                    vcures_b_rready;
wire [VCURES_WIDTH-1:0] vcures_c_rdata;
wire                    vcures_c_rready;
wire [VCURES_WIDTH-1:0] vcures_d_rdata;
wire                    vcures_d_rready;
wire [VCURES_WIDTH-1:0] vcures_e_rdata;
wire                    vcures_e_rready;
wire [VCURES_WIDTH-1:0] vcures_f_rdata;
wire                    vcures_f_rready;
wire                    vcures_0_wready;
wire                    vcures_1_wready;
wire                    vcures_2_wready;
wire                    vcures_3_wready;
wire                    vcures_4_wready;
wire                    vcures_5_wready;
wire                    vcures_6_wready;
wire                    vcures_7_wready;
wire                    vcures_8_wready;
wire                    vcures_9_wready;
wire                    vcures_a_wready;
wire                    vcures_b_wready;
wire                    vcures_c_wready;
wire                    vcures_d_wready;
wire                    vcures_e_wready;
wire                    vcures_f_wready;
wire                    master_0_wready;
wire                    master_1_wready;
wire                    slave_wready;


vcures_ram #(
  .VCURES_WIDTH     ( VCURES_WIDTH     ),
  .VCURES_ADDR_BITS ( VCURES_ADDR_BITS ),
  .BANK             ( BANK             )
) u_vcures_ram(
  .clk             ( clk             ),
  .rst_n           ( rst_n           ),
  .broadcast       ( broadcast       ),
  .broadcast_mask  ( broadcast_mask  ),
  .vcures_0_rvalid ( vcures_0_rvalid ),
  .vcures_0_raddr  ( vcures_0_raddr  ),
  .vcures_1_rvalid ( vcures_1_rvalid ),
  .vcures_1_raddr  ( vcures_1_raddr  ),
  .vcures_2_rvalid ( vcures_2_rvalid ),
  .vcures_2_raddr  ( vcures_2_raddr  ),
  .vcures_3_rvalid ( vcures_3_rvalid ),
  .vcures_3_raddr  ( vcures_3_raddr  ),
  .vcures_4_rvalid ( vcures_4_rvalid ),
  .vcures_4_raddr  ( vcures_4_raddr  ),
  .vcures_5_rvalid ( vcures_5_rvalid ),
  .vcures_5_raddr  ( vcures_5_raddr  ),
  .vcures_6_rvalid ( vcures_6_rvalid ),
  .vcures_6_raddr  ( vcures_6_raddr  ),
  .vcures_7_rvalid ( vcures_7_rvalid ),
  .vcures_7_raddr  ( vcures_7_raddr  ),
  .vcures_8_rvalid ( vcures_8_rvalid ),
  .vcures_8_raddr  ( vcures_8_raddr  ),
  .vcures_9_rvalid ( vcures_9_rvalid ),
  .vcures_9_raddr  ( vcures_9_raddr  ),
  .vcures_a_rvalid ( vcures_a_rvalid ),
  .vcures_a_raddr  ( vcures_a_raddr  ),
  .vcures_b_rvalid ( vcures_b_rvalid ),
  .vcures_b_raddr  ( vcures_b_raddr  ),
  .vcures_c_rvalid ( vcures_c_rvalid ),
  .vcures_c_raddr  ( vcures_c_raddr  ),
  .vcures_d_rvalid ( vcures_d_rvalid ),
  .vcures_d_raddr  ( vcures_d_raddr  ),
  .vcures_e_rvalid ( vcures_e_rvalid ),
  .vcures_e_raddr  ( vcures_e_raddr  ),
  .vcures_f_rvalid ( vcures_f_rvalid ),
  .vcures_f_raddr  ( vcures_f_raddr  ),
  .vcures_0_wvalid ( vcures_0_wvalid ),
  .vcures_0_waddr  ( vcures_0_waddr  ),
  .vcures_0_wdata  ( vcures_0_wdata  ),
  .vcures_1_wvalid ( vcures_1_wvalid ),
  .vcures_1_waddr  ( vcures_1_waddr  ),
  .vcures_1_wdata  ( vcures_1_wdata  ),
  .vcures_2_wvalid ( vcures_2_wvalid ),
  .vcures_2_waddr  ( vcures_2_waddr  ),
  .vcures_2_wdata  ( vcures_2_wdata  ),
  .vcures_3_wvalid ( vcures_3_wvalid ),
  .vcures_3_waddr  ( vcures_3_waddr  ),
  .vcures_3_wdata  ( vcures_3_wdata  ),
  .vcures_4_wvalid ( vcures_4_wvalid ),
  .vcures_4_waddr  ( vcures_4_waddr  ),
  .vcures_4_wdata  ( vcures_4_wdata  ),
  .vcures_5_wvalid ( vcures_5_wvalid ),
  .vcures_5_waddr  ( vcures_5_waddr  ),
  .vcures_5_wdata  ( vcures_5_wdata  ),
  .vcures_6_wvalid ( vcures_6_wvalid ),
  .vcures_6_waddr  ( vcures_6_waddr  ),
  .vcures_6_wdata  ( vcures_6_wdata  ),
  .vcures_7_wvalid ( vcures_7_wvalid ),
  .vcures_7_waddr  ( vcures_7_waddr  ),
  .vcures_7_wdata  ( vcures_7_wdata  ),
  .vcures_8_wvalid ( vcures_8_wvalid ),
  .vcures_8_waddr  ( vcures_8_waddr  ),
  .vcures_8_wdata  ( vcures_8_wdata  ),
  .vcures_9_wvalid ( vcures_9_wvalid ),
  .vcures_9_waddr  ( vcures_9_waddr  ),
  .vcures_9_wdata  ( vcures_9_wdata  ),
  .vcures_a_wvalid ( vcures_a_wvalid ),
  .vcures_a_waddr  ( vcures_a_waddr  ),
  .vcures_a_wdata  ( vcures_a_wdata  ),
  .vcures_b_wvalid ( vcures_b_wvalid ),
  .vcures_b_waddr  ( vcures_b_waddr  ),
  .vcures_b_wdata  ( vcures_b_wdata  ),
  .vcures_c_wvalid ( vcures_c_wvalid ),
  .vcures_c_waddr  ( vcures_c_waddr  ),
  .vcures_c_wdata  ( vcures_c_wdata  ),
  .vcures_d_wvalid ( vcures_d_wvalid ),
  .vcures_d_waddr  ( vcures_d_waddr  ),
  .vcures_d_wdata  ( vcures_d_wdata  ),
  .vcures_e_wvalid ( vcures_e_wvalid ),
  .vcures_e_waddr  ( vcures_e_waddr  ),
  .vcures_e_wdata  ( vcures_e_wdata  ),
  .vcures_f_wvalid ( vcures_f_wvalid ),
  .vcures_f_waddr  ( vcures_f_waddr  ),
  .vcures_f_wdata  ( vcures_f_wdata  ),
  .master_0_wvalid ( master_0_wvalid ),
  .master_0_waddr  ( master_0_waddr  ),
  .master_0_wdata  ( master_0_wdata  ),
  .master_1_wvalid ( master_1_wvalid ),
  .master_1_waddr  ( master_1_waddr  ),
  .master_1_wdata  ( master_1_wdata  ),
  .slave_wvalid    ( slave_wvalid    ),
  .slave_waddr     ( slave_waddr     ),
  .slave_wdata     ( slave_wdata     ),
  .vcures_0_rdata  ( vcures_0_rdata  ),
  .vcures_0_rready ( vcures_0_rready ),
  .vcures_1_rdata  ( vcures_1_rdata  ),
  .vcures_1_rready ( vcures_1_rready ),
  .vcures_2_rdata  ( vcures_2_rdata  ),
  .vcures_2_rready ( vcures_2_rready ),
  .vcures_3_rdata  ( vcures_3_rdata  ),
  .vcures_3_rready ( vcures_3_rready ),
  .vcures_4_rdata  ( vcures_4_rdata  ),
  .vcures_4_rready ( vcures_4_rready ),
  .vcures_5_rdata  ( vcures_5_rdata  ),
  .vcures_5_rready ( vcures_5_rready ),
  .vcures_6_rdata  ( vcures_6_rdata  ),
  .vcures_6_rready ( vcures_6_rready ),
  .vcures_7_rdata  ( vcures_7_rdata  ),
  .vcures_7_rready ( vcures_7_rready ),
  .vcures_8_rdata  ( vcures_8_rdata  ),
  .vcures_8_rready ( vcures_8_rready ),
  .vcures_9_rdata  ( vcures_9_rdata  ),
  .vcures_9_rready ( vcures_9_rready ),
  .vcures_a_rdata  ( vcures_a_rdata  ),
  .vcures_a_rready ( vcures_a_rready ),
  .vcures_b_rdata  ( vcures_b_rdata  ),
  .vcures_b_rready ( vcures_b_rready ),
  .vcures_c_rdata  ( vcures_c_rdata  ),
  .vcures_c_rready ( vcures_c_rready ),
  .vcures_d_rdata  ( vcures_d_rdata  ),
  .vcures_d_rready ( vcures_d_rready ),
  .vcures_e_rdata  ( vcures_e_rdata  ),
  .vcures_e_rready ( vcures_e_rready ),
  .vcures_f_rdata  ( vcures_f_rdata  ),
  .vcures_f_rready ( vcures_f_rready ),
  .vcures_0_wready ( vcures_0_wready ),
  .vcures_1_wready ( vcures_1_wready ),
  .vcures_2_wready ( vcures_2_wready ),
  .vcures_3_wready ( vcures_3_wready ),
  .vcures_4_wready ( vcures_4_wready ),
  .vcures_5_wready ( vcures_5_wready ),
  .vcures_6_wready ( vcures_6_wready ),
  .vcures_7_wready ( vcures_7_wready ),
  .vcures_8_wready ( vcures_8_wready ),
  .vcures_9_wready ( vcures_9_wready ),
  .vcures_a_wready ( vcures_a_wready ),
  .vcures_b_wready ( vcures_b_wready ),
  .vcures_c_wready ( vcures_c_wready ),
  .vcures_d_wready ( vcures_d_wready ),
  .vcures_e_wready ( vcures_e_wready ),
  .vcures_f_wready ( vcures_f_wready ),
  .master_0_wready ( master_0_wready ),
  .master_1_wready ( master_1_wready ),
  .slave_wready    ( slave_wready    )
);

initial begin
clk = 0;
rst_n = 0;
broadcast = 0;
broadcast_mask = 0;
vcures_0_rvalid = 0;
vcures_0_raddr = 0;
vcures_1_rvalid = 0;
vcures_1_raddr = 0;
vcures_2_rvalid = 0;
vcures_2_raddr = 0;
vcures_3_rvalid = 0;
vcures_3_raddr = 0;
vcures_4_rvalid = 0;
vcures_4_raddr = 0;
vcures_5_rvalid = 0;
vcures_5_raddr = 0;
vcures_6_rvalid = 0;
vcures_6_raddr = 0;
vcures_7_rvalid = 0;
vcures_7_raddr = 0;
vcures_8_rvalid = 0;
vcures_8_raddr = 0;
vcures_9_rvalid = 0;
vcures_9_raddr = 0;
vcures_a_rvalid = 0;
vcures_a_raddr = 0;
vcures_b_rvalid = 0;
vcures_b_raddr = 0;
vcures_c_rvalid = 0;
vcures_c_raddr = 0;
vcures_d_rvalid = 0;
vcures_d_raddr = 0;
vcures_e_rvalid = 0;
vcures_e_raddr = 0;
vcures_f_rvalid = 0;
vcures_f_raddr = 0;
vcures_0_wvalid = 0;
vcures_0_waddr = 0;
vcures_0_wdata = 0;
vcures_1_wvalid = 0;
vcures_1_waddr = 0;
vcures_1_wdata = 0;
vcures_2_wvalid = 0;
vcures_2_waddr = 0;
vcures_2_wdata = 0;
vcures_3_wvalid = 0;
vcures_3_waddr = 0;
vcures_3_wdata = 0;
vcures_4_wvalid = 0;
vcures_4_waddr = 0;
vcures_4_wdata = 0;
vcures_5_wvalid = 0;
vcures_5_waddr = 0;
vcures_5_wdata = 0;
vcures_6_wvalid = 0;
vcures_6_waddr = 0;
vcures_6_wdata = 0;
vcures_7_wvalid = 0;
vcures_7_waddr = 0;
vcures_7_wdata = 0;
vcures_8_wvalid = 0;
vcures_8_waddr = 0;
vcures_8_wdata = 0;
vcures_9_wvalid = 0;
vcures_9_waddr = 0;
vcures_9_wdata = 0;
vcures_a_wvalid = 0;
vcures_a_waddr = 0;
vcures_a_wdata = 0;
vcures_b_wvalid = 0;
vcures_b_waddr = 0;
vcures_b_wdata = 0;
vcures_c_wvalid = 0;
vcures_c_waddr = 0;
vcures_c_wdata = 0;
vcures_d_wvalid = 0;
vcures_d_waddr = 0;
vcures_d_wdata = 0;
vcures_e_wvalid = 0;
vcures_e_waddr = 0;
vcures_e_wdata = 0;
vcures_f_wvalid = 0;
vcures_f_waddr = 0;
vcures_f_wdata = 0;
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

initial begin
  $fsdbDumpfile("vcures_ram_tb.fsdb");
  $fsdbDumpvars(0, "vcures_ram_tb");
  $fsdbDumpMDA();
end

always #5 clk = ~clk;

/* -------------------------------------------------------------------------------------------------------- */
/*                                              master 0 write                                              */
/* -------------------------------------------------------------------------------------------------------- */

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_0_wvalid <= 0;
//     master_0_waddr <= 0;
//     master_0_wdata <= 0;
//   end 
//   else begin
//     master_0_wvalid <= 1;
//     master_0_waddr <= master_0_waddr + 1;
//     master_0_wdata <= master_0_wdata + 1;

//     if (master_0_waddr == 256 * 2 * 16 - 2) begin
//       $display("master 0 write done");
//       master_0_wvalid <= 0;
    
//       $finish;
//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                             master 0 1 write                                             */
/* -------------------------------------------------------------------------------------------------------- */

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     master_1_wvalid <=  0;
//     master_1_waddr <=  256 * 8;
//     master_1_wdata <=  0;
//     master_0_wvalid <=  0;
//     master_0_waddr <=  0;
//     master_0_wdata <=  0;
//   end 
//   else begin
//     master_1_wvalid <=  1;
//     master_1_waddr <=  master_1_waddr + 1;
//     master_1_wdata <=  master_1_wdata + 1;
//     master_0_wvalid <=  1;
//     master_0_waddr <=  master_0_waddr + 1;
//     master_0_wdata <=  master_0_wdata + 1;

//     if (master_0_waddr == 256 * 8 - 1) begin
//       master_0_wvalid <=  0;
//       master_1_wvalid <=  0;
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
//     vcures_0_rvalid = 0;
//     vcures_0_raddr = 0;
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
//       vcures_0_rvalid = 1;
//       if (vcures_0_raddr == 256 * 4 - 1) begin
//         vcures_0_raddr = 256 * 16;
//       end
//       else begin
//         vcures_0_raddr = vcures_0_raddr + 1;
//       end
//     end

//     if (vcures_0_raddr == 256 * 16 + 256 * 4 - 1) begin
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
//     vcures_4_rvalid <= 0;
//     vcures_4_raddr <= 256 * 4 - 1;
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
//       vcures_4_rvalid <= 1;
//       if (vcures_4_raddr == 256 * 8 - 1) begin
//         vcures_4_raddr <= 256 * 16 + 256 * 4;
//       end
//       else begin
//         vcures_4_raddr <= vcures_4_raddr + 1;
//       end
//     end

//     if (vcures_4_raddr == 256 * 16 + 256 * 8 - 1) begin
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
//     vcures_8_rvalid <= 0;
//     vcures_8_raddr <= 256 * 8 - 1;
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
//       vcures_8_rvalid <= 1;
//       if (vcures_8_raddr == 256 * 12 - 1) begin
//         vcures_8_raddr <= 256 * 16 + 256 * 8;
//       end
//       else begin
//         vcures_8_raddr <= vcures_8_raddr + 1;
//       end
//     end

//     if (vcures_8_raddr == 256 * 16 + 256 * 12 - 1) begin
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
//     vcures_c_rvalid <= 0;
//     vcures_c_raddr <= 256 * 12 - 1;
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
//       vcures_c_rvalid <= 1;
//       if (vcures_c_raddr == 256 * 16 - 1) begin
//         vcures_c_raddr <= 256 * 16 + 256 * 12;
//       end
//       else begin
//         vcures_c_raddr <= vcures_c_raddr + 1;
//       end
//     end

//     if (vcures_c_raddr == 256 * 16 + 256 * 16 - 1) begin
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
//     vcures_0_rvalid  <= 0;
//     vcures_0_raddr   <= -1;
//     vcures_1_rvalid  <= 0;
//     vcures_1_raddr   <= 256 - 1;
//     vcures_2_rvalid  <= 0;
//     vcures_2_raddr   <= 256 * 2 - 1;
//     vcures_3_rvalid  <= 0;
//     vcures_3_raddr   <= 256 * 3 - 1;
//     vcures_4_rvalid  <= 0;
//     vcures_4_raddr   <= 256 * 4 - 1;
//     vcures_5_rvalid  <= 0;
//     vcures_5_raddr   <= 256 * 5 - 1;
//     vcures_6_rvalid  <= 0;
//     vcures_6_raddr   <= 256 * 6 - 1;
//     vcures_7_rvalid  <= 0;
//     vcures_7_raddr   <= 256 * 7 - 1;
//     vcures_8_rvalid  <= 0;
//     vcures_8_raddr   <= 256 * 8 - 1;
//     vcures_9_rvalid  <= 0;
//     vcures_9_raddr   <= 256 * 9 - 1;
//     vcures_a_rvalid  <= 0;
//     vcures_a_raddr   <= 256 * 10 - 1;
//     vcures_b_rvalid  <= 0;
//     vcures_b_raddr   <= 256 * 11 - 1;
//     vcures_c_rvalid  <= 0;
//     vcures_c_raddr   <= 256 * 12 - 1;
//     vcures_d_rvalid  <= 0;
//     vcures_d_raddr   <= 256 * 13 - 1;
//     vcures_e_rvalid  <= 0;
//     vcures_e_raddr   <= 256 * 14 - 1;
//     vcures_f_rvalid  <= 0;
//     vcures_f_raddr   <= 256 * 15 - 1;
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
//       vcures_0_rvalid <= 1;
//       if (vcures_0_raddr == 256 - 1) begin
//         vcures_0_raddr <= 256 * 16;
//       end
//       else begin
//         vcures_0_raddr <= vcures_0_raddr + 1;
//       end

//       vcures_1_rvalid <= 1;
//       if (vcures_1_raddr == 256 * 2 - 1) begin
//         vcures_1_raddr <= 256 * 16 + 256;
//       end
//       else begin
//         vcures_1_raddr <= vcures_1_raddr + 1;
//       end

//       vcures_2_rvalid <= 1;
//       if (vcures_2_raddr == 256 * 3 - 1) begin
//         vcures_2_raddr <= 256 * 16 + 256 * 2;
//       end
//       else begin
//         vcures_2_raddr <= vcures_2_raddr + 1;
//       end

//       vcures_3_rvalid <= 1;
//       if (vcures_3_raddr == 256 * 4 - 1) begin
//         vcures_3_raddr <= 256 * 16 + 256 * 3;
//       end
//       else begin
//         vcures_3_raddr <= vcures_3_raddr + 1;
//       end

//       vcures_4_rvalid <= 1;
//       if (vcures_4_raddr == 256 * 5 - 1) begin
//         vcures_4_raddr <= 256 * 16 + 256 * 4;
//       end
//       else begin
//         vcures_4_raddr <= vcures_4_raddr + 1;
//       end

//       vcures_5_rvalid <= 1;
//       if (vcures_5_raddr == 256 * 6 - 1) begin
//         vcures_5_raddr <= 256 * 16 + 256 * 5;
//       end
//       else begin
//         vcures_5_raddr <= vcures_5_raddr + 1;
//       end

//       vcures_6_rvalid <= 1;
//       if (vcures_6_raddr == 256 * 7 - 1) begin
//         vcures_6_raddr <= 256 * 16 + 256 * 6;
//       end
//       else begin
//         vcures_6_raddr <= vcures_6_raddr + 1;
//       end

//       vcures_7_rvalid <= 1;
//       if (vcures_7_raddr == 256 * 8 - 1) begin
//         vcures_7_raddr <= 256 * 16 + 256 * 7;
//       end
//       else begin
//         vcures_7_raddr <= vcures_7_raddr + 1;
//       end

//       vcures_8_rvalid <= 1;
//       if (vcures_8_raddr == 256 * 9 - 1) begin
//         vcures_8_raddr <= 256 * 16 + 256 * 8;
//       end
//       else begin
//         vcures_8_raddr <= vcures_8_raddr + 1;
//       end

//       vcures_9_rvalid <= 1;
//       if (vcures_9_raddr == 256 * 10 - 1) begin
//         vcures_9_raddr <= 256 * 16 + 256 * 9;
//       end
//       else begin
//         vcures_9_raddr <= vcures_9_raddr + 1;
//       end

//       vcures_a_rvalid <= 1;
//       if (vcures_a_raddr == 256 * 11 - 1) begin
//         vcures_a_raddr <= 256 * 16 + 256 * 10;
//       end
//       else begin
//         vcures_a_raddr <= vcures_a_raddr + 1;
//       end

//       vcures_b_rvalid <= 1;
//       if (vcures_b_raddr == 256 * 12 - 1) begin
//         vcures_b_raddr <= 256 * 16 + 256 * 11;
//       end
//       else begin
//         vcures_b_raddr <= vcures_b_raddr + 1;
//       end

//       vcures_c_rvalid <= 1;
//       if (vcures_c_raddr == 256 * 13 - 1) begin
//         vcures_c_raddr <= 256 * 16 + 256 * 12;
//       end
//       else begin
//         vcures_c_raddr <= vcures_c_raddr + 1;
//       end

//       vcures_d_rvalid <= 1;
//       if (vcures_d_raddr == 256 * 14 - 1) begin
//         vcures_d_raddr <= 256 * 16 + 256 * 13;
//       end
//       else begin
//         vcures_d_raddr <= vcures_d_raddr + 1;
//       end

//       vcures_e_rvalid <= 1;
//       if (vcures_e_raddr == 256 * 15 - 1) begin
//         vcures_e_raddr <= 256 * 16 + 256 * 14;
//       end
//       else begin
//         vcures_e_raddr <= vcures_e_raddr + 1;
//       end

//       vcures_f_rvalid <= 1;
//       if (vcures_f_raddr == 256 * 16 - 1) begin
//         vcures_f_raddr <= 256 * 16 + 256 * 15;
//       end
//       else begin
//         vcures_f_raddr <= vcures_f_raddr + 1;
//       end

//       if (vcures_f_raddr == 256 * 16 + 256 * 16 - 1) begin
//         $finish;
//       end

//     end
//   end
// end

/* -------------------------------------------------------------------------------------------------------- */
/*                                              vcu write read                                              */
/* -------------------------------------------------------------------------------------------------------- */

reg write_done_flag;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcures_0_wvalid <= 0;
    vcures_0_waddr <= 0;
    vcures_0_wdata <= 0;

    vcures_1_wvalid <= 0;
    vcures_1_waddr <= 256;
    vcures_1_wdata <= 256;

    vcures_2_wvalid <= 0;
    vcures_2_waddr <= 256 * 2;
    vcures_2_wdata <= 256 * 2;

    vcures_3_wvalid <= 0;
    vcures_3_waddr <= 256 * 3;
    vcures_3_wdata <= 256 * 3;

    vcures_4_wvalid <= 0;
    vcures_4_waddr <= 256 * 4;
    vcures_4_wdata <= 256 * 4;

    vcures_5_wvalid <= 0;
    vcures_5_waddr <= 256 * 5;
    vcures_5_wdata <= 256 * 5;

    vcures_6_wvalid <= 0;
    vcures_6_waddr <= 256 * 6;
    vcures_6_wdata <= 256 * 6;

    vcures_7_wvalid <= 0;
    vcures_7_waddr <= 256 * 7;
    vcures_7_wdata <= 256 * 7;

    vcures_8_wvalid <= 0;
    vcures_8_waddr <= 256 * 8;
    vcures_8_wdata <= 256 * 8;

    vcures_9_wvalid <= 0;
    vcures_9_waddr <= 256 * 9;
    vcures_9_wdata <= 256 * 9;

    vcures_a_wvalid <= 0;
    vcures_a_waddr <= 256 * 10;
    vcures_a_wdata <= 256 * 10;

    vcures_b_wvalid <= 0;
    vcures_b_waddr <= 256 * 11;
    vcures_b_wdata <= 256 * 11;

    vcures_c_wvalid <= 0;
    vcures_c_waddr <= 256 * 12;
    vcures_c_wdata <= 256 * 12;

    vcures_d_wvalid <= 0;
    vcures_d_waddr <= 256 * 13;
    vcures_d_wdata <= 256 * 13;

    vcures_e_wvalid <= 0;
    vcures_e_waddr <= 256 * 14;
    vcures_e_wdata <= 256 * 14;

    vcures_f_wvalid <= 0;
    vcures_f_waddr <= 256 * 15;
    vcures_f_wdata <= 256 * 15;

    slave_wvalid <= 0;
    slave_waddr <= 0;
    slave_wdata <= 0;

    vcures_0_rvalid <= 0;
    vcures_0_raddr <= 0;

    vcures_1_rvalid <= 0;
    vcures_1_raddr <=  256;

    vcures_2_rvalid <= 0;
    vcures_2_raddr <= 256 * 2;

    vcures_3_rvalid <= 0;
    vcures_3_raddr <= 256 * 3;

    vcures_4_rvalid <= 0;
    vcures_4_raddr <= 256 * 4;

    vcures_5_rvalid <= 0;
    vcures_5_raddr <=  256 * 5;

    vcures_6_rvalid <= 0;
    vcures_6_raddr <=  256 * 6;

    vcures_7_rvalid <= 0;
    vcures_7_raddr <= 256 * 7;

    vcures_8_rvalid <= 0;
    vcures_8_raddr <=  256 * 8;

    vcures_9_rvalid <= 0;
    vcures_9_raddr <=  256 * 9;

    vcures_a_rvalid <= 0;
    vcures_a_raddr <=  256 * 10;

    vcures_b_rvalid <= 0;
    vcures_b_raddr <=  256 * 11;

    vcures_c_rvalid <= 0;
    vcures_c_raddr <=  256 * 12;

    vcures_d_rvalid <= 0;
    vcures_d_raddr <= 256 * 13;

    vcures_e_rvalid <= 0;
    vcures_e_raddr <=  256 * 14 ;

    vcures_f_rvalid <= 0;
    vcures_f_raddr <=  256 * 15;

    write_done_flag <= 1'b0;
  end
  else begin
    if (!write_done_flag) begin
      vcures_0_wvalid <= 1;
      vcures_1_wvalid <= 1;
      vcures_2_wvalid <= 1;
      vcures_3_wvalid <= 1;
      vcures_4_wvalid <= 1;
      vcures_5_wvalid <= 1;
      vcures_6_wvalid <= 1;
      vcures_7_wvalid <= 1;
      vcures_8_wvalid <= 1;
      vcures_9_wvalid <= 1;
      vcures_a_wvalid <= 1;
      vcures_b_wvalid <= 1;
      vcures_c_wvalid <= 1;
      vcures_d_wvalid <= 1;
      vcures_e_wvalid <= 1;
      vcures_f_wvalid <= 1;

      vcures_0_waddr <= vcures_0_waddr + 1;
      vcures_1_waddr <= vcures_1_waddr + 1;
      vcures_2_waddr <= vcures_2_waddr + 1;
      vcures_3_waddr <= vcures_3_waddr + 1;
      vcures_4_waddr <= vcures_4_waddr + 1;
      vcures_5_waddr <= vcures_5_waddr + 1;
      vcures_6_waddr <= vcures_6_waddr + 1;
      vcures_7_waddr <= vcures_7_waddr + 1;
      vcures_8_waddr <= vcures_8_waddr + 1;
      vcures_9_waddr <= vcures_9_waddr + 1;
      vcures_a_waddr <= vcures_a_waddr + 1;
      vcures_b_waddr <= vcures_b_waddr + 1;
      vcures_c_waddr <= vcures_c_waddr + 1;
      vcures_d_waddr <= vcures_d_waddr + 1;
      vcures_e_waddr <= vcures_e_waddr + 1;
      vcures_f_waddr <= vcures_f_waddr + 1;

      vcures_0_wdata <= vcures_0_wdata + 1;
      vcures_1_wdata <= vcures_1_wdata + 1;
      vcures_2_wdata <= vcures_2_wdata + 1;
      vcures_3_wdata <= vcures_3_wdata + 1;
      vcures_4_wdata <= vcures_4_wdata + 1;
      vcures_5_wdata <= vcures_5_wdata + 1;
      vcures_6_wdata <= vcures_6_wdata + 1;
      vcures_7_wdata <= vcures_7_wdata + 1;
      vcures_8_wdata <= vcures_8_wdata + 1;
      vcures_9_wdata <= vcures_9_wdata + 1;
      vcures_a_wdata <= vcures_a_wdata + 1;
      vcures_b_wdata <= vcures_b_wdata + 1;
      vcures_c_wdata <= vcures_c_wdata + 1;
      vcures_d_wdata <= vcures_d_wdata + 1;
      vcures_e_wdata <= vcures_e_wdata + 1;
      vcures_f_wdata <= vcures_f_wdata + 1;

      if (vcures_0_waddr == 255) begin
        write_done_flag <= 1;
      end
    end
    else begin
      vcures_0_rvalid <= 1;
      vcures_1_rvalid <= 1;
      vcures_2_rvalid <= 1;
      vcures_3_rvalid <= 1;
      vcures_4_rvalid <= 1;
      vcures_5_rvalid <= 1;
      vcures_6_rvalid <= 1;
      vcures_7_rvalid <= 1;
      vcures_8_rvalid <= 1;
      vcures_9_rvalid <= 1;
      vcures_a_rvalid <= 1;
      vcures_b_rvalid <= 1;
      vcures_c_rvalid <= 1;
      vcures_d_rvalid <= 1;
      vcures_e_rvalid <= 1;
      vcures_f_rvalid <= 1;

      vcures_0_wvalid <= 0;
      vcures_1_wvalid <= 0;
      vcures_2_wvalid <= 0;
      vcures_3_wvalid <= 0;
      vcures_4_wvalid <= 0;
      vcures_5_wvalid <= 0;
      vcures_6_wvalid <= 0;
      vcures_7_wvalid <= 0;
      vcures_8_wvalid <= 0;
      vcures_9_wvalid <= 0;
      vcures_a_wvalid <= 0;
      vcures_b_wvalid <= 0;
      vcures_c_wvalid <= 0;
      vcures_d_wvalid <= 0;
      vcures_e_wvalid <= 0;
      vcures_f_wvalid <= 0;

      vcures_0_raddr <= vcures_0_raddr + 1;
      vcures_1_raddr <= vcures_1_raddr + 1;
      vcures_2_raddr <= vcures_2_raddr + 1;
      vcures_3_raddr <= vcures_3_raddr + 1;
      vcures_4_raddr <= vcures_4_raddr + 1;
      vcures_5_raddr <= vcures_5_raddr + 1;
      vcures_6_raddr <= vcures_6_raddr + 1;
      vcures_7_raddr <= vcures_7_raddr + 1;
      vcures_8_raddr <= vcures_8_raddr + 1;
      vcures_9_raddr <= vcures_9_raddr + 1;
      vcures_a_raddr <= vcures_a_raddr + 1;
      vcures_b_raddr <= vcures_b_raddr + 1;
      vcures_c_raddr <= vcures_c_raddr + 1;
      vcures_d_raddr <= vcures_d_raddr + 1;
      vcures_e_raddr <= vcures_e_raddr + 1;
      vcures_f_raddr <= vcures_f_raddr + 1;

      if (vcures_f_raddr == 256 - 1) begin
        $finish;
      end

    end
  end
end

endmodule