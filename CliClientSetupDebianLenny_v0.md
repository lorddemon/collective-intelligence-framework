# CPAN #
On a clean install of Debian Lenny 5.0.7 you will need to do the following to get CPAN "configured properly".

  1. open cpan (Note: if this is your first time, accept all defaults)
```
sudo cpan
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
  1. make sure build-essential and libssl-dev is installed (for Crypt::SSleay and REST::Client)
```
$> sudo apt-get install build-essential libssl-dev
```