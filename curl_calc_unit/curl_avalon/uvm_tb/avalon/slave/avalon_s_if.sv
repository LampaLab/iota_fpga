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

`ifndef AVALON_S_IF
`define AVALON_S_IF

interface avalon_s_if(input clk, arst);
  logic  [31:0]   address;
  logic  [127:0]  byteenable;
  logic           chipselect;
  logic           read;
  logic           write;
  logic  [1023:0] readdata;
  logic  [1023:0] writedata;
  logic           waitrequest;
  logic           readdatavalid;
  logic  [10:0]   burstcount;
  logic           beginbursttransfer;
  // Clock edge alignment
  sequence sync_posedge;
     @(posedge clk) 1;
  endsequence
  // Clocking block
  clocking cb @(posedge clk);
    input  address;
    input  byteenable;
    input  chipselect;
    input  read;
    input  write;
    input  writedata;
    input  burstcount;
    input  beginbursttransfer;
    output readdata;
    output waitrequest;
    output readdatavalid;
  endclocking
  // Clock edge alignment
  task clockAlign();
    wait(sync_posedge.triggered);
  endtask
  //
endinterface

`endif