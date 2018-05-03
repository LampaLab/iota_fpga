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

#ifndef _CURL_H
#define _CURL_H

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>
#include <linux/miscdevice.h>
#include <linux/of_irq.h>
#include <linux/phy.h>
#include <linux/interrupt.h>

#define DRV_NAME "curl"

#define MAIN_CTRL_REG_OFFSET        0
#define SRC_BUF_ADDR_REG_OFFSET     4
#define DST_BUF_ADDR_REG_OFFSET     8
#define MWM_MASK_REG_OFFSET         12
#define HASH_CNT_REG_OFFSET         16
#define TICK_CNT_LOW_REG_OFFSET     20
#define TICK_CNT_HI_REG_OFFSET      24

// Curl drv odata dev fops
extern const struct file_operations curl_odata_dev_fops;

// Curl drv idata dev fops
extern const struct file_operations curl_idata_dev_fops;

// Curl drv ctrl dev fops
extern const struct file_operations curl_ctrl_dev_fops;

static const struct miscdevice curl_ctrl_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name  = "cpow-ctrl",
	.fops  = &curl_ctrl_dev_fops,
};

static const struct miscdevice curl_idata_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name  = "cpow-idata",
	.fops  = &curl_idata_dev_fops,
};

static const struct miscdevice curl_odata_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name  = "cpow-odata",
	.fops  = &curl_odata_dev_fops,
};

struct fpga_curl_dev {
    struct platform_device *pdev;

    struct miscdevice ctrl_dev;	
    struct miscdevice idata_dev;
    struct miscdevice odata_dev;

    wait_queue_head_t data_queue;

    int write_done;

    int irq;

    int idata_len;

    void *ibuf;
    uint32_t isize;
    void *obuf;
    uint32_t osize;    

    void __iomem *regs;  
};

#endif // _CURL_H
