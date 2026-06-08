module load_ed(
  clk, rst_n,

  peripheral_S_raddr, peripheral_S_rlen, peripheral_S_raddr_ready, peripheral_S_raddr_valid, 
  peripheral_S_rdata, peripheral_S_rdata_valid, peripheral_S_rdata_ready, 
  sram_read_addr, sram_read_valid, sram_read_ready, sram_read_data
);

//Define parameters:
parameter integer PERI_ADDR_WIDTH    = 33;
parameter integer PERI_BUSRSTS_WIDTH = 8;
parameter integer PERI_DATA_WIDTH    = 256;

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction  

localparam integer PERI_DATA_BYTES = PERI_DATA_WIDTH / 8;
localparam integer PERI_DATA_BYTES_SHIFTNUMBER = clogb2(PERI_DATA_BYTES - 1);


//Define pins:
input                                clk;
input                                rst_n;
  
input       [PERI_ADDR_WIDTH-1:0]    peripheral_S_raddr;
input       [PERI_BUSRSTS_WIDTH-1:0] peripheral_S_rlen;
output wire                          peripheral_S_raddr_valid;
input                                peripheral_S_raddr_ready;
output wire [PERI_DATA_WIDTH-1:0]    peripheral_S_rdata;
output wire                          peripheral_S_rdata_valid;
input                                peripheral_S_rdata_ready;
output wire [31:0]                   sram_read_addr;
output wire                          sram_read_valid;
input                                sram_read_ready;
input       [31:0]                   sram_read_data;


reg                          sram_ren;
reg [PERI_ADDR_WIDTH-1:0]    sram_raddr;
reg [PERI_BUSRSTS_WIDTH-1:0] sram_rcnt;
reg [PERI_BUSRSTS_WIDTH-1:0] fifo_wcnt;
reg [PERI_BUSRSTS_WIDTH:0]   rlen;
reg                          loaded_free;
reg                          read_working;
reg                          write_working;

wire local_fifo_hfull;
wire local_fifo_empty;

reg                       sram_valid_delay;
reg                       sram_valid_delay_delay;
reg [PERI_DATA_WIDTH-1:0] sram_read_data_reg;
reg [PERI_DATA_WIDTH-1:0] sram_read_data_reg_temp;

assign sram_read_addr           = sram_raddr[31:0];
assign sram_read_valid          = sram_ren && (!local_fifo_hfull);
assign peripheral_S_raddr_valid = loaded_free;

assign peripheral_S_rdata_valid = !local_fifo_empty;

always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    loaded_free   <= 1'b0;
    read_working  <= 1'b0;
    write_working <= 1'b0;
  end
  else begin
    if (peripheral_S_raddr_ready && (!loaded_free) && (!read_working) && (!write_working)) begin
      loaded_free  <= 1'b1;
    end
    else begin
      loaded_free <= 1'b0;
    end

    if (peripheral_S_raddr_valid && peripheral_S_raddr_ready && (!read_working) && (!read_working)) begin
      read_working  <= 1'b1;
      write_working <= 1'b1;
    end
    else begin
      if (fifo_wcnt == rlen - 1 && peripheral_S_rdata_valid && peripheral_S_rdata_ready) begin
        write_working <= 1'b0;
      end

      if (sram_rcnt == rlen - 1) begin
        read_working <= 1'b0;
      end
    end
  end 
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_valid_delay <= 1'b0;
  end
  else begin
    if (sram_read_valid && sram_read_ready) begin
      sram_valid_delay <= 1'b1;
    end
    else begin
      sram_valid_delay <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    sram_raddr <= 'd0;
    sram_rcnt  <= 'd0;
    sram_ren   <= 1'b0;
    fifo_wcnt  <= 'd0;
  end
  else begin

    if (peripheral_S_raddr_ready && peripheral_S_raddr_valid) begin
      rlen       <= peripheral_S_rlen + 1;
      sram_raddr <= peripheral_S_raddr;
      sram_rcnt  <= 'd0;
      fifo_wcnt  <= 'd0;
      sram_ren   <= 1'b1;
    end
    else begin
      if (sram_rcnt == rlen - 1 && sram_read_valid) begin
        sram_ren <= 1'b0;
      end
      else if (read_working) begin
        sram_ren <= 1'b1;
      end

      if (read_working && sram_read_valid) begin
        if (sram_read_ready) begin
          sram_raddr <= sram_raddr + 'h20;
        end
      end
      else begin
        sram_raddr <= sram_raddr;
      end

      if (read_working && sram_read_valid) begin
        sram_rcnt <= sram_rcnt + 1;
      end
      else begin
        sram_rcnt <= sram_rcnt;
      end

      if (write_working && peripheral_S_rdata_valid && peripheral_S_rdata_ready) begin
        fifo_wcnt <= fifo_wcnt + 1;
      end
      else begin
        fifo_wcnt <= fifo_wcnt;
      end
    end
  end
end

sync_fifo_regfile #(
  .width ( PERI_DATA_WIDTH ),
  .depth ( 4               )
) u_data_fifo(
  .clk      ( clk                                                  ),
  .rst_n    ( rst_n                                                ),
  .w_en     ( sram_valid_delay                                     ),
  .w_data   ( {224'd0, sram_read_data}                             ),
  .r_en     ( peripheral_S_rdata_valid && peripheral_S_rdata_ready ),
  .r_data   ( peripheral_S_rdata                                   ),
  .hfull    ( local_fifo_hfull                                     ),
  .hempty   (                                                      ),
  .afull    (                                                      ),
  .aempty   (                                                      ),
  .full     (                                                      ),
  .empty    ( local_fifo_empty                                     ),
  .capacity (                                                      )
);

endmodule

