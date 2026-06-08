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
set DDC_HIER_DESIGNS                    "";
# List of Design Compiler block abstraction hierarchical designs (.ddc will be read) without transparent interface optimization
set DC_BLOCK_ABSTRACTION_DESIGNS        "pea";
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
mpt_mixed.v \
adder_mixed_pipe_stage_1_32.v \
adder_mixed_pipe_stage_1_36.v \
adder_mixed_pipe_stage_1_40.v \
adder_mixed_pipe_stage_1_44.v \
multiplier_mixed_pipeline_stage_1.v \
unpack_mul.v \
multiplier_int4.v \
adder_12_8.v \
adder_16_12.v \
adder_24_16.v \
adder_32_24.v \
adder_4bit.v \
adder_9bit.v \
adder_10bit.v \
adder_11bit.v \
adder_12bit.v \
adder_13bit.v \
adder_14bit.v \
adder_15bit.v \
cla_4bit.v \
full_adder.v \
half_adder.v \
lzd128.v \
lzd64.v \
lzd32.v \
lzd16.v \
lzd8.v \
lzd4.v \
lzd2.v \
shifter_frac.v \
shifter_true_form_int4.v \
shifter_true_form_int8.v \
pea.v \
accumulator_pipeline_stage_1.v \
adder_48bit.v \
shifter_adder_frac.v \
cla_16bit.v \
custom_fma.v \
multiplier_float16_pipeline_stage_1.v \
shifter_right_32_5.v \
shifter_left_22_5.v \
and_minus.v \
mux_16to1_16bit.v \
mux_16to2_16bit.v \
mux_16to4_16bit.v \
mux_16to8_16bit.v \
mux_32to1_16bit.v \
mux_32to16_16bit.v \
mux_32to4_16bit.v \
mux_32to8_16bit.v \
mux_4to1_16bit.v \
mux_4to2_16bit.v \
mux_8to1_16bit.v \
mux_8to2_16bit.v \
mux_8to4_16bit.v \
sparse_selector_32_16bit.v \
mux_16to1_8bit.v \
mux_16to2_8bit.v \
mux_16to4_8bit.v \
mux_16to8_8bit.v \
mux_32to16_8bit.v \
mux_32to1_8bit.v \
mux_32to4_8bit.v \
mux_32to8_8bit.v \
mux_4to1_8bit.v \
mux_4to2_8bit.v \
mux_8to1_8bit.v \
mux_8to2_8bit.v \
mux_8to4_8bit.v \
sparse_selector_64_8bit.v \
mux_16to1_4bit.v \
mux_16to2_4bit.v \
mux_16to4_4bit.v \
mux_16to8_4bit.v \
mux_32to1_4bit.v \
mux_32to16_4bit.v \
mux_32to4_4bit.v \
mux_32to8_4bit.v \
mux_4to1_4bit.v \
mux_4to2_4bit.v \
mux_8to1_4bit.v \
mux_8to2_4bit.v \
mux_8to4_4bit.v \
sparse_selector_128_4bit.v \
mux_16to1_1bit.v \
mux_16to2_1bit.v \
mux_16to4_1bit.v \
mux_16to8_1bit.v \
mux_32to1_1bit.v \
mux_32to16_1bit.v \
mux_32to4_1bit.v \
mux_32to8_1bit.v \
mux_4to1_1bit.v \
mux_4to2_1bit.v \
mux_8to1_1bit.v \
mux_8to2_1bit.v \
mux_8to4_1bit.v \
sparse_selector_outlier_128.v \
sparse_selector_outlier_64.v \
data_move_16_4_ifmap.v \
data_move_16_8_ifmap.v \
data_move_8_4_ifmap.v \
data_move_16_4.v \
data_move_16_8.v \
data_move_8_4.v \
data_move_ifmap.v \
data_move_weight.v \
data_move_ifmapmask.v \
outlier_compressor.v \
data_move_8_4n.v \
data_move_8_4n_ifmap.v
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

