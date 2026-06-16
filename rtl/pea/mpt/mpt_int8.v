module mpt_int8 (
  clk, rst_n,
  valid,
  a, b,
  o,
  done, clear
);

parameter PARALLELISM = 16;

input                            clk;
input                            rst_n;
input                            valid;
input       [PARALLELISM*16-1:0] a;
input       [PARALLELISM*16-1:0] b;
output wire [31:0]               o;
output wire                      done;
input                            clear;

localparam INT8_COUNT = PARALLELISM * 2;

wire signed [7:0]  a_int8[0:INT8_COUNT-1];
wire signed [7:0]  b_int8[0:INT8_COUNT-1];
wire signed [15:0] product[0:INT8_COUNT-1];

reg signed [31:0] product_pair[0:PARALLELISM-1];
reg signed [31:0] sum_stage_0[0:PARALLELISM/2-1];
reg signed [31:0] sum_stage_1[0:PARALLELISM/4-1];
reg signed [31:0] sum_stage_2[0:PARALLELISM/8-1];
reg signed [31:0] sum_stage_3;
reg signed [31:0] result_delay[0:5];
reg [10:0]        valid_pipe;

assign done = valid_pipe[10];
assign o    = result_delay[5];

genvar unpack_i;
generate
  for (unpack_i = 0; unpack_i < INT8_COUNT; unpack_i = unpack_i + 1) begin : int8_unpack
    assign a_int8[unpack_i] = a[unpack_i*8+:8];
    assign b_int8[unpack_i] = b[unpack_i*8+:8];
    assign product[unpack_i] = a_int8[unpack_i] * b_int8[unpack_i];
  end
endgenerate

integer product_i;
integer sum_i;
integer delay_i;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    valid_pipe <= 11'd0;
    sum_stage_3 <= 32'd0;
    for (product_i = 0; product_i < PARALLELISM; product_i = product_i + 1) begin
      product_pair[product_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/2; sum_i = sum_i + 1) begin
      sum_stage_0[sum_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/4; sum_i = sum_i + 1) begin
      sum_stage_1[sum_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/8; sum_i = sum_i + 1) begin
      sum_stage_2[sum_i] <= 32'd0;
    end
    for (delay_i = 0; delay_i < 6; delay_i = delay_i + 1) begin
      result_delay[delay_i] <= 32'd0;
    end
  end
  else if (clear) begin
    valid_pipe <= 11'd0;
    sum_stage_3 <= 32'd0;
    for (product_i = 0; product_i < PARALLELISM; product_i = product_i + 1) begin
      product_pair[product_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/2; sum_i = sum_i + 1) begin
      sum_stage_0[sum_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/4; sum_i = sum_i + 1) begin
      sum_stage_1[sum_i] <= 32'd0;
    end
    for (sum_i = 0; sum_i < PARALLELISM/8; sum_i = sum_i + 1) begin
      sum_stage_2[sum_i] <= 32'd0;
    end
    for (delay_i = 0; delay_i < 6; delay_i = delay_i + 1) begin
      result_delay[delay_i] <= 32'd0;
    end
  end
  else begin
    valid_pipe <= {valid_pipe[9:0], valid};

    for (product_i = 0; product_i < PARALLELISM; product_i = product_i + 1) begin
      product_pair[product_i] <= {{16{product[product_i*2][15]}}, product[product_i*2]} +
                                 {{16{product[product_i*2+1][15]}}, product[product_i*2+1]};
    end

    for (sum_i = 0; sum_i < PARALLELISM/2; sum_i = sum_i + 1) begin
      sum_stage_0[sum_i] <= product_pair[sum_i*2] + product_pair[sum_i*2+1];
    end

    for (sum_i = 0; sum_i < PARALLELISM/4; sum_i = sum_i + 1) begin
      sum_stage_1[sum_i] <= sum_stage_0[sum_i*2] + sum_stage_0[sum_i*2+1];
    end

    for (sum_i = 0; sum_i < PARALLELISM/8; sum_i = sum_i + 1) begin
      sum_stage_2[sum_i] <= sum_stage_1[sum_i*2] + sum_stage_1[sum_i*2+1];
    end

    sum_stage_3 <= sum_stage_2[0] + sum_stage_2[1];
    result_delay[0] <= sum_stage_3;
    for (delay_i = 1; delay_i < 6; delay_i = delay_i + 1) begin
      result_delay[delay_i] <= result_delay[delay_i-1];
    end
  end
end

endmodule