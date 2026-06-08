module mux_4to1_16bit (
  mask,
  data,
  out
);

input [3:0] mask;
input [63:0] data;
output reg [15:0] out;

always @(*) begin
  case(1'b1)
    mask[0]: out = data[15:0];
    mask[1]: out = data[31:16];
    mask[2]: out = data[47:32];
    mask[3]: out = data[63:48];
    default: out = 0;
  endcase
end

endmodule
