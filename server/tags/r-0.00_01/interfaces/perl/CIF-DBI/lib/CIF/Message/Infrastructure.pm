package CIF::Message::Infrastructure;
use base 'CIF::Message::Inet';

use strict;
use warnings;

__PACKAGE__->table('infrastructure');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'infrastructure' unless($info->{'impact'});
    $self->SUPER::insert($info);
}
1;
