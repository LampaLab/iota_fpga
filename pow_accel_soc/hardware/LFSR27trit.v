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

module LFSR27trit(i_clk, i_arst_n, o_rnd_trits);

input               i_clk;
input               i_arst_n;
output  reg [53:0]  o_rnd_trits;

reg     [53:0]      lfsr;

wire    lfsr_lsb = ~(lfsr[53] ^ lfsr[52] ^ lfsr[17] ^ lfsr[16]);

integer i = 0;

always @(posedge i_clk, negedge i_arst_n) begin

    if (~i_arst_n) begin
        lfsr <= '0;
    end else begin
        lfsr <= {lfsr[52:0], lfsr_lsb};
    end

end

always @* begin

    for(i = 0; i < 27; i = i+1) begin
        o_rnd_trits[2*i + 1] = ~(~lfsr[2*i] && lfsr[2*i + 1]) && lfsr[2*i + 1];    
        o_rnd_trits[2*i] = lfsr[2*i];
    end

end

endmodule

