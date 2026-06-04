#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $file = "";
my $help = "";
my $lane = 64;
my $p = 32;

GetOptions(
    "file=s" => \$file,
    "lane:s" => \$lane,
    "p:s" => \$p,
    "help" => \$help
) or die "Error in command line arguments\n";

if ($help) {
    print "Usage: $0 --file <file> [--lane <lane>] [--p <p>]\n";
    print "Options:\n";
    print "  --file <file>  Output file\n";
    print "  --lane <lane>  Lane\n";
    print "  --p <p>        Parallelism\n";
    exit;
}

print "==== INFO: Generating idx_process ==== \n";
print "lane: ", $lane, "\n";
print "p: ", $p, "\n";

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $index_wdith = $p * 4-1;
my $weight_col_idx_width = log($lane) / log(2)-1;

my $code = <<"EOF";
module idx_process (
  idx,
  new_idx,
  weight_col_idx
);

input wire [$index_wdith:0] idx;
output wire [$index_wdith:0] new_idx;
output reg [$weight_col_idx_width:0] weight_col_idx;

EOF

print $fh $code;

for (my $i = 0; $i < $index_wdith / 8; $i++) {
  my $code = <<"EOF";
wire [7:0] idx_$i;
EOF
  print $fh $code;
}
print $fh "\n";

for (my $i = 0; $i < $index_wdith / 8; $i++) {
  my @idx_i = ("assign idx_", $i, " = idx[", $i * 8, "+:8];\n");
  print $fh @idx_i;
}
print $fh "\n";

my @flag = ("wire [", ($index_wdith + 1) / 8 - 1, ":0] flag;\n\n");
print $fh @flag;
for (my $i = 0; $i < $index_wdith / 8; $i++) {
  my @flag_i = ("assign flag[", $i, "] = |idx_", $i, ";\n");
  print $fh @flag_i;
}

print $fh "\n";

for (my $i = 0; $i < $index_wdith / 8; $i++) {
  my @new_idx_i = ("reg [7:0] new_idx_", $i, ";\n");
  print $fh @new_idx_i;
}

print $fh "\n";

print $fh "always @(*) begin\n";
print $fh "  casex(flag)\n";
for (my $i = (($index_wdith+1) / 8)-1; $i >=0 ; $i--) {
  my @case_i = ("    ", "16'b", '0' x ((($index_wdith+1) / 8) - 1 - $i), "1", "x" x $i, ":\n");
  print $fh @case_i;
  print $fh "      begin\n";
  print $fh "        casex(idx_", $i, ")\n";
  for (my $j = 0; $j < 8; $j++) {
    if ($j == 7) {
      my @new_idx_i = ("          8'b00000001: new_idx_", $i, " = 'd0;\n");  
      print $fh @new_idx_i;
    }
    else {
      my @new_idx_i = ("          8'b", "0" x $j, 1, "x" x (7 - $j), ": new_idx_", $i, " = {", $j+1, "'d0, ", "idx_", $i, "[", 6-$j, ":0]}", ";\n");
      print $fh @new_idx_i;
    }
  }
  print $fh "          default: new_idx_", $i, " = 'd0;\n";
  print $fh "        endcase\n";
  for (my $j = 0; $j < ($index_wdith / 8); $j++) {
    if ($j != $i) {
      my @new_idx_i = ("          new_idx_", $j, " = idx_", $j, ";\n");
      print $fh @new_idx_i;
    }
  }
  print $fh "      end\n";
}
print $fh "    default: begin\n";
for (my $i = 0; $i < ($index_wdith / 8); $i++) {
  my @new_idx_i = ("      new_idx_", $i, " = 'd0", ";\n");
  print $fh @new_idx_i;
}
print $fh "    end\n";
print $fh "  endcase\n";
print $fh "end\n";
print $fh "\n";

for (my $i = 0; $i < $index_wdith / 8; $i++) {
  my @new_idx_i = ("assign new_idx[", $i * 8, "+:8] = new_idx_", $i, ";\n");
  print $fh @new_idx_i;
}
print $fh "\n";

print $fh "always @(*) begin\n";
print $fh "  casex(flag)\n";
for (my $i = (($index_wdith+1) / 8)-1; $i >=0 ; $i--) {
  my @case_i = ("    ", "16'b", '0' x ((($index_wdith+1) / 8) - 1 - $i), "1", "x" x $i, ":\n");
  print $fh @case_i;
  print $fh "      casex(idx_", $i, ")\n";
  for (my $j = 0; $j < 8; $j++) {
    my @case_i = ("        8'b", "0" x $j, 1, "x" x (7 - $j), ": weight_col_idx = ", ($i+1) * 8 - $j - 1, ";\n");
    print $fh @case_i;
  }
  print $fh "        default: weight_col_idx = 0;\n";
  print $fh "      endcase\n";
}
print $fh "    default: weight_col_idx = 0;\n";
print $fh "  endcase\n";
print $fh "end\n\n";

print $fh "endmodule\n";

print "==== INFO: Done Generate $file ====\n";
