---
layout: post
title: How to use QEMU with a live USB
---

# Create a disk image for storage

We create a virtual hard drive named `vm.img` of size 20G.

```bash
qemu-img create -f raw vm.img 20G
```

The file format is `raw`, which has few features but offers performance.

# Boot from a live USB

We will boot on a virtual machine with two hard drives, setting the first to the live USB. We use 2G of RAM memory and assume that the unmounted live USB lies in `/dev/sdb`

```bash
qemu-kvm -m 2G -drive file=/dev/sdb,format=raw,snapshot=on -drive file=vm.img,format=raw
```

This command may produce the error: `Could not open '/dev/sdb': Permission denied`. We need read permissions on `/dev/sdb`. There are several methods to deal with this, the simplest is to run the command as `sudo`, accepting the danger of running QEMU as root. Others are detailed in the blog post [Accessing a restricted file on Linux and BSD](https://createyourpersonalaccount.github.io/blog/2022/01/23/accessing-a-restricted-file.html).

Complete installation, shut down and then simply exit out of QEMU.

# Boot from the virtual storage

Now you can boot from your disk file.

```bash
qemu-kvm -m 2G -drive file=vm.img,format=raw
```

If available, it is advisable to enable kvm by passing `-enable-kvm` to `qemu-kvm`. This will speed up emulation significantly.
