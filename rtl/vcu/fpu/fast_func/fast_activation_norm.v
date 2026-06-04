module fast_activation_norm(
  data, sum, opcode, lzd_o, out
);

input [31:0] data;
input [63:0] sum;
input [5:0] opcode;
input [5:0] lzd_o;
output [31:0] out;

reg [23:0] mantissa;    //1+mantissa
// reg flag;    //if 1, jump out
// integer i;

wire [7:0] exp;
wire [63:0] sum_shift;

assign sum_shift = sum << lzd_o;

assign exp = 136 - lzd_o;

assign out = (&data[30:23] && |data[22:0]) ? 32'hFFFFFFFF :
             (&data[30:23] && ~(|data[22:0]) && (opcode[2:0]==3'b100 || opcode[2:0]==3'b101 || opcode[2:0]==3'b110)) ? (data[31]) ? 32'hFFFFFFFF : 32'h7F800000 :
             (data[30:23] > 130 && ~data[31] && (opcode[2:0]==3'b100 || opcode[2:0]==3'b101 || opcode[2:0]==3'b110)) ? data :
             ~(|mantissa) ? 32'b0 : (opcode[2:0]==3'b011) ? {1'b0, exp, mantissa[22:0]} : {data[31], exp, mantissa[22:0]};

always @(*) begin
  //NaN
  if(&data[30:23] && |data[22:0]) begin
    mantissa = 0;
  end
  //inf, sigmoid and tanh output as usual
  else if(&data[30:23] && ~(|data[22:0]) && (opcode[2:0]==3'b100 || opcode[2:0]==3'b101 || opcode[2:0]==3'b110)) begin
    mantissa = 0;
  end
  else if(data[30:23] > 130 && ~data[31] && (opcode[2:0]==3'b100 || opcode[2:0]==3'b101 || opcode[2:0]==3'b110)) begin
    mantissa = 0;
  end
  else begin
    mantissa = sum_shift[63-:24];
  end
end

endmodule