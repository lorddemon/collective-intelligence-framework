package CIF::WebAPI::domain::searches;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::DomainSearch;

sub GET {
    my ($self, $request, $response) = @_;

    if(exists($self->{'domain'})){
        my $arg = $self->domain();
        my @recs = CIF::Message::DomainSearch->search_by_address('%'.$arg.'%',10);
        if(@recs){
            my @res = map { CIF::WebAPI::domain::mapIndex($_) } @recs;
            $response->data()->{'result'} = \@res;
        }
        return Apache2::Const::HTTP_OK;
    } else {
        my $maxdays = $request->{'r'}->param('age') || $request->dir_config->{'CIFFeedAgeDefault'} || 30;
        my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;
        my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * $maxdays)));
        my @recs = CIF::Message::DomainSearch->search_feed($detecttime,$maxresults);
        return CIF::WebAPI::domain::generateFeed($response,@recs);
    }

}

sub buildNext {
    my ($self,$frag,$req) = @_;
    
    my $h = CIF::WebAPI::domain::searches->new($self);
    $h->{'domain'} = $frag;
    return $h;
}

1;
