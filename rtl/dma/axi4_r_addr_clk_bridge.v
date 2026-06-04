//File name  :    axi4_r_addr_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/03/11 00:41:31
//Version    :    V1.0
//Abstract   :        


module axi4_r_addr_clk_bridge(
  axi4_clk, axi4_rst_n,
  raddr_S_fifo_addr, raddr_S_fifo_len, raddr_S_fifo_ready, raddr_S_fifo_valid,

  peripheral_clk, peripheral_rst_n,
  peripheral_S_raddr, peripheral_S_rlen, peripheral_S_raddr_valid, peripheral_S_raddr_ready
);

//Define parameters:
parameter integer PERI_ADDR_WIDTH = 32;
parameter integer PERI_BUSRSTS_WIDTH = 8;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

localparam integer ASYN_ADDR_FIFO_WIDTH_BITS = clogb2(PERI_ADDR_WIDTH + PERI_BUSRSTS_WIDTH - 1);
localparam integer ASYN_ADDR_FIFO_WIDTH = 1 << ASYN_ADDR_FIFO_WIDTH_BITS;
localparam integer ASYN_ADDR_ZERO_FIFO_WIDTH = ASYN_ADDR_FIFO_WIDTH - PERI_ADDR_WIDTH - PERI_BUSRSTS_WIDTH;


//Define pins:
input                          axi4_clk;
input                          axi4_rst_n;
input [PERI_ADDR_WIDTH-1:0]    raddr_S_fifo_addr;
input [PERI_BUSRSTS_WIDTH-1:0] raddr_S_fifo_len;
input                          raddr_S_fifo_valid;
output wire                    raddr_S_fifo_ready;

input                                peripheral_clk;
input                                peripheral_rst_n;
output wire [PERI_ADDR_WIDTH-1:0]    peripheral_S_raddr;
output wire [PERI_BUSRSTS_WIDTH-1:0] peripheral_S_rlen;
output wire                          peripheral_S_raddr_ready;
input                                peripheral_S_raddr_valid;


//Define signals:
wire [ASYN_ADDR_FIFO_WIDTH-1:0] peripheral_r_addrlen;
wire rfifo_full, rfifo_empty;
assign peripheral_S_raddr = peripheral_r_addrlen[PERI_ADDR_WIDTH+PERI_BUSRSTS_WIDTH-1:PERI_BUSRSTS_WIDTH];
assign peripheral_S_rlen = peripheral_r_addrlen[PERI_BUSRSTS_WIDTH-1:0];

// assign raddr_S_fifo_ready = !rfifo_full;
// assign peripheral_S_raddr_ready = !rfifo_empty;

// async_fifo_sram #(
//     .width(ASYN_ADDR_FIFO_WIDTH),
//     .depth(ASYN_ADDR_FIFO_DEPTH),
//     .empty_limit(FIFO_EMPTY_LIMIT),
//     .full_limit(FIFO_FULL_LIMIT)
// ) r_addr_len_fifo (
//     .w_clk(axi4_clk),
//     .w_rst_n(axi4_rst_n),
//     .w_data({{ASYN_ADDR_ZERO_FIFO_WIDTH{1'b0}}, raddr_S_fifo_addr, raddr_S_fifo_len}),
//     .w_en(raddr_S_fifo_valid),
//     .full(rfifo_full),
//     .r_clk(peripheral_clk),
//     .r_rst_n(peripheral_rst_n), 
//     .r_data(peripheral_r_addrlen),
//     .r_en(peripheral_S_raddr_valid),
//     .empty(rfifo_empty)
// );

AsyncAxiFifo8 #(.DATAWIDTH(ASYN_ADDR_FIFO_WIDTH)) u_raddr_fifo (
  .CLKU      ( axi4_clk                 ), 
  .RESETUn   ( axi4_rst_n               ), 
  .READYU    ( raddr_S_fifo_ready       ),
  .VALIDU    ( raddr_S_fifo_valid       ),
  .DATAU     ( {{ASYN_ADDR_ZERO_FIFO_WIDTH{1'b0}}, raddr_S_fifo_addr, raddr_S_fifo_len}  ),
  .SYNCMODEREQ (1'b0),
  .CLKD      ( peripheral_clk           ),
  .RESETDn   ( peripheral_rst_n         ),
  .READYD    ( peripheral_S_raddr_valid ),
  .VALIDD    ( peripheral_S_raddr_ready ),
  .DATAD     ( peripheral_r_addrlen     ), 
  .SYNCMODEACK ()
);

endmodule

