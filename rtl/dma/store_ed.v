module store_ed(
  clk, rst_n,

  peripheral_S_waddr, peripheral_S_wlen, peripheral_S_waddr_ready, peripheral_S_waddr_valid,
  peripheral_S_wdata, peripheral_S_wdata_ready, peripheral_S_wdata_valid,

  sram_write_addr, sram_write_valid, sram_write_ready, sram_write_data
);

parameter integer PERI_ADDR_WIDTH    = 33;
parameter integer PERI_BUSRSTS_WIDTH = 8;
parameter integer PERI_DATA_WIDTH    = 256;

input                             clk;
input                             rst_n;
input [PERI_ADDR_WIDTH-1:0]       peripheral_S_waddr;
input [PERI_BUSRSTS_WIDTH-1:0]    peripheral_S_wlen;
input                             peripheral_S_waddr_ready;
output wire                       peripheral_S_waddr_valid;
input [PERI_DATA_WIDTH-1:0]       peripheral_S_wdata;
input                             peripheral_S_wdata_ready;
output wire                       peripheral_S_wdata_valid;
output wire [31:0]                sram_write_addr;
output wire                       sram_write_valid;
input                             sram_write_ready;
output wire [31:0]                sram_write_data;

reg fifo_addrlen_ren;
reg fifo_data_ren;

assign peripheral_S_waddr_valid = fifo_addrlen_ren;
assign peripheral_S_wdata_valid = fifo_data_ren;

reg                          addrlen_working;
reg [PERI_BUSRSTS_WIDTH-1:0] sram_wlen;
reg [PERI_ADDR_WIDTH-1:0]    sram_waddr;
wire [PERI_DATA_WIDTH-1:0]   sram_wdata;

reg                       sram_write_valid_reg;
reg [PERI_DATA_WIDTH-1:0] sram_write_data_reg;

assign sram_write_addr  = sram_waddr[31:0];
assign sram_write_valid = sram_write_valid_reg;
assign sram_write_data  = sram_write_data_reg[PERI_DATA_WIDTH-1:0];

assign sram_wdata = peripheral_S_wdata;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_write_valid_reg <= 1'b0;
    sram_write_data_reg <= 'd0;
  end
  else begin
    if (peripheral_S_wdata_valid && peripheral_S_wdata_ready) begin
      sram_write_valid_reg <= 1'b1;
    end
    else if (sram_write_ready && sram_write_valid) begin
      sram_write_valid_reg <= 1'b0;
    end
    else begin
      sram_write_valid_reg <= sram_write_valid_reg;
    end

    if (peripheral_S_wdata_valid && peripheral_S_wdata_ready) begin
      sram_write_data_reg <= peripheral_S_wdata;
    end
    else begin
      sram_write_data_reg <= sram_write_data_reg;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    fifo_addrlen_ren <= 0;
  end
  else begin
    if ((!addrlen_working) && (!fifo_addrlen_ren) && peripheral_S_waddr_ready) begin
      fifo_addrlen_ren <= 1'b1;
    end
    else begin
      fifo_addrlen_ren <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_waddr <= 'd0;
    sram_wlen <= 'd0;
  end
  else begin
    if ((!addrlen_working) && (!fifo_addrlen_ren) && peripheral_S_waddr_ready) begin
      sram_waddr <= peripheral_S_waddr;
      sram_wlen <= peripheral_S_wlen + 1;
    end
    else begin
      if (sram_write_valid && sram_write_ready) begin
        sram_waddr <= sram_waddr + 'h20;
        sram_wlen <= sram_wlen - 1;
      end
      else begin
        sram_waddr <= sram_waddr;
        sram_wlen <= sram_wlen;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    addrlen_working <= 1'b0;
  end
  else begin
    if (fifo_addrlen_ren && (|sram_wlen)) begin
      addrlen_working <= 1'b1;
    end
    else begin
      if (sram_wlen == 1 && sram_write_valid && sram_write_ready) begin
        addrlen_working <= 1'b0;
      end
      else begin
        addrlen_working <= addrlen_working;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    fifo_data_ren <= 1'b0;
  end
  else begin
    if (fifo_addrlen_ren) begin
      fifo_data_ren <= 1'b1;
    end
    else if (sram_write_valid && sram_write_ready && addrlen_working && (!(sram_wlen == 1))) begin
      fifo_data_ren <= 1'b1;
    end
    else if (fifo_data_ren && peripheral_S_wdata_ready) begin
      fifo_data_ren <= 1'b0;
    end
    else begin
      fifo_data_ren <= fifo_data_ren;
    end
  end
end

endmodule

