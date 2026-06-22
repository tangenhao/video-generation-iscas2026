module psum_vcu_1_ram(
  clk, rst_n,

  vcu_0_wvalid, vcu_0_waddr, vcu_0_wdata,

  vcu_0_rvalid, vcu_0_raddr, vcu_0_rdata,

  dma_rvalid, dma_raddr, dma_rdata
);

parameter WIDTH     = 512;
parameter ADDR_BITS = 9;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

input                       clk;
input                       rst_n;

input                       vcu_0_wvalid;
input       [ADDR_BITS-1:0] vcu_0_waddr;
input       [WIDTH-1:0]     vcu_0_wdata;

input                       vcu_0_rvalid;
input       [ADDR_BITS-1:0] vcu_0_raddr;
output reg  [WIDTH-1:0]     vcu_0_rdata;

input                       dma_rvalid;
input       [ADDR_BITS-1:0] dma_raddr;
output reg  [WIDTH-1:0]     dma_rdata;

wire                           ren;
wire [ADDR_BITS-1:0]           raddr;
wire [WIDTH-1:0]               rdata;
reg                            wen;
reg  [ADDR_BITS-1:0]           waddr;
reg  [WIDTH-1:0]               wdata;


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wen     <= 'd0;
    waddr   <= 'd0;
    wdata   <= 'd0;
  end
  else begin
    wen     <= vcu_0_wvalid;
    waddr   <= vcu_0_waddr;
    wdata   <= vcu_0_wdata;
  end
end

sram_512x144 u_ram_bank(
  .w_clk  ( clk           ),
  .w_en   ( wen           ),
  .w_addr ( waddr         ),
  .w_data ( wdata         ),
  .r_clk  ( clk           ),
  .r_en   ( ren           ),
  .r_addr ( raddr         ),
  .r_data ( rdata         )
);

wire [1:0] read_request;
reg  [1:0] read_grant_reg;

assign read_request = {vcu_0_rvalid, dma_rvalid};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    read_grant_reg <= 2'd0;
  end
  else begin
    if (read_request[0]) begin
      read_grant_reg <= 2'b01;
    end
    else if (read_request[1]) begin
      read_grant_reg <= 2'b10;
    end
    else begin
      read_grant_reg <= 2'd0;
    end
  end
end

assign ren = |read_request;
assign raddr = read_request[0] ? dma_raddr :
               read_request[1] ? vcu_0_raddr : 0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_rdata  <= 'd0;
  end
  else begin
    if (read_grant_reg[0]) begin
      dma_rdata  <= rdata;
    end
    else begin
      dma_rdata  <= 'd0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcu_0_rdata  <= 'd0;
  end
  else begin
    if (read_grant_reg[1]) begin
      vcu_0_rdata  <= rdata;
    end
    else begin
      vcu_0_rdata  <= 'd0;
    end
  end
end

endmodule
