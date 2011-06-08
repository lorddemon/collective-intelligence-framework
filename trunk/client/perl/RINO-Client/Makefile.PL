use inc::Module::Install;

name        'RINO-Client';
all_from    'lib/RINO/Client.pm';

requires    'XML::IODEF'    => '0.11';
requires    'JSON'          => '2.07';
requires    'Text::Table'   => '1.114';
requires    'Class::CSV'    => undef;

install_script  'rino';

WriteAll();
