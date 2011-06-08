use inc::Module::Install;

name        'RINO-Client';
all_from    'lib/RINO/Client.pm';

requires    'XML::IODEF'    => '0.11';
requires    'JSON'          => '10';
requires    'Text::Table'   => '10';
requires    'Class::CSV'    => '1.03';

install_script  'rino';

WriteAll();
