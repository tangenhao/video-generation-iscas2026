#!/usr/bin/perl
use strict; 
use Getopt::Long;

my $help = "";
my $file = "";
my $width = 16;
my $depth = 2048;
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

print "==== INFO: Generating weight_scale_ram ==== \n";
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

print $fh "module weight_scale_ram(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  weight_scale_rvalid_" . $i . ", weight_scale_raddr_" . $i . ", weight_scale_rdata_" . $i . ", weight_scale_rready_" . $i . ",\n";
}
print $fh "\n";
  print $fh "  weight_scale_wen, weight_scale_waddr, weight_scale_wdata\n";
print $fh ");\n";
print $fh "\n";
print $fh "input wire clk;\n";
print $fh "input wire rst_n;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire weight_scale_rvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] weight_scale_raddr_" . $i . ";\n";
  print $fh "output wire [", $width-1, ":0] weight_scale_rdata_" . $i . ";\n";
  print $fh "output wire weight_scale_rready_" . $i . ";\n";
  print $fh "\n";
}
print $fh "input wire weight_scale_wen;\n";
print $fh "input wire [", $sram_addr_bits_all-1, ":0] weight_scale_waddr;\n";
print $fh "input wire [", $width-1, ":0] weight_scale_wdata;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire ren_" . $i . ";\n";
  print $fh "wire [", $sram_addr_bits-1, ":0] raddr_" . $i . ";\n";
  print $fh "wire [", $width-1, ":0] rdata_" . $i . ";\n";
  print $fh "reg wen_" . $i . ";\n";
  print $fh "reg [", $sram_addr_bits-1, ":0] waddr_" . $i . ";\n";
  print $fh "reg [", $width-1, ":0] wdata_" . $i . ";\n";
  print $fh "\n";
}

my $write_highaddr_bits = log($bank*2) / log(2);
print $fh "wire [" . $write_highaddr_bits . ":0] waddr_high_bits;\n";
print $fh "assign waddr_high_bits = weight_scale_waddr[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$write_highaddr_bits) . "];\n";
print $fh "\n";

print $fh "always @(*) begin\n";
print $fh "  case(waddr_high_bits)\n";
for (my $i = 0; $i < $bank * 2; $i++) {
  print $fh "    " . ($write_highaddr_bits) . "'d" . $i . ": begin\n";
  if ($i < $bank) {
    for (my $j = 0; $j < $bank; $j++) {
      if ($j != $i) {
        print $fh "      wen_" . $j . " = 1'b0;\n";
        print $fh "      waddr_" . $j . " = " . $sram_addr_bits . "'b0;\n";
        print $fh "      wdata_" . $j . " = " . $width . "'b0;\n";
      }
      else {
        print $fh "      wen_" . $i . " = weight_scale_wen;\n";
        print $fh "      waddr_" . $i . " = weight_scale_waddr[" . ($sram_addr_bits-1) . ":0];\n";
        print $fh "      wdata_" . $i . " = weight_scale_wdata;\n";
      }
    }
  }
  else {
    for (my $j = 0; $j < $bank; $j++) {
      if ($j != ($i - $bank)) {
        print $fh "      wen_" . $j . " = 1'b0;\n";
        print $fh "      waddr_" . $j . " = " . $sram_addr_bits . "'b0;\n";
        print $fh "      wdata_" . $j . " = " . $width . "'b0;\n";
      }
      else {
        print $fh "      wen_" . ($i - $bank) . " = weight_scale_wen;\n";
        print $fh "      waddr_" . ($i - $bank) . " = weight_scale_waddr[" . ($sram_addr_bits-1) . ":0];\n";
        print $fh "      wdata_" . ($i - $bank) . " = weight_scale_wdata;\n";
      }
    }
  }
  print $fh "    end\n";
}
print $fh "  default: begin\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "    wen_" . $i . " = 1'b0;\n";
  print $fh "    waddr_" . $i . " = " . $sram_addr_bits . "'b0;\n";
  print $fh "    wdata_" . $i . " = " . $width . "'b0;\n";
}
print $fh "  end\n";
print $fh "  endcase\n";
print $fh "end\n";
print $fh "\n";

print $fh "weight_scale_arbiter u_arbiter(\n";
print $fh "  .clk(clk),\n";
print $fh "  .rst_n(rst_n),\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .rvalid_" . $i . "(weight_scale_rvalid_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .addr_" . $i . "(weight_scale_raddr_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .ren_" . $i . "(ren_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .raddr_" . $i . "(raddr_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .rdata_" . $i . "(rdata_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .data_" . $i . "(weight_scale_rdata_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank - 1) {
    print $fh "  .rready_" . $i . "(weight_scale_rready_" . $i . ")\n";
  }
  else {
    print $fh "  .rready_" . $i . "(weight_scale_rready_" . $i . "),\n";
  }
}
print $fh ");\n";
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "sram_16x2048 u_ram_bank_" . $i . "(\n";
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

print "==== INFO: Done Generate $file ====\n";
