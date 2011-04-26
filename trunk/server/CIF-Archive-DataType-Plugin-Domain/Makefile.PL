use inc::Module::Install;

name        'CIF-Archive-DataType-Plugin-Domain';
all_from    'lib/CIF/Archive/DataType/Plugin/Domain.pm';

requires    'CIF::Archive'  => '0.01_01';

WriteAll();
