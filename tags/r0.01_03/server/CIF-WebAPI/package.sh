make realclean
rm *.tar.gz
rm MANIFEST
rm META.yml
perl Makefile.PL
make manifest
make
make dist
