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

`ifndef CURL_COLLECT_DATA
`define CURL_COLLECT_DATA

class curl_collect_data extends uvm_agent;

	`uvm_component_utils(curl_collect_data)
	
	uvm_analysis_export #(avalon_s_packet) dut_input;
	uvm_analysis_export #(avalon_s_packet) dut_output;
	
	uvm_analysis_export #(avalon_s_packet) dut_output_to_scrb;
	uvm_analysis_export #(avalon_s_packet) dut_input_to_ref;
	 
	
	uvm_tlm_analysis_fifo #(avalon_s_packet) dut_in_fifo_port;
	uvm_tlm_analysis_fifo #(avalon_s_packet) dut_out_fifo_port;
	
	s_byte_darr_t trits_in;
	s_byte_darr_t trits_out_dut;
	
	logic [64255:0] input_trans;
	logic [2047 :0] output_trans;
	
	protected avalon_s_packet input_trits;
	protected avalon_s_packet output_trits;
	
	protected avalon_s_packet coll_in_trits;
	protected avalon_s_packet coll_out_trits;
	
	int in_cnt = 0;
	int out_cnt = 0;
	
	function new (string name, uvm_component parent = null);
		super.new(name, parent);
		
		input_trits 	= new("input_trits");
		output_trits 	= new("output_trits");
		
		coll_in_trits	= new("coll_in_trits");
		coll_out_trits	= new("coll_out_trits");
	endfunction	 
	
	extern virtual function void build_phase 	(uvm_phase phase);
	extern virtual function void connect_phase 	(uvm_phase phase);
	extern virtual task			 run_phase		(uvm_phase phase);
	extern virtual task 		 collect_input_data();
	extern virtual task 		 collect_output_data();
	
endclass : curl_collect_data

function void curl_collect_data::build_phase(uvm_phase phase);
	super.build_phase(phase);
	dut_input 	= new("dut_input", this);
	dut_output	= new("dut_output", this);
	
	dut_output_to_scrb 	= new("dut_output_to_scrb", this);
	dut_input_to_ref	= new("dut_input_to_ref", this);
	
	dut_in_fifo_port	= new("dut_in_fifo_port", this);
	dut_out_fifo_port	= new("dut_out_fifo_port", this);
endfunction : build_phase

function void curl_collect_data::connect_phase(uvm_phase phase);
	dut_input.connect(dut_in_fifo_port.analysis_export);
	dut_output.connect(dut_out_fifo_port.analysis_export);
endfunction : connect_phase

task curl_collect_data::run_phase(uvm_phase phase);
	fork
		collect_input_data();
		collect_output_data();
	join_none
endtask : run_phase

task curl_collect_data::collect_input_data();
	forever begin
		do begin
			dut_in_fifo_port.get(input_trits);
			input_trans [in_cnt * 128 +: 128] = input_trits.data_to_dut [127:0];
			in_cnt++;
		end while (in_cnt !== 502);
		in_cnt = 0;
		coll_in_trits.dut_in = $unsigned(pack2unpack(input_trans [64151:0], 8019));
		dut_input_to_ref.write(coll_in_trits);
	end
endtask : collect_input_data

task curl_collect_data::collect_output_data();
	forever begin
		do begin
			dut_out_fifo_port.get(output_trits);
			output_trans [out_cnt * 128 +: 128] = output_trits.data_from_dut [127:0];
			out_cnt++;
		end while (out_cnt !== 16);
		out_cnt = 0;
		coll_out_trits.dut_out = $unsigned(pack2unpack(output_trans [1943:0], 243));
		//`uvm_info(get_type_name(), $sformatf("OUTPUT_TRANS = %p", coll_out_trits.dut_out [0:242]), UVM_HIGH)
		dut_output_to_scrb.write(coll_out_trits);
	end
endtask : collect_output_data

`endif