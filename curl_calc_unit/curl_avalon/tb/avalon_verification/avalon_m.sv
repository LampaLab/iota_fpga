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

package AVALON_M;
typedef bit [7:0]    bit8;
typedef bit [31:0]   bit32;
typedef bit [127:0]  bit128;
typedef bit [1023:0] bit1024;
typedef bit8         bit8_128[128];
typedef class Avalon_m_busTrans;
typedef class Avalon_m_busBFM;
typedef class Avalon_m_env;
typedef mailbox #(Avalon_m_busTrans) TransMBox;
///////////////////////////////////////////////////////////////////////////////
// Class Avalon_m_busTrans:
///////////////////////////////////////////////////////////////////////////////
class Avalon_m_busTrans;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
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
  /////////////////////////////////////////////////////////////////////////////
  /*- genErrorMsg(): Generate error message and keep in the "failedTr" string.*/
  /////////////////////////////////////////////////////////////////////////////
  function void genErrorMsg(string errString);
    string tempStr;
    errString = {errString, " at sim time "};
    $write(errString);
    $write("%0d\n", $time());
    tempStr.itoa($time);
    this.failedTr = errString;
    this.failedTr = {this.failedTr, " ", tempStr, "ns"};
  endfunction
  //
endclass // Avalon_m_busTrans
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Class Avalon_m_busBFM:
///////////////////////////////////////////////////////////////////////////////
class Avalon_m_busBFM;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  string id_name;
  int blockSize;
  virtual avalon_m_if ifc;
  // Mailboxes
  TransMBox trWrDataBox, trRdDataBox, trRdDataL0Box, statusBox;
  semaphore wrDataSem;
  local Avalon_m_busTrans trWrData;
  int waitReqTimeOut, validTimeOut;
  // Delay control variables
  int       maxBurstLenWrData;
  int       burstCntWrData;
  int       maxBurst;
  int       minBurst;
  int       maxWait;
  int       minWait;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  function new();
    this.maxBurstLenWrData = 0;
    this.burstCntWrData    = 0;
    this.maxBurst          = 0;
    this.minBurst          = 0;
    this.maxWait           = 0;
    this.minWait           = 0;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startBFM(): Start loop for each channel.*/
  /////////////////////////////////////////////////////////////////////////////
  task startBFM();
      fork
        this.run_loop();
        this.read_data_loop();
      join_none
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- run_loop():.*/
  /////////////////////////////////////////////////////////////////////////////
  task run_loop();
    // Init
    this.ifc.cb.address             <= 'd0;
    this.ifc.cb.writedata           <= 'd0;
    this.ifc.cb.byteenable          <= 'd0;
    this.ifc.cb.chipselect          <= 1'b0;
    this.ifc.cb.write               <= 1'b0;
    this.ifc.cb.read                <= 1'b0;
    this.ifc.cb.burstcount          <= 'd0;
    this.ifc.cb.beginbursttransfer  <= 1'b0;
    // Start main loop for write data channel
    forever begin
      this.trWrDataBox.get(this.trWrData);
      if(this.trWrData.TrType == Avalon_m_busTrans::IDLE) begin
        repeat (this.trWrData.idleCycles) @this.ifc.cb;
      end else if (this.trWrData.TrType == Avalon_m_busTrans::WAIT) begin
        this.wrDataSem.put(1);
      end else begin
        this.singleTrans();
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- read_data_loop():.*/
  /////////////////////////////////////////////////////////////////////////////
  task read_data_loop();
    Avalon_m_busTrans trErr, tr;
    string tempStr;
    int counter;
    forever begin
      this.trRdDataL0Box.get(tr);
      // Poll readdatavalid
      counter = 0;
      while((this.ifc.cb.readdatavalid !== 1'b1) && (counter != this.validTimeOut)) begin
        @this.ifc.cb;
        counter++;
      end
      if(this.ifc.cb.readdatavalid !== 1'b1) begin
        trErr = new();
        trErr.genErrorMsg({id_name, "-", "ERROR: Data valid TimeOut Detected"});
        this.statusBox.put(trErr);
        trErr = null;
      end
      tr.dataWord = this.ifc.cb.readdata;
      this.trRdDataBox.put(tr);
      @this.ifc.cb;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- singleTrans(): Generate read/write timings.*/
  /////////////////////////////////////////////////////////////////////////////
  local task singleTrans();
    Avalon_m_busTrans trErr;
    string tempStr;
    // Clock alignment
    this.ifc.clockAlign();
    // Generate timing
    this.ifc.cb.address             <= this.trWrData.address;
    this.ifc.cb.writedata           <= this.trWrData.dataWord;
    this.ifc.cb.byteenable          <= this.trWrData.byteenable;
    this.ifc.cb.chipselect          <= 1'b1;
    this.ifc.cb.write               <= this.trWrData.write;
    this.ifc.cb.read                <= this.trWrData.read;
    this.ifc.cb.burstcount          <= this.trWrData.burstcount;
    this.ifc.cb.beginbursttransfer  <= this.trWrData.beginbursttransfer;
    @this.ifc.cb;
    this.ifc.cb.beginbursttransfer  <= 1'b0;
    // Poll waitrequest
    fork: w_wait_poll
      while(this.ifc.cb.waitrequest !== 1'b0) @this.ifc.cb;
      begin
        repeat(this.waitReqTimeOut) @this.ifc.cb;
        trErr = new();
        trErr.genErrorMsg({id_name, "-", "ERROR: Wait Request TimeOut Detected"});
        this.statusBox.put(trErr);
        trErr = null;
      end
    join_any
    disable w_wait_poll;
    this.ifc.cb.chipselect          <= 1'b0;
    this.ifc.cb.write               <= 1'b0;
    this.ifc.cb.read                <= 1'b0;
    if(this.trWrData.read == 1'b1) begin
      this.trRdDataL0Box.put(this.trWrData);
    end
    // Random timing control.
    if(this.maxBurstLenWrData != 0)begin
      this.burstCntWrData++;
    end
    if(this.burstCntWrData == this.maxBurstLenWrData) begin
      if(this.maxBurstLenWrData != 0) repeat(($urandom_range(this.maxWait, this.minWait))) @this.ifc.cb;
      this.burstCntWrData = 0;
      this.maxBurstLenWrData = $urandom_range(this.maxBurst, this.minBurst);
    end
  endtask
  //
endclass // Avalon_m_busBFM
///////////////////////////////////////////////////////////////////////////////
// Class Avalon_m_env:
///////////////////////////////////////////////////////////////////////////////
class Avalon_m_env;
  /////////////////////////////////////////////////////////////////////////////
  //************************ Class Variables ********************************//
  /////////////////////////////////////////////////////////////////////////////
  local Avalon_m_busTrans trWrData, trRdAddr;
  local int envStarted;
  local Avalon_m_busBFM busBFM;
  local int rdDataBuffSize;
  /////////////////////////////////////////////////////////////////////////////
  //************************* Class Methods *********************************//
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /*- new(): Connect physical interface to virtual. Set data bus size.*/
  /////////////////////////////////////////////////////////////////////////////
  function new(string id_name, virtual avalon_m_if ifc, int blockSize = 4);
    this.busBFM                = new();
    this.envStarted            = 0;
    this.busBFM.ifc            = ifc;
    this.busBFM.trWrDataBox    = new();
    this.busBFM.trRdDataBox    = new();
    this.busBFM.wrDataSem      = new();
    this.busBFM.trRdDataL0Box  = new();
    this.busBFM.statusBox      = new();
    this.busBFM.blockSize      = blockSize;
    this.busBFM.waitReqTimeOut = 10000;
    this.busBFM.validTimeOut   = 10000;
    this.busBFM.id_name        = id_name;
    this.rdDataBuffSize        = 0;
  endfunction
  /////////////////////////////////////////////////////////////////////////////
  /*- startEnv(): Start BFM. Only after this task transactions will appear on
  //  the Avalon bus.*/
  /////////////////////////////////////////////////////////////////////////////
  task startEnv();
    if(this.envStarted == 0) begin
      this.busBFM.startBFM();
      this.envStarted = 1;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setRandDelay(): Enable/Disable bus random delays. To disable delays set
  //  all arguments to zero.*/
  /////////////////////////////////////////////////////////////////////////////
  task setRandDelay(int minBurst=0, maxBurst=0, minWait=0, maxWait=0);
    this.busBFM.minBurst          = minBurst;
    this.busBFM.maxBurst          = maxBurst;
    this.busBFM.minWait           = minWait;
    this.busBFM.maxWait           = maxWait;
    this.busBFM.burstCntWrData    = 0;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- setTimeOut(): Set waitrequest and readdatavalid poll timeouts.*/
  /////////////////////////////////////////////////////////////////////////////
  task setTimeOut(int waitReqTimeOut, validTimeOut);
    this.busBFM.waitReqTimeOut = waitReqTimeOut;
    this.busBFM.validTimeOut   = validTimeOut;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- busIdle(): Hold bus in idle for the specified clock cycles.*/
  /////////////////////////////////////////////////////////////////////////////
  task busIdle(int idleCycles);
    this.trWrData               = new();
    this.trWrData.TrType        = Avalon_m_busTrans::IDLE;
    this.trWrData.idleCycles    = idleCycles;
    this.busBFM.trWrDataBox.put(this.trWrData);
    this.trWrData               = null;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- waitCommandDone(): Wait until all transactions in the mailbox are finished.*/
  /////////////////////////////////////////////////////////////////////////////
  task waitCommandDone();
    this.trWrData               = new();
    this.trWrData.TrType        = Avalon_m_busTrans::WAIT;
    this.busBFM.trWrDataBox.put(this.trWrData);
    this.trWrData               = null;
    this.busBFM.wrDataSem.get(1);
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- writeData(): Send data buffer. Start address will be incremented after
  // each transaction.*/
  /////////////////////////////////////////////////////////////////////////////
  task writeData(input bit32 addr, bit8 inBuff[], int burstEn = 0);
    bit [127:0] byteenable;
    int inBuffSize;
    int inBuffPtr;
    bit32 addrHold;
    int addrAlign;
    int startBurst;
    addrHold = addr;
    addrAlign = 0;
    inBuffSize = inBuff.size();
    startBurst = burstEn;
    // Avalon address always will be aligned. Missaligned data will be controled
    // via "byteenable" bus.
    while((addrHold%this.busBFM.blockSize) != 0) begin
      addrHold--;
      addrAlign++;
    end
    inBuffPtr = 0;
    while(inBuffSize != 0) begin
      // Put data information
      this.trWrData = new();
      byteenable = 'd0;
      for(int j = 0; j < this.busBFM.blockSize; j++) begin
        this.trWrData.dataBlock[j] = 8'd0;
      end
      for(int j = 0; j < this.busBFM.blockSize; j++) begin
        if(inBuffSize == 0) break;
        if(addrAlign == 0) begin
          this.trWrData.dataBlock[j] = inBuff[inBuffPtr];
          inBuffSize--;
          inBuffPtr++;
          byteenable[j] = 1'b1;
        end else begin
          addrAlign--;
        end
      end
      this.trWrData.dataWord            = this.trWrData.unpack2pack(this.trWrData.dataBlock);
      this.trWrData.byteenable          = byteenable;
      this.trWrData.burstcount          = 11'd0;
      if((burstEn == 1) && (startBurst == 0)) begin
        this.trWrData.address           = $random;
      end else begin
        // 1st burst transfer
        this.trWrData.address           = addrHold;
        if(burstEn == 1) begin
          this.trWrData.burstcount        = inBuff.size()/this.busBFM.blockSize;
          if((inBuff.size()%this.busBFM.blockSize) != 0) begin
            this.trWrData.burstcount      = this.trWrData.burstcount + 11'd1;
          end
        end
      end
      this.trWrData.write               = 1'b1;
      this.trWrData.read                = 1'b0;
      this.trWrData.TrType              = Avalon_m_busTrans::WRITE_READ;
      this.trWrData.beginbursttransfer  = startBurst[0];
      this.busBFM.trWrDataBox.put(this.trWrData);
      this.trWrData = null;
      addrHold+=this.busBFM.blockSize;
      startBurst = 0;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- readData():.*/
  /////////////////////////////////////////////////////////////////////////////
  task readData(input bit32 addr, int byteLen, int burstEn = 0);
    bit [127:0] byteenable;
    int inBuffSize;
    bit32 addrHold;
    int addrAlign;
    int startBurst;
    this.rdDataBuffSize += byteLen;
    startBurst = burstEn;
    addrHold = addr;
    addrAlign = 0;
    inBuffSize = byteLen;
    // Avalon address always will be aligned. Missaligned data will be controled
    // via "byteenable" bus.
    while((addrHold%this.busBFM.blockSize) != 0) begin
      addrHold--;
      addrAlign++;
    end
    while(inBuffSize != 0) begin
      // Put data information
      this.trWrData = new();
      byteenable = 'd0;
      for(int j = 0; j < this.busBFM.blockSize; j++) begin
        if(inBuffSize == 0) break;
        if(addrAlign == 0) begin
          inBuffSize--;
          byteenable[j] = 1'b1;
        end else begin
          addrAlign--;
        end
      end
      this.trWrData.byteenable          = byteenable;
      this.trWrData.burstcount          = 11'd0;
      if((burstEn == 1) && (startBurst == 0)) begin
        this.trWrData.address           = $random;
      end else begin
        // 1st burst transfer
        this.trWrData.address           = addrHold;
        if(burstEn == 1) begin
          this.trWrData.burstcount        = byteLen/this.busBFM.blockSize;
          if((byteLen%this.busBFM.blockSize) != 0) begin
            this.trWrData.burstcount      = this.trWrData.burstcount + 11'd1;
          end
        end
      end
      this.trWrData.write               = 1'b0;
      this.trWrData.read                = 1'b1;
      this.trWrData.TrType              = Avalon_m_busTrans::WRITE_READ;
      this.trWrData.beginbursttransfer  = startBurst[0];
      this.busBFM.trWrDataBox.put(this.trWrData);
      this.trWrData = null;
      addrHold+=this.busBFM.blockSize;
      startBurst = 0;
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- getData(): Get read data.*/
  /////////////////////////////////////////////////////////////////////////////
  task getData(int byteLen, output bit8 outBuff[]);
    int outBuffPtr;
    int rdLen;
    Avalon_m_busTrans trErr;
    Avalon_m_busTrans tr;
    if(this.rdDataBuffSize >= byteLen) begin
      rdLen = byteLen;
    end else begin
      rdLen = this.rdDataBuffSize;
      trErr = new();
      trErr.genErrorMsg({this.busBFM.id_name, "-", "ERROR: The requested data size is more that in the read data buffer",
                                        "It will be reduced"});
      this.busBFM.statusBox.put(trErr);
      trErr = null;
    end
    outBuff = new[rdLen];
    outBuffPtr = 0;
    this.rdDataBuffSize -= rdLen;
    while(outBuffPtr < rdLen) begin
      this.busBFM.trRdDataBox.get(tr);
      tr.dataBlock = tr.pack2unpack(tr.dataWord);
      for(int j = 0; j < this.busBFM.blockSize; j++) begin
        if(tr.byteenable[j] == 1'b1) begin
          outBuff[outBuffPtr] = tr.dataBlock[j];
          outBuffPtr++;
        end
      end
    end
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- pollData(): Poll specified addresses until read data buffer is equal to
  // pollData buffer. If poll counter is reached to "pollTimeOut" value
  // stop polling and generate error message.*/
  /////////////////////////////////////////////////////////////////////////////
  task pollData(input bit32 address, bit8 pollData[], int pollTimeOut=10000);
    bit8 dataBuff[];
    int status;
    Avalon_m_busTrans trErr;
    $display("Polling address 0x%h: @sim time %0d", address, $time);
    fork: poll
      begin
        repeat(pollTimeOut) @this.busBFM.ifc.cb;
        trErr = new();
        trErr.genErrorMsg({this.busBFM.id_name, ":-", "ERROR: Poll Time Out Detected"});
        this.busBFM.statusBox.put(trErr);
        trErr = null;
      end
      begin
        do begin
          this.readData(address, pollData.size());
          this.getData(pollData.size(), dataBuff);
          status = 0;
          for(int i = 0; i < pollData.size(); i++) begin
            if(dataBuff[i] != pollData[i]) begin
              status = 1;
              break;
            end
          end
        end while(status == 1);
        $display("Poll Done!");
      end
    join_any
    disable poll;
  endtask
  /////////////////////////////////////////////////////////////////////////////
  /*- printStatus(): Print all time out errors and return errors count.*/
  /////////////////////////////////////////////////////////////////////////////
  function void printStatus();
    int statusBoxSize;
    Avalon_m_busTrans tr;
    tr = new();
    statusBoxSize = this.busBFM.statusBox.num();
    while(this.busBFM.statusBox.num() != 0)begin
      void'(this.busBFM.statusBox.try_get(tr));
      $display(tr.failedTr);
    end
    tr = null;
    $display("The %s master VIP has %d errors", this.busBFM.id_name, statusBoxSize);
  endfunction
  //
endclass //Avalon_m_env
//
endpackage
