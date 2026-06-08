//File name  :    axi4_w_data_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/03/11 01:10:03
//Version    :    V1.0
//Abstract   :        


module axi4_w_data_clk_bridge(
  peripheral_clk, peripheral_rst_n,
  peripheral_S_wdata, peripheral_S_wdata_valid, peripheral_S_wdata_ready,

  axi4_clk, axi4_rst_n,
  wdata_S_fifo_data, wdata_S_fifo_ready, wdata_S_fifo_valid
);

//Define parameters:
parameter integer PERI_DATA_WIDTH = 32;

//Define pins:
input                             peripheral_clk;
input                             peripheral_rst_n;
output wire [PERI_DATA_WIDTH-1:0] peripheral_S_wdata;
output wire                       peripheral_S_wdata_ready;
input                             peripheral_S_wdata_valid;

input                       axi4_clk;
input                       axi4_rst_n;
input [PERI_DATA_WIDTH-1:0] wdata_S_fifo_data;
input                       wdata_S_fifo_valid;
output wire                 wdata_S_fifo_ready;

AsyncAxiFifo8 #(.DATAWIDTH(PERI_DATA_WIDTH)) u_wdata_fifo (
  .CLKU        ( axi4_clk                  ), 
  .RESETUn     ( axi4_rst_n                ), 
  .READYU      ( wdata_S_fifo_ready        ),
  .VALIDU      ( wdata_S_fifo_valid        ),
  .DATAU       ( wdata_S_fifo_data         ),
  .SYNCMODEREQ ( 1'b0                      ),       
  .CLKD        ( peripheral_clk            ),
  .RESETDn     ( peripheral_rst_n          ),
  .READYD      ( peripheral_S_wdata_valid  ),
  .VALIDD      ( peripheral_S_wdata_ready  ),
  .DATAD       ( peripheral_S_wdata        ), 
  .SYNCMODEACK (                           )
);

endmodule

