package CIF::WebAPI::emails;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Email;
use CIF::WebAPI::emails::email;
use CIF::WebAPI::emails::cache;

sub mapIndex {
    my $r = shift;
    my $idx = CIF::WebAPI::mapIndex($r);
    delete($idx->{'rec'});

    return {
        %$idx,
        address     => $r->address(),
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
    my @recs = CIF::Message::Email->search_feed($detecttime,10000);
    return generateFeed($response,@recs);
}

sub buildNext {
    my ($self,$frag,$req) = @_;

    if(lc($frag) eq 'cache'){
        return CIF::WebAPI::emails::cache->new($self);
    }

    my $subh = CIF::WebAPI::emails::email->new($self);
    $subh->{'address'} = $frag;
    return $subh;
}

1;
