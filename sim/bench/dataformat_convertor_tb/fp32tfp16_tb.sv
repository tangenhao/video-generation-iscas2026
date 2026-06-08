module fp32tfp16_tb;

import "DPI-C" function void FromFloatBits(
  input bit signed [31:0] in,
  output bit signed [15:0] out,
  input bit [15:0] debug
);

reg signed [31:0] float32_in;

wire [15:0] float16_out;
bit [15:0] float16_out_ref;

bit [31:0] in_data;

reg [32:0] i;

integer miss_cnt;

fp32_to_half u_dut(
  .in_data   ( in_data     ),
  .out_data  ( float16_out )
);

initial begin
  miss_cnt = 0;

  for (i = 'h00000000; i <= 'hffffffff; i = i + 1) begin
    float32_in = i;
    in_data = i;
    FromFloatBits(float32_in, float16_out_ref, 0);
    #10;
    // $display("int4_in = %h, float32_out = %h, float32_out_ref = %h", int4_in, float32_out, float32_out_ref);
    if (i % 1048576 == 0)
      $display("in_data = %h, float16_out = %h, float16_out_ref = %h", in_data, float16_out, float16_out_ref);
    if (float16_out !== float16_out_ref && (!u_dut.nan)) begin
      miss_cnt = miss_cnt + 1;
      $display("in_data = %h, float16_out = %h, float16_out_ref = %h", in_data, float16_out, float16_out_ref);
      $display("unnorm: %h", u_dut.unnorm);
      $display("unnorm_shift: %h", u_dut.unnorm_shift);
      $display("unnorm_frac: %h", u_dut.unnorm_frac);
      $display("bits_before_round: %h", u_dut.bits_before_round);
      $display("carry: %h", u_dut.carry);
      $display("bits_rounded: %h", u_dut.bits_rounded);
      $display("golden:");
      FromFloatBits(float32_in, float16_out_ref, 1);
      $finish;
    end
  end

  $display("miss_cnt = %d", miss_cnt);

  $finish;
end


endmodule