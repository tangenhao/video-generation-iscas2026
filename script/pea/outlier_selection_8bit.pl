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

print "==== INFO: Generating outlier_selection_8bit ==== \n";
print "lane: ", $lane, "\n";
print "p: ", $p, "\n";

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $code = <<"EOF";
module outlier_selection_8bit (
  en,
  idx,
  data,
  outlier
);

EOF
print $fh $code;

my $index_width = $p * 2;
my $data_width = $lane * 8;

print $fh "input wire en;\n";
print $fh "input wire [", $index_width-1, ":0] idx;\n";
print $fh "input wire [", $data_width-1, ":0] data;\n";
print $fh "output wire [7:0] outlier;\n";
print $fh "\n";
for (my $i = 0; $i < ($index_width/8); $i++) {
  print $fh "wire [7:0] idx_$i;\n";
}
print $fh "\n";
for (my $i = 0; $i < ($index_width/8); $i++) {
  print $fh "assign idx_$i = idx[", 8*$i+7, ":", 8*$i, "];\n";
}
print $fh "\n";
for (my $i = 0; $i < ($index_width/8); $i++) {
  print $fh "wire [", $data_width/8-1, ":0] data_$i;\n";
}
print $fh "\n";
for (my $i = 0; $i < ($index_width/8); $i++) {
  print $fh "assign data_$i = data[", 64*$i+63, ":", 64*$i, "];\n";
}
print $fh "\n";
for (my $i = 0; $i < ($index_width/8); $i++) {
  print $fh "reg [7:0] outlier_$i;\n";
}
print $fh "\n";
for (my $i = 0; $i < ($index_width/8); $i++) {
  print $fh "always @(*) begin\n";
  print $fh "  if (en) begin\n";
  print $fh "    case (idx_$i)\n";
  for (my $j = 0; $j < 8; $j++) {
    print $fh "      8'b", '0' x $j, '1', 'x' x (7-$j), ": outlier_", $i, " = data_", $i, "[", 8*(7-$j)+7, ":", 8*(7-$j), "];\n";
  }
  
  print $fh "      default: outlier_", $i, " = 8'b0;\n";
  print $fh "    endcase\n";
  print $fh "  end\n";
  print $fh "  else begin\n";
  print $fh "    outlier_", $i, " = 8'b0;\n";
  print $fh "  end\n";
  print $fh "end\n";
  print $fh "\n";
}
print $fh "assign outlier = |idx_", $index_width/8-1, " ? outlier_", $index_width/8-1, " :\n";
for (my $i = $index_width/8-2; $i >= 0; $i--) {
  print $fh "                 |idx_", $i, " ? outlier_", $i, " :\n";
}
print $fh "                 8'b0;\n";
print $fh "\n";
print $fh "endmodule\n";

print "==== INFO : Done Generate $file ==== \n";
