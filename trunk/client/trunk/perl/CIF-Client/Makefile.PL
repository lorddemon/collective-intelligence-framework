use inc::Module::Install;

name        'CIF-Client';
all_from    'lib/CIF/Client.pm';
requires    'REST::Client';
requires    'Text::Table';
requires    'JSON';
requires    'Compress::Zlib' => '2.012';
requires    'File::Type' => '0.22';
requires    'Config::Simple' => '4.59';

install_script 'cif';

WriteAll();
