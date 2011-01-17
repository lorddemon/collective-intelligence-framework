use inc::Module::Install;

name        'CIF-DBI';
all_from    'lib/CIF/DBI.pm';

requires    'Class::DBI'    => '3.0.17';
requires    'XML::IODEF'    => '0.07';
requires    'XML::LibXML'   => '1.70';
requires    'OSSP::uuid'    => '1.0501';
requires    'Digest::SHA1'  => '2.11';
requires    'Digest::MD5'   => '2.3601';
requires    'Net::CIDR'     => '0.13';
requires    'Net::Abuse::Utils' => '0.1';
requires    'XML::Malware'  => '0.00_4';

install_script  'cif_infra_wl';
install_script  'cif_domains_wl';

WriteAll();
