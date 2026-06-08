module regfile_cluster(
  clk, rst_n,

  mst_wvalid, mst_wready, mst_waddr, mst_wdata,
  mst_rvalid, mst_rready, mst_raddr, mst_rdata,

  slv_wvalid, slv_wready, slv_waddr, slv_wdata,
  slv_rvalid, slv_rready, slv_raddr, slv_rdata,

  psum_load_valid_bits, psum_store_valid_bits, vcures_load_valid_bits, ifmap_mask_load_valid_bits,
  broadcast,
  
  enable_prof_counter,

  load_0_execute_time, store_0_execute_time,
  load_1_execute_time, store_1_execute_time,
  pea_0_execute_time, pea_1_execute_time,
  vcu_0_execute_time, vcu_1_execute_time
);

input               clk;
input               rst_n;

input               mst_wvalid;
output reg          mst_wready;
input       [31:0]  mst_waddr;
input       [31:0]  mst_wdata;

input               mst_rvalid;
output reg          mst_rready;
input       [31:0]  mst_raddr;
output reg  [31:0]  mst_rdata;

input               slv_wvalid;
output reg          slv_wready;
input       [31:0]  slv_waddr;
input       [31:0]  slv_wdata;

input               slv_rvalid;
output reg          slv_rready;
input       [31:0]  slv_raddr;
output reg  [31:0]  slv_rdata;

output wire [1:0]   psum_load_valid_bits;
output wire [1:0]   psum_store_valid_bits;
output wire [1:0]   vcures_load_valid_bits;
output wire [1:0]   ifmap_mask_load_valid_bits;

input       [31:0]  load_0_execute_time;
input       [31:0]  load_1_execute_time;
input       [31:0]  store_0_execute_time;
input       [31:0]  store_1_execute_time;
input       [31:0]  pea_0_execute_time;
input       [31:0]  pea_1_execute_time;
input       [31:0]  vcu_0_execute_time;
input       [31:0]  vcu_1_execute_time;

output wire         enable_prof_counter;
output wire         broadcast;

reg [31:0] config_reg[0:15];

integer reg_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (reg_i = 0; reg_i < 16; reg_i = reg_i + 1) begin
      config_reg[reg_i] <= 0;
    end
    mst_wready <= 1'b0;
    slv_wready <= 1'b0;
  end
  else begin
    if (mst_wvalid) begin
      mst_wready <= 1'b1;
    end
    else begin
      mst_wready <= 1'b0;
    end

    if (slv_wvalid) begin
      slv_wready <= 1'b1;
    end
    else begin
      slv_wready <= 1'b0;
    end

    if (mst_wvalid) begin
      config_reg[mst_waddr] <= mst_wdata;
    end
    else if (slv_wvalid) begin
      config_reg[slv_waddr] <= slv_wdata;
    end
    else begin
      config_reg[6]  <= load_0_execute_time;
      config_reg[7]  <= store_0_execute_time;
      config_reg[8]  <= load_1_execute_time;
      config_reg[9]  <= store_1_execute_time;
      config_reg[10] <= pea_0_execute_time;
      config_reg[11] <= pea_1_execute_time;
      config_reg[12] <= vcu_0_execute_time;
      config_reg[13] <= vcu_1_execute_time;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    mst_rdata  <= 32'd0;
    mst_rready <= 1'b0;
    slv_rdata  <= 32'd0;
    slv_rready <= 1'b0;
  end
  else begin
    if (mst_rvalid) begin
      mst_rready <= 1'b1;
      slv_rready <= 1'b0;
    end
    else if (slv_rvalid) begin
      mst_rready <= 1'b0;
      slv_rready <= 1'b1;
    end
    else begin
      mst_rready <= 1'b0;
      slv_rready <= 1'b0;
    end

    if (mst_rvalid) begin
      mst_rdata <= config_reg[mst_raddr];
    end
    else if (slv_rvalid) begin
      slv_rdata <= config_reg[slv_raddr];
    end
    else begin
      mst_rdata <= mst_rdata;
      slv_rdata <= slv_rdata;
    end
  end
end

assign psum_load_valid_bits       = config_reg[0][1:0];
assign psum_store_valid_bits      = config_reg[1][1:0];
assign vcures_load_valid_bits     = config_reg[2][1:0];
assign ifmap_mask_load_valid_bits = config_reg[3][2:0];
assign enable_prof_counter        = config_reg[4][0];
assign broadcast                  = config_reg[5][0];

endmodule
