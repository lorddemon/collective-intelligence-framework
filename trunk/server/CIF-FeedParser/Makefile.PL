use inc::Module::Install;

all_from    'lib/CIF/FeedParser.pm';

requires    'CIF::Client'                   => '0.01_01';
requires    'CIF::Archive'                  => '0.01_01';
requires    'LWP::Simple'                   => '5.810';
requires    'LWP::UserAgent'                => '5.813';
requires    'DateTime'                      => '0.47';
requires    'XML::RSS'                      => '1.44';
requires    'Regexp::Common'                => '2.122';
requires    'Encode'                        => '2.23';
requires    'File::Type'                    => '0.22';
requires    'Compress::Zlib'                => '2.012';
requires    'JSON'                          => '2.07';
requires    'Text::CSV'                     => '1.06';
requires    'Config::Simple'                => '4.59';
requires    'Net::DNS::Resolver'            => '737';
requires    'DateTime::Format::DateParse'   => '0.05';
requires    'Linux::Cpuinfo'                => '1.7';

install_script  'cif_feed_parser';

WriteAll();
