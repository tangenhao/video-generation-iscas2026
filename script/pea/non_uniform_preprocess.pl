#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $file = "";
my $help = "";

GetOptions(
    "file=s" => \$file,
    "help" => \$help
) or die "Error in command line arguments\n";

if ($help) {
    print "Usage: $0 --file <file> [--lane <lane>] [--p <p>]\n";
    print "Options:\n";
    print "  --file <file>  Output file\n";
    exit;
}

print "==== INFO: Generating non_uniform_preprocess ==== \n";

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $code = <<"EOF";
module non_uniform_preprocess (
  in,
  out
);

input [3:0] in;
output [7:0] out;

assign out = {in, 4'b0};

endmodule
EOF
print $fh $code;