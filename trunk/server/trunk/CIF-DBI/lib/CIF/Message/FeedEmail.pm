package CIF::Message::FeedEmail;
use base 'CIF::Message::Feed';

use strict;
use warnings;

__PACKAGE__->table('feeds_emails');

sub mapIndex {
    my $self = shift;
    my $r = shift;
    my $idx = $self->SUPER::mapIndex($r);
    delete($idx->{'rec'});
    return {
       %$idx,
        address     => $r->address(),
    };
}

sub generate {
    my $self = shift;
    my @recs = @_;
    @recs = $self->SUPER::aggregateFeed('address',@recs);
    @recs = map { $self->mapIndex($_) } @recs;

    return(@recs);
}

1;
