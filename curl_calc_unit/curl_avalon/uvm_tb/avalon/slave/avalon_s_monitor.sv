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

`ifndef AVALON_S_MONITOR
`define AVALON_S_MONITOR

class avalon_s_active_monitor extends uvm_monitor;

	`uvm_component_utils(avalon_s_active_monitor)
	
	protected int unsigned num_avln_s_active_transactions = 0;
	
	virtual interface avalon_s_if avln_s_vif;
	
	uvm_analysis_port #(avalon_s_packet) avln_s_trans_data_port;
	
	protected avalon_s_packet trans_collected_s;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
	
	extern virtual function void build_phase 	(uvm_phase phase);
	extern virtual task			 run_phase	 	(uvm_phase phase);
	extern virtual function void report_phase 	(uvm_phase phase);
	
endclass : avalon_s_active_monitor



class avalon_s_passive_monitor extends uvm_monitor;
	
	`uvm_component_utils(avalon_s_passive_monitor)
	
	protected int unsigned num_avln_s_passive_transactions = 0;
	
	virtual interface avalon_s_if avln_s_vif;
	
	uvm_analysis_port #(avalon_s_packet) avln_s_addr_data_port;
	uvm_analysis_port #(avalon_s_packet) avln_s_res_data_port;
	
	protected avalon_s_packet res_collected;
	protected avalon_s_packet addr_collected;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction 
	
	extern virtual function void build_phase	(uvm_phase phase);
	extern virtual task 		 run_phase		(uvm_phase phase);
	extern virtual function void report_phase	(uvm_phase phase);

endclass : avalon_s_passive_monitor



function void avalon_s_active_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	avln_s_trans_data_port = new("", this);
	if (!uvm_config_db#(virtual interface avalon_s_if)::get(this, "", "avln_s_vif", avln_s_vif))
			`uvm_fatal(get_type_name(), "Mising virtual I/F for Avalon Slave.");
endfunction : build_phase

task avalon_s_active_monitor::run_phase(uvm_phase phase);
	forever begin
		@(negedge avln_s_vif.cb);
		if (avln_s_vif.readdatavalid) begin
			trans_collected_s = avalon_s_packet::type_id::create("trans_collected_s");
			trans_collected_s.data_to_dut = avln_s_vif.readdata;
			num_avln_s_active_transactions++;
			avln_s_trans_data_port.write(trans_collected_s);
			`uvm_info(get_type_name(), {"Transaction Collected."}, UVM_LOW)
		end
	end
endtask : run_phase

function void avalon_s_active_monitor::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("Report: Avalon Slave active monitor collected %d transfers", 
														num_avln_s_active_transactions), UVM_MEDIUM);
endfunction : report_phase



function void avalon_s_passive_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	avln_s_res_data_port = new("", this);
	avln_s_addr_data_port = new("", this);
	if (!uvm_config_db#(virtual interface avalon_s_if)::get(this, "", "avln_s_vif", avln_s_vif))
			`uvm_fatal(get_type_name(), "Mising virtual I/F for Avalon Slave.");
endfunction : build_phase

task avalon_s_passive_monitor::run_phase(uvm_phase phase);
	fork	
		begin : read_data
			forever begin
				@(avln_s_vif.cb.address);
				@(negedge avln_s_vif.clk);
				if (!avln_s_vif.cb.read || !avln_s_vif.cb.chipselect) 
					wait (avln_s_vif.cb.read && avln_s_vif.cb.chipselect && !avln_s_vif.cb.write);
				addr_collected = avalon_s_packet::type_id::create("addr_collected");
				`uvm_info(get_type_name(), {"Transaction Collected."}, UVM_LOW)
				addr_collected.address	= avln_s_vif.cb.address;
				addr_collected.Operation = avalon_s_packet::READ_DATA;
				avln_s_addr_data_port.write(addr_collected);
				num_avln_s_passive_transactions++;
			end
		end
		begin :	write_data
			forever begin
				@(posedge avln_s_vif.write);
				res_collected = avalon_s_packet::type_id::create("res_collected");
				res_collected.data_from_dut = avln_s_vif.writedata;
				res_collected.address		= avln_s_vif.address;
				res_collected.Operation = avalon_s_packet::WRITE_DATA;
				`uvm_info(get_type_name(), {"Transaction Collected."}, UVM_LOW)
				num_avln_s_passive_transactions++;
				avln_s_res_data_port.write(res_collected);
			end
		end
	join
endtask : run_phase

function void avalon_s_passive_monitor::report_phase(uvm_phase phase);
	`uvm_info(get_type_name(), $sformatf("Report: Avalon Slave passive monitor collected %d transfers", 
														num_avln_s_passive_transactions), UVM_MEDIUM);
endfunction : report_phase

`endif