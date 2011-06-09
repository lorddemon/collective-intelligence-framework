use inc::Module::Install;

name        'CIF-Archive-Storage-Plugin-Iodef';
all_from    'lib/CIF/Archive/Storage/Plugin/Iodef.pm';

requires    'CIF::Archive'              => '0.01';
requires    'XML::IODEF'                => '0.11';
requires    'Regexp::Common'            => '2.122';
requires    'Regexp::Common::net::CIDR' => '0.02';
requires    'XML::Malware'              => '0.0004';

WriteAll();
