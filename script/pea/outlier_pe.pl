#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $file = "";
my $help = "";
my $lane = 64;
my $p = 32;
my $layer = 8;

GetOptions(
    "file=s" => \$file,
    "lane:s" => \$lane,
    "p:s" => \$p,
    "layer:s" => \$layer,
    "help" => \$help
) or die "Error in command line arguments\n";

if ($help) {
    print "Usage: $0 --file <file> [--lane <lane>] [--p <p>]\n";
    print "Options:\n";
    print "  --file <file>  Output file\n";
    print "  --lane <lane>  Lane\n";
    print "  --p <p>        Parallelism\n";
    print "  --layer <layer>  Layer\n";
    exit;
}

print "==== INFO: Generating outlier_pe ==== \n";
print "lane: ", $lane, "\n";
print "layer: ", $layer, "\n";
print "p: ", $p, "\n";

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $index_width = $p * 4;
my $data_width = $lane * 8;
my $lane_width = log($lane)/log(2);

my $code = <<"EOF";
`include "pack.vh"

module outlier_pe (
  clk,
  rst_n,
  valid,
  dtype,
  idx,
  data, 
EOF
print $fh $code;

for (my $i = 0; $i < $layer; $i++) {
  print $fh "  weight_layer_$i, \n";
}
for (my $i = 0; $i < $layer; $i++) {
  print $fh "  weight_idx_$i, \n";
}
print $fh "  result,\n";
print $fh "  halt,\n";
print $fh "  done\n";
print $fh ");\n";
print $fh "\n";
$code = <<"EOF";
input wire clk;
input wire rst_n;
input wire valid;
input wire dtype;
EOF
print $fh $code;
print $fh "input wire [", $index_width-1, ":0] idx;\n";
print $fh "input wire [", $data_width-1, ":0] data;\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "input wire [", $data_width-1, ":0] weight_layer_$i;\n";
}
for (my $i = 0; $i < $layer; $i++) {
  print $fh "input wire [", $lane_width-1, ":0] weight_idx_$i;\n";
}
print $fh "output wire [", $lane*32-1, ":0] result;\n";
print $fh "output wire halt;\n";
print $fh "output wire done;\n";
print $fh "\n";
print $fh "wire all_clear_layer_" . ($layer-1) . ";\n";
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [7:0] outlier_layer_$i;\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [7:0] weight_layer_" . ($i) . "_wire[" . ($lane-1) . ":0];\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [31:0] psum_layer_" . ($i) . "_wire[" . ($lane-1) . ":0];\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [" . ($index_width-1) . ":0] new_idx_layer_" . ($i) . ";\n";
}
print $fh "\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "reg [" . ($data_width-1) . ":0] data_layer_" . ($i) . ";\n";
}
print $fh "\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "reg [" . ($index_width-1) . ":0] idx_layer_" . ($i) . ";\n";
}
print $fh "\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "reg [31:0] psum_layer_" . ($i) . "_reg" . "[" . ($lane-1) . ":0];\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "reg layer_" . ($i) . "_done;\n";
}
print $fh "\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "    layer_" . ($i) . "_done <= 0;\n";
}
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    layer_0_done <= valid;\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "    layer_" . ($i) . "_done <= layer_" . ($i-1) . "_done;\n";
}
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "    data_layer_" . ($i) . " <= 0;\n";
}
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (valid) begin\n";
print $fh "      if (halt) begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "        data_layer_" . ($i) . " <= data_layer_" . ($i) . ";\n";
}
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        data_layer_1 <= data;\n";
for (my $i = 2; $i < $layer; $i++) {
  print $fh "        data_layer_" . ($i) . " <= data_layer_" . ($i-1) . ";\n";
}
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "      data_layer_" . ($i) . " <= 0;\n";
}
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "    idx_layer_" . ($i) . " <= 0;\n";
}
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (valid) begin\n";
print $fh "      if (halt) begin\n";
for (my $i = 1; $i < $layer-1; $i++) {
  print $fh "        idx_layer_" . ($i) . " <= idx_layer_" . ($i) . ";\n";
}
print $fh "        idx_layer_" . ($layer-1) . " <= new_idx_layer_". ($layer-1) . ";\n";
print $fh "      end\n";
print $fh "      else begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "        idx_layer_" . ($i) . " <= new_idx_layer_" . ($i) . ";\n";
}
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "      idx_layer_" . ($i) . " <= 0;\n";
}
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "integer psum_i;\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    for (psum_i = 0; psum_i < " . $lane . "; psum_i = psum_i + 1) begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "      psum_layer_" . ($i) . "_reg[psum_i] <= 0;\n";
}
print $fh "    end\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (valid) begin\n";
print $fh "      if (halt) begin\n";
print $fh "        for (psum_i = 0; psum_i < " . $lane . "; psum_i = psum_i + 1) begin\n";
for (my $i = 1; $i < $layer-1; $i++) {
  print $fh "          psum_layer_" . ($i) . "_reg[psum_i] <= psum_layer_" . ($i) . "_reg[psum_i];\n";
}
print $fh "          psum_layer_" . ($layer-1) . "_reg[psum_i] <= psum_layer_" . ($layer-1) . "_wire[psum_i];\n";
print $fh "        end\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        for (psum_i = 0; psum_i < " . $lane . "; psum_i = psum_i + 1) begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "          psum_layer_" . ($i) . "_reg[psum_i] <= psum_layer_" . ($i-1) . "_wire[psum_i];\n";
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      for (psum_i = 0; psum_i < " . $lane . "; psum_i = psum_i + 1) begin\n";
for (my $i = 1; $i < $layer; $i++) {
  print $fh "        psum_layer_" . ($i) . "_reg[psum_i] <= 0;\n";
}
print $fh "      end\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "outlier_selection u_outlier_selection_layer_" . $i . "(\n";
  print $fh "  .dtype(dtype),\n";
  if ($i == 0) {
    print $fh "  .idx(idx),\n";
    print $fh "  .data(data),\n";
  }
  else {
    print $fh "  .idx(idx_layer_" . ($i) . "),\n";
    print $fh "  .data(data_layer_" . ($i) . "),\n";
  }
  print $fh "  .outlier(outlier_layer_" . $i . ")\n";
  print $fh ");\n";
  print $fh "\n";
  print $fh "idx_process u_idx_process_layer_" . $i . "(\n";
  if ($i == 0) {
    print $fh "  .idx(idx),\n";
  }
  else {
    print $fh "  .idx(idx_layer_" . ($i) . "),\n";
  }
  print $fh "  .new_idx(new_idx_layer_" . $i . "),\n";
  print $fh "  .weight_col_idx(weight_idx_" . $i . ")\n";
  print $fh ");\n";
  print $fh "\n";
}
for (my $i = 0; $i < $layer; $i++) {
  print $fh "genvar mac_array_layer_" . $i . "_i;\n";
  print $fh "generate\n";
  print $fh "  for (mac_array_layer_" . $i . "_i = 0; mac_array_layer_" . $i . "_i < " . $lane . "; mac_array_layer_" . $i . "_i = mac_array_layer_" . $i . "_i + 1) begin: mac_array_layer_" . $i . "_gen\n";
  print $fh "    assign weight_layer_" . $i . "_wire[mac_array_layer_" . $i . "_i] = dtype ? weight_layer_" . $i . "[mac_array_layer_" . $i . "_i*8 +: 8] : {{4{weight_layer_" . $i . "[mac_array_layer_" . $i . "_i*4 + 3]}}, weight_layer_" . $i . "[mac_array_layer_" . $i . "_i*4 +: 4]};\n";
  print $fh "    mac u_mac_layer_" . $i . "_mac_array_layer_" . $i . "_i(\n";
  if ($i == $layer-1) {
    print $fh "      .en(valid),\n";
  }
  else {
    print $fh "      .en(!halt && valid),\n";
  }
  print $fh "      .a(outlier_layer_" . $i . "),\n";
  print $fh "      .b(weight_layer_" . $i . "_wire[mac_array_layer_" . $i . "_i]),\n";
  if ($i == 0) {
    print $fh "      .c(0),\n";
  }
  else {
    print $fh "      .c(psum_layer_" . ($i) . "_reg[mac_array_layer_" . $i . "_i]),\n";
  }
  print $fh "      .o(psum_layer_" . ($i) . "_wire[mac_array_layer_" . $i . "_i])\n";
  print $fh "    );\n";
  print $fh "  end\n";
  print $fh "endgenerate\n";
  print $fh "\n";
}
print $fh "assign all_clear_layer_" . ($layer-1) . " = layer_" . ($layer-1) . "_done ? ~|new_idx_layer_" . ($layer-1) . " : 0;\n";
print $fh "\n";
print $fh "assign halt = layer_" . ($layer-1) . "_done & !all_clear_layer_" . ($layer-1) . ";\n";
print $fh "\n";
print $fh "assign done = layer_" . ($layer-1) . "_done & all_clear_layer_" . ($layer-1) . ";\n";
print $fh "\n";
print $fh "`PACK_ARRAY_WITH_EN(outlier_result_pack_array, outlier_result_pack_idx, all_clear_layer_" . ($layer-1) . ", 32, " . $lane . ", psum_layer_" . ($layer-1) . "_wire, result);\n";
print $fh "\n";
print $fh "endmodule\n";

print "==== INFO : Done Generate $file ==== \n";
