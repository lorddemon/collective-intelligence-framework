package CIF::WebAPI::urls::phishing;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::PhishingURL;

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 90)));

    my @recs = CIF::Message::PhishingURL->search_feed($detecttime,10000);
    my @feed = @recs;

    $response->data()->{'result'} = \@feed;
    return Apache2::Const::HTTP_OK;
}

1;
