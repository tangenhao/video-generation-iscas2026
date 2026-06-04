//File name  :    peripheral_w_data_clk_bridge.v
//Author     :    xiaocuicui
//Time       :    2024/01/14 10:05:19
//Version    :    V1.0
//Abstract   :        


module peripheral_w_data_clk_bridge(
  peripheral_clk, peripheral_rst_n,
  peripheral_M_wdata, peripheral_M_wdata_valid, peripheral_M_wdata_ready,

  axi4_clk, axi4_rst_n,
  wdata_M_fifo_valid, wdata_M_fifo_ready, wdata_M_fifo_data
);

//Define parameters:
parameter integer PERI_DATA_WIDTH = 32;

//Define pins:
input                             peripheral_clk;
input                             peripheral_rst_n;
input [PERI_DATA_WIDTH-1:0]       peripheral_M_wdata;
input                             peripheral_M_wdata_valid;
output wire                       peripheral_M_wdata_ready;

input                             axi4_clk;
input                             axi4_rst_n;
output wire [PERI_DATA_WIDTH-1:0] wdata_M_fifo_data;
input                             wdata_M_fifo_valid;
output wire                       wdata_M_fifo_ready;

AsyncAxiFifo8 #(.DATAWIDTH(PERI_DATA_WIDTH)) u_raddr_fifo (
  .CLKU      ( peripheral_clk            ), 
  .RESETUn   ( peripheral_rst_n          ), 
  .READYU    ( peripheral_M_wdata_ready  ),
  .VALIDU    ( peripheral_M_wdata_valid  ),
  .DATAU     ( peripheral_M_wdata        ),
  .SYNCMODEREQ (1'b0),       
  .CLKD      ( axi4_clk                  ),
  .RESETDn   ( axi4_rst_n                ),
  .READYD    ( wdata_M_fifo_valid        ),
  .VALIDD    ( wdata_M_fifo_ready        ),
  .DATAD     ( wdata_M_fifo_data         ), 
  .SYNCMODEACK ()
);


endmodule

