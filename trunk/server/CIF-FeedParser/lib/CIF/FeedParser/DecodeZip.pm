package CIF::FeedParser::DecodeZip;

use strict;
use warnings;
use IO::Uncompress::Unzip qw(unzip $UnzipError);

sub decode {
    my $data = shift;
    my $unzipped;
    unzip \$data => \$unzipped, Name => 'top-1m.csv' || die('unzip failed: '.$UnzipError);
    return $unzipped;
}

1;
