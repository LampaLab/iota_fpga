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

`timescale 1 ns / 1 ps

/*
	Legend:
		i_name - means input signal of this scheme
		o_name - means output signal of this scheme
		name_n - means signal with active low level
		name_r - means register
*/

module curl #(
parameter HASH_LENGTH  = 243									,
parameter STATE_LENGTH = 3 * HASH_LENGTH						)(			
input 									  i_clk					,		//	Input clock signal
input 								  	  i_rst_n				,		//	Input asynchronous reset signal with active low level 
input 								 	  i_new_hash			,		//	Input strobe signal, means, that new hash comes
input									  i_first_part			, 		//	Input strobe signal, means, that first part of new hash comes
input   		[HASH_LENGTH - 1 : 0]	  i_hash				,		//	Input hash
output logic	[2 * HASH_LENGTH - 1 : 0] o_hash				,		//	Output hash, result of scheme
output logic						 	  o_transform_finish	);		//	Output signal, that signals about the end of the transform phase

parameter NUMBER_OF_ROUNDS = 81;

logic 					transform_start_r	;							//	Internal signal, that means stat of transform phase
logic 			[6 : 0]	rounds_cnt			;							//	Internal counter for transform phase of first  "for _ in range(NUMBER_OF_ROUNDS):"
																		//	cycle in transform phase in pycurl.py file																
logic 			[11: 0]	pos_cnt				;							//	Internal counter for transform phase of second "for pos in range(state_length):"
																		//	cycle in transform phase in pycurl.py file
logic 		   	[9 : 0] index_r				;							//	Signal for "index" variable of transform phase
logic 	 		[17: 0] TRUTH_TABLE			;							//	Register, that holds TRUTH_TABLE values from pycurl.py file for transform phase
logic signed	[1 : 0] prev_trit_r			;							//	Internal register, that will holds previous trit of transform phase for first 
																		//	"for _ in range(NUMBER_OF_ROUNDS):" cycle in pycurl.py file
logic signed	[1 : 0] new_trit_r			;							//	Internal register, that will holds new trit of transform phase for second 
																		//	"for pos in range(state_length):" cycle in pycurl.py file

logic [STATE_LENGTH * 2 - 1 : 0] state_r	;							//	Internal register, that will holds a new hash and, after all calculation, hold a result
logic [STATE_LENGTH * 2 - 1 : 0] new_state_r;							//	Internal register, that will be used in transform phase for calculation a new hash


//	Scheme for internal register, that holds "TRUTH_TABLE = [1, 0, -1, 1, -1, 0, -1, 1, 0]" values from pycurl.py file for transform phase
always @(negedge i_rst_n)
	if (!i_rst_n) begin
		TRUTH_TABLE [1 : 0] <=  1;
		TRUTH_TABLE [3 : 2] <=  0;
		TRUTH_TABLE [5 : 4] <=  3;
		TRUTH_TABLE [7 : 6] <=  1;
		TRUTH_TABLE [9 : 8] <=  3;
		TRUTH_TABLE [11:10] <=  0;
		TRUTH_TABLE [13:12] <=  3;
		TRUTH_TABLE [15:14] <=  1;
		TRUTH_TABLE [17:16] <=  0;
	end

		
//	Counter for transform phase of first "for _ in range(NUMBER_OF_ROUNDS):" cycle in pycurl.py file
always @(posedge i_clk or negedge i_rst_n) 
	if (!i_rst_n) 
		rounds_cnt 			<= 0;
	else if (i_new_hash)
		rounds_cnt		 	<= 0;
	else if ((rounds_cnt == NUMBER_OF_ROUNDS) && (pos_cnt == STATE_LENGTH)) begin
		rounds_cnt 			<= 0;
	end	else if ((pos_cnt == STATE_LENGTH - 1) && transform_start_r) 
		rounds_cnt <= rounds_cnt + 1;


//	Counter for transform phase of second "for pos in range(state_length):" cycle in pycurl.py file
always @(posedge i_clk or negedge i_rst_n) 
	if (!i_rst_n) 
		pos_cnt 		<= 0;
	else if (pos_cnt == STATE_LENGTH)
		pos_cnt		 	<= 0;
	else if (i_new_hash)
		pos_cnt 		<= 0;
	else if (transform_start_r) 
		pos_cnt <= pos_cnt + 1;	

		
//	Internal scheme for prev_trit_r register, that means: "prev_trit = prev_state[index]"
//	and "prev_trit = new_trit" from pycurl.py file
always @(posedge i_clk or negedge i_rst_n) 
	if (!i_rst_n) 
		prev_trit_r <= 0;
	else if (i_new_hash)
		prev_trit_r <= state_r [1:0];
	/*else if (pos_cnt == STATE_LENGTH || rounds_cnt == NUMBER_OF_ROUNDS)
		prev_trit_r <= prev_trit_r;*/
	else if ((pos_cnt == STATE_LENGTH) && transform_start_r) 
		prev_trit_r <= new_state_r [1:0];
	else if (transform_start_r)
		prev_trit_r <= new_trit_r;
		

//	Internal scheme for new_trit_r register, that means: "new_trit = prev_state[index]" from pycurl.py file
always @(posedge i_clk or negedge i_rst_n) 
	if (!i_rst_n)
		new_trit_r <= 0;
	else if (i_new_hash)
		new_trit_r <= state_r [364 * 2 + 1 : 364 * 2];
	else if (pos_cnt == STATE_LENGTH || rounds_cnt == NUMBER_OF_ROUNDS)
		new_trit_r <= new_trit_r;
	else if (pos_cnt == STATE_LENGTH - 1)
		new_trit_r <= new_state_r [index_r * 2 +: 2];	
	else if (transform_start_r)
		new_trit_r <= state_r [index_r * 2 +: 2];


//	Internal scheme for index_r, that means: "index += (364 if index < 365 else -365)" from pycurl.py file
always @(posedge i_clk or negedge i_rst_n) 
	if (!i_rst_n)
		index_r <= 364*2;
	else if (i_new_hash) 
		index_r <= 364*2;
	else if (pos_cnt == STATE_LENGTH || rounds_cnt == NUMBER_OF_ROUNDS)
		index_r <= index_r;
	else if (transform_start_r) 
		if (index_r < 365) 
			index_r <= index_r + 364;
		else
			index_r <= index_r - 365;	

			
//	Internal scheme for new_state_r register, that means:
//	"new_state[pos] = truth_table[prev_trit + (3 * new_trit) + 4]" from pycurl.py file
always @(posedge i_clk or negedge i_rst_n)
	if (!i_rst_n) 
		new_state_r <= 0;
	else if (pos_cnt == STATE_LENGTH || rounds_cnt == NUMBER_OF_ROUNDS)
		new_state_r <= new_state_r;
	else if (i_new_hash || transform_start_r)
		new_state_r [pos_cnt * 2 +: 2] <= TRUTH_TABLE [(prev_trit_r + (3 * new_trit_r) + 4) * 2 +: 2];
		

//	Internal scheme for state_r register, that means: "prev_state  = self._state[:]"
//	and "prev_state  = new_state" from pycurl.py file
always @(posedge i_clk or negedge i_rst_n) 
	if (!i_rst_n)
		state_r <= 0;
	else if (i_first_part)
		state_r [HASH_LENGTH - 1 : 0] <= i_hash;
	else if (i_new_hash)
		state_r [HASH_LENGTH * 2 - 1 : HASH_LENGTH] <= i_hash;
	else if  (pos_cnt == STATE_LENGTH)
		state_r <= new_state_r;		
			

//	Internal scheme for signaling about finish of transform phase
always @(posedge i_clk or negedge i_rst_n) 
	if (!i_rst_n) 
		o_transform_finish <= 0;
	else if (i_new_hash)
		o_transform_finish <= 0;
	else if ((rounds_cnt == NUMBER_OF_ROUNDS) && (pos_cnt == STATE_LENGTH))
		o_transform_finish <= 1;

//	Internal scheme for output hash
assign o_hash = state_r [2 * HASH_LENGTH - 1 : 0];

//	Internal scheme for transform_start_r internal register
always @(posedge i_clk or negedge i_rst_n) 
	if (!i_rst_n)
		transform_start_r <= 0;
	else if ((rounds_cnt == NUMBER_OF_ROUNDS) && (pos_cnt == STATE_LENGTH))
		transform_start_r <= 0;
	else if (i_new_hash)
		transform_start_r <= 1;

endmodule			