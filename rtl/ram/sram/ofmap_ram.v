module ofmap_ram(
  clk, rst_n,

  wvalid_0, waddr_0, wdata_0,
  wvalid_1, waddr_1, wdata_1,

  dma_0_rvalid, dma_0_raddr, dma_0_rdata,
  dma_1_rvalid, dma_1_raddr, dma_1_rdata
);

function integer clogb2 (input integer bit_depth);              
begin
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end
endfunction

input clk;
input rst_n;

parameter OFMAP_WIDTH     = 256;
parameter OFMAP_ADDR_BITS = 12;
parameter BANK            = 2;

input                             wvalid_0;
input       [OFMAP_ADDR_BITS-1:0] waddr_0;
input       [OFMAP_WIDTH-1:0]     wdata_0;

input                             wvalid_1;
input       [OFMAP_ADDR_BITS-1:0] waddr_1;
input       [OFMAP_WIDTH-1:0]     wdata_1;

input                             dma_0_rvalid;
input       [OFMAP_ADDR_BITS-1:0] dma_0_raddr;
output reg  [OFMAP_WIDTH-1:0]     dma_0_rdata;

input                             dma_1_rvalid;
input       [OFMAP_ADDR_BITS-1:0] dma_1_raddr;
output reg  [OFMAP_WIDTH-1:0]     dma_1_rdata;

localparam BANK_BITS = clogb2(BANK)-1;

wire                                 ren[0:BANK-1];
wire [OFMAP_ADDR_BITS-BANK_BITS-1:0] raddr[0:BANK-1];
wire [OFMAP_WIDTH-1:0]               rdata[0:BANK-1];
wire                                 wen[0:BANK-1];
wire [OFMAP_ADDR_BITS-BANK_BITS-1:0] waddr[0:BANK-1];
wire [OFMAP_WIDTH-1:0]               wdata[0:BANK-1];

wire [1:0] read_request[0:BANK-1];
reg  [1:0] read_grant_reg[0:BANK-1];

genvar rbus_i;
generate
  for (rbus_i = 0; rbus_i < BANK; rbus_i = rbus_i + 1) begin : gen_rbus
    assign read_request[rbus_i] = {dma_0_rvalid && dma_0_raddr[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == rbus_i,
                                   dma_1_rvalid && dma_1_raddr[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == rbus_i};

    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        read_grant_reg[rbus_i] <= 1'b0;
      end 
      else begin
        if (read_request[rbus_i][0]) begin
          read_grant_reg[rbus_i] <= 2'b01;
        end
        else if (read_request[rbus_i][1]) begin
          read_grant_reg[rbus_i] <= 2'b10;
        end
        else begin
          read_grant_reg[rbus_i] <= 2'b00;
        end
      end
    end

    assign ren[rbus_i] = |read_request[rbus_i];
    assign raddr[rbus_i] = read_request[rbus_i][1] ? {dma_0_raddr[OFMAP_ADDR_BITS-1], dma_0_raddr[OFMAP_ADDR_BITS-BANK_BITS-2:0]} :
                           read_request[rbus_i][0] ? {dma_1_raddr[OFMAP_ADDR_BITS-1], dma_1_raddr[OFMAP_ADDR_BITS-BANK_BITS-2:0]} : 0;
  end
endgenerate

// assign dma_0_rdata = read_grant_reg[0][1] ? rdata[0] :
//                      read_grant_reg[1][1] ? rdata[1] : 256'h0;

// assign dma_1_rdata = read_grant_reg[0][0] ? rdata[0] :
//                      read_grant_reg[1][0] ? rdata[1] : 256'h0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_0_rdata <= 0;
    dma_1_rdata <= 0;
  end
  else begin
    if (read_grant_reg[0][1]) begin
      dma_0_rdata <= rdata[0];
    end
    else if (read_grant_reg[1][1]) begin
      dma_0_rdata <= rdata[1];
    end
    else begin
      dma_0_rdata <= 0;
    end

    if (read_grant_reg[0][0]) begin
      dma_1_rdata <= rdata[0];
    end
    else if (read_grant_reg[1][0]) begin
      dma_1_rdata <= rdata[1];
    end
    else begin
      dma_1_rdata <= 0;
    end
  end
end

genvar sram_i;
generate
  for (sram_i = 0; sram_i < BANK; sram_i = sram_i + 1) begin : gen_ofmap_sram
    sram_256x2048 u_ram_bank(
      .w_clk  ( clk           ),
      .w_en   ( wen[sram_i]   ),
      .w_addr ( waddr[sram_i] ),
      .w_data ( wdata[sram_i] ),
      .r_clk  ( clk           ),
      .r_rst_n( rst_n         ),
      .r_en   ( ren[sram_i]   ),
      .r_addr ( raddr[sram_i] ),
      .r_data ( rdata[sram_i] )
    );
  end
endgenerate

assign wen[0]   = wvalid_0 && (waddr_0[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == 0);
assign waddr[0] = {waddr_0[OFMAP_ADDR_BITS-1], waddr_0[OFMAP_ADDR_BITS-1-BANK_BITS-1:0]};
assign wdata[0] = wdata_0;

assign wen[1]   = wvalid_0 && (waddr_0[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == 1) ? 1 :
                  wvalid_1 && (waddr_1[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == 0) ? 1 : 0;
assign waddr[1] = wvalid_0 && (waddr_0[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == 1) ? {waddr_0[OFMAP_ADDR_BITS-1], waddr_0[OFMAP_ADDR_BITS-1-BANK_BITS-1:0]} :
                  wvalid_1 && (waddr_1[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == 0) ? {waddr_1[OFMAP_ADDR_BITS-1], waddr_1[OFMAP_ADDR_BITS-1-BANK_BITS-1:0]} : 0;
assign wdata[1] = wvalid_0 && (waddr_0[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == 1) ? wdata_0 :
                  wvalid_1 && (waddr_1[OFMAP_ADDR_BITS-2:OFMAP_ADDR_BITS-BANK_BITS-1] == 0) ? wdata_1 : 0;

endmodule
