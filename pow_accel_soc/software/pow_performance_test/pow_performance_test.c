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
#include <unistd.h>
#include <error.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <fcntl.h>
#include "converter.h"
#include "curl.h"

#define NONCE_LEN                   81
#define HASH_LENGTH                 243
#define TRANSACTION_LEN             3*2673
#define NONCE_OFFSET                2646*3
#define HPS_TO_FPGA_BASE            0xC0000000
#define HPS_TO_FPGA_SPAN            0x0020000
#define HASH_CNT_REG_OFFSET         4
#define TICK_CNT_LOW_REG_OFFSET     5
#define TICK_CNT_HI_REG_OFFSET      6
#define MWM_MASK_REG_OFFSET         3
#define CPOW_BASE                   0

#define HINTS                                                                  \
  "### POW Accelerator Performance Test ###\nUsage:\n\t./pow_performance_test MWM NUM_OF_HASHES_TO_PROCESS \n"

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

int main(int argc, char* argv[]) 
{
    int print_hash = 0;
    int print_input = 0;

    FILE *ctrl_fd = 0;
    FILE *in_fd = 0;
    FILE *out_fd = 0;
    FILE *stat_fd = 0;
    int devmem_fd = 0;

    curl_t curl;

    uint32_t hashes_to_process = 10000;
    uint8_t mwm = 15;

    char transaction[TRANSACTION_LEN];       //2673*3   
    char *transaction_trytes = NULL;
  
    char  nonce_trits[NONCE_LEN];
    char* nonce_trytes = NULL; 

    char hash_trits[HASH_LENGTH];
    char* hash_trytes = NULL;

    time_t start_time;                          // in sec  

    void *fpga_regs_map = 0;
    uint32_t *cpow_map = 0;

    uint32_t hash_cnt = 0;
    uint32_t tick_cnt_l = 0;
    uint32_t tick_cnt_h = 0;
    uint64_t tick_cnt = 0;
    uint32_t hrate = 0;

    float pow_delay = 0;

    int result;

    if (argc == 3) {
        mwm = atoi(argv[1]);
        hashes_to_process = atoi(argv[2]);
    } else {
        fprintf(stderr, HINTS);
        return 1;
    }

    srand(time(NULL));

    stat_fd = fopen("./pow_delays.csv", "w+");

    if(stat_fd == NULL) {
        perror("Failed to create 'pow_delays.csv'");
        exit(EXIT_FAILURE);
    }

    ctrl_fd = fopen("/dev/cpow-ctrl", "r+");

    if(ctrl_fd == NULL) {
        perror("cpow-ctrl open fail");
        exit(EXIT_FAILURE);
    }

    in_fd = fopen("/dev/cpow-idata", "wb");

    if(in_fd == NULL) {
        perror("cpow-idata open fail");
        fclose(ctrl_fd);
        exit(EXIT_FAILURE);
    }

    out_fd = fopen("/dev/cpow-odata", "rb");

    if(out_fd == NULL) {
        perror("cpow-odata open fail");
 	    fclose(ctrl_fd);
	    fclose(in_fd);
        exit(EXIT_FAILURE);
    }

    devmem_fd = open("/dev/mem", O_RDWR | O_SYNC);

    if(devmem_fd < 0) {
        perror("devmem open");
        fclose(ctrl_fd);
	    fclose(in_fd);
        fclose(out_fd);
        exit(EXIT_FAILURE);
    }

    fpga_regs_map = (uint32_t*)mmap(NULL, HPS_TO_FPGA_SPAN, PROT_READ|PROT_WRITE, MAP_SHARED, devmem_fd, HPS_TO_FPGA_BASE);

    if(fpga_regs_map == MAP_FAILED) {
        perror("devmem mmap");
        close(devmem_fd);
        fclose(ctrl_fd);
	    fclose(in_fd);
        fclose(out_fd);
        exit(EXIT_FAILURE);
    }

    cpow_map = (uint32_t*)(fpga_regs_map + CPOW_BASE);

    start_time = time(NULL);                    //time in sec from Jan 1, 1970 

    fprintf(stat_fd, "POWdelay\n");

    for (int i = 0; i < hashes_to_process; i++) {

        gen_trans(transaction, TRANSACTION_LEN);

        rewind(in_fd);
        fwrite(transaction, 1, TRANSACTION_LEN, in_fd);
        fflush(in_fd);

        rewind(ctrl_fd);
        fwrite(&mwm, 1, 1, ctrl_fd);
        fread(&result, sizeof(result), 1, ctrl_fd);
        fflush(ctrl_fd);

        rewind(out_fd);
        fread(nonce_trits, 1, NONCE_LEN, out_fd);
        fflush(out_fd);

        nonce_trytes = trytes_from_trits(nonce_trits, 0, NONCE_LEN);

        hash_cnt = *(cpow_map + HASH_CNT_REG_OFFSET);
        tick_cnt_l = *(cpow_map + TICK_CNT_LOW_REG_OFFSET);
        tick_cnt_h = *(cpow_map + TICK_CNT_HI_REG_OFFSET);
        tick_cnt = tick_cnt_h;
        tick_cnt = (tick_cnt << 32) | tick_cnt_l;

        hrate = (float)hash_cnt / tick_cnt * 100000000;

        pow_delay = (float) tick_cnt / 100000000;

        printf("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");

        if (print_input) {
        
            transaction_trytes = trytes_from_trits(transaction, 0, TRANSACTION_LEN);

            printf("Input:\n");
            printf("%s\n", transaction_trytes);

            free(transaction_trytes);
        }


        printf("Hash no %d from %d\n", i, hashes_to_process);
        printf("Hash rate: %d hash/sec\n", hrate);
        printf("Nonce: %s\n", nonce_trytes);
        printf("POW time: %f sec\n", pow_delay);
        
        fprintf(stat_fd, "%f\n", pow_delay);

        if (print_hash) {

            for (int j = NONCE_OFFSET; j < TRANSACTION_LEN; j++)
                transaction[j] = nonce_trits[j - NONCE_OFFSET];    

            init_curl(&curl);
            absorb(&curl, transaction, TRANSACTION_LEN);
            squeeze(&curl, hash_trits, HASH_LENGTH);

            hash_trytes = trytes_from_trits(hash_trits, 0, HASH_LENGTH);
            printf("Hash: %s\n", hash_trytes);

            free(hash_trytes);
        }

        free(nonce_trytes);
    }

    printf("\n\nAll finish in %f min\n", (float)(time(NULL) - start_time)/60);

    fclose(stat_fd);
    fclose(in_fd);
    fclose(out_fd);
    fclose(ctrl_fd);

    result = munmap(fpga_regs_map, HPS_TO_FPGA_SPAN); 

    close(devmem_fd);

    if(result < 0) {
        perror("devmem munmap");
        exit(EXIT_FAILURE);
    }

}
   
