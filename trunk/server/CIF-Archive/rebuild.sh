make realclean
rm MANIFEST -f
rm META.yml -f
rm *.tar.gz
perl Makefile.PL
make
make manifest
make dist
