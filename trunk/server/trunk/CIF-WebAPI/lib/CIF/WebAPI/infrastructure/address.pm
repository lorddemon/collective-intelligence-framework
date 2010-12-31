package CIF::WebAPI::infrastructure::address;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Infrastructure;
use Regexp::Common;
use Regexp::Common::net::CIDR;

sub GET {
    my ($self, $request, $response) = @_;

    my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;
    my $arg = $self->address();
    my $apikey = $request->{'r'}->param('apikey');
    my @recs;
    @recs = CIF::Message::Infrastructure->lookup($arg,$apikey,$maxresults);
    unless(@recs){ return Apache2::Const::HTTP_OK; }

    $self->SUPER::GET($request,$response,@recs);
}

sub buildNext {
    my ($self,$frag,$req,$resp) = @_;

    if($req->uri() =~ /($RE{net}{CIDR}{IPv4})$/){
        my $subh = CIF::WebAPI::infrastructure::address->new($self);
        $subh->{'address'} = $1;
        return $subh;
    }
}

1;
