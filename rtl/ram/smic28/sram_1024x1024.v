module sram_1024x1024
(
  w_clk, w_addr, w_en, w_data,
  r_clk, r_rst_n, r_addr, r_en, r_data
);

input w_clk, r_clk, r_rst_n;
input w_en, r_en;
input [9:0] w_addr, r_addr;
input [1023:0] w_data;
output wire [1023:0] r_data;

`ifdef SMIC28

wire          wen[0:1];
wire [8:0]    waddr[0:1];
wire [1023:0] wdata[0:1];

wire          ren[0:1];
reg           ren_reg[0:1];
wire [8:0]    raddr[0:1];
wire [1023:0] rdata[0:1];

genvar depth_i;
generate
  for (depth_i = 0; depth_i < 2; depth_i = depth_i + 1) begin
    assign wen[depth_i] = (w_addr[9] == depth_i) & w_en;
    assign waddr[depth_i] = w_addr[8:0];
    assign wdata[depth_i] = w_data;

    assign ren[depth_i] = (r_addr[9] == depth_i) & r_en;
    assign raddr[depth_i] = r_addr[8:0];

    always @(posedge r_clk or negedge r_rst_n) begin
      if (!r_rst_n) begin
        ren_reg[depth_i] <= 1'b0;
      end
      else begin
        if (ren[depth_i]) begin
          ren_reg[depth_i] <= 1'b1;
        end
        else begin
          ren_reg[depth_i] <= 1'b0;
        end
      end
    end
  end
endgenerate

genvar sram_i;
generate
  for(sram_i = 0; sram_i < 8; sram_i = sram_i+1) begin:u_sram_1024x512
    sram_2p_uhde #(
      .BITS  ( 128  ),
      .WORDS ( 512  )
    ) u_sram_2p_uhde_128x512_0 (
      .CLK    ( w_clk                     ),
      .CENA   ( ~wen[0]                   ),
      .CENB   ( ~ren[0]                   ),
      .AA     ( waddr[0]                  ),
      .AB     ( raddr[0]                  ),
      .DB     ( wdata[0][128*sram_i+:128] ),
      .STOV   ( 1'b0                      ),
      .STOVAB ( 1'b0                      ),
      .EMA    ( 3'b011                    ),
      .EMAW   ( 2'b00                     ),
      .EMAS   ( 1'b0                      ),
      .EMAP   ( 1'b0                      ),
      .QA     ( rdata[0][128*sram_i+:128] )
    );

    sram_2p_uhde #(
      .BITS  ( 128  ),
      .WORDS ( 512  )
    ) u_sram_2p_uhde_128x512_1 (
      .CLK    ( w_clk                     ),
      .CENA   ( ~wen[1]                   ),
      .CENB   ( ~ren[1]                   ),
      .AA     ( waddr[1]                  ),
      .AB     ( raddr[1]                  ),
      .DB     ( wdata[1][128*sram_i+:128] ),
      .STOV   ( 1'b0                      ),
      .STOVAB ( 1'b0                      ),
      .EMA    ( 3'b011                    ),
      .EMAW   ( 2'b00                     ),
      .EMAS   ( 1'b0                      ),
      .EMAP   ( 1'b0                      ),
      .QA     ( rdata[1][128*sram_i+:128] )
    );
  end
endgenerate

assign r_data = ren_reg[0] ? rdata[0] :
                ren_reg[1] ? rdata[1] : 1024'h0;

`endif 

`ifdef SIM

wire          wen[0:1];
wire [8:0]    waddr[0:1];
wire [1023:0] wdata[0:1];

wire          ren[0:1];
reg           ren_reg[0:1];
wire [8:0]    raddr[0:1];
wire [1023:0] rdata[0:1];

genvar depth_i;
generate
  for (depth_i = 0; depth_i < 2; depth_i = depth_i + 1) begin
    assign wen[depth_i] = (w_addr[9] == depth_i) & w_en;
    assign waddr[depth_i] = w_addr[8:0];
    assign wdata[depth_i] = w_data;

    assign ren[depth_i] = (r_addr[9] == depth_i) & r_en;
    assign raddr[depth_i] = r_addr[8:0];

    always @(posedge r_clk or negedge r_rst_n) begin
      if (!r_rst_n) begin
        ren_reg[depth_i] <= 1'b0;
      end
      else begin
        if (ren[depth_i]) begin
          ren_reg[depth_i] <= 1'b1;
        end
        else begin
          ren_reg[depth_i] <= 1'b0;
        end
      end
    end
  end
endgenerate

genvar sram_i;
generate
  for(sram_i = 0; sram_i < 8; sram_i = sram_i+1) begin:u_sram_1024x512
    sram_2p_uhde #(
      .BITS  ( 128  ),
      .WORDS ( 512  )
    ) u_sram_2p_uhde_128x512_0 (
      .CLK    ( w_clk                     ),
      .CENA   ( ~wen[0]                   ),
      .CENB   ( ~ren[0]                   ),
      .AA     ( waddr[0]                  ),
      .AB     ( raddr[0]                  ),
      .DB     ( wdata[0][128*sram_i+:128] ),
      .STOV   ( 1'b0                      ),
      .STOVAB ( 1'b0                      ),
      .EMA    ( 3'b011                    ),
      .EMAW   ( 2'b00                     ),
      .EMAS   ( 1'b0                      ),
      .EMAP   ( 1'b0                      ),
      .QA     ( rdata[0][128*sram_i+:128] )
    );

    sram_2p_uhde #(
      .BITS  ( 128  ),
      .WORDS ( 512  )
    ) u_sram_2p_uhde_128x512_1 (
      .CLK    ( w_clk                     ),
      .CENA   ( ~wen[1]                   ),
      .CENB   ( ~ren[1]                   ),
      .AA     ( waddr[1]                  ),
      .AB     ( raddr[1]                  ),
      .DB     ( wdata[1][128*sram_i+:128] ),
      .STOV   ( 1'b0                      ),
      .STOVAB ( 1'b0                      ),
      .EMA    ( 3'b011                    ),
      .EMAW   ( 2'b00                     ),
      .EMAS   ( 1'b0                      ),
      .EMAP   ( 1'b0                      ),
      .QA     ( rdata[1][128*sram_i+:128] )
    );
  end
endgenerate

assign r_data = ren_reg[0] ? rdata[0] :
                ren_reg[1] ? rdata[1] : 1024'h0;

`else

`ifdef FPGA_SRAM

bram_1024x1024 u_bram_1024x1024(
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
  for(i=0;i<16;i=i+1) begin:u_sram_tsmc28_1024x512
    TS6N28HPCPSVTA1024X64M4FWBSO u_sram_tsmc28_64x1024(
      .AA    ( w_addr                  ),
      .D     ( w_data[i*64 +: 64]      ),
      .BWEB  ( 64'd0                   ),
      .WEB   ( !w_en                   ),
      .CLKW  ( w_clk                   ),
      .AB    ( r_addr                  ),
      .REB   ( !r_en                   ),
      .CLKR  ( r_clk                   ),
      .AMA   ( 10'd0                   ),
      .DM    ( 64'd0                   ),
      .BWEBM ( 64'hffff_ffff_ffff_ffff ),
      .WEBM  ( 1'b1                    ),
      .AMB   ( 10'd0                   ),
      .REBM  ( 1'b1                    ),
      .BIST  ( 1'b0                    ),
      .SLP   ( 1'b0                    ),
      .SD    ( 1'b0                    ),
      .Q     ( r_data[i*64 +: 64]      )
    );
  end
endgenerate
`endif

`endif 

endmodule