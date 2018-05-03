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

#include <stdio.h>
#include "hash.h"
#include "constants.h"
#include "curl.h"
#include "curl_lib_wrapper.h"

void curl_lib_wrapper(const svOpenArrayHandle in, const svOpenArrayHandle out)
{
    int *input_data = (int*) svGetArrayPtr(in);
    int *output_data = (int*) svGetArrayPtr(out);
    int len_in = svSize(in, 1);
    int len_out = svSize(out, 1);

    curl_t curl;
    init_curl(&curl);

    if(len_out < 1) return;

    char *curl_hash_trits = new char [len_out];
    char *in_trits = new char [len_in];

    for(int i = 0; i < len_in; i++)
    {
        in_trits[i] = (char)input_data[i];        
        //printf("%d ", in_trits[i]);           
    }

    absorb(&curl, in_trits, len_in);
    squeeze(&curl, curl_hash_trits, len_out);

    for(int i = 0; i < len_out; i++)
    {        
        //printf("%d ", curl_hash_trits[i]);   
        output_data[i] = (int)curl_hash_trits[i];        
    }
    
    //printf("\n");
    delete [] curl_hash_trits;

    delete [] in_trits;
}
