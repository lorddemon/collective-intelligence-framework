package CIF::WebAPI::url::address;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Url;

sub GET {
    my ($self, $request, $response) = @_;

    my $arg = $self->address();
    my $apikey = $request->{'r'}->param('apikey');
    my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;
    my @recs = CIF::Message::Url->lookup($arg,$apikey,$maxresults);
    unless(@recs){ 
        return Apache2::Const::HTTP_OK;
    }

    @recs = map { CIF::WebAPI::url::mapIndex($_) } @recs;
    
    $response->data()->{'result'} = \@recs;
    return Apache2::Const::HTTP_OK;
}

1;
