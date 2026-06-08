module pcie_irq(
  npu_clk, npu_rst_n,
  pcie_clk, pcie_rst_n,
  npu_done, 
  pcie_irq_enable, pcie_highaddr_config_done,
  pcie_ven_msi_req, pcie_ven_msi_func_num, pcie_ven_msi_tc, pcie_ven_msi_vector,
  pcie_msi_grant
);

input npu_clk;
input npu_rst_n;

input pcie_clk;
input pcie_rst_n;

input npu_done;

output reg       pcie_ven_msi_req;
output     [2:0] pcie_ven_msi_func_num;
output     [2:0] pcie_ven_msi_tc;
output reg [4:0] pcie_ven_msi_vector;
input            pcie_msi_grant;
input            pcie_irq_enable;
input            pcie_highaddr_config_done;

assign pcie_ven_msi_tc = 3'b000;
assign pcie_ven_msi_func_num = 3'b000;

wire [3:0] irq;

assign irq = {1'b0, npu_done, 1'b0, 1'b0};

reg        fifo_rvalid;
wire       fifo_rready;
wire [3:0] fifo_rdata;
reg  [3:0] fifo_rdata_reg;
reg        invoke_irq;

always @(posedge pcie_clk or negedge pcie_rst_n) begin
  if (!pcie_rst_n) begin
    fifo_rvalid <= 1'b0;
  end
  else begin
    if (!pcie_ven_msi_req && !pcie_msi_grant && !invoke_irq) begin
      if (fifo_rready && fifo_rvalid) begin
        fifo_rvalid <= 1'b0;
      end
      else begin
        fifo_rvalid <= 1'b1;
      end
    end
    else begin
      fifo_rvalid <= 1'b0;
    end
  end
end

always @(posedge pcie_clk or negedge pcie_rst_n) begin
  if (!pcie_rst_n) begin
    pcie_ven_msi_req    <= 1'b0;
    pcie_ven_msi_vector <= 5'b00000;
    fifo_rdata_reg      <= 4'b0000;
    invoke_irq          <= 1'b0;
  end
  else begin
    if (fifo_rvalid && fifo_rready) begin
      invoke_irq     <= 1'b1;
      fifo_rdata_reg <= fifo_rdata;
    end
    else begin
      invoke_irq     <= 1'b0;
      fifo_rdata_reg <= fifo_rdata_reg;
    end

    if (pcie_msi_grant) begin
      pcie_ven_msi_req    <= 1'b0;
      pcie_ven_msi_vector <= 1'b0;
    end
    else if (pcie_highaddr_config_done) begin
      pcie_ven_msi_req    <= 1'b1;
      pcie_ven_msi_vector <= 5'b00011;
    end
    else if (invoke_irq) begin
      pcie_ven_msi_req <= 1'b1;
      case(fifo_rdata_reg)
        4'b0100: pcie_ven_msi_vector <= 5'b00000;
        default: pcie_ven_msi_vector <= 5'b00000;
      endcase
    end
    else begin
      pcie_ven_msi_req <= pcie_ven_msi_req;
      pcie_ven_msi_vector <= pcie_ven_msi_vector;
    end
  end
end

AsyncAxiFifo8 #(.DATAWIDTH(4)) u_irq_fifo (
  .CLKU        ( npu_clk                   ), 
  .RESETUn     ( npu_rst_n                 ), 
  .READYU      (                           ),
  .VALIDU      ( (|irq) && pcie_irq_enable ),
  .DATAU       ( irq                       ),
  .SYNCMODEREQ ( 1'b0                      ),
  .CLKD        ( pcie_clk                  ),
  .RESETDn     ( pcie_rst_n                ),
  .READYD      ( fifo_rvalid               ),
  .VALIDD      ( fifo_rready               ),
  .DATAD       ( fifo_rdata                ), 
  .SYNCMODEACK (                           )
);

endmodule
