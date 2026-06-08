module and_minus(
  in, out
);

parameter width = 4;

input wire [width-1:0] in;
output wire [width-1:0] out;

wire signed [width-1:0] in_minus;
assign in_minus = -in;

assign out = in & in_minus;

endmodule