use inc::Module::Install;

all_from    'lib/CIF/FeedParser.pm';

requires    'CIF::DBI'          => '0.01_01';
requires    'LWP::Simple'       => '10';
requires    'LWP::UserAgent'    => '10';
requires    'DateTime'          => '10';
requires    'XML::RSS'          => '10';
requires    'Regexp::Common'    => '10';
requires    'Encode'            => '10';
requires    'File::Type'        => '10';
requires    'Compress::Zlib'    => '10';
requires    'JSON'              => '10';
requires    'Text::CSV'         => '10';
requires    'Config::Simple'    => '10';
requires    'Net::DNS::Resolver'    => '10';
requires    'DateTime::Format::DateParse'   => '10';
requires    'Linux::Cpuinfo'    => '1.7';

install_script  'cif_feed_parser';

WriteAll();
