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
              int NUMBER_OF_ROUNDS = curl_const_pkg::NUMBER_OF_ROUNDS,
              int STEPS = STATE_LENGTH/54 + 1                          // we generate 54 trits on each step
              );
  
    signed_byte_t [0:8] TRUTH_TABLE = '{1, 0, -1, 1, -1, 0, -1, 1, 0};

    signed_byte_t [0:STATE_LENGTH-1] state;
    signed_byte_t [0:STATE_LENGTH-1] tmp_state;

    signed_byte_t [0:STATE_LENGTH-1] state_new[2];

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

    function automatic void absorb_new(const ref s_byte_darr_t trits);
 
        int len = trits.size();
        int offset = 0;
        int num = 0;
    
        state_new[0] = '0;
        state_new[1] = '0;
    
        if (len > 0)
        do begin 
            num = (len < HASH_LENGTH) ? len : HASH_LENGTH;
            for(int i=0; i < num; i++)
                state_new[0][i] = trits[offset + i];
            this.transform_new();
            state_new[0] = state_new[1];
            //$display("%p", state);
	        offset += HASH_LENGTH;
        end while( (len -= HASH_LENGTH) > 0 );
 
    endfunction

    function automatic void reset();
        state = '0;
	endfunction  
    
    function automatic void squeeze_new(ref s_byte_darr_t trits, input int len);
	 
        int offset = 0;
        int num = 0;
        trits = new[len];

        if (len > 0) 
        do begin
            num = (len < HASH_LENGTH) ? len : HASH_LENGTH;
            for(int i=0; i < num; i++)
                trits[offset + i] = state_new[0][i];
	        this.transform_new(); 
            state_new[0] = state_new[1];
	        offset += HASH_LENGTH;
	    end while( (len -= HASH_LENGTH) > 0 );  
	  	
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
	
    function automatic void transform_new();

    bit sel_state = 0;
    bit sel_trit = 0;

    int i, j, k, s, round; 

    int baseA, baseB;

    signed_byte_t trit1, trit2;

    state_new[1] = '0;

    for(round = 0; round < NUMBER_OF_ROUNDS; round++) begin

        baseA = 364;
        baseB = 728;
        sel_trit = 0;
        /*$display("Transform New. Round %0d start", round);
        $display("state_new[0]: %p", state_new[0]);
        $display("state_new[1]: %p", state_new[1]);*/

        for(s = 0; s < STEPS; s++) begin

            for(i = 0; i < 54; i++) begin
    
                j = i/2;
                k = (i % 2) ? j : j - 1;

                if (0 == sel_state) begin
                    
                    trit1 = sel_trit ? state_new[0][baseA - j] : (0 == i && 0 == s) ? state_new[0][0] : state_new[0][baseB - k];
                    trit2 = sel_trit ? state_new[0][baseB - k] : state_new[0][baseA - j];
                    state_new[1][s*54 + i] = TRUTH_TABLE[trit1 + trit2 * 3 + 4];                    
                    
                end else begin

                    trit1 = sel_trit ? state_new[1][baseA - j] : (0 == i && 0 == s) ? state_new[1][0] : state_new[1][baseB - k];
                    trit2 = sel_trit ? state_new[1][baseB - k] : state_new[1][baseA - j];
                    state_new[0][s*54 + i] = TRUTH_TABLE[trit1 + trit2 * 3 + 4];
 
                end
                
                sel_trit = ~sel_trit;

                if ( (STEPS - 1) == s && 26 == i )
                    break;

            end

            baseA -= 27;
            baseB -= 27;

        end

        sel_state = ~sel_state;
        /*$display("Transform New. Round %0d end", round);
        $display("state_new[0]: %p", state_new[0]);
        $display("state_new[1]: %p", state_new[1]);*/

    end

    endfunction  

	function automatic void transform();   
	
	    int id = 0;
	    int id_old = 0;
	
	    for(int round = 0; round<NUMBER_OF_ROUNDS; round++) begin
	   
	        tmp_state = state;
            /*$display("Transform. Round %0d start", round);
            $display("state: %p", state);
            $display("tmp_state: %p", tmp_state);*/
	   
	        for(int i = 0; i < STATE_LENGTH; i++) begin
	            id_old = id; 
	            id += (id < 365 ? 364 : -365);
	            state[i] = TRUTH_TABLE[ tmp_state[id_old] + tmp_state[id] * 3 + 4 ];
                //$display("%0d -> %0d %0d", i, id_old, id);
	        end
            //$stop;
            /*$display("Transform. Round %0d end", round);
            $display("state: %p", state);
            $display("tmp_state: %p", tmp_state);*/
	     
	    end
	
	endfunction
	
endclass

`endif // CURL_SV

