module mux_32to1_16bit (
  mask,
  data,
  out
);

input [31:0] mask;
input [511:0] data;
output reg [15:0] out;

// wire [15:0] mux_0_res;
// wire [15:0] mux_1_res;
// wire [15:0] mux_2_res;
// wire [15:0] mux_3_res;
// wire [15:0] mux_4_res;
// wire [15:0] mux_5_res;
// wire [15:0] mux_6_res;
// wire [15:0] mux_7_res;

// mux_4to1_16bit u_mux_0 (
//   .mask(mask[3:0]),
//   .data(data[63:0]),
//   .out(mux_0_res)
// );

// mux_4to1_16bit u_mux_1 (
//   .mask(mask[7:4]),
//   .data(data[127:64]),
//   .out(mux_1_res)
// );

// mux_4to1_16bit u_mux_2 (
//   .mask(mask[11:8]),
//   .data(data[191:128]),
//   .out(mux_2_res)
// );

// mux_4to1_16bit u_mux_3 (
//   .mask(mask[15:12]),
//   .data(data[255:192]),
//   .out(mux_3_res)
// );

// mux_4to1_16bit u_mux_4 (
//   .mask(mask[19:16]),
//   .data(data[319:256]),
//   .out(mux_4_res)
// );

// mux_4to1_16bit u_mux_5 (
//   .mask(mask[23:20]),
//   .data(data[383:320]),
//   .out(mux_5_res)
// );

// mux_4to1_16bit u_mux_6 (
//   .mask(mask[27:24]),
//   .data(data[447:384]),
//   .out(mux_6_res)
// );

// mux_4to1_16bit u_mux_7 (
//   .mask(mask[31:28]),
//   .data(data[511:448]),
//   .out(mux_7_res)
// );

// assign out = |mask[31:28] ? mux_7_res : 
//              |mask[31:28] ? mux_6_res : 
//              |mask[27:24] ? mux_5_res : 
//              |mask[23:20] ? mux_4_res : 
//              |mask[19:16] ? mux_3_res : 
//              |mask[15:12] ? mux_2_res : 
//              |mask[11:8] ? mux_1_res : 
//              |mask[3:0] ? mux_0_res : 0;

always @(*) begin
  case(1'b1)
    mask[0]: out = data[15:0];
    mask[1]: out = data[31:16];
    mask[2]: out = data[47:32];
    mask[3]: out = data[63:48];
    mask[4]: out = data[79:64];
    mask[5]: out = data[95:80];
    mask[6]: out = data[111:96];
    mask[7]: out = data[127:112];
    mask[8]: out = data[143:128];
    mask[9]: out = data[159:144];
    mask[10]: out = data[175:160];
    mask[11]: out = data[191:176];
    mask[12]: out = data[207:192];
    mask[13]: out = data[223:208];
    mask[14]: out = data[239:224];
    mask[15]: out = data[255:240];
    mask[16]: out = data[271:256];
    mask[17]: out = data[287:272];
    mask[18]: out = data[303:288];
    mask[19]: out = data[319:304];
    mask[20]: out = data[335:320];
    mask[21]: out = data[351:336];
    mask[22]: out = data[367:352];
    mask[23]: out = data[383:368];
    mask[24]: out = data[399:384];
    mask[25]: out = data[415:400];
    mask[26]: out = data[431:416];
    mask[27]: out = data[447:432];
    mask[28]: out = data[463:448];
    mask[29]: out = data[479:464];
    mask[30]: out = data[495:480];
    mask[31]: out = data[511:496];
    default: out = 0;
  endcase
end

endmodule
