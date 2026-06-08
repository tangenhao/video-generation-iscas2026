//File name  :    apb4_w_data_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/03/29 12:53:55
//Version    :    V1.0
//Abstract   :        


module apb4_w_data_clk_bridge(
peripheral_clk, peripheral_rst_n,
peripheral_S_wdata, peripheral_S_wdata_valid, peripheral_S_wdata_ready,

pclk, presetn, 
wdata_S_fifo_data, wdata_S_fifo_ready, wdata_S_fifo_valid
);

//Define parameters:
parameter integer ASYN_DATA_FIFO_DEPTH = 8;
parameter integer PERI_DATA_WIDTH = 32;
parameter integer FIFO_EMPTY_LIMIT = 3;
parameter integer FIFO_FULL_LIMIT = 3;


//Define pins:
input peripheral_clk, peripheral_rst_n;
output wire [31:0] peripheral_S_wdata;
output wire peripheral_S_wdata_ready;
input peripheral_S_wdata_valid;

input pclk, presetn;
input [31:0] wdata_S_fifo_data;
output wire wdata_S_fifo_ready;
input wdata_S_fifo_valid;



//Define signals:
// wire wfifo_full, wfifo_empty;
// assign wdata_S_fifo_ready = !wfifo_full;
// assign peripheral_S_wdata_ready = !wfifo_empty;

// async_fifo_sram #(
//     .width(PERI_DATA_WIDTH),
//     .depth(ASYN_DATA_FIFO_DEPTH),
//     .empty_limit(FIFO_EMPTY_LIMIT),
//     .full_limit(FIFO_FULL_LIMIT)
// ) w_data_fifo (
//     .w_clk(pclk),
//     .w_rst_n(presetn),
//     .w_data(wdata_S_fifo_data),
//     .w_en(wdata_S_fifo_valid),
//     .full(wfifo_full),
//     .r_clk(peripheral_clk),
//     .r_rst_n(peripheral_rst_n), 
//     .r_data(peripheral_S_wdata),
//     .r_en(peripheral_S_wdata_valid),
//     .empty(wfifo_empty)
// );

AsyncAxiFifo8 #(.DATAWIDTH(32)) u_raddr_fifo (
    .CLKU      ( pclk                      ), 
    .RESETUn   ( presetn                   ), 
    .READYU    ( wdata_S_fifo_ready        ),
    .VALIDU    ( wdata_S_fifo_valid        ),
    .DATAU     ( wdata_S_fifo_data         ),
    .SYNCMODEREQ (1'b0),       
    .CLKD      ( peripheral_clk            ),
    .RESETDn   ( peripheral_rst_n          ),
    .READYD    ( peripheral_S_wdata_valid  ),
    .VALIDD    ( peripheral_S_wdata_ready  ),
    .DATAD     ( peripheral_S_wdata         ), 
    .SYNCMODEACK ()
);



endmodule

