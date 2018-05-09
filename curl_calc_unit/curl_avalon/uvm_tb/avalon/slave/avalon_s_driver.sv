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

`ifndef AVALON_S_DRV
`define AVALON_S_DRV

class avalon_s_busTrans extends uvm_sequence_item;
	
	`uvm_object_utils(avalon_s_busTrans)
	
	bit32                            address;
	bit8_128                         dataBlock;
	bit128                           byteenable;
	bit1024                          dataWord;
	bit                              read;
	bit                              write;
	bit  [10:0]                      burstcount;
	bit                              beginbursttransfer;
	
	function new(string name = "");
		super.new(name);
	endfunction 
	
	
	function bit1024 unpack2pack(bit8_128 dataBlock);
		for (int i = 0; i < 128; i++)
			unpack2pack[8 * i +: 8] = dataBlock [i];
	endfunction : unpack2pack

	function bit8_128 pack2unpack(bit1024 dataBlock);
		for (int i = 0; i < 128; i++)
			pack2unpack [i] = dataBlock [8 * i +: 8];
	endfunction : pack2unpack
	
endclass : avalon_s_busTrans

typedef class 		 avalon_s_busTrans;
typedef mailbox	#(avalon_s_busTrans) TransMBox;

class avalon_s_driver extends uvm_driver #(avalon_s_packet);

	`uvm_component_utils(avalon_s_driver)
	
	virtual interface avalon_s_if	avln_s_vif;
	
	int minWaitReqDelay;
	int maxWaitReqDelay;
	int minValidDelay;
	int maxValidDelay;
	int waitReqDelay;
	int validDelay;
	int blockSize;
	
	TransMBox	trWrDataBox, trRdDataBox;	
	
	bit8 intMemArray [bit32];
	
	avalon_s_packet avln_s_pkt;
	
	function new (string name, uvm_component parent = null);
		super.new(name, parent);
		this.minWaitReqDelay   	= 0;
		this.maxWaitReqDelay   	= 0;
		this.minValidDelay     	= 0;
		this.maxValidDelay     	= 0;
		this.waitReqDelay      	= 0;
		this.validDelay        	= 0;
		this.trWrDataBox		= new();
		this.trRdDataBox		= new();
	endfunction 
	
	extern virtual function void  		build_phase (uvm_phase phase);
	extern virtual task			  		run_phase   (uvm_phase phase);
	extern virtual local task 			write_loop();
	extern virtual local task 			write_data_loop();
	extern virtual local task 			read_data_loop();
	extern virtual protected task 		startBFM();
	extern virtual protected task 		putData (avalon_s_packet avln_s_pkt);
	extern virtual protected task  		send_to_dut (avalon_s_packet avln_s_pkt);
	
endclass : avalon_s_driver

function void avalon_s_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
		if (!uvm_config_db#(virtual interface avalon_s_if)::get(this, "", "avln_s_vif", avln_s_vif))
			`uvm_fatal(get_type_name(), "Mising virtual I/F for Avalon Slave.");
endfunction : build_phase

task avalon_s_driver::run_phase(uvm_phase phase);
	startBFM();
	forever begin
		@(posedge avln_s_vif.clk iff !avln_s_vif.arst);
		seq_item_port.get_next_item(avln_s_pkt);
		send_to_dut(avln_s_pkt);
		seq_item_port.item_done();
	end
endtask : run_phase

task avalon_s_driver::send_to_dut(avalon_s_packet avln_s_pkt);
	if (avln_s_pkt.Command_s == avalon_s_packet::PUT_DATA)
		putData(avln_s_pkt);

	if (avln_s_pkt.Init_s == avalon_s_packet::INITIALIZATION) begin
		this.waitReqDelay	 = avln_s_pkt.maxWaitReqDelay;
		this.minWaitReqDelay = avln_s_pkt.minWaitReqDelay;
		this.maxWaitReqDelay = avln_s_pkt.maxWaitReqDelay;
		this.minValidDelay	 = avln_s_pkt.minValidDelay;
		this.maxValidDelay	 = avln_s_pkt.maxValidDelay;
		this.blockSize		 = avln_s_pkt.blockSize;
	end
endtask : send_to_dut

task avalon_s_driver::startBFM();
	this.trWrDataBox	= new();
	this.trRdDataBox	= new();
	fork
		this.write_data_loop();
		this.read_data_loop();
		this.write_loop();
	join_none
endtask : startBFM


task avalon_s_driver::write_loop();
	
	avalon_s_busTrans	tr_wd;
	
	bit32 		addr, burstAddr;
	bit [10:0]	burstCount;
	burstCount	= 11'd0;

	forever begin
		
		this.trWrDataBox.get(tr_wd);
		
		addr = tr_wd.address;
		
		if (tr_wd.beginbursttransfer == 1'b1) begin
			burstAddr  = tr_wd.address;
			burstCount = tr_wd.burstcount;
		end else if (burstCount != 0) begin
			burstAddr += this.blockSize;
			addr = burstAddr;
			burstCount--;
		end
		
		while ((addr % this.blockSize) != 0) begin
			addr--;
			burstAddr--;
		end
		
		if (tr_wd.write == 1'b1) begin
			for (int i = 0; i < this.blockSize; i++) 
				if(tr_wd.byteenable[i] == 1'b1)
					this.intMemArray [addr + i] = tr_wd.dataBlock[i];
		end else if (tr_wd.read == 1'b1) begin
			for (int i = 0; i < this.blockSize; i++) 
				if (this.intMemArray.exists(addr + i)) begin
					tr_wd.dataBlock[i] = this.intMemArray[addr + i];
					//`uvm_info(get_type_name(), $sformatf("ADDR = %d", addr + i), UVM_HIGH)	
				end else
					tr_wd.dataBlock[i] = $random;
			tr_wd.dataWord = tr_wd.unpack2pack(tr_wd.dataBlock);
			this.trRdDataBox.put(tr_wd);
		end
		
	end

endtask : write_loop

task avalon_s_driver::write_data_loop();
	
	avalon_s_busTrans 	tr;
	
	forever begin
		
		tr = new("tr");
		
		do begin
			if (this.waitReqDelay == 0)
				avln_s_vif.waitrequest <= 1'b0;
			else
				avln_s_vif.waitrequest <= 1'b1;
			@avln_s_vif.cb;
		end while (avln_s_vif.chipselect !== 1'b1);
		
		tr.burstcount			= avln_s_vif.burstcount;
		tr.beginbursttransfer	= avln_s_vif.beginbursttransfer;
		
		repeat (this.waitReqDelay) @avln_s_vif.cb;
		
		while (avln_s_vif.chipselect !== 1'b1) @avln_s_vif.cb;
		
		avln_s_vif.waitrequest <= 1'b0;
		tr.dataBlock		= tr.pack2unpack(avln_s_vif.writedata);
		tr.address			= avln_s_vif.address;
		tr.byteenable		= avln_s_vif.byteenable;
		tr.read				= avln_s_vif.read;
		tr.write			= avln_s_vif.write;
		this.trWrDataBox.put(tr);
		tr = null;
		
		if (this.waitReqDelay != 0)
			@avln_s_vif.cb;
			
		this.waitReqDelay = $urandom_range(this.maxWaitReqDelay, this.minWaitReqDelay);
		
	end
	
endtask : write_data_loop

task avalon_s_driver::read_data_loop();
	
	avalon_s_busTrans	tr_rd;
	
	avln_s_vif.readdatavalid	<= 1'b0;
	
	forever begin
		
		this.trRdDataBox.get(tr_rd);
		
		repeat (this.validDelay) @avln_s_vif.cb;
		
		this.validDelay = $urandom_range(this.maxValidDelay, this.minValidDelay);
		avln_s_vif.readdatavalid <= 1'b1;
		avln_s_vif.readdata 	 <= tr_rd.dataWord;
		@(avln_s_vif.cb);
		avln_s_vif.readdatavalid	<= 1'b0;
		
	end
	
endtask : read_data_loop

task avalon_s_driver::putData(avalon_s_packet avln_s_pkt);
	for (int i = 0; i < avln_s_pkt.dataInBuff.size(); i++)
		this.intMemArray [avln_s_pkt.startAddr+i] = avln_s_pkt.dataInBuff [i];
endtask : putData

`endif