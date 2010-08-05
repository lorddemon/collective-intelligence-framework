package CIF::WebAPI::domains;
use base 'CIF::WebAPI';

use CIF::Message::Domain;
use CIF::WebAPI::domains::domain;
use CIF::WebAPI::domains::feed;
use CIF::WebAPI::domains::nameservers;

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
        ttl         => $r->ttl(),
        class       => $r->class(),
        rdata       => $r->rdata()
    };
}

sub aggregateFeed {
    my @recs = @_;

    my @res = @{CIF::WebAPI::aggregateFeed('address',@recs)};
    my @feed;
    foreach (@res){
        my $idx = mapIndex($_->{'rec'});
        delete($_->{'rec'});
        push(@feed,$idx);
    }
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
    my @recs = CIF::Message::Domain->search_feed($detecttime,10000);
    return generateFeed($response,@recs);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    my $subh;
    for(lc($frag)){
        if(/^nameservers$/){
            $subh = CIF::WebAPI::domains::nameservers->new($self);
            return $subh;
            last;
        }
        $subh = CIF::WebAPI::domains::domain->new($self);
        $subh->{'domain'} = $frag;
        return $subh;
    }
}

1;
