module mux_4to1_4bit (
  mask,
  data,
  out
);

input [3:0] mask;
input [15:0] data;
output reg [3:0] out;

always @(*) begin
  case(1'b1)
    mask[0]: out = data[3:0];
    mask[1]: out = data[7:4];
    mask[2]: out = data[11:8];
    mask[3]: out = data[15:12];
    default: out = 0;
  endcase
end

endmodule
