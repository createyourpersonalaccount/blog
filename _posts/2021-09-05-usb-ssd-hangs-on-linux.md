---
layout: post
title: USB SSD hangs on Linux
---

# Thanks to

I was helped by the friendly folks at [Libera.Chat](https://libera.chat/). A great network for computer-related discussions.

# The issue

I bought a new 250G [ssd](https://en.wikipedia.org/wiki/Solid-state_drive) that I wanted to use as data backup. After plugging it in, I wanted to run

~~~ sh
    sudo fdisk /dev/sdc
~~~

to format it and create a 32G partition. Unfortunately, the `fdisk` command would either hang right then and there or at a later stage when I tried to write out the partition with the `w` command.

# The cause

The cause turned out to be the [UAS](https://en.wikipedia.org/wiki/USB_Attached_SCSI) protocol. Hard drive manufacturers often do not implement it correctly and the `uas` Linux kernel module is then unable to communicate with the hard drive properly.

# The solution

## Diagnostics

First, let us verify that the issue has to do with the  `uas` module:

Unplug the usb ssd, run

``` sh
    journalctl --dmesg --follow
```

and then plug it in. In my case, one of the messages was `kernel: scsi host4: uas`, which indicates that the uas module is in effect. Moreover, I got

    kernel: usb 2-2: Product: SSD-PGU3-A
    kernel: usb 2-2: Manufacturer: BUFFALO

Now run `lsusb` to obtain the ID of the ssd:

    Bus 002 Device 002: ID 0411:02d0 BUFFALO INC. (formerly MelCo., Inc.) SSD-PGU3-A
    
The part we are interested in is given above by `0411:02d0`. Set a temporary shell variable,

``` sh
    ID=0411:02d0
```

## On a permanent environment

If you are trying to fix this issue on a permanent environment, use

```sh
    echo usb_storage quirks=$ID:u | sudo tee -a /etc/modprobe.d/usb_storage.conf
```

## On a live environment

On a live environment, such as a liveCD, use instead

```sh
    echo $ID:u | sudo tee /sys/module/usb_storage/parameters/quirks
```

# Conclusion

What we did was inform the `usb_storage` kernel module that when handling the usb device with id `$ID`, it should not load up the `uas` module. The UAS protocol is useful because it is a standarized and efficient way to communicate with a usb hard drive. When manufacturers do not follow the UAS protocol, the only hope is that the `uas` module developers have created patches for the specific mishandling of the manufacturer. Otherwise, we have to disable the `uas` module for the specific device and default to [USB Mass Storage](https://en.wikipedia.org/wiki/USB_mass_storage_device_class), which is slower.
