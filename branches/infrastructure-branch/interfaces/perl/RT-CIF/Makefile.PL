use inc::Module::Install;

RTx('RT-CIF');
license('GPL Version 2');
author('Barely3am Solutions <wes@barely3am.com>');
version_from('lib/RT/CIF.pm');

{ # check RT version
    my @v = split /\./, "$RT::VERSION";
    unless ($v[0]>=3 && $v[1]>=8 && ($v[2]>=1 || $v[2]eq'HEAD')) {
        die "RT::CIF and newer needs RT 3.8.2 at least, you have $RT::VERSION";
    }
}

# XXX: This should be reported by M::I::RTx
my ($lib_path) = $INC{'RT.pm'} =~ /^(.*)[\\\/]/;
my $local_lib_path = "$RT::LocalPath/lib";
unshift @INC, $local_lib_path, $lib_path;
requires('Net::CIDR');
requires('CIF::DBI');
requires('DateTime');
requires('DateTime::Format::DateParse');
requires('Regexp::Common');
requires('Regexp::Common::net::CIDR');
requires('JSON');
requires('Text::Table');
auto_install();

tests("t/*.t t/*/*.t");

WriteAll();
