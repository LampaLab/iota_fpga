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
#include "hash.h"
#include "constants.h"

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
    int measure_time = 60;                      //sec

    char digest[HASH_LENGTH];
    char transaction[TRANSACTION_LENGTH];       //TRANSACTION_LENGTH = 2673*3    
    time_t start_time;                          // in sec
    int hash_cnt = 0;    
    long int start_work, stop_work, work_time;  //in msec

    int in_trits_len = TRANSACTION_LENGTH;
    int result;

    FILE *ctrl_fd = 0;
    FILE *in_fd = 0;
    FILE *out_fd = 0;

    srand(time(NULL));    

    ctrl_fd = fopen("/dev/curl-ctrl", "r+");

    if(ctrl_fd == NULL) {
        perror("curl-ctrl open fail");
        exit(EXIT_FAILURE);
    }

    in_fd = fopen("/dev/curl-idata", "wb");

    if(in_fd == NULL) {
        perror("curl-idata open fail");
        fclose(ctrl_fd);
	exit(EXIT_FAILURE);
    }

    out_fd = fopen("/dev/curl-odata", "rb");

    if(out_fd == NULL) {
        perror("curl-odata open fail");
 	fclose(ctrl_fd);
	fclose(in_fd);
        exit(EXIT_FAILURE);
    }

    if (argc > 1)
        if(atoi(argv[1]))
            measure_time = atoi(argv[1]);

    start_time = time(NULL);                    //time in sec from Jan 1, 1970 

    work_time = 0;    

    do {
        gen_trans(transaction, TRANSACTION_LENGTH);
        start_work = get_time_ms();

        rewind(in_fd);
        fwrite(transaction, 1, TRANSACTION_LENGTH, in_fd);
        fflush(in_fd);

        rewind(ctrl_fd);
        fwrite(&in_trits_len, 1, 2, ctrl_fd);
        fread(&result, sizeof(result), 1, ctrl_fd);
        fflush(ctrl_fd);

        rewind(out_fd);
        fread(digest, 1, 243, out_fd);
        fflush(out_fd);

        stop_work = get_time_ms();
        work_time += stop_work - start_work;              
        hash_cnt++;
        if (0 == (get_time_ms() % 100) ) 
            printf("Curl hashrate: %f hash/sec\n", (double)hash_cnt/work_time*1000);
    } while (difftime(time(NULL), start_time) < measure_time);

    printf("Curl hashrate: %f hash/sec\n", (double)hash_cnt/work_time*1000);    

    fclose(in_fd);
    fclose(out_fd);
    fclose(ctrl_fd);

    exit(EXIT_SUCCESS);
}
