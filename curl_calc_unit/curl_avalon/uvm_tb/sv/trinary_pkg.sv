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

`ifndef TRINARY_PKG_SV
`define TRINARY_PKG_SV

package trinary_pkg;

    typedef bit signed [7:0] signed_byte_t;
    typedef bit [7:0] unsigned_byte_t;
    typedef signed_byte_t s_byte_darr_t[];
    typedef unsigned_byte_t u_byte_darr_t[];  
    typedef signed_byte_t trit_t;
    typedef bit [7:0] tryte_t;
    typedef trit_t trit_darr_t[];
    typedef tryte_t tryte_darr_t[];

    parameter int TRYTE_SPACE = 27;
    parameter int MIN_TRYTE_VALUE = -13;
    parameter int MAX_TRYTE_VALUE = 13;
    parameter int RADIX = 3;
    parameter int MAX_TRIT_VALUE = (RADIX - 1) / 2;
    parameter int MIN_TRIT_VALUE = -MAX_TRIT_VALUE;
    parameter int NUMBER_OF_TRITS_IN_A_BYTE = 5;                  
    parameter int NUMBER_OF_TRITS_IN_A_TRYTE = 3;

    typedef trit_t [0:NUMBER_OF_TRITS_IN_A_TRYTE-1] trits_in_tryte_t;

    const string TRYTE_STRING = "9ABCDEFGHIJKLMNOPQRSTUVWXYZ";

endpackage : trinary_pkg

`endif 




