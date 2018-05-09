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

`ifndef AVALON_M_MONITOR
`define AVALON_M_MONITOR

class avalon_m_active_monitor extends uvm_monitor;
	
	`uvm_component_utils(avalon_m_active_monitor)
	
	protected int unsigned num_avln_m_active_transactions = 0;
	
	virtual interface avalon_m_if 	avln_m_vif;
	
	uvm_analysis_port #(avalon_m_packet) avln_m_trans_data_port;
	
	protected avalon_m_packet trans_collected;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction 
	
	extern virtual function void build_phase	(uvm_phase phase);
	extern virtual task 		 run_phase 		(uvm_phase phase);
	extern virtual function void report_phase 	(uvm_phase phase);
	
endclass : avalon_m_active_monitor



class avalon_m_passive_monitor extends uvm_monitor;
	
	`uvm_component_utils(avalon_m_passive_monitor)
	
	protected int unsigned num_avln_m_passive_transactions = 0;
	
	virtual interface avalon_m_if avln_m_vif;
	
	uvm_analysis_port #(avalon_m_packet) avln_m_res_data_port;
	
	protected avalon_m_packet res_collected;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	extern virtual function void build_phase	(uvm_phase phase);
	extern virtual task 		 run_phase		(uvm_phase phase);
	extern virtual function void report_phase	(uvm_phase phase);
	
endclass : avalon_m_passive_monitor 



function void avalon_m_active_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	avln_m_trans_data_port = new("", this);
	if (!uvm_config_db#(virtual interface avalon_m_if)::get(this, "", "avln_m_vif", avln_m_vif))
			`uvm_fatal(get_type_name(), "Mising virtual I/F for Avalon Master.");
endfunction : build_phase

task avalon_m_active_monitor::run_phase(uvm_phase phase);
	forever begin 
		@(avln_m_vif.cb.address or avln_m_vif.cb.writedata);
		@(negedge avln_m_vif.clk);
		if (!avln_m_vif.cb.write || !avln_m_vif.cb.chipselect)
			wait (avln_m_vif.cb.write && avln_m_vif.cb.chipselect && !avln_m_vif.cb.read);
		trans_collected = avalon_m_packet::type_id::create("trans_collected");
		trans_collected.data_to_dut = avln_m_vif.writedata;
		trans_collected.addr		= avln_m_vif.address;
		`uvm_info(get_type_name(), {"Transaction Collected."}, UVM_LOW)
		num_avln_m_active_transactions++;
		avln_m_trans_data_port.write(trans_collected);
	end 
endtask : run_phase

function void avalon_m_active_monitor::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("Report: Avalon Master active monitor collected %d transfers", 
														num_avln_m_active_transactions), UVM_MEDIUM);
endfunction : report_phase



function void avalon_m_passive_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	avln_m_res_data_port = new("", this);
	if (!uvm_config_db#(virtual interface avalon_m_if)::get(this, "", "avln_m_vif", avln_m_vif))
			`uvm_fatal(get_type_name(), "Mising virtual I/F for Avalon Master.");
endfunction : build_phase

task avalon_m_passive_monitor::run_phase(uvm_phase phase);
	forever begin 
		@(negedge avln_m_vif.cb);
		if (avln_m_vif.readdatavalid) begin
			res_collected = avalon_m_packet::type_id::create("res_collected");
			res_collected.data_from_dut = avln_m_vif.readdata;
			num_avln_m_passive_transactions++;
			avln_m_res_data_port.write(res_collected);
			`uvm_info(get_type_name(), {"Transaction Collected."}, UVM_LOW)
		end
	end 
endtask : run_phase

function void avalon_m_passive_monitor::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("Report: Avalon Master passive monitor collected %d transfers", 
														num_avln_m_passive_transactions), UVM_MEDIUM);
endfunction : report_phase
	
`endif