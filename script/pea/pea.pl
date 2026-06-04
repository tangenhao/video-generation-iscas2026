#!/usr/bin/perl
use strict; 
use Getopt::Long;

my $help = "";
my $file = "";
my $p = 32;
my $lane = 64;
my $layer = 8;
my $ifmap_sram_depth = 512;
my $weight_sram_depth = 2048;
my $psum_sram_depth = 512;
my $bank = 8;

GetOptions(
  "file=s" => \$file, 
  "help" => \$help, 
  "lane:s" => \$lane, 
  "layer:s" => \$layer, 
  "p:s" => \$p, 
  "bank:s" => \$bank, 
  "ifmap_sram_depth:s" => \$ifmap_sram_depth, 
  "weight_sram_depth:s" => \$weight_sram_depth, 
  "psum_sram_depth:s" => \$psum_sram_depth
) or die "Error in command line arguments\n";

if ($help) {
  print "Usage: perl pea.pl --file <file> --p <p> --lane <lane> --layer <layer> --ifmap_sram_depth <ifmap_sram_depth> --weight_sram_depth <weight_sram_depth> --psum_sram_depth <psum_sram_depth>\n";
  print "Options:\n";
  print "  --file <file>               Output file\n";
  print "  --p <p>                     Parallelism\n";
  print "  --lane <lane>               Lane\n";
  print "  --layer <layer>             Layer\n";
  print "  --bank <bank>               Bank\n";
  print "  --ifmap_sram_depth <ifmap_sram_depth> Ifmap SRAM depth\n";
  print "  --weight_sram_depth <weight_sram_depth> Weight SRAM depth\n";
  print "  --psum_sram_depth <psum_sram_depth> Psum SRAM depth\n";
  exit;
}

print "==== INFO: Generating pea ==== \n";
print "lane: ", $lane, "\n";
print "layer: ", $layer, "\n";
print "p: ", $p, "\n";
print "bank: ", $bank, "\n";
print "ifmap_sram_depth: ", $ifmap_sram_depth, "\n";
print "weight_sram_depth: ", $weight_sram_depth, "\n";
print "psum_sram_depth: ", $psum_sram_depth, "\n";


my $fh;

if ($file eq "") {
  die "Error: file is not specified\n";
}
else {
  open $fh, ">" , $file or die "Can't open file: $!";
}

sub min($$) {
  my ($a, $b) = @_;
  return $a < $b ? $a : $b;
}

sub max($$) {
  my ($a, $b) = @_;
  return $a > $b ? $a : $b;
}

my $ifmap_sram_address_bits = log($ifmap_sram_depth * $bank)/log(2);
my $weight_sram_address_bits = log($weight_sram_depth * $bank * 2)/log(2);
my $psum_sram_address_bits = log($psum_sram_depth * $bank)/log(2);

my $ifmap_sram_width = $p * 16 * $bank;
my $ifmapmask_sram_width = $p * 4 * $bank;
my $weight_sram_width = $p * 16;
my $psum_sram_width = $lane * 32;
my $outlier_index_sram_width = $p * 4;

my $max_ifmap_width = $ifmap_sram_depth * $bank / 2;
my $max_ifmap_height = $ifmap_sram_depth * $bank / 2;
my $max_weight_width = $weight_sram_depth * $bank * 2 / 2 / $lane;
my $max_weight_height = $weight_sram_depth * $bank * 2 / 2 / $lane;
my $max_psum_width = min($psum_sram_depth * $bank / 4, $ifmap_sram_depth * $bank / 2);
my $max_psum_height = min($psum_sram_depth * $bank / 4, $ifmap_sram_depth * $bank / 2);
my $max_channel = min($weight_sram_depth * $bank * 2 / 2 / $lane, $ifmap_sram_depth * $bank / 2);

my $max_ifmap_width_bits = log($max_ifmap_width)/log(2);
my $max_ifmap_height_bits = log($max_ifmap_height)/log(2);
my $max_weight_width_bits = log($max_weight_width)/log(2);
my $max_weight_height_bits = log($max_weight_height)/log(2);
my $max_weight_number_bits = $max_weight_height_bits * 2 + 5;
my $max_psum_width_bits = log($max_psum_width)/log(2);
my $max_psum_height_bits = log($max_psum_height)/log(2);
my $max_channel_bits = log($max_channel)/log(2);
my $max_pad_left_bits = 5;
my $max_pad_top_bits = 5;
my $max_stride_width_bits = 5;
my $max_stride_height_bits = 5;
my $max_dilation_width_bits = 5;
my $max_dilation_height_bits = 5;

my $max_psum_number_bits = $max_channel_bits + 1;

my $max_tile_m = $ifmap_sram_depth / 2;
my $max_n_groups = $weight_sram_depth / 2 / $lane;
my $max_k_groups = $weight_sram_depth / 2 / $p;
my $max_tile_m_bits = log($max_tile_m)/log(2);
my $max_n_groups_bits = log($max_n_groups)/log(2);
my $max_k_groups_bits = log($max_k_groups)/log(2);

my $weight_internal_channel_bits = log($lane)/log(2) - 1;

# ----------------------------------------- common config insn bits ---------------------------------------- #
my $insn_kind_bits = 3;
my $type_a_bits = 3;
my $type_b_bits = 3;
my $type_accumulator_bits = 1;
my $type_output_bits = 2;
my $sparse_enable_bits = 1;
my $sparse_base_bits = 2;
my $sparse_ratio_bits = 2;
my $non_uniform_quantization_bits = 1;
my $outlier_enable_bits = 1;
my $expand_weight_sram_bits = 1;
my $ifmap_sram_base_highaddr_bits = 3;
my $weight_sram_base_highaddr_bits = 3;
my $psum_sram_base_highaddr_bits = 3;


# -------------------------------------- common config insn start end -------------------------------------- #
my $insn_kind_start = 5;
my $type_a_start = $insn_kind_start + $insn_kind_bits;
my $type_b_start = $type_a_start + $type_a_bits;
my $type_accumulator_start = $type_b_start + $type_b_bits;
my $type_output_start = $type_accumulator_start + $type_accumulator_bits;
my $sparse_enable_start = $insn_kind_start + $type_output_bits;
my $sparse_base_start = $sparse_enable_start + $sparse_enable_bits;
my $sparse_ratio_start = $sparse_base_start + $sparse_base_bits;
my $non_uniform_quantization_start = $sparse_ratio_start + $sparse_ratio_bits;
my $outlier_enable_start = $non_uniform_quantization_start + $non_uniform_quantization_bits;
my $expand_weight_sram_start = $outlier_enable_start + $outlier_enable_bits;
my $ifmap_sram_base_highaddr_start = $expand_weight_sram_start + $expand_weight_sram_bits;
my $weight_sram_base_highaddr_start = $ifmap_sram_base_highaddr_start + $ifmap_sram_base_highaddr_bits;
my $psum_sram_base_highaddr_start = $weight_sram_base_highaddr_start + $weight_sram_base_highaddr_bits;

my $insn_kind_end = $insn_kind_start + $insn_kind_bits - 1;
my $type_a_end = $type_a_start + $type_a_bits - 1;
my $type_b_end = $type_b_start + $type_b_bits - 1;
my $type_accumulator_end = $type_accumulator_start + $type_accumulator_bits - 1;
my $type_output_end = $type_output_start + $type_output_bits - 1;
my $sparse_enable_end = $sparse_enable_start + $sparse_enable_bits - 1;
my $sparse_base_end = $sparse_base_start + $sparse_base_bits - 1;
my $sparse_ratio_end = $sparse_ratio_start + $sparse_ratio_bits - 1;
my $non_uniform_quantization_end = $non_uniform_quantization_start + $non_uniform_quantization_bits - 1;
my $outlier_enable_end = $outlier_enable_start + $outlier_enable_bits - 1;
my $expand_weight_sram_end = $expand_weight_sram_start + $expand_weight_sram_bits - 1;
my $ifmap_sram_base_highaddr_end = $ifmap_sram_base_highaddr_start + $ifmap_sram_base_highaddr_bits - 1;
my $weight_sram_base_highaddr_end = $weight_sram_base_highaddr_start + $weight_sram_base_highaddr_bits - 1;
my $psum_sram_base_highaddr_end = $psum_sram_base_highaddr_start + $psum_sram_base_highaddr_bits - 1;


# ----------------------------------------- conv config insn bits ----------------------------------------- #
my $conv_stride_width_bits = $max_stride_height_bits;
my $conv_stride_height_bits = $max_stride_height_bits;
my $conv_dilation_width_bits = $max_dilation_width_bits;
my $conv_dilation_height_bits = $max_dilation_height_bits;

# --------------------------------------- conv config insn start end -------------------------------------- #
my $conv_stride_width_start = $psum_sram_base_highaddr_start + $psum_sram_base_highaddr_bits;
my $conv_stride_height_start = $conv_stride_width_start + $conv_stride_width_bits;
my $conv_dilation_width_start = $conv_stride_height_start + $conv_stride_height_bits;
my $conv_dilation_height_start = $conv_dilation_width_start + $conv_dilation_width_bits;

my $conv_stride_width_end = $conv_stride_width_start + $conv_stride_width_bits - 1;
my $conv_stride_height_end = $conv_stride_height_start + $conv_stride_height_bits - 1;
my $conv_dilation_width_end = $conv_dilation_width_start + $conv_dilation_width_bits - 1;
my $conv_dilation_height_end = $conv_dilation_height_start + $conv_dilation_height_bits - 1;

# ----------------------------------------- conv execute insn bits ----------------------------------------- #
my $conv_ifmap_width_bits = $max_ifmap_width_bits;
my $conv_ifmap_height_bits = $max_ifmap_height_bits;
my $conv_weight_width_bits = $max_weight_width_bits;
my $conv_weight_height_bits = $max_weight_height_bits;
my $conv_psum_width_bits = $max_psum_width_bits;
my $conv_psum_height_bits = $max_psum_height_bits;
my $conv_ic_group_bits = $max_channel_bits;
my $conv_oc_group_bits = $max_channel_bits;
my $conv_ifmap_highaddr_bits = 1;
my $conv_weight_highaddr_bits = 1;
my $conv_psum_highaddr_bits = 2;
my $conv_pad_left_bits = $max_pad_left_bits;
my $conv_pad_top_bits = $max_pad_top_bits;
my $conv_psum_number_bits = $max_psum_number_bits;
my $conv_psum_accumulated_bits = 1;

# --------------------------------------- conv execute insn start end -------------------------------------- #
my $conv_ifmap_width_start = $type_output_start + $type_output_bits;
my $conv_ifmap_height_start = $conv_ifmap_width_start + $conv_ifmap_width_bits;
my $conv_weight_width_start = $conv_ifmap_height_start + $conv_ifmap_height_bits;
my $conv_weight_height_start = $conv_weight_width_start + $conv_weight_width_bits;
my $conv_psum_width_start = $conv_weight_height_start + $conv_weight_height_bits;
my $conv_psum_height_start = $conv_psum_width_start + $conv_psum_width_bits;
my $conv_ic_group_start = $conv_psum_height_start + $conv_psum_height_bits;
my $conv_oc_group_start = $conv_ic_group_start + $conv_ic_group_bits;
my $conv_ifmap_highaddr_start = $conv_oc_group_start + $conv_oc_group_bits;
my $conv_weight_highaddr_start = $conv_ifmap_highaddr_start + $conv_ifmap_highaddr_bits;
my $conv_psum_highaddr_start = $conv_weight_highaddr_start + $conv_weight_highaddr_bits;
my $conv_pad_left_start = $conv_psum_highaddr_start + $conv_psum_highaddr_bits;
my $conv_pad_top_start = $conv_pad_left_start + $conv_pad_left_bits;
my $conv_psum_number_start = $conv_pad_top_start + $conv_pad_top_bits;
my $conv_psum_accumulated_start = $conv_psum_number_start + $conv_psum_number_bits;

my $conv_ifmap_width_end = $conv_ifmap_width_start + $conv_ifmap_width_bits - 1;
my $conv_ifmap_height_end = $conv_ifmap_height_start + $conv_ifmap_height_bits - 1;
my $conv_weight_width_end = $conv_weight_width_start + $conv_weight_width_bits - 1;
my $conv_weight_height_end = $conv_weight_height_start + $conv_weight_height_bits - 1;
my $conv_psum_width_end = $conv_psum_width_start + $conv_psum_width_bits - 1;
my $conv_psum_height_end = $conv_psum_height_start + $conv_psum_height_bits - 1;
my $conv_ic_group_end = $conv_ic_group_start + $conv_ic_group_bits - 1;
my $conv_oc_group_end = $conv_oc_group_start + $conv_oc_group_bits - 1;
my $conv_ifmap_highaddr_end = $conv_ifmap_highaddr_start + $conv_ifmap_highaddr_bits - 1;
my $conv_weight_highaddr_end = $conv_weight_highaddr_start + $conv_weight_highaddr_bits - 1;
my $conv_psum_highaddr_end = $conv_psum_highaddr_start + $conv_psum_highaddr_bits - 1;
my $conv_pad_left_end = $conv_pad_left_start + $conv_pad_left_bits - 1;
my $conv_pad_top_end = $conv_pad_top_start + $conv_pad_top_bits - 1;
my $conv_psum_number_end = $conv_psum_number_start + $conv_psum_number_bits - 1;
my $conv_psum_accumulated_end = $conv_psum_accumulated_start + $conv_psum_accumulated_bits - 1;

# ----------------------------------------- gemm execute insn bits ----------------------------------------- #
my $gemm_tile_m_bits = $max_tile_m_bits;
my $gemm_n_groups_bits = $max_n_groups_bits;
my $gemm_k_groups_bits = $max_k_groups_bits;
my $gemm_ifmap_highaddr_bits = 1;
my $gemm_weight_highaddr_bits = 1;
my $gemm_psum_highaddr_bits = 2;
my $gemm_psum_number_bits = $max_psum_number_bits;
my $gemm_psum_accumulated_bits = 1;

# --------------------------------------- gemm execute insn start end -------------------------------------- #
my $gemm_tile_m_start = $insn_kind_start + $insn_kind_bits;
my $gemm_n_groups_start = $gemm_tile_m_start + $gemm_tile_m_bits;
my $gemm_k_groups_start = $gemm_n_groups_start + $gemm_n_groups_bits;
my $gemm_ifmap_highaddr_start = $gemm_k_groups_start + $gemm_k_groups_bits;
my $gemm_weight_highaddr_start = $gemm_ifmap_highaddr_start + $gemm_ifmap_highaddr_bits;
my $gemm_psum_highaddr_start = $gemm_weight_highaddr_start + $gemm_weight_highaddr_bits;
my $gemm_psum_number_start = $gemm_psum_highaddr_start + $gemm_psum_highaddr_bits;
my $gemm_psum_accumulated_start = $gemm_psum_number_start + $gemm_psum_number_bits;

my $gemm_tile_m_end = $gemm_tile_m_start + $gemm_tile_m_bits - 1;
my $gemm_n_groups_end = $gemm_n_groups_start + $gemm_n_groups_bits - 1;
my $gemm_k_groups_end = $gemm_k_groups_start + $gemm_k_groups_bits - 1;
my $gemm_ifmap_highaddr_end = $gemm_ifmap_highaddr_start + $gemm_ifmap_highaddr_bits - 1;
my $gemm_weight_highaddr_end = $gemm_weight_highaddr_start + $gemm_weight_highaddr_bits - 1;
my $gemm_psum_highaddr_end = $gemm_psum_highaddr_start + $gemm_psum_highaddr_bits - 1;
my $gemm_psum_number_end = $gemm_psum_number_start + $gemm_psum_number_bits - 1;
my $gemm_psum_accumulated_end = $gemm_psum_accumulated_start + $gemm_psum_accumulated_bits - 1;


my $code = <<"EOF";
`include "pack.vh"

module pea(
  clk, rst_n,
  work_en, insn,
  done,

  ifmap_sram_raddr, ifmap_sram_ren, ifmap_sram_rdata, ifmap_sram_rresp, ifmap_sram_rsparse,
  ifmapmask_sram_raddr, ifmapmask_sram_ren, ifmapmask_sram_rdata, ifmapmask_sram_rresp,
  weight_sram_raddr, weight_sram_ren, weight_sram_rdata, weight_sram_rresp,
  psum_sram_raddr, psum_sram_ren, psum_sram_rdata, psum_sram_rresp,
  psum_sram_waddr, psum_sram_wen, psum_sram_wdata, psum_sram_wresp,
  ifmap_scale_sram_raddr, ifmap_scale_sram_ren, ifmap_scale_sram_rdata, ifmap_scale_sram_rresp,
  weight_scale_sram_raddr, weight_scale_sram_ren, weight_scale_sram_rdata, weight_scale_sram_rresp,
  outlier_index_sram_raddr, outlier_index_sram_ren, outlier_index_sram_rdata, outlier_index_sram_rresp,

  error
);

parameter conv_config_insn = 0;
parameter conv_execute_insn = 1;
parameter gemm_config_insn = 2;
parameter gemm_execute_insn = 3;
parameter deconv_config_insn = 4;
parameter deconv_execute_insn = 5;

parameter TYPE_IS_INT4 = 0;
parameter TYPE_IS_INT8 = 1;
parameter TYPE_IS_FP16 = 2;
parameter TYPE_IS_BF16 = 3;

parameter parallelism    = $p;
parameter outlier_layers = $layer;
parameter lane           = $lane;

parameter IFMAP_SRAM_ADDRESS_BITS         = $ifmap_sram_address_bits;
parameter IFMAPMASK_SRAM_ADDRESS_BITS     = $weight_sram_address_bits;
parameter WEIGHT_SRAM_ADDRESS_BITS        = $weight_sram_address_bits;
parameter PSUM_SRAM_ADDRESS_BITS          = $psum_sram_address_bits;
parameter IFMAP_SCALE_SRAM_ADDRESS_BITS   = $ifmap_sram_address_bits;
parameter WEIGHT_SCALE_SRAM_ADDRESS_BITS  = $weight_sram_address_bits;
parameter OUTLIER_INDEX_SRAM_ADDRESS_BITS = $ifmap_sram_address_bits;

parameter IFMAP_SRAM_WIDTH         = $ifmap_sram_width;
parameter IFMAPMASK_SRAM_WIDTH     = $ifmapmask_sram_width;
parameter WEIGHT_SRAM_WIDTH        = $weight_sram_width;
parameter PSUM_SRAM_WIDTH          = $psum_sram_width;
parameter IFMAP_SCALE_SRAM_WIDTH   = 32;
parameter WEIGHT_SCALE_SRAM_WIDTH  = 16;
parameter OUTLIER_INDEX_SRAM_WIDTH = $outlier_index_sram_width;

parameter MAX_IFMAP_WIDTH   = $max_ifmap_width;
parameter MAX_IFMAP_HEIGHT  = $max_ifmap_height;
parameter MAX_WEIGHT_WIDTH  = $max_weight_width;
parameter MAX_WEIGHT_HEIGHT = $max_weight_height;
parameter MAX_PSUM_WIDTH    = $max_psum_width;
parameter MAX_PSUM_HEIGHT   = $max_psum_height;
parameter MAX_CHANNEL       = $max_channel;

parameter MAX_IFMAP_WIDTH_BITS     = $max_ifmap_width_bits;
parameter MAX_IFMAP_HEIGHT_BITS    = $max_ifmap_height_bits;
parameter MAX_WEIGHT_WIDTH_BITS    = $max_weight_width_bits;
parameter MAX_WEIGHT_HEIGHT_BITS   = $max_weight_height_bits;
parameter MAX_PSUM_WIDTH_BITS      = $max_psum_width_bits;
parameter MAX_PSUM_HEIGHT_BITS     = $max_psum_height_bits;
parameter MAX_CHANNEL_BITS         = $max_channel_bits;
parameter MAX_PAD_LEFT_BITS        = $max_pad_left_bits;
parameter MAX_PAD_TOP_BITS         = $max_pad_top_bits;
parameter MAX_STRIDE_WIDTH_BITS    = $max_stride_width_bits;
parameter MAX_STRIDE_HEIGHT_BITS   = $max_stride_height_bits;
parameter MAX_DILATION_WIDTH_BITS  = $max_dilation_width_bits;
parameter MAX_DILATION_HEIGHT_BITS = $max_dilation_height_bits;

parameter MAX_TILE_M_BITS   = $max_tile_m_bits;
parameter MAX_K_GROUPS_BITS = $max_k_groups_bits;
parameter MAX_N_GROUPS_BITS = $max_n_groups_bits;

parameter MAX_PSUM_NUMBER_BITS = $max_psum_number_bits;
parameter MAX_WEIGHT_NUMBER_BITS = $max_weight_number_bits;

parameter PE_SERIAL_NUMBER = 0;

parameter PE_NO_ERROR = 0;
parameter PE_DATATYPE_CONFIG_ERROR = 1;
parameter PE_SPARSE_CONFIG_ERROR = 2;
parameter PE_QUANTIZATION_CONFIG_ERROR = 3;
parameter PE_OUTLIER_CONFIG_ERROR = 4;
parameter PE_EXPAND_WEIGHT_SRAM_CONFIG_ERROR = 5;
EOF
print $fh $code;
print $fh "parameter REAL_IFMAP_WIDTH = " . ($p * 16) . ";\n";
print $fh "parameter REAL_OUTLIER_INDEX_WIDTH = " . ($p * 4) . ";\n";
print $fh "\n";
print $fh "input wire         clk;\n";
print $fh "input wire         rst_n;\n";
print $fh "input wire         work_en;\n";
print $fh "input wire [127:0] insn;\n";
print $fh "output wire        done;\n";
print $fh "output wire [2:0]  error;\n";
print $fh "\n";
print $fh "output wire [IFMAP_SRAM_ADDRESS_BITS-1:0] ifmap_sram_raddr;\n";
print $fh "output wire                               ifmap_sram_ren;\n";
print $fh "input  wire [IFMAP_SRAM_WIDTH-1:0]        ifmap_sram_rdata;\n";
print $fh "input  wire                               ifmap_sram_rresp;\n";
print $fh "output wire [1:0]                         ifmap_sram_rsparse;\n";
print $fh "\n";
print $fh "output wire [IFMAPMASK_SRAM_ADDRESS_BITS-1:0] ifmapmask_sram_raddr;\n";
print $fh "output wire                                   ifmapmask_sram_ren;\n";
print $fh "input  wire [IFMAPMASK_SRAM_WIDTH-1:0]        ifmapmask_sram_rdata;\n";
print $fh "input  wire                                   ifmapmask_sram_rresp;\n";
print $fh "\n";
print $fh "output wire [WEIGHT_SRAM_ADDRESS_BITS-1:0] weight_sram_raddr;\n";
print $fh "output wire                                weight_sram_ren;\n";
print $fh "input  wire [WEIGHT_SRAM_WIDTH-1:0]        weight_sram_rdata;\n";
print $fh "input  wire                                weight_sram_rresp;\n";
print $fh "\n";
print $fh "output wire [PSUM_SRAM_ADDRESS_BITS-1:0] psum_sram_raddr;\n";
print $fh "output wire                              psum_sram_ren;\n";
print $fh "input  wire [PSUM_SRAM_WIDTH-1:0]        psum_sram_rdata;\n";
print $fh "input  wire                              psum_sram_rresp;\n";
print $fh "\n";
print $fh "output wire [PSUM_SRAM_ADDRESS_BITS-1:0] psum_sram_waddr;\n";
print $fh "output wire                              psum_sram_wen;\n";
print $fh "output wire [PSUM_SRAM_WIDTH-1:0]        psum_sram_wdata;\n";
print $fh "input  wire                              psum_sram_wresp;\n";
print $fh "\n";
print $fh "output wire [IFMAP_SCALE_SRAM_ADDRESS_BITS-1:0] ifmap_scale_sram_raddr;\n";
print $fh "output wire                                     ifmap_scale_sram_ren;\n";
print $fh "input  wire [IFMAP_SCALE_SRAM_WIDTH-1:0]        ifmap_scale_sram_rdata;\n";
print $fh "input  wire                                     ifmap_scale_sram_rresp;\n";
print $fh "\n";
print $fh "output wire [WEIGHT_SCALE_SRAM_ADDRESS_BITS-1:0] weight_scale_sram_raddr;\n";
print $fh "output wire                                      weight_scale_sram_ren;\n";
print $fh "input  wire [WEIGHT_SCALE_SRAM_WIDTH-1:0]        weight_scale_sram_rdata;\n";
print $fh "input  wire                                      weight_scale_sram_rresp;\n";
print $fh "\n";
print $fh "output wire [OUTLIER_INDEX_SRAM_ADDRESS_BITS-1:0] outlier_index_sram_raddr;\n";
print $fh "output wire                                       outlier_index_sram_ren;\n";
print $fh "input  wire [OUTLIER_INDEX_SRAM_WIDTH-1:0]        outlier_index_sram_rdata;\n";
print $fh "input  wire                                       outlier_index_sram_rresp;\n";
print $fh "\n";
print $fh "reg insn_valid;\n";
print $fh "reg conv_config_done;\n";
print $fh "reg conv_execute_done;\n";
print $fh "reg gemm_config_done;\n";
print $fh "reg gemm_execute_done;\n";
print $fh "reg deconv_config_done;\n";
print $fh "reg deconv_execute_done;\n";
print $fh "reg error_done;\n";
print $fh "wire compute_done;\n";
print $fh "assign done = conv_config_done | conv_execute_done | gemm_config_done | gemm_execute_done | error_done;\n";
print $fh "\n";
print $fh "reg [".($insn_kind_bits-1).":0] insn_kind;\n";
print $fh "reg [".($type_a_bits-1).":0] type_a;\n";
print $fh "reg [".($type_b_bits-1).":0] type_b;\n";
print $fh "reg       type_accumulator;\n";
print $fh "reg [1:0] type_output;\n";
print $fh "wire      sparse_enable;\n";
print $fh "reg [1:0] sparse_base;\n";
print $fh "reg [1:0] sparse_ratio;\n";
print $fh "reg       expand_weight_sram_enable;\n";
print $fh "reg       non_uniform_quantization;\n";
print $fh "reg       outlier_enable;\n";
print $fh "\n";
print $fh "reg [".($ifmap_sram_base_highaddr_bits-1).":0] ifmap_sram_base_highaddr;\n";
print $fh "reg [".($weight_sram_base_highaddr_bits-1).":0] weight_sram_base_highaddr;\n";
print $fh "reg [".($psum_sram_base_highaddr_bits-1).":0] psum_sram_base_highaddr;\n";
print $fh "\n";
print $fh "reg [MAX_STRIDE_WIDTH_BITS:0]     stride_width;\n";
print $fh "reg [MAX_STRIDE_HEIGHT_BITS:0]    stride_height;\n";
print $fh "reg [MAX_DILATION_WIDTH_BITS:0]   dilation_width;\n";
print $fh "reg [MAX_DILATION_HEIGHT_BITS:0]  dilation_height;\n";
print $fh "\n";
print $fh "reg [MAX_IFMAP_WIDTH_BITS:0]      ifmap_width;\n";
print $fh "reg [MAX_IFMAP_HEIGHT_BITS:0]     ifmap_height;\n";
print $fh "reg [MAX_WEIGHT_WIDTH_BITS:0]     weight_width;\n";
print $fh "reg [MAX_WEIGHT_HEIGHT_BITS:0]    weight_height;\n";
print $fh "reg [MAX_WEIGHT_NUMBER_BITS:0]    weight_number;\n";
print $fh "reg [MAX_PSUM_WIDTH_BITS:0]       psum_width;\n";
print $fh "reg [MAX_PSUM_HEIGHT_BITS:0]      psum_height;\n";
print $fh "reg [MAX_CHANNEL_BITS:0]          ic_group;\n";
print $fh "reg [MAX_CHANNEL_BITS:0]          oc_group;\n";
print $fh "reg [MAX_PAD_LEFT_BITS-1:0]       pad_left;\n";
print $fh "reg [MAX_PAD_TOP_BITS-1:0]        pad_top;\n";
print $fh "\n";
print $fh "reg [MAX_TILE_M_BITS:0]   tile_m;\n";
print $fh "reg [MAX_N_GROUPS_BITS:0] n_groups;\n";
print $fh "reg [MAX_K_GROUPS_BITS:0] k_groups;\n";
print $fh "\n";
print $fh "reg [MAX_PSUM_NUMBER_BITS:0] psum_number;\n";
print $fh "reg                          psum_accumulated;\n";
print $fh "reg                          ifmap_scale_enable;\n";
print $fh "reg                          weight_scale_enable;\n";
print $fh "reg                          ifmap_highaddr;\n";
print $fh "reg                          weight_highaddr;\n";
print $fh "reg [1:0]                    psum_highaddr;\n";
print $fh "\n";
print $fh "reg [MAX_IFMAP_HEIGHT_BITS:0]  ifmap_area;\n";
print $fh "reg [MAX_WEIGHT_HEIGHT_BITS:0] weight_area;\n";
print $fh "reg [MAX_PSUM_HEIGHT_BITS:0]   psum_area;\n";
print $fh "\n";
print $fh "reg [MAX_PSUM_WIDTH_BITS-1:0]    psum_width_read_cnt;\n";
print $fh "reg [MAX_PSUM_HEIGHT_BITS-1:0]   psum_height_read_cnt;\n";
print $fh "reg [MAX_WEIGHT_WIDTH_BITS-1:0]  weight_width_read_cnt;\n";
print $fh "reg [MAX_WEIGHT_HEIGHT_BITS-1:0] weight_height_read_cnt;\n";
print $fh "reg [MAX_CHANNEL_BITS-1:0]       weight_ic_group_read_cnt;\n";
print $fh "reg [MAX_CHANNEL_BITS-1:0]       weight_oc_group_read_cnt;\n";
print $fh "\n";
print $fh "reg [MAX_TILE_M_BITS-1:0]   psum_m_tile_read_cnt;\n";
print $fh "reg [MAX_K_GROUPS_BITS-1:0] weight_k_group_read_cnt;\n";
print $fh "reg [MAX_N_GROUPS_BITS-1:0] weight_n_group_read_cnt;\n";
print $fh "\n";
print $fh "reg [MAX_PSUM_NUMBER_BITS:0]   psum_sram_write_cnt;\n";
print $fh "reg [MAX_PSUM_WIDTH_BITS-1:0]  psum_width_write_cnt;\n";
print $fh "reg [MAX_PSUM_HEIGHT_BITS-1:0] psum_height_write_cnt;\n";
print $fh "reg [MAX_CHANNEL_BITS-1:0]     psum_ic_group_write_cnt;\n";
print $fh "reg [MAX_CHANNEL_BITS-1:0]     psum_oc_group_write_cnt;\n";
print $fh "\n";
print $fh "reg [MAX_TILE_M_BITS-1:0]   psum_m_tile_write_cnt;\n";
print $fh "reg [MAX_K_GROUPS_BITS-1:0] psum_k_group_write_cnt;\n";
print $fh "reg [MAX_N_GROUPS_BITS-1:0] psum_n_group_write_cnt;\n";
print $fh "\n";
print $fh "wire psum_width_read_done;\n";
print $fh "wire psum_height_read_done;\n";
print $fh "wire weight_width_read_done;\n";
print $fh "wire weight_height_read_done;\n";
print $fh "wire weight_ic_group_read_done;\n";
print $fh "wire weight_oc_group_read_done;\n";
print $fh "\n";
print $fh "wire psum_width_write_done;\n";
print $fh "wire psum_height_write_done;\n";
print $fh "wire psum_ic_group_write_done;\n";
print $fh "wire psum_oc_group_write_done;\n";
print $fh "\n";
print $fh "wire psum_m_tile_read_done;\n";
print $fh "wire weight_n_group_read_done;\n";
print $fh "wire weight_k_group_read_done;\n";
print $fh "\n";
print $fh "wire psum_m_tile_write_done;\n";
print $fh "wire psum_n_group_write_done;\n";
print $fh "wire psum_k_group_write_done;\n";
print $fh "\n";
print $fh "reg  [IFMAP_SRAM_ADDRESS_BITS-2:0]  ifmap_sram_raddr_reg;\n";
print $fh "reg                                 ifmap_sram_ren_reg;\n";
print $fh "reg  [IFMAP_SRAM_WIDTH-1:0]         ifmap_local_rdata_reg;\n";
print $fh "reg  [WEIGHT_SRAM_ADDRESS_BITS-1:0] weight_sram_raddr_reg;\n";
print $fh "reg                                 weight_sram_ren_reg;\n";
print $fh "wire [PSUM_SRAM_ADDRESS_BITS - 1:0] psum_sram_waddr_wire;\n";
print $fh "reg  [PSUM_SRAM_ADDRESS_BITS - 1:0] psum_sram_waddr_reg;\n";
print $fh "reg                                 psum_sram_wen_reg;\n";
print $fh "reg  [PSUM_SRAM_WIDTH-1:0]          psum_sram_wdata_reg;\n";
print $fh "reg  [PSUM_SRAM_ADDRESS_BITS-1:0]   psum_sram_raddr_reg;\n";
print $fh "reg                                 psum_sram_ren_reg;\n";
print $fh "reg  [PSUM_SRAM_WIDTH-1:0]          psum_local_rdata_reg;\n";
print $fh "\n";
print $fh "reg weight_sram_ping_valid;\n";
print $fh "reg weight_sram_pang_valid;\n";
print $fh "reg weight_sram_ping_loading;\n";
print $fh "reg weight_sram_pang_loading;\n";
print $fh "reg weight_sram_ping_loaded;\n";
print $fh "reg weight_sram_pang_loaded;\n";
print $fh "reg weight_sram_ping_pang_identifier;\n";
print $fh "reg weight_sram_valid_reg;\n";
print $fh "reg ifmapmask_sram_valid_reg;\n";
print $fh "\n";
print $fh "reg [$weight_internal_channel_bits:0] weight_sram_ping_loading_cnt;\n";
print $fh "reg [$weight_internal_channel_bits:0] weight_sram_pang_loading_cnt;\n";
print $fh "\n";
print $fh "reg weight_regfile_ping_wen;\n";
print $fh "reg weight_regfile_pang_wen;\n";
print $fh "reg [$weight_internal_channel_bits:0] weight_regfile_ping_waddr;\n";
print $fh "reg [$weight_internal_channel_bits:0] weight_regfile_pang_waddr;\n";
print $fh "\n";
print $fh "reg weight_ping_pang_loading;\n";
print $fh "reg weight_ping_pang_using;\n";
print $fh "reg psum_sram_valid_reg;\n";
print $fh "reg ifmap_sram_valid_reg;\n";
print $fh "\n";
print $fh "wire [PSUM_SRAM_ADDRESS_BITS-1:0]  psum_sram_raddr_wire;\n";
print $fh "wire [IFMAP_SRAM_ADDRESS_BITS-1:0] ifmap_sram_raddr_wire;\n";
print $fh "wire                               psum_read_zero_wire;\n";
print $fh "reg                                psum_read_zero_reg;\n";
print $fh "reg                                psum_read_zero_reg_delay;\n";
print $fh "\n";
print $fh "reg ifmap_local_rdata_valid;\n";
print $fh "reg psum_local_rdata_valid;\n";
print $fh "\n";
print $fh "wire [IFMAP_SRAM_ADDRESS_BITS-1:0] ifmap_horizontal_offset;\n";
print $fh "wire [IFMAP_SRAM_ADDRESS_BITS-1:0] ifmap_vertical_offset;\n";
print $fh "wire [IFMAP_SRAM_ADDRESS_BITS-1:0] ifmap_col_nopad;\n";
print $fh "wire [IFMAP_SRAM_ADDRESS_BITS-1:0] ifmap_row_nopad;\n";
print $fh "wire                               ifmap_read_zero_wire;\n";
print $fh "reg                                ifmap_read_zero_reg;\n";
print $fh "reg                                ifmap_read_zero_reg_delay;\n";
print $fh "\n";
print $fh "assign ifmap_sram_raddr = {ifmap_highaddr, ifmap_sram_raddr_reg};\n";
print $fh "assign ifmap_sram_ren   = ifmap_sram_ren_reg & !ifmap_read_zero_reg;\n";
print $fh "\n";
print $fh "assign weight_sram_raddr = {weight_highaddr, weight_sram_raddr_reg};\n";
print $fh "assign weight_sram_ren   = weight_sram_ren_reg;\n";
print $fh "\n";
print $fh "assign psum_sram_raddr = {psum_highaddr, psum_sram_raddr_reg};\n";
print $fh "assign psum_sram_waddr = {psum_highaddr, psum_sram_waddr_reg};\n";
print $fh "assign psum_sram_ren   = psum_sram_ren_reg & (!psum_read_zero_reg);\n";
print $fh "assign psum_sram_wen   = psum_sram_wen_reg;\n";
print $fh "assign psum_sram_wdata = psum_sram_wdata_reg;\n";
print $fh "\n";
print $fh "reg execute_start;\n";
print $fh "\n";
print $fh "reg fma_done_reg_stage;\n";
print $fh "reg fma_done_reg;\n";
print $fh "reg accumulator_done_reg_stage;\n";
print $fh "reg accumulator_done_reg;\n";
print $fh "reg compute_done_reg;\n";
print $fh "\n";
print $fh "wire [parallelism * 16 - 1:0]        weight_local_data[0:lane-1];\n";
print $fh "wire [parallelism * 16 * lane - 1:0] weight_ping_data_packed;\n";
print $fh "wire [parallelism * 16 * lane - 1:0] weight_pang_data_packed;\n";
print $fh "wire [parallelism * 16 * lane - 1:0] weight_data_packed;\n";
print $fh "\n";
print $fh "assign weight_data_packed = weight_ping_pang_using ? weight_pang_data_packed : weight_ping_data_packed;\n";
print $fh "\n";
print $fh "`UNPACK_ARRAY(weight_data_unpack_array, weight_data_unpack_idx, parallelism * 16, lane, weight_local_data, weight_data_packed);\n";
print $fh "\n";
print $fh "wire [15:0] weight_scale_local_data[0:lane-1];\n";
print $fh "wire [IFMAPMASK_SRAM_WIDTH-1:0] ifmapmask_local_data[0:lane-1];\n";
print $fh "\n";
print $fh "wire mpt_valid;\n";
print $fh "reg mpt_valid_reg;\n";
print $fh "\n";
print $fh "assign mpt_valid = ifmap_local_rdata_valid & psum_local_rdata_valid;\n";
print $fh "\n";
print $fh "wire [31:0]     mpt_result[0:lane-1];\n";
print $fh "wire [lane-1:0] mpt_done;\n";
print $fh "\n";
print $fh "wire outlier_pe_valid;\n";
print $fh "wire outlier_pe_type;\n";
print $fh "wire outlier_pe_halt;\n";

print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [" . ($weight_sram_width-1) . ":0] weight_layer_${i};\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [" . ($weight_sram_width-1) . ":0] weight_layer_${i}_ping;\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [" . ($weight_sram_width-1) . ":0] weight_layer_${i}_pang;\n";
}
my $weight_idx_width = log($lane)/log(2);
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [" . ($weight_idx_width-1) . ":0] weight_idx_${i};\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [" . ($weight_idx_width-1) . ":0] weight_idx_${i}_ping;\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++) {
  print $fh "wire [" . ($weight_idx_width-1) . ":0] weight_idx_${i}_pang;\n";
}
print $fh "\n";
print $fh "wire [" . ($lane * 32 - 1) . ":0] outlier_pe_result_packed;\n";
print $fh "wire [31:0]   outlier_pe_result[0:lane-1];\n";
print $fh "wire          outlier_pe_done;\n";
$code = <<"EOF";

reg [OUTLIER_INDEX_SRAM_WIDTH-1:0] outlier_index_local_rdata_reg;

reg [IFMAP_SCALE_SRAM_WIDTH-1:0]  ifmap_scale_local_rdata_reg;
reg [WEIGHT_SCALE_SRAM_WIDTH-1:0] weight_scale_local_data_reg_ping[0:lane-1];
reg [WEIGHT_SCALE_SRAM_WIDTH-1:0] weight_scale_local_data_reg_pang[0:lane-1];
reg [IFMAPMASK_SRAM_WIDTH-1:0]    ifmapmask_local_data_reg_ping[0:lane-1];
reg [IFMAPMASK_SRAM_WIDTH-1:0]    ifmapmask_local_data_reg_pang[0:lane-1];

wire [31:0] fma_result[0:lane-1];
wire [31:0] accumulator_result[0:lane-1];
wire [PSUM_SRAM_WIDTH-1:0]  accumulator_result_pack;

`PACK_ARRAY(accumulator_result_pack_array, accumulator_result_pack_idx, 32, lane, accumulator_result, accumulator_result_pack);

wire [REAL_IFMAP_WIDTH-1:0]         ifmap_local_data_wire[0:lane-1];

wire [REAL_IFMAP_WIDTH-1:0] ifmap_sparse_4bit_data[0:lane-1];
wire [REAL_IFMAP_WIDTH-1:0] ifmap_sparse_8bit_data[0:lane-1];
wire [REAL_IFMAP_WIDTH-1:0] ifmap_sparse_16bit_data[0:lane-1];

/* -------------------------------------------------------------------------------------------------------- */
/*                                            instruction Decoder                                           */
/* -------------------------------------------------------------------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_valid <= 0;
  end
  else begin
    if (work_en) begin
      insn_valid <= 1;
    end
    else begin
      insn_valid <= 0;
    end
  end
end

/* -------------------------------------------- Config decoder -------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    insn_kind                 <= 0;
    sparse_base               <= 0;
    sparse_ratio              <= 0;
    non_uniform_quantization  <= 0;
    outlier_enable            <= 0;
    expand_weight_sram_enable <= 1;
    ifmap_sram_base_highaddr  <= PE_SERIAL_NUMBER;
    weight_sram_base_highaddr <= PE_SERIAL_NUMBER;
    psum_sram_base_highaddr   <= PE_SERIAL_NUMBER;
    stride_width              <= 0;
    stride_height             <= 0;
    dilation_width            <= 0;
    dilation_height           <= 0;
  end
  else begin
    if (insn_valid) begin
      insn_kind                <= insn[$insn_kind_end:$insn_kind_start];
      if ((insn[$insn_kind_end:$insn_kind_start] == conv_config_insn) || (insn[$insn_kind_end:$insn_kind_start] == gemm_config_insn) || (insn[$insn_kind_end:$insn_kind_start] == deconv_config_insn)) begin
        sparse_base               <= insn[$sparse_base_end:$sparse_base_start];
        sparse_ratio              <= insn[$sparse_ratio_end:$sparse_ratio_start];
        non_uniform_quantization  <= insn[$non_uniform_quantization_end:$non_uniform_quantization_start];
        outlier_enable            <= insn[$outlier_enable_end:$outlier_enable_start];
        expand_weight_sram_enable <= insn[$expand_weight_sram_start];
        ifmap_sram_base_highaddr  <= insn[$ifmap_sram_base_highaddr_end:$ifmap_sram_base_highaddr_start];
        weight_sram_base_highaddr <= insn[$weight_sram_base_highaddr_end:$weight_sram_base_highaddr_start];
        psum_sram_base_highaddr   <= insn[$psum_sram_base_highaddr_end:$psum_sram_base_highaddr_start];
        if (insn[$insn_kind_end:$insn_kind_start] == conv_config_insn) begin
          stride_width           <= insn[$conv_stride_width_end:$conv_stride_width_start];
          stride_height          <= insn[$conv_stride_height_end:$conv_stride_height_start];
          dilation_width         <= insn[$conv_dilation_width_end:$conv_dilation_width_start];
          dilation_height        <= insn[$conv_dilation_height_end:$conv_dilation_height_start];
        end
        else begin
          stride_width           <= stride_width;
          stride_height          <= stride_height;
          dilation_width         <= dilation_width;
          dilation_height        <= dilation_height;
        end
      end
      else begin
        sparse_base               <= sparse_base;
        sparse_ratio              <= sparse_ratio;
        non_uniform_quantization  <= non_uniform_quantization;
        outlier_enable            <= outlier_enable;
        expand_weight_sram_enable <= expand_weight_sram_enable;
        ifmap_sram_base_highaddr  <= ifmap_sram_base_highaddr;
        weight_sram_base_highaddr <= weight_sram_base_highaddr;
        psum_sram_base_highaddr   <= psum_sram_base_highaddr;
        stride_width              <= stride_width;
        stride_height             <= stride_height;
        dilation_width            <= dilation_width;
        dilation_height           <= dilation_height;
      end
    end
    else begin
      insn_kind                 <= insn_kind;
      sparse_base               <= sparse_base;
      sparse_ratio              <= sparse_ratio;
      non_uniform_quantization  <= non_uniform_quantization;
      outlier_enable            <= outlier_enable;
      expand_weight_sram_enable <= expand_weight_sram_enable;
      ifmap_sram_base_highaddr  <= ifmap_sram_base_highaddr;
      weight_sram_base_highaddr <= weight_sram_base_highaddr;
      psum_sram_base_highaddr   <= psum_sram_base_highaddr;
      stride_width              <= stride_width;
      stride_height             <= stride_height;
      dilation_width            <= dilation_width;
      dilation_height           <= dilation_height;
    end
  end
end

assign sparse_enable = |sparse_ratio;

/* -------------------------------------------- execute decoder ------------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    execute_start       <= 0;
    type_a              <= 0;
    type_b              <= 0;
    type_accumulator    <= 0;
    type_output         <= 0;
    ifmap_width         <= 0;
    ifmap_height        <= 0;
    weight_width        <= 0;
    weight_height       <= 0;
    weight_number       <= 0;
    psum_width          <= 0;
    psum_height         <= 0;
    ic_group            <= 0;
    oc_group            <= 0;
    pad_left            <= 0;
    pad_top             <= 0;
    psum_number         <= 0;
    psum_accumulated    <= 0;
    ifmap_highaddr      <= 0;
    weight_highaddr     <= 0;
    psum_highaddr       <= 0;
    ifmap_area          <= 0;
    weight_area         <= 0;
    psum_area           <= 0;
    tile_m              <= 0;
    n_groups            <= 0;
    k_groups            <= 0;
    ifmap_scale_enable  <= 0;
    weight_scale_enable <= 0;
  end
  else begin
    if (insn_valid) begin
      if ((insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn) || (insn[$insn_kind_end:$insn_kind_start] == gemm_execute_insn) || (insn[$insn_kind_end:$insn_kind_start] == deconv_execute_insn)) begin
        execute_start    <= 1;
        type_a           <= insn[$type_a_end:$type_a_start];
        type_b           <= insn[$type_b_end:$type_b_start];
        type_accumulator <= insn[$type_accumulator_start];
        type_output      <= insn[$type_output_end:$type_output_start];
        ifmap_scale_enable <= (~|insn[$type_a_end:$type_a_start]) & (~|insn[$type_b_end:$type_b_start]) & insn[$type_accumulator_start] & insn[$type_output_start];
        weight_scale_enable <= (~|insn[$type_a_end:$type_a_start]) & (~|insn[$type_b_end:$type_b_start]) & insn[$type_accumulator_start] & insn[$type_output_start];
        if (insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn) begin
          ifmap_width      <= insn[$conv_ifmap_width_end:$conv_ifmap_width_start] + 1;
          ifmap_height     <= insn[$conv_ifmap_height_end:$conv_ifmap_height_start] + 1;
          weight_width     <= insn[$conv_weight_width_end:$conv_weight_width_start] + 1;
          weight_height    <= insn[$conv_weight_height_end:$conv_weight_height_start] + 1;
          weight_number    <= (insn[$conv_weight_height_end:$conv_weight_height_start] + 1) * (insn[$conv_weight_width_end:$conv_weight_width_start] + 1) * (insn[$conv_oc_group_end:$conv_oc_group_start] + 1) * (insn[$conv_ic_group_end:$conv_ic_group_start] + 1) * 64;
          psum_width       <= insn[$conv_psum_width_end:$conv_psum_width_start] + 1;
          psum_height      <= insn[$conv_psum_height_end:$conv_psum_height_start] + 1;
          ic_group         <= insn[$conv_ic_group_end:$conv_ic_group_start] + 1;
          oc_group         <= insn[$conv_oc_group_end:$conv_oc_group_start] + 1;
          ifmap_highaddr   <= insn[$conv_ifmap_highaddr_start];
          weight_highaddr  <= insn[$conv_weight_highaddr_start];
          psum_highaddr    <= insn[$conv_psum_highaddr_end:$conv_psum_highaddr_start];
          pad_left         <= insn[$conv_pad_left_end:$conv_pad_left_start];
          pad_top          <= insn[$conv_pad_top_end:$conv_pad_top_start];
          psum_number      <= insn[$conv_psum_number_end:$conv_psum_number_start];
          psum_accumulated <= insn[$conv_psum_accumulated_start];
          ifmap_area       <= (insn[$conv_ifmap_height_end:$conv_ifmap_height_start] + 1) * (insn[$conv_ifmap_width_end:$conv_ifmap_width_start] + 1);
          weight_area      <= (insn[$conv_weight_height_end:$conv_weight_height_start] + 1) * (insn[$conv_weight_width_end:$conv_weight_width_start] + 1);
          psum_area        <= (insn[$conv_psum_height_end:$conv_psum_height_start] + 1) * (insn[$conv_psum_width_end:$conv_psum_width_start] + 1);
        end
        else if (insn[$insn_kind_end:$insn_kind_start] == gemm_execute_insn) begin
          tile_m           <= insn[$gemm_tile_m_end:$gemm_tile_m_start] + 1;
          n_groups         <= insn[$gemm_n_groups_end:$gemm_n_groups_start] + 1;
          k_groups         <= insn[$gemm_k_groups_end:$gemm_k_groups_start] + 1;
          ifmap_highaddr   <= insn[$gemm_ifmap_highaddr_end:$gemm_ifmap_highaddr_start];
          weight_highaddr  <= insn[$gemm_weight_highaddr_end:$gemm_weight_highaddr_start];
          psum_highaddr    <= insn[$gemm_psum_highaddr_end:$gemm_psum_highaddr_start];
          psum_number      <= insn[$gemm_psum_number_end:$gemm_psum_number_start];
          psum_accumulated <= insn[$gemm_psum_accumulated_start];
          weight_number    <= (insn[$gemm_n_groups_end:$gemm_n_groups_start] + 1) * (insn[$gemm_k_groups_end:$gemm_k_groups_start] + 1) * 64;
        end
        else begin
        end
      end
      else begin
        execute_start    <= 0;
        type_a           <= type_a;
        type_b           <= type_b;
        type_accumulator <= type_accumulator;
        type_output      <= type_output;
        ifmap_width      <= ifmap_width;
        ifmap_height     <= ifmap_height;
        weight_width     <= weight_width;
        weight_height    <= weight_height;
        weight_number    <= weight_number;
        psum_width       <= psum_width;
        psum_height      <= psum_height;
        ic_group         <= ic_group;
        oc_group         <= oc_group;
        pad_left         <= pad_left;
        pad_top          <= pad_top;
        psum_number      <= psum_number;
        psum_accumulated <= psum_accumulated;
        ifmap_highaddr   <= ifmap_highaddr;
        weight_highaddr  <= weight_highaddr;
        psum_highaddr    <= psum_highaddr;
        ifmap_area       <= ifmap_area;
        weight_area      <= weight_area;
        psum_area        <= psum_area;
      end
    end
    else begin
      if (done) begin
        execute_start    <= 0;
        ifmap_width      <= 0;
        ifmap_height     <= 0;
        weight_width     <= 0;
        weight_height    <= 0;
        weight_number    <= 0;
        psum_width       <= 0;
        psum_height      <= 0;
        ic_group         <= 0;
        oc_group         <= 0;
        pad_left         <= 0;
        pad_top          <= 0;
        stride_width     <= 0;
        stride_height    <= 0;
        dilation_width   <= 0;
        dilation_height  <= 0;
        psum_number      <= 0;
        psum_accumulated <= 0;
        ifmap_highaddr   <= 0;
        weight_highaddr  <= 0;
        psum_highaddr    <= 0;
        ifmap_area       <= 0;
        weight_area      <= 0;
        psum_area        <= 0;
        tile_m           <= 0;
        n_groups         <= 0;
        k_groups         <= 0;
      end
      else begin
        execute_start    <= execute_start;
        ifmap_width      <= ifmap_width;
        ifmap_height     <= ifmap_height;
        weight_width     <= weight_width;
        weight_height    <= weight_height;
        weight_number    <= weight_number;
        psum_width       <= psum_width;
        psum_height      <= psum_height;
        ic_group         <= ic_group;
        oc_group         <= oc_group;
        pad_left         <= pad_left;
        pad_top          <= pad_top;
        stride_width     <= stride_width;
        stride_height    <= stride_height;
        dilation_width   <= dilation_width;
        dilation_height  <= dilation_height;
        psum_number      <= psum_number;
        psum_accumulated <= psum_accumulated;
        ifmap_highaddr   <= ifmap_highaddr;
        weight_highaddr  <= weight_highaddr;
        psum_highaddr    <= psum_highaddr;
        ifmap_area       <= ifmap_area;
        weight_area      <= weight_area;
        psum_area        <= psum_area;
        tile_m           <= tile_m;
        n_groups         <= n_groups;
        k_groups         <= k_groups;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        Weight SRAM Read Controller                                       */
/* -------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------- Weight SRAM Read Enable --------------------------------------- */

assign weight_width_read_done    = (weight_width_read_cnt == (weight_width - 1)) & execute_start;
assign weight_height_read_done   = (weight_height_read_cnt == (weight_height - 1)) & execute_start;
assign weight_ic_group_read_done = (weight_ic_group_read_cnt == (ic_group - 1)) & execute_start;
assign weight_oc_group_read_done = (weight_oc_group_read_cnt == (oc_group - 1)) & execute_start;

assign weight_n_group_read_done  = (weight_n_group_read_cnt == (n_groups - 1)) & execute_start;
assign weight_k_group_read_done  = (weight_k_group_read_cnt == (k_groups - 1)) & execute_start;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_ren_reg <= 1'b0;
  end
  else begin
    if (execute_start && !done) begin
      if (weight_sram_raddr_reg == weight_number) begin
        weight_sram_ren_reg <= 1'b0;
      end
      else begin
        if (weight_sram_ping_valid && weight_sram_pang_valid) begin
          weight_sram_ren_reg <= 1'b0;
        end
        else begin
          if ((weight_sram_ping_loading_cnt == lane - 1) || (weight_sram_pang_loading_cnt == lane - 1)) begin
            weight_sram_ren_reg <= 1'b0;
          end
          else begin
            weight_sram_ren_reg <= 1'b1;
          end
        end
      end
    end
    else begin
      if (done) begin
        weight_sram_ren_reg <= 1'b0;
      end
      else begin
        weight_sram_ren_reg <= weight_sram_ren_reg;
      end
    end
  end
end

/* --------------------------------------- Weight SRAM Read Address --------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_raddr_reg <= 0;
  end
  else begin
    if (insn_valid && (!(execute_start && !done))) begin
      weight_sram_raddr_reg <= weight_sram_base_highaddr;
    end
    else if (execute_start && !done) begin
      if (weight_sram_ren && weight_sram_rresp && ((!weight_scale_enable) | (weight_scale_enable & weight_scale_sram_rresp)) && ((!sparse_enable) | (sparse_enable & ifmapmask_sram_rresp))) begin
        weight_sram_raddr_reg <= weight_sram_raddr_reg + 1;
      end
      else begin
        weight_sram_raddr_reg <= weight_sram_raddr;
      end
    end
    else begin
      weight_sram_raddr_reg <= weight_sram_raddr;
    end
  end
end

/* --------------------------------------- Weight SRAM Read Counter --------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_width_read_cnt    <= 0;
    weight_height_read_cnt   <= 0;
    weight_ic_group_read_cnt <= 0;
    weight_oc_group_read_cnt <= 0;
    weight_n_group_read_cnt  <= 0;
    weight_k_group_read_cnt  <= 0;
  end
  else begin
    if (execute_start && !done) begin
      if (insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn) begin
        if (psum_height_read_done && psum_width_read_done) begin
          if (weight_width_read_done) begin
            weight_width_read_cnt <= 'd0;
          end
          else begin
            weight_width_read_cnt <= weight_width_read_cnt + 1;
          end
        end
        else begin
          weight_width_read_cnt <= weight_width_read_cnt;
        end

        if (weight_width_read_done && psum_height_read_done && psum_width_read_done) begin
          if (weight_height_read_done) begin
            weight_height_read_cnt <= 'd0;
          end
          else begin
            weight_height_read_cnt <= weight_height_read_cnt + 1;
          end
        end
        else begin
          weight_height_read_cnt <= weight_height_read_cnt;
        end

        if (weight_height_read_done && weight_width_read_done && psum_height_read_done && psum_width_read_done) begin
          if (weight_ic_group_read_done) begin
            weight_ic_group_read_cnt <= 'd0;
          end
          else begin
            weight_ic_group_read_cnt <= weight_ic_group_read_cnt + 1;
          end
        end
        else begin
          weight_ic_group_read_cnt <= weight_ic_group_read_cnt;
        end

        if (weight_ic_group_read_done && weight_height_read_done && weight_width_read_done && psum_height_read_done && psum_width_read_done) begin
          if (weight_oc_group_read_done) begin
            weight_oc_group_read_cnt <= 'd0;
          end
          else begin
            weight_oc_group_read_cnt <= weight_oc_group_read_cnt + 1;
          end
        end
        else begin
          weight_oc_group_read_cnt <= weight_oc_group_read_cnt;
        end

        weight_n_group_read_cnt <= 'd0;
        weight_k_group_read_cnt <= 'd0;
      end
      else if (insn[$insn_kind_end:$insn_kind_start] == gemm_execute_insn) begin
        if (psum_m_tile_read_done) begin
          if (weight_k_group_read_done) begin
            weight_k_group_read_cnt <= 'd0;
          end
          else begin
            weight_k_group_read_cnt <= weight_k_group_read_cnt + 1;
          end
        end

        if (weight_k_group_read_done && psum_m_tile_read_done) begin
          if (weight_n_group_read_done) begin
            weight_n_group_read_cnt <= 'd0;
          end
          else begin
            weight_n_group_read_cnt <= weight_n_group_read_cnt + 1;
          end
        end

        weight_width_read_cnt    <= 'd0;
        weight_height_read_cnt   <= 'd0;
        weight_ic_group_read_cnt <= 'd0;
        weight_oc_group_read_cnt <= 'd0;
      end
      else begin
        weight_width_read_cnt    <= weight_width_read_cnt;
        weight_height_read_cnt   <= weight_height_read_cnt;
        weight_ic_group_read_cnt <= weight_ic_group_read_cnt;
        weight_oc_group_read_cnt <= weight_oc_group_read_cnt;
        weight_n_group_read_cnt  <= weight_n_group_read_cnt;
        weight_k_group_read_cnt  <= weight_k_group_read_cnt;
      end
    end
    else begin
      if (done) begin
        weight_width_read_cnt    <= 0;
        weight_height_read_cnt   <= 0;
        weight_ic_group_read_cnt <= 0;
        weight_oc_group_read_cnt <= 0;
        weight_n_group_read_cnt  <= 0;
        weight_k_group_read_cnt  <= 0;
      end
      else begin
        weight_width_read_cnt    <= weight_width_read_cnt;
        weight_height_read_cnt   <= weight_height_read_cnt;
        weight_ic_group_read_cnt <= weight_ic_group_read_cnt;
        weight_oc_group_read_cnt <= weight_oc_group_read_cnt;
        weight_n_group_read_cnt  <= weight_n_group_read_cnt;
        weight_k_group_read_cnt  <= weight_k_group_read_cnt;
      end
    end
  end
end

/* ----------------------------------- Weight SRAM Ping-Pang Controller ----------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_sram_ping_valid           <= 1'b0;
    weight_sram_pang_valid           <= 1'b0;
    weight_sram_ping_loading         <= 1'b0;
    weight_sram_pang_loading         <= 1'b0;
    weight_sram_ping_loading_cnt     <= 0;
    weight_sram_pang_loading_cnt     <= 0;
    weight_sram_ping_pang_identifier <= 1'b0;
    weight_regfile_pang_waddr        <= 'd0;
    weight_regfile_ping_waddr        <= 'd0;
  end
  else begin
    if (execute_start && !done) begin
      weight_regfile_ping_waddr <= weight_sram_ping_loading_cnt;
      weight_regfile_pang_waddr <= weight_sram_pang_loading_cnt;
      
      if (weight_sram_ping_valid && weight_sram_pang_valid) begin
        weight_sram_ping_loading     <= 1'b0;
        weight_sram_pang_loading     <= 1'b0;
        weight_sram_ping_loading_cnt <= weight_sram_ping_loading_cnt;
        weight_sram_pang_loading_cnt <= weight_sram_pang_loading_cnt;
      end
      else begin
        if (weight_sram_ping_loading || ((!weight_sram_ping_loading) && (!weight_sram_pang_loading) && (!weight_sram_ping_valid))) begin
          if (weight_sram_ping_loading_cnt == 64 - 1) begin
            weight_sram_ping_loading <= 1'b0;
          end
          else begin
            weight_sram_ping_loading <= 1'b1;
          end
          weight_sram_pang_loading <= 1'b0;
        end
        else begin
          if (weight_sram_pang_loading_cnt == 64 - 1) begin
            weight_sram_pang_loading <= 1'b0;
          end
          else begin
            weight_sram_pang_loading <= 1'b1;
          end
        end

        if (weight_sram_ping_loading && (weight_sram_ping_loading_cnt == 64 - 1)) begin
          weight_sram_ping_loading_cnt <= 0;
        end
        else if (weight_sram_ping_loading) begin
          weight_sram_ping_loading_cnt <= weight_sram_ping_loading_cnt + 1;
        end
        else begin
          weight_sram_ping_loading_cnt <= weight_sram_ping_loading_cnt;
        end

        if (weight_sram_pang_loading && (weight_sram_pang_loading_cnt == 64 - 1)) begin
          weight_sram_pang_loading_cnt <= 0;
        end
        else if (weight_sram_pang_loading) begin
          weight_sram_pang_loading_cnt <= weight_sram_pang_loading_cnt + 1;
        end
        else begin
          weight_sram_pang_loading_cnt <= weight_sram_pang_loading_cnt;
        end
      end

      if ((psum_width_read_done && psum_height_read_done) || (psum_m_tile_read_done)) begin
        weight_sram_ping_pang_identifier <= ~weight_sram_ping_pang_identifier;
      end
      else begin
        weight_sram_ping_pang_identifier <= weight_sram_ping_pang_identifier;
      end

      if (weight_sram_ping_loading && (weight_sram_ping_loading_cnt == lane - 1)) begin
          weight_sram_ping_valid <= 1'b1;
      end
      else if (weight_sram_ping_pang_identifier) begin
        weight_sram_ping_valid <= weight_sram_ping_valid;
      end
      else begin
        if ((psum_width_read_done && psum_height_read_done) || (psum_m_tile_read_done)) begin
          weight_sram_ping_valid <= 1'b0;
        end
        else begin
          weight_sram_ping_valid <= weight_sram_ping_valid;
        end
      end

      if (weight_sram_pang_loading && (weight_sram_pang_loading_cnt == lane - 1)) begin
        weight_sram_pang_valid <= 1'b1;
      end
      else if (weight_sram_ping_pang_identifier) begin
        if ((psum_width_read_done && psum_height_read_done) || (psum_m_tile_read_done)) begin
          weight_sram_pang_valid <= 1'b0;
        end
        else begin
          weight_sram_pang_valid <= weight_sram_pang_valid;
        end
      end
      else begin
        weight_sram_pang_valid <= weight_sram_pang_valid;
      end
    end
    else begin
      if (done) begin
        weight_sram_ping_valid           <= 1'b0;
        weight_sram_pang_valid           <= 1'b0;
        weight_sram_ping_loading         <= 1'b0;
        weight_sram_pang_loading         <= 1'b0;
        weight_sram_ping_loading_cnt     <= 0;
        weight_sram_pang_loading_cnt     <= 0;
        weight_sram_ping_pang_identifier <= 1'b0;
      end
      else begin
        weight_sram_ping_valid           <= weight_sram_ping_valid;
        weight_sram_pang_valid           <= weight_sram_pang_valid;
        weight_sram_ping_loading         <= weight_sram_ping_loading;
        weight_sram_pang_loading         <= weight_sram_pang_loading;
        weight_sram_ping_loading_cnt     <= weight_sram_ping_loading_cnt;
        weight_sram_pang_loading_cnt     <= weight_sram_pang_loading_cnt;
        weight_sram_ping_pang_identifier <= weight_sram_ping_pang_identifier;
      end
    end
  end
end

/* ------------------------------------ Weight Regfile Write Controller ----------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_regfile_pang_wen <= 'd0;
    weight_regfile_ping_wen <= 'd0;
  end
  else begin
    if (weight_sram_ren && weight_sram_ping_loading) begin
      weight_regfile_ping_wen <= 1'b1;
    end
    else begin
      weight_regfile_ping_wen <= 1'b0;
    end

    if (weight_sram_ren && weight_sram_pang_loading) begin
      weight_regfile_pang_wen <= 1'b1;
    end
    else begin
      weight_regfile_pang_wen <= 1'b0;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                         Ifmap SRAM Read Contoller                                        */
/* -------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------- Ifmap SRAM Read Address --------------------------------------- */

assign ifmap_horizontal_offset = psum_width_read_cnt * stride_width + weight_width_read_cnt * dilation_width;
assign ifmap_vertical_offset = psum_height_read_cnt * stride_height + weight_height_read_cnt * dilation_height;
assign ifmap_col_nopad = ifmap_horizontal_offset - pad_left;
assign ifmap_row_nopad = ifmap_vertical_offset - pad_top;
assign ifmap_read_zero_wire = insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn ? (ifmap_horizontal_offset < pad_left) || (ifmap_col_nopad > ifmap_width - 1) 
                              || (ifmap_vertical_offset < pad_top) || (ifmap_row_nopad > ifmap_height - 1) : 
                              0;
assign ifmap_sram_raddr_wire = insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn ? weight_ic_group_read_cnt * ifmap_area + ifmap_row_nopad * ifmap_width + ifmap_col_nopad + ifmap_sram_base_highaddr :
                               psum_m_tile_read_cnt + ifmap_sram_base_highaddr;

/* ---------------------------------------- Ifmap SRAM Read Enable ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_ren_reg       <= 1'b0;
    ifmap_read_zero_reg      <= 1'b0;
    ifmap_sram_raddr_reg     <= 0;
  end
  else begin
    if (execute_start && !done) begin
      if ((!weight_sram_ping_pang_identifier && weight_sram_ping_valid) || (weight_sram_ping_pang_identifier && weight_sram_pang_valid)) begin
        ifmap_sram_ren_reg   <= 1'b1;
        ifmap_read_zero_reg  <= ifmap_read_zero_wire;
        ifmap_sram_raddr_reg <= ifmap_sram_raddr_wire;
      end
      else begin
        ifmap_sram_ren_reg   <= 1'b0;
        ifmap_sram_raddr_reg <= ifmap_sram_raddr_reg;
        ifmap_read_zero_reg  <= ifmap_read_zero_reg;
      end
    end
    else begin
      if (done) begin
        ifmap_sram_ren_reg       <= 1'b0;
        ifmap_read_zero_reg      <= 1'b0;
        ifmap_sram_raddr_reg     <= 0;
      end
      else begin
        ifmap_sram_ren_reg       <= ifmap_sram_ren_reg;
        ifmap_read_zero_reg      <= ifmap_read_zero_reg;
        ifmap_sram_raddr_reg     <= ifmap_sram_raddr_reg;
      end
    end
  end
end

/* ----------------------------------------- Ifmap SRAM Read Data ----------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_sram_valid_reg      <= 1'b0;
    ifmap_read_zero_reg_delay <= 1'b0;
    ifmap_local_rdata_reg   <= 0;
    ifmap_local_rdata_valid <= 1'b0;
  end
  else begin
    if (ifmap_sram_ren_reg) begin
      ifmap_sram_valid_reg      <= 1'b1;
      ifmap_read_zero_reg_delay <= ifmap_read_zero_reg;
    end
    else begin
      ifmap_sram_valid_reg      <= 1'b0;
      ifmap_read_zero_reg_delay <= 1'b0;
    end

    if (ifmap_sram_valid_reg) begin
      ifmap_local_rdata_reg   <= ifmap_read_zero_reg_delay ? 0 : ifmap_sram_rdata;
      ifmap_local_rdata_valid <= ifmap_sram_valid_reg;
    end
    else begin
      ifmap_local_rdata_reg   <= ifmap_local_rdata_reg;
      ifmap_local_rdata_valid <= 1'b0;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                         Psum SRAM Read Controller                                        */
/* -------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------- Psum SRAM Read Address ---------------------------------------- */

assign psum_width_read_done  = (psum_width_read_cnt == (psum_width - 1)) & execute_start;
assign psum_height_read_done = (psum_height_read_cnt == (psum_height - 1)) & execute_start;

assign psum_read_zero_wire = psum_accumulated ? 1'b0 : (insn_kind == conv_execute_insn & ((~|weight_ic_group_read_cnt) & (~|weight_width_read_cnt) & (~|weight_height_read_cnt))) | (insn_kind == gemm_execute_insn & ((~|weight_n_group_read_cnt) & (~|weight_k_group_read_cnt)));
assign psum_sram_raddr_wire = insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn ? weight_oc_group_read_cnt * psum_area + psum_height_read_cnt * psum_width + psum_width_read_cnt + psum_sram_base_highaddr :
                              weight_n_group_read_cnt * tile_m + psum_m_tile_read_cnt + psum_sram_base_highaddr;

assign psum_m_tile_read_done = (psum_m_tile_read_cnt == (tile_m - 1)) & execute_start;

/* ---------------------------------------- Psum SRAM Read Counter ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_width_read_cnt  <= 0;
    psum_height_read_cnt <= 0;
    psum_m_tile_read_cnt <= 0;
  end
  else begin
    if (execute_start && !done) begin
      if (insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn) begin
        if ((!weight_sram_ping_pang_identifier && weight_sram_ping_valid) || (weight_sram_ping_pang_identifier && weight_sram_pang_valid)) begin
          if (psum_width_read_done) begin
            psum_width_read_cnt <= 'd0;
          end
          else if (((ifmap_read_zero_wire) | (!ifmap_read_zero_wire & ifmap_sram_rresp)) & ((psum_read_zero_wire) | (!psum_read_zero_wire & psum_sram_rresp))) begin
            psum_width_read_cnt <= psum_width_read_cnt + 1;
          end
          else begin
            psum_width_read_cnt <= psum_width_read_cnt;
          end
        end
        else begin
          psum_width_read_cnt  <= psum_width_read_cnt;
        end

        if (psum_width_read_done) begin
          if (psum_height_read_done) begin
            psum_height_read_cnt <= 'd0;
          end
          else begin
            psum_height_read_cnt <= psum_height_read_cnt + 1;
          end
        end
        else begin
          psum_height_read_cnt <= psum_height_read_cnt;
        end

        psum_m_tile_read_cnt <= 0;
      end
      else begin
        if ((!weight_sram_ping_pang_identifier && weight_sram_ping_valid) || (weight_sram_ping_pang_identifier && weight_sram_pang_valid)) begin
          if (psum_m_tile_read_done) begin
            psum_m_tile_read_cnt <= 'd0;
          end
          else begin
            psum_m_tile_read_cnt <= psum_m_tile_read_cnt + 1;
          end
        end
        else begin
          psum_m_tile_read_cnt <= psum_m_tile_read_cnt;
        end

        psum_width_read_cnt  <= 0;
        psum_height_read_cnt <= 0;
      end
    end
    else begin
      if (done) begin
        psum_width_read_cnt  <= 0;
        psum_height_read_cnt <= 0;
        psum_m_tile_read_cnt <= 0;
      end
      else begin
        psum_width_read_cnt  <= psum_width_read_cnt;
        psum_height_read_cnt <= psum_height_read_cnt;
        psum_m_tile_read_cnt <= psum_m_tile_read_cnt;
      end
    end
  end
end

/* ----------------------------------------- Psum SRAM Read Enable ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_ren_reg        <= 1'b0;
    psum_read_zero_reg       <= 1'b0;
    psum_sram_raddr_reg      <= 0;
  end
  else begin
    if (execute_start && !done) begin
      if ((!weight_sram_ping_pang_identifier && weight_sram_ping_valid) || (weight_sram_ping_pang_identifier && weight_sram_pang_valid)) begin
        psum_sram_ren_reg    <= 1'b1;
        psum_read_zero_reg   <= psum_read_zero_wire;
        psum_sram_raddr_reg  <= psum_sram_raddr_wire;
      end
      else begin
        psum_sram_ren_reg    <= 1'b0;
        psum_sram_raddr_reg  <= psum_sram_raddr_reg;
        psum_read_zero_reg   <= psum_read_zero_reg;
      end
    end
    else begin
      if (done) begin
        psum_sram_ren_reg        <= 1'b0;
        psum_read_zero_reg       <= 1'b0;
        psum_sram_raddr_reg      <= 0;
      end
      else begin
        psum_sram_ren_reg        <= psum_sram_ren_reg;
        psum_sram_raddr_reg      <= psum_sram_raddr_reg;
        psum_read_zero_reg       <= psum_read_zero_reg;
      end
    end
  end
end

/* ------------------------------------------ Psum SRAM Read Data ----------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_valid_reg       <= 1'b0;
    psum_read_zero_reg_delay  <= 1'b0;
    psum_local_rdata_reg    <= 0;
    psum_local_rdata_valid  <= 1'b0;
  end
  else begin
    if (psum_sram_ren_reg) begin
      psum_sram_valid_reg      <= 1'b1;
      psum_read_zero_reg_delay <= psum_read_zero_reg;
    end
    else begin
      psum_sram_valid_reg      <= 1'b0;
      psum_read_zero_reg_delay <= 1'b0;
    end

    if (psum_sram_valid_reg) begin
      psum_local_rdata_reg   <= psum_read_zero_reg_delay ? 0 : psum_sram_rdata;
      psum_local_rdata_valid <= psum_sram_valid_reg;
    end
    else begin
      psum_local_rdata_reg   <= psum_local_rdata_reg;
      psum_local_rdata_valid <= 1'b0;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                        Psum SRAM Write Controller                                        */
/* -------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------- Psum SRAM Write Address --------------------------------------- */

assign psum_sram_waddr_wire     = insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn ? psum_oc_group_write_cnt * psum_area + psum_height_write_cnt * psum_width + psum_width_write_cnt + psum_sram_base_highaddr :
                                  psum_n_group_write_cnt * tile_m + psum_m_tile_write_cnt + psum_sram_base_highaddr;

assign psum_width_write_done    = (psum_width_write_cnt == (psum_width - 1)) & execute_start & (compute_done | compute_done_reg);
assign psum_height_write_done   = (psum_height_write_cnt == (psum_height - 1)) & execute_start & (compute_done | compute_done_reg);
assign psum_ic_group_write_done = (psum_ic_group_write_cnt == (ic_group - 1)) & execute_start & (compute_done | compute_done_reg);
assign psum_oc_group_write_done = (psum_oc_group_write_cnt == (oc_group - 1)) & execute_start & (compute_done | compute_done_reg);

assign psum_m_tile_write_done = (psum_m_tile_write_cnt == (tile_m - 1)) & execute_start & (compute_done | compute_done_reg);
assign psum_n_group_write_done = (psum_n_group_write_cnt == (n_groups - 1)) & execute_start & (compute_done | compute_done_reg);
assign psum_k_group_write_done = (psum_k_group_write_cnt == (k_groups - 1)) & execute_start & (compute_done | compute_done_reg);

/* ---------------------------------------- Psum SRAM Write Counter --------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_width_write_cnt    <= 0;
    psum_height_write_cnt   <= 0;
    psum_ic_group_write_cnt <= 0;
    psum_oc_group_write_cnt <= 0;
    psum_m_tile_write_cnt   <= 0;
    psum_n_group_write_cnt  <= 0;
    psum_k_group_write_cnt  <= 0;
  end
  else begin
    if (execute_start && !done) begin
      if (insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn) begin
        if (compute_done) begin
          if (psum_width_write_done) begin
            psum_width_write_cnt <= 'd0;
          end
          else if (psum_sram_wresp) begin
            psum_width_write_cnt <= psum_width_write_cnt + 1;
          end
          else begin
            psum_width_write_cnt <= psum_width_write_cnt;
          end

          if (psum_width_write_done) begin
            if (psum_height_write_done) begin
              psum_height_write_cnt <= 'd0;
            end
            else begin
              psum_height_write_cnt <= psum_height_write_cnt + 1;
            end
          end
          else begin
            psum_height_write_cnt <= psum_height_write_cnt;
          end

          if (psum_height_write_done && psum_width_write_done) begin
            if (psum_ic_group_write_done) begin
              psum_ic_group_write_cnt <= 'd0;
            end
            else begin
              psum_ic_group_write_cnt <= psum_ic_group_write_cnt + 1;
            end
          end
          else begin
            psum_ic_group_write_cnt <= psum_ic_group_write_cnt;
          end

          if (psum_ic_group_write_done && psum_height_write_done && psum_width_write_done) begin
            if (psum_oc_group_write_done) begin
              psum_oc_group_write_cnt <= 'd0;
            end
            else begin
              psum_oc_group_write_cnt <= psum_oc_group_write_cnt + 1;
            end
          end
          else begin
            psum_oc_group_write_cnt <= psum_oc_group_write_cnt;
          end
        end
        else begin
          psum_width_write_cnt    <= psum_width_write_cnt;
          psum_height_write_cnt   <= psum_height_write_cnt;
          psum_ic_group_write_cnt <= psum_ic_group_write_cnt;
          psum_oc_group_write_cnt <= psum_oc_group_write_cnt;
        end

        psum_m_tile_write_cnt   <= 0;
        psum_n_group_write_cnt  <= 0;
        psum_k_group_write_cnt  <= 0;
      end
      else if (insn[$insn_kind_end:$insn_kind_start] == gemm_execute_insn) begin
        if (compute_done) begin
          if (psum_m_tile_write_done) begin
            psum_m_tile_write_cnt <= 'd0;
          end
          else begin
            psum_m_tile_write_cnt <= psum_m_tile_write_cnt + 1;
          end

          if (psum_m_tile_write_done) begin
            if (psum_k_group_write_done) begin
              psum_k_group_write_cnt <= 'd0;
            end
            else begin
              psum_k_group_write_cnt <= psum_k_group_write_cnt + 1;
            end
          end
          else begin
            psum_k_group_write_cnt <= psum_k_group_write_cnt;
          end

          if (psum_k_group_write_done && psum_m_tile_write_done) begin
            if (psum_n_group_write_done) begin
              psum_n_group_write_cnt <= 'd0;
            end
            else begin
              psum_n_group_write_cnt <= psum_n_group_write_cnt + 1;
            end
          end
          else begin
            psum_n_group_write_cnt <= psum_n_group_write_cnt;
          end
        end
        else begin
          psum_m_tile_write_cnt   <= psum_m_tile_write_cnt;
          psum_n_group_write_cnt  <= psum_n_group_write_cnt;
          psum_k_group_write_cnt  <= psum_k_group_write_cnt;
        end

        psum_width_write_cnt    <= 0;
        psum_height_write_cnt   <= 0;
        psum_ic_group_write_cnt <= 0;
      end
      else begin
        psum_width_write_cnt    <= psum_width_write_cnt;
        psum_height_write_cnt   <= psum_height_write_cnt;
        psum_ic_group_write_cnt <= psum_ic_group_write_cnt;
        psum_oc_group_write_cnt <= psum_oc_group_write_cnt;
        psum_m_tile_write_cnt   <= psum_m_tile_write_cnt;
        psum_n_group_write_cnt  <= psum_n_group_write_cnt;
        psum_k_group_write_cnt  <= psum_k_group_write_cnt;
      end
    end
    else begin
      if (done) begin
        psum_width_write_cnt    <= 0;
        psum_height_write_cnt   <= 0;
        psum_ic_group_write_cnt <= 0;
        psum_oc_group_write_cnt <= 0;
        psum_m_tile_write_cnt   <= 0;
        psum_n_group_write_cnt  <= 0;
        psum_k_group_write_cnt  <= 0;
      end
      else begin
        psum_width_write_cnt    <= psum_width_write_cnt;
        psum_height_write_cnt   <= psum_height_write_cnt;
        psum_ic_group_write_cnt <= psum_ic_group_write_cnt;
        psum_oc_group_write_cnt <= psum_oc_group_write_cnt;
        psum_m_tile_write_cnt   <= psum_m_tile_write_cnt;
        psum_n_group_write_cnt  <= psum_n_group_write_cnt;
        psum_k_group_write_cnt  <= psum_k_group_write_cnt;
      end
    end
  end
end

/* ---------------------------------------- Psum SRAM Write Enable ---------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_wen_reg       <= 1'b0;
    psum_sram_waddr_reg     <= 0;
  end
  else begin
    if (execute_start && !done) begin
      if (compute_done) begin
        psum_sram_waddr_reg <= psum_sram_waddr_wire;
        psum_sram_wen_reg <= 1'b1;
      end
      else begin
        psum_sram_waddr_reg     <= psum_sram_waddr_reg;
        psum_sram_wen_reg       <= 1'b0;
      end
    end
    else begin
      if (done) begin
        psum_sram_wen_reg       <= 1'b0;
        psum_sram_waddr_reg     <= 0;
      end
      else begin
        psum_sram_wen_reg       <= psum_sram_wen_reg;
        psum_sram_waddr_reg     <= psum_sram_waddr_reg;
      end
    end
  end
end

/* ----------------------------------------- Psum SRAM Write Data ----------------------------------------- */
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_wdata_reg     <= 0;
  end
  else begin
    if (execute_start && !done) begin
      if (compute_done) begin
        psum_sram_wdata_reg <= accumulator_result_pack;
      end
      else begin
        psum_sram_wdata_reg     <= psum_sram_wdata_reg;
      end
    end
    else begin
      if (done) begin
        psum_sram_wdata_reg     <= 0;
      end
      else begin
        psum_sram_wdata_reg     <= psum_sram_wdata_reg;
      end
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                    Outlier Index SRAM Read Controller                                    */
/* -------------------------------------------------------------------------------------------------------- */

/* ------------------------------------ Outlier Index SRAM Read Address ----------------------------------- */

assign outlier_index_sram_raddr = {ifmap_highaddr, ifmap_sram_raddr_reg};
assign outlier_index_sram_ren = ifmap_sram_ren & outlier_enable;

/* ------------------------------------- Outlier Index SRAM Read Data ------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    outlier_index_local_rdata_reg <= 0;
  end
  else begin
    if (ifmap_sram_valid_reg) begin
      outlier_index_local_rdata_reg <= ifmap_read_zero_reg_delay ? 0 : outlier_index_sram_rdata;
    end
    else begin
      outlier_index_local_rdata_reg <= outlier_index_local_rdata_reg;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                      Ifmap Scale SRAM Read Contoller                                     */
/* -------------------------------------------------------------------------------------------------------- */

/* ------------------------------- Ifmap Scale SRAM Read Address and Enable ------------------------------- */

assign ifmap_scale_sram_raddr  = {ifmap_highaddr, ifmap_sram_raddr_reg};
assign ifmap_scale_sram_ren    = ifmap_sram_ren & ifmap_scale_enable;

/* -------------------------------------- Ifmap Scale Sram Read Data -------------------------------------- */

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ifmap_scale_local_rdata_reg <= 0;
  end
  else begin
    if (ifmap_sram_valid_reg) begin
      ifmap_scale_local_rdata_reg <= ifmap_read_zero_reg_delay ? 0 : ifmap_scale_sram_rdata;
    end
    else begin
      ifmap_scale_local_rdata_reg <= ifmap_scale_local_rdata_reg;
    end
  end
end

/* -------------------------------------------------------------------------------------------------------- */
/*                                     Weight Scale SRAM Read Controller                                    */
/* -------------------------------------------------------------------------------------------------------- */

/* ------------------------------- Weight Scale SRAM Read Address and Enable ------------------------------ */

assign weight_scale_sram_raddr = {weight_highaddr, weight_sram_raddr_reg};
assign weight_scale_sram_ren   = weight_sram_ren & weight_scale_enable;

/* ------------------------------ Weight Scale SRAM Read Ping-Pang Controller ----------------------------- */

integer weight_scale_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (weight_scale_i = 0; weight_scale_i < 64; weight_scale_i = weight_scale_i + 1) begin
      weight_scale_local_data_reg_ping[weight_scale_i] <= 0;
      weight_scale_local_data_reg_pang[weight_scale_i] <= 0;
    end
  end
  else begin
    if (weight_regfile_ping_wen) begin
      weight_scale_local_data_reg_ping[weight_regfile_ping_waddr] <= weight_scale_sram_rdata;
    end

    if (weight_regfile_pang_wen) begin
      weight_scale_local_data_reg_pang[weight_regfile_pang_waddr] <= weight_scale_sram_rdata;
    end
  end
end

EOF
print $fh $code;
print $fh "genvar weight_scale_assign_idx;\n";
print $fh "generate\n";
print $fh "  for (weight_scale_assign_idx = 0; weight_scale_assign_idx < lane; weight_scale_assign_idx = weight_scale_assign_idx + 1) begin: weight_scale_assign\n";
print $fh "    assign weight_scale_local_data[weight_scale_assign_idx] = weight_ping_pang_using ? weight_scale_local_data_reg_pang[weight_scale_assign_idx] : weight_scale_local_data_reg_ping[weight_scale_assign_idx];\n";
print $fh "  end\n";
print $fh "endgenerate\n";
print $fh "\n";
$code = <<EOF;
/* -------------------------------------------------------------------------------------------------------- */
/*                                              Scale Processor                                             */
/* -------------------------------------------------------------------------------------------------------- */

wire [15:0] mpt_scale_mul_result[0:lane-1];
EOF
print $fh $code;

my $scale_pipeline_stage = log($p*4)/log(2) + 1;

for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "reg [15:0] mpt_scale_stage_" . $i . "[0:lane-1];\n";
}
print $fh "\n";
print $fh "integer mpt_scale_i;\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    for (mpt_scale_i = 0; mpt_scale_i < lane; mpt_scale_i = mpt_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "      mpt_scale_stage_" . $i . "[mpt_scale_i] <= 0;\n"
}
print $fh "    end\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (execute_start && !done) begin\n";
print $fh "      if (ifmap_scale_enable && weight_scale_enable) begin\n";
print $fh "        if (outlier_pe_halt) begin\n";
print $fh "          for (mpt_scale_i = 0; mpt_scale_i < lane; mpt_scale_i = mpt_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "            mpt_scale_stage_" . $i . "[mpt_scale_i] <= mpt_scale_stage_" . $i . "[mpt_scale_i];\n"
}
print $fh "          end\n";
print $fh "        end\n";
print $fh "        else begin\n";
print $fh "          for (mpt_scale_i = 0; mpt_scale_i < lane; mpt_scale_i = mpt_scale_i + 1) begin\n";
print $fh "            mpt_scale_stage_1[mpt_scale_i] <= ifmap_scale_local_rdata_reg;\n";
for (my $i = 2; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "            mpt_scale_stage_" . $i . "[mpt_scale_i] <= mpt_scale_stage_" . $i . "[mpt_scale_i];\n";
}
print $fh "          end\n";
print $fh "        end\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        for (mpt_scale_i = 0; mpt_scale_i < lane; mpt_scale_i = mpt_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "          mpt_scale_stage_" . $i . "[mpt_scale_i] <= 0;\n"
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      if (done) begin\n";
print $fh "        for (mpt_scale_i = 0; mpt_scale_i < lane; mpt_scale_i = mpt_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "          mpt_scale_stage_" . $i . "[mpt_scale_i] <= 0;\n"
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        for (mpt_scale_i = 0; mpt_scale_i < lane; mpt_scale_i = mpt_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "          mpt_scale_stage_" . $i . "[mpt_scale_i] <= mpt_scale_stage_" . $i . "[mpt_scale_i];\n"
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";

$code = <<EOF;
genvar mpt_scale_mul_i;
generate
  for (mpt_scale_mul_i = 0; mpt_scale_mul_i < lane; mpt_scale_mul_i = mpt_scale_mul_i + 1) begin : mpt_scale_multiplier
    multiplier_float16_pipeline_stage_1 u_mpt_scale_multiplier(
      .clk(clk),
      .rst_n(rst_n),
      .a(ifmap_scale_local_rdata_reg[15:0]),
      .b(weight_scale_local_data_reg_ping[mpt_scale_mul_i]),
      .o(mpt_scale_mul_result[mpt_scale_mul_i])
    );
  end
endgenerate

wire [15:0] outlier_pe_scale_result[0:lane-1];
EOF
print $fh $code;

for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "reg [15:0] outlier_pe_scale_stage_" . $i . "[0:lane-1];\n";
}
print $fh "\n";
print $fh "integer outlier_pe_scale_i;\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    for (outlier_pe_scale_i = 0; outlier_pe_scale_i < lane; outlier_pe_scale_i = outlier_pe_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "      outlier_pe_scale_stage_" . $i . "[outlier_pe_scale_i] <= 0;\n";
}
print $fh "    end\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (execute_start && !done) begin\n";
print $fh "      if (ifmap_scale_enable && weight_scale_enable && outlier_enable) begin\n";
print $fh "        if (outlier_pe_halt) begin\n";
print $fh "          for (outlier_pe_scale_i = 0; outlier_pe_scale_i < lane; outlier_pe_scale_i = outlier_pe_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "            outlier_pe_scale_stage_" . $i . "[outlier_pe_scale_i] <= outlier_pe_scale_stage_" . $i . "[outlier_pe_scale_i];\n"
}
print $fh "          end\n";
print $fh "        end\n";
print $fh "        else begin\n";
print $fh "          for (outlier_pe_scale_i = 0; outlier_pe_scale_i < lane; outlier_pe_scale_i = outlier_pe_scale_i + 1) begin\n";
print $fh "            outlier_pe_scale_stage_1[outlier_pe_scale_i] <= mpt_scale_mul_result[outlier_pe_scale_i];\n";
for (my $i = 2; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "            outlier_pe_scale_stage_" . $i . "[outlier_pe_scale_i] <= outlier_pe_scale_stage_" . ($i-1) . "[outlier_pe_scale_i];\n";
}
print $fh "          end\n";
print $fh "        end\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        for (outlier_pe_scale_i = 0; outlier_pe_scale_i < lane; outlier_pe_scale_i = outlier_pe_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "          outlier_pe_scale_stage_" . $i . "[outlier_pe_scale_i] <= 0;\n";
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      if (done) begin\n";
print $fh "        for (outlier_pe_scale_i = 0; outlier_pe_scale_i < lane; outlier_pe_scale_i = outlier_pe_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "          outlier_pe_scale_stage_" . $i . "[outlier_pe_scale_i] <= 0;\n";
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        for (outlier_pe_scale_i = 0; outlier_pe_scale_i < lane; outlier_pe_scale_i = outlier_pe_scale_i + 1) begin\n";
for (my $i = 1; $i < $scale_pipeline_stage; $i = $i + 1) {
  print $fh "          outlier_pe_scale_stage_" . $i . "[outlier_pe_scale_i] <= outlier_pe_scale_stage_" . $i . "[outlier_pe_scale_i];\n";
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";

$code = <<EOF;
genvar outlier_pe_scale_mul_i;
generate
  for (outlier_pe_scale_mul_i = 0; outlier_pe_scale_mul_i < lane; outlier_pe_scale_mul_i = outlier_pe_scale_mul_i + 1) begin : outlier_pe_scale
    multiplier_float16_pipeline_stage_1 u_outlier_pe_scale_multiplier(
      .clk(clk),
      .rst_n(rst_n),
      .a(ifmap_scale_local_rdata_reg[31:16]),
      .b(weight_scale_local_data[outlier_pe_scale_mul_i]),
      .o(outlier_pe_scale_result[outlier_pe_scale_mul_i])
    );
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                               Psum Pipeline                                              */
/* -------------------------------------------------------------------------------------------------------- */

EOF
print $fh $code;

my $psum_pipeline_stage_fp = (log($p)/log(2) + 1) * 2;
my $psum_pipeline_stage_int4 = log($p*4)/log(2) + 1;
my $psum_pipeline_stage_int4_fma = log($p*4)/log(2) + 1 + 2;
my $psum_pipeline_stage_int16 = log($p)/log(2) + 1;
print $fh "wire [1:0] psum_pipeline_stage_mode;\n";
print $fh "assign psum_pipeline_stage_mode = (type_a[2] | type_b[2]) ? 2 : (type_a[1] & type_a[1]) ? 1 : 0;\n";
print $fh "wire [31:0] psum_local_rdata_wire[0:lane-1];\n";
print $fh "`UNPACK_ARRAY(psum_unpack_array, psum_local_rdata_i, 32, lane, psum_local_rdata_wire, psum_local_rdata_reg);\n";
print $fh "\n";
my $psum_pipeline_stage = max($psum_pipeline_stage_fp, $psum_pipeline_stage_int4_fma);
for (my $i = 0; $i < $psum_pipeline_stage; $i = $i + 1) {
  print $fh "reg [31:0] psum_reg_stage_" . $i . "[0:lane-1];\n";
}
print $fh "\n";
print $fh "integer psum_i;\n";
print $fh "always @(posedge clk or negedge rst_n) begin\n";
print $fh "  if (!rst_n) begin\n";
print $fh "    for (psum_i = 0; psum_i < lane; psum_i = psum_i + 1) begin\n";
for (my $i = 0; $i < $psum_pipeline_stage; $i = $i + 1) {
  print $fh "      psum_reg_stage_" . $i . "[psum_i] <= 0;\n";
}
print $fh "    end\n";
print $fh "  end\n";
print $fh "  else begin\n";
print $fh "    if (execute_start && !done) begin\n";
print $fh "      if (outlier_pe_halt) begin\n";
print $fh "        for (psum_i = 0; psum_i < lane; psum_i = psum_i + 1) begin\n";
for (my $i = 0; $i < $psum_pipeline_stage; $i = $i + 1) {
  print $fh "          psum_reg_stage_" . $i . "[psum_i] <= psum_reg_stage_" . $i . "[psum_i];\n";
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        for (psum_i = 0; psum_i < lane; psum_i = psum_i + 1) begin\n";
print $fh "          psum_reg_stage_0[psum_i] <= psum_local_rdata_wire[psum_i];\n";
for (my $i = 1; $i < $psum_pipeline_stage_int16; $i = $i + 1) {
  print $fh "          psum_reg_stage_" . $i . "[psum_i] <= psum_reg_stage_" . ($i-1) . "[psum_i];\n";
}
print $fh "          if (psum_pipeline_stage_mode == 2) begin\n";
for (my $i = $psum_pipeline_stage_int16; $i < $psum_pipeline_stage_fp; $i = $i + 1) {
  print $fh "            psum_reg_stage_" . $i . "[psum_i] <= psum_reg_stage_" . ($i-1) . "[psum_i];\n";
}
print $fh "          end\n";
print $fh "          else if (psum_pipeline_stage_mode == 0) begin\n";
print $fh "            if (type_accumulator) begin\n";
for (my $i = $psum_pipeline_stage_int16; $i < $psum_pipeline_stage_int4_fma; $i = $i + 1) {
  print $fh "              psum_reg_stage_" . $i . "[psum_i] <= psum_reg_stage_" . ($i-1) . "[psum_i];\n";
}
for (my $i = $psum_pipeline_stage_int4_fma; $i < $psum_pipeline_stage_fp; $i = $i + 1) {
  print $fh "              psum_reg_stage_" . $i . "[psum_i] <= 0;\n";
}
print $fh "            end\n";
print $fh "            else begin\n";
for (my $i = $psum_pipeline_stage_int16; $i < $psum_pipeline_stage_int4; $i = $i + 1) {
  print $fh "              psum_reg_stage_" . $i . "[psum_i] <= psum_reg_stage_" . ($i-1) . "[psum_i];\n";
}
for (my $i = $psum_pipeline_stage_int4; $i < $psum_pipeline_stage_fp; $i = $i + 1) {
  print $fh "              psum_reg_stage_" . $i . "[psum_i] <= 0;\n";
}
print $fh "            end\n";
print $fh "          end\n";
print $fh "          else begin\n";
for (my $i = $psum_pipeline_stage_int16; $i < $psum_pipeline_stage_fp; $i = $i + 1) {
  print $fh "            psum_reg_stage_" . $i . "[psum_i] <= 0;\n";
}
print $fh "          end\n";
print $fh "        end\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "    else begin\n";
print $fh "      if (done) begin\n";
print $fh "        for (psum_i = 0; psum_i < lane; psum_i = psum_i + 1) begin\n";
for (my $i = 0; $i < $psum_pipeline_stage; $i = $i + 1) {
  print $fh "          psum_reg_stage_" . $i . "[psum_i] <= 0;\n";
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "      else begin\n";
print $fh "        for (psum_i = 0; psum_i < lane; psum_i = psum_i + 1) begin\n";
for (my $i = 0; $i < $psum_pipeline_stage; $i = $i + 1) {
  print $fh "          psum_reg_stage_" . $i . "[psum_i] <= psum_reg_stage_" . $i . "[psum_i];\n";
}
print $fh "        end\n";
print $fh "      end\n";
print $fh "    end\n";
print $fh "  end\n";
print $fh "end\n";

$code = <<EOF;

/* -------------------------------------------------------------------------------------------------------- */
/*                                          Weight Ping-Pang Buffer                                         */
/* -------------------------------------------------------------------------------------------------------- */

wire regfile_int4;
assign regfile_int4 = !(~|type_a[2:1] & !type_a[0] & ~|type_b[2:1] & !type_b[0]);

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    weight_ping_pang_using <= 'd0;
  end
  else begin
    if (execute_start && !done) begin
      weight_ping_pang_using <= weight_sram_ping_pang_identifier;
    end
    else begin
      if (done) begin
        weight_ping_pang_using <= 'd0;
      end
      else begin
        weight_ping_pang_using <= weight_ping_pang_using;
      end
    end
  end
end

regfile u_regfile_ping(
  .clk(clk),
  .rst_n(rst_n),
  .rw(weight_regfile_ping_wen),
  .dtype(regfile_int4),
  .non_uniform(1'b0),
  .non_uniform_sel(1'b0),
  .row_idx(weight_regfile_ping_waddr),
  .data(weight_sram_rdata),
  .row_data(weight_ping_data_packed),
EOF

print $fh $code;

for my $i (1..$layer){
  $i--;
  print $fh "  .weight_idx_$i(weight_idx_$i" . "_ping),\n";
}

for my $i (1..$layer){
  $i--;
  $i == $layer - 1 ? print $fh "  .weight_layer_$i(weight_layer_$i" . "_ping)\n" : print $fh "  .weight_layer_$i(weight_layer_$i" . "_ping),\n";
}

print $fh ");\n\n";

$code = <<EOF;
regfile u_regfile_pang(
  .clk(clk),
  .rst_n(rst_n),
  .rw(weight_regfile_pang_wen),
  .dtype(regfile_int4),
  .non_uniform(1'b0),
  .non_uniform_sel(1'b0),
  .row_idx(weight_regfile_pang_waddr),
  .data(weight_sram_rdata),
  .row_data(weight_pang_data_packed),
EOF

print $fh $code;

for my $i (1..$layer){
  $i--;
  print $fh "  .weight_idx_$i(weight_idx_$i" . "_pang),\n";
}

for my $i (1..$layer){
  $i--;
  $i == $layer - 1 ? print $fh "  .weight_layer_$i(weight_layer_$i" . "_pang)\n" : print $fh "  .weight_layer_$i(weight_layer_$i" . "_pang),\n";
}

print $fh ");\n\n";

$code = <<EOF;
/* -------------------------------------------------------------------------------------------------------- */
/*                                                    MPT                                                   */
/* -------------------------------------------------------------------------------------------------------- */

genvar mpt_i;
generate
  for (mpt_i = 0; mpt_i < lane; mpt_i = mpt_i + 1) begin : mpt
    mpt_mixed u_mpt(
      .clk(clk),
      .rst_n(rst_n),
      .type_a(type_a),
      .type_b(type_b),
      .valid(mpt_valid),
      .halt(outlier_pe_halt),
      .a(ifmap_local_data_wire[mpt_i]),
      .b(weight_local_data[mpt_i]),
      .o(mpt_result[mpt_i]),
      .done(mpt_done[mpt_i])
    );
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                                Outlier PE                                                */
/* -------------------------------------------------------------------------------------------------------- */

assign outlier_pe_valid = mpt_valid && outlier_enable && !(type_a[2] | type_b[2]) && !(type_a[1] | type_b[1]);
assign outlier_pe_type = type_a[0] | type_a[1];
`UNPACK_ARRAY(outlier_result_unpack_array, outlier_pe_unpack_idx, 32, lane, outlier_pe_result, outlier_pe_result_packed);

EOF
print $fh $code;
for (my $i = 0; $i < $layer; $i++){
  print $fh "assign weight_layer_" . $i . " = weight_ping_pang_using ? weight_layer_" . $i . "_pang : weight_layer_" . $i . "_ping;\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++){
  print $fh "assign weight_idx_" . $i . "_ping = weight_ping_pang_using ? 'd0 : weight_idx_" . $i . ";\n";
}
print $fh "\n";
for (my $i = 0; $i < $layer; $i++){
  print $fh "assign weight_idx_" . $i . "_pang = weight_ping_pang_using ? weight_idx_" . $i . " : 'd0;\n";
}

my $code = <<EOF;

outlier_pe u_outlier_pe(
  .clk(clk),
  .rst_n(rst_n),
  .valid(outlier_pe_valid),
  .dtype(outlier_pe_type),
  .idx(outlier_index_local_rdata_reg),
  .data(ifmap_local_rdata_reg[REAL_IFMAP_WIDTH-1:0]),
EOF
print $fh $code;

for (my $i = 0; $i < $layer; $i++){
  print $fh "  .weight_layer_" . $i . "(weight_layer_" . $i . "),\n";
}
for (my $i = 0; $i < $layer; $i++){
  print $fh "  .weight_idx_" . $i . "(weight_idx_" . $i . "),\n";
}
print $fh "  .result(outlier_pe_result_packed),\n";
print $fh "  .halt(outlier_pe_halt),\n";
print $fh "  .done(outlier_pe_done)\n";
print $fh ");\n\n";

$code = <<EOF;
/* -------------------------------------------------------------------------------------------------------- */
/*                                                Accumulator                                               */
/* -------------------------------------------------------------------------------------------------------- */

genvar fma_i;
generate 
  for (fma_i = 0; fma_i < lane; fma_i = fma_i + 1) begin : fma
    custom_fma u_fma(
      .clk(clk),
      .rst_n(rst_n),
      .p0(mpt_result[fma_i]),
      .p1(outlier_pe_result[fma_i]),
      .s0(mpt_scale_stage_7[fma_i]),
      .s1(outlier_pe_scale_stage_7[fma_i]),
      .o(fma_result[fma_i])
    );
  end
endgenerate

wire [31:0] accumulator_a[0:lane-1];
wire [31:0] accumulator_b[0:lane-1];

EOF
print $fh $code;
print $fh "genvar accumulator_a_i;\n";
print $fh "generate\n";
print $fh "  for (accumulator_a_i = 0; accumulator_a_i < lane; accumulator_a_i = accumulator_a_i + 1) begin : accumulator_a_assign\n";
print $fh "    assign accumulator_a[accumulator_a_i] = psum_pipeline_stage_mode == 0 && type_accumulator ? fma_result[accumulator_a_i] : mpt_result[accumulator_a_i];\n";
print $fh "  end\n";
print $fh "endgenerate\n";
print $fh "\n";
print $fh "genvar accumulator_b_i;\n";
print $fh "generate\n";
print $fh "  for (accumulator_b_i = 0; accumulator_b_i < lane; accumulator_b_i = accumulator_b_i + 1) begin : accumulator_b_assign\n";
print $fh "    assign accumulator_b[accumulator_b_i] = psum_pipeline_stage_mode == 2 ? psum_reg_stage_" . ($psum_pipeline_stage_fp-1) . "[accumulator_b_i] :\n";
print $fh "                                            psum_pipeline_stage_mode == 0 && type_accumulator ? psum_reg_stage_" . ($psum_pipeline_stage_int4_fma-1) . "[accumulator_b_i] :\n";
print $fh "                                            psum_pipeline_stage_mode == 0 && !type_accumulator ? psum_reg_stage_" . ($psum_pipeline_stage_int4-1) . "[accumulator_b_i] :\n";
print $fh "                                            psum_pipeline_stage_mode == 1 ? psum_reg_stage_" . ($psum_pipeline_stage_int16-1) . "[accumulator_b_i] : 0;\n";
print $fh "  end\n";
print $fh "endgenerate\n\n";
print $fh "\n";
my $code = <<EOF;
genvar accumulator_i;
generate
  for (accumulator_i = 0; accumulator_i < lane; accumulator_i = accumulator_i + 1) begin : accumulator
    accumulator_pipeline_stage_1 u_accumulator(
      .clk(clk),
      .rst_n(rst_n),
      .mode(type_accumulator),
      .a(accumulator_a[accumulator_i]),
      .b(accumulator_b[accumulator_i]),
      .o(accumulator_result[accumulator_i])
    );
  end
endgenerate

/* -------------------------------------------------------------------------------------------------------- */
/*                                              Sparse selector                                             */
/* -------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------- Sparse mask read ------------------------------------------- */

assign ifmapmask_sram_raddr = {weight_highaddr, weight_sram_raddr_reg};
assign ifmapmask_sram_ren   = weight_sram_ren & sparse_enable;

integer ifmapmask_i;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (ifmapmask_i = 0; ifmapmask_i < 64; ifmapmask_i = ifmapmask_i + 1) begin
      ifmapmask_local_data_reg_ping[ifmapmask_i] <= 0;
      ifmapmask_local_data_reg_pang[ifmapmask_i] <= 0;
    end
  end
  else begin
    if (weight_regfile_ping_wen) begin
      ifmapmask_local_data_reg_ping[weight_regfile_ping_waddr] <= weight_scale_sram_rdata;
    end

    if (weight_regfile_pang_wen) begin
      ifmapmask_local_data_reg_pang[weight_regfile_pang_waddr] <= weight_scale_sram_rdata;
    end
  end
end
EOF
print $fh $code;
print $fh "genvar ifmapmask_assign_idx;\n";
print $fh "generate\n";
print $fh "  for (ifmapmask_assign_idx = 0; ifmapmask_assign_idx < lane; ifmapmask_assign_idx = ifmapmask_assign_idx + 1) begin: ifmapmask_assign\n";
print $fh "    assign ifmapmask_local_data[ifmapmask_assign_idx] = weight_ping_pang_using ? ifmapmask_local_data_reg_pang[ifmapmask_assign_idx] : ifmapmask_local_data_reg_ping[ifmapmask_assign_idx];\n";
print $fh "  end\n";
print $fh "endgenerate\n";
print $fh "\n";
print $fh "genvar fp16_sparse_selector_i;\n";
print $fh "generate\n";
print $fh "  for (fp16_sparse_selector_i = 0; fp16_sparse_selector_i < lane; fp16_sparse_selector_i = fp16_sparse_selector_i + 1) begin : fp16_sparse_selector\n";
print $fh "    sparse_selector_32_16bit u_sparse_selector_16bit(\n"; 
print $fh "      .mask(ifmapmask_local_data[fp16_sparse_selector_i][" . ($p*8-1) . ":0]),\n";
print $fh "      .mode({SPARSE_ENABLE}),\n";
print $fh "      .data(ifmap_local_rdata_reg),\n";
print $fh "      .out(ifmap_sparse_16bit_data[fp16_sparse_selector_i])\n";
print $fh "    );\n";
print $fh "  end\n";
print $fh "endgenerate\n";
print $fh "\n";
print $fh "genvar int4_sparse_selector_i;\n";
print $fh "generate\n";
print $fh "  for (int4_sparse_selector_i = 0; int4_sparse_selector_i < lane; int4_sparse_selector_i = int4_sparse_selector_i + 1) begin : int4_sparse_selector\n";
print $fh "    sparse_selector_128_4bit u_sparse_selector_4bit(\n";
print $fh "      .mask(ifmapmask_local_data[int4_sparse_selector_i]),\n";
print $fh "      .mode({SPARSE_ENABLE}),\n";
print $fh "      .data(ifmap_local_rdata_reg),\n";
print $fh "      .out(ifmap_sparse_4bit_data[int4_sparse_selector_i])\n";
print $fh "    );\n";
print $fh "  end\n";
print $fh "endgenerate\n";
print $fh "\n";
print $fh "genvar int8_sparse_selector_i;\n";
print $fh "generate\n";
print $fh "  for (int8_sparse_selector_i = 0; int8_sparse_selector_i < lane; int8_sparse_selector_i = int8_sparse_selector_i + 1) begin : int8_sparse_selector\n";
print $fh "    sparse_selector_64_8bit u_sparse_selector_8bit(\n";
print $fh "      .mask(ifmapmask_local_data[int8_sparse_selector_i][" . ($p*16-1) . ":0]),\n";
print $fh "      .mode({SPARSE_ENABLE}),\n";
print $fh "      .data(ifmap_local_rdata_reg),\n";
print $fh "      .out(ifmap_sparse_8bit_data[int8_sparse_selector_i])\n";
print $fh "    );\n";
print $fh "  end\n";
print $fh "endgenerate\n";
print $fh "\n";
print $fh "genvar ifmap_local_data_assign_i;\n";
print $fh "generate\n";
print $fh "  for (ifmap_local_data_assign_i = 0; ifmap_local_data_assign_i < lane; ifmap_local_data_assign_i = ifmap_local_data_assign_i + 1) begin : ifmap_local_data_assign\n";
print $fh "    assign ifmap_local_data_wire[ifmap_local_data_assign_i] = sparse_enable ? type_a[1] | type_b[1] ? ifmap_sparse_16bit_data[ifmap_local_data_assign_i] :\n";
print $fh "                                                                              type_a[0] | type_b[0] ? ifmap_sparse_8bit_data[ifmap_local_data_assign_i] :\n";
print $fh "                                                                              ifmap_sparse_4bit_data[ifmap_local_data_assign_i] : ifmap_local_rdata_reg[REAL_IFMAP_WIDTH-1:0];\n";
print $fh "  end\n";
print $fh "endgenerate\n";
print $fh "\n";
my $code = <<EOF;
/* -------------------------------------------------------------------------------------------------------- */
/*                                                Done Logic                                                */
/* -------------------------------------------------------------------------------------------------------- */

assign compute_done = accumulator_done_reg;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    fma_done_reg               <= 1'b0;
    fma_done_reg_stage         <= 1'b0;
    accumulator_done_reg       <= 1'b0;
    accumulator_done_reg_stage <= 1'b0;
    compute_done_reg           <= 1'b0;
  end
  else begin
    if (execute_start && !done) begin
      if (psum_pipeline_stage_mode == 0 && type_accumulator) begin
        fma_done_reg_stage <= mpt_done & outlier_pe_done;
        fma_done_reg       <= fma_done_reg_stage;
        accumulator_done_reg_stage <= fma_done_reg;
        accumulator_done_reg       <= accumulator_done_reg_stage;
      end
      else if (psum_pipeline_stage_mode == 0) begin
        accumulator_done_reg <= mpt_done;
        fma_done_reg <= 1'b0;
        fma_done_reg_stage <= 1'b0;
        accumulator_done_reg_stage <= 1'b0;
      end
      else if (psum_pipeline_stage_mode == 1) begin
        accumulator_done_reg <= mpt_done;
        fma_done_reg <= 1'b0;
        fma_done_reg_stage <= 1'b0;
        accumulator_done_reg_stage <= 1'b0;
      end
      else if (psum_pipeline_stage_mode == 2) begin
        fma_done_reg <= 1'b0;
        fma_done_reg_stage <= 1'b0;
        accumulator_done_reg_stage <= mpt_done;
        accumulator_done_reg <= accumulator_done_reg_stage;
      end
      else begin
        fma_done_reg <= 1'b0;
        fma_done_reg_stage <= 1'b0;
        accumulator_done_reg <= 1'b0;
        accumulator_done_reg_stage <= 1'b0;
      end

      if (compute_done) begin
        compute_done_reg <= 1'b1;
      end
      else begin
        compute_done_reg <= 1'b0;
      end
    end
    else begin
      compute_done_reg <= 1'b0;
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    psum_sram_write_cnt <= 0;
  end
  else begin
    if (execute_start && !done) begin
      if ((psum_width_write_done && psum_height_write_done) || psum_m_tile_write_done) begin
        if (psum_sram_write_cnt == weight_number) begin
          psum_sram_write_cnt <= psum_sram_write_cnt;
        end
        else begin
          psum_sram_write_cnt <= psum_sram_write_cnt + 1;
        end
      end
      else begin
        psum_sram_write_cnt <= psum_sram_write_cnt;
      end
    end
    else begin
      if (done) begin
        psum_sram_write_cnt <= 0;
      end
      else begin
        psum_sram_write_cnt <= psum_sram_write_cnt;
      end
    end
  end
end

wire sparse_error;
assign sparse_error = ((sparse_base == 2'b10) & (sparse_ratio == 2'b11)) | ((sparse_base == 2'b11) & sparse_ratio[1]);

wire type_error;
assign type_error = (type_a == 3'b100 && type_b != 3'b100) || (type_a != 3'b100 && type_b == 3'b100);

wire quantization_error;
assign quantization_error = non_uniform_quantization & ((|type_a) | (|type_b));

wire outlier_error;
assign outlier_error = outlier_enable & (type_a[1] | type_b[1]| type_a[2] | type_b[2] | sparse_enable);

wire expand_error;
assign expand_error = expand_weight_sram_enable & sparse_ratio[1];

assign error = type_error ? PE_DATATYPE_CONFIG_ERROR :
               sparse_error ? PE_SPARSE_CONFIG_ERROR :
               quantization_error ? PE_QUANTIZATION_CONFIG_ERROR :
               outlier_error ? PE_OUTLIER_CONFIG_ERROR :
               expand_error ? PE_EXPAND_WEIGHT_SRAM_CONFIG_ERROR :
               PE_NO_ERROR;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    conv_config_done  <= 1'b0;
    conv_execute_done <= 1'b0;
    gemm_config_done  <= 1'b0;
    gemm_execute_done <= 1'b0;
    error_done        <= 1'b0;
  end
  else begin
    if (execute_start && !done) begin
      if ((!conv_execute_done) && (insn[$insn_kind_end:$insn_kind_start] == conv_execute_insn) && psum_width_write_done && psum_height_write_done && (psum_sram_write_cnt == psum_number)) begin
        conv_execute_done <= 1'b1;
      end
      else begin
        conv_execute_done <= 1'b0;
      end
    end

    if (execute_start && !done) begin
      if (!gemm_execute_done && (insn[$insn_kind_end:$insn_kind_start] == gemm_execute_insn) && psum_m_tile_write_done && (psum_sram_write_cnt == psum_number)) begin
        gemm_execute_done <= 1'b1;
      end
      else begin
        gemm_execute_done <= gemm_execute_done;
      end
    end

    if (insn_valid && insn[$insn_kind_end:$insn_kind_start] == conv_config_insn) begin
      conv_config_done <= 1'b1;
    end
    else begin
      conv_config_done <= 1'b0;
    end

    if (insn_valid && insn[$insn_kind_end:$insn_kind_start] == gemm_config_insn) begin
      gemm_config_done <= 1'b1;
    end
    else begin
      gemm_config_done <= 1'b0;
    end

    if (|error) begin
      error_done <= 1'b1;
    end
    else begin
      error_done <= 1'b0;
    end
  end
end

endmodule

EOF

print $fh $code;

print "==== INFO : Done Generate $file ==== \n";
