WAVETOOL:=gtkwave.exe
SIMTOOL:=verilator
LINTTOOL:=verilator
LANGUAGE:=-sv
SIMTOOL_FLAGS:=-cc
LINTTOOL_FLAGS:=--lint-only
TB_TOP=tb_top

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Generate makefile dependencies (not shown as complicates the Makefile)
VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -x-assign fast
# Warn abount lint issues; may not want this on less solid designs
# VERILATOR_FLAGS += -Wall
# Make waveforms
VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert
# Generate coverage analysis
VERILATOR_FLAGS += --coverage
# Run Verilator in debug mode
# VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt
#include
VERILATOR_FLAGS +=-y ${WORKSPACE}/rtl/systemverilog/
VERILATOR_FLAGS += --trace
# VERILATOR_FLAGS += -CFLAGS -std=gnu++2a



# Input files for Verilator
#timing 
VERILATOR_INPUT += -f ${WORKSPACE}/tb/tool/input.vc 
VERILATOR_INPUT += -Wno-context -Wno-TIMESCALEMOD --no-timing 
VERILATOR_INPUT += ${WORKSPACE}/tb/${TB_TOP}.sv ${WORKSPACE}/tb/tool/${TB_TOP}.cc


# VM_TIMING=1
VM_TIMING+=1

VERILINT_INPUT +=-y ${WORKSPACE}/rtl/systemverilog/
VERILINT_INPUT += -f ${WORKSPACE}/tb/tool/input.vc
VERILINT_INPUT += ${WORKSPACE}/tb/${TB_TOP}.sv




check-env: 
	@echo "WORKSPACE is ${WORKSPACE}!"

clean: check-env
	rm -fR ${WORKSPACE}/out
	rm -f ${WORKSPACE}/model/a.out ${WORKSPACE}/model/*.txt 
	@echo "Clean up done."

lint: 
	mkdir -p ${WORKSPACE}/out; \
	cd ${WORKSPACE}/out; \
	${LINTTOOL} $(LINTTOOL_FLAGS) $(VERILINT_INPUT); 

sim : check-env
	mkdir -p ${WORKSPACE}/out/build; \
	cd ${WORKSPACE}/out/build; \
	${SIMTOOL} $(VERILATOR_FLAGS) $(VERILATOR_INPUT); \
	cp ${WORKSPACE}/tb/tool/Makefile_obj ./; \
	make -j -C obj_dir -f ../Makefile_obj; \
	rm -Rf ${WORKSPACE}/out/logs; \
	mkdir -p ${WORKSPACE}/out/logs; \
	cd ${WORKSPACE}/out; \
	${WORKSPACE}/out/build/obj_dir/Vtb_top +trace
  
sim_debug : check-env
	mkdir -p ${WORKSPACE}/out/build; \
	cd ${WORKSPACE}/out/build; \
	${SIMTOOL} $(VERILATOR_FLAGS) $(VERILATOR_INPUT); \
	cp ${WORKSPACE}/tb/tool/Makefile_obj ./; \
	make -j -C obj_dir -f ../Makefile_obj; \
	rm -Rf ${WORKSPACE}/out/logs; \
	mkdir -p ${WORKSPACE}/out/logs; \
	cd ${WORKSPACE}/out; \
	${WORKSPACE}/out/build/obj_dir/Vtb_top +trace; \
	${WAVETOOL} logs/${TB_TOP}_dump.vcd
  

vsim: check-env
	mkdir -p ${WORKSPACE}/out/build; \
	cd ${WORKSPACE}/out/build; \
	vlib.exe work; \
	export WINWORK=${WINWORK};\
	vlog.exe -sv -svinputport=relaxed -work work +incdir+${WINWORK}/rtl/systemverilog/ +define+SIMULATION -f ${WINWORK}/tb/tool/rtl.f; \
	vlog.exe -sv -svinputport=relaxed -work work +incdir+${WINWORK}/rtl/systemverilog/ ${WINWORK}/tb/${TB_TOP}.sv;

vsim_debug: check-env
	cd ${WORKSPACE}/model; \
	g++ hams.cc; \
	./a.out; \
  mkdir -p ${WORKSPACE}/out/build; \
	cd ${WORKSPACE}/out/build; \
	vlib.exe work; \
	export WINWORK=${WINWORK};\
	vlog.exe -sv -svinputport=relaxed -work work +incdir+${WINWORK}/rtl/systemverilog/ +define+SIMULATION -f ${WINWORK}/tb/tool/rtl.f; \
	vlog.exe -sv -svinputport=relaxed -work work +incdir+${WINWORK}/rtl/systemverilog/ ${WINWORK}/tb/${TB_TOP}.sv; \
	vlog.exe -work ${WINWORK}/out/build/work -refresh -force_refresh; \
	vsim.exe  -L work work.${TB_TOP} -t ps  -do "add log -r sim:/${TB_TOP}/*;force -freeze sim:/tb_top/clk 1 0, 0 {5000 ps} -r 10000;run 10 us;"