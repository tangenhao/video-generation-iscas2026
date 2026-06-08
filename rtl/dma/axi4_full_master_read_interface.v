module axi4_full_master_read_interface(
  axi4_clk, axi4_rst_n,

  raddr_M_fifo_addr, raddr_M_fifo_len, raddr_M_fifo_ready, raddr_M_fifo_valid,
  rdata_M_fifo_data, rdata_M_fifo_valid, rdata_M_fifo_ready,

  axi4_full_M_AXI_ARID, axi4_full_M_AXI_ARADDR, axi4_full_M_AXI_ARLEN, 
  axi4_full_M_AXI_ARSIZE, axi4_full_M_AXI_ARBURST, axi4_full_M_AXI_ARLOCK, axi4_full_M_AXI_ARCACHE, axi4_full_M_AXI_ARPROT, axi4_full_M_AXI_ARQOS, axi4_full_M_AXI_ARUSER, 
  axi4_full_M_AXI_ARVALID, axi4_full_M_AXI_ARREADY,
  axi4_full_M_AXI_RID, axi4_full_M_AXI_RDATA, axi4_full_M_AXI_RRESP, axi4_full_M_AXI_RLAST, axi4_full_M_AXI_RUSER, axi4_full_M_AXI_RVALID, axi4_full_M_AXI_RREADY
);

//Define parameters:
parameter integer PERI_ADDR_WIDTH    = 32;
parameter integer PERI_BUSRSTS_WIDTH = 8;
parameter integer PERI_DATA_WIDTH    = 128;

parameter integer AXI_M_AXI_MAX_ID      = 1;
parameter integer AXI_M_AXI_MIN_ID      = 1;
parameter integer AXI_M_AXI_ID_WIDTH	  = 4;
parameter integer AXI_M_AXI_ADDR_WIDTH  = 64;
parameter integer AXI_M_AXI_USER_WIDTH  = 0;
parameter integer AXI_M_AXI_DATA_WIDTH  = 128;
parameter integer AXI_M_AXI_BURSTLENGTH = 128;
parameter integer AXI_OUTSTANDING_DEPTH = 8;

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
input axi4_clk;
input axi4_rst_n;

input       [PERI_ADDR_WIDTH-1:0]    raddr_M_fifo_addr;
input       [PERI_BUSRSTS_WIDTH-1:0] raddr_M_fifo_len;
input                                raddr_M_fifo_ready;
output wire                          raddr_M_fifo_valid;
output wire [PERI_DATA_WIDTH-1:0]    rdata_M_fifo_data;
output wire                          rdata_M_fifo_valid;
input                                rdata_M_fifo_ready;

output wire [AXI_M_AXI_ID_WIDTH-1:0]    axi4_full_M_AXI_ARID;
output wire [AXI_M_AXI_ADDR_WIDTH-1:0]  axi4_full_M_AXI_ARADDR;
output wire [7:0]                       axi4_full_M_AXI_ARLEN;
output wire [2:0]                       axi4_full_M_AXI_ARSIZE;
output wire [1:0]                       axi4_full_M_AXI_ARBURST;
output wire                             axi4_full_M_AXI_ARLOCK;
output wire [3:0]                       axi4_full_M_AXI_ARCACHE;
output wire [2:0]                       axi4_full_M_AXI_ARPROT;
output wire [3:0]                       axi4_full_M_AXI_ARQOS;
output wire [AXI_M_AXI_USER_WIDTH-1:0]  axi4_full_M_AXI_ARUSER;
output wire                             axi4_full_M_AXI_ARVALID;
input                                   axi4_full_M_AXI_ARREADY;
input       [AXI_M_AXI_ID_WIDTH-1:0]    axi4_full_M_AXI_RID;
input       [AXI_M_AXI_DATA_WIDTH-1:0]  axi4_full_M_AXI_RDATA;
input       [1:0]                       axi4_full_M_AXI_RRESP;
input                                   axi4_full_M_AXI_RLAST;
input       [AXI_M_AXI_USER_WIDTH-1:0]  axi4_full_M_AXI_RUSER;
input                                   axi4_full_M_AXI_RVALID;
output wire                             axi4_full_M_AXI_RREADY;

reg [8:0] local_id;

assign axi4_full_M_AXI_ARID    = {3'b0, local_id, 8'b0};
assign axi4_full_M_AXI_ARSIZE  = AXI_M_AXI_DATA_BITS;
assign axi4_full_M_AXI_ARBURST = 2'b01;
assign axi4_full_M_AXI_ARLOCK  = 1'b0;
assign axi4_full_M_AXI_ARCACHE = 4'b0010;
assign axi4_full_M_AXI_ARPROT  = 3'b000;
assign axi4_full_M_AXI_ARQOS   = 4'b0000;
assign axi4_full_M_AXI_ARUSER  = 'd1;

//Define signals:
wire [AXI_M_AXI_ADDR_WIDTH-1:0] aligned_addr;
wire [PERI_BUSRSTS_WIDTH:0]     aligned_len;
reg  [AXI_M_AXI_ADDR_WIDTH-1:0] dealing_addr;
reg  [PERI_BUSRSTS_WIDTH:0]     dealing_len;
reg                             dealing_signal;
reg                             undeal_ren;
// reg undeal_addr_valid;
wire                              dealt_fifo_afull;
reg [OUTSTANDING_FIFO_WIDTH-1:0]  dealt_fifo_wdata;
reg                               dealt_fifo_wen;
wire [OUTSTANDING_FIFO_WIDTH-1:0] dealt_fifo_rdata;
reg                               dealt_fifo_ren;
wire                              dealt_fifo_empty;

assign raddr_M_fifo_valid = undeal_ren;

sync_fifo_sram_128x32 r_addrlen_fifo (
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

wire [AXI_M_AXI_ADDR_WIDTH-1:0] axi_araddr;
wire [7:0] axi_arlen;
reg axi_arvalid;
assign axi4_full_M_AXI_ARADDR = axi_araddr;
assign axi4_full_M_AXI_ARLEN = axi_arlen;
assign axi4_full_M_AXI_ARVALID = axi_arvalid;
wire axi4_rready;
assign axi4_full_M_AXI_RREADY = axi4_rready;

wire [AXI_M_AXI_DATA_WIDTH-1:0] undeal_rdata;
wire undeal_r_datavalid;
wire undeal_r_dataready;
assign undeal_rdata = axi4_full_M_AXI_RDATA;
assign undeal_r_datavalid = axi4_full_M_AXI_RVALID;
assign axi4_rready = undeal_r_dataready;

wire [PERI_DATA_WIDTH-1:0] dealt_rdata;
wire dealt_rdatavalid;
wire dealt_rdataready;
assign rdata_M_fifo_data = dealt_rdata;
assign rdata_M_fifo_valid = dealt_rdatavalid;
assign dealt_rdataready = rdata_M_fifo_ready;

datawidth_convertor #(
  .DATA_IN_WIDTH  ( AXI_M_AXI_DATA_WIDTH ),
  .DATA_OUT_WIDTH ( PERI_DATA_WIDTH       )
) u_datawidth_convertor(
  .clk       ( axi4_clk           ),
  .rst_n     ( axi4_rst_n         ),
  .data_in   ( undeal_rdata       ),
  .valid_in  ( undeal_r_datavalid ),
  .ready_out ( dealt_rdataready   ),
  .ready_in  ( undeal_r_dataready ),
  .data_out  ( dealt_rdata        ),
  .valid_out ( dealt_rdatavalid   )
);

//Edit code:
generate
  if (PERI_ADDR_WIDTH < AXI_M_AXI_ADDR_WIDTH) begin : addr_align_small
    assign aligned_addr = {{AXI4_MINUS_PERIPHERAL_ADDR_WIDTH{1'b0}}, raddr_M_fifo_addr};
  end
  else begin : addr_align_large
    assign aligned_addr = raddr_M_fifo_addr;
  end
endgenerate

generate
  if (PERI_DATA_WIDTH < AXI_M_AXI_DATA_WIDTH) begin : data_align_small
    assign aligned_len = (raddr_M_fifo_len + 1) >> AXI4_DIV_PERIPHERAL_BITS;
  end
  else if (PERI_DATA_WIDTH > AXI_M_AXI_DATA_WIDTH) begin : data_align_large
    assign aligned_len = (raddr_M_fifo_len + 1) << PERIPHERAL_DIV_AXI4_BITS;
  end
  else begin : data_align_equal
    assign aligned_len = (raddr_M_fifo_len + 1);
  end
endgenerate


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if(!axi4_rst_n) begin
    undeal_ren <= 1'b0;
    dealing_signal <= 1'b0;
  end
  else begin

    if (undeal_ren && raddr_M_fifo_ready) begin
      undeal_ren <= 1'b0;
    end
    else begin
      if ((!dealt_fifo_afull) && (!dealing_signal)) begin
        undeal_ren <= 1'b1;
      end
      else begin
        undeal_ren <= 1'b0;
      end
    end

    if (undeal_ren && raddr_M_fifo_ready) begin
      dealing_signal <= 1'b1;
    end
    else if (dealt_fifo_wen && (!(| dealing_len))) begin
      dealing_signal <= 1'b0;
    end
    else begin
      dealing_signal <= dealing_signal;
    end
  end //the end of biggest if
end //the end of always


// always @(posedge axi4_clk or negedge axi4_rst_n) begin
// if(!axi4_rst_n) begin
// undeal_addr_valid <= 1'b0;
// end
// else begin
//     if (undeal_ren && raddr_M_fifo_ready) begin
//         undeal_addr_valid <= 1'b1;
//     end
//     else begin
//         undeal_addr_valid <= 1'b0;
//     end
// end

// end


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if(!axi4_rst_n) begin
    dealing_addr <= 'd0;
    dealing_len <= 'd0;
    dealt_fifo_wdata <= 'd0;
    dealt_fifo_wen <= 1'b0;
  end
  else begin

    // if (undeal_addr_valid) begin
    if (undeal_ren && raddr_M_fifo_ready) begin
      dealing_addr <= aligned_addr;
      dealing_len <= aligned_len;
    end
    else if ((!dealt_fifo_afull) && ((| dealing_len))) begin
      dealing_addr <= iter_addr;
      dealing_len <= dealing_len - iter_len;
    end
    else begin
      dealing_addr <= dealing_addr;
      dealing_len <= dealing_len;
    end

    if ((!dealt_fifo_afull) && ((| dealing_len)) && dealing_signal) begin
      dealt_fifo_wdata <= {{(OUTSTANDING_FIFO_WIDTH - AXI_M_AXI_ADDR_WIDTH - 8){1'b0}}, dealing_addr, iter_true_len[7:0]};
      dealt_fifo_wen <= 1'b1;
    end
    else begin
      dealt_fifo_wdata <= dealt_fifo_wdata;
      dealt_fifo_wen <= 1'b0;
    end
  end //the end of biggest if
end //the end of always


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if(!axi4_rst_n) begin
    dealt_fifo_ren <= 1'b0;
  end
  else begin
    if ((!dealt_fifo_empty) && (!axi_arvalid) && (!dealt_fifo_ren)) begin
      dealt_fifo_ren <= 1'b1;
    end
    else begin
      dealt_fifo_ren <= 1'b0;
    end
  end //the end of biggest if
end //the end of always


always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if(!axi4_rst_n) begin
    axi_arvalid <= 1'b0;
  end
  else begin
    if (dealt_fifo_ren) begin
      axi_arvalid <= 1'b1;
    end
    else if (axi_arvalid && axi4_full_M_AXI_ARREADY) begin
      axi_arvalid <= 1'b0;
    end
    else begin
      axi_arvalid <= axi_arvalid;
    end
  end //the end of biggest if
end //the end of always


assign axi_araddr = dealt_fifo_rdata[AXI_M_AXI_ADDR_WIDTH+8-1:8];
assign axi_arlen = dealt_fifo_rdata[7:0];

always @(posedge axi4_clk or negedge axi4_rst_n) begin
  if (!axi4_rst_n) begin
    local_id <= AXI_M_AXI_MIN_ID;
  end
  else begin
    if (axi_arvalid && axi4_full_M_AXI_ARREADY) begin
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

