module mux_4to1_8bit (
  mask,
  data,
  out
);

input [3:0] mask;
input [31:0] data;
output reg [7:0] out;

always @(*) begin
  case(1'b1)
    mask[0]: out = data[7:0];
    mask[1]: out = data[15:8];
    mask[2]: out = data[23:16];
    mask[3]: out = data[31:24];
    default: out = 0;
  endcase
end

endmodule
