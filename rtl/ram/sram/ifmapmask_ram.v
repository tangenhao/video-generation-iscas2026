module ifmapmask_ram(
  clk, rst_n,

  rvalid_0, raddr_0, rdata_0,
  rvalid_1, raddr_1, rdata_1,

  dma_wvalid, dma_waddr, dma_wdata
);

function integer clogb2 (input integer bit_depth);              
begin                                                         
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                               
end                                                         
endfunction 

parameter WIDTH     = 128;
parameter ADDR_BITS = 12;
parameter BANK      = 2;

input                       clk;
input                       rst_n;

input                       rvalid_0;
input       [ADDR_BITS-1:0] raddr_0;
output reg  [WIDTH-1:0]     rdata_0;

input                       rvalid_1;
input       [ADDR_BITS-1:0] raddr_1;
output reg  [WIDTH-1:0]     rdata_1;

input                       dma_wvalid;
input  [ADDR_BITS-1:0]      dma_waddr;
input  [WIDTH-1:0]          dma_wdata;

localparam BANK_BITS = clogb2(BANK)-1;

wire                           ren[0:BANK-1];
wire [ADDR_BITS-BANK_BITS-1:0] raddr[0:BANK-1];
wire [WIDTH-1:0]               rdata[0:BANK-1];
wire                           wen[0:BANK-1];
wire [ADDR_BITS-BANK_BITS-1:0] waddr[0:BANK-1];
wire [WIDTH-1:0]               wdata[0:BANK-1];

wire dma_wen[0:BANK-1];

assign dma_wen[0] = (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == 0) & dma_wvalid;
assign dma_wen[1] = (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == 1) & dma_wvalid;

genvar sram_i;
generate
  for (sram_i = 0; sram_i < BANK; sram_i = sram_i + 1) begin : gen_ifmapmask_sram
    assign wen[sram_i] = dma_wen[sram_i];
    assign waddr[sram_i] = {dma_waddr[ADDR_BITS-1], dma_waddr[ADDR_BITS-BANK_BITS-2:0]};
    assign wdata[sram_i] = dma_wdata;

    sram_128x2048 u_ram_bank(
      .w_clk  ( clk           ),
      .w_en   ( wen[sram_i]   ),
      .w_addr ( waddr[sram_i] ),
      .w_data ( wdata[sram_i] ),
      .r_clk  ( clk           ),
      .r_en   ( ren[sram_i]   ),
      .r_addr ( raddr[sram_i] ),
      .r_data ( rdata[sram_i] )
    );
  end
endgenerate

reg       grant_reg_0;
reg [1:0] grant_reg_1;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    grant_reg_0 <= 1'b0;
    grant_reg_1 <= 2'b00;
  end 
  else begin
    if (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) begin
      grant_reg_0 <= 1'b1;
    end
    else begin
      grant_reg_0 <= 1'b0;
    end

    if (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) begin
      grant_reg_1 <= 2'b01;
    end
    else if (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) begin
      grant_reg_1 <= 2'b10;
    end
    else begin
      grant_reg_1 <= 2'b00;
    end
  end
end

assign ren[0] = rvalid_0;
assign raddr[0] = {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]};

assign ren[1] = rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1 ? 1 :
                rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0 ? 1 : 0;
assign raddr[1] = rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1 ? {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]} :
                  rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0 ? {raddr_1[ADDR_BITS-1], raddr_1[ADDR_BITS-BANK_BITS-2:0]} : 0;

// assign rdata_0 = grant_reg_1[0] ? rdata[1] : rdata[0];
// assign rdata_1 = grant_reg_1[1] ? rdata[1] : 0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rdata_0 <= 0;
    rdata_1 <= 0;
  end
  else begin
    if (grant_reg_0) begin
      rdata_0 <= rdata[0];
    end
    else if (grant_reg_1[0]) begin
      rdata_0 <= rdata[1];
    end
    else begin
      rdata_0 <= 0;
    end

    if (grant_reg_1[1]) begin
      rdata_1 <= rdata[1];
    end
    else begin
      rdata_1 <= 0;
    end
  end
end

endmodule
