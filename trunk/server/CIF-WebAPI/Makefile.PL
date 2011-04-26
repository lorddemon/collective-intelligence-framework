use inc::Module::Install;

name        'CIF-WebAPI';
all_from    'lib/CIF/WebAPI.pm';

requires    'Text::Table'   => '1.114';
requires    'Apache2::REST' => '0.06';
requires    'CIF::Archive'  => '0.01_01';
requires    'JSON'          => '2.07';

install_script  'cif_apikeys';

WriteAll();
