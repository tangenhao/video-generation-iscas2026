module ofmap_ram_tb();

parameter OFMAP_WIDTH      = 256;
parameter OFMAP_ADDR_BITS  = 13;
parameter BANK             = 16;

reg                        clk;
reg                        rst_n;
reg                        ofmap_0_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_0_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_0_wdata;
reg                        ofmap_1_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_1_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_1_wdata;
reg                        ofmap_2_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_2_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_2_wdata;
reg                        ofmap_3_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_3_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_3_wdata;
reg                        ofmap_4_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_4_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_4_wdata;
reg                        ofmap_5_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_5_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_5_wdata;
reg                        ofmap_6_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_6_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_6_wdata;
reg                        ofmap_7_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_7_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_7_wdata;
reg                        ofmap_8_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_8_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_8_wdata;
reg                        ofmap_9_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_9_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_9_wdata;
reg                        ofmap_a_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_a_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_a_wdata;
reg                        ofmap_b_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_b_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_b_wdata;
reg                        ofmap_c_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_c_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_c_wdata;
reg                        ofmap_d_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_d_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_d_wdata;
reg                        ofmap_e_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_e_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_e_wdata;
reg                        ofmap_f_wvalid;
reg  [OFMAP_ADDR_BITS-1:0] ofmap_f_waddr;
reg  [OFMAP_WIDTH-1:0]     ofmap_f_wdata;
reg                        master_0_rvalid;
reg  [OFMAP_ADDR_BITS-1:0] master_0_raddr;
reg                        master_1_rvalid;
reg  [OFMAP_ADDR_BITS-1:0] master_1_raddr;
reg                        slave_rvalid;
reg  [OFMAP_ADDR_BITS-1:0] slave_raddr;

wire                   ofmap_0_wready;
wire                   ofmap_1_wready;
wire                   ofmap_2_wready;
wire                   ofmap_3_wready;
wire                   ofmap_4_wready;
wire                   ofmap_5_wready;
wire                   ofmap_6_wready;
wire                   ofmap_7_wready;
wire                   ofmap_8_wready;
wire                   ofmap_9_wready;
wire                   ofmap_a_wready;
wire                   ofmap_b_wready;
wire                   ofmap_c_wready;
wire                   ofmap_d_wready;
wire                   ofmap_e_wready;
wire                   ofmap_f_wready;
wire [OFMAP_WIDTH-1:0] master_0_rdata;
wire                   master_0_rready;
wire [OFMAP_WIDTH-1:0] master_1_rdata;
wire                   master_1_rready;
wire [OFMAP_WIDTH-1:0] slave_rdata;
wire                   slave_rready;


ofmap_ram #(
  .OFMAP_WIDTH     ( OFMAP_WIDTH     ),
  .OFMAP_ADDR_BITS ( OFMAP_ADDR_BITS ),
  .BANK            ( BANK            )
) u_ofmap_ram(
  .clk             ( clk             ),
  .rst_n           ( rst_n           ),
  .ofmap_0_wvalid  ( ofmap_0_wvalid  ),
  .ofmap_0_waddr   ( ofmap_0_waddr   ),
  .ofmap_0_wdata   ( ofmap_0_wdata   ),
  .ofmap_1_wvalid  ( ofmap_1_wvalid  ),
  .ofmap_1_waddr   ( ofmap_1_waddr   ),
  .ofmap_1_wdata   ( ofmap_1_wdata   ),
  .ofmap_2_wvalid  ( ofmap_2_wvalid  ),
  .ofmap_2_waddr   ( ofmap_2_waddr   ),
  .ofmap_2_wdata   ( ofmap_2_wdata   ),
  .ofmap_3_wvalid  ( ofmap_3_wvalid  ),
  .ofmap_3_waddr   ( ofmap_3_waddr   ),
  .ofmap_3_wdata   ( ofmap_3_wdata   ),
  .ofmap_4_wvalid  ( ofmap_4_wvalid  ),
  .ofmap_4_waddr   ( ofmap_4_waddr   ),
  .ofmap_4_wdata   ( ofmap_4_wdata   ),
  .ofmap_5_wvalid  ( ofmap_5_wvalid  ),
  .ofmap_5_waddr   ( ofmap_5_waddr   ),
  .ofmap_5_wdata   ( ofmap_5_wdata   ),
  .ofmap_6_wvalid  ( ofmap_6_wvalid  ),
  .ofmap_6_waddr   ( ofmap_6_waddr   ),
  .ofmap_6_wdata   ( ofmap_6_wdata   ),
  .ofmap_7_wvalid  ( ofmap_7_wvalid  ),
  .ofmap_7_waddr   ( ofmap_7_waddr   ),
  .ofmap_7_wdata   ( ofmap_7_wdata   ),
  .ofmap_8_wvalid  ( ofmap_8_wvalid  ),
  .ofmap_8_waddr   ( ofmap_8_waddr   ),
  .ofmap_8_wdata   ( ofmap_8_wdata   ),
  .ofmap_9_wvalid  ( ofmap_9_wvalid  ),
  .ofmap_9_waddr   ( ofmap_9_waddr   ),
  .ofmap_9_wdata   ( ofmap_9_wdata   ),
  .ofmap_a_wvalid  ( ofmap_a_wvalid  ),
  .ofmap_a_waddr   ( ofmap_a_waddr   ),
  .ofmap_a_wdata   ( ofmap_a_wdata   ),
  .ofmap_b_wvalid  ( ofmap_b_wvalid  ),
  .ofmap_b_waddr   ( ofmap_b_waddr   ),
  .ofmap_b_wdata   ( ofmap_b_wdata   ),
  .ofmap_c_wvalid  ( ofmap_c_wvalid  ),
  .ofmap_c_waddr   ( ofmap_c_waddr   ),
  .ofmap_c_wdata   ( ofmap_c_wdata   ),
  .ofmap_d_wvalid  ( ofmap_d_wvalid  ),
  .ofmap_d_waddr   ( ofmap_d_waddr   ),
  .ofmap_d_wdata   ( ofmap_d_wdata   ),
  .ofmap_e_wvalid  ( ofmap_e_wvalid  ),
  .ofmap_e_waddr   ( ofmap_e_waddr   ),
  .ofmap_e_wdata   ( ofmap_e_wdata   ),
  .ofmap_f_wvalid  ( ofmap_f_wvalid  ),
  .ofmap_f_waddr   ( ofmap_f_waddr   ),
  .ofmap_f_wdata   ( ofmap_f_wdata   ),
  .master_0_rvalid ( master_0_rvalid ),
  .master_0_raddr  ( master_0_raddr  ),
  .master_1_rvalid ( master_1_rvalid ),
  .master_1_raddr  ( master_1_raddr  ),
  .slave_rvalid    ( slave_rvalid    ),
  .slave_raddr     ( slave_raddr     ),
  .ofmap_0_wready  ( ofmap_0_wready  ),
  .ofmap_1_wready  ( ofmap_1_wready  ),
  .ofmap_2_wready  ( ofmap_2_wready  ),
  .ofmap_3_wready  ( ofmap_3_wready  ),
  .ofmap_4_wready  ( ofmap_4_wready  ),
  .ofmap_5_wready  ( ofmap_5_wready  ),
  .ofmap_6_wready  ( ofmap_6_wready  ),
  .ofmap_7_wready  ( ofmap_7_wready  ),
  .ofmap_8_wready  ( ofmap_8_wready  ),
  .ofmap_9_wready  ( ofmap_9_wready  ),
  .ofmap_a_wready  ( ofmap_a_wready  ),
  .ofmap_b_wready  ( ofmap_b_wready  ),
  .ofmap_c_wready  ( ofmap_c_wready  ),
  .ofmap_d_wready  ( ofmap_d_wready  ),
  .ofmap_e_wready  ( ofmap_e_wready  ),
  .ofmap_f_wready  ( ofmap_f_wready  ),
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
  ofmap_0_wvalid = 0;
  ofmap_0_waddr = 0;
  ofmap_0_wdata = 0;
  ofmap_1_wvalid = 0;
  ofmap_1_waddr = 0;
  ofmap_1_wdata = 0;
  ofmap_2_wvalid = 0;
  ofmap_2_waddr = 0;
  ofmap_2_wdata = 0;
  ofmap_3_wvalid = 0;
  ofmap_3_waddr = 0;
  ofmap_3_wdata = 0;
  ofmap_4_wvalid = 0;
  ofmap_4_waddr = 0;
  ofmap_4_wdata = 0;
  ofmap_5_wvalid = 0;
  ofmap_5_waddr = 0;
  ofmap_5_wdata = 0;
  ofmap_6_wvalid = 0;
  ofmap_6_waddr = 0;
  ofmap_6_wdata = 0;
  ofmap_7_wvalid = 0;
  ofmap_7_waddr = 0;
  ofmap_7_wdata = 0;
  ofmap_8_wvalid = 0;
  ofmap_8_waddr = 0;
  ofmap_8_wdata = 0;
  ofmap_9_wvalid = 0;
  ofmap_9_waddr = 0;
  ofmap_9_wdata = 0;
  ofmap_a_wvalid = 0;
  ofmap_a_waddr = 0;
  ofmap_a_wdata = 0;
  ofmap_b_wvalid = 0;
  ofmap_b_waddr = 0;
  ofmap_b_wdata = 0;
  ofmap_c_wvalid = 0;
  ofmap_c_waddr = 0;
  ofmap_c_wdata = 0;
  ofmap_d_wvalid = 0;
  ofmap_d_waddr = 0;
  ofmap_d_wdata = 0;
  ofmap_e_wvalid = 0;
  ofmap_e_waddr = 0;
  ofmap_e_wdata = 0;
  ofmap_f_wvalid = 0;
  ofmap_f_waddr = 0;
  ofmap_f_wdata = 0;
  master_0_rvalid = 0;
  master_0_raddr = 0;
  master_1_rvalid = 0;
  master_1_raddr = 0;
  slave_rvalid = 0;
  slave_raddr = 0;

  #10 rst_n = 1;
end

always begin
  #5 clk = ~clk;
end

initial begin
  $fsdbDumpfile("ofmap_ram_tb.fsdb");
  $fsdbDumpvars(0, "ofmap_ram_tb");
  $fsdbDumpMDA();
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                           multi core write read                                          */
/* -------------------------------------------------------------------------------------------------------- */

reg write_done;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ofmap_0_wvalid <= 0;
    ofmap_0_waddr <= 0;
    ofmap_0_wdata <= 0;
    ofmap_1_wvalid <= 0;
    ofmap_1_waddr <= 256;
    ofmap_1_wdata <= 0;
    ofmap_2_wvalid <= 0;
    ofmap_2_waddr <= 256 * 2;
    ofmap_2_wdata <= 0;
    ofmap_3_wvalid <= 0;
    ofmap_3_waddr <= 256 * 3;
    ofmap_3_wdata <= 0;
    ofmap_4_wvalid <= 0;
    ofmap_4_waddr <= 256 * 4;
    ofmap_4_wdata <= 0;
    ofmap_5_wvalid <= 0;
    ofmap_5_waddr <= 256 * 5;
    ofmap_5_wdata <= 0;
    ofmap_6_wvalid <= 0;
    ofmap_6_waddr <= 256 * 6;
    ofmap_6_wdata <= 0;
    ofmap_7_wvalid <= 0;
    ofmap_7_waddr <= 256 * 7;
    ofmap_7_wdata <= 0;
    ofmap_8_wvalid <= 0;
    ofmap_8_waddr <= 256 * 8;
    ofmap_8_wdata <= 0;
    ofmap_9_wvalid <= 0;
    ofmap_9_waddr <= 256 * 9;
    ofmap_9_wdata <= 0;
    ofmap_a_wvalid <= 0;
    ofmap_a_waddr <= 256 * 10;
    ofmap_a_wdata <= 0;
    ofmap_b_wvalid <= 0;
    ofmap_b_waddr <= 256 * 11;
    ofmap_b_wdata <= 0;
    ofmap_c_wvalid <= 0;
    ofmap_c_waddr <= 256 * 12;
    ofmap_c_wdata <= 0;
    ofmap_d_wvalid <= 0;
    ofmap_d_waddr <= 256 * 13;
    ofmap_d_wdata <= 0;
    ofmap_e_wvalid <= 0;
    ofmap_e_waddr <= 256 * 14;
    ofmap_e_wdata <= 0;
    ofmap_f_wvalid <= 0;
    ofmap_f_waddr <= 256 * 15;
    ofmap_f_wdata <= 0;
    master_0_raddr <= 0;
    master_0_rvalid <= 0;
    write_done <= 0;
  end
  else begin
    if (!write_done) begin
      ofmap_0_wvalid <= 1;
      ofmap_1_wvalid <= 1;
      ofmap_2_wvalid <= 1;
      ofmap_3_wvalid <= 1;
      ofmap_4_wvalid <= 1;
      ofmap_5_wvalid <= 1;
      ofmap_6_wvalid <= 1;
      ofmap_7_wvalid <= 1;
      ofmap_8_wvalid <= 1;
      ofmap_9_wvalid <= 1;
      ofmap_a_wvalid <= 1;
      ofmap_b_wvalid <= 1;
      ofmap_c_wvalid <= 1;
      ofmap_d_wvalid <= 1;
      ofmap_e_wvalid <= 1;
      ofmap_f_wvalid <= 1;
    
      if (ofmap_0_waddr == 255) begin
        write_done = 1;
      end

      ofmap_0_waddr <= ofmap_0_waddr + 1;
      ofmap_1_waddr <= ofmap_1_waddr + 1;
      ofmap_2_waddr <= ofmap_2_waddr + 1;
      ofmap_3_waddr <= ofmap_3_waddr + 1;
      ofmap_4_waddr <= ofmap_4_waddr + 1;
      ofmap_5_waddr <= ofmap_5_waddr + 1;
      ofmap_6_waddr <= ofmap_6_waddr + 1;
      ofmap_7_waddr <= ofmap_7_waddr + 1;
      ofmap_8_waddr <= ofmap_8_waddr + 1;
      ofmap_9_waddr <= ofmap_9_waddr + 1;
      ofmap_a_waddr <= ofmap_a_waddr + 1;
      ofmap_b_waddr <= ofmap_b_waddr + 1;
      ofmap_c_waddr <= ofmap_c_waddr + 1;
      ofmap_d_waddr <= ofmap_d_waddr + 1;
      ofmap_e_waddr <= ofmap_e_waddr + 1;
      ofmap_f_waddr <= ofmap_f_waddr + 1;

      ofmap_0_wdata <= ofmap_0_wdata + 1;
      ofmap_1_wdata <= ofmap_1_wdata + 1;
      ofmap_2_wdata <= ofmap_2_wdata + 1;
      ofmap_3_wdata <= ofmap_3_wdata + 1;
      ofmap_4_wdata <= ofmap_4_wdata + 1;
      ofmap_5_wdata <= ofmap_5_wdata + 1;
      ofmap_6_wdata <= ofmap_6_wdata + 1;
      ofmap_7_wdata <= ofmap_7_wdata + 1;
      ofmap_8_wdata <= ofmap_8_wdata + 1;
      ofmap_9_wdata <= ofmap_9_wdata + 1;
      ofmap_a_wdata <= ofmap_a_wdata + 1;
      ofmap_b_wdata <= ofmap_b_wdata + 1;
      ofmap_c_wdata <= ofmap_c_wdata + 1;
      ofmap_d_wdata <= ofmap_d_wdata + 1;
      ofmap_e_wdata <= ofmap_e_wdata + 1;
      ofmap_f_wdata <= ofmap_f_wdata + 1;
    end
    else begin
      
      ofmap_0_wvalid <= 0;
      ofmap_1_wvalid <= 0;
      ofmap_2_wvalid <= 0;
      ofmap_3_wvalid <= 0;
      ofmap_4_wvalid <= 0;
      ofmap_5_wvalid <= 0;
      ofmap_6_wvalid <= 0;
      ofmap_7_wvalid <= 0;
      ofmap_8_wvalid <= 0;
      ofmap_9_wvalid <= 0;
      ofmap_a_wvalid <= 0;
      ofmap_b_wvalid <= 0;
      ofmap_c_wvalid <= 0;
      ofmap_d_wvalid <= 0;
      ofmap_e_wvalid <= 0;
      ofmap_f_wvalid <= 0;

      master_0_raddr <= master_0_raddr + 1;
      master_0_rvalid <= 1;
    
      if (master_0_raddr == 256 * 16 - 1) begin
        master_0_raddr <= 0;
        write_done = 0;
        $finish;
      end
    end

  end

end

endmodule