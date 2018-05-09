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

`ifndef AVALON_M_DRV
`define AVALON_M_DRV

class Avalon_m_busTrans extends uvm_sequence_item;

	`uvm_object_utils(Avalon_m_busTrans)
	
	enum {WRITE_READ, IDLE, WAIT}       TrType;
	bit32                               address;
	bit8_128                            dataBlock;
	bit128                              byteenable;
	bit1024                             dataWord;
	bit                                 chipselect;
	bit                                 read;
	bit                                 write;
	bit  [10:0]                         burstcount;
	bit                                 beginbursttransfer;
	int                                 idleCycles;
	
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
	
endclass : Avalon_m_busTrans

typedef class 		 Avalon_m_busTrans;
typedef mailbox #(Avalon_m_busTrans) TransMBox;

class avalon_m_driver extends uvm_driver #(avalon_m_packet);

	`uvm_component_utils(avalon_m_driver)
	
	virtual interface avalon_m_if	avln_m_vif;
	
	int     maxBurstLenWrData;
	int     burstCntWrData;
	int     maxBurst;
	int     minBurst;
	int     maxWait;
	int     minWait;
	
	int 	rdDataBuffSize;
	
	int 	blockSize;
	
	TransMBox trWrDataBox, trRdDataBox, trRdDataL0Box;
	semaphore wrDataSem;
	
	avalon_m_packet		avln_m_pkt;
	
	int waitReqTimeOut, validTimeOut;
	
	local Avalon_m_busTrans trWrData, trWrDataEnv;
	
	function new (string name, uvm_component parent = null);
		super.new(name, parent);
		this.maxBurstLenWrData 	= 0;
		this.burstCntWrData		= 0;
		this.maxBurst			= 0;
		this.minBurst			= 0;
		this.maxWait			= 0;
		this.minWait 			= 0;
		this.rdDataBuffSize		= 0;
		this.trWrDataBox		= new();
		this.trRdDataBox		= new();
		this.wrDataSem			= new();
		this.trRdDataL0Box		= new();
	endfunction
	
	extern virtual function	void		build_phase (uvm_phase phase);
	extern virtual task			  		run_phase   (uvm_phase phase);
	extern virtual local task 			run_loop();
	extern virtual local task 			read_data_loop();
	extern virtual local task 			singleTrans();
	extern virtual protected task 		startBFM();
	extern virtual protected task 		writeData 	(avalon_m_packet avln_m_pkt);
	extern virtual protected task 		readData	(avalon_m_packet avln_m_pkt);
	extern virtual protected task 		waitCommand_mDone();
	extern virtual protected task 		send_to_dut (avalon_m_packet avln_m_pkt);
	
endclass : avalon_m_driver

function void avalon_m_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
		if (!uvm_config_db#(virtual interface avalon_m_if)::get(this, "", "avln_m_vif", avln_m_vif))
			`uvm_fatal(get_type_name(), "Mising virtual I/F for Avalon Master.");
endfunction : build_phase

task avalon_m_driver::run_phase(uvm_phase phase);
	startBFM();
	forever begin
		@(posedge avln_m_vif.clk iff !avln_m_vif.arst);
		seq_item_port.get_next_item(avln_m_pkt);
		send_to_dut(avln_m_pkt);
		seq_item_port.item_done();
	end
endtask : run_phase

task avalon_m_driver::send_to_dut(avalon_m_packet avln_m_pkt);
	if (avln_m_pkt.Init_m == avalon_m_packet::INITIALIZATION) begin
		this.maxBurstLenWrData	= avln_m_pkt.maxBurstLenWrData;
		this.burstCntWrData		= avln_m_pkt.burstCntWrData;
		this.maxBurst			= avln_m_pkt.maxBurst;
		this.minBurst			= avln_m_pkt.minBurst;
		this.maxWait			= avln_m_pkt.maxWait;
		this.minWait			= avln_m_pkt.minWait;
		this.blockSize			= avln_m_pkt.blockSize;
		this.waitReqTimeOut		= avln_m_pkt.waitReqTimeOut;
		this.validTimeOut		= avln_m_pkt.validTimeOut;
	end
	
	if (avln_m_pkt.Command_m == avalon_m_packet::WRITE_DATA) 
		writeData(avln_m_pkt);
	else if (avln_m_pkt.Command_m == avalon_m_packet::READ_DATA)
		readData(avln_m_pkt);
	
	if (avln_m_pkt.Wait_command_done == avalon_m_packet::WAIT)
		waitCommand_mDone();
endtask : send_to_dut

task avalon_m_driver::startBFM();
	fork
		this.run_loop();
		this.read_data_loop();
	join_none
endtask : startBFM

task avalon_m_driver::run_loop();
	
	this.avln_m_vif.cb.address             <= 'd0;
    this.avln_m_vif.cb.writedata           <= 'd0;
    this.avln_m_vif.cb.byteenable          <= 'd0;
    this.avln_m_vif.cb.chipselect          <= 1'b0;
    this.avln_m_vif.cb.write               <= 1'b0;
    this.avln_m_vif.cb.read                <= 1'b0;
    this.avln_m_vif.cb.burstcount          <= 'd0;
    this.avln_m_vif.cb.beginbursttransfer  <= 1'b0;
	
	forever begin
		this.trWrDataBox.get(this.trWrData);
		if(this.trWrData.TrType == Avalon_m_busTrans::IDLE) 
			repeat (this.trWrData.idleCycles) @this.avln_m_vif.cb;
		else if (this.trWrData.TrType == Avalon_m_busTrans::WAIT) 
			this.wrDataSem.put(1);
		else 
			this.singleTrans();
    end
	
endtask : run_loop

task avalon_m_driver::singleTrans();
		
	this.avln_m_vif.clockAlign();
	
	this.avln_m_vif.cb.address             <= this.trWrData.address;
    this.avln_m_vif.cb.writedata           <= this.trWrData.dataWord;
    this.avln_m_vif.cb.byteenable          <= this.trWrData.byteenable;
    this.avln_m_vif.cb.chipselect          <= 1'b1;
    this.avln_m_vif.cb.write               <= this.trWrData.write;
    this.avln_m_vif.cb.read                <= this.trWrData.read;
    this.avln_m_vif.cb.burstcount          <= this.trWrData.burstcount;
    this.avln_m_vif.cb.beginbursttransfer  <= this.trWrData.beginbursttransfer;
	@this.avln_m_vif.cb;
    this.avln_m_vif.cb.beginbursttransfer  <= 1'b0;
	
	fork: w_wait_poll
      while(this.avln_m_vif.cb.waitrequest !== 1'b0) @this.avln_m_vif.cb;
      begin
        repeat(this.waitReqTimeOut) @this.avln_m_vif.cb;
        `uvm_error(get_type_name(), {"Wait Request TimeOut Detected."});
      end
    join_any
	
	disable w_wait_poll;
	this.avln_m_vif.cb.chipselect          <= 1'b0;
    this.avln_m_vif.cb.write               <= 1'b0;
    this.avln_m_vif.cb.read                <= 1'b0;
    if(this.trWrData.read == 1'b1) 
      this.trRdDataL0Box.put(this.trWrData);
    	
	if(this.maxBurstLenWrData != 0)
      this.burstCntWrData++;
    	
	if(this.burstCntWrData == this.maxBurstLenWrData) begin
		if(this.maxBurstLenWrData != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.avln_m_vif.cb;
		this.burstCntWrData = 0;
		this.maxBurstLenWrData = $urandom_range(this.maxBurst, this.minBurst);
    end
	
endtask : singleTrans

task avalon_m_driver::read_data_loop();
	
	Avalon_m_busTrans	tr;
	
	int counter;
	forever begin
		this.trRdDataL0Box.get(tr);
		counter = 0;
		while ((this.avln_m_vif.cb.readdatavalid !== 1'b1) && (counter != this.validTimeOut)) begin
			@this.avln_m_vif.cb;
			counter++;
		end
		if (this.avln_m_vif.cb.readdatavalid !== 1'b1) 
			 `uvm_error(get_type_name(), {"Wait Request TimeOut Detected."});
		tr.dataWord = this.avln_m_vif.cb.readdata;
		this.trRdDataBox.put(tr);
		@this.avln_m_vif.cb;
	end
	
endtask : read_data_loop

task avalon_m_driver::writeData(avalon_m_packet avln_m_pkt);

	bit [127:0] byteenable;
    int inBuffSize;
    int inBuffPtr;
	bit32 addrHold;
    int addrAlign;
    int startBurst;
	addrHold = avln_m_pkt.addr;
	addrAlign = 0;
	inBuffSize = avln_m_pkt.inBuff.size();
	startBurst = avln_m_pkt.burstEn;
	// Avalon address always will be aligned. Missaligned data will be controled
    // via "byteenable" bus.
	while((addrHold%this.blockSize) != 0) begin
		addrHold--;
		addrAlign++;
    end
    inBuffPtr = 0;
	while(inBuffSize != 0) begin
      // Put data information
		trWrDataEnv = new("trWrDataEnv");
		byteenable = 'd0;
		for(int j = 0; j < this.blockSize; j++) begin
			this.trWrDataEnv.dataBlock[j] = 8'd0;
		end
		for(int j = 0; j < this.blockSize; j++) begin
			if(inBuffSize == 0) break;
			if(addrAlign == 0) begin
				this.trWrDataEnv.dataBlock[j] = avln_m_pkt.inBuff[inBuffPtr];
				inBuffSize--;
				inBuffPtr++;
				byteenable[j] = 1'b1;
			end else 
				addrAlign--;
		end
		this.trWrDataEnv.dataWord            = this.trWrDataEnv.unpack2pack(this.trWrDataEnv.dataBlock);
		this.trWrDataEnv.byteenable          = byteenable;
		this.trWrDataEnv.burstcount          = 11'd0;
		if((avln_m_pkt.burstEn == 1) && (startBurst == 0)) 
			this.trWrDataEnv.address         = $random;
		else begin
        // 1st burst transfer
			this.trWrDataEnv.address         = addrHold;
			if(avln_m_pkt.burstEn == 1) begin
				this.trWrDataEnv.burstcount  = avln_m_pkt.inBuff.size()/this.blockSize;
				if((avln_m_pkt.inBuff.size()%this.blockSize) != 0) 
					this.trWrDataEnv.burstcount  = this.trWrDataEnv.burstcount + 11'd1;
			end
		end
		this.trWrDataEnv.write               = 1'b1;
		this.trWrDataEnv.read                = 1'b0;
		this.trWrDataEnv.TrType              = Avalon_m_busTrans::WRITE_READ;
		this.trWrDataEnv.beginbursttransfer  = startBurst[0];
		this.trWrDataBox.put(this.trWrDataEnv);
		this.trWrDataEnv = null;
		addrHold+=this.blockSize;
		startBurst = 0;
    end
	
endtask : writeData

task avalon_m_driver::readData(avalon_m_packet avln_m_pkt);
	
	bit [127:0] byteenable;
    int inBuffSize;
    bit32 addrHold;
    int addrAlign;
    int startBurst;
    this.rdDataBuffSize += avln_m_pkt.byteLen;
    startBurst = avln_m_pkt.burstEn;
    addrHold = avln_m_pkt.addr;
    addrAlign = 0;
    inBuffSize = avln_m_pkt.byteLen;
	
	while ((addrHold % this.blockSize) != 0) begin
		addrHold--;
		addrAlign++;
	end
	while (inBuffSize != 0) begin
		trWrDataEnv = new("trWrDataEnv");
		byteenable = 'd0;
		for (int j = 0; j < blockSize; j++) begin
			if (inBuffSize == 0) break;
			if (addrAlign == 0) begin
				inBuffSize--;
				byteenable [j] = 1'b1;
			end else 
				addrAlign--;	
		end
		this.trWrDataEnv.byteenable	= byteenable;
		this.trWrDataEnv.burstcount	= 11'd0;
		if ((avln_m_pkt.burstEn == 1) && (startBurst == 0))
			this.trWrDataEnv.address	= $random;
		else begin
			this.trWrDataEnv.address	= addrHold;
			if (avln_m_pkt.burstEn == 1) begin
				this.trWrDataEnv.burstcount		= avln_m_pkt.byteLen / this.blockSize;
				if ((avln_m_pkt.byteLen % this.blockSize) != 0) 
					this.trWrDataEnv.burstcount = this.trWrDataEnv.burstcount + 11'd1;
			end
		end
		this.trWrDataEnv.write				= 1'b0;
		this.trWrDataEnv.read				= 1'b1;
		this.trWrDataEnv.TrType				= Avalon_m_busTrans::WRITE_READ;
		this.trWrDataBox.put(this.trWrDataEnv);
		this.trWrDataEnv = null;
		addrHold += this.blockSize;
		startBurst = 0;
	end
	
endtask : readData

task avalon_m_driver::waitCommand_mDone();
	
	this.trWrDataEnv		= Avalon_m_busTrans::type_id::create("trWrDataEnv");
	this.trWrDataEnv.TrType	= Avalon_m_busTrans::WAIT;
	this.trWrDataBox.put(this.trWrDataEnv);
	this.trWrDataEnv	= null;
	this.wrDataSem.get(1);
	
endtask : waitCommand_mDone

`endif








































