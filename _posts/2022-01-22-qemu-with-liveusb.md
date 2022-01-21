---
layout: post
title: How to use QEMU with a live USB
---

# Create a disk image for storage

We create a virtual hard drive named `vm.img` of size 10G.

```bash
qemu-img create -f raw vm.img 10G
```

The file format is `raw`, which has few features but offers performance.

# Boot from a live USB

We will boot on a virtual machine with two hard drives, setting the first to the live USB. We use 2G of RAM memory and assume that the unmounted live USB lies in `/dev/sdb`

```bash
qemu-kvm -m 2G -drive file=/dev/sdb,format=raw,snapshot=on -drive file=vm.img,format=raw
```

This command may produce the error: `Could not open '/dev/sdb': Permission denied`. There are several methods to deal with this, we detail two:

- Run the command as `sudo`, accepting the danger of running QEMU as root.
- Add your user to the group permissions for `/dev/sdb`:
  - First, find the group by using `ls -l /dev/sdb | cut -d " " -f 4`, which for me is `disk`.
  - Then add the user to the listed group above (the method varies depending on the distribution).
  - Log in again using `su -l <user>` to refresh the groups the user is in.
  - Execute QEMU and finish the installation.
  - Remove the user from the `disk` group (the method varies depending on the distribution).

Complete installation, shut down and then simply exit out of QEMU.

# Boot from the virtual storage

Now you can boot from your disk file.

```bash
qemu-kvm -m 2G -drive file=vm.img,format=raw
```
