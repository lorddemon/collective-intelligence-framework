package CIF::WebAPI::infrastructure::phishing::cache;
use base 'CIF::WebAPI';

use strict;
use warnings;

my $feed = 'infrastructure_phishing.feed';

sub GET {
    my ($self,$req,$resp) = @_;
    return $self->cachedFeed($req,$resp,$feed);
}

1;
