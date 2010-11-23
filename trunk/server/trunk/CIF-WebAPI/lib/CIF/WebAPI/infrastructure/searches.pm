package CIF::WebAPI::infrastructure::searches;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::InfrastructureSearch;
use Regexp::Common;
use Regexp::Common::net::CIDR;

sub GET {
    my ($self, $request, $response) = @_;

    if($self->{'address'}){
        my $arg = $_;
        my @recs = CIF::Message::InfrastructureSearch->search_by_address($arg,$arg,10);

        if(@recs){
            my @res = map { CIF::WebAPI::infrastructure::mapIndex($_) } @recs;
            $response->data()->{'result'} = \@res;
        }
        return Apache2::Const::HTTP_OK;
    } else {
        my $maxdays = $request->{'r'}->param('age') || $request->dir_config->{'CIFFeedAgeDefault'} || 30;
        my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;        
        my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * $maxdays)));
        my @recs = CIF::Message::InfrastructureSearch->search_feed($detecttime,$maxresults);
        return CIF::WebAPI::infrastructure::generateFeed($response,@recs);
    }
}

sub buildNext {
    my ($self,$frag,$req) = @_;
    
    my $h = CIF::WebAPI::infrastructure::searches->new($self);
    $h->{'address'} = $frag;
    if($req->uri() =~ /($RE{net}{CIDR}{IPv4})$/){
        $h->{'address'} = $1;
    }
    return $h;
}

1;
