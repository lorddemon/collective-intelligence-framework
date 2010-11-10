package CIF::WebAPI::infrastructure::scan::cache;
use base 'CIF::WebAPI';

use strict;
use warnings;

my $feed = 'infrastructure_scan.feed';

sub GET {
    my ($self,$req,$resp) = @_;
    return $self->cachedFeed($req,$resp,$feed);
}

1;
