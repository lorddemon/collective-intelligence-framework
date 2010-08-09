package CIF::WebAPI::infrastructure;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Infrastructure;
use CIF::WebAPI::infrastructure::address;
use CIF::WebAPI::infrastructure::malware;
use CIF::WebAPI::infrastructure::botnet;
use CIF::WebAPI::infrastructure::scan;
use CIF::WebAPI::infrastructure::spam;
use CIF::WebAPI::infrastructure::phishing;
use CIF::WebAPI::infrastructure::networks;
use CIF::Message::Structured;

sub mapIndex {
    my $r = shift;
    my $idx = CIF::WebAPI::mapIndex($r);
    delete($idx->{'rec'});
    return {
       %$idx,
        address     => $r->address(),
        asn         => $r->asn(),
        asn_desc    => $r->asn_desc(),
        cidr        => $r->cidr(),
        cc          => $r->cc(),
        rir         => $r->rir(),
        portlist    => $r->portlist(),
        protocol    => $r->protocol(),
    };
} 

sub aggregateFeed {
    my @recs = @_;

    my @res = @{CIF::WebAPI::aggregateFeed('address',@recs)};
    my @feed = map { mapIndex($_->{'rec'}) } @res;
    return(@feed);
}

sub generateFeed {
    my $response = shift;
    my @recs = @_;

    my @feed = aggregateFeed(@recs);

    $response->data()->{'result'} = \@feed;
    return Apache2::Const::HTTP_OK;
}

sub GET {
    my ($self, $request, $response) = @_;

    my $detecttime = DateTime->from_epoch(epoch => (time() - (84600 * 30)));
    my @recs = CIF::Message::Infrastructure->search_feed($detecttime,10000);
    return generateFeed($response,@recs);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    for(lc($frag)){
        if(/^malware$/){
            $subh = CIF::WebAPI::infrastructure::malware->new($self);
            return $subh;
            last;
        }
        if(/^botnet$/){
            $subh = CIF::WebAPI::infrastructure::botnet->new($self);
            return $subh;
            last;
        }
        if(/^scan$/){
            $subh = CIF::WebAPI::infrastructure::scan->new($self);
            return $subh;
            last;
        }
        if(/^spam$/){
            $subh = CIF::WebAPI::infrastructure::spam->new($self);
            return $subh;
            last;
        }
        if(/^phishing$/){
            $subh = CIF::WebAPI::infrastructure::phishing->new($self);
            return $subh;
            last;
        }
        if(/^networks$/){
            $subh = CIF::WebAPI::infrastructure::networks->new($self);
            return $subh;
            last;
        }
        $subh = CIF::WebAPI::infrastructure::address->new($self);
        $subh->{'address'} = $frag;
        return $subh;
    }
}

1;
