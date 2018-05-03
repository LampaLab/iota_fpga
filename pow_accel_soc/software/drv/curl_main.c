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

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include "curl_drv.h"

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Ievgen Korotkyi");
MODULE_DESCRIPTION("Driver for IOTA POW hardware accelerator");
MODULE_VERSION("0.1");

static int ibuf_size = 65536;
static int obuf_size = 512;

static struct of_device_id curl_of_match[] = {
    {
        .compatible = "lamp,cpow"
    },
    { /* end of table */ }
};

/*****************************************************************************/

irqreturn_t curl_isr(int irq, void *dev_id)
{
	struct fpga_curl_dev *curl_dev = dev_id;

    printk( KERN_INFO "Get interrupt\n" );

    curl_dev->write_done = 1;

    wake_up_interruptible(&curl_dev->data_queue);
        
	return IRQ_HANDLED;
}

/*****************************************************************************/

int fpga_add_buffs(struct fpga_curl_dev *curl_dev, uint32_t isize, uint32_t osize)
{
    void *src_addr;
    dma_addr_t src_dma_addr;

    void *dst_addr;
    dma_addr_t dst_dma_addr;

    // Alloc ibuf for DMA

    src_addr = dmam_alloc_coherent(&curl_dev->pdev->dev, isize, &src_dma_addr, GFP_KERNEL);

	if (unlikely(NULL == src_addr)) {
		printk(KERN_ERR "Failed to allocate ibuf\n");
		return -ENOMEM;
	}

	if (dma_mapping_error(&curl_dev->pdev->dev, src_dma_addr)) {
		printk(KERN_ERR "Failed to map ibuf\n");
		curl_dev->ibuf = NULL;
		return -ENOMEM;
	}

    curl_dev->ibuf = src_addr;
    curl_dev->isize = isize;
    
    //printk( KERN_INFO "Add ibuf, addr=0x%px, dma_addr=0x%px\n", src_addr, (void *)src_dma_addr);  

    // Alloc obuf for DMA

    dst_addr = dmam_alloc_coherent(&curl_dev->pdev->dev, osize, &dst_dma_addr, GFP_KERNEL);

    if (unlikely(NULL == dst_addr)) {
		printk(KERN_ERR "Failed to allocate obuf\n");
		return -ENOMEM;
	}

    if (dma_mapping_error(&curl_dev->pdev->dev, dst_dma_addr)) {
		printk(KERN_ERR "Failed to map ibuf\n");
		curl_dev->obuf = NULL;
		return -ENOMEM;
	}

    curl_dev->obuf = dst_addr;
    curl_dev->osize = osize;

    //printk( KERN_INFO "Add obuf, addr=0x%px, dma_addr=0x%px\n", dst_addr, dst_dma_addr);

    iowrite32(src_dma_addr / 16, curl_dev->regs + SRC_BUF_ADDR_REG_OFFSET);
    iowrite32(dst_dma_addr / 16, curl_dev->regs + DST_BUF_ADDR_REG_OFFSET);
       
	return 0;
}

/*****************************************************************************/

static int curl_probe(struct platform_device *pdev)
{
    int ret_val = -EBUSY;
    struct fpga_curl_dev *curl_dev;
    struct resource *r = 0;

    printk(KERN_INFO "Curl POW Driver Probe enter!\n");

    r = platform_get_resource(pdev, IORESOURCE_MEM, 0);

    if(r == NULL) {
        printk(KERN_ERR "IORESOURCE_MEM (reg space) for Curl dev doesn't exist\n");
        goto bad_exit_return;
    }

    curl_dev = devm_kzalloc(&pdev->dev, sizeof(struct fpga_curl_dev), GFP_KERNEL);

    if (!curl_dev) {
        printk(KERN_ERR "Failed alloc mem for dev struct in Curl POW Drviver Probe\n");
        ret_val = -ENOMEM;
        goto bad_exit_return;
    }

    curl_dev->regs = devm_ioremap_resource(&pdev->dev, r);

    //printk( KERN_INFO "curl_dev->regs=0x%px\n", curl_dev->regs);

    if(IS_ERR(curl_dev->regs)) {
        printk(KERN_ERR "Regs ioremap failed in Curl POW Driver Probe\n");
        ret_val = PTR_ERR(curl_dev->regs);
        goto bad_exit_return;
    }

    iowrite32(0x3FFF, curl_dev->regs + MWM_MASK_REG_OFFSET);

	curl_dev->pdev = pdev;

    // Alloc and reg interrupt
    curl_dev->irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
    //printk( KERN_INFO "IRQ from dts: %u\n", curl_dev->irq );

    // Alloc DMA buffs
    ret_val = fpga_add_buffs(curl_dev, ibuf_size, obuf_size);

    if (ret_val) {
	    printk( KERN_ERR "Failed to initialize io buffers\n");
	    goto bad_exit_return;
    }

    curl_dev->ctrl_dev = curl_ctrl_dev;

    ret_val = misc_register(&curl_dev->ctrl_dev);

    if(ret_val != 0) {
        pr_info("Couldn't register ctrl dev in Curl POW Driver Probe :(");
        goto bad_exit_return;
    }

    curl_dev->idata_dev = curl_idata_dev;
    
    ret_val = misc_register(&curl_dev->idata_dev);
    
    if(ret_val != 0) {
        pr_info("Couldn't register in dev in Curl POW Driver Probe :(");
        goto ctrl_exit;
    }

    curl_dev->odata_dev = curl_odata_dev;

    ret_val = misc_register(&curl_dev->odata_dev);
    
    if(ret_val != 0) {
        pr_info("Couldn't register out dev in Curl POW Driver Probe :(");
        goto idev_exit;
    }

    init_waitqueue_head(&curl_dev->data_queue);

    ret_val = request_irq(curl_dev->irq, curl_isr, IRQF_SHARED, DRV_NAME, curl_dev);

    if (ret_val) {
		printk(KERN_ERR "Cannot allocate interrupt %d\n", curl_dev->irq);
		goto odev_exit;
	}

    platform_set_drvdata(pdev, (void*)curl_dev);

    printk(KERN_INFO "Curl POW Driver Probe exit success\n");

    return 0;

odev_exit:
    misc_deregister(&curl_dev->odata_dev);
	curl_dev->odata_dev.this_device = NULL;

idev_exit:
    misc_deregister(&curl_dev->idata_dev);
	curl_dev->idata_dev.this_device = NULL;

ctrl_exit:
    misc_deregister(&curl_dev->ctrl_dev);
	curl_dev->ctrl_dev.this_device = NULL;

bad_exit_return:
    printk(KERN_ERR "Curl POW Driver Probe bad exit :(\n");
    return ret_val;
}

/*****************************************************************************/

static int curl_remove(struct platform_device *pdev)
{
    struct fpga_curl_dev *curl_dev;

    curl_dev = (struct fpga_curl_dev*)platform_get_drvdata(pdev);
    
    printk(KERN_INFO "curl_remove enter\n");

    if (curl_dev) {

        if (curl_dev->ctrl_dev.this_device) {
	        misc_deregister(&curl_dev->ctrl_dev);
            curl_dev->ctrl_dev.this_device = NULL;
        }

        if (curl_dev->idata_dev.this_device) {
	        misc_deregister(&curl_dev->idata_dev);
            curl_dev->idata_dev.this_device = NULL;
        }

        if (curl_dev->odata_dev.this_device) {
	        misc_deregister(&curl_dev->odata_dev);
            curl_dev->odata_dev.this_device = NULL;
        }

        free_irq(curl_dev->irq, curl_dev);

        platform_set_drvdata(pdev, NULL);
    }    

    printk(KERN_INFO "curl_remove exit\n");
    return 0;
}

/*****************************************************************************/

MODULE_DEVICE_TABLE(of, curl_of_match);

static struct platform_driver curl_platform = {
    .probe = curl_probe,
    .remove = curl_remove,
    .driver = {
        .name = DRV_NAME,
        .owner = THIS_MODULE,
        .of_match_table = of_match_ptr(curl_of_match),
    },
};

/*****************************************************************************/

static int __init curl_drv_init(void)
{
    int ret_val = 0;
    printk(KERN_INFO "Initializing Curl POW Driver module\n");
    ret_val = platform_driver_register(&curl_platform);
    if(ret_val != 0) {
        printk(KERN_ERR "platform_driver_register returned %d\n", ret_val);
        return ret_val;
    }
    printk(KERN_INFO "Curl POW Driver module successfully initialized!\n");
    return 0;
}

/*****************************************************************************/

static void __exit curl_drv_exit(void)
{
    platform_driver_unregister(&curl_platform);
    printk(KERN_INFO "Curl POW Driver module exit\n");	
}

/*****************************************************************************/


module_init(curl_drv_init);
module_exit(curl_drv_exit);
