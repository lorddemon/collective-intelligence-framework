# Introduction #
This assumes a clean install of Ubuntu 12.04 with all base system updates applied. There are some duplicates between the system wide deps and CPAN, this can be ignored. In some cases we need an upgraded version of the module and by installing the system-wide dependency first, it installs some of the other deps via that mechanism too, simplifying the install. Sometimes it's easier to get bugs fixes into CPAN faster than the more stable Debian/Ubuntu tree.

**Table of Contents**


# Details #
## Caveats ##

---

### Perl 5.14 CPAN ###
Newer versions of Perl / CPAN have made some [changes](http://sipb.mit.edu/doc/cpan/) to their configuration defaults that affect how packages are installed. If you're not familiar with customizing CPAN, you'll need to start out by boot-strapping your own config. This way it'll install dependencies system wide by default instead of to a local home directory. CIF may be adapted to this in the future, but this is a work-around for now.
  1. boot-strap the default CPAN config
```
$ sudo su - root
$ mkdir -p /root/.cpan/CPAN
$ vi /root/.cpan/CPAN/MyConfig.pm
```
  1. copy / paste the following into `MyConfig.pm`
```
$CPAN::Config = {
  'applypatch' => q[],
  'auto_commit' => q[0],
  'build_cache' => q[100],
  'build_dir' => q[/root/.cpan/build],
  'build_dir_reuse' => q[0],
  'build_requires_install_policy' => q[yes],
  'bzip2' => q[/bin/bzip2],
  'cache_metadata' => q[1],
  'check_sigs' => q[0],
  'colorize_output' => q[0],
  'commandnumber_in_prompt' => q[1],
  'connect_to_internet_ok' => q[1],
  'cpan_home' => q[/root/.cpan],
  'ftp_passive' => q[1],
  'ftp_proxy' => q[],
  'getcwd' => q[cwd],
  'gpg' => q[/usr/bin/gpg],
  'gzip' => q[/bin/gzip],
  'halt_on_failure' => q[0],
  'histfile' => q[/root/.cpan/histfile],
  'histsize' => q[100],
  'http_proxy' => q[],
  'inactivity_timeout' => q[0],
  'index_expire' => q[1],
  'inhibit_startup_message' => q[0],
  'keep_source_where' => q[/root/.cpan/sources],
  'load_module_verbosity' => q[none],
  'make' => q[/usr/bin/make],
  'make_arg' => q[],
  'make_install_arg' => q[],
  'make_install_make_command' => q[/usr/bin/make],
  'makepl_arg' => q[INSTALLDIRS=site],
  'mbuild_arg' => q[],
  'mbuild_install_arg' => q[],
  'mbuild_install_build_command' => q[sudo ./Build],
  'mbuildpl_arg' => q[--installdirs site],
  'no_proxy' => q[],
  'pager' => q[/usr/bin/less],
  'patch' => q[/usr/bin/patch],
  'perl5lib_verbosity' => q[none],
  'prefer_external_tar' => q[1],
  'prefer_installer' => q[MB],
  'prefs_dir' => q[/root/.cpan/prefs],
  'prerequisites_policy' => q[follow],
  'scan_cache' => q[atstart],
  'shell' => q[/bin/bash],
  'show_unparsable_versions' => q[0],
  'show_upload_date' => q[0],
  'show_zero_versions' => q[0],
  'tar' => q[/bin/tar],
  'tar_verbosity' => q[none],
  'term_is_latin' => q[1],
  'term_ornaments' => q[1],
  'test_report' => q[0],
  'trust_test_report_history' => q[0],
  'unzip' => q[],
  'use_sqlite' => q[0],
  'version_timeout' => q[15],
  'wget' => q[/usr/bin/wget],
  'yaml_load_code' => q[0],
  'yaml_module' => q[YAML],
};
1;
__END__
```
  1. when you run the first "perl -MCPAN install ..." command, it will auto-configure a list of local CPAN mirrors for you
## Dependencies Installation ##

---

  1. Install the base dependencies from the Ubuntu repositories (as root)
```
$ aptitude -y install build-essential libossp-uuid-perl libmodule-install-perl libregexp-common-perl libunicode-string-perl libconfig-simple-perl libmodule-pluggable-perl libtry-tiny-perl libclass-accessor-perl pkg-config libjson-xs-perl perl-modules libdigest-sha-perl libsnappy-dev libdatetime-format-dateparse-perl liblwp-protocol-https-perl libnet-patricia-perl libnet-ssleay-perl liblog-dispatch-perl libregexp-common-net-cidr-perl libtext-table-perl libdatetime-perl libencode-perl libmime-base64-perl libhtml-table-perl libssl-dev
```
  1. Install the remaining perl dependencies from CPAN (as root)
```
$ PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Google::ProtocolBuffers,Iodef::Pb::Simple,Compress::Snappy,Snort::Rule,Log::Dispatch,Net::SSLeay,LWP::Protocol::https'
```
### Default CIF user ###

---

Create your "cif" user/group (the configure script will default to this user "cif")
```
$ sudo adduser --disabled-password --gecos '' cif
```
Continue with the libcif [installation](ClientInstall_v1#Package.md)