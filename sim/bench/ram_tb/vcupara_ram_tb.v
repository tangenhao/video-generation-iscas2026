module vcupara_ram_tb();

parameter VCUPARA_WIDTH      = 1024;
parameter VCUPARA_ADDR_BITS  = 6;
parameter BANK               = 16;
parameter BANK_BITS          = 4;

reg                                    clk;
reg                                    rst_n;
reg                                    broadcast;
reg  [BANK-1:0]                        broadcast_mask;
reg                                    vcupara_0_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_0_raddr;
reg                                    vcupara_1_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_1_raddr;
reg                                    vcupara_2_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_2_raddr;
reg                                    vcupara_3_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_3_raddr;
reg                                    vcupara_4_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_4_raddr;
reg                                    vcupara_5_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_5_raddr;
reg                                    vcupara_6_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_6_raddr;
reg                                    vcupara_7_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_7_raddr;
reg                                    vcupara_8_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_8_raddr;
reg                                    vcupara_9_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_9_raddr;
reg                                    vcupara_a_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_a_raddr;
reg                                    vcupara_b_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_b_raddr;
reg                                    vcupara_c_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_c_raddr;
reg                                    vcupara_d_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_d_raddr;
reg                                    vcupara_e_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_e_raddr;
reg                                    vcupara_f_rvalid;
reg  [VCUPARA_ADDR_BITS-1:0]           vcupara_f_raddr;
reg                                    master_0_wvalid;
reg  [VCUPARA_ADDR_BITS+BANK_BITS-1:0] master_0_waddr;
reg  [VCUPARA_WIDTH-1:0]               master_0_wdata;
reg                                    master_1_wvalid;
reg  [VCUPARA_ADDR_BITS+BANK_BITS-1:0] master_1_waddr;
reg  [VCUPARA_WIDTH-1:0]               master_1_wdata;
reg                                    slave_wvalid;
reg  [VCUPARA_ADDR_BITS+BANK_BITS-1:0] slave_waddr;
reg  [VCUPARA_WIDTH-1:0]               slave_wdata;

wire [VCUPARA_WIDTH-1:0] vcupara_0_rdata;
wire                     vcupara_0_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_1_rdata;
wire                     vcupara_1_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_2_rdata;
wire                     vcupara_2_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_3_rdata;
wire                     vcupara_3_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_4_rdata;
wire                     vcupara_4_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_5_rdata;
wire                     vcupara_5_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_6_rdata;
wire                     vcupara_6_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_7_rdata;
wire                     vcupara_7_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_8_rdata;
wire                     vcupara_8_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_9_rdata;
wire                     vcupara_9_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_a_rdata;
wire                     vcupara_a_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_b_rdata;
wire                     vcupara_b_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_c_rdata;
wire                     vcupara_c_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_d_rdata;
wire                     vcupara_d_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_e_rdata;
wire                     vcupara_e_rready;
wire [VCUPARA_WIDTH-1:0] vcupara_f_rdata;
wire                     vcupara_f_rready;
wire                     master_0_wready;
wire                     master_1_wready;
wire                     slave_wready;


vcupara_ram #(
    .VCUPARA_WIDTH     ( VCUPARA_WIDTH     ),
    .VCUPARA_ADDR_BITS ( VCUPARA_ADDR_BITS ),
    .BANK              ( BANK              )
) u_vcupara_ram(
    .clk              ( clk              ),
    .rst_n            ( rst_n            ),
    .broadcast        ( broadcast        ),
    .broadcast_mask   ( broadcast_mask   ),
    .vcupara_0_rvalid ( vcupara_0_rvalid ),
    .vcupara_0_raddr  ( vcupara_0_raddr  ),
    .vcupara_1_rvalid ( vcupara_1_rvalid ),
    .vcupara_1_raddr  ( vcupara_1_raddr  ),
    .vcupara_2_rvalid ( vcupara_2_rvalid ),
    .vcupara_2_raddr  ( vcupara_2_raddr  ),
    .vcupara_3_rvalid ( vcupara_3_rvalid ),
    .vcupara_3_raddr  ( vcupara_3_raddr  ),
    .vcupara_4_rvalid ( vcupara_4_rvalid ),
    .vcupara_4_raddr  ( vcupara_4_raddr  ),
    .vcupara_5_rvalid ( vcupara_5_rvalid ),
    .vcupara_5_raddr  ( vcupara_5_raddr  ),
    .vcupara_6_rvalid ( vcupara_6_rvalid ),
    .vcupara_6_raddr  ( vcupara_6_raddr  ),
    .vcupara_7_rvalid ( vcupara_7_rvalid ),
    .vcupara_7_raddr  ( vcupara_7_raddr  ),
    .vcupara_8_rvalid ( vcupara_8_rvalid ),
    .vcupara_8_raddr  ( vcupara_8_raddr  ),
    .vcupara_9_rvalid ( vcupara_9_rvalid ),
    .vcupara_9_raddr  ( vcupara_9_raddr  ),
    .vcupara_a_rvalid ( vcupara_a_rvalid ),
    .vcupara_a_raddr  ( vcupara_a_raddr  ),
    .vcupara_b_rvalid ( vcupara_b_rvalid ),
    .vcupara_b_raddr  ( vcupara_b_raddr  ),
    .vcupara_c_rvalid ( vcupara_c_rvalid ),
    .vcupara_c_raddr  ( vcupara_c_raddr  ),
    .vcupara_d_rvalid ( vcupara_d_rvalid ),
    .vcupara_d_raddr  ( vcupara_d_raddr  ),
    .vcupara_e_rvalid ( vcupara_e_rvalid ),
    .vcupara_e_raddr  ( vcupara_e_raddr  ),
    .vcupara_f_rvalid ( vcupara_f_rvalid ),
    .vcupara_f_raddr  ( vcupara_f_raddr  ),
    .master_0_wvalid  ( master_0_wvalid  ),
    .master_0_waddr   ( master_0_waddr   ),
    .master_0_wdata   ( master_0_wdata   ),
    .master_1_wvalid  ( master_1_wvalid  ),
    .master_1_waddr   ( master_1_waddr   ),
    .master_1_wdata   ( master_1_wdata   ),
    .slave_wvalid     ( slave_wvalid     ),
    .slave_waddr      ( slave_waddr      ),
    .slave_wdata      ( slave_wdata      ),
    .vcupara_0_rdata  ( vcupara_0_rdata  ),
    .vcupara_0_rready ( vcupara_0_rready ),
    .vcupara_1_rdata  ( vcupara_1_rdata  ),
    .vcupara_1_rready ( vcupara_1_rready ),
    .vcupara_2_rdata  ( vcupara_2_rdata  ),
    .vcupara_2_rready ( vcupara_2_rready ),
    .vcupara_3_rdata  ( vcupara_3_rdata  ),
    .vcupara_3_rready ( vcupara_3_rready ),
    .vcupara_4_rdata  ( vcupara_4_rdata  ),
    .vcupara_4_rready ( vcupara_4_rready ),
    .vcupara_5_rdata  ( vcupara_5_rdata  ),
    .vcupara_5_rready ( vcupara_5_rready ),
    .vcupara_6_rdata  ( vcupara_6_rdata  ),
    .vcupara_6_rready ( vcupara_6_rready ),
    .vcupara_7_rdata  ( vcupara_7_rdata  ),
    .vcupara_7_rready ( vcupara_7_rready ),
    .vcupara_8_rdata  ( vcupara_8_rdata  ),
    .vcupara_8_rready ( vcupara_8_rready ),
    .vcupara_9_rdata  ( vcupara_9_rdata  ),
    .vcupara_9_rready ( vcupara_9_rready ),
    .vcupara_a_rdata  ( vcupara_a_rdata  ),
    .vcupara_a_rready ( vcupara_a_rready ),
    .vcupara_b_rdata  ( vcupara_b_rdata  ),
    .vcupara_b_rready ( vcupara_b_rready ),
    .vcupara_c_rdata  ( vcupara_c_rdata  ),
    .vcupara_c_rready ( vcupara_c_rready ),
    .vcupara_d_rdata  ( vcupara_d_rdata  ),
    .vcupara_d_rready ( vcupara_d_rready ),
    .vcupara_e_rdata  ( vcupara_e_rdata  ),
    .vcupara_e_rready ( vcupara_e_rready ),
    .vcupara_f_rdata  ( vcupara_f_rdata  ),
    .vcupara_f_rready ( vcupara_f_rready ),
    .master_0_wready  ( master_0_wready  ),
    .master_1_wready  ( master_1_wready  ),
    .slave_wready     ( slave_wready     )
);

initial begin
  $fsdbDumpfile("vcupara_ram_tb.fsdb");
  $fsdbDumpvars(0, "vcupara_ram_tb");
  $fsdbDumpMDA();
end

initial begin
  clk = 0;
  rst_n = 0;
  broadcast = 0;
  broadcast_mask = 0;
  vcupara_0_rvalid = 0;
  vcupara_0_raddr = 0;
  vcupara_1_rvalid = 0;
  vcupara_1_raddr = 0;
  vcupara_2_rvalid = 0;
  vcupara_2_raddr = 0;
  vcupara_3_rvalid = 0;
  vcupara_3_raddr = 0;
  vcupara_4_rvalid = 0;
  vcupara_4_raddr = 0;
  vcupara_5_rvalid = 0;
  vcupara_5_raddr = 0;
  vcupara_6_rvalid = 0;
  vcupara_6_raddr = 0;
  vcupara_7_rvalid = 0;
  vcupara_7_raddr = 0;
  vcupara_8_rvalid = 0;
  vcupara_8_raddr = 0;
  vcupara_9_rvalid = 0;
  vcupara_9_raddr = 0;
  vcupara_a_rvalid = 0;
  vcupara_a_raddr = 0;
  vcupara_b_rvalid = 0;
  vcupara_b_raddr = 0;
  vcupara_c_rvalid = 0;
  vcupara_c_raddr = 0;
  vcupara_d_rvalid = 0;
  vcupara_d_raddr = 0;
  vcupara_e_rvalid = 0;
  vcupara_e_raddr = 0;
  vcupara_f_rvalid = 0;
  vcupara_f_raddr = 0;
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

reg write_done_flag;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    master_1_wvalid <= 0;
    master_1_waddr <= -1;
    master_1_wdata <= -1;
    write_done_flag <= 0;
    vcupara_0_rvalid  <= 0;
    vcupara_0_raddr   <= -1;
    vcupara_1_rvalid  <= 0;
    vcupara_1_raddr   <= 64 - 1;
    vcupara_2_rvalid  <= 0;
    vcupara_2_raddr   <= 64 * 2 - 1;
    vcupara_3_rvalid  <= 0;
    vcupara_3_raddr   <= 64 * 3 - 1;
    vcupara_4_rvalid  <= 0;
    vcupara_4_raddr   <= 64 * 4 - 1;
    vcupara_5_rvalid  <= 0;
    vcupara_5_raddr   <= 64 * 5 - 1;
    vcupara_6_rvalid  <= 0;
    vcupara_6_raddr   <= 64 * 6 - 1;
    vcupara_7_rvalid  <= 0;
    vcupara_7_raddr   <= 64 * 7 - 1;
    vcupara_8_rvalid  <= 0;
    vcupara_8_raddr   <= 64 * 8 - 1;
    vcupara_9_rvalid  <= 0;
    vcupara_9_raddr   <= 64 * 9 - 1;
    vcupara_a_rvalid  <= 0;
    vcupara_a_raddr   <= 64 * 10 - 1;
    vcupara_b_rvalid  <= 0;
    vcupara_b_raddr   <= 64 * 11 - 1;
    vcupara_c_rvalid  <= 0;
    vcupara_c_raddr   <= 64 * 12 - 1;
    vcupara_d_rvalid  <= 0;
    vcupara_d_raddr   <= 64 * 13 - 1;
    vcupara_e_rvalid  <= 0;
    vcupara_e_raddr   <= 64 * 14 - 1;
    vcupara_f_rvalid  <= 0;
    vcupara_f_raddr   <= 64 * 15 - 1;
  end
  else begin
    if (!write_done_flag) begin
      master_1_wvalid = 1;
      master_1_waddr <= master_1_waddr + 1;
      master_1_wdata <= master_1_wdata + 1;
    end
    else begin
      master_1_wvalid <= 0;
      master_1_waddr <= 0;
      master_1_wdata <= 0;
    end

    if (master_1_waddr == 64 * 16 - 2) begin
      write_done_flag <= 1;
    end

    if (write_done_flag) begin
      vcupara_0_rvalid <= 1;
      vcupara_0_raddr <= vcupara_0_raddr + 1;

      vcupara_1_rvalid <= 1;
      vcupara_1_raddr <= vcupara_1_raddr + 1;

      vcupara_2_rvalid <= 1;
      vcupara_2_raddr <= vcupara_2_raddr + 1;

      vcupara_3_rvalid <= 1;
      vcupara_3_raddr <= vcupara_3_raddr + 1;

      vcupara_4_rvalid <= 1;
      vcupara_4_raddr <= vcupara_4_raddr + 1;

      vcupara_5_rvalid <= 1;
      vcupara_5_raddr <= vcupara_5_raddr + 1;

      vcupara_6_rvalid <= 1;
      vcupara_6_raddr <= vcupara_6_raddr + 1;

      vcupara_7_rvalid <= 1;
      vcupara_7_raddr <= vcupara_7_raddr + 1;

      vcupara_8_rvalid <= 1;
      vcupara_8_raddr <= vcupara_8_raddr + 1;

      vcupara_9_rvalid <= 1;
      vcupara_9_raddr <= vcupara_9_raddr + 1;

      vcupara_a_rvalid <= 1;
      vcupara_a_raddr <= vcupara_a_raddr + 1;

      vcupara_b_rvalid <= 1;
      vcupara_b_raddr <= vcupara_b_raddr + 1;

      vcupara_c_rvalid <= 1;
      vcupara_c_raddr <= vcupara_c_raddr + 1;

      vcupara_d_rvalid <= 1;
      vcupara_d_raddr <= vcupara_d_raddr + 1;

      vcupara_e_rvalid <= 1;
      vcupara_e_raddr <= vcupara_e_raddr + 1;

      vcupara_f_rvalid <= 1;
      vcupara_f_raddr <= vcupara_f_raddr + 1;

      if (vcupara_f_raddr == 64 - 2) begin
        $finish;
      end

    end
  end
end

endmodule