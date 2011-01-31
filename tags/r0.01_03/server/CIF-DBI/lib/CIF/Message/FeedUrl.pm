package CIF::Message::FeedUrl;
use base 'CIF::Message::Feed';

use strict;
use warnings;

__PACKAGE__->table('feed_url');

sub mapIndex {
    my $self = shift;
    my $r = shift;
    my $idx = $self->SUPER::mapIndex($r);
    delete($idx->{'rec'});
    return {
       %$idx,
        address     => $r->address(),
        url_md5     => $r->url_md5(),
        url_sha1    => $r->url_sha1(),
        malware_md5 => $r->malware_md5(),
        malware_sha1    => $r->malware_sha1(),
    };
}

sub generate {
    my $self = shift;
    my @recs = @_;
    @recs = $self->SUPER::aggregateFeed('url_md5',@recs);
    @recs = map { $self->mapIndex($_) } @recs;

    return(@recs);
}

1;
