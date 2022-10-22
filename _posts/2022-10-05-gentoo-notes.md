---
layout: post
title: Gentoo notes
---

# Gentoo notes

Here I keep track of my own personal notes on installing and maintaining [Gentoo Linux](https://www.gentoo.org/). It is not yet in a state where it will be much useful to others.

## Install Gentoo on amd64 with OpenRC

### Obtaining the files

1. Download the installation media and burn to a USB.
2. Download the stage3 file and store in another USB.

### Booting the USB

1. Connect the Ethernet cable to the computer.
2. Boot the USB.

### Preparing the disk

We will use ext4 as the filesystem. We assume the disk is /dev/sda with 16G of RAM. (same as swap space.)

1. `fdisk /dev/sda`
2. Use the following key sequence, each time pressing enter in between:

       g n 1 +256M t 1 n 2 +16G t 2 19 n 3 RET RET w

3. `mkfs.vfat -F 32 /dev/sda1`
4. `mkfs.ext4 /dev/sda3`
5. `mkswap /dev/sda2`
6. `swapon /dev/sda2`
7. `mount /dev/sda3 /mnt/gentoo`

### Installing stage3

1. Verify the date with the `date` command. It should be accurate to within a second in UTC time. The time may be obtained from the internet using `ntpd -q -g`.
2. `cd /mnt/gentoo`
3. Copy the stage3 tarball to current directory.
4. `tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner`

#### Compile options

1. `nano /mnt/gentoo/etc/portage/make.conf`
2. Example contents may be

       COMMON_FLAGS="-march=native -O2 -pipe"
       MAKEOPTS="-j8"

The `MAKEOPTS` flag decides on the number of parallel

#### Select mirrors

1. `mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf`
2. `mkdir --parents /mnt/gentoo/etc/portage/repos.conf`
3. `cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf`
4. `cp --dereference /etc/resolv.conf /mnt/gentoo/etc/`

#### Mount the filesystems

1. `mount --types proc /proc /mnt/gentoo/proc`
2. `mount --rbind /sys /mnt/gentoo/sys`
3. `mount --rbind /dev /mnt/gentoo/dev`
4. `mount --bind /run /mnt/gentoo/run`

#### Enter the new environment

1. `chroot /mnt/gentoo /bin/bash`
2. `source /etc/profile`
3. `export PS1="(chroot) ${PS1}"`
4. `mount /dev/sda1 /boot`

#### Update ebuilds

1. `emerge --sync --quiet`
2. `eselect news read`
3. `eselect profile list`
4. `eselect profile set <number>`
5. `emerge --ask --verbose --update --deep --newuse @world`

#### Configuring the USE variable

View it with `emerge --info | grep ^USE`. A full description is found in `/var/db/repos/gentoo/profiles/use.desc`. Edit `/etc/portage/make.conf`, for example:

    USE="doc examples -bluetooth -cdr -dvd -dvdr -intel"

If `X` is desired, add it and add also `xft` for modern fonts.

#### Configuring the ACCEPT_LICENSE variable

View it with `portageq envvar ACCEPT_LICENSE`. Edit `/etc/portage/make.conf`, for example:

    ACCEPT_LICENSE="-* @FREE @BINARY_REDISTRIBUTABLE"

#### Timezone

1. Find the timezone under `ls /usr/share/zoneinfo`
2. Write in `/etc/timezone`, e.g.:

       echo "Europe/Brussels" > /etc/timezone

3. `emerge --config sys-libs/timezone-data`

#### Locale generation & selection

1. `nano /etc/locale.gen`
2. Add

       en_US ISO-8859-1
       en_US.UTF-8 UTF-8

3. `locale-gen`
4. `eselect locale list`
5. `eselect locale set <number>`
6. `env-update && source /etc/profile && export PS1="(chroot) ${PS1}"`

### Configuring the kernel with genkernel

1. `emerge --ask sys-kernel/linux-firmware`
2. `emerge --ask sys-kernel/gentoo-sources`
3. `eselect kernel list`
4. `eselect kernel set <number>`
5. `emerge --ask sys-kernel/genkernel`
6. `nano /etc/fstab`

       /dev/sda1	/boot	ext4	defaults	0 2

7. `genkernel all`
8. Write down the names of the kernel and initrd, displayed with

       ls /boot/vmlinu* /boot/initramfs*

### Configuring the system

#### Edit fstab

1. `nano /etc/fstab`

       /dev/sda1   /boot        vfat    defaults,noatime     0 2
       /dev/sda2   none         swap    sw                   0 0
       /dev/sda3   /            ext4    noatime              0 1

#### Network

1. `nano /etc/conf.d/hostname`

       hostname="tux"

2. `emerge --ask net-misc/dhcpcd`
3. `rc-update add dhcpcd default`
4. `rc-service dhcpcd start # may error if dhcpcd is already running`

#### Account management

Set up root password with `passwd`.

Set up a new account with `useradd -m -G audio,video,users,wheel -s /bin/bash <username>`. These are the right groups for that account to launch Xorg later with elogind and have access to `su -l root`.

Accounts can be modified with `usermod`.

#### System logger

1. `emerge --ask app-admin/sysklogd`
2. `rc-update add sysklogd default`

#### Install a cron daemon

1. `emerge --ask sys-process/cronie`
2. `rc-update add cronie default`

#### File indexing

1. `emerge --ask sys-apps/mlocate`

#### Time synchronization

1. `emerge --ask net-misc/chrony`
2. `rc-update add chronyd default`

#### Wireless tools

1. `emerge --ask net-wireless/iw net-wireless/wpa_supplicant`

### Bootloader

1. `emerge --ask --verbose sys-boot/grub`
2. `grub-install --target=x86_64-efi --efi-directory=/boot`
3. Check that the names of the kernel and initrd are mentioned under `ls /boot`
4. `grub-mkconfig -o /boot/grub/grub.cfg`

### Reboot

1. `exit`
2. `cd`
3. `umount -l /mnt/gentoo/dev{/shm,/pts,}`
4. `umount -R /mnt/gentoo`
5. `reboot`

## encrypted btrfs with hardened nomultilib selinux profile

It is recommended to follow the ext4-unencrypted steps above at least once before attempting this. The steps below are simply adding to the instructions given above.

### Preparing the disk (extended)

At the _Preparing the disk_ step, use `gdisk` to create a `256M` EFI boot partition and make another partition, a linux filesystem, with the rest of the disk. Then use `cryptsetup luksFormat` to make the latter a luks-encrypted partition, and then `cryptsetup open` it. Then use `make.btrfs` in the mapper to create a btrfs filesystem, and use `btrfs` to create three subvolumes; `root, swap, home`. Follow the [Btrfs documentation for a swapfile](https://btrfs.readthedocs.io/en/latest/Swapfile.html). Finally, mount the three subvolumes using the `mount` option `-o subvol=...` where `...` is each of `root, swap, home`, and `swapon` the swapfile.

### Configuring the kernel with genkernel (extended)

Use genkernel with the `--luks` parameter when compiling the kernel and initramfs.

### Edit fstab (extended)

The `/etc/fstab` file should use the PARTUUID for `/boot` and the `UUID` corresponding to the mapper partitions for `/, /swap, /home`, obtained from the `blkid` command, for example:

    UUID=...		/		btrfs	defaults,noatime,subvol=root	0 0
    PARTUUID=...	/boot	vfat	defaults,noatime				0 2
    UUID=...		/home	btrfs	defaults,noatime,subvol=home	0 0
    UUID=...		/swap	btrfs	defaults,noatime,subvol=swap	0 0
    /swap/swapfile	none	swap	defaults						0 0

### Bootloader (extended)

Install grub with the `device-mapper` USE flag enabled, e.g. add it in [`/etc/portage/package.use`](https://wiki.gentoo.org/wiki//etc/portage/package.use).

After installing grub, edit `/etc/defaults/grub` to have the second partition UUID specified as

    GRUB_CMDLINE_LINUX="crypt_root=UUID=<my-root-uuid-here>"

At the end, if `/mnt/gentoo` can't be unmounted because it is busy, you might need to `swapoff` the swapfile.

## updating the kernel

When updating the kernel, use

    eselect kernel list
    eselect kernel set <number>

This switches the kernel symlink `/usr/src/linux` to the newest version.

Then copy the configuration file from the old kernel, somewhere under `/usr/src/linux-*/.config`, to `/usr/src/linux`.

Then run `make oldconfig` under `/usr/src/linux` to configure any options that are new.

Finally run `make -j12` and then `make modules_install` and finally `make install`.

Update initramfs with `genkernel --kernel-config=/usr/src/linux-target/.config initramfs` where `linux-target` is the kernel you're compiling. (Do not use `/usr/src/linux/.config` here; it can cause data loss).

The last thing is to update GRUB, so run `grub-mkconfig -o /boot/grub/grub.cfg`.

## OpenRC

To show the OpenRC registered scripts, use

    rc-update show

With `-v`, all are shown. It is also possible to use `rc-status`.
    
To add `elogind` to `boot`, use

    rc-update add elogind boot

To restart a service such as cronie, use

    rc-service cronie restart

To stop and remove a service, use

    rc-service my_service stop
    rc-update delete my_service my_runlevel

For more info, see https://wiki.gentoo.org/wiki/OpenRC_to_systemd_Cheatsheet

## portage

View the world contents with

    cat /var/lib/portage/world

View information about a package with

    emerge -s package-name

Find which package a file belongs to

    portageq owners / /path/to/file

Find reverse-dependencies with

    emerge -cvp package

Direct dependencies may be listed with

    emerge -evp package

List USE flags of a package with

    emerge -vp package

To update the system, use

    emaint sync -a
    emerge -auND @world

The `-u` flag updates to recent version; the `-N` flag is to include packages whose USE flags have changed and `-D` makes a deep update of dependencies.

To view the metadata of a Gentoo repo package, look at the file

    /var/db/repos/gentoo/metadata/md5-cache/category/package_name

## i3 configuration

1. `cp /etc/i3/config ~/.config/i3/config`
2. Delete the `bindsym` line relating to `exit` and replace with

        mode "exit? [y/n]" {
            bindsym y exec i3-msg exit
            bindsym n mode "default"
        }
        bindsym Mod1+Shift+e mode "exit? [y/n]"
3. Then reload the configuration with `Mod1+Shift+c`.


## rxvt-unicode

Make sure to install with the `xfg` USE flag; it allows for modern fonts as opposed to the old X core fonts.

Find the system fonts with

    fc-list | sort

The final phrase is the name of the font, for example `Liberation Mono`. To use this font with `.Xresources`, use

    URxvt.font: xft:Liberation Mono

It is also possible to use `xft:monospace` and then the font selected by `fontconfig` and matching with `fc-match monospace` will be used.

## Touchpad

Sometimes enabling `libinput` and `synaptics` to `INPUT_DEVICES` is not enough; also follow https://wiki.gentoo.org/wiki/Synaptics which recommends some kernel parameters.

## Working internet (WiFi and Ethernet)

If `dhcpcd` is installed, Ethernet should work by plugging in the cable. It uses dhcpcd directly.

WiFi has a lot of options. We will use the following combination: `dhcpcd`, `wpa_supplicant`, `netifrc`. Netifrc is a network manager, the default under Gentoo with OpenRC. `wpa_supplicant` contains the algorithms for WiFi data transfer.

Edit `/etc/wpa_supplicant/wpa_supplicant.conf` to contain (whitespace-sensitive around assignment):

    ctrl_interface=/var/run/wpa_supplicant
    ctrl_interface_group=0
    ap_scan=1

Then run `wpa_passphrase "MyNetworkSSID" >> /etc/wpa_supplicant/wpa_supplicant.conf` and enter the WiFi passphrase. Edit `MyNetworkSSID` to your network SSID. This completes the `wpa_supplicant` configuration.

Now to configure netifrc. First run `ip link` and grab the wireless interface, such as `wlan0`. Edit `/etc/conf.d/net` to contain:

    modules_wlan0="wpa_supplicant"
    config_wlan0="dhcp"

Here, replace `wlan0` with your wireless interface.

Then, create a soft link with `ln -s /etc/init.d/net.lo /etc/init.d/net.wlan0`, again changing `wlan0` to the wireless interface.

Finally, start the service with

    rc-update net.wlan0 start

and add it to start at boot with

    rc-update add net.wlan0 default

## sysklogd logger

A program can generate a log message using `syslog(3)`. The utility `logger` can generate messages in the command line. System logs are found under `/var/log/`, as configured in `/etc/syslog.conf` and other configuration files.

Note that not all programs use syslog; some user their own custom log files, and some of them are found under `/var/log/`. The file `/var/log/syslog` captures all sysklogd messages.

By default `syslogd` reads messages from `/dev/log` and `/dev/kmsg`, as well as an Internet socket (if specified) in `/etc/services`. See `man 8 syslogd` and `man 5 syslog.conf`.

The format of `syslog.conf` is somewhat simple: there are two parts separated by a dot, the facility and the severity. Facility examples are `kern, user, mail`, and there's 7 severities in decreasing order of importance: `emergency, alert, critical, error, warning, notice, info, debug`. 

The filter rules use the symbol set `*,!=;`. For example:

    *.warning              # Capture everything at least as important as a warning (inclusive)
    mail.!=warning         # Capture every message from mail except warning
    kern,mail.!alert       # Capture every message from kernel or mail less important than an alert (exclusive)
    kern.=alert;mail.=info # Capture kernel alert and mail info messages

The filepath that follows the rule is where the messages are written. If a file path is preceded by a `-`, the messages are not synced to the file.

Optionally, there is the option of specifying the format after the filepath, such as `;RFC5424`, but by default it is `;RFC3164`. Finally there's a `secure_mode 0-2` line, that specifies whether syslog messages are remotely received or sent.

### Configuration

- `/etc/conf.d/syslogd-` Gentoo's config file for `/etc/init.d/sysklogd` daemon. See `man syslogd` for options.
- `/etc/syslog.conf-` Global (system wide) configuration file. See `syslog.conf(5)` for more information.
- `/etc/syslog.d/*.conf-` Conventional sub-directory of `.conf` files read by `syslogd`.
- `/etc/syslog.d/10-remote-logging.conf-` Conventional filename for additional configuration rules.

### Log a mock message

Use

    logger -t test my syslog test message
    tail /var/log/messages

## cron

Each line in a "crontab" file is specified as follows:

    <minute> <hour> <day> <month> <day of week>

There are ranges with step such as `1-6/2` which mean `1,3,5`. When the asterisk `*` is specified in the first four fields, it means for each; the final field is ignored.

With cronie, the following commands can be used

- `crontab -l`, list cron jobs
- `crontab -e`, edit a crontab
- `crontab -d <user>`, remove crontab
- `crontab <file>`, new crontab

### cronie

To have cronie run SSD-trim operations once a week under all drives mentioned in fstab, insert the following script, called `trim_drive.sh` under `/etc/cron.weekly/`:

    #!/bin/sh
    fstrim --fstab

Finally set `chmod ug+x /etc/cron.weekly/trim_drive.sh` on the script, to give it owner & group execution permissions.

This script is loaded by cronie, who runs anacron every minute, which checks `/etc/anacrontab` and confirms that the files listed under there have ran as they should. In particular, it contains pre-configured daily, weekly, and monthly directories for sh scripts.

### logrotation

To enable log rotation, use the script

    #!/bin/sh
    
    for x in kern.log messages syslog auth.log
        mv -f "/var/log/${x}" "/var/log/${x}.old"
    done

saved under `/etc/cron.monthly/logrotate.sh` and with the execution bit set via `chmod ug+x /etc/cron.monthly/logrotate.sh`.

## portage

The Gentoo ebuild repository is a collection of _ebuilds_. The local clone resides in `/var/db/repos/gentoo`. In addition, the repository includes _profiles_, which define `USE` flags and other variables in `make.conf`, as well as the `@system` set. Finally, they contain _news items_.

Another repository, community-maintained, is GURU.

_Package sets_ define the base system, called `@system` and those installed by users, called `@selected-packages`. The `@world` set is the union of `@selected, @system, @profile`. Another important set is `@security`.

Updating the ebuilds repos is important:

    emaint sync -a

To search use

    emerge --search pdf                    # search title
    emerge --searchdesc pdf                # search description

To install software, use

    emerge --ask app-office/gnumeric       # same as -a
    emerge --pretend gnumeric              # same as -p
    emerge --pretend --verbose gnumeric    # same as -vp; additionally shows USE flags
    emerge --fetchonly gnumeric

To obtain documentation, enable `USE=doc emerge gnumeric`. List the documentation files with

    equery files --filter=doc gnumeric

To remove software, use

    emerge --deselect gnumeric

To update software, pulling from local ebuild repos, use

    emerge --update --deep --newuse @world
    emerge --ask --depclean                 # clean up unneeded dependencies

To query Portage-specific env variables, use `portageq`.

To update the configuration of software after software update, use `dispatch-conf`.

### Important files:

- `/etc/portage/repos.conf`, ebuild repositories (remote and local) configuration
- `/etc/portage/package.mask`, rules for ignoring specific packages specific repositories
- `/etc/portage/package.mask`, rules for undoing certain parts of the 'ignore' rules
- `/usr/share/portage/config/make.globals` file contains default configuration values
- `/var/db/repos/`, default directory for local ebuild repos
- `/var/db/repos/gentoo/metadata/timestamp.chk`, gentoo repo last sync time
- `/var/lib/portage/world`, the user-installed packages; the packages of `@selected-packages`.

### License

Licenses are stored in `/var/db/repos/gentoo/licenses/`, and license groups in `/var/db/repos/gentoo/profiles/license_groups`.

They can be specified globally at `/etc/portage/make.conf`, or per-package in `/etc/portage/package.license`.

The `ACCEPT_LICENSE` variable can also be used to specify licenses. 

### Slots, virtuals

A package can have many versions in a system; each is a _SLOT_.

A virtual package, say `virtual/logger` can have exclusive dependencies, allowing for concrete loggers such as `sysklogd` and `metalogd`. A package that requires a logger can simply depend on the virtual package.

## The hard drive

For the purpose of this subsection, the hard drive is divided into logical blocks of 512 byte size. The first block contains a "protective" MBR, which is a header that older BIOS hardware will recognize as a full disk of unidentified type. The second block contains the primary GPT header, and blocks 3 to 34 contain partition entries (known as "partition table"), with the rest of the disk containing the partitions themselves. The entire GPT header is copied at the end of the disk as well (known as "secondary"), for backup reasons, in case the primary is corrupted. In fact, the number of partitions is variable with GPT, but 128 is used for compatibility reasons with Windows.

| Logical block | Purpose               |
|---------------|-----------------------|
| 0             | protective MBR        |
| 1             | Primary GPT header    |
| 2-*           | partition information |
| rest          | partitions            |
| end of disk   | secondary GPT header  |

# TODO

- [ ] Reconfigure kernel. Find which drivers are needed, which kernel modules are loaded.
- [ ] Configure Wayland
- [ ] Figure out selinux
- [ ] Make a list of important Gentoo files and directories.
- [ ] Use pipewire?
- [ ] Get a firewall
- [ ] Read the security handbook
- [ ] See https://wiki.gentoo.org/wiki/Keyboard_layout_switching to switch `Menu` key to `Control_R`.
- [ ] Proceed to install packages that make the system nice: gdb, emacs, firefox, etc...
- [ ] To enable debugging with gdb of installed packages, see https://wiki.gentoo.org/wiki/Debugging
- [ ] Write a Rust cron daemon? Or proof-check cronie.
- [X] Configure encrypted hard drives. See https://forums.gentoo.org/viewtopic-t-1110764-highlight-.html
- [X] Enable log rotation.
- [X] Learn more about cronie.
- [X] Enable SSD trimming.
- [X] Study Portage more. Figure out the `emerge` options for `-uND` for example.
- [X] Maintanance: How to perform security updates only? It is not worth it. But `glsa-check --list` can be used to check for issues after a sync.

# Questions

- [ ] How to use `dracut` to generate an initramfs?

    Before using `dracut`, maybe I can just use
    
        genkernel --luks --menuconfig all

    Note that `dracut` is also a USE flag; and that the command to use should be

        dracut --hostonly

    One can also use `--kver 3.2.5-hardened` to give a special version string to the generated initramfs.

- [ ] How should the kernel be configured?

    Use the article on [Hardware detection](https://wiki.gentoo.org/wiki/Hardware_detection) to find the right kernel drivers.
    
    In short, use `lspci` and `dmidecode` to find the hardware you are using (or look inside your computer).
    
    Use `lsmod` to read which kernel modules are loaded at any point in time. A full list of them is given with
    
        find /lib/modules/$(uname -r) -type f -name '*.ko*'
    
    The list of kernel modules built into the kernel is given by
    
        cat /lib/modules/$(uname -r)/modules.builtin
    
    Parameters of a loadable module can be set under `/etc/modprobe.d/my_module_name.conf`.
    
    Modules can be unloaded with
    
        modprobe -r my_module
    
    and loaded with
    
        modprobe my_module

- [ ] What is bpftrace useful for? Should collectd be installed?

- [X] Get rid of multilib.

- [X] What does `grub-mkconfig -o /boot/grub/grub.cfg` do? Does it look under `/boot` to generate the GRUB entries?

    The command generates a configuration file using scripts from `/etc/grub.d` and information from `/etc/default/grub`. The scripts can search for kernels and other operating systems, initramfs, and do other things.

- [X] Set up log rotation with anacron.

    This was possible with a custom monthly script that moves logs to `.old` logs under `/var/log`.

- [X] Read https://wiki.gentoo.org/wiki/SSD and enable trimming.

    This was possible by setting a weekly anacron job with `fstrim --fstab`.

- [X] What is the difference between profiles? Can it be pointed out? The difference between stable, desktop and hardened.

    Profiles defined in the Gentoo ebuild repo can be found under `/var/db/repos/gentoo/profiles/`. The profiles are directories; they form a [directed acyclic graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph) (DAG), with the parent nodes defined in the `parent` file of the child node directory. As a DAG, there is a [well-defined linear order](https://en.wikipedia.org/wiki/Topological_sorting) that defines the order of the inheritance operation of parent profiles.

- [X] Fix brightness buttons. Do they show up under `xev`? Does adjustment via `/sys/class/backlight` work?

    The buttons show up under `xev`. For now, I simply edit it to contain a fixed value. The `xbacklight` program might help.
