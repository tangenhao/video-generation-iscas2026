#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $file = "";
my $help = "";
my $p = 32;

GetOptions(
    "file=s" => \$file,
    "p:s" => \$p,
    "help" => \$help
) or die "Error in command line arguments\n";

if ($help) {
    print "Usage: $0 --file <file> [--p <p>]\n";
    print "Options:\n";
    print "  --file <file>  Output file\n";
    print "  --p <p>        Parallelism\n";
    exit;
}

print "==== INFO: Generating mpt_mixed ==== \n";
print "p: ", $p, "\n";

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $data_width = $p * 16;

my $code = <<"EOF";
module mpt_mixed (
  clk,
  rst_n,
  type_a,
  type_b,
  valid,
  halt,
  a,
  b,
  o,
  done
);

input wire clk;
input wire rst_n;
input wire [2:0] type_a;
input wire [2:0] type_b;
input wire valid;
input wire halt;
EOF
print $fh $code;

print $fh "input wire [", $data_width-1, ":0] a;\n";
print $fh "input wire [", $data_width-1, ":0] b;\n";
print $fh "output wire [31:0] o;\n";
print $fh "output wire done;\n";
print $fh "\n";

print $fh "wire signed [31:0] mul_result[0:" . ($p-1) . "];\n";
my $number_of_float_layers = log($p)/log(2);
for (my $i = 0; $i < $number_of_float_layers-1; $i++) {
  print $fh "wire signed [" . (31 + 4 * ($i+1)) . ":0] add_result_" . $i . "[0:" . (($p / (2 ** ($i + 1))) - 1) . "];\n";
}
print $fh "wire signed [" . (31 + 4 * $number_of_float_layers) . ":0] add_result_" . ($number_of_float_layers-1) . ";\n";
print $fh "wire signed [" . ((((32 + 4 * $number_of_float_layers) / 4) + 1) * 2 - 1) . ":0] add_result_" . $number_of_float_layers . ";\n";
print $fh "wire signed [" . ((((32 + 4 * $number_of_float_layers) / 4) + 1)) . ":0] add_result_" . ($number_of_float_layers+1) . ";\n";
print $fh "\n";
print $fh "wire [" . ($p-1) . ":0] mul_inf;\n";
print $fh "wire [" . ($p-1) . ":0] mul_nan;\n";
print $fh "wire [" . ($p-1) . ":0] mul_zero;\n";
print $fh "\n";
for (my $i = 0; $i < $number_of_float_layers-1; $i++) {
  print $fh "wire [" . (($p / (2 ** ($i + 1))) - 1) . ":0] add_inf_" . $i . ";\n";
  print $fh "wire [" . (($p / (2 ** ($i + 1))) - 1) . ":0] add_nan_" . $i . ";\n";
  print $fh "wire [" . (($p / (2 ** ($i + 1))) - 1) . ":0] add_zero_" . $i . ";\n";
  print $fh "\n";
}
print $fh "wire add_inf_" . ($number_of_float_layers - 1) . ";\n";
print $fh "wire add_nan_" . ($number_of_float_layers - 1) . ";\n";
print $fh "wire add_zero_" . ($number_of_float_layers - 1) . ";\n";
print $fh "\n";
print $fh "reg [" . ($p-1) . ":0] mul_inf_reg;\n";
print $fh "reg [" . ($p-1) . ":0] mul_nan_reg;\n";
print $fh "reg [" . ($p-1) . ":0] mul_zero_reg;\n";
print $fh "\n";
for (my $i = 0; $i < $number_of_float_layers-1; $i++) {
  print $fh "reg [" . (($p / (2 ** ($i + 1))) - 1) . ":0] add_inf_reg_" . $i . ";\n";
  print $fh "reg [" . (($p / (2 ** ($i + 1))) - 1) . ":0] add_nan_reg_" . $i . ";\n";
  print $fh "reg [" . (($p / (2 ** ($i + 1))) - 1) . ":0] add_zero_reg_" . $i . ";\n";
  print $fh "\n";
}
print $fh "reg add_inf_reg_" . ($number_of_float_layers - 1) . ";\n";
print $fh "reg add_nan_reg_" . ($number_of_float_layers - 1) . ";\n";
print $fh "reg add_zero_reg_" . ($number_of_float_layers - 1) . ";\n";
print $fh "\n";
print $fh "reg signed [31:0] mul_result_reg[0:" . ($p-1) . "];\n";
for (my $i = 0; $i < $number_of_float_layers-1; $i++) {
  print $fh "reg signed [" . (31 + 4 * ($i+1)) . ":0] add_result_reg_" . $i . "[0:" . (($p / (2 ** ($i + 1))) - 1) . "];\n";
}
print $fh "reg signed [" . (31 + 4 * $number_of_float_layers) . ":0] add_result_reg_" . ($number_of_float_layers-1) . ";\n";
print $fh "reg signed [" . ((((32 + 4 * $number_of_float_layers) / 4) + 1) * 2 - 1) . ":0] add_result_reg_" . $number_of_float_layers . ";\n";
print $fh "reg signed [" . ((((32 + 4 * $number_of_float_layers) / 4) + 1) * 2 - 1) . ":0] add_result_reg_" . $number_of_float_layers . "_delay;\n";
print $fh "reg signed [" . ((((32 + 4 * $number_of_float_layers) / 4) + 1)) . ":0] add_result_reg_" . ($number_of_float_layers+1) . ";\n";
print $fh "\n";
print $fh "reg mul_done;\n";
for (my $i = 0; $i < $number_of_float_layers-1; $i++) {
  print $fh "reg add_done_" . $i . ";\n";
}
print $fh "reg add_done_" . ($number_of_float_layers-1) . ";\n";
print $fh "reg add_done_" . $number_of_float_layers . ";\n";
print $fh "reg add_done_" . ($number_of_float_layers+1) . ";\n";
print $fh "\n";
print $fh "reg mul_done_stage_1;\n";
for (my $i = 0; $i < $number_of_float_layers; $i++) {
  print $fh "reg add_done_stage_1_" . $i . ";\n";
}
print $fh "\n";
print $fh "assign done = (type_a[2] | type_b[2] | (type_a[1] & type_b[1])) ? add_done_" . ($number_of_float_layers-1) . " : add_done_" . ($number_of_float_layers+1) . ";\n";
print $fh "\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    mul_done <= 0;\n";
for (my $i = 0; $i < $number_of_float_layers+1; $i++) {
  print $fh "    add_done_" . $i . " <= 0;\n";
}
print $fh "    mul_done_stage_1 <= 0;\n";
for (my $i = 0; $i < $number_of_float_layers; $i++) {
  print $fh "    add_done_stage_1_" . $i . " <= 0;\n";
}
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (valid) begin\n";
print $fh "      if (halt) begin\n";
print $fh "        mul_done <= 'd0;\n";
for (my $i = 0; $i < $number_of_float_layers+1; $i++) {
  print $fh "        add_done_" . $i . " <= 'd0;\n";
}
print $fh "        mul_done_stage_1 <= 'd0;\n";
for (my $i = 0; $i < $number_of_float_layers; $i++) {
  print $fh "        add_done_stage_1_" . $i . " <= 'd0;\n";
}
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        if (type_a[2] | type_b[2]) begin\n";
print $fh "          mul_done_stage_1 <= valid;\n";
print $fh "          mul_done <= mul_done_stage_1;\n";
print $fh "          add_done_stage_1_0 <= mul_done;\n";
print $fh "          add_done_0 <= add_done_stage_1_0;\n";
for (my $i = 1; $i < $number_of_float_layers; $i++) {
  print $fh "          add_done_stage_1_" . $i . " <= add_done_stage_1_" . ($i-1) . ";\n";
  print $fh "          add_done_" . $i . " <= add_done_stage_1_" . $i . ";\n";
}
for (my $i = $number_of_float_layers; $i < $number_of_float_layers+2; $i++) {
  print $fh "          add_done_" . $i . " <= 0;\n";
}
print $fh "        end\n";
print $fh "        else begin\n";
print $fh "          mul_done <= valid;\n";
print $fh "          add_done_0 <= mul_done;\n";
for (my $i = 1; $i < $number_of_float_layers+2; $i++) {
  print $fh "          add_done_" . $i . " <= add_done_" . ($i-1) . ";\n";
}
print $fh "          mul_done_stage_1 <= 0;\n";
for (my $i = 0; $i < $number_of_float_layers; $i++) {
  print $fh "          add_done_stage_1_" . $i . " <= 0;\n";
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      mul_done <= 0;\n";
for (my $i = 0; $i < $number_of_float_layers+1; $i++) {
  print $fh "      add_done_" . $i . " <= 0;\n";
}
print $fh "      mul_done_stage_1 <= 0;\n";
for (my $i = 0; $i < $number_of_float_layers; $i++) {
  print $fh "      add_done_stage_1_" . $i . " <= 0;\n";
}
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "integer mul_i_reg;\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    for (mul_i_reg = 0; mul_i_reg < " . $p . "; mul_i_reg = mul_i_reg + 1) begin\n";
print $fh "      mul_result_reg[mul_i_reg] <= 0;\n";
print $fh "    end\n";
print $fh "    mul_inf_reg <= 0;\n";
print $fh "    mul_nan_reg <= 0;\n";
print $fh "    mul_zero_reg <= 0;\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (valid) begin\n";
print $fh "      if (halt) begin\n";
print $fh "        for (mul_i_reg = 0; mul_i_reg < " . $p . "; mul_i_reg = mul_i_reg + 1) begin\n";
print $fh "          mul_result_reg[mul_i_reg] <= mul_result_reg[mul_i_reg];\n";
print $fh "        end\n";
print $fh "        mul_inf_reg <= mul_inf_reg;\n";
print $fh "        mul_nan_reg <= mul_nan_reg;\n";
print $fh "        mul_zero_reg <= mul_zero_reg;\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        for (mul_i_reg = 0; mul_i_reg < " . $p . "; mul_i_reg = mul_i_reg + 1) begin\n";
print $fh "          mul_result_reg[mul_i_reg] <= mul_result[mul_i_reg];\n";
print $fh "        end\n";
print $fh "        mul_inf_reg <= mul_inf;\n";
print $fh "        mul_nan_reg <= mul_nan;\n";
print $fh "        mul_zero_reg <= mul_zero;\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      for (mul_i_reg = 0; mul_i_reg < " . $p . "; mul_i_reg = mul_i_reg + 1) begin\n";
print $fh "        mul_result_reg[mul_i_reg] <= 0;\n";
print $fh "      end\n";
print $fh "      mul_inf_reg <= 0;\n";
print $fh "      mul_nan_reg <= 0;\n";
print $fh "      mul_zero_reg <= 0;\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
for (my $i = 0; $i < $number_of_float_layers-1; $i++) {
  print $fh "integer add_i_reg_" . $i . ";\n";
  print $fh "always @(posedge clk or negedge rst_n) begin\n";
  print $fh "  if (!rst_n) begin\n";
  print $fh "    for (add_i_reg_" . $i . " = 0; add_i_reg_" . $i . " < " . ($p / (2 ** ($i + 1)) ) . "; add_i_reg_" . $i . " = add_i_reg_" . $i . " + 1) begin\n";
  print $fh "      add_result_reg_" . $i . "[add_i_reg_" . $i . "] <= 0;\n";
  print $fh "    end\n";
  print $fh "    add_inf_reg_" . $i . " <= 0;\n";
  print $fh "    add_nan_reg_" . $i . " <= 0;\n";
  print $fh "    add_zero_reg_" . $i . " <= 0;\n";
  print $fh "  end\n";
  print $fh "  else begin\n";
  print $fh "    if (valid) begin\n";
  print $fh "      if (halt) begin\n";
  print $fh "        for (add_i_reg_" . $i . " = 0; add_i_reg_" . $i . " < " . ($p / (2 ** ($i + 1)) ) . "; add_i_reg_" . $i . " = add_i_reg_" . $i . " + 1) begin\n";
  print $fh "          add_result_reg_" . $i . "[add_i_reg_" . $i . "] <= add_result_reg_" . $i . "[add_i_reg_" . $i . "];\n";
  print $fh "        end\n";
  print $fh "        add_inf_reg_" . $i . " <= add_inf_reg_" . $i . ";\n";
  print $fh "        add_nan_reg_" . $i . " <= add_nan_reg_" . $i . ";\n";
  print $fh "        add_zero_reg_" . $i . " <= add_zero_reg_" . $i . ";\n";
  print $fh "      end\n";
  print $fh "      else begin\n";
  print $fh "        for (add_i_reg_" . $i . " = 0; add_i_reg_" . $i . " < " . ($p / (2 ** ($i + 1)) ) . "; add_i_reg_" . $i . " = add_i_reg_" . $i . " + 1) begin\n";
  print $fh "          add_result_reg_" . $i . "[add_i_reg_" . $i . "] <= add_result_" . $i . "[add_i_reg_" . $i . "];\n";
  print $fh "        end\n";
  print $fh "        add_inf_reg_" . $i . " <= add_inf_" . $i . ";\n";
  print $fh "        add_nan_reg_" . $i . " <= add_nan_" . $i . ";\n";
  print $fh "        add_zero_reg_" . $i . " <= add_zero_" . $i . ";\n";
  print $fh "      end\n";
  print $fh "    end\n";
  print $fh "    else begin\n";
  print $fh "      for (add_i_reg_" . $i . " = 0; add_i_reg_" . $i . " < " . ($p / (2 ** ($i + 1)) ) . "; add_i_reg_" . $i . " = add_i_reg_" . $i . " + 1) begin\n";
  print $fh "        add_result_reg_" . $i . "[add_i_reg_" . $i . "] <= 0;\n";
  print $fh "      end\n";
  print $fh "      add_inf_reg_" . $i . " <= 0;\n";
  print $fh "      add_nan_reg_" . $i . " <= 0;\n";
  print $fh "      add_zero_reg_" . $i . " <= 0;\n";
  print $fh "    end\n";
  print $fh "  end\n";
  print $fh "end\n";
  print $fh "\n";
}
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    add_result_reg_" . ($number_of_float_layers-1) . " <= 0;\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (valid) begin\n";
print $fh "      if (halt) begin\n";
print $fh "        add_result_reg_" . ($number_of_float_layers-1) . " <= add_result_reg_" . ($number_of_float_layers-1) . ";\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        add_result_reg_" . ($number_of_float_layers-1) . " <= add_result_" . ($number_of_float_layers-1) . ";\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      add_result_reg_" . ($number_of_float_layers-1) . " <= 0;\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    add_result_reg_" . ($number_of_float_layers) . " <= 0;\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (valid) begin\n";
print $fh "      if (halt) begin\n";
print $fh "        add_result_reg_" . ($number_of_float_layers) . " <= add_result_reg_" . ($number_of_float_layers) . ";\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        add_result_reg_" . ($number_of_float_layers) . " <= add_result_" . ($number_of_float_layers) . ";\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      add_result_reg_" . ($number_of_float_layers) . " <= 0;\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    add_result_reg_" . ($number_of_float_layers) . "_delay <= 0;\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    add_result_reg_" . ($number_of_float_layers) . "_delay <= add_result_reg_" . ($number_of_float_layers) . ";\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    add_result_reg_" . ($number_of_float_layers+1) . " <= 0;\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (valid) begin\n";
print $fh "      if (halt) begin\n";
print $fh "        add_result_reg_" . ($number_of_float_layers+1) . " <= add_result_reg_" . ($number_of_float_layers+1) . ";\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        add_result_reg_" . ($number_of_float_layers+1) . " <= add_result_" . ($number_of_float_layers+1) . ";\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      add_result_reg_" . ($number_of_float_layers+1) . " <= 0;\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "genvar mul_i;\n";
print $fh "generate\n";
print $fh "for (mul_i = 0; mul_i < " . $p . "; mul_i = mul_i + 1) begin : mul_gen\n";
print $fh "  multiplier_mixed_pipeline_stage_1 u_mul(\n";
print $fh "    .clk(clk),\n";
print $fh "    .rst_n(rst_n),\n";
print $fh "    .type_a(type_a),\n";
print $fh "    .type_b(type_b),\n";
print $fh "    .a(a[mul_i*16+:16]),\n";
print $fh "    .b(b[mul_i*16+:16]),\n";
print $fh "    .o(mul_result[mul_i]),\n";
print $fh "    .inf(mul_inf[mul_i]),\n";
print $fh "    .nan(mul_nan[mul_i]),\n";
print $fh "    .zero(mul_zero[mul_i])\n";
print $fh "  );\n";
print $fh "end\n";
print $fh "endgenerate\n";
print $fh "\n";
print $fh "wire [1:0] add_mode;\n";
print $fh "assign add_mode = type_a[2] & type_b[2] ? 2'b11 :\n";
print $fh "                  type_a[1] | type_b[1] ? 2'b10 :\n";
print $fh "                  type_a[0] | type_b[0] ? 2'b01 :\n";
print $fh "                  2'b00;\n";
for (my $i = 0; $i < $number_of_float_layers-1; $i++) {
  print $fh "genvar add_i_" . $i . ";\n";
  print $fh "generate\n";
  print $fh "for (add_i_" . $i . " = 0; add_i_" . $i . " < " . ($p / (2 ** ($i + 1)) ) . "; add_i_" . $i . " = add_i_" . $i . " + 1) begin : add_gen_" . $i . "\n";
  print $fh "  adder_mixed_pipe_stage_1" . "_" . (32 + $i*4) . " u_add_" . $i . "(\n";
  print $fh "    .clk(clk),\n";
  print $fh "    .rst_n(rst_n),\n";
  print $fh "    .mode(add_mode),\n";
  if ($i == 0) {
    print $fh "    .a(mul_result[add_i_" . $i . "*2]),\n";
    print $fh "    .b(mul_result[add_i_" . $i . "*2+1]),\n";
  }
  else {
    print $fh "    .a(add_result_reg_" . ($i-1) . "[add_i_" . $i . "*2]),\n";
    print $fh "    .b(add_result_reg_" . ($i-1) . "[add_i_" . $i . "*2+1]),\n";
  }
  print $fh "    .o(add_result_" . $i . "[add_i_" . $i . "]),\n";
  if ($i == 0) {
    print $fh "    .a_inf(mul_inf_reg[add_i_" . $i . "*2]),\n";
    print $fh "    .a_nan(mul_nan_reg[add_i_" . $i . "*2]),\n";
    print $fh "    .a_zero(mul_zero_reg[add_i_" . $i . "*2]),\n";
    print $fh "    .b_inf(mul_inf_reg[add_i_" . $i . "*2+1]),\n";
    print $fh "    .b_nan(mul_nan_reg[add_i_" . $i . "*2+1]),\n";
    print $fh "    .b_zero(mul_zero_reg[add_i_" . $i . "*2+1]),\n";
  }
  else {
    print $fh "    .a_inf(add_inf_reg_" . ($i-1) . "[add_i_" . $i . "*2]),\n";
    print $fh "    .a_nan(add_nan_reg_" . ($i-1) . "[add_i_" . $i . "*2]),\n";
    print $fh "    .a_zero(add_zero_reg_" . ($i-1) . "[add_i_" . $i . "*2]),\n";
    print $fh "    .b_inf(add_inf_reg_" . ($i-1) . "[add_i_" . $i . "*2+1]),\n";
    print $fh "    .b_nan(add_nan_reg_" . ($i-1) . "[add_i_" . $i . "*2+1]),\n";
    print $fh "    .b_zero(add_zero_reg_" . ($i-1) . "[add_i_" . $i . "*2+1]),\n";
  }
  print $fh "    .inf(add_inf_" . $i . "[add_i_" . $i . "]),\n";
  print $fh "    .nan(add_nan_" . $i . "[add_i_" . $i . "]),\n";
  print $fh "    .zero(add_zero_" . $i . "[add_i_" . $i . "])\n";
  print $fh "  );\n";
  print $fh "end\n";
  print $fh "endgenerate\n";
  print $fh "\n";
}
print $fh "adder_mixed_pipe_stage_1" . "_" . (32 + ($number_of_float_layers-1)*4) . " u_add_" . ($number_of_float_layers-1) . "(\n";
print $fh "  .clk(clk),\n";
print $fh "  .rst_n(rst_n),\n";
print $fh "  .mode(add_mode),\n";
print $fh "  .a(add_result_reg_" . ($number_of_float_layers-2) . "[0]),\n";
print $fh "  .b(add_result_reg_" . ($number_of_float_layers-2) . "[1]),\n";
print $fh "  .o(add_result_" . ($number_of_float_layers-1) . "),\n";
print $fh "  .a_inf(add_inf_reg_" . ($number_of_float_layers-2) . "[0]),\n";
print $fh "  .a_nan(add_nan_reg_" . ($number_of_float_layers-2) . "[0]),\n";
print $fh "  .a_zero(add_zero_reg_" . ($number_of_float_layers-2) . "[0]),\n";
print $fh "  .b_inf(add_inf_reg_" . ($number_of_float_layers-2) . "[1]),\n";
print $fh "  .b_nan(add_nan_reg_" . ($number_of_float_layers-2) . "[1]),\n";
print $fh "  .b_zero(add_zero_reg_" . ($number_of_float_layers-2) . "[1]),\n";
print $fh "  .inf(add_inf_" . ($number_of_float_layers-1) . "),\n";
print $fh "  .nan(add_nan_" . ($number_of_float_layers-1) . "),\n";
print $fh "  .zero(add_zero_" . ($number_of_float_layers-1) . ")\n";
print $fh ");\n";
print $fh "\n";
print $fh "wire signed [" . (((32 + 4 * $number_of_float_layers) / 4)) . ":0] add_" . $number_of_float_layers . "_0_a;\n";
print $fh "wire signed [" . (((32 + 4 * $number_of_float_layers) / 4)) . ":0] add_" . $number_of_float_layers . "_0_b;\n";
print $fh "wire add_" . $number_of_float_layers . "_0_c_o;\n";
print $fh "wire signed [" . (((32 + 4 * $number_of_float_layers) / 4)) . ":0] add_" . $number_of_float_layers . "_1_a;\n";
print $fh "wire signed [" . (((32 + 4 * $number_of_float_layers) / 4)) . ":0] add_" . $number_of_float_layers . "_1_b;\n";
print $fh "\n";
print $fh "assign add_" . $number_of_float_layers . "_0_a = (type_a[0] | type_b[0]) ? {1'b0, add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4-1) . ":0]} : {add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4-1) . "], add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4-1) . ":0]};\n";
print $fh "assign add_" . $number_of_float_layers . "_1_a = (type_a[0] | type_b[0]) ? {1'b0, add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4*2-1) . ":" . ((32+4*$number_of_float_layers)/4) . "]} : {add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4*2-1) . "], add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4*2-1) . ":" . ((32+4*$number_of_float_layers)/4) ."]};\n";
print $fh "assign add_" . $number_of_float_layers . "_0_b = (type_a[0] | type_b[0]) ? {1'b0, add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4*3-1) . ":" . ((32+4*$number_of_float_layers)/4*2) . "]} : {add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4*3-1) . "], add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)/4*3-1) . ":" . ((32+4*$number_of_float_layers)/4*2) ."]};\n";
print $fh "assign add_" . $number_of_float_layers . "_1_b = (type_a[0] | type_b[0]) ? {1'b0, add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)-1) . ":" . ((32+4*$number_of_float_layers)/4*3) . "]} : {add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)-1) . "], add_result_reg_" . ($number_of_float_layers-1) . "[" . ((32+4*$number_of_float_layers)-1) . ":" . ((32+4*$number_of_float_layers)/4*3) ."]};\n";
print $fh "\n";
print $fh "adder_" . (((32 + 4 * $number_of_float_layers) / 4) + 1) . "bit u_add_" . $number_of_float_layers . "_0(\n";
print $fh "  .a(add_" . $number_of_float_layers . "_0_a),\n";
print $fh "  .b(add_" . $number_of_float_layers . "_0_b),\n";
print $fh "  .c_i(1'b0),\n";
print $fh "  .c_o(add_" . $number_of_float_layers . "_0_c_o),\n";
print $fh "  .o(add_result_" . $number_of_float_layers . "[" . ((32+4*$number_of_float_layers)/4) . ":0])\n";
print $fh ");\n";
print $fh "\n";
print $fh "adder_" . (((32 + 4 * $number_of_float_layers) / 4) + 1) . "bit u_add_" . $number_of_float_layers . "_1(\n";
print $fh "  .a(add_" . $number_of_float_layers . "_1_a),\n";
print $fh "  .b(add_" . $number_of_float_layers . "_1_b),\n";
print $fh "  .c_i(add_" . $number_of_float_layers . "_0_c_o),\n";
print $fh "  .c_o(),\n";
print $fh "  .o(add_result_" . $number_of_float_layers . "[" . ((32+4*$number_of_float_layers)/4*2+1) . ":" . ((32+4*$number_of_float_layers)/4+1) . "])\n";
print $fh ");\n";
print $fh "\n";
# print $fh "assign add_result_" . $number_of_float_layers . "[" . (((32+4*$number_of_float_layers)/4+1)*2-1) . "] = add_result_" . $number_of_float_layers . "[" . ((32+4*$number_of_float_layers)/4*2-1) . "];\n";
# print $fh "assign add_result_" . $number_of_float_layers . "[" . (((32+4*$number_of_float_layers)/4+1)*2-2) . "] = add_result_" . $number_of_float_layers . "[" . ((32+4*$number_of_float_layers)/4*2-1) . "];\n";
# print $fh "\n";
print $fh "adder_" . (((32 + 4 * $number_of_float_layers) / 4) + 2) . "bit u_add_" . ($number_of_float_layers+1) . "(\n";
print $fh "  .a({add_result_reg_" . $number_of_float_layers . "[" . ((32+4*$number_of_float_layers)/4) . "], add_result_reg_" . $number_of_float_layers . "[" . ((32+4*$number_of_float_layers)/4) . ":0]}),\n";
print $fh "  .b({add_result_reg_" . $number_of_float_layers . "[" . ((32+4*$number_of_float_layers)/4*2+1) . "], add_result_reg_" . $number_of_float_layers . "[" . ((32+4*$number_of_float_layers)/4*2+1) . ":" . ((32+4*$number_of_float_layers)/4+1) . "]}),\n";
print $fh "  .c_i(1'b0),\n";
print $fh "  .c_o(),\n";
print $fh "  .o(add_result_" . ($number_of_float_layers+1). ")\n";
print $fh ");\n";
print $fh "\n";
print $fh "wire [31:0] float_result;\n";
print $fh "assign float_result = {add_result_reg_" . ($number_of_float_layers-1) . "[29], add_result_reg_" . ($number_of_float_layers-1) . "[28:21], add_result_reg_" . ($number_of_float_layers-1) . "[19:0], 3'b0};\n";
print $fh "assign o = add_mode[1] ? float_result : (type_a[0] | type_b[0]) ? add_result_reg_" . ($number_of_float_layers) . "_delay : add_result_" . ($number_of_float_layers+1) . ";\n";
print $fh "\n";
print $fh "endmodule\n";

close $fh;
print "==== INFO : Done Generate $file ==== \n";