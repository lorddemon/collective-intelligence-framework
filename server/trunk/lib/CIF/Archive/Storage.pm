package CIF::Archive::Storage;

use strict;
use warnings;

use Module::Pluggable require => 1, except => qr/Plugin::\S+::/;
use Encode;

sub format {
    my $class = shift;
    my @bits = split(/\:\:/,$class);
    return(lc($bits[$#bits]));
}

sub prepare { return(0) };

sub convert { return; }

sub from { return; }

sub _is_printable {
    my $self = shift;
    my $data = shift;

    local $@;
    # try decoding this $data with UTF-8
    my $decoded =
        ( Encode::is_utf8($data)
          ? $data
          : eval { Encode::decode("utf-8", $data, Encode::FB_CROAK) } );

    return ! $@ && $decoded =~ /^\p{IsPrint}*$/;
}

1;
