module mux_32to1_4bit (
  mask,
  data,
  out
);

input [31:0] mask;
input [127:0] data;
output reg [3:0] out;

always @(*) begin
  case(1'b1)
    mask[0]: out = data[3:0];
    mask[1]: out = data[7:4];
    mask[2]: out = data[11:8];
    mask[3]: out = data[15:12];
    mask[4]: out = data[19:16];
    mask[5]: out = data[23:20];
    mask[6]: out = data[27:24];
    mask[7]: out = data[31:28];
    mask[8]: out = data[35:32];
    mask[9]: out = data[39:36];
    mask[10]: out = data[43:40];
    mask[11]: out = data[47:44];
    mask[12]: out = data[51:48];
    mask[13]: out = data[55:52];
    mask[14]: out = data[59:56];
    mask[15]: out = data[63:60];
    mask[16]: out = data[67:64];
    mask[17]: out = data[71:68];
    mask[18]: out = data[75:72];
    mask[19]: out = data[79:76];
    mask[20]: out = data[83:80];
    mask[21]: out = data[87:84];
    mask[22]: out = data[91:88];
    mask[23]: out = data[95:92];
    mask[24]: out = data[99:96];
    mask[25]: out = data[103:100];
    mask[26]: out = data[107:104];
    mask[27]: out = data[111:108];
    mask[28]: out = data[115:112];
    mask[29]: out = data[119:116];
    mask[30]: out = data[123:120];
    mask[31]: out = data[127:124];
    default: out = 0;
  endcase
end

endmodule
