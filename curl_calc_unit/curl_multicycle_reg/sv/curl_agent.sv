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

`ifndef CURL_AGENT
`define CURL_AGENT

class curl_active_agent extends uvm_agent;
	
	`uvm_component_utils(curl_active_agent)
	
	curl_active_monitor		active_monitor;
	curl_sequencer			sequencer;
	curl_driver				driver;
	
	uvm_analysis_export #(curl_packet) transmitted_data_port;
	
	function new (string name, uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	
endclass : curl_active_agent	



class curl_passive_agent extends uvm_agent;
	
	`uvm_component_utils(curl_passive_agent)
	
	curl_passive_monitor	passive_monitor;
	
	uvm_analysis_export #(curl_packet) received_data_port;
	
	function new (string name, uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	
endclass : curl_passive_agent



//	UVM Build Phase of active agent
function void curl_active_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	transmitted_data_port = new("", this);

	active_monitor = curl_active_monitor::type_id::create("active_monitor",this);
	sequencer = curl_sequencer::type_id::create("sequencer",this);
	driver = curl_driver::type_id::create("driver",this);	
endfunction : build_phase

//	UVM Connect Phase of active agent
function void curl_active_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);	
	driver.seq_item_port.connect(sequencer.seq_item_export);
	active_monitor.transmitted_data_port.connect(transmitted_data_port);
endfunction : connect_phase



//	UVM Build Phase of passive agent
function void curl_passive_agent::build_phase(uvm_phase phase);
	super.connect_phase(phase);
	received_data_port = new("", this);
	
	passive_monitor = curl_passive_monitor::type_id::create("passive_monitor",this);
endfunction : build_phase

//	UVM Connect Phase of passive agent
function void curl_passive_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	passive_monitor.received_data_port.connect(received_data_port);
endfunction : connect_phase

`endif