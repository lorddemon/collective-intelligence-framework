use inc::Module::Install;

name        'CIF-Archive-DataType-Plugin-Feed';
all_from    'lib/CIF/Archive/DataType/Plugin/Feed.pm';

requires    'CIF::Archive'      => '0.01_01';
requires    'Digest::SHA1'      => '2.10';
requires    'MIME::Base64'      => '3.06';
requires    'Compress::Zlib'    => '2.008';
requires    'JSON'              => '2.07';
requires    'Config::Simple'    => '4.59';
requires    'DateTime'          => '0.47';

WriteAll();
