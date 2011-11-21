package CIF::Message::Spammer;
use base 'CIF::Message::Inet';

use strict;
use warnings;

__PACKAGE__->table('spammers');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'spam';
    return $self->SUPER::insert($info);
}
1;
