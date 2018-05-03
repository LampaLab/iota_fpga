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

module true_dual_port_ram (i_clk,
							i_data_a, 
							i_data_b,
							i_addr_a, 
							i_addr_b,
							i_we_a, 
							i_we_b, 
							o_data_a, 
							o_data_b
							);

parameter 	DATA_WIDTH 	= 54;
parameter 	WORD_NUM	= 27;
parameter 	ADDR_WIDTH 	= $clog2(WORD_NUM);

input 								i_clk;
input 		[(DATA_WIDTH - 1) : 0] 	i_data_a; 
input 		[(DATA_WIDTH - 1) : 0] 	i_data_b;
input 		[(ADDR_WIDTH - 1) : 0] 	i_addr_a; 
input 		[(ADDR_WIDTH - 1) : 0] 	i_addr_b;
input 								i_we_a;
input 								i_we_b;
output reg 	[(DATA_WIDTH - 1) : 0] 	o_data_a; 
output reg 	[(DATA_WIDTH - 1) : 0] 	o_data_b;

reg [(DATA_WIDTH - 1) : 0] ram[WORD_NUM - 1 : 0];

// Port A 
always @(posedge i_clk) 
begin	
	if (i_we_a) begin
		ram[i_addr_a] <= i_data_a;
		o_data_a <= i_data_a;
	end else begin
		o_data_a <= ram[i_addr_a];
	end
 end 

 // Port B 
 always @(posedge i_clk)
 begin
	if (i_we_b) begin
		ram[i_addr_b] <= i_data_b;
		o_data_b <= i_data_b;
	end else begin
		o_data_b <= ram[i_addr_b];
	end 
 end

endmodule
