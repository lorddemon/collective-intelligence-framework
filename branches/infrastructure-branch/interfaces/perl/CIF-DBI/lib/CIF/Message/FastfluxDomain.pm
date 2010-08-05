package CIF::Message::FastfluxDomain;
use base 'CIF::Message::Domain';

use strict;
use warnings;

__PACKAGE__->table('fastflux_domains');
__PACKAGE__->has_a(uuid => 'CIF::Message');

sub insert {
    my $self = shift;
    my $info = {%{+shift}};
    
    $info->{'impact'} = 'fastflux domain' unless($info->{'impact'});
    $self->SUPER::insert($info);
}
1;
