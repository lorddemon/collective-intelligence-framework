use inc::Module::Install;

all_from    'lib/CIF/Archive/DataType/Plugin/Url.pm';

requires    'CIF::Archive'                          => '0.01_01';
requires    'CIF::Archive::DataType::Plugin::Hash'  => '0.01_01';

WriteAll();
