package CIF::WebAPI::domains::cache;
use base 'CIF::WebAPI';

use strict;
use warnings;

my $feed = 'domains.feed';

sub GET {
    my ($self,$req,$resp) = @_;
    return $self->cachedFeed($req,$resp,$feed);
}

1;
