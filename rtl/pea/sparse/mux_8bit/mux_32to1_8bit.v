module mux_32to1_8bit (
  mask,
  data,
  out
);

input [31:0] mask;
input [255:0] data;
output reg [7:0] out;

always @(*) begin
  case(1'b1)
    mask[0]: out = data[7:0];
    mask[1]: out = data[15:8];
    mask[2]: out = data[23:16];
    mask[3]: out = data[31:24];
    mask[4]: out = data[39:32];
    mask[5]: out = data[47:40];
    mask[6]: out = data[55:48];
    mask[7]: out = data[63:56];
    mask[8]: out = data[71:64];
    mask[9]: out = data[79:72];
    mask[10]: out = data[87:80];
    mask[11]: out = data[95:88];
    mask[12]: out = data[103:96];
    mask[13]: out = data[111:104];
    mask[14]: out = data[119:112];
    mask[15]: out = data[127:120];
    mask[16]: out = data[135:128];
    mask[17]: out = data[143:136];
    mask[18]: out = data[151:144];
    mask[19]: out = data[159:152];
    mask[20]: out = data[167:160];
    mask[21]: out = data[175:168];
    mask[22]: out = data[183:176];
    mask[23]: out = data[191:184];
    mask[24]: out = data[199:192];
    mask[25]: out = data[207:200];
    mask[26]: out = data[215:208];
    mask[27]: out = data[223:216];
    mask[28]: out = data[231:224];
    mask[29]: out = data[239:232];
    mask[30]: out = data[247:240];
    mask[31]: out = data[255:248];
    default: out = 0;
  endcase
end

endmodule
