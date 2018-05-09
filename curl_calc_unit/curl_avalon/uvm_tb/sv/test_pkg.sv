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

`ifndef TESTBENCH_PKG
`define TESTBENCH_PKG

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "../avalon/slave/avalon_s_pkg.sv"
`include "../avalon/master/avalon_m_pkg.sv"

`include "trinary_pkg.sv"
`include "../ref_model/curl_const_pkg.sv"
`include "pack_unpack.sv"

package test_pkg;

	import avalon_s_pkg::*;
	
	import avalon_m_pkg::*;
	
	import trinary_pkg::*; 
	
	import curl_const_pkg::*;
	
	import pack_unpack::*;
	
	`include "../ref_model/curl_ref_model_wrapper.sv" 
	
	`include "curl_collect_data.sv"
	
	`include "curl_scoreboard.sv"

	`include "synch_data_pkt.sv"
	`include "synch_monitor.sv"
	
	`include "curl_env.sv"
	
    `include "converter.sv"
	
	`include "avalon_s_curl_sequences.sv"
	`include "avalon_m_curl_sequences.sv"
	`include "avalon_top_sequences.sv"
	
	`include "curl_test.sv"

endpackage : test_pkg

`endif