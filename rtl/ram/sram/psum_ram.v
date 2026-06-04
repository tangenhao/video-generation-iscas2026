module psum_ram(
  clk, rst_n,

  pea_0_wvalid, pea_0_waddr, pea_0_wdata,
  pea_1_wvalid, pea_1_waddr, pea_1_wdata,

  vcu_0_wvalid, vcu_0_waddr, vcu_0_wdata,
  vcu_1_wvalid, vcu_1_waddr, vcu_1_wdata,

  dma_wvalid, dma_waddr, dma_wdata,

  pea_0_rvalid, pea_0_raddr, pea_0_rdata,
  pea_1_rvalid, pea_1_raddr, pea_1_rdata,

  vcu_0_rvalid, vcu_0_raddr, vcu_0_rdata,
  vcu_1_rvalid, vcu_1_raddr, vcu_1_rdata,

  dma_rvalid, dma_raddr, dma_rdata
);

parameter WIDTH     = 1024;
parameter ADDR_BITS = 12;
parameter BANK      = 4;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

input                       clk;
input                       rst_n;

input                       pea_0_wvalid;
input       [ADDR_BITS-1:0] pea_0_waddr;
input       [WIDTH-1:0]     pea_0_wdata;

input                       pea_1_wvalid;
input       [ADDR_BITS-1:0] pea_1_waddr;
input       [WIDTH-1:0]     pea_1_wdata;

input                       vcu_0_wvalid;
input       [ADDR_BITS-1:0] vcu_0_waddr;
input       [WIDTH-1:0]     vcu_0_wdata;

input                       vcu_1_wvalid;
input       [ADDR_BITS-1:0] vcu_1_waddr;
input       [WIDTH-1:0]     vcu_1_wdata;

input                       dma_wvalid;
input       [ADDR_BITS-1:0] dma_waddr;
input       [WIDTH-1:0]     dma_wdata;

input                       pea_0_rvalid;
input       [ADDR_BITS-1:0] pea_0_raddr;
output reg  [WIDTH-1:0]     pea_0_rdata;

input                       pea_1_rvalid;
input       [ADDR_BITS-1:0] pea_1_raddr;
output reg  [WIDTH-1:0]     pea_1_rdata;

input                       vcu_0_rvalid;
input       [ADDR_BITS-1:0] vcu_0_raddr;
output reg  [WIDTH-1:0]     vcu_0_rdata;

input                       vcu_1_rvalid;
input       [ADDR_BITS-1:0] vcu_1_raddr;
output reg  [WIDTH-1:0]     vcu_1_rdata;

input                       dma_rvalid;
input       [ADDR_BITS-1:0] dma_raddr;
output reg  [WIDTH-1:0]     dma_rdata;

localparam BANK_BITS = clogb2(BANK)-1;

wire                             ren[0:BANK-1];
wire [ADDR_BITS-BANK_BITS-1:0]   raddr[0:BANK-1];
wire [WIDTH-1:0]                 rdata[0:BANK-1];
wire                             wen[0:BANK-1];
wire [ADDR_BITS-BANK_BITS-1:0]   waddr[0:BANK-1];
wire [WIDTH-1:0]                 wdata[0:BANK-1];

genvar sram_i;
generate
for(sram_i = 0; sram_i < BANK; sram_i = sram_i + 1) begin : sram_gen
  sram_1024x1024 u_ram_bank(
    .w_clk  ( clk               ),
    .w_en   ( wen[sram_i + 0]   ),
    .w_addr ( waddr[sram_i + 0] ),
    .w_data ( wdata[sram_i + 0] ),
    .r_clk  ( clk               ),
    .r_rst_n( rst_n             ),
    .r_en   ( ren[sram_i + 0]   ),
    .r_addr ( raddr[sram_i + 0] ),
    .r_data ( rdata[sram_i + 0] )
  );
end
endgenerate

wire [1:0] pea_raddr_high_0;
wire [1:0] pea_raddr_high_1;
wire [1:0] vcu_raddr_high_0;
wire [1:0] vcu_raddr_high_1;
wire [1:0] dma_raddr_high;

assign pea_raddr_high_0 = {pea_0_raddr[ADDR_BITS-3], pea_0_raddr[ADDR_BITS-1]};
assign pea_raddr_high_1 = {pea_1_raddr[ADDR_BITS-3], pea_1_raddr[ADDR_BITS-1]};
assign vcu_raddr_high_0 = {vcu_0_raddr[ADDR_BITS-3], vcu_0_raddr[ADDR_BITS-1]};
assign vcu_raddr_high_1 = {vcu_1_raddr[ADDR_BITS-3], vcu_1_raddr[ADDR_BITS-1]};
assign dma_raddr_high = {dma_raddr[ADDR_BITS-3], dma_raddr[ADDR_BITS-1]};

wire [1:0] pea_waddr_high_0;
wire [1:0] pea_waddr_high_1;
wire [1:0] vcu_waddr_high_0;
wire [1:0] vcu_waddr_high_1;
wire [1:0] dma_waddr_high;

assign pea_waddr_high_0 = {pea_0_waddr[ADDR_BITS-3], pea_0_waddr[ADDR_BITS-1]};
assign pea_waddr_high_1 = {pea_1_waddr[ADDR_BITS-3], pea_1_waddr[ADDR_BITS-1]};
assign vcu_waddr_high_0 = {vcu_0_waddr[ADDR_BITS-3], vcu_0_waddr[ADDR_BITS-1]};
assign vcu_waddr_high_1 = {vcu_1_waddr[ADDR_BITS-3], vcu_1_waddr[ADDR_BITS-1]};
assign dma_waddr_high = {dma_waddr[ADDR_BITS-3], dma_waddr[ADDR_BITS-1]};

wire [2:0] read_request_0;
reg  [2:0] read_grant_0_reg;

assign read_request_0 = {vcu_0_rvalid && vcu_raddr_high_0 == 0,
                         pea_0_rvalid && pea_raddr_high_0 == 0,
                         dma_rvalid && dma_raddr_high == 0};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    read_grant_0_reg <= 3'd0;
  end
  else begin
    if (read_request_0[0]) begin
      read_grant_0_reg <= 3'b001;
    end
    else if (read_request_0[1]) begin
      read_grant_0_reg <= 3'b010;
    end
    else if (read_request_0[2]) begin
      read_grant_0_reg <= 3'b100;
    end
    else begin
      read_grant_0_reg <= 3'd0;
    end
  end
end

assign ren[0] = |read_request_0;
assign raddr[0] = read_request_0[0] ? {dma_raddr[ADDR_BITS-2], dma_raddr[ADDR_BITS-4:0]} :
                  read_request_0[1] ? {pea_0_raddr[ADDR_BITS-2], pea_0_raddr[ADDR_BITS-4:0]} :
                  read_request_0[2] ? {vcu_0_raddr[ADDR_BITS-2], vcu_0_raddr[ADDR_BITS-4:0]} : 0;

wire [2:0] read_request_1;
reg  [2:0] read_grant_1_reg;
                        
assign read_request_1 = {vcu_0_rvalid && vcu_raddr_high_0 == 1,
                         pea_0_rvalid && pea_raddr_high_0 == 1,
                         dma_rvalid && dma_raddr_high == 1};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    read_grant_1_reg <= 'd0;
  end
  else begin
    if (read_request_1[0]) begin
      read_grant_1_reg <= 3'b001;
    end
    else if (read_request_1[1]) begin
      read_grant_1_reg <= 3'b010;
    end
    else if (read_request_1[2]) begin
      read_grant_1_reg <= 3'b100;
    end
    else begin
      read_grant_1_reg <= 'd0;
    end
  end
end

assign ren[1] = |read_request_1;
assign raddr[1] = read_request_1[0] ? {dma_raddr[ADDR_BITS-2], dma_raddr[ADDR_BITS-4:0]} :
                  read_request_1[1] ? {pea_0_raddr[ADDR_BITS-2], pea_0_raddr[ADDR_BITS-4:0]} :
                  read_request_1[2] ? {vcu_0_raddr[ADDR_BITS-2], vcu_0_raddr[ADDR_BITS-4:0]} : 0;

wire [4:0] read_request_2;
reg  [4:0] read_grant_2_reg;

assign read_request_2 = {vcu_0_rvalid && vcu_raddr_high_0 == 2,
                         pea_0_rvalid && pea_raddr_high_0 == 2,
                         vcu_1_rvalid && vcu_raddr_high_1 == 0,
                         pea_1_rvalid && pea_raddr_high_1 == 0,
                         dma_rvalid && dma_raddr_high == 2};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    read_grant_2_reg <= 5'd0;
  end
  else begin
    if (read_request_2[0]) begin
      read_grant_2_reg <= 5'b00001;
    end
    else if (read_request_2[1]) begin
      read_grant_2_reg <= 5'b00010;
    end
    else if (read_request_2[2]) begin
      read_grant_2_reg <= 5'b00100;
    end
    else if (read_request_2[3]) begin
      read_grant_2_reg <= 5'b01000;
    end
    else if (read_request_2[4]) begin
      read_grant_2_reg <= 5'b10000;
    end
    else begin
      read_grant_2_reg <= 5'd0;
    end
  end
end

assign ren[2] = |read_request_2;
assign raddr[2] = read_request_2[0] ? {dma_raddr[ADDR_BITS-2], dma_raddr[ADDR_BITS-4:0]} :
                  read_request_2[1] ? {pea_1_raddr[ADDR_BITS-2], pea_1_raddr[ADDR_BITS-4:0]} :
                  read_request_2[2] ? {vcu_1_raddr[ADDR_BITS-2], vcu_1_raddr[ADDR_BITS-4:0]} :
                  read_request_2[3] ? {pea_0_raddr[ADDR_BITS-2], pea_0_raddr[ADDR_BITS-4:0]} :
                  read_request_2[4] ? {vcu_0_raddr[ADDR_BITS-2], vcu_0_raddr[ADDR_BITS-4:0]} : 0;

wire [4:0] read_request_3;
reg  [4:0] read_grant_3_reg;

assign read_request_3 = {vcu_0_rvalid && vcu_raddr_high_0 == 3,
                         pea_0_rvalid && pea_raddr_high_0 == 3,
                         vcu_1_rvalid && vcu_raddr_high_1 == 1,
                         pea_1_rvalid && pea_raddr_high_1 == 1,
                         dma_rvalid && dma_raddr_high == 3};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    read_grant_3_reg <= 5'd0;
  end
  else begin
    if (read_request_3[0]) begin
      read_grant_3_reg <= 5'b00001;
    end
    else if (read_request_3[1]) begin
      read_grant_3_reg <= 5'b00010;
    end
    else if (read_request_3[2]) begin
      read_grant_3_reg <= 5'b00100;
    end
    else if (read_request_3[3]) begin
      read_grant_3_reg <= 5'b01000;
    end
    else if (read_request_3[4]) begin
      read_grant_3_reg <= 5'b10000;
    end
    else begin
      read_grant_3_reg <= 5'd0;
    end
  end
end

assign ren[3] = |read_request_3;
assign raddr[3] = read_request_3[0] ? {dma_raddr[ADDR_BITS-2], dma_raddr[ADDR_BITS-4:0]} :
                  read_request_3[1] ? {pea_1_raddr[ADDR_BITS-2], pea_1_raddr[ADDR_BITS-4:0]} :
                  read_request_3[2] ? {vcu_1_raddr[ADDR_BITS-2], vcu_1_raddr[ADDR_BITS-4:0]} :
                  read_request_3[3] ? {pea_0_raddr[ADDR_BITS-2], pea_0_raddr[ADDR_BITS-4:0]} :
                  read_request_3[4] ? {vcu_0_raddr[ADDR_BITS-2], vcu_0_raddr[ADDR_BITS-4:0]} : 0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_rdata  <= 0;
  end
  else begin
    if (read_grant_0_reg[0]) begin
      dma_rdata  <= rdata[0];
    end
    else if (read_grant_1_reg[0]) begin
      dma_rdata  <= rdata[1];
    end
    else if (read_grant_2_reg[0]) begin
      dma_rdata  <= rdata[2];
    end
    else if (read_grant_3_reg[0]) begin
      dma_rdata  <= rdata[3];
    end
    else begin
      dma_rdata  <= 0;
    end
  end
end

// assign dma_rdata = read_grant_0_reg[0] ? rdata[0] :
//                    read_grant_1_reg[0] ? rdata[1] :
//                    read_grant_2_reg[0] ? rdata[2] :
//                    read_grant_3_reg[0] ? rdata[3] : 0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pea_0_rdata  <= 0;
  end
  else begin
    if (read_grant_0_reg[1]) begin
      pea_0_rdata  <= rdata[0];
    end
    else if (read_grant_1_reg[1]) begin
      pea_0_rdata  <= rdata[1];
    end
    else if (read_grant_2_reg[3]) begin
      pea_0_rdata  <= rdata[2];
    end
    else if (read_grant_3_reg[3]) begin
      pea_0_rdata  <= rdata[3];
    end
    else begin
      pea_0_rdata  <= 0;
    end
  end
end

// assign pea_0_rdata = read_grant_0_reg[1] ? rdata[0] :
//                      read_grant_1_reg[1] ? rdata[1] :
//                      read_grant_2_reg[3] ? rdata[2] :
//                      read_grant_3_reg[3] ? rdata[3] : 0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    pea_1_rdata  <= 0;
  end
  else begin
    if (read_grant_2_reg[1]) begin
      pea_1_rdata  <= rdata[2];
    end
    else if (read_grant_3_reg[1]) begin
      pea_1_rdata  <= rdata[3];
    end
    else begin
      pea_1_rdata  <= 0;
    end
  end
end

// assign pea_1_rdata = read_grant_2_reg[1] ? rdata[2] :
//                      read_grant_3_reg[1] ? rdata[3] : 0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcu_0_rdata  <= 0;
  end
  else begin
    if (read_grant_0_reg[2]) begin
      vcu_0_rdata  <= rdata[0];
    end
    else if (read_grant_1_reg[2]) begin
      vcu_0_rdata  <= rdata[1];
    end
    else if (read_grant_2_reg[4]) begin
      vcu_0_rdata  <= rdata[2];
    end
    else if (read_grant_3_reg[4]) begin
      vcu_0_rdata  <= rdata[3];
    end
    else begin
      vcu_0_rdata  <= 0;
    end
  end
end

// assign vcu_0_rdata = read_grant_0_reg[2] ? rdata[0] :
//                      read_grant_1_reg[2] ? rdata[1] :
//                      read_grant_2_reg[4] ? rdata[2] :
//                      read_grant_3_reg[4] ? rdata[3] : 0;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    vcu_1_rdata  <= 0;
  end
  else begin
    if (read_grant_2_reg[2]) begin
      vcu_1_rdata  <= rdata[2];
    end
    else if (read_grant_3_reg[2]) begin
      vcu_1_rdata  <= rdata[3];
    end
    else begin
      vcu_1_rdata  <= 0;
    end
  end
end

// assign vcu_1_rdata = read_grant_2_reg[2] ? rdata[2] :
//                      read_grant_3_reg[2] ? rdata[3] : 0;

wire [2:0] write_request_0;
assign write_request_0 = {vcu_0_wvalid && vcu_waddr_high_0 == 0,
                          pea_0_wvalid && pea_waddr_high_0 == 0,
                          dma_wvalid && dma_waddr_high == 0};
assign wen[0] = |write_request_0;
assign waddr[0] = write_request_0[0] ? {dma_waddr[ADDR_BITS-2], dma_waddr[ADDR_BITS-4:0]} :
                  write_request_0[1] ? {pea_0_waddr[ADDR_BITS-2], pea_0_waddr[ADDR_BITS-4:0]} :
                  write_request_0[2] ? {vcu_0_waddr[ADDR_BITS-2], vcu_0_waddr[ADDR_BITS-4:0]} : 0;
assign wdata[0] = write_request_0[0] ? dma_wdata :
                  write_request_0[1] ? pea_0_wdata :
                  write_request_0[2] ? vcu_0_wdata : 0;

wire [2:0] write_request_1;
assign write_request_1 = {vcu_0_wvalid && vcu_waddr_high_0 == 1,
                          pea_0_wvalid && pea_waddr_high_0 == 1,
                          dma_wvalid && dma_waddr_high == 1};
assign wen[1] = |write_request_1;
assign waddr[1] = write_request_1[0] ? {dma_waddr[ADDR_BITS-2], dma_waddr[ADDR_BITS-4:0]} :
                  write_request_1[1] ? {pea_0_waddr[ADDR_BITS-2], pea_0_waddr[ADDR_BITS-4:0]} :
                  write_request_1[2] ? {vcu_0_waddr[ADDR_BITS-2], vcu_0_waddr[ADDR_BITS-4:0]} : 0;
assign wdata[1] = write_request_1[0] ? dma_wdata :
                  write_request_1[1] ? pea_0_wdata :
                  write_request_1[2] ? vcu_0_wdata : 0;

wire [4:0] write_request_2;
assign write_request_2 = {vcu_0_wvalid && vcu_waddr_high_0 == 2,
                          pea_0_wvalid && pea_waddr_high_0 == 2,
                          vcu_1_wvalid && vcu_waddr_high_1 == 0,
                          pea_1_wvalid && pea_waddr_high_1 == 0,
                          dma_wvalid && dma_waddr_high == 2};
assign wen[2] = |write_request_2;
assign waddr[2] = write_request_2[0] ? {dma_waddr[ADDR_BITS-2], dma_waddr[ADDR_BITS-4:0]} :
                  write_request_2[1] ? {pea_1_waddr[ADDR_BITS-2], pea_1_waddr[ADDR_BITS-4:0]} :
                  write_request_2[2] ? {vcu_1_waddr[ADDR_BITS-2], vcu_1_waddr[ADDR_BITS-4:0]} :
                  write_request_2[3] ? {pea_0_waddr[ADDR_BITS-2], pea_0_waddr[ADDR_BITS-4:0]} :
                  write_request_2[4] ? {vcu_0_waddr[ADDR_BITS-2], vcu_0_waddr[ADDR_BITS-4:0]} : 0;
assign wdata[2] = write_request_2[0] ? dma_wdata :
                  write_request_2[1] ? pea_1_wdata :
                  write_request_2[2] ? vcu_1_wdata :
                  write_request_2[3] ? pea_0_wdata :
                  write_request_2[4] ? vcu_0_wdata : 0;

wire [4:0] write_request_3;
assign write_request_3 = {vcu_0_wvalid && vcu_waddr_high_0 == 3,
                          pea_0_wvalid && pea_waddr_high_0 == 3,
                          vcu_1_wvalid && vcu_waddr_high_1 == 1,
                          pea_1_wvalid && pea_waddr_high_1 == 1,
                          dma_wvalid && dma_waddr_high == 3};
assign wen[3] = |write_request_3;
assign waddr[3] = write_request_3[0] ? {dma_waddr[ADDR_BITS-2], dma_waddr[ADDR_BITS-4:0]} :
                  write_request_3[1] ? {pea_1_waddr[ADDR_BITS-2], pea_1_waddr[ADDR_BITS-4:0]} :
                  write_request_3[2] ? {vcu_1_waddr[ADDR_BITS-2], vcu_1_waddr[ADDR_BITS-4:0]} :
                  write_request_3[3] ? {pea_0_waddr[ADDR_BITS-2], pea_0_waddr[ADDR_BITS-4:0]} :
                  write_request_3[4] ? {vcu_0_waddr[ADDR_BITS-2], vcu_0_waddr[ADDR_BITS-4:0]} : 0;

assign wdata[3] = write_request_3[0] ? dma_wdata :
                  write_request_3[1] ? pea_1_wdata :
                  write_request_3[2] ? vcu_1_wdata :
                  write_request_3[3] ? pea_0_wdata :
                  write_request_3[4] ? vcu_0_wdata : 0;

endmodule
