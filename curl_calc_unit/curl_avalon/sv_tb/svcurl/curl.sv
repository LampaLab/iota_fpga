/*MIT License

Copyright (c) 2018 Ievgen Korokyi

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

`ifndef CURL_SV
`define CURL_SV

class Curl  #(int HASH_LENGTH = curl_const_pkg::HASH_LENGTH,
              int STATE_LENGTH = curl_const_pkg::STATE_LENGTH,
              int NUMBER_OF_ROUNDS = curl_const_pkg::NUMBER_OF_ROUNDS
              );
  
    signed_byte_t [0:8] TRUTH_TABLE = '{1, 0, -1, 1, -1, 0, -1, 1, 0};

    signed_byte_t [0:STATE_LENGTH-1] state;
    signed_byte_t [0:STATE_LENGTH-1] tmp_state;

    function new();
        state = '0;
    endfunction
	
    function automatic void absorb(const ref s_byte_darr_t trits);
 
        int len = trits.size();
        int offset = 0;
        int num = 0;
    
        state = '0;
    
        if (len > 0)
        do begin 
            num = (len < HASH_LENGTH) ? len : HASH_LENGTH;
            for(int i=0; i < num; i++)
                state[i] = trits[offset + i];
            this.transform();
            //$display("%p", state);
	        offset += HASH_LENGTH;
        end while( (len -= HASH_LENGTH) > 0 );
 
    endfunction

    function automatic void reset();
        state = '0;
	endfunction  
	
	function automatic void squeeze(ref s_byte_darr_t trits, input int len);
	 
        int offset = 0;
        int num = 0;
        trits = new[len];

        if (len > 0) 
        do begin
            num = (len < HASH_LENGTH) ? len : HASH_LENGTH;
            for(int i=0; i < num; i++)
                trits[offset + i] = state[i];
	        this.transform(); 
	        offset += HASH_LENGTH;
	    end while( (len -= HASH_LENGTH) > 0 );  
	  	
	endfunction
	
	function automatic void transform();   
	
	    int id = 0;
	    int id_old = 0;
	
	    for(int round = 0; round<NUMBER_OF_ROUNDS; round++) begin
	   
	        tmp_state = state;
	   
	        for(int i=0; i < STATE_LENGTH; i++) begin
	            id_old = id; 
	            id += (id < 365 ? 364 : -365);
	            state[i] = TRUTH_TABLE[ tmp_state[id_old] + tmp_state[id] * 3 + 4 ];
                //$display("%0d -> %0d %0d", i, id_old, id);
	        end
            //$stop;
	     
	    end
	
	endfunction
	
endclass

`endif // CURL_SV

