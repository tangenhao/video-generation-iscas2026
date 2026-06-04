//File name  :    peripheral_w_addr_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/01/11 22:38:47
//Version    :    V1.0
//Abstract   :        


module peripheral_w_addr_clk_bridge(
  peripheral_clk, peripheral_rst_n,
  peripheral_M_waddr, peripheral_M_wlen, peripheral_M_waddr_valid, peripheral_M_waddr_ready,

  axi4_clk, axi4_rst_n,
  waddr_M_fifo_addr, waddr_M_fifo_len, waddr_M_fifo_ready, waddr_M_fifo_valid
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
input                                peripheral_clk;
input                                peripheral_rst_n;
input [PERI_ADDR_WIDTH-1:0]          peripheral_M_waddr;
input [PERI_BUSRSTS_WIDTH-1:0]       peripheral_M_wlen;
input                                peripheral_M_waddr_valid;
output wire                          peripheral_M_waddr_ready;

input                                axi4_clk;
input                                axi4_rst_n;
output wire [PERI_ADDR_WIDTH-1:0]    waddr_M_fifo_addr;
output wire [PERI_BUSRSTS_WIDTH-1:0] waddr_M_fifo_len;
output wire                          waddr_M_fifo_ready;
input                                waddr_M_fifo_valid;

//Define signals:
wire [ASYN_ADDR_FIFO_WIDTH-1:0] undeal_w_addrlen;
wire wfifo_full, wfifo_empty;
assign waddr_M_fifo_addr = undeal_w_addrlen[PERI_ADDR_WIDTH+PERI_BUSRSTS_WIDTH-1:PERI_BUSRSTS_WIDTH];
assign waddr_M_fifo_len = undeal_w_addrlen[PERI_BUSRSTS_WIDTH-1:0];

AsyncAxiFifo8 #(.DATAWIDTH(ASYN_ADDR_FIFO_WIDTH)) u_raddr_fifo (
  .CLKU      ( peripheral_clk            ), 
  .RESETUn   ( peripheral_rst_n          ), 
  .READYU    ( peripheral_M_waddr_ready  ),
  .VALIDU    ( peripheral_M_waddr_valid  ),
  .DATAU     ( {{ASYN_ADDR_ZERO_FIFO_WIDTH{1'b0}}, peripheral_M_waddr, peripheral_M_wlen}        ),
  .SYNCMODEREQ (1'b0),       
  .CLKD      ( axi4_clk                  ),
  .RESETDn   ( axi4_rst_n                ),
  .READYD    ( waddr_M_fifo_valid        ),
  .VALIDD    ( waddr_M_fifo_ready        ),
  .DATAD     ( undeal_w_addrlen          ), 
  .SYNCMODEACK ()
);


endmodule
