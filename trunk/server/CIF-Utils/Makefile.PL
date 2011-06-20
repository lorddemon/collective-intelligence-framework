use inc::Module::Install;

name        'CIF-Utils';
all_from    'lib/CIF/Utils.pm';

requires    'OSSP::uuid'                    => '1.0501';
requires    'Linux::Cpuinfo'                => '1.7';
requires    'DateTime::Format::DateParse'   => '0.04';

WriteAll();
