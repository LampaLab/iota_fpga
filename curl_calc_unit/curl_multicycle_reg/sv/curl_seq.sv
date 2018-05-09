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

`ifndef CURL_SEQUENCE
`define CURL_SEQUENCE

`include "curl_params.sv"

class curl_seq extends uvm_sequence #(curl_packet);

	`uvm_object_utils(curl_seq)
	
	curl_packet seq_hash_object;
	
	function new(string name = "");
		super.new(name);
	endfunction
	
endclass : curl_seq

class trytes_seq extends curl_seq;
	
	`uvm_object_utils(trytes_seq)
	
	int i;
	
	task body();
		`uvm_info(get_type_name(), "Hash sequence start...", UVM_MEDIUM)
		
		seq_hash_object = curl_packet::type_id::create("seq_hash_object");
		start_item(seq_hash_object);
		
		seq_hash_object.trytes_hash_object = "999999999999999999999999999999999999999999999999999999999999999999999999999999999";
		
		for (i = 0; i < `HASH_LENGTH_TRYTES; i++) begin
			randcase 
				22: seq_hash_object.one_tryte = "9";
				 3: seq_hash_object.one_tryte = "A";
				 3: seq_hash_object.one_tryte = "B";
				 3: seq_hash_object.one_tryte = "C";
				 3: seq_hash_object.one_tryte = "D";
				 3: seq_hash_object.one_tryte = "E";
				 3: seq_hash_object.one_tryte = "F";
				 3: seq_hash_object.one_tryte = "G";
				 3: seq_hash_object.one_tryte = "H";
				 3: seq_hash_object.one_tryte = "I";
				 3: seq_hash_object.one_tryte = "J";
				 3: seq_hash_object.one_tryte = "K";
				 3: seq_hash_object.one_tryte = "L";
				 3: seq_hash_object.one_tryte = "M";
				 3: seq_hash_object.one_tryte = "N";
				 3: seq_hash_object.one_tryte = "O";
				 3: seq_hash_object.one_tryte = "P";
				 3: seq_hash_object.one_tryte = "Q";
				 3: seq_hash_object.one_tryte = "R";
				 3: seq_hash_object.one_tryte = "S";
				 3: seq_hash_object.one_tryte = "T";
				 3: seq_hash_object.one_tryte = "U";
				 3: seq_hash_object.one_tryte = "V";
				 3: seq_hash_object.one_tryte = "W";
				 3: seq_hash_object.one_tryte = "X";
				 3: seq_hash_object.one_tryte = "Y";
				 3: seq_hash_object.one_tryte = "Z";
			endcase
			seq_hash_object.trytes_hash_object.putc(i, seq_hash_object.one_tryte.getc(0));
		end
		
		finish_item(seq_hash_object);
	endtask : body
	
endclass : trytes_seq

class curl_top_sequence extends uvm_sequence;
	
	`uvm_object_utils(curl_top_sequence)
	
	curl_sequencer 	sequencer;
	
	trytes_seq		trytes;
	
	function new(string name = "");
		super.new(name);
	endfunction

	task body();
		if (starting_phase != null)
			starting_phase.raise_objection(this);
				
				trytes = trytes_seq::type_id::create("trytes");
				
				for (int j = 0; j < `NUMBER_OF_TESTS; j++)
					for (int i = 0; i < `MESSAGE_LENGTH; i++)begin
						if (!trytes.randomize())
							`uvm_error("", "Randomize failed.")
						trytes.start(sequencer);
					end
		
		if (starting_phase != null)
			starting_phase.drop_objection(this);
	endtask : body
	
endclass : curl_top_sequence

`endif