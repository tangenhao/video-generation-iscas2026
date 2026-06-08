//File name  :    axi4_full_slave_read_interface.v
//Author     :    xiaocuicui
//Time       :    2024/03/10 21:55:35
//Version    :    V1.0
//Abstract   :        


module axi4_full_slave_read_interface(
  axi4_clk, axi4_rst_n,

  raddr_S_fifo_addr, raddr_S_fifo_len, raddr_S_fifo_valid, raddr_S_fifo_ready,
  rdata_S_fifo_data, rdata_S_fifo_ready, rdata_S_fifo_valid,

  axi4_full_S_AXI_ARID, axi4_full_S_AXI_ARADDR, axi4_full_S_AXI_ARLEN, 
  axi4_full_S_AXI_ARSIZE, axi4_full_S_AXI_ARBURST, axi4_full_S_AXI_ARLOCK, axi4_full_S_AXI_ARCACHE, axi4_full_S_AXI_ARPROT, axi4_full_S_AXI_ARQOS, axi4_full_S_AXI_ARUSER, 
  axi4_full_S_AXI_ARVALID, axi4_full_S_AXI_ARREADY,
  axi4_full_S_AXI_RID, axi4_full_S_AXI_RDATA, axi4_full_S_AXI_RRESP, axi4_full_S_AXI_RLAST, axi4_full_S_AXI_RUSER, axi4_full_S_AXI_RVALID, axi4_full_S_AXI_RREADY
);

//Define parameters:
parameter integer PERI_ADDR_WIDTH    = 32;
parameter integer PERI_BUSRSTS_WIDTH = 8;
parameter integer PERI_DATA_WIDTH    = 128;

parameter integer AXI_S_AXI_ID_WIDTH	   = 20;
parameter integer AXI_S_AXI_ADDR_WIDTH = 64;
parameter integer AXI_S_AXI_USER_WIDTH = 1;
parameter integer AXI_S_AXI_DATA_WIDTH	 = 256;

parameter integer AXI_S_AXI_BURSTLENGTH = 32;
parameter integer AXI_OUTSTANDING_DEPTH = 8;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction  

localparam integer OUTSTANDING_FIFO_WIDTH_BITS = clogb2(PERI_ADDR_WIDTH + PERI_BUSRSTS_WIDTH - 1);
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

output wire [PERI_ADDR_WIDTH-1:0]    raddr_S_fifo_addr;
output wire [PERI_BUSRSTS_WIDTH-1:0] raddr_S_fifo_len;
output wire                          raddr_S_fifo_valid;
input                                raddr_S_fifo_ready;
input [PERI_DATA_WIDTH-1:0]          rdata_S_fifo_data;
input                                rdata_S_fifo_ready;
output wire                          rdata_S_fifo_valid;

input       [AXI_S_AXI_ID_WIDTH-1:0]     axi4_full_S_AXI_ARID;
input       [AXI_S_AXI_ADDR_WIDTH-1:0] axi4_full_S_AXI_ARADDR;
input       [7:0]                        axi4_full_S_AXI_ARLEN;
input       [2:0]                        axi4_full_S_AXI_ARSIZE;
input       [1:0]                        axi4_full_S_AXI_ARBURST;
input                                    axi4_full_S_AXI_ARLOCK;
input       [3:0]                        axi4_full_S_AXI_ARCACHE;
input       [2:0]                        axi4_full_S_AXI_ARPROT;
input       [3:0]                        axi4_full_S_AXI_ARQOS;
input       [AXI_S_AXI_USER_WIDTH-1:0] axi4_full_S_AXI_ARUSER;
input                                    axi4_full_S_AXI_ARVALID;
output wire                              axi4_full_S_AXI_ARREADY;
output wire [AXI_S_AXI_ID_WIDTH-1:0]     axi4_full_S_AXI_RID;
output wire [AXI_S_AXI_DATA_WIDTH-1:0]  axi4_full_S_AXI_RDATA;
output wire [1:0]                        axi4_full_S_AXI_RRESP;
output wire                              axi4_full_S_AXI_RLAST;
output wire [AXI_S_AXI_USER_WIDTH-1:0]  axi4_full_S_AXI_RUSER;
output wire                              axi4_full_S_AXI_RVALID;
input                                    axi4_full_S_AXI_RREADY;

wire [AXI_S_AXI_ID_WIDTH-1:0] current_rid;
assign axi4_full_S_AXI_RID = current_rid;
assign axi4_full_S_AXI_RUSER = 'd1;
assign axi4_full_S_AXI_RRESP = 2'b00;


//Define signals:
wire [PERI_ADDR_WIDTH-1:0]  aligned_addr;
wire [PERI_BUSRSTS_WIDTH:0] aligned_len;
wire                                dealt_fifo_afull;
reg  [OUTSTANDING_FIFO_WIDTH-1:0]   dealt_fifo_wdata;
reg                                 dealt_fifo_wen;
wire [OUTSTANDING_FIFO_WIDTH-1:0]   dealt_fifo_rdata;
reg                                 dealt_fifo_ren;
wire                                dealt_fifo_empty;

sync_fifo_sram_64x128 r_addrlen_fifo (
  .clk      ( axi4_clk          ),
  .rst_n    ( axi4_rst_n        ),
  .w_en     ( dealt_fifo_wen    ),
  .w_data   ( dealt_fifo_wdata  ),
  .hfull    (                   ),
  .afull    ( dealt_fifo_afull  ),
  .full     (                   ),
  .r_en     ( dealt_fifo_ren    ),
  .r_data   ( dealt_fifo_rdata  ),
  .hempty   (                   ),
  .aempty   (                   ),
  .empty    ( dealt_fifo_empty  ),
  .capacity (                   )
);

wire         arlen_fifo_afull;
reg [8-1:0]  arlen_fifo_wdata;
reg          arlen_fifo_wen;
wire [8-1:0] arlen_fifo_rdata;
reg          arlen_fifo_ren;
reg          arlen_fifo_rvalid;
wire         arlen_fifo_empty;

sync_fifo_sram_8x128 axi_arlen_fifo (
  .clk     ( axi4_clk         ),
  .rst_n   ( axi4_rst_n       ),
  .w_en    ( arlen_fifo_wen   ),
  .w_data  ( arlen_fifo_wdata ),
  .hfull   (                  ),
  .afull   ( arlen_fifo_afull ),
  .full    (                  ),
  .r_en    ( arlen_fifo_ren   ),
  .r_data  ( arlen_fifo_rdata ),
  .hempty  (                  ),
  .aempty  (                  ),
  .empty   ( arlen_fifo_empty ),
  .capacity(                  )
);

reg       axi_rlast;
reg [8:0] length_counter;
reg [8:0] current_len;

assign axi4_full_S_AXI_ARREADY = !arlen_fifo_afull;
assign axi4_full_S_AXI_RLAST   = axi_rlast & axi4_full_S_AXI_RVALID & axi4_full_S_AXI_RREADY;

wire [PERI_ADDR_WIDTH-1:0]    raddr;
wire [PERI_BUSRSTS_WIDTH-1:0] rlen;
reg                                   raddr_fifo_valid_reg;

assign raddr_S_fifo_addr  = raddr;
assign raddr_S_fifo_len   = rlen;
assign raddr_S_fifo_valid = raddr_fifo_valid_reg;

wire                                   rdata_fifo_data_ready;
wire [AXI_S_AXI_DATA_WIDTH-1:0] rdata;
wire                                   converted_rdata_valid;
wire                                   converted_rdata_ready;

assign axi4_full_S_AXI_RDATA  = rdata;
assign axi4_full_S_AXI_RVALID = converted_rdata_valid;
assign converted_rdata_ready  = axi4_full_S_AXI_RREADY;
assign rdata_S_fifo_valid     = rdata_fifo_data_ready;

datawidth_convertor #(
  .DATA_IN_WIDTH(PERI_DATA_WIDTH),
  .DATA_OUT_WIDTH(AXI_S_AXI_DATA_WIDTH)
) r_data_convertor (
  .clk       ( axi4_clk              ),
  .rst_n     ( axi4_rst_n            ),
  .data_in   ( rdata_S_fifo_data     ), 
  .valid_in  ( rdata_S_fifo_ready    ), 
  .ready_in  ( rdata_fifo_data_ready ), 
  .data_out  ( rdata                 ), 
  .valid_out ( converted_rdata_valid ), 
  .ready_out ( converted_rdata_ready )
);

generate
  if (PERI_ADDR_WIDTH > AXI_S_AXI_ADDR_WIDTH) begin : addr_align_large
    assign aligned_addr = {{PERIPHERAL_MINUS_AXI4_ADDR_WIDTH{1'b0}}, axi4_full_S_AXI_ARADDR};
  end
  else begin : addr_align_small
    assign aligned_addr = axi4_full_S_AXI_ARADDR;
  end
endgenerate

generate
  if (PERI_DATA_WIDTH < AXI_S_AXI_DATA_WIDTH) begin : data_align_large
    assign aligned_len = (axi4_full_S_AXI_ARLEN + 1) >> PERIPHERAL_DIV_AXI4_BITS;
  end
  else if (PERI_DATA_WIDTH > AXI_S_AXI_DATA_WIDTH) begin : data_align_small
    assign aligned_len = (axi4_full_S_AXI_ARLEN + 1) << AXI4_DIV_PERIPHERAL_BITS;
  end
  else begin : data_align_equal
    assign aligned_len = (axi4_full_S_AXI_ARLEN + 1);
  end
endgenerate


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    dealt_fifo_wdata <= 'd0;
    dealt_fifo_wen <= 1'b0;
  end
  else begin
    if (axi4_full_S_AXI_ARVALID && axi4_full_S_AXI_ARREADY) begin
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
    arlen_fifo_wdata <= 'd0;
    arlen_fifo_wen <= 1'b0;
  end
  else begin
    if (axi4_full_S_AXI_ARVALID && axi4_full_S_AXI_ARREADY) begin
      arlen_fifo_wdata <= axi4_full_S_AXI_ARLEN;
      arlen_fifo_wen <= 1'b1;
    end
    else begin
      arlen_fifo_wdata <= 'd0;
      arlen_fifo_wen <= 1'b0;
    end
  end
end


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    dealt_fifo_ren <= 1'b0;
  end
  else begin
    if ((!dealt_fifo_empty) && (!(| length_counter)) && (!dealt_fifo_ren) && (!arlen_fifo_rvalid)) begin
      dealt_fifo_ren <= 1'b1;
    end
    else begin
      dealt_fifo_ren <= 1'b0;
    end
  end
end

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    raddr_fifo_valid_reg <= 1'b0;
  end
  else begin
    if (dealt_fifo_ren) begin
      raddr_fifo_valid_reg <= 1'b1;
    end
    else begin
      if (raddr_S_fifo_valid && raddr_S_fifo_ready) begin
        raddr_fifo_valid_reg <= 1'b0;
      end
      else begin
        raddr_fifo_valid_reg <= raddr_fifo_valid_reg;
      end
    end
  end
end


assign raddr = dealt_fifo_rdata[PERI_ADDR_WIDTH+PERI_BUSRSTS_WIDTH: PERI_BUSRSTS_WIDTH+1];
assign rlen = dealt_fifo_rdata[PERI_BUSRSTS_WIDTH:0] - 1;


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    current_len       <= 'd0;
    length_counter    <= 'd0;
    arlen_fifo_ren    <= 1'b0;
    arlen_fifo_rvalid <= 1'b0;
  end
  else begin
    if ((!arlen_fifo_empty) && (!(| current_len)) && (!arlen_fifo_ren) && (!arlen_fifo_rvalid)) begin
      arlen_fifo_ren <= 1'b1;
    end
    else begin
      arlen_fifo_ren <= 1'b0;
    end

    if (arlen_fifo_ren) begin
      arlen_fifo_rvalid <= arlen_fifo_ren;
    end
    else begin
      arlen_fifo_rvalid <= 1'b0;
    end

    if (arlen_fifo_rvalid) begin
      current_len <= arlen_fifo_rdata + 1;
    end
    else if (axi4_full_S_AXI_RVALID && axi4_full_S_AXI_RREADY && axi4_full_S_AXI_RLAST) begin
      current_len <= 'd0;
    end
    else begin
      current_len <= current_len;
    end

    if (axi4_full_S_AXI_RVALID && axi4_full_S_AXI_RREADY && axi4_full_S_AXI_RLAST) begin
      length_counter <= 'd0;
    end
    else if (axi4_full_S_AXI_RVALID && axi4_full_S_AXI_RREADY) begin
      length_counter <= length_counter + 1;
    end
    else begin
      length_counter <= length_counter;
    end
  end
end

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    axi_rlast <= 1'b0;
  end
  else begin
    if (axi_rlast && axi4_full_S_AXI_RVALID && axi4_full_S_AXI_RREADY) begin
      axi_rlast <= 1'b0;
    end
    else begin
      if ((current_len == 1) || ((current_len != 1)) && (length_counter == current_len - 2)) begin
        axi_rlast <= 1'b1;
      end
      else begin
        axi_rlast <= axi_rlast;
      end
    end
  end
end

sync_fifo_regfile #(
  .depth ( AXI_OUTSTANDING_DEPTH * 2 ),
  .width ( AXI_S_AXI_ID_WIDTH        )
) arid_fifo (
  .clk      ( axi4_clk                                                                ),
  .rst_n    ( axi4_rst_n                                                              ),
  .w_en     ( axi4_full_S_AXI_ARVALID & axi4_full_S_AXI_ARREADY                       ),
  .w_data   ( axi4_full_S_AXI_ARID                                                    ),
  .r_en     ( axi4_full_S_AXI_RLAST & axi4_full_S_AXI_RVALID & axi4_full_S_AXI_RREADY ),
  .r_data   ( current_rid                                                             ),
  .hfull    (                                                                         ),
  .hempty   (                                                                         ),
  .afull    (                                                                         ),
  .aempty   (                                                                         ),
  .full     (                                                                         ),
  .empty    (                                                                         ),
  .capacity (                                                                         )
);

endmodule

