PWD  := $(shell pwd)
KDIR ?= ../linux-socfpga

obj-m := cpowdrv.o
cpowdrv-objs := curl_main.o ctrl_dev_fops.o idata_dev_fops.o odata_dev_fops.o

default:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) ARCH=arm M=$(PWD) clean
