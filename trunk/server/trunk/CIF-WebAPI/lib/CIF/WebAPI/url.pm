package CIF::WebAPI::url;
use base 'CIF::WebAPI';

use strict;
use warnings;

use CIF::Message::Url;
use CIF::WebAPI::url::address;

sub mapIndex {
    my $r = shift;
    my $idx = CIF::WebAPI::mapIndex($r);
    delete($idx->{'rec'});
    return {
        %$idx,
        address     => $r->address(),
        url_md5     => $r->url_md5(),
        url_sha1    => $r->url_sha1(),
        malware_md5 => $r->malware_md5(),
        malware_sha1 => $r->malware_sha1(),
    };
}

sub aggregateFeed {
    my @recs = @{CIF::WebAPI::aggregateFeed('url_md5',@_)};
    my @feed = map { mapIndex($_->{'rec'}) } @recs;
    return(@feed);
}

sub generateFeed {
    my $resp = shift;
    my @feed = aggregateFeed(@_);
    $resp->data()->{'result'} = \@feed;
    return Apache2::Const::HTTP_OK;
}

sub GET {
    my ($self, $request, $response) = @_;
    return generateFeed($response,$self->SUPER::GET($request,$response));
}

sub buildNext {
    my ($self,$frag,$req) = @_;    

    if(lc($frag) =~ /^([a-f0-9]{32})|([a-f0-9]{40})$/){
        my $subh = CIF::WebAPI::url::address->new($self);
        $subh->{'address'} = lc($frag);
        return $subh;
    }
    return $self->SUPER::buildNext($frag,$req);
}

1;
