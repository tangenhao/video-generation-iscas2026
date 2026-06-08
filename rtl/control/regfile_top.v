module regfile_top(
  clk, rst_n,
  mcu_clk, mcu_rst_n,
  pcie_clk, pcie_rst_n,

  slv_rvalid, slv_rready, slv_raddr, slv_rdata,
  slv_wvalid, slv_wready, slv_waddr, slv_wdata,

  apb_rvalid, apb_rready, apb_raddr, apb_rdata,
  apb_wvalid, apb_wready, apb_waddr, apb_wdata,

  cluster_0_rvalid, cluster_0_rready, cluster_0_raddr, cluster_0_rdata,
  cluster_0_wvalid, cluster_0_wready, cluster_0_waddr, cluster_0_wdata,

  cluster_1_rvalid, cluster_1_rready, cluster_1_raddr, cluster_1_rdata,
  cluster_1_wvalid, cluster_1_wready, cluster_1_waddr, cluster_1_wdata,

  cluster_2_rvalid, cluster_2_rready, cluster_2_raddr, cluster_2_rdata,
  cluster_2_wvalid, cluster_2_wready, cluster_2_waddr, cluster_2_wdata,

  cluster_3_rvalid, cluster_3_rready, cluster_3_raddr, cluster_3_rdata,
  cluster_3_wvalid, cluster_3_wready, cluster_3_waddr, cluster_3_wdata,

  pcie_highaddr, pcie_irq_enable, pcie_highaddr_config_done,
  cib_irq_enable, cib_irq_highaddr,
  mcu_highaddr,

  control, insn_addr, insn_number, insn_burst_length, local_highaddr, cmd_rst, cmd_start,
  word_cnt_debug, done_reg_debug, word_reg_debug, insn_fifo_empty_debug, insn_fifo_full_debug,

  dispatch_empty, dispatch_insn_done
);

function integer clogb2 (input integer bit_depth);              
begin
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
  bit_depth = bit_depth >> 1;
end
endfunction

/* -------------------------------------------------------------------------------------------------------- */
/*                                             Define Parameters                                            */
/* -------------------------------------------------------------------------------------------------------- */

input              clk;
input              rst_n;
input              pcie_clk;
input              pcie_rst_n;
input              mcu_clk;
input              mcu_rst_n;

input              slv_rvalid;
output reg         slv_rready;
input       [31:0] slv_raddr;
output reg  [31:0] slv_rdata;

input              slv_wvalid;
output wire        slv_wready;
input       [31:0] slv_waddr;
input       [31:0] slv_wdata;

input              apb_rvalid;
output reg         apb_rready;
input       [31:0] apb_raddr;
output reg  [31:0] apb_rdata;

input              apb_wvalid;
output wire        apb_wready;
input       [31:0] apb_waddr;
input       [31:0] apb_wdata;

output reg         cluster_0_rvalid;
input              cluster_0_rready;
output reg  [31:0] cluster_0_raddr;
input       [31:0] cluster_0_rdata;

output reg         cluster_0_wvalid;
input              cluster_0_wready;
output reg  [31:0] cluster_0_waddr;
output reg  [31:0] cluster_0_wdata;

output reg         cluster_1_rvalid;
input              cluster_1_rready;
output reg  [31:0] cluster_1_raddr;
input       [31:0] cluster_1_rdata;

output reg         cluster_1_wvalid;
input              cluster_1_wready;
output reg  [31:0] cluster_1_waddr;
output reg  [31:0] cluster_1_wdata;

output reg         cluster_2_rvalid;
input              cluster_2_rready;
output reg  [31:0] cluster_2_raddr;
input       [31:0] cluster_2_rdata;

output reg         cluster_2_wvalid;
input              cluster_2_wready;
output reg  [31:0] cluster_2_waddr;
output reg  [31:0] cluster_2_wdata;

output reg         cluster_3_rvalid;
input              cluster_3_rready;
output reg  [31:0] cluster_3_raddr;
input       [31:0] cluster_3_rdata;

output reg         cluster_3_wvalid;
input              cluster_3_wready;
output reg  [31:0] cluster_3_waddr;
output reg  [31:0] cluster_3_wdata;

output reg         pcie_irq_enable;
output reg  [31:0] pcie_highaddr;
output wire        pcie_highaddr_config_done;
output reg         cib_irq_enable;
output wire [63:0] cib_irq_highaddr;
output reg  [31:0] mcu_highaddr;

output reg  [31:0] control;
output reg         cmd_rst;
output reg         cmd_start;
output wire [63:0] insn_addr;
output reg  [31:0] insn_number;
output reg  [31:0] insn_burst_length;
output reg  [23:0] local_highaddr;

input       [31:0] word_cnt_debug;
input       [31:0] done_reg_debug;
input       [31:0] word_reg_debug;
input       [31:0] insn_fifo_empty_debug;
input       [31:0] insn_fifo_full_debug;
input              dispatch_empty;
input              dispatch_insn_done;

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 local reg                                                */
/* -------------------------------------------------------------------------------------------------------- */

reg [31:0] insn_addr_low_32;
reg [31:0] insn_addr_high_32;
reg [31:0] cib_irq_addr_low32;
reg [31:0] cib_irq_addr_high32;

reg [32:0] word_cnt;
reg [32:0] done_reg;
reg [32:0] word_reg;
reg [32:0] insn_fifo_empty;
reg [32:0] insn_fifo_full;

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 axi write                                                */
/* -------------------------------------------------------------------------------------------------------- */

wire [2:0] axi_write_high_addr;
wire [2:0] axi_read_high_addr;

assign axi_write_high_addr = slv_waddr[13:11];
assign axi_read_high_addr  = slv_raddr[13:11];

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 apb write                                                */
/* -------------------------------------------------------------------------------------------------------- */

wire [2:0] apb_write_high_addr;
wire [2:0] apb_read_high_addr;

assign apb_write_high_addr = apb_waddr[10:8];
assign apb_read_high_addr  = apb_raddr[10:8];

/* -------------------------------------------------------------------------------------------------------- */
/*                                               write arbiter                                              */
/* -------------------------------------------------------------------------------------------------------- */

reg        local_wen;
reg [31:0] local_waddr;
reg [31:0] local_wdata;
reg        local_wready;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    local_wen    <= 1'b0;
    local_waddr  <= 32'h0;
    local_wdata  <= 32'h0;
    local_wready <= 1'b0;

    cluster_0_wvalid <= 1'b0;
    cluster_0_waddr  <= 32'h0;
    cluster_0_wdata  <= 32'h0;

    cluster_1_wvalid <= 1'b0;
    cluster_1_waddr  <= 32'h0;
    cluster_1_wdata  <= 32'h0;

    cluster_2_wvalid <= 1'b0;
    cluster_2_waddr  <= 32'h0;
    cluster_2_wdata  <= 32'h0;

    cluster_3_wvalid <= 1'b0;
    cluster_3_waddr  <= 32'h0;
    cluster_3_wdata  <= 32'h0;
  end
  else begin
    if (slv_wvalid && (axi_write_high_addr == 0) && (!local_wready)) begin
      local_wen    <= 1'b1;
      local_waddr  <= {25'd0, slv_waddr[10:5]};
      local_wdata  <= slv_wdata;
      local_wready <= 1'b1;
    end
    else if (apb_wvalid && (apb_write_high_addr == 0) && (!local_wready)) begin
      local_wen    <= 1'b1;
      local_waddr  <= {25'd0, apb_waddr[7:2]};
      local_wdata  <= apb_wdata;
      local_wready <= 1'b1;
    end
    else begin
      local_wen    <= 1'b0;
      local_waddr  <= 32'h0;
      local_wdata  <= 32'h0;
      local_wready <= 1'b0;
    end

    if (slv_wvalid && (axi_write_high_addr == 1)) begin
      cluster_0_wvalid <= 1'b1;
      cluster_0_waddr  <= {25'd0, slv_waddr[10:5]};
      cluster_0_wdata  <= slv_wdata;
    end
    else if (apb_wvalid && (apb_write_high_addr == 1)) begin
      cluster_0_wvalid <= 1'b1;
      cluster_0_waddr  <= {25'd0, apb_waddr[7:2]};
      cluster_0_wdata  <= apb_wdata;
    end
    else begin
      cluster_0_wvalid <= 1'b0;
      cluster_0_waddr  <= 32'h0;
      cluster_0_wdata  <= 32'h0;
    end

    if (slv_wvalid && (axi_write_high_addr == 2)) begin
      cluster_1_wvalid <= 1'b1;
      cluster_1_waddr  <= {25'd0, slv_waddr[10:5]};
      cluster_1_wdata  <= slv_wdata;
    end
    else if (apb_wvalid && (apb_write_high_addr == 2)) begin
      cluster_1_wvalid <= 1'b1;
      cluster_1_waddr  <= {25'd0, apb_waddr[7:2]};
      cluster_1_wdata  <= apb_wdata;
    end
    else begin
      cluster_1_wvalid <= 1'b0;
      cluster_1_waddr  <= 32'h0;
      cluster_1_wdata  <= 32'h0;
    end

    if (slv_wvalid && (axi_write_high_addr == 3)) begin
      cluster_2_wvalid <= 1'b1;
      cluster_2_waddr  <= {25'd0, slv_waddr[10:5]};
      cluster_2_wdata  <= slv_wdata;
    end
    else if (apb_wvalid && (apb_write_high_addr == 3)) begin
      cluster_2_wvalid <= 1'b1;
      cluster_2_waddr  <= {25'd0, apb_waddr[7:2]};
      cluster_2_wdata  <= apb_wdata;
    end
    else begin
      cluster_2_wvalid <= 1'b0;
      cluster_2_waddr  <= 32'h0;
      cluster_2_wdata  <= 32'h0;
    end

    if (slv_wvalid && (axi_write_high_addr == 4)) begin
      cluster_3_wvalid <= 1'b1;
      cluster_3_waddr  <= {25'd0, slv_waddr[10:5]};
      cluster_3_wdata  <= slv_wdata;
    end
    else if (apb_wvalid && (apb_write_high_addr == 4)) begin
      cluster_3_wvalid <= 1'b1;
      cluster_3_waddr  <= {25'd0, apb_waddr[7:2]};
      cluster_3_wdata  <= apb_wdata;
    end
    else begin
      cluster_3_wvalid <= 1'b0;
      cluster_3_waddr  <= 32'h0;
      cluster_3_wdata  <= 32'h0;
    end
  end
end

assign slv_wready = local_wready | cluster_0_wready | cluster_1_wready | cluster_2_wready | cluster_3_wready;

/* -------------------------------------------------------------------------------------------------------- */
/*                                               Read Arbiter                                               */
/* -------------------------------------------------------------------------------------------------------- */

reg [31:0] raddr_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    raddr_reg <= 32'h0;
  end
  else begin
    if (slv_rvalid) begin
      raddr_reg <= slv_raddr;
    end
    else if (apb_rvalid) begin
      raddr_reg <= apb_raddr;
    end
    else begin
      raddr_reg <= raddr_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    slv_rready <= 1'b0;
    slv_rdata  <= 32'h0;
    apb_rready <= 1'b0;
    apb_rdata  <= 32'h0;
  end
  else begin
    if (slv_rvalid) begin
      if (axi_read_high_addr == 0) begin
        slv_rready <= 1'b1;
        case(slv_raddr[10:5])
          6'b000000: slv_rdata <= control;
          6'b000001: slv_rdata <= insn_addr_low_32;
          6'b000010: slv_rdata <= insn_addr_high_32;
          6'b000011: slv_rdata <= insn_number;
          6'b000100: slv_rdata <= insn_burst_length;
          6'b000101: slv_rdata <= cib_irq_enable;
          6'b000110: slv_rdata <= cib_irq_addr_low32;
          6'b000111: slv_rdata <= cib_irq_addr_high32;
          6'b001000: slv_rdata <= pcie_irq_enable;
          6'b001001: slv_rdata <= local_highaddr;
          6'b001100: slv_rdata <= word_cnt[31:0];
          6'b001101: slv_rdata <= word_reg[31:0];
          6'b001110: slv_rdata <= insn_fifo_empty[31:0];
          6'b001111: slv_rdata <= insn_fifo_full[31:0];
          6'b010000: slv_rdata <= {30'd0, dispatch_empty, dispatch_insn_done};
          default: slv_rdata <= 32'h0;
        endcase
      end
      else if (axi_read_high_addr == 1) begin
        slv_rready <= cluster_0_rready;
        slv_rdata  <= cluster_0_rdata;
      end
      else if (axi_read_high_addr == 2) begin
        slv_rready <= cluster_1_rready;
        slv_rdata  <= cluster_1_rdata;
      end
      else if (axi_read_high_addr == 3) begin
        slv_rready <= cluster_2_rready;
        slv_rdata  <= cluster_2_rdata;
      end
      else if (axi_read_high_addr == 4) begin
        slv_rready <= cluster_3_rready;
        slv_rdata  <= cluster_3_rdata;
      end
      else begin
        slv_rready <= 1'b0;
        slv_rdata  <= 32'h0;
      end
    end
    else if (apb_rvalid) begin
      if (apb_read_high_addr == 0) begin
        apb_rready <= 1'b1;
        case(apb_raddr[7:2])
          6'b000000: apb_rdata <= control;
          6'b000001: apb_rdata <= insn_addr_low_32;
          6'b000010: apb_rdata <= insn_addr_high_32;
          6'b000011: apb_rdata <= insn_number;
          6'b000100: apb_rdata <= insn_burst_length;
          6'b000101: apb_rdata <= cib_irq_enable;
          6'b000110: apb_rdata <= cib_irq_addr_low32;
          6'b000111: apb_rdata <= cib_irq_addr_high32;
          6'b001000: apb_rdata <= pcie_irq_enable;
          6'b001001: apb_rdata <= local_highaddr;
          6'b001100: apb_rdata <= word_cnt[31:0];
          6'b001101: apb_rdata <= word_reg[31:0];
          6'b001110: apb_rdata <= insn_fifo_empty[31:0];
          6'b001111: apb_rdata <= insn_fifo_full[31:0];
          6'b010000: apb_rdata <= {30'd0, dispatch_empty, dispatch_insn_done};
          default: apb_rdata <= 32'h0;
        endcase
      end
      else if (apb_read_high_addr == 1) begin
        apb_rready <= cluster_0_rready;
        apb_rdata  <= cluster_0_rdata;
      end
      else if (apb_read_high_addr == 2) begin
        apb_rready <= cluster_1_rready;
        apb_rdata  <= cluster_1_rdata;
      end
      else if (apb_read_high_addr == 3) begin
        apb_rready <= cluster_2_rready;
        apb_rdata  <= cluster_2_rdata;
      end
      else if (apb_read_high_addr == 4) begin
        apb_rready <= cluster_3_rready;
        apb_rdata  <= cluster_3_rdata;
      end
      else begin
        apb_rready <= 1'b0;
        apb_rdata  <= 32'h0;
      end
    end
    else begin
      slv_rready <= 1'b0;
      slv_rdata  <= 32'h0;
      apb_rready <= 1'b0;
      apb_rdata  <= 32'h0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cluster_0_rvalid <= 1'b0;
    cluster_0_raddr  <= 32'h0;
    cluster_1_rvalid <= 1'b0;
    cluster_1_raddr  <= 32'h0;
    cluster_2_rvalid <= 1'b0;
    cluster_2_raddr  <= 32'h0;
    cluster_3_rvalid <= 1'b0;
    cluster_3_raddr  <= 32'h0;
  end
  else begin
    if (slv_rvalid) begin
      if (axi_read_high_addr == 1) begin
        cluster_0_rvalid <= 1'b1;
        cluster_0_raddr  <= {25'd0, slv_raddr[10:5]};
      end
      else begin
        cluster_0_rvalid <= 1'b0;
        cluster_0_raddr  <= 32'h0;
      end

      if (axi_read_high_addr == 2) begin
        cluster_1_rvalid <= 1'b1;
        cluster_1_raddr  <= {25'd0, slv_raddr[10:5]};
      end
      else begin
        cluster_1_rvalid <= 1'b0;
        cluster_1_raddr  <= 32'h0;
      end

      if (axi_read_high_addr == 3) begin
        cluster_2_rvalid <= 1'b1;
        cluster_2_raddr  <= {25'd0, slv_raddr[10:5]};
      end
      else begin
        cluster_2_rvalid <= 1'b0;
        cluster_2_raddr  <= 32'h0;
      end

      if (axi_read_high_addr == 4) begin
        cluster_3_rvalid <= 1'b1;
        cluster_3_raddr  <= {25'd0, slv_raddr[10:5]};
      end
      else begin
        cluster_3_rvalid <= 1'b0;
        cluster_3_raddr  <= 32'h0;
      end
    end
    else if (apb_rvalid) begin
      if (apb_read_high_addr == 1) begin
        cluster_0_rvalid <= 1'b1;
        cluster_0_raddr  <= {25'd0, apb_raddr[7:2]};
      end
      else begin
        cluster_0_rvalid <= 1'b0;
        cluster_0_raddr  <= 32'h0;
      end

      if (apb_read_high_addr == 2) begin
        cluster_1_rvalid <= 1'b1;
        cluster_1_raddr  <= {25'd0, apb_raddr[7:2]};
      end
      else begin
        cluster_1_rvalid <= 1'b0;
        cluster_1_raddr  <= 32'h0;
      end

      if (apb_read_high_addr == 3) begin
        cluster_2_rvalid <= 1'b1;
        cluster_2_raddr  <= {25'd0, apb_raddr[7:2]};
      end
      else begin
        cluster_2_rvalid <= 1'b0;
        cluster_2_raddr  <= 32'h0;
      end

      if (apb_read_high_addr == 4) begin
        cluster_3_rvalid <= 1'b1;
        cluster_3_raddr  <= {25'd0, apb_raddr[7:2]};
      end
      else begin
        cluster_3_rvalid <= 1'b0;
        cluster_3_raddr  <= 32'h0;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                                 local reg                                                */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    control             <= 32'h0;
    insn_addr_high_32   <= 32'h0;
    insn_addr_low_32    <= 32'h0;
    insn_number         <= 32'h0;
    insn_burst_length   <= 32'h0;
    cib_irq_enable      <= 1'b0;
    cib_irq_addr_low32  <= 32'h0;
    cib_irq_addr_high32 <= 32'h0;
    pcie_irq_enable     <= 1'b0;
    local_highaddr      <= 24'h0;
  end
  else begin
    if (local_wen && (local_waddr[4:0] == 0)) begin
      control <= local_wdata;
    end
    else if (local_wen && (local_waddr[4:0] == 1)) begin
      insn_addr_low_32 <= local_wdata;
    end
    else if (local_wen && (local_waddr[4:0] == 2)) begin
      insn_addr_high_32 <= local_wdata;
    end
    else if (local_wen && (local_waddr[4:0] == 3)) begin
      insn_number <= local_wdata;
    end
    else if (local_wen && (local_waddr[4:0] == 4)) begin
      insn_burst_length <= local_wdata;
    end
    else if (local_wen && (local_waddr[4:0] == 5)) begin
      cib_irq_enable <= local_wdata[0];
    end
    else if (local_wen && (local_waddr[4:0] == 6)) begin
      cib_irq_addr_low32 <= local_wdata;
    end
    else if (local_wen && (local_waddr[4:0] == 7)) begin
      cib_irq_addr_high32 <= local_wdata;
    end
    else if (local_wen && (local_waddr[4:0] == 8)) begin
      pcie_irq_enable <= local_wdata[0];
    end
    else if (local_wen && (local_waddr[4:0] == 9)) begin
      local_highaddr <= local_wdata[23:0];
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                             pcie highaddr cfg                                            */
/* -------------------------------------------------------------------------------------------------------- */

reg         pcie_fifo_wvalid;
reg  [31:0] pcie_fifo_wdata;
wire [31:0] pcie_highaddr_temp;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pcie_fifo_wvalid <= 1'b0;
    pcie_fifo_wdata  <= 32'h0;
  end
  else begin
    if (local_wen && (local_waddr[4:0] == 10)) begin
      pcie_fifo_wvalid <= 1'b1;
      pcie_fifo_wdata  <= local_wdata;
    end
    else begin
      pcie_fifo_wvalid <= 1'b0;
      pcie_fifo_wdata  <= 32'h0;
    end
  end
end

AsyncAxiFifo8 #(.DATAWIDTH(32)) u_pcie_highaddr_fifo (
  .CLKU        ( clk                         ), 
  .RESETUn     ( rst_n                       ), 
  .READYU      (                             ),
  .VALIDU      ( pcie_fifo_wvalid            ),
  .DATAU       ( pcie_fifo_wdata             ),
  .SYNCMODEREQ ( 1'b0                        ),
  .CLKD        ( pcie_clk                    ),
  .RESETDn     ( pcie_rst_n                  ),
  .READYD      ( 1'b1                        ),
  .VALIDD      ( pcie_highaddr_config_done   ),
  .DATAD       ( pcie_highaddr_temp          ), 
  .SYNCMODEACK (                             )
);

always @(posedge pcie_clk or negedge pcie_rst_n) begin
  if (!pcie_rst_n) begin
    pcie_highaddr <= 0;
  end
  else begin
    if (pcie_highaddr_config_done) begin
      pcie_highaddr <= pcie_highaddr_temp;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                               mcu highaddr                                               */
/* -------------------------------------------------------------------------------------------------------- */

reg         mcu_fifo_wvalid;
reg  [31:0] mcu_fifo_wdata;
wire [31:0] mcu_highaddr_temp;
wire        mcu_highaddr_config_done;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    mcu_fifo_wvalid <= 1'b0;
    mcu_fifo_wdata  <= 32'h0;
  end
  else begin
    if (local_wen && (local_waddr[4:0] == 11)) begin
      mcu_fifo_wvalid <= 1'b1;
      mcu_fifo_wdata  <= local_wdata;
    end
    else begin
      mcu_fifo_wvalid <= 1'b0;
      mcu_fifo_wdata  <= 32'h0;
    end
  end
end

AsyncAxiFifo8 #(.DATAWIDTH(32)) u_mcu_highaddr_fifo (
  .CLKU        ( clk                       ), 
  .RESETUn     ( rst_n                     ), 
  .READYU      (                           ),
  .VALIDU      ( mcu_fifo_wvalid           ),
  .DATAU       ( mcu_fifo_wdata            ),
  .SYNCMODEREQ ( 1'b0                      ),
  .CLKD        ( mcu_clk                   ),
  .RESETDn     ( mcu_rst_n                 ),
  .READYD      ( 1'b1                      ),
  .VALIDD      ( mcu_highaddr_config_done  ),
  .DATAD       ( mcu_highaddr_temp         ), 
  .SYNCMODEACK (                           )
);

always @(posedge mcu_clk or negedge mcu_rst_n) begin
  if (!mcu_rst_n) begin
    mcu_highaddr <= 0;
  end
  else begin
    if (mcu_highaddr_config_done) begin
      mcu_highaddr <= mcu_highaddr_temp;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                              cib irq control                                             */
/* -------------------------------------------------------------------------------------------------------- */

assign cib_irq_highaddr = {cib_irq_addr_high32, cib_irq_addr_low32};
assign insn_addr        = {insn_addr_high_32, insn_addr_low_32};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    word_cnt        <= 33'd0;
    done_reg        <= 33'd0;
    word_reg        <= 33'd0;
    insn_fifo_empty <= 33'd0;
    insn_fifo_full  <= 33'd0;
  end
  else begin
    if (dispatch_empty) begin
      word_cnt        <= word_cnt_debug;
      done_reg        <= done_reg_debug;
      word_reg        <= word_reg_debug;
      insn_fifo_empty <= insn_fifo_empty_debug;
      insn_fifo_full  <= insn_fifo_full_debug;
    end
  end
end

reg cmd_rst_level;
reg cmd_rst_level_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cmd_rst            <= 1'b0;
    cmd_rst_level      <= 1'b0;
    cmd_rst_level_reg  <= 1'b0;
    cmd_start          <= 1'b0;
  end
  else begin
    if (control[0] == 1) begin
      cmd_rst_level <= 1'b1;
    end
    else begin
      cmd_rst_level <= 1'b0;
    end

    cmd_rst_level_reg <= cmd_rst_level;

    if (cmd_rst_level && !cmd_rst_level_reg) begin
      cmd_rst <= 1'b1;
    end
    else if (cmd_rst_level_reg) begin
      cmd_rst <= 1'b0;
    end
    else begin
      cmd_rst <= cmd_rst;
    end

    if (cmd_rst) begin
      cmd_start <= 1'b0;
    end
    else if (control == 2) begin
      cmd_start <= 1'b1;
    end
    else begin
      cmd_start <= cmd_start;
    end
  end
end


endmodule