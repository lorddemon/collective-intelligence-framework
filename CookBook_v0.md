# Tips and Tricks #
  * aliases are fun.. vi ~/.profile (or .bashrc):
```
alias ci1='cif -C ~/.cif1'
alias ci2='cif -C ~/.cif2'
alias cif_snort='cif1 -p snort'
alias feed_suspicious_networks='cif -q infrastructure/network -p snort'
```