#!/bin/bash

bank=8
parallelism_fp16=32
multiply_plus_tree_lane=64
outlier_process_layer=8
ifmap_sram_depth=512
weight_sram_depth=1024
psum_sram_depth=1024
ofmap_sram_depth=512

perl pea/idx_process.pl --file ../rtl/pea/outlier_pe/idx_process.v --lane $multiply_plus_tree_lane --p $parallelism_fp16
perl pea/mpt_mixed.pl --file ../rtl/pea/mpt/mpt_mixed.v -p $parallelism_fp16 
perl pea/outlier_pe.pl --file ../rtl/pea/outlier_pe/outlier_pe.v --layer $outlier_process_layer --p $parallelism_fp16 -lane $multiply_plus_tree_lane
perl pea/outlier_selection.pl --file ../rtl/pea/outlier_pe/outlier_selection.v -p $parallelism_fp16 -lane $multiply_plus_tree_lane
perl pea/outlier_selection_4bit.pl --file ../rtl/pea/outlier_pe/outlier_selection_4bit.v -p $parallelism_fp16 -lane $multiply_plus_tree_lane
perl pea/outlier_selection_8bit.pl --file ../rtl/pea/outlier_pe/outlier_selection_8bit.v -p $parallelism_fp16 -lane $multiply_plus_tree_lane
perl pea/pea.pl --file ../rtl/pea/pea.v --p $parallelism_fp16 --lane $multiply_plus_tree_lane --layer $outlier_process_layer --ifmap_sram_depth $ifmap_sram_depth --weight_sram_depth $weight_sram_depth --psum_sram_depth $psum_sram_depth --bank $bank
perl pea/regfile.pl --file ../rtl/pea/temp_storage/regfile.v --lane $multiply_plus_tree_lane --p $(($parallelism_fp16 * 2)) --layer $outlier_process_layer
perl pea/non_uniform_preprocess.pl --file ../rtl/pea/temp_storage/non_uniform_preprocess.v 
perl pea/row_non_uniform_preprocess.pl --file ../rtl/pea/temp_storage/row_non_uniform_preprocess.v --p $(($parallelism_fp16 * 2))
perl pea/col_non_uniform_preprocess.pl --file ../rtl/pea/temp_storage/col_non_uniform_preprocess.v --lane $multiply_plus_tree_lane

perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_4to1_4bit.v --n 4 --m 1 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_4to2_4bit.v --n 4 --m 2 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_8to1_4bit.v --n 8 --m 1 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_8to2_4bit.v --n 8 --m 2 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_8to4_4bit.v --n 8 --m 4 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_16to1_4bit.v --n 16 --m 1 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_16to2_4bit.v --n 16 --m 2 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_16to4_4bit.v --n 16 --m 4 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_16to8_4bit.v --n 16 --m 8 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_32to1_4bit.v --n 32 --m 1 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_32to4_4bit.v --n 32 --m 4 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_32to8_4bit.v --n 32 --m 8 --bitwidth 4
perl pea/mux.pl --file ../rtl/pea/sparse/mux_4bit/mux_32to16_4bit.v --n 32 --m 16 --bitwidth 4


perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_4to1_8bit.v --n 4 --m 1 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_4to2_8bit.v --n 4 --m 2 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_8to1_8bit.v --n 8 --m 1 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_8to2_8bit.v --n 8 --m 2 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_8to4_8bit.v --n 8 --m 4 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_16to1_8bit.v --n 16 --m 1 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_16to2_8bit.v --n 16 --m 2 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_16to4_8bit.v --n 16 --m 4 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_16to8_8bit.v --n 16 --m 8 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_32to1_8bit.v --n 32 --m 1 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_32to4_8bit.v --n 32 --m 4 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_32to8_8bit.v --n 32 --m 8 --bitwidth 8
perl pea/mux.pl --file ../rtl/pea/sparse/mux_8bit/mux_32to16_8bit.v --n 32 --m 16 --bitwidth 8


perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_4to1_16bit.v --n 4 --m 1 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_4to2_16bit.v --n 4 --m 2 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_8to1_16bit.v --n 8 --m 1 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_8to2_16bit.v --n 8 --m 2 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_8to4_16bit.v --n 8 --m 4 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_16to1_16bit.v --n 16 --m 1 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_16to2_16bit.v --n 16 --m 2 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_16to4_16bit.v --n 16 --m 4 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_16to8_16bit.v --n 16 --m 8 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_32to1_16bit.v --n 32 --m 1 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_32to4_16bit.v --n 32 --m 4 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_32to8_16bit.v --n 32 --m 8 --bitwidth 16
perl pea/mux.pl --file ../rtl/pea/sparse/mux_16bit/mux_32to16_16bit.v --n 32 --m 16 --bitwidth 16


perl pea/selector.pl --file ../rtl/pea/sparse/mux_4bit/sparse_selector_128_4bit.v --p $(($parallelism_fp16*4)) --bitwidth 4
perl pea/selector.pl --file ../rtl/pea/sparse/mux_8bit/sparse_selector_64_8bit.v --p $(($parallelism_fp16*2)) --bitwidth 8
perl pea/selector.pl --file ../rtl/pea/sparse/mux_16bit/sparse_selector_32_16bit.v --p $parallelism_fp16 --bitwidth 16


perl sram/ifmap_ram.pl --file ../rtl/ram/sram/ifmap_ram.v --width $(( $parallelism_fp16 * 16 )) --depth $ifmap_sram_depth --bank $bank
perl sram/outlier_index_ram.pl --file ../rtl/ram/sram/outlier_index_ram.v --width $(($parallelism_fp16*4)) --depth $ifmap_sram_depth --bank $bank
perl sram/psum_ram.pl --file ../rtl/ram/sram/psum_ram.v --width $(($multiply_plus_tree_lane*32)) --depth $psum_sram_depth --bank $bank
perl sram/ifmap_scale_ram.pl --file ../rtl/ram/sram/ifmap_scale_ram.v --width 32 --depth $ifmap_sram_depth --bank $bank
perl sram/weight_scale_ram.pl --file ../rtl/ram/sram/weight_scale_ram.v --width 16 --depth $(($weight_sram_depth*2)) --bank $bank
perl sram/vcures_ram.pl --file ../rtl/ram/sram/vcures_ram.v --width $(($multiply_plus_tree_lane*32)) --depth $ofmap_sram_depth --bank $bank
perl sram/vcupara_ram.pl --file ../rtl/ram/sram/vcupara_ram.v --width $(($multiply_plus_tree_lane*32)) --depth 64 --bank $bank
perl sram/ofmap_ram.pl --file ../rtl/ram/sram/ofmap_ram.v --width $(($multiply_plus_tree_lane*8)) --depth $ofmap_sram_depth --bank $bank

perl sram/ifmap_arbiter.pl --file ../rtl/ram/arbiter/ifmap_arbiter.v --width $(($parallelism_fp16*16)) --depth $ifmap_sram_depth --bank $bank
perl sram/outlier_index_arbiter.pl --file ../rtl/ram/arbiter/outlier_index_arbiter.v --width $(($parallelism_fp16*4)) --depth $ifmap_sram_depth --bank $bank
perl sram/ifmap_scale_arbiter.pl --file ../rtl/ram/arbiter/ifmap_scale_arbiter.v --width 32 --depth $ifmap_sram_depth --bank $bank
perl sram/weight_scale_arbiter.pl --file ../rtl/ram/arbiter/weight_scale_arbiter.v --width 16 --depth $(($weight_sram_depth*2)) --bank $bank
perl sram/vcures_arbiter.pl --file ../rtl/ram/arbiter/vcures_arbiter.v --width $(($multiply_plus_tree_lane*32)) --depth $ofmap_sram_depth --bank $bank
perl sram/ofmap_arbiter.pl --file ../rtl/ram/arbiter/ofmap_arbiter.v --width $(($multiply_plus_tree_lane*8)) --depth $ofmap_sram_depth --bank $bank

perl sram/weight_ifmapmask_ram.pl --file ../rtl/ram/sram/weight_ifmapmask_ram.v --width $(($multiply_plus_tree_lane*8)) --depth $weight_sram_depth --bank $bank
perl sram/weight_ifmapmask_arbiter.pl --file ../rtl/ram/arbiter/weight_ifmapmask_arbiter.v --width $(($multiply_plus_tree_lane*8)) --depth $weight_sram_depth --bank $bank

perl sram/psum_read_arbiter.pl --file ../rtl/ram/arbiter/psum_read_arbiter.v --width $(($multiply_plus_tree_lane*32)) --depth $psum_sram_depth --bank $bank
perl sram/psum_write_arbiter.pl --file ../rtl/ram/arbiter/psum_write_arbiter.v --width $(($multiply_plus_tree_lane*32)) --depth $psum_sram_depth --bank $bank

# perl bench/pea_tb.pl --file ../sim/bench/pea_tb.v