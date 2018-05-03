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
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <pthread.h>
#include "hash.h"
#include "constants.h"
#include "curl.h"

int gen_trans(char *transaction, int len)
{
    if (!len)
        return -1;

    if (NULL == transaction)
        return -1;

    for (int i = 0; i < len; i++)
        transaction[i] = (rand() % 3) - 1;

    return 0;
}

long int get_time_ms() 
{
    struct timeval tp;
    gettimeofday(&tp, NULL);
    return tp.tv_sec * 1000 + tp.tv_usec / 1000;
}

int main(int argc, char **argv)
{
    int measure_time = 10;                      //sec

    curl_t curl;
    char digest[HASH_LENGTH];
    char transaction[TRANSACTION_LENGTH];       //TRANSACTION_LENGTH = 2673*3    
    time_t start_time;                          // in sec
    int hash_cnt = 0;

    long int start_work, stop_work, work_time;  //in msec

    srand(time(NULL));

    if (argc > 1)
        if(atoi(argv[1]))
            measure_time = atoi(argv[1]);

    start_time = time(NULL);                    //time in sec from Jan 1, 1970 

    work_time = 0;

    do {
        gen_trans(transaction, TRANSACTION_LENGTH);
        start_work = get_time_ms();
        init_curl(&curl);
        absorb(&curl, transaction, TRANSACTION_LENGTH);
        squeeze(&curl, digest, HASH_LENGTH);
        stop_work = get_time_ms();
        work_time += stop_work - start_work;
        hash_cnt++;
        if (0 == (get_time_ms() % 100) )
            printf("Curl hashrate: %f hash/sec\n", (double)hash_cnt/work_time*1000);
    } while (difftime(time(NULL), start_time) < measure_time);

    printf("Curl hashrate: %f hash/sec\n", (double)hash_cnt/work_time*1000);

    return 0;
}
