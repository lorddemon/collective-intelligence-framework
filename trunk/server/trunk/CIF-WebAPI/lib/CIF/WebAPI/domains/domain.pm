package CIF::WebAPI::domains::domain;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Domain;

sub GET {
    my ($self, $request, $response) = @_;

    my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;
    my $arg = $self->domain();
    my $apikey = $request->{'r'}->param('apikey');
    my @recs = CIF::Message::Domain->lookup($arg,$apikey,$maxresults);
    unless(@recs){ 
        return Apache2::Const::HTTP_OK; 
    }

    my @res = map { CIF::WebAPI::domains::mapIndex($_) } @recs;

    $response->data()->{'result'} = \@res;
    return Apache2::Const::HTTP_OK;
}

1;
