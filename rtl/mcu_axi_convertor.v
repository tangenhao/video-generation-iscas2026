module mcu_axi_convertor(
  highaddr, in_address,
  out_address
);

input  [31:0] highaddr;
input  [31:0] in_address;
output [63:0] out_address;

assign out_address = in_address[31] ? {1'b0, highaddr, in_address[30:0]} : {32'b0, in_address[30:0]};

endmodule