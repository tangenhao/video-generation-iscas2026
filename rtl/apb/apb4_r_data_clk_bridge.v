//File name  :    apb4_r_data_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/03/29 12:53:35
//Version    :    V1.0
//Abstract   :        


module apb4_r_data_clk_bridge(
peripheral_clk, peripheral_rst_n,
peripheral_S_rdata, peripheral_S_rdata_valid, peripheral_S_rdata_ready,

pclk, presetn,
rdata_S_fifo_data, rdata_S_fifo_ready, rdata_S_fifo_valid
);

//Define parameters:
parameter integer ASYN_DATA_FIFO_DEPTH = 8;
parameter integer FIFO_EMPTY_LIMIT = 3;
parameter integer FIFO_FULL_LIMIT = 3;


//Define pins:
input peripheral_clk, peripheral_rst_n;
input [31:0] peripheral_S_rdata;
input peripheral_S_rdata_valid;
output wire peripheral_S_rdata_ready;

input pclk, presetn;
output wire [31:0] rdata_S_fifo_data;
input rdata_S_fifo_valid;
output wire rdata_S_fifo_ready;

//Define signals:
// wire rfifo_full, rfifo_empty;
// assign peripheral_S_rdata_ready = !rfifo_full;
// assign rdata_S_fifo_ready = !rfifo_empty;

// async_fifo_sram #(
//     .width(32),
//     .depth(ASYN_DATA_FIFO_DEPTH),
//     .empty_limit(FIFO_EMPTY_LIMIT),
//     .full_limit(FIFO_FULL_LIMIT)
// ) r_data_fifo (
//     .w_clk(peripheral_clk),
//     .w_rst_n(peripheral_rst_n),
//     .w_data(peripheral_S_rdata),
//     .w_en(peripheral_S_rdata_valid),
//     .full(rfifo_full),
//     .r_clk(pclk),
//     .r_rst_n(presetn), 
//     .r_data(rdata_S_fifo_data),
//     .r_en(rdata_S_fifo_valid),
//     .empty(rfifo_empty)
// );

AsyncAxiFifo8 #(.DATAWIDTH(32)) u_raddr_fifo (
    .CLKU      ( peripheral_clk            ), 
    .RESETUn   ( peripheral_rst_n          ), 
    .READYU    ( peripheral_S_rdata_ready  ),
    .VALIDU    ( peripheral_S_rdata_valid  ),
    .DATAU     ( peripheral_S_rdata        ),
    .SYNCMODEREQ (1'b0),       
    .CLKD      ( pclk                      ),
    .RESETDn   ( presetn                   ),
    .READYD    ( rdata_S_fifo_valid        ),
    .VALIDD    ( rdata_S_fifo_ready        ),
    .DATAD     ( rdata_S_fifo_data         ), 
    .SYNCMODEACK ()
);





endmodule

