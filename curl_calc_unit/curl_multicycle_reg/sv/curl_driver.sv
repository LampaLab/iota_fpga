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

`ifndef CURL_DRIVER
`define CURL_DRIVER

`include "curl_params.sv"

class curl_driver extends uvm_driver #(curl_packet);
	
	`uvm_component_utils(curl_driver)
	
	virtual interface curl_if vif;
	
    curl_packet	pkt;
	curl_packet	drv_pkt;
      
	function new (string name, uvm_component parent = null);
		super.new(name, parent);
	endfunction: new
	
	extern virtual function void build_phase	(uvm_phase phase);
	extern virtual task			 run_phase		(uvm_phase phase);
	extern virtual protected task reset();
	extern virtual protected task trytes_to_trits_conv(curl_packet pkt);
	extern virtual protected task send_to_dut(curl_packet pkt);
		
endclass : curl_driver

//	UVM Build Phase
function void curl_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
		if (!uvm_config_db#(virtual interface curl_if)::get(this, "", "vif", vif))
		`uvm_fatal(get_type_name(), "Missing virtual I/F");
endfunction : build_phase

//	UVM Run Phase	
task curl_driver::run_phase(uvm_phase phase);
	reset();
	forever begin
		@(posedge vif.clk iff vif.arst_n)
		seq_item_port.get_next_item(pkt);
		send_to_dut(pkt);
		seq_item_port.item_done();
	end
endtask : run_phase

//	Reset task
task curl_driver::reset();
	wait (!vif.arst_n);
	`uvm_info(get_type_name(), {"Reset starts..."}, UVM_LOW)
	vif.curl_first_part_hash 	<= 'h0;
	vif.curl_second_part_hash	<= 'h0;
	vif.curl_in_hash			<= 'h0;
	`uvm_info(get_type_name(), {"Reset completed."}, UVM_LOW)
endtask : reset

//	Trytes to trits converter
task curl_driver::trytes_to_trits_conv(curl_packet pkt);
	int offset;
	offset = 0;
 	drv_pkt = curl_packet::type_id::create("drv_pkt");
	`uvm_info(get_type_name(), {"Trytes to trits converting starts..."}, UVM_LOW)
	`uvm_info(get_type_name(), $sformatf("Trytes hash object: %s", pkt.trytes_hash_object), UVM_LOW)
	for (int i = 0; i < pkt.trytes_hash_object.len(); i++) begin
		case (pkt.trytes_hash_object[i])
			"9" :	drv_pkt.one_trit = {2'h0 , 2'h0	, 2'h0};
			"A" :	drv_pkt.one_trit = {2'h0 , 2'h0	, 2'h1};
			"B"	:	drv_pkt.one_trit = {2'h0 , 2'h1	, 2'h3};
			"C" :	drv_pkt.one_trit = {2'h0 , 2'h1	, 2'h0};
			"D" :	drv_pkt.one_trit = {2'h0 , 2'h1	, 2'h1};
			"E" :	drv_pkt.one_trit = {2'h1 , 2'h3	, 2'h3};
			"F" :	drv_pkt.one_trit = {2'h1 , 2'h3	, 2'h0};
			"G" :	drv_pkt.one_trit = {2'h1 , 2'h3	, 2'h1};
			"H" :	drv_pkt.one_trit = {2'h1 , 2'h0	, 2'h3};
			"I" :	drv_pkt.one_trit = {2'h1 , 2'h0	, 2'h0};
			"J" :	drv_pkt.one_trit = {2'h1 , 2'h0	, 2'h1};
			"K" :	drv_pkt.one_trit = {2'h1 , 2'h1	, 2'h3};
			"L" :	drv_pkt.one_trit = {2'h1 , 2'h1	, 2'h0};
			"M" :	drv_pkt.one_trit = {2'h1 , 2'h1	, 2'h1};
			"N" :	drv_pkt.one_trit = {2'h3 , 2'h3	, 2'h3};
			"O" :	drv_pkt.one_trit = {2'h3 , 2'h3	, 2'h0};
			"P" :	drv_pkt.one_trit = {2'h3 , 2'h3	, 2'h1};
			"Q"	:	drv_pkt.one_trit = {2'h3 , 2'h0	, 2'h3};
			"R"	:	drv_pkt.one_trit = {2'h3 , 2'h0	, 2'h0};
			"S"	:	drv_pkt.one_trit = {2'h3 , 2'h0	, 2'h1};
			"T"	:	drv_pkt.one_trit = {2'h3 , 2'h1	, 2'h3};
			"U"	:	drv_pkt.one_trit = {2'h3 , 2'h1	, 2'h0};
			"V"	:	drv_pkt.one_trit = {2'h3 , 2'h1	, 2'h1};
			"W"	:	drv_pkt.one_trit = {2'h0 , 2'h3	, 2'h3};
			"X"	:	drv_pkt.one_trit = {2'h0 , 2'h3	, 2'h0};
			"Y"	:	drv_pkt.one_trit = {2'h0 , 2'h3	, 2'h1};
			"Z"	:	drv_pkt.one_trit = {2'h0 , 2'h0	, 2'h3};
		endcase
		
      drv_pkt.trits_object[offset +: 6] = drv_pkt.one_trit;
		offset = offset + 6;
	end
	
	`uvm_info(get_type_name(), {"Trytes to trits converting complete."}, UVM_LOW)
	
endtask : trytes_to_trits_conv

//	Drive the hash to interface
task curl_driver::send_to_dut(curl_packet pkt);
	trytes_to_trits_conv(pkt);
	@(negedge vif.clk);
		`uvm_info(get_type_name(), {"Curl driver starts transfer data to DUT..."}, UVM_LOW)
		vif.curl_in_hash = drv_pkt.trits_object [`HASH_LENGTH - 1 : 0];
		vif.curl_first_part_hash = 'h1;
	@(negedge vif.clk);
		vif.curl_in_hash = drv_pkt.trits_object [2 * `HASH_LENGTH - 1 : `HASH_LENGTH];
		vif.curl_second_part_hash = 'h1;
		vif.curl_first_part_hash  = 'h0;
	@(negedge vif.clk);
		vif.curl_second_part_hash = 'h0;
		`uvm_info(get_type_name(), {"Curl driver finished driving transfer."}, UVM_LOW)
	wait (vif.curl_transform_finish);	
endtask : send_to_dut

`endif