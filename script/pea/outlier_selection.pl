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

my $fh;

print "==== INFO: Generating outlier_selection ==== \n";
print "lane: ", $lane, "\n";
print "p: ", $p, "\n";

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $index_width = $p * 4;
my $data_width = $lane * 8;

my $code = <<"EOF";
module outlier_selection(
  dtype,
  idx,
  data,
  outlier
);

EOF
print $fh $code;

print $fh "input wire dtype;\n";
print $fh "input wire [", $index_width-1, ":0] idx;\n";
print $fh "input wire [", $data_width-1, ":0] data;\n";
print $fh "output wire [7:0] outlier;\n";
print $fh "\n";
print $fh "wire [3:0] outlier_4bit;\n";
print $fh "wire [7:0] outlier_8bit;\n";
print $fh "\n";
print $fh "outlier_selection_4bit u_outlier_selection_4bit(\n";
print $fh "  .en(!dtype),\n";
print $fh "  .idx(idx),\n";
print $fh "  .data(data),\n";
print $fh "  .outlier(outlier_4bit)\n";
print $fh ");\n";
print $fh "\n";
print $fh "outlier_selection_8bit u_outlier_selection_8bit(\n";
print $fh "  .en(!dtype),\n";

print $fh "  .idx(idx[", $index_width/2-1, ":0]),\n";
print $fh "  .data(data),\n";
print $fh "  .outlier(outlier_8bit)\n";
print $fh ");\n";
print $fh "\n";
print $fh "assign outlier = dtype ? outlier_8bit : {{4{outlier_4bit[3]}}, outlier_4bit};\n";
print $fh "\n";
print $fh "endmodule\n";

print "==== INFO : Done Generate $file ==== \n";
