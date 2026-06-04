#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $file = "";
my $help = "";
my $lane = 64;
my $p = 64;
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

print "==== INFO: Generating regfile ==== \n";
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

my $data_width = $p * 8;
my $lane_width = log($lane)/log(2);

my $code = <<"EOF";
`include "pack.vh"

module regfile (
  clk,
  rst_n,
  rw,
  dtype,
  non_uniform,
  non_uniform_sel,
  data,
  row_idx,
  row_data,
EOF
print $fh $code;

for (my $i = 0; $i < $layer; $i++) {
  print $fh "  weight_idx_$i, \n";
}
for (my $i = 0; $i < $layer; $i++) {
  if ($i == $layer - 1) {
    print $fh "  weight_layer_$i\n";
  }
  else {
    print $fh "  weight_layer_$i, \n";
  }
}
print $fh ");\n";
print $fh "\n";
$code = <<"EOF";
input wire clk;
input wire rst_n;
input wire rw;
input wire dtype;
input wire non_uniform;
input wire non_uniform_sel;
EOF
print $fh $code;
print $fh "input wire [", $data_width-1, ":0] data;\n";
print $fh "input wire [", $lane_width-1, ":0] row_idx;\n";
print $fh "input wire [" . ($p * $lane * 8 - 1) . ":0] row_data;\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "input wire [", $lane_width-1, ":0] weight_idx_$i;\n";
}
for (my $i = 0; $i < $layer; $i++) {
  print $fh "output wire [", $data_width-1, ":0] weight_layer_$i;\n";
}
print $fh "\n";
print $fh "reg [" . ($data_width-1) . ":0] regfile [0:" . ($lane-1) . "];\n";
print $fh "\n";
print $fh "integer i;\n";
print $fh "\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    for (i = 0; i < $lane; i = i + 1) begin\n";
print $fh "      regfile[i] <= 0;\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (rw) begin\n";
print $fh "      regfile[row_idx] <= data;\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      for (i = 0; i < $lane; i = i + 1) begin\n";
print $fh "        regfile[i] <= regfile[i];\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "wire [" . ($data_width/2-1) . ":0] non_uniform_row_in[0:" . ($lane-1) . "];\n";
print $fh "wire [" . ($data_width-1) . ":0] non_uniform_row_out[0:" . ($lane-1) . "];\n";
print $fh "\n";
print $fh "genvar row_non_uniform_sel_i;\n";
print $fh "generate\n";
print $fh "for (row_non_uniform_sel_i = 0; row_non_uniform_sel_i < " . $lane . "; row_non_uniform_sel_i = row_non_uniform_sel_i + 1) begin : non_uniform_preprocess\n";
print $fh "  assign non_uniform_row_in[row_non_uniform_sel_i] = non_uniform ? non_uniform_sel ? regfile[row_non_uniform_sel_i][" . ($data_width-1) . ":" . ($data_width/2) . "] : regfile[row_non_uniform_sel_i][" . ($data_width/2-1) . ":0] : " . $data_width/2 . "'d0;\n";
print $fh "  row_non_uniform_preprocess u_row_non_uniform_preprocess (\n";
print $fh "    .in(non_uniform_row_in[row_non_uniform_sel_i]),\n";
print $fh "    .out(non_uniform_row_out[row_non_uniform_sel_i])\n";
print $fh "  );\n";
print $fh "end\n";
print $fh "endgenerate\n";
print $fh "\n";
print $fh "genvar row_data_sel_i;\n";
print $fh "generate\n";
print $fh "for (row_data_sel_i = 0; row_data_sel_i < " . $lane . "; row_data_sel_i = row_data_sel_i + 1) begin : row_data_sel\n";
print $fh "  assign row_data[row_data_sel_i*".$data_width."+:".$data_width."] = non_uniform ? non_uniform_row_out[row_data_sel_i] : regfile[row_data_sel_i];\n";
print $fh "end\n";
print $fh "endgenerate\n";
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "reg [" . ($data_width-1) . ":0] weight_col_in_". $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [" . ($data_width-1) . ":0] weight_col_out_". $i .";\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "col_non_uniform_preprocess u_col_non_uniform_preprocess_" . $i . " (\n";
  print $fh "  .in(weight_col_in_" . $i . "[255:0]),\n";
  print $fh "  .out(weight_col_out_" . $i . ")\n";
  print $fh ");\n";
  print $fh "\n";
}
print $fh "always @(*) begin\n";
print $fh "  if (!rw) begin\n";
print $fh "    if (dtype) begin\n";
for(my $i = 0; $i < $layer; $i++) {
  print $fh "      case(weight_idx_$i)\n";
  for(my $j = 0; $j < $lane; $j++) {
    my $s = "{";
    for(my $k = 0; $k < $p; $k++) {
      $s = $s . "regfile[" . $k . "][" . ($j*8+7) . ":" . $j*8 . "]";
      if ($k != $p - 1) {
        $s = $s . ", ";
      }
    }
    $s = $s . "};";
    print $fh "        " . $lane_width . "'d" . $j . ": weight_col_in_" . "$i = " . $s . "\n";
  }
  print $fh "        default: weight_col_in_" . "$i = " . "0;\n";
  print $fh "      endcase\n";
}
print $fh "    end\n";
print $fh "    else begin\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "      case(weight_idx_$i)\n";
  for (my $j = 0; $j < $lane; $j++) {
    my $s = "{255'd0, ";
    for(my $k = 0; $k < $p; $k++) {
      $s = $s . "regfile[" . $k . "][" . ($j*4+3) . ":" . $j*4 . "]";
      if ($k != $p - 1) {
        $s = $s . ", ";
      }
    }
    $s = $s . "};";
    print $fh "        " . $lane_width . "'d" . $j . ": weight_col_in_" . "$i = " . $s . "\n";
  }
  print $fh "        default: weight_col_in_" . "$i = " . "0;\n";
  print $fh "      endcase\n";
}
print $fh "    end\n";
print $fh "  end\n";
print $fh "  else begin\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "    weight_col_in_" . "$i = " . "0;\n";
}
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "assign weight_layer_" . $i . " = non_uniform ? weight_col_out_" . $i . " : weight_col_in_" . $i . ";\n";
}
print $fh "\n";
print $fh "endmodule\n";