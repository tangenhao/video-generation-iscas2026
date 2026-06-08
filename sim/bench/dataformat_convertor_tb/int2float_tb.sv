module int2float_tb;

import "DPI-C" function void int4tofloat(
  input bit signed [31:0] in,
  output bit signed [31:0] out
);

reg signed [3:0] int4_in;
reg signed [7:0] int8_in;
reg signed [15:0] int16_in;
reg signed [31:0] int32_in;

wire [31:0] float32_out;
bit [31:0] float32_out_ref;

bit [1:0] dtype_sel;
bit [31:0] in_data;

integer i;

integer int4_miss_cnt;
integer int8_miss_cnt;
integer int16_miss_cnt;
integer int32_miss_cnt;

initial begin
  int4_miss_cnt = 0;
  int8_miss_cnt = 0;
  int16_miss_cnt = 0;
  int32_miss_cnt = 0;

  dtype_sel = 0;
  for (i = -8; i <= 7; i = i + 1) begin
    int4_in = i;
    in_data = i;
    int4tofloat(int4_in, float32_out_ref);
    #10;
    // $display("int4_in = %h, float32_out = %h, float32_out_ref = %h", int4_in, float32_out, float32_out_ref);
    if (float32_out !== float32_out_ref) begin
      int4_miss_cnt = int4_miss_cnt + 1;
    end
  end

  $display("int4_miss_cnt = %d", int4_miss_cnt);

  dtype_sel = 1;
  for (i = -128; i <= 127; i = i + 1) begin
    int8_in = i;
    in_data = i;
    int4tofloat(int8_in, float32_out_ref);
    #10;
      // $display("int8_in = %h, float32_out = %h, float32_out_ref = %h", int8_in, float32_out, float32_out_ref);
    if (float32_out !== float32_out_ref) begin
      int8_miss_cnt = int8_miss_cnt + 1;
    end
  end

  $display("int8_miss_cnt = %d", int8_miss_cnt);

  dtype_sel = 2;
  for (i = -32768; i <= 32767; i = i + 1) begin
    int16_in = i;
    in_data = i;
    int4tofloat(int16_in, float32_out_ref);
    #10;
    // $display("int16_in = %h, float32_out = %h, float32_out_ref = %h", int16_in, float32_out, float32_out_ref);
    if (float32_out !== float32_out_ref) begin
      int16_miss_cnt = int16_miss_cnt + 1;
    end
  end

  $display("int16_miss_cnt = %d", int16_miss_cnt);

  dtype_sel = 3;
  for (i = -2147483648; i <= 2147483647; i = i + 1) begin
    int32_in = i;
    in_data = i;
    int4tofloat(int32_in, float32_out_ref);
    #1;
    if (i % 1000000 == 0) begin
      $display("int32_in = %d, float32_out = %h, float32_out_ref = %h", int32_in, float32_out, float32_out_ref);
    end
    // $display("int32_in = %h, float32_out = %h, float32_out_ref = %h", int32_in, float32_out, float32_out_ref);
    if (float32_out !== float32_out_ref) begin
      int32_miss_cnt = int32_miss_cnt + 1;
    end
  end

  $display("int32_miss_cnt = %d", int32_miss_cnt);

  $finish;
end

int2fp32 u_dut(
  .in_data   ( in_data     ),
  .dtype_sel ( dtype_sel   ),
  .out_data  ( float32_out )
);

endmodule