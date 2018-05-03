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

    int transaction_num;

    Curl curl;
    Converter conv;

    virtual interface Curl_tb_if curl_tb_if;

    rand int len;
    rand s_byte_darr_t trytes_in = new[2673];

    s_byte_darr_t trits_in;
    s_byte_darr_t trits_out_golden;
    s_byte_darr_t trytes_out_golden;
    s_byte_darr_t trits_out_rtl;
    s_byte_darr_t trytes_out_rtl;    
    
    const int CURL_STATE_WORD_NUM = 27;
    const int HASH_LEN_WORD_NUM = 9;    
    
    constraint data_in 
    {
        //len > 0; 
        //len < 100;
        //trytes_in.size() == len;
        foreach(trytes_in[i]) trytes_in[i] inside {[65:90], 57}; //69-90 are ascii codes range for A-Z
    }

    function new(virtual interface Curl_tb_if curl_tb_if, int transaction_num);
        this.transaction_num = transaction_num;
        this.curl_tb_if = curl_tb_if;
        $timeformat(-9, 2, " ns", 20);
        curl = new(); 
        conv = new();
    endfunction

    task automatic run();

        this.reset_rtl();

        repeat (transaction_num) begin
            this.randomize();
            conv.trits_from_trytes(trytes_in, trits_in);

            fork
                begin: curl_golden
                    curl.absorb(trits_in);
                    curl.squeeze(trits_out_golden, curl_const_pkg::HASH_LENGTH);
                end
                
                begin: curl_rtl_driver
                    this.clear_rtl();
                    this.absorb_rtl(trits_in);
                    this.squeeze_rtl(trits_out_rtl);
                end
               
            join
 
            conv.trytes_from_trits(trytes_out_golden, trits_out_golden);           
            conv.trytes_from_trits(trytes_out_rtl, trits_out_rtl); 
            
            if(trytes_out_rtl !== trytes_out_golden) begin
                $display("ERROR! Results mismatch!");
                $display("%0t: Input: %s", $time, string'(trytes_in));
                $display("%0t: Out golden: %s", $time, string'(trytes_out_golden));
                $display("%0t: Out rtl: %s", $time, string'(trytes_out_rtl));
            end 

        end

        $finish;

    endtask
        
    task automatic reset_rtl();

        @(curl_tb_if.cb);
        curl_tb_if.cb.i_arst_n      <= 1'b0; 
        curl_tb_if.cb.i_we          <= 1'b0;
        curl_tb_if.cb.i_addr        <= 1'b0;
        curl_tb_if.cb.i_data        <= 1'b0;   
        curl_tb_if.cb.i_transform   <= 1'b0; 
        @(curl_tb_if.cb);       
        curl_tb_if.cb.i_arst_n      <= 1'b1;

    endtask

    task automatic clear_rtl();

        for(int i = 0; i < CURL_STATE_WORD_NUM; i++) begin
            @(curl_tb_if.cb);    
            curl_tb_if.cb.i_we <= 1'b1;
            curl_tb_if.cb.i_addr <= i;
            curl_tb_if.cb.i_data <= '0;
        end

        @(curl_tb_if.cb);    
        curl_tb_if.cb.i_we <= 1'b0;
        
    endtask

    task automatic absorb_rtl(const ref s_byte_darr_t trits);
 
        int data_len = trits.size();
        int data_offset = 0;
        int msg_offset = 0;
        int M = 0;
        int N = 0;
        int msg_len = 0;
        int msg_id = 0;
    
        bit signed [8:0][26:0][1:0] data_to_rtl;
    
        if (data_len > 0)
        do begin 

            M = (data_len < HASH_LENGTH) ? data_len : HASH_LENGTH;
            data_to_rtl = '0;

            msg_len = M;
            msg_id = 0;
            msg_offset = 0;

            do begin
            
                N = (msg_len < CURL_STATE_WORD_NUM) ? msg_len : CURL_STATE_WORD_NUM;
                    
                for(int j = 0; j < N; j++)
                    data_to_rtl[msg_id][j] = trits[data_offset + msg_offset + j][1:0];

                msg_offset += CURL_STATE_WORD_NUM;
                msg_id++;

            end while ( (msg_len -= CURL_STATE_WORD_NUM) > 0); // CURL_STATE_WORD_NUM = 27
    
            this.set_data(data_to_rtl);

            this.transform_rtl();

            //$display("%p", state);
	        data_offset += HASH_LENGTH;
        end while( (data_len -= HASH_LENGTH) > 0 );
 
    endtask

    task automatic set_data(ref bit signed [8:0][26:0][1:0] data_to_rtl);

        for(int i = 0; i < HASH_LEN_WORD_NUM; i++) begin
            @(curl_tb_if.cb);    
            curl_tb_if.cb.i_we <= 1'b1;
            curl_tb_if.cb.i_addr <= i;
            curl_tb_if.cb.i_data <= data_to_rtl[i];
        end

        @(curl_tb_if.cb);    
        curl_tb_if.cb.i_we <= 1'b0;

    endtask
  
    task automatic squeeze_rtl(ref s_byte_darr_t trits_out);

        bit signed [8:0][26:0][1:0] data_from_rtl = '0;

        trits_out = new[curl_const_pkg::HASH_LENGTH];

        for(int i = 0; i < HASH_LEN_WORD_NUM; i++) begin
            @(curl_tb_if.cb);    
            curl_tb_if.cb.i_addr <= i;
            @(curl_tb_if.cb);
            @(curl_tb_if.cb);
            data_from_rtl[i] = curl_tb_if.cb.o_data;
        end

        for(int i = 0; i < HASH_LEN_WORD_NUM; i++) begin

            for(int j = 0; j < CURL_STATE_WORD_NUM; j++) begin
                trits_out[CURL_STATE_WORD_NUM*i + j] = $signed(data_from_rtl[i][j]);
            end

        end

    endtask

    task automatic transform_rtl();

        wait(!curl_tb_if.cb.o_transforming);

        @(curl_tb_if.cb); 
        curl_tb_if.cb.i_transform <= 1'b1;
        @(curl_tb_if.cb); 
        curl_tb_if.cb.i_transform <= 1'b0;
    
        @(negedge curl_tb_if.cb.o_transforming);
        @(curl_tb_if.cb);

    endtask


endclass

`endif // CURL_TB_SV

`timescale 1 ns / 1 ps

module tb;

parameter PERIOD = 10;

logic clk;

Curl_tb_if curl_tb_if( .clk(clk) );

Curl_tb tb = new(curl_tb_if, 5);

initial begin
    clk = 0;
    forever #(PERIOD/2) clk = !clk;
end

initial tb.run();

curl_transform transform_inst (.i_clk ( clk ),
						        .i_arst_n ( curl_tb_if.i_arst_n ),
				                .i_we ( curl_tb_if.i_we ),
                                .i_addr ( curl_tb_if.i_addr ),
						        .i_data ( curl_tb_if.i_data ),
						        .i_transform ( curl_tb_if.i_transform ),
						        .o_transforming ( curl_tb_if.o_transforming ),
						        .o_data ( curl_tb_if.o_data )
					            );

endmodule

