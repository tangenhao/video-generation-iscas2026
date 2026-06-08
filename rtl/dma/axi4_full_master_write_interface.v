module axi4_full_master_write_interface(
  axi4_clk, axi4_rst_n,

  waddr_M_fifo_addr, waddr_M_fifo_len, waddr_M_fifo_ready, waddr_M_fifo_valid,
  wdata_M_fifo_data, wdata_M_fifo_ready, wdata_M_fifo_valid,

  axi4_full_M_AXI_AWID, axi4_full_M_AXI_AWADDR, axi4_full_M_AXI_AWLEN,
  axi4_full_M_AXI_AWSIZE, axi4_full_M_AXI_AWBURST, axi4_full_M_AXI_AWLOCK, axi4_full_M_AXI_AWCACHE, axi4_full_M_AXI_AWPROT, axi4_full_M_AXI_AWQOS, axi4_full_M_AXI_AWUSER,
  axi4_full_M_AXI_AWVALID, axi4_full_M_AXI_AWREADY,
  axi4_full_M_AXI_WDATA, axi4_full_M_AXI_WSTRB, axi4_full_M_AXI_WLAST, axi4_full_M_AXI_WUSER, axi4_full_M_AXI_WVALID, axi4_full_M_AXI_WREADY,
  axi4_full_M_AXI_BID, axi4_full_M_AXI_BRESP, axi4_full_M_AXI_BUSER, axi4_full_M_AXI_BVALID, axi4_full_M_AXI_BREADY,

  wdata_M_fifo_bvalid, wdata_M_fifo_bready,
  axi_transfer_done
);

//Define parameters:
parameter integer PERI_ADDR_WIDTH    = 32;
parameter integer PERI_BUSRSTS_WIDTH = 8;
parameter integer PERI_DATA_WIDTH    = 128;

parameter integer AXI_M_AXI_MAX_ID       = 1;
parameter integer AXI_M_AXI_MIN_ID       = 1;
parameter integer AXI_M_AXI_ID_WIDTH	   = 4;
parameter integer AXI_M_AXI_ADDR_WIDTH   = 64;
parameter integer AXI_M_AXI_USER_WIDTH   = 1;
parameter integer AXI_M_AXI_DATA_WIDTH	 = 128;
parameter integer AXI_M_AXI_BURSTLENGTH  = 256;
parameter integer AXI_OUTSTANDING_DEPTH  = 8;

function integer clogb2 (input integer bit_depth);
begin
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
  bit_depth = bit_depth >> 1; 
end
endfunction 

localparam integer OUTSTANDING_FIFO_WIDTH_BITS = clogb2(AXI_M_AXI_ADDR_WIDTH + 8 - 1);
localparam integer OUTSTANDING_FIFO_WIDTH      = 1 << OUTSTANDING_FIFO_WIDTH_BITS;

localparam integer PERIPHERAL_MINUS_AXI4_ADDR_WIDTH = PERI_ADDR_WIDTH - AXI_M_AXI_ADDR_WIDTH;
localparam integer AXI4_MINUS_PERIPHERAL_ADDR_WIDTH = AXI_M_AXI_ADDR_WIDTH - PERI_ADDR_WIDTH;

localparam integer PERIPHERAL_DATA_BYTES      = PERI_DATA_WIDTH / 8;
localparam integer PERIPHERAL_DATA_BITS       = clogb2(PERIPHERAL_DATA_BYTES - 1);
localparam integer AXI_M_AXI_DATA_BYTES = AXI_M_AXI_DATA_WIDTH / 8;
localparam integer AXI_M_AXI_DATA_BITS  = clogb2(AXI_M_AXI_DATA_BYTES - 1);

localparam integer PERIPHERAL_DIV_AXI4_BITS  = PERIPHERAL_DATA_BITS - AXI_M_AXI_DATA_BITS;
localparam integer PERIPHERAL_DIV_AXI4_BYTES = PERIPHERAL_DATA_BYTES >> AXI_M_AXI_DATA_BITS;
localparam integer AXI4_DIV_PERIPHERAL_BITS  = AXI_M_AXI_DATA_BITS - PERIPHERAL_DATA_BITS;
localparam integer AXI4_DIV_PERIPHERAL_BYTES = AXI_M_AXI_DATA_BYTES >> PERIPHERAL_DATA_BITS;


//Define pins:
input axi4_clk, axi4_rst_n;

input       [PERI_ADDR_WIDTH-1:0]    waddr_M_fifo_addr;
input       [PERI_BUSRSTS_WIDTH-1:0] waddr_M_fifo_len;
input                                waddr_M_fifo_ready;
output wire                          waddr_M_fifo_valid;
input       [PERI_DATA_WIDTH-1:0]    wdata_M_fifo_data;
input                                wdata_M_fifo_ready;
output wire                          wdata_M_fifo_valid;
output reg                           axi_transfer_done;

output wire wdata_M_fifo_bvalid;
input       wdata_M_fifo_bready;

output wire [AXI_M_AXI_ID_WIDTH-1:0]   axi4_full_M_AXI_AWID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0] axi4_full_M_AXI_AWADDR;
output wire [7:0]                      axi4_full_M_AXI_AWLEN;
output wire [2:0]                      axi4_full_M_AXI_AWSIZE;
output wire [1:0]                      axi4_full_M_AXI_AWBURST;
output wire                            axi4_full_M_AXI_AWLOCK;
output wire [3:0]                      axi4_full_M_AXI_AWCACHE;
output wire [2:0]                      axi4_full_M_AXI_AWPROT;
output wire [3:0]                      axi4_full_M_AXI_AWQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_AWUSER;
output wire                            axi4_full_M_AXI_AWVALID;
input                                  axi4_full_M_AXI_AWREADY;
output wire [AXI_M_AXI_DATA_WIDTH-1:0] axi4_full_M_AXI_WDATA;
output wire [AXI_M_AXI_DATA_BYTES-1:0] axi4_full_M_AXI_WSTRB;
output wire                            axi4_full_M_AXI_WLAST;
output wire [AXI_M_AXI_USER_WIDTH-1:0] axi4_full_M_AXI_WUSER;
output wire                            axi4_full_M_AXI_WVALID;
input                                  axi4_full_M_AXI_WREADY;
input [AXI_M_AXI_ID_WIDTH-1:0]         axi4_full_M_AXI_BID;
input [1:0]                            axi4_full_M_AXI_BRESP;
input [AXI_M_AXI_USER_WIDTH-1:0]       axi4_full_M_AXI_BUSER;
input                                  axi4_full_M_AXI_BVALID;
output wire                            axi4_full_M_AXI_BREADY;

reg [8:0] local_id;

assign axi4_full_M_AXI_AWID    = {3'b0, local_id, 8'b0};;
assign axi4_full_M_AXI_AWSIZE  = AXI_M_AXI_DATA_BITS;
assign axi4_full_M_AXI_AWBURST = 2'b01;
assign axi4_full_M_AXI_AWLOCK  = 1'b0;
assign axi4_full_M_AXI_AWCACHE = 4'b0010;
assign axi4_full_M_AXI_AWPROT  = 3'b000;
assign axi4_full_M_AXI_AWQOS   = 4'b0000;
assign axi4_full_M_AXI_AWUSER  = 'd1;

assign axi4_full_M_AXI_WSTRB = {AXI_M_AXI_DATA_BYTES{1'b1}};
assign axi4_full_M_AXI_WUSER = 'd1;

assign axi4_full_M_AXI_BREADY = wdata_M_fifo_bready;
assign wdata_M_fifo_bvalid = axi4_full_M_AXI_BVALID;

//Define signals:
reg  [AXI_M_AXI_ADDR_WIDTH-1:0]    aligned_addr;
reg  [PERI_BUSRSTS_WIDTH:0]        aligned_len;
reg  [AXI_M_AXI_ADDR_WIDTH-1:0]    dealing_addr;
reg  [PERI_BUSRSTS_WIDTH:0]        dealing_len;
reg                                dealing_signal;
reg                                undeal_addrfifo_ren;
reg                                undeal_waddrfifo_valid;
wire                               dealt_fifo_afull;
reg  [OUTSTANDING_FIFO_WIDTH-1:0]  dealt_fifo_wdata;
reg                                dealt_fifo_wen;
wire [OUTSTANDING_FIFO_WIDTH-1:0]  dealt_fifo_rdata;
reg                                dealt_fifo_ren;
reg                                dealt_fifo_rvalid;
wire                               dealt_fifo_empty;

assign waddr_M_fifo_valid = undeal_addrfifo_ren;

sync_fifo_sram_128x32 w_addrlen_fifo (
  .clk      ( axi4_clk         ),
  .rst_n    ( axi4_rst_n       ),
  .w_en     ( dealt_fifo_wen   ),
  .w_data   ( dealt_fifo_wdata ),
  .hfull    (                  ),
  .afull    ( dealt_fifo_afull ),
  .full     (                  ),
  .r_en     ( dealt_fifo_ren   ),
  .r_data   ( dealt_fifo_rdata ),
  .hempty   (                  ),
  .aempty   (                  ),
  .empty    ( dealt_fifo_empty ),
  .capacity (                  )
);

wire handshake_fifo_empty;

wire rest_flag, boundary_burst_flag, boundary_rest_flag;
wire [AXI_M_AXI_ADDR_WIDTH-1:0] burstlen_addr, boundary_addr, rest_addr, iter_addr;
wire [8:0] burstlen_len, boundary_len, rest_len, iter_len, iter_true_len;
assign burstlen_addr = dealing_addr + (AXI_M_AXI_BURSTLENGTH << AXI_M_AXI_DATA_BITS);
assign burstlen_len = AXI_M_AXI_BURSTLENGTH;
wire [AXI_M_AXI_ADDR_WIDTH-13:0] boundary_addr_high;
assign boundary_addr_high = dealing_addr[AXI_M_AXI_ADDR_WIDTH-1:12] + 1;
assign boundary_addr = {boundary_addr_high, 12'd0};
assign boundary_len = (13'd4096 - dealing_addr[11:0]) >> AXI_M_AXI_DATA_BITS;
assign rest_addr = dealing_addr;
assign rest_len = dealing_len;
assign rest_flag = (dealing_len > AXI_M_AXI_BURSTLENGTH)? 1'b0: 1'b1;
assign boundary_burst_flag = (boundary_len > AXI_M_AXI_BURSTLENGTH)? 1'b0: 1'b1;
assign boundary_rest_flag = (boundary_len > dealing_len)? 1'b0: 1'b1;
assign iter_addr = ({AXI_M_AXI_ADDR_WIDTH{({rest_flag, boundary_rest_flag} == 2'b11)}} & boundary_addr) 
                 | ({AXI_M_AXI_ADDR_WIDTH{({rest_flag, boundary_rest_flag} == 2'b10)}} & rest_addr) 
                 | ({AXI_M_AXI_ADDR_WIDTH{({rest_flag, boundary_burst_flag} == 2'b01)}} & boundary_addr) 
                 | ({AXI_M_AXI_ADDR_WIDTH{({rest_flag, boundary_burst_flag} == 2'b00)}} & burstlen_addr);
assign iter_len = ({8{({rest_flag, boundary_rest_flag} == 2'b11)}} & boundary_len) 
                | ({8{({rest_flag, boundary_rest_flag} == 2'b10)}} & rest_len) 
                | ({8{({rest_flag, boundary_burst_flag} == 2'b01)}} & boundary_len) 
                | ({8{({rest_flag, boundary_burst_flag} == 2'b00)}} & burstlen_len);
assign iter_true_len = iter_len - 1;

reg                                     bursting;
reg  [AXI_M_AXI_ADDR_WIDTH-1:0] axi_awaddr;
reg  [7:0]                              axi_awlen;
reg                                     axi_awvalid;
wire                                    axi_wvalid;
reg  [8:0]                              last_cnt;
reg                                     axi_wlast;

assign axi4_full_M_AXI_AWADDR  = axi_awaddr;
assign axi4_full_M_AXI_AWLEN   = axi_awlen;
assign axi4_full_M_AXI_AWVALID = axi_awvalid;
assign axi4_full_M_AXI_WVALID = axi_wvalid;
assign axi4_full_M_AXI_WLAST = axi_wlast & axi_wvalid;

reg wdata_fifo_ren_reg;
reg wdata_fifo_rvalid;

wire [PERI_DATA_WIDTH-1:0] undeal_handshake_wdata;
wire                       undeal_handshake_wen;
wire                       wdata_handshake_hfull;
wire                       undeal_handshake_wenable;

assign undeal_handshake_wdata   = wdata_M_fifo_data;
assign undeal_handshake_wen     = undeal_handshake_wenable && wdata_M_fifo_ready;
assign undeal_handshake_wenable = !wdata_handshake_hfull;

wire [PERI_DATA_WIDTH-1:0] undeal_handshake_rdata;
wire                       undeal_handshake_ren;
wire                       wdata_handshake_empty;
wire                       undeal_handshake_rvalid;

assign undeal_handshake_rvalid = !wdata_handshake_empty;
assign wdata_M_fifo_valid = undeal_handshake_wenable && wdata_M_fifo_ready;

sync_fifo_regfile #(
  .width ( PERI_DATA_WIDTH ),
  .depth ( 8               )
) wdata_handshake (
  .clk      ( axi4_clk                ),
  .rst_n    ( axi4_rst_n              ),
  .w_en     ( undeal_handshake_wen    ),
  .w_data   ( undeal_handshake_wdata  ),
  .hfull    ( wdata_handshake_hfull   ),
  .afull    (                         ),
  .full     (                         ),
  .r_en     ( undeal_handshake_ren    ),
  .r_data   ( undeal_handshake_rdata  ),
  .hempty   (                         ),
  .aempty   (                         ),
  .empty    ( wdata_handshake_empty   ),
  .capacity (                         )
);

wire [PERI_DATA_WIDTH-1:0]       undeal_convertor_data;
wire                             undeal_convertor_ready;
wire [AXI_M_AXI_DATA_WIDTH-1:0] dealt_convertor_data;
wire                             dealt_convertor_valid;
wire                             dealt_convertor_ready;

assign undeal_handshake_ren  = undeal_convertor_ready & undeal_handshake_rvalid & bursting;
assign axi4_full_M_AXI_WDATA = dealt_convertor_data;
assign axi_wvalid            = dealt_convertor_valid & bursting;
assign dealt_convertor_ready = axi4_full_M_AXI_WREADY;

datawidth_convertor #(
  .DATA_IN_WIDTH  ( PERI_DATA_WIDTH       ),
  .DATA_OUT_WIDTH ( AXI_M_AXI_DATA_WIDTH )
) w_data_convertor (
  .clk       ( axi4_clk                ),
  .rst_n     ( axi4_rst_n              ),
  .data_in   ( undeal_handshake_rdata  ), 
  .valid_in  ( undeal_handshake_rvalid ), 
  .ready_in  ( undeal_convertor_ready  ), 
  .data_out  ( dealt_convertor_data    ), 
  .valid_out ( dealt_convertor_valid   ), 
  .ready_out ( dealt_convertor_ready   )
);

//Edit code:
generate
  if (PERI_ADDR_WIDTH < AXI_M_AXI_ADDR_WIDTH) begin : adder_align_small
    // assign aligned_addr = {{AXI4_MINUS_PERIPHERAL_ADDR_WIDTH{1'b0}}, waddr_M_fifo_addr};
    always @(posedge axi4_clk or negedge axi4_rst_n) begin
      if (!axi4_rst_n) begin
        aligned_addr <= 'd0;
      end
      else begin
        aligned_addr <= {{AXI4_MINUS_PERIPHERAL_ADDR_WIDTH{1'b0}}, waddr_M_fifo_addr};
      end
    end
  end
  else begin : adder_align_large
    // assign aligned_addr = waddr_M_fifo_addr;
    always @(posedge axi4_clk or negedge axi4_rst_n) begin
      if (!axi4_rst_n) begin
        aligned_addr <= 'd0;
      end
      else begin
        aligned_addr <= waddr_M_fifo_addr;
      end
    end
  end
endgenerate

generate
  if (PERI_DATA_WIDTH < AXI_M_AXI_DATA_WIDTH) begin : data_align_small
    // assign aligned_len = (waddr_M_fifo_len + 1) >> AXI4_DIV_PERIPHERAL_BITS;
    always @(posedge axi4_clk or negedge axi4_rst_n) begin
      if (!axi4_rst_n) begin
        aligned_len <= 'd0;
      end
      else begin
        aligned_len <= (waddr_M_fifo_len + 1) >> AXI4_DIV_PERIPHERAL_BITS;
      end
    end
  end
  else if (PERI_DATA_WIDTH > AXI_M_AXI_DATA_WIDTH) begin : data_align_large
    // assign aligned_len = (waddr_M_fifo_len + 1) << PERIPHERAL_DIV_AXI4_BITS;
    always @(posedge axi4_clk or negedge axi4_rst_n) begin
      if (!axi4_rst_n) begin
        aligned_len <= 'd0;
      end
      else begin
        aligned_len <= (waddr_M_fifo_len + 1) << PERIPHERAL_DIV_AXI4_BITS;
      end
    end
  end
  else begin : data_align_equal
    // assign aligned_len = (waddr_M_fifo_len + 1);
    always @(posedge axi4_clk or negedge axi4_rst_n) begin
      if (!axi4_rst_n) begin
        aligned_len <= 'd0;
      end
      else begin
        aligned_len <= (waddr_M_fifo_len + 1);
      end
    end
  end
endgenerate


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if(!axi4_rst_n) begin
    undeal_addrfifo_ren <= 1'b0;
    undeal_waddrfifo_valid <= 1'b0;
    dealing_signal <= 1'b0;
  end
  else begin
    if ((!dealt_fifo_afull) && (waddr_M_fifo_ready) && (!dealing_signal) && (!undeal_addrfifo_ren) && (!undeal_waddrfifo_valid)) begin
      undeal_addrfifo_ren <= 1'b1;
    end
    else begin
      undeal_addrfifo_ren <= 1'b0;
    end

    if (undeal_addrfifo_ren && waddr_M_fifo_ready) begin
      undeal_waddrfifo_valid <= 1'b1;
    end
    else begin
      undeal_waddrfifo_valid <= 1'b0;
    end

    if (undeal_addrfifo_ren && waddr_M_fifo_ready) begin
      dealing_signal <= 1'b1;
    end
    else if (dealt_fifo_wen && (!(| dealing_len))) begin
      dealing_signal <= 1'b0;
    end
    else begin
      dealing_signal <= dealing_signal;
    end
  end
end


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if(!axi4_rst_n) begin
    dealing_addr <= 'd0;
    dealing_len <= 'd0;
    dealt_fifo_wdata <= 'd0;
    dealt_fifo_wen <= 1'b0;
  end
  else begin

    if (undeal_waddrfifo_valid) begin
      dealing_addr <= aligned_addr;
      dealing_len <= aligned_len;
    end
    else if ((!dealt_fifo_afull) && (| dealing_len)) begin
      dealing_addr <= iter_addr;
      dealing_len <= dealing_len - iter_len;
    end
    else begin
      dealing_addr <= dealing_addr;
      dealing_len <= dealing_len;
    end

    if ((!dealt_fifo_afull) && (| dealing_len) && dealing_signal) begin
      dealt_fifo_wdata <= {{(OUTSTANDING_FIFO_WIDTH - AXI_M_AXI_ADDR_WIDTH - 8){1'b0}}, dealing_addr, iter_true_len[7:0]};
      dealt_fifo_wen <= 1'b1;
    end
    else begin
      dealt_fifo_wdata <= dealt_fifo_wdata;
      dealt_fifo_wen <= 1'b0;
    end
  end 
end 


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if(!axi4_rst_n) begin
    dealt_fifo_ren <= 1'b0;
    dealt_fifo_rvalid <= 1'b0;
  end
  else begin

    if ((!dealt_fifo_empty) && (!axi_awvalid) && (!dealt_fifo_ren) && !(dealt_fifo_rvalid) && (!(| last_cnt))) begin
      dealt_fifo_ren <= 1'b1;
    end
    else begin
      dealt_fifo_ren <= 1'b0;
    end

    if (dealt_fifo_ren) begin
      dealt_fifo_rvalid <= 1'b1;
    end
    else begin
      dealt_fifo_rvalid <= 1'b0;
    end 
  end 
end 

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if(!axi4_rst_n) begin
    axi_awaddr <= 'd0;
    axi_awlen <= 'd0;
    axi_awvalid <= 1'b0;
  end
  else begin

    if (dealt_fifo_rvalid) begin
      axi_awaddr <= dealt_fifo_rdata[AXI_M_AXI_ADDR_WIDTH + 8 - 1:8];
      axi_awlen <= dealt_fifo_rdata[7:0];
      axi_awvalid <= 1'b1;
    end
    else if (axi_awvalid && axi4_full_M_AXI_AWREADY) begin
      axi_awaddr <= 'd0;
      axi_awlen <= 'd0;
      axi_awvalid <= 1'b0;
    end
    else begin
      axi_awaddr <= axi_awaddr;
      axi_awlen <= axi_awlen;
      axi_awvalid <= axi_awvalid;
    end
  end 
end 

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    bursting <= 1'b0;
  end
  else begin

    if (axi_awvalid && axi4_full_M_AXI_AWREADY) begin
      bursting <= 1'b1;
    end
    else begin
      if (((last_cnt == 'd1) && (|dealt_fifo_rdata[7:0]) && axi4_full_M_AXI_WREADY && axi_wvalid) || 
          (!(|dealt_fifo_rdata[7:0])) && axi_wvalid && axi4_full_M_AXI_WREADY) begin
        bursting <= 1'b0;
      end
      else begin
        bursting <= bursting;
      end
    end

  end
end


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    last_cnt <= 9'd0;
    axi_wlast <= 1'b0;
  end
  else begin

    if (dealt_fifo_rvalid) begin
      last_cnt <= dealt_fifo_rdata[7:0] + 1;
    end
    else if (bursting && axi_wvalid && axi4_full_M_AXI_WREADY) begin
      last_cnt <= last_cnt - 1;
    end
    else begin
      last_cnt <= last_cnt;
    end

    if (((last_cnt == 'd1) && (axi_awvalid && axi4_full_M_AXI_AWREADY)) || ((last_cnt == 'd2) && (!axi_awvalid) && (axi_wvalid && axi4_full_M_AXI_WREADY))) begin
      axi_wlast <= 1'b1;
    end
    else if (axi_wvalid && axi4_full_M_AXI_WREADY) begin
      axi_wlast <= 1'b0;
    end
    else begin
      axi_wlast <= axi_wlast;
    end
  end
end

reg [7:0] aw_cnt;
reg [7:0] b_cnt;

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    aw_cnt <= 8'd0;
    b_cnt <= 8'd0;
    axi_transfer_done <= 1'b0;
  end
  else begin
    if (dealt_fifo_rvalid) begin
      aw_cnt <= aw_cnt + 1;
    end

    if (axi4_full_M_AXI_BVALID && axi4_full_M_AXI_BREADY) begin
      b_cnt <= b_cnt + 1;
    end

    if (aw_cnt == b_cnt) begin
      axi_transfer_done <= 1'b1;
    end
    else begin
      axi_transfer_done <= 1'b0;
    end
  end
end

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    local_id <= AXI_M_AXI_MIN_ID;
  end
  else begin
    if (axi_awvalid && axi4_full_M_AXI_AWREADY) begin
      if (local_id == AXI_M_AXI_MAX_ID - 1) begin
        local_id <= AXI_M_AXI_MIN_ID;
      end
      else begin
        local_id <= local_id + 1;
      end
    end
  end
end

endmodule

