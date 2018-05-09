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

`ifndef SYNCH_MONITOR
`define SYNCH_MONITOR

class synch_monitor extends uvm_agent;

	`uvm_component_utils(synch_monitor)
	
	uvm_analysis_port #(avalon_m_packet) avln_m_res_data_port;
	
	mailbox #(synch_data_pkt) synch_data_port;
	
	uvm_tlm_analysis_fifo #(avalon_m_packet) avln_m_res_fifo;
	
	protected avalon_m_packet 	synch_data;
	
	protected synch_data_pkt	synch_pkt;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
		synch_data 		= new("synch_data");
		synch_pkt		= new("synch_pkt");
		synch_data_port = new();
	endfunction
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	
endclass : synch_monitor

function void synch_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	avln_m_res_data_port = new("avln_m_res_data_port", this);
	
	avln_m_res_fifo = new("avln_m_res_fifo", this);
endfunction : build_phase

function void synch_monitor::connect_phase(uvm_phase phase);
	avln_m_res_data_port.connect(avln_m_res_fifo.analysis_export);
endfunction : connect_phase

task synch_monitor::run_phase(uvm_phase phase);
	forever begin
		avln_m_res_fifo.get(synch_data);
		if (synch_data.data_from_dut [0] == 1) begin
			synch_pkt.next_seq = synch_data_pkt::NEXT_SEQUENCE;
		end else begin
			synch_pkt.next_seq = synch_data_pkt::WAIT;
		end
		synch_data_port.put(synch_pkt);	
	end
endtask : run_phase

`endif