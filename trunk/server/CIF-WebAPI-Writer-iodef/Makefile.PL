use inc::Module::Install;

name        'CIF-WebAPI-Writer-iodef';
all_from    'lib/CIF/WebAPI/Writer/iodef.pm';

requires    'CIF::WebAPI'   => '0.01_01';
requires    'XML::IODEF'    => '0.09';

WriteAll();
