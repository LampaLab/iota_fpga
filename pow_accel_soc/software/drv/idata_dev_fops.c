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

#include "curl_drv.h"

static int curl_idata_dev_open(struct inode *inode, struct file *filp)
{
    printk(KERN_DEBUG "curl_idata_dev_open\n");
	return 0;
}

static int curl_idata_dev_release(struct inode *inode, struct file *filp)
{
    printk(KERN_DEBUG "curl_idata_dev_release\n");
    return 0;
}

static ssize_t curl_idata_dev_write(struct file *filp, const char __user *buf, size_t count, loff_t *f_pos)
{
    struct fpga_curl_dev *curl_dev;

    loff_t maxpos;

    curl_dev = container_of(filp->private_data, struct fpga_curl_dev, idata_dev);
        
    maxpos = curl_dev->isize;

    printk(KERN_DEBUG "curl_idata_dev_write begin\n");

    if (*f_pos > maxpos)
        return -EINVAL;
    
    if (*f_pos == maxpos)
        return -ENOSPC;

    if (*f_pos + count > maxpos)
        count = maxpos - *f_pos;

    if (copy_from_user(curl_dev->ibuf + *f_pos, buf, count)) {
        printk(KERN_ERR "Fail copy_from_user in curl_idata_dev_write :(\n");
        return -EFAULT;
    }

    *f_pos += count;

    printk(KERN_DEBUG "curl_idata_dev_write end\n");

    return count;
}

static ssize_t curl_idata_dev_read(struct file *filp, char __user *buf, size_t count, loff_t *f_pos)
{
    printk(KERN_DEBUG "curl_idata_dev_read\n");
    return -EINVAL;
}

static loff_t curl_idata_dev_lseek (struct file *filp, loff_t off, int whence)
{
    struct fpga_curl_dev *curl_dev;
	
    loff_t newpos;
    loff_t maxpos;

    curl_dev = container_of(filp->private_data, struct fpga_curl_dev, idata_dev);
    
    maxpos = curl_dev->isize;

    printk(KERN_DEBUG "curl_idata_dev_lseek begin\n");

    switch(whence) {

    case SEEK_SET:
        newpos = off;
        break;

    case SEEK_CUR:
        newpos = filp->f_pos + off;
        break;

    case SEEK_END:
        newpos = maxpos;
        break;
    
    default: 
        return -EINVAL;
    }

    if (newpos < 0) 
        return -EINVAL;

    if (newpos > maxpos)
        newpos = maxpos;

    filp->f_pos = newpos;

    printk(KERN_DEBUG "curl_idata_dev_lseek end\n");

    return newpos;  
}

const struct file_operations curl_idata_dev_fops = {
	.owner   = THIS_MODULE,
	.open    = curl_idata_dev_open,
	.release = curl_idata_dev_release,
	.write   = curl_idata_dev_write,
    .read    = curl_idata_dev_read,
    .llseek  = curl_idata_dev_lseek,
};

