#!/usr/bin/perl
use strict; 
use Getopt::Long;

my $help = "";
my $file = "";
my $bitwidth = 1;
my $n = 4;
my $m = 1;

GetOptions(
  "file=s" => \$file, 
  "help" => \$help, 
  "bitwidth:s" => \$bitwidth, 
  "n:s" => \$n, 
  "m:s" => \$m, 
) or die "Error in command line arguments\n";

if ($help) {
  print "Usage: perl pea.pl --file <file> --p <p> --lane <lane> --layer <layer> --ifmap_sram_depth <ifmap_sram_depth> --weight_sram_depth <weight_sram_depth> --psum_sram_depth <psum_sram_depth>\n";
  print "Options:\n";
  print "  --file <file>               Output file\n";
  print "  --bitwidth <bitwidth>       Bitwidth\n";
  print "  --n <n>                     n:m\n";
  print "  --m <m>                     n:m\n";
  exit;
}

print "==== INFO: Generating mux ==== \n";
print "File: $file\n";
print "Bitwidth: $bitwidth\n";
print "n: $n\n";
print "m: $m\n";

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

print $fh "module mux_" . $n . "to" . $m . "_" . $bitwidth . "bit (\n";
print $fh "  mask,\n";
print $fh "  data,\n";
print $fh "  out\n";
print $fh ");\n";
print $fh "\n";
print $fh "input [" . ($n-1) . ":0] mask;\n";
print $fh "input [" . ($n*$bitwidth-1) . ":0] data;\n";
if ($m == 1 && $n == 4) {
  if ($bitwidth == 1) {
    print $fh "output reg  out;\n";
  }
  else {
    print $fh "output reg [" . ($bitwidth-1) . ":0] out;\n";
  }
}
else {
  print $fh "output [" . ($m*$bitwidth-1) . ":0] out;\n";
}
print $fh "\n";
if ($m == 1) {
  if ($n == 4) {
    print $fh "always @(*) begin\n";
    print $fh "  case(1'b1)\n";
    for (my $i = 0; $i < $n; $i++) {
      if ($bitwidth == 1) {
        print $fh "    mask[" . $i . "]: out = data[" . $i . "];\n";
      }
      else {
        print $fh "    mask[" . $i . "]: out = data[" . ($bitwidth*$i+$bitwidth-1) . ":" . ($bitwidth*$i) . "];\n";
      }
    }
    print $fh "    default: out = 0;\n";
    print $fh "  endcase\n";
    print $fh "end\n";
    print $fh "\n";
  }
  else {
    for (my $i = 0; $i < $n / 4; $i++) {
      if ($bitwidth == 1) {
        print $fh "wire mux_" . $i . "_res;\n";
      }
      else {
        print $fh "wire [" . ($bitwidth-1) . ":0] mux_" . $i . "_res;\n";
      }
    }
    print $fh "\n";
    for (my $i = 0; $i < $n / 4; $i++) {
      print $fh "mux_4to1_" . $bitwidth . "bit u_mux_" . $i . " (\n";
      print $fh "  .mask(mask[" . (4*$i+3) . ":" . (4*$i) . "]),\n";
      print $fh "  .data(data[" . ($bitwidth*(4*$i+4)-1) . ":" . ($bitwidth*4*$i) . "]),\n";
      print $fh "  .out(mux_" . $i . "_res)\n";
      print $fh ");\n";
      print $fh "\n";
    }
    my $out = "assign out = |mask[" . ($n-1) . ":" . ($n-4) . "] ? mux_" . (int($n/4)-1) . "_res : \n";
    for (my $i = int($n/4)-2; $i > 0; $i--) {
      $out = $out . "             |mask[" . (4*($i+1)+3) . ":" . (4*($i+1)) . "] ? mux_" . $i . "_res : \n";
    }
    $out = $out . "             |mask[3:0] ? mux_0_res : 0;";
    print $fh $out;
    print $fh "\n";
  }
}
else {
  for (my $i = 0; $i < $m; $i++) {
    print $fh "wire [".($n-1).":0] mask_" . $i . "_sel;\n";
  }
  print $fh "\n";
  for (my $i = 0; $i < $m; $i++) {
    print $fh "and_minus #(.width(" . $n . ")) u_and_minus_" . $i . " (\n";
    if ($i == 0) {
      print $fh "  .in(mask),\n";
    }
    elsif ($i == 1) {
      print $fh "  .in(mask_" . ($i-1) . "_sel ^ mask),\n";
    }
    else {
      print $fh "  .in(mask_" . ($i-1) . "_sel ^ mask_" . ($i-2) . "_sel),\n";
    }
    print $fh "  .out(mask_" . $i . "_sel)\n";
    print $fh ");\n";
    print $fh "\n";
  }
  for (my $i = 0; $i < $m; $i++) {
    print $fh "mux_" . $n . "to1_" . $bitwidth . "bit u_mux_" . $i . " (\n";
    print $fh "  .mask(mask_" . $i . "_sel),\n";
    print $fh "  .data(data),\n";
    if ($bitwidth == 1) {
      print $fh "  .out(out[" . $i . "])\n";
    }
    else {
      print $fh "  .out(out[" . ($bitwidth*($i+1)-1) . ":" . ($bitwidth*$i) . "])\n";
    }
    print $fh ");\n";
    print $fh "\n";
  }
}
print $fh "endmodule\n";
