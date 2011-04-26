use inc::Module::Install;

name        'CIF-Archive-DataType-Plugin-Countrycode';
all_from    'lib/CIF/Archive/DataType/Plugin/Countrycode.pm';

requires    'CIF::Archive'      => '0.01_01';

WriteAll();
