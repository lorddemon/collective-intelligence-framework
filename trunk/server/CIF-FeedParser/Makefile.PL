use inc::Module::Install;

name        'CIF-FeedParser';
all_from    'lib/CIF/FeedParser.pm';

requires    'CIF::DBI'          => '0.01_01';
requires    'LWP::Simple'       => undef;
requires    'LWP::UserAgent'    => undef;
requires    'DateTime'          => undef;
requires    'XML::RSS'          => undef;
requires    'Regexp::Common'    => undef;
requires    'Encode'            => undef;
requires    'File::Type'        => undef;
requires    'Compress::Zlib'    => undef;
requires    'JSON'              => undef;
requires    'Text::CSV'         => undef;
requires    'Config::Simple'    => undef;
requires    'Net::DNS::Resolver'    => undef;
requires    'DateTime::Format::DateParse'   => undef;
requires    'Linux::Cpuinfo'    => '1.7';

install_script  'cif_feed_parser';

WriteAll();
