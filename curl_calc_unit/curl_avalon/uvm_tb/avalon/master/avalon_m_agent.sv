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

`ifndef AVALON_M_AGENT
`define AVALON_M_AGENT

class avalon_m_active_agent extends uvm_agent;

	`uvm_component_utils(avalon_m_active_agent)
	
	avalon_m_active_monitor		avln_m_active_mon;
	avalon_m_sequencer			avln_m_sequencer;
	avalon_m_driver				avln_m_driver;
	
	uvm_analysis_port #(avalon_m_packet) avln_m_trans_data_port;
	
	function new (string name, uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	extern virtual function void build_phase 	(uvm_phase phase);
	extern virtual function void connect_phase 	(uvm_phase phase);
	
endclass : avalon_m_active_agent



class avalon_m_passive_agent extends uvm_agent;
	
	`uvm_component_utils(avalon_m_passive_agent)
	
	avalon_m_passive_monitor	avln_m_passive_mon;
	
	uvm_analysis_port #(avalon_m_packet) avln_m_res_data_port;
	
	function new (string name, uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	extern virtual function void build_phase 	(uvm_phase phase);
	extern virtual function void connect_phase 	(uvm_phase phase);
	
endclass : avalon_m_passive_agent



function void avalon_m_active_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	avln_m_trans_data_port = new("", this);
	
	avln_m_active_mon 	= avalon_m_active_monitor::type_id::create("avln_m_active_mon", this);
	avln_m_driver		= avalon_m_driver::type_id::create("avln_m_driver", this);
	avln_m_sequencer	= avalon_m_sequencer::type_id::create("avln_m_sequencer", this);
endfunction : build_phase

function void avalon_m_active_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	avln_m_driver.seq_item_port.connect(avln_m_sequencer.seq_item_export);
	avln_m_active_mon.avln_m_trans_data_port.connect(avln_m_trans_data_port);
endfunction : connect_phase



function void avalon_m_passive_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	avln_m_res_data_port = new("", this);
	
	avln_m_passive_mon = avalon_m_passive_monitor::type_id::create("avln_m_passive_mon", this);
endfunction : build_phase

function void avalon_m_passive_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	avln_m_passive_mon.avln_m_res_data_port.connect(avln_m_res_data_port);
endfunction : connect_phase

`endif