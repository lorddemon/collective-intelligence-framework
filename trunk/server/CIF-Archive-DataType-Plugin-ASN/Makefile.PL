use inc::Module::Install;

name        'CIF-Archive-DataType-Plugin-ASN';
all_from    'lib/CIF/Archive/DataType/Plugin/ASN.pm';

requires    'CIF::Archive'      => '0.01_01';
requires    'Module::Pluggable' => '3.6';

WriteAll();
