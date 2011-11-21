use inc::Module::Install;

name        'CIF-WebAPI';
all_from    'lib/CIF/WebAPI.pm';

requires    'Text::Table'   => '1.114';
requires    'Class::DBI'    => '3.0.17';
requires    'Apache2::REST' => '0.06';
requires    'CIF::DBI'      => '0.00_2';
requires    'JSON'          => '2.07';
requires    'Net::DNS'      => '0.65';
requires    'Config::Simple'    => '4.59';
requires    'Pod::POM'      => '0.25';

install_script  'cif_apikeys';
install_script  'cif_feeds';

WriteAll();
