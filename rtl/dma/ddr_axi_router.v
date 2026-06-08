module ddr_axi_router(
  in_addr, out_addr
);

input  [63:0] in_addr;
output [63:0] out_addr;

assign out_addr = !in_addr[37] ? {4'b0110, 28'd0, in_addr[31:0]} : {4'b0001, 28'd0, in_addr[31:0]};

endmodule