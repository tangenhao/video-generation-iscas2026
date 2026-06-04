module mpt_mixed (
  clk, rst_n,
  type_a, type_b,
  valid,
  a, b,
  o,
  done, clear
);

parameter PARALLELISM = 16;

input                            clk;
input                            rst_n;
input       [1:0]                type_a;
input       [1:0]                type_b;
input                            valid;
input       [PARALLELISM*16-1:0] a;
input       [PARALLELISM*16-1:0] b;
output wire [31:0]               o;
output wire                      done;
input                            clear;

wire signed [31:0] mul_result[0:PARALLELISM-1];
wire signed [35:0] add_result_0[0:PARALLELISM/2-1];
wire signed [39:0] add_result_1[0:PARALLELISM/4-1];
wire signed [43:0] add_result_2[0:PARALLELISM/8-1];
wire signed [47:0] add_result_3;
wire signed [25:0] add_result_4;
wire signed [13:0] add_result_5;

wire [15:0] mul_inf;
wire [15:0] mul_nan;
wire [15:0] mul_zero;

wire [7:0] add_inf_0;
wire [7:0] add_nan_0;
wire [7:0] add_zero_0;

wire [3:0] add_inf_1;
wire [3:0] add_nan_1;
wire [3:0] add_zero_1;

wire [1:0] add_inf_2;
wire [1:0] add_nan_2;
wire [1:0] add_zero_2;

wire add_inf_3;
wire add_nan_3;
wire add_zero_3;

reg [PARALLELISM-1:0] mul_inf_reg;
reg [PARALLELISM-1:0] mul_nan_reg;
reg [PARALLELISM-1:0] mul_zero_reg;

reg [PARALLELISM/2-1:0] add_inf_reg_0;
reg [PARALLELISM/2-1:0] add_nan_reg_0;
reg [PARALLELISM/2-1:0] add_zero_reg_0;

reg [PARALLELISM/4-1:0] add_inf_reg_1;
reg [PARALLELISM/4-1:0] add_nan_reg_1;
reg [PARALLELISM/4-1:0] add_zero_reg_1;

reg [PARALLELISM/8-1:0] add_inf_reg_2;
reg [PARALLELISM/8-1:0] add_nan_reg_2;
reg [PARALLELISM/8-1:0] add_zero_reg_2;

reg add_inf_reg_3;
reg add_nan_reg_3;
reg add_zero_reg_3;

reg signed [31:0] mul_result_reg[0:PARALLELISM-1];
reg signed [35:0] add_result_reg_0[0:PARALLELISM/2-1];
reg signed [39:0] add_result_reg_1[0:PARALLELISM/4-1];
reg signed [43:0] add_result_reg_2[0:PARALLELISM/8-1];
reg signed [47:0] add_result_reg_3;
reg signed [25:0] add_result_reg_4;

reg mul_done;
reg add_done_0;
reg add_done_1;
reg add_done_2;
reg add_done_3;
reg add_done_4;
reg add_done_5;

reg mul_done_stage_1;
reg add_done_stage_1_0;
reg add_done_stage_1_1;
reg add_done_stage_1_2;
reg add_done_stage_1_3;

reg [1:0] type_a_reg;
reg [1:0] type_b_reg;

assign done = ((type_a_reg[1] | type_b_reg[1])) ? add_done_3 : add_done_4;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    type_a_reg <= 0;
    type_b_reg <= 0;
  end
  else begin
    type_a_reg <= type_a;
    type_b_reg <= type_b;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    mul_done           <= 0;
    add_done_0         <= 0;
    add_done_1         <= 0;
    add_done_2         <= 0;
    add_done_3         <= 0;
    add_done_4         <= 0;
    add_done_5         <= 0;
    mul_done_stage_1   <= 0;
    add_done_stage_1_0 <= 0;
    add_done_stage_1_1 <= 0;
    add_done_stage_1_2 <= 0;
    add_done_stage_1_3 <= 0;
  end
  else begin
    if (clear) begin
      mul_done           <= 0;
      add_done_0         <= 0;
      add_done_1         <= 0;
      add_done_2         <= 0;
      add_done_3         <= 0;
      add_done_4         <= 0;
      add_done_5         <= 0;
      mul_done_stage_1   <= 0;
      add_done_stage_1_0 <= 0;
      add_done_stage_1_1 <= 0;
      add_done_stage_1_2 <= 0;
      add_done_stage_1_3 <= 0;
    end
    else begin
      mul_done_stage_1   <= valid;
      mul_done           <= mul_done_stage_1;
      add_done_stage_1_0 <= mul_done;
      add_done_0         <= add_done_stage_1_0;
      add_done_stage_1_1 <= add_done_0;
      add_done_1         <= add_done_stage_1_1;
      add_done_stage_1_2 <= add_done_1;
      add_done_2         <= add_done_stage_1_2;
      add_done_stage_1_3 <= add_done_2;
      add_done_3         <= add_done_stage_1_3;
      add_done_4         <= add_done_3;
      add_done_5         <= 0;
    end
  end
end

integer mul_i_reg;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (mul_i_reg = 0; mul_i_reg < PARALLELISM; mul_i_reg = mul_i_reg + 1) begin
      mul_result_reg[mul_i_reg] <= 0;
    end
    mul_inf_reg  <= 0;
    mul_nan_reg  <= 0;
    mul_zero_reg <= 0;
  end
  else begin
    for (mul_i_reg = 0; mul_i_reg < PARALLELISM; mul_i_reg = mul_i_reg + 1) begin
      mul_result_reg[mul_i_reg] <= mul_result[mul_i_reg];
    end
    mul_inf_reg <= mul_inf;
    mul_nan_reg <= mul_nan;
    mul_zero_reg <= mul_zero;
  end
end

integer add_i_reg_0;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (add_i_reg_0 = 0; add_i_reg_0 < PARALLELISM/2; add_i_reg_0 = add_i_reg_0 + 1) begin
      add_result_reg_0[add_i_reg_0] <= 0;
    end
    add_inf_reg_0 <= 0;
    add_nan_reg_0 <= 0;
    add_zero_reg_0 <= 0;
  end
  else begin
    for (add_i_reg_0 = 0; add_i_reg_0 < PARALLELISM/2; add_i_reg_0 = add_i_reg_0 + 1) begin
      add_result_reg_0[add_i_reg_0] <= add_result_0[add_i_reg_0];
    end
    add_inf_reg_0 <= add_inf_0;
    add_nan_reg_0 <= add_nan_0;
    add_zero_reg_0 <= add_zero_0;
  end
end

integer add_i_reg_1;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (add_i_reg_1 = 0; add_i_reg_1 < PARALLELISM/4; add_i_reg_1 = add_i_reg_1 + 1) begin
      add_result_reg_1[add_i_reg_1] <= 0;
    end
    add_inf_reg_1 <= 0;
    add_nan_reg_1 <= 0;
    add_zero_reg_1 <= 0;
  end
  else begin
    for (add_i_reg_1 = 0; add_i_reg_1 < PARALLELISM/4; add_i_reg_1 = add_i_reg_1 + 1) begin
      add_result_reg_1[add_i_reg_1] <= add_result_1[add_i_reg_1];
    end
    add_inf_reg_1 <= add_inf_1;
    add_nan_reg_1 <= add_nan_1;
    add_zero_reg_1 <= add_zero_1;
  end
end

integer add_i_reg_2;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (add_i_reg_2 = 0; add_i_reg_2 < PARALLELISM/8; add_i_reg_2 = add_i_reg_2 + 1) begin
      add_result_reg_2[add_i_reg_2] <= 0;
    end
    add_inf_reg_2 <= 0;
    add_nan_reg_2 <= 0;
    add_zero_reg_2 <= 0;
  end
  else begin
    for (add_i_reg_2 = 0; add_i_reg_2 < PARALLELISM/8; add_i_reg_2 = add_i_reg_2 + 1) begin
      add_result_reg_2[add_i_reg_2] <= add_result_2[add_i_reg_2];
    end
    add_inf_reg_2 <= add_inf_2;
    add_nan_reg_2 <= add_nan_2;
    add_zero_reg_2 <= add_zero_2;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    add_result_reg_3 <= 0;
  end
  else begin
    add_result_reg_3 <= add_result_3;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    add_result_reg_4 <= 0;
  end
  else begin
    add_result_reg_4 <= add_result_4;
  end
end

genvar mul_i;
generate
for (mul_i = 0; mul_i < PARALLELISM; mul_i = mul_i + 1) begin : mul_gen
  multiplier_mixed_pipeline_stage_1 u_mul(
    .clk     ( clk               ),
    .rst_n   ( rst_n             ),
    .type_a  ( type_a            ),
    .type_b  ( type_b            ),
    .a       ( a[mul_i*16+:16]   ),
    .b       ( b[mul_i*16+:16]   ),
    .o       ( mul_result[mul_i] ),
    .inf     ( mul_inf[mul_i]    ),
    .nan     ( mul_nan[mul_i]    ),
    .zero    ( mul_zero[mul_i]   )
  );
end
endgenerate

wire [1:0] add_mode;
assign add_mode = type_a_reg[1] | type_b_reg[1] ? 2'b10 :
                  type_a_reg[0] | type_b_reg[0] ? 2'b01 :
                  2'b00;
genvar add_i_0;
generate
for (add_i_0 = 0; add_i_0 < PARALLELISM/2; add_i_0 = add_i_0 + 1) begin : add_gen_0
  adder_mixed_pipe_stage_1_32 u_add_0(
    .clk     ( clk                         ),
    .rst_n   ( rst_n                       ),
    .mode    ( add_mode                    ),
    .a       ( mul_result_reg[add_i_0*2]   ),
    .b       ( mul_result_reg[add_i_0*2+1] ),
    .o       ( add_result_0[add_i_0]       ),
    .a_inf   ( mul_inf_reg[add_i_0*2]      ),
    .a_nan   ( mul_nan_reg[add_i_0*2]      ),
    .a_zero  ( mul_zero_reg[add_i_0*2]     ),
    .b_inf   ( mul_inf_reg[add_i_0*2+1]    ),
    .b_nan   ( mul_nan_reg[add_i_0*2+1]    ),
    .b_zero  ( mul_zero_reg[add_i_0*2+1]   ),
    .inf     ( add_inf_0[add_i_0]          ),
    .nan     ( add_nan_0[add_i_0]          ),
    .zero    ( add_zero_0[add_i_0]         )
  );
end
endgenerate

genvar add_i_1;
generate
for (add_i_1 = 0; add_i_1 < PARALLELISM/4; add_i_1 = add_i_1 + 1) begin : add_gen_1
  adder_mixed_pipe_stage_1_36 u_add_1(
    .clk     ( clk                           ),
    .rst_n   ( rst_n                         ),
    .mode    ( add_mode                      ),
    .a       ( add_result_reg_0[add_i_1*2]   ),
    .b       ( add_result_reg_0[add_i_1*2+1] ),
    .o       ( add_result_1[add_i_1]         ),
    .a_inf   ( add_inf_reg_0[add_i_1*2]      ),
    .a_nan   ( add_nan_reg_0[add_i_1*2]      ),
    .a_zero  ( add_zero_reg_0[add_i_1*2]     ),
    .b_inf   ( add_inf_reg_0[add_i_1*2+1]    ),
    .b_nan   ( add_nan_reg_0[add_i_1*2+1]    ),
    .b_zero  ( add_zero_reg_0[add_i_1*2+1]   ),
    .inf     ( add_inf_1[add_i_1]            ),
    .nan     ( add_nan_1[add_i_1]            ),
    .zero    ( add_zero_1[add_i_1]           )
  );
end
endgenerate

genvar add_i_2;
generate
for (add_i_2 = 0; add_i_2 < PARALLELISM/8; add_i_2 = add_i_2 + 1) begin : add_gen_2
  adder_mixed_pipe_stage_1_40 u_add_2(
    .clk     ( clk                           ),
    .rst_n   ( rst_n                         ),
    .mode    ( add_mode                      ),
    .a       ( add_result_reg_1[add_i_2*2]   ),
    .b       ( add_result_reg_1[add_i_2*2+1] ),
    .o       ( add_result_2[add_i_2]         ),
    .a_inf   ( add_inf_reg_1[add_i_2*2]      ),
    .a_nan   ( add_nan_reg_1[add_i_2*2]      ),
    .a_zero  ( add_zero_reg_1[add_i_2*2]     ),
    .b_inf   ( add_inf_reg_1[add_i_2*2+1]    ),
    .b_nan   ( add_nan_reg_1[add_i_2*2+1]    ),
    .b_zero  ( add_zero_reg_1[add_i_2*2+1]   ),
    .inf     ( add_inf_2[add_i_2]            ),
    .nan     ( add_nan_2[add_i_2]            ),
    .zero    ( add_zero_2[add_i_2]           )
  );
end
endgenerate

adder_mixed_pipe_stage_1_44 u_add_3(
  .clk     ( clk                 ),
  .rst_n   ( rst_n               ),
  .mode    ( add_mode            ),
  .a       ( add_result_reg_2[0] ),
  .b       ( add_result_reg_2[1] ),
  .o       ( add_result_3        ),
  .a_inf   ( add_inf_reg_2[0]    ),
  .a_nan   ( add_nan_reg_2[0]    ),
  .a_zero  ( add_zero_reg_2[0]   ),
  .b_inf   ( add_inf_reg_2[1]    ),
  .b_nan   ( add_nan_reg_2[1]    ),
  .b_zero  ( add_zero_reg_2[1]   ),
  .inf     ( add_inf_3           ),
  .nan     ( add_nan_3           ),
  .zero    ( add_zero_3          )
);

wire [12:0] add_4_0_a;
wire [12:0] add_4_0_b;
wire        add_4_0_c_o;
wire [12:0] add_4_1_a;
wire [12:0] add_4_1_b;

assign add_4_0_a = (type_a_reg[0] | type_b_reg[0]) ? add_result_reg_3[12:0] : {add_result_reg_3[11], add_result_reg_3[11:0]};
assign add_4_1_a = (type_a_reg[0] | type_b_reg[0]) ? {{2{add_result_reg_3[23]}}, add_result_reg_3[23:13]} : {add_result_reg_3[23], add_result_reg_3[23:12]};
assign add_4_0_b = (type_a_reg[0] | type_b_reg[0]) ? add_result_reg_3[36:24] : {add_result_reg_3[35], add_result_reg_3[35:24]};
assign add_4_1_b = (type_a_reg[0] | type_b_reg[0]) ? {{2{add_result_reg_3[47]}}, add_result_reg_3[47:37]} : {add_result_reg_3[47], add_result_reg_3[47:36]};

wire [13:0] add_result_4_0;

assign add_result_4_0 = add_4_0_a + add_4_0_b;
assign add_4_0_c_o = add_result_4_0[13] & (type_a_reg[0] | type_b_reg[0]);
assign add_result_4[12:0] = add_result_4_0[12:0];
assign add_result_4[25:13] = add_4_1_a + add_4_1_b + add_4_0_c_o;

adder_14bit u_add_4(
  .a   ( {add_result_reg_4[12], add_result_reg_4[12:0]}  ),
  .b   ( {add_result_reg_4[25], add_result_reg_4[25:13]} ),
  .c_i ( 1'b0                                            ),
  .c_o (                                                 ),
  .o   ( add_result_5                                    )
);

wire [31:0] float_result;
assign float_result = {add_result_3[29], add_result_3[28:21], add_result_3[19:0], 3'b0};
assign o = add_mode[1] ? float_result : 
           (type_a_reg[0] | type_b_reg[0]) ? {{6{add_result_reg_4[25]}}, add_result_reg_4} : {{18{add_result_5[13]}}, add_result_5[13:0]};

endmodule
