package CIF::WebAPI::urls::phishing;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::URLPhishing;

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 90)));

    my @recs = CIF::Message::URLPhishing->search_feed($detecttime,10000);
    return CIF::WebAPI::urls::generateFeed($response,@recs);
}

1;
