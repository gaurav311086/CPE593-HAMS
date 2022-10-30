SIMTOOL:=verilator
LINTTOOL:=verilator
LANGUAGE:=-sv
SIMTOOL_FLAGS:=-cc
LINTTOOL_FLAGS:=--lint-only
TB_TOP=tb_top

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Generate makefile dependencies (not shown as complicates the Makefile)
# VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -x-assign fast
# Warn abount lint issues; may not want this on less solid designs
# VERILATOR_FLAGS += -Wall
# Make waveforms
VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
# VERILATOR_FLAGS += --assert
# Generate coverage analysis
# VERILATOR_FLAGS += --coverage
# Run Verilator in debug mode
# VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt
#include
VERILATOR_FLAGS +=-y ${STEM}/rtl/systemverilog/
VERILATOR_FLAGS += --trace
# VERILATOR_FLAGS += -CFLAGS -std=gnu++2a



# Input files for Verilator
#timing 
VERILATOR_INPUT += -f ${STEM}/tb/tool/input.vc 
VERILATOR_INPUT += -Wno-TIMESCALEMOD --no-timing
VERILATOR_INPUT += ${STEM}/tb/${TB_TOP}.sv ${STEM}/tb/tool/${TB_TOP}.cc


# VM_TIMING=1
VM_TIMING+=1

VERILINT_INPUT +=-y ${STEM}/rtl/systemverilog/
VERILINT_INPUT += -f ${STEM}/tb/tool/input.vc
VERILINT_INPUT += ${STEM}/tb/${TB_TOP}.sv




check-env: 
	@echo "STEM is ${STEM}!"

clean: check-env
	rm -fR ${STEM}/out
	@echo "Clean up done."

lint: 
	mkdir -p ${STEM}/out; \
	cd ${STEM}/out; \
	${LINTTOOL} $(LINTTOOL_FLAGS) $(VERILINT_INPUT); 

sim : check-env
	mkdir -p ${STEM}/out/build; \
	cd ${STEM}/out/build; \
	${SIMTOOL} $(VERILATOR_FLAGS) $(VERILATOR_INPUT); \
	cp ${STEM}/tb/tool/Makefile_obj ./; \
	make -j -C obj_dir -f ../Makefile_obj; \
	@rm -Rf logs; \
	@mkdir -p logs; \
	obj_dir/Vtb_top +trace
