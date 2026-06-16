module pea(
  clk, rst_n,
  work_en, insn, insn_read, done,

  ifmap_sram_raddr, ifmap_sram_rvalid, ifmap_sram_rdata,
  weight_sram_raddr, weight_sram_rvalid, weight_sram_rdata,
  scale_sram_raddr, scale_sram_rvalid, scale_sram_rdata,
  ofmap_sram_wvalid, ofmap_sram_wdata,

  enable_prof_counter, execute_time
);

parameter PARALLELISM  = 32;
parameter LANE         = 32;

parameter IFMAP_ADDR_BITS  = 9;
parameter WEIGHT_ADDR_BITS = 14;
parameter PSUM_ADDR_BITS   = 6;
parameter SCALE_ADDR_BITS  = 9;

parameter IFMAP_WIDTH  = 256;
parameter WEIGHT_WIDTH = 256;
parameter PSUM_WIDTH   = 1024;
parameter SCALE_WIDTH  = 512;
parameter OFMAP_WIDTH  = 512;

parameter MAX_K_GROUPS_BITS = 8;
parameter MAX_N_GROUPS_BITS = 8;
parameter MAX_PSUM_NUMBER_BITS = 12;

parameter SRAM_DEPTH       = 144;

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

output wire [SCALE_ADDR_BITS-1:0]         scale_sram_raddr;
output wire                               scale_sram_rvalid;
input       [SCALE_WIDTH-1:0]             scale_sram_rdata;

output                                    ofmap_sram_wvalid;
output      [OFMAP_WIDTH-1:0]             ofmap_sram_wdata;

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
wire [MAX_PSUM_NUMBER_BITS-1:0] psum_number;

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

wire [PSUM_ADDR_BITS-1:0]   psum_sram_raddr;
wire                        psum_sram_rvalid;
wire [PSUM_WIDTH-1:0]       psum_sram_rdata;
wire [PSUM_ADDR_BITS-1:0]   psum_sram_waddr;
wire                        psum_sram_wvalid;
wire [PSUM_WIDTH-1:0]       psum_sram_wdata;

reg  [PSUM_WIDTH-1:0]       acc_data;
reg                         valid_acc;
reg                         psum_sram_rvalid_reg_d0;

reg [PSUM_ADDR_BITS-3:0]    psum_sram_raddr_reg;
reg                         psum_sram_rvalid_reg;
reg [PSUM_ADDR_BITS-3:0]    psum_sram_waddr_reg;
reg                         psum_sram_wvalid_reg;
reg [PSUM_WIDTH-1:0]        psum_sram_wdata_reg;
reg                         psum_read_zero_reg;
reg [PSUM_ADDR_BITS-3:0]    psum_read_addr_reg;

reg                         ifmap_sram_rvalid_d0;
reg                         ifmap_sram_rvalid_d1;
reg                         mpt_valid_pipe;
reg [IFMAP_WIDTH-1:0]       ifmap_regfile;
reg [WEIGHT_WIDTH-1:0]      weight_regfile[0:LANE-1];


wire [31:0]                 mpt_result[0:LANE-1];
wire                        mpt_done;
wire [PARALLELISM*LANE-1:0] mpt_result_unpack;

reg [SCALE_ADDR_BITS-1:0]   scale_sram_raddr_reg;
reg                         scale_sram_rvalid_reg;
  
reg  [SCALE_WIDTH-1:0]      dequant_scale_wire;
reg  [PSUM_WIDTH-1:0]       dequant_wdata_wire;
wire [SCALE_WIDTH-1:0]      fma_result_unpack;
wire [15:0]                 fma_result[0:LANE-1];
reg                         scale_sram_rvalid_reg_d0;
reg                         scale_sram_rvalid_reg_d1;

reg                         fma_done_reg;
reg                         fma_done;


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
assign gemm_psum_read_flag        = insn_reg[53];    //占用psum_highaddr的最高位，判断是否需要从psum_sram读取psum值，不然则是0
assign gemm_psum_write_flag       = insn_reg[52];    //占用psum_highaddr的最低位，判断是否需要将结果写回psum_sram，不然则不写回，直接进入dequant阶段
assign psum_number                = insn_reg[65:54]; //k_groups维度上，psum写入次数


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
      if (insn_kind_wire == PEA_CONFIG_INSN) begin
        real_k_groups     <= insn_reg[20:13];
        real_n_groups     <= insn_reg[28:21];
        gemm_type         <= insn_reg[30:29];
      end
      else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
        execute_start     <= 1;

        ifmap_burst_len   <= gemm_tile_m_wire + 1;
        weight_burst_len  <= gemm_k_groups_wire + 1;
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


/* -------------------------------------------------------------------------------------------------------- */
/*                                           Execution Controller                                           */
/* -------------------------------------------------------------------------------------------------------- */

assign  k_group_last = (weight_sram_rvalid_reg && k_group_cnt == real_k_groups - 1);
assign  n_group_last = (weight_sram_rvalid_reg && n_group_cnt == real_n_groups - 1);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    k_group_cnt        <= 'd0;
    n_group_cnt        <= 'd0;
  end
  else if (weight_sram_rvalid_reg && k_group_cnt == real_k_groups - 1 && n_group_cnt == real_n_groups - 1) begin
    n_group_cnt        <= 'd0;
  end
  else if (weight_sram_rvalid_reg && k_group_cnt == real_k_groups - 1) begin
    k_group_cnt        <= 'd0;
    n_group_cnt        <= n_group_cnt + 1'b1;
  end
  else if (weight_sram_rvalid_reg) begin
    k_group_cnt        <= k_group_cnt + 1'b1;
  end
  else begin
    k_group_cnt        <= k_group_cnt;
    n_group_cnt        <= n_group_cnt;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                      Ifmap SRAM Read Controller                                          */
/* -------------------------------------------------------------------------------------------------------- */

assign ifmap_sram_raddr     = {ifmap_highaddr, ifmap_sram_raddr_reg};
assign ifmap_sram_rvalid    = ifmap_sram_rvalid_reg;
assign cnt_ifmap_burst_len  = ifmap_sram_rvalid_reg ? ifmap_sram_rvalid_reg % ifmap_burst_len : 'd0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_baseaddr  <= 'd0;
  end
  else if (execute_start && k_group_cnt == 'd0 && n_group_cnt == 'd0) begin
    ifmap_sram_baseaddr  <= ifmap_sram_rvalid_reg;
  end
  else begin
    ifmap_sram_baseaddr  <= ifmap_sram_baseaddr;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_raddr_reg  <= 'd0;
    ifmap_sram_rvalid_reg <= 'd0;
  end
  else if (execute_start) begin
    if (ifmap_sram_rvalid_reg && ifmap_sram_raddr_reg == SRAM_DEPTH - 1) begin
      ifmap_sram_raddr_reg  <= 'd0;
      ifmap_sram_rvalid_reg <= ifmap_sram_rvalid_reg;
    end
    else if (ifmap_sram_rvalid_reg && cnt_ifmap_burst_len == ifmap_burst_len - 1) begin
      ifmap_sram_raddr_reg  <= ifmap_sram_raddr_reg;
      ifmap_sram_rvalid_reg <= 'd0;
    end
    else if (k_group_last && !n_group_last) begin
      ifmap_sram_raddr_reg  <= ifmap_sram_baseaddr;
    end
    else begin
      ifmap_sram_raddr_reg  <= ifmap_sram_raddr_reg + 1'b1;
      ifmap_sram_rvalid_reg <= 1'b1;
    end
  end
  else begin
    ifmap_sram_raddr_reg  <= ifmap_sram_raddr_reg ;
    ifmap_sram_rvalid_reg <= ifmap_sram_rvalid_reg;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                      Weight SRAM Read Controller                                         */
/* -------------------------------------------------------------------------------------------------------- */

assign weight_sram_raddr          = {weight_highaddr, weight_sram_raddr_reg};
assign weight_sram_rvalid         = weight_sram_rvalid_reg;

assign cnt_weight_burst_len = weight_sram_rvalid ? weight_sram_rvalid_reg % weight_burst_len : 'd0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_raddr_reg  <= 'd0;
    weight_sram_rvalid_reg <= 'd0;
  end
  else if (execute_start) begin
    if (weight_sram_rvalid_reg && weight_sram_raddr_reg == SRAM_DEPTH - 1) begin
      weight_sram_raddr_reg  <= 'd0;
      weight_sram_rvalid_reg <= weight_sram_rvalid_reg;
    end
    else if (weight_sram_rvalid_reg && cnt_weight_burst_len == weight_burst_len - 1) begin
      weight_sram_raddr_reg  <= weight_sram_raddr_reg;
      weight_sram_rvalid_reg <= 'd0;
    end
    else begin
      weight_sram_raddr_reg  <= weight_sram_raddr_reg + 1'b1;
      weight_sram_rvalid_reg <= 1'b1;
    end
  end
  else begin
    weight_sram_raddr_reg  <= weight_sram_raddr_reg ;
    weight_sram_rvalid_reg <= weight_sram_rvalid_reg;
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

assign psum_sram_raddr  = psum_sram_raddr_reg;
assign psum_sram_rvalid = psum_sram_rvalid_reg;
assign psum_sram_waddr  = psum_sram_waddr_reg;
assign psum_sram_wvalid = psum_sram_wvalid_reg;
assign psum_sram_wdata  = psum_sram_wdata_reg;


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_wvalid_reg <= 'd0;
    psum_sram_waddr_reg  <= 'd0;
    psum_sram_wdata_reg  <= 'd0;
  end
  else if (gemm_type == ATT_LINEAR) begin
    if (mpt_done && psum_sram_waddr_reg == real_n_groups - 1) begin
      psum_sram_waddr_reg  <= 'd0;
    end
    else if (mpt_done && gemm_psum_write_flag) begin
      psum_sram_wvalid_reg <= 1'b1;
      psum_sram_waddr_reg  <= psum_sram_waddr_reg + 1'b1;
      psum_sram_wdata_reg  <= mpt_result_unpack;
    end
    else begin
      psum_sram_wvalid_reg <= 'd0;
      psum_sram_waddr_reg  <= psum_sram_waddr_reg;
      psum_sram_wdata_reg  <= psum_sram_wdata_reg;
    end
  end
  else begin
    psum_sram_wvalid_reg <= 'd0;
    psum_sram_waddr_reg  <= 'd0;
    psum_sram_wdata_reg  <= 'd0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_rvalid_reg <= 'd0;
    psum_sram_raddr_reg  <= 'd0;
  end
  else if (gemm_type == ATT_LINEAR) begin
    if (insn_valid_reg && psum_sram_raddr_reg == real_n_groups - 1) begin
      psum_sram_raddr_reg  <= 'd0;
    end
    else if (insn_valid_reg && gemm_psum_read_flag) begin
      psum_sram_rvalid_reg <= 1'b1;
      psum_sram_raddr_reg  <= psum_sram_raddr_reg + 1'b1;
    end
    else begin
      psum_sram_rvalid_reg <= 'd0;
      psum_sram_raddr_reg  <= psum_sram_raddr_reg;
    end
  end
  else begin
    psum_sram_rvalid_reg <= 'd0;
    psum_sram_raddr_reg  <= 'd0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_rvalid_reg_d0 <= 1'b0;
  end
  else begin
    psum_sram_rvalid_reg_d0 <= psum_sram_rvalid_reg;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    valid_acc    <= 'd0;
    acc_data     <= 'd0;
  end
  else if (gemm_type == ATT_LINEAR) begin
    if (psum_sram_rvalid_reg_d0) begin
      valid_acc  <= 1'b1;
      acc_data   <= psum_sram_rdata;
    end
    else begin
      valid_acc    <= 'd0;
      acc_data     <= 'd0;
    end
  end
  else if (insn_valid_reg) begin
    valid_acc  <= 1'b1;
    acc_data   <= 'd0; //对于非ATT_LINEAR的gemm指令，不从psum_sram读取初始值，直接将累加器输入置0
  end
  else begin
    valid_acc    <= 'd0;
    acc_data     <= 'd0;
  end
end

sram_1024x48 u_psum_sram(
  .w_clk  ( clk              ),
  .w_addr ( psum_sram_waddr  ),
  .w_en   ( psum_sram_wvalid ),
  .w_data ( psum_sram_wdata  ),
  .r_clk  ( clk              ),
  .r_addr ( psum_sram_raddr  ),
  .r_en   ( psum_sram_rvalid ),
  .r_data ( psum_sram_rdata  )
);

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
      .clk    ( clk                          ),
      .rst_n  ( rst_n                        ),
      .valid  ( mpt_valid_pipe               ),
      .valid_c( valid_acc                    ),
      .a      ( ifmap_regfile                ),
      .b      ( weight_regfile[mpt_i]        ),
      .c      ( acc_data[mpt_i*32+:32]       ),
      .o      ( mpt_result[mpt_i]            ),
      .done   ( mpt_done                     )
    );

    assign mpt_result_unpack[mpt_i*32+:32] = mpt_result[mpt_i];
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                       Scale SRAM Read Controller                                         */
/* -------------------------------------------------------------------------------------------------------- */

assign scale_sram_raddr = scale_sram_raddr_reg;
assign scale_sram_rvalid = scale_sram_rvalid_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    scale_sram_rvalid_reg <= 'd0;
    scale_sram_raddr_reg  <= 'd0;
  end
  else if (scale_sram_rvalid_reg && !gemm_psum_write_flag && scale_sram_raddr_reg == SRAM_DEPTH - 1) begin
    scale_sram_raddr_reg  <='d0;
  end
  else if (insn_valid_reg && !gemm_psum_write_flag) begin
    scale_sram_rvalid_reg <= 1'b1;
    scale_sram_raddr_reg  <= scale_sram_raddr_reg + 1'b1;
  end
  else begin
    scale_sram_rvalid_reg <= scale_sram_rvalid_reg;
    scale_sram_raddr_reg  <= scale_sram_raddr_reg;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                  Dequant                                                 */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    scale_sram_rvalid_reg_d0 <= 1'b0;
    scale_sram_rvalid_reg_d1 <= 1'b0;
  end
  else begin
    scale_sram_rvalid_reg_d0 <= scale_sram_rvalid_reg;
    scale_sram_rvalid_reg_d1 <= scale_sram_rvalid_reg_d0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dequant_wdata_wire <= 'd0;
  end
  else if (mpt_done && !gemm_psum_write_flag) begin
    dequant_wdata_wire <= mpt_result_unpack;
  end
  else begin
    dequant_wdata_wire <= dequant_wdata_wire;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dequant_scale_wire <= 'd0;
  end
  else if (scale_sram_rvalid_reg_d1) begin
    dequant_scale_wire <= scale_sram_rdata;
  end
  else begin
    dequant_scale_wire <= dequant_scale_wire;
  end
end

genvar fma_i;
generate
  for (fma_i = 0; fma_i < LANE; fma_i = fma_i + 1) begin : fma
    custom_fma_fp16 u_fma(
      .clk   ( clk                                ),
      .rst_n ( rst_n                              ),
      .psum  ( dequant_wdata_wire[fma_i*32+:32]   ),
      .scale ( dequant_scale_wire[fma_i*16+:16]   ),
      .o     ( fma_result[fma_i]                  )
    );

    assign fma_result_unpack[fma_i*16+:16] = fma_result[fma_i];
  end
endgenerate

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    fma_done_reg <= 1'b0;
  end
  else if (mpt_done && !gemm_psum_write_flag) begin
    fma_done_reg <= 1'b1;
  end
  else begin
    fma_done_reg <= 1'b0;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    fma_done     <= 1'b0;
  end
  else begin
    fma_done     <= fma_done_reg;
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                  Ofmap SRAM Write Controller                                             */
/* -------------------------------------------------------------------------------------------------------- */

assign ofmap_sram_wvalid = fma_done;
assign ofmap_sram_wdata  = fma_result_unpack;

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Done Signal                                               */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    gemm_execute_done     <= 1'b0;
  end
  else if (gemm_type == ATT_LINEAR) begin
    if (gemm_psum_write_flag) begin
      gemm_execute_done   <= mpt_done;
    end
    else begin
      gemm_execute_done   <= fma_done;
    end
  end
  else begin
    gemm_execute_done     <= fma_done;
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
