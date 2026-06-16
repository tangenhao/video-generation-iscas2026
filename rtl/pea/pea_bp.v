module pea(
  clk, rst_n,
  work_en, insn, insn_read, done,

  ifmap_sram_raddr, ifmap_sram_rvalid, ifmap_sram_rdata,
  weight_sram_raddr, weight_sram_rvalid, weight_sram_rdata,
  scale_sram_raddr, scale_sram_rvalid, scale_sram_rdata,

  enable_prof_counter, execute_time
);

parameter PARALLELISM  = 16;
parameter LANE         = 32;

parameter IFMAP_ADDR_BITS  = 9;
parameter WEIGHT_ADDR_BITS = 14;
parameter PSUM_ADDR_BITS   = 6;
parameter SCALE_ADDR_BITS  = 9;

parameter IFMAP_WIDTH  = 256;
parameter WEIGHT_WIDTH = 256;
parameter PSUM_WIDTH   = 1024;
parameter SCALE_WIDTH  = 512;

parameter MAX_TILE_M_BITS   = 12;
parameter MAX_K_GROUPS_BITS = 8;
parameter MAX_N_GROUPS_BITS = 8;

parameter MAX_WEIGHT_NUMBER_BITS = 19;

parameter REAL_IFMAP_WIDTH = 256;

localparam PEA_CONFIG_INSN     = 0;
localparam GEMM_EXECUTE_INSN   = 2;

localparam STATE_IDLE        = 0;
localparam STATE_LOAD_WEIGHT = 1;
localparam STATE_RUN_TILE    = 2;

localparam MPT_LATENCY       = 11;
localparam SRAM_READ_LATENCY = 2;
localparam WEIGHT_BANK_BITS  = 5;
localparam WEIGHT_ROW_BITS   = WEIGHT_ADDR_BITS - WEIGHT_BANK_BITS - 1;

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

input                                     enable_prof_counter;
output reg  [31:0]                        execute_time;

reg       insn_valid;
reg       insn_valid_reg;
reg [3:0] insn_number;
reg [127:0] insn_reg;

reg config_done;
reg gemm_execute_done;
wire fake_done;

assign fake_done = config_done | gemm_execute_done;

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

wire [2:0] insn_kind_wire;
wire [11:0] gemm_tile_m_wire;
wire [7:0]  gemm_n_groups_wire;
wire [7:0]  gemm_k_groups_wire;
wire        gemm_ifmap_highaddr_wire;
wire        gemm_weight_highaddr_wire;
wire [1:0]  gemm_psum_highaddr_wire;
wire        gemm_psum_accumulated_wire;

assign insn_kind_wire             = insn_reg[12:10];
assign gemm_tile_m_wire           = insn_reg[33:22];
assign gemm_n_groups_wire         = insn_reg[41:34];
assign gemm_k_groups_wire         = insn_reg[49:42];
assign gemm_ifmap_highaddr_wire   = insn_reg[50];
assign gemm_weight_highaddr_wire  = insn_reg[51];
assign gemm_psum_highaddr_wire    = insn_reg[53:52];
assign gemm_psum_accumulated_wire = insn_reg[66];

/* -------------------------------------------------------------------------------------------------------- */
/*                                           GEMM Loop Registers                                            */
/* -------------------------------------------------------------------------------------------------------- */

reg [1:0] state;

reg [MAX_TILE_M_BITS:0]      tile_m;
reg [MAX_N_GROUPS_BITS:0]    n_groups;
reg [MAX_K_GROUPS_BITS:0]    weight_k_groups;
reg                          psum_accumulated;
reg                          ifmap_highaddr;
reg                          weight_highaddr;
reg [1:0]                    psum_highaddr;

reg [MAX_N_GROUPS_BITS:0]    n_group_cnt;
reg [MAX_K_GROUPS_BITS:0]    k_group_cnt;
reg [MAX_TILE_M_BITS:0]      tile_m_issue_cnt;
reg [MAX_TILE_M_BITS:0]      tile_m_write_cnt;
reg                          weight_read_issued;

/* -------------------------------------------------------------------------------------------------------- */
/*                                      Ifmap SRAM Read Controller                                          */
/* -------------------------------------------------------------------------------------------------------- */

reg [IFMAP_ADDR_BITS-2:0] ifmap_sram_raddr_reg;
reg                       ifmap_sram_rvalid_reg;

wire [IFMAP_ADDR_BITS-1:0] ifmap_read_addr_wire;

assign ifmap_read_addr_wire = k_group_cnt * tile_m + tile_m_issue_cnt;
assign ifmap_sram_raddr     = {ifmap_highaddr, ifmap_sram_raddr_reg};
assign ifmap_sram_rvalid    = ifmap_sram_rvalid_reg;

/* -------------------------------------------------------------------------------------------------------- */
/*                                      Weight SRAM Read Controller                                         */
/* -------------------------------------------------------------------------------------------------------- */

reg [WEIGHT_ADDR_BITS-2:0] weight_sram_raddr_reg;
reg                        weight_sram_rvalid_reg;

wire [MAX_WEIGHT_NUMBER_BITS:0] weight_read_addr_wire;
wire [WEIGHT_ADDR_BITS-2:0]     weight_read_sram_addr_wire;
wire [WEIGHT_WIDTH-1:0]         weight_lane_data[0:LANE-1];

assign weight_read_addr_wire      = n_group_cnt * weight_k_groups + k_group_cnt;
assign weight_read_sram_addr_wire = {{WEIGHT_BANK_BITS{1'b0}}, weight_read_addr_wire[WEIGHT_ROW_BITS-1:0]};
assign weight_sram_raddr          = {weight_highaddr, weight_sram_raddr_reg};
assign weight_sram_rvalid         = weight_sram_rvalid_reg;

genvar weight_unpack_i;
generate
  for (weight_unpack_i = 0; weight_unpack_i < LANE; weight_unpack_i = weight_unpack_i + 1) begin : weight_lane_unpack
    assign weight_lane_data[weight_unpack_i] = weight_sram_rdata[weight_unpack_i*WEIGHT_WIDTH+:WEIGHT_WIDTH];
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                       Scale SRAM Read Controller                                         */
/* -------------------------------------------------------------------------------------------------------- */

reg [SCALE_ADDR_BITS-1:0] scale_sram_raddr_reg;
reg                       scale_sram_rvalid_reg;

wire [SCALE_ADDR_BITS-1:0] scale_read_addr_wire;

assign scale_read_addr_wire = tile_m_issue_cnt[SCALE_ADDR_BITS-1:0];
assign scale_sram_raddr     = scale_sram_raddr_reg;
assign scale_sram_rvalid    = scale_sram_rvalid_reg;

/* -------------------------------------------------------------------------------------------------------- */
/*                                  Psum SRAM Read/Write Controller                                         */
/* -------------------------------------------------------------------------------------------------------- */

wire [PSUM_ADDR_BITS-1:0] psum_sram_raddr;
wire                      psum_sram_rvalid;
wire [PSUM_WIDTH-1:0]     psum_sram_rdata;
wire [PSUM_ADDR_BITS-1:0] psum_sram_waddr;
wire                      psum_sram_wvalid;
wire [PSUM_WIDTH-1:0]     psum_sram_wdata;

reg [PSUM_ADDR_BITS-3:0] psum_sram_raddr_reg;
reg                      psum_sram_rvalid_reg;
reg [PSUM_ADDR_BITS-3:0] psum_sram_waddr_reg;
reg                      psum_sram_wvalid_reg;
reg [PSUM_WIDTH-1:0]     psum_sram_wdata_reg;
reg                      psum_read_zero_reg;
reg [PSUM_ADDR_BITS-3:0] psum_read_addr_reg;

wire [PSUM_ADDR_BITS-1:0] psum_access_addr_wire;
wire                      first_k_without_external_psum;

assign psum_access_addr_wire         = n_group_cnt * tile_m + tile_m_issue_cnt;
assign first_k_without_external_psum = (k_group_cnt == 0) && (!psum_accumulated);

assign psum_sram_raddr  = {psum_highaddr, psum_sram_raddr_reg};
assign psum_sram_rvalid = psum_sram_rvalid_reg;
assign psum_sram_waddr  = {psum_highaddr, psum_sram_waddr_reg};
assign psum_sram_wvalid = psum_sram_wvalid_reg;
assign psum_sram_wdata  = psum_sram_wdata_reg;

sram_1024x64 u_psum_sram(
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
/*                                        SRAM Read Data Pipeline                                           */
/* -------------------------------------------------------------------------------------------------------- */

reg [SRAM_READ_LATENCY-1:0] ifmap_read_valid_pipe;
reg [SRAM_READ_LATENCY-1:0] weight_read_valid_pipe;
reg [SRAM_READ_LATENCY-1:0] scale_read_valid_pipe;
reg [SRAM_READ_LATENCY-1:0] psum_read_zero_pipe;
reg [PSUM_ADDR_BITS-3:0]    psum_read_addr_pipe[0:SRAM_READ_LATENCY-1];

wire ifmap_read_data_valid;
wire weight_read_data_valid;
wire scale_read_data_valid;

assign ifmap_read_data_valid  = ifmap_read_valid_pipe[SRAM_READ_LATENCY-1];
assign weight_read_data_valid = weight_read_valid_pipe[SRAM_READ_LATENCY-1];
assign scale_read_data_valid  = scale_read_valid_pipe[SRAM_READ_LATENCY-1];

reg [REAL_IFMAP_WIDTH-1:0] ifmap_vector;
reg [SCALE_WIDTH-1:0]      scale_data_pipe[0:MPT_LATENCY];
reg [PSUM_WIDTH-1:0]       psum_data_pipe[0:MPT_LATENCY];
reg [PSUM_ADDR_BITS-3:0]   psum_addr_pipe[0:MPT_LATENCY];

/* -------------------------------------------------------------------------------------------------------- */
/*                                             Weight Regfile                                               */
/* -------------------------------------------------------------------------------------------------------- */

reg [WEIGHT_WIDTH-1:0] weight_regfile[0:LANE-1];

integer weight_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (weight_i = 0; weight_i < LANE; weight_i = weight_i + 1) begin
      weight_regfile[weight_i] <= {WEIGHT_WIDTH{1'b0}};
    end
  end
  else if (weight_read_data_valid) begin
    for (weight_i = 0; weight_i < LANE; weight_i = weight_i + 1) begin
      weight_regfile[weight_i] <= weight_lane_data[weight_i];
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                       Multiply-Accumulate Units                                          */
/* -------------------------------------------------------------------------------------------------------- */

reg [LANE-1:0] mpt_valid_pipe;
wire [31:0]    mpt_result[0:LANE-1];
wire [LANE-1:0] mpt_done;

genvar mpt_i;
generate
  for (mpt_i = 0; mpt_i < LANE; mpt_i = mpt_i + 1) begin : mpt
    mpt_int8 #(
      .PARALLELISM ( PARALLELISM )
    ) u_mpt(
      .clk    ( clk                    ),
      .rst_n  ( rst_n                  ),
      .valid  ( mpt_valid_pipe[mpt_i]  ),
      .a      ( ifmap_vector           ),
      .b      ( weight_regfile[mpt_i]  ),
      .o      ( mpt_result[mpt_i]      ),
      .done   ( mpt_done[mpt_i]        ),
      .clear  ( fake_done              )
    );
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Accumulator                                               */
/* -------------------------------------------------------------------------------------------------------- */

wire [31:0]         psum_lane_data[0:LANE-1];
wire [31:0]         accumulator_result[0:LANE-1];
wire [PSUM_WIDTH-1:0] accumulator_wdata_wire;

genvar psum_unpack_i;
generate
  for (psum_unpack_i = 0; psum_unpack_i < LANE; psum_unpack_i = psum_unpack_i + 1) begin : psum_lane_unpack
    assign psum_lane_data[psum_unpack_i]         = psum_data_pipe[MPT_LATENCY][psum_unpack_i*32+:32];
    assign accumulator_result[psum_unpack_i]     = mpt_result[psum_unpack_i] + psum_lane_data[psum_unpack_i];
    assign accumulator_wdata_wire[psum_unpack_i*32+:32] = accumulator_result[psum_unpack_i];
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                                  Dequant                                                 */
/* -------------------------------------------------------------------------------------------------------- */

wire [SCALE_WIDTH-1:0] dequant_scale_wire;
wire [PSUM_WIDTH-1:0]  dequant_wdata_wire;

assign dequant_scale_wire = scale_data_pipe[MPT_LATENCY];
assign dequant_wdata_wire = accumulator_wdata_wire;

/* -------------------------------------------------------------------------------------------------------- */
/*                                           Data Path Pipelines                                            */
/* -------------------------------------------------------------------------------------------------------- */

integer pipe_i;
integer read_pipe_i;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_read_valid_pipe  <= {SRAM_READ_LATENCY{1'b0}};
    weight_read_valid_pipe <= {SRAM_READ_LATENCY{1'b0}};
    scale_read_valid_pipe  <= {SRAM_READ_LATENCY{1'b0}};
    psum_read_zero_pipe    <= {SRAM_READ_LATENCY{1'b0}};
    ifmap_vector           <= {REAL_IFMAP_WIDTH{1'b0}};
    mpt_valid_pipe         <= {LANE{1'b0}};
    psum_sram_waddr_reg    <= {PSUM_ADDR_BITS-2{1'b0}};
    psum_sram_wvalid_reg   <= 1'b0;
    psum_sram_wdata_reg    <= {PSUM_WIDTH{1'b0}};

    for (read_pipe_i = 0; read_pipe_i < SRAM_READ_LATENCY; read_pipe_i = read_pipe_i + 1) begin
      psum_read_addr_pipe[read_pipe_i] <= {PSUM_ADDR_BITS-2{1'b0}};
    end
    for (pipe_i = 0; pipe_i <= MPT_LATENCY; pipe_i = pipe_i + 1) begin
      scale_data_pipe[pipe_i] <= {SCALE_WIDTH{1'b0}};
      psum_data_pipe[pipe_i]  <= {PSUM_WIDTH{1'b0}};
      psum_addr_pipe[pipe_i]  <= {PSUM_ADDR_BITS-2{1'b0}};
    end
  end
  else begin
    ifmap_read_valid_pipe  <= {ifmap_read_valid_pipe[SRAM_READ_LATENCY-2:0], ifmap_sram_rvalid_reg};
    weight_read_valid_pipe <= {weight_read_valid_pipe[SRAM_READ_LATENCY-2:0], weight_sram_rvalid_reg};
    scale_read_valid_pipe  <= {scale_read_valid_pipe[SRAM_READ_LATENCY-2:0], scale_sram_rvalid_reg};
    psum_read_zero_pipe    <= {psum_read_zero_pipe[SRAM_READ_LATENCY-2:0], psum_read_zero_reg};

    psum_read_addr_pipe[0] <= psum_read_addr_reg;
    for (read_pipe_i = 1; read_pipe_i < SRAM_READ_LATENCY; read_pipe_i = read_pipe_i + 1) begin
      psum_read_addr_pipe[read_pipe_i] <= psum_read_addr_pipe[read_pipe_i-1];
    end

    mpt_valid_pipe <= {LANE{ifmap_read_data_valid}};

    if (ifmap_read_data_valid) begin
      ifmap_vector      <= ifmap_sram_rdata[REAL_IFMAP_WIDTH-1:0];
      psum_data_pipe[0] <= psum_read_zero_pipe[SRAM_READ_LATENCY-1] ? {PSUM_WIDTH{1'b0}} : psum_sram_rdata;
      psum_addr_pipe[0] <= psum_read_addr_pipe[SRAM_READ_LATENCY-1];
    end
    else begin
      psum_data_pipe[0] <= {PSUM_WIDTH{1'b0}};
      psum_addr_pipe[0] <= {PSUM_ADDR_BITS-2{1'b0}};
    end

    if (scale_read_data_valid) begin
      scale_data_pipe[0] <= scale_sram_rdata;
    end
    else begin
      scale_data_pipe[0] <= {SCALE_WIDTH{1'b0}};
    end

    for (pipe_i = 1; pipe_i <= MPT_LATENCY; pipe_i = pipe_i + 1) begin
      scale_data_pipe[pipe_i] <= scale_data_pipe[pipe_i-1];
      psum_data_pipe[pipe_i]  <= psum_data_pipe[pipe_i-1];
      psum_addr_pipe[pipe_i]  <= psum_addr_pipe[pipe_i-1];
    end

    if (|mpt_done) begin
      psum_sram_wvalid_reg <= 1'b1;
      psum_sram_waddr_reg  <= psum_addr_pipe[MPT_LATENCY];
      psum_sram_wdata_reg  <= dequant_wdata_wire;
    end
    else begin
      psum_sram_wvalid_reg <= 1'b0;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                           Execution Controller                                           */
/* -------------------------------------------------------------------------------------------------------- */






always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state <= STATE_IDLE;

    config_done       <= 1'b0;
    gemm_execute_done <= 1'b0;

    tile_m           <= {MAX_TILE_M_BITS+1{1'b0}};
    n_groups         <= {MAX_N_GROUPS_BITS+1{1'b0}};
    weight_k_groups  <= {MAX_K_GROUPS_BITS+1{1'b0}};
    psum_accumulated <= 1'b0;
    ifmap_highaddr   <= 1'b0;
    weight_highaddr  <= 1'b0;
    psum_highaddr    <= 2'b00;

    n_group_cnt      <= {MAX_N_GROUPS_BITS+1{1'b0}};
    k_group_cnt      <= {MAX_K_GROUPS_BITS+1{1'b0}};
    tile_m_issue_cnt <= {MAX_TILE_M_BITS+1{1'b0}};
    tile_m_write_cnt <= {MAX_TILE_M_BITS+1{1'b0}};
    weight_read_issued <= 1'b0;

    ifmap_sram_raddr_reg  <= {IFMAP_ADDR_BITS-1{1'b0}};
    ifmap_sram_rvalid_reg <= 1'b0;
    weight_sram_raddr_reg <= {WEIGHT_ADDR_BITS-1{1'b0}};
    weight_sram_rvalid_reg <= 1'b0;
    scale_sram_raddr_reg  <= {SCALE_ADDR_BITS{1'b0}};
    scale_sram_rvalid_reg <= 1'b0;
    psum_sram_raddr_reg   <= {PSUM_ADDR_BITS-2{1'b0}};
    psum_sram_rvalid_reg  <= 1'b0;
    psum_read_zero_reg    <= 1'b0;
    psum_read_addr_reg    <= {PSUM_ADDR_BITS-2{1'b0}};
  end
  else begin
    config_done       <= 1'b0;
    gemm_execute_done <= 1'b0;

    ifmap_sram_rvalid_reg  <= 1'b0;
    weight_sram_rvalid_reg <= 1'b0;
    scale_sram_rvalid_reg  <= 1'b0;
    psum_sram_rvalid_reg   <= 1'b0;
    psum_read_zero_reg     <= 1'b0;
    psum_read_addr_reg     <= {PSUM_ADDR_BITS-2{1'b0}};

    case (state)
      STATE_IDLE: begin
        weight_read_issued <= 1'b0;
        if (insn_valid_reg) begin
          if (insn_kind_wire == PEA_CONFIG_INSN) begin
            config_done <= 1'b1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            tile_m           <= gemm_tile_m_wire + 1'b1;
            n_groups         <= gemm_n_groups_wire + 1'b1;
            weight_k_groups  <= gemm_k_groups_wire + 1'b1;
            ifmap_highaddr   <= gemm_ifmap_highaddr_wire;
            weight_highaddr  <= gemm_weight_highaddr_wire;
            psum_highaddr    <= gemm_psum_highaddr_wire;
            psum_accumulated <= gemm_psum_accumulated_wire;

            n_group_cnt      <= {MAX_N_GROUPS_BITS+1{1'b0}};
            k_group_cnt      <= {MAX_K_GROUPS_BITS+1{1'b0}};
            tile_m_issue_cnt <= {MAX_TILE_M_BITS+1{1'b0}};
            tile_m_write_cnt <= {MAX_TILE_M_BITS+1{1'b0}};
            state            <= STATE_LOAD_WEIGHT;
          end
        end
      end

      STATE_LOAD_WEIGHT: begin
        if (!weight_read_issued) begin
          weight_sram_rvalid_reg <= 1'b1;
          weight_sram_raddr_reg  <= weight_read_sram_addr_wire;
          weight_read_issued     <= 1'b1;
        end

        if (weight_read_data_valid) begin
          tile_m_issue_cnt   <= {MAX_TILE_M_BITS+1{1'b0}};
          tile_m_write_cnt   <= {MAX_TILE_M_BITS+1{1'b0}};
          weight_read_issued <= 1'b0;
          state              <= STATE_RUN_TILE;
        end
      end

      STATE_RUN_TILE: begin
        if (tile_m_issue_cnt < tile_m) begin
          ifmap_sram_rvalid_reg <= 1'b1;
          ifmap_sram_raddr_reg  <= ifmap_read_addr_wire[IFMAP_ADDR_BITS-2:0];

          scale_sram_rvalid_reg <= 1'b1;
          scale_sram_raddr_reg  <= scale_read_addr_wire;

          psum_sram_rvalid_reg <= !first_k_without_external_psum;
          psum_sram_raddr_reg  <= psum_access_addr_wire[PSUM_ADDR_BITS-3:0];
          psum_read_zero_reg   <= first_k_without_external_psum;
          psum_read_addr_reg   <= psum_access_addr_wire[PSUM_ADDR_BITS-3:0];

          tile_m_issue_cnt <= tile_m_issue_cnt + 1'b1;
        end

        if (|mpt_done) begin
          if (tile_m_write_cnt == tile_m - 1'b1) begin
            tile_m_write_cnt <= {MAX_TILE_M_BITS+1{1'b0}};
            tile_m_issue_cnt <= {MAX_TILE_M_BITS+1{1'b0}};

            if (k_group_cnt == weight_k_groups - 1'b1) begin
              k_group_cnt <= {MAX_K_GROUPS_BITS+1{1'b0}};
              if (n_group_cnt == n_groups - 1'b1) begin
                state             <= STATE_IDLE;
                gemm_execute_done <= 1'b1;
              end
              else begin
                n_group_cnt <= n_group_cnt + 1'b1;
                state       <= STATE_LOAD_WEIGHT;
              end
            end
            else begin
              k_group_cnt <= k_group_cnt + 1'b1;
              state       <= STATE_LOAD_WEIGHT;
            end
          end
          else begin
            tile_m_write_cnt <= tile_m_write_cnt + 1'b1;
          end
        end
      end

      default: begin
        state <= STATE_IDLE;
      end
    endcase
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Done Signal                                               */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    done <= 1'b0;
  end
  else begin
    done <= fake_done && (~|insn_number);
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                             Profile Counter                                              */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_time <= 32'd0;
  end
  else if (state != STATE_IDLE && enable_prof_counter) begin
    execute_time <= execute_time + 1'b1;
  end
end

endmodule
