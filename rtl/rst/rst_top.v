module rst_top(
  clk, rst_n, rst_soft,
  cmd_rst_0, cmd_rst_1, cmd_rst_2, cmd_rst_3,
  apb_rst_n, dispatch_rst_n, sync_rst_n
);

input clk;
input rst_n;
input rst_soft;

output reg cmd_rst_0;
output reg cmd_rst_1;
output reg cmd_rst_2;
output reg cmd_rst_3;

output reg apb_rst_n;
output reg dispatch_rst_n;
output reg sync_rst_n;

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
    dispatch_rst_n <= 1'b0;
    sync_rst_n     <= 1'b0;
    apb_rst_n      <= 1'b0;
  end 
  else begin
    dispatch_rst_n <= 1'b1;
    sync_rst_n     <= 1'b1;
    apb_rst_n      <= 1'b1;
  end
end

reg cmd_rst_1st;
reg cmd_rst_2nd;
reg cmd_rst_3rd;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cmd_rst_1st <= 1'b0;
    cmd_rst_2nd <= 1'b0;
    cmd_rst_3rd <= 1'b0;
  end 
  else begin
    if (rst_soft) begin
      cmd_rst_1st <= 1'b1;
    end
    else begin
      cmd_rst_1st <= 1'b0;
    end

    if (cmd_rst_1st) begin
      cmd_rst_2nd <= 1'b1;
    end
    else begin
      cmd_rst_2nd <= 1'b0;
    end

    if (cmd_rst_2nd) begin
      cmd_rst_3rd <= 1'b1;
    end
    else begin
      cmd_rst_3rd <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cmd_rst_0 <= 1'b0;
    cmd_rst_1 <= 1'b0;
    cmd_rst_2 <= 1'b0;
    cmd_rst_3 <= 1'b0;
  end 
  else begin
    if (cmd_rst_3rd) begin
      cmd_rst_0 <= 1'b1;
      cmd_rst_1 <= 1'b1;
      cmd_rst_2 <= 1'b1;
      cmd_rst_3 <= 1'b1;
    end
    else begin
      cmd_rst_0 <= 1'b0;
      cmd_rst_1 <= 1'b0;
      cmd_rst_2 <= 1'b0;
      cmd_rst_3 <= 1'b0;
    end
  end
end

endmodule