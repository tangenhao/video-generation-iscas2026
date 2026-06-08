source -echo -verbose ./setup/common_setup.tcl
source -echo -verbose ./setup/dc_setup_filenames.tcl
source -echo -verbose ./setup/ptpx_setup_filenames.tcl
source -echo -verbose ./setup/dc_setup.tcl

# Define the verification setup file for Formality
set_svf ${RESULTS_DIR}/${DCRM_SVF_OUTPUT_FILE}

#################################################################################
# Setup SAIF Name Mapping Database
#
# Include an RTL SAIF for better power optimization and analysis.
#
# saif_map should be issued prior to RTL elaboration to create a name mapping
# database for better annotation.
################################################################################

saif_map -start

#################################################################################
# Read in the RTL Design
#
# Read in the RTL source files or read in the elaborated design (.ddc).
#################################################################################

define_design_lib WORK -path ./WORK

analyze -format verilog ${RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}
elaborate ${DESIGN_NAME}

current_design ${DESIGN_NAME}

# Read VCD waveform file
sh fsdb2saif $PTPX_WAVEFORM_FILE -o ${PTPX_DIR}/$PTPX_SAIF_NAME
saif_map -create_map -source_instance $PTPX_TB_INST_NAME -input ${PTPX_DIR}/$PTPX_SAIF_NAME
saif_map -write_map ${PTPX_DIR}/$PTPX_RTLNET_MAP_FILE -type ptpx

exit