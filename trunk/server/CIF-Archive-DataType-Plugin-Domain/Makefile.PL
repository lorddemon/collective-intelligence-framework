use inc::Module::Install;

all_from    'lib/CIF/Archive/DataType/Plugin/Domain.pm';

requires    'CIF::Archive'  => '0.01_01';

WriteAll();
