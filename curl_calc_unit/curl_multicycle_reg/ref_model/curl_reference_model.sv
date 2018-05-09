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

`ifndef CURL_REFERENCE_MODEL
`define CURL_REFERENCE_MODEL

`include "../sv/curl_params.sv"

class curl_reference_model extends uvm_agent;

	`uvm_component_utils(curl_reference_model)
	
	uvm_analysis_export #(curl_packet) transmitted_data_port;
	
	uvm_tlm_analysis_fifo #(curl_packet) transmitted_fifo_port;
	
	uvm_analysis_export #(curl_packet) scrb_ref_port;
	
	curl_packet ref_pkt;
	curl_packet trans_collected;
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern function void reset();
	extern function void absorb(curl_packet trans_collected);
	extern function void squeeze(curl_packet trans_collected);
	extern function void transform();
    extern virtual task run_phase(uvm_phase phase);  
	
endclass : curl_reference_model
	
function void curl_reference_model::build_phase(uvm_phase phase);
	super.build_phase(phase);
	ref_pkt = new("ref_pkt");
	trans_collected = new("trans_collected");
  
	transmitted_data_port = new("transmitted_data_port", this);
	transmitted_fifo_port = new("transmitted_fifo_port", this);
	scrb_ref_port = new("scrb_ref_port",this);
endfunction : build_phase	

function void curl_reference_model::connect_phase(uvm_phase phase);
	transmitted_data_port.connect(transmitted_fifo_port.analysis_export);
endfunction : connect_phase

function void curl_reference_model::reset();
	int i;
	for (i = 0; i < `STATE_LENGTH; i++) 
		ref_pkt.state_queue[i] = 0;
endfunction : reset
	
function void curl_reference_model::absorb(curl_packet trans_collected);
	int offset;
	int length;
	int i;
	offset = 0;
	i = 0;
	length = trans_collected.trits_object_queue.size();
	while (length > 0) begin
		ref_pkt.state_queue [0 : `HASH_LENGTH - 1] = trans_collected.trits_object_queue [0 + offset : `HASH_LENGTH - 1 + offset];
		transform();
		i = i + 1;
		offset = offset + `HASH_LENGTH;
		length = length - `HASH_LENGTH;
	end
endfunction : absorb
	
function void curl_reference_model::squeeze(curl_packet trans_collected);
	int offset;
	int length;
	offset = 0;
	length =  trans_collected.trits_object_queue.size();
	while (length > 0) begin
		ref_pkt.trits_object_queue [0 + offset : `HASH_LENGTH - 1 + offset] = ref_pkt.state_queue [0 : `HASH_LENGTH - 1];
		//transform();
		offset = offset + `HASH_LENGTH;
		length = length - `HASH_LENGTH;
	end
endfunction : squeeze
	
function void curl_reference_model::transform();
	int round;
	int stateIndex;		
	logic signed [1:0] scratchpad [$];					
	for (round = 0; round < `NUMBER_OF_ROUNDS; round++) begin
		scratchpad [0: `STATE_LENGTH - 1] = ref_pkt.state_queue [0 : `STATE_LENGTH - 1];				
			for (stateIndex = 0; stateIndex < `STATE_LENGTH; stateIndex++) begin
				ref_pkt.state_queue [stateIndex] = ref_pkt.TRUTH_TABLE [ scratchpad[ref_pkt.INDEX_TABLE[stateIndex]] + 
															(scratchpad[ref_pkt.INDEX_TABLE[stateIndex + 1]] << 2) + 5 ];
			end	
	end
endfunction : transform

task curl_reference_model::run_phase(uvm_phase phase);
	reset();
	forever begin
		transmitted_fifo_port.get(trans_collected);
		`uvm_info(get_type_name(), {"Absorb phase starts..."}, UVM_LOW)
		absorb(trans_collected);
		`uvm_info(get_type_name(), {"Absorb phase complete."}, UVM_LOW)
		`uvm_info(get_type_name(), {"Squeeze phase starts..."}, UVM_LOW)
		squeeze(trans_collected);
		`uvm_info(get_type_name(), {"Squeeze phase complete."}, UVM_LOW)
		for (int i = 0; i < `HASH_LENGTH; i++)
          ref_pkt.trits_object [i * 2 +: 2] = ref_pkt.trits_object_queue [i];
		scrb_ref_port.write(ref_pkt);
	end
endtask : run_phase
      
`endif