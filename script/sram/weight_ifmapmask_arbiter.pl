#!/usr/bin/perl
use strict; 
use Getopt::Long;

my $help = "";
my $file = "";
my $width = 512;
my $depth = 1024;
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

print "==== INFO: Generating weight_ifmapmask_arbiter ==== \n";
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
my $weight_sram_depth_expand = $depth * 2 * $bank;
my $weight_sram_addr_bits_expand = log($weight_sram_depth_expand) / log(2);
my $ifmap_mask_sram_addr_bits = log($weight_sram_depth_expand) / log(2);

print $fh "module weight_ifmapmask_arbiter(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
print $fh "  expand,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  weight_rvalid_" . $i . ", weight_addr_" . $i . ", weight_data_" . $i . ", weight_rready_" . $i . ",\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  mask_rvalid_" . $i . ", mask_addr_" . $i . ", mask_data_" . $i . ", mask_rready_" . $i . ",\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank*5; $i++) {
  if ($i == $bank*5 - 1) {
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
print $fh "input wire expand;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire weight_rvalid_" . $i . ";\n";
  print $fh "input wire [", $weight_sram_addr_bits_expand-1, ":0] weight_addr_" . $i . ";\n";
  print $fh "output wire [" . ($width-1) . ":0] weight_data_" . $i . ";\n";
  print $fh "output wire weight_rready_" . $i . ";\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire mask_rvalid_" . $i . ";\n";
  print $fh "input wire [", $ifmap_mask_sram_addr_bits-1, ":0] mask_addr_" . $i . ";\n";
  print $fh "output wire [" . ($width*2-1) . ":0] mask_data_" . $i . ";\n";
  print $fh "output wire mask_rready_" . $i . ";\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "output wire ren_" . $i . ";\n";
  print $fh "output wire [" . ($sram_addr_bits-1) . ":0] raddr_" . $i . ";\n";
  print $fh "input wire [" . ($width-1) . ":0] rdata_" . $i . ";\n";
  print $fh "\n";
}
for (my $i = $bank; $i < $bank*5; $i++) {
  print $fh "input wire ren_" . $i . ";\n";
  print $fh "input wire [" . ($sram_addr_bits-1) . ":0] raddr_" . $i . ";\n";
  print $fh "output wire [" . ($width/2-1) . ":0] rdata_" . $i . ";\n";
  print $fh "\n";
}

my $weight_highaddr_bits = log($bank*2) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $weight_highaddr_bits-1, ":0] weight_raddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign weight_raddr_high_" . $i . " = weight_addr_" . $i . "[" . ($weight_sram_addr_bits_expand-2) . ":" . ($weight_sram_addr_bits_expand - $weight_highaddr_bits-2) . "];\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $bank-1, ":0] weight_request_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [", $bank-1, ":0] weight_request_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $weight_req = "assign weight_request_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == 0) {
      $weight_req = $weight_req . "weight_rvalid_" . $j . " && (weight_raddr_high_" . $j . "[". ($weight_highaddr_bits-1) . ":0] == " . $i . ")};\n";
    }
    else {
      $weight_req = $weight_req . "weight_rvalid_" . $j . " && (weight_raddr_high_" . $j . "[". ($weight_highaddr_bits-1) . ":0] == " . $i . "), ";
    }
  }
  print $fh $weight_req;
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] weight_grant_" . $i . ";\n";
} 
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] weight_grant_" . $i . "_reg;\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $weight_grant = "assign weight_grant_" . $i . " = weight_request_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j != $i && (($j == $bank-2 && $i == $bank-1) || ($j == $bank-1 && $i != $bank-1))) {
      $weight_grant = $weight_grant . "                        weight_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :";
    }
    elsif ($j != $i && $j != $bank-1) {
      $weight_grant = $weight_grant . "                        weight_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :\n";
    }
  }
  print $fh $weight_grant;
  print $fh " 0;\n";
  print $fh "\n";
}

my $weight_expand_highaddr_bits = log($bank*4) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $weight_expand_highaddr_bits-1, ":0] weight_expand_raddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign weight_expand_raddr_high_" . $i . " = weight_addr_" . $i . "[" . ($weight_sram_addr_bits_expand-1) . ":" . ($weight_sram_addr_bits_expand - $weight_expand_highaddr_bits) . "];\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $bank-1, ":0] weight_expand_weight_request_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [", $bank-1, ":0] weight_expand_weight_request_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $weight_expand_req = "assign weight_expand_weight_request_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == 0) {
      $weight_expand_req = $weight_expand_req . "weight_rvalid_" . $j . " && (weight_expand_raddr_high_" . $j . "[". ($weight_expand_highaddr_bits-2) . ":0] == " . $i . ")};\n";
    }
    else {
      $weight_expand_req = $weight_expand_req . "weight_rvalid_" . $j . " && (weight_expand_raddr_high_" . $j . "[". ($weight_expand_highaddr_bits-2) . ":0] == " . $i . "), ";
    }
  }
  print $fh $weight_expand_req;
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $bank-1, ":0] weight_expand_mask_request_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [", $bank-1, ":0] weight_expand_mask_request_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $weight_expand_req = "assign weight_expand_mask_request_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == 0) {
      $weight_expand_req = $weight_expand_req . "weight_rvalid_" . $j . " && (weight_expand_raddr_high_" . $j . "[". ($weight_expand_highaddr_bits-2) . ":0] == " . ($i+8) . ")};\n";
    }
    else {
      $weight_expand_req = $weight_expand_req . "weight_rvalid_" . $j . " && (weight_expand_raddr_high_" . $j . "[". ($weight_expand_highaddr_bits-2) . ":0] == " . ($i+8) . "), ";
    }
  }
  print $fh $weight_expand_req;
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] weight_expand_weight_grant_" . $i . ";\n";
} 
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] weight_expand_weight_grant_" . $i . "_reg;\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $weight_expand_grant = "assign weight_expand_weight_grant_" . $i . " = weight_expand_weight_request_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j != $i && (($j == $bank-2 && $i == $bank-1) || ($j == $bank-1 && $i != $bank-1))) {
      $weight_expand_grant = $weight_expand_grant . "                                      weight_expand_weight_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :";
    }
    elsif ($j != $i && $j != $bank-1) {
      $weight_expand_grant = $weight_expand_grant . "                                      weight_expand_weight_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :\n";
    }
  }
  print $fh $weight_expand_grant;
  print $fh " 0;\n";
  print $fh "\n";
}

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] weight_expand_mask_grant_" . $i . ";\n";
} 
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] weight_expand_mask_grant_" . $i . "_reg;\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $weight_expand_grant = "assign weight_expand_mask_grant_" . $i . " = weight_expand_mask_request_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j != $i && (($j == $bank-2 && $i == $bank-1) || ($j == $bank-1 && $i != $bank-1))) {
      $weight_expand_grant = $weight_expand_grant . "                                    weight_expand_mask_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :";
    }
    elsif ($j != $i && $j != $bank-1) {
      $weight_expand_grant = $weight_expand_grant . "                                    weight_expand_mask_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :\n";
    }
  }
  print $fh $weight_expand_grant;
  print $fh " 0;\n";
  print $fh "\n";
}

my $mask_highaddr_bits = log($bank*2) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $mask_highaddr_bits-1, ":0] mask_raddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign mask_raddr_high_" . $i . " = mask_addr_" . $i . "[" . ($ifmap_mask_sram_addr_bits-2) . ":" . ($ifmap_mask_sram_addr_bits - $mask_highaddr_bits-1) . "];\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $bank-1, ":0] mask_request_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [", $bank-1, ":0] mask_request_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $mask_req = "assign mask_request_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == 0) {
      $mask_req = $mask_req . "mask_rvalid_" . $j . " && (mask_raddr_high_" . $j . "[". ($mask_highaddr_bits-2) . ":0] == " . $i . ")};\n";
    }
    else {
      $mask_req = $mask_req . "mask_rvalid_" . $j . " && (mask_raddr_high_" . $j . "[". ($mask_highaddr_bits-2) . ":0] == " . $i . "), ";
    }
  }
  print $fh $mask_req;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] mask_grant_" . $i . ";\n";
} 
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] mask_grant_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $mask_grant = "assign mask_grant_" . $i . " = mask_request_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j != $i && (($j == $bank-2 && $i == $bank-1) || ($j == $bank-1 && $i != $bank-1))) {
      $mask_grant = $mask_grant . "                      mask_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j;
    }
    elsif ($j != $i && $j != $bank-1) {
      $mask_grant = $mask_grant . "                      mask_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :\n";
    }
  }
  print $fh $mask_grant;
  print $fh " : 0;\n";
  print $fh "\n";
}

my $mask_expand_highaddr_bits = log($bank*2) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $mask_expand_highaddr_bits-1, ":0] mask_expand_raddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign mask_expand_raddr_high_" . $i . " = mask_addr_" . $i . "[" . ($ifmap_mask_sram_addr_bits-1) . ":" . ($ifmap_mask_sram_addr_bits - $mask_highaddr_bits) . "];\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [", $bank-1, ":0] mask_expand_request_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [", $bank-1, ":0] mask_expand_request_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $mask_req = "assign mask_expand_request_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == 0) {
      $mask_req = $mask_req . "mask_rvalid_" . $j . " && (mask_raddr_high_" . $j . "[". ($mask_highaddr_bits-2) . ":0] == " . $i . ")};\n";
    }
    else {
      $mask_req = $mask_req . "mask_rvalid_" . $j . " && (mask_raddr_high_" . $j . "[". ($mask_highaddr_bits-2) . ":0] == " . $i . "), ";
    }
  }
  print $fh $mask_req;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] mask_expand_grant_" . $i . ";\n";
} 
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] mask_expand_grant_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $mask_expand_grant = "assign mask_expand_grant_" . $i . " = mask_expand_request_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j != $i && (($j == $bank-2 && $i == $bank-1) || ($j == $bank-1 && $i != $bank-1))) {
      $mask_expand_grant = $mask_expand_grant . "                             mask_expand_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j;
    }
    elsif ($j != $i && $j != $bank-1) {
      $mask_expand_grant = $mask_expand_grant . "                             mask_expand_request_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :\n";
    }
  }
  print $fh $mask_expand_grant;
  print $fh " : 0;\n";
  print $fh "\n";
}

for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign ren_" . $i . " = (!expand & |weight_request_" . $i . ") | (expand & |weight_expand_weight_request_" . $i . ");\n";
}
print $fh "\n";

for (my $i = $bank; $i < $bank*3; $i++) {
  print $fh "assign ren_" . $i . " = (!expand & |mask_request_" . int(($i-$bank) / 4). ") | (expand & |weight_expand_mask_request_" . int(($i-$bank)/2) . ");\n";
}
print $fh "\n";

for (my $i = $bank*3; $i < $bank*5; $i++) {
  if ($i - $bank*3 < $bank){
    print $fh "assign ren_" . $i . " = (!expand & |mask_request_" . int(($i-$bank) / 4) . ") | (expand & |mask_expand_request_" . int(($i-$bank*3) / 2) . ");\n";
  } 
  else{
    print $fh "assign ren_" . $i . " = (!expand & |mask_request_" . int(($i-$bank) / 4) . ") | (expand & |mask_expand_request_" . int(($i-$bank*3) / 2) . ");\n";
  }
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $raddr = "assign raddr_" . $i . " = !expand ? weight_request_" . $i . "[0] && weight_grant_" . $i . "[0] ? weight_addr_" . $i . "[" . ($sram_addr_bits-1) .":0] : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $raddr = $raddr . "                           weight_request_" . $i . "[" . $j . "] && weight_grant_" . $i . "[" . $j . "] ? weight_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] : 0 :\n";
    }
    else {
      $raddr = $raddr . "                           weight_request_" . $i . "[" . $j . "] && weight_grant_" . $i . "[" . $j . "] ? weight_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] :\n";
    }
  }
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $raddr = $raddr . "                           weight_expand_weight_request_" . $i . "[" . $j . "] && weight_expand_weight_grant_" . $i . "[" . $j . "] ? weight_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] : 0;\n";
    }
    else {
      $raddr = $raddr . "                           weight_expand_weight_request_" . $i . "[" . $j . "] && weight_expand_weight_grant_" . $i . "[" . $j . "] ? weight_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] :\n";
    }
  }
  print $fh "\n";
  print $fh $raddr;
}

for (my $i = $bank; $i < $bank*3; $i++) {
  my $raddr = "assign raddr_" . $i . " = !expand ? mask_request_" . int(($i-$bank)/4) . "[0] && mask_grant_" . int(($i-$bank)/4) . "[0] ? mask_addr_0" . "[" . ($sram_addr_bits-1) .":0] : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $raddr = $raddr . "                           mask_request_" . int(($i-$bank)/4) . "[" . $j . "] && mask_grant_" . int(($i-$bank)/4) . "[" . $j . "] ? mask_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] : 0 :\n";
    }
    else {
      $raddr = $raddr . "                           mask_request_" . int(($i-$bank)/4) . "[" . $j . "] && mask_grant_" . int(($i-$bank)/4) . "[" . $j . "] ? mask_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] :\n";
    }
  }
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $raddr = $raddr . "                           weight_expand_mask_request_" . int(($i-$bank)/2) . "[" . $j . "] && weight_expand_mask_grant_" . int(($i-$bank)/2) . "[" . $j . "] ? weight_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] : 0;\n";
    }
    else {
      $raddr = $raddr . "                           weight_expand_mask_request_" . int(($i-$bank)/2) . "[" . $j . "] && weight_expand_mask_grant_" . int(($i-$bank)/2) . "[" . $j . "] ? weight_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] :\n";
    }
  }
  print $fh "\n";
  print $fh $raddr;
}

for (my $i = $bank*3; $i < $bank*5; $i++) {
  my $raddr = "assign raddr_" . $i . " = !expand ? mask_request_" . int(($i-$bank)/4) . "[0] && mask_grant_" . int(($i-$bank)/4) . "[0] ? mask_addr_0" . "[" . ($sram_addr_bits-1) .":0] : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $raddr = $raddr . "                            mask_request_" . int(($i-$bank)/4) . "[" . $j . "] && mask_grant_" . int(($i-$bank)/4) . "[" . $j . "] ? mask_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] : 0 :\n";
    }
    else {
      $raddr = $raddr . "                            mask_request_" . int(($i-$bank)/4) . "[" . $j . "] && mask_grant_" . int(($i-$bank)/4) . "[" . $j . "] ? mask_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] :\n";
    }
  }
  if ($i % 2 == 0){  
    for (my $j = 0; $j < $bank; $j++) {
      if ($j == $bank-1) {
        $raddr = $raddr . "                            mask_expand_request_" . int(($i-$bank*3)/2) . "[" . $j . "] && mask_expand_grant_" . int(($i-$bank*3)/2) . "[" . $j . "] & !mask_addr_" . $j . "[" . $sram_addr_bits . "] ? mask_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] : 0;\n";
      }
      else {
        $raddr = $raddr . "                            mask_expand_request_" . int(($i-$bank*3)/2) . "[" . $j . "] && mask_expand_grant_" . int(($i-$bank*3)/2) . "[" . $j . "] & !mask_addr_" . $j . "[" . $sram_addr_bits . "] ? mask_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] :\n";
      }
    }
  }
  else {
    for (my $j = 0; $j < $bank; $j++) {
      if ($j == $bank-1) {
        $raddr = $raddr . "                            mask_expand_request_" . int(($i-$bank*3)/2) . "[" . $j . "] && mask_expand_grant_" . int(($i-$bank*3)/2) . "[" . $j . "] & mask_addr_" . $j . "[" . $sram_addr_bits . "] ? mask_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] : 0;\n";
      }
      else {
        $raddr = $raddr . "                            mask_expand_request_" . int(($i-$bank*3)/2) . "[" . $j . "] && mask_expand_grant_" . int(($i-$bank*3)/2) . "[" . $j . "] & mask_addr_" . $j . "[" . $sram_addr_bits . "] ? mask_addr_" . $j . "[" . ($sram_addr_bits-1) .":0] :\n";
      }
    }
  }
  print $fh "\n";
  print $fh $raddr;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $weight_rresp = "assign weight_rready_" . $i . " = (!expand & (";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $weight_rresp = $weight_rresp . "(weight_request_" . $j . "[" . $i . "] & weight_grant_" . $j . "[" . $i . "])))\n";
    }
    else {
      $weight_rresp = $weight_rresp . "(weight_request_" . $j . "[" . $i . "] & weight_grant_" . $j . "[" . $i . "]) | ";
    }
  }
  $weight_rresp = $weight_rresp . "                      | (expand & (";
  for (my $j = 0; $j < $bank; $j++) {
    $weight_rresp = $weight_rresp . "(weight_expand_weight_request_" . $j . "[" . $i . "] & weight_expand_weight_grant_" . $j . "[" . $i . "]) | ";
  }
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $weight_rresp = $weight_rresp . "(weight_expand_mask_request_" . $j . "[" . $i . "] & weight_expand_mask_grant_" . $j . "[" . $i . "])));\n";
    }
    else {
      $weight_rresp = $weight_rresp . "(weight_expand_mask_request_" . $j . "[" . $i . "] & weight_expand_mask_grant_" . $j . "[" . $i . "]) | ";
    }
  }
  print $fh $weight_rresp;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $mask_rresp = "assign mask_rready_" . $i . " = (!expand & (";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $mask_rresp = $mask_rresp . "(mask_request_" . $j . "[" . $i . "] & mask_grant_" . $j . "[" . $i . "])))\n";
    }
    else {
      $mask_rresp = $mask_rresp . "(mask_request_" . $j . "[" . $i . "] & mask_grant_" . $j . "[" . $i . "]) | ";
    }
  }
  $mask_rresp = $mask_rresp . "                    | (expand & (";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $mask_rresp = $mask_rresp . "(mask_expand_request_" . $j . "[" . $i . "] & mask_expand_grant_" . $j . "[" . $i . "])));\n";
    }
    else {
      $mask_rresp = $mask_rresp . "(mask_expand_request_" . $j . "[" . $i . "] & mask_expand_grant_" . $j . "[" . $i . "]) | ";
    }
  }
  print $fh $mask_rresp;
}


for (my $i = 0; $i < $bank; $i++) {
  my $weight_data = "assign weight_data_" . $i . " = !expand ? weight_request_0_reg[" . $i . "] && weight_grant_0_reg[" . $i . "] ? rdata_0 : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $weight_data = $weight_data . "                                 weight_request_" . $j . "_reg[" . $i . "] && weight_grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " : 0 :\n";
    }
    else {
      $weight_data = $weight_data . "                                 weight_request_" . $j . "_reg[" . $i . "] && weight_grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " :\n";
    }
  }
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $weight_data = $weight_data . "                                 weight_expand_weight_request_" . $j . "_reg[" . $i . "] && weight_expand_weight_grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " : \n";
    }
    else {
      $weight_data = $weight_data . "                                 weight_expand_weight_request_" . $j . "_reg[" . $i . "] && weight_expand_weight_grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " :\n";
    }
  }
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $weight_data = $weight_data . "                                 weight_expand_mask_request_" . $j . "_reg[" . $i . "] && weight_expand_mask_grant_" . $j . "_reg[" . $i . "] ? {rdata_" . ($j*2+$bank+1) . ", rdata_" . ($j*2+$bank) . "} : 0;\n";
    }
    else {
      $weight_data = $weight_data . "                                 weight_expand_mask_request_" . $j . "_reg[" . $i . "] && weight_expand_mask_grant_" . $j . "_reg[" . $i . "] ? {rdata_" . ($j*2+$bank+1) . ", rdata_" . ($j*2+$bank) . "} :\n";
    }
  }
  print $fh "\n";
  print $fh $weight_data;
}


for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg mask_expand_sel_" . $i . "_reg;\n";
}


for (my $i = 0; $i < $bank; $i++) {
  my $mask_data = "assign mask_data_" . $i . " = !expand ? mask_request_0_reg[" . $i . "] && mask_grant_0_reg[" . $i . "] ? {rdata_" . int($bank+3) . ", rdata_" . int($bank+2) . ", rdata_" . int($bank+1) . ", rdata_" . int($bank) . "} : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $mask_data = $mask_data . "                               mask_request_" . $j . "_reg[" . $i . "] && mask_grant_" . $j . "_reg[" . $i . "] ? {rdata_" . int($j*4+$bank+3) . ", rdata_" . int($j*4+$bank+2) . ", rdata_" . int($j*4+$bank+1) . ", rdata_" . int($j*4+$bank) . "} : 0 :\n";
    }
    else {
      $mask_data = $mask_data . "                               mask_request_" . $j . "_reg[" . $i . "] && mask_grant_" . $j . "_reg[" . $i . "] ? {rdata_" . int($j*4+$bank+3) . ", rdata_" . int($j*4+$bank+2) . ", rdata_" . int($j*4+$bank+1) . ", rdata_" . int($j*4+$bank) . "} :\n";
    }
  }
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $mask_data = $mask_data . "                            mask_expand_request_" .  $j . "_reg[" . $i . "] && mask_expand_grant_" . $j . "_reg[" . $i . "] ? !mask_expand_sel_" . $j ."_reg ? {768'd0, rdata_" . int($j*2+$bank*3) . "} : {768'd0, rdata_" . int($j*2+1+$bank*3) . "} : 0;\n";
    }
    else {
      $mask_data = $mask_data . "                            mask_expand_request_" .  $j . "_reg[" . $i . "] && mask_expand_grant_" . $j . "_reg[" . $i . "] ? !mask_expand_sel_" . $j ."_reg ? {768'd0, rdata_" . int($j*2+$bank*3) . "} : {768'd0, rdata_" . int($j*2+1+$bank*3) . "} :\n";
    }
  }
  
  print $fh "\n";
  print $fh $mask_data;
}
print $fh "\n";


print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_request_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_grant_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_expand_weight_request_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_expand_weight_grant_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_expand_mask_request_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_expand_mask_grant_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_request_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_grant_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_expand_sel_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_expand_request_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_expand_grant_" . $i . "_reg <= 0;\n";
}
print $fh "  end\n";
print $fh "  else begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_request_" . $i . "_reg <= weight_request_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_grant_" . $i . "_reg <= weight_grant_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_expand_weight_request_" . $i . "_reg <= weight_expand_weight_request_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_expand_weight_grant_" . $i . "_reg <= weight_expand_weight_grant_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_expand_mask_request_" . $i . "_reg <= weight_expand_mask_request_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    weight_expand_mask_grant_" . $i . "_reg <= weight_expand_mask_grant_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_request_" . $i . "_reg <= mask_request_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_grant_" . $i . "_reg <= mask_grant_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_expand_sel_" . $i . "_reg <= mask_addr_" . $i . "[9];\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_expand_request_" . $i . "_reg <= mask_expand_request_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    mask_expand_grant_" . $i . "_reg <= mask_expand_grant_" . $i . ";\n";
}
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "endmodule\n";

print "==== INFO: Done Generate $file ====\n";
