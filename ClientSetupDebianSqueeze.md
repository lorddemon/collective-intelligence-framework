# CPAN #
On a clean install of Debian Squeeze 6.0.4 you will need to do the following to get CPAN "configured properly".

  1. Become root or use sudo if installed
```
su -
```
  1. open cpan (Note: if this is your first time, accept all defaults)
```
cpan
```
  1. Install the newest version of CPAN
```
install CPAN
```
  1. Reload CPAN
```
reload CPAN
```
  1. Exit CPAN
```
exit
```

# Installation #
  1. Become root or use sudo if installed
```
su -
```
  1. make sure build-essential and libssl-dev is installed (for Crypt::SSleay and REST::Client)
```
$> apt-get install build-essential libssl-dev
```
  1. install the client library (accept all defaults)
```
perl -MCPAN -e 'install CIF::Client'
```

# Configuration #
  1. As a standard user (non-root), create the .cif file on the home directory
```
nano /home/$user/.cif
```
  1. setup your [configuration file](GlobalConfigurationFile.md)