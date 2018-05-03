/*MIT License

Copyright (c) 2018 Ievgen Korokyi

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

`ifndef CURL_TB_SV
`define CURL_TB_SV

import trinary_pkg::*;
import curl_pkg::*;
import converter_pkg::*;
import curl_const_pkg::*;

import AVALON_M::*;
import AVALON_S::*;

interface Curl_tb_if (input wire clk);
                     
logic           i_arst_n;
logic   [53:0]  i_data;
logic   [4:0]   i_addr;    
logic           i_we;
logic		    i_transform;
wire		    o_transforming;
wire	[53:0]  o_data;

clocking cb @(posedge clk);
    output    i_arst_n;
    output    i_data;
    output    i_addr;
    output    i_we;
    output    i_transform;
    input     o_transforming;
    input     o_data;
endclocking

endinterface : Curl_tb_if

class Curl_tb;

    int hash_num;
    int timeout;

    Curl curl;
    Converter conv;

    Avalon_m_env avalon_cpu_master;
    Avalon_s_env avalon_sdram_slave;

    virtual interface avalon_s_if avalon_slave_if;
    virtual interface avalon_m_if avalon_master_if;

    typedef bit [7:0] ubyte;
    typedef ubyte ctrl_word_t[0:3];
    ctrl_word_t ctrl_word;

    //rand int len = 2673;
    int len = 486;
    rand s_byte_darr_t trytes_in = new[len];

    s_byte_darr_t trits_in;
    s_byte_darr_t trits_out_golden;
    s_byte_darr_t trytes_out_golden;
    s_byte_darr_t s_trits_out_rtl;
    bit [7:0] u_trits_out_rtl[];
    s_byte_darr_t trytes_out_rtl;    
    
    const int CURL_STATE_WORD_NUM = 27;
    const int HASH_LEN_WORD_NUM = 9;    

    const int SRC_ADDR = 'h1000;//addr in 128 bit words
    const int DST_ADDR = 'h100000;
    
    constraint data_in 
    {
        //len > 0; 
        //len < 100;
        //len == 2673;
        //trytes_in.size() == len;
        foreach(trytes_in[i]) trytes_in[i] inside {[65:90], 57}; //69-90 are ascii codes range for A-Z
    }

    function new(virtual interface avalon_s_if avalon_slave_if, 
                    virtual interface avalon_m_if avalon_master_if, 
                    int hash_num = 1
                );
        this.hash_num = hash_num;
        this.avalon_slave_if = avalon_slave_if;
        this.avalon_master_if = avalon_master_if;  

        avalon_cpu_master = new("Avalon CPU master", avalon_master_if, 4);   
        avalon_sdram_slave = new("Avalon SDRAM slave", avalon_slave_if, 16);   
        
        $timeformat(-9, 2, " ns", 20);
        curl = new(); 
        conv = new();

    endfunction

    task automatic run();

        avalon_cpu_master.startEnv();
        avalon_sdram_slave.startEnv();

        avalon_cpu_master.setRandDelay(0, 10, 0, 10);
        avalon_sdram_slave.setRandDelay(0, 5, 0, 5);

        repeat (hash_num) begin

            this.randomize();
            conv.trits_from_trytes(trytes_in, trits_in);

            fork
                begin: curl_golden
                    curl.absorb(trits_in);
                    curl.squeeze(trits_out_golden, curl_const_pkg::HASH_LENGTH);
                end
                
                begin: curl_rtl_driver

                    avalon_sdram_slave.putData(SRC_ADDR*16, u_byte_darr_t'(trits_in));

                    {<<ubyte{ctrl_word}} = SRC_ADDR;
                    avalon_cpu_master.writeData(4, ctrl_word);
                    
                    {<<ubyte{ctrl_word}} = DST_ADDR;
                    avalon_cpu_master.writeData(8, ctrl_word);

                    ctrl_word[0] = 2;
                    ctrl_word[1] = (3*len & 8'hff);
                    ctrl_word[2] = (3*len >> 8);
                    avalon_cpu_master.writeData(0, ctrl_word);

                    avalon_cpu_master.waitCommandDone();

                    this.timeout = 10000;

                    do begin
            
                        repeat(500) @avalon_master_if.cb;

                        avalon_cpu_master.readData(0, 4);
                        avalon_cpu_master.waitCommandDone();
                        avalon_cpu_master.getData(4, ctrl_word);
                      
                        this.timeout--;

                        if (0 == this.timeout) begin
                            $display("Timeout during waiting for curl calculation finish :(");
                            $fatal;
                        end
                                                  
                    end while( !(ctrl_word[0] & 1) );

                    u_trits_out_rtl = new[curl_const_pkg::HASH_LENGTH];
                    avalon_sdram_slave.getData(DST_ADDR*16, u_trits_out_rtl, curl_const_pkg::HASH_LENGTH);

                    s_trits_out_rtl  = s_byte_darr_t'(u_trits_out_rtl);

                end
               
            join
 
            conv.trytes_from_trits(trytes_out_golden, trits_out_golden);           
            conv.trytes_from_trits(trytes_out_rtl, s_trits_out_rtl); 
            
            if(trytes_out_rtl !== trytes_out_golden) begin
                $display("ERROR! Results mismatch!");
                $display("%0t: Input: %s", $time, string'(trytes_in));
                $display("%0t: Out golden: %s", $time, string'(trytes_out_golden));
                $display("%0t: Out rtl: %s", $time, string'(trytes_out_rtl));
            end else $display("Hash OK!");

        end

        $finish;

    endtask

endclass

`endif // CURL_TB_SV

`timescale 1 ns / 1 ps

module tb;

parameter PERIOD = 10;

logic clk;
logic arst;

Curl_tb_if curl_tb_if( .clk(clk) );

avalon_s_if avalon_slave_if( .clk(clk) );
avalon_m_if avalon_master_if( .clk(clk) );

Curl_tb tb = new(avalon_slave_if, avalon_master_if, 20);

initial begin
    clk = 0;
    forever #(PERIOD/2) clk = !clk;
end


initial begin
    arst = 1'b1;
    repeat (2) @(negedge clk);
    arst = 1'b0;
    tb.run();
end

assign avalon_slave_if.address[3:0] = '0;
assign avalon_slave_if.chipselect = avalon_slave_if.write | avalon_slave_if.read;

curl_avalon cv_inst( .i_clk (clk),
                    .i_arst (arst),
                    // slave IF
                    .i_slave_writedata ( avalon_master_if.writedata ),
                    .i_slave_byteenable ( avalon_master_if.byteenable ),
                    .i_slave_write ( avalon_master_if.write ),
                    .i_slave_read ( avalon_master_if.read ),
                    .i_slave_address ( avalon_master_if.address[31:2] ),
                    .o_slave_readdata ( avalon_master_if.readdata ),
                    .o_slave_waitrequest ( avalon_master_if.waitrequest ),
                    .o_slave_readdatavalid ( avalon_master_if.readdatavalid ),
                    // master IF
                    .o_master_address ( avalon_slave_if.address[31:4] ),
	                .o_master_write ( avalon_slave_if.write ),
                    .o_master_read ( avalon_slave_if.read ),
	                .o_master_byteenable ( avalon_slave_if.byteenable ),
	                .o_master_writedata ( avalon_slave_if.writedata ),
	                .i_master_waitrequest ( avalon_slave_if.waitrequest ),
                    .i_master_readdatavalid ( avalon_slave_if.readdatavalid ),
                    .i_master_readdata ( avalon_slave_if.readdata )
                    );

endmodule

