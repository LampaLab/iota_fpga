#include <stdio.h>
#include "hash.h"
#include "constants.h"
#include "curl.h"
#include "../workspace/curl_lib_wrapper.h"

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
