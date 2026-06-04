puts "RM-Info: Running script [info script]\n"

set PTPX_WAVEFORM_FILE             $PTPX_SIM_NAME/$PTPX_WAVEFORM_NAME
set PTPX_RTLNET_MAP_FILE           ${DESIGN_NAME}.rtlnet_map.tcl

set PTPX_SWITCHING_ACTIVITY_REPORT               ${DESIGN_NAME}.switching_activity.rpt
set PTPX_SWITCHING_POWER_REPORT                  ${DESIGN_NAME}.switching_power.rpt
set PTPX_SWITCHING_ACTIVITY_REPORT_POST_ANALYSYS ${DESIGN_NAME}.switching_activity_post_opt.rpt

puts "RM-Info: Completed script [info script]\n"
