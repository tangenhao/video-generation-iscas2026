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

print "==== INFO: Generating ifmap_arbiter ==== \n";
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
my $sparse_x4_enable = $bank % 4 == 0 ? 1 : 0;
my $sparse_x8_enable = $bank % 8 == 0 ? 1 : 0;

print $fh "module ifmap_arbiter(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  rvalid_" . $i . ", addr_" . $i . ", data_" . $i . ", rready_" . $i . ", rsparse_" . $i . ",\n";
}
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
  print $fh "input wire rvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] addr_" . $i . ";\n";
  print $fh "output wire [", ($width * 8 - 1), ":0] data_" . $i . ";\n";
  print $fh "output wire rready_" . $i . ";\n";
  print $fh "input wire [1:0] rsparse_" . $i . ";\n";
  print $fh "\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "output wire ren_" . $i . ";\n";
  print $fh "output wire [", $sram_addr_bits-1, ":0] raddr_" . $i . ";\n";
  print $fh "input wire [", $width-1, ":0] rdata_" . $i . ";\n";
  print $fh "\n";
}
print $fh "wire dense;\n";

print $fh "wire sparse_x2;\n";
if ($sparse_x4_enable) {
  print $fh "wire sparse_x4;\n";
}
if ($sparse_x8_enable) {
  print $fh "wire sparse_x8;\n";
}
print $fh "\n";

my $dense = "assign dense = ";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank-1) {
    $dense = $dense . "(rsparse_" . $i . " == 0);\n";
  }
  else {
    $dense = $dense . "(rsparse_" . $i . " == 0) || ";
  }
}
print $fh $dense;

my $sparse_x2 = "assign sparse_x2 = ";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank-1) {
    $sparse_x2 = $sparse_x2 . "(rsparse_" . $i . " == 1);\n";
  }
  else {
    $sparse_x2 = $sparse_x2 . "(rsparse_" . $i . " == 1) || ";
  }
}
print $fh $sparse_x2;

if ($sparse_x4_enable) {
  my $sparse_x4 = "assign sparse_x4 = ";
  for (my $i = 0; $i < $bank; $i++) {
    if ($i == $bank-1) {
      $sparse_x4 = $sparse_x4 . "(rsparse_" . $i . " == 2);\n";
    }
    else {
      $sparse_x4 = $sparse_x4 . "(rsparse_" . $i . " == 2) || ";
    }
  }
  print $fh $sparse_x4;
}

if ($sparse_x8_enable) {
  my $sparse_x8 = "assign sparse_x8 = ";
  for (my $i = 0; $i < $bank; $i++) {
    if ($i == $bank-1) {
      $sparse_x8 = $sparse_x8 . "(rsparse_" . $i . " == 3);\n";
    }
    else {
      $sparse_x8 = $sparse_x8 . "(rsparse_" . $i . " == 3) || ";
    }
  }
  print $fh $sparse_x8;
}

print $fh "\n";
my $highaddr_bits = log($bank*2) / log(2);
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($highaddr_bits-1) . ":0] raddr_high_dense_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign raddr_high_dense_" . $i . " = addr_" . $i . "[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] request_dense_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] request_dense_" . $i . "_reg;\n";
}
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  my $request_dense = "assign request_dense_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == 0) {
      $request_dense = $request_dense . "rvalid_" . $j . " && (raddr_high_dense_" . $j . "[". ($highaddr_bits-2) . ":0] == " . $i . ")};\n";
    }
    else {
      $request_dense = $request_dense . "rvalid_" . $j . " && (raddr_high_dense_" . $j . "[". ($highaddr_bits-2) . ":0] == " . $i . "), ";
    }
  }
  print $fh $request_dense;
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] grant_dense_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] grant_dense_" . $i . "_reg;\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $grant_dense = "assign grant_dense_" . $i . " = request_dense_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j != $i && (($j == $bank-2 && $i == $bank-1) || ($j == $bank-1 && $i != $bank-1))) {
      $grant_dense = $grant_dense . "                       request_dense_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " :";
    }
    elsif ($j != $i && $j != $bank-1) {
      $grant_dense = $grant_dense . "                       request_dense_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " : \n";
    }
  }
  print $fh $grant_dense;
  print $fh " 0;\n";
  print $fh "\n";
}

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire [" . ($highaddr_bits-2) . ":0] raddr_high_x2_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "assign raddr_high_x2_" . $i . " = addr_" . $i . "[" . ($sram_addr_bits_all-2) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank / 2; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] request_x2_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank / 2; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] request_x2_" . $i . "_reg;\n";
}
print $fh "\n";


for (my $i = 0; $i < $bank / 2; $i++) {
  my $request_x2 = "assign request_x2_" . $i . " = {";
  for (my $j = $bank-1; $j >= 0; $j--) {
    if ($j == 0) {
      if ($highaddr_bits-3 > 0) {
        $request_x2 = $request_x2 . "rvalid_" . $j . " && (raddr_high_x2_" . $j . "[". ($highaddr_bits-3) . ":0] == " . $i . ")};\n";
      }
      else {
        $request_x2 = $request_x2 . "rvalid_" . $j . " && (raddr_high_x2_" . $j . "[0] == " . $i . ")};\n";
      }
    }
    else {
      if ($highaddr_bits-3 > 0) {
        $request_x2 = $request_x2 . "rvalid_" . $j . " && (raddr_high_x2_" . $j . "[". ($highaddr_bits-3) . ":0] == " . $i . "), ";
      }
      else {
        $request_x2 = $request_x2 . "rvalid_" . $j . " && (raddr_high_x2_" . $j . "[0] == " . $i . "), ";
      }
    }
  }
  print $fh $request_x2;
}
print $fh "\n";

for (my $i = 0; $i < $bank / 2; $i++) {
  print $fh "wire [" . ($bank-1) . ":0] grant_x2_" . $i . ";\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank / 2; $i++) {
  print $fh "reg [" . ($bank-1) . ":0] grant_x2_" . $i . "_reg;\n";
}
print $fh "\n";

for (my $i = 0; $i < $bank / 2; $i++) {
  my $grant_x2 = "assign grant_x2_" . $i . " = request_x2_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $grant_x2 = $grant_x2 . "                    request_x2_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " : 0;\n";
    }
    if ($j != $i && $j != $bank-1) {
      $grant_x2 = $grant_x2 . "                    request_x2_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " : \n";
    }
  }
  print $fh $grant_x2;
  print $fh "\n";
}

if ($sparse_x4_enable) {
  for (my $i = 0; $i < $bank; $i++) {
    if ($highaddr_bits-3 > 0) {
      print $fh "wire [" . ($highaddr_bits-3) . ":0] raddr_high_x4_" . $i . ";\n";
    }
    else {
      print $fh "wire raddr_high_x4_" . $i . ";\n";
    }
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank; $i++) {
    if ($highaddr_bits-3 > 0) {
      print $fh "assign raddr_high_x4_" . $i . " = addr_" . $i . "[" . ($sram_addr_bits_all-3) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
    }
    else {
      print $fh "assign raddr_high_x4_" . $i . " = addr_" . $i . "[" . ($sram_addr_bits_all-3) . "];\n";
    }
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 4; $i++) {
    print $fh "wire [" . ($bank-1) . ":0] request_x4_" . $i . ";\n";
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 4; $i++) {
    print $fh "reg [" . ($bank-1) . ":0] request_x4_" . $i . "_reg;\n";
  }
  print $fh "\n";


  for (my $i = 0; $i < $bank / 4; $i++) {
    my $request_x4 = "assign request_x4_" . $i . " = {";
    for (my $j = $bank-1; $j >= 0; $j--) {
      if ($j == 0) {
        if ($highaddr_bits-4 > 0) {
          $request_x4 = $request_x4 . "rvalid_" . $j . " && (raddr_high_x4_" . $j . "[". ($highaddr_bits-4) . ":0] == " . $i . ")};\n";
        }
        elsif ($highaddr_bits-4 == 0) {
          $request_x4 = $request_x4 . "rvalid_" . $j . " && (raddr_high_x4_" . $j . " == " . $i . ")};\n";
        }
        else {
          $request_x4 = $request_x4 . "rvalid_" . $j . "};\n";
        }
      }
      else {
        if ($highaddr_bits-4 > 0) {
          $request_x4 = $request_x4 . "rvalid_" . $j . " && (raddr_high_x4_" . $j . "[". ($highaddr_bits-4) . ":0] == " . $i . "), ";
        }
        elsif ($highaddr_bits-4 == 0) {
          $request_x4 = $request_x4 . "rvalid_" . $j . " && (raddr_high_x4_" . $j . "[0] == " . $i . "), ";
        }
        else {
          $request_x4 = $request_x4 . "rvalid_" . $j . ", ";
        }
      }
    }
    print $fh $request_x4;
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 4; $i++) {
    print $fh "wire [" . ($bank-1) . ":0] grant_x4_" . $i . ";\n";
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 4; $i++) {
    print $fh "reg [" . ($bank-1) . ":0] grant_x4_" . $i . "_reg;\n";
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 4; $i++) {
    my $grant_x4 = "assign grant_x4_" . $i . " = request_x4_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
    for (my $j = 0; $j < $bank; $j++) {
      if ($j == $bank-1) {
        $grant_x4 = $grant_x4 . "                    request_x4_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " : 0;\n";
      }
      if ($j != $i && $j != $bank-1) {
        $grant_x4 = $grant_x4 . "                    request_x4_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " : \n";
      }
    }
    print $fh $grant_x4;
    print $fh "\n";
  }
}

if ($sparse_x8_enable) {
  for (my $i = 0; $i < $bank; $i++) {
    if ($highaddr_bits-4 > 0) {
      print $fh "wire [" . ($highaddr_bits-4) . ":0] raddr_high_x8_" . $i . ";\n";
    }
    else {
      print $fh "wire raddr_high_x8_" . $i . ";\n";
    }
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank; $i++) {
    if ($highaddr_bits-4 > 0) {
      print $fh "assign raddr_high_x8_" . $i . " = addr_" . $i . "[" . ($sram_addr_bits_all-4) . ":" . ($sram_addr_bits_all-$highaddr_bits) . "];\n";
    }
    else {
      print $fh "assign raddr_high_x8_" . $i . " = addr_" . $i . "[" . ($sram_addr_bits_all-4) . "];\n";
    }
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 8; $i++) {
    print $fh "wire [" . ($bank-1) . ":0] request_x8_" . $i . ";\n";
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 8; $i++) {
    print $fh "reg [" . ($bank-1) . ":0] request_x8_" . $i . "_reg;\n";
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 8; $i++) {
    my $request_x8 = "assign request_x8_" . $i . " = {";
    for (my $j = $bank-1; $j >= 0; $j--) {
      if ($j == 0) {
        if ($highaddr_bits-5 > 0) {
          $request_x8 = $request_x8 . "rvalid_" . $j . " && (raddr_high_x8_" . $j . "[". ($highaddr_bits-5) . ":0] == " . $i . ")};\n";
        }
        elsif ($highaddr_bits-5 == 0) {
          $request_x8 = $request_x8 . "rvalid_" . $j . " && (raddr_high_x8_" . $j . "[0] == " . $i . ")};\n";
        }
        else {
          $request_x8 = $request_x8 . "rvalid_" . $j . "};\n";
        }
      }
      else {
        if ($highaddr_bits-5 > 0) {
          $request_x8 = $request_x8 . "rvalid_" . $j . " && (raddr_high_x8_" . $j . "[". ($highaddr_bits-5) . ":0] == " . $i . "), ";
        }
        elsif ($highaddr_bits-5 == 0) {
          $request_x8 = $request_x8 . "rvalid_" . $j . " && (raddr_high_x8_" . $j . "[0] == " . $i . "), ";
        }
        else {
          $request_x8 = $request_x8 . "rvalid_" . $j . ", ";
        }
      }
    }
    print $fh $request_x8;
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 8; $i++) {
    print $fh "wire [" . ($bank-1) . ":0] grant_x8_" . $i . ";\n";
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 8; $i++) {
    print $fh "reg [" . ($bank-1) . ":0] grant_x8_" . $i . "_reg;\n";
  }
  print $fh "\n";

  for (my $i = 0; $i < $bank / 8; $i++) {
    my $grant_x8 = "assign grant_x8_" . $i . " = request_x8_" . $i . "[" . $i . "] ? " . $bank . "'b" . "0" x ($bank-1-$i) . "1" . "0" x $i . " : \n";
    for (my $j = 0; $j < $bank; $j++) {
      if ($j == $bank-1) {
        $grant_x8 = $grant_x8 . "                    request_x8_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " : 0;\n";
      }
      if ($j != $i && $j != $bank-1) {
        $grant_x8 = $grant_x8 . "                    request_x8_" . $i . "[" . $j . "] ? " . $bank . "'b" . "0" x ($bank-1-$j) . "1" . "0" x $j . " : \n";
      }
    }
    print $fh $grant_x8;
    print $fh "\n";
  }
}

for (my $i = 0; $i < $bank; $i++) {
  my $ren = "assign ren_" . $i . " = ";
  $ren = $ren . "(dense & (|request_dense_" . $i . ")) | (sparse_x2 & (|request_x2_" . int($i/2) . "))";
  if ($sparse_x4_enable) {
    $ren = $ren . " | (sparse_x4 & (|request_x4_" . int($i/4) . "))";
  }
  if ($sparse_x8_enable) {
    $ren = $ren . " | (sparse_x8 & (|request_x8_" . int($i/8) . "))";
  }
  $ren = $ren . ";\n";
  print $fh $ren;
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $raddr = "assign raddr_" . $i . " = dense ? (request_dense_" . $i . "[0] && grant_dense_" . $i . "[0]) ? addr_0" . "[" . ($sram_addr_bits-1) . ":0] : \n"; 
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank - 1) {
      $raddr = $raddr . "                         (request_dense_" . $i . "[" . $j . "] && grant_dense_" . $i . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : 0 :\n";
    }
    else {
      $raddr = $raddr . "                         (request_dense_" . $i . "[" . $j . "] && grant_dense_" . $i . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : \n";
    } 
  }
  $raddr = $raddr . "                 sparse_x2 ? (request_x2_" . int($i / 2) . "[0] && grant_x2_" . int($i / 2) . "[0]) ? addr_0" . "[" . ($sram_addr_bits-1) . ":0] : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank - 1) {
      $raddr = $raddr . "                             (request_x2_" . int($i / 2) . "[" . $j . "] && grant_x2_" . int($i / 2) . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : 0 :";
    }
    else {
      $raddr = $raddr . "                             (request_x2_" . int($i / 2) . "[" . $j . "] && grant_x2_" . int($i / 2) . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : \n";
    } 
  }
  if ($sparse_x4_enable) {
    $raddr = $raddr . "\n                 sparse_x4 ? (request_x4_" . int($i / 4) . "[0] && grant_x4_" . int($i / 4) . "[0]) ? addr_0" . "[" . ($sram_addr_bits-1) . ":0] : \n";
    for (my $j = 1; $j < $bank; $j++) {
      if ($j == $bank - 1) {
        $raddr = $raddr . "                             (request_x4_" . int($i / 4) . "[" . $j . "] && grant_x4_" . int($i / 4) . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : 0 :";
      }
      else {
        $raddr = $raddr . "                             (request_x4_" . int($i / 4) . "[" . $j . "] && grant_x4_" . int($i / 4) . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : \n";
      }
    }
  }
  if ($sparse_x8_enable) {
    $raddr = $raddr . "\n                 sparse_x8 ? (request_x8_" . int($i / 8) . "[0] && grant_x8_" . int($i / 8) . "[0]) ? addr_0" . "[" . ($sram_addr_bits-1) . ":0] : \n";
    for (my $j = 1; $j < $bank; $j++) {
      if ($j == $bank - 1) {
        $raddr = $raddr . "                             (request_x8_" . int($i / 8) . "[" . $j . "] && grant_x8_" . int($i / 8) . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : 0";
      }
      else {
        $raddr = $raddr . "                             (request_x8_" . int($i / 8) . "[" . $j . "] && grant_x8_" . int($i / 8) . "[" . $j . "]) ? addr_" . $j . "[" . ($sram_addr_bits-1) . ":0] : \n";
      }
    }
  }
  $raddr = $raddr . " : 0;\n";
  print $fh $raddr;
  print $fh "\n";
}

for (my $i = 0; $i < $bank; $i++) {
  my $rready = "assign rready_" . $i . " = (dense & (";
  for (my $j = 0; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $rready = $rready . "(request_dense_" . $j . "[" . $i . "] & grant_dense_" . $j . "[" . $i . "]))";
    }
    else {
      $rready = $rready . "(request_dense_" . $j . "[" . $i . "] & grant_dense_" . $j . "[" . $i . "]) | ";
    }
  }
  $rready = $rready . ")\n               | (sparse_x2 & (";
  for (my $j = 0; $j < $bank / 2; $j++) {
    if ($j == $bank/2-1) {
      $rready = $rready . "(request_x2_" . $j . "[" . $i . "] & grant_x2_" . $j . "[" . $i . "]))";
    }
    else {
      $rready = $rready . "(request_x2_" . $j . "[" . $i . "] & grant_x2_" . $j . "[" . $i . "]) | ";
    }
  }
  if ($sparse_x4_enable) {
    $rready = $rready . ")\n               | (sparse_x4 & (";
    for (my $j = 0; $j < $bank / 4; $j++) {
      if ($j == $bank/4-1) {
        $rready = $rready . "(request_x4_" . $j . "[" . $i . "] & grant_x4_" . $j . "[" . $i . "]))";
      }
      else {
        $rready = $rready . "(request_x4_" . $j . "[" . $i . "] & grant_x4_" . $j . "[" . $i . "]) | ";
      }
    }
  }
  if ($sparse_x8_enable) {
    $rready = $rready . ")\n               | (sparse_x8 & (";
    for (my $j = 0; $j < $bank / 8; $j++) {
      if ($j == $bank/8-1) {
        $rready = $rready . "(request_x8_" . $j . "[" . $i . "] & grant_x8_" . $j . "[" . $i . "]))";
      }
      else {
        $rready = $rready . "(request_x8_" . $j . "[" . $i . "] & grant_x8_" . $j . "[" . $i . "]) | ";
      }
    }
  }
  $rready = $rready . ");\n";
  print $fh $rready;
}
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  my $data = "assign data_" . $i . " = dense ? request_dense_0_reg[" . $i . "] && grant_dense_0_reg[" . $i . "] ? {" . $width * 7 . "'d0, rdata_0} : \n";
  for (my $j = 1; $j < $bank; $j++) {
    if ($j == $bank-1) {
      $data = $data . "                        request_dense_" . $j . "_reg[" . $i . "] && grant_dense_" . $j . "_reg[" . $i . "] ? {" . $width * 7 . "'d0, rdata_" . $j . "} : 0 :\n";
    }
    else {
      $data = $data . "                        request_dense_" . $j . "_reg[" . $i . "] && grant_dense_" . $j . "_reg[" . $i . "] ? {" . $width * 7 . "'d0, rdata_" . $j . "} : \n";
    }
  }
  $data = $data . "                sparse_x2 ? request_x2_0_reg[" . $i . "] && grant_x2_0_reg[" . $i . "] ? {" . $width * 6 . "'d0, rdata_1, rdata_0} : \n";
  for (my $j = 1; $j < $bank / 2; $j++) {
    if ($j == $bank / 2 - 1) {
      $data = $data . "                            request_x2_" . $j . "_reg[" . $i . "] && grant_x2_" . $j . "_reg[" . $i . "] ? {" . $width * 6 . "'d0, rdata_" . ($j * 2 + 1) . ", rdata_" . ($j * 2 + 0) . "} : 0 :";
    } 
    else { 
      $data = $data . "                            request_x2_" . $j . "_reg[" . $i . "] && grant_x2_" . $j . "_reg[" . $i . "] ? {" . $width * 6 . "'d0, rdata_" . ($j * 2 + 1) . ", rdata_" . ($j * 2 + 0) . "} :\n";
    }
  }
  if ($sparse_x4_enable) {
    $data = $data . "\n                sparse_x4 ? request_x4_0_reg[0] && grant_x4_0_reg[0] ? {" . $width * 4 . "'d0, rdata_3, rdata_2, rdata_1, rdata_0} : \n";
    for (my $j = 1; $j < $bank / 4; $j++) {
      if ($j == $bank / 4 - 1) {
        $data = $data . "                            request_x4_" . $j . "_reg[" . $i . "] && grant_x4_" . $j . "_reg[" . $i . "] ? {" . $width * 4 . "'d0, rdata_" . ($j * 4 + 3) . ", rdata_" . ($j * 4 + 2) . ", rdata_" . ($j * 4 + 1) .", rdata_" . ($j * 4) . "} : 0 :";
      } 
      else { 
        $data = $data . "                            request_x4_" . $j . "_reg[" . $i . "] && grant_x4_" . $j . "_reg[" . $i . "] ? {" . $width * 4 . "'d0, rdata_" . ($j * 4 + 3) . ", rdata_" . ($j * 4 + 2) . ", rdata_" . ($j * 4 + 1) .", rdata_" . ($j * 4) . "} : \n";
      }
    }
  }
  if ($sparse_x8_enable) {
    $data = $data . "\n                sparse_x8 ? request_x8_0_reg[0] && grant_x8_0_reg[0] ? {rdata_7, rdata_6, rdata_5, rdata_4, rdata_3, rdata_2, rdata_1, rdata_0} : 0";
  }
  print $fh $data;
  print $fh " : 0;\n";
  print $fh "\n";
}

print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    request_dense_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    grant_dense_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank / 2; $i++) {
  print $fh "    request_x2_" . $i . "_reg <= 0;\n";
}
for (my $i = 0; $i < $bank / 2; $i++) {
  print $fh "    grant_x2_" . $i . "_reg <= 0;\n";
}
if ($sparse_x4_enable) {
  for (my $i = 0; $i < $bank / 4; $i++) {
    print $fh "    request_x4_" . $i . "_reg <= 0;\n";
  }
  for (my $i = 0; $i < $bank / 4; $i++) {
    print $fh "    grant_x4_" . $i . "_reg <= 0;\n";
  }
}
if ($sparse_x8_enable) {
  for (my $i = 0; $i < $bank / 8; $i++) {
    print $fh "    request_x8_" . $i . "_reg <= 0;\n";
  }
  for (my $i = 0; $i < $bank / 8; $i++) {
    print $fh "    grant_x8_" . $i . "_reg <= 0;\n";
  }
}
print $fh "  end\n";
print $fh "  else begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    request_dense_" . $i . "_reg <= request_dense_" . $i . ";\n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    grant_dense_" . $i . "_reg <= grant_dense_" . $i . ";\n";
}
for (my $i = 0; $i < $bank / 2; $i++) {
  print $fh "    request_x2_" . $i . "_reg <= request_x2_" . $i . ";\n";
}
for (my $i = 0; $i < $bank / 2; $i++) {
  print $fh "    grant_x2_" . $i . "_reg <= grant_x2_" . $i . ";\n";
}
if ($sparse_x4_enable) {
  for (my $i = 0; $i < $bank / 4; $i++) {
    print $fh "    request_x4_" . $i . "_reg <= request_x4_" . $i . ";\n";
  }
  for (my $i = 0; $i < $bank / 4; $i++) {
    print $fh "    grant_x4_" . $i . "_reg <= grant_x4_" . $i . ";\n";
  }
}
if ($sparse_x8_enable) {
  for (my $i = 0; $i < $bank / 8; $i++) {
    print $fh "    request_x8_" . $i . "_reg <= request_x8_" . $i . ";\n";
  }
  for (my $i = 0; $i < $bank / 8; $i++) {
    print $fh "    grant_x8_" . $i . "_reg <= grant_x8_" . $i . ";\n";
  }
}
print $fh "  end\n";
print $fh "end\n";

print $fh "endmodule\n";

print "==== INFO: Done Generate $file ====\n";
