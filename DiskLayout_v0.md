# Introduction #

Disk layout is important, all the way down to the way you raid out your physical drives. On top of that, you should use LVM where-ever possible in case you run out of space. By default, the best bang for your buck is RAID5, as it will give you a good combination of performance and redundancy. The known current growth rate (levering the default public data avail in etc/) is about 321,000 records per gig (this includes index + archive).

Where possible, you should:

  1. mirror the main OS on it's own set of disks
  1. mirror the postgresql directory (/var/lib/postgres) on it's own set of disks
  1. mirror or RAID5 main archive table space on it's own set of disks
  1. RAID5 or even RAID0 the index table space (it can be rebuilt from the archive if the disks fail, a trade-off for speed)
  1. the WAL logs (pg\_xlog) should be on it's own set of disks due to the constant sequential writes (raid 1 at the least)
  1. give /var at-least 5-10GB of disk space for database logs

# Details #
## Partition Mapping ##
  1. your database system space should be about 5-10G on the lower end
  1. the index partition should grow at about the same rate (maybe more) as your archive partition
  1. starting out; each logical volume (archive/index) should share your free space 40/60.
  1. for 1TB of free space:
    * 400GB for the archive
    * 600GB for the index
  1. you shouldn't use up 100% of your "data drive", leave some slack space incase one of the partitions out-grows the other. For instance, instead of splitting the drive up "400GB / 600GB", split it up "350GB / 550GB", leaving 100GB of free space to re-allocate to either partition as the growth continues

## LVM Example ##

  1. the /etc/fstab would look like:
```
/dev/mapper/vg00-dbsystem        /var/lib/postgresql   ext3    defaults,noatime         0       2
/dev/mapper/vg00-archive            /mnt/archive            ext3    defaults,noatime         0       2
/dev/mapper/vg00-index              /mnt/index               ext3    defaults,noatime         0       2
/dev/mapper/vg00-xlog                /mnt/pg_xlog           ext3    defaults,noatime         0       2
```
  1. after you've created your system via lvm, assuming your "data volume" is on vg00:
```
$ sudo lvcreate -n archive -L 450G vg00
$ sudo lvcreate -n index -L 450G vg00
$ sudo mkdir /mnt/archive
$ sudo mkdir /mnt/index
$ sudo mke2fs -j -m 2 /dev/mapper/vg00-index
$ sudo mke2fs -j /dev/mapper/vg00-archive
$ sudo mount /mnt/archive
$ sudo mount /mnt/index
$ sudo chown postgres:postgres /mnt/archive /mnt/index
$ sudo chmod 750 /mnt/archive /mnt/index
```
  1. setup the pg\_xlog partition
```
$ sudo lvcreate -n xlog -L 2G vg00
$ sudo mkdir /mnt/pg_xlog
$ sudo mke2fs -j /dev/mapper/vg00-xlog
$ sudo mount /mnt/pg_xlog
$ sudo chown postgres:postgres pg_xlog
$ sudo chmod 700 pg_xlog
$ sudo ln -sf /mnt/pg_xlog /var/lib/postgresql/8.4/main/pg_xlog
```
## Example Layout ##
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
## Growth Rate Example ##
```
cif=# select count(*) from archive;
  count  
---------
 4160688
(1 row)

/dev/mapper/ses01-archive
                      197G  6.2G  181G   4% /mnt/archive
/dev/mapper/ses01-index
                      197G  6.8G  187G   4% /mnt/index
```

### Records per gig ###
```
4,160,688 records / 13 (6.2+6.8) gig = 321,000 (rounded up) per gig.
```
### records per day ###

11:47:23 up 6 days, 13:10,  1 user,  load average: 9.10, 8.26, 9.18
```
4,160,688 records / 6 days = 694,000 (rounded up) recs / day
```
### gigs per day ###

this isn't perfect math, but it's close enough for now:
```
694,000 / 321,000 = 2.17 gigs / day
```
### days per total space avail ###
```
394 gig / 2.17 = 181 days
```
### space required ###

that's on the lower end, because we front loaded the data, that number is a bit skewed right now and will normalize over time. For ~ 2 years of storage we'll need:
```
365 * 2 * 2.17 GB = 1600 GB (rounded up)
```