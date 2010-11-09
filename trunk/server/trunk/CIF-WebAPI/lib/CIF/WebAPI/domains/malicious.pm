package CIF::WebAPI::domains::malicious;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::DomainMalicious;
use DateTime;

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 30)));
    my @recs = CIF::Message::DomainMalware->search_feed($detecttime,10000);
    return CIF::WebAPI::domains::generateFeed($response,@recs);
}

1;
