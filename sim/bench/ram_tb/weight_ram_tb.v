module weight_ram_tb();

parameter WEIGHT_WIDTH      = 256;
parameter WEIGHT_ADDR_BITS  = 14;
parameter BANK              = 16;

reg                         clk;
reg                         rst_n;
reg  [1:0]                  broadcast;
reg  [BANK-1:0]             broadcast_mask;
reg                         weight_0_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_0_raddr;
reg                         weight_1_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_1_raddr;
reg                         weight_2_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_2_raddr;
reg                         weight_3_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_3_raddr;
reg                         weight_4_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_4_raddr;
reg                         weight_5_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_5_raddr;
reg                         weight_6_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_6_raddr;
reg                         weight_7_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_7_raddr;
reg                         weight_8_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_8_raddr;
reg                         weight_9_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_9_raddr;
reg                         weight_a_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_a_raddr;
reg                         weight_b_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_b_raddr;
reg                         weight_c_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_c_raddr;
reg                         weight_d_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_d_raddr;
reg                         weight_e_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_e_raddr;
reg                         weight_f_rvalid;
reg  [WEIGHT_ADDR_BITS-1:0] weight_f_raddr;
reg                         master_0_wvalid;
reg  [WEIGHT_ADDR_BITS-1:0] master_0_waddr;
reg  [WEIGHT_WIDTH-1:0]     master_0_wdata;
reg                         master_1_wvalid;
reg  [WEIGHT_ADDR_BITS-1:0] master_1_waddr;
reg  [WEIGHT_WIDTH-1:0]     master_1_wdata;
reg                         slave_wvalid;
reg  [WEIGHT_ADDR_BITS-1:0] slave_waddr;
reg  [WEIGHT_WIDTH-1:0]     slave_wdata;

wire [WEIGHT_WIDTH-1:0] weight_0_rdata;
wire                    weight_0_rready;
wire [WEIGHT_WIDTH-1:0] weight_1_rdata;
wire                    weight_1_rready;
wire [WEIGHT_WIDTH-1:0] weight_2_rdata;
wire                    weight_2_rready;
wire [WEIGHT_WIDTH-1:0] weight_3_rdata;
wire                    weight_3_rready;
wire [WEIGHT_WIDTH-1:0] weight_4_rdata;
wire                    weight_4_rready;
wire [WEIGHT_WIDTH-1:0] weight_5_rdata;
wire                    weight_5_rready;
wire [WEIGHT_WIDTH-1:0] weight_6_rdata;
wire                    weight_6_rready;
wire [WEIGHT_WIDTH-1:0] weight_7_rdata;
wire                    weight_7_rready;
wire [WEIGHT_WIDTH-1:0] weight_8_rdata;
wire                    weight_8_rready;
wire [WEIGHT_WIDTH-1:0] weight_9_rdata;
wire                    weight_9_rready;
wire [WEIGHT_WIDTH-1:0] weight_a_rdata;
wire                    weight_a_rready;
wire [WEIGHT_WIDTH-1:0] weight_b_rdata;
wire                    weight_b_rready;
wire [WEIGHT_WIDTH-1:0] weight_c_rdata;
wire                    weight_c_rready;
wire [WEIGHT_WIDTH-1:0] weight_d_rdata;
wire                    weight_d_rready;
wire [WEIGHT_WIDTH-1:0] weight_e_rdata;
wire                    weight_e_rready;
wire [WEIGHT_WIDTH-1:0] weight_f_rdata;
wire                    weight_f_rready;
wire                    master_0_wready;
wire                    master_1_wready;
wire                    slave_wready;


weight_ram #(
    .WEIGHT_WIDTH     ( WEIGHT_WIDTH     ),
    .WEIGHT_ADDR_BITS ( WEIGHT_ADDR_BITS ),
    .BANK             ( BANK             )
) u_weight_ram(
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .broadcast       ( broadcast       ),
    .broadcast_mask  ( broadcast_mask  ),
    .weight_0_rvalid ( weight_0_rvalid ),
    .weight_0_raddr  ( weight_0_raddr  ),
    .weight_1_rvalid ( weight_1_rvalid ),
    .weight_1_raddr  ( weight_1_raddr  ),
    .weight_2_rvalid ( weight_2_rvalid ),
    .weight_2_raddr  ( weight_2_raddr  ),
    .weight_3_rvalid ( weight_3_rvalid ),
    .weight_3_raddr  ( weight_3_raddr  ),
    .weight_4_rvalid ( weight_4_rvalid ),
    .weight_4_raddr  ( weight_4_raddr  ),
    .weight_5_rvalid ( weight_5_rvalid ),
    .weight_5_raddr  ( weight_5_raddr  ),
    .weight_6_rvalid ( weight_6_rvalid ),
    .weight_6_raddr  ( weight_6_raddr  ),
    .weight_7_rvalid ( weight_7_rvalid ),
    .weight_7_raddr  ( weight_7_raddr  ),
    .weight_8_rvalid ( weight_8_rvalid ),
    .weight_8_raddr  ( weight_8_raddr  ),
    .weight_9_rvalid ( weight_9_rvalid ),
    .weight_9_raddr  ( weight_9_raddr  ),
    .weight_a_rvalid ( weight_a_rvalid ),
    .weight_a_raddr  ( weight_a_raddr  ),
    .weight_b_rvalid ( weight_b_rvalid ),
    .weight_b_raddr  ( weight_b_raddr  ),
    .weight_c_rvalid ( weight_c_rvalid ),
    .weight_c_raddr  ( weight_c_raddr  ),
    .weight_d_rvalid ( weight_d_rvalid ),
    .weight_d_raddr  ( weight_d_raddr  ),
    .weight_e_rvalid ( weight_e_rvalid ),
    .weight_e_raddr  ( weight_e_raddr  ),
    .weight_f_rvalid ( weight_f_rvalid ),
    .weight_f_raddr  ( weight_f_raddr  ),
    .master_0_wvalid ( master_0_wvalid ),
    .master_0_waddr  ( master_0_waddr  ),
    .master_0_wdata  ( master_0_wdata  ),
    .master_1_wvalid ( master_1_wvalid ),
    .master_1_waddr  ( master_1_waddr  ),
    .master_1_wdata  ( master_1_wdata  ),
    .slave_wvalid    ( slave_wvalid    ),
    .slave_waddr     ( slave_waddr     ),
    .slave_wdata     ( slave_wdata     ),
    .weight_0_rdata  ( weight_0_rdata  ),
    .weight_0_rready ( weight_0_rready ),
    .weight_1_rdata  ( weight_1_rdata  ),
    .weight_1_rready ( weight_1_rready ),
    .weight_2_rdata  ( weight_2_rdata  ),
    .weight_2_rready ( weight_2_rready ),
    .weight_3_rdata  ( weight_3_rdata  ),
    .weight_3_rready ( weight_3_rready ),
    .weight_4_rdata  ( weight_4_rdata  ),
    .weight_4_rready ( weight_4_rready ),
    .weight_5_rdata  ( weight_5_rdata  ),
    .weight_5_rready ( weight_5_rready ),
    .weight_6_rdata  ( weight_6_rdata  ),
    .weight_6_rready ( weight_6_rready ),
    .weight_7_rdata  ( weight_7_rdata  ),
    .weight_7_rready ( weight_7_rready ),
    .weight_8_rdata  ( weight_8_rdata  ),
    .weight_8_rready ( weight_8_rready ),
    .weight_9_rdata  ( weight_9_rdata  ),
    .weight_9_rready ( weight_9_rready ),
    .weight_a_rdata  ( weight_a_rdata  ),
    .weight_a_rready ( weight_a_rready ),
    .weight_b_rdata  ( weight_b_rdata  ),
    .weight_b_rready ( weight_b_rready ),
    .weight_c_rdata  ( weight_c_rdata  ),
    .weight_c_rready ( weight_c_rready ),
    .weight_d_rdata  ( weight_d_rdata  ),
    .weight_d_rready ( weight_d_rready ),
    .weight_e_rdata  ( weight_e_rdata  ),
    .weight_e_rready ( weight_e_rready ),
    .weight_f_rdata  ( weight_f_rdata  ),
    .weight_f_rready ( weight_f_rready ),
    .master_0_wready ( master_0_wready ),
    .master_1_wready ( master_1_wready ),
    .slave_wready    ( slave_wready    )
);

initial begin
  $fsdbDumpfile("weight_ram_tb.fsdb");
  $fsdbDumpvars(0, "weight_ram_tb");
  $fsdbDumpMDA();
end

initial begin
  clk = 0;
  rst_n = 0;
  broadcast = 0;
  broadcast_mask = 0;
  weight_0_rvalid = 0;
  weight_0_raddr = 0;
  weight_1_rvalid = 0;
  weight_1_raddr = 0;
  weight_2_rvalid = 0;
  weight_2_raddr = 0;
  weight_3_rvalid = 0;
  weight_3_raddr = 0;
  weight_4_rvalid = 0;
  weight_4_raddr = 0;
  weight_5_rvalid = 0;
  weight_5_raddr = 0;
  weight_6_rvalid = 0;
  weight_6_raddr = 0;
  weight_7_rvalid = 0;
  weight_7_raddr = 0;
  weight_8_rvalid = 0;
  weight_8_raddr = 0;
  weight_9_rvalid = 0;
  weight_9_raddr = 0;
  weight_a_rvalid = 0;
  weight_a_raddr = 0;
  weight_b_rvalid = 0;
  weight_b_raddr = 0;
  weight_c_rvalid = 0;
  weight_c_raddr = 0;
  weight_d_rvalid = 0;
  weight_d_raddr = 0;
  weight_e_rvalid = 0;
  weight_e_raddr = 0;
  weight_f_rvalid = 0;
  weight_f_raddr = 0;
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

//     if (master_0_waddr == 512 * 2 * 16 - 1) begin
//       $display("master 0 write done");
//       master_0_wvalid = 0;

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
//     master_1_waddr = 512 * 8;
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

//     if (master_0_waddr == 512 * 8 - 1) begin
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
//     weight_0_rvalid = 0;
//     weight_0_raddr = 0;
//     write_done_flag = 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_0_wvalid = 1;
//       if (master_0_waddr == 512 * 4 - 1) begin
//         master_0_waddr = 512 * 16;
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

//     if (master_0_waddr == 512 * 16 + 512 * 4 - 1) begin
//       write_done_flag = 1;
//     end

//     if (write_done_flag) begin
//       weight_0_rvalid = 1;
//       if (weight_0_raddr == 512 * 4 - 1) begin
//         weight_0_raddr = 512 * 16;
//       end
//       else begin
//         weight_0_raddr = weight_0_raddr + 1;
//       end
//     end

//     if (weight_0_raddr == 512 * 16 + 512 * 4 - 1) begin
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
//     master_0_waddr <= 512 * 4 - 1;
//     master_0_wdata <= -1;
//     weight_4_rvalid <= 0;
//     weight_4_raddr <= 512 * 4 - 1;
//     write_done_flag <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_0_wvalid = 1;
//       if (master_0_waddr == 512 * 8 - 1) begin
//         master_0_waddr <= 512 * 16 + 512 * 4;
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

//     if (master_0_waddr == 512 * 16 + 512 * 8 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       weight_4_rvalid <= 1;
//       if (weight_4_raddr == 512 * 8 - 1) begin
//         weight_4_raddr <= 512 * 16 + 512 * 4;
//       end
//       else begin
//         weight_4_raddr <= weight_4_raddr + 1;
//       end
//     end

//     if (weight_4_raddr == 512 * 16 + 512 * 8 - 1) begin
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
//     master_0_waddr <= 512 * 8 - 1;
//     master_0_wdata <= -1;
//     weight_8_rvalid <= 0;
//     weight_8_raddr <= 512 * 8 - 1;
//     write_done_flag <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_0_wvalid = 1;
//       if (master_0_waddr == 512 * 12 - 1) begin
//         master_0_waddr <= 512 * 16 + 512 * 8;
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

//     if (master_0_waddr == 512 * 16 + 512 * 12 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       weight_8_rvalid <= 1;
//       if (weight_8_raddr == 512 * 12 - 1) begin
//         weight_8_raddr <= 512 * 16 + 512 * 8;
//       end
//       else begin
//         weight_8_raddr <= weight_8_raddr + 1;
//       end
//     end

//     if (weight_8_raddr == 512 * 16 + 512 * 12 - 1) begin
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
//     master_0_waddr <= 512 * 12 - 1;
//     master_0_wdata <= -1;
//     weight_c_rvalid <= 0;
//     weight_c_raddr <= 512 * 12 - 1;
//     write_done_flag <= 0;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_0_wvalid = 1;
//       if (master_0_waddr == 512 * 16 - 1) begin
//         master_0_waddr <= 512 * 16 + 512 * 12;
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

//     if (master_0_waddr == 512 * 16 + 512 * 16 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       weight_c_rvalid <= 1;
//       if (weight_c_raddr == 512 * 16 - 1) begin
//         weight_c_raddr <= 512 * 16 + 512 * 12;
//       end
//       else begin
//         weight_c_raddr <= weight_c_raddr + 1;
//       end
//     end

//     if (weight_c_raddr == 512 * 16 + 512 * 16 - 1) begin
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
//     weight_0_rvalid  <= 0;
//     weight_0_raddr   <= -1;
//     weight_1_rvalid  <= 0;
//     weight_1_raddr   <= 512 - 1;
//     weight_2_rvalid  <= 0;
//     weight_2_raddr   <= 512 * 2 - 1;
//     weight_3_rvalid  <= 0;
//     weight_3_raddr   <= 512 * 3 - 1;
//     weight_4_rvalid  <= 0;
//     weight_4_raddr   <= 512 * 4 - 1;
//     weight_5_rvalid  <= 0;
//     weight_5_raddr   <= 512 * 5 - 1;
//     weight_6_rvalid  <= 0;
//     weight_6_raddr   <= 512 * 6 - 1;
//     weight_7_rvalid  <= 0;
//     weight_7_raddr   <= 512 * 7 - 1;
//     weight_8_rvalid  <= 0;
//     weight_8_raddr   <= 512 * 8 - 1;
//     weight_9_rvalid  <= 0;
//     weight_9_raddr   <= 512 * 9 - 1;
//     weight_a_rvalid  <= 0;
//     weight_a_raddr   <= 512 * 10 - 1;
//     weight_b_rvalid  <= 0;
//     weight_b_raddr   <= 512 * 11 - 1;
//     weight_c_rvalid  <= 0;
//     weight_c_raddr   <= 512 * 12 - 1;
//     weight_d_rvalid  <= 0;
//     weight_d_raddr   <= 512 * 13 - 1;
//     weight_e_rvalid  <= 0;
//     weight_e_raddr   <= 512 * 14 - 1;
//     weight_f_rvalid  <= 0;
//     weight_f_raddr   <= 512 * 15 - 1;
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

//     if (master_1_waddr == 512 * 16 * 2 - 2) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       weight_0_rvalid <= 1;
//       if (weight_0_raddr == 512 - 1) begin
//         weight_0_raddr <= 512 * 16;
//       end
//       else begin
//         weight_0_raddr <= weight_0_raddr + 1;
//       end

//       weight_1_rvalid <= 1;
//       if (weight_1_raddr == 512 * 2 - 1) begin
//         weight_1_raddr <= 512 * 16 + 512;
//       end
//       else begin
//         weight_1_raddr <= weight_1_raddr + 1;
//       end

//       weight_2_rvalid <= 1;
//       if (weight_2_raddr == 512 * 3 - 1) begin
//         weight_2_raddr <= 512 * 16 + 512 * 2;
//       end
//       else begin
//         weight_2_raddr <= weight_2_raddr + 1;
//       end

//       weight_3_rvalid <= 1;
//       if (weight_3_raddr == 512 * 4 - 1) begin
//         weight_3_raddr <= 512 * 16 + 512 * 3;
//       end
//       else begin
//         weight_3_raddr <= weight_3_raddr + 1;
//       end

//       weight_4_rvalid <= 1;
//       if (weight_4_raddr == 512 * 5 - 1) begin
//         weight_4_raddr <= 512 * 16 + 512 * 4;
//       end
//       else begin
//         weight_4_raddr <= weight_4_raddr + 1;
//       end

//       weight_5_rvalid <= 1;
//       if (weight_5_raddr == 512 * 6 - 1) begin
//         weight_5_raddr <= 512 * 16 + 512 * 5;
//       end
//       else begin
//         weight_5_raddr <= weight_5_raddr + 1;
//       end

//       weight_6_rvalid <= 1;
//       if (weight_6_raddr == 512 * 7 - 1) begin
//         weight_6_raddr <= 512 * 16 + 512 * 6;
//       end
//       else begin
//         weight_6_raddr <= weight_6_raddr + 1;
//       end

//       weight_7_rvalid <= 1;
//       if (weight_7_raddr == 512 * 8 - 1) begin
//         weight_7_raddr <= 512 * 16 + 512 * 7;
//       end
//       else begin
//         weight_7_raddr <= weight_7_raddr + 1;
//       end

//       weight_8_rvalid <= 1;
//       if (weight_8_raddr == 512 * 9 - 1) begin
//         weight_8_raddr <= 512 * 16 + 512 * 8;
//       end
//       else begin
//         weight_8_raddr <= weight_8_raddr + 1;
//       end

//       weight_9_rvalid <= 1;
//       if (weight_9_raddr == 512 * 10 - 1) begin
//         weight_9_raddr <= 512 * 16 + 512 * 9;
//       end
//       else begin
//         weight_9_raddr <= weight_9_raddr + 1;
//       end

//       weight_a_rvalid <= 1;
//       if (weight_a_raddr == 512 * 11 - 1) begin
//         weight_a_raddr <= 512 * 16 + 512 * 10;
//       end
//       else begin
//         weight_a_raddr <= weight_a_raddr + 1;
//       end

//       weight_b_rvalid <= 1;
//       if (weight_b_raddr == 512 * 12 - 1) begin
//         weight_b_raddr <= 512 * 16 + 512 * 11;
//       end
//       else begin
//         weight_b_raddr <= weight_b_raddr + 1;
//       end

//       weight_c_rvalid <= 1;
//       if (weight_c_raddr == 512 * 13 - 1) begin
//         weight_c_raddr <= 512 * 16 + 512 * 12;
//       end
//       else begin
//         weight_c_raddr <= weight_c_raddr + 1;
//       end

//       weight_d_rvalid <= 1;
//       if (weight_d_raddr == 512 * 14 - 1) begin
//         weight_d_raddr <= 512 * 16 + 512 * 13;
//       end
//       else begin
//         weight_d_raddr <= weight_d_raddr + 1;
//       end

//       weight_e_rvalid <= 1;
//       if (weight_e_raddr == 512 * 15 - 1) begin
//         weight_e_raddr <= 512 * 16 + 512 * 14;
//       end
//       else begin
//         weight_e_raddr <= weight_e_raddr + 1;
//       end

//       weight_f_rvalid <= 1;
//       if (weight_f_raddr == 512 * 16 - 1) begin
//         weight_f_raddr <= 512 * 16 + 512 * 15;
//       end
//       else begin
//         weight_f_raddr <= weight_f_raddr + 1;
//       end

//       if (weight_f_raddr == 512 * 16 + 512 * 16 - 1) begin
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
//     weight_0_rvalid  <= 0;
//     weight_0_raddr   <= -1;
//     weight_1_rvalid  <= 0;
//     weight_1_raddr   <= 512 - 1;
//     weight_2_rvalid  <= 0;
//     weight_2_raddr   <= 512 * 2 - 1;
//     weight_3_rvalid  <= 0;
//     weight_3_raddr   <= 512 * 3 - 1;
//     weight_4_rvalid  <= 0;
//     weight_4_raddr   <= 512 * 4 - 1;
//     weight_5_rvalid  <= 0;
//     weight_5_raddr   <= 512 * 5 - 1;
//     weight_6_rvalid  <= 0;
//     weight_6_raddr   <= 512 * 6 - 1;
//     weight_7_rvalid  <= 0;
//     weight_7_raddr   <= 512 * 7 - 1;
//     weight_8_rvalid  <= 0;
//     weight_8_raddr   <= 512 * 8 - 1;
//     weight_9_rvalid  <= 0;
//     weight_9_raddr   <= 512 * 9 - 1;
//     weight_a_rvalid  <= 0;
//     weight_a_raddr   <= 512 * 10 - 1;
//     weight_b_rvalid  <= 0;
//     weight_b_raddr   <= 512 * 11 - 1;
//     weight_c_rvalid  <= 0;
//     weight_c_raddr   <= 512 * 12 - 1;
//     weight_d_rvalid  <= 0;
//     weight_d_raddr   <= 512 * 13 - 1;
//     weight_e_rvalid  <= 0;
//     weight_e_raddr   <= 512 * 14 - 1;
//     weight_f_rvalid  <= 0;
//     weight_f_raddr   <= 512 * 15 - 1;
//   end
//   else begin
//     if (!write_done_flag) begin
//       master_1_wvalid = 1;
//       if (master_1_waddr == 512 - 1) begin
//         master_1_waddr <= 512 * 16;
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

//     if (master_1_waddr == 512 * 16 + 512 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       weight_0_rvalid <= 1;
//       if (weight_0_raddr == 512 - 1) begin
//         weight_0_raddr <= 512 * 16;
//       end
//       else begin
//         weight_0_raddr <= weight_0_raddr + 1;
//       end

//       weight_1_rvalid <= 1;
//       if (weight_1_raddr == 512 * 2 - 1) begin
//         weight_1_raddr <= 512 * 16 + 512;
//       end
//       else begin
//         weight_1_raddr <= weight_1_raddr + 1;
//       end

//       weight_2_rvalid <= 1;
//       if (weight_2_raddr == 512 * 3 - 1) begin
//         weight_2_raddr <= 512 * 16 + 512 * 2;
//       end
//       else begin
//         weight_2_raddr <= weight_2_raddr + 1;
//       end

//       weight_3_rvalid <= 1;
//       if (weight_3_raddr == 512 * 4 - 1) begin
//         weight_3_raddr <= 512 * 16 + 512 * 3;
//       end
//       else begin
//         weight_3_raddr <= weight_3_raddr + 1;
//       end

//       weight_4_rvalid <= 1;
//       if (weight_4_raddr == 512 * 5 - 1) begin
//         weight_4_raddr <= 512 * 16 + 512 * 4;
//       end
//       else begin
//         weight_4_raddr <= weight_4_raddr + 1;
//       end

//       weight_5_rvalid <= 1;
//       if (weight_5_raddr == 512 * 6 - 1) begin
//         weight_5_raddr <= 512 * 16 + 512 * 5;
//       end
//       else begin
//         weight_5_raddr <= weight_5_raddr + 1;
//       end

//       weight_6_rvalid <= 1;
//       if (weight_6_raddr == 512 * 7 - 1) begin
//         weight_6_raddr <= 512 * 16 + 512 * 6;
//       end
//       else begin
//         weight_6_raddr <= weight_6_raddr + 1;
//       end

//       weight_7_rvalid <= 1;
//       if (weight_7_raddr == 512 * 8 - 1) begin
//         weight_7_raddr <= 512 * 16 + 512 * 7;
//       end
//       else begin
//         weight_7_raddr <= weight_7_raddr + 1;
//       end

//       weight_8_rvalid <= 1;
//       if (weight_8_raddr == 512 * 9 - 1) begin
//         weight_8_raddr <= 512 * 16 + 512 * 8;
//       end
//       else begin
//         weight_8_raddr <= weight_8_raddr + 1;
//       end

//       weight_9_rvalid <= 1;
//       if (weight_9_raddr == 512 * 10 - 1) begin
//         weight_9_raddr <= 512 * 16 + 512 * 9;
//       end
//       else begin
//         weight_9_raddr <= weight_9_raddr + 1;
//       end

//       weight_a_rvalid <= 1;
//       if (weight_a_raddr == 512 * 11 - 1) begin
//         weight_a_raddr <= 512 * 16 + 512 * 10;
//       end
//       else begin
//         weight_a_raddr <= weight_a_raddr + 1;
//       end

//       weight_b_rvalid <= 1;
//       if (weight_b_raddr == 512 * 12 - 1) begin
//         weight_b_raddr <= 512 * 16 + 512 * 11;
//       end
//       else begin
//         weight_b_raddr <= weight_b_raddr + 1;
//       end

//       weight_c_rvalid <= 1;
//       if (weight_c_raddr == 512 * 13 - 1) begin
//         weight_c_raddr <= 512 * 16 + 512 * 12;
//       end
//       else begin
//         weight_c_raddr <= weight_c_raddr + 1;
//       end

//       weight_d_rvalid <= 1;
//       if (weight_d_raddr == 512 * 14 - 1) begin
//         weight_d_raddr <= 512 * 16 + 512 * 13;
//       end
//       else begin
//         weight_d_raddr <= weight_d_raddr + 1;
//       end

//       weight_e_rvalid <= 1;
//       if (weight_e_raddr == 512 * 15 - 1) begin
//         weight_e_raddr <= 512 * 16 + 512 * 14;
//       end
//       else begin
//         weight_e_raddr <= weight_e_raddr + 1;
//       end

//       weight_f_rvalid <= 1;
//       if (weight_f_raddr == 512 * 16 - 1) begin
//         weight_f_raddr <= 512 * 16 + 512 * 15;
//       end
//       else begin
//         weight_f_raddr <= weight_f_raddr + 1;
//       end

//       if (weight_f_raddr == 512 * 16 + 512 * 16 - 1) begin
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
//     weight_0_rvalid  <= 0;
//     weight_0_raddr   <= -1;
//     weight_4_rvalid  <= 0;
//     weight_4_raddr   <= 512 * 4 - 1;
//     weight_8_rvalid  <= 0;
//     weight_8_raddr   <= 512 * 8 - 1;
//     weight_c_rvalid  <= 0;
//     weight_c_raddr   <= 512 * 12 - 1;
//   end
//   else begin
//     if (!write_done_flag) begin
//       slave_wvalid = 1;
//       if (slave_waddr == 512 * 4 - 1) begin
//         slave_waddr <= 512 * 16;
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

//     if (slave_waddr == 512 * 16 + 512 * 4 - 1) begin
//       write_done_flag <= 1;
//     end

//     if (write_done_flag) begin
//       weight_0_rvalid <= 1;
//       if (weight_0_raddr == 512 * 4 - 1) begin
//         weight_0_raddr <= 512 * 16;
//       end
//       else begin
//         weight_0_raddr <= weight_0_raddr + 1;
//       end

//       weight_4_rvalid <= 1;
//       if (weight_4_raddr == 512 * 8 - 1) begin
//         weight_4_raddr <= 512 * 16 + 512 * 4;
//       end
//       else begin
//         weight_4_raddr <= weight_4_raddr + 1;
//       end

//       weight_8_rvalid <= 1;
//       if (weight_8_raddr == 512 * 12 - 1) begin
//         weight_8_raddr <= 512 * 16 + 512 * 8;
//       end
//       else begin
//         weight_8_raddr <= weight_8_raddr + 1;
//       end

//       weight_c_rvalid <= 1;
//       if (weight_c_raddr == 512 * 16 - 1) begin
//         weight_c_raddr <= 512 * 16 + 512 * 12;
//       end
//       else begin
//         weight_c_raddr <= weight_c_raddr + 1;
//       end

//       if (weight_c_raddr == 512 * 16 + 512 * 16 - 1) begin
//         $finish;
//       end

//     end
//   end
// end

endmodule