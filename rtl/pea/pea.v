module pea(
  clk, rst_n,
  work_en, insn, insn_read, done,

  ifmap_sram_raddr, ifmap_sram_rvalid, ifmap_sram_rdata, ifmap_sram_rsparse,
  ifmapmask_sram_raddr, ifmapmask_sram_rvalid, ifmapmask_sram_rdata,
  weight_sram_raddr, weight_sram_rvalid, weight_sram_rdata,
  psum_sram_raddr, psum_sram_rvalid, psum_sram_rdata,
  psum_sram_waddr, psum_sram_wvalid, psum_sram_wdata,
  ifmap_scale_sram_raddr, ifmap_scale_sram_rvalid, ifmap_scale_sram_rdata,
  weight_scale_sram_raddr, weight_scale_sram_rvalid, weight_scale_sram_rdata,
  outlier_index_sram_raddr, outlier_index_sram_rvalid, outlier_index_sram_rdata, outlier_index_sram_rsparse,

  enable_prof_counter, execute_time
);

parameter TYPE_IS_INT4 = 0;
parameter TYPE_IS_INT8 = 1;
parameter TYPE_IS_FP16 = 2;
parameter TYPE_IS_BF16 = 3;

parameter PARALLELISM  = 16;
parameter LANE         = 32;

parameter IFMAP_ADDR_BITS         = 11;
parameter IFMAPMASK_ADDR_BITS     = 12;
parameter WEIGHT_ADDR_BITS        = 12;
parameter PSUM_ADDR_BITS          = 12;
parameter IFMAP_SCALE_ADDR_BITS   = 11;
parameter WEIGHT_SCALE_ADDR_BITS  = 12;
parameter OUTLIER_INDEX_ADDR_BITS = 11;

parameter IFMAP_WIDTH         = 512;
parameter IFMAPMASK_WIDTH     = 128;
parameter WEIGHT_WIDTH        = 256;
parameter PSUM_WIDTH          = 1024;
parameter IFMAP_SCALE_WIDTH   = 32;
parameter WEIGHT_SCALE_WIDTH  = 16;
parameter OUTLIER_INDEX_WIDTH = 128;

parameter MAX_IFMAP_WIDTH   = 2048;
parameter MAX_IFMAP_HEIGHT  = 2048;
parameter MAX_WEIGHT_WIDTH  = 128;
parameter MAX_WEIGHT_HEIGHT = 128;
parameter MAX_PSUM_WIDTH    = 2048;
parameter MAX_PSUM_HEIGHT   = 2048;
parameter MAX_CHANNEL       = 128;

parameter MAX_IFMAP_WIDTH_BITS     = 12;
parameter MAX_IFMAP_HEIGHT_BITS    = 12;
parameter MAX_WEIGHT_WIDTH_BITS    = 8;
parameter MAX_WEIGHT_HEIGHT_BITS   = 8;
parameter MAX_PSUM_WIDTH_BITS      = 12;
parameter MAX_PSUM_HEIGHT_BITS     = 12;
parameter MAX_CHANNEL_BITS         = 8;
parameter MAX_PAD_LEFT_BITS        = 7;
parameter MAX_PAD_TOP_BITS         = 7;
parameter MAX_STRIDE_WIDTH_BITS    = 5;
parameter MAX_STRIDE_HEIGHT_BITS   = 5;
parameter MAX_DILATION_WIDTH_BITS  = 5;
parameter MAX_DILATION_HEIGHT_BITS = 5;

parameter MAX_TILE_M_BITS   = 12;
parameter MAX_K_GROUPS_BITS = 8;
parameter MAX_N_GROUPS_BITS = 8;

parameter MAX_PSUM_NUMBER_BITS   = 12;
parameter MAX_WEIGHT_NUMBER_BITS = 19;

parameter REAL_IFMAP_WIDTH          = 256;
parameter REAL_OUTLIER_INDEX_WIDTH  = 64;

localparam PEA_CONFIG_INSN     = 0;
localparam CONV_EXECUTE_INSN   = 1;
localparam GEMM_EXECUTE_INSN   = 2;
localparam DECONV_EXECUTE_INSN = 3;

input               clk;
input               rst_n;
input               work_en;
input       [127:0] insn;
output reg          insn_read;
output reg          done;

output wire [IFMAP_ADDR_BITS-1:0]         ifmap_sram_raddr;
output wire                               ifmap_sram_rvalid;
input       [IFMAP_WIDTH-1:0]             ifmap_sram_rdata;
output wire [1:0]                         ifmap_sram_rsparse;

output wire [IFMAPMASK_ADDR_BITS-1:0]     ifmapmask_sram_raddr;
output wire                               ifmapmask_sram_rvalid;
input       [IFMAPMASK_WIDTH-1:0]         ifmapmask_sram_rdata;

output wire [WEIGHT_ADDR_BITS-1:0]        weight_sram_raddr;
output wire                               weight_sram_rvalid;
input       [WEIGHT_WIDTH-1:0]            weight_sram_rdata;

output wire [PSUM_ADDR_BITS-1:0]          psum_sram_raddr;
output wire                               psum_sram_rvalid;
input       [PSUM_WIDTH-1:0]              psum_sram_rdata;

output wire [PSUM_ADDR_BITS-1:0]          psum_sram_waddr;
output wire                               psum_sram_wvalid;
output wire [PSUM_WIDTH-1:0]              psum_sram_wdata;

output wire [IFMAP_SCALE_ADDR_BITS-1:0]   ifmap_scale_sram_raddr;
output wire                               ifmap_scale_sram_rvalid;
input       [IFMAP_SCALE_WIDTH-1:0]       ifmap_scale_sram_rdata;

output wire [WEIGHT_SCALE_ADDR_BITS-1:0]  weight_scale_sram_raddr;
output wire                               weight_scale_sram_rvalid;
input       [WEIGHT_SCALE_WIDTH-1:0]      weight_scale_sram_rdata;

output wire [OUTLIER_INDEX_ADDR_BITS-1:0] outlier_index_sram_raddr;
output wire                               outlier_index_sram_rvalid;
input       [OUTLIER_INDEX_WIDTH-1:0]     outlier_index_sram_rdata;
output wire [1:0]                         outlier_index_sram_rsparse;

input                                     enable_prof_counter;
output reg  [31:0]                        execute_time;

reg       insn_valid;
reg [3:0] insn_number;
reg       config_done;
reg       conv_execute_done;
reg       gemm_execute_done;
reg       deconv_execute_done;
wire      compute_done;
wire      fake_done;

assign fake_done = config_done | conv_execute_done | gemm_execute_done;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    done <= 1'b0;
  end
  else begin
    if (fake_done && (~|insn_number)) begin
      done <= 1'b1;
    end
    else begin
      done <= 1'b0;
    end
  end
end

reg [5:0] insn_opcode;
reg [2:0] insn_kind;
reg [2:0] type_a;
reg [2:0] type_b;
reg       type_accumulator;
reg [1:0] type_output;
reg       sparse_enable;
reg       weight_non_uniform_quantization;
reg       ifmap_non_uniform_quantization;
reg       outlier_enable;

localparam IFMAP_RADDR_NO_RESET      = 0;
localparam IFMAP_RADDR_RESET         = 1;
localparam IFMAP_RADDR_RESET_PER_TWO = 2;

localparam WEIGHT_NO_MOVE    = 0;
localparam WEIGHT_MOVE_8TO16 = 1;
localparam WEIGHT_MOVE_4TO16 = 2;
localparam WEIGHT_MOVE_4TO8  = 3;
localparam WEIGHT_MOVE_4UTO8 = 4;

localparam IFMAP_NO_MOVE    = 0;
localparam IFMAP_MOVE_8TO16 = 1;
localparam IFMAP_MOVE_4TO16 = 2;
localparam IFMAP_MOVE_4TO8  = 3;
localparam IFMAP_MOVE_4UTO8 = 4;

reg [1:0] ifmap_sram_addr_control_mode;
reg [2:0] weight_data_move_control_mode;
reg [2:0] ifmap_data_move_control_mode;

reg       weight_1_ifmap_2;
reg       weight_1_ifmap_2_identifier;
reg       weight_1_ifmap_2_identifier_delay_1;
reg       weight_1_ifmap_2_identifier_delay_2;
reg       weight_1_ifmap_2_identifier_delay_3;
reg       weight_1_ifmap_2_identifier_delay_4;

reg       weight_1_ifmap_4;
reg [1:0] weight_1_ifmap_4_identifier;
reg [1:0] weight_1_ifmap_4_identifier_delay_1;
reg [1:0] weight_1_ifmap_4_identifier_delay_2;
reg [1:0] weight_1_ifmap_4_identifier_delay_3;
reg [1:0] weight_1_ifmap_4_identifier_delay_4;

reg       weight_2_ifmap_2;
reg       weight_2_ifmap_2_identifier;
reg       weight_2_ifmap_2_identifier_delay_1;
reg       weight_2_ifmap_2_identifier_delay_2;
reg       weight_2_ifmap_2_identifier_delay_3;
reg       weight_2_ifmap_2_identifier_delay_4;

reg       weight_2_ifmap_4;
reg       weight_2_ifmap_4_identifier;
reg       weight_2_ifmap_4_identifier_delay_1;
reg       weight_2_ifmap_4_identifier_delay_2;
reg       weight_2_ifmap_4_identifier_delay_3;
reg       weight_2_ifmap_4_identifier_delay_4;
reg       weight_2_ifmap_4_cross_ic;
reg       weight_2_ifmap_4_cross_ic_delay_1;
reg       weight_2_ifmap_4_cross_ic_delay_2;
reg       weight_2_ifmap_4_cross_ic_delay_3;
reg       weight_2_ifmap_4_cross_ic_delay_4;

reg       weight_4_ifmap_4;
reg [1:0] weight_4_ifmap_4_identifier;
reg [1:0] weight_4_ifmap_4_identifier_delay_1;
reg [1:0] weight_4_ifmap_4_identifier_delay_2;
reg [1:0] weight_4_ifmap_4_identifier_delay_3;
reg [1:0] weight_4_ifmap_4_identifier_delay_4;

reg multiple_read_trigger;

reg [MAX_STRIDE_WIDTH_BITS:0]    stride_width;
reg [MAX_STRIDE_HEIGHT_BITS:0]   stride_height;
reg [MAX_DILATION_WIDTH_BITS:0]  dilation_width;
reg [MAX_DILATION_HEIGHT_BITS:0] dilation_height;

reg [MAX_IFMAP_WIDTH_BITS:0]     ifmap_width;
reg [MAX_IFMAP_HEIGHT_BITS:0]    ifmap_height;
reg [MAX_WEIGHT_WIDTH_BITS:0]    weight_width;
reg [MAX_WEIGHT_HEIGHT_BITS:0]   weight_height;
reg [MAX_WEIGHT_NUMBER_BITS:0]   weight_number;
reg [MAX_PSUM_WIDTH_BITS:0]      psum_width;
reg [MAX_PSUM_HEIGHT_BITS:0]     psum_height;
reg [MAX_CHANNEL_BITS:0]         weight_ic_group;
reg [MAX_CHANNEL_BITS:0]         psum_ic_group;
reg [MAX_CHANNEL_BITS:0]         oc_group;
reg [MAX_PAD_LEFT_BITS-1:0]      pad_left;
reg [MAX_PAD_TOP_BITS-1:0]       pad_top;

reg [MAX_TILE_M_BITS:0]   tile_m;
reg [MAX_N_GROUPS_BITS:0] n_groups;
reg [MAX_K_GROUPS_BITS:0] weight_k_groups;
reg [MAX_K_GROUPS_BITS:0] psum_k_groups;

reg [MAX_PSUM_NUMBER_BITS:0] psum_number;
reg                          psum_accumulated;
reg                          ifmap_scale_enable;
reg                          weight_scale_enable;
reg                          ifmap_highaddr;
reg                          weight_highaddr;
reg [1:0]                    psum_highaddr;

reg [MAX_IFMAP_HEIGHT_BITS:0]  ifmap_area;
reg [MAX_WEIGHT_HEIGHT_BITS:0] weight_area;
reg [MAX_PSUM_HEIGHT_BITS:0]   psum_area;

reg [MAX_PSUM_WIDTH_BITS-1:0]    psum_width_read_cnt;
reg [MAX_PSUM_HEIGHT_BITS-1:0]   psum_height_read_cnt;
reg [MAX_WEIGHT_WIDTH_BITS-1:0]  weight_width_read_cnt;
reg [MAX_WEIGHT_HEIGHT_BITS-1:0] weight_height_read_cnt;
reg [MAX_CHANNEL_BITS-1:0]       weight_ic_group_read_cnt;
reg [MAX_CHANNEL_BITS-1:0]       weight_oc_group_read_cnt;

reg [MAX_TILE_M_BITS-1:0]   psum_m_tile_read_cnt;
reg [MAX_K_GROUPS_BITS-1:0] weight_k_group_read_cnt;
reg [MAX_N_GROUPS_BITS-1:0] weight_n_group_read_cnt;

reg [MAX_WEIGHT_WIDTH_BITS-1:0]  weight_width_write_cnt;
reg [MAX_WEIGHT_HEIGHT_BITS-1:0] weight_height_write_cnt;
reg [MAX_PSUM_NUMBER_BITS:0]     psum_sram_write_cnt;
reg [MAX_PSUM_WIDTH_BITS-1:0]    psum_width_write_cnt;
reg [MAX_PSUM_HEIGHT_BITS-1:0]   psum_height_write_cnt;
reg [MAX_CHANNEL_BITS-1:0]       psum_ic_group_write_cnt;
reg [MAX_CHANNEL_BITS-1:0]       psum_oc_group_write_cnt;

reg [MAX_TILE_M_BITS-1:0]   psum_m_tile_write_cnt; 
reg [MAX_K_GROUPS_BITS-1:0] psum_k_group_write_cnt;
reg [MAX_N_GROUPS_BITS-1:0] psum_n_group_write_cnt;

wire psum_width_read_done;
wire psum_height_read_done;
wire weight_width_read_done;
wire weight_height_read_done;
wire weight_ic_group_read_done;
wire weight_oc_group_read_done;
reg  psum_read_done;

wire weight_width_write_done;
wire weight_height_write_done;
wire psum_width_write_done;
wire psum_height_write_done;
wire psum_ic_group_write_done;
wire psum_oc_group_write_done;

wire psum_m_tile_read_done;
wire weight_n_group_read_done;
wire weight_k_group_read_done;

wire psum_m_tile_write_done;
wire psum_n_group_write_done;
wire psum_k_group_write_done;

reg  [IFMAP_ADDR_BITS-2:0]  ifmap_sram_raddr_reg;
reg                         ifmap_sram_rvalid_reg;
reg  [IFMAP_WIDTH-1:0]      ifmap_local_rdata_reg;
wire [IFMAP_WIDTH-1:0]      read_ifmap_local_rdata;
reg  [WEIGHT_ADDR_BITS-2:0] weight_sram_raddr_reg;
reg                         weight_sram_rvalid_reg;
wire [PSUM_ADDR_BITS-3:0]   psum_sram_waddr_wire;
reg  [PSUM_ADDR_BITS-3:0]   psum_sram_waddr_reg;
reg                         psum_sram_wvalid_reg;
reg  [PSUM_WIDTH-1:0]       psum_sram_wdata_reg;
reg  [PSUM_ADDR_BITS-3:0]   psum_sram_raddr_reg;
reg                         psum_sram_rvalid_reg;
reg  [PSUM_WIDTH-1:0]       psum_local_rdata_reg;
reg  [IFMAP_ADDR_BITS-1:0]  ifmap_scale_sram_raddr_reg;

wire [IFMAP_WIDTH-1:0] ifmap_local_rdata_16_8_lower;
wire [IFMAP_WIDTH-1:0] ifmap_local_rdata_16_8_upper;

wire [IFMAP_WIDTH-1:0] ifmap_local_rdata_16_4_0;
wire [IFMAP_WIDTH-1:0] ifmap_local_rdata_16_4_1;
wire [IFMAP_WIDTH-1:0] ifmap_local_rdata_16_4_2;
wire [IFMAP_WIDTH-1:0] ifmap_local_rdata_16_4_3;

wire [IFMAP_WIDTH-1:0] ifmap_local_rdata_8_4_lower;
wire [IFMAP_WIDTH-1:0] ifmap_local_rdata_8_4_upper;

reg weight_sram_ping_valid;
reg weight_sram_pang_valid;
reg weight_sram_ping_loading;
reg weight_sram_ping_loading_delay;
reg weight_sram_pang_loading;
reg weight_sram_pang_loading_delay;
reg weight_sram_ping_loaded;
reg weight_sram_pang_loaded;
reg weight_sram_ping_pang_identifier;
reg weight_sram_ping_pang_identifier_delay_1;
reg weight_sram_ping_pang_identifier_delay_2;
reg weight_sram_ping_pang_identifier_delay_3;
reg weight_sram_valid_reg;
reg ifmapmask_sram_valid_reg;

reg [4:0] weight_sram_ping_loading_cnt;
reg [4:0] weight_sram_ping_loading_cnt_delay;
reg [4:0] weight_sram_pang_loading_cnt;
reg [4:0] weight_sram_pang_loading_cnt_delay;

reg weight_regfile_ping_wen;
reg weight_regfile_pang_wen;
reg [4:0] weight_regfile_ping_waddr;
reg [4:0] weight_regfile_pang_waddr;

reg weight_ping_pang_loading;
reg weight_ping_pang_using;
reg psum_sram_valid_reg;
reg psum_sram_valid_reg_delay;
reg ifmap_sram_valid_reg;
reg ifmap_sram_valid_reg_delay;

wire [PSUM_ADDR_BITS-3:0]  psum_sram_raddr_wire;
wire [IFMAP_ADDR_BITS-1:0] ifmap_sram_raddr_wire;
wire [IFMAP_ADDR_BITS-1:0] ifmap_scale_sram_raddr_wire;
wire                       psum_read_zero_wire;
reg                        psum_read_zero_reg;
reg                        psum_read_zero_reg_delay;
reg                        psum_read_zero_reg_delay_1;

reg ifmap_local_rdata_valid;
reg ifmap_local_rdata_valid_delay;
reg psum_local_rdata_valid;
reg psum_local_rdata_valid_delay;

wire [IFMAP_ADDR_BITS-1:0] ifmap_horizontal_offset;
wire [IFMAP_ADDR_BITS-1:0] ifmap_vertical_offset;
wire [IFMAP_ADDR_BITS-1:0] ifmap_col_nopad;
wire [IFMAP_ADDR_BITS-1:0] ifmap_row_nopad;
wire                       ifmap_read_zero_wire;
reg                        ifmap_read_zero_reg;
reg                        ifmap_read_zero_reg_delay;
reg                        ifmap_read_zero_reg_delay_1;

assign ifmap_sram_raddr           = {ifmap_highaddr, ifmap_sram_raddr_reg};
assign ifmap_sram_rvalid          = ifmap_sram_rvalid_reg & (!ifmap_read_zero_reg);
assign ifmap_sram_rsparse         = sparse_enable;
assign outlier_index_sram_rsparse = sparse_enable;

assign weight_sram_raddr  = {weight_highaddr, weight_sram_raddr_reg};
assign weight_sram_rvalid = weight_sram_rvalid_reg;

assign psum_sram_raddr  = {psum_highaddr, psum_sram_raddr_reg};
assign psum_sram_waddr  = {psum_highaddr, psum_sram_waddr_reg};
assign psum_sram_rvalid = psum_sram_rvalid_reg & (!psum_read_zero_reg);
assign psum_sram_wvalid = psum_sram_wvalid_reg;
assign psum_sram_wdata  = psum_sram_wdata_reg;

reg execute_start;

reg fma_done_reg;
reg accumulator_done_reg;
reg compute_done_reg;

reg  [WEIGHT_WIDTH-1:0] weight_regfile_ping[0:LANE-1];
reg  [WEIGHT_WIDTH-1:0] weight_regfile_pang[0:LANE-1];
reg  [WEIGHT_WIDTH-1:0] weight_local_data[0:LANE-1];
wire [WEIGHT_WIDTH-1:0] weight_local_data_shifted[0:LANE-1];
reg  [WEIGHT_WIDTH-1:0] weight_local_data_shifted_reg[0:LANE-1];

reg [2:0] type_a_reg_stage_1;
reg [2:0] type_a_reg_stage_2;
reg [2:0] type_b_reg_stage_1;
reg [2:0] type_b_reg_stage_2;

genvar weight_local_data_idx;
generate
  for (weight_local_data_idx = 0; weight_local_data_idx < LANE; weight_local_data_idx = weight_local_data_idx + 1) begin : weight_local_data_assign
    data_move_weight u_data_move_weight(
      .in                          ( weight_local_data[weight_local_data_idx]         ),
      .out                         ( weight_local_data_shifted[weight_local_data_idx] ),
      .mode                        ( weight_data_move_control_mode                    ),
      .type_a                      ( type_a_reg_stage_2                               ),
      .outlier_enable              ( outlier_enable                                   ),
      .weight_1_ifmap_4_identifier ( weight_1_ifmap_4_identifier_delay_4              ),
      .weight_1_ifmap_2_identifier ( weight_1_ifmap_2_identifier_delay_4              )
    );
    
    always @(*) begin
      if (weight_ping_pang_using) begin
        weight_local_data[weight_local_data_idx] = weight_regfile_pang[weight_local_data_idx];
      end
      else begin
        weight_local_data[weight_local_data_idx] = weight_regfile_ping[weight_local_data_idx];
      end
    end

    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        weight_local_data_shifted_reg[weight_local_data_idx] <= 'd0;
      end
      else begin
        weight_local_data_shifted_reg[weight_local_data_idx] <= weight_local_data_shifted[weight_local_data_idx];
      end
    end
  end

endgenerate

wire [15:0] weight_scale_local_data[0:LANE-1];

wire mpt_valid;

assign mpt_valid = ifmap_local_rdata_valid_delay & psum_local_rdata_valid_delay;

wire [31:0]     mpt_result[0:LANE-1];
reg  [31:0]     mpt_result_reg[0:LANE-1];
wire [LANE-1:0] mpt_done;

reg outlier_second_pass;
reg outlier_second_pass_delay_delay_1;
reg outlier_second_pass_delay_delay_2;
reg outlier_second_pass_delay_delay_3;
reg outlier_second_pass_delay_delay_4;

reg [OUTLIER_INDEX_WIDTH-1:0] outlier_index_local_rdata_reg;
reg [OUTLIER_INDEX_WIDTH-1:0] real_outlier_index_data;

reg  [IFMAP_SCALE_WIDTH-1:0]  ifmap_scale_local_rdata_reg;
reg  [WEIGHT_SCALE_WIDTH-1:0] weight_scale_local_data_reg_ping[0:LANE-1];
reg  [WEIGHT_SCALE_WIDTH-1:0] weight_scale_local_data_reg_pang[0:LANE-1];
reg  [IFMAPMASK_WIDTH-1:0]    ifmapmask_local_data_reg_ping[0:LANE-1];
reg  [IFMAPMASK_WIDTH-1:0]    ifmapmask_local_data_reg_pang[0:LANE-1];
reg  [IFMAPMASK_WIDTH-1:0]    ifmapmask_local_data[0:LANE-1];
wire [IFMAPMASK_WIDTH-1:0]    real_ifmapmask_local_data[0:LANE-1];

wire [31:0]            fma_result[0:LANE-1];
wire [31:0]            accumulator_result[0:LANE-1];
wire [PSUM_WIDTH-1:0]  accumulator_result_pack;

generate
genvar accumulator_result_pack_idx;
  for (accumulator_result_pack_idx=0; accumulator_result_pack_idx<LANE; accumulator_result_pack_idx=accumulator_result_pack_idx+1) begin: accumulator_result_pack_array 
    assign accumulator_result_pack[(32*accumulator_result_pack_idx+31):(32*accumulator_result_pack_idx)] = accumulator_result[accumulator_result_pack_idx][31:0];
  end
endgenerate

reg [REAL_IFMAP_WIDTH-1:0] ifmap_local_data[0:LANE-1];

wire [REAL_IFMAP_WIDTH-1:0] ifmap_sparse_4bit_data[0:LANE-1];
wire [REAL_IFMAP_WIDTH-1:0] ifmap_sparse_8bit_data[0:LANE-1];
wire [REAL_IFMAP_WIDTH-1:0] ifmap_sparse_16bit_data[0:LANE-1];

reg [REAL_OUTLIER_INDEX_WIDTH-1:0] outlier_index_local_data[0:LANE-1];
reg [REAL_OUTLIER_INDEX_WIDTH-1:0] outlier_index_local_data_reg[0:LANE-1];

wire [REAL_OUTLIER_INDEX_WIDTH-1:0] outlier_index_sparse_4bit_data[0:LANE-1];
wire [REAL_OUTLIER_INDEX_WIDTH/2-1:0] outlier_index_sparse_8bit_data[0:LANE-1];

/* -------------------------------------------------------------------------------------------------------- */
/*                                            Instruction Decoder                                           */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    insn_valid <= 1'b0;
    insn_read  <= 1'b0;
	end
	else begin
    if (work_en) begin
      insn_read <= work_en;
    end
    else begin
      if (fake_done && |insn_number) begin
        insn_read <= 1'b1;
      end
      else begin
        insn_read <= 1'b0;
      end
    end

    if (insn_read) begin
      insn_valid <= 1'b1;
    end
    else begin
      insn_valid <= 1'b0;
    end
	end 
end

reg insn_valid_reg;
reg [127:0] insn_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_valid_reg <= 1'b0;
    insn_reg <= 128'b0;
  end
  else begin
    if (insn_valid) begin
      insn_valid_reg <= 1'b1;
      insn_reg <= insn;
    end
    else begin
      insn_valid_reg <= 1'b0;
      insn_reg <= insn_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_number <= 'd0; 
  end
  else begin
    if (insn_valid_reg) begin
      insn_number <= |insn_reg[9:6] ? insn_reg[9:6] : insn_number;
    end
    else begin
      if (fake_done && |insn_number) begin
        insn_number <= insn_number - 1;
      end
    end
  end
end

/* -------------------------------------------- execute decoder ------------------------------------------- */

wire [5:0]  insn_opcode_wire;
wire [2:0]  insn_kind_wire;
wire [2:0]  type_a_wire;
wire [2:0]  type_b_wire;
wire        type_accumulator_wire;
wire [1:0]  type_output_wire;
wire [11:0] conv_ifmap_width_wire;
wire [11:0] conv_ifmap_height_wire;
wire [7:0]  conv_weight_width_wire;
wire [7:0]  conv_weight_height_wire;
wire [11:0] conv_psum_width_wire;
wire [11:0] conv_psum_height_wire;
wire [7:0]  conv_ic_group_wire;
wire [7:0]  conv_oc_group_wire;
wire        conv_ifmap_highaddr_wire;
wire        conv_weight_highaddr_wire;
wire [1:0]  conv_psum_highaddr_wire;
wire [6:0]  conv_pad_left_wire;
wire [6:0]  conv_pad_top_wire;
wire [6:0]  conv_psum_number_wire;
wire        conv_psum_accumulated_wire;
wire [11:0] gemm_tile_m_wire;
wire [7:0]  gemm_n_groups_wire;
wire [7:0]  gemm_k_groups_wire;
wire        gemm_ifmap_highaddr_wire;
wire        gemm_weight_highaddr_wire;
wire [1:0]  gemm_psum_highaddr_wire;
wire [11:0] gemm_psum_number_wire;
wire        gemm_psum_accumulated_wire;

assign insn_opcode_wire           = insn_reg[5:0];
assign insn_kind_wire             = insn_reg[12:10];
assign type_a_wire                = insn_reg[15:13];
assign type_b_wire                = insn_reg[18:16];
assign type_accumulator_wire      = insn_reg[19];
assign type_output_wire           = insn_reg[21:20];
assign conv_ifmap_width_wire      = insn_reg[33:22];
assign conv_ifmap_height_wire     = insn_reg[45:34];
assign conv_weight_width_wire     = insn_reg[53:46];
assign conv_weight_height_wire    = insn_reg[61:54];
assign conv_psum_width_wire       = insn_reg[73:62];
assign conv_psum_height_wire      = insn_reg[85:74];
assign conv_ic_group_wire         = insn_reg[93:86];
assign conv_oc_group_wire         = insn_reg[101:94];
assign conv_ifmap_highaddr_wire   = insn_reg[102];
assign conv_weight_highaddr_wire  = insn_reg[103];
assign conv_psum_highaddr_wire    = insn_reg[105:104];
assign conv_pad_left_wire         = insn_reg[112:106];
assign conv_pad_top_wire          = insn_reg[119:113];
assign conv_psum_number_wire      = insn_reg[126:120];
assign conv_psum_accumulated_wire = insn_reg[127];

assign gemm_tile_m_wire           = conv_ifmap_width_wire;
assign gemm_n_groups_wire         = insn_reg[41:34];
assign gemm_k_groups_wire         = insn_reg[49:42];
assign gemm_ifmap_highaddr_wire   = insn_reg[50];
assign gemm_weight_highaddr_wire  = insn_reg[51];
assign gemm_psum_highaddr_wire    = insn_reg[53:52];
assign gemm_psum_number_wire      = insn_reg[65:54];
assign gemm_psum_accumulated_wire = insn_reg[66];

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_start                   <= 0;
    insn_opcode                     <= 0;
    insn_kind                       <= 0;
    sparse_enable                   <= 0;
    weight_non_uniform_quantization <= 0;
    ifmap_non_uniform_quantization  <= 0;
    outlier_enable                  <= 0;
    type_a                          <= 0;
    type_b                          <= 0;
    type_accumulator                <= 0;
    type_output                     <= 0;
    ifmap_width                     <= 0;
    ifmap_height                    <= 0;
    weight_width                    <= 0;
    weight_height                   <= 0;
    weight_number                   <= 0;
    psum_width                      <= 0;
    psum_height                     <= 0;
    weight_ic_group                 <= 0;
    psum_ic_group                   <= 0;
    oc_group                        <= 0;
    pad_left                        <= 0;
    pad_top                         <= 0;
    stride_width                    <= 0;
    stride_height                   <= 0;
    dilation_width                  <= 0;
    dilation_height                 <= 0;
    psum_number                     <= 0;
    psum_accumulated                <= 0;
    ifmap_highaddr                  <= 0;
    weight_highaddr                 <= 0;
    psum_highaddr                   <= 0;
    ifmap_area                      <= 0;
    weight_area                     <= 0;
    psum_area                       <= 0;
    tile_m                          <= 0;
    n_groups                        <= 0;
    weight_k_groups                 <= 0;
    psum_k_groups                   <= 0;
    ifmap_scale_enable              <= 0;
    weight_scale_enable             <= 0;
    weight_1_ifmap_2                <= 0;
    weight_1_ifmap_4                <= 0;
    weight_2_ifmap_2                <= 0;
    weight_2_ifmap_4                <= 0;
    weight_4_ifmap_4                <= 0;
    ifmap_sram_addr_control_mode    <= 0;
    weight_data_move_control_mode   <= 0;
    ifmap_data_move_control_mode    <= 0;
  end
  else begin
    if (insn_valid_reg) begin
      insn_opcode         <= insn_opcode_wire;
      insn_kind           <= insn_kind_wire;
      if (insn_kind_wire == PEA_CONFIG_INSN) begin
        sparse_enable                   <= insn_reg[13];
        weight_non_uniform_quantization <= insn_reg[14];
        ifmap_non_uniform_quantization  <= insn_reg[15];
        outlier_enable                  <= insn_reg[16];
        stride_width                    <= insn_reg[21:17];
        stride_height                   <= insn_reg[26:22];
        dilation_width                  <= insn_reg[31:27];
        dilation_height                 <= insn_reg[36:32];
      end
      else if ((insn_kind_wire == CONV_EXECUTE_INSN) || (insn_kind_wire == GEMM_EXECUTE_INSN)) begin
        execute_start       <= 1;
        type_a              <= type_a_wire;
        type_b              <= type_b_wire;
        type_accumulator    <= type_accumulator_wire;
        type_output         <= type_output_wire;
        ifmap_scale_enable  <= ((type_a_wire == TYPE_IS_INT4) & (type_b_wire == TYPE_IS_INT4) & (type_accumulator_wire) & (type_output_wire == 1)) | 
                               ((type_a_wire == TYPE_IS_INT4) & (type_b_wire == TYPE_IS_INT8) & (type_accumulator_wire) & (type_output_wire == 1)) | 
                               ((type_a_wire == TYPE_IS_INT8) & (type_b_wire == TYPE_IS_INT4) & (type_accumulator_wire) & (type_output_wire == 1)) | 
                               ((type_a_wire == TYPE_IS_INT8) & (type_b_wire == TYPE_IS_INT8) & (type_accumulator_wire) & (type_output_wire == 1));
        weight_scale_enable <= ((type_a_wire == TYPE_IS_INT4) & (type_b_wire == TYPE_IS_INT4) & (type_accumulator_wire) & (type_output_wire == 1)) | 
                               ((type_a_wire == TYPE_IS_INT4) & (type_b_wire == TYPE_IS_INT8) & (type_accumulator_wire) & (type_output_wire == 1)) | 
                               ((type_a_wire == TYPE_IS_INT8) & (type_b_wire == TYPE_IS_INT4) & (type_accumulator_wire) & (type_output_wire == 1)) | 
                               ((type_a_wire == TYPE_IS_INT8) & (type_b_wire == TYPE_IS_INT8) & (type_accumulator_wire) & (type_output_wire == 1));
        
        if ((type_a_wire == TYPE_IS_FP16 && type_b_wire == TYPE_IS_INT8) ||
            (type_a_wire == TYPE_IS_BF16 && type_b_wire == TYPE_IS_INT8)) begin
          weight_data_move_control_mode <= WEIGHT_MOVE_8TO16;    
        end
        else if ((type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT4 && weight_non_uniform_quantization) ||
                 (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && weight_non_uniform_quantization)) begin
          weight_data_move_control_mode <= WEIGHT_MOVE_4UTO8;
        end
        else if ((type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT4 && (!weight_non_uniform_quantization)) ||
                 (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && (!weight_non_uniform_quantization) && (ifmap_non_uniform_quantization))) begin
          weight_data_move_control_mode <= WEIGHT_MOVE_4TO8;
        end
        else if ((type_a_wire == TYPE_IS_BF16 && type_b_wire == TYPE_IS_INT4) ||
                 (type_a_wire == TYPE_IS_FP16 && type_b_wire == TYPE_IS_INT4)) begin
          weight_data_move_control_mode <= WEIGHT_MOVE_4TO16;         
        end
        
        if ((type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_BF16) ||
            (type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_FP16)) begin
          ifmap_data_move_control_mode <= IFMAP_MOVE_8TO16;    
        end
        else if ((type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT8 && ifmap_non_uniform_quantization) ||
                 (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && ifmap_non_uniform_quantization)) begin
          ifmap_data_move_control_mode <= IFMAP_MOVE_4UTO8;
        end
        else if ((type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT8 && (!ifmap_non_uniform_quantization)) ||
                 (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && (!ifmap_non_uniform_quantization) && (weight_non_uniform_quantization))) begin
          ifmap_data_move_control_mode <= IFMAP_MOVE_4TO8;
        end
        else if ((type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_FP16) ||
                 (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_BF16)) begin
          ifmap_data_move_control_mode <= IFMAP_MOVE_4TO16;         
        end
        
        if ((type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_FP16) ||
            (type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_BF16) ||
            (type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT8 && outlier_enable) ||
            (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_FP16) ||
            (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_BF16) ||
            (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT8) ||
            (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && (outlier_enable || ifmap_non_uniform_quantization || weight_non_uniform_quantization))) begin
          ifmap_sram_addr_control_mode <= IFMAP_RADDR_RESET;
        end
        else if ((type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT4 && outlier_enable)) begin
          ifmap_sram_addr_control_mode <= IFMAP_RADDR_RESET_PER_TWO;
        end
        else begin
          ifmap_sram_addr_control_mode <= IFMAP_RADDR_NO_RESET;
        end

        if ((type_a_wire == TYPE_IS_BF16 && type_b_wire == TYPE_IS_INT8) ||
            (type_a_wire == TYPE_IS_FP16 && type_b_wire == TYPE_IS_INT8) ||
            (type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT4 && (!outlier_enable)) ||
            (type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT8 && outlier_enable) ||
            (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && ((outlier_enable && (!(weight_non_uniform_quantization || ifmap_non_uniform_quantization))) || ((!outlier_enable) && (weight_non_uniform_quantization || ifmap_non_uniform_quantization))))) begin
          weight_1_ifmap_2 <= 1'b1;
          if (insn_kind_wire == CONV_EXECUTE_INSN) begin
            if (outlier_enable || ((type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && ((outlier_enable && (!(weight_non_uniform_quantization || ifmap_non_uniform_quantization))) || ((!outlier_enable) && (weight_non_uniform_quantization || ifmap_non_uniform_quantization)))))) begin
              weight_ic_group <= (conv_ic_group_wire + 1);
              psum_ic_group   <= (conv_ic_group_wire + 1) << 1;
            end
            else begin
              weight_ic_group <= (conv_ic_group_wire + 1) << 1;
              psum_ic_group   <= (conv_ic_group_wire + 1) << 1;
            end
            weight_number   <= (conv_weight_height_wire + 1) * (conv_weight_width_wire + 1) * (conv_oc_group_wire + 1) * ((conv_ic_group_wire + 1)) * 32 - 1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            if (outlier_enable || ((type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && ((outlier_enable && (!(weight_non_uniform_quantization || ifmap_non_uniform_quantization))) || ((!outlier_enable) && (weight_non_uniform_quantization || ifmap_non_uniform_quantization)))))) begin
              weight_k_groups <= (gemm_k_groups_wire + 1);
              psum_k_groups   <= (gemm_k_groups_wire + 1) << 1;
            end
            else begin
              weight_k_groups <= (gemm_k_groups_wire + 1) << 1;
              psum_k_groups   <= (gemm_k_groups_wire + 1) << 1;
            end
            weight_number   <= (gemm_n_groups_wire + 1) * ((gemm_k_groups_wire + 1)) * 32 - 1;
          end
        end
        else if ((type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_BF16) ||
                 (type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_FP16) ||
                 (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT8 && (!outlier_enable))) begin
          weight_2_ifmap_2 <= 1'b1;
          if (insn_kind_wire == CONV_EXECUTE_INSN) begin
            weight_ic_group <= (conv_ic_group_wire + 1) >> 1;
            psum_ic_group   <= conv_ic_group_wire + 1;
            weight_number   <= (conv_weight_height_wire + 1) * (conv_weight_width_wire + 1) * (conv_oc_group_wire + 1) * ((conv_ic_group_wire + 1)) * 32 - 1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            weight_k_groups <= (gemm_k_groups_wire + 1) >> 1;
            psum_k_groups   <= gemm_k_groups_wire + 1;
            weight_number   <= (gemm_n_groups_wire + 1) * ((gemm_k_groups_wire + 1)) * 32 - 1;
          end
        end
        else if (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT8 && outlier_enable) begin
          weight_2_ifmap_4 <= 1'b1;
          if (insn_kind_wire == CONV_EXECUTE_INSN) begin
            weight_ic_group <= (conv_ic_group_wire + 1) >> 1;
            psum_ic_group   <= (conv_ic_group_wire + 1) << 1;
            weight_number   <= (conv_weight_height_wire + 1) * (conv_weight_width_wire + 1) * (conv_oc_group_wire + 1) * ((conv_ic_group_wire + 1)) * 32 - 1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            weight_k_groups <= (gemm_k_groups_wire + 1) >> 1;
            psum_k_groups   <= (gemm_k_groups_wire + 1) << 1;
            weight_number   <= (gemm_n_groups_wire + 1) * ((gemm_k_groups_wire + 1)) * 32 - 1;
          end
        end
        else if ((type_a_wire == TYPE_IS_BF16 && type_b_wire == TYPE_IS_INT4) ||
                 (type_a_wire == TYPE_IS_FP16 && type_b_wire == TYPE_IS_INT4) ||
                 (type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT4 && outlier_enable) ||
                 (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && ((weight_non_uniform_quantization && outlier_enable) || (ifmap_non_uniform_quantization && outlier_enable)))) begin
          weight_1_ifmap_4 <= 1'b1;
          if (insn_kind_wire == CONV_EXECUTE_INSN) begin
            if ((type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT4 && outlier_enable)) begin
              weight_ic_group <= (conv_ic_group_wire + 1) << 1;
            end
            else if ((type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && ((weight_non_uniform_quantization && outlier_enable) || (ifmap_non_uniform_quantization && outlier_enable)))) begin
              weight_ic_group <= (conv_ic_group_wire + 1);
            end
            else begin
              weight_ic_group <= (conv_ic_group_wire + 1) << 2;
            end
            psum_ic_group   <= (conv_ic_group_wire + 1) << 2;
            weight_number   <= (conv_weight_height_wire + 1) * (conv_weight_width_wire + 1) * (conv_oc_group_wire + 1) * ((conv_ic_group_wire + 1)) * 32 - 1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            if ((type_a_wire == TYPE_IS_INT8 && type_b_wire == TYPE_IS_INT4 && outlier_enable)) begin
              weight_k_groups <= (gemm_k_groups_wire + 1) << 1;
            end
            else if ((type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT4 && ((weight_non_uniform_quantization && outlier_enable) || (ifmap_non_uniform_quantization && outlier_enable)))) begin
              weight_k_groups <= gemm_k_groups_wire + 1;
            end
            else begin
              weight_k_groups <= (gemm_k_groups_wire + 1) << 2;
            end
            psum_k_groups   <= (gemm_k_groups_wire + 1) << 2;
            weight_number   <= (gemm_n_groups_wire + 1) * ((gemm_k_groups_wire + 1)) * 32 - 1;
          end
        end
        else if ((type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_BF16) ||
                 (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_FP16)) begin
          weight_4_ifmap_4 <= 1'b1;
          if (insn_kind_wire == CONV_EXECUTE_INSN) begin
            weight_ic_group <= (conv_ic_group_wire + 1) >> 2;
            psum_ic_group   <= conv_ic_group_wire + 1;
            weight_number   <= (conv_weight_height_wire + 1) * (conv_weight_width_wire + 1) * (conv_oc_group_wire + 1) * ((conv_ic_group_wire + 1)) * 32 - 1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            weight_k_groups <= (gemm_k_groups_wire + 1);
            psum_k_groups   <= gemm_k_groups_wire + 1;
            weight_number   <= (gemm_n_groups_wire + 1) * ((gemm_k_groups_wire + 1)) * 32 - 1;
          end
        end
        else if (type_a_wire == TYPE_IS_INT4 && type_b_wire == TYPE_IS_INT8 && outlier_enable) begin
          weight_2_ifmap_2 <= 1'b1;
          if (insn_kind_wire == CONV_EXECUTE_INSN) begin
            weight_ic_group <= conv_ic_group_wire + 1;
            psum_ic_group   <= (conv_ic_group_wire + 1) << 2;
            weight_number   <= (conv_weight_height_wire + 1) * (conv_weight_width_wire + 1) * (conv_oc_group_wire + 1) * ((conv_ic_group_wire + 1)) * 32 - 1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            weight_k_groups <= gemm_k_groups_wire + 1;
            psum_k_groups   <= (gemm_k_groups_wire + 1) << 2;
            weight_number   <= (gemm_n_groups_wire + 1) * ((gemm_k_groups_wire + 1)) * 32 - 1;
          end
        end
        else begin
          if (insn_kind_wire == CONV_EXECUTE_INSN) begin
            weight_ic_group <= conv_ic_group_wire + 1;
            psum_ic_group <= conv_ic_group_wire + 1;
            weight_number    <= (conv_weight_height_wire + 1) * (conv_weight_width_wire + 1) * (conv_oc_group_wire + 1) * (conv_ic_group_wire + 1) * 32 - 1;
          end
          else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
            weight_k_groups <= gemm_k_groups_wire + 1;
            psum_k_groups <= gemm_k_groups_wire + 1;
            weight_number    <= (gemm_n_groups_wire + 1) * (gemm_k_groups_wire + 1) * 32 - 1;
          end
        end

        if (insn_kind_wire == CONV_EXECUTE_INSN) begin
          ifmap_width      <= conv_ifmap_width_wire + 1;
          ifmap_height     <= conv_ifmap_height_wire + 1;
          weight_width     <= conv_weight_width_wire + 1;
          weight_height    <= conv_weight_height_wire + 1;
          psum_width       <= conv_psum_width_wire + 1;
          psum_height      <= conv_psum_height_wire + 1;
          oc_group         <= conv_oc_group_wire + 1;
          ifmap_highaddr   <= conv_ifmap_highaddr_wire;
          weight_highaddr  <= conv_weight_highaddr_wire;
          psum_highaddr    <= conv_psum_highaddr_wire;
          pad_left         <= conv_pad_left_wire;
          pad_top          <= conv_pad_top_wire;
          psum_number      <= conv_psum_number_wire;
          psum_accumulated <= conv_psum_accumulated_wire;
          ifmap_area       <= (conv_ifmap_height_wire + 1) * (conv_ifmap_width_wire + 1);
          weight_area      <= (conv_weight_height_wire + 1) * (conv_weight_width_wire + 1);
          psum_area        <= (conv_psum_height_wire + 1) * (conv_psum_width_wire + 1);
        end
        else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
          tile_m           <= gemm_tile_m_wire + 1;
          n_groups         <= gemm_n_groups_wire + 1;
          ifmap_highaddr   <= gemm_ifmap_highaddr_wire;
          weight_highaddr  <= gemm_weight_highaddr_wire;
          psum_highaddr    <= gemm_psum_highaddr_wire;
          psum_number      <= gemm_psum_number_wire;
          psum_accumulated <= gemm_psum_accumulated_wire;
        end
      end
    end
    else begin
      if (fake_done) begin
        execute_start    <= 0;
        insn_opcode      <= 0;
        insn_kind        <= 0;
        type_a           <= 0;
        type_b           <= 0;
        type_accumulator <= 0;
        type_output      <= 0;
        ifmap_width      <= 0;
        ifmap_height     <= 0;
        weight_width     <= 0;
        weight_height    <= 0;
        weight_number    <= 0;
        psum_width       <= 0;
        psum_height      <= 0;
        psum_ic_group    <= 0;
        weight_ic_group  <= 0;
        oc_group         <= 0;
        pad_left         <= 0;
        pad_top          <= 0;
        psum_number      <= 0;
        psum_accumulated <= 0;
        ifmap_highaddr   <= 0;
        weight_highaddr  <= 0;
        psum_highaddr    <= 0;
        ifmap_area       <= 0;
        weight_area      <= 0;
        psum_area        <= 0;
        tile_m           <= 0;
        n_groups         <= 0;
        weight_k_groups  <= 0;
        psum_k_groups    <= 0;
        weight_1_ifmap_2 <= 0;
        weight_1_ifmap_4 <= 0;
        weight_2_ifmap_2 <= 0;
        weight_2_ifmap_4 <= 0;
        weight_4_ifmap_4 <= 0;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                       Mixed Precision Read Control                                       */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_1_ifmap_2_identifier         <= 1'b0;
    weight_1_ifmap_2_identifier_delay_1 <= 1'b0;
    weight_1_ifmap_2_identifier_delay_2 <= 1'b0;
    weight_1_ifmap_2_identifier_delay_3 <= 1'b0;
    weight_1_ifmap_2_identifier_delay_4 <= 1'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      weight_1_ifmap_2_identifier_delay_4 <= weight_1_ifmap_2_identifier_delay_3;
      weight_1_ifmap_2_identifier_delay_3 <= weight_1_ifmap_2_identifier_delay_2;
      weight_1_ifmap_2_identifier_delay_2 <= weight_1_ifmap_2_identifier_delay_1;
      weight_1_ifmap_2_identifier_delay_1 <= weight_1_ifmap_2_identifier;

      if (weight_1_ifmap_2) begin
        if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && (!weight_1_ifmap_2_identifier)) begin
          weight_1_ifmap_2_identifier <= 1'b1;
        end
        else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_2_identifier) begin
          weight_1_ifmap_2_identifier <= 1'b0;
        end
        else begin
          weight_1_ifmap_2_identifier <= weight_1_ifmap_2_identifier;
        end
      end
    end
    else if (fake_done) begin
      weight_1_ifmap_2_identifier         <= 1'b0;
      weight_1_ifmap_2_identifier_delay_1 <= 1'b0;
      weight_1_ifmap_2_identifier_delay_2 <= 1'b0;
      weight_1_ifmap_2_identifier_delay_3 <= 1'b0;
      weight_1_ifmap_2_identifier_delay_4 <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_1_ifmap_4_identifier         <= 2'b0;
    weight_1_ifmap_4_identifier_delay_1 <= 2'b0;
    weight_1_ifmap_4_identifier_delay_2 <= 2'b0;
    weight_1_ifmap_4_identifier_delay_3 <= 2'b0;
    weight_1_ifmap_4_identifier_delay_4 <= 2'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      weight_1_ifmap_4_identifier_delay_4 <= weight_1_ifmap_4_identifier_delay_3;
      weight_1_ifmap_4_identifier_delay_3 <= weight_1_ifmap_4_identifier_delay_2;
      weight_1_ifmap_4_identifier_delay_2 <= weight_1_ifmap_4_identifier_delay_1;
      weight_1_ifmap_4_identifier_delay_1 <= weight_1_ifmap_4_identifier;

      if (weight_1_ifmap_4) begin
        if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b00) begin
          weight_1_ifmap_4_identifier <= 2'b01;
        end
        else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b01) begin
          weight_1_ifmap_4_identifier <= 2'b10;
        end
        else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b10) begin
          weight_1_ifmap_4_identifier <= 2'b11;
        end
        else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b11) begin
          weight_1_ifmap_4_identifier <= 2'b00;
        end
        else begin
          weight_1_ifmap_4_identifier <= weight_1_ifmap_4_identifier;
        end
      end
    end
    else if (fake_done) begin
      weight_1_ifmap_4_identifier         <= 2'b0;
      weight_1_ifmap_4_identifier_delay_1 <= 2'b0;
      weight_1_ifmap_4_identifier_delay_2 <= 2'b0;
      weight_1_ifmap_4_identifier_delay_3 <= 2'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_2_ifmap_2_identifier         <= 1'b0;
    weight_2_ifmap_2_identifier_delay_1 <= 1'b0;
    weight_2_ifmap_2_identifier_delay_2 <= 1'b0;
    weight_2_ifmap_2_identifier_delay_3 <= 1'b0;
    weight_2_ifmap_2_identifier_delay_4 <= 1'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      weight_2_ifmap_2_identifier_delay_4 <= weight_2_ifmap_2_identifier_delay_3;
      weight_2_ifmap_2_identifier_delay_3 <= weight_2_ifmap_2_identifier_delay_2;
      weight_2_ifmap_2_identifier_delay_2 <= weight_2_ifmap_2_identifier_delay_1;
      weight_2_ifmap_2_identifier_delay_1 <= weight_2_ifmap_2_identifier;

      if (weight_2_ifmap_2) begin
        if (((psum_width_read_done && psum_height_read_done && weight_width_read_done && weight_height_read_done) || psum_m_tile_read_done) && (!weight_2_ifmap_2_identifier)) begin
          weight_2_ifmap_2_identifier <= 1'b1;
        end
        else if (((psum_width_read_done && psum_height_read_done && weight_width_read_done && weight_height_read_done) || psum_m_tile_read_done) && weight_2_ifmap_2_identifier) begin
          weight_2_ifmap_2_identifier <= 1'b0;
        end
        else begin
          weight_2_ifmap_2_identifier <= weight_2_ifmap_2_identifier;
        end
      end
    end
    else if (fake_done) begin
      weight_2_ifmap_2_identifier         <= 1'b0;
      weight_2_ifmap_2_identifier_delay_1 <= 1'b0;
      weight_2_ifmap_2_identifier_delay_2 <= 1'b0;
      weight_2_ifmap_2_identifier_delay_3 <= 1'b0;
      weight_2_ifmap_2_identifier_delay_4 <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_2_ifmap_4_identifier         <= 1'b0;
    weight_2_ifmap_4_identifier_delay_1 <= 1'b0;
    weight_2_ifmap_4_identifier_delay_2 <= 1'b0;
    weight_2_ifmap_4_identifier_delay_3 <= 1'b0;
    weight_2_ifmap_4_identifier_delay_4 <= 1'b0;
    weight_2_ifmap_4_cross_ic           <= 1'b0;
    weight_2_ifmap_4_cross_ic_delay_1   <= 1'b0;
    weight_2_ifmap_4_cross_ic_delay_2   <= 1'b0;
    weight_2_ifmap_4_cross_ic_delay_3   <= 1'b0;
    weight_2_ifmap_4_cross_ic_delay_4   <= 1'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      weight_2_ifmap_4_identifier_delay_4 <= weight_2_ifmap_4_identifier_delay_3;
      weight_2_ifmap_4_identifier_delay_3 <= weight_2_ifmap_4_identifier_delay_2;
      weight_2_ifmap_4_identifier_delay_2 <= weight_2_ifmap_4_identifier_delay_1;
      weight_2_ifmap_4_identifier_delay_1 <= weight_2_ifmap_4_identifier;

      if (weight_2_ifmap_4) begin
        if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && (!weight_2_ifmap_4_identifier)) begin
          weight_2_ifmap_4_identifier <= 1'b1;
        end
        else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_2_ifmap_4_identifier == 1'b1) begin
          weight_2_ifmap_4_identifier <= 1'b0;
        end
        else begin
          weight_2_ifmap_4_identifier <= weight_2_ifmap_4_identifier;
        end

        weight_2_ifmap_4_cross_ic_delay_4 <= weight_2_ifmap_4_cross_ic_delay_3;
        weight_2_ifmap_4_cross_ic_delay_3 <= weight_2_ifmap_4_cross_ic_delay_2;
        weight_2_ifmap_4_cross_ic_delay_2 <= weight_2_ifmap_4_cross_ic_delay_1;
        weight_2_ifmap_4_cross_ic_delay_1 <= weight_2_ifmap_4_cross_ic;

        if (((psum_width_read_done && psum_height_read_done && weight_width_read_done && weight_height_read_done) || psum_m_tile_read_done) && (!weight_2_ifmap_4_cross_ic) && weight_2_ifmap_4_identifier) begin
          weight_2_ifmap_4_cross_ic <= 1'b1;
        end
        else if (((psum_width_read_done && psum_height_read_done && weight_width_read_done && weight_height_read_done) || psum_m_tile_read_done) && weight_2_ifmap_4_cross_ic && weight_2_ifmap_4_identifier) begin
          weight_2_ifmap_4_cross_ic <= 1'b0;
        end
        else begin
          weight_2_ifmap_4_cross_ic <= weight_2_ifmap_4_cross_ic;
        end
      end
    end
    else if (fake_done) begin
      weight_2_ifmap_4_identifier         <= 1'b0;
      weight_2_ifmap_4_identifier_delay_1 <= 1'b0;
      weight_2_ifmap_4_identifier_delay_2 <= 1'b0;
      weight_2_ifmap_4_identifier_delay_3 <= 1'b0;
      weight_2_ifmap_4_identifier_delay_4 <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_4_ifmap_4_identifier         <= 2'b0;
    weight_4_ifmap_4_identifier_delay_1 <= 2'b0;
    weight_4_ifmap_4_identifier_delay_2 <= 2'b0;
    weight_4_ifmap_4_identifier_delay_3 <= 2'b0;
    weight_4_ifmap_4_identifier_delay_4 <= 2'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      weight_4_ifmap_4_identifier_delay_4 <= weight_4_ifmap_4_identifier_delay_3;
      weight_4_ifmap_4_identifier_delay_3 <= weight_4_ifmap_4_identifier_delay_2;
      weight_4_ifmap_4_identifier_delay_2 <= weight_4_ifmap_4_identifier_delay_1;
      weight_4_ifmap_4_identifier_delay_1 <= weight_4_ifmap_4_identifier;

      if (weight_4_ifmap_4) begin
        if (((psum_width_read_done && psum_height_read_done && weight_width_read_done && weight_height_read_done) || psum_m_tile_read_done) && weight_4_ifmap_4_identifier == 2'b00) begin
          weight_4_ifmap_4_identifier <= 2'b01;
        end
        else if (((psum_width_read_done && psum_height_read_done && weight_width_read_done && weight_height_read_done) || psum_m_tile_read_done) && weight_4_ifmap_4_identifier == 2'b01) begin
          weight_4_ifmap_4_identifier <= 2'b10;
        end
        else if (((psum_width_read_done && psum_height_read_done && weight_width_read_done && weight_height_read_done) || psum_m_tile_read_done) && weight_4_ifmap_4_identifier == 2'b10) begin
          weight_4_ifmap_4_identifier <= 2'b11;
        end
        else if (((psum_width_read_done && psum_height_read_done && weight_width_read_done && weight_height_read_done) || psum_m_tile_read_done) && weight_4_ifmap_4_identifier == 2'b11) begin
          weight_4_ifmap_4_identifier <= 2'b00;
        end
        else begin
          weight_4_ifmap_4_identifier <= weight_4_ifmap_4_identifier;
        end
      end
    end
    else if (fake_done) begin
      weight_4_ifmap_4_identifier         <= 2'b0;
      weight_4_ifmap_4_identifier_delay_1 <= 2'b0;
      weight_4_ifmap_4_identifier_delay_2 <= 2'b0;
      weight_4_ifmap_4_identifier_delay_3 <= 2'b0;
      weight_4_ifmap_4_identifier_delay_4 <= 2'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    multiple_read_trigger <= 1'b1;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && psum_sram_wvalid) begin
        multiple_read_trigger <= 1'b1;
      end
      else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg)) begin
        multiple_read_trigger <= 1'b0;
      end
      else if (psum_sram_wvalid) begin
        multiple_read_trigger <= 1'b1;
      end
      else begin
        multiple_read_trigger <= multiple_read_trigger;
      end
    end
    else if (fake_done) begin
      multiple_read_trigger <= 1'b1;
    end
    else begin
      multiple_read_trigger <= multiple_read_trigger;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    outlier_second_pass               <= 1'b0;
    outlier_second_pass_delay_delay_1 <= 1'b0;
    outlier_second_pass_delay_delay_2 <= 1'b0;
    outlier_second_pass_delay_delay_3 <= 1'b0;
    outlier_second_pass_delay_delay_4 <= 1'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      outlier_second_pass_delay_delay_1 <= outlier_second_pass;
      outlier_second_pass_delay_delay_2 <= outlier_second_pass_delay_delay_1;
      outlier_second_pass_delay_delay_3 <= outlier_second_pass_delay_delay_2;
      outlier_second_pass_delay_delay_4 <= outlier_second_pass_delay_delay_3;

      if (weight_1_ifmap_2 && outlier_enable) begin
        if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && (!outlier_second_pass)) begin
          outlier_second_pass <= 1'b1;
        end
        else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && outlier_second_pass) begin
          outlier_second_pass <= 1'b0;
        end
        else begin
          outlier_second_pass <= outlier_second_pass;
        end
      end
      else if (weight_1_ifmap_4 && outlier_enable) begin
        if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET_PER_TWO) begin
          if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b00) begin
            outlier_second_pass <= 1'b1;
          end
          else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b01) begin
            outlier_second_pass <= 1'b0;
          end
          else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b10) begin
            outlier_second_pass <= 1'b1;
          end
          else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b11) begin
            outlier_second_pass <= 1'b0;
          end
          else begin
            outlier_second_pass <= outlier_second_pass;
          end
        end
        else begin
          if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b00) begin
            outlier_second_pass <= 1'b0;
          end
          else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b01) begin
            outlier_second_pass <= 1'b1;
          end
          else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b10) begin
            outlier_second_pass <= 1'b1;
          end
          else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_1_ifmap_4_identifier == 2'b11) begin
            outlier_second_pass <= 1'b0;
          end
          else begin
            outlier_second_pass <= outlier_second_pass;
          end
        end
      end
      else if (weight_2_ifmap_4 && outlier_enable) begin
        if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && (!weight_2_ifmap_4_identifier)) begin
          outlier_second_pass <= 1'b1;
        end
        else if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg) && weight_2_ifmap_4_identifier) begin
          outlier_second_pass <= 1'b0;
        end
        else begin
          outlier_second_pass <= outlier_second_pass;
        end
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        Weight SRAM Read Controller                                       */
/* -------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------- Weight SRAM Read Enable --------------------------------------- */

assign weight_width_read_done    = (weight_width_read_cnt == (weight_width - 1)) & execute_start;
assign weight_height_read_done   = (weight_height_read_cnt == (weight_height - 1)) & execute_start;
assign weight_ic_group_read_done = (weight_ic_group_read_cnt == (weight_ic_group - 1)) & execute_start;
assign weight_oc_group_read_done = (weight_oc_group_read_cnt == (oc_group - 1)) & execute_start;

assign weight_n_group_read_done  = (weight_n_group_read_cnt == (n_groups - 1)) & execute_start;
assign weight_k_group_read_done  = (weight_k_group_read_cnt == (weight_k_groups - 1)) & execute_start;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_rvalid_reg <= 1'b0;
  end
  else begin
    if (execute_start && !fake_done) begin
      if (weight_sram_raddr_reg[8:0] == weight_number) begin
        weight_sram_rvalid_reg <= 1'b0;
      end
      else begin
        if (weight_sram_ping_valid && weight_sram_pang_valid) begin
          weight_sram_rvalid_reg <= 1'b0;
        end
        else begin
          if ((weight_sram_ping_loading_cnt == LANE - 1) || (weight_sram_pang_loading_cnt == LANE - 1)) begin
            weight_sram_rvalid_reg <= 1'b0;
          end
          else begin
            weight_sram_rvalid_reg <= 1'b1;
          end
        end
      end
    end
    else begin
      if (fake_done) begin
        weight_sram_rvalid_reg <= 1'b0;
      end
      else begin
        weight_sram_rvalid_reg <= weight_sram_rvalid_reg;
      end
    end
  end
end

/* --------------------------------------- Weight SRAM Read Address --------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_raddr_reg <= 0;
  end
  else begin
    if ((insn_valid_reg && (!(execute_start && !fake_done)))) begin
      weight_sram_raddr_reg <= 'd0;
    end
    else if (execute_start && !fake_done) begin
      if (weight_sram_raddr_reg[10:0] == weight_number) begin
        weight_sram_raddr_reg <= weight_sram_raddr_reg;
      end
      else if (weight_sram_rvalid) begin
        weight_sram_raddr_reg <= weight_sram_raddr_reg + 1;
      end
      else begin
        weight_sram_raddr_reg <= weight_sram_raddr_reg;
      end
    end
    else begin
      weight_sram_raddr_reg <= weight_sram_raddr_reg;
    end
  end
end

/* --------------------------------------- Weight SRAM Read Counter --------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_width_read_cnt    <= 0;
    weight_height_read_cnt   <= 0;
    weight_ic_group_read_cnt <= 0;
    weight_oc_group_read_cnt <= 0;
    weight_n_group_read_cnt  <= 0;
    weight_k_group_read_cnt  <= 0;
  end
  else begin
    if (execute_start && !fake_done) begin
      if (insn_kind_wire == CONV_EXECUTE_INSN) begin
        if ((psum_height_read_done && psum_width_read_done) &&
            ((weight_1_ifmap_2 && weight_1_ifmap_2_identifier) || (!weight_1_ifmap_2)) &&
            ((weight_1_ifmap_4 && (&weight_1_ifmap_4_identifier)) || (!weight_1_ifmap_4)) &&
            ((weight_2_ifmap_4 && weight_2_ifmap_4_identifier) || (!weight_2_ifmap_4))) begin
          if (weight_width_read_done) begin
            weight_width_read_cnt <= 'd0;
          end
          else begin
            weight_width_read_cnt <= weight_width_read_cnt + 1;
          end
        end
        else begin
          weight_width_read_cnt <= weight_width_read_cnt;
        end

        if ((psum_height_read_done && psum_width_read_done && weight_width_read_done) &&
            ((weight_1_ifmap_2 && weight_1_ifmap_2_identifier) || (!weight_1_ifmap_2)) &&
            ((weight_1_ifmap_4 && (&weight_1_ifmap_4_identifier)) || (!weight_1_ifmap_4)) &&
            ((weight_2_ifmap_4 && weight_2_ifmap_4_identifier) || (!weight_2_ifmap_4))) begin
          if (weight_height_read_done) begin
            weight_height_read_cnt <= 'd0;
          end
          else begin
            weight_height_read_cnt <= weight_height_read_cnt + 1;
          end
        end
        else begin
          weight_height_read_cnt <= weight_height_read_cnt;
        end

        if (((weight_height_read_done && weight_width_read_done) || weight_1_ifmap_2 || weight_1_ifmap_4) && (psum_width_read_done && psum_height_read_done)) begin
          if (weight_1_ifmap_2) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_ic_group_read_done) begin
                weight_ic_group_read_cnt <= 'd0;
              end
              else begin
                weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if (weight_1_ifmap_2_identifier && weight_height_read_done && weight_width_read_done) begin
                if (weight_ic_group_read_done) begin
                  weight_ic_group_read_cnt <= 'd0;
                end
                else begin
                  weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
                end
              end
            end
          end
          else if (weight_1_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_ic_group_read_done) begin
                weight_ic_group_read_cnt <= 'd0;
              end
              else begin
                weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET_PER_TWO) begin
              if (weight_1_ifmap_4_identifier == 1) begin
                if (weight_ic_group_read_done) begin
                  weight_ic_group_read_cnt <= 'd0;
                end
                else begin
                  weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
                end
              end
              else if (weight_1_ifmap_4_identifier == 3 && weight_height_read_done && weight_width_read_done) begin
                if (weight_ic_group_read_done) begin
                  weight_ic_group_read_cnt <= 'd0;
                end
                else begin
                  weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
                end
              end
              else if (weight_1_ifmap_4_identifier == 3) begin
                weight_ic_group_read_cnt <= weight_ic_group_read_cnt - 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_1_ifmap_4_identifier) && weight_height_read_done && weight_width_read_done) begin
                if (weight_ic_group_read_done) begin
                  weight_ic_group_read_cnt <= 'd0;
                end
                else begin
                  weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
                end
              end
            end
            else begin
              if (weight_ic_group_read_done) begin
                weight_ic_group_read_cnt <= 'd0;
              end
              else begin
                weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
              end
            end
          end
          else if (weight_2_ifmap_2) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_ic_group_read_done) begin
                weight_ic_group_read_cnt <= 'd0;
              end
              else begin
                weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if (weight_2_ifmap_2_identifier && weight_height_read_done && weight_width_read_done) begin
                if (weight_ic_group_read_done) begin
                  weight_ic_group_read_cnt <= 'd0;
                end
                else begin
                  weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
                end
              end
            end
          end
          else if (weight_2_ifmap_4) begin
            if (weight_2_ifmap_4_cross_ic && weight_2_ifmap_4_identifier) begin
              if (weight_ic_group_read_done) begin
                weight_ic_group_read_cnt <= 'd0;
              end
              else begin
                weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
              end
            end
          end
          else if (weight_4_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_4_ifmap_4_identifier) && weight_height_read_done && weight_width_read_done) begin
                if (weight_ic_group_read_done) begin
                  weight_ic_group_read_cnt <= 'd0;
                end
                else begin
                  weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
                end
              end
            end
            else begin
              if (weight_ic_group_read_done) begin
                weight_ic_group_read_cnt <= 'd0;
              end
              else begin
                weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
              end
            end
          end
          else begin
            if (weight_ic_group_read_done) begin
              weight_ic_group_read_cnt <= 'd0;
            end
            else begin
              weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1'b1;
            end
          end
        end
        else begin
          weight_ic_group_read_cnt <= weight_ic_group_read_cnt;
        end

        if (((weight_ic_group_read_done && weight_height_read_done && weight_width_read_done) || weight_1_ifmap_2 || weight_1_ifmap_4) && (psum_width_read_done) && psum_height_read_done) begin
          if (weight_1_ifmap_2) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_1_ifmap_2_identifier && (weight_ic_group_read_done && weight_height_read_done && weight_width_read_done)) begin
                if (weight_oc_group_read_done) begin
                  weight_oc_group_read_cnt <= 'd0;
                end
                else begin
                  weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
                end
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if (weight_1_ifmap_2_identifier && (weight_ic_group_read_done && weight_height_read_done && weight_width_read_done)) begin
                if (weight_oc_group_read_done) begin
                  weight_oc_group_read_cnt <= 'd0;
                end
                else begin
                  weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
                end
              end
            end
          end
          else if (weight_1_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if ((&weight_1_ifmap_4_identifier) && (weight_ic_group_read_done && weight_height_read_done && weight_width_read_done)) begin
                if (weight_oc_group_read_done) begin
                  weight_oc_group_read_cnt <= 'd0;
                end
                else begin
                  weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
                end
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET_PER_TWO) begin
              if (weight_1_ifmap_4_identifier == 3 && (weight_ic_group_read_done && weight_height_read_done && weight_width_read_done)) begin
                if (weight_oc_group_read_done) begin
                  weight_oc_group_read_cnt <= 'd0;
                end
                else begin
                  weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
                end
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_1_ifmap_4_identifier) && (weight_ic_group_read_done && weight_height_read_done && weight_width_read_done)) begin
                if (weight_oc_group_read_done) begin
                  weight_oc_group_read_cnt <= 'd0;
                end
                else begin
                  weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
                end
              end
            end
            else begin
              if (weight_oc_group_read_done) begin
                weight_oc_group_read_cnt <= 'd0;
              end
              else begin
                weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
              end
            end
          end
          else if (weight_2_ifmap_2) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_oc_group_read_done) begin
                weight_oc_group_read_cnt <= 'd0;
              end
              else begin
                weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if (weight_2_ifmap_2_identifier && (weight_ic_group_read_done && weight_height_read_done && weight_width_read_done)) begin
                if (weight_oc_group_read_done) begin
                  weight_oc_group_read_cnt <= 'd0;
                end
                else begin
                  weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
                end
              end
            end
          end
          else if (weight_2_ifmap_4) begin
            if (weight_2_ifmap_4_cross_ic && weight_2_ifmap_4_identifier) begin
              if (weight_oc_group_read_done) begin
                weight_oc_group_read_cnt <= 'd0;
              end
              else begin
                weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
              end
            end
          end
          else if (weight_4_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_4_ifmap_4_identifier) && (weight_ic_group_read_done && weight_height_read_done && weight_width_read_done)) begin
                if (weight_oc_group_read_done) begin
                  weight_oc_group_read_cnt <= 'd0;
                end
                else begin
                  weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
                end
              end
            end
            else begin
              if (weight_oc_group_read_done) begin
                weight_oc_group_read_cnt <= 'd0;
              end
              else begin
                weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
              end
            end
          end
          else begin
            if (weight_oc_group_read_done) begin
              weight_oc_group_read_cnt <= 'd0;
            end
            else begin
              weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1'b1;
            end
          end
        end
        else begin
          weight_oc_group_read_cnt <= weight_oc_group_read_cnt;
        end

        weight_n_group_read_cnt <= 'd0;
        weight_k_group_read_cnt <= 'd0;
      end
      else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin

        if (psum_m_tile_read_done) begin
          if (weight_1_ifmap_2) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_k_group_read_done) begin
                weight_k_group_read_cnt <= 'd0;
              end
              else begin
                weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if (weight_1_ifmap_2_identifier) begin
                if (weight_k_group_read_done) begin
                  weight_k_group_read_cnt <= 'd0;
                end
                else begin
                  weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
                end
              end
            end
          end
          else if (weight_1_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_k_group_read_done) begin
                weight_k_group_read_cnt <= 'd0;
              end
              else begin
                weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET_PER_TWO) begin
              if (weight_1_ifmap_4_identifier == 1) begin
                if (weight_k_group_read_done) begin
                  weight_k_group_read_cnt <= 'd0;
                end
                else begin
                  weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
                end
              end
              else if (weight_1_ifmap_4_identifier == 3) begin
                if (weight_k_group_read_done) begin
                  weight_k_group_read_cnt <= 'd0;
                end
                else begin
                  weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
                end
              end
              else if (weight_1_ifmap_4_identifier == 3) begin
                weight_k_group_read_cnt <= weight_k_group_read_cnt - 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_1_ifmap_4_identifier)) begin
                if (weight_k_group_read_done) begin
                  weight_k_group_read_cnt <= 'd0;
                end
                else begin
                  weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
                end
              end
            end
            else begin
              if (weight_k_group_read_done) begin
                weight_k_group_read_cnt <= 'd0;
              end
              else begin
                weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
              end
            end
          end
          else if (weight_2_ifmap_2) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_k_group_read_done) begin
                weight_k_group_read_cnt <= 'd0;
              end
              else begin
                weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if (weight_2_ifmap_2_identifier) begin
                if (weight_k_group_read_done) begin
                  weight_k_group_read_cnt <= 'd0;
                end
                else begin
                  weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
                end
              end
            end
          end
          else if (weight_2_ifmap_4) begin
            if (weight_2_ifmap_4_cross_ic && weight_2_ifmap_4_identifier) begin
              if (weight_k_group_read_done) begin
                weight_k_group_read_cnt <= 'd0;
              end
              else begin
                weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
              end
            end
          end
          else if (weight_4_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_4_ifmap_4_identifier)) begin
                if (weight_k_group_read_done) begin
                  weight_k_group_read_cnt <= 'd0;
                end
                else begin
                  weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
                end
              end
            end
            else begin
              if (weight_k_group_read_done) begin
                weight_k_group_read_cnt <= 'd0;
              end
              else begin
                weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
              end
            end
          end
          else begin
            if (weight_k_group_read_done) begin
              weight_k_group_read_cnt <= 'd0;
            end
            else begin
              weight_k_group_read_cnt <= weight_k_group_read_cnt + 1'b1;
            end
          end
        end
        else begin
          weight_k_group_read_cnt <= weight_k_group_read_cnt;
        end

        if (weight_k_group_read_done && psum_m_tile_read_done) begin
          if (weight_1_ifmap_2) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_1_ifmap_2_identifier && weight_k_group_read_done) begin
                if (weight_n_group_read_done) begin
                  weight_n_group_read_cnt <= 'd0;
                end
                else begin
                  weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
                end
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if (weight_1_ifmap_2_identifier && weight_k_group_read_done) begin
                if (weight_n_group_read_done) begin
                  weight_n_group_read_cnt <= 'd0;
                end
                else begin
                  weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
                end
              end
            end
          end
          else if (weight_1_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if ((&weight_1_ifmap_4_identifier) && weight_k_group_read_done) begin
                if (weight_n_group_read_done) begin
                  weight_n_group_read_cnt <= 'd0;
                end
                else begin
                  weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
                end
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET_PER_TWO) begin
              if (weight_1_ifmap_4_identifier == 3 && weight_k_group_read_done) begin
                if (weight_n_group_read_done) begin
                  weight_n_group_read_cnt <= 'd0;
                end
                else begin
                  weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
                end
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_1_ifmap_4_identifier) && weight_k_group_read_done) begin
                if (weight_n_group_read_done) begin
                  weight_n_group_read_cnt <= 'd0;
                end
                else begin
                  weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
                end
              end
            end
            else begin
              if (weight_n_group_read_done) begin
                weight_n_group_read_cnt <= 'd0;
              end
              else begin
                weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
              end
            end
          end
          else if (weight_2_ifmap_2) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_NO_RESET) begin
              if (weight_n_group_read_done) begin
                weight_n_group_read_cnt <= 'd0;
              end
              else begin
                weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
              end
            end
            else if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if (weight_2_ifmap_2_identifier && weight_k_group_read_done) begin
                if (weight_n_group_read_done) begin
                  weight_n_group_read_cnt <= 'd0;
                end
                else begin
                  weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
                end
              end
            end
          end
          else if (weight_2_ifmap_4) begin
            if (weight_2_ifmap_4_cross_ic && weight_2_ifmap_4_identifier) begin
              if (weight_n_group_read_done) begin
                weight_n_group_read_cnt <= 'd0;
              end
              else begin
                weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
              end
            end
          end
          else if (weight_4_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_4_ifmap_4_identifier) && weight_k_group_read_done) begin
                if (weight_n_group_read_done) begin
                  weight_n_group_read_cnt <= 'd0;
                end
                else begin
                  weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
                end
              end
            end
            else begin
              if (weight_n_group_read_done) begin
                weight_n_group_read_cnt <= 'd0;
              end
              else begin
                weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
              end
            end
          end
          else begin
            if (weight_n_group_read_done) begin
              weight_n_group_read_cnt <= 'd0;
            end
            else begin
              weight_n_group_read_cnt <= weight_n_group_read_cnt + 1'b1;
            end
          end
        end
        else begin
          weight_n_group_read_cnt <= weight_n_group_read_cnt;
        end


        weight_width_read_cnt    <= 'd0;
        weight_height_read_cnt   <= 'd0;
        weight_ic_group_read_cnt <= 'd0;
        weight_oc_group_read_cnt <= 'd0;
      end
      else begin
        weight_width_read_cnt    <= weight_width_read_cnt;
        weight_height_read_cnt   <= weight_height_read_cnt;
        weight_ic_group_read_cnt <= weight_ic_group_read_cnt;
        weight_oc_group_read_cnt <= weight_oc_group_read_cnt;
        weight_n_group_read_cnt  <= weight_n_group_read_cnt;
        weight_k_group_read_cnt  <= weight_k_group_read_cnt;
      end
    end
    else begin
      if (fake_done) begin
        weight_width_read_cnt    <= 0;
        weight_height_read_cnt   <= 0;
        weight_ic_group_read_cnt <= 0;
        weight_oc_group_read_cnt <= 0;
        weight_n_group_read_cnt  <= 0;
        weight_k_group_read_cnt  <= 0;
      end
      else begin
        weight_width_read_cnt    <= weight_width_read_cnt;
        weight_height_read_cnt   <= weight_height_read_cnt;
        weight_ic_group_read_cnt <= weight_ic_group_read_cnt;
        weight_oc_group_read_cnt <= weight_oc_group_read_cnt;
        weight_n_group_read_cnt  <= weight_n_group_read_cnt;
        weight_k_group_read_cnt  <= weight_k_group_read_cnt;
      end
    end
  end
end

/* ----------------------------------- Weight SRAM Ping-Pang Controller ----------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_ping_valid                   <= 1'b0;
    weight_sram_pang_valid                   <= 1'b0;
    weight_sram_ping_pang_identifier         <= 1'b0;
    weight_sram_ping_pang_identifier_delay_1 <= 1'b0;
    weight_sram_ping_pang_identifier_delay_2 <= 1'b0;
    weight_sram_ping_pang_identifier_delay_3 <= 1'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      weight_sram_ping_pang_identifier_delay_3 <= weight_sram_ping_pang_identifier_delay_2;
      weight_sram_ping_pang_identifier_delay_2 <= weight_sram_ping_pang_identifier_delay_1;
      weight_sram_ping_pang_identifier_delay_1 <= weight_sram_ping_pang_identifier;

      if (weight_sram_ping_loading && (weight_sram_ping_loading_cnt == LANE - 1)) begin
        weight_sram_ping_valid <= 1'b1;
      end
      else if (weight_sram_ping_pang_identifier_delay_3) begin
        weight_sram_ping_valid <= weight_sram_ping_valid;
      end
      else begin
        if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg)) begin
          if (weight_1_ifmap_2) begin
            if (weight_1_ifmap_2_identifier) begin
              weight_sram_ping_valid <= 1'b0;
            end
            else begin
              weight_sram_ping_valid <= weight_sram_ping_valid;
            end
          end
          else if (weight_1_ifmap_4) begin
            if (&weight_1_ifmap_4_identifier) begin
              weight_sram_ping_valid <= 1'b0;
            end
            else begin
              weight_sram_ping_valid <= weight_sram_ping_valid;
            end
          end
          else if (weight_2_ifmap_4) begin
            if (weight_2_ifmap_4_identifier) begin
              weight_sram_ping_valid <= 1'b0;
            end
            else begin
              weight_sram_ping_valid <= weight_sram_ping_valid;
            end
          end
          else begin
            weight_sram_ping_valid <= 1'b0;
          end
        end
        else begin
          weight_sram_ping_valid <= weight_sram_ping_valid;
        end
      end

      if (weight_sram_pang_loading && (weight_sram_pang_loading_cnt == LANE - 1)) begin
        weight_sram_pang_valid <= 1'b1;
      end
      else if (weight_sram_ping_pang_identifier_delay_3) begin
        if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg)) begin
          if (weight_1_ifmap_2) begin
            if (weight_1_ifmap_2_identifier)
              weight_sram_pang_valid <= 1'b0;
            else begin
              weight_sram_pang_valid <= weight_sram_pang_valid;
            end
          end
          else if (weight_1_ifmap_4) begin
            if (&weight_1_ifmap_4_identifier) begin
              weight_sram_pang_valid <= 1'b0;
            end
            else begin
              weight_sram_pang_valid <= weight_sram_pang_valid;
            end
          end
          else if (weight_2_ifmap_4) begin
            if (weight_2_ifmap_4_identifier) begin
              weight_sram_pang_valid <= 1'b0;
            end
            else begin
              weight_sram_pang_valid <= weight_sram_pang_valid;
            end
          end
          else begin
            weight_sram_pang_valid <= 1'b0;
          end
        end
        else begin
          weight_sram_pang_valid <= weight_sram_pang_valid;
        end
      end
      else begin
        weight_sram_pang_valid <= weight_sram_pang_valid;
      end

      if (((psum_width_read_done && psum_height_read_done) || psum_m_tile_read_done) && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg)) begin
        if (weight_1_ifmap_2) begin
          if (weight_1_ifmap_2_identifier) begin
            weight_sram_ping_pang_identifier <= ~weight_sram_ping_pang_identifier;
          end
          else begin
            weight_sram_ping_pang_identifier <= weight_sram_ping_pang_identifier;
          end
        end
        else if (weight_1_ifmap_4) begin
          if (&weight_1_ifmap_4_identifier) begin
            weight_sram_ping_pang_identifier <= ~weight_sram_ping_pang_identifier;
          end
          else begin
            weight_sram_ping_pang_identifier <= weight_sram_ping_pang_identifier;
          end
        end
        else if (weight_2_ifmap_4) begin
          if (weight_2_ifmap_4_identifier) begin
            weight_sram_ping_pang_identifier <= ~weight_sram_ping_pang_identifier;
          end
          else begin
            weight_sram_ping_pang_identifier <= weight_sram_ping_pang_identifier;
          end
        end
        else begin 
          weight_sram_ping_pang_identifier <= ~weight_sram_ping_pang_identifier;
        end
      end
      else begin
        weight_sram_ping_pang_identifier <= weight_sram_ping_pang_identifier;
      end
    end
    else begin
      if (fake_done) begin
        weight_sram_ping_valid                   <= 1'b0;
        weight_sram_pang_valid                   <= 1'b0;
        weight_sram_ping_pang_identifier         <= 1'b0;
        weight_sram_ping_pang_identifier_delay_1 <= 1'b0;
        weight_sram_ping_pang_identifier_delay_2 <= 1'b0;
        weight_sram_ping_pang_identifier_delay_3 <= 1'b0;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_ping_loading           <= 1'b0;
    weight_sram_ping_loading_delay     <= 1'b0;
    weight_sram_pang_loading           <= 1'b0;
    weight_sram_pang_loading_delay     <= 1'b0;
    weight_sram_ping_loading_cnt       <= 0;
    weight_sram_ping_loading_cnt_delay <= 0;
    weight_sram_pang_loading_cnt       <= 0;
    weight_sram_pang_loading_cnt_delay <= 0;
    weight_regfile_pang_waddr          <= 'd0;
    weight_regfile_ping_waddr          <= 'd0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      weight_sram_ping_loading_delay     <= weight_sram_ping_loading;
      weight_sram_pang_loading_delay     <= weight_sram_pang_loading;
      weight_sram_ping_loading_cnt_delay <= weight_sram_ping_loading_cnt;
      weight_sram_pang_loading_cnt_delay <= weight_sram_pang_loading_cnt;
      if (weight_sram_raddr_reg[8:0] == weight_number) begin
        weight_sram_ping_loading_cnt <= weight_sram_ping_loading_cnt;
        weight_sram_pang_loading_cnt <= weight_sram_pang_loading_cnt;
        weight_sram_ping_loading     <= 1'b0;
        weight_sram_pang_loading     <= 1'b0;
        weight_regfile_ping_waddr    <= weight_sram_ping_loading_cnt_delay;
        weight_regfile_pang_waddr    <= weight_sram_pang_loading_cnt_delay;
      end
      else begin
        weight_regfile_ping_waddr <= weight_sram_ping_loading_cnt_delay;
        weight_regfile_pang_waddr <= weight_sram_pang_loading_cnt_delay;
        
        if (weight_sram_ping_valid && weight_sram_pang_valid) begin
          weight_sram_ping_loading     <= 1'b0;
          weight_sram_pang_loading     <= 1'b0;
          weight_sram_ping_loading_cnt <= weight_sram_ping_loading_cnt;
          weight_sram_pang_loading_cnt <= weight_sram_pang_loading_cnt;
        end
        else begin
          if (weight_sram_ping_loading || ((!weight_sram_ping_loading) && (!weight_sram_pang_loading) && (!weight_sram_ping_valid))) begin
            if (weight_sram_ping_loading_cnt == LANE - 1) begin
              weight_sram_ping_loading <= 1'b0;
            end
            else begin
              weight_sram_ping_loading <= 1'b1;
            end
            weight_sram_pang_loading <= 1'b0;
          end
          else begin
            if (weight_sram_pang_loading_cnt == LANE - 1) begin
              weight_sram_pang_loading <= 1'b0;
            end
            else begin
              weight_sram_pang_loading <= 1'b1;
            end
          end

          if (weight_sram_ping_loading) begin
            weight_sram_ping_loading_cnt <= weight_sram_ping_loading_cnt + 1;
          end
          else begin
            weight_sram_ping_loading_cnt <= weight_sram_ping_loading_cnt;
          end

          if (weight_sram_pang_loading) begin
            weight_sram_pang_loading_cnt <= weight_sram_pang_loading_cnt + 1;
          end
          else begin
            weight_sram_pang_loading_cnt <= weight_sram_pang_loading_cnt;
          end
        end
      end
    end
    else begin
      if (fake_done) begin
        weight_sram_ping_loading           <= 1'b0;
        weight_sram_ping_loading_delay     <= 1'b0;
        weight_sram_pang_loading           <= 1'b0;
        weight_sram_pang_loading_delay     <= 1'b0;
        weight_sram_ping_loading_cnt       <= 0;
        weight_sram_ping_loading_cnt_delay <= 0;
        weight_sram_pang_loading_cnt       <= 0;
        weight_sram_pang_loading_cnt_delay <= 0;
        weight_regfile_pang_waddr          <= 'd0;
        weight_regfile_ping_waddr          <= 'd0;
      end
    end
  end
end

/* ------------------------------------ Weight Regfile Write Controller ----------------------------------- */

reg weight_sram_rvalid_delay;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_rvalid_delay <= 1'b0;
  end
  else begin
    weight_sram_rvalid_delay <= weight_sram_rvalid_reg;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_regfile_pang_wen <= 'd0;
    weight_regfile_ping_wen <= 'd0;
  end
  else begin
    if (weight_sram_rvalid_delay && weight_sram_ping_loading_delay) begin
      weight_regfile_ping_wen <= 1'b1;
    end
    else begin
      weight_regfile_ping_wen <= 1'b0;
    end

    if (weight_sram_rvalid_delay && weight_sram_pang_loading_delay) begin
      weight_regfile_pang_wen <= 1'b1;
    end
    else begin
      weight_regfile_pang_wen <= 1'b0;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                         Ifmap SRAM Read Contoller                                        */
/* -------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------- Ifmap SRAM Read Address --------------------------------------- */

assign ifmap_horizontal_offset = psum_width_read_cnt * stride_width + weight_width_read_cnt * dilation_width;
assign ifmap_vertical_offset   = psum_height_read_cnt * stride_height + weight_height_read_cnt * dilation_height;
assign ifmap_col_nopad         = ifmap_horizontal_offset - pad_left;
assign ifmap_row_nopad         = ifmap_vertical_offset - pad_top;
assign ifmap_read_zero_wire = insn_kind_wire == CONV_EXECUTE_INSN ? (ifmap_horizontal_offset < pad_left) || (ifmap_col_nopad > ifmap_width - 1) 
                              || (ifmap_vertical_offset < pad_top) || (ifmap_row_nopad > ifmap_height - 1) : 
                              0;
assign ifmap_sram_raddr_wire = insn_kind_wire == CONV_EXECUTE_INSN ? weight_ic_group_read_cnt * ifmap_area + ifmap_row_nopad * ifmap_width + ifmap_col_nopad :
                               weight_k_group_read_cnt * tile_m + psum_m_tile_read_cnt;
assign ifmap_scale_sram_raddr_wire = insn_kind_wire == CONV_EXECUTE_INSN ? ifmap_row_nopad * ifmap_width + ifmap_col_nopad :
                                     psum_m_tile_read_cnt;

/* ---------------------------------------- Ifmap SRAM Read Enable ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_rvalid_reg      <= 1'b0;
    ifmap_read_zero_reg        <= 1'b0;
    ifmap_sram_raddr_reg       <= 0;
    ifmap_scale_sram_raddr_reg <= 0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if (((!weight_sram_ping_pang_identifier && weight_sram_ping_valid) || (weight_sram_ping_pang_identifier && weight_sram_pang_valid)) && multiple_read_trigger && (!psum_read_done)) begin
        ifmap_sram_rvalid_reg      <= 1'b1;
        ifmap_read_zero_reg        <= ifmap_read_zero_wire;
        ifmap_sram_raddr_reg       <= ifmap_sram_raddr_wire;
        ifmap_scale_sram_raddr_reg <= ifmap_scale_sram_raddr_wire;
      end
      else begin
        ifmap_sram_rvalid_reg      <= 1'b0;
        ifmap_sram_raddr_reg       <= ifmap_sram_raddr_reg;
        ifmap_read_zero_reg        <= ifmap_read_zero_reg;
        ifmap_scale_sram_raddr_reg <= ifmap_scale_sram_raddr_reg;
      end
    end
    else begin
      if (fake_done) begin
        ifmap_sram_rvalid_reg      <= 1'b0;
        ifmap_read_zero_reg        <= 1'b0;
        ifmap_sram_raddr_reg       <= 0;
        ifmap_scale_sram_raddr_reg <= 0;
      end
      else begin
        ifmap_sram_rvalid_reg      <= ifmap_sram_rvalid_reg;
        ifmap_read_zero_reg        <= ifmap_read_zero_reg;
        ifmap_sram_raddr_reg       <= ifmap_sram_raddr_reg;
        ifmap_scale_sram_raddr_reg <= ifmap_scale_sram_raddr_reg;
      end
    end
  end
end

/* ----------------------------------------- Ifmap SRAM Read Data ----------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_valid_reg          <= 1'b0;
    ifmap_sram_valid_reg_delay    <= 1'b0;
    ifmap_read_zero_reg_delay     <= 1'b0;
    ifmap_read_zero_reg_delay_1   <= 1'b0;
    ifmap_local_rdata_reg         <= 0;
    ifmap_local_rdata_valid       <= 1'b0;
    ifmap_local_rdata_valid_delay <= 1'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      ifmap_read_zero_reg_delay_1   <= ifmap_read_zero_reg_delay;
      ifmap_local_rdata_valid_delay <= ifmap_local_rdata_valid;
      ifmap_sram_valid_reg_delay    <= ifmap_sram_valid_reg;
      if ((ifmap_sram_rvalid_reg || ifmap_read_zero_reg)) begin
        ifmap_sram_valid_reg      <= 1'b1;
        ifmap_read_zero_reg_delay <= ifmap_read_zero_reg;
      end
      else begin
        ifmap_sram_valid_reg      <= 1'b0;
        ifmap_read_zero_reg_delay <= 1'b0;
      end

      if (ifmap_sram_valid_reg_delay) begin
        ifmap_local_rdata_reg   <= ifmap_read_zero_reg_delay_1 ? 0 : ifmap_sram_rdata;
        ifmap_local_rdata_valid <= ifmap_sram_valid_reg_delay;
      end
      else begin
        ifmap_local_rdata_reg   <= ifmap_local_rdata_reg;
        ifmap_local_rdata_valid <= 1'b0;
      end
    end
    else begin
      if (fake_done) begin
        ifmap_sram_valid_reg          <= 1'b0;
        ifmap_read_zero_reg_delay     <= 1'b0;
        ifmap_read_zero_reg_delay_1   <= 1'b0;
        ifmap_local_rdata_reg         <= 0;
        ifmap_local_rdata_valid       <= 1'b0;
        ifmap_local_rdata_valid_delay <= 1'b0;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                         Psum SRAM Read Controller                                        */
/* -------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------- Psum SRAM Read Address ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_read_done <= 1'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if (insn_kind_wire == CONV_EXECUTE_INSN) begin
        if (psum_width_read_done && psum_height_read_done && weight_ic_group_read_done && weight_oc_group_read_done && weight_height_read_done && weight_width_read_done && (ifmap_sram_rvalid_reg || ifmap_read_zero_reg) && (psum_sram_rvalid_reg || psum_read_zero_reg)) begin
          if (weight_1_ifmap_2) begin
            if (weight_1_ifmap_2_identifier) begin
              psum_read_done <= 1'b1;
            end
            else begin
              psum_read_done <= 1'b0;
            end
          end
          else if (weight_1_ifmap_4) begin
            if (&weight_1_ifmap_4_identifier) begin
              psum_read_done <= 1'b1;
            end
            else begin
              psum_read_done <= 1'b0;
            end
          end
          else if (weight_2_ifmap_2) begin
            if (weight_2_ifmap_2_identifier) begin
              psum_read_done <= 1'b1;
            end
            else begin
              psum_read_done <= 1'b0;
            end
          end
          else if (weight_2_ifmap_4) begin
            if (weight_2_ifmap_4_identifier && weight_2_ifmap_4_cross_ic) begin
              psum_read_done <= 1'b1;
            end
            else begin
              psum_read_done <= 1'b0;
            end
          end
          else if (weight_4_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_4_ifmap_4_identifier) && weight_height_read_done && weight_width_read_done) begin
                if (weight_ic_group_read_done) begin
                  psum_read_done <= 1'b1;
                end
              end
            end
            else begin
              psum_read_done <= psum_read_done;
            end
          end
          else begin
            psum_read_done <= 1'b1;
          end
        end
      end
      else begin
        if (psum_m_tile_read_done && weight_k_group_read_done && weight_n_group_read_done) begin
          if (weight_1_ifmap_2) begin
            if (weight_1_ifmap_2_identifier) begin
              psum_read_done <= 1'b1;
            end
            else begin
              psum_read_done <= 1'b0;
            end
          end
          else if (weight_1_ifmap_4) begin
            if (&weight_1_ifmap_4_identifier) begin
              psum_read_done <= 1'b1;
            end
            else begin
              psum_read_done <= 1'b0;
            end
          end
          else if (weight_2_ifmap_2) begin
            if (weight_2_ifmap_2_identifier) begin
              psum_read_done <= 1'b1;
            end
            else begin
              psum_read_done <= 1'b0;
            end
          end
          else if (weight_2_ifmap_4) begin
            if (weight_2_ifmap_4_identifier && weight_2_ifmap_4_cross_ic) begin
              psum_read_done <= 1'b1;
            end
            else begin
              psum_read_done <= 1'b0;
            end
          end
          else if (weight_4_ifmap_4) begin
            if (ifmap_sram_addr_control_mode == IFMAP_RADDR_RESET) begin
              if ((&weight_4_ifmap_4_identifier) && weight_height_read_done && weight_width_read_done) begin
                if (weight_ic_group_read_done) begin
                  psum_read_done <= 1'b1;
                end
              end
            end
            else begin
              psum_read_done <= psum_read_done;
            end
          end
          else begin
            psum_read_done <= 1'b1;
          end
        end
      end
    end
    else begin
      if (fake_done) begin
        psum_read_done <= 1'b0;
      end
    end
  end
end

assign psum_width_read_done  = (psum_width_read_cnt == (psum_width - 1)) & execute_start;
assign psum_height_read_done = (psum_height_read_cnt == (psum_height - 1)) & execute_start;

assign psum_read_zero_wire = (psum_accumulated | outlier_second_pass | weight_1_ifmap_2_identifier | (|weight_1_ifmap_4_identifier) | weight_2_ifmap_2_identifier | (|weight_4_ifmap_4_identifier) | weight_2_ifmap_4_identifier | weight_2_ifmap_4_cross_ic) ? 1'b0 : 
                             (insn_kind == CONV_EXECUTE_INSN & ((~(|weight_ic_group_read_cnt)) & (~(|weight_width_read_cnt)) & (~(|weight_height_read_cnt)))) | 
                             (insn_kind == GEMM_EXECUTE_INSN & (~(|weight_k_group_read_cnt)));
assign psum_sram_raddr_wire = insn_kind_wire == CONV_EXECUTE_INSN ? weight_oc_group_read_cnt * psum_area + psum_height_read_cnt * psum_width + psum_width_read_cnt :
                              weight_n_group_read_cnt * tile_m + psum_m_tile_read_cnt;

assign psum_m_tile_read_done = (psum_m_tile_read_cnt == (tile_m - 1)) & execute_start;

/* ---------------------------------------- Psum SRAM Read Counter ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_width_read_cnt  <= 0;
    psum_height_read_cnt <= 0;
    psum_m_tile_read_cnt <= 0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if (insn_kind_wire == CONV_EXECUTE_INSN) begin
        if (((!weight_sram_ping_pang_identifier && weight_sram_ping_valid) || (weight_sram_ping_pang_identifier && weight_sram_pang_valid)) && multiple_read_trigger) begin
          if (psum_width_read_done) begin
            psum_width_read_cnt <= 'd0;
          end
          else begin
            psum_width_read_cnt <= psum_width_read_cnt + 1;
          end

          if (psum_width_read_done) begin
            if (psum_height_read_done) begin
              psum_height_read_cnt <= 'd0;
            end
            else begin
              psum_height_read_cnt <= psum_height_read_cnt + 1;
            end
          end
          else begin
            psum_height_read_cnt <= psum_height_read_cnt;
          end
        end
        else begin
          psum_width_read_cnt  <= psum_width_read_cnt;
          psum_height_read_cnt <= psum_height_read_cnt;
        end

        psum_m_tile_read_cnt <= 0;
      end
      else begin
        if (((!weight_sram_ping_pang_identifier && weight_sram_ping_valid) || (weight_sram_ping_pang_identifier && weight_sram_pang_valid)) && multiple_read_trigger) begin
          if (psum_m_tile_read_done) begin
            psum_m_tile_read_cnt <= 'd0;
          end
          else begin
            psum_m_tile_read_cnt <= psum_m_tile_read_cnt + 1;
          end
        end
        else begin
          psum_m_tile_read_cnt <= psum_m_tile_read_cnt;
        end

        psum_width_read_cnt  <= 0;
        psum_height_read_cnt <= 0;
      end
    end
    else begin
      if (fake_done) begin
        psum_width_read_cnt  <= 0;
        psum_height_read_cnt <= 0;
        psum_m_tile_read_cnt <= 0;
      end
      else begin
        psum_width_read_cnt  <= psum_width_read_cnt;
        psum_height_read_cnt <= psum_height_read_cnt;
        psum_m_tile_read_cnt <= psum_m_tile_read_cnt;
      end
    end
  end
end

/* ----------------------------------------- Psum SRAM Read Enable ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_rvalid_reg <= 1'b0;
    psum_read_zero_reg   <= 1'b0;
    psum_sram_raddr_reg  <= 0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if (((!weight_sram_ping_pang_identifier && weight_sram_ping_valid) || (weight_sram_ping_pang_identifier && weight_sram_pang_valid)) && multiple_read_trigger && (!psum_read_done)) begin
        psum_sram_rvalid_reg <= 1'b1;
        psum_read_zero_reg   <= psum_read_zero_wire;
        psum_sram_raddr_reg  <= psum_sram_raddr_wire;
      end
      else begin
        psum_sram_rvalid_reg <= 1'b0;
        psum_sram_raddr_reg  <= psum_sram_raddr_reg;
        psum_read_zero_reg   <= psum_read_zero_reg;
      end
    end
    else begin
      if (fake_done) begin
        psum_sram_rvalid_reg <= 1'b0;
        psum_read_zero_reg   <= 1'b0;
        psum_sram_raddr_reg  <= 0;
      end
      else begin
        psum_sram_rvalid_reg <= psum_sram_rvalid_reg;
        psum_sram_raddr_reg  <= psum_sram_raddr_reg;
        psum_read_zero_reg   <= psum_read_zero_reg;
      end
    end
  end
end

/* ------------------------------------------ Psum SRAM Read Data ----------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_valid_reg          <= 1'b0;
    psum_sram_valid_reg_delay    <= 1'b0;
    psum_read_zero_reg_delay     <= 1'b0;
    psum_read_zero_reg_delay_1   <= 1'b0;
    psum_local_rdata_reg         <= 0;
    psum_local_rdata_valid       <= 1'b0;
    psum_local_rdata_valid_delay <= 1'b0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      psum_read_zero_reg_delay_1   <= psum_read_zero_reg_delay;
      psum_local_rdata_valid_delay <= psum_local_rdata_valid;
      psum_sram_valid_reg_delay    <= psum_sram_valid_reg;
      if (psum_sram_rvalid_reg) begin
        psum_sram_valid_reg      <= 1'b1;
        psum_read_zero_reg_delay <= psum_read_zero_reg;
      end
      else begin
        psum_sram_valid_reg      <= 1'b0;
        psum_read_zero_reg_delay <= 1'b0;
      end

      if (psum_sram_valid_reg_delay) begin
        psum_local_rdata_reg   <= psum_read_zero_reg_delay_1 ? 0 : psum_sram_rdata;
        psum_local_rdata_valid <= psum_sram_valid_reg_delay;
      end
      else begin
        psum_local_rdata_reg   <= psum_local_rdata_reg;
        psum_local_rdata_valid <= 1'b0;
      end
    end
    else begin
      if (fake_done) begin
        psum_sram_valid_reg          <= 1'b0;
        psum_sram_valid_reg_delay    <= 1'b0;
        psum_read_zero_reg_delay     <= 1'b0;
        psum_read_zero_reg_delay_1   <= 1'b0;
        psum_local_rdata_reg         <= 0;
        psum_local_rdata_valid       <= 1'b0;
        psum_local_rdata_valid_delay <= 1'b0;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        Psum SRAM Write Controller                                        */
/* -------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------- Psum SRAM Write Address --------------------------------------- */

assign psum_sram_waddr_wire     = insn_kind_wire == CONV_EXECUTE_INSN ? psum_oc_group_write_cnt * psum_area + psum_height_write_cnt * psum_width + psum_width_write_cnt :
                                  psum_n_group_write_cnt * tile_m + psum_m_tile_write_cnt;

assign weight_width_write_done  = (weight_width_write_cnt == (weight_width - 1)) & execute_start & (compute_done);
assign weight_height_write_done = (weight_height_write_cnt == (weight_height - 1)) & execute_start & (compute_done);
assign psum_width_write_done    = (psum_width_write_cnt == (psum_width - 1)) & execute_start & (compute_done);
assign psum_height_write_done   = (psum_height_write_cnt == (psum_height - 1)) & execute_start & (compute_done);
assign psum_ic_group_write_done = (psum_ic_group_write_cnt == (psum_ic_group - 1)) & execute_start & (compute_done);
assign psum_oc_group_write_done = (psum_oc_group_write_cnt == (oc_group - 1)) & execute_start & (compute_done);

assign psum_m_tile_write_done = (psum_m_tile_write_cnt == (tile_m - 1)) & execute_start & (compute_done);
assign psum_n_group_write_done = (psum_n_group_write_cnt == (n_groups - 1)) & execute_start & (compute_done);
assign psum_k_group_write_done = (psum_k_group_write_cnt == (psum_k_groups - 1)) & execute_start & (compute_done);

/* ---------------------------------------- Psum SRAM Write Counter --------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_width_write_cnt  <= 0;
    weight_height_write_cnt <= 0;
    psum_width_write_cnt    <= 0;
    psum_height_write_cnt   <= 0;
    psum_ic_group_write_cnt <= 0;
    psum_oc_group_write_cnt <= 0;
    psum_m_tile_write_cnt   <= 0;
    psum_n_group_write_cnt  <= 0;
    psum_k_group_write_cnt  <= 0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if (insn_kind_wire == CONV_EXECUTE_INSN) begin
        if (compute_done) begin
          if (psum_width_write_done) begin
            psum_width_write_cnt <= 'd0;
          end
          else begin
            psum_width_write_cnt <= psum_width_write_cnt + 1;
          end

          if (psum_width_write_done) begin
            if (psum_height_write_done) begin
              psum_height_write_cnt <= 'd0;
            end
            else begin
              psum_height_write_cnt <= psum_height_write_cnt + 1;
            end
          end
          else begin
            psum_height_write_cnt <= psum_height_write_cnt;
          end

          if (psum_height_write_done && psum_width_write_done) begin
            if (weight_width_write_done) begin
              weight_width_write_cnt <= 'd0;
            end
            else begin
              weight_width_write_cnt <= weight_width_write_cnt + 1'b1;
            end
          end
          else begin
            weight_width_write_cnt <= weight_width_write_cnt;
          end

          if (psum_width_write_done && psum_height_write_done && weight_width_write_done) begin
            if (weight_height_write_done) begin
              weight_height_write_cnt <= 'd0;
            end
            else begin
              weight_height_write_cnt <= weight_height_write_cnt + 1;
            end
          end
          else begin
            weight_height_write_cnt <= weight_height_write_cnt;
          end

          if (psum_width_write_done && psum_height_write_done && weight_width_write_done && weight_height_write_done) begin
            if (psum_ic_group_write_done) begin
              psum_ic_group_write_cnt <= 'd0;
            end
            else begin
              psum_ic_group_write_cnt <= psum_ic_group_write_cnt + 1;
            end
          end
          else begin
            psum_ic_group_write_cnt <= psum_ic_group_write_cnt;
          end

          if (psum_ic_group_write_done && psum_height_write_done && psum_width_write_done && weight_width_write_done && weight_height_write_done) begin
            if (psum_oc_group_write_done) begin
              psum_oc_group_write_cnt <= 'd0;
            end
            else begin
              psum_oc_group_write_cnt <= psum_oc_group_write_cnt + 1;
            end
          end
          else begin
            psum_oc_group_write_cnt <= psum_oc_group_write_cnt;
          end
        end
        else begin
          psum_width_write_cnt    <= psum_width_write_cnt;
          psum_height_write_cnt   <= psum_height_write_cnt;
          psum_ic_group_write_cnt <= psum_ic_group_write_cnt;
          psum_oc_group_write_cnt <= psum_oc_group_write_cnt;
        end

        psum_m_tile_write_cnt   <= 0;
        psum_n_group_write_cnt  <= 0;
        psum_k_group_write_cnt  <= 0;
      end
      else if (insn_kind_wire == GEMM_EXECUTE_INSN) begin
        if (compute_done) begin
          if (psum_m_tile_write_done) begin
            psum_m_tile_write_cnt <= 'd0;
          end
          else begin
            psum_m_tile_write_cnt <= psum_m_tile_write_cnt + 1;
          end

          if (psum_m_tile_write_done) begin
            if (psum_k_group_write_done) begin
              psum_k_group_write_cnt <= 'd0;
            end
            else begin
              psum_k_group_write_cnt <= psum_k_group_write_cnt + 1;
            end
          end
          else begin
            psum_k_group_write_cnt <= psum_k_group_write_cnt;
          end

          if (psum_k_group_write_done && psum_m_tile_write_done) begin
            if (psum_n_group_write_done) begin
              psum_n_group_write_cnt <= 'd0;
            end
            else begin
              psum_n_group_write_cnt <= psum_n_group_write_cnt + 1;
            end
          end
          else begin
            psum_n_group_write_cnt <= psum_n_group_write_cnt;
          end
        end
        else begin
          psum_m_tile_write_cnt   <= psum_m_tile_write_cnt;
          psum_n_group_write_cnt  <= psum_n_group_write_cnt;
          psum_k_group_write_cnt  <= psum_k_group_write_cnt;
        end

        psum_width_write_cnt    <= 0;
        psum_height_write_cnt   <= 0;
        psum_ic_group_write_cnt <= 0;
      end
      else begin
        psum_width_write_cnt    <= psum_width_write_cnt;
        psum_height_write_cnt   <= psum_height_write_cnt;
        psum_ic_group_write_cnt <= psum_ic_group_write_cnt;
        psum_oc_group_write_cnt <= psum_oc_group_write_cnt;
        psum_m_tile_write_cnt   <= psum_m_tile_write_cnt;
        psum_n_group_write_cnt  <= psum_n_group_write_cnt;
        psum_k_group_write_cnt  <= psum_k_group_write_cnt;
      end
    end
    else begin
      if (fake_done) begin
        psum_width_write_cnt    <= 0;
        psum_height_write_cnt   <= 0;
        psum_ic_group_write_cnt <= 0;
        psum_oc_group_write_cnt <= 0;
        psum_m_tile_write_cnt   <= 0;
        psum_n_group_write_cnt  <= 0;
        psum_k_group_write_cnt  <= 0;
      end
      else begin
        psum_width_write_cnt    <= psum_width_write_cnt;
        psum_height_write_cnt   <= psum_height_write_cnt;
        psum_ic_group_write_cnt <= psum_ic_group_write_cnt;
        psum_oc_group_write_cnt <= psum_oc_group_write_cnt;
        psum_m_tile_write_cnt   <= psum_m_tile_write_cnt;
        psum_n_group_write_cnt  <= psum_n_group_write_cnt;
        psum_k_group_write_cnt  <= psum_k_group_write_cnt;
      end
    end
  end
end

/* ---------------------------------------- Psum SRAM Write Enable ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_wvalid_reg <= 1'b0;
    psum_sram_waddr_reg  <= 0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if (compute_done) begin
        psum_sram_wvalid_reg <= 1'b1;
      end
      else begin
        psum_sram_wvalid_reg <= 1'b0;
      end

      if (compute_done) begin
        psum_sram_waddr_reg <= psum_sram_waddr_wire;
      end
      else begin
        psum_sram_waddr_reg <= psum_sram_waddr_wire;
      end
    end
    else begin
      if (fake_done) begin
        psum_sram_wvalid_reg    <= 1'b0;
        psum_sram_waddr_reg     <= 0;
      end
      else begin
        psum_sram_wvalid_reg    <= psum_sram_wvalid_reg;
        psum_sram_waddr_reg     <= 0;
      end
    end
  end
end

/* ----------------------------------------- Psum SRAM Write Data ----------------------------------------- */
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_wdata_reg     <= 0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if (compute_done) begin
        psum_sram_wdata_reg <= accumulator_result_pack;
      end
      else begin
        psum_sram_wdata_reg     <= psum_sram_wdata_reg;
      end
    end
    else begin
      if (fake_done) begin
        psum_sram_wdata_reg     <= 0;
      end
      else begin
        psum_sram_wdata_reg     <= psum_sram_wdata_reg;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                    Outlier Index SRAM Read Controller                                    */
/* -------------------------------------------------------------------------------------------------------- */

/* ------------------------------------ Outlier Index SRAM Read Address ----------------------------------- */

assign outlier_index_sram_raddr = {ifmap_highaddr, ifmap_sram_raddr_reg};
assign outlier_index_sram_rvalid = ifmap_sram_rvalid & outlier_enable;

/* ------------------------------------- Outlier Index SRAM Read Data ------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    outlier_index_local_rdata_reg <= 0;
  end
  else if (execute_start && !fake_done) begin
    if (ifmap_sram_valid_reg_delay) begin
      if (ifmap_read_zero_reg_delay_1) begin
        outlier_index_local_rdata_reg <= 0;
      end
      else begin
        if (outlier_enable) begin
          outlier_index_local_rdata_reg <= outlier_index_sram_rdata;
        end
      end
    end
  end
  else begin
    if (fake_done) begin
      outlier_index_local_rdata_reg <= 0;
    end
    else begin
      outlier_index_local_rdata_reg <= outlier_index_local_rdata_reg;
    end
  end
end

always @(*) begin
  if (outlier_enable) begin
      if (type_a_reg_stage_1 == TYPE_IS_INT8 && type_b_reg_stage_1 == TYPE_IS_INT8) begin
        real_outlier_index_data = {{REAL_OUTLIER_INDEX_WIDTH{1'b0}}, outlier_index_local_rdata_reg[(OUTLIER_INDEX_WIDTH-REAL_OUTLIER_INDEX_WIDTH/2-1)-:REAL_OUTLIER_INDEX_WIDTH/2], outlier_index_local_rdata_reg[(OUTLIER_INDEX_WIDTH/2-REAL_OUTLIER_INDEX_WIDTH/2-1)-:REAL_OUTLIER_INDEX_WIDTH/2]};
      end
      else if (type_a_reg_stage_1 == TYPE_IS_INT4 && type_b_reg_stage_1 == TYPE_IS_INT4) begin
        if (ifmap_non_uniform_quantization || weight_non_uniform_quantization) begin
          if (sparse_enable) begin
            if (weight_1_ifmap_4_identifier_delay_4[0]) begin
              real_outlier_index_data = {{REAL_OUTLIER_INDEX_WIDTH{1'b0}}, outlier_index_local_rdata_reg[OUTLIER_INDEX_WIDTH-1-:REAL_OUTLIER_INDEX_WIDTH]};
            end
            else begin
              real_outlier_index_data = {{REAL_OUTLIER_INDEX_WIDTH{1'b0}}, outlier_index_local_rdata_reg[REAL_OUTLIER_INDEX_WIDTH-1:0]};
            end
          end
          else begin
            if (weight_1_ifmap_4_identifier_delay_4[0]) begin
              real_outlier_index_data = {{REAL_OUTLIER_INDEX_WIDTH{1'b0}}, outlier_index_local_rdata_reg[OUTLIER_INDEX_WIDTH-1-:REAL_OUTLIER_INDEX_WIDTH/2], outlier_index_local_rdata_reg[OUTLIER_INDEX_WIDTH/2-1-:REAL_OUTLIER_INDEX_WIDTH/2]};
            end
            else begin
              real_outlier_index_data = {{REAL_OUTLIER_INDEX_WIDTH{1'b0}}, outlier_index_local_rdata_reg[(OUTLIER_INDEX_WIDTH-REAL_OUTLIER_INDEX_WIDTH/2-1)-:REAL_OUTLIER_INDEX_WIDTH/2], outlier_index_local_rdata_reg[(OUTLIER_INDEX_WIDTH/2-REAL_OUTLIER_INDEX_WIDTH/2-1)-:REAL_OUTLIER_INDEX_WIDTH/2]};
            end
          end
        end
        else begin
          real_outlier_index_data = outlier_index_local_rdata_reg;
        end
      end
      else if (type_a_reg_stage_1 == TYPE_IS_INT4 && type_b_reg_stage_1 == TYPE_IS_INT8) begin
        if (weight_2_ifmap_4_cross_ic_delay_4) begin
          real_outlier_index_data = {{REAL_OUTLIER_INDEX_WIDTH{1'b0}}, outlier_index_local_rdata_reg[OUTLIER_INDEX_WIDTH-1-:REAL_OUTLIER_INDEX_WIDTH/2], outlier_index_local_rdata_reg[OUTLIER_INDEX_WIDTH/2-1-:REAL_OUTLIER_INDEX_WIDTH/2]};
        end
        else begin
          real_outlier_index_data = {{REAL_OUTLIER_INDEX_WIDTH{1'b0}}, outlier_index_local_rdata_reg[(OUTLIER_INDEX_WIDTH-REAL_OUTLIER_INDEX_WIDTH/2-1)-:REAL_OUTLIER_INDEX_WIDTH/2], outlier_index_local_rdata_reg[(OUTLIER_INDEX_WIDTH/2-REAL_OUTLIER_INDEX_WIDTH/2-1)-:REAL_OUTLIER_INDEX_WIDTH/2]};
        end
      end
      else begin
        real_outlier_index_data = {{REAL_OUTLIER_INDEX_WIDTH{1'b0}}, outlier_index_local_rdata_reg[(OUTLIER_INDEX_WIDTH-REAL_OUTLIER_INDEX_WIDTH/2-1)-:REAL_OUTLIER_INDEX_WIDTH/2], outlier_index_local_rdata_reg[(OUTLIER_INDEX_WIDTH/2-REAL_OUTLIER_INDEX_WIDTH/2-1)-:REAL_OUTLIER_INDEX_WIDTH/2]};
      end
    end
  else begin
    real_outlier_index_data = {OUTLIER_INDEX_WIDTH{1'b0}};
  end
end

genvar outlier_index_int4_sparse_selector_i;
generate
  for (outlier_index_int4_sparse_selector_i = 0; outlier_index_int4_sparse_selector_i < LANE; outlier_index_int4_sparse_selector_i = outlier_index_int4_sparse_selector_i + 1) begin : outlier_index_int4_sparse_selector
    sparse_selector_outlier_128 u_outlier_index_sparse_selector_4bit(
      .mask ( real_ifmapmask_local_data[outlier_index_int4_sparse_selector_i]      ),
      .data ( real_outlier_index_data                                              ),
      .out  ( outlier_index_sparse_4bit_data[outlier_index_int4_sparse_selector_i] )
    );
  end
endgenerate

genvar outlier_index_int8_sparse_selector_i;
generate
  for (outlier_index_int8_sparse_selector_i = 0; outlier_index_int8_sparse_selector_i < LANE; outlier_index_int8_sparse_selector_i = outlier_index_int8_sparse_selector_i + 1) begin : outlier_index_int8_sparse_selector
    sparse_selector_outlier_64 u_outlier_index_sparse_selector_8bit(
      .mask ( real_ifmapmask_local_data[outlier_index_int8_sparse_selector_i][OUTLIER_INDEX_WIDTH/2-1:0] ),
      .data ( real_outlier_index_data[OUTLIER_INDEX_WIDTH/2-1:0]                                         ),
      .out  ( outlier_index_sparse_8bit_data[outlier_index_int8_sparse_selector_i]                       )
    );
  end
endgenerate

genvar outlier_local_data_assign_i;
generate
for (outlier_local_data_assign_i = 0; outlier_local_data_assign_i < LANE; outlier_local_data_assign_i = outlier_local_data_assign_i + 1) begin : outlier_local_data_assign
  always @(*) begin
    if (sparse_enable) begin
      if (type_a_reg_stage_1[0] | type_b_reg_stage_1[0]) begin
        outlier_index_local_data[outlier_local_data_assign_i] = {{REAL_OUTLIER_INDEX_WIDTH/2{1'b0}}, outlier_index_sparse_8bit_data[outlier_local_data_assign_i]};
      end
      else begin
        outlier_index_local_data[outlier_local_data_assign_i] = outlier_index_sparse_4bit_data[outlier_local_data_assign_i];
      end
    end
    else begin
      outlier_index_local_data[outlier_local_data_assign_i] = real_outlier_index_data[REAL_OUTLIER_INDEX_WIDTH-1:0];
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      outlier_index_local_data_reg[outlier_local_data_assign_i] <= 0;
    end
    else begin
      outlier_index_local_data_reg[outlier_local_data_assign_i] <= outlier_index_local_data[outlier_local_data_assign_i];
    end
  end
end
endgenerate
        
/* -------------------------------------------------------------------------------------------------------- */
/*                                      Ifmap Scale SRAM Read Contoller                                     */
/* -------------------------------------------------------------------------------------------------------- */

/* ------------------------------- Ifmap Scale SRAM Read Address and Enable ------------------------------- */

assign ifmap_scale_sram_raddr  = {ifmap_highaddr, ifmap_scale_sram_raddr_reg};
assign ifmap_scale_sram_rvalid    = ifmap_sram_rvalid & ifmap_scale_enable;

/* -------------------------------------- Ifmap Scale Sram Read Data -------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_scale_local_rdata_reg <= 0;
  end
  else begin
    if (ifmap_sram_valid_reg_delay) begin
      ifmap_scale_local_rdata_reg <= ifmap_read_zero_reg_delay_1 ? 0 : ifmap_scale_sram_rdata;
    end
    else begin
      ifmap_scale_local_rdata_reg <= ifmap_scale_local_rdata_reg;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                     Weight Scale SRAM Read Controller                                    */
/* -------------------------------------------------------------------------------------------------------- */

/* ------------------------------- Weight Scale SRAM Read Address and Enable ------------------------------ */

assign weight_scale_sram_raddr = {weight_highaddr, weight_sram_raddr_reg};
assign weight_scale_sram_rvalid   = weight_sram_rvalid & weight_scale_enable;

/* ------------------------------ Weight Scale SRAM Read Ping-Pang Controller ----------------------------- */

integer weight_scale_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (weight_scale_i = 0; weight_scale_i < LANE; weight_scale_i = weight_scale_i + 1) begin
      weight_scale_local_data_reg_ping[weight_scale_i] <= 0;
      weight_scale_local_data_reg_pang[weight_scale_i] <= 0;
    end
  end
  else begin
    if (weight_regfile_ping_wen) begin
      weight_scale_local_data_reg_ping[weight_regfile_ping_waddr] <= weight_scale_sram_rdata;
    end

    if (weight_regfile_pang_wen) begin
      weight_scale_local_data_reg_pang[weight_regfile_pang_waddr] <= weight_scale_sram_rdata;
    end
  end
end

genvar weight_scale_assign_idx;
generate
  for (weight_scale_assign_idx = 0; weight_scale_assign_idx < LANE; weight_scale_assign_idx = weight_scale_assign_idx + 1) begin: weight_scale_assign
    assign weight_scale_local_data[weight_scale_assign_idx] = weight_ping_pang_using ? weight_scale_local_data_reg_pang[weight_scale_assign_idx] : weight_scale_local_data_reg_ping[weight_scale_assign_idx];
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                              Scale Processor                                             */
/* -------------------------------------------------------------------------------------------------------- */

wire [15:0] mpt_scale_mul_result[0:LANE-1];
reg [15:0] mpt_scale_stage_1[0:LANE-1];
reg [15:0] mpt_scale_stage_2[0:LANE-1];
reg [15:0] mpt_scale_stage_3[0:LANE-1];
reg [15:0] mpt_scale_stage_4[0:LANE-1];
reg [15:0] mpt_scale_stage_5[0:LANE-1];
reg [15:0] mpt_scale_stage_6[0:LANE-1];
reg [15:0] mpt_scale_stage_7[0:LANE-1];
reg [15:0] mpt_scale_stage_8[0:LANE-1];
reg [15:0] mpt_scale_stage_9[0:LANE-1];
reg [15:0] mpt_scale_stage_10[0:LANE-1];
reg [15:0] mpt_scale_stage_11[0:LANE-1];
reg [15:0] mpt_scale_stage_12[0:LANE-1];

integer mpt_scale_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (mpt_scale_i = 0; mpt_scale_i < LANE; mpt_scale_i = mpt_scale_i + 1) begin
      mpt_scale_stage_1[mpt_scale_i]  <= 0;
      mpt_scale_stage_2[mpt_scale_i]  <= 0;
      mpt_scale_stage_3[mpt_scale_i]  <= 0;
      mpt_scale_stage_4[mpt_scale_i]  <= 0;
      mpt_scale_stage_5[mpt_scale_i]  <= 0;
      mpt_scale_stage_6[mpt_scale_i]  <= 0;
      mpt_scale_stage_7[mpt_scale_i]  <= 0;
      mpt_scale_stage_8[mpt_scale_i]  <= 0;
      mpt_scale_stage_9[mpt_scale_i]  <= 0;
      mpt_scale_stage_10[mpt_scale_i] <= 0;
      mpt_scale_stage_11[mpt_scale_i] <= 0;
      mpt_scale_stage_12[mpt_scale_i] <= 0;
    end
  end
  else begin
    if (execute_start && !fake_done) begin
      if (ifmap_scale_enable && weight_scale_enable) begin
        for (mpt_scale_i = 0; mpt_scale_i < LANE; mpt_scale_i = mpt_scale_i + 1) begin
          mpt_scale_stage_1[mpt_scale_i]  <= mpt_scale_mul_result[mpt_scale_i];
          mpt_scale_stage_2[mpt_scale_i]  <= mpt_scale_stage_1[mpt_scale_i];
          mpt_scale_stage_3[mpt_scale_i]  <= mpt_scale_stage_2[mpt_scale_i];
          mpt_scale_stage_4[mpt_scale_i]  <= mpt_scale_stage_3[mpt_scale_i];
          mpt_scale_stage_5[mpt_scale_i]  <= mpt_scale_stage_4[mpt_scale_i];
          mpt_scale_stage_6[mpt_scale_i]  <= mpt_scale_stage_5[mpt_scale_i];
          mpt_scale_stage_7[mpt_scale_i]  <= mpt_scale_stage_6[mpt_scale_i];
          mpt_scale_stage_8[mpt_scale_i]  <= mpt_scale_stage_7[mpt_scale_i];
          mpt_scale_stage_9[mpt_scale_i]  <= mpt_scale_stage_8[mpt_scale_i];
          mpt_scale_stage_10[mpt_scale_i] <= mpt_scale_stage_9[mpt_scale_i];
          mpt_scale_stage_11[mpt_scale_i] <= mpt_scale_stage_10[mpt_scale_i];
          mpt_scale_stage_12[mpt_scale_i] <= mpt_scale_stage_11[mpt_scale_i];
        end
      end
      else begin
        for (mpt_scale_i = 0; mpt_scale_i < LANE; mpt_scale_i = mpt_scale_i + 1) begin
          mpt_scale_stage_1[mpt_scale_i]  <= 0;
          mpt_scale_stage_2[mpt_scale_i]  <= 0;
          mpt_scale_stage_3[mpt_scale_i]  <= 0;
          mpt_scale_stage_4[mpt_scale_i]  <= 0;
          mpt_scale_stage_5[mpt_scale_i]  <= 0;
          mpt_scale_stage_6[mpt_scale_i]  <= 0;
          mpt_scale_stage_7[mpt_scale_i]  <= 0;
          mpt_scale_stage_8[mpt_scale_i]  <= 0;
          mpt_scale_stage_9[mpt_scale_i]  <= 0;
          mpt_scale_stage_10[mpt_scale_i] <= 0;
          mpt_scale_stage_11[mpt_scale_i] <= 0;
          mpt_scale_stage_12[mpt_scale_i] <= 0;
        end
      end
    end
    else begin
      if (fake_done) begin
        for (mpt_scale_i = 0; mpt_scale_i < LANE; mpt_scale_i = mpt_scale_i + 1) begin
          mpt_scale_stage_1[mpt_scale_i]  <= 0;
          mpt_scale_stage_2[mpt_scale_i]  <= 0;
          mpt_scale_stage_3[mpt_scale_i]  <= 0;
          mpt_scale_stage_4[mpt_scale_i]  <= 0;
          mpt_scale_stage_5[mpt_scale_i]  <= 0;
          mpt_scale_stage_6[mpt_scale_i]  <= 0;
          mpt_scale_stage_7[mpt_scale_i]  <= 0;
          mpt_scale_stage_8[mpt_scale_i]  <= 0;
          mpt_scale_stage_9[mpt_scale_i]  <= 0;
          mpt_scale_stage_10[mpt_scale_i] <= 0;
          mpt_scale_stage_11[mpt_scale_i] <= 0;
          mpt_scale_stage_12[mpt_scale_i] <= 0;
        end
      end
      else begin
        for (mpt_scale_i = 0; mpt_scale_i < LANE; mpt_scale_i = mpt_scale_i + 1) begin
          mpt_scale_stage_1[mpt_scale_i]  <= mpt_scale_stage_1[mpt_scale_i];
          mpt_scale_stage_2[mpt_scale_i]  <= mpt_scale_stage_2[mpt_scale_i];
          mpt_scale_stage_3[mpt_scale_i]  <= mpt_scale_stage_3[mpt_scale_i];
          mpt_scale_stage_4[mpt_scale_i]  <= mpt_scale_stage_4[mpt_scale_i];
          mpt_scale_stage_5[mpt_scale_i]  <= mpt_scale_stage_5[mpt_scale_i];
          mpt_scale_stage_6[mpt_scale_i]  <= mpt_scale_stage_6[mpt_scale_i];
          mpt_scale_stage_7[mpt_scale_i]  <= mpt_scale_stage_7[mpt_scale_i];
          mpt_scale_stage_8[mpt_scale_i]  <= mpt_scale_stage_8[mpt_scale_i];
          mpt_scale_stage_9[mpt_scale_i]  <= mpt_scale_stage_9[mpt_scale_i];
          mpt_scale_stage_10[mpt_scale_i] <= mpt_scale_stage_10[mpt_scale_i];
          mpt_scale_stage_11[mpt_scale_i] <= mpt_scale_stage_11[mpt_scale_i];
          mpt_scale_stage_12[mpt_scale_i] <= mpt_scale_stage_12[mpt_scale_i];
        end
      end
    end
  end
end

wire [15:0] ifmap_scale_select;
assign ifmap_scale_select = outlier_enable ? outlier_second_pass_delay_delay_4 ? ifmap_scale_local_rdata_reg[31:16] : ifmap_scale_local_rdata_reg[15:0] : ifmap_scale_local_rdata_reg[15:0];

genvar mpt_scale_mul_i;
generate
  for (mpt_scale_mul_i = 0; mpt_scale_mul_i < LANE; mpt_scale_mul_i = mpt_scale_mul_i + 1) begin : mpt_scale_multiplier
    multiplier_float16_pipeline_stage_1 u_mpt_scale_multiplier(
      .clk   ( clk                                      ),
      .rst_n ( rst_n                                    ),
      .a     ( ifmap_scale_select                       ),
      .b     ( weight_scale_local_data[mpt_scale_mul_i] ),
      .o     ( mpt_scale_mul_result[mpt_scale_mul_i]    )
    );
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                               Psum Pipeline                                              */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    type_a_reg_stage_1 <= 0;
    type_a_reg_stage_2 <= 0;
    type_b_reg_stage_1 <= 0;
    type_b_reg_stage_2 <= 0;
  end
  else begin
    if (execute_start && !fake_done) begin
      type_a_reg_stage_1 <= type_a;
      type_a_reg_stage_2 <= type_a_reg_stage_1;
      type_b_reg_stage_1 <= type_b;
      type_b_reg_stage_2 <= type_b_reg_stage_1;
    end
    else begin
      if (fake_done) begin
        type_a_reg_stage_1 <= 0;
        type_a_reg_stage_2 <= 0;
        type_b_reg_stage_1 <= 0;
        type_b_reg_stage_2 <= 0;
      end
      else begin
        type_a_reg_stage_1 <= type_a_reg_stage_1;
        type_a_reg_stage_2 <= type_a_reg_stage_2;
        type_b_reg_stage_1 <= type_b_reg_stage_1;
        type_b_reg_stage_2 <= type_b_reg_stage_2;
      end
    end
  end
end

wire [1:0] psum_pipeline_stage_mode;
assign psum_pipeline_stage_mode = (type_a[1] | type_b[1]) ? 2 : 0;
wire [31:0] psum_local_rdata_wire[0:LANE-1];

generate
genvar psum_local_rdata_i;
for (psum_local_rdata_i=0; psum_local_rdata_i<LANE; psum_local_rdata_i=psum_local_rdata_i+1)
begin: psum_unpack_array
        assign psum_local_rdata_wire[psum_local_rdata_i][31:0] = psum_local_rdata_reg[(32*psum_local_rdata_i+31):(32*psum_local_rdata_i)];
end
endgenerate

reg [31:0] psum_reg_stage_0[0:LANE-1];
reg [31:0] psum_reg_stage_1[0:LANE-1];
reg [31:0] psum_reg_stage_2[0:LANE-1];
reg [31:0] psum_reg_stage_3[0:LANE-1];
reg [31:0] psum_reg_stage_4[0:LANE-1];
reg [31:0] psum_reg_stage_5[0:LANE-1];
reg [31:0] psum_reg_stage_6[0:LANE-1];
reg [31:0] psum_reg_stage_7[0:LANE-1];
reg [31:0] psum_reg_stage_8[0:LANE-1];
reg [31:0] psum_reg_stage_9[0:LANE-1];
reg [31:0] psum_reg_stage_10[0:LANE-1];
reg [31:0] psum_reg_stage_11[0:LANE-1];
reg [31:0] psum_reg_stage_12[0:LANE-1];
reg [31:0] psum_reg_stage_13[0:LANE-1];
reg [31:0] psum_reg_stage_14[0:LANE-1];

integer psum_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (psum_i = 0; psum_i < LANE; psum_i = psum_i + 1) begin
      psum_reg_stage_0[psum_i]  <= 0; // mul 0
      psum_reg_stage_1[psum_i]  <= 0; // mul 1
      psum_reg_stage_2[psum_i]  <= 0; // add 0 0
      psum_reg_stage_3[psum_i]  <= 0; // add 0 1
      psum_reg_stage_4[psum_i]  <= 0; // add 1 0
      psum_reg_stage_5[psum_i]  <= 0; // add 1 1
      psum_reg_stage_6[psum_i]  <= 0; // add 2 0
      psum_reg_stage_7[psum_i]  <= 0; // add 2 1
      psum_reg_stage_8[psum_i]  <= 0; // add 3 0
      psum_reg_stage_9[psum_i]  <= 0; // add 3 1
      psum_reg_stage_10[psum_i] <= 0; // add 4 0
      psum_reg_stage_11[psum_i] <= 0; // add 4 1
      psum_reg_stage_12[psum_i] <= 0; // accumulator
      psum_reg_stage_13[psum_i] <= 0; // accumulator
      psum_reg_stage_14[psum_i] <= 0; // accumulator
    end
  end
  else begin
    if (execute_start && !fake_done) begin
      for (psum_i = 0; psum_i < LANE; psum_i = psum_i + 1) begin
        psum_reg_stage_0[psum_i]  <= psum_local_rdata_wire[psum_i];
        psum_reg_stage_1[psum_i]  <= psum_reg_stage_0[psum_i];
        psum_reg_stage_2[psum_i]  <= psum_reg_stage_1[psum_i];
        psum_reg_stage_3[psum_i]  <= psum_reg_stage_2[psum_i];
        psum_reg_stage_4[psum_i]  <= psum_reg_stage_3[psum_i];
        psum_reg_stage_5[psum_i]  <= psum_reg_stage_4[psum_i];
        psum_reg_stage_6[psum_i]  <= psum_reg_stage_5[psum_i];
        psum_reg_stage_7[psum_i]  <= psum_reg_stage_6[psum_i];
        psum_reg_stage_8[psum_i]  <= psum_reg_stage_7[psum_i];
        psum_reg_stage_9[psum_i]  <= psum_reg_stage_8[psum_i];
        psum_reg_stage_10[psum_i] <= psum_reg_stage_9[psum_i];
        psum_reg_stage_11[psum_i] <= psum_reg_stage_10[psum_i];
        psum_reg_stage_12[psum_i] <= psum_reg_stage_11[psum_i];
        psum_reg_stage_13[psum_i] <= psum_reg_stage_12[psum_i];
        psum_reg_stage_14[psum_i] <= psum_reg_stage_13[psum_i];
      end
    end
    else begin
      if (fake_done) begin
        for (psum_i = 0; psum_i < LANE; psum_i = psum_i + 1) begin
          psum_reg_stage_0[psum_i]  <= 0;
          psum_reg_stage_1[psum_i]  <= 0;
          psum_reg_stage_2[psum_i]  <= 0;
          psum_reg_stage_3[psum_i]  <= 0;
          psum_reg_stage_4[psum_i]  <= 0;
          psum_reg_stage_5[psum_i]  <= 0;
          psum_reg_stage_6[psum_i]  <= 0;
          psum_reg_stage_7[psum_i]  <= 0;
          psum_reg_stage_8[psum_i]  <= 0;
          psum_reg_stage_9[psum_i]  <= 0;
          psum_reg_stage_10[psum_i] <= 0;
          psum_reg_stage_11[psum_i] <= 0;
          psum_reg_stage_12[psum_i] <= 0;
          psum_reg_stage_13[psum_i] <= 0;
          psum_reg_stage_14[psum_i] <= 0;
        end
      end
      else begin
        for (psum_i = 0; psum_i < LANE; psum_i = psum_i + 1) begin
          psum_reg_stage_0[psum_i]  <= psum_reg_stage_0[psum_i];
          psum_reg_stage_1[psum_i]  <= psum_reg_stage_1[psum_i];
          psum_reg_stage_2[psum_i]  <= psum_reg_stage_2[psum_i];
          psum_reg_stage_3[psum_i]  <= psum_reg_stage_3[psum_i];
          psum_reg_stage_4[psum_i]  <= psum_reg_stage_4[psum_i];
          psum_reg_stage_5[psum_i]  <= psum_reg_stage_5[psum_i];
          psum_reg_stage_6[psum_i]  <= psum_reg_stage_6[psum_i];
          psum_reg_stage_7[psum_i]  <= psum_reg_stage_7[psum_i];
          psum_reg_stage_8[psum_i]  <= psum_reg_stage_8[psum_i];
          psum_reg_stage_9[psum_i]  <= psum_reg_stage_9[psum_i];
          psum_reg_stage_10[psum_i] <= psum_reg_stage_10[psum_i];
          psum_reg_stage_11[psum_i] <= psum_reg_stage_11[psum_i];
          psum_reg_stage_12[psum_i] <= psum_reg_stage_11[psum_i];
          psum_reg_stage_13[psum_i] <= psum_reg_stage_12[psum_i];
          psum_reg_stage_14[psum_i] <= psum_reg_stage_13[psum_i];
        end
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                          Weight Ping-Pang Buffer                                         */
/* -------------------------------------------------------------------------------------------------------- */

wire regfile_int4;
assign regfile_int4 = !((~(|type_a[2:1])) & !type_a[0] & (~(|type_b[2:1])) & (!type_b[0]));

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_ping_pang_using <= 'd0;
  end
  else begin
    if (execute_start && !fake_done) begin
      weight_ping_pang_using <= weight_sram_ping_pang_identifier_delay_3;
    end
    else begin
      if (fake_done) begin
        weight_ping_pang_using <= 'd0;
      end
      else begin
        weight_ping_pang_using <= weight_ping_pang_using;
      end
    end
  end
end

integer weight_regfile_assign_i;

always @(posedge clk or negedge rst_n)
begin
  if (!rst_n) begin
    for (weight_regfile_assign_i = 0; weight_regfile_assign_i < LANE; weight_regfile_assign_i = weight_regfile_assign_i + 1) begin
      weight_regfile_ping[weight_regfile_assign_i] <= {WEIGHT_WIDTH{1'b0}};
      weight_regfile_pang[weight_regfile_assign_i] <= {WEIGHT_WIDTH{1'b0}};
    end
  end
  else begin
    if (weight_regfile_ping_wen) begin
      weight_regfile_ping[weight_regfile_ping_waddr] <= weight_sram_rdata;
    end
    else begin
      for (weight_regfile_assign_i = 0; weight_regfile_assign_i < LANE; weight_regfile_assign_i = weight_regfile_assign_i + 1) begin
        weight_regfile_ping[weight_regfile_assign_i] <= weight_regfile_ping[weight_regfile_assign_i];
      end
    end

    if (weight_regfile_pang_wen) begin
      weight_regfile_pang[weight_regfile_pang_waddr] <= weight_sram_rdata;
    end
    else begin
      for (weight_regfile_assign_i = 0; weight_regfile_assign_i < LANE; weight_regfile_assign_i = weight_regfile_assign_i + 1) begin
        weight_regfile_pang[weight_regfile_assign_i] <= weight_regfile_pang[weight_regfile_assign_i];
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                    MPT                                                   */
/* -------------------------------------------------------------------------------------------------------- */

genvar mpt_i;
generate
  for (mpt_i = 0; mpt_i < LANE; mpt_i = mpt_i + 1) begin : mpt
    mpt_mixed u_mpt(
      .clk    ( clk                                                              ),
      .rst_n  ( rst_n                                                            ),
      .type_a ( ifmap_non_uniform_quantization ? 2'b1 : type_a_reg_stage_2[1:0]  ),
      .type_b ( weight_non_uniform_quantization ? 2'b1 : type_b_reg_stage_2[1:0] ),
      .valid  ( mpt_valid                                                        ),
      .a      ( ifmap_local_data[mpt_i]                                          ),
      .b      ( weight_local_data_shifted_reg[mpt_i]                             ),
      .o      ( mpt_result[mpt_i]                                                ),
      .done   ( mpt_done[mpt_i]                                                  ),
      .clear  ( fake_done                                                        )
    );
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Accumulator                                               */
/* -------------------------------------------------------------------------------------------------------- */

integer mpt_result_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (mpt_result_i = 0; mpt_result_i < LANE; mpt_result_i = mpt_result_i + 1) begin
      mpt_result_reg[mpt_result_i] <= 0;
    end
  end
  else begin
    for (mpt_result_i = 0; mpt_result_i < LANE; mpt_result_i = mpt_result_i + 1) begin
      mpt_result_reg[mpt_result_i] <= mpt_result[mpt_result_i];
    end
  end
end

genvar fma_i;
generate 
  for (fma_i = 0; fma_i < LANE; fma_i = fma_i + 1) begin : fma
    custom_fma u_fma(
      .clk   ( clk                      ),
      .rst_n ( rst_n                    ),
      .psum  ( mpt_result_reg[fma_i]    ),
      .scale ( mpt_scale_stage_12[fma_i] ),
      .o     ( fma_result[fma_i]        )
    );
  end
endgenerate

reg [31:0] accumulator_a[0:LANE-1];
wire [31:0] accumulator_b[0:LANE-1];

integer accumulator_a_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (accumulator_a_i = 0; accumulator_a_i < LANE; accumulator_a_i = accumulator_a_i + 1) begin
      accumulator_a[accumulator_a_i] <= 0;
    end
  end
  else begin
    for (accumulator_a_i = 0; accumulator_a_i < LANE; accumulator_a_i = accumulator_a_i + 1) begin
      if (psum_pipeline_stage_mode == 0 && type_accumulator) begin
        accumulator_a[accumulator_a_i] <= fma_result[accumulator_a_i];
      end
      else begin
        accumulator_a[accumulator_a_i] <= mpt_result[accumulator_a_i];
      end
    end
  end
end

genvar accumulator_b_i;
generate
  for (accumulator_b_i = 0; accumulator_b_i < LANE; accumulator_b_i = accumulator_b_i + 1) begin : accumulator_b_assign
    assign accumulator_b[accumulator_b_i] = psum_pipeline_stage_mode == 2 ? psum_reg_stage_10[accumulator_b_i] :
                                            psum_pipeline_stage_mode == 0 && type_accumulator ? psum_reg_stage_14[accumulator_b_i] :
                                            psum_pipeline_stage_mode == 0 && !type_accumulator ? psum_reg_stage_12[accumulator_b_i] : 0;
  end
endgenerate


genvar accumulator_i;
generate
  for (accumulator_i = 0; accumulator_i < LANE; accumulator_i = accumulator_i + 1) begin : accumulator
    accumulator_pipeline_stage_1 u_accumulator(
      .clk     ( clk                               ),
      .rst_n   ( rst_n                             ),
      .mode    ( type_accumulator                  ),
      .a       ( accumulator_a[accumulator_i]      ),
      .b       ( accumulator_b[accumulator_i]      ),
      .o       ( accumulator_result[accumulator_i] )
    );
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                              Sparse selector                                             */
/* -------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------- Sparse mask read ------------------------------------------- */

assign ifmapmask_sram_raddr = {weight_highaddr, weight_sram_raddr_reg};
assign ifmapmask_sram_rvalid   = weight_sram_rvalid & sparse_enable;

integer ifmapmask_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (ifmapmask_i = 0; ifmapmask_i < LANE; ifmapmask_i = ifmapmask_i + 1) begin
      ifmapmask_local_data_reg_ping[ifmapmask_i] <= 0;
      ifmapmask_local_data_reg_pang[ifmapmask_i] <= 0;
    end
  end
  else begin
    if (weight_regfile_ping_wen) begin
      ifmapmask_local_data_reg_ping[weight_regfile_ping_waddr] <= ifmapmask_sram_rdata;
    end

    if (weight_regfile_pang_wen) begin
      ifmapmask_local_data_reg_pang[weight_regfile_pang_waddr] <= ifmapmask_sram_rdata;
    end
  end
end

genvar ifmapmask_assign_idx;
generate
  for (ifmapmask_assign_idx = 0; ifmapmask_assign_idx < LANE; ifmapmask_assign_idx = ifmapmask_assign_idx + 1) begin: ifmapmask_assign
    data_move_ifmapmask u_data_move_ifmapmask(
      .in                               ( ifmapmask_local_data[ifmapmask_assign_idx]      ),
      .out                              ( real_ifmapmask_local_data[ifmapmask_assign_idx] ),
      .mode                             ( weight_data_move_control_mode                   ),
      .type_a                           ( type_a_reg_stage_1[1:0]                         ),
      .outlier_enable                   ( outlier_enable                                  ),
      .weight_1_ifmap_4_identifier      ( weight_1_ifmap_4_identifier_delay_4             ),
      .weight_1_ifmap_2_identifier      ( weight_1_ifmap_2_identifier_delay_4             )
    );
    
    always @(*) begin
      if (weight_ping_pang_using) begin
        ifmapmask_local_data[ifmapmask_assign_idx] = ifmapmask_local_data_reg_pang[ifmapmask_assign_idx];
      end
      else begin
        ifmapmask_local_data[ifmapmask_assign_idx] = ifmapmask_local_data_reg_ping[ifmapmask_assign_idx];
      end
    end
  end
endgenerate

genvar fp16_sparse_selector_i;
generate
  for (fp16_sparse_selector_i = 0; fp16_sparse_selector_i < LANE; fp16_sparse_selector_i = fp16_sparse_selector_i + 1) begin : fp16_sparse_selector
    sparse_selector_32_16bit u_sparse_selector_16bit(
      .mask ( real_ifmapmask_local_data[fp16_sparse_selector_i][PARALLELISM*2-1:0] ),
      .data ( read_ifmap_local_rdata                                               ),
      .out  ( ifmap_sparse_16bit_data[fp16_sparse_selector_i]                      )
    );
  end
endgenerate

genvar int4_sparse_selector_i;
generate
  for (int4_sparse_selector_i = 0; int4_sparse_selector_i < LANE; int4_sparse_selector_i = int4_sparse_selector_i + 1) begin : int4_sparse_selector
    sparse_selector_128_4bit u_sparse_selector_4bit(
      .mask ( real_ifmapmask_local_data[int4_sparse_selector_i] ),
      .data ( read_ifmap_local_rdata                            ),
      .out  ( ifmap_sparse_4bit_data[int4_sparse_selector_i]    )
    );
  end
endgenerate

genvar int8_sparse_selector_i;
generate
  for (int8_sparse_selector_i = 0; int8_sparse_selector_i < LANE; int8_sparse_selector_i = int8_sparse_selector_i + 1) begin : int8_sparse_selector
    sparse_selector_64_8bit u_sparse_selector_8bit(
      .mask ( real_ifmapmask_local_data[int8_sparse_selector_i][PARALLELISM*4-1:0] ),
      .data ( read_ifmap_local_rdata                                               ),
      .out  ( ifmap_sparse_8bit_data[int8_sparse_selector_i]                       )
    );
  end
endgenerate

data_move_ifmap u_data_move_ifmap(
  .in                          ( ifmap_local_rdata_reg                         ),
  .type_b                      ( type_b_reg_stage_1                            ),
  .outlier_enable              ( outlier_enable                                ),
  .sparse_enable               ( sparse_enable                                 ),
  .weight_1_ifmap_2_identifier ( weight_1_ifmap_2_identifier_delay_4           ),
  .weight_1_ifmap_4_identifier ( weight_1_ifmap_4_identifier_delay_4           ),
  .weight_2_ifmap_2_identifier ( weight_2_ifmap_2_identifier_delay_4           ),
  .weight_2_ifmap_4_cross_ic   ( weight_2_ifmap_4_cross_ic_delay_4             ),
  .weight_4_ifmap_4_identifier ( weight_4_ifmap_4_identifier_delay_4           ),
  .mode                        ( ifmap_data_move_control_mode                  ),
  .out                         ( read_ifmap_local_rdata                        )
);

wire int8_enable;

assign int8_enable = (type_a_reg_stage_1 == TYPE_IS_INT8) | (type_b_reg_stage_1 == TYPE_IS_INT8) |
                     (type_a_reg_stage_1 == TYPE_IS_INT4 & ifmap_non_uniform_quantization) |
                     (type_b_reg_stage_1 == TYPE_IS_INT4 & weight_non_uniform_quantization);

genvar ifmap_local_data_assign_i;
generate
for (ifmap_local_data_assign_i = 0; ifmap_local_data_assign_i < LANE; ifmap_local_data_assign_i = ifmap_local_data_assign_i + 1) begin : ifmap_local_data_assign
  wire [REAL_IFMAP_WIDTH-1:0] ifmap_local_data_before_outlier;
  wire [REAL_IFMAP_WIDTH-1:0] ifmap_local_data_after_outlier;

  assign ifmap_local_data_before_outlier = sparse_enable ? (type_a_reg_stage_1[1] | type_b_reg_stage_1[1]) ? ifmap_sparse_16bit_data[ifmap_local_data_assign_i] :
                                                  (type_a_reg_stage_1[0] | type_b_reg_stage_1[0] | ifmap_non_uniform_quantization | weight_non_uniform_quantization) ? ifmap_sparse_8bit_data[ifmap_local_data_assign_i] :
                                                  ifmap_sparse_4bit_data[ifmap_local_data_assign_i] : read_ifmap_local_rdata[REAL_IFMAP_WIDTH-1:0];
  
  outlier_compressor u_outlier_compressor(
    .dtype_sel           ( int8_enable                                         ),
    .ifmap               ( ifmap_local_data_before_outlier                     ),
    .outlier_second_pass ( outlier_second_pass_delay_delay_4                   ),
    .outlier_index       ( outlier_index_local_data[ifmap_local_data_assign_i] ),
    .out                 ( ifmap_local_data_after_outlier                      )
  );
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ifmap_local_data[ifmap_local_data_assign_i] <= 0;
    end
    else begin
      if (outlier_enable) begin
        ifmap_local_data[ifmap_local_data_assign_i] <= ifmap_local_data_after_outlier;
      end
      else begin
        ifmap_local_data[ifmap_local_data_assign_i] <= ifmap_local_data_before_outlier;
      end
    end
  end
end
endgenerate
  

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Done Logic                                                */
/* -------------------------------------------------------------------------------------------------------- */

reg mpt_done_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    mpt_done_reg <= 1'b0;
  end
  else begin
    if (execute_start && !fake_done) begin
      mpt_done_reg <= mpt_done;
    end
    else begin
      if (fake_done) begin
        mpt_done_reg <= 1'b0;
      end
      else begin
        mpt_done_reg <= mpt_done_reg;
      end
    end
  end
end

assign compute_done = (accumulator_done_reg & ((psum_pipeline_stage_mode == 0 && type_accumulator) | (psum_pipeline_stage_mode == 2)))
                    | ((&mpt_done_reg) & ((psum_pipeline_stage_mode == 0 && !type_accumulator)));

reg accumulator_done;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    fma_done_reg         <= 1'b0;
    accumulator_done     <= 1'b0;
    accumulator_done_reg <= 1'b0;
    compute_done_reg     <= 1'b0;
  end
  else begin
    if (execute_start && !fake_done) begin
      if (psum_pipeline_stage_mode == 0 && type_accumulator) begin
        fma_done_reg         <= (&mpt_done_reg);
        accumulator_done     <= fma_done_reg;
        accumulator_done_reg <= accumulator_done;
      end
      else if (psum_pipeline_stage_mode == 0) begin
        accumulator_done_reg <= (&mpt_done);
        fma_done_reg         <= 1'b0;
      end
      else if (psum_pipeline_stage_mode == 2) begin
        fma_done_reg         <= 1'b0;
        accumulator_done_reg <= (&mpt_done);
      end
      else begin
        fma_done_reg         <= 1'b0;
        accumulator_done_reg <= 1'b0;
      end

      if (compute_done) begin
        compute_done_reg <= 1'b1;
      end
      else begin
        compute_done_reg <= 1'b0;
      end
    end
    else begin
      if (fake_done) begin
        fma_done_reg         <= 1'b0;
        accumulator_done_reg <= 1'b0;
        compute_done_reg     <= 1'b0;
      end
      else begin
        fma_done_reg         <= fma_done_reg;
        accumulator_done_reg <= accumulator_done_reg;
        compute_done_reg     <= compute_done_reg;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_write_cnt <= 0;
  end
  else begin
    if (execute_start && (!fake_done)) begin
      if ((psum_width_write_done && psum_height_write_done) || psum_m_tile_write_done) begin
        if (psum_sram_write_cnt == psum_number) begin
          psum_sram_write_cnt <= psum_sram_write_cnt;
        end
        else begin
          psum_sram_write_cnt <= psum_sram_write_cnt + 1;
        end
      end
      else begin
        psum_sram_write_cnt <= psum_sram_write_cnt;
      end
    end
    else begin
      if (fake_done) begin
        psum_sram_write_cnt <= 0;
      end
      else begin
        psum_sram_write_cnt <= psum_sram_write_cnt;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    config_done             <= 1'b0;
    conv_execute_done       <= 1'b0;
    gemm_execute_done       <= 1'b0;
  end
  else begin
    if (execute_start && !fake_done) begin
      if ((!conv_execute_done) && (insn_kind_wire == CONV_EXECUTE_INSN) && psum_width_write_done && psum_height_write_done && (psum_sram_write_cnt == psum_number)) begin
        conv_execute_done <= 1'b1;
      end
      else begin
        conv_execute_done <= 1'b0;
      end

      if ((!gemm_execute_done) && (insn_kind_wire == GEMM_EXECUTE_INSN) && psum_m_tile_write_done && (psum_sram_write_cnt == psum_number)) begin
        gemm_execute_done <= 1'b1;
      end
      else begin
        gemm_execute_done <= gemm_execute_done;
      end
    end
    else begin
      if (fake_done) begin
        conv_execute_done       <= 1'b0;
        gemm_execute_done       <= 1'b0;
      end
    end

    if (insn_valid_reg && insn_kind_wire == PEA_CONFIG_INSN) begin
      config_done <= 1'b1;
    end
    else begin
      config_done <= 1'b0;
    end

  end
end

reg start_level;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    start_level <= 1'b0;
  end
  else begin
    if (work_en) begin
      start_level <= 1'b1;
    end
    else if (done) begin
      start_level <= 1'b0;
    end
    else begin
      start_level <= start_level;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_time <= 32'd0;
  end
  else begin
    if (start_level && enable_prof_counter) begin
      execute_time <= execute_time + 1;
    end
  end
end

endmodule

