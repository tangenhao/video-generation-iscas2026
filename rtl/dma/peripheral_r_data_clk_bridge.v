module peripheral_r_data_clk_bridge(
  peripheral_clk, peripheral_rst_n,
  peripheral_M_rdata, peripheral_M_rdata_valid, peripheral_M_rdata_ready,

  axi4_clk, axi4_rst_n,
  rdata_M_fifo_data, rdata_M_fifo_ready, rdata_M_fifo_valid
);

parameter integer PERI_DATA_WIDTH = 32;

input                             peripheral_clk;
input                             peripheral_rst_n;
output wire [PERI_DATA_WIDTH-1:0] peripheral_M_rdata;
output wire                       peripheral_M_rdata_ready;
input                             peripheral_M_rdata_valid;

input                             axi4_clk;
input                             axi4_rst_n;
input [PERI_DATA_WIDTH-1:0]       rdata_M_fifo_data;
output wire                       rdata_M_fifo_ready;
input                             rdata_M_fifo_valid;

wire rfifo_full, rfifo_empty;

AsyncAxiFifo8 #(.DATAWIDTH(PERI_DATA_WIDTH)) u_raddr_fifo (
  .CLKU      ( axi4_clk                 ), 
  .RESETUn   ( axi4_rst_n               ), 
  .READYU    ( rdata_M_fifo_ready       ),
  .VALIDU    ( rdata_M_fifo_valid       ),
  .DATAU     ( rdata_M_fifo_data ),
  .SYNCMODEREQ (1'b0),
  .CLKD      ( peripheral_clk           ),
  .RESETDn   ( peripheral_rst_n         ),
  .READYD    ( peripheral_M_rdata_valid ),
  .VALIDD    ( peripheral_M_rdata_ready ),
  .DATAD     ( peripheral_M_rdata       ), 
  .SYNCMODEACK ()
);

endmodule

