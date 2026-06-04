module fp32toint_tb;

import "DPI-C" function void ToInt(
  input bit signed [31:0] in,
  output bit signed [31:0] out
);

reg signed [31:0] float32_in;

wire [31:0] int_out;
bit [31:0] int_out_ref;

bit [31:0] in_data;

integer i;

integer miss_cnt;

fp32_to_int u_dut(
  .in_data   ( in_data ),
  .out_data  ( int_out )
);

initial begin
  miss_cnt = 0;

  for (i = 'h0; i < 'h100000000; i = i + 1) begin
    float32_in = i;
    in_data = i;
    ToInt(float32_in, int_out_ref);
    #1;
    if (i % 1048576 == 0)
    // $display("int4_in = %h, float32_out = %h, float32_out_ref = %h", int4_in, float32_out, float32_out_ref);
      $display("in_data = %h, int_out = %h, int_out_ref = %h", in_data, int_out, int_out_ref);
    if (int_out !== int_out_ref) begin
      miss_cnt = miss_cnt + 1;
      $display("f_frac_ext = %h", u_dut.f_frac_ext);
      $display("f_exp_ext = %h", u_dut.f_exp_ext);
      $display("shift_result = %h", u_dut.shift_result);
      $display("in_data = %h, int_out = %h, int_out_ref = %h", in_data, int_out, int_out_ref);
      $finish;
    end
  end

  $display("miss_cnt = %d", miss_cnt);

  $finish;
end


endmodule