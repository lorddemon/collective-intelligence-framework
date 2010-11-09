use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'CIF::Client',
    VERSION_FROM      => 'lib/CIF/Client.pm', # finds $VERSION
    PREREQ_PM         => {
        REST::Client    => undef,
        Text::Table     => undef,
        JSON            => undef,
        Getopt::Std     => undef,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/CIF/Client.pm', # retrieve abstract from module
       AUTHOR         => 'Wes Young <wes@barely3am.com>') : ()),
);
