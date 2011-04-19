use inc::Module::Install;

name        'CIF-Archive';
all_from    'lib/CIF/Archive.pm';
version_from    'lib/CIF/Archive.pm';

requires    'Class::DBI'                    => '3.0.17';
requires    'OSSP::uuid'                    => '1.0501';
requires    'Config::Simple'                => '4.59';
requires    'DateTime::Format::DateParse'   => '0.04';
requires    'Module::Pluggable'             => '3.6';
requires    'JSON'                          => '2.07';
requires    'Digest::SHA1'                  => '2.10';
requires    'MIME::Base64'                  => '3.06';
requires    'Compress::Zlib'                => '2.008';

WriteAll();
