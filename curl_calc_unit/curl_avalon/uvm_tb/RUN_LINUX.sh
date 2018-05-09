# !/bin/bash
clear
msim=$(which vsim)
UVM_HOME=$MTI_HOME/uvm-1.1d

cd ./workspace

vlib work
vmap work work
vlog -sv +incdir+../rtl ../rtl/truth_table.v ../rtl/curl_transform_one_cycle.v ../rtl/write_master.v \
	../rtl/latency_aware_read_master.v ../rtl/curl_avalon.v ../rtl/altera_mf.v
vlog -sv -dpiheader curl_lib_wrapper.h ../tb_top.sv +incdir+../sv +incdir+../avalon/slave \
	+incdir+../avalon/master +incdir+../ref_model 
g++ -shared -m32 -I$MTI_HOME/include -fPIC -o curl_lib_wrapper.so \
	../ref_model/curl_lib_wrapper.cc ../ref_model/curl.c
	
vsim -c -sv_lib curl_lib_wrapper -novopt -do "run -all; q" tb_top	
	
if [ -d work ]; then vdel -lib work -all; fi;

rm -f *.so transcript curl_lib_wrapper.h modelsim.ini
rm -R work

cd ../
