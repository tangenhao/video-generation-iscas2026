DW_PATH="/eda/synopsys22/dc/dw/sim_ver/"
DW03_PATH="/eda/synopsys22/dc/dw/dw03/src_ver/"

sim:
		vcs -full64 \
	-y ${DW_PATH} -y ${DW03_PATH} +libext+.v +incdir+${DW_PATH}+ +incdir+${DW03_PATH}+ \
    -f filelist.f \
    -top $(TOP) \
    -sverilog -timescale=1ns/1ns -debug_acc+dmptf \
    -debug_region+cell+encrypt+lib +lint=TFIPC-L \
    -debug_access+all +vcd+vcdpluson +memcbk +error+999 -LDFLAGS -Wl,--no-as-needed -kdb -lca -l sim.log \
		+define+SIM +incdir+../../rtl/include -fgp
		./simv | tee run.log

fpga_sim:
		vcs -full64 \
	-y ${DW_PATH} -y ${DW03_PATH} +libext+.v +incdir+${DW_PATH}+ +incdir+${DW03_PATH}+ \
    -f filelist.f \
    -top $(TOP) \
    -sverilog -timescale=1ns/1ns -debug_acc+dmptf \
    -debug_region+cell+encrypt+lib +lint=TFIPC-L \
    -debug_access+all +vcd+vcdpluson +memcbk +error+999 -LDFLAGS -Wl,--no-as-needed -kdb -lca -l sim.log \
		+define+SIM +incdir+../../rtl/include +define+FGPA -fgp
		./simv | tee run.log

compile:
		vcs -full64 \
	-y ${DW_PATH} -y ${DW03_PATH} +libext+.v +incdir+${DW_PATH}+ +incdir+${DW03_PATH}+ \
    -f filelist.f \
    -top $(TOP) \
    -sverilog -timescale=1ns/1ns -debug_acc+dmptf \
    -debug_region+cell+encrypt+lib +lint=TFIPC-L \
    -debug_access+all +vcd+vcdpluson +memcbk +error+999 -LDFLAGS -Wl,--no-as-needed -kdb -lca -l sim.log \
		+define+SIM +incdir+../../rtl/include -fgp
		# ./simv | tee run.log

clean:
		rm -rf ./csrc ./DVEfiles *.daidir ./csrc  						\
		*.log  *.vpd  *.vdb  simv* *.key				\
		+race.out* novas* verdi* *fsdb *.dot *.vcd \
		*.alias *.chain *.field *.lock *.netwk *.p2s *.pidat *.podat *.sinf *.slist *.str *.tlist *.xlist *.pdf *.dat

clean_memory:
		rm -rf ../memory/ddr* ../memory/ifmap_mask* ../memory/ifmap_scale* \
		       ../memory/ifmap* ../memory/insn* ../memory/ofmap* ../memory/outlier_index* \
					 ../memory/psum* ../memory/vcucode* ../memory/weight_scale* ../memory/weight*

verdi:
		verdi -sverilog -y ${DW_PATH} -y ${DW03_PATH} +libext+.v +incdir+${DW_PATH}+ +incdir+${DW03_PATH}+ -f filelist.f -top $(TOP) -nologo -ssf *.fsdb -sswr ./signal.rc +define+SIM

fpga_verdi:
		verdi -sverilog -y ${DW_PATH} -y ${DW03_PATH} +libext+.v +incdir+${DW_PATH}+ +incdir+${DW03_PATH}+ -f filelist.f -top $(TOP) -nologo -ssf *.fsdb -sswr ./signal.rc +define+SIM +define+FPGA

update:
		$(SHELL) ./update_filelist.sh 
