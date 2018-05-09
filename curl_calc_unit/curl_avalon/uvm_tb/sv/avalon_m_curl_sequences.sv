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

`ifndef AVALON_M_CURL_SEQUENCES
`define AVALON_M_CURL_SEQUENCES

class avalon_m_curl_sequences extends uvm_sequence #(avalon_m_packet);

	`uvm_object_utils(avalon_m_curl_sequences)
	
	avalon_m_packet		seq_object_m;
	
	const int SRC_ADDR = 'h1000;
    const int DST_ADDR = 'h100000;
	
	typedef bit [7:0] ubyte;
    typedef ubyte ctrl_word_t[0:3];
    ctrl_word_t ctrl_word;
	
	function new(string name = "");
		super.new(name);
	endfunction 

endclass : avalon_m_curl_sequences

class init_m extends avalon_m_curl_sequences;

	`uvm_object_utils(init_m)

	task body();
	
		seq_object_m = avalon_m_packet::type_id::create("seq_object_m");
		
		`uvm_info(get_type_name(), "Initialization of Avalon Master start...", UVM_LOW)
		
		start_item(seq_object_m);
		
			seq_object_m.Command_m				= avalon_m_packet::NOP;
			seq_object_m.Wait_command_done		= avalon_m_packet::RUN;
			seq_object_m.Init_m	 				= avalon_m_packet::INITIALIZATION;
			seq_object_m.minBurst				= 0;
			seq_object_m.maxBurst				= 10;
			seq_object_m.minWait				= 0;
			seq_object_m.maxWait				= 10;
			seq_object_m.burstCntWrData			= 0;
			seq_object_m.maxBurstLenWrData		= 0;
			seq_object_m.blockSize 				= 4;
			seq_object_m.waitReqTimeOut			= 10000;
			seq_object_m.validTimeOut			= 10000;
		
		finish_item(seq_object_m);
		
	endtask : body
	
endclass : init_m

class source_addr extends avalon_m_curl_sequences;

	`uvm_object_utils(source_addr)
	
	task body();
		
		seq_object_m = avalon_m_packet::type_id::create("seq_object_m");
		
		`uvm_info(get_type_name(), "Initialization of source addr for DUT start...", UVM_LOW)
		
		{<<ubyte{ctrl_word}} = SRC_ADDR;
		
		start_item(seq_object_m);
		
			seq_object_m.Command_m				= avalon_m_packet::WRITE_DATA;
			seq_object_m.Wait_command_done		= avalon_m_packet::RUN;
			seq_object_m.Init_m	 				= avalon_m_packet::STANDBY;
			seq_object_m.addr					= 4;
			seq_object_m.inBuff					= ctrl_word;
			seq_object_m.burstEn				= 0;
		
		finish_item(seq_object_m);
		
	endtask : body
		
endclass : source_addr

class destination_addr extends avalon_m_curl_sequences;

	`uvm_object_utils(destination_addr)
	
	task body();
	
		seq_object_m = avalon_m_packet::type_id::create("seq_object_m");
		
		`uvm_info(get_type_name(), "Initialization of destination addr for DUT start...", UVM_LOW)
		
		{<<ubyte{ctrl_word}} = DST_ADDR;
		
		start_item(seq_object_m);
			
			seq_object_m.Command_m				= avalon_m_packet::WRITE_DATA;
			seq_object_m.Wait_command_done		= avalon_m_packet::RUN;
			seq_object_m.Init_m	 				= avalon_m_packet::STANDBY;
			seq_object_m.addr					= 8;
			seq_object_m.inBuff					= ctrl_word;
			seq_object_m.burstEn				= 0;
			
		finish_item(seq_object_m);
		
	endtask : body

endclass : destination_addr

class start_calc extends avalon_m_curl_sequences;

	`uvm_object_utils(start_calc)
	
	task body();
	
		seq_object_m = avalon_m_packet::type_id::create("seq_object_m");
		
		`uvm_info(get_type_name(), "Final initialization for DUT start...", UVM_LOW)
		
		 ctrl_word[0] = 2;
         ctrl_word[1] = (3*2673 & 8'hff);
         ctrl_word[2] = (3*2673 >> 8);
		
		start_item(seq_object_m);
		
			seq_object_m.Command_m				= avalon_m_packet::WRITE_DATA;
			seq_object_m.Wait_command_done		= avalon_m_packet::WAIT;
			seq_object_m.Init_m	 				= avalon_m_packet::STANDBY;
			seq_object_m.addr					= 0;
			seq_object_m.inBuff					= ctrl_word;
			seq_object_m.burstEn				= 0;
		
		finish_item(seq_object_m);
		
	endtask

endclass : start_calc

class check_next_seq extends avalon_m_curl_sequences;
	
	`uvm_object_utils(check_next_seq)
	
	task body();
		
		seq_object_m = avalon_m_packet::type_id::create("seq_object_m");
		
		start_item(seq_object_m);
		
			seq_object_m.Command_m				= avalon_m_packet::READ_DATA;
			seq_object_m.Wait_command_done		= avalon_m_packet::WAIT;
			seq_object_m.Init_m	 				= avalon_m_packet::STANDBY;
			seq_object_m.addr					= 0;
			seq_object_m.byteLen				= 4;
			seq_object_m.burstEn				= 0;
		
		finish_item(seq_object_m);
		
	endtask
	
endclass : check_next_seq

`endif