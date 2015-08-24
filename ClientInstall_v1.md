**Before you Begin**

**Table of Contents**


# Preamble #

---

A semi-complete [ChangeLog](https://github.com/collectiveintel/cif-v1/blob/master/ChangeLog) of v1

A list of known [issues](https://github.com/collectiveintel/cif-v1/issues) for v1

## Backwards Compatibility ##
  * as of v1, the 'CIF-Client' is now part of the client side library 'libcif'
  * the deprecated "CIF::Client" (via CPAN) cannot be used with a v1 instance
  * the v0 client **MUST** be [removed](ClientRemoval_v0.md) first if it's installed

## Caveats ##
  * libcif cannot be installed via CPAN at this time
  * libcif provides:
    * CIF::Client library to build (perl) applications against
    * the 'cif' command
    * by default, is installed to '/opt/cif', can be changed with the '--prefix' flag when running './configure'
  * to build applications in other languages, simply pipe the 'cif' command with '-p json' which will pipe stripped down (non-iodef) json key-pairs to your application
  * currently, libcif defaults to the /opt/cif environment due to it's perl nature
  * future versions of libcif will be written in a lower level language (more portable) and provide high level language bindings
  * a sample python client can be found [here](https://github.com/collectiveintel/cif-client-python/tree/v1)

# Installation #
## Required Dependencies ##
  * (stable) [Debian Squeeze (6.x)](ClientInstall_DebianSqueeze_v1.md)
  * (stable) [Debian Wheezy (7.x)](ClientInstall_DebianWheezy_v1.md)
  * (stable) [Ubuntu 12](ClientInstall_Ubuntu12_v1.md)
  * (stable) [CentOS 6](ClientInstall_CentOS6_v1.md)
  * (testing) [OSX 7](ClientInstall_OSX7_v1.md)
  * (unstable) [OSX 8](ClientInstall_OSX8_v1.md)
## Package ##
  1. download the latest [libcif-v1.x.x](https://github.com/collectiveintel/cif-v1/releases), BE SURE TO PICK THE RIGHT DOWNLOAD (green button).
```
$ tar -xzvf libcif-v1.x.x.tar.gz
$ cd libcif-v1.x.x
$ ./configure && make testdeps
$ sudo make install
```
## Configuration ##
## Environment ##
  1. create a default configuration file
```
$ vi ~/.cif
```
  1. add the following as a template
```
# the simple stuff
[client]
# the apikey for your client
apikey = XXXXXX-XXX-XXXX

[client_http]
host = https://localhost:443/api
verify_tls = 0
```
  1. set up your user's environment (typically ~/.profile)
```
if [ -d "/opt/cif/bin" ]; then
    PATH="/opt/cif/bin:$PATH"
fi
```
  1. reload your profile
```
$ source .profile
```

# Examples #
For a more complete overview, see the [Generating Feeds](Feeds_v1.md) page.
## Infrastructure ##
  1. ipv4 query:
```
$ cif -q 130.201.0.2
```
  1. ipv4 prefix query:
```
$ cif -q 130.201.0.0/16
```
## FQDN ##
  1. top level domain query:
```
$ cif -q example.com
```
  1. simple domain query:
```
$ cif -q test.yahoo.com
```
## URL ##
  1. simple url query:
```
$ cif -q 'http://www.yahoo.com/example.html'
```
## Malware ##
  1. simple sha1 hash lookup:
```
$ cif -q a5135ec6f2322cc12f3d9daa38dfb358
```
# Features #
```
$ cif -h
Usage: perl /opt/cif/bin/cif -q xyz.com

Standard Options:
    -h  --help:             this message
    -C  --config:           specify cofiguration file, default: /home/<username>/.cif

Query Options:
    -q  --query:            query string
    -n  --nolog:            perform a "silent" query (no log query), default: 0
    -l  --limit:            set the default result limit (queries only), default is set on server, usually around 500.
    -c  --confidence:       lowest tolerated confidence (0.00 -- 100.00), default

Format Options:
    -p  --plugin:           output plugin ('Table','Snort','Csv','Json','Html'), default: Table
    -f  --fields:           set default output fields for default table display
    -S  --summary:          consolidated Text::Table output (default: True)
    -N  --nomap:            don't map restrictions
    -g  --guid:             filter by a specific group id (guid), ex: group1.example.com
    -G  --groupmap:         turn group mapping (guid to 'group name') on/off, default: 1
    -e  --exclude:          exclude a specific assessment (search,botnet,malware, etc).
    -x  --csv-noheader:     don't display the header when using the csv plugin

Nonstandard Options:
    -z                      compact address field to 32 chars, applies only to defalt table output, default: 1 (0 turns it off)
    -I  --round-confidence: round (down) confidence to the nearest integer, default 0.
    -m                      return only the results where "$DETECTTIME >= $TODAY (UTC)" (the most recent results from a feed)
    -F  --filter-me:        exclude results based on my apikey (usually logged searches)

Example Queries:

    $> perl /opt/cif/bin/cif -q 1.2.3.4
    $> perl /opt/cif/bin/cif -q 1.2.3.0/24
    $> perl /opt/cif/bin/cif -q f8e74165fb840026fd0fce1fd7d62f5d0e57e7ac
    $> perl /opt/cif/bin/cif -q hut2.ru
    $> perl /opt/cif/bin/cif -q hut2.ru,f8e74165fb840026fd0fce1fd7d62f5d0e57e7ac
    $> perl /opt/cif/bin/cif hut2.ru

    $> perl /opt/cif/bin/cif -q malware
    $> perl /opt/cif/bin/cif -q malware
    $> perl /opt/cif/bin/cif -q infrastructure/botnet -p Snort
    $> perl /opt/cif/bin/cif -q domain/malware -p bindzone -c 95
    $> perl /opt/cif/bin/cif -q domain -c 40

    $ /opt/cif/bin/cif -d -q example.com -e search

Configuration:

    configuration file ~/.cif should be readable and look something like:

    [client]
    apikey = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    driver = 'http'

    # table_nowarning = 1
    # csv_noseperator = 1

    [client_http]
    host = https://example.com:443/api
    timeout = 60

    # add this if you have a self signed cert
    verify_tls = 0

    # proxy settings
    # proxy = https://localhost:5555

Plugin Specific Configurations:

    Table:

        [client]
        table_nowarning = 1

    Csv:
        [client]
        # when we filter out commas in the various fields, do we replace them with "_"'s or just spaces
        csv_noseperator = 1

    Bindzone:

        [client]
        bindzone_path = /etc/namedb/

    Snort:

        [client]
        snort_startsid = 10000000
```