use inc::Module::Install;

name        'RINO-Client';
all_from    'lib/RINO/Client.pm';

requires    'XML::IODEF'      => '.1001';
requires    'XML::Simple'       => '2.18';

WriteAll();
