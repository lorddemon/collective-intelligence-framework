package CIF::FeedParser::DecodeGzip;

use strict;
use warnings;
use Compress::Zlib;

sub decode {
    my $data = shift;
    return Compress::Zlib::memGunzip($data);
}

1;
