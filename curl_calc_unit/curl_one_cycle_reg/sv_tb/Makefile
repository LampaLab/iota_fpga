all: compile sim

.PHONY: all compile sim clean

compile: clean
	vlib work
	vmap work work
	vlog -sv +incdir+../../../svcurl ../../../svcurl/trinary_pkg.sv ../../../svcurl/curl_const_pkg.sv ../../../svcurl/converter_pkg.sv ../../../svcurl/curl_pkg.sv ../rtl/truth_table.v ../rtl/curl_transform_one_cycle.v tb.sv
	
sim:
	vsim -c -novopt -do "run -all; q" tb

clean:
	if [ -d work ]; then vdel -lib work -all; fi;
	if [ -f transcript ]; then rm transcript; fi;
