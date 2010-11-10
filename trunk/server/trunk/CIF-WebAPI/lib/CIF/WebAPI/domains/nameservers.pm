package CIF::WebAPI::domains::nameservers;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::DomainNameserver;
use DateTime;

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 30)));
    my @recs = CIF::Message::DomainNameserver->search_feed($detecttime,10000);
    return CIF::WebAPI::domains::generateFeed($response,@recs);
}

sub buildNext {
    my ($self,$req,$resp) = @_;
    warn $self->dir_conf('CIFCacheDir');
}

1;
