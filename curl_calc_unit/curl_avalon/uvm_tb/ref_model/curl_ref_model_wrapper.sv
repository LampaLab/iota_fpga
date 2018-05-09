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

`ifndef CURL_REF_MODEL_WRAPPER
`define CURL_REF_MODEL_WRAPPER

`include "uvm_macros.svh"
import uvm_pkg::*;

import "DPI-C" context function void curl_lib_wrapper(input s_byte_darr_t in, inout s_byte_darr_t out);

class curl_ref_model_wrapper extends uvm_agent;

	`uvm_component_utils(curl_ref_model_wrapper)
	
	uvm_analysis_export #(avalon_s_packet) transmitted_data_port;
	
	uvm_tlm_analysis_fifo #(avalon_s_packet) transmitted_fifo_port;
	
	uvm_analysis_export #(avalon_s_packet) scrb_ref_port;
	
	avalon_s_packet		ref_pkt;
	avalon_s_packet		in_trans_coll;
	
	s_byte_darr_t trits_in;
    s_byte_darr_t trits_out_golden = new[curl_const_pkg::HASH_LENGTH];
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction 
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
	
endclass : curl_ref_model_wrapper													  

function void curl_ref_model_wrapper::build_phase(uvm_phase phase);
	super.build_phase(phase);
	ref_pkt = new("ref_pkt");
	in_trans_coll = new("in_trans_coll");
		
	transmitted_data_port = new("transmitted_data_port", this);
	transmitted_fifo_port = new("transmitted_fifo_port", this);
	scrb_ref_port = new("scrb_ref_port", this);
endfunction : build_phase

function void curl_ref_model_wrapper::connect_phase(uvm_phase phase);
	transmitted_data_port.connect(transmitted_fifo_port.analysis_export);
endfunction : connect_phase

task curl_ref_model_wrapper::run_phase(uvm_phase phase);
	int i;
	trits_in  = s_reset_value;
	ref_pkt.ref_out = us_reset_value;
	forever begin
		transmitted_fifo_port.get(in_trans_coll);
		for (i = 0; i < 8019; i++) 
			trits_in [i] = in_trans_coll.dut_in [i];
		`uvm_info(get_type_name(), $sformatf("INPUT_TRANS_SIZE = %p", trits_in), UVM_HIGH)
		`uvm_info(get_type_name(), {"Curl reference model starts calculation..."}, UVM_LOW)
		curl_lib_wrapper(trits_in, trits_out_golden);
		`uvm_info(get_type_name(), {"Curl reference model finish calculation."}, UVM_LOW)
		`uvm_info(get_type_name(), $sformatf("REFERENCE = %p", trits_out_golden), UVM_HIGH)
		for (int i = 0; i < 243; i++) begin
			if (trits_out_golden [i] == 2'sd0)
				ref_pkt.ref_out [i] = 8'd0;
			else if (trits_out_golden [i] == 2'sd1)
				ref_pkt.ref_out [i] = 8'd1;
			else if (trits_out_golden [i] == -2'sd1)
				ref_pkt.ref_out [i] = 8'd255;
		end	
		scrb_ref_port.write(ref_pkt);
	end
endtask : run_phase
													  
`endif
