module mux_32to1_1bit (
  mask,
  data,
  out
);

input [31:0] mask;
input [31:0] data;
output reg out;

always @(*) begin
  case(1'b1)
    mask[0]: out = data[0];
    mask[1]: out = data[1];
    mask[2]: out = data[2];
    mask[3]: out = data[3];
    mask[4]: out = data[4];
    mask[5]: out = data[5];
    mask[6]: out = data[6];
    mask[7]: out = data[7];
    mask[8]: out = data[8];
    mask[9]: out = data[9];
    mask[10]: out = data[10];
    mask[11]: out = data[11];
    mask[12]: out = data[12];
    mask[13]: out = data[13];
    mask[14]: out = data[14];
    mask[15]: out = data[15];
    mask[16]: out = data[16];
    mask[17]: out = data[17];
    mask[18]: out = data[18];
    mask[19]: out = data[19];
    mask[20]: out = data[20];
    mask[21]: out = data[21];
    mask[22]: out = data[22];
    mask[23]: out = data[23];
    mask[24]: out = data[24];
    mask[25]: out = data[25];
    mask[26]: out = data[26];
    mask[27]: out = data[27];
    mask[28]: out = data[28];
    mask[29]: out = data[29];
    mask[30]: out = data[30];
    mask[31]: out = data[31];
    default: out = 0;
  endcase
end

endmodule
