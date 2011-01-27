package CIF::Message::FeedMessage;
use base 'CIF::Message::Feed';

use strict;
use warnings;

__PACKAGE__->table('feed_message');

sub mapIndex {
    my $self = shift;
    my $r = shift;
    my $idx = $self->SUPER::mapIndex($r);
    delete($idx->{'rec'});
    return {
       %$idx,
    };
}

sub generate {
    my $self = shift;
    my @recs = @_;
    @recs = $self->SUPER::aggregateFeed('uuid',@recs);
    @recs = map { $self->mapIndex($_) } @recs;

    return(@recs);
}

1;
