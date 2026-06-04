
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/19 15:05:33
// Design Name: 
// Module Name: reverse
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reverse(
    input wire clk,
    input wire rst_n,
    input   [15:0]  op1,
    input valid,
    input  [5:0] opration,
    output [15:0] data_out,
    output reg done
    );
    wire [15:0] float16_abs;
    wire [15:0] float16_reverse;

    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done <= 'd0;
    end
    else if(valid)begin 
        done <= 'd1;
    end
    else begin
        done <= 'd0;
    end
    end
    assign float16_reverse = {~op1[15], op1[14:0]};
    assign float16_abs = {1'b0, op1[14:0]};
       
    assign data_out = ( {16{opration == 6'b011001}} & float16_abs) | ( {16{opration == 6'b011000}} & float16_reverse);
    
endmodule

