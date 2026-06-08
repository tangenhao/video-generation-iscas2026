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

print "==== INFO: Generating psum_ram ==== \n";
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

my $sram_depth_bits = log($depth) / log(2);
my $sram_addr_bits_all = log($depth * $bank) / log(2);

print $fh "module psum_ram(\n";
print $fh "  clk, rst_n,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  pea_wvalid_" . $i . ", pea_waddr_" . $i . ", pea_wdata_" . $i . ", pea_wready_" . $i . ",\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  vcu_wvalid_" . $i . ", vcu_waddr_" . $i . ", vcu_wdata_" . $i . ", vcu_wready_" . $i . ",\n";
}
print $fh "\n";
print $fh "  load_wen, load_waddr, load_wdata, load_wresp,\n";
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  pea_rvalid_" . $i . ", pea_raddr_" . $i . ", pea_rdata_" . $i . ", pea_rready_" . $i . ",\n";
}
print $fh "\n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  vcu_rvalid_" . $i . ", vcu_raddr_" . $i . ", vcu_rdata_" . $i . ", vcu_rready_" . $i . ",\n";
}
print $fh "\n";
print $fh "  store_rvalid, store_raddr, store_rdata, store_rready\n";
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
  print $fh "input wire vcu_wvalid_" . $i . ";\n";
  print $fh "input wire [", $sram_addr_bits_all-1, ":0] vcu_waddr_" . $i . ";\n";
  print $fh "input wire [", ($width - 1), ":0] vcu_wdata_" . $i . ";\n";
  print $fh "output wire vcu_wready_" . $i . ";\n";
  print $fh "\n";
}
print $fh "input wire load_wen;\n";
print $fh "input wire [", $sram_addr_bits_all-1, ":0] load_waddr;\n";
print $fh "input wire [", ($width - 1), ":0] load_wdata;\n";
print $fh "output wire load_wresp;\n";
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
  print $fh "wire psum_wen_" . $i . ";\n";
  print $fh "wire [" . $sram_depth_bits . "-1:0] psum_waddr_" . $i . ";\n";
  print $fh "wire [" . ($width - 1) . ":0] psum_wdata_" . $i . ";\n";
  print $fh "wire psum_ren_" . $i . ";\n";
  print $fh "wire [" . $sram_depth_bits . "-1:0] psum_raddr_" . $i . ";\n";
  print $fh "wire [" . ($width - 1) . ":0] psum_rdata_" . $i . ";\n";
  print $fh "\n";
}


print $fh "psum_read_arbiter u_psum_read_arbiter (\n";
print $fh "  .clk(clk),\n";
print $fh "  .rst_n(rst_n),\n";
print $fh " \n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .pea_rvalid_" . $i . "(pea_rvalid_" . $i . "),\n";
  print $fh "  .pea_raddr_" . $i . "(pea_raddr_" . $i . "),\n";
  print $fh "  .pea_rdata_" . $i . "(pea_rdata_" . $i . "),\n";
  print $fh "  .pea_rready_" . $i . "(pea_rready_" . $i . "),\n";
  print $fh " \n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .vcu_rvalid_" . $i . "(vcu_rvalid_" . $i . "),\n";
  print $fh "  .vcu_raddr_" . $i . "(vcu_raddr_" . $i . "),\n";
  print $fh "  .vcu_rdata_" . $i . "(vcu_rdata_" . $i . "),\n";
  print $fh "  .vcu_rready_" . $i . "(vcu_rready_" . $i . "),\n";
  print $fh " \n";
}
print $fh "  .store_rvalid(store_rvalid),\n";
print $fh "  .store_raddr(store_raddr),\n";
print $fh "  .store_rdata(store_rdata),\n";
print $fh "  .store_rready(store_rready),\n";
print $fh " \n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .ren_" . $i . "(psum_ren_" . $i . "),\n";
  print $fh "  .raddr_" . $i . "(psum_raddr_" . $i . "),\n";
  if ($i == $bank - 1) {
    print $fh "  .rdata_" . $i . "(psum_rdata_" . $i . ")\n";
  }
  else {
    print $fh "  .rdata_" . $i . "(psum_rdata_" . $i . "),\n";
    print $fh " \n";
  }
}
print $fh ");\n";
print $fh " \n";


print $fh "psum_write_arbiter u_psum_write_arbiter (\n";
print $fh "  .clk(clk),\n";
print $fh "  .rst_n(rst_n),\n";
print $fh " \n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .pea_wvalid_" . $i . "(pea_wvalid_" . $i . "),\n";
  print $fh "  .pea_waddr_" . $i . "(pea_waddr_" . $i . "),\n";
  print $fh "  .pea_wdata_" . $i . "(pea_wdata_" . $i . "),\n";
  print $fh "  .pea_wready_" . $i . "(pea_wready_" . $i . "),\n";
  print $fh " \n";
}
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .vcu_wvalid_" . $i . "(vcu_wvalid_" . $i . "),\n";
  print $fh "  .vcu_waddr_" . $i . "(vcu_waddr_" . $i . "),\n";
  print $fh "  .vcu_wdata_" . $i . "(vcu_wdata_" . $i . "),\n";
  print $fh "  .vcu_wready_" . $i . "(vcu_wready_" . $i . "),\n";
  print $fh " \n";
}
print $fh "  .load_wen(load_wen),\n";
print $fh "  .load_waddr(load_waddr),\n";
print $fh "  .load_wdata(load_wdata),\n";
print $fh "  .load_wresp(load_wresp),\n";
print $fh " \n";
for (my $i = 0; $i < $bank; $i++) {
  print $fh "  .wen_" . $i . "(psum_wen_" . $i . "),\n";
  print $fh "  .waddr_" . $i . "(psum_waddr_" . $i . "),\n";
  if ($i == $bank - 1) {
    print $fh "  .wdata_" . $i . "(psum_wdata_" . $i . ")\n";
  }
  else {
    print $fh "  .wdata_" . $i . "(psum_wdata_" . $i . "),\n";
    print $fh " \n";
  }
}
print $fh ");\n";
print $fh " \n";

for (my $i = 0; $i < $bank; $i++) {
  print $fh "sram_2048x1024 u_ram_bank_" . $i . "(\n";
  print $fh "  .w_clk(clk),\n";
  print $fh "  .w_en(psum_wen_" . $i . "),\n";
  print $fh "  .w_addr(psum_waddr_" . $i . "),\n";
  print $fh "  .w_data(psum_wdata_" . $i . "),\n";
  print $fh "  .r_clk(clk),\n";
  print $fh "  .r_en(psum_ren_" . $i . "),\n";
  print $fh "  .r_addr(psum_raddr_" . $i . "),\n";
  print $fh "  .r_data(psum_rdata_" . $i . ")\n";
  print $fh ");\n";
  print $fh "\n";
}
print $fh "endmodule\n";

print "==== INFO: Done Generate $file ====\n";
