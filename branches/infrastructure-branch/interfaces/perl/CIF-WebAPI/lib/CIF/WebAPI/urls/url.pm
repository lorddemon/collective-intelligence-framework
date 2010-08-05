package CIF::WebAPI::urls::url;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::URL;

sub GET {
    my ($self, $request, $response) = @_;

    my $arg = $self->url();
    my @recs = CIF::Message::URL->search(address => $arg);
    unless(@recs){ return undef; }
    
    $response->data()->{'result'} = \@recs;
    return Apache2::Const::HTTP_OK;
}

1;
