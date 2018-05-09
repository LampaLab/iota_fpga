/*MIT License
Copyright (c) 2018 Serhii Sachov
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

`ifndef CURL_SCOREBOARD
`define CURL_SCOREBOARD

`include "uvm_macros.svh"
import uvm_pkg::*;

class curl_scoreboard extends uvm_scoreboard;

	`uvm_component_utils(curl_scoreboard)

	uvm_analysis_export #(avalon_s_packet) dut_result_port;
	uvm_analysis_export #(avalon_s_packet) ref_result_port;
	
	uvm_tlm_analysis_fifo #(avalon_s_packet) dut_fifo_port;
	uvm_tlm_analysis_fifo #(avalon_s_packet) ref_fifo_port;
	
	avalon_s_packet		scrb_dut_pkt;
	avalon_s_packet		scrb_ref_pkt;
	
	int err_cnt = 0;
	int chk_cnt = 0;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		scrb_dut_pkt = new("scrb_dut_pkt");
		scrb_ref_pkt = new("scrb_ref_pkt");
	endfunction 
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function void compare();
	extern virtual function void extract_phase(uvm_phase phase);
	
endclass : curl_scoreboard

function void curl_scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	dut_result_port = new("dut_result_port", this);
	ref_result_port = new("ref_result_port", this);
	
	dut_fifo_port = new("dut_fifo_port", this);
	ref_fifo_port = new("ref_fifo_port", this);
endfunction : build_phase

function void curl_scoreboard::connect_phase(uvm_phase phase);
	dut_result_port.connect(dut_fifo_port.analysis_export);
	ref_result_port.connect(ref_fifo_port.analysis_export);
endfunction : connect_phase

task curl_scoreboard::run_phase(uvm_phase phase);
	forever begin
		ref_fifo_port.get(scrb_ref_pkt);
		`uvm_info(get_type_name(), {"Reference result has been received"}, UVM_LOW)
		dut_fifo_port.get(scrb_dut_pkt);
		`uvm_info(get_type_name(), {"DUT result has been received"}, UVM_LOW)
		compare();
	end
endtask : run_phase

function void curl_scoreboard::compare();
	if (scrb_ref_pkt.ref_out [0:242] !== scrb_dut_pkt.dut_out [0:242]) begin
		`uvm_error(get_type_name(), {"FAIL!"})
		err_cnt++;
	end else
		`uvm_info(get_type_name(), {"SUCCESS!"}, UVM_MEDIUM)
	`uvm_info(get_type_name(), $sformatf("Reference result:\t%p ", scrb_ref_pkt.ref_out [0:242]), UVM_HIGH)
	`uvm_info(get_type_name(), $sformatf("DUT result:\t%p ", scrb_dut_pkt.dut_out [0:242]), UVM_HIGH)
	chk_cnt++;	
endfunction : compare

function void curl_scoreboard::extract_phase(uvm_phase phase);
	uvm_config_db#(int)::set(null, "*", "error_counter", err_cnt);
	uvm_config_db#(int)::set(null, "*", "checked_counter", chk_cnt);
endfunction : extract_phase

`endif