source -echo -verbose ./setup/common_setup.tcl
source -echo -verbose ./setup/dc_setup_filenames.tcl
source -echo -verbose ./setup/ptpx_setup_filenames.tcl
source -echo -verbose ./setup/dc_setup.tcl

set power_enable_analysis TRUE     
set power_analysis_mode time_based 

################################################################################
# Read Design Compiler Results
################################################################################

read_verilog ${RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}

current_design ${DESIGN_NAME}

link_design -force -verbose -keep_sub_designs

################################################################################
# Read SDC Constraints
################################################################################

if {[file exists [which ${DCRM_SDC_INPUT_FILE}]]} {
  puts "RM-Info: Reading SDC file [which ${DCRM_SDC_INPUT_FILE}]\n"
  read_sdc ${DCRM_SDC_INPUT_FILE}
}
if {[file exists [which ${DCRM_CONSTRAINTS_INPUT_FILE}]]} {
  puts "RM-Info: Sourcing script file [which ${DCRM_CONSTRAINTS_INPUT_FILE}]\n"
  source -echo -verbose [which ${DCRM_CONSTRAINTS_INPUT_FILE}]
}

################################################################################
# Read name mapping database
################################################################################

source ${PTPX_DIR}/$PTPX_RTLNET_MAP_FILE

################################################################################
# Read switch activity file
################################################################################

read_vcd -rtl $PTPX_WAVEFORM_FILE -strip_path $PTPX_TB_INST_NAME
report_switching_activity -list_not_annotated > ${REPORTS_DIR}/${PTPX_SWITCHING_ACTIVITY_REPORT}

################################################################################
# Power Analysis
################################################################################
check_power
set_power_analysis_options -waveform_format fsdb -waveform_output vcd
update_power 

report_power -verbose > ${REPORTS_DIR}/${PTPX_SWITCHING_POWER_REPORT}
report_switching_activity -list_not_annotated -include_only sequential > ${REPORTS_DIR}/${PTPX_SWITCHING_ACTIVITY_REPORT_POST_ANALYSYS}

exit