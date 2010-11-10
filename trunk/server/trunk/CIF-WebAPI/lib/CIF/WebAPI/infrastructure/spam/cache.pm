package CIF::WebAPI::infrastructure::spam::cache;
use base 'CIF::WebAPI';

use strict;
use warnings;

my $feed = 'infrastructure_spam.feed';

sub GET {
    my ($self,$req,$resp) = @_;
    return $self->cachedFeed($req,$resp,$feed);
}

1;
