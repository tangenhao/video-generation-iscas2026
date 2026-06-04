module fake_vcu(
  clk, rst_n,

  work_en, insn, insn_read, done,

  psum_rvalid, psum_rready, psum_raddr, psum_rdata,
  vcures_rvalid, vcures_rready, vcures_raddr, vcures_rdata,
  vcupara_rvalid, vcupara_rready, vcupara_raddr, vcupara_rdata,

  psum_wvalid, psum_wready, psum_waddr, psum_wdata,
  vcucode_wvalid, vcucode_waddr, vcucode_wdata, vcucode_wready,
  vculut_wvalid, vculut_waddr, vculut_wdata, vculut_wready,
  ofmap_wvalid, ofmap_wready, ofmap_waddr, ofmap_wdata, outlier_sign,
  vcures_wvalid, vcures_wready, vcures_waddr, vcures_wdata,

  enable_prof_counter, execute_time
);


parameter PSUM_WIDTH        = 1024;
parameter VCUCODE_WIDTH     = 64;
parameter VCUPARA_WIDTH     = 1024;
parameter VCULUT_WIDTH      = 64;
parameter VCURES_WIDTH      = 1024;
parameter OFMAP_WIDTH       = 256;

parameter PSUM_ADDR_BITS    = 14;
parameter VCUCODE_ADDR_BITS = 7;
parameter VCUPARA_ADDR_BITS = 6;
parameter VCULUT_ADDR_BITS  = 9;
parameter VCURES_ADDR_BITS  = 13; 
parameter OFMAP_ADDR_BITS   = 13;
parameter INSN_WIDTH        = 128;
parameter VCU_INSN_OPCODE   = 5'd10;
parameter VCU_SERIAL_NUMBER = 3'b000;

localparam VCU_EXECUTE_INSN  = 1;

input                                clk;
input                                rst_n;

output                               ofmap_wvalid;
output       [OFMAP_ADDR_BITS-1:0]   ofmap_waddr;
output       [OFMAP_WIDTH-1:0]       ofmap_wdata;
input                                ofmap_wready;

output                               psum_rvalid;
output       [PSUM_ADDR_BITS-1:0]    psum_raddr;
input        [PSUM_WIDTH-1:0]        psum_rdata;
input                                psum_rready;

output                               vcures_rvalid;
output       [VCURES_ADDR_BITS-1:0]  vcures_raddr;
input        [VCURES_WIDTH-1:0]      vcures_rdata;
input                                vcures_rready;

output                               vcupara_rvalid;
output       [VCUPARA_ADDR_BITS-1:0] vcupara_raddr;
input        [VCUPARA_WIDTH-1:0]     vcupara_rdata;
input                                vcupara_rready;

input                                vcucode_wvalid;
input        [VCUCODE_ADDR_BITS-1:0] vcucode_waddr;
input        [VCUCODE_WIDTH-1:0]     vcucode_wdata;
output                              vcucode_wready;

output                               psum_wvalid;
output       [PSUM_ADDR_BITS-1:0]    psum_waddr;
output       [PSUM_WIDTH-1:0]        psum_wdata;
input                                psum_wready;

input                                vculut_wvalid;
input        [VCULUT_ADDR_BITS-1:0]  vculut_waddr;
input        [VCULUT_WIDTH-1:0]      vculut_wdata;
output                              vculut_wready;

input                                work_en;
input        [INSN_WIDTH-1:0]          insn;
output reg                           insn_read;
output                               done;
output outlier_sign;

assign outlier_sign = 0;

output wire                          vcures_wvalid;
output wire [VCURES_ADDR_BITS-1:0]   vcures_waddr;
output wire [VCURES_WIDTH-1:0]       vcures_wdata;
input                                vcures_wready;

input enable_prof_counter;
output reg [31:0] execute_time;

reg insn_valid;
reg [4:0] insn_number;
reg execute_done;

assign vculut_wready = 1'b1;
assign vcucode_wready = 1'b1;

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
    if (insn_valid && (insn[11:10] == VCU_EXECUTE_INSN)) begin
      insn_number <= ~|insn[9:5] ? insn[9:5] : insn_number;
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

assign done = execute_done & (~|insn_number);

assign ofmap_wvalid = 1'b0;
assign ofmap_waddr = 0;
assign ofmap_wdata = 0;

assign psum_wvalid = 1'b0;
assign psum_waddr = 0;
assign psum_wdata = 0;

assign vcupara_rvalid = 1'b0;
assign vcupara_raddr = 0;

assign vcures_rvalid = 1'b0;
assign vcures_raddr = 0;

assign psum_rvalid = 1'b0;
assign psum_raddr = 0;

assign vcures_wvalid = 1'b0;
assign vcures_waddr = 0;
assign vcures_wdata = 0;

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