TARGET = pow_performance_test
DEP1 = converter
DEP2 = curl
CFLAGS = -static -g -Wall -std=gnu99 -fsigned-char -fPIC
LDFLAGS = -g -Wall
CC = gcc
ARCH = arm

build: $(TARGET)

$(TARGET): $(TARGET).o  $(DEP1).o $(DEP2).o
	$(CC) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean

clean:
	rm -f $(TARGET) *.a *.o *.~

