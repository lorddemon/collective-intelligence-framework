use inc::Module::Install;

name        'CIF-WebAPI-Writer-atom';
all_from    'lib/CIF/WebAPI/Writer/atom.pm';

requires    'CIF::WebAPI'   => '0.01_01';
requires    'XML::Atom'     => '0.28';

WriteAll();
