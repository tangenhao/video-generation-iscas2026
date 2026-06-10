module vcu(
  clk, rst_n,

  work_en, insn, insn_read, done,

  psum_rvalid, psum_raddr, psum_rdata,
  ifmap_rvalid, ifmap_raddr, ifmap_rdata,
  vcures_rvalid, vcures_raddr, vcures_rdata,
  vcupara_rvalid, vcupara_raddr, vcupara_rdata,

  psum_wvalid, psum_waddr, psum_wdata,
  vcucode_wvalid, vcucode_waddr, vcucode_wdata,
  vculut_wvalid, vculut_waddr, vculut_wdata,
  ofmap_wvalid, ofmap_waddr, ofmap_wdata,
  vcures_wvalid, vcures_waddr, vcures_wdata,
  qact_wvalid, qact_waddr, qact_wdata,
  scale_wvalid, scale_waddr, scale_wdata,

  enable_prof_counter, execute_time
);


parameter PSUM_WIDTH        = 512;
parameter IFMAP_WIDTH       = 512;
parameter VCUCODE_WIDTH     = 64;
parameter VCUPARA_WIDTH     = 512;
parameter VCULUT_WIDTH      = 64;
parameter VCURES_WIDTH      = 512;
parameter OFMAP_WIDTH       = 256;
parameter QACT_WIDTH        = 256;
parameter SCALE_WIDTH       = 512;

parameter PSUM_ADDR_BITS    = 9;
parameter IFMAP_ADDR_BITS   = 9;
parameter VCUPARA_ADDR_BITS = 9;
parameter VCURES_ADDR_BITS  = 9; 
parameter OFMAP_ADDR_BITS   = 12;
parameter QACT_ADDR_BITS    = OFMAP_ADDR_BITS;
parameter SCALE_ADDR_BITS   = 14;
parameter VCUCODE_ADDR_BITS = 7;
parameter VCULUT_ADDR_BITS  = 9;

parameter INSN_WIDTH        = 128;
parameter PARALLELISM       = 32;
parameter DATA_WIDTH        = 16;
parameter VCU_INSN_OPCODE   = 5'd10;
parameter VCU_SERIAL_NUMBER = 3'b000;

localparam VCU_CONFIG_INSN                  = 0;
localparam VCU_EXECUTE_INSN                 = 1;
localparam VCU_TRANSPOSE_INSN               = 8;

localparam IDLE           = 4'b0000;
localparam DATA_PREPARE   = 4'b0001;
localparam OPCODE_PREPARE = 4'b0010;
localparam COMPUTE        = 4'b0011;
localparam CHANGE_PARA    = 4'b0100;
localparam DONE           = 4'b0101;
localparam WRITE          = 4'b0110;
localparam STREAM_READ    = 4'b0111;
localparam STREAM_DRAIN   = 4'b1000;
localparam STREAM_OPCODE_PREPARE = 4'b1010;

localparam ADD = 6'b000001;
localparam MUL = 6'b000010;
localparam FMA = 6'b000011;
localparam COMP_GEQ = 6'b000100;
localparam COMP_LES = 6'b000101;
localparam DIV = 6'b000110;
localparam SQRT = 6'b000111;
localparam REC = 6'b001010;
localparam EXP = 6'b001100;
localparam RSQRT = 6'b001101;
localparam REDUCE_SUM = 6'b010000;
localparam REDUCE_MAX = 6'b010001;
localparam REDUCE_MIN = 6'b010010;
localparam ADD_CONST = 6'b010101;
localparam MUL_CONST = 6'b010110;
localparam DIV_CONST = 6'b010111;
localparam INV = 6'b011000;
localparam ABS = 6'b011001;
localparam FSIWSH = 6'b100100;
localparam FGELU = 6'b100110;
localparam COMP_GRE = 6'b101011;
localparam COMP_LEQ = 6'b101100;

input                                clk;
input                                rst_n;

output reg                           ofmap_wvalid;
output reg   [OFMAP_ADDR_BITS-1:0]   ofmap_waddr;
output reg   [OFMAP_WIDTH-1:0]       ofmap_wdata;

output reg                           psum_rvalid;
output reg   [PSUM_ADDR_BITS-1:0]    psum_raddr;
input        [PSUM_WIDTH-1:0]        psum_rdata;

output reg                           ifmap_rvalid;
output reg   [IFMAP_ADDR_BITS-1:0]   ifmap_raddr;
input        [IFMAP_WIDTH-1:0]       ifmap_rdata;

output reg                           vcures_rvalid;
output reg   [VCURES_ADDR_BITS-1:0]  vcures_raddr;
input        [VCURES_WIDTH-1:0]      vcures_rdata;

output reg                           vcupara_rvalid;
output reg   [VCUPARA_ADDR_BITS-1:0] vcupara_raddr;
input        [VCUPARA_WIDTH-1:0]     vcupara_rdata;

input                                vcucode_wvalid;
input        [VCUCODE_ADDR_BITS-1:0] vcucode_waddr;
input        [VCUCODE_WIDTH-1:0]     vcucode_wdata;

output reg                           psum_wvalid;
output reg   [PSUM_ADDR_BITS-1:0]    psum_waddr;
output reg   [PSUM_WIDTH-1:0]        psum_wdata;

input                                vculut_wvalid;
input        [VCULUT_ADDR_BITS-1:0]  vculut_waddr;
input        [VCULUT_WIDTH-1:0]      vculut_wdata;

input                                work_en;
input        [INSN_WIDTH-1:0]        insn;
output reg                           insn_read;
output                               done;

output reg                           vcures_wvalid;
output reg  [VCURES_ADDR_BITS-1:0]   vcures_waddr;
output reg  [VCURES_WIDTH-1:0]       vcures_wdata;

output reg                           qact_wvalid;
output reg  [QACT_ADDR_BITS-1:0]     qact_waddr;
output reg  [QACT_WIDTH-1:0]         qact_wdata;

output reg                           scale_wvalid;
output reg  [SCALE_ADDR_BITS-1:0]    scale_waddr;
output reg  [SCALE_WIDTH-1:0]        scale_wdata;

input                                enable_prof_counter;
output reg  [31:0]                   execute_time;

reg       insn_valid;
reg [4:0] insn_number;

reg [19:0] func_base_highaddr;
reg        config_done;

reg transpose_start;
reg transpose_done;


wire vcu_execute_done;

reg [2:0]	  psum_data_type;
reg [2:0]	  resadd_para_type;	
reg [2:0]	  data_out_type;
reg [1:0]   data_out_ram;
reg [6:0]	  opcode_number;
reg [6:0]	  opcode_addr;
reg [13:0]  psum_in_addr;
reg [8:0]   ifmap_in_addr;
reg [5:0]   para_in_addr;
reg [12:0]  resadd_in_addr;
reg [13:0]  ram_out_addr;
reg [14:0]  num_data;
reg [8:0]   oc_group; // if add 1 is 5bit
reg [1:0]	  para_func;
reg [13:0]  ram_out_addr_reg;
wire [13:0] ram_out_addr_wire;
reg         psum_addr_hop;
reg         acc_clear;
reg         stream_en;


wire  [DATA_WIDTH*PARALLELISM-1:0] psum_16b;
wire  [DATA_WIDTH*PARALLELISM-1:0] ifmap_16b;
wire  [DATA_WIDTH*PARALLELISM-1:0] resadd_16b;
wire  [DATA_WIDTH*PARALLELISM-1:0] resadd_8b;
wire  [DATA_WIDTH*PARALLELISM-1:0] resadd_4b;

wire  [DATA_WIDTH*PARALLELISM-1:0] psum_format_tran_in;
wire  [DATA_WIDTH*PARALLELISM-1:0] ifmap_format_tran_in;
wire  [DATA_WIDTH*PARALLELISM-1:0] resadd_format_tran_in;

wire  [DATA_WIDTH*PARALLELISM-1:0] psum_int2fp32_out;
wire  [DATA_WIDTH*PARALLELISM-1:0] psum_fp_to_fp32_out;
wire  [DATA_WIDTH*PARALLELISM-1:0] ifmap_int2fp32_out;
wire  [DATA_WIDTH*PARALLELISM-1:0] ifmap_fp_to_fp32_out;
wire  [DATA_WIDTH*PARALLELISM-1:0] ifmap_unused_int2fp32_out;
wire  [DATA_WIDTH*PARALLELISM-1:0] ifmap_unused_fp_to_fp32_out;
wire  [DATA_WIDTH*PARALLELISM-1:0] resadd_int2fp32_out;
wire  [DATA_WIDTH*PARALLELISM-1:0] resadd_fp_to_fp32_out;

wire  [DATA_WIDTH*PARALLELISM-1:0] psum_compute_in;
wire  [DATA_WIDTH*PARALLELISM-1:0] ifmap_compute_in;
wire  [DATA_WIDTH*PARALLELISM-1:0] resadd_compute_in;
wire  [DATA_WIDTH*PARALLELISM-1:0] para_compute_in;
wire  [PSUM_WIDTH-1:0]             psum_rdata_convert_src;
wire  [VCURES_WIDTH-1:0]           vcures_rdata_convert_src;
wire  [VCUPARA_WIDTH-1:0]          vcupara_rdata_convert_src;

reg                                stream_ewise_valid_d;
reg   [DATA_WIDTH*PARALLELISM-1:0] para_compute_in_d;

wire  [DATA_WIDTH*PARALLELISM-1:0] fpu_out;
wire  [DATA_WIDTH*PARALLELISM-1:0] data_out_source;
wire  [16*PARALLELISM-1:0]         result_fp16;
wire  [8*PARALLELISM-1:0]          result_8b_int;
wire  [DATA_WIDTH*PARALLELISM-1:0] vcu_out;
reg  [DATA_WIDTH*PARALLELISM-1:0]  vcu_out_reg;

reg [3:0] current_state;
reg [3:0] next_state;
reg       idle_insn_read_done;
wire      data_prepare_done;
wire      compute_done;
wire      operator_compute_done;
wire      stream_compute_done;
wire      stream_reduce_opcode;
wire      stream_ewise_opcode;
wire      stream_fpu_opcode;
wire      stream_pair_fuse_opcode;
wire      stream_reduce_opcode_0;
wire      stream_reduce_opcode_1;
wire      stream_fpu_opcode_0;
wire      stream_pair_ewise_opcode_0;
wire      stream_execute_done;
wire      stream_ewise_execute_done;
wire      prefetch_all;
wire      stream_reduce_data_valid_d;
wire      stream_ewise_has_sram_source;
wire      stream_ewise_data_valid_d;
wire      stream_ewise_input_rvalid_delay;
wire      stream_input_rvalid_delay;
wire      stream_opcode_first_done;
wire      stream_opcode_second_done;
wire      stream_opcode_need_second;
wire      stream_opcode_second_read_en;

wire ram_read_en;
reg  psum_rvalid_done;
reg  ifmap_rvalid_done;
reg  vcures_rvalid_done;
reg  vcupara_rvalid_done;
reg  vcucode_rvalid_done;
wire opcode_ram_read_en;

reg                          vcucode_rvalid;
reg  [VCUCODE_ADDR_BITS-1:0] vcucode_raddr;
wire [VCUCODE_WIDTH-1:0]     vcucode_rdata;

reg [14:0] para_data_cnt;
reg [1:0]  para_func_cnt;
reg [8:0]  para_oc_group_cnt;
reg [6:0]  operator_count;

reg vcu_execute_psum_sram_valid;
reg vcu_execute_ifmap_sram_valid;
reg vcu_execute_vcures_sram_valid;
reg vcu_execute_vcupara_sram_valid;

reg vcu_execute_psum_sram_rdata_valid;
reg vcu_execute_ifmap_sram_rdata_valid;
reg vcu_execute_vcures_sram_rdata_valid;
reg vcu_execute_vcupara_sram_rdata_valid;

reg psum_sram_rvalid_delay;
reg psum_sram_rvalid_delay_1;
reg ifmap_sram_rvalid_delay;
reg vcures_sram_rvalid_delay;
reg vcupara_sram_rvalid_delay;

wire                         fpu_done;
reg  [31:0]                  loop_times_reg;
reg  [VCUCODE_ADDR_BITS-1:0] ini_addr_reg;
reg  [VCUCODE_ADDR_BITS-1:0] end_addr_reg;
reg  [VCUCODE_ADDR_BITS-1:0] loop_address_reg;

reg [PSUM_WIDTH-1:0]     vcu_execute_psum_rdata_reg;
reg [IFMAP_WIDTH-1:0]    ifmap_rdata_reg;
reg [VCUPARA_WIDTH-1:0]  vcupara_rdata_reg;
reg [VCURES_WIDTH-1:0]   vcures_rdata_reg;
reg [VCUCODE_WIDTH-1:0]  vcucode_rdata_reg;
reg [VCUCODE_WIDTH-1:0]  stream_reduce_opcode_reg;
reg                      stream_opcode_second_pending;
reg                      stream_opcode_second_done_reg;
wire                     opcode_data_update;

wire [PARALLELISM-1:0]       operator_done;
wire [PARALLELISM-1:0]       prefetch;
wire                         change_para;
wire                         read_cross_ocgroup;
wire                         read_cross_ocgroup_flag;
wire                         write_cross_ocgroup;
reg                          write_cross_ocgroup_reg;
wire                         write_cross_ocgroup_flag;
wire [1:0]                   write_cross_ocgroup_sram_id;
reg  [1:0]                   write_cross_ocgroup_sram_id_reg;
wire [2:0]                   write_cross_ocgroup_dtype;
reg  [2:0]                   write_cross_ocgroup_dtype_reg;
wire                         loop_sign;
wire [31:0]                  loop_times;
wire [VCUCODE_ADDR_BITS-1:0] ini_addr;
wire [VCUCODE_ADDR_BITS-1:0] end_addr;
wire [VCUCODE_ADDR_BITS-1:0] loop_address;
wire                         compute_valid;

wire [PSUM_ADDR_BITS-1:0] vcu_execute_psum_sram_raddr_wire;
wire                      vcu_execute_psum_sram_wvalid;
wire [PSUM_ADDR_BITS-1:0] vcu_execute_psum_sram_waddr;
wire [PSUM_WIDTH-1:0]     vcu_execute_psum_sram_wdata;

wire                       vcu_execute_ofmap_sram_wvalid;
wire [OFMAP_ADDR_BITS-1:0] vcu_execute_ofmap_sram_waddr;
wire [OFMAP_WIDTH-1:0]     vcu_execute_ofmap_sram_wdata;

wire                       vcu_execute_qact_sram_wvalid;
wire [QACT_ADDR_BITS-1:0]  vcu_execute_qact_sram_waddr;
wire [QACT_WIDTH-1:0]      vcu_execute_qact_sram_wdata;

wire                       vcu_execute_scale_sram_wvalid;
wire [SCALE_ADDR_BITS-1:0] vcu_execute_scale_sram_waddr;
wire [SCALE_WIDTH-1:0]     vcu_execute_scale_sram_wdata;

reg  out_w_en;

reg loop_sign_reg;
reg vcu_execute_start;
reg [14:0] stream_read_cnt;
reg [14:0] stream_recv_cnt;
reg        stream_reduce_valid;
reg        stream_reduce_first;
reg        stream_reduce_last;
reg        stream_ewise_first_d;
reg        stream_ewise_last_d;
reg [PSUM_WIDTH-1:0] stream_psum_rdata_reg;
reg        stream_psum_rdata_valid_d;
reg        stream_psum_first_d;
reg        stream_psum_last_d;
reg [IFMAP_WIDTH-1:0] stream_ifmap_rdata_reg;
reg        stream_ifmap_rdata_valid_d;
reg [VCURES_WIDTH-1:0] stream_vcures_rdata_reg;
reg        stream_vcures_rdata_valid_d;
reg [VCUPARA_WIDTH-1:0] stream_vcupara_rdata_reg;
reg        stream_vcupara_rdata_valid_d;
reg        stream_result_valid;
reg [DATA_WIDTH*PARALLELISM-1:0] stream_result_reg;
reg [14:0] stream_write_cnt;
wire       stream_ewise_write_fire;
wire [13:0] stream_ewise_write_addr;
wire       stream_read_fire;
wire       stream_read_done;
wire       stream_recv_done;
wire       stream_ewise_valid;
wire       stream_ewise_done;
wire [DATA_WIDTH*PARALLELISM-1:0] stream_ewise_out;
wire       stream_opcode_prepare_done;
wire       stream_reduce_done;
wire [DATA_WIDTH*PARALLELISM-1:0] stream_reduce_data;
wire [DATA_WIDTH*PARALLELISM-1:0] stream_reduce_out;

wire fake_done;
wire vcu_execute_real_done;
assign vcu_execute_real_done = (current_state == DONE) && (next_state == IDLE);
assign fake_done = config_done | transpose_done | vcu_execute_real_done;
assign done = fake_done & (~(|insn_number));

reg [1:0]                transpose_psum_datawidth;
reg [5:0]                transpose_psum_read_number;
reg [5:0]                transpose_psum_internal_sram_write_number;
reg [PSUM_ADDR_BITS-1:0] transpose_psum_write_number;
reg [5:0]                transpose_psum_internal_sram_sel;
reg [5:0]                transpose_psum_internal_sram_sel_delay_1;
reg [5:0]                transpose_psum_internal_sram_sel_delay_2;
reg [5:0]                transpose_psum_internal_read_number;
reg [5:0]                transpose_psum_internal_process_number;
reg                      transpose_psum_internal_read_en;
reg                      transpose_psum_internal_rvalid;
reg                      transpose_psum_internal_rvalid_delay;
reg                      transpose_psum_read_done;
reg                      transpose_psum_read_done_delay_1;
reg                      transpose_psum_read_done_delay_2;
reg [5:0]                transpose_iteration_write_index;

reg                      transpose_psum_sram_rdata_valid;
reg                      transpose_psum_sram_rdata_valid_delay;
reg [DATA_WIDTH-1:0]     transpose_psum_sram_rdata[0:PARALLELISM-1];
reg                      transpose_psum_sram_wvalid;
reg [PSUM_ADDR_BITS-1:0] transpose_psum_sram_waddr;
reg [PSUM_WIDTH-1:0]     transpose_psum_sram_wdata;
reg [PSUM_WIDTH-1:0]     transpose_psum_sram_out_temp;


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_rvalid <= 1'b0;
  end
  else begin
    if (vcu_execute_start && (!fake_done)) begin
      if (stream_read_fire && vcu_execute_psum_sram_valid) begin
        psum_rvalid <= 1'b1;
      end
      else if (ram_read_en && vcu_execute_psum_sram_valid && !stream_en) begin
        psum_rvalid <= 1'b1;
      end
      else if (psum_rvalid) begin
        psum_rvalid <= 'd0;
      end
      else if (data_prepare_done) begin
        psum_rvalid <= 'd0;
      end
      else begin
        psum_rvalid <= psum_rvalid;
      end
    end
    else if (transpose_start && (!fake_done)) begin
      if (transpose_start) begin
        if (transpose_done) begin
          psum_rvalid <= 1'b0;
        end
        else if (!transpose_psum_read_done) begin
          if (transpose_psum_read_number == 31) begin
            psum_rvalid <= 1'b0;
          end
          else begin
            psum_rvalid <= 1'b1;
          end
        end
      end
    end
    else begin
      psum_rvalid <= 1'b0;
    end
  end
end


reg         insn_valid_reg;
reg [127:0] insn_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_raddr <= 0;
  end
  else if (insn_valid_reg) begin
    if (insn_reg[13:10] == VCU_TRANSPOSE_INSN) begin
      psum_raddr <= insn_reg[29:16];
    end
  end
  else begin
    if (transpose_start && (!fake_done)) begin
      if (transpose_start) begin
        if (transpose_done) begin
          psum_raddr  <= 1'b0;
        end
        else if (!transpose_psum_read_done) begin
          if (transpose_psum_read_number == 31) begin
            psum_raddr  <= 1'b0;
          end
          else begin
            if (psum_rvalid) begin
              psum_raddr  <= psum_raddr + 1;
            end
          end
        end
      end
    end
    else if (vcu_execute_start && (!fake_done)) begin
      if (idle_insn_read_done) begin
        psum_raddr <= psum_in_addr;
      end
      else if (stream_read_fire && vcu_execute_psum_sram_valid) begin
        psum_raddr <= psum_in_addr + stream_read_cnt;
      end
      else if (next_state == CHANGE_PARA) begin
        if (change_para) begin
          psum_raddr <= psum_raddr + psum_in_addr;
        end
        else if (read_cross_ocgroup) begin
          if (vcu_execute_psum_sram_valid && read_cross_ocgroup_flag) begin
            psum_raddr <= vcu_execute_psum_sram_raddr_wire + num_data + psum_in_addr;
          end
          else if (vcu_execute_psum_sram_valid) begin
            psum_raddr <= vcu_execute_psum_sram_raddr_wire - 1 + psum_in_addr;
          end
        end
      end
      else begin
        if (psum_rvalid && vcu_execute_psum_sram_valid) begin
          psum_raddr <= vcu_execute_psum_sram_raddr_wire + psum_in_addr;
        end
      end
    end
    else begin
      psum_raddr <= 0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_wvalid <= 1'b0;
    psum_waddr  <= 0;
    psum_wdata  <= 0;
  end
  else begin
    if (vcu_execute_start) begin
      psum_wvalid <= vcu_execute_psum_sram_wvalid;
      psum_waddr  <= vcu_execute_psum_sram_waddr;
      psum_wdata  <= vcu_execute_psum_sram_wdata;
    end
    else if (transpose_start) begin
      psum_wvalid <= transpose_psum_sram_wvalid;
      psum_waddr  <= transpose_psum_sram_waddr;
      psum_wdata  <= transpose_psum_sram_wdata;
    end
    else begin
      psum_wvalid <= 1'b0;
      psum_waddr  <= 0;
      psum_wdata  <= 0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_rvalid <= 1'b0;
  end
  else begin
    if (stream_read_fire && vcu_execute_ifmap_sram_valid) begin
      ifmap_rvalid <= 1'b1;
    end
    else if (ram_read_en && vcu_execute_ifmap_sram_valid && !stream_en) begin
      ifmap_rvalid <= 1'b1;
    end
    else if (ifmap_rvalid) begin
      ifmap_rvalid <= 'd0;
    end
    else if (data_prepare_done) begin
      ifmap_rvalid <= 'd0;
    end
    else begin
      ifmap_rvalid <= ifmap_rvalid;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_raddr <= 0;
  end
  else begin
    if (idle_insn_read_done) begin
      ifmap_raddr <= ifmap_in_addr;
    end
    else if (stream_read_fire && vcu_execute_ifmap_sram_valid) begin
      ifmap_raddr <= ifmap_in_addr + stream_read_cnt[IFMAP_ADDR_BITS-1:0];
    end
    else if (next_state == CHANGE_PARA) begin
      if (change_para) begin
        ifmap_raddr <= ifmap_raddr + ifmap_in_addr;
      end
      else if (read_cross_ocgroup) begin
        if (vcu_execute_ifmap_sram_valid && read_cross_ocgroup_flag) begin
          ifmap_raddr <= vcu_execute_psum_sram_raddr_wire[IFMAP_ADDR_BITS-1:0] + num_data[IFMAP_ADDR_BITS-1:0] + ifmap_in_addr;
        end
        else if (vcu_execute_ifmap_sram_valid) begin
          ifmap_raddr <= vcu_execute_psum_sram_raddr_wire[IFMAP_ADDR_BITS-1:0] - 1'b1 + ifmap_in_addr;
        end
      end
    end
    else begin
      if (ifmap_rvalid && vcu_execute_ifmap_sram_valid) begin
        ifmap_raddr <= vcu_execute_psum_sram_raddr_wire[IFMAP_ADDR_BITS-1:0] + ifmap_in_addr;
      end
    end
  end
end

// assign vcures_rvalid = vcu_execute_vcures_sram_rvalid;
// assign vcures_raddr = vcu_execute_vcures_sram_raddr;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcures_rvalid <= 1'b0;
  end
  else begin
    if (stream_read_fire && vcu_execute_vcures_sram_valid) begin
      vcures_rvalid <= 1'b1;
    end
    else if (ram_read_en && vcu_execute_vcures_sram_valid && !stream_en) begin
      vcures_rvalid <= 1'b1;
    end
    else if (vcures_rvalid) begin
      vcures_rvalid <= 'd0;
    end
    else if (data_prepare_done) begin
      vcures_rvalid <= 'd0;
    end
    else begin
      vcures_rvalid <= vcures_rvalid;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcures_raddr <= 0;
  end
  else begin
    if (idle_insn_read_done) begin
      vcures_raddr  <= resadd_in_addr;   
    end
    else if (stream_read_fire && vcu_execute_vcures_sram_valid) begin
      vcures_raddr <= resadd_in_addr + stream_read_cnt;
    end
    else if (next_state == CHANGE_PARA) begin
      if (change_para) begin
        vcures_raddr  <= vcures_raddr + resadd_in_addr;
      end
      else if (read_cross_ocgroup) begin
        if (vcu_execute_vcures_sram_valid && read_cross_ocgroup_flag) begin
          vcures_raddr <= vcu_execute_psum_sram_raddr_wire + num_data + resadd_in_addr;
        end
        else if (vcu_execute_vcures_sram_valid) begin
          vcures_raddr <= vcu_execute_psum_sram_raddr_wire - 1 + resadd_in_addr;
        end
      end
    end
    else begin
      if (vcures_rvalid && vcu_execute_vcures_sram_valid) begin
        vcures_raddr <= vcu_execute_psum_sram_raddr_wire + resadd_in_addr;
      end
    end
  end
end

// assign vcupara_rvalid = vcu_execute_vcupara_sram_rvalid;
// assign vcupara_raddr = vcu_execute_vcupara_sram_raddr;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcupara_rvalid <= 1'b0;
  end
  else begin
    if (stream_read_fire && vcu_execute_vcupara_sram_valid) begin
      vcupara_rvalid <= 1'b1;
    end
    else if (ram_read_en && vcu_execute_vcupara_sram_valid && !stream_en) begin
      vcupara_rvalid <= 1'b1;
    end
    else if (vcupara_rvalid) begin
      vcupara_rvalid <= 'd0;
    end
    else if (data_prepare_done) begin
      vcupara_rvalid <= 'd0;
    end
    else begin
      vcupara_rvalid <= vcupara_rvalid;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcupara_raddr <= 0;
  end
  else begin
    if (idle_insn_read_done) begin
      vcupara_raddr <= para_in_addr;  // an Instruction is finished 
    end
    else if (stream_read_fire && vcu_execute_vcupara_sram_valid) begin
      vcupara_raddr <= para_in_addr + stream_read_cnt;
    end
    else if (next_state == CHANGE_PARA) begin
      if (change_para) begin
        vcupara_raddr <= (para_func_cnt + 1) * (oc_group + 1) + para_oc_group_cnt + para_in_addr;   //ordered
      end
      else if (read_cross_ocgroup) begin
        if (vcu_execute_vcupara_sram_valid && read_cross_ocgroup_flag) begin
          vcupara_raddr <= (para_func_cnt + 1) * (oc_group + 1) + para_oc_group_cnt + para_in_addr + 1;
        end
        else if (vcu_execute_vcupara_sram_valid) begin
          vcupara_raddr <= (para_func_cnt + 1) * (oc_group + 1) + para_oc_group_cnt + para_in_addr;
        end
      end
    end
    else begin
      if (fpu_done && (para_data_cnt == num_data)) begin
        vcupara_raddr <= para_in_addr + para_oc_group_cnt + 1;
      end
      else if (fpu_done) begin
        vcupara_raddr <= para_in_addr + para_oc_group_cnt;
      end
      else begin
        vcupara_raddr <= vcupara_raddr;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ofmap_wvalid <= 1'b0;
    ofmap_waddr  <= 0;
    ofmap_wdata  <= 0;
  end
  else begin
    if (vcu_execute_start) begin
      ofmap_wvalid <= vcu_execute_ofmap_sram_wvalid;
      ofmap_waddr  <= vcu_execute_ofmap_sram_waddr;
      ofmap_wdata  <= vcu_execute_ofmap_sram_wdata;
    end
    else begin
      ofmap_wvalid <= 1'b0;
      ofmap_waddr  <= 0;
      ofmap_wdata  <= 0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    qact_wvalid <= 1'b0;
    qact_waddr      <= 0;
    qact_wdata  <= 0;
  end
  else begin
    if (vcu_execute_start) begin
      qact_wvalid <= vcu_execute_qact_sram_wvalid;
      qact_waddr      <= vcu_execute_qact_sram_waddr;
      qact_wdata  <= vcu_execute_qact_sram_wdata;
    end
    else begin
      qact_wvalid <= 1'b0;
      qact_waddr      <= 0;
      qact_wdata  <= 0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    scale_wvalid <= 1'b0;
    scale_waddr  <= 0;
    scale_wdata  <= 0;
  end
  else begin
    if (vcu_execute_start) begin
      scale_wvalid <= vcu_execute_scale_sram_wvalid;
      scale_waddr  <= vcu_execute_scale_sram_waddr;
      scale_wdata  <= vcu_execute_scale_sram_wdata;
    end
    else begin
      scale_wvalid <= 1'b0;
      scale_waddr  <= 0;
      scale_wdata  <= 0;
    end
  end
end


/* -------------------------------------------------------------------------------------------------------- */
/*                                            insn number control                                           */
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
      insn_number <= (|insn_reg[9:6]) ? insn_reg[9:6] : insn_number;
    end
    else begin
      if (fake_done && |insn_number) begin
        insn_number <= insn_number - 1;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                insn decode                                               */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_data_type                 <= 'd0;
    resadd_para_type               <= 'd0;	
    data_out_type                  <= 'd0;
    data_out_ram                   <= 'd0;
    opcode_number                  <= 'd0;
    opcode_addr                    <= 'd0;
    psum_in_addr                   <= 'd0;
    ifmap_in_addr                  <= 'd0;
    para_in_addr                   <= 'd0;
    resadd_in_addr                 <= 'd0;
    ram_out_addr                   <= 'd0;
    num_data                       <= 'd0;
    oc_group                       <= 'd0; 
    para_func                      <= 'd0;
    idle_insn_read_done            <= 'd0;
    vcu_execute_start              <= 1'b0;
    vcu_execute_psum_sram_valid    <= 1'b0;
    vcu_execute_ifmap_sram_valid   <= 1'b0;
    vcu_execute_vcures_sram_valid  <= 1'b0;
    vcu_execute_vcupara_sram_valid <= 1'b0;
    psum_addr_hop                  <= 1'b0;
    acc_clear                      <= 1'b0;
    stream_en               <= 1'b0;
  end
  else begin
    if (insn_valid_reg && insn_reg[13:10] == VCU_EXECUTE_INSN) begin 
      psum_data_type                 <= insn_reg[16:14];
      resadd_para_type               <= insn_reg[19:17];	
      data_out_type                  <= insn_reg[22:20];
      data_out_ram                   <= insn_reg[24:23];
      opcode_number                  <= insn_reg[31:25];  //real = +1 limit_line= -1 
      opcode_addr                    <= insn_reg[38:32];
      psum_in_addr                   <= insn_reg[52:39];
      ifmap_in_addr                  <= insn_reg[125:117];
      para_in_addr                   <= insn_reg[58:53];
      resadd_in_addr                 <= insn_reg[71:59];
      ram_out_addr                   <= insn_reg[85:72];
      num_data                       <= insn_reg[99:86];  //real = +1 limit_line= -1 
      oc_group                       <= insn_reg[107:100];  //real = +1 limit_line= -1 
      para_func                      <= insn_reg[109:108];  //real = +1 limit_line= -1
      vcu_execute_psum_sram_valid    <= insn_reg[110];
      vcu_execute_vcures_sram_valid  <= insn_reg[111];
      vcu_execute_vcupara_sram_valid <= insn_reg[112];
      psum_addr_hop                  <= insn_reg[113];
      acc_clear                      <= insn_reg[114];
      stream_en               <= insn_reg[115];
      vcu_execute_ifmap_sram_valid   <= insn_reg[116];
      idle_insn_read_done            <= 1'b1;
      vcu_execute_start              <= 1'b1;
    end
    else if (vcu_execute_real_done ) begin  
      psum_data_type                 <= 'd0;
      resadd_para_type               <= 'd0;	
      data_out_type                  <= 'd0;
      data_out_ram                   <= 'd0;
      opcode_number                  <= 'd0;
      opcode_addr                    <= 'd0;
      psum_in_addr                   <= 'd0;
      ifmap_in_addr                  <= 'd0;
      para_in_addr                   <= 'd0;
      resadd_in_addr                 <= 'd0;
      ram_out_addr                   <= 'd0;
      num_data                       <= 'd0;
      oc_group                       <= 'd0; 
      para_func                      <= 'd0;
      idle_insn_read_done            <= 'd0;
      vcu_execute_start              <= 1'b0;
      vcu_execute_psum_sram_valid    <= 1'b0;
      vcu_execute_ifmap_sram_valid   <= 1'b0;
      vcu_execute_vcures_sram_valid  <= 1'b0;
      vcu_execute_vcupara_sram_valid <= 1'b0;
      psum_addr_hop                  <= 1'b0;
      acc_clear                      <= 1'b0;
      stream_en               <= 1'b0;
    end
    else begin
      psum_data_type                 <= psum_data_type;
      resadd_para_type               <= resadd_para_type;	
      data_out_type                  <= data_out_type;
      data_out_ram                   <= data_out_ram;
      opcode_number                  <= opcode_number;
      opcode_addr                    <= opcode_addr;
      psum_in_addr                   <= psum_in_addr;
      ifmap_in_addr                  <= ifmap_in_addr;
      para_in_addr                   <= para_in_addr;
      resadd_in_addr                 <= resadd_in_addr;
      ram_out_addr                   <= ram_out_addr;
      num_data                       <= num_data;
      oc_group                       <= oc_group; 
      para_func                      <= para_func;
      idle_insn_read_done            <= 'd0;
      vcu_execute_start              <= vcu_execute_start;
      vcu_execute_psum_sram_valid    <= vcu_execute_psum_sram_valid;
      vcu_execute_ifmap_sram_valid   <= vcu_execute_ifmap_sram_valid;
      vcu_execute_vcures_sram_valid  <= vcu_execute_vcures_sram_valid;
      vcu_execute_vcupara_sram_valid <= vcu_execute_vcupara_sram_valid;
      psum_addr_hop                  <= psum_addr_hop;
      acc_clear                      <= acc_clear;
      stream_en               <= stream_en;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    transpose_psum_datawidth <= 2'b0;
    transpose_start          <= 1'b0;
  end
  else begin
    if (insn_valid_reg && insn_reg[13:10] == VCU_TRANSPOSE_INSN) begin
      transpose_psum_datawidth <= insn_reg[15:14];
      transpose_start          <= 1'b1;
    end
    else begin
      transpose_psum_datawidth <= transpose_psum_datawidth;
      if (transpose_done) begin
        transpose_start <= 1'b0;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    func_base_highaddr <= 20'b0;
  end
  else begin
    if (insn_valid_reg && insn_reg[13:10] == VCU_CONFIG_INSN) begin
      func_base_highaddr <= insn_reg[33:14];
    end
    else begin
      func_base_highaddr <= func_base_highaddr;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                done logic                                                */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    config_done <= 1'b0;
  end
  else begin
    if (insn_valid_reg && insn_reg[13:10] == VCU_CONFIG_INSN) begin
      config_done <= 1'b1;
    end
    else if (config_done) begin
      config_done <= 1'b0;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                              transpose logic                                             */
/* -------------------------------------------------------------------------------------------------------- */

reg  [31:0] current_transpose_data;
wire [31:0] transpose_data[0:31];

always @(*) begin
  case(transpose_psum_internal_sram_sel_delay_1)
    5'b00000: current_transpose_data = transpose_data[0];
    5'b00001: current_transpose_data = transpose_data[1];
    5'b00010: current_transpose_data = transpose_data[2];
    5'b00011: current_transpose_data = transpose_data[3];
    5'b00100: current_transpose_data = transpose_data[4];
    5'b00101: current_transpose_data = transpose_data[5];
    5'b00110: current_transpose_data = transpose_data[6];
    5'b00111: current_transpose_data = transpose_data[7];
    5'b01000: current_transpose_data = transpose_data[8];
    5'b01001: current_transpose_data = transpose_data[9];
    5'b01010: current_transpose_data = transpose_data[10];
    5'b01011: current_transpose_data = transpose_data[11];
    5'b01100: current_transpose_data = transpose_data[12];
    5'b01101: current_transpose_data = transpose_data[13];
    5'b01110: current_transpose_data = transpose_data[14];
    5'b01111: current_transpose_data = transpose_data[15];
    5'b10000: current_transpose_data = transpose_data[16];
    5'b10001: current_transpose_data = transpose_data[17];
    5'b10010: current_transpose_data = transpose_data[18];
    5'b10011: current_transpose_data = transpose_data[19];
    5'b10100: current_transpose_data = transpose_data[20];
    5'b10101: current_transpose_data = transpose_data[21];
    5'b10110: current_transpose_data = transpose_data[22];
    5'b10111: current_transpose_data = transpose_data[23];
    5'b11000: current_transpose_data = transpose_data[24];
    5'b11001: current_transpose_data = transpose_data[25];
    5'b11010: current_transpose_data = transpose_data[26];
    5'b11011: current_transpose_data = transpose_data[27];
    5'b11100: current_transpose_data = transpose_data[28];
    5'b11101: current_transpose_data = transpose_data[29];
    5'b11110: current_transpose_data = transpose_data[30];
    5'b11111: current_transpose_data = transpose_data[31];
    default : current_transpose_data = 32'b0;
  endcase
end

genvar transpose_sram_i;
generate
  for (transpose_sram_i = 0; transpose_sram_i < 32; transpose_sram_i = transpose_sram_i + 1) begin: transpose_sram
    sram_32x64 u_sram_32x64(
      .w_clk  ( clk                                                                                           ),
      .w_en   ( transpose_psum_sram_rdata_valid_delay                                                         ),
      .w_addr ( transpose_psum_internal_sram_write_number                                                     ),
      .w_data ( transpose_psum_sram_rdata[transpose_sram_i]                                                   ),
      .r_clk  ( clk                                                                                           ),
      .r_en   ( transpose_psum_internal_read_en && transpose_psum_internal_sram_sel == transpose_sram_i ),
      .r_addr ( transpose_psum_internal_read_number                                                           ),
      .r_data ( transpose_data[transpose_sram_i]                                                              )
    );
  end
endgenerate

wire [PSUM_WIDTH/8-1:0] transposed_wire_4bit;
wire [PSUM_WIDTH/4-1:0] transposed_wire_8bit;
wire [PSUM_WIDTH/2-1:0] transposed_wire_16bit;

genvar t_4bit;
generate
  for (t_4bit = 0; t_4bit < 32; t_4bit = t_4bit + 1) begin : transpose_4bit
    assign transposed_wire_4bit[t_4bit*4+:4] = transpose_psum_sram_out_temp[t_4bit*32+:4];
  end
endgenerate

genvar t_8bit;
generate
  for (t_8bit = 0; t_8bit < 32; t_8bit = t_8bit + 1) begin : transpose_8bit
    assign transposed_wire_8bit[t_8bit*8+:8] = transpose_psum_sram_out_temp[t_8bit*32+:8];
  end
endgenerate

genvar t_16bit;
generate
  for (t_16bit = 0; t_16bit < 32; t_16bit = t_16bit + 1) begin : transpose_16bit
    assign transposed_wire_16bit[t_16bit*16+:16] = transpose_psum_sram_out_temp[t_16bit*32+:16];
  end
endgenerate

integer transpose_read_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    transpose_psum_sram_rdata_valid             <= 1'b0;
    transpose_psum_sram_rdata_valid_delay       <= 1'b0;
    transpose_psum_read_number                  <= 1'b0;
    transpose_psum_internal_sram_write_number   <= 1'b0;
    transpose_psum_read_done                    <= 1'b0;
    transpose_psum_read_done_delay_1            <= 1'b0;
    transpose_psum_read_done_delay_2            <= 1'b0;
    for (transpose_read_i = 0; transpose_read_i < 32; transpose_read_i = transpose_read_i + 1) begin
      transpose_psum_sram_rdata[transpose_read_i] <= 32'b0;
    end
  end
  else begin
    transpose_psum_read_done_delay_1 <= transpose_psum_read_done;
    transpose_psum_read_done_delay_2 <= transpose_psum_read_done_delay_1;
    if (transpose_start) begin
      if (transpose_done) begin
        transpose_psum_read_number <= 1'b0;
        transpose_psum_read_done   <= 1'b0;
      end
      else if (!transpose_psum_read_done) begin
        if (transpose_psum_read_number == 31) begin
          transpose_psum_read_number <= 1'b0;
          transpose_psum_read_done   <= 1'b1;
        end
        else begin
          if (psum_rvalid) begin
            transpose_psum_read_number <= transpose_psum_read_number + 1;
          end
        end
      end
    end

    if (transpose_start) begin
      if (transpose_done) begin
        transpose_psum_internal_sram_write_number <= 1'b0;
      end
      else if (!transpose_psum_read_done_delay_2) begin
        if (transpose_psum_internal_sram_write_number == 31) begin
          transpose_psum_internal_sram_write_number <= 1'b0;
        end
        else begin
          if (transpose_psum_sram_rdata_valid_delay) begin
            transpose_psum_internal_sram_write_number <= transpose_psum_internal_sram_write_number + 1;
          end
        end
      end
    end

    if (psum_sram_rvalid_delay) begin
      transpose_psum_sram_rdata_valid <= 1'b1;
    end
    else begin
      transpose_psum_sram_rdata_valid <= 1'b0;
    end

    transpose_psum_sram_rdata_valid_delay <= transpose_psum_sram_rdata_valid;

    if (transpose_psum_sram_rdata_valid) begin
      for (transpose_read_i = 0; transpose_read_i < 32; transpose_read_i = transpose_read_i + 1) begin
        if (transpose_psum_datawidth == 3) begin
          transpose_psum_sram_rdata[transpose_read_i] <= psum_rdata[transpose_read_i*32+:32];
        end
        else if (transpose_psum_datawidth == 2) begin
          transpose_psum_sram_rdata[transpose_read_i] <= {16'd0, psum_rdata[transpose_read_i*16+:16]};
        end
        else if (transpose_psum_datawidth == 1) begin
          transpose_psum_sram_rdata[transpose_read_i] <= {24'd0, psum_rdata[transpose_read_i*8+:8]};
        end
        else if (transpose_psum_datawidth == 0) begin
          transpose_psum_sram_rdata[transpose_read_i] <= {28'd0, psum_rdata[transpose_read_i*4+:4]};
        end
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    transpose_iteration_write_index <= 6'b0;
  end
  else begin
    if (transpose_done) begin
      transpose_iteration_write_index <= 6'b0;
    end
    else if (transpose_start) begin
      if (transpose_psum_sram_rdata_valid) begin
        if (transpose_iteration_write_index == 31) begin
          transpose_iteration_write_index <= 6'b0;
        end
        else begin
          transpose_iteration_write_index <= transpose_iteration_write_index + 1;
        end
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    transpose_psum_sram_wdata                    <= 0;
    transpose_psum_sram_waddr                    <= 1'b0;
    transpose_psum_sram_wvalid                   <= 1'b0;
    transpose_psum_internal_sram_sel             <= 1'b0;
    transpose_psum_internal_sram_sel_delay_1       <= 1'b0;
    transpose_psum_internal_sram_sel_delay_2 <= 1'b0;
    transpose_psum_internal_read_number          <= 'd0;
    transpose_psum_internal_process_number       <= 'd0;
    transpose_psum_internal_read_en              <= 'd0;
    transpose_psum_internal_rvalid               <= 'd0;
    transpose_psum_internal_rvalid_delay         <= 'd0;
    transpose_psum_sram_out_temp                 <= 0;
  end
  else if (insn_valid_reg) begin
    if (insn_reg[13:10] == VCU_TRANSPOSE_INSN) begin
      transpose_psum_sram_waddr <= insn_reg[43:30];
    end
  end
  else begin
    transpose_psum_internal_rvalid           <= transpose_psum_internal_read_en;
    transpose_psum_internal_rvalid_delay     <= transpose_psum_internal_rvalid;
    transpose_psum_internal_sram_sel_delay_1 <= transpose_psum_internal_sram_sel;
    transpose_psum_internal_sram_sel_delay_2 <= transpose_psum_internal_sram_sel_delay_1;
    if (transpose_start && !transpose_done) begin
      if (transpose_psum_read_done_delay_1) begin
        if (transpose_psum_write_number == 31 && transpose_psum_sram_wvalid) begin
          transpose_psum_internal_read_en <= 1'b0;
          transpose_psum_sram_wvalid      <= 1'b0;
          transpose_psum_sram_wdata       <= 0;
          transpose_psum_sram_out_temp    <= 0;
        end
        else begin
          transpose_psum_internal_read_en <= 1'b1;
          if (transpose_psum_internal_process_number == 31 && transpose_psum_internal_rvalid_delay) begin
            transpose_psum_sram_wvalid <= 1'b1;
            if (transpose_psum_datawidth == 0) begin
              transpose_psum_sram_wdata <= {1792'd0, transposed_wire_4bit};
            end
            else if (transpose_psum_datawidth == 1) begin
              transpose_psum_sram_wdata <= {896'd0, transposed_wire_8bit};
            end
            else if (transpose_psum_datawidth == 2) begin
              transpose_psum_sram_wdata <= {512'd0, transposed_wire_16bit};
            end
            else if (transpose_psum_datawidth == 3) begin
              transpose_psum_sram_wdata <= transpose_psum_sram_out_temp;
            end
            transpose_psum_internal_process_number <= 0;
          end
          else if (transpose_psum_internal_rvalid_delay) begin
            transpose_psum_sram_wvalid             <= 1'b0;
            transpose_psum_internal_process_number <= transpose_psum_internal_process_number + 1;
          end

          if (transpose_psum_internal_rvalid) begin
            transpose_psum_sram_out_temp <= {current_transpose_data, transpose_psum_sram_out_temp[PSUM_WIDTH-1:32]};
          end
        end
      end

      if (transpose_psum_read_done_delay_2) begin
        if (transpose_psum_internal_read_number == 31) begin
          transpose_psum_internal_read_number <= 0;
          transpose_psum_internal_sram_sel <= transpose_psum_internal_sram_sel + 1;
        end
        else begin
          transpose_psum_internal_read_number <= transpose_psum_internal_read_number + 1;
        end
      end

      if (transpose_psum_sram_wvalid) begin
        transpose_psum_sram_waddr <= transpose_psum_sram_waddr + 1;
      end
    end
    else begin
      if (transpose_done) begin
        transpose_psum_sram_wvalid <= 1'b0;
        transpose_psum_sram_wdata  <= 0;
        transpose_psum_sram_out_temp <= 0;
        transpose_psum_internal_read_en <= 1'b0;
        transpose_psum_internal_sram_sel <= 1'b0;
        transpose_psum_internal_process_number <= 0;
        transpose_psum_internal_read_number <= 0;
        transpose_psum_sram_waddr <= 1'b0;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    transpose_done <= 1'b0;
    transpose_psum_write_number <= 0;
  end
  else begin
    if (transpose_start && transpose_psum_write_number == 31 && transpose_psum_sram_wvalid) begin
      transpose_done <= 1'b1;
      transpose_psum_write_number <= 0;
    end
    else begin
      transpose_done <= 1'b0;
      if (transpose_psum_sram_wvalid) begin
        transpose_psum_write_number <= transpose_psum_write_number + 1;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                             vcu execute logic                                            */
/* -------------------------------------------------------------------------------------------------------- */

// data_initialization --------------------------------------------------------------------------

assign psum_compute_in    = vcu_execute_psum_rdata_reg;
assign ifmap_compute_in   = ifmap_rdata_reg;
assign resadd_compute_in  = vcures_rdata_reg;
assign para_compute_in    = (stream_ewise_opcode || stream_pair_fuse_opcode) ? stream_vcupara_rdata_reg : vcupara_rdata_reg;
assign stream_reduce_data = (vcu_execute_psum_sram_valid   ) ? psum_compute_in   :
                            (vcu_execute_vcures_sram_valid ) ? resadd_compute_in : 
                            (vcu_execute_vcupara_sram_valid) ? para_compute_in   : 
                            (vcu_execute_ifmap_sram_valid  ) ? ifmap_compute_in   :'d0;


// result unification---------------------------------------------------------------------------------------------
wire [DATA_WIDTH*PARALLELISM-1:0] data_out_convert_source;
assign data_out_source = stream_execute_done ? stream_reduce_out : (stream_ewise_write_fire ? stream_ewise_out : fpu_out);
assign data_out_convert_source = vcu_execute_start ? data_out_source : 'd0;

wire [2:0] real_data_out_type;
assign real_data_out_type = write_cross_ocgroup ? write_cross_ocgroup_dtype : data_out_type;

genvar j ;
generate 
for(j=0;j<PARALLELISM;j=j+1) begin: result_data_format_trans
    data_out_convert u_data_out_convert(
      .fpu_out_fp16        ( data_out_convert_source[16*(j+1)-1:16*j] ),
      .result_8b_int       ( result_8b_int[8*(j+1)-1:8*j]             ),
      .fpu_out_fp16_direct ( result_fp16[16*(j+1)-1:16*j]             )
    );
  end
endgenerate

wire real_data_out_int8;
assign real_data_out_int8 = real_data_out_type == 3'd1;

assign vcu_out = (((next_state == WRITE) || (next_state == DONE)) || stream_ewise_write_fire) ?
                 (real_data_out_int8 ? {{(DATA_WIDTH*PARALLELISM - 8*PARALLELISM){1'b0}}, result_8b_int} : result_fp16) :
                 'd0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcu_out_reg <= 'd0;
  end
  else begin
    if ((next_state == WRITE) || (next_state == DONE) || stream_ewise_write_fire) begin
      vcu_out_reg <= vcu_out;
    end
    else begin
      vcu_out_reg <= vcu_out_reg;
    end
  end
end

//FSM---------------------------------------------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    current_state <= IDLE;
  end
  else begin
    current_state <= next_state;
  end
end

always @(*) begin
  case (current_state)
    IDLE: begin
      if (idle_insn_read_done && stream_en) begin
        next_state = STREAM_OPCODE_PREPARE;
      end
      else if (idle_insn_read_done) begin
        next_state = DATA_PREPARE;
      end
      else begin
        next_state = IDLE;
      end
    end 

    DATA_PREPARE: begin
      if (data_prepare_done) begin
        next_state = COMPUTE;
      end
      else begin
        next_state = DATA_PREPARE;
      end
    end

    OPCODE_PREPARE: begin
      next_state = COMPUTE;
    end

    COMPUTE: begin 
      if (vcu_execute_done) begin
        next_state = DONE;
      end
      else if (fpu_done | write_cross_ocgroup) begin
        next_state = WRITE;
      end
      else if (change_para | read_cross_ocgroup) begin
        next_state = CHANGE_PARA;
      end
      else if (compute_done) begin
        next_state = OPCODE_PREPARE;
      end
      else begin
        next_state = COMPUTE;
      end
    end

    CHANGE_PARA: begin
      next_state = DATA_PREPARE;
    end

    DONE: begin 
      next_state = IDLE;
    end

    WRITE: begin
      if (!write_cross_ocgroup_reg) begin
        next_state = DATA_PREPARE;
      end
      else begin
        next_state = COMPUTE;
      end
    end

    STREAM_OPCODE_PREPARE: begin
      if (stream_opcode_prepare_done) begin
        next_state = STREAM_READ;
      end
      else begin
        next_state = STREAM_OPCODE_PREPARE;
      end
    end

    STREAM_READ: begin
      if (stream_read_done) begin
        next_state = STREAM_DRAIN;
      end
      else begin
        next_state = STREAM_READ;
      end
    end

    STREAM_DRAIN: begin
      if (stream_execute_done || stream_ewise_execute_done) begin
        next_state = DONE;
      end
      else begin
        next_state = STREAM_DRAIN;
      end
    end

    default: begin
      next_state = IDLE;
    end
  endcase
end


//ram_read--------------------------------------------------------------------------------------

// assign ram_read_en = ((state!=DATA_PREPARE) & (next_state==DATA_PREPARE) & (state != CHANGE_PARA)); 
assign ram_read_en = (current_state !=DATA_PREPARE) & (next_state==DATA_PREPARE); 
assign stream_read_fire = (current_state == STREAM_READ) && (stream_read_cnt <= num_data);
assign stream_read_done = (current_state == STREAM_READ) && (stream_read_cnt == num_data + 1'b1);
assign stream_reduce_data_valid_d = (vcu_execute_psum_sram_valid && stream_psum_rdata_valid_d) ||
                                    (!vcu_execute_psum_sram_valid && vcu_execute_vcures_sram_valid && stream_vcures_rdata_valid_d) ||
                                    (!vcu_execute_psum_sram_valid && !vcu_execute_vcures_sram_valid && vcu_execute_vcupara_sram_valid && stream_vcupara_rdata_valid_d) ||
                                    (!vcu_execute_psum_sram_valid && !vcu_execute_vcures_sram_valid && !vcu_execute_vcupara_sram_valid && vcu_execute_ifmap_sram_valid && stream_ifmap_rdata_valid_d);
assign stream_ewise_has_sram_source = vcu_execute_psum_sram_valid || vcu_execute_ifmap_sram_valid ||
                                      vcu_execute_vcures_sram_valid || vcu_execute_vcupara_sram_valid;
assign stream_ewise_data_valid_d = stream_ewise_has_sram_source &&
                                   (!vcu_execute_psum_sram_valid || stream_psum_rdata_valid_d) &&
                                   (!vcu_execute_ifmap_sram_valid || stream_ifmap_rdata_valid_d) &&
                                   (!vcu_execute_vcures_sram_valid || stream_vcures_rdata_valid_d) &&
                                   (!vcu_execute_vcupara_sram_valid || stream_vcupara_rdata_valid_d);
assign stream_ewise_input_rvalid_delay = (vcu_execute_psum_sram_valid && psum_sram_rvalid_delay) ||
                                         (vcu_execute_ifmap_sram_valid && ifmap_sram_rvalid_delay) ||
                                         (vcu_execute_vcures_sram_valid && vcures_sram_rvalid_delay) ||
                                         (vcu_execute_vcupara_sram_valid && vcupara_sram_rvalid_delay);
assign stream_input_rvalid_delay = stream_reduce_opcode ? ((vcu_execute_psum_sram_valid && psum_sram_rvalid_delay) ||
                                                           (!vcu_execute_psum_sram_valid && vcu_execute_vcures_sram_valid && vcures_sram_rvalid_delay) ||
                                                           (!vcu_execute_psum_sram_valid && !vcu_execute_vcures_sram_valid && vcu_execute_vcupara_sram_valid && vcupara_sram_rvalid_delay) ||
                                                           (!vcu_execute_psum_sram_valid && !vcu_execute_vcures_sram_valid && !vcu_execute_vcupara_sram_valid && vcu_execute_ifmap_sram_valid && ifmap_sram_rvalid_delay)) :
                                  stream_ewise_input_rvalid_delay;
assign stream_recv_done = (stream_reduce_opcode || stream_pair_fuse_opcode) && (stream_recv_cnt == num_data + 1'b1);
assign stream_ewise_valid = (stream_ewise_opcode || stream_pair_fuse_opcode) && stream_ewise_data_valid_d;
assign stream_ewise_write_fire = stream_ewise_opcode && stream_ewise_done;
assign stream_ewise_write_addr = ram_out_addr + stream_write_cnt;
assign stream_ewise_execute_done = stream_ewise_opcode && stream_ewise_write_fire && (stream_write_cnt == num_data);
assign stream_opcode_need_second = stream_en && (opcode_number == 2);
assign stream_opcode_first_done = (current_state == STREAM_OPCODE_PREPARE) && vcucode_rvalid_done && !stream_opcode_second_pending;
assign stream_opcode_second_done = (current_state == STREAM_OPCODE_PREPARE) && vcucode_rvalid_done && stream_opcode_second_pending;
assign stream_opcode_second_read_en = stream_opcode_first_done && stream_opcode_need_second && !stream_opcode_second_done_reg;
assign stream_opcode_prepare_done = stream_opcode_need_second ? stream_opcode_second_done :
                                                               ((current_state == STREAM_OPCODE_PREPARE) && vcucode_rvalid_done);
assign data_prepare_done = (((psum_rvalid_done && vcu_execute_psum_sram_valid) || (!vcu_execute_psum_sram_valid)) || (stream_en && stream_result_valid)) &&
                           ((ifmap_rvalid_done && vcu_execute_ifmap_sram_valid) || !(vcu_execute_ifmap_sram_valid)) &&
                           ((vcures_rvalid_done && vcu_execute_vcures_sram_valid) || !(vcu_execute_vcures_sram_valid)) &&
                           ((vcupara_rvalid_done && vcu_execute_vcupara_sram_valid) || (!vcu_execute_vcupara_sram_valid)) && vcucode_rvalid_done;
// assign opcode_ram_read_en = ((current_state != DATA_PREPARE) & (next_state == DATA_PREPARE) & (state != CHANGE_PARA) ) | prefetch_all;
assign opcode_ram_read_en = (((current_state != DATA_PREPARE) & (next_state == DATA_PREPARE)) |
                             ((current_state != STREAM_OPCODE_PREPARE) & (next_state == STREAM_OPCODE_PREPARE)) |
                             stream_opcode_second_read_en) |
                             prefetch_all;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    stream_read_cnt        <= 'd0;
    stream_recv_cnt        <= 'd0;
    stream_reduce_valid    <= 1'b0;
    stream_reduce_first    <= 1'b0;
    stream_reduce_last     <= 1'b0;
    stream_psum_rdata_reg  <= 'd0;
    stream_psum_rdata_valid_d <= 1'b0;
    stream_psum_first_d    <= 1'b0;
    stream_psum_last_d     <= 1'b0;
    stream_ifmap_rdata_reg <= 'd0;
    stream_ifmap_rdata_valid_d <= 1'b0;
    stream_vcures_rdata_reg <= 'd0;
    stream_vcures_rdata_valid_d <= 1'b0;
    stream_vcupara_rdata_reg <= 'd0;
    stream_vcupara_rdata_valid_d <= 1'b0;
    stream_result_valid    <= 1'b0;
    stream_result_reg      <= 'd0;
    stream_write_cnt       <= 'd0;
  end
  else if (!vcu_execute_start || vcu_execute_real_done) begin
    stream_read_cnt        <= 'd0;
    stream_recv_cnt        <= 'd0;
    stream_reduce_valid    <= 1'b0;
    stream_reduce_first    <= 1'b0;
    stream_reduce_last     <= 1'b0;
    stream_psum_rdata_reg  <= 'd0;
    stream_psum_rdata_valid_d <= 1'b0;
    stream_psum_first_d    <= 1'b0;
    stream_psum_last_d     <= 1'b0;
    stream_ifmap_rdata_reg <= 'd0;
    stream_ifmap_rdata_valid_d <= 1'b0;
    stream_vcures_rdata_reg <= 'd0;
    stream_vcures_rdata_valid_d <= 1'b0;
    stream_vcupara_rdata_reg <= 'd0;
    stream_vcupara_rdata_valid_d <= 1'b0;
    stream_result_valid    <= 1'b0;
    stream_result_reg      <= 'd0;
    stream_write_cnt       <= 'd0;
  end
  else begin
    stream_reduce_valid <= stream_reduce_opcode && stream_reduce_data_valid_d;
    stream_reduce_first <= stream_psum_first_d;
    stream_reduce_last  <= stream_psum_last_d;
    stream_psum_rdata_valid_d <= 1'b0;
    stream_psum_first_d <= 1'b0;
    stream_psum_last_d  <= 1'b0;
    stream_ifmap_rdata_valid_d <= 1'b0;
    stream_vcures_rdata_valid_d <= 1'b0;
    stream_vcupara_rdata_valid_d <= 1'b0;
    if (stream_read_fire) begin
      stream_read_cnt <= stream_read_cnt + 1'b1;
    end

    if ((stream_reduce_opcode || stream_ewise_opcode || stream_pair_fuse_opcode) && psum_sram_rvalid_delay) begin
      stream_psum_rdata_reg     <= psum_rdata;
      stream_psum_rdata_valid_d <= 1'b1;
    end

    if ((stream_reduce_opcode || stream_ewise_opcode || stream_pair_fuse_opcode) && vcu_execute_ifmap_sram_valid && ifmap_sram_rvalid_delay) begin
      stream_ifmap_rdata_reg     <= ifmap_rdata;
      stream_ifmap_rdata_valid_d <= 1'b1;
    end

    if ((stream_reduce_opcode || stream_ewise_opcode || stream_pair_fuse_opcode) && vcu_execute_vcures_sram_valid && vcures_sram_rvalid_delay) begin
      stream_vcures_rdata_reg     <= vcures_rdata;
      stream_vcures_rdata_valid_d <= 1'b1;
    end

    if ((stream_reduce_opcode || stream_ewise_opcode || stream_pair_fuse_opcode) && vcu_execute_vcupara_sram_valid && vcupara_sram_rvalid_delay) begin
      stream_vcupara_rdata_reg     <= vcupara_rdata;
      stream_vcupara_rdata_valid_d <= 1'b1;
    end

    if ((stream_reduce_opcode || stream_ewise_opcode || stream_pair_fuse_opcode) && stream_input_rvalid_delay) begin
      stream_psum_first_d <= acc_clear && (stream_recv_cnt == 0);
      stream_psum_last_d  <= (stream_recv_cnt == num_data);
      stream_recv_cnt     <= stream_recv_cnt + 1'b1;
    end

    if (stream_ewise_done) begin
      stream_write_cnt             <= stream_write_cnt + 1'b1;
    end

    if (stream_compute_done) begin
      stream_result_valid <= 1'b1;
      stream_result_reg   <= stream_reduce_out;
    end
    else if (operator_compute_done && !stream_compute_done) begin
      stream_result_valid <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_rvalid_done <= 'd0;
  end
  else begin
    if( ram_read_en && vcu_execute_psum_sram_valid ) begin
      psum_rvalid_done <= 'd0;
    end
    else if (psum_rvalid) begin
      psum_rvalid_done <= 'd1;
    end
    else if (data_prepare_done) begin
      psum_rvalid_done <= 'd0;
    end
    else begin
      psum_rvalid_done <= psum_rvalid_done;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_rvalid_done <= 'd0;
  end
  else begin
    if( ram_read_en && vcu_execute_ifmap_sram_valid ) begin
      ifmap_rvalid_done <= 'd0;
    end
    else if (ifmap_rvalid) begin
      ifmap_rvalid_done <= 'd1;
    end
    else if (data_prepare_done) begin
      ifmap_rvalid_done <= 'd0;
    end
    else begin
      ifmap_rvalid_done <= ifmap_rvalid_done;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcures_rvalid_done <= 'd0;
  end
  else begin
    if( ram_read_en && vcu_execute_vcures_sram_valid ) begin
      vcures_rvalid_done <= 'd0;
    end
    else if (vcures_rvalid) begin
      vcures_rvalid_done <= 'd1;
    end
    else if (data_prepare_done) begin
      vcures_rvalid_done <= 'd0;
    end
    else begin
      vcures_rvalid_done <= vcures_rvalid_done;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcupara_rvalid_done <= 'd0;
  end
  else begin
    if( ram_read_en && vcu_execute_vcupara_sram_valid ) begin
      vcupara_rvalid_done <= 'd0;
    end
    else if (vcupara_rvalid) begin
      vcupara_rvalid_done <= 'd1;
    end
    else if (data_prepare_done) begin
      vcupara_rvalid_done <= 'd0;
    end
    else begin
      vcupara_rvalid_done <= vcupara_rvalid_done;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcucode_rvalid      <= 'd0;
    vcucode_rvalid_done <= 'd0;
  end
  else begin
    if (opcode_ram_read_en && (!write_cross_ocgroup)) begin
      vcucode_rvalid      <= 1'b1;
      vcucode_rvalid_done <= 'd0;
    end
    else if (vcucode_rvalid) begin
      vcucode_rvalid      <= 'd0;
      vcucode_rvalid_done <= 'd1;
    end
    else if (data_prepare_done) begin
      vcucode_rvalid      <= 'd0;
      vcucode_rvalid_done <= 'd0;
    end
    else begin
      vcucode_rvalid      <= vcucode_rvalid;
      vcucode_rvalid_done <= vcucode_rvalid_done;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    stream_opcode_second_pending  <= 1'b0;
    stream_opcode_second_done_reg <= 1'b0;
  end
  else if (!vcu_execute_start || vcu_execute_real_done) begin
    stream_opcode_second_pending  <= 1'b0;
    stream_opcode_second_done_reg <= 1'b0;
  end
  else begin
    if ((current_state != STREAM_OPCODE_PREPARE) && (next_state == STREAM_OPCODE_PREPARE)) begin
      stream_opcode_second_pending  <= 1'b0;
      stream_opcode_second_done_reg <= 1'b0;
    end
    else if (stream_opcode_second_read_en) begin
      stream_opcode_second_pending <= 1'b1;
    end
    else if (stream_opcode_second_done) begin
      stream_opcode_second_pending  <= 1'b0;
      stream_opcode_second_done_reg <= 1'b1;
    end
  end
end

//address update--------------------------------------------------------------------
assign stream_reduce_opcode_0 = (vcucode_rdata_reg[5:0] == REDUCE_SUM) ||
                                (vcucode_rdata_reg[5:0] == REDUCE_MAX) ||
                                (vcucode_rdata_reg[5:0] == REDUCE_MIN);
assign stream_reduce_opcode_1 = (stream_reduce_opcode_reg[5:0] == REDUCE_SUM) ||
                                (stream_reduce_opcode_reg[5:0] == REDUCE_MAX) ||
                                (stream_reduce_opcode_reg[5:0] == REDUCE_MIN);
assign stream_fpu_opcode_0 = (vcucode_rdata_reg[5:0] == ADD) || (vcucode_rdata_reg[5:0] == MUL) || (vcucode_rdata_reg[5:0] == FMA) ||
                           (vcucode_rdata_reg[5:0] == COMP_GEQ) || (vcucode_rdata_reg[5:0] == COMP_LES) ||
                           (vcucode_rdata_reg[5:0] == COMP_GRE) || (vcucode_rdata_reg[5:0] == COMP_LEQ) ||
                           (vcucode_rdata_reg[5:0] == DIV) || (vcucode_rdata_reg[5:0] == SQRT) ||
                           (vcucode_rdata_reg[5:0] == REC) || (vcucode_rdata_reg[5:0] == EXP) ||
                           (vcucode_rdata_reg[5:0] == RSQRT) || (vcucode_rdata_reg[5:0] == ADD_CONST) ||
                           (vcucode_rdata_reg[5:0] == MUL_CONST) || (vcucode_rdata_reg[5:0] == DIV_CONST) ||
                           (vcucode_rdata_reg[5:0] == INV) || (vcucode_rdata_reg[5:0] == ABS) ||
                           (vcucode_rdata_reg[5:0] == FSIWSH) || (vcucode_rdata_reg[5:0] == FGELU);
assign stream_pair_ewise_opcode_0 = (vcucode_rdata_reg[5:0] == MUL) ||
                                    (vcucode_rdata_reg[5:0] == INV) ||
                                    (vcucode_rdata_reg[5:0] == ABS);
assign stream_fpu_opcode = stream_fpu_opcode_0;
assign stream_pair_fuse_opcode = stream_en && stream_opcode_second_done_reg && stream_pair_ewise_opcode_0 && stream_reduce_opcode_1;
assign stream_reduce_opcode = stream_en && !stream_pair_fuse_opcode && stream_reduce_opcode_0;
assign stream_ewise_opcode = stream_en && !stream_pair_fuse_opcode && stream_fpu_opcode && !stream_reduce_opcode_0;
assign stream_compute_done = stream_recv_done && stream_reduce_done;
assign compute_done = stream_reduce_opcode ? stream_compute_done :
                      stream_pair_fuse_opcode ? stream_compute_done :
                      stream_ewise_opcode ? stream_ewise_execute_done :
                      operator_compute_done;
assign fpu_done = stream_execute_done || stream_ewise_execute_done || (compute_done & (operator_count == opcode_number - 1));
assign stream_execute_done = (stream_reduce_opcode || stream_pair_fuse_opcode) && stream_compute_done;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    loop_sign_reg <= 'd0;
  end
  else begin
    if (loop_sign) begin
      loop_sign_reg <= 1'b1;
    end
    else if ((vcucode_raddr == end_addr_reg + 1) && (~(|loop_times_reg))) begin
      loop_sign_reg <= 'd0;
    end
    else begin
      loop_sign_reg <= loop_sign_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcucode_raddr    <= 'd0;
    loop_times_reg   <= 'd0;
    ini_addr_reg     <= 'd0;
    end_addr_reg     <= 'd0;
    loop_address_reg <= 'd0;
  end
  else begin
    if(idle_insn_read_done | fpu_done) begin
      vcucode_raddr    <= opcode_addr; //insn[35:29]
      loop_times_reg   <= 'd0;
      ini_addr_reg     <= 'd0;
      end_addr_reg     <= 'd0;
      loop_address_reg <= 'd0;
    end
    else if (loop_sign) begin
      vcucode_raddr    <= ini_addr;
      loop_times_reg   <= loop_times;
      ini_addr_reg     <= ini_addr;
      end_addr_reg     <= end_addr;
      loop_address_reg <= loop_address;
    end
    else if ((vcucode_raddr == end_addr_reg + 1) && (~(|loop_times_reg)) && loop_sign_reg) begin
      vcucode_raddr    <= loop_address_reg + 1;
      loop_times_reg   <= 'd0;
      ini_addr_reg     <= 'd0;
      end_addr_reg     <= 'd0;
      loop_address_reg <= 'd0;
    end
    else if ((vcucode_raddr == end_addr_reg + 1) && loop_sign_reg) begin// pay attention to the period
      vcucode_raddr    <= ini_addr_reg;
      loop_times_reg   <= loop_times_reg - 1;
      ini_addr_reg     <= ini_addr_reg;
      end_addr_reg     <= end_addr_reg;
      loop_address_reg <= loop_address_reg;
    end
    else if (vcucode_rvalid || write_cross_ocgroup) begin
      vcucode_raddr    <= vcucode_raddr + 1;
      ini_addr_reg     <= ini_addr_reg;
      end_addr_reg     <= end_addr_reg;
      loop_address_reg <= loop_address_reg;
    end
    else begin
      vcucode_raddr    <= vcucode_raddr;
      ini_addr_reg     <= ini_addr_reg;
      end_addr_reg     <= end_addr_reg;
      loop_address_reg <= loop_address_reg;
    end
  end
end

assign vcu_execute_psum_sram_raddr_wire = (para_data_cnt + 1) + para_oc_group_cnt * (num_data + 1);

assign ram_out_addr_wire = para_data_cnt + para_oc_group_cnt * (num_data + 1) + ram_out_addr;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ram_out_addr_reg <= 'd0;
  end
  else begin
    if (idle_insn_read_done) begin
      ram_out_addr_reg <= ram_out_addr;
    end
    else begin
      if (write_cross_ocgroup && write_cross_ocgroup_flag) begin
        ram_out_addr_reg <= ram_out_addr_wire + num_data + 1;
      end
      else begin
        ram_out_addr_reg <= ram_out_addr_wire;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    operator_count <= 'd0;
  end
  else begin
    if(operator_count < opcode_number) begin
      if((compute_done & (~loop_sign_reg))) begin
        operator_count <= operator_count + 1;
      end
      else begin
        operator_count <= operator_count;
      end
    end
    else begin
      operator_count <= 'd0;
    end
  end
end

assign vcu_execute_done = stream_execute_done || stream_ewise_execute_done || ((para_oc_group_cnt == oc_group) && (para_data_cnt == num_data) && (fpu_done));
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    para_data_cnt <= 'd0;
    para_oc_group_cnt <= 'd0;
  end
  else if (stream_execute_done || stream_ewise_execute_done) begin
    para_data_cnt <= 'd0;
    para_oc_group_cnt <= 'd0;
  end
  else if( (para_oc_group_cnt == oc_group) && (para_data_cnt == num_data) && (fpu_done))begin
    para_data_cnt <= 'd0;
    para_oc_group_cnt <= 'd0;
  end
  else if((para_data_cnt == num_data) && (fpu_done))begin
    para_data_cnt <= 'd0;
    if (psum_addr_hop) begin
      para_oc_group_cnt <= para_oc_group_cnt + 2;
    end
    else begin
      para_oc_group_cnt <= para_oc_group_cnt + 1;
    end
  end
  else if (fpu_done) begin
    para_data_cnt <= para_data_cnt + 1;
    para_oc_group_cnt <= para_oc_group_cnt;
  end
  else begin
    para_data_cnt <= para_data_cnt;
    para_oc_group_cnt <= para_oc_group_cnt;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    para_func_cnt <= 'd0;
  end
  else if ( para_func_cnt == para_func) begin
    para_func_cnt <= 'd0;
  end
  else if (fpu_done) begin
    para_func_cnt <= 'd0;
  end
  else if (next_state == CHANGE_PARA && change_para) begin
    para_func_cnt <= para_func_cnt + 1;
  end
  else if ( done ) begin  
    para_func_cnt <= 'd0;
  end
  else begin
    para_func_cnt <= para_func_cnt;
  end
end

// ram data update------------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_rvalid_delay   <= 'd0;
    psum_sram_rvalid_delay_1 <= 'd0;
    ifmap_sram_rvalid_delay  <= 'd0;
    vcures_sram_rvalid_delay <= 'd0;
    vcupara_sram_rvalid_delay <= 'd0;
  end
  else begin
    psum_sram_rvalid_delay   <= psum_rvalid;
    psum_sram_rvalid_delay_1 <= psum_sram_rvalid_delay;
    ifmap_sram_rvalid_delay  <= ifmap_rvalid;
    vcures_sram_rvalid_delay <= vcures_rvalid;
    vcupara_sram_rvalid_delay <= vcupara_rvalid;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcu_execute_psum_rdata_reg           <= 'd0;
    ifmap_rdata_reg                      <= 'd0;
    vcupara_rdata_reg                    <= 'd0;
    vcures_rdata_reg                     <= 'd0;
    vcu_execute_psum_sram_rdata_valid    <= 'd0;
    vcu_execute_ifmap_sram_rdata_valid   <= 'd0;
    vcu_execute_vcupara_sram_rdata_valid <= 'd0;
    vcu_execute_vcures_sram_rdata_valid  <= 'd0;
  end
  else begin
    if (vcu_execute_start) begin
      if (vcu_execute_psum_sram_valid && psum_sram_rvalid_delay) begin
        vcu_execute_psum_sram_rdata_valid <= 1'b1;
      end
      else begin
        vcu_execute_psum_sram_rdata_valid <= 1'd0;
      end

      if (vcu_execute_ifmap_sram_valid && ifmap_sram_rvalid_delay) begin
        vcu_execute_ifmap_sram_rdata_valid <= 1'b1;
      end
      else begin
        vcu_execute_ifmap_sram_rdata_valid <= 1'd0;
      end

      if (vcu_execute_vcures_sram_valid && vcures_sram_rvalid_delay) begin
        vcu_execute_vcures_sram_rdata_valid <= 1'b1;
      end
      else begin
        vcu_execute_vcures_sram_rdata_valid <= 1'd0;
      end

      if (vcu_execute_vcupara_sram_valid && vcupara_rvalid) begin
        vcu_execute_vcupara_sram_rdata_valid <= 1'b1;
      end
      else begin
        vcu_execute_vcupara_sram_rdata_valid <= 1'd0;
      end
    end

    if (vcu_execute_psum_sram_rdata_valid && vcu_execute_psum_sram_valid) begin
      vcu_execute_psum_rdata_reg <= psum_rdata;
    end
    else if (done) begin
      vcu_execute_psum_rdata_reg <= 'd0;
    end
    else begin
      vcu_execute_psum_rdata_reg <= vcu_execute_psum_rdata_reg;
    end

    if (vcu_execute_ifmap_sram_rdata_valid && vcu_execute_ifmap_sram_valid) begin
      ifmap_rdata_reg <= ifmap_rdata;
    end
    else if (done) begin
      ifmap_rdata_reg <= 'd0;
    end
    else begin
      ifmap_rdata_reg <= ifmap_rdata_reg;
    end
    
    if (vcu_execute_vcupara_sram_rdata_valid && vcu_execute_vcupara_sram_valid) begin
      vcupara_rdata_reg <= vcupara_rdata;
    end
    else if (done) begin  
      vcupara_rdata_reg <= 'd0;
    end
    else begin
      vcupara_rdata_reg <= vcupara_rdata_reg;
    end

    if (vcu_execute_vcures_sram_rdata_valid && vcu_execute_vcures_sram_valid) begin
      vcures_rdata_reg <= vcures_rdata;
    end
    else if (done) begin  
      vcures_rdata_reg  <= 'd0;
    end
    else begin
      vcures_rdata_reg  <= vcures_rdata_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcucode_rdata_reg <= 'd0;
    stream_reduce_opcode_reg <= 'd0;
  end
  else begin
    if (stream_opcode_second_done) begin
      stream_reduce_opcode_reg <= vcucode_rdata;
    end
    else if (done) begin
      stream_reduce_opcode_reg <= 'd0;
    end
    else begin
      stream_reduce_opcode_reg <= stream_reduce_opcode_reg;
    end

    if( ((current_state != COMPUTE) && (next_state == COMPUTE)) || stream_opcode_first_done )
      vcucode_rdata_reg <= vcucode_rdata;
    else if ( done )
      vcucode_rdata_reg <= 'd0;
    else
      vcucode_rdata_reg <= vcucode_rdata_reg;
  end
end

//operator instantiation------------------------------------------------------------------
assign compute_valid = (current_state != COMPUTE) & (next_state == COMPUTE);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    stream_ewise_valid_d <= 'd0;
    stream_ewise_first_d <= 1'b0;
    stream_ewise_last_d  <= 1'b0;
    para_compute_in_d    <= 'd0;
  end
  else begin
    stream_ewise_valid_d <= stream_ewise_valid;
    stream_ewise_first_d <= stream_psum_first_d;
    stream_ewise_last_d  <= stream_psum_last_d;
    para_compute_in_d    <= para_compute_in;

  end
end


operator u_operator(
  .clk                         ( clk                             ),
  .rst_n                       ( rst_n                           ),
  .vcu_execute_start           ( vcu_execute_start               ),
  .fpu_done                    ( fpu_done                        ),
  .compute_valid               ( compute_valid                   ),
  .opcode                      ( vcucode_rdata_reg               ),
  .psum_data                   ( psum_compute_in                 ),
  .ifmap_data                  ( ifmap_compute_in                ),
  .resadd_data                 ( resadd_compute_in               ),
  .para_data                   ( vcupara_rdata_reg               ),
  .stream_reduce_valid         ( stream_reduce_valid             ),
  .stream_reduce_first         ( stream_reduce_first             ),
  .stream_reduce_last          ( stream_reduce_last              ),
  .stream_reduce_data          ( stream_reduce_data              ),
  .stream_reduce_done          ( stream_reduce_done              ),
  .stream_reduce_out           ( stream_reduce_out               ),
  .stream_ewise_valid          ( stream_ewise_valid_d            ),
  .stream_ewise_opcode         ( vcucode_rdata_reg[5:0]          ),
  .stream_ewise_reduce         ( stream_pair_fuse_opcode          ),
  .stream_ewise_reduce_opcode  ( stream_reduce_opcode_reg         ),
  .stream_ewise_first          ( stream_ewise_first_d             ),
  .stream_ewise_last           ( stream_ewise_last_d              ),
  .stream_ewise_psum_data      ( psum_compute_in                 ),
  .stream_ewise_ifmap_data     ( ifmap_compute_in                ),
  .stream_ewise_resadd_data    ( resadd_compute_in               ),
  .stream_ewise_para_data      ( para_compute_in_d               ),
  .stream_ewise_done           ( stream_ewise_done               ),
  .stream_ewise_out            ( stream_ewise_out                ),
  .operator_out                ( fpu_out                         ),
  .operator_done               ( operator_compute_done           ),
  .change_para                 ( change_para                     ),
  .read_cross_ocgroup          ( read_cross_ocgroup              ),
  .read_cross_ocgroup_flag     ( read_cross_ocgroup_flag         ),
  .write_cross_ocgroup         ( write_cross_ocgroup             ),
  .write_cross_ocgroup_flag    ( write_cross_ocgroup_flag        ),
  .write_cross_ocgroup_sram_id ( write_cross_ocgroup_sram_id     ),
  .write_cross_ocgroup_dtype   ( write_cross_ocgroup_dtype       ),
  .prefetch                    ( prefetch_all                    ),
  .loop_sign                   ( loop_sign                       ),
  .loop_times                  ( loop_times                      ), 
  .ini_addr                    ( ini_addr                        ), 
  .end_addr                    ( end_addr                        ),
  .loop_address                ( loop_address                    ),
  .vculut_wvalid               ( vculut_wvalid                   ),
  .vculut_waddr                ( vculut_waddr                    ),
  .vculut_wdata                ( vculut_wdata                    ),
  .func_base_highaddr          ( func_base_highaddr              )
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    write_cross_ocgroup_reg <= 'd0;
    write_cross_ocgroup_dtype_reg <= 'd0;
    write_cross_ocgroup_sram_id_reg <= 'd0;
  end
  else begin
    write_cross_ocgroup_reg <= write_cross_ocgroup;
    write_cross_ocgroup_dtype_reg <= write_cross_ocgroup_dtype;
    write_cross_ocgroup_sram_id_reg <= write_cross_ocgroup_sram_id;
  end
end

//opcode sram instantiation-----------------------------------------------------------------
vcucode_ram u_vcucode_ram(
  .clk            ( clk                                  ),
  .rst_n          ( rst_n                                ),
  .vcucode_rvalid ( vcucode_rvalid | write_cross_ocgroup ),
  .vcucode_raddr  ( vcucode_raddr                        ),
  .vcucode_rdata  ( vcucode_rdata                        ),
  .vcucode_wvalid ( vcucode_wvalid                       ),
  .vcucode_waddr  ( vcucode_waddr                        ),
  .vcucode_wdata  ( vcucode_wdata                        )
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    out_w_en <= 'd0;
  end
  else begin
    if ((next_state == WRITE) || (next_state == DONE) || stream_ewise_write_fire) begin
      out_w_en <= 1'b1;
    end
    else begin
      out_w_en <= 1'b0;
    end
  end
end

assign vcu_execute_ofmap_sram_wvalid = stream_ewise_write_fire ? (data_out_ram == 1) && (!real_data_out_int8) :
                                       stream_ewise_opcode ? 1'b0 :
                                       write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 1 && out_w_en && (!real_data_out_int8) :
                                       data_out_ram == 1 && out_w_en && (!real_data_out_int8);
assign vcu_execute_ofmap_sram_waddr = stream_ewise_write_fire ? stream_ewise_write_addr[OFMAP_ADDR_BITS-1:0] :
                                                                stream_ewise_opcode ? {OFMAP_ADDR_BITS{1'b0}} :
                                                                write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 1 ? ram_out_addr_reg[OFMAP_ADDR_BITS-1:0] : {OFMAP_ADDR_BITS{1'b0}} :
                                                                data_out_ram == 1 ? ram_out_addr_reg[OFMAP_ADDR_BITS-1:0] : {OFMAP_ADDR_BITS{1'b0}};
assign vcu_execute_ofmap_sram_wdata = stream_ewise_write_fire ? vcu_out[OFMAP_WIDTH-1:0] :
                                                                stream_ewise_opcode ? {OFMAP_WIDTH{1'b0}} :
                                                                write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 1 ? vcu_out_reg[OFMAP_WIDTH-1:0] : {OFMAP_WIDTH{1'b0}} :
                                                                data_out_ram == 1 ? vcu_out_reg[OFMAP_WIDTH-1:0] : {OFMAP_WIDTH{1'b0}};

assign vcu_execute_qact_sram_wvalid = stream_ewise_write_fire ? (data_out_ram == 3) && real_data_out_int8 :
                                      stream_ewise_opcode ? 1'b0 :
                                      write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 3 && out_w_en && real_data_out_int8 :
                                      data_out_ram == 3 && out_w_en && real_data_out_int8;
assign vcu_execute_qact_sram_waddr  = stream_ewise_write_fire ? stream_ewise_write_addr[QACT_ADDR_BITS-1:0] :
                                      stream_ewise_opcode ? {QACT_ADDR_BITS{1'b0}} :
                                      write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 3 ? ram_out_addr_reg[QACT_ADDR_BITS-1:0] : {QACT_ADDR_BITS{1'b0}} :
                                      data_out_ram == 3 ? ram_out_addr_reg[QACT_ADDR_BITS-1:0] : {QACT_ADDR_BITS{1'b0}};
assign vcu_execute_qact_sram_wdata  = stream_ewise_write_fire ? vcu_out[QACT_WIDTH-1:0] :
                                      stream_ewise_opcode ? {QACT_WIDTH{1'b0}} :
                                      write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 3 ? vcu_out_reg[QACT_WIDTH-1:0] : {QACT_WIDTH{1'b0}} :
                                      data_out_ram == 3 ? vcu_out_reg[QACT_WIDTH-1:0] : {QACT_WIDTH{1'b0}};

assign vcu_execute_scale_sram_wvalid = stream_ewise_write_fire ? (data_out_ram == 3) && (!real_data_out_int8) :
                                       stream_ewise_opcode ? 1'b0 :
                                       write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 3 && out_w_en && (!real_data_out_int8) :
                                       data_out_ram == 3 && out_w_en && (!real_data_out_int8);
assign vcu_execute_scale_sram_waddr  = stream_ewise_write_fire ? stream_ewise_write_addr[SCALE_ADDR_BITS-1:0] :
                                       stream_ewise_opcode ? {SCALE_ADDR_BITS{1'b0}} :
                                       write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 3 ? ram_out_addr_reg[SCALE_ADDR_BITS-1:0] : {SCALE_ADDR_BITS{1'b0}} :
                                       data_out_ram == 3 ? ram_out_addr_reg[SCALE_ADDR_BITS-1:0] : {SCALE_ADDR_BITS{1'b0}};
assign vcu_execute_scale_sram_wdata  = stream_ewise_write_fire ? vcu_out[SCALE_WIDTH-1:0] :
                                       stream_ewise_opcode ? {SCALE_WIDTH{1'b0}} :
                                       write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 3 ? vcu_out_reg[SCALE_WIDTH-1:0] : {SCALE_WIDTH{1'b0}} :
                                       data_out_ram == 3 ? vcu_out_reg[SCALE_WIDTH-1:0] : {SCALE_WIDTH{1'b0}};

assign vcu_execute_psum_sram_wvalid = stream_ewise_write_fire ? (data_out_ram == 0) && (!real_data_out_int8) :
                                                               stream_ewise_opcode ? 1'b0 :
                                                               write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 0 && out_w_en && (!real_data_out_int8) :
                                                               data_out_ram == 0 && out_w_en && (!real_data_out_int8);
assign vcu_execute_psum_sram_waddr = stream_ewise_write_fire ? stream_ewise_write_addr[PSUM_ADDR_BITS-1:0] :
                                                               stream_ewise_opcode ? {PSUM_ADDR_BITS{1'b0}} :
                                                               write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 0 ? ram_out_addr_reg[PSUM_ADDR_BITS-1:0] : {PSUM_ADDR_BITS{1'b0}} :
                                                               data_out_ram == 0 ? ram_out_addr_reg[PSUM_ADDR_BITS-1:0] : {PSUM_ADDR_BITS{1'b0}};
assign vcu_execute_psum_sram_wdata = stream_ewise_write_fire ? vcu_out[PSUM_WIDTH-1:0] :
                                                               stream_ewise_opcode ? {PSUM_WIDTH{1'b0}} :
                                                               write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 0 ? vcu_out_reg[PSUM_WIDTH-1:0] : {PSUM_WIDTH{1'b0}} :
                                                               data_out_ram == 0 ? vcu_out_reg[PSUM_WIDTH-1:0] : {PSUM_WIDTH{1'b0}};

wire                        vcures_wvalid_t;
wire [VCURES_ADDR_BITS-1:0] vcures_waddr_t;
wire [VCURES_WIDTH-1:0]     vcures_wdata_t;

assign vcures_wvalid_t = stream_ewise_write_fire ? (data_out_ram == 2) && (!real_data_out_int8) :
                         stream_ewise_opcode ? 1'b0 :
                         write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 2 && out_w_en && (!real_data_out_int8) :
                         data_out_ram == 2 && out_w_en && (!real_data_out_int8);
assign vcures_waddr_t  = stream_ewise_write_fire ? stream_ewise_write_addr[VCURES_ADDR_BITS-1:0] :
                         stream_ewise_opcode ? {VCURES_ADDR_BITS{1'b0}} :
                         write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 2 ? ram_out_addr_reg[VCURES_ADDR_BITS-1:0] : {VCURES_ADDR_BITS{1'b0}} :
                         data_out_ram == 2 ? ram_out_addr_reg[VCURES_ADDR_BITS-1:0] : {VCURES_ADDR_BITS{1'b0}};
assign vcures_wdata_t  = stream_ewise_write_fire ? vcu_out[VCURES_WIDTH-1:0] :
                         stream_ewise_opcode ? {VCURES_WIDTH{1'b0}} :
                         write_cross_ocgroup_reg ? write_cross_ocgroup_sram_id_reg == 2 ? vcu_out_reg[VCURES_WIDTH-1:0] : {VCURES_WIDTH{1'b0}} :
                         data_out_ram == 2 ? vcu_out_reg[VCURES_WIDTH-1:0] : {VCURES_WIDTH{1'b0}};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcures_wvalid <= 1'b0;
    vcures_waddr  <= {VCURES_ADDR_BITS{1'b0}};
    vcures_wdata  <= {VCURES_WIDTH{1'b0}};
  end
  else begin
    vcures_wvalid <= vcures_wvalid_t;
    vcures_waddr  <= vcures_waddr_t;
    vcures_wdata  <= vcures_wdata_t;
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
