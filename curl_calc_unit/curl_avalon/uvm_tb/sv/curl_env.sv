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
	
	avalon_s_active_agent		avln_s_actv_agnt;
	avalon_s_passive_agent		avln_s_pasv_agnt;
	
	avalon_m_active_agent		avln_m_actv_agnt;
	avalon_m_passive_agent		avln_m_pasv_agnt;
	
	curl_collect_data			collecter;
	
	curl_ref_model_wrapper		ref_model_top;
	
	curl_scoreboard				scrb;
	
	synch_monitor				syn_mon;
	
	function new(string name, uvm_component parent = null);
		super.new(name, parent);
	endfunction 
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
endclass : curl_env

function void curl_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	scrb = curl_scoreboard::type_id::create("scrb", this);
	
	collecter = curl_collect_data::type_id::create("collecter", this);
	
	syn_mon = synch_monitor::type_id::create("syn_mon", this);
	
	ref_model_top = curl_ref_model_wrapper::type_id::create("ref_model_top", this);
	
	avln_s_actv_agnt = avalon_s_active_agent::type_id::create("avln_s_actv_agnt", this);
	avln_s_pasv_agnt = avalon_s_passive_agent::type_id::create("avln_s_pasv_agnt", this);
	
	avln_m_actv_agnt = avalon_m_active_agent::type_id::create("avln_m_actv_agnt", this);
	avln_m_pasv_agnt = avalon_m_passive_agent::type_id::create("avln_m_pasv_agnt", this);
endfunction : build_phase

function void curl_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	avln_s_pasv_agnt.avln_s_res_data_port.connect(collecter.dut_output);
	avln_s_actv_agnt.avln_s_trans_data_port.connect(collecter.dut_input);
	
	avln_m_pasv_agnt.avln_m_res_data_port.connect(syn_mon.avln_m_res_data_port);
	
	collecter.dut_output_to_scrb.connect(scrb.dut_result_port);
	collecter.dut_input_to_ref.connect(ref_model_top.transmitted_data_port);
	
	ref_model_top.scrb_ref_port.connect(scrb.ref_result_port);
endfunction : connect_phase

`endif