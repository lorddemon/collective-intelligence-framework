use inc::Module::Install;

name        'CIF-Client';
all_from    'lib/CIF/Client.pm';

requires    'REST::Client'      => '171';
requires    'Text::Table'       => '1.116';
requires    'JSON'              => '2.50';
requires    'Compress::Zlib'    => '2.012';
requires    'Config::Simple'    => '4.59';

install_script 'cif';

WriteAll();
