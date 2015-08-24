# Introduction #



[RC 4.1 bits](https://www.dropbox.com/sh/69g1kl18lzfgd42/gQ_ohBVago)

# Server #
## Server install single host ##

[Server install instructions](https://code.google.com/p/collective-intelligence-framework/wiki/ServerInstall_v1)

| OS | arch | CIF | Result | Date | Person |
|:---|:-----|:----|:-------|:-----|:-------|
| Ubuntu 12.04.3 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz | success | 2013-08-26 | giovino |
| Debian 6.0.7 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz | success | 2013-08-27 | giovino |
| Debian 7.1 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz | success | 2013-08-28 | wy     |
| CentOS 5.9 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz |        | 2013-08-29 | giovino |
| CentOS 6.4 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz | success | 2013-08-27 | wy     |

Success is defined as the following without errors:
  * server installs without error
  * run the following commands without error
```
time cif_crontool -p hourly -d -P
time cif_crontool -p daily -d
time cif_smrt -C /home/cif/.cif -r /opt/cif/etc/zeustracker.cfg -f dropzones -d -P
cif -d -M -q google.com
time cif_feed -d
time cif -M -d -q infrastructure/scan -c 85
```

## Server install multiple host ##

### Smrt install single host ###

[Smrt install instructions](SmrtInstall_v1.md)

| OS | arch | CIF | Result | Date | Person |
|:---|:-----|:----|:-------|:-----|:-------|
| Ubuntu 12.04.3 | amd64 |     |        |      |        |
| Debian 6.0.7 | amd64 |     |        |      |        |
| CentOS 6.4 | amd64 |     |        |      |        |

Success is defined as the following without errors:
  * aaa
  * bbb
  * ccc

### Router install single host ###

[Router install instructions](RouterInstall_v1.md)

| OS | arch | CIF | Result | Date | Person |
|:---|:-----|:----|:-------|:-----|:-------|
| Ubuntu 12.04.3 | amd64 |     |        |      |        |
| Debian 6.0.7 | amd64 |     |        |      |        |
| CentOS 6.4 | amd64 |     |        |      |        |

Success is defined as the following without errors:
  * aaa
  * bbb
  * ccc

### Database interface single host ###

[Database interface install instructions](DbiInstall_v1.md)

| OS | arch | CIF | Result | Date | Person |
|:---|:-----|:----|:-------|:-----|:-------|
| Ubuntu 12.04.3 | amd64 |     |        |      |        |
| Debian 6.0.7 | amd64 |     |        |      |        |
| CentOS 6.4 | amd64 |     |        |      |        |

Success is defined as the following without errors:
  * aaa
  * bbb
  * ccc

### PostgreSQL single host ###

[PostgreSQL install instructions](PostgresqlStandalone_v1.md)

| OS | arch | CIF | Result | Date | Person |
|:---|:-----|:----|:-------|:-----|:-------|
| Ubuntu 12.04.3 | amd64 |     |        |      |        |
| Debian 6.0.7 | amd64 |     |        |      |        |
| CentOS 6.4 | amd64 |     |        |      |        |

Success is defined as the following without errors:
  * aaa
  * bbb
  * ccc

## Upgrade installation ##

[Single server upgrade instructions](Upgrade_v1.md)

| OS | arch | CIF | Result | Date | Person |
|:---|:-----|:----|:-------|:-----|:-------|
| Ubuntu 12.04.3 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz |        |      |        |
| Debian 6.0.7 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz |        |      |        |
| Debian 7.1 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz |        |      |        |
| CentOS 5.9 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz |        |      |        |
| CentOS 6.4 | amd64 | cif-v1-1.0.0-rc.4.1.tar.gz |        |      |        |

Success is defined as the following without errors:
  * server installs without error
  * run the following commands without error
```
time cif_crontool -p hourly -d -P
time cif_crontool -p daily -d
time cif_smrt -C /home/cif/.cif -r /opt/cif/etc/zeustracker.cfg -f dropzones -d -P
cif -d -M -q google.com
time cif_feed -d
time cif -M -d -q infrastructure/scan -c 85
```

# Client #
## CLI client install ##

[CLI install instructions](https://code.google.com/p/collective-intelligence-framework/wiki/ClientInstall_v1)

| OS | arch | CIF | Result | Date | Person |
|:---|:-----|:----|:-------|:-----|:-------|
| Ubuntu 12.04.3 | amd64 | libcif-v1.0.0-rc.4.1.tar.gz |        |      |        |
| Debian 6.0.7 | amd64 | libcif-v1.0.0-rc.4.1.tar.gz |        |      |        |
| Debian 7.1 | amd64 | libcif-v1.0.0-rc.4.1.tar.gz | success | 2013-08-27 | wy     |
| CentOS 5.9 | amd64 | libcif-v1.0.0-rc.4.1.tar.gz |        |      |        |
| CentOS 6.4 | amd64 | libcif-v1.0.0-rc.4.1.tar.gz | success | 2013-08-27 | wy     |
| OS X 10.7 | amd64 | libcif-v1.0.0-rc.4.1.tar.gz |        |      |        |
| OS X 10.8 | amd64 | libcif-v1.0.0-rc.4.1.tar.gz |        |      |        |

Success is defined as the following without errors:
  * aaa
  * bbb
  * ccc

## Web browser client install ##

[Browser install instructions](https://code.google.com/p/collective-intelligence-framework/wiki/ClientInstall_Browser_v1)

| Browser | plugin ver | Query | Submit | Date | Person |
|:--------|:-----------|:------|:-------|:-----|:-------|
| Firefox 23.0.1 |            | v0    | success | 2013-08-27 | wy     |
| Firefox 23.0.1 |            | v1    | success | 2013-08-27 | wy     |
| Chrome 29.0.x |            | v0    | success | 2013-08-27 | wy     |
| Chrome 29.0.x |            | v1    | success | 2013-08-27 | wy     |

Success is defined as the following without errors:

  * Can query to a cif server
  * Can submit to a cif server