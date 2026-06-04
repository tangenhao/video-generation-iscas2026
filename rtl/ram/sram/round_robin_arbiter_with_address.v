module round_robin_arbiter_with_address(
  clk, rst_n,
  request, grant,
  address_0,
  address_1,
  address_2,
  address_3,
  address_4,
  address_5,
  address_6,
  address_7
);
parameter ADDR_WIDTH = 5;
input clk;
input rst_n;
input [7:0] request;
output [7:0] grant;
input [ADDR_WIDTH-1:0] address_0;
input [ADDR_WIDTH-1:0] address_1;
input [ADDR_WIDTH-1:0] address_2;
input [ADDR_WIDTH-1:0] address_3;
input [ADDR_WIDTH-1:0] address_4;
input [ADDR_WIDTH-1:0] address_5;
input [ADDR_WIDTH-1:0] address_6;
input [ADDR_WIDTH-1:0] address_7;
reg [7:0] last_state;
wire [7:0] real_grant;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    last_state <= 8'd1;
  end
  else if (&request) begin
    last_state <= 8'd1;
  end
  else if (|request) begin
    last_state <= {real_grant[6:0], real_grant[7]};
  end
  else begin
    last_state <= last_state;
  end
end
wire [15:0] grant_ext;
assign grant_ext = {request,request} & ~({request,request} - last_state);
assign real_grant = grant_ext[7:0] | grant_ext[15:8];
wire [7:0] addr_equal_0;
wire [7:0] addr_equal_1;
wire [7:0] addr_equal_2;
wire [7:0] addr_equal_3;
wire [7:0] addr_equal_4;
wire [7:0] addr_equal_5;
wire [7:0] addr_equal_6;
wire [7:0] addr_equal_7;
assign addr_equal_0 = {address_7 == address_0, address_6 == address_0, address_5 == address_0, address_4 == address_0, address_3 == address_0, address_2 == address_0, address_1 == address_0, address_0 == address_0};
assign addr_equal_1 = {address_7 == address_1, address_6 == address_1, address_5 == address_1, address_4 == address_1, address_3 == address_1, address_2 == address_1, address_1 == address_1, address_0 == address_1};
assign addr_equal_2 = {address_7 == address_2, address_6 == address_2, address_5 == address_2, address_4 == address_2, address_3 == address_2, address_2 == address_2, address_1 == address_2, address_0 == address_2};
assign addr_equal_3 = {address_7 == address_3, address_6 == address_3, address_5 == address_3, address_4 == address_3, address_3 == address_3, address_2 == address_3, address_1 == address_3, address_0 == address_3};
assign addr_equal_4 = {address_7 == address_4, address_6 == address_4, address_5 == address_4, address_4 == address_4, address_3 == address_4, address_2 == address_4, address_1 == address_4, address_0 == address_4};
assign addr_equal_5 = {address_7 == address_5, address_6 == address_5, address_5 == address_5, address_4 == address_5, address_3 == address_5, address_2 == address_5, address_1 == address_5, address_0 == address_5};
assign addr_equal_6 = {address_7 == address_6, address_6 == address_6, address_5 == address_6, address_4 == address_6, address_3 == address_6, address_2 == address_6, address_1 == address_6, address_0 == address_6};
assign addr_equal_7 = {address_7 == address_7, address_6 == address_7, address_5 == address_7, address_4 == address_7, address_3 == address_7, address_2 == address_7, address_1 == address_7, address_0 == address_7};
assign grant = real_grant[0] ? real_grant | (addr_equal_0 & request) :
               real_grant[1] ? real_grant | (addr_equal_1 & request) :
               real_grant[2] ? real_grant | (addr_equal_2 & request) :
               real_grant[3] ? real_grant | (addr_equal_3 & request) :
               real_grant[4] ? real_grant | (addr_equal_4 & request) :
               real_grant[5] ? real_grant | (addr_equal_5 & request) :
               real_grant[6] ? real_grant | (addr_equal_6 & request) :
               real_grant[7] ? real_grant | (addr_equal_7 & request) :
               8'b0;
endmodule