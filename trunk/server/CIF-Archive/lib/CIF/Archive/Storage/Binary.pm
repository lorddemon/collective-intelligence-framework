package CIF::Archive::Binary;
use base 'CIF::Archive::Storage';

use strict;
use warnings;

use JSON;
use Digest::SHA1 qw/sha1_hex/;
use MIME::Base64;
use Data::Dumper;
use Compress::Zlib;

sub to {
    my $class = shift;
    my $data = shift;

    $data = base64_encode(compress($data));
    my $h = {
        hash_sha1   => sha1_hex($data),
        data        => $data,
    };
    $data = to_json($h);
    return($data);
}

sub from {
    my $class = shift;
    my $data = shift;

    my $h = from_json($data);
    return(undef) unless($h->{'hash_sha1'} eq sha1_hex($h->{'data'}));
    return(uncompress(base64_decode($data)));
}

1;
