use inc::Module::Install;

name        'CIF-APIKEY';
all_from    'lib/CIF/APIKEY.pm';
reuqires    'Text::Table' => 0;

requires        'Class::DBI';
install_script  'cif_apikeys';

WriteAll();
