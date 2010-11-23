package CIF::WebAPI::urls::url;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::URL;

sub GET {
    my ($self, $request, $response) = @_;

    my $arg = $self->url();
    my $apikey = $request->{'r'}->param('apikey');
    my @recs = CIF::Message::URL->lookup($arg,$apikey);
    unless(@recs){ return undef; }

    @recs = map { CIF::WebAPI::urls::mapIndex($_) } @recs;
    
    $response->data()->{'result'} = \@recs;
    return Apache2::Const::HTTP_OK;
}

1;
