module rst_cluster(
  clk, rst_n, rst_soft,
  pea_0_rst_n, pea_1_rst_n,
  vcu_0_rst_n, vcu_1_rst_n,
  dma_rst_n, fifo_rst_n, sram_rst_n
);

input clk;
input rst_n;
input rst_soft;

output reg pea_0_rst_n;
output reg pea_1_rst_n;

output reg vcu_0_rst_n;
output reg vcu_1_rst_n;

output reg dma_rst_n;
output reg fifo_rst_n;
output reg sram_rst_n;

wire async_rst_n;
assign async_rst_n = rst_n & !rst_soft;

reg core_rst_ff_1st;
reg core_rst_ff_2nd;
reg core_rst_ff_3rd;

always @(posedge clk or negedge async_rst_n) begin
  if (!async_rst_n) begin
    core_rst_ff_1st <= 1'b0;
    core_rst_ff_2nd <= 1'b0;
    core_rst_ff_3rd <= 1'b0;
  end else begin
    core_rst_ff_1st <= 1'b1;
    core_rst_ff_2nd <= core_rst_ff_1st;
    core_rst_ff_3rd <= core_rst_ff_2nd;
  end
end

always @(posedge clk or negedge core_rst_ff_3rd) begin
  if (!core_rst_ff_3rd) begin
    pea_0_rst_n <= 1'b0;
    pea_1_rst_n <= 1'b0;

    vcu_0_rst_n <= 1'b0;
    vcu_1_rst_n <= 1'b0;

    dma_rst_n  <= 1'b0;
    fifo_rst_n <= 1'b0;
    sram_rst_n <= 1'b0;
  end 
  else begin
    pea_0_rst_n <= 1'b1;
    pea_1_rst_n <= 1'b1;

    vcu_0_rst_n <= 1'b1;
    vcu_1_rst_n <= 1'b1;

    dma_rst_n  <= 1'b1;
    fifo_rst_n <= 1'b1;
    sram_rst_n <= 1'b1;
  end
end

endmodule