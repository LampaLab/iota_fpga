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

`ifndef CURL_MONITOR
`define CURL_MONITOR

`include "curl_params.sv"

class curl_active_monitor extends uvm_monitor;
	
	`uvm_component_utils(curl_active_monitor)
		
	protected int unsigned num_transactions = 0;
	
	virtual interface curl_if vif;
		
	uvm_analysis_port #(curl_packet) transmitted_data_port;
	
	protected curl_packet trans_collected;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);
	
endclass : curl_active_monitor
	
	
	
class curl_passive_monitor extends uvm_monitor;

	`uvm_component_utils(curl_passive_monitor)
	
	protected int unsigned num_resived_transactions = 0;
	
	virtual interface curl_if vif;
	
	uvm_analysis_port #(curl_packet) received_data_port;
	
	protected curl_packet receiv_collected;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function void report_phase(uvm_phase phase);

endclass : curl_passive_monitor



//	UVM Build Phase of active monitor
function void curl_active_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	transmitted_data_port = new("", this);
	if (!uvm_config_db#(virtual interface curl_if)::get(this, "", "vif", vif))
			`uvm_fatal(get_type_name(), "Missing virtual I/F");
endfunction : build_phase

//	UVM Run phase of active monitor
task curl_active_monitor::run_phase(uvm_phase phase);
	int i;
	forever begin 
		@(posedge vif.curl_first_part_hash iff (vif.arst_n));
			trans_collected = curl_packet::type_id::create("trans_collected");
			trans_collected.trits_object_to_dut [`HASH_LENGTH - 1 : 0] = vif.curl_in_hash;
		@(posedge vif.curl_second_part_hash iff (vif.arst_n));
			trans_collected.trits_object_to_dut [2 * `HASH_LENGTH - 1 : `HASH_LENGTH] = vif.curl_in_hash;
				
		for (i = 0; i < `HASH_LENGTH; i++)
			trans_collected.trits_object_queue [i] = trans_collected.trits_object_to_dut [i * 2 +: 2];
		`uvm_info(get_type_name(), {"Transaction Collected."}, UVM_LOW)
		num_transactions++;
		transmitted_data_port.write(trans_collected);
	end 
endtask : run_phase

//	UVM Report phase of active monitor
function void curl_active_monitor::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("Report: CURL active monitor collected %d transfers", num_transactions), UVM_MEDIUM);
endfunction : report_phase



//	UVM Build Phase of passive monitor
function void curl_passive_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	received_data_port = new("", this);
	if (!uvm_config_db#(virtual interface curl_if)::get(this, "", "vif", vif))
			`uvm_fatal(get_type_name(), "Missing virtual I/F");
endfunction : build_phase

//	UVM Run Phase of passive monitor
task curl_passive_monitor::run_phase(uvm_phase phase);
	forever begin 
		@(posedge vif.curl_transform_finish iff (vif.arst_n));
			receiv_collected = curl_packet::type_id::create("receiv_collected");
			receiv_collected.trits_object_from_dut = vif.curl_out_hash;
		`uvm_info(get_type_name(), {"DUT output data collected."}, UVM_LOW)
		num_resived_transactions++;
		received_data_port.write(receiv_collected);
	end 
endtask : run_phase

//	UVM Report Phase of passive monitor
function void curl_passive_monitor::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("Report: Curl passive monitor collected %d transfers", num_resived_transactions), UVM_MEDIUM);
endfunction : report_phase

`endif