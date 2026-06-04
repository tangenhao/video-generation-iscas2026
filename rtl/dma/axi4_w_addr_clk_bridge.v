module axi4_w_addr_clk_bridge(
  axi4_clk, axi4_rst_n,
  waddr_S_fifo_addr, waddr_S_fifo_len, waddr_S_fifo_ready, waddr_S_fifo_valid,

  peripheral_clk, peripheral_rst_n,
  peripheral_S_waddr, peripheral_S_wlen, peripheral_S_waddr_valid, peripheral_S_waddr_ready
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
input [PERI_ADDR_WIDTH-1:0]    waddr_S_fifo_addr;
input [PERI_BUSRSTS_WIDTH-1:0] waddr_S_fifo_len;
input                          waddr_S_fifo_valid;
output wire                    waddr_S_fifo_ready;

input                                peripheral_clk;
input                                peripheral_rst_n;
output wire [PERI_ADDR_WIDTH-1:0]    peripheral_S_waddr;
output wire [PERI_BUSRSTS_WIDTH-1:0] peripheral_S_wlen;
output wire                          peripheral_S_waddr_ready;
input                                peripheral_S_waddr_valid;


//Define signals:
wire [ASYN_ADDR_FIFO_WIDTH-1:0] peripheral_w_addrlen;
wire wfifo_full, wfifo_empty;
assign peripheral_S_waddr = peripheral_w_addrlen[PERI_ADDR_WIDTH+PERI_BUSRSTS_WIDTH-1:PERI_BUSRSTS_WIDTH];
assign peripheral_S_wlen = peripheral_w_addrlen[PERI_BUSRSTS_WIDTH-1:0];

AsyncAxiFifo8 #(.DATAWIDTH(ASYN_ADDR_FIFO_WIDTH)) u_waddr_fifo (
  .CLKU      ( axi4_clk                 ), 
  .RESETUn   ( axi4_rst_n               ), 
  .READYU    ( waddr_S_fifo_ready       ),
  .VALIDU    ( waddr_S_fifo_valid       ),
  .DATAU     ( {{ASYN_ADDR_ZERO_FIFO_WIDTH{1'b0}}, waddr_S_fifo_addr, waddr_S_fifo_len}  ),
  .SYNCMODEREQ (1'b0),
  .CLKD      ( peripheral_clk           ),
  .RESETDn   ( peripheral_rst_n         ),
  .READYD    ( peripheral_S_waddr_valid ),
  .VALIDD    ( peripheral_S_waddr_ready ),
  .DATAD     ( peripheral_w_addrlen     ), 
  .SYNCMODEACK ()
);


endmodule

