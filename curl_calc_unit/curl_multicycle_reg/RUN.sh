# !/bin/bash

cd ./workspace

vlib work
vmap work work
vlog -sv ../curl_tb_top.sv +incdir+../sv +incdir+../rtl +incdir+../ref_model
vsim -novopt -do "run -all; q" curl_tb_top

if [ -d work ]; then vdel -lib work -all; fi;

rm -f transcript modelsim.ini
rm -R work

cd ../