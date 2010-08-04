package CIF::WebAPI::infrastructure::botnet;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Infrastructure;

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 30)));
    my $sql = qq{
        detecttime >= '$detecttime'
        AND (lower(impact) LIKE '%botnet%')
        ORDER BY detecttime DESC, created DESC, id DESC
    };

    my @recs = CIF::Message::Infrastructure->retrieve_from_sql($sql);
    return CIF::WebAPI::infrastructure::generateFeed($response,@recs);
}

1;
