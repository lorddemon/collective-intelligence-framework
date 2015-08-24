# Prerequisites #
  * To install the CIF Perl client under Cygwin, you need the following packages:
    * perl (under Perl)
    * make (under Devel)
    * gcc4 (under Devel, note the 4 is important!)
    * openssl (under Net)
    * openssl-devel (under Devel)

# Installation #
  * Start Cygwin and run "perl -MCPAN -e 'install App::cpanminus". Allow defaults and always accept prepending the dependencies.
```
cpanm NANIS/Crypt-SSLeay-0.59_03.tar.gz
perl -MCPAN -e 'install LWP::Protocol::https'
perl -MCPAN -e 'install CIF::Client'
```

# Known Issues #
  * if you get lots of odd errors about "address space needed by some.dll is already occupied", you will need to run [rebaseall](http://www.heikkitoivonen.net/blog/2008/11/26/cygwin-upgrades-and-rebaseall/) from ash within a regular Windows command prompt with admin privileges.

# Credits #
  * https://groups.google.com/d/topic/ci-framework/WkYwiX11Ivo/discussion