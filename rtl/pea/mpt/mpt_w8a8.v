module mpt_w8a8(
  clk, rst_n,
  a, b, c,
  o,
  valid, valid_c, done
);

input              clk;
input              rst_n;
input      [255:0] a;
input      [255:0] b;
input      [31:0]  c;
output     [31:0]  o;
input              valid;
input              valid_c;
output             done;

reg mul_done;
reg add_done_0;
reg add_done_1;
reg add_done_2;
reg add_done_3;
reg add_done_4;
reg add_done_4_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    mul_done <= 0;
    add_done_0 <= 0;
    add_done_1 <= 0;
    add_done_2 <= 0;
    add_done_3 <= 0;
    add_done_4 <= 0;
    add_done_4_reg <= 0;
  end
  else begin
    mul_done <= valid;
    add_done_0 <= mul_done;
    add_done_1 <= add_done_0;
    add_done_2 <= add_done_1;
    add_done_3 <= add_done_2;
    add_done_4 <= add_done_3;
    add_done_4_reg <= add_done_4;
  end
end

wire signed [7:0]  mul_a[31:0];
wire signed [7:0]  mul_b[31:0];
wire signed [15:0] mul_result[31:0];

reg signed [15:0] mul_result_reg[31:0];

genvar mul_i;
generate
  for (mul_i = 0; mul_i < 32; mul_i = mul_i + 1) begin : mul_gen
    assign mul_a[mul_i] = a[8*mul_i +: 8];
    assign mul_b[mul_i] = b[8*mul_i +: 8];
    assign mul_result[mul_i] = mul_a[mul_i] * mul_b[mul_i];
  
    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        mul_result_reg[mul_i] <= 0;
      end 
      else begin
        mul_result_reg[mul_i] <= mul_result[mul_i];
      end
    end
  end
endgenerate

wire signed [16:0] add_result_0[15:0];
reg signed  [16:0] add_result_0_reg[15:0];

genvar add_0_i;
generate
  for (add_0_i = 0; add_0_i < 16; add_0_i = add_0_i + 1) begin : add_gen_0
    assign add_result_0[add_0_i] = mul_result_reg[2*add_0_i] + mul_result_reg[2*add_0_i + 1];
  
    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        add_result_0_reg[add_0_i] <= 0;
      end 
      else begin
        add_result_0_reg[add_0_i] <= add_result_0[add_0_i];
      end
    end
  end
endgenerate

wire signed [17:0] add_result_1[7:0];
reg signed  [17:0] add_result_1_reg[7:0];

genvar add_1_i;
generate
  for (add_1_i = 0; add_1_i < 8; add_1_i = add_1_i + 1) begin : add_gen_1
    assign add_result_1[add_1_i] = add_result_0_reg[2*add_1_i] + add_result_0_reg[2*add_1_i + 1];
  
    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        add_result_1_reg[add_1_i] <= 0;
      end 
      else begin
        add_result_1_reg[add_1_i] <= add_result_1[add_1_i];
      end
    end
  end
endgenerate

wire signed [18:0] add_result_2[3:0];
reg signed  [18:0] add_result_2_reg[3:0];

genvar add_2_i;
generate
  for (add_2_i = 0; add_2_i < 4; add_2_i = add_2_i + 1) begin : add_gen_2
    assign add_result_2[add_2_i] = add_result_1_reg[2*add_2_i] + add_result_1_reg[2*add_2_i + 1];
  
    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        add_result_2_reg[add_2_i] <= 0;
      end 
      else begin
        add_result_2_reg[add_2_i] <= add_result_2[add_2_i];
      end
    end
  end
endgenerate

wire signed [19:0] add_result_3[1:0];
reg signed  [19:0] add_result_3_reg[1:0];

genvar add_3_i;
generate
  for (add_3_i = 0; add_3_i < 2; add_3_i = add_3_i + 1) begin : add_gen_3
    assign add_result_3[add_3_i] = add_result_2_reg[2*add_3_i] + add_result_2_reg[2*add_3_i + 1];
  
    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        add_result_3_reg[add_3_i] <= 0;
      end 
      else begin
        add_result_3_reg[add_3_i] <= add_result_3[add_3_i];
      end
    end
  end
endgenerate

wire signed [20:0] add_result_4;
reg signed  [20:0] add_result_4_reg;

assign add_result_4 = add_result_3_reg[0] + add_result_3_reg[1];

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    add_result_4_reg <= 0;
  end
  else begin
    add_result_4_reg <= add_result_4;
  end
end

reg signed [31:0] add_result_5;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    add_result_5 <= 'd0;
  end
  else if (valid_c) begin
    add_result_5 <= c;
  end
  else if (add_done_4) begin
    add_result_5 <= add_result_4_reg + add_result_5;
  end
  else begin
    add_result_5 <= add_result_5;
  end
end

assign o    = add_result_5;
assign done = ~add_done_4 & add_done_4_reg;

endmodule