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

`ifndef CONVERTER_SV
`define CONVERTER_SV

class converter extends uvm_sequence_item;

	`uvm_object_utils(converter)			  

	int TRYTE_SPACE = trinary_pkg::TRYTE_SPACE;
	int MIN_TRYTE_VALUE = trinary_pkg::MIN_TRYTE_VALUE;
	int MAX_TRYTE_VALUE = trinary_pkg::MAX_TRYTE_VALUE;
	int RADIX = trinary_pkg::RADIX;
	int MAX_TRIT_VALUE = trinary_pkg::MAX_TRIT_VALUE;
	int MIN_TRIT_VALUE = trinary_pkg::MIN_TRIT_VALUE;
	int NUMBER_OF_TRITS_IN_A_BYTE = trinary_pkg::NUMBER_OF_TRITS_IN_A_BYTE;
	int NUMBER_OF_TRITS_IN_A_TRYTE = trinary_pkg::NUMBER_OF_TRITS_IN_A_TRYTE;
											  
	
	trits_in_tryte_t [0:trinary_pkg::TRYTE_SPACE-1] TRYTE_TO_TRITS_MAPPINGS;
	
	trits_in_tryte_t trits;
	
	function new (string name = "");
		
		super.new(name);
		
		 trits = '0;
	  
		for (int i = 0; i < TRYTE_SPACE; i++) begin
			TRYTE_TO_TRITS_MAPPINGS[i] = trits;
			this.increment(trits);
		end

	endfunction
	
	function automatic void increment(ref trits_in_tryte_t trits);

		for (int i = 0; i < NUMBER_OF_TRITS_IN_A_TRYTE; i++) begin
			trits[i]++;
			if (trits[i] > MAX_TRIT_VALUE)
				trits[i] = MIN_TRIT_VALUE;
			else
				break;
		end
	  
	endfunction : increment
	
	function automatic void trits_from_trytes(ref s_byte_darr_t trytes, ref s_byte_darr_t trits);
	  
		if(trytes.size()>0) begin
	   
			trits = new[trytes.size()*NUMBER_OF_TRITS_IN_A_TRYTE];   
		
			foreach(trytes[i]) begin
				foreach(TRYTE_STRING[j])
					if(TRYTE_STRING[j] == trytes[i]) begin
						trits[3*i] = TRYTE_TO_TRITS_MAPPINGS[j][0];
						trits[3*i+1] = TRYTE_TO_TRITS_MAPPINGS[j][1];
						trits[3*i+2] = TRYTE_TO_TRITS_MAPPINGS[j][2];
						break;
					end
				end
			end
	  
	endfunction : trits_from_trytes
	
	function automatic void trytes_from_trits(ref s_byte_darr_t trytes, ref s_byte_darr_t trits);
	  
		int id = 0;
	  
		if(trits.size()>0) begin
	  
			int len = (trits.size() + NUMBER_OF_TRITS_IN_A_TRYTE - 1) / NUMBER_OF_TRITS_IN_A_TRYTE;
	  
			trytes = new[len+1];
			trytes[len] = "\0";
	  
			for (int i = 0; i < len; i++) begin
				id = trits[i*3] + trits[i*3+1]*3 + trits[i*3+2]*9;
				if(id<0) id += 27;
					trytes[i] = TRYTE_STRING[id]; 
			end
		end

	endfunction : trytes_from_trits

endclass : converter

`endif 
