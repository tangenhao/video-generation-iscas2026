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

print "==== INFO: Generating psum_read_arbiter ==== \n";
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

print $fh "module psum_read_arbiter(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  pea_rvalid_" . $i . ", pea_raddr_" . $i . ", pea_rdata_" . $i . ", pea_rready_" . $i . ",\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  vcu_rvalid_" . $i . ", vcu_raddr_" . $i . ", vcu_rdata_" . $i . ", vcu_rready_" . $i . ",\n";
}
print $fh "\n";
print $fh "  store_rvalid, store_raddr, store_rdata, store_rready,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank - 1) {
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
  print $fh "input wire pea_rvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] pea_raddr_" . $i . ";\n";
  print $fh "output wire [", ($width - 1), ":0] pea_rdata_" . $i . ";\n";
  print $fh "output wire pea_rready_" . $i . ";\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire vcu_rvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] vcu_raddr_" . $i . ";\n";
  print $fh "output wire [", ($width - 1), ":0] vcu_rdata_" . $i . ";\n";
  print $fh "output wire vcu_rready_" . $i . ";\n";
  print $fh "\n";
}
print $fh "input wire store_rvalid;\n";
print $fh "input wire [", $sram_addr_bits_all-1, ":0] store_raddr;\n";
print $fh "output wire [", ($width - 1), ":0] store_rdata;\n";
print $fh "output wire store_rready;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "output wire ren_" . $i . ";\n";
  print $fh "output wire [", $sram_addr_bits-1, ":0] raddr_" . $i . ";\n";
  print $fh "input wire [", $width-1, ":0] rdata_" . $i . ";\n";
  print $fh "\n";
}


my $highaddr_bits = log($bank*4) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($highaddr_bits-1) . ":0] pea_raddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign pea_raddr_high_" . $i . " = pea_raddr_" . $i . "[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($highaddr_bits-1) . ":0] vcu_raddr_high_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign vcu_raddr_high_" . $i . " = vcu_raddr_" . $i . "[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
}
print $fh "\n";


print $fh "wire [" . ($highaddr_bits-1) . ":0] store_raddr_high;\n";
print $fh "\n";
print $fh "assign store_raddr_high = store_raddr[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
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
      $request = $request . "vcu_rvalid_" . $j . " && (vcu_raddr_high_" . $j . "[". ($highaddr_bits-3) . ":0] == " . $i . "), \n";
    }
    else {
      $request = $request . "                    vcu_rvalid_" . $j . " && (vcu_raddr_high_" . $j . "[". ($highaddr_bits-3) . ":0] == " . $i . "), \n";
    }
  }
  for (my $j = $bank-1; $j >= 0; $j--) {
    $request = $request . "                    pea_rvalid_" . $j . " && (pea_raddr_high_" . $j . "[". ($highaddr_bits-3) . ":0] == " . $i . "), \n";
  }
  $request = $request . "                    store_rvalid && (store_raddr_high[". ($highaddr_bits-3) . ":0] == " . $i . ")};\n";
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
  my $ren = "assign ren_" . $i . " = ";
  $ren = $ren . "|request_" . $i . ";\n";
  print $fh $ren;
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $raddr = "assign raddr_" . $i . " = (request_" . $i . "[0] && grant_" . $i . "[0]) ? store_raddr" . "[" . ($sram_addr_bits-1) . ":0] : \n"; 
  for (my $j = 0; $j < $bank; $j++) {
    $raddr = $raddr . "                 (request_" . $i . "[" . ($j+1) . "] && grant_" . $i . "[" . ($j+1) . "]) ? pea_raddr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : \n";
  }
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $raddr = $raddr . "                 (request_" . $i . "[" . ($j+$bank+1) . "] && grant_" . $i . "[" . ($j+$bank+1) . "]) ? vcu_raddr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : 0;\n";
    }
    else {
      $raddr = $raddr . "                 (request_" . $i . "[" . ($j+$bank+1) . "] && grant_" . $i . "[" . ($j+$bank+1) . "]) ? vcu_raddr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : \n";
    } 
  }
  print $fh $raddr;
  print $fh "\n";
}


my $store_rready = "assign store_rready = (";
for (my $j = 0; $j < $bank; $j++) {
  if ($j == $bank-1) {
    $store_rready = $store_rready . "                      (request_" . $j . "[0] & grant_" . $j . "[0]));";
  }
  elsif ($j == 0) {
    $store_rready = $store_rready . "(request_" . $j . "[0] & grant_" . $j . "[0]) | \n";
  }
  else {
    $store_rready = $store_rready . "                      (request_" . $j . "[0] & grant_" . $j . "[0]) | \n";
  }
}
print $fh $store_rready;
print $fh "\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  my $rresp = "assign pea_rready_" . $i . " = (";
  for (my $j = 1; $j < $bank+1; $j++) {
    if ($j == $bank) {
      $rresp = $rresp . "                      (request_" . ($j-1) . "[" . ($i+1) . "] & grant_" . ($j-1) . "[" . ($i+1) . "]));";
    }
    elsif ($j == 1) {
      $rresp = $rresp . "(request_" . ($j-1) . "[" . ($i+1) . "] & grant_" . ($j-1) . "[" . ($i+1) . "]) | \n";
    }
    else {
      $rresp = $rresp . "                      (request_" . ($j-1) . "[" . ($i+1) . "] & grant_" . ($j-1) . "[" . ($i+1) . "]) | \n";
    }
  }
  print $fh $rresp;
  print $fh "\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  my $rresp = "assign vcu_rready_" . $i . " = (";
  for (my $j = $bank+1; $j < $bank*2+1; $j++) {
    if ($j == $bank*2) {
      $rresp = $rresp . "                      (request_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "] & grant_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "]));";
    }
    elsif ($j == 1+$bank) {
      $rresp = $rresp . "(request_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "] & grant_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "]) | \n";
    }
    else {
      $rresp = $rresp . "                      (request_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "] & grant_" . ($j-1-$bank) . "[" . ($i+1+$bank) . "]) | \n";
    }
  }
  print $fh $rresp;
  print $fh "\n";
  print $fh "\n";
}


my $data = "assign store_data = request_0_reg[0] && grant_0_reg[0] ? rdata_0 : \n";
for (my $j = 1; $j < $bank; $j++) {
  if ($j == $bank-1) {
    $data = $data . "                    request_" . $j . "_reg[0] && grant_" . $j . "_reg[0] ? rdata_" . $j . " : 0;\n";
  }    
  else {    
    $data = $data . "                    request_" . $j . "_reg[0] && grant_" . $j . "_reg[0] ? rdata_" . $j . " : \n";
  }
}
print $fh $data;
print $fh "\n";

for (my $i = 1; $i < $bank+1; $i++) {
  my $data = "assign pea_rdata_" . ($i-1) . " = request_0_reg[" . $i . "] && grant_0_reg[" . $i . "] ? rdata_0 : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $data = $data . "                     request_" . $j . "_reg[" . $i . "] && grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " : 0;\n";
    }     
    else {     
      $data = $data . "                     request_" . $j . "_reg[" . $i . "] && grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " : \n";
    }
  }
  print $fh $data;
  print $fh "\n";
}

for (my $i = $bank+1; $i < $bank*2+1; $i++) {
  my $data = "assign vcu_rdata_" . ($i-1-$bank) . " = request_0_reg[" . $i . "] && grant_0_reg[" . $i . "] ? rdata_0 : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $data = $data . "                     request_" . $j . "_reg[" . $i . "] && grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " : 0;\n";
    }     
    else {     
      $data = $data . "                     request_" . $j . "_reg[" . $i . "] && grant_" . $j . "_reg[" . $i . "] ? rdata_" . $j . " : \n";
    }
  }
  print $fh $data;
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
