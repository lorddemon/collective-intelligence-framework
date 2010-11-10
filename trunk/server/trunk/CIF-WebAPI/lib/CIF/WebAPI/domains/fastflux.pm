package CIF::WebAPI::domains::fastflux;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::DomainFastflux;
use DateTime;

sub GET {
    my ($self, $request, $response) = @_;
    my $maxdays = $request->{'r'}->param('age') || $request->dir_config->{'CIFFeedAgeDefault'} || 30;
    my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;


    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * $maxdays)));
    my @recs = CIF::Message::DomainFastflux->search_feed($detecttime,$maxresults);
    return CIF::WebAPI::domains::generateFeed($response,@recs);
}

1;
