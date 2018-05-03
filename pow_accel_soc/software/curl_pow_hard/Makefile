TARGET = curl_pow_hard
DEPS = converter
CFLAGS = -static -g -Wall -std=gnu99 -fsigned-char -fPIC
LDFLAGS = -g -Wall
CC = gcc
ARCH = arm

build: $(TARGET)

$(TARGET): $(TARGET).o  $(DEPS).o
	$(CC) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	rm -f $(TARGET) *.a *.o *.~

