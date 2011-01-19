use inc::Module::Install;

name        'CIF-Client';
all_from    'lib/CIF/Client.pm';

requires    'REST::Client'      => '164';
requires    'Text::Table'       => '1.114';
requires    'JSON'              => '2.07';
requires    'Compress::Zlib'    => '2.008';
requires    'Config::Simple'    => '4.58';
requires    'Snort::Rule'       => '1.07';
requires    'Class::Accessor'   => '0.31';
requires    'Digest::MD5'        => '2.36';
requires    'Digest::SHA1'       => '2.11';

install_script 'cif';

WriteAll();
