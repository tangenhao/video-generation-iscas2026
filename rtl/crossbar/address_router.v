module address_router(
  in_address,
  out_address,
  local_highaddr
);

parameter ADDR_WIDTH = 64;
parameter HIGHADDR_BITS = 16;
parameter VALIDADDR_BITS = 44;

input  [ADDR_WIDTH-1:0] in_address;
output [ADDR_WIDTH-1:0] out_address;
input  [HIGHADDR_BITS-1:0] local_highaddr;
// output [HIGHADDR_BITS-1:0] route_highaddr;

wire match;

assign match = in_address[59:44] == local_highaddr;

// wire [1:0] ori_issue_addr;
// wire [1:0] dst_issue_addr;
// assign ori_issue_addr = in_address[(VALIDADDR_BITS-2)+:2];
// assign dst_issue_addr = ori_issue_addr == 2'b01 ? 2'b10
//                       : ori_issue_addr == 2'b10 ? 2'b01
//                       : 2'b00;

// assign out_address = match ? in_address[VALIDADDR_BITS-3:0] : in_address;
assign out_address = match ? {in_address[43:40], {HIGHADDR_BITS{1'b0}}, 4'b0, in_address[39:0]} : in_address;
endmodule