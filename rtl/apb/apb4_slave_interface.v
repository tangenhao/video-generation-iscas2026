//File name  :    apb4_slave_interface.v
//Author     :    xiaocuicui
//Time       :    2024/03/29 09:41:47
//Version    :    V1.0
//Abstract   :    pstrb is not used    


module apb4_slave_interface(
pclk, presetn, 
paddr, psel, penable, pwrite, 
pready, 
pwdata, pstrb, 
prdata,
pprot, pslverr, 

raddr_S_fifo_addr, raddr_S_fifo_ready, raddr_S_fifo_valid, 
rdata_S_fifo_data, rdata_S_fifo_ready, rdata_S_fifo_valid,

waddr_S_fifo_addr, waddr_S_fifo_ready, waddr_S_fifo_valid, 
wdata_S_fifo_data, wdata_S_fifo_ready, wdata_S_fifo_valid

);

//Define pins:
input pclk;
input presetn;
input [31:0] paddr;
input psel;
input penable;
input pwrite;
output wire pready;
input [31:0] pwdata;
input [3:0] pstrb;
output wire [31:0] prdata;
input [2:0] pprot;
output wire pslverr;

output wire [31:0] raddr_S_fifo_addr;
input raddr_S_fifo_ready;
output wire raddr_S_fifo_valid;
input [31:0] rdata_S_fifo_data;
input rdata_S_fifo_ready;
output wire rdata_S_fifo_valid;

output wire [31:0] waddr_S_fifo_addr;
input waddr_S_fifo_ready;
output wire waddr_S_fifo_valid;
output wire [31:0] wdata_S_fifo_data;
input wdata_S_fifo_ready;
output wire wdata_S_fifo_valid;

// assign pprot = 3'b000;
assign pslverr = 1'b0;


//Define signals:
reg apb_w_ready, apb_r_ready;
assign pready = (apb_w_ready & pwrite) | (apb_r_ready & !pwrite);

reg fifo_waddr_wen, fifo_wdata_wen;
reg [31:0] fifo_waddr, fifo_wdata;
reg apb_waddr_flag;
assign waddr_S_fifo_addr = fifo_waddr;
assign waddr_S_fifo_valid = fifo_waddr_wen;
assign wdata_S_fifo_data = fifo_wdata;
assign wdata_S_fifo_valid = fifo_wdata_wen;

reg fifo_raddr_wen, fifo_rdata_ren;
reg [31:0] fifo_raddr, fifo_rdata;
reg apb_raddr_flag;
assign raddr_S_fifo_addr = fifo_raddr;
assign raddr_S_fifo_valid = fifo_raddr_wen;
assign rdata_S_fifo_valid = fifo_rdata_ren;
assign prdata = fifo_rdata;


//Edit code:
always @(posedge pclk or negedge presetn) begin
if (!presetn) begin
apb_waddr_flag <= 1'b0;
fifo_waddr_wen <= 1'b0;
fifo_waddr <= 'd0;
fifo_wdata_wen <= 1'b0;
fifo_wdata <= 'd0;
apb_w_ready <= 1'b0;
end
else begin

if (psel && pwrite) begin
    apb_waddr_flag <= 1'b1;
end
else begin
    if (fifo_waddr_wen) begin
        apb_waddr_flag <= 1'b0;
    end
    else begin
        apb_waddr_flag <= apb_waddr_flag;
    end
end

if (apb_waddr_flag && waddr_S_fifo_ready && !fifo_waddr_wen) begin
    fifo_waddr_wen <= 1'b1;
    fifo_waddr <= paddr;
end
else begin
    fifo_waddr_wen <= 1'b0;
    fifo_waddr <= fifo_waddr;
end

if (psel && wdata_S_fifo_ready && penable && pwrite) begin
    fifo_wdata_wen <= 1'b1;
    fifo_wdata <= pwdata;
end
else begin
    fifo_wdata_wen <= 1'b0;
    fifo_wdata <= fifo_wdata;
end

if (psel && wdata_S_fifo_ready && pwrite && !pready) begin
    apb_w_ready <= 1'b1;
end
else begin
    if (apb_w_ready && penable) begin
        apb_w_ready <= 1'b0;
    end
    else begin
        apb_w_ready <= apb_w_ready;
    end
end


end
end


always @(posedge pclk or negedge presetn) begin
if (!presetn) begin
apb_r_ready <= 1'b0;
fifo_raddr_wen <= 1'b0;
fifo_raddr <= 'd0;
fifo_rdata_ren <= 1'b0;
// fifo_rdata_valid <= 1'b0;
apb_raddr_flag <= 1'b0;
end
else begin

// if (psel && penable && !pwrite && !apb_raddr_flag) begin
//     apb_raddr_flag <= 1'b1;
// end
// else begin
//     if (fifo_raddr_wen) begin
//         apb_raddr_flag <= 1'b0;
//     end
//     else begin
//         apb_raddr_flag <= apb_raddr_flag;
//     end
// end

if (psel && penable && !pwrite && pready ) begin
    apb_raddr_flag <= 1'b0;
end
else begin
    if (raddr_S_fifo_ready && fifo_raddr_wen) begin
        apb_raddr_flag <= 1'b1;
    end
    else begin
        apb_raddr_flag <= apb_raddr_flag;
    end
end


if (psel && penable && !pwrite && !apb_raddr_flag && raddr_S_fifo_ready && !fifo_raddr_wen) begin
    fifo_raddr_wen <= 1'b1;
    fifo_raddr <= paddr;
end
else begin
    fifo_raddr_wen <= 1'b0;
    fifo_raddr <= fifo_raddr;
end

if (psel && !pwrite && rdata_S_fifo_ready && penable && !fifo_rdata_ren) begin
    fifo_rdata_ren <= 1'b1;
end
else begin
    fifo_rdata_ren <= 1'b0;
end

// if (fifo_rdata_ren) begin
//     fifo_rdata_valid <= fifo_rdata_ren;
// end
// else begin
//     fifo_rdata_valid <= 1'b0;
// end

if (fifo_rdata_ren) begin
    apb_r_ready <= 1'b0;
end
else begin
    if (psel) begin
        apb_r_ready <= 1'b0;
    end
    else if (apb_r_ready && penable) begin
        apb_r_ready <= 1'b0;
    end
    else begin
        apb_r_ready <= apb_r_ready;
    end
end

if (fifo_rdata_ren) begin
    fifo_rdata <= rdata_S_fifo_data;
end
else begin
    fifo_rdata <= fifo_rdata;
end


end
end







endmodule

