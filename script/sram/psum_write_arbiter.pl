#!/usr/bin/perl
use strict; 
use Getopt::Long;

my $help = "";
my $file = "";
my $width = 2048;
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

print "==== INFO: Generating psum_write_arbiter ==== \n";
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

print $fh "module psum_write_arbiter(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  pea_wvalid_" . $i . ", pea_waddr_" . $i . ", pea_wdata_" . $i . ", pea_wready_" . $i . ",\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  pea_wvalid_" . $i . ", vcu_waddr_" . $i . ", vcu_wdata_" . $i . ", vcu_wready_" . $i . ",\n";
}
print $fh "\n";
print $fh "  load_wready, load_waddr, load_wdata, load_wready,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank-1) {
    print $fh "  wen_" . $i . ", waddr_" . $i . ", wdata_" . $i . "\n";
  }
  else {
    print $fh "  wen_" . $i . ", waddr_" . $i . ", wdata_" . $i . ",\n";
  }
}
print $fh ");\n";
print $fh "\n";
print $fh "input wire clk;\n";
print $fh "input wire rst_n;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire pea_wvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] pea_waddr_" . $i . ";\n";
  print $fh "input wire [", ($width - 1), ":0] pea_wdata_" . $i . ";\n";
  print $fh "output wire pea_wready_" . $i . ";\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire pea_wvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] vcu_waddr_" . $i . ";\n";
  print $fh "input wire [", ($width - 1), ":0] vcu_wdata_" . $i . ";\n";
  print $fh "output wire vcu_wready_" . $i . ";\n";
  print $fh "\n";
}
print $fh "input wire load_wready;\n";
print $fh "input wire [", $sram_addr_bits_all-1, ":0] load_waddr;\n";
print $fh "input wire [", ($width - 1), ":0] load_wdata;\n";
print $fh "output wire load_wready;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "output wire wen_" . $i . ";\n";
  print $fh "output wire [", $sram_addr_bits-1, ":0] waddr_" . $i . ";\n";
  print $fh "output wire [", $width-1, ":0] wdata_" . $i . ";\n";
  print $fh "\n";
}


my $highaddr_bits = log($bank*4) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($highaddr_bits-1) . ":0] pea_waddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign pea_waddr_high_" . $i . " = pea_waddr_" . $i . "[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($highaddr_bits-1) . ":0] vcu_waddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign vcu_waddr_high_" . $i . " = vcu_waddr_" . $i . "[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
}
print $fh "\n";


print $fh "wire [" . ($highaddr_bits-1) . ":0] load_waddr_high;\n";
print $fh "\n";
print $fh "assign load_waddr_high = load_waddr[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank*2) . ":0] request_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank*2) . ":0] request_" . $i . "_reg;\n";
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $request = "assign request_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == $bank-1) {
      $request = $request . "pea_wvalid_" . $j . " && (vcu_waddr_high_" . $j . "[". ($highaddr_bits-3) . ":0] == " . $i . "), \n";
    }
    else {
      $request = $request . "                    pea_wvalid_" . $j . " && (vcu_waddr_high_" . $j . "[". ($highaddr_bits-3) . ":0] == " . $i . "), \n";
    }
  }
  for (my $j = $bank-1; $j >= 0; $j--) {
    $request = $request . "                    pea_wvalid_" . $j . " && (pea_waddr_high_" . $j . "[". ($highaddr_bits-3) . ":0] == " . $i . "), \n";
  }
  $request = $request . "                    load_wready && (load_waddr_high[". ($highaddr_bits-3) . ":0] == " . $i . ")};\n";
  print $fh $request;
  print $fh "\n";
}


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank*2) . ":0] grant_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank*2) . ":0] grant_" . $i . "_reg;\n";
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $grant = "assign grant_" . $i . " = request_" . $i . "[0] ? " . ($bank*2+1) . "'b" . "0" x ($bank*2) . "1" . " : \n";
  $grant = $grant . "                 request_" . $i . "[" . ($i+1) . "] ? " . ($bank*2+1) . "'b" . "0" x ($bank*2-1-$i) . "1" . "0" x ($i+1) . " :\n";
  for (my $j = 1; $j < $bank+1; $j++) {
    if ($j != $i+1 && $j == $bank) {
      $grant = $grant . "                 request_" . $i . "[" . $j . "] ? " . ($bank*2+1) . "'b" . "0" x ($bank*2-$j) . "1" . "0" x $j . " : \n";
    }
    if ($j != $i+1 && $j != $bank) {
      $grant = $grant . "                 request_" . $i . "[" . $j . "] ? " . ($bank*2+1) . "'b" . "0" x ($bank*2-$j) . "1" . "0" x $j . " : \n";
    }
  }
  $grant = $grant . "                 request_" . $i . "[" . ($i+$bank+1) . "] ? " . ($bank*2+1) . "'b" . "0" x ($bank*2-$i-($bank+1)) . "1" . "0" x ($i+$bank+1) . " :";
  if ($i != 0) {
    $grant = $grant . " \n";
  }
  for (my $j = $bank+1; $j < $bank*2+1; $j++) {
    if (($j != $i+$bank+1 && $j == $bank*2) || ($j == $bank*2-1 && $i == $bank-1)) {
      $grant = $grant . "                 request_" . $i . "[" . $j . "] ? " . ($bank*2+1) . "'b" . "0" x ($bank*2-$j) . "1" . "0" x $j . " : 0;\n";
    }
    elsif ($j != $i+$bank+1 && $j != $bank*2) {
      $grant = $grant . "                 request_" . $i . "[" . $j . "] ? " . ($bank*2+1) . "'b" . "0" x ($bank*2-$j) . "1" . "0" x $j . " :";
    }
    if ($j == $bank*2) {
      $grant = $grant . "\n";
    }
    elsif ($j != $i+$bank+1 && $j != $bank*2) {
      $grant = $grant . "\n";
    }
    elsif ($j == $bank+1) {
      $grant = $grant . "\n";
    }
  }
  print $fh $grant;
}

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($width-1) . ":0] pea_wdata_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($width-1) . ":0] vcu_wdata_" . $i . "_reg;\n";
}
print $fh "\n";
print $fh "reg [" . ($width-1) . ":0] load_wdata_reg;\n";
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($sram_addr_bits_all-1) . ":0] pea_waddr_" . $i . "_reg;\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($sram_addr_bits_all-1) . ":0] vcu_waddr_" . $i . "_reg;\n";
}
print $fh "\n";
print $fh "reg [" . ($sram_addr_bits_all-1) . ":0] load_waddr_reg;\n";

for (my $i = 0; $i < $bank; $i++) {
  my $wen = "assign wen_" . $i . " = ";
  $wen = $wen . "|request_" . $i . "_reg;\n";
  print $fh $wen;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $waddr = "assign waddr_" . $i . " = (request_" . $i . "_reg[0] && grant_" . $i . "_reg[0]) ? load_waddr_reg" . "[" . ($sram_addr_bits-1) . ":0] : \n"; 
  for (my $j = 1; $j < $bank+1; $j++) {
    $waddr = $waddr . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? pea_waddr_" . ($j-1) . "_reg[" . ($sram_addr_bits-1) . ":0] : \n";
  }
  for (my $j = $bank+1; $j < $bank*2+1; $j++) {
    if ($j == $bank*2) {
      $waddr = $waddr . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? vcu_waddr_" . ($j-1-$bank) . "_reg[" . ($sram_addr_bits-1) . ":0] : 0;\n";
    }
    else {
      $waddr = $waddr . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? vcu_waddr_" . ($j-1-$bank) . "_reg[" . ($sram_addr_bits-1) . ":0] : \n";
    }
  }
  print $fh $waddr;
  print $fh "\n";
}


my $load_wready = "assign load_wready = (";
for (my $j = 0; $j < $bank; $j++) {
  if ($j == $bank-1) {
    $load_wready = $load_wready . "                     (request_" . $j . "[0] & grant_" . $j . "[0]));";
  }
  elsif ($j == 0) {
    $load_wready = $load_wready . "(request_" . $j . "[0] & grant_" . $j . "[0]) | \n";
  }
  else {
    $load_wready = $load_wready . "                     (request_" . $j . "[0] & grant_" . $j . "[0]) | \n";
  }
}
print $fh $load_wready;
print $fh "\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $wresp = "assign pea_wready_" . $i . " = (";
  for (my $j = 1; $j < $bank+1; $j++) {
    if ($j == $bank) {
      $wresp = $wresp . "                      (request_" . ($j-1) . "[" . ($i+1) . "] & grant_" . ($j-1) . "[" . ($i+1) . "]));";
    }
    elsif ($j == 1) {
      $wresp = $wresp . "(request_" . ($j-1) . "[" . ($i+1) . "] & grant_" . ($j-1) . "[" . ($i+1) . "]) | \n";
    }
    else {
      $wresp = $wresp . "                      (request_" . ($j-1) . "[" . ($i+1) . "] & grant_" . ($j-1) . "[" . ($i+1) . "]) | \n";
    }
  }
  print $fh $wresp;
  print $fh "\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  my $wresp = "assign vcu_wready_" . $i . " = (";
  for (my $j = $bank+1; $j < $bank*2+1; $j++) {
    if ($j == $bank*2) {
      $wresp = $wresp . "                      (request_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "] & grant_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "]));";
    }
    elsif ($j == 1+$bank) {
      $wresp = $wresp . "(request_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "] & grant_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "]) | \n";
    }
    else {
      $wresp = $wresp . "                      (request_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "] & grant_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "]) | \n";
    }
  }
  print $fh $wresp;
  print $fh "\n";
  print $fh "\n";
}


for (my $i = 0; $i < $bank; $i++) {
  my $wdata = "assign wdata_" . $i . " = ";
  $wdata = $wdata . "(request_" . $i . "_reg[0] && grant_" . $i . "_reg[0]) ? load_wdata_reg : \n";
  for (my $j = 1; $j < $bank+1; $j++) {
    if ($j == $bank*2) {
      $wdata = $wdata . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? pea_wdata_" . ($j-1) . "_reg : 0;\n";
    }
    else {
      $wdata = $wdata . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? pea_wdata_" . ($j-1) . "_reg : \n";
    }
  }
  for (my $j = $bank+1; $j < $bank*2+1; $j++) {
    if ($j == $bank*2) {
      $wdata = $wdata . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? vcu_wdata_" . ($j-$bank-1) . "_reg : 0;\n";
    }
    else {
      $wdata = $wdata . "                 (request_" . $i . "_reg[" . $j . "] && grant_" . $i . "_reg[" . $j . "]) ? vcu_wdata_" . ($j-$bank-1) . "_reg : \n";
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
  print $fh "    pea_wdata_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    vcu_wdata_" . $i . "_reg <= 0;\n";
}
print $fh "    load_wdata_reg <= 0;\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    pea_waddr_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    vcu_waddr_" . $i . "_reg <= 0;\n";
}
print $fh "    load_waddr_reg <= 0;\n";
print $fh "  end\n";
print $fh "  else begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    request_" . $i . "_reg <= request_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    grant_" . $i . "_reg <= grant_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    pea_wdata_" . $i . "_reg <= pea_wdata_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    vcu_wdata_" . $i . "_reg <= vcu_wdata_" . $i . ";\n";
}
print $fh "    load_wdata_reg <= load_wdata;\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    pea_waddr_" . $i . "_reg <= pea_waddr_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    vcu_waddr_" . $i . "_reg <= vcu_waddr_" . $i . ";\n";
}
print $fh "    load_waddr_reg <= load_waddr;\n";
print $fh "  end\n";
print $fh "end\n";
print $fh "\n";
print $fh "endmodule\n";

print "==== INFO: Done Generate $file ====\n";
