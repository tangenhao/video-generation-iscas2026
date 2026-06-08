//File name  :    axi4_r_data_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/03/11 01:10:03
//Version    :    V1.0
//Abstract   :        


module axi4_r_data_clk_bridge(
  peripheral_clk, peripheral_rst_n,
  peripheral_S_rdata, peripheral_S_rdata_valid, peripheral_S_rdata_ready,

  axi4_clk, axi4_rst_n,
  rdata_S_fifo_data, rdata_S_fifo_ready, rdata_S_fifo_valid
);

//Define parameters:
parameter integer PERI_DATA_WIDTH = 32;

//Define pins:
input                       peripheral_clk;
input                       peripheral_rst_n;
input [PERI_DATA_WIDTH-1:0] peripheral_S_rdata;
input                       peripheral_S_rdata_valid;
output wire                 peripheral_S_rdata_ready;

input                             axi4_clk;
input                             axi4_rst_n;
output wire [PERI_DATA_WIDTH-1:0] rdata_S_fifo_data;
input                             rdata_S_fifo_valid;
output wire                       rdata_S_fifo_ready;

//Define signals:
wire rfifo_full, rfifo_empty;
// assign peripheral_S_rdata_ready = !rfifo_full;
// assign rdata_S_fifo_ready = !rfifo_empty;

// async_fifo_sram #(
//     .width(PERI_DATA_WIDTH),
//     .depth(ASYN_DATA_FIFO_DEPTH),
//     .empty_limit(FIFO_EMPTY_LIMIT),
//     .full_limit(FIFO_FULL_LIMIT)
// ) r_data_fifo (
//     .w_clk(peripheral_clk),
//     .w_rst_n(peripheral_rst_n),
//     .w_data(peripheral_S_rdata),
//     .w_en(peripheral_S_rdata_valid),
//     .full(rfifo_full),
//     .r_clk(axi4_clk),
//     .r_rst_n(axi4_rst_n), 
//     .r_data(rdata_S_fifo_data),
//     .r_en(rdata_S_fifo_valid & ~rfifo_empty),
//     .empty(rfifo_empty)
// );

AsyncAxiFifo8 #(.DATAWIDTH(PERI_DATA_WIDTH)) u_rdata_fifo (
  .CLKU      ( peripheral_clk            ), 
  .RESETUn   ( peripheral_rst_n          ), 
  .READYU    ( peripheral_S_rdata_ready  ),
  .VALIDU    ( peripheral_S_rdata_valid  ),
  .DATAU     ( peripheral_S_rdata        ),
  .SYNCMODEREQ (1'b0),       
  .CLKD      ( axi4_clk                  ),
  .RESETDn   ( axi4_rst_n                ),
  .READYD    ( rdata_S_fifo_valid        ),
  .VALIDD    ( rdata_S_fifo_ready        ),
  .DATAD     ( rdata_S_fifo_data         ), 
  .SYNCMODEACK ()
);

endmodule

