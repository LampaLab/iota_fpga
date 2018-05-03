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
#include "converter.h"

#define MAX_TRYTE_LENGTH 3159

#define HINTS                                                                  \
  "### CCURL DIGEST ###\nUsage:\n\tccurl-cli [TRYTES (maxlength: %d)] \n\techo "  \
  "TRYTES | ccurl-cli \n"

int main(int argc, char* argv[]) 
{
    FILE *ctrl_fd = 0;
    FILE *in_fd = 0;
    FILE *out_fd = 0;

    int result;
    
    char* itrytes = NULL;
    char* itrits = NULL;

    char  otrits[HASH_LENGTH];
    char* otrytes = NULL;


    size_t itrytelen = 0;
    size_t itritlen = 0;

    if (argc > 1) {
        itrytes = argv[1];
        itrytelen = strnlen(itrytes, MAX_TRYTE_LENGTH);
        itritlen = 3*itrytelen;
    } else {
        fprintf(stderr, HINTS, MAX_TRYTE_LENGTH);
        return 1;
    }

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

    itrits = trits_from_trytes(itrytes, itrytelen < MAX_TRYTE_LENGTH ? itrytelen : MAX_TRYTE_LENGTH);

    fwrite(itrits, 1, itritlen, in_fd);
    fflush(in_fd);

    fwrite(&itritlen, 2, 1, ctrl_fd);
    fread(&result, sizeof(result), 1, ctrl_fd);
    fflush(ctrl_fd);

    fread(otrits, 1, HASH_LENGTH, out_fd);

    otrytes = trytes_from_trits(otrits, 0, HASH_LENGTH);

    printf("\nHASH: %s\n", otrytes);

    if (otrytes)
        free(otrytes);

    if (itrits)
        free(itrits);

    fclose(in_fd);
    fclose(out_fd);
    fclose(ctrl_fd);

    exit(EXIT_SUCCESS);
}

