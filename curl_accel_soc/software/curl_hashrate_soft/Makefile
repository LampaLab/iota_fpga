TARGET = curl_hashrate_soft
DEPS = curl
CFLAGS = -static -g -Wall -std=gnu99
LDFLAGS = -g -Wall
CC = gcc
ARCH = arm

build: $(TARGET)

$(TARGET): $(TARGET).o $(DEPS).o
	$(CC) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	rm -f $(TARGET) *.a *.o *.~

