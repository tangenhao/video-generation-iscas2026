module sram_2p_uhde (QA, CLK, CENA, CENB, AA, AB, DB, STOV, STOVAB, EMA, EMAW, EMAS,EMAP);

parameter ASSERT_PREFIX = "";
parameter BITS = 128;
parameter WORDS = 512;
parameter MUX = 2;
parameter MEM_WIDTH = 256;// redun block size 2,128 on left, 128 on right
parameter MEM_HEIGHT = 256;
parameter WP_SIZE = 128;
parameter UPM_WIDTH = 3;
parameter UPMW_WIDTH = 2;
parameter UPMS_WIDTH = 1;
parameter ROWS = 256;

function integer clogb2 (input integer bit_depth);
  begin
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
      bit_depth = bit_depth >> 1;
  end
endfunction

localparam ADDR_WIDTH = clogb2(WORDS-1);

output [BITS-1:0] QA;
input CLK; 
input CENA;
input CENB;
input [ADDR_WIDTH-1:0] AA; 
input [ADDR_WIDTH-1:0] AB;
input [BITS-1:0] DB;
input STOV;
input STOVAB;
input [2:0] EMA;
input [1:0] EMAW;
input EMAS;
input EMAP;

reg [BITS-1:0] mem [0:WORDS-1];

reg [BITS-1:0] rdata_reg;
assign QA = rdata_reg;

always @(posedge CLK) begin
  if (!CENA) begin
    mem[AA] <= DB;
  end
end

always @(posedge CLK) begin
  if (!CENB) begin
    rdata_reg <= mem[AB];
  end
end

endmodule