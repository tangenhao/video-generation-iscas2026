module apb4_ed(
  clk, rst_n,

  peripheral_S_raddr, peripheral_S_raddr_valid, peripheral_S_raddr_ready,
  peripheral_S_rdata, peripheral_S_rdata_valid, peripheral_S_rdata_ready,

  peripheral_S_waddr, peripheral_S_waddr_valid, peripheral_S_waddr_ready,
  peripheral_S_wdata, peripheral_S_wdata_valid, peripheral_S_wdata_ready,

  sram_raddr, sram_rvalid, sram_rready, sram_rdata,
  sram_waddr, sram_wvalid, sram_wready, sram_wdata
);

input clk;
input rst_n;

output wire [31:0] sram_raddr;
output wire        sram_rvalid;
input              sram_rready;
input       [31:0] sram_rdata;

output wire [31:0] sram_waddr;
output wire        sram_wvalid;
input              sram_wready;
output wire [31:0] sram_wdata;

input       [31:0] peripheral_S_raddr;
output reg         peripheral_S_raddr_valid;
input              peripheral_S_raddr_ready;

output wire [31:0] peripheral_S_rdata;
output reg         peripheral_S_rdata_valid;
input              peripheral_S_rdata_ready;

input       [31:0] peripheral_S_waddr;
output reg         peripheral_S_waddr_valid;
input              peripheral_S_waddr_ready;

input       [31:0] peripheral_S_wdata;
output reg         peripheral_S_wdata_valid;
input              peripheral_S_wdata_ready;

reg wait_for_rdata_handshake;
reg [31:0] peripheral_S_waddr_reg;

assign sram_raddr = peripheral_S_raddr;
assign sram_waddr = peripheral_S_waddr_reg;
assign sram_wdata = peripheral_S_wdata;
assign peripheral_S_rdata = sram_rdata;

// SRAM read
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    peripheral_S_raddr_valid <= 1'b0;
    wait_for_rdata_handshake <= 1'b0;
  end 
  else begin
    if (!peripheral_S_raddr_valid && peripheral_S_raddr_ready) begin
      peripheral_S_raddr_valid <= 1'b1;
    end
    else if ((peripheral_S_raddr_valid && peripheral_S_raddr_ready) || wait_for_rdata_handshake) begin
      peripheral_S_raddr_valid <= 1'b0;
    end

    if (peripheral_S_raddr_valid && peripheral_S_raddr_ready) begin
      wait_for_rdata_handshake <= 1'b1;
    end
    else if (!peripheral_S_raddr_valid && peripheral_S_raddr_ready) begin
      wait_for_rdata_handshake <= 1'b0;
    end 
  end
end

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     sram_rvalid <= 1'b0;
//   end
//   else begin
//     if (peripheral_S_raddr_valid && peripheral_S_raddr_ready) begin
//       sram_rvalid <= 1'b1;
//     end
//     else begin
//       sram_rvalid <= 1'b0;
//     end
//   end
// end

assign sram_rvalid = peripheral_S_raddr_valid && peripheral_S_raddr_ready;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    peripheral_S_rdata_valid <= 1'b0;
  end
  else begin
    if (sram_rvalid) begin
      peripheral_S_rdata_valid <= 1'b1;
    end
    else begin
      peripheral_S_rdata_valid <= 1'b0;
    end
  end
end

reg wait_for_wdata_handshake;

// SRAM write
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    peripheral_S_waddr_valid <= 1'b0;
    wait_for_wdata_handshake <= 1'b0;
    peripheral_S_waddr_reg <= 32'b0;
  end 
  else begin
    if (!peripheral_S_waddr_valid && peripheral_S_waddr_ready) begin
      peripheral_S_waddr_valid <= 1'b1;
    end
    else if ((peripheral_S_waddr_valid && peripheral_S_waddr_ready) || wait_for_wdata_handshake) begin
      peripheral_S_waddr_valid <= 1'b0;
    end

    if (peripheral_S_waddr_valid && peripheral_S_waddr_ready) begin
      wait_for_wdata_handshake <= 1'b1;
      peripheral_S_waddr_reg <= peripheral_S_waddr;

    end
    else if (peripheral_S_wdata_valid && peripheral_S_wdata_ready) begin
      wait_for_wdata_handshake <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    peripheral_S_wdata_valid <= 1'b0;
  end
  else begin
    if (peripheral_S_waddr_valid && peripheral_S_waddr_ready) begin
      peripheral_S_wdata_valid <= 1'b1;
    end
    else begin
      if (peripheral_S_wdata_valid && peripheral_S_wdata_ready) begin
        peripheral_S_wdata_valid <= 1'b0;
      end
      else begin
        peripheral_S_wdata_valid <= peripheral_S_wdata_valid;
      end
    end
  end
end

// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n) begin
//     sram_wvalid <= 1'b0;
//   end
//   else begin
//     if (peripheral_S_wdata_valid && peripheral_S_wdata_ready) begin
//       sram_wvalid <= 1'b1;
//     end
//     else begin
//       sram_wvalid <= 1'b0;
//     end
//   end
// end

assign sram_wvalid = peripheral_S_wdata_valid && peripheral_S_wdata_ready;

endmodule
