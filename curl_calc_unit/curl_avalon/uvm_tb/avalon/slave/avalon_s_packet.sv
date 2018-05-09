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

`ifndef AVALON_S_PACKET
`define AVALON_S_PACKET

`include "uvm_macros.svh"
import uvm_pkg::*;

class avalon_s_packet extends uvm_sequence_item;
	
	`uvm_object_utils(avalon_s_packet)
	
	enum {PUT_DATA, NOP}			Command_s;
	enum {INITIALIZATION, STANDBY}	Init_s;
	enum {READ_DATA, WRITE_DATA}	Operation;
	int minWaitReqDelay;
	int maxWaitReqDelay;
	int minValidDelay;
	int maxValidDelay;
	int blockSize;
	bit8 dataInBuff [];
	bit8 dut_out [];
	bit8 dut_in [];
	bit8 ref_out [];
	bit32 startAddr;
	logic  [1023:0]	data_to_dut;
	logic  [1023:0] data_from_dut;
	logic  [1023:0] ref_data;
	logic  [31	:0] address;
	
	function new(string name = "avalon_s_packet");
		super.new(name);
	endfunction 
	
endclass : avalon_s_packet

`endif