use inc::Module::Install;

name        'CIF-WebAPI';
all_from    'lib/CIF/WebAPI.pm';
requires    'Text::Table';
requires    'Class::DBI';
requires    'Apache2::REST';
requires    'CIF::DBI';
requires    'JSON';
requires    'Net::DNS';

install_script  'cif_apikeys';
install_script  'cif_feed';

WriteAll();
