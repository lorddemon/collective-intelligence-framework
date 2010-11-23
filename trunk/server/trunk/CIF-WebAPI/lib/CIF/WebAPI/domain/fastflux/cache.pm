package CIF::WebAPI::domains::fastflux::cache;
use base 'CIF::WebAPI';

use strict;
use warnings;

my $feed = 'domains_fastflux.feed';

sub GET {
    my ($self,$req,$resp) = @_;
    return $self->cachedFeed($req,$resp,$feed);
}

1;
