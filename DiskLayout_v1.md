# Introduction #

---

Disk layout is important, all the way down to the way you raid out your physical drives. In addition to that, LVM should be used where-ever possible in the event that the system runs low on disk space. By default, the best bang for your buck is RAID5, as it will give you a good combination of performance and redundancy.

**Table of Contents**


## Small Install ##

---

This includes instances where only the default publicly available data is being used, and/or running on a vm, etc. Should read/write performance become an issue, adapting your instance to the large install will help.

  1. setup the archive and index data directories, the permissions will be set later in the install.
```
$ sudo mkdir /mnt/archive
$ sudo mkdir /mnt/index
$ sudo chmod 770 /mnt/index
$ sudo chmod 770 /mnt/archive
```
  1. should look like
```
$ ls -l /mnt/
```
```
total 8
drwxrwx--- 2 root root 4096 Jan  3 18:02 archive
drwxrwx--- 2 root root 4096 Jan  3 18:02 index
```

Continue with [Required applications and dependencies](ServerInstall_v1#Required_applications_and_dependencies.md)

## Large Install ##

---

This includes bare-metal instances where large data-sets, in-addition to the default publicly available data is being used.

Where possible, you should:

  1. mirror the main OS on it's own set of disks
  1. mirror the postgresql directory (/var/lib/postgres) on it's own set of disks
  1. mirror or RAID5 main archive table space on it's own set of disks
  1. RAID5 or even RAID0 the index table space (it can be rebuilt from the archive if the disks fail, a trade-off for size and speed)
  1. the WAL logs (pg\_xlog) should be on it's own set of disks due to the constant sequential writes (raid+1 if possible)
  1. give /var at-least 10-20GB of disk space for database logs

### Partition Mapping ###
  1. your database system space should be about 10-20G on the lower end
  1. the index partition should grow at about the same rate (maybe more) as your archive partition
  1. starting out; each logical volume (index/archive) should share your free space 60/40.
  1. for 1TB of free space:
    * 400GB for the archive
    * 600GB for the index
  1. you shouldn't use up 100% of your "data drive", leave some slack space incase one of the partitions out-grows the other. For instance, instead of splitting the drive up "400GB / 600GB", split it up "350GB / 550GB", leaving 100GB of free space to re-allocate to either partition as the growth continues

### LVM Example ###

---

  1. the /etc/fstab would look like:
```
/dev/mapper/vg00-dbsystem        /var/lib/postgresql   ext3    defaults,noatime         0       2
/dev/mapper/vg00-archive            /mnt/archive            ext3    defaults,noatime         0       2
/dev/mapper/vg00-index              /mnt/index               ext3    defaults,noatime         0       2
/dev/mapper/vg00-xlog                /mnt/pg_xlog           ext3    defaults,noatime         0       2
```
  1. after you've created your system via lvm, assuming your "data volume" is on vg00, we'll set the ownership permissions later in the guide:
```
$ sudo lvcreate -n archive -L 450G vg00
$ sudo lvcreate -n index -L 450G vg00
$ sudo mkdir /mnt/archive
$ sudo mkdir /mnt/index
$ sudo mke2fs -j -m 2 /dev/mapper/vg00-index
$ sudo mke2fs -j /dev/mapper/vg00-archive
$ sudo mount /mnt/archive
$ sudo mount /mnt/index
$ sudo chmod 750 /mnt/archive /mnt/index
```
  1. setup the pg\_xlog partition, we'll set the ownership permissions later in the guide:
```
$ sudo lvcreate -n xlog -L 2G vg00
$ sudo mkdir /mnt/pg_xlog
$ sudo mke2fs -j /dev/mapper/vg00-xlog
$ sudo mount /mnt/pg_xlog
$ sudo chmod 700 pg_xlog
```
### Example Layout ###

---

```
/dev/mapper/vg00-root  6.5G  2.2G  4.0G  35% /
tmpfs                 2.0G     0  2.0G   0% /lib/init/rw
udev                  2.0G   96K  2.0G   1% /dev
tmpfs                 2.0G     0  2.0G   0% /dev/shm
/dev/sda1             228M   31M  186M  15% /boot
/dev/mapper/vg00-home  4.6G  200M  4.2G   5% /home

/dev/mapper/vg01-archive 350G   1G  349G  1% /mnt/archive
/dev/mapper/vg02-index 550G   1G  549G  1% /mnt/index
```

Continue with [Required applications and dependencies](ServerInstall_v1#Required_applications_and_dependencies.md)