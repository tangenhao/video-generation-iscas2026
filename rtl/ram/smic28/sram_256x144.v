module sram_256x144
(
  w_clk, w_addr, w_en, w_data,
  r_clk, r_addr, r_en, r_data
);

input w_clk, r_clk;
input w_en, r_en;
input [7:0] w_addr, r_addr;
input [255:0] w_data;
output wire [255:0] r_data;

`ifdef SMIC28

genvar sram_i;
generate
  for (sram_i = 0; sram_i < 2; sram_i = sram_i + 1) begin : sram_256x144
    sram_2p_uhde #(
      .BITS  ( 128  ),
      .WORDS ( 144  )
    ) u_sram_2p_uhde_128x144 (
      .CLK    ( w_clk                       ),
      .CENA   ( ~w_en                       ),
      .CENB   ( ~r_en                       ),
      .AA     ( w_addr                      ),
      .AB     ( r_addr                      ),
      .DB     ( w_data[128*sram_i +: 128]   ),
      .STOV   ( 1'b0                        ),
      .STOVAB ( 1'b0                        ),
      .EMA    ( 3'b011                      ),
      .EMAW   ( 2'b00                       ),
      .EMAS   ( 1'b0                        ),
      .EMAP   ( 1'b0                        ),
      .QA     ( r_data[128*sram_i +: 128]   )
    );
  end
endgenerate

`endif 

`ifdef SIM

genvar sram_i;
generate
  for (sram_i = 0; sram_i < 2; sram_i = sram_i + 1) begin : sram_256x144
    sram_2p_uhde #(
      .BITS  ( 128  ),
      .WORDS ( 144  )
    ) u_sram_2p_uhde_128x144 (
      .CLK    ( w_clk                       ),
      .CENA   ( ~w_en                       ),
      .CENB   ( ~r_en                       ),
      .AA     ( w_addr                      ),
      .AB     ( r_addr                      ),
      .DB     ( w_data[128*sram_i +: 128]   ),
      .STOV   ( 1'b0                        ),
      .STOVAB ( 1'b0                        ),
      .EMA    ( 3'b011                      ),
      .EMAW   ( 2'b00                       ),
      .EMAS   ( 1'b0                        ),
      .EMAP   ( 1'b0                        ),
      .QA     ( r_data[128*sram_i +: 128]   )
    );
  end
endgenerate

`else

`ifdef FPGA_SRAM

bram_256x144 u_bram_256x144(
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

genvar i;
generate
  for(i=0;i<2;i=i+1) begin:u_sram_tsmc28_256x144
    TS6N28HPCPSVTA144X128M4FWBSO u_sram_tsmc28_128x144(
      .AA    ( w_addr                  ),
      .D     ( w_data[i*128+:128]      ),
      .BWEB  ( 128'd0                  ),
      .WEB   ( !w_en                   ),
      .CLKW  ( w_clk                   ),
      .AB    ( r_addr                  ),
      .REB   ( !r_en                   ),
      .CLKR  ( r_clk                   ),
      .AMA   ( 8'd0                    ),
      .DM    ( 128'd0                  ),
      .BWEBM ( 128'hffff_ffff_ffff_ffff),
      .WEBM  ( 1'b1                    ),
      .AMB   ( 8'd0                    ),
      .REBM  ( 1'b1                    ),
      .BIST  ( 1'b0                    ),
      .SLP   ( 1'b0                    ),
      .SD    ( 1'b0                    ),
      .Q     ( r_data[i*128+:128]      )
    );
  end
endgenerate
`endif

`endif 
endmodule