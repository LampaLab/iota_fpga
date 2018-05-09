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

`ifndef CURL_TESTBENCH
`define CURL_TESTBENCH

`include "uvm_macros.svh"
import uvm_pkg::*;

class curl_test extends uvm_test;
	
	`uvm_component_utils(curl_test)
	
	curl_env			env		;
	curl_top_sequence	top_seq;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void end_of_elaboration();
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
		
endclass : curl_test

function void curl_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	env = curl_env::type_id::create("env", this);
	
endfunction : build_phase

function void curl_test::end_of_elaboration();
	env.set_report_verbosity_level_hier(UVM_NONE);
endfunction : end_of_elaboration

task curl_test::run_phase(uvm_phase phase);
	phase.raise_objection(this);
		`uvm_info(get_type_name(), "Start of tests...", UVM_NONE);
	
		top_seq = curl_top_sequence::type_id::create("top_seq", this);
		
		top_seq.starting_phase = phase;
		
		top_seq.sequencer = env.active_agent.sequencer;
		
		env.ref_model.reset();
		
		top_seq.start(null);
		
		`uvm_info(get_type_name(), "All tests are finished.", UVM_NONE);
	phase.drop_objection(this);
endtask : run_phase

function void curl_test::report_phase(uvm_phase phase);
	int err_cnt;
	int chk_cnt;
	
	if(!uvm_config_db #(int)::get(this, "", "error_counter", err_cnt))
		`uvm_fatal(get_type_name(), "No error counter result")
	else begin
		if (err_cnt == 0)
			`uvm_info(get_type_name(), $sformatf("SUCCESS!"), UVM_NONE)
		else
			`uvm_info(get_type_name(), $sformatf("Test has %d errors!", err_cnt), UVM_NONE)
	end
	
	if(!uvm_config_db #(int)::get(this, "", "checked_counter", chk_cnt))
		`uvm_warning(get_type_name(), "No checker counter result")
	else 
		`uvm_info(get_type_name(), $sformatf("There are %d transfers checked", chk_cnt), UVM_NONE)
endfunction : report_phase

`endif