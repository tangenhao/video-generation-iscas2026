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

print "==== INFO: Generating weight_ifmapmask_ram ==== \n";
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

if ($bank < 8) {
  die "Error: bank should be at least 8\n";
}

my $sram_addr_bits = log($depth) / log(2);
my $weight_sram_depth_expand = $depth * 2 * $bank;
my $weight_sram_addr_bits_expand = log($weight_sram_depth_expand) / log(2);
my $sram_addr_bits_all = log($depth * $bank * 4) / log(2);
my $ifmap_mask_width = 1024;
my $ifmap_mask_sram_addr_bits = log($weight_sram_depth_expand) / log(2);

print $fh "module weight_ifmapmask_ram(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
print $fh "  expand,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  weight_rvalid_" . $i . ", weight_raddr_" . $i . ", weight_rdata_" . $i . ", weight_rready_" . $i . ",\n";
}
print $fh "\n";
print $fh "  weight_wen, weight_waddr, weight_wdata,\n\n";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank - 1){
    print $fh "  ifmap_mask_rvalid_" . $i . ", ifmap_mask_raddr_" . $i . ", ifmap_mask_rdata_" . $i . ", ifmap_mask_rready_" . $i . "\n";
  }
  else {
    print $fh "  ifmap_mask_rvalid_" . $i . ", ifmap_mask_raddr_" . $i . ", ifmap_mask_rdata_" . $i . ", ifmap_mask_rready_" . $i . ",\n";
  }
}
print $fh ");\n";
print $fh "\n";
print $fh "input wire clk;\n";
print $fh "input wire rst_n;\n";
print $fh "input wire expand;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire weight_rvalid_" . $i . ";\n";
  print $fh "input wire [", $weight_sram_addr_bits_expand-1, ":0] weight_raddr_" . $i . ";\n";
  print $fh "output wire [", $width-1, ":0] weight_rdata_" . $i . ";\n";
  print $fh "output wire weight_rready_" . $i . ";\n";
  print $fh "\n";
}
print $fh "input wire weight_wen;\n";
print $fh "input wire [", $sram_addr_bits_all-1, ":0] weight_waddr;\n";
print $fh "input wire [", $width-1, ":0] weight_wdata;\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "input wire ifmap_mask_rvalid_" . $i . ";\n";
  print $fh "input wire [", $ifmap_mask_sram_addr_bits-1, ":0] ifmap_mask_raddr_" . $i . ";\n";
  print $fh "output wire [", $ifmap_mask_width-1, ":0] ifmap_mask_rdata_" . $i . ";\n";
  print $fh "output wire ifmap_mask_rready_" . $i . ";\n";
  print $fh "\n";
}

for (my $i = 0; $i < $bank; $i++) {
  print $fh "wire ren_" . $i . ";\n";
  print $fh "wire [", $sram_addr_bits-1, ":0] raddr_" . $i . ";\n";
  print $fh "wire [", $width-1, ":0] rdata_" . $i . ";\n";
  print $fh "reg wen_" . $i . ";\n";
  print $fh "reg [", $sram_addr_bits-1, ":0] waddr_" . $i . ";\n";
  print $fh "reg [", $width-1, ":0] wdata_" . $i . ";\n";
  print $fh "\n";
}

for (my $i = $bank; $i < $bank * 5; $i++) {
  print $fh "wire ren_" . $i . ";\n";
  print $fh "wire [", $sram_addr_bits-1, ":0] raddr_" . $i . ";\n";
  print $fh "wire [", $width/2-1, ":0] rdata_" . $i . ";\n";
  print $fh "reg wen_" . $i . ";\n";
  print $fh "reg [", $sram_addr_bits-1, ":0] waddr_" . $i . ";\n";
  print $fh "reg [", $width/2-1, ":0] wdata_" . $i . ";\n";
  print $fh "\n";
}

my $write_highaddr_bits = log($bank * 4 * 2) / log(2);
print $fh "wire [" . ($write_highaddr_bits-1) . ":0] waddr_high_bits;\n";
print $fh "assign waddr_high_bits = weight_waddr[" . ($sram_addr_bits_all-1) . ":" . ($sram_addr_bits_all-$write_highaddr_bits) . "];\n";
print $fh "\n";

print $fh "always @(*) begin\n";
print $fh "  case(waddr_high_bits)\n";
for (my $i = 0; $i < $bank * 6; $i++) {
  print $fh "    " . ($write_highaddr_bits) . "'d" . $i . ": begin\n";
  if ($i < $bank*3) {
    for (my $j = 0; $j < $bank * 5; $j++) {
      if ($j != $i && $j < $bank) {
        print $fh "      wen_" . $j . " = 1'b0;\n";
        print $fh "      waddr_" . $j . " = " . $sram_addr_bits . "'b0;\n";
        print $fh "      wdata_" . $j . " = " . $width . "'b0;\n";
      }
      elsif ($j < $bank) {
        print $fh "      wen_" . $j . " = weight_wen;\n";
        print $fh "      waddr_" . $j . " = weight_waddr[" . ($sram_addr_bits-1) . ":0];\n";
        print $fh "      wdata_" . $j . " = weight_wdata;\n";
      }

      if ($j >= $bank && ((int(($j - $bank) / 2) + $bank) == $i)) {
        print $fh "      wen_" . $j . " = weight_wen;\n";
        print $fh "      waddr_" . $j . " = weight_waddr[" . ($sram_addr_bits-1) . ":0];\n";
        if ($j % 2 == 1) {
          print $fh "      wdata_" . $j . " = weight_wdata[" . ($width-1) . ":" . ($width/2) . "];\n";
        }
        else {
          print $fh "      wdata_" . $j . " = weight_wdata[" . ($width/2-1) . ":0];\n";
        }
      }
      elsif($j >= $bank) {
        print $fh "      wen_" . $j . " = 1'b0;\n";
        print $fh "      waddr_" . $j . " = " . $sram_addr_bits . "'b0;\n";
        print $fh "      wdata_" . $j . " = " . $width/2 . "'b0;\n";
      
      }
    }
  }
  else {
    for (my $j = 0; $j < $bank * 5; $j++) {
      if ($j != ($i - $bank*3) && $j < $bank) {
        print $fh "      wen_" . $j . " = 1'b0;\n";
        print $fh "      waddr_" . $j . " = " . $sram_addr_bits . "'b0;\n";
        print $fh "      wdata_" . $j . " = " . $width . "'b0;\n";
      }
      elsif ($j < $bank) {
        print $fh "      wen_" . $j . " = weight_wen;\n";
        print $fh "      waddr_" . $j . " = weight_waddr[" . ($sram_addr_bits-1) . ":0];\n";
        print $fh "      wdata_" . $j . " = weight_wdata;\n";
      }

      if ($j >= $bank && ((int(($j - $bank) / 2) + $bank) == ($i - $bank*3))) {
        print $fh "      wen_" . $j . " = weight_wen;\n";
        print $fh "      waddr_" . $j . " = weight_waddr[" . ($sram_addr_bits-1) . ":0];\n";
        if ($j % 2 == 1) {
          print $fh "      wdata_" . $j . " = weight_wdata[" . ($width-1) . ":" . ($width/2) . "];\n";
        }
        else {
          print $fh "      wdata_" . $j . " = weight_wdata[" . ($width/2-1) . ":0];\n";
        }
      }
      elsif($j >= $bank) {
        print $fh "      wen_" . $j . " = 1'b0;\n";
        print $fh "      waddr_" . $j . " = " . $sram_addr_bits . "'b0;\n";
        print $fh "      wdata_" . $j . " = " . $width/2 . "'b0;\n";
      
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

print $fh "weight_ifmapmask_arbiter u_arbiter(\n";
print $fh "  .clk(clk),\n";
print $fh "  .rst_n(rst_n),\n";
print $fh "  .expand(expand),\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .weight_rvalid_" . $i . "(weight_rvalid_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .weight_addr_" . $i . "(weight_raddr_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .mask_rvalid_" . $i . "(ifmap_mask_rvalid_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .mask_addr_" . $i . "(ifmap_mask_raddr_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank*5; $i++) {
  print $fh "  .ren_" . $i . "(ren_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank*5; $i++) {
  print $fh "  .raddr_" . $i . "(raddr_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank*5; $i++) {
  print $fh "  .rdata_" . $i . "(rdata_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .weight_data_" . $i . "(weight_rdata_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .mask_data_" . $i . "(ifmap_mask_rdata_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .weight_rready_" . $i . "(weight_rready_" . $i . "),\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  if ($i == $bank - 1) {
    print $fh "  .mask_rready_" . $i . "(ifmap_mask_rready_" . $i . ")\n";
  }
  else {
    print $fh "  .mask_rready_" . $i . "(ifmap_mask_rready_" . $i . "),\n";
  }
}
print $fh ");\n";
print $fh "\n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "sram_512x1024 u_ram_bank_" . $i . "(\n";
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

for (my $i = $bank; $i < $bank*5; $i++) {
  print $fh "sram_256x1024 u_ram_bank_" . $i . "(\n";
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
