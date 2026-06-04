module vcu_regfile(
  clk, rst_n,

  next_state, register_change_sign, 
  config_sign, store_sign, config_data,
  compute_done, activation_tanh, out,
  copy_sign, other_op1,
  tanh_done, tanh_iteration_0,
  reduce_done, reduce_out, reduce_sign,
  outlier_compress_out, outlier_compress_sign,

  iteration_reg
);

localparam IDLE       = 4'b0000;
localparam DECODE     = 4'b0001;
localparam COMPUTE    = 4'b0010;
localparam DONE       = 4'b0011;
localparam ACTIVATION = 4'b0100;
localparam REDUCE     = 4'b0101;
localparam SIN_COS    = 4'b0110;

parameter DATA_WIDTH = 1024;

input                     clk;
input                     rst_n;
input [3:0]               next_state;
input                     register_change_sign;
input                     config_sign;
input                     store_sign;
input [DATA_WIDTH-1:0]    config_data;
input                     compute_done;
input                     activation_tanh;
input [DATA_WIDTH-1:0]    out;
input                     copy_sign;
input [DATA_WIDTH-1:0]    other_op1;
input                     tanh_done;
input [DATA_WIDTH-1:0]    tanh_iteration_0;
input                     reduce_done;
input [DATA_WIDTH-1:0]    reduce_out;
input                     reduce_sign;
input [DATA_WIDTH-1:0]    outlier_compress_out;
input                     outlier_compress_sign;

output reg  [DATA_WIDTH-1:0] iteration_reg;

wire [DATA_WIDTH-1:0] iteration_copy;
wire [DATA_WIDTH-1:0] iteration;

assign iteration = config_sign && store_sign ? config_data :
                   compute_done && store_sign && (!config_sign) && (!activation_tanh) && (!reduce_done) ? out :
                   copy_sign && store_sign ? other_op1 :
                   (!store_sign) ? iteration_reg :
                   tanh_done && store_sign && (!config_sign) ? tanh_iteration_0 :
                   reduce_done && store_sign && (!config_sign) ? reduce_out :
                   outlier_compress_sign && store_sign && (!config_sign) && (!activation_tanh) ? outlier_compress_out : iteration_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
      iteration_reg <= 'd0;
  end
  else begin 
    if ((next_state == DONE) | (compute_done & (~activation_tanh) & (~reduce_sign)) | register_change_sign | tanh_done | reduce_done) begin
      iteration_reg <= iteration;
    end
    else begin
      iteration_reg <= iteration_reg;
    end
  end
end

endmodule