package CIF::WebAPI::infrastructure::botnet;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::InfrastructureBotnet;

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 30)));
    my @recs = CIF::Message::InfrastructureBotnet->search_feed($detecttime,10000);
    return CIF::WebAPI::infrastructure::generateFeed($response,@recs);
}

1;
