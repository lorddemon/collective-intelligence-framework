use inc::Module::Installer;

name        'CIF-DBI';
all_from    'lib/CIF/DBI.pm';

requires    'Class::DBI'    => '3.0.17';
requires    'XML::IODEF'    => '0.07';
requires    'XML::LibXML'   => '1.70';
requires    'OSSP::uuid'    => '1.5.1';
requires    'Digest::SHA1'  => '2.12';
requires    'Digest::MD5'   => '2.39';
requires    'Net::CIDR'     => '0.13';
requires    'Net::Abuse::Utils' => '0.11';
requires    'XML::Malware'  => '0.00_4';

WriteAll();
