# Introduction #

These instructions are for launching a demo EC2 instance of CIF. The image in its default configuration is not meant for production because it has limited disk space.

A micro instance is good enough for a demo, but performance will be poor if you enable analytics as well. If you want to try analytics, use a larger instance size.

# Details #

Currently, the AMI is only available in the East(Virginia) region.
The AMI ID is **ami-ac15b5c5**.

  * For instructions about configuring and launching an EC2 instance, follow Amazons [Get Started](http://docs.amazonwebservices.com/AWSEC2/latest/GettingStartedGuide/GetStartedLinux.html) instructions.

  * Once at the **Quick Launch Wizard**, select **More Amazon Machine Images** and enter **ami-ac15b5c5** in the search box on the following page. Select the resulting image follow the rest of the Amazon guide to get it online.

  * When configuring the security group, the only inbound ports that need to be permitted are TCP 443 for access to the CIF API and TCP 22 for SSH access.

  * The username required to connect to the instance is **ubuntu**. SSH authentication is restricted to SSH keys and none of the users have passwords.

  * SSH Example:
```
$ ssh -i EC2PrivKey.pem ubuntu@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
```

# Configure CIF #

Once the instance starts up, a few changes need to be made before it will start working.

For more details on what these commands do, refer to the full server install guide [here](ServerInstall_v0.md).


  1. Switch to the cif user.
```
$ sudo su - cif
```
  1. Add a role key that will be used to generate feeds.
```
$ cif_apikeys -u role_everyone_feed -a -g everyone -G everyone
```
  1. Add a CIF user to get an API key that will be used to access CIF with the client. Copy the generated API key for the next step.
```
$ cif_apikeys -u myuser@mydomain.com -a -g everyone -G everyone
```
  1. Edit **~/.cif** and paste the following configuration in to generate feeds and setup the client. Replace the **apikey** value with the key from the previous command. (_existing keys can be listed with **cif\_apikeys -l**_)
```
[cif_feeds]
maxrecords = 10000
severity_feeds = high,medium
confidence_feeds = 95,85
apikeys = role_everyone_feed
max_days = 2
disabled_feeds = hash,rir,asn,countrycode,malware

[client]
host = https://127.0.0.1:443/api
apikey = xx-xx-xx-xx-xx #<<<< Paste in the API key from the last step here
timeout = 60
verify_tls = 0
```
  1. Run cif\_crontool to load data into the database. This should take about 30 minutes to complete. (_Without running this command, CIF won't contain any information until the the hourly and daily cron jobs run._)
```
$ time /opt/cif/bin/cif_crontool -f -d && /opt/cif/bin/cif_crontool -d -p daily && /opt/cif/bin/cif_crontool -d -p hourly
```
  1. Generate the first set of feeds. This could take up to 2 hours to complete.
```
$ time /opt/cif/bin/cif_feeds -d
```
  1. You should now be able to run queries against your server using the cif client. For details on feed queries, refer to the [Feeds wiki](Feeds_v0.md).
Examples:
```
$ cif -q infrastructure/network -c 85 -s medium
```
```
$ cif -q url/botnet -c 85
```
# Enable Analytics and Logging (Optional) #
Logging has not been setup and analytics has been disabled. To enable analytics, uncomment the following line in the crontab for the cif user:
```
#*/5 * * * * /opt/cif/bin/cif_analytic -t 4 -m 4000 &> /dev/null
```
To enable logging, follow the 2nd step of **Finishing up** in the server install [guide](ServerInstall_v0#Finishing_up.md).

# Expand Storage Space #
The CIF data is stored on an LVM volume mounted to **/mnt**. By default it only has 8 GBs of space, which will fill up if the instance is run for more than a few days. Use the following guide to add more space.

  1. [Create a new volume in EC2](http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/ebs-creating-volume.html) and [attach it to your instance](http://docs.amazonwebservices.com/AWSEC2/latest/UserGuide/ebs-attaching-volume.html). (_Note: The volume must be in the same availability zone as your instance or it won't be able to attach._)
    * For an idea of how much data CIF consumes daily, refer to the [disk layout guide](DiskLayout_v0.md).
  1. Run **dmesg** to see what identifier is assigned to the new drive when it attaches.
```
$ dmesg
...
[  685.417268] blkfront device/vbd/2128 num-ring-pages 4 nr_ents 128.
[  686.298455] blkfront: xvdf: barrier or flush: disabled
[  686.306742]  xvdf: unknown partition table
```
  1. Run **pvcreate** on the new drive.
```
$ sudo pvcreate /dev/xvdf
```
  1. Extend the **data** volume group with the new drive.
```
$ sudo vgextend data /dev/xvdf
```
  1. Run **vgdisplay** to determine the free space available.
```
$ sudo vgdisplay
  --- Volume group ---
  VG Name               data
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               47.99 GiB
  PE Size               4.00 MiB
  Total PE              12286
  Alloc PE / Size       2000 / 7.81 GiB
  Free  PE / Size       10286 / 40.18 GiB
  VG UUID               ZXPqfP-bocS-e7yh-f90h-Nf81-WVus-VZwsnV
```
  1. Run **lvextend** with the Free PE number from above.
```
$ sudo lvextend /dev/data/mntvol -l +10286
  Extending logical volume mntvol to 47.99 GiB
  Logical volume mntvol successfully resized
```
  1. Resize the partition
```
$ sudo resize2fs /dev/data/mntvol
resize2fs 1.42 (29-Nov-2011)
Filesystem at /dev/data/mntvol is mounted on /mnt; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 3
Performing an on-line resize of /dev/data/mntvol to 12580864 (4k) blocks.
The filesystem on /dev/data/mntvol is now 12580864 blocks long.
```