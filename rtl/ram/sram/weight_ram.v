module weight_ram(
  clk, rst_n,

  rvalid_0, raddr_0, rdata_0,

  dma_wvalid, dma_waddr, dma_wdata
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

parameter WIDTH     = 256;
parameter ADDR_BITS = 14;
parameter BANK      = 32;

input                       clk;
input                       rst_n;

input                       rvalid_0;
input       [ADDR_BITS-1:0] raddr_0;
output reg  [WIDTH-1:0]     rdata_0;

input                       dma_wvalid;
input       [ADDR_BITS-1:0] dma_waddr;
input       [WIDTH-1:0]     dma_wdata;

localparam BANK_BITS = clogb2(BANK)-1;

wire [BANK-1:0]                ren;
wire [ADDR_BITS-BANK_BITS-1:0] raddr;
wire [WIDTH-1:0]               rdata[0:BANK-1];
wire                           wen[0:BANK-1];
wire [ADDR_BITS-BANK_BITS-1:0] waddr[0:BANK-1];
wire [WIDTH-1:0]               wdata[0:BANK-1];
reg  [BANK-1:0]                ren_reg;

reg  [BANK-1:0]                dma_wen;
reg  [ADDR_BITS-1:0]           dma_waddr_reg;
reg  [WIDTH-1:0]               dma_wdata_reg;

integer dma_wen_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (dma_wen_i = 0; dma_wen_i < BANK; dma_wen_i = dma_wen_i + 1) begin
      dma_wen[dma_wen_i] <= 1'b0;
    end
  end
  else begin
    for (dma_wen_i = 0; dma_wen_i < BANK; dma_wen_i = dma_wen_i + 1) begin
      dma_wen[dma_wen_i] <= (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == dma_wen_i) & dma_wvalid;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_waddr_reg   <= 'd0;
    dma_wdata_reg   <= 'd0;
  end
  else begin
    dma_waddr_reg  <= dma_waddr;
    dma_wdata_reg  <= dma_wdata;
  end
end

genvar sram_i;
generate
  for (sram_i = 0; sram_i < BANK; sram_i = sram_i + 1) begin : gen_weight_sram
    assign wen[sram_i] = dma_wen[sram_i];
    assign waddr[sram_i] = {dma_waddr_reg[ADDR_BITS-1], dma_waddr_reg[ADDR_BITS-BANK_BITS-2:0]};
    assign wdata[sram_i] = dma_wdata_reg;

    sram_256x144 u_ram_bank(
      .w_clk  ( clk           ),
      .w_en   ( wen[sram_i]   ),
      .w_addr ( waddr[sram_i] ),
      .w_data ( wdata[sram_i] ),
      .r_clk  ( clk           ),
      .r_en   ( ren           ),
      .r_addr ( raddr         ),
      .r_data ( rdata[sram_i] )
    );
  end
endgenerate

genvar rd_i;
generate
  for (rd_i = 0; rd_i < BANK; rd_i = rd_i + 1) begin: rd_mux
    assign ren[rd_i]   = (raddr_0[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == rd_i) & rvalid_0;
  end
endgenerate

assign raddr = {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ren_reg <= 'd0;
  end
  else begin
    ren_reg <= ren;
  end
end

integer rdata_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rdata_0 <= 'd0;
  end
  else begin
    for (rdata_i = 0; rdata_i < BANK; rdata_i = rdata_i + 1) begin
      if (ren_reg[rdata_i]) begin
        rdata_0 <= rdata[rdata_i];
      end
    end
  end
end

endmodule
