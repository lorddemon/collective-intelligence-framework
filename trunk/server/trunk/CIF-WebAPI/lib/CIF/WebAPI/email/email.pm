package CIF::WebAPI::email::email;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Email;

sub GET {
    my ($self, $request, $response) = @_;
    my $maxdays = $request->{'r'}->param('age') || $request->dir_config->{'CIFFeedAgeDefault'} || 30;
    my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;

    my $arg = $self->address();
    my $sql = qq{
        WHERE lower(address) LIKE lower('%$arg%')
        ORDER BY detecttime DESC, created DESC, id DESC
        LIMIT $maxresults
    };
    my @recs = CIF::Message::Email->retrieve_from_sql($sql);
    unless(@recs){ return undef; }

    my @res = map { CIF::WebAPI::email::mapIndex($_) } @recs;

    $response->data()->{'result'} = \@res;
    return Apache2::Const::HTTP_OK;
}

1;
