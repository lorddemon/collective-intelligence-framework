use inc::Module::Install;

RTx('RT-CIFMinimal');
license('GPL Version 2');
author('Barely3am Solutions <wes@barely3am.com>');
version_from('lib/RT/RENISAC.pm');

{ # check RT version
    my @v = split /\./, "$RT::VERSION";
    unless ($v[0]>=3 && $v[1]>=8 && ($v[2]>=1 || $v[2]eq'HEAD')) {
        die "SES v1 and newer needs RT 3.8.2 at least, you have $RT::VERSION";
    }
}

# XXX: This should be reported by M::I::RTx
my ($lib_path) = $INC{'RT.pm'} =~ /^(.*)[\\\/]/;
my $local_lib_path = "$RT::LocalPath/lib";
unshift @INC, $local_lib_path, $lib_path;
requires('DateTime::Format::DateParse');
requires('Snort::Rule');
requires('Regexp::Common');
requires('Regexp::Common::net::CIDR');
requires('XML::IODEF::PhraudReport');
requires('Net::Abuse::Utils');
requires('JSON');
requires('XML::Simple');
requires('Text::Table');
requires('LWP::UserAgent');
requires('CIF::Client');
auto_install();

tests("t/*.t t/*/*.t");

WriteAll();
