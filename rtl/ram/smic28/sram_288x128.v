module sram_288x128
(
  w_clk, w_addr, w_en, w_data,
  r_clk, r_addr, r_en, r_data
);

input w_clk, r_clk;
input w_en, r_en;
input [6:0] w_addr, r_addr;
input [287:0] w_data;
output wire [287:0] r_data;

`ifdef SMIC28

genvar sram_i;
generate
  for (sram_i = 0; sram_i < 2; sram_i = sram_i + 1) begin : sram_256x128
    sram_2p_uhde #(
      .BITS  ( 128 ),
      .WORDS ( 128 )
    ) u_sram_2p_uhde_128x128 (
      .CLK    ( w_clk                     ),
      .CENA   ( ~w_en                     ),
      .CENB   ( ~r_en                     ),
      .AA     ( w_addr                    ),
      .AB     ( r_addr                    ),
      .DB     ( w_data[128*sram_i +: 128] ),
      .STOV   ( 1'b0                      ),
      .STOVAB ( 1'b0                      ),
      .EMA    ( 3'b011                    ),
      .EMAW   ( 2'b00                     ),
      .EMAS   ( 1'b0                      ),
      .EMAP   ( 1'b0                      ),
      .QA     ( r_data[128*sram_i +: 128] )
    );
  end
endgenerate

`endif 

`ifdef SIM

genvar sram_i;
generate
  for (sram_i = 0; sram_i < 2; sram_i = sram_i + 1) begin : sram_288x128
    sram_2p_uhde #(
      .BITS  ( 144 ),
      .WORDS ( 128 )
    ) u_sram_2p_uhde_144x128 (
      .CLK    ( w_clk                     ),
      .CENA   ( ~w_en                     ),
      .CENB   ( ~r_en                     ),
      .AA     ( w_addr                    ),
      .AB     ( r_addr                    ),
      .DB     ( w_data[144*sram_i +: 144] ),
      .STOV   ( 1'b0                      ),
      .STOVAB ( 1'b0                      ),
      .EMA    ( 3'b011                    ),
      .EMAW   ( 2'b00                     ),
      .EMAS   ( 1'b0                      ),
      .EMAP   ( 1'b0                      ),
      .QA     ( r_data[144*sram_i +: 144] )
    );
  end
endgenerate

`else

`ifdef FPGA_SRAM

bram_288x128 u_bram_288x128(
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

genvar sram_i;
generate
  for (sram_i = 0; sram_i < 2; sram_i = sram_i + 1) begin : sram_288x128
    TS6N28HPCPSVTA128X144M2FWBSO u_sram_tsmc28_144x128(
      .AA    ( w_addr                                       ),
      .D     ( w_data[sram_i*144 +: 144]                    ),
      .BWEB  ( 144'd0                                       ),
      .WEB   ( !w_en                                        ),
      .CLKW  ( w_clk                                        ),
      .AB    ( r_addr                                       ),
      .REB   ( !r_en                                        ),
      .CLKR  ( r_clk                                        ),
      .AMA   ( 7'd0                                         ),
      .DM    ( 144'd0                                       ),
      .BWEBM ( 144'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff ),
      .WEBM  ( 1'b1                                         ),
      .AMB   ( 7'd0                                         ),
      .REBM  ( 1'b1                                         ),
      .BIST  ( 1'b0                                         ),
      .SLP   ( 1'b0                                         ),
      .SD    ( 1'b0                                         ),
      .Q     ( r_data[sram_i*144 +: 144]                    )
    );
  end
endgenerate
`endif

`endif 
endmodule