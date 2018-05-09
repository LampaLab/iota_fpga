/*
Copyright (C) 2012 SysWip

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
`timescale 1ns/10ps

package AVALON_S;
typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [127:0]  bit128;
typedef bit [1023:0] bit1024;
typedef bit8         bit8_128[128];
typedef class Avalon_s_busTrans;
typedef class Avalon_s_busBFM;
typedef class Avalon_s_env;
typedef mailbox #(Avalon_s_busTrans) TransMBox;
///////////////////////////////////////////////////////////////////////////////
// Class Avalon_s_busTrans:
///////////////////////////////////////////////////////////////////////////////
class Avalon_s_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  bit32                               address;
  bit8_128                            dataBlock;
  bit128                              byteenable;
  bit1024                             dataWord;
  bit                                 read;
  bit                                 write;
  bit  [10:0]                         burstcount;
  bit                                 beginbursttransfer;
  string                              failedTr;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- unpack2pack(): Convert unpack array to packed.*/
  /////////////////////////////////////////////////////////////////////////////
  function bit1024 unpack2pack(bit8_128 dataBlock);
    for (int i = 0; i < 128; i++) unpack2pack[8*i+:8] = dataBlock[i];
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- pack2unpack(): Convert packed array to unpacked.*/
  /////////////////////////////////////////////////////////////////////////////
  function bit8_128 pack2unpack(bit1024 dataBlock);
    for (int i = 0; i < 128; i++) pack2unpack[i] = dataBlock[8*i+:8];
  endfunction
  //
endclass // Avalon_s_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class AX4LiteI_s_busBFM:
///////////////////////////////////////////////////////////////////////////////
class Avalon_s_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  string id_name;
  int blockSize;
  virtual avalon_s_if ifc;
  // Mailboxes
  TransMBox trWrDataBox, trRdDataBox, statusBox;
  // Internal memory
  bit8 intMemArray[bit32];
  // Delay controls
  int minWaitReqDelay;
  int maxWaitReqDelay;
  int minValidDelay;
  int maxValidDelay;
  int waitReqDelay;
  int validDelay;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  function new();
    this.minWaitReqDelay   = 0;
    this.maxWaitReqDelay   = 0;
    this.minValidDelay     = 0;
    this.maxValidDelay     = 0;
    this.waitReqDelay      = 0;
    this.validDelay        = 0;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startBFM(): Start loop for each channel.*/
  /////////////////////////////////////////////////////////////////////////////
  task startBFM();
    this.trWrDataBox   = new();
    this.trRdDataBox   = new();
    this.statusBox     = new();
    fork
      this.write_data_loop();
      this.read_data_loop();
      this.write_loop();
    join_none
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_loop(): Get write address and data transactions from the lower level.
  //  Put data to the internal memory. Generate write response transaction.*/
  /////////////////////////////////////////////////////////////////////////////
  local task write_loop();
    Avalon_s_busTrans tr;
    bit32 addr, burstAddr;
    bit [10:0] burstCount;
    burstCount = 11'd0;
    // Start main loop for write address channel
    forever begin
      // Get data and put to the memory
      this.trWrDataBox.get(tr);
      addr = tr.address;
      if(tr.beginbursttransfer == 1'b1) begin
        burstAddr  = tr.address;
        burstCount = tr.burstcount;
      end else if(burstCount != 0) begin
        burstAddr += this.blockSize;
        addr = burstAddr;
        burstCount--;
      end
      // Avalon address always will be aligned. Missaligned data will be controled
      // via "byteenable" bus.
      while((addr%this.blockSize) != 0) begin
        addr--;
        burstAddr--;
      end
      if(tr.write == 1'b1) begin
        for(int i = 0; i < this.blockSize; i++) begin
          if(tr.byteenable[i] == 1'b1) begin
            this.intMemArray[addr + i] = tr.dataBlock[i];
          end
        end
      end else if (tr.read == 1'b1) begin
        
        //if (32'h11f50 == tr.address[31:0]) $stop;
    
        // Read transaction. Provide read data
        for(int i = 0; i < this.blockSize; i++) begin
          if(this.intMemArray.exists(addr + i)) begin
            tr.dataBlock[i] = this.intMemArray[addr + i];
          end else begin
            tr.dataBlock[i] = $random;
          end
        end
        tr.dataWord = tr.unpack2pack(tr.dataBlock);
        this.trRdDataBox.put(tr);
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- write_data_loop(): Get write data transaction and pass one level up.*/
  /////////////////////////////////////////////////////////////////////////////
  local task write_data_loop();
    Avalon_s_busTrans tr;
    // Start main loop for write address channel
    forever begin
      tr = new();
      do begin
        if(this.waitReqDelay == 0) this.ifc.cb.waitrequest <= 1'b0;
        else this.ifc.cb.waitrequest <= 1'b1;
        @this.ifc.cb;
      end while(this.ifc.cb.chipselect !== 1'b1);
      tr.burstcount         = this.ifc.cb.burstcount;
      tr.beginbursttransfer = this.ifc.cb.beginbursttransfer;
      // Delay waitrequest signal
      repeat (this.waitReqDelay) @this.ifc.cb;

      while(this.ifc.cb.chipselect !== 1'b1) @this.ifc.cb;
  
      this.ifc.cb.waitrequest <= 1'b0;
      tr.dataBlock      = tr.pack2unpack(this.ifc.cb.writedata);
      tr.address        = this.ifc.cb.address;
      tr.byteenable     = this.ifc.cb.byteenable;
      tr.read           = this.ifc.cb.read;
      tr.write          = this.ifc.cb.write;
      this.trWrDataBox.put(tr);
      tr = null;
      if(this.waitReqDelay != 0) begin
        @this.ifc.cb;
      end
      // Generate random delay
      this.waitReqDelay = $urandom_range(this.maxWaitReqDelay, this.minWaitReqDelay);
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- read_data_loop(): Get read data transaction from upper level and put to
  //  the bus.*/
  /////////////////////////////////////////////////////////////////////////////
  local task read_data_loop();
    Avalon_s_busTrans tr;
    // Init
    this.ifc.cb.readdatavalid       <= 1'b0;
    // Start main loop for write address channel
    forever begin
      this.trRdDataBox.get(tr);
      // Delay readdatavalid signal
      repeat (this.validDelay) @this.ifc.cb;
      // Generate random delay
      this.validDelay = $urandom_range(this.maxValidDelay, this.minValidDelay);
      this.ifc.cb.readdatavalid     <= 1'b1;
      this.ifc.cb.readdata <= tr.dataWord;
      @this.ifc.cb;
      this.ifc.cb.readdatavalid     <= 1'b0;
    end
  endtask
  //
endclass // Avalon_s_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class Avalon_s_env:
///////////////////////////////////////////////////////////////////////////////
class Avalon_s_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local Avalon_s_busBFM busBFM; 
  local int envStarted      = 0;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Connect physical interface to virtual and set data bus size.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(string id_name, virtual avalon_s_if ifc, int blockSize = 4);
    this.busBFM            = new();
    this.busBFM.ifc        = ifc;
    this.busBFM.blockSize  = blockSize;
    this.busBFM.id_name    = id_name;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start BFM. Only after this task transactions will appear on
  //  the Avalon bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(envStarted == 0) begin
      this.busBFM.startBFM();
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRandDelay(): Set response random delays. To disable random delays set
  //  all arguments to zero.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRandDelay(int minWaitReqDelay=0, maxWaitReqDelay=0, minValidDelay=0, maxValidDelay=0);
    this.busBFM.minWaitReqDelay  = minWaitReqDelay;
    this.busBFM.maxWaitReqDelay  = maxWaitReqDelay;
    this.busBFM.minValidDelay    = minValidDelay;
    this.busBFM.maxValidDelay    = maxValidDelay;
    this.busBFM.waitReqDelay     = maxWaitReqDelay;
    this.busBFM.validDelay       = maxValidDelay;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- putData(): Put data buffer to the internal memory.*/
  /////////////////////////////////////////////////////////////////////////////
  task putData(input bit32 startAddr, bit8 dataInBuff[]);
    for(int i = 0; i < dataInBuff.size(); i++) begin
      this.busBFM.intMemArray[startAddr+i] = dataInBuff[i];
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getData(): Get data buffer from the internal memory.*/
  /////////////////////////////////////////////////////////////////////////////
  task getData(input bit32 startAddr, output bit8 dataOutBuff[], input int lenght);
    dataOutBuff = new[lenght];
    for(int i = 0; i < lenght; i++) begin
      if(this.busBFM.intMemArray.exists(startAddr+i)) begin
        dataOutBuff[i] = this.busBFM.intMemArray[startAddr+i];
      end else begin
        dataOutBuff[i] = 8'd0;
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- pollData(): Poll specified address until read data is equal to pollData.
  // If poll counter is reached to "pollTimeOut" value stop, polling and
  // generate error message.*/
  /////////////////////////////////////////////////////////////////////////////
  task pollData(input bit32 address, bit8 pollData[], bit32 pollTimeOut = 1000);
    bit8 dataBuff[];
    int status;
    string tempStr;
    Avalon_s_busTrans trErr;
    $display("Polling address 0x%h: @sim time %0d", address, $time);
    fork: poll
    begin
      do begin
        this.getData(address, dataBuff, pollData.size());
        status = 0;
        for(int i = 0; i < pollData.size(); i++) begin
          if(dataBuff[i] != pollData[i]) begin
            status = 1;
            break;
          end
        end
        if(status == 1) @this.busBFM.ifc.cb;
      end while(status == 1);
      $display("Poll Done!");
    end
    begin
      repeat(pollTimeOut) @this.busBFM.ifc.cb;
      trErr = new();
      $display("%s,-Poll Time Out Detected at sim time %0d", this.busBFM.id_name, $time());
      tempStr.itoa($time);
      trErr.failedTr     = {this.busBFM.id_name, "-", "Poll TimeOut detected. At simulation time "};
      trErr.failedTr     = {trErr.failedTr, tempStr, "ns"};
      this.busBFM.statusBox.put(trErr);
      trErr = null;
    end
    join_any
    disable poll;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print poll timeout errors and return errors count.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    int statusBoxSize;
    Avalon_s_busTrans tr;
    tr = new();
    statusBoxSize = this.busBFM.statusBox.num();
    while(this.busBFM.statusBox.num() != 0)begin
      void'(this.busBFM.statusBox.try_get(tr));
      $display(tr.failedTr);
    end
    tr = null;
    $display("The %s slave VIP has %d errors", this.busBFM.id_name, statusBoxSize);
  endfunction
  //
endclass // Avalon_s_env
//
endpackage
