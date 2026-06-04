module compare(
  input wire clk,
  input wire rst_n,
  input  [15 : 0] op1,
  input  [15 : 0] op2,
  input  [15 : 0] op3,
  input  [15 : 0] op4,   
  input  [5:0] operation,
  input valid,
  output [15 : 0] data_out,
  output reg done   
);

localparam COMP_GEQ         = 6'b000100;
localparam COMP_LES         = 6'b000101;
localparam COMP_GRE         = 6'b101011;
localparam COMP_LEQ         = 6'b101100;

wire [15 : 0] bigger;
wire [15 : 0] smaller;
wire [15 : 0] bigger_eq;
wire [15 : 0] smaller_eq;
wire a_equal_b;
wire a_less_b;
wire a_greater_b;
wire a_sign;
wire b_sign;
wire [4:0] a_exp;
wire [4:0] b_exp;
wire [9:0] a_frac;
wire [9:0] b_frac;
wire a_zero;
wire b_zero;
wire a_nan;
wire b_nan;
wire unordered;
wire same_sign;
wire a_mag_greater_b;
wire a_mag_less_b;

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
   
assign a_sign = op1[15];
assign b_sign = op2[15];
assign a_exp  = op1[14:10];
assign b_exp  = op2[14:10];
assign a_frac = op1[9:0];
assign b_frac = op2[9:0];

assign a_zero = (~(|a_exp)) & (~(|a_frac));
assign b_zero = (~(|b_exp)) & (~(|b_frac));
assign a_nan  = (&a_exp) & (|a_frac);
assign b_nan  = (&b_exp) & (|b_frac);
assign unordered = a_nan | b_nan;

assign same_sign = ~(a_sign ^ b_sign);
assign a_mag_greater_b = {a_exp, a_frac} > {b_exp, b_frac};
assign a_mag_less_b    = {a_exp, a_frac} < {b_exp, b_frac};

assign a_equal_b = !unordered & (((op1 == op2) | (a_zero & b_zero)));
assign a_greater_b = !unordered & !a_equal_b &
                     ((~a_sign & b_sign) |
                      (same_sign & ~a_sign & a_mag_greater_b) |
                      (same_sign &  a_sign & a_mag_less_b));
assign a_less_b = !unordered & !a_equal_b &
                  ((a_sign & ~b_sign) |
                   (same_sign & ~a_sign & a_mag_less_b) |
                   (same_sign &  a_sign & a_mag_greater_b));

assign bigger =  a_greater_b ? op3 : op4;
assign smaller = a_less_b    ? op3 : op4;
assign bigger_eq = (a_greater_b | a_equal_b) ? op3 : op4;
assign smaller_eq = (a_less_b | a_equal_b) ? op3 : op4;

assign data_out = ({16{operation == COMP_GEQ}} & bigger_eq) | ({16{operation == COMP_LES}} & smaller) | 
                  ({16{operation == COMP_GRE}} & bigger) | ({16{operation == COMP_LEQ}} & smaller_eq);
    
endmodule
