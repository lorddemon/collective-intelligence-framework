package CIF::FeedParser::Plugin::Decode::Zip;

use strict;
use warnings;
use IO::Uncompress::Unzip qw(unzip $UnzipError);

sub decode {
    my $class = shift;
    my $data = shift;
    my $type = shift;
    return unless($type =~ /zip/ || $type !~ /gzip/);

    my $unzipped;
    unzip \$data => \$unzipped, Name => 'top-1m.csv' || die('unzip failed: '.$UnzipError);
    return $unzipped;
}

1;
