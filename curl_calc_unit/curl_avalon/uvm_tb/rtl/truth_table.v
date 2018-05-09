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

module truth_table(truth_table_sel, truth_table_trit);

input               [3:0]   truth_table_sel;
output  reg signed  [1:0]   truth_table_trit;

always @* begin

    case (truth_table_sel)

    0:  truth_table_trit = 2'd1;

    1:  truth_table_trit = 2'd0;

    2:  truth_table_trit = -2'd1;

    3:  truth_table_trit = 2'd1;

    4:  truth_table_trit = -2'd1;

    5:  truth_table_trit = 2'd0;

    6:  truth_table_trit = -2'd1;

    7:  truth_table_trit = 2'd1;

    8:  truth_table_trit = 2'd0;

    default: truth_table_trit = 2'd0;

    endcase

end	

endmodule

