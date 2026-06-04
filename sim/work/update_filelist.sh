#!/bin/bash

echo "Updating filelist.f"

find ../../rtl -name *.v | tee filelist.f
find ../bench -name *.v | tee -a filelist.f
find ../bench/ram_tb -name *.v | tee -a filelist.f
find ../bench -name *.sv | tee -a filelist.f
find ../../rtl -name *.sv | tee -a filelist.f
find ../../rtl -name *.cpp | tee -a filelist.f

# find ../../submit/rtl -name *.v | tee filelist.f
# find ../bench -name *.v | tee -a filelist.f
# find ../bench -name *.sv | tee -a filelist.f
# find ../../rtl -name *.sv | tee -a filelist.f