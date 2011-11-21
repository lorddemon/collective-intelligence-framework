package CIF::Message::SuspiciousNetwork;
use base 'CIF::Message::Inet';

use strict;
use warnings;

__PACKAGE__->table('suspicious_networks');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'suspicious network' unless($info->{'impact'});
    return $self->SUPER::insert($info);
}
1;
