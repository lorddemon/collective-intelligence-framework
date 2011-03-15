use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'CIF::Archive::Storage::Plugin::Iodef',
    VERSION_FROM      => 'lib/CIF/Archive/Storage/Plugin/Iodef.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/CIF/Archive/Storage/Plugin/Iodef.pm', # retrieve abstract from module
       AUTHOR         => 'Wes Young <wes@>') : ()),
);
