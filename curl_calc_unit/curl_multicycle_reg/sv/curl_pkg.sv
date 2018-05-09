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

`ifndef CURL_PKG
`define CURL_PKG

`include "uvm_macros.svh"
import uvm_pkg::*;
	
package curl_pkg;
	
	`include "curl_if.sv"
	`include "curl_packet.sv"
	`include "curl_driver.sv"
	`include "curl_sequencer.sv"
	`include "curl_seq.sv"
	`include "curl_monitor.sv"	
	`include "curl_agent.sv"
	`include "curl_scoreboard.sv"
	`include "../ref_model/curl_reference_model.sv"
	`include "curl_env.sv"
	`include "curl_test.sv"

endpackage : curl_pkg

`endif