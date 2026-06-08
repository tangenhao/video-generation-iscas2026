module vculut_ram(
  clk, rst_n,

  vculut_0_rvalid, vculut_0_raddr, vculut_0_rdata, vculut_0_rready,
  vculut_1_rvalid, vculut_1_raddr, vculut_1_rdata, vculut_1_rready,
  vculut_2_rvalid, vculut_2_raddr, vculut_2_rdata, vculut_2_rready,
  vculut_3_rvalid, vculut_3_raddr, vculut_3_rdata, vculut_3_rready,
  vculut_4_rvalid, vculut_4_raddr, vculut_4_rdata, vculut_4_rready,
  vculut_5_rvalid, vculut_5_raddr, vculut_5_rdata, vculut_5_rready,
  vculut_6_rvalid, vculut_6_raddr, vculut_6_rdata, vculut_6_rready,
  vculut_7_rvalid, vculut_7_raddr, vculut_7_rdata, vculut_7_rready,

  wvalid, waddr, wdata
);

parameter VCULUT_WIDTH     = 64;
parameter VCULUT_ADDR_BITS = 9;
parameter BANK             = 8;

input clk;
input rst_n;

input                              vculut_0_rvalid;
input       [VCULUT_ADDR_BITS-1:0] vculut_0_raddr;
output wire [VCULUT_WIDTH-1:0]     vculut_0_rdata;
output wire                        vculut_0_rready;

input                              vculut_1_rvalid;
input       [VCULUT_ADDR_BITS-1:0] vculut_1_raddr;
output wire [VCULUT_WIDTH-1:0]     vculut_1_rdata;
output wire                        vculut_1_rready;

input                              vculut_2_rvalid;
input       [VCULUT_ADDR_BITS-1:0] vculut_2_raddr;
output wire [VCULUT_WIDTH-1:0]     vculut_2_rdata;
output wire                        vculut_2_rready;

input                              vculut_3_rvalid;
input       [VCULUT_ADDR_BITS-1:0] vculut_3_raddr;
output wire [VCULUT_WIDTH-1:0]     vculut_3_rdata;
output wire                        vculut_3_rready;

input                              vculut_4_rvalid;
input       [VCULUT_ADDR_BITS-1:0] vculut_4_raddr;
output wire [VCULUT_WIDTH-1:0]     vculut_4_rdata;
output wire                        vculut_4_rready;

input                              vculut_5_rvalid;
input       [VCULUT_ADDR_BITS-1:0] vculut_5_raddr;
output wire [VCULUT_WIDTH-1:0]     vculut_5_rdata;
output wire                        vculut_5_rready;

input                              vculut_6_rvalid;
input       [VCULUT_ADDR_BITS-1:0] vculut_6_raddr;
output wire [VCULUT_WIDTH-1:0]     vculut_6_rdata;
output wire                        vculut_6_rready;

input                              vculut_7_rvalid;
input       [VCULUT_ADDR_BITS-1:0] vculut_7_raddr;
output wire [VCULUT_WIDTH-1:0]     vculut_7_rdata;
output wire                        vculut_7_rready;

input                        wvalid;
input [VCULUT_ADDR_BITS-1:0] waddr;
input [VCULUT_WIDTH-1:0]     wdata;

wire wen_0;
wire wen_1;
wire wen_2;
wire wen_3;

wire [63:0] wdata_0;
wire [63:0] wdata_1;
wire [63:0] wdata_2;
wire [63:0] wdata_3;

wire [6:0] waddr_0;
wire [6:0] waddr_1;
wire [6:0] waddr_2;
wire [6:0] waddr_3;

assign wen_0 = wvalid & (waddr[6:5] == 2'b00);
assign wen_1 = wvalid & (waddr[6:5] == 2'b01);
assign wen_2 = wvalid & (waddr[6:5] == 2'b10);
assign wen_3 = wvalid & (waddr[6:5] == 2'b11);

assign waddr_0 = {waddr[8:7], waddr[4:0]};
assign waddr_1 = {waddr[8:7], waddr[4:0]};
assign waddr_2 = {waddr[8:7], waddr[4:0]};
assign waddr_3 = {waddr[8:7], waddr[4:0]};

assign wdata_0 = {64{wen_0}} & wdata;
assign wdata_1 = {64{wen_1}} & wdata;
assign wdata_2 = {64{wen_2}} & wdata;
assign wdata_3 = {64{wen_3}} & wdata;

wire ren_0;
wire ren_1;
wire ren_2;
wire ren_3;

wire [6:0] raddr_0;
wire [6:0] raddr_1;
wire [6:0] raddr_2;
wire [6:0] raddr_3;

wire [63:0] rdata_0;
wire [63:0] rdata_1;
wire [63:0] rdata_2;
wire [63:0] rdata_3;

vculut_arbiter u_vculut_arbiter(
  .clk             ( clk             ),
  .rst_n           ( rst_n           ),
  .vculut_0_rvalid ( vculut_0_rvalid ),
  .vculut_0_raddr  ( vculut_0_raddr  ),
  .vculut_1_rvalid ( vculut_1_rvalid ),
  .vculut_1_raddr  ( vculut_1_raddr  ),
  .vculut_2_rvalid ( vculut_2_rvalid ),
  .vculut_2_raddr  ( vculut_2_raddr  ),
  .vculut_3_rvalid ( vculut_3_rvalid ),
  .vculut_3_raddr  ( vculut_3_raddr  ),
  .vculut_4_rvalid ( vculut_4_rvalid ),
  .vculut_4_raddr  ( vculut_4_raddr  ),
  .vculut_5_rvalid ( vculut_5_rvalid ),
  .vculut_5_raddr  ( vculut_5_raddr  ),
  .vculut_6_rvalid ( vculut_6_rvalid ),
  .vculut_6_raddr  ( vculut_6_raddr  ),
  .vculut_7_rvalid ( vculut_7_rvalid ),
  .vculut_7_raddr  ( vculut_7_raddr  ),
  .rdata_0         ( rdata_0         ),
  .rdata_1         ( rdata_1         ),
  .rdata_2         ( rdata_2         ),
  .rdata_3         ( rdata_3         ),
  .vculut_0_rdata  ( vculut_0_rdata  ),
  .vculut_0_rready ( vculut_0_rready ),
  .vculut_1_rdata  ( vculut_1_rdata  ),
  .vculut_1_rready ( vculut_1_rready ),
  .vculut_2_rdata  ( vculut_2_rdata  ),
  .vculut_2_rready ( vculut_2_rready ),
  .vculut_3_rdata  ( vculut_3_rdata  ),
  .vculut_3_rready ( vculut_3_rready ),
  .vculut_4_rdata  ( vculut_4_rdata  ),
  .vculut_4_rready ( vculut_4_rready ),
  .vculut_5_rdata  ( vculut_5_rdata  ),
  .vculut_5_rready ( vculut_5_rready ),
  .vculut_6_rdata  ( vculut_6_rdata  ),
  .vculut_6_rready ( vculut_6_rready ),
  .vculut_7_rdata  ( vculut_7_rdata  ),
  .vculut_7_rready ( vculut_7_rready ),
  .ren_0           ( ren_0           ),
  .ren_1           ( ren_1           ),
  .ren_2           ( ren_2           ),
  .ren_3           ( ren_3           ),
  .raddr_0         ( raddr_0         ),
  .raddr_1         ( raddr_1         ),
  .raddr_2         ( raddr_2         ),
  .raddr_3         ( raddr_3         )
);

sram_64x128 u_sram_64x128_0(
    .w_clk  ( clk        ),
    .r_clk  ( clk        ),
    .w_en   ( wen_0      ),
    .r_en   ( ren_0      ),
    .w_addr ( waddr_0    ),
    .r_addr ( raddr_0    ),
    .w_data ( wdata      ),
    .r_data ( rdata_0    )
);

sram_64x128 u_sram_64x128_1(
    .w_clk  ( clk        ),
    .r_clk  ( clk        ),
    .w_en   ( wen_1      ),
    .r_en   ( ren_1      ),
    .w_addr ( waddr_1    ),
    .r_addr ( raddr_1    ),
    .w_data ( wdata      ),
    .r_data ( rdata_1    )
);

sram_64x128 u_sram_64x128_2(
    .w_clk  ( clk        ),
    .r_clk  ( clk        ),
    .w_en   ( wen_2      ),
    .r_en   ( ren_2      ),
    .w_addr ( waddr_2    ),
    .r_addr ( raddr_2    ),
    .w_data ( wdata      ),
    .r_data ( rdata_2    )
);

sram_64x128 u_sram_64x128_3(
    .w_clk  ( clk        ),
    .r_clk  ( clk        ),
    .w_en   ( wen_3      ),
    .r_en   ( ren_3      ),
    .w_addr ( waddr_3    ),
    .r_addr ( raddr_3    ),
    .w_data ( wdata      ),
    .r_data ( rdata_3    )
);

endmodule