module pea(
  clk, rst_n,
  work_en, insn, insn_read, done,

  ifmap_sram_raddr, ifmap_sram_rvalid, ifmap_sram_rdata,
  weight_sram_raddr, weight_sram_rvalid, weight_sram_rdata,
  scale_sram_raddr, scale_sram_rvalid, scale_sram_rdata,

  psum_sram_raddr, psum_sram_rvalid, psum_sram_rdata,
  psum_sram_waddr, psum_sram_wvalid, psum_sram_wdata,

  enable_prof_counter, execute_time
);

parameter PARALLELISM  = 16;
parameter LANE         = 32;

parameter IFMAP_ADDR_BITS  = 11;
parameter WEIGHT_ADDR_BITS = 12;
parameter PSUM_ADDR_BITS   = 12;
parameter SCALE_ADDR_BITS  = 12;

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

localparam MPT_LATENCY = 11;

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
input       [WEIGHT_WIDTH-1:0]            weight_sram_rdata;

output wire [SCALE_ADDR_BITS-1:0]         scale_sram_raddr;
output wire                               scale_sram_rvalid;
input       [SCALE_WIDTH-1:0]             scale_sram_rdata;

output wire [PSUM_ADDR_BITS-1:0]          psum_sram_raddr;
output wire                               psum_sram_rvalid;
input       [PSUM_WIDTH-1:0]              psum_sram_rdata;

output wire [PSUM_ADDR_BITS-1:0]          psum_sram_waddr;
output wire                               psum_sram_wvalid;
output wire [PSUM_WIDTH-1:0]              psum_sram_wdata;

input                                     enable_prof_counter;
output reg  [31:0]                        execute_time;

reg       insn_valid;
reg       insn_valid_reg;
reg [3:0] insn_number;
reg [127:0] insn_reg;

reg config_done;
reg gemm_execute_done;
reg unsupported_done;
wire fake_done;

assign fake_done = config_done | gemm_execute_done | unsupported_done;

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

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    done <= 1'b0;
  end
  else begin
    done <= fake_done && (~|insn_number);
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

reg [1:0] state;

reg [MAX_TILE_M_BITS:0]   tile_m;
reg [MAX_N_GROUPS_BITS:0] n_groups;
reg [MAX_K_GROUPS_BITS:0] weight_k_groups;
reg                          psum_accumulated;
reg                          ifmap_highaddr;
reg                          weight_highaddr;
reg [1:0]                    psum_highaddr;

reg [MAX_N_GROUPS_BITS:0] n_group_cnt;
reg [MAX_K_GROUPS_BITS:0] k_group_cnt;
reg [MAX_TILE_M_BITS:0]   tile_m_issue_cnt;
reg [MAX_TILE_M_BITS:0]   tile_m_write_cnt;

reg [5:0] weight_issue_lane;
reg       weight_read_valid_delay;
reg [5:0] weight_read_lane_delay;
reg [WEIGHT_WIDTH-1:0] weight_regfile[0:LANE-1];

reg [IFMAP_ADDR_BITS-2:0]  ifmap_sram_raddr_reg;
reg                        ifmap_sram_rvalid_reg;
reg [WEIGHT_ADDR_BITS-2:0] weight_sram_raddr_reg;
reg                        weight_sram_rvalid_reg;
reg [PSUM_ADDR_BITS-3:0]   psum_sram_raddr_reg;
reg                        psum_sram_rvalid_reg;
reg [PSUM_ADDR_BITS-3:0]   psum_sram_waddr_reg;
reg                        psum_sram_wvalid_reg;
reg [PSUM_WIDTH-1:0]       psum_sram_wdata_reg;

reg                        read_valid_delay;
reg                        psum_read_zero_delay;
reg [PSUM_ADDR_BITS-3:0]   psum_addr_delay;

reg                        mpt_valid;
reg [REAL_IFMAP_WIDTH-1:0] ifmap_vector;
wire [31:0]                mpt_result[0:LANE-1];
wire [LANE-1:0]            mpt_done;

reg [PSUM_WIDTH-1:0]       psum_data_pipe[0:MPT_LATENCY];
reg [PSUM_ADDR_BITS-3:0]   psum_addr_pipe[0:MPT_LATENCY];

wire [MAX_WEIGHT_NUMBER_BITS:0] weight_read_addr_wire;
wire [IFMAP_ADDR_BITS-1:0]      ifmap_read_addr_wire;
wire [PSUM_ADDR_BITS-1:0]       psum_access_addr_wire;

assign weight_read_addr_wire = ((n_group_cnt * weight_k_groups) + k_group_cnt) * LANE + weight_issue_lane;
assign ifmap_read_addr_wire  = k_group_cnt * tile_m + tile_m_issue_cnt;
assign psum_access_addr_wire = n_group_cnt * tile_m + tile_m_issue_cnt;

assign ifmap_sram_raddr  = {ifmap_highaddr, ifmap_sram_raddr_reg};
assign ifmap_sram_rvalid = ifmap_sram_rvalid_reg;

assign weight_sram_raddr  = {weight_highaddr, weight_sram_raddr_reg};
assign weight_sram_rvalid = weight_sram_rvalid_reg;

assign psum_sram_raddr  = {psum_highaddr, psum_sram_raddr_reg};
assign psum_sram_rvalid = psum_sram_rvalid_reg;
assign psum_sram_waddr  = {psum_highaddr, psum_sram_waddr_reg};
assign psum_sram_wvalid = psum_sram_wvalid_reg;
assign psum_sram_wdata  = psum_sram_wdata_reg;

integer init_i;
integer pipe_i;

wire first_k_without_external_psum;
assign first_k_without_external_psum = (k_group_cnt == 0) && (!psum_accumulated);

wire [31:0] psum_lane_data[0:LANE-1];
wire [31:0] accumulator_result[0:LANE-1];
wire [PSUM_WIDTH-1:0] psum_sram_wdata_wire;

genvar lane_unpack_i;
generate
  for (lane_unpack_i = 0; lane_unpack_i < LANE; lane_unpack_i = lane_unpack_i + 1) begin : psum_lane_unpack
    assign psum_lane_data[lane_unpack_i] = psum_data_pipe[MPT_LATENCY][lane_unpack_i*32+:32];
    assign accumulator_result[lane_unpack_i] = mpt_result[lane_unpack_i] + psum_lane_data[lane_unpack_i];
    assign psum_sram_wdata_wire[lane_unpack_i*32+:32] = accumulator_result[lane_unpack_i];
  end
endgenerate

genvar mpt_i;
generate
  for (mpt_i = 0; mpt_i < LANE; mpt_i = mpt_i + 1) begin : mpt
    mpt_int8 #(
      .PARALLELISM ( PARALLELISM )
    ) u_mpt(
      .clk    ( clk                    ),
      .rst_n  ( rst_n                  ),
      .valid  ( mpt_valid              ),
      .a      ( ifmap_vector           ),
      .b      ( weight_regfile[mpt_i]  ),
      .o      ( mpt_result[mpt_i]      ),
      .done   ( mpt_done[mpt_i]        ),
      .clear  ( fake_done              )
    );
  end
endgenerate

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state <= STATE_IDLE;

    config_done <= 1'b0;
    gemm_execute_done <= 1'b0;
    unsupported_done <= 1'b0;

    tile_m <= 0;
    n_groups <= 0;
    weight_k_groups <= 0;
    psum_accumulated <= 1'b0;
    ifmap_highaddr <= 1'b0;
    weight_highaddr <= 1'b0;
    psum_highaddr <= 2'b00;

    n_group_cnt <= 0;
    k_group_cnt <= 0;
    tile_m_issue_cnt <= 0;
    tile_m_write_cnt <= 0;
    weight_issue_lane <= 0;
    weight_read_valid_delay <= 1'b0;
    weight_read_lane_delay <= 0;

    ifmap_sram_raddr_reg <= 0;
    ifmap_sram_rvalid_reg <= 1'b0;
    weight_sram_raddr_reg <= 0;
    weight_sram_rvalid_reg <= 1'b0;
    psum_sram_raddr_reg <= 0;
    psum_sram_rvalid_reg <= 1'b0;
    psum_sram_waddr_reg <= 0;
    psum_sram_wvalid_reg <= 1'b0;
    psum_sram_wdata_reg <= 0;

    read_valid_delay <= 1'b0;
    psum_read_zero_delay <= 1'b0;
    psum_addr_delay <= 0;
    mpt_valid <= 1'b0;
    ifmap_vector <= 0;

    for (init_i = 0; init_i < LANE; init_i = init_i + 1) begin
      weight_regfile[init_i] <= 0;
    end
    for (init_i = 0; init_i <= MPT_LATENCY; init_i = init_i + 1) begin
      psum_data_pipe[init_i] <= 0;
      psum_addr_pipe[init_i] <= 0;
    end
  end
  else begin
    config_done <= 1'b0;
    gemm_execute_done <= 1'b0;
    unsupported_done <= 1'b0;

    ifmap_sram_rvalid_reg <= 1'b0;
    weight_sram_rvalid_reg <= 1'b0;
    psum_sram_rvalid_reg <= 1'b0;
    psum_sram_wvalid_reg <= 1'b0;

    weight_read_valid_delay <= weight_sram_rvalid_reg;
    read_valid_delay <= ifmap_sram_rvalid_reg;
    mpt_valid <= read_valid_delay;

    if (weight_read_valid_delay) begin
      weight_regfile[weight_read_lane_delay] <= weight_sram_rdata;
    end

    if (read_valid_delay) begin
      ifmap_vector <= ifmap_sram_rdata[REAL_IFMAP_WIDTH-1:0];
      psum_data_pipe[0] <= psum_read_zero_delay ? {PSUM_WIDTH{1'b0}} : psum_sram_rdata;
      psum_addr_pipe[0] <= psum_addr_delay;
    end
    else begin
      psum_data_pipe[0] <= {PSUM_WIDTH{1'b0}};
      psum_addr_pipe[0] <= 0;
    end

    for (pipe_i = 1; pipe_i <= MPT_LATENCY; pipe_i = pipe_i + 1) begin
      psum_data_pipe[pipe_i] <= psum_data_pipe[pipe_i-1];
      psum_addr_pipe[pipe_i] <= psum_addr_pipe[pipe_i-1];
    end

    if (|mpt_done) begin
      psum_sram_wvalid_reg <= 1'b1;
      psum_sram_waddr_reg <= psum_addr_pipe[MPT_LATENCY];
      psum_sram_wdata_reg <= psum_sram_wdata_wire;
    end

    case (state)
      STATE_IDLE: begin
        if (insn_valid_reg) begin
          if (insn_kind_wire == PEA_CONFIG_INSN) begin
            config_done <= 1'b1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            tile_m <= gemm_tile_m_wire + 1'b1;
            n_groups <= gemm_n_groups_wire + 1'b1;
            weight_k_groups <= gemm_k_groups_wire + 1'b1;
            ifmap_highaddr <= gemm_ifmap_highaddr_wire;
            weight_highaddr <= gemm_weight_highaddr_wire;
            psum_highaddr <= gemm_psum_highaddr_wire;
            psum_accumulated <= gemm_psum_accumulated_wire;

            n_group_cnt <= 0;
            k_group_cnt <= 0;
            tile_m_issue_cnt <= 0;
            tile_m_write_cnt <= 0;
            weight_issue_lane <= 0;
            weight_read_valid_delay <= 1'b0;
            state <= STATE_LOAD_WEIGHT;
          end
          else begin
            unsupported_done <= 1'b1;
          end
        end
      end

      STATE_LOAD_WEIGHT: begin
        if (weight_issue_lane < LANE) begin
          weight_sram_rvalid_reg <= 1'b1;
          weight_sram_raddr_reg <= weight_read_addr_wire[WEIGHT_ADDR_BITS-2:0];
          weight_read_lane_delay <= weight_issue_lane;
          weight_issue_lane <= weight_issue_lane + 1'b1;
        end

        if (weight_read_valid_delay && (weight_read_lane_delay == LANE - 1)) begin
          tile_m_issue_cnt <= 0;
          tile_m_write_cnt <= 0;
          read_valid_delay <= 1'b0;
          mpt_valid <= 1'b0;
          state <= STATE_RUN_TILE;
        end
      end

      STATE_RUN_TILE: begin
        if (tile_m_issue_cnt < tile_m) begin
          ifmap_sram_rvalid_reg <= 1'b1;
          ifmap_sram_raddr_reg <= ifmap_read_addr_wire[IFMAP_ADDR_BITS-2:0];

          psum_sram_rvalid_reg <= !first_k_without_external_psum;
          psum_sram_raddr_reg <= psum_access_addr_wire[PSUM_ADDR_BITS-3:0];
          psum_read_zero_delay <= first_k_without_external_psum;
          psum_addr_delay <= psum_access_addr_wire[PSUM_ADDR_BITS-3:0];

          tile_m_issue_cnt <= tile_m_issue_cnt + 1'b1;
        end

        if (|mpt_done) begin
          if (tile_m_write_cnt == tile_m - 1'b1) begin
            tile_m_write_cnt <= 0;
            tile_m_issue_cnt <= 0;
            weight_issue_lane <= 0;
            weight_read_valid_delay <= 1'b0;

            if (k_group_cnt == weight_k_groups - 1'b1) begin
              k_group_cnt <= 0;
              if (n_group_cnt == n_groups - 1'b1) begin
                state <= STATE_IDLE;
                gemm_execute_done <= 1'b1;
              end
              else begin
                n_group_cnt <= n_group_cnt + 1'b1;
                state <= STATE_LOAD_WEIGHT;
              end
            end
            else begin
              k_group_cnt <= k_group_cnt + 1'b1;
              state <= STATE_LOAD_WEIGHT;
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

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_time <= 32'd0;
  end
  else if (state != STATE_IDLE && enable_prof_counter) begin
    execute_time <= execute_time + 1'b1;
  end
end

endmodule

module mpt_int8 (
  clk, rst_n,
  valid,
  a, b,
  o,
  done, clear
);

parameter PARALLELISM = 16;

input                            clk;
input                            rst_n;
input                            valid;
input       [PARALLELISM*16-1:0] a;
input       [PARALLELISM*16-1:0] b;
output wire [31:0]               o;
output wire                      done;
input                            clear;

localparam INT8_COUNT = PARALLELISM * 2;

wire signed [7:0]  a_int8[0:INT8_COUNT-1];
wire signed [7:0]  b_int8[0:INT8_COUNT-1];
wire signed [15:0] product[0:INT8_COUNT-1];

reg signed [31:0] product_pair[0:PARALLELISM-1];
reg signed [31:0] sum_stage_0[0:PARALLELISM/2-1];
reg signed [31:0] sum_stage_1[0:PARALLELISM/4-1];
reg signed [31:0] sum_stage_2[0:PARALLELISM/8-1];
reg signed [31:0] sum_stage_3;
reg signed [31:0] result_delay[0:5];
reg [10:0]        valid_pipe;

assign done = valid_pipe[10];
assign o    = result_delay[5];

genvar unpack_i;
generate
  for (unpack_i = 0; unpack_i < INT8_COUNT; unpack_i = unpack_i + 1) begin : int8_unpack
    assign a_int8[unpack_i] = a[unpack_i*8+:8];
    assign b_int8[unpack_i] = b[unpack_i*8+:8];
    assign product[unpack_i] = a_int8[unpack_i] * b_int8[unpack_i];
  end
endgenerate

integer product_i;
integer sum_i;
integer delay_i;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    valid_pipe <= 11'd0;
    sum_stage_3 <= 32'd0;
    for (product_i = 0; product_i < PARALLELISM; product_i = product_i + 1) begin
      product_pair[product_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/2; sum_i = sum_i + 1) begin
      sum_stage_0[sum_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/4; sum_i = sum_i + 1) begin
      sum_stage_1[sum_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/8; sum_i = sum_i + 1) begin
      sum_stage_2[sum_i] <= 32'd0;
    end
    for (delay_i = 0; delay_i < 6; delay_i = delay_i + 1) begin
      result_delay[delay_i] <= 32'd0;
    end
  end
  else if (clear) begin
    valid_pipe <= 11'd0;
    sum_stage_3 <= 32'd0;
    for (product_i = 0; product_i < PARALLELISM; product_i = product_i + 1) begin
      product_pair[product_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/2; sum_i = sum_i + 1) begin
      sum_stage_0[sum_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/4; sum_i = sum_i + 1) begin
      sum_stage_1[sum_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/8; sum_i = sum_i + 1) begin
      sum_stage_2[sum_i] <= 32'd0;
    end
    for (delay_i = 0; delay_i < 6; delay_i = delay_i + 1) begin
      result_delay[delay_i] <= 32'd0;
    end
  end
  else begin
    valid_pipe <= {valid_pipe[9:0], valid};

    for (product_i = 0; product_i < PARALLELISM; product_i = product_i + 1) begin
      product_pair[product_i] <= {{16{product[product_i*2][15]}}, product[product_i*2]} +
                                 {{16{product[product_i*2+1][15]}}, product[product_i*2+1]};
    end

    for (sum_i = 0; sum_i < PARALLELISM/2; sum_i = sum_i + 1) begin
      sum_stage_0[sum_i] <= product_pair[sum_i*2] + product_pair[sum_i*2+1];
    end

    for (sum_i = 0; sum_i < PARALLELISM/4; sum_i = sum_i + 1) begin
      sum_stage_1[sum_i] <= sum_stage_0[sum_i*2] + sum_stage_0[sum_i*2+1];
    end

    for (sum_i = 0; sum_i < PARALLELISM/8; sum_i = sum_i + 1) begin
      sum_stage_2[sum_i] <= sum_stage_1[sum_i*2] + sum_stage_1[sum_i*2+1];
    end

    sum_stage_3 <= sum_stage_2[0] + sum_stage_2[1];
    result_delay[0] <= sum_stage_3;
    for (delay_i = 1; delay_i < 6; delay_i = delay_i + 1) begin
      result_delay[delay_i] <= result_delay[delay_i-1];
    end
  end
end

endmodule