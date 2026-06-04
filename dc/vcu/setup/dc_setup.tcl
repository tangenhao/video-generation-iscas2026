source -echo -verbose ./setup/common_setup.tcl
source -echo -verbose ./setup/dc_setup_filenames.tcl

puts "RM-Info: Running script [info script]\n"

#################################################################################
# Design Compiler Reference Methodology Setup for Hierarchical Flow
# Script: dc_setup.tcl
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
#################################################################################

##########################################################################################
# Hierarchical Flow Blocks
#
# If you are performing a hierarchical flow, define the hierarchical designs here.
# List the reference names of the hierarchical blocks.  Cell instance names will
# be automatically derived from the design names provided.
#
# Note: These designs are expected to be unique. There should not be multiple
#       instantiations of physical hierarchical blocks.
#
##########################################################################################

# Each of the hierarchical designs specified in ${HIERARCHICAL_DESIGNS} in the common_setup.tcl file
# should be added to only one of the lists below:
# List of Design Compiler hierarchical design names (.ddc will be read)
set DDC_HIER_DESIGNS                    [list \
multiplier_float32_pipeline_stage_1 \
adder_float32_pipeline_stage_1 \
fast_func \
fma_float32_pipeline_stage_3 \
vfdsu_top \
fpu \
vcu_regfile \
activation_func
];
# List of Design Compiler block abstraction hierarchical designs (.ddc will be read) without transparent interface optimization
set DC_BLOCK_ABSTRACTION_DESIGNS        "vcu";
# List of Design Compiler block abstraction hierarchical designs # with transparent interface optimization
set DC_BLOCK_ABSTRACTION_DESIGNS_TIO    ""  ;
# List of IC Compiler block abstraction hierarchical design names (Milkyway will be read)
set ICC_BLOCK_ABSTRACTION_DESIGNS       ""  ;


#################################################################################
# Setup Variables
#
# Modify settings in this section to customize your Design Compiler Reference 
# Methodology run.
# Portions of dc_setup.tcl may be used by other tools so program name checks
# are performed where necessary.
#################################################################################

  # The following setting removes new variable info messages from the end of the log file
  set_app_var sh_new_variable_message false

if {$synopsys_program_name == "dc_shell"}  {

  #################################################################################
  # Design Compiler Setup Variables
  #################################################################################

  # Use the set_host_options command to enable multicore optimization to improve runtime.
  # This feature has special usage and license requirements.  Refer to the 
  # "Support for Multicore Technology" section in the Design Compiler User Guide
  # for multicore usage guidelines.
  # Note: This is a DC Ultra feature and is not supported in DC Expert.

  set_host_options -max_cores 16

  # Change alib_library_analysis_path to point to a central cache of analyzed libraries
  # to save runtime and disk space.  The following setting only reflects the
  # default value and should be changed to a central location for best results.

  set_app_var alib_library_analysis_path .

  # Add any additional Design Compiler variables needed here

}

# Enter the list of source RTL files if reading from RTL
set RTL_SOURCE_FILES  [list \
activation_func.v \
fma_float32_pipeline_stage_3.v \
shifter_left_48_6.v \
shifter_right_71_8.v \
shifter_left_71_7.v \
adder_71bit.v \
cla_16bit.v \
adder_4bit.v \
cla_4bit.v \
full_adder.v \
lzd128.v \
lzd64.v \
lzd32.v \
lzd16.v \
lzd8.v \
lzd4.v \
lzd2.v \
adder_float32_pipeline_stage_1.v \
shifter_right_47_8.v \
adder_48bit.v \
adder_38bit.v \
compressor_10_to_2.v \
CSA_35b.v \
CSA_38b.v \
CSA_49b.v \
CSA_64b.v \
exp2_norm.v \
exp2_pre.v \
fast_activation_norm.v \
fast_activation_pre.v \
fast_func.v \
interpolor.v \
log2_norm.v \
log2_pre.v \
reciprocal_norm.v \
reciprocal_pre.v \
rsqrt_norm.v \
rsqrt_pre.v \
sincos_norm.v \
sincos_pre.v \
squarer.v \
wallace_mul_11b_38b.v \
wallace_mul_16b_19b.v \
multiplier_float32_pipeline_stage_1.v \
vfdsu_ctrl.v \
vfdsu_double.v \
vfdsu_ff1.v \
vfdsu_pack.v \
vfdsu_prepare.v \
vfdsu_round.v \
vfdsu_scalar_dp.v \
vfdsu_srt_radix16_bound_table.v \
vfdsu_srt_radix16_with_sqrt.v \
vfdsu_srt.v \
vfdsu_top.v \
fpu.v \
compare.v \
reverse.v \
operator.v \
vculut_ram.v \
vculut_arbiter.v \
sram_64x128.v \
sram_32x64.v \
round_robin_arbiter_with_address.v \
vcu.v \
vcucode_ram.v \
bf16_to_fp32.v \
data_in_convert.v \
data_out_convert.v \
fp_to_fp32.v \
fp16_to_fp32.v \
fp32_to_fp.v \
fp32_to_int.v \
int2fp32.v \
int4_to_fp32.v \
int8_to_fp32.v \
int16_to_fp32.v \
int32_to_fp32.v \
shifter_55_8.v \
fp32_to_bfloat.v \
fp32_to_half.v \
shifter_24_8.v 
];

# The following variables are used by scripts in the rm_dc_scripts folder to direct 
# the location of the output files.

set REPORTS_DIR "reports"
set RESULTS_DIR "results"
set PTPX_DIR "ptpx"

file mkdir ${REPORTS_DIR}
file mkdir ${RESULTS_DIR}
file mkdir ${PTPX_DIR}

#################################################################################
# Search Path Setup
#
# Set up the search path to find the libraries and design files.
#################################################################################

  set_app_var search_path ". ${ADDITIONAL_SEARCH_PATH} $search_path"

  # For a hierarchical flow, add the block-level results directories to the
  # search path to find the block-level design files.

  set HIER_DESIGNS "${DDC_HIER_DESIGNS} ${DC_BLOCK_ABSTRACTION_DESIGNS} ${DC_BLOCK_ABSTRACTION_DESIGNS_TIO}"
  foreach design $HIER_DESIGNS {
    lappend search_path ../${design}/results
  }

#################################################################################
# Library Setup
#
# This section is designed to work with the settings from common_setup.tcl
# without any additional modification.
#################################################################################

  # Milkyway variable settings

  # Make sure to define the Milkyway library variable
  # mw_design_library, it is needed by write_milkyway command

  set mw_reference_library ${MW_REFERENCE_LIB_DIRS}
  set mw_design_library ${DCRM_MW_LIBRARY_NAME}

  set mw_site_name_mapping { {CORE unit} {Core unit} {core unit} }

# The remainder of the setup below should only be performed in Design Compiler
if {$synopsys_program_name == "dc_shell"}  {

  set_app_var target_library ${TARGET_LIBRARY_FILES}
  set_app_var synthetic_library dw_foundation.sldb
  set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"

  # Set min libraries if they exist
  foreach {max_library min_library} $MIN_LIBRARY_FILES {
    set_min_library $max_library -min_version $min_library
  }

  if {[shell_is_in_topographical_mode]} {

    # To activate the extended layer mode to support 4095 layers uncomment the extend_mw_layers command 
    # before creating the Milkyway library. The extended layer mode is permanent and cannot be reverted 
    # back to the 255 layer mode once activated.

    # extend_mw_layers

    # Only create new Milkyway design library if it doesn't already exist
    if {![file isdirectory $mw_design_library ]} {
      create_mw_lib   -technology $TECH_FILE \
                      -mw_reference_library $mw_reference_library \
                      $mw_design_library
    } else {
      # If Milkyway design library already exists, ensure that it is consistent with specified Milkyway reference libraries
      set_mw_lib_reference $mw_design_library -mw_reference_library $mw_reference_library
    }

    open_mw_lib     $mw_design_library

    check_library > ${REPORTS_DIR}/${DCRM_CHECK_LIBRARY_REPORT}

    set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE \
                       -min_tluplus $TLUPLUS_MIN_FILE \
                       -tech2itf_map $MAP_FILE

    check_tlu_plus_files
  }

  #################################################################################
  # Library Modifications
  #
  # Apply library modifications after the libraries are loaded.
  #################################################################################

  if {[file exists [which ${LIBRARY_DONT_USE_FILE}]]} {
    puts "RM-Info: Sourcing script file [which ${LIBRARY_DONT_USE_FILE}]\n"
    source -echo -verbose ${LIBRARY_DONT_USE_FILE}
  }
}

if {$synopsys_program_name == "pt_shell"} {
  set_app_var target_library ${TARGET_LIBRARY_FILES}
  set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES"
}

puts "RM-Info: Completed script [info script]\n"

