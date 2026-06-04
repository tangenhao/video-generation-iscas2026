module peripheral_r_addr_clk_bridge(
  peripheral_clk, peripheral_rst_n,
  peripheral_M_raddr, peripheral_M_rlen, peripheral_M_raddr_valid, peripheral_M_raddr_ready,

  axi4_clk, axi4_rst_n,
  raddr_M_fifo_addr, raddr_M_fifo_len, raddr_M_fifo_ready, raddr_M_fifo_valid
);

parameter integer PERI_ADDR_WIDTH    = 32;
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
input [PERI_ADDR_WIDTH-1:0]          peripheral_M_raddr;
input [PERI_BUSRSTS_WIDTH-1:0]       peripheral_M_rlen;
input                                peripheral_M_raddr_valid;
output wire                          peripheral_M_raddr_ready;

input                                axi4_clk;
input                                axi4_rst_n;
output wire [PERI_ADDR_WIDTH-1:0]    raddr_M_fifo_addr;
output wire [PERI_BUSRSTS_WIDTH-1:0] raddr_M_fifo_len;
output wire                          raddr_M_fifo_ready;
input                                raddr_M_fifo_valid;

wire [ASYN_ADDR_FIFO_WIDTH-1:0] undeal_r_addrlen;
wire rfifo_full, rfifo_empty;
assign raddr_M_fifo_addr = undeal_r_addrlen[PERI_ADDR_WIDTH+PERI_BUSRSTS_WIDTH-1:PERI_BUSRSTS_WIDTH];
assign raddr_M_fifo_len = undeal_r_addrlen[PERI_BUSRSTS_WIDTH-1:0];

reg peripheral_raddr_valid_delay;

always @(posedge peripheral_clk or negedge peripheral_rst_n) begin
  if(!peripheral_rst_n) begin
    peripheral_raddr_valid_delay <= 1'b0;
  end 
  else if (peripheral_M_raddr_ready) begin
    peripheral_raddr_valid_delay <= peripheral_M_raddr_valid;
  end
end

AsyncAxiFifo8 #(.DATAWIDTH(ASYN_ADDR_FIFO_WIDTH)) u_raddr_fifo (
  .CLKU      ( peripheral_clk                ), 
  .RESETUn   ( peripheral_rst_n              ), 
  .READYU    ( peripheral_M_raddr_ready      ),
  .VALIDU    ( peripheral_M_raddr_valid      ),
  .DATAU     ( {{ASYN_ADDR_ZERO_FIFO_WIDTH{1'b0}}, peripheral_M_raddr, peripheral_M_rlen} ),
  .SYNCMODEREQ (1'b0),
  .CLKD      ( axi4_clk                      ),
  .RESETDn   ( axi4_rst_n                    ),
  .READYD    ( raddr_M_fifo_valid            ),
  .VALIDD    ( raddr_M_fifo_ready            ),
  .DATAD     ( undeal_r_addrlen              ), 
  .SYNCMODEACK ()
);


endmodule
