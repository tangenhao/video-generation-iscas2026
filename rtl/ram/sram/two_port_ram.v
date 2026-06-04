//File name  :    two_port_ram.v
//Author     :    xiaocuicui
//Time       :    2023/03/19 11:16:26
//Version    :    V1.0
//Abstract   :        


module two_port_ram
(
  w_clk, w_addr, w_en, w_data,
  r_clk, r_addr, r_en, r_data
);

parameter width = 1024;
parameter depth = 512;

function integer clogb2 (input integer bit_depth);
begin
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
  bit_depth = bit_depth >> 1; 
end
endfunction

localparam addr_bit = clogb2(depth - 1);


input w_clk, r_clk;
input w_en, r_en;
input [addr_bit-1:0] w_addr, r_addr;
input [width-1:0] w_data;
output wire [width-1:0] r_data;

reg [width-1:0] mem [0:depth-1];

reg [width-1:0] rdata_reg;
assign r_data = rdata_reg;

always @(posedge w_clk) begin
  if (w_en) begin
    mem[w_addr] <= w_data;
  end
end

always @(posedge r_clk) begin
  if (r_en) begin
    rdata_reg <= mem[r_addr];
end
end


endmodule

