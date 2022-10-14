---
layout: post
title: Gentoo notes
---

# Gentoo notes

Here I keep track of my own personal notes on installing and maintaining [Gentoo Linux](https://www.gentoo.org/). It is not yet in a state where it will be much useful to others.

## sysklogd logger

- supports RFC5424 and RFC3164 style log messages.
- local and remote logging available.

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

Continue reading from <https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/Portage#When_Portage_is_complaining>

# Questions

- [X] What does `grub-mkconfig -o /boot/grub/grub.cfg` do? Does it look under `/boot` to generate the GRUB entries?

    The command generates a configuration file using scripts from `/etc/grub.d` and information from `/etc/default/grub`.

- [X] Set up log rotation with anacron.

    This was possible with a custom monthly script that moves logs to `.old` logs under `/var/log`.

- [X] Read https://wiki.gentoo.org/wiki/SSD and enable trimming.

    This was possible by setting a weekly anacron job with `fstrim --fstab`.

- [X] What is the difference between profiles? Can it be pointed out? The difference between stable, desktop and hardened.

    Profiles defined in the Gentoo ebuild repo can be found under `/var/db/repos/gentoo/profiles/`. The profiles are directories; they form a [directed acyclic graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph) (DAG), with the parent nodes defined in the `parent` file of the child node directory. As a DAG, there is a [well-defined linear order](https://en.wikipedia.org/wiki/Topological_sorting) that defines the order of the inheritance operation of parent profiles.

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

- [ ] Get rid of multilib.

- [X] Fix brightness buttons. Do they show up under `xev`? Does adjustment via `/sys/class/backlight` work?

    The buttons show up under `xev`. For now, I simply edit it to contain a fixed value. The `xbacklight` program might help.
