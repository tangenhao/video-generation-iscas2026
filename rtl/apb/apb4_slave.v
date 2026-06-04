module apb4_slave(
  pclk, presetn, 
  paddr, psel, penable, pwrite, 
  pready, 
  pwdata, pstrb, 
  prdata,
  pprot, pslverr,

  clk, fifo_rst_n, logic_rst_n,
  sram_raddr, sram_rvalid, sram_rready, sram_rdata,
  sram_waddr, sram_wvalid, sram_wready, sram_wdata
);

parameter PERIPHERAL_R_BUSRSTS_WIDTH = 8;
parameter PERIPHERAL_W_BUSRSTS_WIDTH = 8;
parameter ASYN_ADDR_FIFO_DEPTH = 8;
parameter ASYN_DATA_FIFO_DEPTH = 8;

input              pclk;
input              presetn;
input       [31:0] paddr;
input              psel;
input              penable;
input              pwrite;
output wire        pready;
input       [31:0] pwdata;
input       [3:0]  pstrb;
output wire [31:0] prdata;
input       [2:0]  pprot;
output wire        pslverr;
input              clk;
input              fifo_rst_n;
input              logic_rst_n;
output wire [31:0] sram_raddr;
output wire        sram_rvalid;
input wire         sram_rready;
input       [31:0] sram_rdata;
output wire [31:0] sram_waddr;
output wire        sram_wvalid;
input wire         sram_wready;
output wire [31:0] sram_wdata;

wire [31:0] raddr_S_fifo_addr;
wire        raddr_S_fifo_ready;
wire        raddr_S_fifo_valid;
wire [31:0] rdata_S_fifo_data;
wire        rdata_S_fifo_ready;
wire        rdata_S_fifo_valid;

wire [31:0] waddr_S_fifo_addr;
wire        waddr_S_fifo_ready;
wire        waddr_S_fifo_valid;
wire [31:0] wdata_S_fifo_data;
wire        wdata_S_fifo_ready;
wire        wdata_S_fifo_valid;

wire [31:0] peripheral_S_raddr;
wire        peripheral_S_raddr_valid;
wire        peripheral_S_raddr_ready;

wire [31:0] peripheral_S_rdata;
wire        peripheral_S_rdata_valid;
wire        peripheral_S_rdata_ready;

wire [31:0] peripheral_S_waddr;
wire        peripheral_S_waddr_valid;
wire        peripheral_S_waddr_ready;

wire [31:0] peripheral_S_wdata;
wire        peripheral_S_wdata_valid;
wire        peripheral_S_wdata_ready;

apb4_slave_interface u_apb4_slave_interface(
  .pclk               ( pclk               ),
  .presetn            ( presetn            ),
  .paddr              ( paddr              ),
  .psel               ( psel               ),
  .penable            ( penable            ),
  .pwrite             ( pwrite             ),
  .pready             ( pready             ),
  .pwdata             ( pwdata             ),
  .pstrb              ( pstrb              ),
  .prdata             ( prdata             ),
  .pprot              ( pprot              ),
  .pslverr            ( pslverr            ),
  .raddr_S_fifo_addr  ( raddr_S_fifo_addr  ),
  .raddr_S_fifo_ready ( raddr_S_fifo_ready ),
  .raddr_S_fifo_valid ( raddr_S_fifo_valid ),
  .rdata_S_fifo_data  ( rdata_S_fifo_data  ),
  .rdata_S_fifo_ready ( rdata_S_fifo_ready ),
  .rdata_S_fifo_valid ( rdata_S_fifo_valid ),
  .waddr_S_fifo_addr  ( waddr_S_fifo_addr  ),
  .waddr_S_fifo_ready ( waddr_S_fifo_ready ),
  .waddr_S_fifo_valid ( waddr_S_fifo_valid ),
  .wdata_S_fifo_data  ( wdata_S_fifo_data  ),
  .wdata_S_fifo_ready ( wdata_S_fifo_ready ),
  .wdata_S_fifo_valid ( wdata_S_fifo_valid )
);

apb4_r_addr_clk_bridge #(
  .PERIPHERAL_R_BUSRSTS_WIDTH ( PERIPHERAL_R_BUSRSTS_WIDTH ),
  .ASYN_ADDR_FIFO_DEPTH       ( ASYN_ADDR_FIFO_DEPTH       )
) u_apb4_r_addr_clk_bridge(
  .pclk                     ( pclk                     ),
  .presetn                  ( presetn                  ),
  .raddr_S_fifo_addr        ( raddr_S_fifo_addr        ),
  .raddr_S_fifo_valid       ( raddr_S_fifo_valid       ),
  .raddr_S_fifo_ready       ( raddr_S_fifo_ready       ),
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .peripheral_S_raddr       ( peripheral_S_raddr       ),
  .peripheral_S_raddr_valid ( peripheral_S_raddr_valid ),
  .peripheral_S_raddr_ready ( peripheral_S_raddr_ready )
);

apb4_r_data_clk_bridge #(
  .ASYN_DATA_FIFO_DEPTH (ASYN_DATA_FIFO_DEPTH)
) u_apb4_r_data_clk_bridge(
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .peripheral_S_rdata       ( peripheral_S_rdata       ),
  .peripheral_S_rdata_valid ( peripheral_S_rdata_valid ),
  .peripheral_S_rdata_ready ( peripheral_S_rdata_ready ),
  .pclk                     ( pclk                     ),
  .presetn                  ( presetn                  ),
  .rdata_S_fifo_data        ( rdata_S_fifo_data        ),
  .rdata_S_fifo_ready       ( rdata_S_fifo_ready       ),
  .rdata_S_fifo_valid       ( rdata_S_fifo_valid       )
);

apb4_w_addr_clk_bridge #(
  .PERIPHERAL_W_BUSRSTS_WIDTH ( PERIPHERAL_W_BUSRSTS_WIDTH ),
  .ASYN_ADDR_FIFO_DEPTH       ( ASYN_ADDR_FIFO_DEPTH       )
) u_apb4_w_addr_clk_bridge(
  .pclk                     ( pclk                     ),
  .presetn                  ( presetn                  ),
  .waddr_S_fifo_addr        ( waddr_S_fifo_addr        ),
  .waddr_S_fifo_ready       ( waddr_S_fifo_ready       ),
  .waddr_S_fifo_valid       ( waddr_S_fifo_valid       ),
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .peripheral_S_waddr       ( peripheral_S_waddr       ),
  .peripheral_S_waddr_valid ( peripheral_S_waddr_valid ),
  .peripheral_S_waddr_ready ( peripheral_S_waddr_ready )
);

apb4_w_data_clk_bridge #(
  .ASYN_DATA_FIFO_DEPTH(ASYN_DATA_FIFO_DEPTH)
) u_apb4_w_data_clk_bridge(
  .peripheral_clk           ( clk                      ),
  .peripheral_rst_n         ( fifo_rst_n               ),
  .peripheral_S_wdata       ( peripheral_S_wdata       ),
  .peripheral_S_wdata_valid ( peripheral_S_wdata_valid ),
  .peripheral_S_wdata_ready ( peripheral_S_wdata_ready ),
  .pclk                     ( pclk                     ),
  .presetn                  ( presetn                  ),
  .wdata_S_fifo_data        ( wdata_S_fifo_data        ),
  .wdata_S_fifo_ready       ( wdata_S_fifo_ready       ),
  .wdata_S_fifo_valid       ( wdata_S_fifo_valid       )
);

apb4_ed u_apb4_ed(
  .clk                      ( clk                      ),
  .rst_n                    ( logic_rst_n              ),
  .peripheral_S_raddr       ( peripheral_S_raddr       ),
  .peripheral_S_raddr_valid ( peripheral_S_raddr_valid ),
  .peripheral_S_raddr_ready ( peripheral_S_raddr_ready ),
  .peripheral_S_rdata       ( peripheral_S_rdata       ),
  .peripheral_S_rdata_valid ( peripheral_S_rdata_valid ),
  .peripheral_S_rdata_ready ( peripheral_S_rdata_ready ),
  .peripheral_S_waddr       ( peripheral_S_waddr       ),
  .peripheral_S_waddr_valid ( peripheral_S_waddr_valid ),
  .peripheral_S_waddr_ready ( peripheral_S_waddr_ready ),
  .peripheral_S_wdata       ( peripheral_S_wdata       ),
  .peripheral_S_wdata_valid ( peripheral_S_wdata_valid ),
  .peripheral_S_wdata_ready ( peripheral_S_wdata_ready ),
  .sram_raddr           ( sram_raddr           ),
  .sram_rvalid          ( sram_rvalid          ),
  .sram_rready          ( sram_rready          ),
  .sram_rdata           ( sram_rdata           ),
  .sram_waddr          ( sram_waddr          ),
  .sram_wvalid         ( sram_wvalid         ),
  .sram_wready         ( sram_wready         ),
  .sram_wdata          ( sram_wdata          )
);


endmodule