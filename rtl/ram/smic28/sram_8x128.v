module sram_8x128
(
  w_clk, w_addr, w_en, w_data,
  r_clk, r_addr, r_en, r_data
);

input w_clk, r_clk;
input w_en, r_en;
input [6:0] w_addr, r_addr;
input [7:0] w_data;
output wire [7:0] r_data;

`ifdef SMIC28

sram_2p_uhde #(
  .BITS  ( 8   ),
  .WORDS ( 128 )
) u_sram_2p_uhde_8x128 (
  .CLK    ( w_clk  ),
  .CENA   ( ~w_en  ),
  .CENB   ( ~r_en  ),
  .AA     ( w_addr ),
  .AB     ( r_addr ),
  .DB     ( w_data ),
  .STOV   ( 1'b0   ),
  .STOVAB ( 1'b0   ),
  .EMA    ( 3'b011 ),
  .EMAW   ( 2'b00  ),
  .EMAS   ( 1'b0   ),
  .EMAP   ( 1'b0   ),
  .QA     ( r_data )
);

`else

`ifdef SIM

sram_2p_uhde #(
  .BITS  ( 8   ),
  .WORDS ( 128 )
) u_sram_2p_uhde_8x128 (
  .CLK    ( w_clk  ),
  .CENA   ( ~w_en  ),
  .CENB   ( ~r_en  ),
  .AA     ( w_addr ),
  .AB     ( r_addr ),
  .DB     ( w_data ),
  .STOV   ( 1'b0   ),
  .STOVAB ( 1'b0   ),
  .EMA    ( 3'b011 ),
  .EMAW   ( 2'b00  ),
  .EMAS   ( 1'b0   ),
  .EMAP   ( 1'b0   ),
  .QA     ( r_data )
);

`endif 

`ifdef FPGA_SRAM

bram_8x128 u_bram_8x128(
  .clka  ( w_clk  ),
  .wea   ( w_en   ),
  .addra ( w_addr ),
  .dina  ( w_data ),
  .clkb  ( r_clk  ),
  .addrb ( r_addr ),
  .enb   ( r_en   ),
  .doutb ( r_data )
);

`endif 

`ifdef TSMC28

TS6N28HPCPSVTA128X8M2FWBSO u_u_sram_tsmc28_8x128(
  .AA    ( w_addr ),
  .D     ( w_data ),
  .BWEB  ( 8'h0   ),
  .WEB   ( !w_en  ),
  .CLKW  ( w_clk  ),
  .AB    ( r_addr ),
  .REB   ( !r_en  ),
  .CLKR  ( r_clk  ),
  .AMA   ( 7'd0   ),
  .DM    ( 8'd0   ),
  .BWEBM ( 8'hff  ),
  .WEBM  ( 1'b1   ),
  .AMB   ( 7'd0   ),
  .REBM  ( 1'b1   ),
  .BIST  ( 1'b0   ),
  .SLP   ( 1'b0   ),
  .SD    ( 1'b0   ),
  .Q     ( r_data )
);

`endif

`endif 

endmodule