#!/usr/bin/perl
use strict; 
use Getopt::Long;

my $help = "";
my $file = "";
my $width = 32;
my $depth = 512;
my $bank = 8;

GetOptions(
  "file=s" => \$file, 
  "help" => \$help, 
  "width:s" => \$width, 
  "depth:s" => \$depth, 
  "bank:s" => \$bank, 
) or die "Error in command line arguments\n";

if ($help) {
  print "Usage: $0 --file <file> --p <p> --depth <depth> --width <width> --bank <bank>\n";
  print "Options:\n";
  print "  --file <file>               Output file\n";
  print "  --width <width>             Sram width\n";
  print "  --depth <depth>             Sram depth\n";
  print "  --bank <bank>               Sram Bank\n";
  exit;
}

print "==== INFO: Generating ifmap_scale_arbiter ==== \n";
print "width: ", $width, "\n";
print "depth: ", $depth, "\n";
print "bank: ", $bank, "\n";

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $sram_addr_bits = log($depth) / log(2);
my $sram_addr_bits_all = log($depth * $bank) / log(2);

print $fh "module ifmap_scale_arbiter(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  rvalid_" . $i . ", addr_" . $i . ", data_" . $i . ", rready_" . $i . ",\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank - 1){
    print $fh "  ren_" . $i . ", raddr_" . $i . ", rdata_" . $i . "\n";
  }
  else {
    print $fh "  ren_" . $i . ", raddr_" . $i . ", rdata_" . $i . ",\n";
  }
}
print $fh ");\n";
print $fh "\n";
print $fh "input wire clk;\n";
print $fh "input wire rst_n;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire rvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] addr_" . $i . ";\n";
  print $fh "output wire [", ($width - 1), ":0] data_" . $i . ";\n";
  print $fh "output wire rready_" . $i . ";\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "output wire ren_" . $i . ";\n";
  print $fh "output wire [", $sram_addr_bits-1, ":0] raddr_" . $i . ";\n";
  print $fh "input wire [", $width-1, ":0] rdata_" . $i . ";\n";
  print $fh "\n";
}


my $highaddr_bits = log($bank*2) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($highaddr_bits-1) . ":0] raddr_high_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign raddr_high_" . $i . " = addr_" . $i . "[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] request_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] request_" . $i . "_reg;\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $request = "assign request_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == 0) {
      $request = $request . "rvalid_" . $j . " && (raddr_high_" . $j . "[". ($highaddr_bits-2) . ":0] == " . $i . ")};\n";
    }
    else {
      $request = $request . "rvalid_" . $j . " && (raddr_high_" . $j . "[". ($highaddr_bits-2) . ":0] == " . $i . "), ";
    }
  }
  print $fh $request;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] grant_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] grant_" . $i . "_reg;\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $grant = "assign grant_" . $i . " = request_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j != $i && (($j == $bank-2 && $i == $bank-1) || ($j == $bank-1 && $i != $bank-1))) {
      $grant = $grant . "                 request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :";
    }
    elsif ($j != $i && $j != $bank-1) {
      $grant = $grant . "                 request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " : \n";
    }
  }
  print $fh $grant;
  print $fh " 0;\n";
  print $fh "\n";
}

for (my $i = 0; $i < $bank; $i++) {
  my $ren = "assign ren_" . $i . " = ";
  $ren = $ren . "|request_" . $i . ";\n";
  print $fh $ren;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $raddr = "assign raddr_" . $i . " = (request_" . $i . "[0] && grant_" . $i . "[0]) ? addr_0" . "[" . ($sram_addr_bits-1) . ":0] : \n"; 
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank - 1) {
      $raddr = $raddr . "                 (request_" . $i . "[" . $j . "] && grant_" . $i . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : 0;\n";
    }
    else {
      $raddr = $raddr . "                 (request_" . $i . "[" . $j . "] && grant_" . $i . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : \n";
    } 
  }
  print $fh $raddr;
  print $fh "\n";
}


for (my $i = 0; $i < $bank; $i++) {
  my $rready = "assign rready_" . $i . " = (";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $rready = $rready . "(request_" . $j . "[" . $i . "] & grant_" . $j . "[" . $i . "]))";
    }
    else {
      $rready = $rready . "(request_" . $j . "[" . $i . "] & grant_" . $j . "[" . $i . "]) | ";
    }
  }
  print $fh $rready;
  print $fh ";\n";
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $data = "assign data_" . $i . " = request_0_reg[" . $i . "] && grant_0_reg[" . $i . "] ? rdata_0 : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $data = $data . "                request_" . $j . "_reg[" . $i . "] && grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " : 0;\n";
    }
    else {
      $data = $data . "                request_" . $j . "_reg[" . $i . "] && grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " : \n";
    }
  }
  print $fh $data;
  print $fh "\n";
}


print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    request_" . $i . "_reg <= " . $bank . "'b0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    grant_" . $i . "_reg <= " . $bank . "'b0;\n";
}
print $fh "  end\n";
print $fh "  else begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    request_" . $i . "_reg <= request_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    grant_" . $i . "_reg <= grant_" . $i . ";\n";
}
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";

print $fh "endmodule\n";

print "==== INFO: Done Generate $file ====\n";
