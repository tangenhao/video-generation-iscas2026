module vculut_arbiter(
  clk, rst_n,
  vculut_0_rvalid, vculut_0_raddr, vculut_0_rdata, vculut_0_rready,
  vculut_1_rvalid, vculut_1_raddr, vculut_1_rdata, vculut_1_rready,
  vculut_2_rvalid, vculut_2_raddr, vculut_2_rdata, vculut_2_rready,
  vculut_3_rvalid, vculut_3_raddr, vculut_3_rdata, vculut_3_rready,
  vculut_4_rvalid, vculut_4_raddr, vculut_4_rdata, vculut_4_rready,
  vculut_5_rvalid, vculut_5_raddr, vculut_5_rdata, vculut_5_rready,
  vculut_6_rvalid, vculut_6_raddr, vculut_6_rdata, vculut_6_rready,
  vculut_7_rvalid, vculut_7_raddr, vculut_7_rdata, vculut_7_rready,
  ren_0, raddr_0, rdata_0,
  ren_1, raddr_1, rdata_1,
  ren_2, raddr_2, rdata_2,
  ren_3, raddr_3, rdata_3
);
input clk;
input rst_n;
input         vculut_0_rvalid;
input  [8:0]  vculut_0_raddr;
output [63:0] vculut_0_rdata;
output        vculut_0_rready;
input         vculut_1_rvalid;
input  [8:0]  vculut_1_raddr;
output [63:0] vculut_1_rdata;
output        vculut_1_rready;
input         vculut_2_rvalid;
input  [8:0]  vculut_2_raddr;
output [63:0] vculut_2_rdata;
output        vculut_2_rready;
input         vculut_3_rvalid;
input  [8:0]  vculut_3_raddr;
output [63:0] vculut_3_rdata;
output        vculut_3_rready;
input         vculut_4_rvalid;
input  [8:0]  vculut_4_raddr;
output [63:0] vculut_4_rdata;
output        vculut_4_rready;
input         vculut_5_rvalid;
input  [8:0]  vculut_5_raddr;
output [63:0] vculut_5_rdata;
output        vculut_5_rready;
input         vculut_6_rvalid;
input  [8:0]  vculut_6_raddr;
output [63:0] vculut_6_rdata;
output        vculut_6_rready;
input         vculut_7_rvalid;
input  [8:0]  vculut_7_raddr;
output [63:0] vculut_7_rdata;
output        vculut_7_rready;
output ren_0;
output ren_1;
output ren_2;
output ren_3;
output [6:0] raddr_0;
output [6:0] raddr_1;
output [6:0] raddr_2;
output [6:0] raddr_3;
input [63:0] rdata_0;
input [63:0] rdata_1;
input [63:0] rdata_2;
input [63:0] rdata_3;
wire [7:0] request_0;
wire [7:0] request_1;
wire [7:0] request_2;
wire [7:0] request_3;
wire [7:0] grant_0;
wire [7:0] grant_1;
wire [7:0] grant_2;
wire [7:0] grant_3;
assign request_0 = {vculut_7_rvalid & vculut_7_raddr[6:5] == 2'b00, vculut_6_rvalid & vculut_6_raddr[6:5] == 2'b00, vculut_5_rvalid & vculut_5_raddr[6:5] == 3'b00, vculut_4_rvalid & vculut_4_raddr[6:5] == 2'b00, vculut_3_rvalid & vculut_3_raddr[6:5] == 2'b00, vculut_2_rvalid & vculut_2_raddr[6:5] == 2'b00, vculut_1_rvalid & vculut_1_raddr[6:5] == 2'b00, vculut_0_rvalid & vculut_0_raddr[6:5] == 2'b00};
assign request_1 = {vculut_7_rvalid & vculut_7_raddr[6:5] == 2'b01, vculut_6_rvalid & vculut_6_raddr[6:5] == 2'b01, vculut_5_rvalid & vculut_5_raddr[6:5] == 3'b01, vculut_4_rvalid & vculut_4_raddr[6:5] == 2'b01, vculut_3_rvalid & vculut_3_raddr[6:5] == 2'b01, vculut_2_rvalid & vculut_2_raddr[6:5] == 2'b01, vculut_1_rvalid & vculut_1_raddr[6:5] == 2'b01, vculut_0_rvalid & vculut_0_raddr[6:5] == 2'b01};
assign request_2 = {vculut_7_rvalid & vculut_7_raddr[6:5] == 2'b10, vculut_6_rvalid & vculut_6_raddr[6:5] == 2'b10, vculut_5_rvalid & vculut_5_raddr[6:5] == 3'b10, vculut_4_rvalid & vculut_4_raddr[6:5] == 2'b10, vculut_3_rvalid & vculut_3_raddr[6:5] == 2'b10, vculut_2_rvalid & vculut_2_raddr[6:5] == 2'b10, vculut_1_rvalid & vculut_1_raddr[6:5] == 2'b10, vculut_0_rvalid & vculut_0_raddr[6:5] == 2'b10};
assign request_3 = {vculut_7_rvalid & vculut_7_raddr[6:5] == 2'b11, vculut_6_rvalid & vculut_6_raddr[6:5] == 2'b11, vculut_5_rvalid & vculut_5_raddr[6:5] == 3'b11, vculut_4_rvalid & vculut_4_raddr[6:5] == 2'b11, vculut_3_rvalid & vculut_3_raddr[6:5] == 2'b11, vculut_2_rvalid & vculut_2_raddr[6:5] == 2'b11, vculut_1_rvalid & vculut_1_raddr[6:5] == 2'b11, vculut_0_rvalid & vculut_0_raddr[6:5] == 2'b11};
round_robin_arbiter_with_address #(
  .ADDR_WIDTH(7)
) u_round_robin_arbiter_with_address_0(
  .clk       ( clk                                        ),
  .rst_n     ( rst_n                                      ),
  .request   ( request_0                                  ),
  .address_0 ( {vculut_0_raddr[8:7], vculut_0_raddr[4:0]} ),
  .address_1 ( {vculut_1_raddr[8:7], vculut_1_raddr[4:0]} ),
  .address_2 ( {vculut_2_raddr[8:7], vculut_2_raddr[4:0]} ),
  .address_3 ( {vculut_3_raddr[8:7], vculut_3_raddr[4:0]} ),
  .address_4 ( {vculut_4_raddr[8:7], vculut_4_raddr[4:0]} ),
  .address_5 ( {vculut_5_raddr[8:7], vculut_5_raddr[4:0]} ),
  .address_6 ( {vculut_6_raddr[8:7], vculut_6_raddr[4:0]} ),
  .address_7 ( {vculut_7_raddr[8:7], vculut_7_raddr[4:0]} ),
  .grant     ( grant_0                                    )
);
round_robin_arbiter_with_address #(
  .ADDR_WIDTH(7)
) u_round_robin_arbiter_with_address_1(
  .clk       ( clk                                        ),
  .rst_n     ( rst_n                                      ),
  .request   ( request_1                                  ),
  .address_0 ( {vculut_0_raddr[8:7], vculut_0_raddr[4:0]} ),
  .address_1 ( {vculut_1_raddr[8:7], vculut_1_raddr[4:0]} ),
  .address_2 ( {vculut_2_raddr[8:7], vculut_2_raddr[4:0]} ),
  .address_3 ( {vculut_3_raddr[8:7], vculut_3_raddr[4:0]} ),
  .address_4 ( {vculut_4_raddr[8:7], vculut_4_raddr[4:0]} ),
  .address_5 ( {vculut_5_raddr[8:7], vculut_5_raddr[4:0]} ),
  .address_6 ( {vculut_6_raddr[8:7], vculut_6_raddr[4:0]} ),
  .address_7 ( {vculut_7_raddr[8:7], vculut_7_raddr[4:0]} ),
  .grant     ( grant_1                                    )
);
round_robin_arbiter_with_address #(
  .ADDR_WIDTH(7)
) u_round_robin_arbiter_with_address_2(
  .clk       ( clk                                        ),
  .rst_n     ( rst_n                                      ),
  .request   ( request_2                                  ),
  .address_0 ( {vculut_0_raddr[8:7], vculut_0_raddr[4:0]} ),
  .address_1 ( {vculut_1_raddr[8:7], vculut_1_raddr[4:0]} ),
  .address_2 ( {vculut_2_raddr[8:7], vculut_2_raddr[4:0]} ),
  .address_3 ( {vculut_3_raddr[8:7], vculut_3_raddr[4:0]} ),
  .address_4 ( {vculut_4_raddr[8:7], vculut_4_raddr[4:0]} ),
  .address_5 ( {vculut_5_raddr[8:7], vculut_5_raddr[4:0]} ),
  .address_6 ( {vculut_6_raddr[8:7], vculut_6_raddr[4:0]} ),
  .address_7 ( {vculut_7_raddr[8:7], vculut_7_raddr[4:0]} ),
  .grant     ( grant_2                                    )
);
round_robin_arbiter_with_address #(
  .ADDR_WIDTH(7)
) u_round_robin_arbiter_with_address_3(
  .clk       ( clk                                        ),
  .rst_n     ( rst_n                                      ),
  .request   ( request_3                                  ),
  .address_0 ( {vculut_0_raddr[8:7], vculut_0_raddr[4:0]} ),
  .address_1 ( {vculut_1_raddr[8:7], vculut_1_raddr[4:0]} ),
  .address_2 ( {vculut_2_raddr[8:7], vculut_2_raddr[4:0]} ),
  .address_3 ( {vculut_3_raddr[8:7], vculut_3_raddr[4:0]} ),
  .address_4 ( {vculut_4_raddr[8:7], vculut_4_raddr[4:0]} ),
  .address_5 ( {vculut_5_raddr[8:7], vculut_5_raddr[4:0]} ),
  .address_6 ( {vculut_6_raddr[8:7], vculut_6_raddr[4:0]} ),
  .address_7 ( {vculut_7_raddr[8:7], vculut_7_raddr[4:0]} ),
  .grant     ( grant_3                                    )
);
assign ren_0 = |grant_0;
assign ren_1 = |grant_1;
assign ren_2 = |grant_2;
assign ren_3 = |grant_3;
assign raddr_0 = grant_0[0] ? {vculut_0_raddr[8:7], vculut_0_raddr[4:0]} :
                 grant_0[1] ? {vculut_1_raddr[8:7], vculut_1_raddr[4:0]} :
                 grant_0[2] ? {vculut_2_raddr[8:7], vculut_2_raddr[4:0]} :
                 grant_0[3] ? {vculut_3_raddr[8:7], vculut_3_raddr[4:0]} :
                 grant_0[4] ? {vculut_4_raddr[8:7], vculut_4_raddr[4:0]} :
                 grant_0[5] ? {vculut_5_raddr[8:7], vculut_5_raddr[4:0]} :
                 grant_0[6] ? {vculut_6_raddr[8:7], vculut_6_raddr[4:0]} :
                 grant_0[7] ? {vculut_7_raddr[8:7], vculut_7_raddr[4:0]} : 5'b0;
assign raddr_1 = grant_1[0] ? {vculut_0_raddr[8:7], vculut_0_raddr[4:0]} :
                 grant_1[1] ? {vculut_1_raddr[8:7], vculut_1_raddr[4:0]} :
                 grant_1[2] ? {vculut_2_raddr[8:7], vculut_2_raddr[4:0]} :
                 grant_1[3] ? {vculut_3_raddr[8:7], vculut_3_raddr[4:0]} :
                 grant_1[4] ? {vculut_4_raddr[8:7], vculut_4_raddr[4:0]} :
                 grant_1[5] ? {vculut_5_raddr[8:7], vculut_5_raddr[4:0]} :
                 grant_1[6] ? {vculut_6_raddr[8:7], vculut_6_raddr[4:0]} :
                 grant_1[7] ? {vculut_7_raddr[8:7], vculut_7_raddr[4:0]} : 5'b0; 
assign raddr_2 = grant_2[0] ? {vculut_0_raddr[8:7], vculut_0_raddr[4:0]} :
                 grant_2[1] ? {vculut_1_raddr[8:7], vculut_1_raddr[4:0]} :
                 grant_2[2] ? {vculut_2_raddr[8:7], vculut_2_raddr[4:0]} :
                 grant_2[3] ? {vculut_3_raddr[8:7], vculut_3_raddr[4:0]} :
                 grant_2[4] ? {vculut_4_raddr[8:7], vculut_4_raddr[4:0]} :
                 grant_2[5] ? {vculut_5_raddr[8:7], vculut_5_raddr[4:0]} :
                 grant_2[6] ? {vculut_6_raddr[8:7], vculut_6_raddr[4:0]} :
                 grant_2[7] ? {vculut_7_raddr[8:7], vculut_7_raddr[4:0]} : 5'b0;
assign raddr_3 = grant_3[0] ? {vculut_0_raddr[8:7], vculut_0_raddr[4:0]} :
                 grant_3[1] ? {vculut_1_raddr[8:7], vculut_1_raddr[4:0]} :
                 grant_3[2] ? {vculut_2_raddr[8:7], vculut_2_raddr[4:0]} :
                 grant_3[3] ? {vculut_3_raddr[8:7], vculut_3_raddr[4:0]} :
                 grant_3[4] ? {vculut_4_raddr[8:7], vculut_4_raddr[4:0]} :
                 grant_3[5] ? {vculut_5_raddr[8:7], vculut_5_raddr[4:0]} :
                 grant_3[6] ? {vculut_6_raddr[8:7], vculut_6_raddr[4:0]} :
                 grant_3[7] ? {vculut_7_raddr[8:7], vculut_7_raddr[4:0]} : 5'b0;
reg [7:0] grant_reg_0;
reg [7:0] grant_reg_1;
reg [7:0] grant_reg_2;
reg [7:0] grant_reg_3;
reg [7:0] request_reg_0;
reg [7:0] request_reg_1;
reg [7:0] request_reg_2;
reg [7:0] request_reg_3;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    grant_reg_0 <= 8'b0;
    grant_reg_1 <= 8'b0;
    grant_reg_2 <= 8'b0;
    grant_reg_3 <= 8'b0;
  end
  else begin
    grant_reg_0 <= grant_0;
    grant_reg_1 <= grant_1;
    grant_reg_2 <= grant_2;
    grant_reg_3 <= grant_3;
  end
end
assign vculut_0_rready = grant_0[0] | grant_1[0] | grant_2[0] | grant_3[0];
assign vculut_1_rready = grant_0[1] | grant_1[1] | grant_2[1] | grant_3[1];
assign vculut_2_rready = grant_0[2] | grant_1[2] | grant_2[2] | grant_3[2];
assign vculut_3_rready = grant_0[3] | grant_1[3] | grant_2[3] | grant_3[3];
assign vculut_4_rready = grant_0[4] | grant_1[4] | grant_2[4] | grant_3[4];
assign vculut_5_rready = grant_0[5] | grant_1[5] | grant_2[5] | grant_3[5];
assign vculut_6_rready = grant_0[6] | grant_1[6] | grant_2[6] | grant_3[6];
assign vculut_7_rready = grant_0[7] | grant_1[7] | grant_2[7] | grant_3[7];
assign vculut_0_rdata = ({64{grant_reg_0[0]}} & rdata_0) | ({64{grant_reg_1[0]}} & rdata_1) | ({64{grant_reg_2[0]}} & rdata_2) | ({64{grant_reg_3[0]}} & rdata_3);
assign vculut_1_rdata = ({64{grant_reg_0[1]}} & rdata_0) | ({64{grant_reg_1[1]}} & rdata_1) | ({64{grant_reg_2[1]}} & rdata_2) | ({64{grant_reg_3[1]}} & rdata_3);
assign vculut_2_rdata = ({64{grant_reg_0[2]}} & rdata_0) | ({64{grant_reg_1[2]}} & rdata_1) | ({64{grant_reg_2[2]}} & rdata_2) | ({64{grant_reg_3[2]}} & rdata_3);
assign vculut_3_rdata = ({64{grant_reg_0[3]}} & rdata_0) | ({64{grant_reg_1[3]}} & rdata_1) | ({64{grant_reg_2[3]}} & rdata_2) | ({64{grant_reg_3[3]}} & rdata_3);
assign vculut_4_rdata = ({64{grant_reg_0[4]}} & rdata_0) | ({64{grant_reg_1[4]}} & rdata_1) | ({64{grant_reg_2[4]}} & rdata_2) | ({64{grant_reg_3[4]}} & rdata_3);
assign vculut_5_rdata = ({64{grant_reg_0[5]}} & rdata_0) | ({64{grant_reg_1[5]}} & rdata_1) | ({64{grant_reg_2[5]}} & rdata_2) | ({64{grant_reg_3[5]}} & rdata_3);
assign vculut_6_rdata = ({64{grant_reg_0[6]}} & rdata_0) | ({64{grant_reg_1[6]}} & rdata_1) | ({64{grant_reg_2[6]}} & rdata_2) | ({64{grant_reg_3[6]}} & rdata_3);
assign vculut_7_rdata = ({64{grant_reg_0[7]}} & rdata_0) | ({64{grant_reg_1[7]}} & rdata_1) | ({64{grant_reg_2[7]}} & rdata_2) | ({64{grant_reg_3[7]}} & rdata_3);
endmodule