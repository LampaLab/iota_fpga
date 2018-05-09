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

`ifndef CURL_ENV
`define CURL_ENV

class curl_env extends uvm_env;
	
	`uvm_component_utils(curl_env)	
		
	curl_active_agent 		active_agent;
	curl_passive_agent		passive_agent;
	curl_scoreboard			scrb;
	curl_reference_model	ref_model;
		
	function new(string name, uvm_component parent = null);
		super.new(name, parent);
	endfunction 
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	
endclass : curl_env

function void curl_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	scrb = curl_scoreboard::type_id::create("scrb",this);
	active_agent = curl_active_agent::type_id::create("active_agent",this);
	passive_agent = curl_passive_agent::type_id::create("passive_agent",this);
	ref_model = curl_reference_model::type_id::create("ref_model", this);
endfunction : build_phase

function void curl_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	active_agent.transmitted_data_port.connect(ref_model.transmitted_data_port);
	ref_model.scrb_ref_port.connect(scrb.scrb_ref_port);
	passive_agent.received_data_port.connect(scrb.scrb_received_data_port);
endfunction : connect_phase

`endif