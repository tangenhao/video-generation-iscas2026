#!/usr/bin/perl
use strict; 
use Getopt::Long;

my $help = "";
my $file = "";
my $width = 512;
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

print "==== INFO: Generating ofmap_arbiter ==== \n";
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

print $fh "module ofmap_arbiter(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  wvalid_" . $i . ", addr_" . $i . ", data_" . $i . ", wready_" . $i . ",\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank - 1) {
    print $fh "  wen_" . $i . ", waddr_" . $i . ", wdata_" . $i . "\n";
  }
  else{
    print $fh "  wen_" . $i . ", waddr_" . $i . ", wdata_" . $i . ",\n";
  }
}
print $fh ");\n";
print $fh "\n";
print $fh "input wire clk;\n";
print $fh "input wire rst_n;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire wvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] addr_" . $i . ";\n";
  print $fh "input wire [", ($width - 1), ":0] data_" . $i . ";\n";
  print $fh "output wire wready_" . $i . ";\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "output wire wen_" . $i . ";\n";
  print $fh "output wire [", $sram_addr_bits-1, ":0] waddr_" . $i . ";\n";
  print $fh "output wire [", $width-1, ":0] wdata_" . $i . ";\n";
  print $fh "\n";
}


my $highaddr_bits = log($bank*2) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($highaddr_bits-1) . ":0] waddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign waddr_high_" . $i . " = waddr_" . $i . "[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
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
    if ($j == $bank-1) {
      $request = $request . "wvalid_" . $j . " && (waddr_high_" . $j . "[". ($highaddr_bits-2) . ":0] == " . $i . "),\n";
    }
    elsif ($j == 0) {
      $request = $request . "                    wvalid_" . $j . " && (waddr_high_" . $j . "[". ($highaddr_bits-2) . ":0] == " . $i . ")};\n";
    }
    else {
      $request = $request . "                    wvalid_" . $j . " && (waddr_high_" . $j . "[". ($highaddr_bits-2) . ":0] == " . $i . "), \n";
    }
  }
  print $fh $request;
  print $fh "\n";
}


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank) . ":0] grant_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank) . ":0] grant_" . $i . "_reg;\n";
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
  print $fh "reg [" . ($sram_addr_bits-1) . ":0] addr_" . $i . "_reg;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($width-1) . ":0] wdata_" . $i . "_reg;\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $wen = "assign wen_" . $i . " = ";
  $wen = $wen . "|request_" . $i . "_reg;\n";
  print $fh $wen;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $waddr = "assign waddr_" . $i . " = (request_" . $i . "_reg[0] && grant_" . $i . "_reg[0]) ? addr_0_reg" . "[" . ($sram_addr_bits-1) . ":0] : \n"; 
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $waddr = $waddr . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? addr_" . $j . "_reg[" . ($sram_addr_bits-1) . ":0] : 0;\n";
    }
    else {
      $waddr = $waddr . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? addr_" . $j . "_reg[" . ($sram_addr_bits-1) . ":0] : \n";
    } 
  }
  print $fh $waddr;
  print $fh "\n";
}


for (my $i = 0; $i < $bank; $i++) {
  my $wresp = "assign wready_" . $i . " = (";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $wresp = $wresp . "                  (request_" . ($j) . "[" . ($i) . "] & grant_" . ($j) . "[" . ($i) . "]));";
    }
    elsif ($j == 0) {
      $wresp = $wresp . "(request_" . ($j) . "[" . ($i) . "] & grant_" . ($j) . "[" . ($i) . "]) | \n";
    }
    else {
      $wresp = $wresp . "                  (request_" . ($j) . "[" . ($i) . "] & grant_" . ($j) . "[" . ($i) . "]) | \n";
    }
  }
  print $fh $wresp;
  print $fh "\n";
  print $fh "\n";
}


for (my $i = 0; $i < $bank; $i++) {
  my $wdata = "assign wdata_" . $i . " = ";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $wdata = $wdata . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? wdata_" . $j . "_reg : 0;\n";
    }
    elsif ($j == 0) {
      $wdata = $wdata . "(request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? wdata_" . $j . "_reg : \n";
    }
    else {
      $wdata = $wdata . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? wdata_" . $j . "_reg : \n";
    }
  }
  print $fh $wdata;
  print $fh "\n";
}


print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    request_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    grant_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    wdata_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    addr_" . $i . "_reg <= 0;\n";
}
print $fh "  end\n";
print $fh "  else begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    request_" . $i . "_reg <= request_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    grant_" . $i . "_reg <= grant_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    wdata_" . $i . "_reg <= data_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    addr_" . $i . "_reg <= addr_" . $i . ";\n";
}
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "endmodule\n";

print "==== INFO: Done Generate $file ====\n";

