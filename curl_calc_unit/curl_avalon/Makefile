all: compile sim

.PHONY: all compile sim clean

compile: clean
	vlib work
	vmap work work
	vlog -sv +incdir+./tb/svcurl ./tb/svcurl/trinary_pkg.sv ./tb/svcurl/curl_const_pkg.sv ./tb/svcurl/converter_pkg.sv ./tb/svcurl/curl_pkg.sv
	vlog -sv +incdir+./tb/avalon_verification ./tb/avalon_verification/avalon_m_if.sv ./tb/avalon_verification/avalon_s_if.sv ./tb/avalon_verification/avalon_m.sv ./tb/avalon_verification/avalon_s.sv
	vlog -sv +incdir+./rtl ./rtl/truth_table.v ./rtl/curl_transform_one_cycle.v ./rtl/write_master.v ./rtl/latency_aware_read_master.v ./rtl/curl_avalon.v ./rtl/altera_mf.v
	vlog -sv ./tb/tb.sv
	
sim:
	vsim -c -novopt -do "run -all; q" tb

clean:
	if [ -d work ]; then vdel -lib work -all; fi;
	if [ -f transcript ]; then rm transcript; fi;
