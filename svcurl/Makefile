all: compile sim

.PHONY: all compile sim clean

compile: clean
	vlib work
	vmap work work
	vlog -sv trinary_pkg.sv converter_pkg.sv curl_const_pkg.sv curl_pkg.sv
	vlog -sv -dpiheader curl_lib_wrapper.h curl_tb.sv
	g++ -shared -m32 -I$(MODEL_TECH)/../include -fPIC -o curl_lib_wrapper.so curl_lib_wrapper.cc curl.c

sim:
	vsim -c -sv_lib curl_lib_wrapper -novopt -do "run -all; q" tb


clean:
	if [ -d work ]; then vdel -lib work -all; fi;
	rm -f *.so transcript curl_lib_wrapper.h

