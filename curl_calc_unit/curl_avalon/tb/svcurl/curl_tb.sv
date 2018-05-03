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

import "DPI-C" context function void curl_lib_wrapper(input s_byte_darr_t in, inout s_byte_darr_t out);

interface Curl_tb_if (input clk);
endinterface : Curl_tb_if

class Curl_tb;

    int transaction_num;

    virtual interface Curl_tb_if curl_tb_if;

    rand int len;
    rand s_byte_darr_t trytes_in;
    
    s_byte_darr_t curl_hash_c;
    s_byte_darr_t curl_hash_sv;

    Curl curl;
    Converter conv;

    constraint data_in 
    {
        len > 0; 
        len < 10;
        trytes_in.size() == len;
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
        
        repeat (transaction_num) 
            @(posedge curl_tb_if.clk) begin
                this.randomize();
                fork
                    this.curl_sv(trytes_in, curl_hash_sv);
                    this.curl_c(trytes_in, curl_hash_c);
                join
                if(curl_hash_sv != curl_hash_c) begin
                    $display("ERROR! Results mismatch!");
                    $display("%0t: Input: %s", $time, string'(trytes_in));
                    $display("%0t: Out hash C: %s", $time, string'(curl_hash_c));
                    $display("%0t: Out hash SV: %s", $time, string'(curl_hash_sv));
                end
            end

        $finish;

    endtask

    function automatic void curl_sv(ref s_byte_darr_t trytes_in, ref s_byte_darr_t trytes_out);
        
        s_byte_darr_t trits_in;
        s_byte_darr_t trits_out;

        conv.trits_from_trytes(trytes_in, trits_in);
        curl.absorb(trits_in);
        curl.squeeze(trits_out, curl_const_pkg::HASH_LENGTH);
        conv.trytes_from_trits(trytes_out, trits_out);

    endfunction

    function automatic void curl_c(ref s_byte_darr_t trytes_in, ref s_byte_darr_t trytes_out);
        
        s_byte_darr_t trits_in;
        s_byte_darr_t trits_out = new[curl_const_pkg::HASH_LENGTH];

        conv.trits_from_trytes(trytes_in, trits_in);

        curl_lib_wrapper(trits_in, trits_out);

        conv.trytes_from_trits(trytes_out, trits_out);

    endfunction

endclass

`endif // CURL_TB_SV

`timescale 1 ns / 1 ps

module tb;

import trinary_pkg::*;
import curl_pkg::*;
import converter_pkg::*;

parameter PERIOD = 10;

logic clk;

Curl_tb_if curl_tb_if( .clk(clk) );

Curl_tb tb = new(curl_tb_if, 1000); 

initial begin
    clk = 0;
    forever #(PERIOD/2) clk = !clk;
end

initial tb.run();

endmodule

