package CIF::WebAPI::emails::email::cache;
use base 'CIF::WebAPI';

use strict;
use warnings;

my $feed = 'emails_email.feed';

sub GET {
    my ($self,$req,$resp) = @_;
    return $self->cachedFeed($req,$resp,$feed);
}

1;
