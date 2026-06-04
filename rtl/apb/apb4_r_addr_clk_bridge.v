//File name  :    apb4_r_addr_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/03/29 12:53:20
//Version    :    V1.0
//Abstract   :        


module apb4_r_addr_clk_bridge(
pclk, presetn,
raddr_S_fifo_addr, raddr_S_fifo_valid, raddr_S_fifo_ready,

peripheral_clk, peripheral_rst_n,
peripheral_S_raddr, peripheral_S_raddr_valid, peripheral_S_raddr_ready
);

//Define parameters:
parameter integer PERIPHERAL_R_BUSRSTS_WIDTH = 8;
parameter integer ASYN_ADDR_FIFO_DEPTH = 8;
parameter integer FIFO_EMPTY_LIMIT = 3;
parameter integer FIFO_FULL_LIMIT = 3;


//Define pins:
input pclk, presetn;
input [31:0] raddr_S_fifo_addr;
input raddr_S_fifo_valid;
output wire raddr_S_fifo_ready;

input peripheral_clk, peripheral_rst_n;
output wire [31:0] peripheral_S_raddr;
output wire peripheral_S_raddr_ready;
input peripheral_S_raddr_valid;


//Define signals:
// wire rfifo_full, rfifo_empty;
// assign raddr_S_fifo_ready = !rfifo_full;
// assign peripheral_S_raddr_ready = !rfifo_empty;

// async_fifo_sram #(
//     .width(32),
//     .depth(ASYN_ADDR_FIFO_DEPTH),
//     .empty_limit(FIFO_EMPTY_LIMIT),
//     .full_limit(FIFO_FULL_LIMIT)
// ) r_addr_len_fifo (
//     .w_clk(pclk),
//     .w_rst_n(presetn),
//     .w_data(raddr_S_fifo_addr),
//     .w_en(raddr_S_fifo_valid),
//     .full(rfifo_full),
//     .r_clk(peripheral_clk),
//     .r_rst_n(peripheral_rst_n), 
//     .r_data(peripheral_S_raddr),
//     .r_en(peripheral_S_raddr_valid),
//     .empty(rfifo_empty)
// );

AsyncAxiFifo8 #(.DATAWIDTH(32)) u_raddr_fifo (
    .CLKU      ( pclk                     ), 
    .RESETUn   ( presetn                  ), 
    .READYU    ( raddr_S_fifo_ready       ),
    .VALIDU    ( raddr_S_fifo_valid       ),
    .DATAU     ( raddr_S_fifo_addr        ),
    .SYNCMODEREQ (1'b0),
    .CLKD      ( peripheral_clk           ),
    .RESETDn   ( peripheral_rst_n         ),
    .READYD    ( peripheral_S_raddr_valid ),
    .VALIDD    ( peripheral_S_raddr_ready ),
    .DATAD     ( peripheral_S_raddr       ), 
    .SYNCMODEACK ()
);


endmodule

