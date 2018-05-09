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

`include "../sv/curl_if.sv"
`include "../rtl/curl.sv"

`include "../sv/curl_params.sv"

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "../sv/curl_pkg.sv"
import curl_pkg::*; 

module curl_tb_top;
			
	logic clk;
	logic arst_n;
	
	
	curl_if vif	(clk, arst_n);
	curl	#(.HASH_LENGTH  (`HASH_LENGTH ),	
			  .STATE_LENGTH (`STATE_LENGTH))	dut		(	.i_clk				(clk						),
															.i_rst_n			(arst_n						),
															.i_first_part		(vif.curl_first_part_hash	),
															.i_new_hash			(vif.curl_second_part_hash	),
															.i_hash				(vif.curl_in_hash			),
															.o_hash				(vif.curl_out_hash			),
															.o_transform_finish	(vif.curl_transform_finish	));
															
	initial begin
		uvm_config_db#(virtual curl_if)::set(null, "*", "vif", vif);
		run_test("curl_test");
	end
	
	initial begin
		arst_n = 1'b0;
		#4 arst_n = 1'b1;
	end
	
	initial 
		fork	
			begin
				clk = 1'b0;
				forever #(`PERIOD / 2) clk = ~clk;
			end
		join_none
	
endmodule : curl_tb_top