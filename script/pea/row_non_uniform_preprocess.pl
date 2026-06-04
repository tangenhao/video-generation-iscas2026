#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $file = "";
my $help = "";
my $p = 64;

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

print "==== INFO: Generating row_non_uniform_preprocess ==== \n";
print "p: ", $p, "\n";

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $data_width = $p * 8;

my $code = <<"EOF";
module row_non_uniform_preprocess (
  in,
  out
);

EOF
print $fh $code;
print $fh "input [".($p*4 - 1).":0] in;\n";
print $fh "output [".($p*8 - 1).":0] out;\n";
print $fh "\n";
print $fh "genvar non_uniform_sel;\n";
print $fh "generate\n";
print $fh "for (non_uniform_sel = 0; non_uniform_sel < " . $p . "; non_uniform_sel = non_uniform_sel + 1) begin : non_uniform_preprocess\n";
print $fh "  non_uniform_preprocess u_non_uniform_preprocess (\n";
print $fh "    .in(in[non_uniform_sel * 4+:4]),\n";
print $fh "    .out(out[non_uniform_sel * 8+:8])\n";
print $fh "  );\n";
print $fh "end\n";
print $fh "endgenerate\n";
print $fh "\n";
print $fh "endmodule\n";
