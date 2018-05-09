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

`ifndef AVALON_S_CURL_SEQUENCES
`define AVALON_S_CURL_SEQUENCES

class avalon_s_curl_sequences extends uvm_sequence #(avalon_s_packet);

	`uvm_object_utils(avalon_s_curl_sequences)
	
	avalon_s_packet		seq_object_s;
	
	function new(string name = "");
		super.new(name);
	endfunction 
	
endclass : avalon_s_curl_sequences

class init_s extends avalon_s_curl_sequences;

	`uvm_object_utils(init_s)
	
	task body();
	
		seq_object_s = avalon_s_packet::type_id::create("seq_object_s");
		
		`uvm_info(get_type_name(), "Initialization of Avalon Slave start...", UVM_LOW)
	
		start_item(seq_object_s);
			
			seq_object_s.Command_s			= avalon_s_packet::NOP;
			seq_object_s.Init_s				= avalon_s_packet::INITIALIZATION;
			seq_object_s.minWaitReqDelay	= 1;
			seq_object_s.maxWaitReqDelay	= 5;
			seq_object_s.minValidDelay		= 1;
			seq_object_s.maxValidDelay		= 5;
			seq_object_s.blockSize			= 16;
		
		finish_item(seq_object_s);
	
	endtask : body

endclass : init_s

class memory_data extends avalon_s_curl_sequences;

	`uvm_object_utils(memory_data)
	
	converter	trytes_trits_conv;
	
	rand s_byte_darr_t trytes_in = new[2673];
	s_byte_darr_t trits_in;
	
	const int SRC_ADDR = 'h1000;//addr in 128 bit words
	
	constraint data_in 
    {
        foreach(trytes_in[i]) trytes_in[i] inside {[65:90], 57}; //69-90 are ascii codes range for A-Z
    }
	
	task body();
	
		seq_object_s = avalon_s_packet::type_id::create("seq_object_s");
		
		trytes_trits_conv = converter::type_id::create("trytes_trits_conv");
		
		`uvm_info(get_type_name(), "Initialization of input data for dut in memory start...", UVM_LOW)
		
		this.randomize();
		
		start_item(seq_object_s);
		
			trytes_trits_conv.trits_from_trytes(trytes_in, trits_in);
			
			seq_object_s.Command_s	= avalon_s_packet::PUT_DATA;
			seq_object_s.Init_s		= avalon_s_packet::STANDBY;
			seq_object_s.startAddr	= SRC_ADDR * 16;
			seq_object_s.dataInBuff = u_byte_darr_t'(trits_in);
			`uvm_info(get_type_name(), $sformatf("Input hash = %p", trits_in), UVM_HIGH)
		finish_item(seq_object_s);
		
	endtask : body
	
endclass : memory_data

`endif