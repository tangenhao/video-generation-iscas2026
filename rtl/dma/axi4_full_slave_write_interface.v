module axi4_full_slave_write_interface(
  axi4_clk, axi4_rst_n,

  waddr_S_fifo_addr, waddr_S_fifo_len, waddr_S_fifo_valid, waddr_S_fifo_ready,
  wdata_S_fifo_data, wdata_S_fifo_valid, wdata_S_fifo_ready,

  axi4_full_S_AXI_AWID, axi4_full_S_AXI_AWADDR, axi4_full_S_AXI_AWLEN,
  axi4_full_S_AXI_AWSIZE, axi4_full_S_AXI_AWBURST, axi4_full_S_AXI_AWLOCK, axi4_full_S_AXI_AWCACHE, axi4_full_S_AXI_AWPROT, axi4_full_S_AXI_AWQOS, axi4_full_S_AXI_AWUSER,
  axi4_full_S_AXI_AWVALID, axi4_full_S_AXI_AWREADY,
  axi4_full_S_AXI_WDATA, axi4_full_S_AXI_WSTRB, axi4_full_S_AXI_WLAST, axi4_full_S_AXI_WUSER, axi4_full_S_AXI_WVALID, axi4_full_S_AXI_WREADY,
  axi4_full_S_AXI_BID, axi4_full_S_AXI_BRESP, axi4_full_S_AXI_BUSER, axi4_full_S_AXI_BVALID, axi4_full_S_AXI_BREADY
);

//Define parameters:
parameter integer PERI_ADDR_WIDTH    = 32;
parameter integer PERI_BUSRSTS_WIDTH = 8;
parameter integer PERI_DATA_WIDTH    = 128;

parameter integer AXI_S_AXI_ID_WIDTH	   = 4;
parameter integer AXI_S_AXI_ADDR_WIDTH = 64;
parameter integer AXI_S_AXI_USER_WIDTH = 1;
parameter integer AXI_S_AXI_DATA_WIDTH  = 128;

parameter integer AXI_S_AXI_BURSTLENGTH  = 32;
parameter integer AXI_OUTSTANDING_DEPTH  = 128;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction  

localparam integer OUTSTANDING_FIFO_WIDTH_BITS = clogb2(AXI_S_AXI_ADDR_WIDTH + 8 - 1);
localparam integer OUTSTANDING_FIFO_WIDTH = 1 << OUTSTANDING_FIFO_WIDTH_BITS;

localparam integer PERIPHERAL_MINUS_AXI4_ADDR_WIDTH = PERI_ADDR_WIDTH - AXI_S_AXI_ADDR_WIDTH;
localparam integer AXI4_MINUS_PERIPHERAL_ADDR_WIDTH = AXI_S_AXI_ADDR_WIDTH - PERI_ADDR_WIDTH;

localparam integer PERIPHERAL_DATA_BYTES = PERI_DATA_WIDTH / 8;
localparam integer PERIPHERAL_DATA_BITS = clogb2(PERIPHERAL_DATA_BYTES - 1);
localparam integer AXI_S_AXI_DATA_BYTES = AXI_S_AXI_DATA_WIDTH / 8;
localparam integer AXI_S_AXI_DATA_BITS = clogb2(AXI_S_AXI_DATA_BYTES - 1);

localparam integer PERIPHERAL_DIV_AXI4_BITS = PERIPHERAL_DATA_BITS - AXI_S_AXI_DATA_BITS;
localparam integer PERIPHERAL_DIV_AXI4_BYTES = PERIPHERAL_DATA_BYTES >> AXI_S_AXI_DATA_BITS;
localparam integer AXI4_DIV_PERIPHERAL_BITS = AXI_S_AXI_DATA_BITS - PERIPHERAL_DATA_BITS;
localparam integer AXI4_DIV_PERIPHERAL_BYTES = AXI_S_AXI_DATA_BYTES >> PERIPHERAL_DATA_BITS;


//Define pins:
input axi4_clk, axi4_rst_n;

output wire [PERI_ADDR_WIDTH-1:0]    waddr_S_fifo_addr;
output wire [PERI_BUSRSTS_WIDTH-1:0] waddr_S_fifo_len;
output wire                          waddr_S_fifo_valid;
input                                waddr_S_fifo_ready;
output wire [PERI_DATA_WIDTH-1:0]    wdata_S_fifo_data;
output wire                          wdata_S_fifo_valid;
input                                wdata_S_fifo_ready;

input       [AXI_S_AXI_ID_WIDTH-1:0]     axi4_full_S_AXI_AWID;
input       [AXI_S_AXI_ADDR_WIDTH-1:0] axi4_full_S_AXI_AWADDR;
input       [7:0]                        axi4_full_S_AXI_AWLEN;
input       [2:0]                        axi4_full_S_AXI_AWSIZE;
input       [1:0]                        axi4_full_S_AXI_AWBURST;
input                                    axi4_full_S_AXI_AWLOCK;
input       [3:0]                        axi4_full_S_AXI_AWCACHE;
input       [2:0]                        axi4_full_S_AXI_AWPROT;
input       [3:0]                        axi4_full_S_AXI_AWQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0] axi4_full_S_AXI_AWUSER;
input                                    axi4_full_S_AXI_AWVALID;
output wire                              axi4_full_S_AXI_AWREADY;
input       [AXI_S_AXI_DATA_WIDTH-1:0]  axi4_full_S_AXI_WDATA;
input       [AXI_S_AXI_DATA_BYTES-1:0]   axi4_full_S_AXI_WSTRB;
input                                    axi4_full_S_AXI_WLAST;
input       [AXI_S_AXI_USER_WIDTH-1:0]  axi4_full_S_AXI_WUSER;
input                                    axi4_full_S_AXI_WVALID;
output wire                              axi4_full_S_AXI_WREADY;
output wire [AXI_S_AXI_ID_WIDTH-1:0]     axi4_full_S_AXI_BID;
output wire [1:0]                        axi4_full_S_AXI_BRESP;
output wire [AXI_S_AXI_USER_WIDTH-1:0]  axi4_full_S_AXI_BUSER;
output wire                              axi4_full_S_AXI_BVALID;
input                                    axi4_full_S_AXI_BREADY;

wire [AXI_S_AXI_ID_WIDTH-1:0] current_bid;
assign axi4_full_S_AXI_BID   = current_bid;
assign axi4_full_S_AXI_BUSER = 'd1;
assign axi4_full_S_AXI_BRESP = 2'b00;


//Define signals:
wire [PERI_ADDR_WIDTH-1:0]  aligned_addr;
wire [PERI_BUSRSTS_WIDTH:0] aligned_len;

wire                              dealt_fifo_afull;
reg [OUTSTANDING_FIFO_WIDTH-1:0]  dealt_fifo_wdata;
reg                               dealt_fifo_wen;
wire [OUTSTANDING_FIFO_WIDTH-1:0] dealt_fifo_rdata;
reg                               dealt_fifo_ren;
reg                               dealt_fifo_rvalid;
wire                              dealt_fifo_empty;

sync_fifo_sram_128x128 r_addrlen_fifo (
  .clk     ( axi4_clk         ),
  .rst_n   ( axi4_rst_n       ),
  .w_en    ( dealt_fifo_wen   ),
  .w_data  ( dealt_fifo_wdata ),
  .hfull   (                  ),
  .afull   ( dealt_fifo_afull ),
  .full    (                  ),
  .r_en    ( dealt_fifo_ren   ),
  .r_data  ( dealt_fifo_rdata ),
  .hempty  (                  ),
  .aempty  (                  ),
  .empty   ( dealt_fifo_empty ),
  .capacity(                  )
);

assign axi4_full_S_AXI_AWREADY = !dealt_fifo_afull;
reg axi_bvalid;
assign axi4_full_S_AXI_BVALID = axi_bvalid;

reg dealt_waddr_wen_reg;
assign waddr_S_fifo_valid = dealt_waddr_wen_reg;

reg [PERI_ADDR_WIDTH-1:0]    dealt_waddr;
reg [PERI_BUSRSTS_WIDTH-1:0] dealt_wlen;

assign waddr_S_fifo_addr = dealt_waddr;
assign waddr_S_fifo_len = dealt_wlen;

datawidth_convertor #(
  .DATA_IN_WIDTH  ( AXI_S_AXI_DATA_WIDTH ),
  .DATA_OUT_WIDTH ( PERI_DATA_WIDTH     )
) w_data_convertor (
  .clk       ( axi4_clk               ),
  .rst_n     ( axi4_rst_n             ),
  .data_in   ( axi4_full_S_AXI_WDATA  ), 
  .valid_in  ( axi4_full_S_AXI_WVALID ), 
  .ready_in  ( axi4_full_S_AXI_WREADY ), 
  .data_out  ( wdata_S_fifo_data      ), 
  .valid_out ( wdata_S_fifo_valid     ), 
  .ready_out ( wdata_S_fifo_ready     )
);

//Edit code:
generate
  if (PERI_ADDR_WIDTH > AXI_S_AXI_ADDR_WIDTH) begin : addr_align_large
    assign aligned_addr = {{PERIPHERAL_MINUS_AXI4_ADDR_WIDTH{1'b0}}, axi4_full_S_AXI_AWADDR};
  end
  else begin : addr_align_small
    assign aligned_addr = axi4_full_S_AXI_AWADDR;
  end
endgenerate

generate
  if (PERI_DATA_WIDTH < AXI_S_AXI_DATA_WIDTH) begin : data_align_large
    assign aligned_len = (axi4_full_S_AXI_AWLEN + 1) >> PERIPHERAL_DIV_AXI4_BITS;
  end
  else if (PERI_DATA_WIDTH > AXI_S_AXI_DATA_WIDTH) begin : data_align_small
    assign aligned_len = (axi4_full_S_AXI_AWLEN + 1) << AXI4_DIV_PERIPHERAL_BITS;
  end
  else begin : data_align_equal
    assign aligned_len = (axi4_full_S_AXI_AWLEN + 1);
  end
endgenerate


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    dealt_fifo_wdata <= 'd0;
    dealt_fifo_wen <= 1'b0;
  end
  else begin
    if (axi4_full_S_AXI_AWVALID && axi4_full_S_AXI_AWREADY) begin
      dealt_fifo_wdata <= {{(OUTSTANDING_FIFO_WIDTH - PERI_ADDR_WIDTH - PERI_BUSRSTS_WIDTH){1'b0}}, aligned_addr, aligned_len};
      dealt_fifo_wen <= 1'b1;
    end
    else begin
      dealt_fifo_wdata <= 'd0;
      dealt_fifo_wen <= 1'b0;
    end
  end
end

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    dealt_fifo_ren <= 1'b0;
    dealt_fifo_rvalid <= 1'b0;
  end
  else begin
    if (wdata_S_fifo_ready && !dealt_fifo_empty && (!dealt_fifo_ren)) begin
      dealt_fifo_ren <= 1'b1;
    end
    else begin
      dealt_fifo_ren <= 1'b0;
    end
    if (dealt_fifo_ren) begin
      dealt_fifo_rvalid <= dealt_fifo_ren;
    end
    else begin
      dealt_fifo_rvalid <= 1'b0;
    end
  end
end

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    dealt_waddr <= 'd0;
    dealt_wlen <= 'd0;
    dealt_waddr_wen_reg <= 1'b0;
  end
  else begin
    if (dealt_fifo_rvalid) begin
      dealt_waddr <= dealt_fifo_rdata[PERI_ADDR_WIDTH + PERI_BUSRSTS_WIDTH: PERI_BUSRSTS_WIDTH+1];
      dealt_wlen <= dealt_fifo_rdata[PERI_BUSRSTS_WIDTH: 0] - 1;
      dealt_waddr_wen_reg <= 1'b1;
    end
    else begin
      dealt_waddr <= 'd0;
      dealt_wlen <= 'd0;
      dealt_waddr_wen_reg <= 1'b0;
    end
  end
end


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    axi_bvalid <= 1'b0;
  end
  else begin
    if (axi4_full_S_AXI_WLAST && axi4_full_S_AXI_WVALID && axi4_full_S_AXI_WREADY) begin
      axi_bvalid <= 1'b1;
    end
    else if (axi4_full_S_AXI_BREADY) begin
      axi_bvalid <= 1'b0;
    end
  end
end

sync_fifo_regfile #(
  .depth ( AXI_OUTSTANDING_DEPTH * 2 ),
  .width ( AXI_S_AXI_ID_WIDTH        )
) awid_fifo (
.clk      ( axi4_clk                                          ),
.rst_n    ( axi4_rst_n                                        ),
.w_en     ( axi4_full_S_AXI_AWVALID & axi4_full_S_AXI_AWREADY ),
.w_data   ( axi4_full_S_AXI_AWID                              ),
.r_en     ( axi4_full_S_AXI_BVALID & axi4_full_S_AXI_BREADY   ),
.r_data   ( current_bid                                       ),
.hfull    (                                                   ),
.hempty   (                                                   ),
.afull    (                                                   ),
.aempty   (                                                   ),
.full     (                                                   ),
.empty    (                                                   ),
.capacity (                                                   )
);


endmodule

