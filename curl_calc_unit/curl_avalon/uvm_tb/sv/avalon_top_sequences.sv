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

`ifndef AVALON_TOP_SEQUENCES
`define AVALON_TOP_SEQUENCES

`define NUM_OF_TESTS	500

class avalon_top_sequences extends uvm_sequence;

	`uvm_object_utils(avalon_top_sequences)
		
	avalon_m_sequencer		m_sequencer;
	avalon_s_sequencer		s_sequencer;
	
	//	Master Sequenses
	init_m					master_init;
	source_addr				dut_src_addr;
	destination_addr		dut_dst_addr;
	start_calc				run_dut;
	check_next_seq			check_next_test;
	
	//	Slave Sequences
	init_s					slave_init;
	memory_data				input_hash;
	
	//	Synchronization packet
	synch_data_pkt			wait_next_test;
	
	mailbox #(synch_data_pkt) synch_fifo;
	
	function new(string name = "");
		super.new(name);
		wait_next_test	= new("wait_next_test");
	endfunction
	
	task body();
		
		if (starting_phase != null)
			starting_phase.raise_objection(this);
			
			master_init 	= init_m::type_id::create("master_init");
			dut_src_addr	= source_addr::type_id::create("dut_src_addr");
			dut_dst_addr	= destination_addr::type_id::create("dut_dst_addr");
			run_dut			= start_calc::type_id::create("run_dut");
			check_next_test = check_next_seq::type_id::create("check_next_test");
			
			slave_init		= init_s::type_id::create("slave_init");
			input_hash		= memory_data::type_id::create("input_hash");
			
			master_init.start(m_sequencer);
			slave_init.start(s_sequencer);
			
			wait_next_test.next_seq = synch_data_pkt::WAIT;
			
			for (int i = 0; i < `NUM_OF_TESTS; i++) begin
				input_hash.start(s_sequencer);
				dut_src_addr.start(m_sequencer);
				dut_dst_addr.start(m_sequencer);
				run_dut.start(m_sequencer);	
				do begin 
					#10000;
					check_next_test.start(m_sequencer);
					synch_fifo.get(wait_next_test);
				end while (wait_next_test.next_seq == synch_data_pkt::WAIT);
			end
			
		if (starting_phase != null)
			starting_phase.drop_objection(this);
		
	endtask : body
	
endclass : avalon_top_sequences

`endif