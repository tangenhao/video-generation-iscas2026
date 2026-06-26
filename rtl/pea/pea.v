module pea(
  clk, rst_n,
  work_en, insn, insn_read, done,

  ifmap_sram_raddr, ifmap_sram_rvalid, ifmap_sram_rdata,
  weight_sram_raddr, weight_sram_rvalid, weight_sram_rdata,
  ofmap_sram_wvalid, ofmap_sram_waddr, ofmap_sram_wdata,

  enable_prof_counter, execute_time
);

parameter PARALLELISM  = 36;
parameter LANE         = 36;

parameter IFMAP_ADDR_BITS  = 9;
parameter WEIGHT_ADDR_BITS = 14;
parameter OFMAP_ADDR_BITS  = 9;

parameter IFMAP_WIDTH  = 288;
parameter WEIGHT_WIDTH = 288;
parameter OFMAP_WIDTH  = 1152;

parameter MAX_K_GROUPS_BITS = 8;
parameter MAX_N_GROUPS_BITS = 8;

parameter SRAM_DEPTH       = 128;
parameter OFMAP_SRAM_DEPTH = 128;

localparam PEA_CONFIG_INSN     = 0;
localparam GEMM_EXECUTE_INSN   = 2;

localparam NORMAL            = 0;
localparam MLP_UP            = 1;
localparam MLP_DOWN          = 2;
localparam ATT_LINEAR        = 3;


input               clk;
input               rst_n;
input               work_en;
input       [127:0] insn;
output reg          insn_read;
output reg          done;

output wire [IFMAP_ADDR_BITS-1:0]         ifmap_sram_raddr;
output wire                               ifmap_sram_rvalid;
input       [IFMAP_WIDTH-1:0]             ifmap_sram_rdata;

output wire [WEIGHT_ADDR_BITS-1:0]        weight_sram_raddr;
output wire                               weight_sram_rvalid;
input       [WEIGHT_WIDTH*LANE-1:0]       weight_sram_rdata;

output reg                                ofmap_sram_wvalid;
output reg  [OFMAP_ADDR_BITS-1:0]         ofmap_sram_waddr;
output reg  [OFMAP_WIDTH-1:0]             ofmap_sram_wdata;

input                                     enable_prof_counter;
output reg  [31:0]                        execute_time;

reg       insn_valid;
reg       insn_valid_reg;
reg [3:0] insn_number;
reg [127:0] insn_reg;

reg [2:0] insn_kind;
reg       execute_start;

reg config_done;
reg gemm_execute_done;
wire fake_done;

wire [2:0]                      insn_kind_wire;
wire [11:0]                     gemm_tile_m_wire;
wire [7:0]                      gemm_n_groups_wire;
wire [7:0]                      gemm_k_groups_wire;
wire                            gemm_ifmap_highaddr_wire;
wire                            gemm_weight_highaddr_wire;
wire                            gemm_psum_read_flag;
wire                            gemm_psum_write_flag;
wire                            gemm_acc_clear;
wire                            gemm_last_k_groups;


reg [MAX_K_GROUPS_BITS-1:0] real_k_groups;
reg [MAX_N_GROUPS_BITS-1:0] real_n_groups;
reg [1:0]                   gemm_type;

reg [MAX_N_GROUPS_BITS:0]   n_group_cnt;
reg [MAX_K_GROUPS_BITS:0]   k_group_cnt;

reg [MAX_K_GROUPS_BITS-1:0] ifmap_burst_len;
reg [MAX_K_GROUPS_BITS-1:0] weight_burst_len;
reg                         ifmap_highaddr;
reg                         weight_highaddr;

reg [IFMAP_ADDR_BITS-1:0]   ifmap_sram_raddr_reg;
reg                         ifmap_sram_rvalid_reg;
wire [MAX_K_GROUPS_BITS-1:0] cnt_ifmap_burst_len;
reg [IFMAP_ADDR_BITS-1:0]   ifmap_sram_baseaddr;

reg [WEIGHT_ADDR_BITS-1:0]  weight_sram_raddr_reg;
reg                         weight_sram_rvalid_reg;
wire [MAX_K_GROUPS_BITS-1:0] cnt_weight_burst_len;
wire [WEIGHT_WIDTH-1:0]     weight_lane_data[0:LANE-1];
wire                        k_group_last;
wire                        n_group_last;

reg                         acc_clear;

reg                         ifmap_sram_rvalid_d0;
reg                         ifmap_sram_rvalid_d1;
reg                         mpt_valid_pipe;
reg [IFMAP_WIDTH-1:0]       ifmap_regfile;
reg [WEIGHT_WIDTH-1:0]      weight_regfile[0:LANE-1];

wire [31:0]                 mpt_result[0:LANE-1];
wire                        mpt_done;
wire [32*LANE-1:0]          mpt_result_unpack;


/* -------------------------------------------------------------------------------------------------------- */
/*                                            Instruction Decoder                                           */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_read  <= 1'b0;
    insn_valid <= 1'b0;
  end
  else begin
    if (work_en) begin
      insn_read <= 1'b1;
    end
    else if (fake_done && |insn_number) begin
      insn_read <= 1'b1;
    end
    else begin
      insn_read <= 1'b0;
    end

    insn_valid <= insn_read;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_valid_reg <= 1'b0;
    insn_reg       <= 128'd0;
  end
  else begin
    insn_valid_reg <= insn_valid;
    if (insn_valid) begin
      insn_reg <= insn;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_number <= 4'd0;
  end
  else if (insn_valid_reg) begin
    insn_number <= |insn_reg[9:6] ? insn_reg[9:6] : insn_number;
  end
  else if (fake_done && |insn_number) begin
    insn_number <= insn_number - 1'b1;
  end
end

assign insn_kind_wire             = insn_reg[12:10];
assign gemm_tile_m_wire           = insn_reg[33:22];
assign gemm_n_groups_wire         = insn_reg[41:34];
assign gemm_k_groups_wire         = insn_reg[49:42];
assign gemm_ifmap_highaddr_wire   = insn_reg[50];
assign gemm_weight_highaddr_wire  = insn_reg[51];
assign gemm_acc_clear             = insn_reg[53];    //占用psum_highaddr的最高位
assign gemm_last_k_groups         = insn_reg[52];    //占用psum_highaddr的最低位
// assign psum_number                = insn_reg[65:54]; //k_groups维度上，psum写入次数


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_start         <= 'd0;
    insn_kind             <= 'd0;
    real_k_groups         <= 'd0;
    real_n_groups         <= 'd0;
    gemm_type             <= 'd0;

    ifmap_burst_len       <= 'd0;
    weight_burst_len      <= 'd0;
    ifmap_highaddr        <= 'd0;
    weight_highaddr       <= 'd0;
  end
  else begin
    if (insn_valid_reg) begin
      insn_kind           <= insn_kind_wire;
      // if (insn_kind_wire == PEA_CONFIG_INSN) begin
      //   real_k_groups     <= insn_reg[20:13];
      //   real_n_groups     <= insn_reg[28:21];
      //   gemm_type         <= insn_reg[30:29];
      // end
      if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
        execute_start     <= 1;

        ifmap_burst_len   <= gemm_tile_m_wire ;
        weight_burst_len  <= gemm_tile_m_wire ;
        real_k_groups     <= gemm_k_groups_wire ;
        real_n_groups     <= gemm_n_groups_wire ;
        ifmap_highaddr    <= gemm_ifmap_highaddr_wire;
        weight_highaddr   <= gemm_weight_highaddr_wire;
      end
    end
    else begin
      if (fake_done) begin
        execute_start    <= 'd0;
        ifmap_burst_len       <= 'd0;
        weight_burst_len      <= 'd0;
        ifmap_highaddr        <= 'd0;
        weight_highaddr       <= 'd0;
      end
    end
  end
end

`ifdef PEA_DEBUG
always @(posedge clk) begin
  if (rst_n && insn_valid_reg) begin
    $display("[%0t][PEA] insn kind=%0d num=%0d raw=%032h tile_m=%0d n_groups=%0d k_groups=%0d acc_clear=%0d last_k=%0d if_hi=%0d wt_hi=%0d",
             $time, insn_kind_wire, insn_number, insn_reg, gemm_tile_m_wire, gemm_n_groups_wire, gemm_k_groups_wire,
             gemm_acc_clear, gemm_last_k_groups, gemm_ifmap_highaddr_wire, gemm_weight_highaddr_wire);
  end
  if (rst_n && ifmap_sram_rvalid_reg) begin
    $display("[%0t][PEA] rd ifmap_addr=%0d weight_addr=%0d k_cnt=%0d n_cnt=%0d real_k=%0d real_n=%0d cnt_if=%0d cnt_wt=%0d",
             $time, ifmap_sram_raddr, weight_sram_raddr, k_group_cnt, n_group_cnt, real_k_groups, real_n_groups,
             cnt_ifmap_burst_len, cnt_weight_burst_len);
  end
  if (rst_n && mpt_valid_pipe) begin
    $display("[%0t][PEA] mpt_valid acc_clear=%0d lane0_ifmap=%072h lane0_weight=%072h",
             $time, acc_clear, ifmap_regfile, weight_regfile[0]);
  end
  if (rst_n && mpt_done) begin
    $display("[%0t][PEA] mpt_done insn_kind_wire=%0d insn_kind=%0d last_k_wire=%0d out_wvalid_next=%0d lane0=%08h lane1=%08h",
             $time, insn_kind_wire, insn_kind, gemm_last_k_groups, gemm_last_k_groups, mpt_result[0], mpt_result[1]);
  end
  if (rst_n && ofmap_sram_wvalid) begin
    $display("[%0t][PEA] ofmap_write addr=%0d data0=%08h data1=%08h data35=%08h",
             $time, ofmap_sram_waddr, ofmap_sram_wdata[31:0], ofmap_sram_wdata[63:32], ofmap_sram_wdata[1151:1120]);
  end
  if (rst_n && done) begin
    $display("[%0t][PEA] done insn_number=%0d", $time, insn_number);
  end
end
`endif


/* -------------------------------------------------------------------------------------------------------- */
/*                                           Execution Controller                                           */
/* -------------------------------------------------------------------------------------------------------- */

assign  k_group_last = (weight_sram_rvalid_reg && k_group_cnt == real_k_groups - 1);
assign  n_group_last = (weight_sram_rvalid_reg && n_group_cnt == real_n_groups - 1);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    k_group_cnt        <= 'd0;
  end
  else if (weight_sram_rvalid_reg && k_group_cnt == real_k_groups - 1) begin
    k_group_cnt        <= 'd0;
  end
  else if (weight_sram_rvalid_reg) begin
    k_group_cnt        <= k_group_cnt + 1'b1;
  end
  else begin
    k_group_cnt        <= k_group_cnt;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    n_group_cnt        <= 'd0;
  end
  else if (weight_sram_rvalid_reg && k_group_cnt == real_k_groups - 1 && n_group_cnt == real_n_groups - 1) begin
    n_group_cnt        <= 'd0;
  end
  else if (weight_sram_rvalid_reg && k_group_cnt == real_k_groups - 1) begin
    n_group_cnt        <= n_group_cnt + 1'b1;
  end
  else begin
    n_group_cnt        <= n_group_cnt;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                      Ifmap SRAM Read Controller                                          */
/* -------------------------------------------------------------------------------------------------------- */

assign ifmap_sram_raddr     = {ifmap_highaddr, ifmap_sram_raddr_reg};
assign ifmap_sram_rvalid    = ifmap_sram_rvalid_reg;
assign cnt_ifmap_burst_len  = ifmap_sram_rvalid_reg ? ifmap_sram_raddr_reg % ifmap_burst_len : 'd0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_baseaddr  <= 'd0;
  end
  else if (ifmap_sram_rvalid_reg && k_group_cnt == 'd0 && n_group_cnt == 'd0) begin
    ifmap_sram_baseaddr  <= ifmap_sram_raddr_reg;
  end
  else begin
    ifmap_sram_baseaddr  <= ifmap_sram_baseaddr;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_rvalid_reg <= 'd0;
  end
  else if (ifmap_sram_rvalid_reg && cnt_ifmap_burst_len == ifmap_burst_len - 1) begin
    ifmap_sram_rvalid_reg <= 'd0;
  end
  // else if (ifmap_sram_rvalid_reg) begin
  //   ifmap_sram_rvalid_reg <= 1'b1;
  // end
  else if (insn_valid_reg) begin
    ifmap_sram_rvalid_reg <= 1'b1;
  end
  else begin
    ifmap_sram_rvalid_reg <= ifmap_sram_rvalid_reg;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_raddr_reg  <= 'd0;
  end
  else if (ifmap_sram_rvalid_reg) begin
    if (ifmap_sram_raddr_reg == SRAM_DEPTH - 1) begin
      ifmap_sram_raddr_reg  <= 'd0;
    end
    else if (k_group_last && !n_group_last) begin
      ifmap_sram_raddr_reg  <= ifmap_sram_baseaddr;
    end
    else begin
      ifmap_sram_raddr_reg  <= ifmap_sram_raddr_reg + 1'b1;
    end
  end
  else begin
    ifmap_sram_raddr_reg  <= ifmap_sram_raddr_reg ;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                      Weight SRAM Read Controller                                         */
/* -------------------------------------------------------------------------------------------------------- */

assign weight_sram_raddr          = {weight_highaddr, weight_sram_raddr_reg};
assign weight_sram_rvalid         = weight_sram_rvalid_reg;

assign cnt_weight_burst_len = weight_sram_rvalid ? weight_sram_raddr_reg % weight_burst_len : 'd0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_rvalid_reg <= 'd0;
  end
  else if (weight_sram_rvalid_reg && cnt_weight_burst_len == weight_burst_len - 1) begin
    weight_sram_rvalid_reg <= 'd0;
  end
  else if (insn_valid_reg) begin
    weight_sram_rvalid_reg <= 1'b1;
  end
  else begin
    weight_sram_rvalid_reg <= weight_sram_rvalid_reg;
  end
end


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_raddr_reg  <= 'd0;
  end
  else if (weight_sram_rvalid_reg) begin
    if (weight_sram_raddr_reg == SRAM_DEPTH - 1) begin
      weight_sram_raddr_reg  <= 'd0;
    end
    else begin
      weight_sram_raddr_reg  <= weight_sram_raddr_reg + 1'b1;
    end
  end
  else begin
    weight_sram_raddr_reg  <= weight_sram_raddr_reg ;
  end
end

genvar weight_unpack_i;
generate
  for (weight_unpack_i = 0; weight_unpack_i < LANE; weight_unpack_i = weight_unpack_i + 1) begin : weight_lane_unpack
    assign weight_lane_data[weight_unpack_i] = weight_sram_rdata[weight_unpack_i*WEIGHT_WIDTH+:WEIGHT_WIDTH];
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                  Psum SRAM Read/Write Controller                                         */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    acc_clear <= 'd0;
  end
  else if (gemm_acc_clear && insn_valid_reg) begin
    acc_clear <= 1'b1;
  end
  else begin
    acc_clear <= 'd0;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                             Ifmap and Weight Regfile                                     */
/* -------------------------------------------------------------------------------------------------------- */

integer weight_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (weight_i = 0; weight_i < LANE; weight_i = weight_i + 1) begin
      weight_regfile[weight_i] <= {WEIGHT_WIDTH{1'b0}};
    end
  end
  else begin
    for (weight_i = 0; weight_i < LANE; weight_i = weight_i + 1) begin
      weight_regfile[weight_i] <= weight_lane_data[weight_i];
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_regfile <= {IFMAP_WIDTH{1'b0}};
  end
  else begin
    ifmap_regfile <= ifmap_sram_rdata;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_rvalid_d0 <= 1'b0;
    ifmap_sram_rvalid_d1 <= 1'b0;
    mpt_valid_pipe       <= 1'b0;
  end
  else begin
    ifmap_sram_rvalid_d0 <= ifmap_sram_rvalid;
    ifmap_sram_rvalid_d1 <= ifmap_sram_rvalid_d0;
    mpt_valid_pipe       <= ifmap_sram_rvalid_d1;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                       Multiply-Accumulate Units                                          */
/* -------------------------------------------------------------------------------------------------------- */

genvar mpt_i;
generate
  for (mpt_i = 0; mpt_i < LANE; mpt_i = mpt_i + 1) begin : mpt
    mpt_w8a8 u_mpt(
      .clk      ( clk                          ),
      .rst_n    ( rst_n                        ),
      .valid    ( mpt_valid_pipe               ),
      .acc_clear( acc_clear                    ),
      .a        ( ifmap_regfile                ),
      .b        ( weight_regfile[mpt_i]        ),
      .o        ( mpt_result[mpt_i]            ),
      .done     ( mpt_done                     )
    );

    assign mpt_result_unpack[mpt_i*32+:32] = mpt_result[mpt_i];
  end
endgenerate


/* -------------------------------------------------------------------------------------------------------- */
/*                                  Ofmap SRAM Write Controller                                             */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ofmap_sram_wvalid     <= 1'b0;
    ofmap_sram_wdata      <= 'd0;
  end
  else if (gemm_last_k_groups && mpt_done) begin
    ofmap_sram_wvalid     <= 1'b1;
    ofmap_sram_wdata      <= mpt_result_unpack;
  end
  else begin
    ofmap_sram_wvalid     <= 1'b0;
    ofmap_sram_wdata      <= 'd0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ofmap_sram_waddr      <= 'd0;
  end
  else if (ofmap_sram_wvalid && ofmap_sram_waddr == OFMAP_SRAM_DEPTH - 1) begin
    ofmap_sram_waddr      <= 'd0;
  end
  else if (ofmap_sram_wvalid) begin
    ofmap_sram_waddr      <= ofmap_sram_waddr + 1'b1;
  end
  else begin
    ofmap_sram_waddr      <= ofmap_sram_waddr;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Done Signal                                               */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    gemm_execute_done     <= 1'b0;
  end
  else if (mpt_done && insn_kind_wire == GEMM_EXECUTE_INSN) begin
    gemm_execute_done     <= 1'b1;
  end
  else begin
    gemm_execute_done     <= 1'b0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    config_done     <= 1'b0;
  end
  else if (insn_valid_reg && insn_kind_wire == PEA_CONFIG_INSN) begin
    config_done     <= 1'b1;
  end
  else begin
    config_done     <= 1'b0;
  end
end

assign fake_done = config_done | gemm_execute_done;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    done <= 1'b0;
  end
  else begin
    done <= fake_done && (~|insn_number);
  end
end

endmodule
