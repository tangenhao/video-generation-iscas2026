module vcu_ofmap_ram(
  clk, rst_n,

  rvalid_0, raddr_0, rdata_0,

  wvalid, waddr, wdata
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

parameter WRITE_WIDTH     = 576;
parameter WRITE_ADDR_BITS = 5;
parameter READ_WIDTH      = 256;
parameter READ_ADDR_BITS  = 9;

localparam SRAM_READ_WIDTH = WRITE_WIDTH / 2;
localparam WORD_W          = 32;
localparam SRAM_READ_WORDS = SRAM_READ_WIDTH / WORD_W;
localparam READ_WORDS      = READ_WIDTH / WORD_W;
localparam READ_BEAT_BITS  = clogb2(SRAM_READ_WORDS);
localparam [READ_BEAT_BITS-1:0] INPUT_READ_BEATS = READ_WORDS;
localparam [READ_BEAT_BITS-1:0] GROUP_READ_LAST  = SRAM_READ_WORDS - 1;

input                            clk;
input                            rst_n;

input                            rvalid_0;
input       [READ_ADDR_BITS-1:0] raddr_0;
output wire [READ_WIDTH-1:0]     rdata_0;

input                             wvalid;
input       [WRITE_ADDR_BITS-1:0] waddr;
input       [WRITE_WIDTH-1:0]     wdata;

wire                           ren;
wire [READ_ADDR_BITS-2:0]      raddr;
wire [WRITE_WIDTH-1:0]         rdata;
wire [SRAM_READ_WIDTH-1:0]     gearbox_data_in;
wire                           gearbox_ready;
wire                           gearbox_valid;

reg                            wen;
reg  [WRITE_ADDR_BITS-1:0]     waddr_reg;
reg  [WRITE_WIDTH-1:0]         wdata_reg;

reg                            ren_reg;
reg                            raddr_sel_reg;
reg  [READ_BEAT_BITS-1:0]      read_beat_cnt;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    wen         <= 'd0;
    waddr_reg   <= 'd0;
    wdata_reg   <= 'd0;
  end
  else begin
    wen         <= wvalid;
    waddr_reg   <= waddr;
    wdata_reg   <= wdata;
  end
end

sram_576x128 u_ram_bank(
  .w_clk  ( clk           ),
  .w_en   ( wen           ),
  .w_addr ( waddr_reg     ),
  .w_data ( wdata_reg     ),
  .r_clk  ( clk           ),
  .r_en   ( ren           ),
  .r_addr ( raddr         ),
  .r_data ( rdata         )
);

assign ren   = rvalid_0;
assign raddr = raddr_0[READ_ADDR_BITS-1:1];
assign gearbox_data_in = raddr_sel_reg ? rdata[SRAM_READ_WIDTH +: SRAM_READ_WIDTH] :
                                         rdata[0               +: SRAM_READ_WIDTH];

gearbox_288_to_256 #(
  .WORD_W    ( WORD_W          ),
  .IN_WORDS  ( SRAM_READ_WORDS ),
  .OUT_WORDS ( READ_WORDS      )
) u_gearbox_288_to_256 (
  .clk            ( clk             ),
  .rst_n          ( rst_n           ),
  .restart        ( 1'b0            ),
  .valid_data_in  ( ren_reg         ),
  .ready_data_in  ( gearbox_ready   ),
  .data_in        ( gearbox_data_in ),
  .valid_data_out ( gearbox_valid   ),
  .data_out       ( rdata_0         )
);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ren_reg       <= 1'b0;
    raddr_sel_reg <= 1'b0;
    read_beat_cnt <= {READ_BEAT_BITS{1'b0}};
  end
  else begin
    ren_reg       <= ren && (read_beat_cnt < INPUT_READ_BEATS);
    raddr_sel_reg <= raddr_0[0];

    if (ren) begin
      if (read_beat_cnt == GROUP_READ_LAST) begin
        read_beat_cnt <= {READ_BEAT_BITS{1'b0}};
      end
      else begin
        read_beat_cnt <= read_beat_cnt + 1'b1;
      end
    end
    else begin
      read_beat_cnt <= {READ_BEAT_BITS{1'b0}};
    end
  end
end

endmodule
