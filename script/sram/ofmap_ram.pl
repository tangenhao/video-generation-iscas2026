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

my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

my $sram_addr_bits = log($depth) / log(2);
my $sram_addr_bits_all = log($depth * $bank) / log(2);

print "====INFO: Generating ofmap_ram ====\n";

print "width: ", $width, "\n";
print "depth: ", $depth, "\n";
print "bank: ", $bank, "\n";

print "sram_addr_bits: ", $sram_addr_bits_all, "\n";


print $fh "module ofmap_ram(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  ofmap_wvalid_" . $i . ", ofmap_waddr_" . $i . ", ofmap_wdata_" . $i . ", ofmap_wready_" . $i . ",\n";
}
print $fh "\n";
  print $fh "  ofmap_ren, ofmap_raddr, ofmap_rdata\n";
print $fh ");\n";
print $fh "\n";
print $fh "input wire clk;\n";
print $fh "input wire rst_n;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire ofmap_wvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] ofmap_waddr_" . $i . ";\n";
  print $fh "input wire [", $width-1, ":0] ofmap_wdata_" . $i . ";\n";
  print $fh "output wire ofmap_wready_" . $i . ";\n";
  print $fh "\n";
}
print $fh "input wire ofmap_ren;\n";
print $fh "input wire [", $sram_addr_bits_all-1, ":0] ofmap_raddr;\n";
print $fh "output reg [", $width-1, ":0] ofmap_rdata;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "reg ren_" . $i . ";\n";
  print $fh "reg [", $sram_addr_bits-1, ":0] raddr_" . $i . ";\n";
  print $fh "reg [", $width-1, ":0] rdata_" . $i . ";\n";
  print $fh "wire wen_" . $i . ";\n";
  print $fh "wire [", $sram_addr_bits-1, ":0] waddr_" . $i . ";\n";
  print $fh "wire [", $width-1, ":0] wdata_" . $i . ";\n";
  print $fh "\n";
}

my $read_highaddr_bits = log($bank*2) / log(2);
print $fh "wire [" . ($read_highaddr_bits-1) . ":0] raddr_high_bits;\n";
print $fh "assign raddr_high_bits = ofmap_raddr[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$read_highaddr_bits) . "];\n";
print $fh "\n";

print $fh "always @(*) begin\n";
print $fh "  case(raddr_high_bits)\n";
for (my $i = 0; $i < $bank*2; $i++) {
  print $fh "    " . ($read_highaddr_bits) . "'d" . $i . ": begin\n";
  if ($i < $bank) {
    for (my $j = 0; $j < $bank; $j++) {
      if ($j != $i) {
        print $fh "      ren_" . $j . " = 1'b0;\n";
        print $fh "      raddr_" . $j . " = " . $sram_addr_bits . "'b0;\n";
      }
      else {
        print $fh "      ren_" . $i . " = ofmap_ren;\n";
        print $fh "      raddr_" . $i . " = ofmap_raddr[" . ($sram_addr_bits-1) . ":0];\n";
        print $fh "      ofmap_rdata = rdata_" . $i . ";\n";
      }
    }
  }
  else {
    for (my $j = 0; $j < $bank; $j++) {
      if ($j != ($i - $bank)) {
        print $fh "      ren_" . $j . " = 1'b0;\n";
        print $fh "      raddr_" . $j . " = " . $sram_addr_bits . "'b0;\n";
      }
      else {
        print $fh "      ren_" . ($i - $bank) . " = ofmap_ren;\n";
        print $fh "      raddr_" . ($i - $bank) . " = ofmap_raddr[" . ($sram_addr_bits-1) . ":0];\n";
        print $fh "      ofmap_rdata = rdata_" . ($i - $bank) . ";\n";
      }
    }
  }
  print $fh "    end\n";
}
print $fh "  default: begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    ren_" . $i . " = 1'b0;\n";
  print $fh "    raddr_" . $i . " = " . $sram_addr_bits . "'b0;\n";
}
print $fh "    ofmap_rdata = 0;\n";
print $fh "  end\n";
print $fh "  endcase\n";
print $fh "end\n";
print $fh "\n";

print $fh "ofmap_arbiter u_ofmap_arbiter(\n";
print $fh "  .clk(clk),\n";
print $fh "  .rst_n(rst_n),\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .wvalid_" . $i . "(ofmap_wvalid_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .addr_" . $i . "(ofmap_waddr_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .wen_" . $i . "(wen_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .waddr_" . $i . "(waddr_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .wdata_" . $i . "(wdata_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .data_" . $i . "(ofmap_wdata_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank - 1) {
    print $fh "  .wready_" . $i . "(ofmap_wready_" . $i . ")\n";
  }
  else {
    print $fh "  .wready_" . $i . "(ofmap_wready_" . $i . "),\n";
  }
}
print $fh ");\n";
print $fh "\n";


for (my $i = 0; $i < $bank; $i++) {
  print $fh "sram_512x512  u_ram_bank_" . $i . "(\n";
  print $fh "  .w_clk(clk),\n";
  print $fh "  .w_en(wen_" . $i . "),\n";
  print $fh "  .w_addr(waddr_" . $i . "),\n";
  print $fh "  .w_data(wdata_" . $i . "),\n";
  print $fh "  .r_clk(clk),\n";
  print $fh "  .r_en(ren_" . $i . "),\n";
  print $fh "  .r_addr(raddr_" . $i . "),\n";
  print $fh "  .r_data(rdata_" . $i . ")\n";
  print $fh ");\n";
  print $fh "\n";
}
print $fh "endmodule\n";

close $fh;
print "====INFO: Done Generate $file ====\n";