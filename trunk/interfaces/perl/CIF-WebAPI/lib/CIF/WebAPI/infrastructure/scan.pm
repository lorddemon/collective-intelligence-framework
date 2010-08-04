package CIF::WebAPI::infrastructure::scan;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Scanner;

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 90)));

    my @recs = CIF::Message::Scanner->search_feed($detecttime,10000);
    return CIF::WebAPI::infrastructure::generateFeed($response,@recs);
}

1;
