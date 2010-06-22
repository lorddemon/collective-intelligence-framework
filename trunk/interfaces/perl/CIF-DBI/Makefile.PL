use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'CIF::DBI',
    VERSION_FROM      => 'lib/CIF/DBI.pm', # finds $VERSION
    PREREQ_PM         => {
        Class::DBI      => undef,
        XML::IODEF      => 0.07,
        XML::LibXML     => 1.70,
        OSSP::uuid      => undef,
        Digest::SHA1    => undef,
        Digest::MD5     => undef,
        LWP::Simple     => undef,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/CIF/DBI.pm', # retrieve abstract from module
       AUTHOR         => 'Wes Young <wes@barely3am.com>') : ()),
);
