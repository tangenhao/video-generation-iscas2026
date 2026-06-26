module weight_ram_2dma(
  clk, rst_n,

  rvalid_0, raddr_0, rdata,

  dma_wvalid_0, dma_wdata_0,
  dma_wvalid_1, dma_wdata_1
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

parameter WIDTH     = 288;
parameter ADDR_BITS = 14;
parameter BANK      = 8;
parameter DEPTH     = 128;

input                        clk;
input                        rst_n;
 
input                        rvalid_0;
input       [ADDR_BITS-1:0]  raddr_0;
output      [WIDTH*BANK-1:0] rdata;
 
input                        dma_wvalid_0;
input       [WIDTH-1:0]      dma_wdata_0;

input                        dma_wvalid_1;
input       [WIDTH-1:0]      dma_wdata_1;

localparam BANK_div_2 = BANK >> 1;
localparam BANK_BITS = clogb2(BANK)-1;
localparam LOW_ADDR_BITS = ADDR_BITS-BANK_BITS;

wire                           ren;
wire [ADDR_BITS-BANK_BITS-1:0] raddr;
wire [WIDTH-1:0]               sram_rdata_0[0:BANK_div_2-1];
wire [BANK_div_2-1:0]          wen_0;
wire [ADDR_BITS-BANK_BITS-1:0] waddr_0[0:BANK_div_2-1];
wire [WIDTH-1:0]               wdata_0[0:BANK_div_2-1];

wire [WIDTH-1:0]               sram_rdata_1[0:BANK_div_2-1];
wire [BANK_div_2-1:0]          wen_1;
wire [ADDR_BITS-BANK_BITS-1:0] waddr_1[0:BANK_div_2-1];
wire [WIDTH-1:0]               wdata_1[0:BANK_div_2-1];

reg                            dma_wvalid_0_reg;
wire [ADDR_BITS-1:0]           dma_waddr_0;
reg  [LOW_ADDR_BITS-1:0]       dma_lowaddr_0;
reg  [BANK_BITS-1:0]           dma_bankaddr_0;
reg  [WIDTH-1:0]               dma_wdata_0_reg;

reg                            dma_wvalid_1_reg;
wire [ADDR_BITS-1:0]           dma_waddr_1;
reg  [LOW_ADDR_BITS-1:0]       dma_lowaddr_1;
reg  [BANK_BITS-1:0]           dma_bankaddr_1;
reg  [WIDTH-1:0]               dma_wdata_1_reg;

wire [BANK_div_2-1:0]          dma_wen_0;
wire [BANK_div_2-1:0]          dma_wen_1;

reg                            ren_reg;
reg  [WIDTH*BANK_div_2-1:0]    rdata_0;
reg  [WIDTH*BANK_div_2-1:0]    rdata_1;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_wvalid_0_reg <= 'd0;
    dma_wvalid_1_reg <= 'd0;
  end
  else begin
    dma_wvalid_0_reg <= dma_wvalid_0;
    dma_wvalid_1_reg <= dma_wvalid_1;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_bankaddr_0 <= 'd0;
  end
  else begin
    if (dma_wvalid_0_reg && dma_bankaddr_0 == BANK_div_2 - 1) begin
      dma_bankaddr_0 <= 'd0;
    end
    else if (dma_wvalid_0_reg) begin
      dma_bankaddr_0 <= dma_bankaddr_0 + 1;
    end
    else begin
      dma_bankaddr_0 <= dma_bankaddr_0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_lowaddr_0 <= 'd0;
  end
  else begin
    if (dma_wvalid_0_reg && dma_bankaddr_0 == BANK_div_2 - 1 && dma_lowaddr_0 == DEPTH - 1) begin
      dma_lowaddr_0 <= 'd0;
    end
    else if (dma_wvalid_0_reg && dma_bankaddr_0 == BANK_div_2 - 1) begin
      dma_lowaddr_0 <= dma_lowaddr_0 + 1;
    end
    else begin
      dma_lowaddr_0 <= dma_lowaddr_0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_bankaddr_1 <= 'd0;
  end
  else begin
    if (dma_wvalid_1_reg && !dma_wvalid_0_reg && dma_bankaddr_1 == BANK - 1) begin
      dma_bankaddr_1 <= 'd0;
    end
    else if (dma_wvalid_1_reg && dma_wvalid_0_reg && dma_bankaddr_1 == BANK_div_2 - 1) begin
      dma_bankaddr_1 <= 'd0;
    end
    else if (dma_wvalid_1_reg) begin
      dma_bankaddr_1 <= dma_bankaddr_1 + 1;
    end
    else begin
      dma_bankaddr_1 <= dma_bankaddr_1;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_lowaddr_1 <= 'd0;
  end
  else begin
    if (dma_wvalid_1_reg && !dma_wvalid_0_reg  && dma_bankaddr_1 == BANK - 1 && dma_lowaddr_1 == DEPTH - 1) begin
      dma_lowaddr_1 <= 'd0;
    end
    else if (dma_wvalid_1_reg && dma_wvalid_0_reg  && dma_bankaddr_1 == BANK_div_2 - 1 && dma_lowaddr_1 == DEPTH - 1) begin
      dma_lowaddr_1 <= 'd0;
    end
    else if (dma_wvalid_1_reg && !dma_wvalid_0_reg && dma_bankaddr_1 == BANK - 1) begin
      dma_lowaddr_1 <= dma_lowaddr_1 + 1;
    end
    else if (dma_wvalid_1_reg && dma_wvalid_0_reg && dma_bankaddr_1 == BANK_div_2 - 1) begin
      dma_lowaddr_1 <= dma_lowaddr_1 + 1;
    end
    else begin
      dma_lowaddr_1 <= dma_lowaddr_1;
    end
  end
end

genvar dma_wen_0_i;
generate
    for (dma_wen_0_i = 0; dma_wen_0_i < BANK_div_2; dma_wen_0_i = dma_wen_0_i + 1) begin
      assign dma_wen_0[dma_wen_0_i] = ((dma_bankaddr_0 == dma_wen_0_i) & dma_wvalid_0_reg) | ((dma_bankaddr_1 == dma_wen_0_i) & (dma_wvalid_1_reg & !dma_wvalid_0_reg));
    end
endgenerate

genvar dma_wen_1_i;
generate
    for (dma_wen_1_i = 0; dma_wen_1_i < BANK_div_2; dma_wen_1_i = dma_wen_1_i + 1) begin
      assign dma_wen_1[dma_wen_1_i] = ((dma_bankaddr_1 > BANK_div_2 - 1) && (dma_bankaddr_1 - BANK_div_2 == dma_wen_1_i) && dma_wvalid_1_reg);
    end
endgenerate


always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_wdata_0_reg   <= 'd0;
  end
  else if (dma_wvalid_0) begin
    dma_wdata_0_reg   <= dma_wdata_0;
  end
  else if (dma_wvalid_1 & !dma_wvalid_0) begin
    dma_wdata_0_reg   <= dma_wdata_1;
  end
  else begin
    dma_wdata_0_reg  <= dma_wdata_0_reg;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dma_wdata_1_reg   <= 'd0;
  end
  else if (dma_wvalid_1 ) begin
    dma_wdata_1_reg   <= dma_wdata_1;
  end
  else begin
    dma_wdata_1_reg  <= dma_wdata_1_reg;
  end
end

genvar sram_i_0;
generate
  for (sram_i_0 = 0; sram_i_0 < BANK_div_2; sram_i_0 = sram_i_0 + 1) begin : gen_weight_sram_0
    assign wen_0[sram_i_0]   = dma_wen_0[sram_i_0];
    assign waddr_0[sram_i_0] = (dma_wvalid_1_reg & !dma_wvalid_0_reg) ? dma_lowaddr_1 : dma_lowaddr_0;
    assign wdata_0[sram_i_0] = dma_wdata_0_reg;

    sram_288x128 u_ram_bank(
      .w_clk  ( clk                    ),
      .w_en   ( wen_0[sram_i_0]        ),
      .w_addr ( waddr_0[sram_i_0]      ),
      .w_data ( wdata_0[sram_i_0]      ),
      .r_clk  ( clk                     ),
      .r_en   ( ren                     ),
      .r_addr ( raddr                   ),
      .r_data (sram_rdata_0[sram_i_0]  )
    );
  end
endgenerate

genvar sram_i_1;
generate
  for (sram_i_1 = 0; sram_i_1 < BANK_div_2; sram_i_1 = sram_i_1 + 1) begin : gen_weight_sram_1
    assign wen_1[sram_i_1]   = dma_wen_1[sram_i_1];
    assign waddr_1[sram_i_1] = dma_lowaddr_1;
    assign wdata_1[sram_i_1] = dma_wdata_1_reg;

    sram_288x128 u_ram_bank(
      .w_clk  ( clk                   ),
      .w_en   ( wen_1[sram_i_1]       ),
      .w_addr ( waddr_1[sram_i_1]     ),
      .w_data ( wdata_1[sram_i_1]     ),
      .r_clk  ( clk                    ),
      .r_en   ( ren                    ),
      .r_addr ( raddr                  ),
      .r_data (sram_rdata_1[sram_i_1] )
    );
  end
endgenerate

assign ren   = rvalid_0;
assign raddr = {raddr_0[ADDR_BITS-1], raddr_0[ADDR_BITS-BANK_BITS-2:0]};

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ren_reg <= 'd0;
  end
  else begin
    ren_reg <= ren;
  end
end

integer rdata_0_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rdata_0 <= 'd0;
  end
  else begin
    for (rdata_0_i = 0; rdata_0_i < BANK_div_2; rdata_0_i = rdata_0_i + 1) begin
      if (ren_reg) begin
        rdata_0[rdata_0_i*WIDTH +: WIDTH] <= sram_rdata_0[rdata_0_i];
      end
    end
  end
end

integer rdata_1_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    rdata_1 <= 'd0;
  end
  else begin
    for (rdata_1_i = 0; rdata_1_i < BANK_div_2; rdata_1_i = rdata_1_i + 1) begin
      if (ren_reg) begin
        rdata_1[rdata_1_i*WIDTH +: WIDTH] <= sram_rdata_1[rdata_1_i];
      end
    end
  end
end

assign rdata = {rdata_1, rdata_0};

endmodule