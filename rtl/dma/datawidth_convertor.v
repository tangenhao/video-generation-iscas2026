//File name  :    datawidth_convertor.v
//Author     :    xiaocuicui
//Time       :    2024/01/13 22:12:18
//Version    :    V1.0
//Abstract   :        


module datawidth_convertor(
  clk, rst_n,
  data_in, valid_in, ready_in, 
  data_out, valid_out, ready_out
);


//Define parameters:
function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

parameter integer DATA_IN_WIDTH = 512;
parameter integer DATA_OUT_WIDTH = 2048;

localparam integer DATA_IN_BYTES = DATA_IN_WIDTH / 8;
localparam integer DATA_IN_BITS = clogb2(DATA_IN_BYTES - 1);
localparam integer DATA_OUT_BYTES = DATA_OUT_WIDTH / 8;
localparam integer DATA_OUT_BITS = clogb2(DATA_OUT_BYTES - 1);
localparam integer IN_DIV_OUT_BITS = DATA_IN_BITS - DATA_OUT_BITS;
localparam integer IN_DIV_OUT_BYTES = (1 << IN_DIV_OUT_BITS) - 1;
localparam integer OUT_DIV_IN_BITS = DATA_OUT_BITS - DATA_IN_BITS;
localparam integer OUT_DIV_IN_BYTES = (1 << OUT_DIV_IN_BITS) - 1;

//Define pins:
input                            clk;
input                            rst_n;
input [DATA_IN_WIDTH-1:0]        data_in;
input                            valid_in;
output                           ready_in;
output wire [DATA_OUT_WIDTH-1:0] data_out;
output wire                      valid_out;
input                            ready_out;

//Define signals:
reg work;


//Edit code:
generate 

if (DATA_IN_WIDTH > DATA_OUT_WIDTH) begin : large2small

reg [DATA_OUT_WIDTH-1:0] data_out_reg;
assign data_out = data_out_reg;
reg ready_in_reg;
assign ready_in = ready_in_reg;
reg valid_out_reg;
assign valid_out = valid_out_reg;

reg [DATA_IN_WIDTH-1:0] data_in_reg;
reg [IN_DIV_OUT_BITS:0] count;

always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
work <= 1'b0;
ready_in_reg <= 1'b0;
data_in_reg <= 'd0;
valid_out_reg <= 1'b0;
data_out_reg <= 'd0;
count <= 'd0;
end
else begin

if ((!work) && (!ready_in_reg)) begin
    ready_in_reg <= 1'b1;
end
else if (ready_in_reg && valid_in) begin
    ready_in_reg <= 1'b0;
end
else begin
    ready_in_reg <= ready_in_reg;
end

if (ready_in && valid_in) begin
    data_in_reg <= (data_in >> DATA_OUT_WIDTH);
end
else if (valid_out_reg && ready_out) begin
    data_in_reg <= (data_in_reg >> DATA_OUT_WIDTH);
end
else begin
    data_in_reg <= data_in_reg;
end

if (ready_in && valid_in) begin
    valid_out_reg <= 1'b1;
end 
else if (valid_out_reg && ready_out && (& count)) begin
    valid_out_reg <= 1'b0;
end
else begin
    valid_out_reg <= valid_out_reg;
end

if (ready_in_reg && valid_in) begin
    data_out_reg <= data_in[DATA_OUT_WIDTH-1:0];
end
else if (ready_out && valid_out_reg) begin
    data_out_reg <= data_in_reg[DATA_OUT_WIDTH-1:0];
end
else begin
    data_out_reg <= data_out_reg;
end

if (ready_out && valid_out_reg) begin
    count <= count + 1'b1;
end
else begin
    count <= count;
end

if (ready_in_reg && valid_in) begin
    work <= 1'b1;
end
else if (ready_out && valid_out_reg && (& count)) begin
    work <= 1'b0;
end
else begin
    work <= work;
end

end //the end of biggest if
end //the end of always


end
else if (DATA_IN_WIDTH < DATA_OUT_WIDTH) begin : small2large

reg [DATA_OUT_WIDTH-1:0] data_out_reg;
assign data_out = data_out_reg;
reg ready_in_reg;
assign ready_in = ready_in_reg;
reg valid_out_reg;
assign valid_out = valid_out_reg;

reg [OUT_DIV_IN_BITS:0] count;

always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin
work <= 1'b0;
ready_in_reg <= 1'b0;
valid_out_reg <= 1'b0;
data_out_reg <= 'd0;
count <= 'd0;
end
else begin

if ((!work) && (!ready_in_reg)) begin
    ready_in_reg <= 1'b1;
end
else if (ready_in_reg && valid_in && (& count)) begin
    ready_in_reg <= 1'b0;
end
else begin
    ready_in_reg <= ready_in_reg;
end

if (ready_in_reg && valid_in && (& count)) begin
    valid_out_reg <= 1'b1;
end    
else if (ready_in && valid_in) begin
    valid_out_reg <= 1'b0;
end
else begin
    valid_out_reg <= valid_out_reg;
end

if (ready_in_reg && valid_in) begin
    data_out_reg <= {data_in, data_out_reg[DATA_OUT_WIDTH-1-:DATA_IN_WIDTH]};
end
else begin
    data_out_reg <= data_out_reg;
end

if (ready_in_reg && valid_in) begin
    count <= count + 1'b1;
end
else begin
    count <= count;
end

if (ready_in_reg && valid_in) begin
    work <= 1'b1;
end
else if (ready_out && valid_out_reg) begin
    work <= 1'b0;
end
else begin
    work <= work;
end

end //the end of biggest if
end //the end of always


end
else begin : equal

assign data_out = data_in;
assign valid_out = valid_in;
assign ready_in = ready_out;


end //the end of generate branch

endgenerate



endmodule

