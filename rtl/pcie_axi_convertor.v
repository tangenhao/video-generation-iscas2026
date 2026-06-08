module pcie_axi_convertor(
  mode_sel,
  highaddr, in_address,
  out_address
);

input  [2:0]  mode_sel;
input  [31:0] highaddr;
input  [63:0] in_address;
output [63:0] out_address;

assign out_address = mode_sel == 3'b001 ? in_address[31] ? {1'b0, highaddr, in_address[30:0]} : {32'b0, in_address[30:0]} : in_address;

endmodule