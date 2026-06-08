module mux_4to1_1bit (
  mask,
  data,
  out
);

input [3:0] mask;
input [3:0] data;
output reg out;

always @(*) begin
  case(1'b1)
    mask[0]: out = data[0];
    mask[1]: out = data[1];
    mask[2]: out = data[2];
    mask[3]: out = data[3];
    default: out = 0;
  endcase
end

endmodule
