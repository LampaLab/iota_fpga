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

`include "../avalon/master/avalon_m_if.sv"
`include "../avalon/slave/avalon_s_if.sv"

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "../sv/test_pkg.sv"
import test_pkg::*; 

`define PERIOD 10

module tb_top;

	logic clk;
	logic arst;
	
	avalon_m_if		avln_m_vif(clk, arst);
	avalon_s_if		avln_s_vif(clk, arst);
	
	assign avln_s_vif.address[3:0] = '0;
	assign avln_s_vif.chipselect = avln_s_vif.write | avln_s_vif.read;
	
	curl_avalon 	dut( 	.i_clk (clk),
							.i_arst (arst),
							// slave IF
							.i_slave_writedata ( avln_m_vif.writedata ),
							.i_slave_byteenable ( avln_m_vif.byteenable ),
							.i_slave_write ( avln_m_vif.write ),
							.i_slave_read ( avln_m_vif.read ),
							.i_slave_address ( avln_m_vif.address[31:2] ),
							.o_slave_readdata ( avln_m_vif.readdata ),
							.o_slave_waitrequest ( avln_m_vif.waitrequest ),
							.o_slave_readdatavalid ( avln_m_vif.readdatavalid ),
							// master IF
							.o_master_address ( avln_s_vif.address[31:4] ),
							.o_master_write ( avln_s_vif.write ),
							.o_master_read ( avln_s_vif.read ),
							.o_master_byteenable ( avln_s_vif.byteenable ),
							.o_master_writedata ( avln_s_vif.writedata ),
							.i_master_waitrequest ( avln_s_vif.waitrequest ),
							.i_master_readdatavalid ( avln_s_vif.readdatavalid ),
							.i_master_readdata ( avln_s_vif.readdata )
							);
	
	initial begin
		uvm_config_db#(virtual avalon_m_if)::set(null, "*", "avln_m_vif", avln_m_vif);
		uvm_config_db#(virtual avalon_s_if)::set(null, "*", "avln_s_vif", avln_s_vif);
		run_test("curl_test");
	end
	
	initial begin
		arst = 1'b1;
		repeat (2) @(negedge clk);
		arst = 1'b0;
	end
	
	initial 
		fork	
			begin
				clk = 1'b0;
				forever #(`PERIOD / 2) clk = ~clk;
			end
		join_none
	
endmodule : tb_top