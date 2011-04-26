use inc::Module::Install;

all_from    'lib/CIF/Archive/DataType/Plugin/Infrastructure.pm';

requires    'CIF::Archive'              => '0.01_01';
requires    'Net::CIDR'                 => '0.13';
requires    'Net::Abuse::Utils'         => '0.10';
requires    'Regexp::Common'            => '2.122';
requires    'Regexp::Common::net::CIDR' => '0.02';

WriteAll();
