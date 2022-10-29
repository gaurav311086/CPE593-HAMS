SIMTOOL:=verilator
LINTTOOL:=verilator
LANGUAGE:=-sv
SIMTOOL_FLAGS:=-cc
LINTTOOL_FLAGS:=--lint-only

check-env: 
	@echo "STEM is ${STEM}!"

lint: 
	mkdir -p ${STEM}/out/lint; \
	cd ${STEM}/out/lint; \
	${LINTTOOL} ${LANGUAGE} ${LINTTOOL_FLAGS} -y ${STEM}/rtl/systemverilog/ ${STEM}/rtl/systemverilog/hams_Mele_sort.sv


compile: check-env 
	mkdir -p ${STEM}/out/build; \
	cd ${STEM}/out/build; \
	${SIMTOOL} ${LANGUAGE} ${SIMTOOL_FLAGS}   -y ${STEM}/rtl/systemverilog/ ${STEM}/rtl/systemverilog/hams_Mele_sort.sv


clean: check-env
	rm -fR ${STEM}/out
	@echo "Clean up done."

sim: check-env 
	mkdir -p ${STEM}/out/build; \
	cd ${STEM}/out/build; \
	${SIMTOOL} ${LANGUAGE} ${SIMTOOL_FLAGS}  -Wno-TIMESCALEMOD -y ${STEM}/rtl/systemverilog/ --timing --hierarchical ${STEM}/tb/tb_top.sv
  
