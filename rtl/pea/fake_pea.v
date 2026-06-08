module fake_pea(
  clk, rst_n,
  work_en, insn, insn_read, done,

  ifmap_sram_raddr, ifmap_sram_rvalid, ifmap_sram_rdata, ifmap_sram_rready, ifmap_sram_rsparse,
  ifmapmask_sram_raddr, ifmapmask_sram_rvalid, ifmapmask_sram_rdata, ifmapmask_sram_rready,
  weight_sram_raddr, weight_sram_rvalid, weight_sram_rdata, weight_sram_rready,
  psum_sram_raddr, psum_sram_rvalid, psum_sram_rdata, psum_sram_rready,
  psum_sram_waddr, psum_sram_wvalid, psum_sram_wdata, psum_sram_wready,
  ifmap_scale_sram_raddr, ifmap_scale_sram_rvalid, ifmap_scale_sram_rdata, ifmap_scale_sram_rready,
  weight_scale_sram_raddr, weight_scale_sram_rvalid, weight_scale_sram_rdata, weight_scale_sram_rready,
  outlier_index_sram_raddr, outlier_index_sram_rvalid, outlier_index_sram_rdata, outlier_index_sram_rready, outlier_index_sram_rsparse,

  enable_prof_counter, execute_time,

  error
);

localparam CONV_CONFIG_INSN    = 0;
localparam CONV_EXECUTE_INSN   = 1;
localparam GEMM_CONFIG_INSN    = 2;
localparam GEMM_EXECUTE_INSN   = 3;
localparam DECONV_CONFIG_INSN  = 4;
localparam DECONV_EXECUTE_INSN = 5;

localparam TYPE_IS_INT4 = 0;
localparam TYPE_IS_INT8 = 1;
localparam TYPE_IS_FP16 = 2;
localparam TYPE_IS_BF16 = 3;

localparam PARALLELISM    = 32;
localparam OUTLIER_LAYERS = 8;
localparam LANE           = 64;

parameter IFMAP_ADDR_BITS         = 13;
parameter IFMAPMASK_ADDR_BITS     = 14;
parameter WEIGHT_ADDR_BITS        = 14;
parameter PSUM_ADDR_BITS          = 14;
parameter IFMAP_SCALE_ADDR_BITS   = 13;
parameter WEIGHT_SCALE_ADDR_BITS  = 14;
parameter OUTLIER_INDEX_ADDR_BITS = 13;

parameter IFMAP_WIDTH         = 512;
parameter IFMAPMASK_WIDTH     = 128;
parameter WEIGHT_WIDTH        = 256;
parameter PSUM_WIDTH          = 1024;
parameter IFMAP_SCALE_WIDTH   = 32;
parameter WEIGHT_SCALE_WIDTH  = 16;
parameter OUTLIER_INDEX_WIDTH = 128;

input clk;
input rst_n;

input               work_en;
input       [127:0] insn;
output reg          insn_read;
output              done;
output      [2:0]   error;

assign error = 0;

output                       ifmap_sram_rvalid;
input                        ifmap_sram_rready;
output [IFMAP_ADDR_BITS-1:0] ifmap_sram_raddr;
input  [IFMAP_WIDTH-1:0]     ifmap_sram_rdata;
output [1:0]                 ifmap_sram_rsparse;

output                           ifmapmask_sram_rvalid;
input                            ifmapmask_sram_rready;
output [IFMAPMASK_ADDR_BITS-1:0] ifmapmask_sram_raddr;
input  [IFMAPMASK_WIDTH-1:0]     ifmapmask_sram_rdata;

output                        weight_sram_rvalid;
input                         weight_sram_rready;
output [WEIGHT_ADDR_BITS-1:0] weight_sram_raddr;
input  [WEIGHT_WIDTH-1:0]     weight_sram_rdata;

output                      psum_sram_rvalid;
input                       psum_sram_rready;
output [PSUM_ADDR_BITS-1:0] psum_sram_raddr;
input  [PSUM_WIDTH-1:0]     psum_sram_rdata;

output                             ifmap_scale_sram_rvalid;
input                              ifmap_scale_sram_rready;
output [IFMAP_SCALE_ADDR_BITS-1:0] ifmap_scale_sram_raddr;
input  [IFMAP_SCALE_WIDTH-1:0]     ifmap_scale_sram_rdata;

output                              weight_scale_sram_rvalid;
input                               weight_scale_sram_rready;
output [WEIGHT_SCALE_ADDR_BITS-1:0] weight_scale_sram_raddr;
input  [WEIGHT_SCALE_WIDTH-1:0]     weight_scale_sram_rdata;

output                      psum_sram_wvalid;
input                       psum_sram_wready;
output [PSUM_ADDR_BITS-1:0] psum_sram_waddr;
output [PSUM_WIDTH-1:0]     psum_sram_wdata;

output                               outlier_index_sram_rvalid;
input                                outlier_index_sram_rready;
output [OUTLIER_INDEX_ADDR_BITS-1:0] outlier_index_sram_raddr;
input  [OUTLIER_INDEX_WIDTH-1:0]     outlier_index_sram_rdata;
output wire [1:0]                         outlier_index_sram_rsparse;

input enable_prof_counter;
output reg [31:0] execute_time;

assign outlier_index_sram_rsparse = 0;

reg insn_valid;
reg [4:0] insn_number;
reg execute_done;

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
      if (execute_done && |insn_number) begin
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
    insn_number <= 'd0;
  end
  else begin
    if (insn_valid) begin
      insn_number <= |insn[9:5] ? insn[9:5] : insn_number;
    end
    else begin
      if (execute_done && |insn_number) begin
        insn_number <= insn_number - 1;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_done <= 1'b0;
  end
  else begin
    execute_done <= work_en;
  end
end

assign done = execute_done & (~(|insn_number));

assign ifmap_sram_rvalid   = 0;
assign ifmap_sram_raddr    = 0;
assign ifmap_sram_rsparse  = 0;

assign ifmapmask_sram_rvalid = 0;
assign ifmapmask_sram_raddr  = 0;

assign weight_sram_rvalid = 0;
assign weight_sram_raddr  = 0;

assign psum_sram_rvalid = 0;
assign psum_sram_raddr  = 0;

assign ifmap_scale_sram_rvalid = 0;
assign ifmap_scale_sram_raddr  = 0;

assign weight_scale_sram_rvalid = 0;
assign weight_scale_sram_raddr  = 0;

assign psum_sram_wvalid = 0;
assign psum_sram_waddr  = 0;
assign psum_sram_wdata  = 0;

assign outlier_index_sram_rvalid = 0;
assign outlier_index_sram_raddr  = 0;

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