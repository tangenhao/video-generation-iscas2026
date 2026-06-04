module outlier_index_ram(
  clk, rst_n,

  broadcast,

  rvalid_0, raddr_0, rdata_0, rsparse_0,
  rvalid_1, raddr_1, rdata_1, rsparse_1,

  dma_wvalid, dma_waddr, dma_wdata
);

function integer clogb2 (input integer bit_depth);              
begin     
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end     
endfunction 

parameter WIDTH     = 64;
parameter ADDR_BITS = 11;
parameter BANK      = 4;

input                       clk;
input                       rst_n;

input                       broadcast;

input                       rvalid_0;
input       [ADDR_BITS-1:0] raddr_0;
output reg  [WIDTH*2-1:0]   rdata_0;
input       [1:0]           rsparse_0;

input                       rvalid_1;
input       [ADDR_BITS-1:0] raddr_1;
output reg  [WIDTH*2-1:0]   rdata_1;
input       [1:0]           rsparse_1;

input                       dma_wvalid;
input       [ADDR_BITS-1:0] dma_waddr;
input       [WIDTH-1:0]     dma_wdata;

localparam BANK_BITS = clogb2(BANK)-1;

wire                           ren[0:BANK-1];
wire [ADDR_BITS-BANK_BITS-1:0] raddr[0:BANK-1];
wire [WIDTH-1:0]               rdata[0:BANK-1];
wire                           wen[0:BANK-1];
wire [ADDR_BITS-BANK_BITS-1:0] waddr[0:BANK-1];
wire [WIDTH-1:0]               wdata[0:BANK-1];

wire dma_wen[0:BANK-1];

reg rsparse_0_reg;
reg rsparse_1_reg;
reg broadcast_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rsparse_0_reg <= 2'b00;
    rsparse_1_reg <= 2'b00;
    broadcast_reg <= 1'b0;
  end
  else begin
    rsparse_0_reg <= rsparse_0;
    rsparse_1_reg <= rsparse_1;
    broadcast_reg <= broadcast;
  end
end

assign dma_wen[0] = (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == 0) & dma_wvalid;
assign dma_wen[1] = (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == 1) & dma_wvalid;
assign dma_wen[2] = broadcast_reg ? (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == 0) & dma_wvalid : (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == 2) & dma_wvalid;
assign dma_wen[3] = broadcast_reg ? (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == 1) & dma_wvalid : (dma_waddr[(ADDR_BITS-2):(ADDR_BITS-BANK_BITS-1)] == 3) & dma_wvalid;

genvar sram_i;
generate
  for (sram_i = 0; sram_i < BANK; sram_i = sram_i + 1) begin : gen_outlier_index_sram
    assign wen[sram_i] = dma_wen[sram_i];
    assign waddr[sram_i] = {dma_waddr[ADDR_BITS-1], dma_waddr[ADDR_BITS-BANK_BITS-2:0]};
    assign wdata[sram_i] = dma_wdata;
                            
    sram_64x512 u_ram_bank(
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

wire dense;
wire sparse;

assign dense = (rsparse_0_reg == 0) && (rsparse_1_reg == 0);
assign sparse = (rsparse_0_reg == 1) || (rsparse_1_reg == 1);

assign ren[0] = (dense && rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) || (sparse && rvalid_0);
assign raddr[0] = {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]};

assign ren[1] = (dense && rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) || (sparse & rvalid_0);
assign raddr[1] = {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]};

assign ren[2] = dense ? (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 2) ? 1 :
                        (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) ? 1 : 0 :
                sparse ? (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) ? 1 :
                         (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) ? 1 : 0 : 0;
assign raddr[2] = dense ? (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 2) ? {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]} :
                          (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) ? {raddr_1[ADDR_BITS-1], raddr_1[ADDR_BITS-BANK_BITS-2:0]} : 0 :
                  sparse ? (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) ? {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]} :
                           (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) ? {raddr_1[ADDR_BITS-1], raddr_1[ADDR_BITS-BANK_BITS-2:0]} : 0 : 0;

assign ren[3] = dense ? (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 3) ? 1 :
                        (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) ? 1 : 0 :
                sparse ? (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) ? 1 :
                         (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) ? 1 : 0 : 0;
assign raddr[3] = dense ? (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) ? {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]} :
                          (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 3) ? {raddr_1[ADDR_BITS-1], raddr_1[ADDR_BITS-BANK_BITS-2:0]} : 0 :
                  sparse ? (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) ? {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]} :
                           (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) ? {raddr_1[ADDR_BITS-1], raddr_1[ADDR_BITS-BANK_BITS-2:0]} : 0 : 0;

reg grant_reg_0;
reg grant_reg_1;
reg [1:0] grant_reg_2;
reg [1:0] grant_reg_3;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    grant_reg_0 <= 1'b0;
    grant_reg_1 <= 1'b0;
    grant_reg_2 <= 1'b0;
    grant_reg_3 <= 1'b0;
  end
  else begin
    if (dense) begin
      if (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 2) begin
        grant_reg_2 <= 2'b01;
      end
      else if (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) begin
        grant_reg_2 <= 2'b10;
      end
      else begin
        grant_reg_2 <= 2'b00;
      end

      if (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 3) begin
        grant_reg_3 <= 2'b01;
      end
      else if (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) begin
        grant_reg_3 <= 2'b10;
      end
      else begin
        grant_reg_3 <= 2'b00;
      end
      grant_reg_0 <= ren[0];
      grant_reg_1 <= ren[1];
    end
    else if (sparse) begin
      grant_reg_0 <= ren[0];
      grant_reg_1 <= ren[1];
      if (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) begin
        grant_reg_2 <= 2'b01;
      end
      else if (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) begin
        grant_reg_2 <= 2'b10;
      end
      else begin
        grant_reg_2 <= 2'b00;
      end

      if (rvalid_0 && raddr_0[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 1) begin
        grant_reg_3 <= 2'b01;
      end
      else if (rvalid_1 && raddr_1[ADDR_BITS-2:ADDR_BITS-BANK_BITS-1] == 0) begin
        grant_reg_3 <= 2'b10;
      end
      else begin
        grant_reg_3 <= 2'b00;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rdata_0 <= 0;
    rdata_1 <= 0;
  end
  else begin
    if (dense) begin
      if (grant_reg_0) begin
        rdata_0 <= {256'd0, rdata[0]};
      end
      else if (grant_reg_1) begin
        rdata_0 <= {256'd0, rdata[1]};
      end
      else if (grant_reg_2[0]) begin
        rdata_0 <= {256'd0, rdata[2]};
      end
      else if (grant_reg_3[0]) begin
        rdata_0 <= {256'd0, rdata[3]};
      end
      else begin
        rdata_0 <= 0;
      end

      if (grant_reg_2[1]) begin
        rdata_1 <= {256'd0, rdata[2]};
      end
      else if (grant_reg_3[1]) begin
        rdata_1 <= {256'd0, rdata[3]};
      end
      else begin
        rdata_1 <= 0;
      end
    end
    else if (sparse) begin
      if (grant_reg_2[0]) begin
        rdata_0 <= {rdata[3], rdata[2]};
      end
      else if (grant_reg_0) begin
        rdata_0 <= {rdata[1], rdata[0]};
      end
      else begin
        rdata_0 <= 0;
      end

      if (grant_reg_2[1]) begin
        rdata_1 <= {rdata[3], rdata[2]};
      end
      else begin
        rdata_1 <= 0;
      end
    end
  end
end

// assign rdata_0 = dense ? grant_reg_0 ? {256'd0, rdata[0]} : 
//                          grant_reg_1 ? {256'd0, rdata[1]} :
//                          grant_reg_2[0] ? {256'd0, rdata[2]} :
//                          grant_reg_3[0] ? {256'd0, rdata[3]} : 0 :
//                  sparse ? grant_reg_2[0] ? {rdata[3], rdata[2]} :
//                           grant_reg_0 ? {rdata[1], rdata[0]} : 0 : 0;

// assign rdata_1 = dense ? grant_reg_2[1] ? {256'd0, rdata[2]} : 
//                          grant_reg_3[1] ? {256'd0, rdata[3]} : 0 :
//                  sparse ? grant_reg_2[1] ? {rdata[3], rdata[2]} : 0 : 0;

endmodule
