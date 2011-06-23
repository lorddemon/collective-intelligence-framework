make realclean
rm MANIFEST
rm META.yml
rm *.targ.z
perl Makefile.PL
make
make manifest
make dist
