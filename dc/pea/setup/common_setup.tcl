puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Variables common to all reference methodology scripts
# Script: common_setup.tcl
# Version: K-2015.06 (July 13, 2015)
# Copyright (C) 2007-2015 Synopsys, Inc. All rights reserved.
##########################################################################################

set DESIGN_NAME                   "pea"  ;#  The name of the top-level design

#  Absolute path prefix variable for library/design data.
#  Use this variable to prefix the common absolute path  
#  to the common variables defined below.
#  Absolute paths are mandatory for hierarchical 
#  reference methodology flow.
set DESIGN_REF_DATA_PATH          [list \
/SSD/maweize/work/dispatch/dc/pea/constraints \
/SSD/maweize/work/dispatch/rtl/pea/common \
/SSD/maweize/work/dispatch/rtl/vcu/common \
/SSD/maweize/work/dispatch/rtl/pea/accumulator \
/SSD/maweize/work/dispatch/rtl/pea/mpt/adder \
/SSD/maweize/work/dispatch/rtl/pea/mpt/multiplier \
/SSD/maweize/work/dispatch/rtl/pea/mpt/ \
/SSD/maweize/work/dispatch/rtl/pea/scale_multiplier/ \
/SSD/maweize/work/dispatch/rtl/pea/sparse/ \
/SSD/maweize/work/dispatch/rtl/pea/sparse/mux_1bit \
/SSD/maweize/work/dispatch/rtl/pea/sparse/mux_4bit \
/SSD/maweize/work/dispatch/rtl/pea/sparse/mux_8bit \
/SSD/maweize/work/dispatch/rtl/pea/sparse/mux_16bit \
/SSD/maweize/work/dispatch/rtl/pea/fma/ \
/SSD/maweize/work/dispatch/rtl/pea/ \
];

##########################################################################################
# Hierarchical Flow Design Variables
##########################################################################################
# List of hierarchical block design names "DesignA DesignB" ...
set HIERARCHICAL_DESIGNS           ""
set HIERARCHICAL_CELLS             "pea" ;# List of hierarchical block cell instance names "u_DesignA u_DesignB" ...

##########################################################################################
# Library Setup Variables
##########################################################################################

# For the following variables, use a blank space to separate multiple entries.
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"
#  Additional search path to be added to the default search path
set ADDITIONAL_SEARCH_PATH  [list \
/SSD/maweize/work/dispatch/dc/pea/constraints \
/SSD/maweize/work/dispatch/rtl/pea/common \
/SSD/maweize/work/dispatch/rtl/vcu/common \
/SSD/maweize/work/dispatch/rtl/pea/accumulator \
/SSD/maweize/work/dispatch/rtl/pea/mpt/adder \
/SSD/maweize/work/dispatch/rtl/pea/mpt/multiplier \
/SSD/maweize/work/dispatch/rtl/pea/mpt/ \
/SSD/maweize/work/dispatch/rtl/pea/scale_multiplier/ \
/SSD/maweize/work/dispatch/rtl/pea/sparse/mux_1bit \
/SSD/maweize/work/dispatch/rtl/pea/sparse/mux_4bit \
/SSD/maweize/work/dispatch/rtl/pea/sparse/mux_8bit \
/SSD/maweize/work/dispatch/rtl/pea/sparse/mux_16bit \
/SSD/maweize/work/dispatch/rtl/pea/sparse/ \
/SSD/maweize/work/dispatch/rtl/pea/fma/ \
/SSD/maweize/work/dispatch/rtl/pea/ \
];

#  Target technology logical libraries
set TARGET_LIBRARY_FILES          [list \
/SSD/TSMC/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_110c/tcbn28hpcplusbwp30p140tt0p9v25c.db \
];

set ADDITIONAL_LINK_LIB_FILES     ""  ;#  Extra link logical libraries not included in TARGET_LIBRARY_FILES

set MIN_LIBRARY_FILES             ""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

set MW_REFERENCE_LIB_DIRS         ""  ;#  Milkyway reference libraries (include IC Compiler ILMs here)

set MW_REFERENCE_CONTROL_FILE     ""  ;#  Reference Control file to define the Milkyway reference libs

set TECH_FILE                     ""  ;#  Milkyway technology file
set MAP_FILE                      ""  ;#  Mapping file for TLUplus
set TLUPLUS_MAX_FILE              ""  ;#  Max TLUplus file
set TLUPLUS_MIN_FILE              ""  ;#  Min TLUplus file

set MIN_ROUTING_LAYER            ""   ;# Min routing layer
set MAX_ROUTING_LAYER            ""   ;# Max routing layer

set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use

##########################################################################################
# Multivoltage Common Variables
#
# Define the following multivoltage common variables for the reference methodology scripts 
# for multivoltage flows. 
# Use as few or as many of the following definitions as needed by your design.
##########################################################################################

# set PD1                          ""           ;# Name of power domain/voltage area  1
# set VA1_COORDINATES              {}           ;# Coordinates for voltage area 1
# set MW_POWER_NET1                "VDD1"       ;# Power net for voltage area 1

# set PD2                          ""           ;# Name of power domain/voltage area  2
# set VA2_COORDINATES              {}           ;# Coordinates for voltage area 2
# set MW_POWER_NET2                "VDD2"       ;# Power net for voltage area 2

# set PD3                          ""           ;# Name of power domain/voltage area  3
# set VA3_COORDINATES              {}           ;# Coordinates for voltage area 3
# set MW_POWER_NET3                "VDD3"       ;# Power net for voltage area 3

# set PD4                          ""           ;# Name of power domain/voltage area  4
# set VA4_COORDINATES              {}           ;# Coordinates for voltage area 4
# set MW_POWER_NET4                "VDD4"       ;# Power net for voltage area 4

set PTPX_TB_INST_NAME            ""           ;# Testbench instance name
set PTPX_SIM_NAME                ""           ;# Simulation directory
set PTPX_WAVEFORM_NAME           ""           ;# Waveform file
set PTPX_SAIF_NAME               ""           ;# SAIF file

puts "RM-Info: Completed script [info script]\n"

