//File name  :    apb4_w_addr_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/03/29 12:53:45
//Version    :    V1.0
//Abstract   :        


module apb4_w_addr_clk_bridge(
pclk, presetn, 
waddr_S_fifo_addr, waddr_S_fifo_ready, waddr_S_fifo_valid,

peripheral_clk, peripheral_rst_n,
peripheral_S_waddr, peripheral_S_waddr_valid, peripheral_S_waddr_ready
);

//Define parameters:
parameter integer PERIPHERAL_W_BUSRSTS_WIDTH = 8;
parameter integer ASYN_ADDR_FIFO_DEPTH = 8;
parameter integer FIFO_EMPTY_LIMIT = 3;
parameter integer FIFO_FULL_LIMIT = 3;


//Define pins:
input pclk, presetn;
input [31:0] waddr_S_fifo_addr;
input wire waddr_S_fifo_valid;
output waddr_S_fifo_ready;

input peripheral_clk, peripheral_rst_n;
output wire [31:0] peripheral_S_waddr;
input peripheral_S_waddr_valid;
output wire peripheral_S_waddr_ready;


//Define signals:
// wire wfifo_full, wfifo_empty;

// assign waddr_S_fifo_ready = !wfifo_full;
// assign peripheral_S_waddr_ready = !wfifo_empty;

// async_fifo_sram #(
//     .width(32),
//     .depth(ASYN_ADDR_FIFO_DEPTH),
//     .empty_limit(FIFO_EMPTY_LIMIT),
//     .full_limit(FIFO_FULL_LIMIT)
// ) w_addr_len_fifo (
//     .w_clk(pclk),
//     .w_rst_n(presetn),
//     .w_data(waddr_S_fifo_addr),
//     .w_en(waddr_S_fifo_valid),
//     .full(wfifo_full),
//     .r_clk(peripheral_clk),
//     .r_rst_n(peripheral_rst_n), 
//     .r_data(peripheral_S_waddr),
//     .r_en(peripheral_S_waddr_valid),
//     .empty(wfifo_empty)
// );

AsyncAxiFifo8 #(.DATAWIDTH(32)) u_raddr_fifo (
    .CLKU      ( pclk                     ), 
    .RESETUn   ( presetn                  ), 
    .READYU    ( waddr_S_fifo_ready       ),
    .VALIDU    ( waddr_S_fifo_valid       ),
    .DATAU     ( waddr_S_fifo_addr        ),
    .SYNCMODEREQ (1'b0),
    .CLKD      ( peripheral_clk           ),
    .RESETDn   ( peripheral_rst_n         ),
    .READYD    ( peripheral_S_waddr_valid ),
    .VALIDD    ( peripheral_S_waddr_ready ),
    .DATAD     ( peripheral_S_waddr       ), 
    .SYNCMODEACK ()
);


endmodule

